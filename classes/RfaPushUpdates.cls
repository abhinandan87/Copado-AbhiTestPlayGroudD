/*  @author: Akash Punera
*   @date: 25 Oct 2022
*   @description: Class to push request/response from source org to hub org
*/
public with Sharing class RfaPushUpdates implements Queueable, Database.AllowsCallouts{
    
    string reqFields;
    string resFields;
    string reqObjectName;
    string resObjectName;
    string resRelationName;
    string recFilter;
    string sourceDivision;
    static string[] toAddresses = new string[]{};
    boolean sendStatusEmails = false;
    String emailSubject;
    String emailBody;
    public map<String,String> mapExternalIdToId = new map<String,String>();

    /*  @author: Akash Punera
    *   @date: 28 Oct 2022
    *   @description: Method to populate variables from custom metadata
    */
    public void setConfigurations() {
        //Adding query instead of get instance method as the later has a limit of 255 char on fields queried
        S1_RFA_Configurations__mdt config = [SELECT    id, Request_Fields__c, Response_Fields__c, Request_Object_API__c, Response_Object_API__c,
                                                    Response_Child_API__c, Filter_String__c, Division_Name__c, To_Email_Address__c, Send_Email_Notification__c, 
                                                    Email_Body_Prefix__c, Email_Subject__c
                                            FROM    S1_RFA_Configurations__mdt WHERE DeveloperName  = 'Default'];
        reqFields = config.Request_Fields__c;
        resFields = config.Response_Fields__c;
        reqObjectName = config.Request_Object_API__c;
        resObjectName = config.Response_Object_API__c;
        resRelationName = config.Response_Child_API__c;
        recFilter = config.Filter_String__c;
        sourceDivision = config.Division_Name__c;
        toAddresses.addAll(config?.To_Email_Address__c?.split(','));
        sendStatusEmails = config.Send_Email_Notification__c;
        emailBody = config.Email_Body_Prefix__c;
        emailSubject = config.Email_Subject__c;
    }
        
    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: Method to make callout to push changes to the Hub
    */
    public void pushUpdatesToHub() {
        try{
            setConfigurations();
            string response;
            string reqBody = createRequestBody();
            response = makeCallout('upsertRecords',reqBody);
            updateRecords(response);
        }catch (Exception ex) {
            System.debug('Exception '+Ex.getMessage()+'--'+ex.getStackTraceString());
            if(sendStatusEmails) {
                sendNotification(Ex.getMessage()+'--'+ex.getStackTraceString());
            }
        }
    }
    
    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: Send a notification email to notify about the job status (failure/success)
    *   @param: Additional description to be sent 
    */
    public void sendNotification(string description) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(emailSubject);
        emailBody = emailBody.replace('{{mailContent}}', description);
        emailBody = emailBody.replace('{{jobname}}', 'PushUpdatesToHub');
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });

    }

    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: Update Request and response records based on Rest Callout response (only records successfully added to hub are updated)
    *   @param: Rest Callout response
    */
    public void updateRecords(String response) {
        schema.sObjectType sObjType = Schema.getGlobalDescribe().get(reqObjectName);
        String requestObjPrefix = sObjType.getDescribe().getKeyPrefix();
        List<sObject> recToUpdate = new List<sObject>();
        String decodedStr = EncodingUtil.urlDecode(response, 'UTF-8');
        decodedStr = decodedStr.substring(1, decodedStr.length()-1);
        List<RfaWrapper.RfaRestResponse> responses = (List<RfaWrapper.RfaRestResponse>)JSON.deserialize(decodedStr, List<RfaWrapper.RfaRestResponse>.Class);
        prepareIdMap(responses);
        for(RfaWrapper.RfaRestResponse res: responses) {
            string idToUpdate = mapExternalIdToId.containsKey(res.recordID) ? mapExternalIdToId.get(res.recordID) : res.recordID; 
            system.debug(res);
            if(res.status.equalsIgnoreCase('success')) {
                if(res.type.equalsIgnoreCase(resObjectName)) {
                    recToUpdate.add(new S1_Response__c(id = idToUpdate, push_updates__c = false, status__c = 'Sent'));
                }else if(res.type.equalsIgnoreCase(reqObjectName)) {
                    recToUpdate.add(new S1_Request__c(id = idToUpdate, push_updates__c = false));
                    //for MI make both the Divisional and the S1 request as false
                    if(sourceDivision.equalsIgnoreCase('mi') && idToUpdate != res.recordId && String.valueOf(res.recordId).startsWith(requestObjPrefix)) {
                        recToUpdate.add(new S1_Request__c(id = res.recordID, push_updates__c = false));
                    }
                }
            }
        }
        update recToUpdate;
    }

    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: Method to creat a map of externalIdToId this map is used to identify records for update
    *   @param: List of Rest responsed from Hub
    */
    public void prepareIdMap(List<RfaWrapper.RfaRestResponse> listRes) {
        set<id> externalIdsToQuery = new Set<Id>();
        for(RfaWrapper.RfaRestResponse res: listRes) {
            externalIdsToQuery.add(res.recordID);
        }
        for(S1_request__c req : [SELECT id, external_id__c FROM S1_Request__c WHERE external_id__c IN: externalIdsToQuery]) {
            mapExternalIdToId.put(req.external_id__c,req.id);
        }
        for(S1_response__c res : [SELECT id, external_id__c FROM S1_Response__c WHERE external_id__c IN: externalIdsToQuery]) {
            mapExternalIdToId.put(res.external_id__c,res.id);
        }
        system.debug(mapExternalIdToId);
    }

    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: Method to create body for HTTP request to the hub org, this method also URL encodes the request body
    */
    public string createRequestBody() {
        List<sObject> listRecordsToPush = new List<sObject>();
        string reqBody;
        
        string queryStr = generateQueryString();        
        listRecordsToPush = database.query(queryStr);
        reqBody = EncodingUtil.urlEncode(JSON.serialize(listRecordsToPush),'UTF-8');
        return reqBody;
    }
    
    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: generate the query sting based on fields and object names specified in the custom settings
    */
    public string generateQueryString() {
        string childQueryStr = ', (SELECT '+ resFields + ' FROM '+ resRelationName +' WHERE '+ recFilter +')';
        string queryStr = 'SELECT '+ reqFields + childQueryStr + ' FROM '+ reqObjectName +' WHERE '+ recFilter +' order by Status__c desc';
        system.debug('Generated Query: '+queryStr);
        return queryStr;
    }
    
    /*  @author: Akash Punera
    *   @date: 25 Oct 2022
    *   @description: Method to make callout to the Hub org with encoded Request body
    *   @param: Rest Webservice Method to call, Request body for the webservice method
    */
    public string makeCallout(string serviceMethod, string reqBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:RFAHubConnect/services/apexrest/rfa/'+serviceMethod);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"reqBody" : "'+reqBody+'","sourceDivision" : "'+ sourceDivision+'" }');
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug(res);
        return res.getBody();
    }

    /*  @author: Akash Punera
    *   @date: 29 Nov 2022
    *   @description: Method to queue push updates in a async call
    *   @param: Rest Callout response
    */
    public void execute(QueueableContext context) {
        pushUpdatesToHub();
    }
}