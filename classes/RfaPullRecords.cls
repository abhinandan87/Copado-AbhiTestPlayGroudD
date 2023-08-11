/*  @author: Pankhuri Jain
*   @date: 21 Nov 2022
*   @description: Class to pull request/response records from hub org to source org
*/
public with Sharing class RfaPullRecords implements Queueable, Database.AllowsCallouts{
    Schema.SObjectField reqExternalId = S1_Request__c.Fields.Id;
    Schema.SObjectField resExternalId = S1_Response__c.Fields.Id;
    Map<string,string> mapIdToExternalID = new Map<string,string>();
    List<RfaWrapper.RfaRestResponse> restResponse = new List<RfaWrapper.RfaRestResponse>();    
    String sourceDivision;
    String subDivisions; // only in IHS
    static string[] toAddresses = new string[]{};
    boolean sendStatusEmails = false;
    String emailSubject;
    String emailBody;
    
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Method to populate variables from custom metadata
    */
    public void setConfigurations() {       
        S1_RFA_Configurations__mdt config = [SELECT    id, Request_Fields__c, Response_Fields__c, Request_Object_API__c, Response_Object_API__c,
                                                    Response_Child_API__c, Filter_String__c, Sub_Divisions__c, Division_Name__c, To_Email_Address__c, Send_Email_Notification__c, 
                                                    Email_Body_Prefix__c, Email_Subject__c
                                            FROM    S1_RFA_Configurations__mdt WHERE DeveloperName  = 'Default'];
        sourceDivision = config.Division_Name__c;
        subDivisions = config.Sub_Divisions__c; 
        toAddresses.addAll(config?.To_Email_Address__c?.split(','));
        sendStatusEmails = config.Send_Email_Notification__c;
        emailBody = config.Email_Body_Prefix__c;
        emailSubject = config.Email_Subject__c;       
    }

    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Method to make callout to pull changes from Hub
    */
    public void pullRecordsFromHub(){
          try{
              setConfigurations();
              string response;
              response = makeCallout('getRecords');
              upsertRecords(response);                          
              string reqBody = serializeResponse(); 
              if(reqBody != ''){
                  makeCalloutToC360Update('updateRecords',reqBody); 
              }
          }catch (Exception ex) {
                System.debug('Exception '+Ex.getMessage()+'--'+ex.getStackTraceString());    
                if(sendStatusEmails) {
                    sendNotification(Ex.getMessage()+'--'+ex.getStackTraceString());
                }        
          }   
    }
     
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: method to serialize and url encode Success/Failure response message after upsert of Request/Response Records
    */  
    public string serializeResponse() {
          String responseStr = JSON.serialize(restResponse);
          String decodedStr = EncodingUtil.urlEncode(responseStr, 'UTF-8');          
          return decodedStr; 
    }

    /*  @author: Pankhuri Jain
    *   @date: 28 Nov 2022
    *   @description: Send a notification email to notify about the job status (failure/success)
    *   @param: Additional description to be sent 
    */
    public void sendNotification(string description) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject(emailSubject);
        emailBody = emailBody.replace('{{jobname}}', 'pullRecordsFromHub');
        emailBody = emailBody.replace('{{mailContent}}', description);
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.Email[] { mail });
    }
      
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Update Request and response records in Division based on Rest Callout response from Hub 
    *   @param: Rest Callout response
    */
    public void upsertRecords(string resBody){
          List<sObject> recToUpdate = new List<sObject>();
          String decodedStr = EncodingUtil.urlDecode(resBody, 'UTF-8');
          decodedStr = decodedStr.replaceAll('__c','').replaceAll('__r','').replaceAll('_','');
          decodedStr = decodedStr.substring(1, decodedStr.length()-1);
          List<RfaWrapper.RecordData> listS1Request = (List<RfaWrapper.RecordData>) JSON.deserialize(decodedStr, List<RfaWrapper.RecordData>.class);
          system.debug('RequestList** ' + listS1Request);
          upsertRequestRecords(listS1Request);
          upsertResponseRecords(listS1Request);
    }
    
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Upsert data to request object
    */
    public void upsertRequestRecords(List<RfaWrapper.RecordData> listS1Request) {
          List<S1_Request__c> listToUpsert = new List<S1_Request__c>();
          for(RfaWrapper.RecordData s1Request : listS1Request) {
              if(subDivisions.contains(s1Request.division) && s1Request.divisionSentFrom != sourceDivision){ 
                 listToUpsert.add(createS1Request(s1Request));
              }
          }
          System.debug('RequestlistToUpsert** ' + listToUpsert);      
          system.debug('RequestlistToUpsertSize** ' + listToUpsert.size());            
          List<Database.upsertResult> uResults = database.upsert(listToUpsert, reqExternalId, false);  
          updateResponseMessage(uResults,'S1_Request__c');
  
    }
     
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Upsert data to response object
    */
    public void upsertResponseRecords(List<RfaWrapper.RecordData> listS1Request) {
          List<S1_Response__c> listToUpsert = new List<S1_Response__c>();
          for(RfaWrapper.RecordData s1Request : listS1Request) {
              if(s1Request.s1Response != null && subDivisions.contains(s1Request.division)) {   
                  listToUpsert.addAll(createS1Response(s1Request));
              }
          }
          System.debug('ResponselistToUpsert** ' + listToUpsert);
          system.debug('ResponselistToUpsertSize** ' + listToUpsert.size());         
          List<Database.upsertResult> uResults = database.upsert(listToUpsert, resExternalId, false);
          updateResponseMessage(uResults,'S1_Response__c');
  
    }
      
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Create an object instance of S1Request
    */ 
    public S1_Request__c createS1Request(RfaWrapper.RecordData s1Request) {        
          S1_Request__c newS1Req = new S1_Request__c();              
          newS1Req.Id = s1Request.externalId;
          newS1Req.External_Id__c = s1Request.externalId;        
          newS1Req.Account__c = s1Request.Account;    
          newS1Req.Opportunity__c = s1Request.Opportunity; 
          newS1Req.Category__c = s1Request.Category;
          newS1Req.Industry__c = s1Request.Industry;
          newS1Req.Division__c = s1Request.Division; 
          newS1Req.Description__c = s1Request.Description; 
          if(s1Request.completedDate != null) {
            newS1Req.Completed_Date__c = Date.ValueOf(s1Request.completedDate);
          }           
          newS1Req.Status__c = s1Request.Status;  
          newS1Req.Push_Updates__c = false;             
                    
          return newS1Req;
    }
     
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Create an object instance of S1Response
    */ 
    public List<S1_response__c> createS1Response(RfaWrapper.RecordData s1Request) {
          list<S1_Response__c> listRes = new List<S1_Response__c>();               
          for(RfaWrapper.RecordData s1Response : s1Request.s1Response.records) {
            if(!subDivisions.contains(s1Response.Division)){// Response has come from S1 user
                S1_Response__c newS1Res = new S1_Response__c();
                newS1Res.External_Id__c = s1Response.externalId;
                newS1Res.Description__c = s1Response.Description;
                newS1Res.Push_Updates__c = false;             
                newS1Res.Status__c = 'Received';
                newS1Res.Owner__c = s1Response.Owner;
                newS1Res.Owner_Email__c = s1Response.OwnerEmail;
                newS1Res.Type__c = 'Incoming';              
                newS1Res.S1_Request__c = s1Request.externalId; 
                listRes.add(newS1Res);
              }
          }
          return listRes;
    }
    
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: method to generate a response wrapper and get record Ids
    */
    public void updateResponseMessage(List<Database.UpsertResult> uResults, string sObjectType) {       
          createIdMap(uResults,sObjectType);
          for(Database.upsertResult result:uResults) {
              if (!result.isSuccess()) {
                  restResponse.add(new RfaWrapper.RfaRestResponse(mapIdToExternalID.get(result.getId()),'Failure',JSON.serialize(result.getErrors()),sObjectType));
              }else {
                  restResponse.add(new RfaWrapper.RfaRestResponse(mapIdToExternalID.get(result.getId()),'Success','Record Upserted',sObjectType));
              }
          }
    }
    
    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: method to generate a Id to external Id map
    */
    public void createIdMap(List<Database.UpsertResult> uResults, string sObjectType) {
          List<sobject> listRecords = new List<sObject>();
          Set<Id> idsToQuery = new Set<Id>();
          for(Database.upsertResult result:uResults) {
              if (result.isSuccess()) {
                  idsToQuery.add(result.getId());
              }
          }
          listRecords = Database.query('SELECT id, external_id__c FROM '+sObjectType+' WHERE id in:idsToQuery');
          for(sobject obj : listRecords) {
              if(obj.get('external_id__c') != null){
                 mapIdToExternalID.put(String.valueOf(obj.get('id')),String.valueOf(obj.get('external_id__c')));
              }
              else 
                 mapIdToExternalID.put(String.valueOf(obj.get('id')),String.valueOf(obj.get('id')));
          }
          system.debug('mapIdToExternalID** ' + mapIdToExternalID);
    }
      
    /*  @author: Pankhuri Jain
    *   @date: 21 Nov 2022
    *   @description: Method to make callout to the Hub org to pull records
    *   @param: Rest Webservice Method to call
    */
    public string makeCallout(string serviceMethod) {
          HttpRequest req = new HttpRequest();
          req.setEndpoint('callout:RFAHubConnect/services/apexrest/rfa_pull/'+serviceMethod);
          req.setMethod('GET');
          req.setHeader('Content-Type', 'application/json');         
          req.setTimeout(120000);
          Http http = new Http();
          HTTPResponse res = http.send(req);
          system.debug('body** ' + res.getBody());
          return res.getBody();
    }

    /*  @author: Pankhuri Jain
    *   @date: 25 Nov 2022
    *   @description: Method to make callout to the Hub org to make updates in Hub with encoded Request body(Division Success/Failure response message)
    *   @param: Rest Webservice Method to call,Request body for the webservice method
    */
    @future(callout = true)
    public static void makeCalloutToC360Update(string serviceMethod, string reqBody) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:RFAHubConnect/services/apexrest/rfa_pull/'+serviceMethod);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"reqBody" : "'+reqBody+'"}');
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('resbody** ' + res.getBody());
    }

    /*  @author: Pankhuri Jain
    *   @date: 15 Dec 2022
    *   @description: Method to queue pull updates in a async call
    *   @param: Rest Callout response
    */
    public void execute(QueueableContext context) {
        pullRecordsFromHub();
    }
}