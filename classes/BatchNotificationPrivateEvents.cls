/**
* @Author:  Priyanka Vyas
* @Date:    25th May 2020
* @description: SFDC-2872 Batch class to send notification about the deletion of the personal appointments. 
				Must be scheduled every Monday at 1:00 AM GMT as SF Admin.
				It notifies about all the personal appointment events which have enddate < last week's friday
**/
global class BatchNotificationPrivateEvents implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts{
    //public static Map<Integer, Set<ID>> counterMap=new Map<Integer, Set<ID>>();
    //public static Integer batchCount = 0;
    public String emailId = '';
    public integer numberOfUsers;
    public Set<Id> ownerIDSet=new Set<Id>();
    public Set<Id> errorLogIdSet = new Set<Id>();
    public String soqlquery='';
    public List<String> userIDList=new List<String>();
    public Date endDateForNotification;
    public Datetime StartDateForPvtEventsDeletion;
    Public Set<ID> userIDSet=new Set<ID>();
    global BatchNotificationPrivateEvents(String email){
        //String endDateForNotification = (System.now()-Integer.valueOf(Label.DaysBeforePvtEventsNotificationBatch)).format('yyyy-MM-dd');
        endDateForNotification = (System.today()-Integer.valueOf(Label.DaysBeforePvtEventsNotificationBatch));
        //StartDateForPvtEventsDeletion=Datetime.valueOfGMT(Label.StartDateForPvtEventsDeletion).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        StartDateForPvtEventsDeletion=Datetime.valueOfGMT(Label.StartDateForPvtEventsDeletion);
        //Set<String> userIDSet=new Set<String>();
        List<PermissionSetAssignment> psaList=new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaListToExclude=new List<PermissionSetAssignment>();
        If(Test.isRunningTest()){
        	psaList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OutlookSyncEnabled' and Assignee.IsActive=true];
        }
        else{
            psaList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OutlookSyncEnabled' and Assignee.IsActive=true and SystemModstamp<:endDateForNotification];
        }
        psaListToExclude = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'DoNotDeletePrivateEvents' and Assignee.IsActive=true];
        if(psaList.size()>0){    
            for(PermissionSetAssignment p: psaList){
                userIDSet.add(p.AssigneeId);
            }
        }
        if(psaListToExclude.size()>0){
            for(PermissionSetAssignment psa: psaListToExclude){
                if(userIDSet.contains(psa.AssigneeId)){
                    userIDSet.remove(psa.AssigneeId);
                }
            }
        }
        /*if(userIDSet.size()>0){    
            for(String userid:userIDSet){
                userIDList.add('\''+userid+ '\'');
            }
        }*/
        emailId = String.isNotBlank(email) ? email : Label.OpptyPrimaryContactBatchEmail;
        soqlquery = 'SELECT Id, OwnerId FROM Event where PrivacyLevel__c=\'Personal appointment\' and isChild=false and EndDate<:endDateForNotification and OwnerId in:userIDSet and createddate>=:StartDateForPvtEventsDeletion and NotesCompleted__c=false and RecordType.developerName=\'Standard\' and SourceGlobalAction__c=false';
        System.debug(soqlquery);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug(database.getquerylocator(soqlquery));
        return database.getquerylocator(soqlquery);
    }
    global void execute(Database.BatchableContext BC, List<Event> scope) { 
        //Set<ID> IDSet = new Set<ID>();
        if(scope.size()>0){ 
            for(Event e:scope){
                ownerIDSet.add(e.OwnerId);
                //IDSet.add(e.OwnerId);
            }
        }
        System.debug('ownerIDSet in execute()-->'+ownerIDSet);
        
        /*if (batchcount==0 || !counterMap.keyset().contains(batchcount) || (counterMap.keyset().contains(batchcount) && counterMap.get(batchcount).size()>=10000)){
			batchcount++;
		}
		if(!counterMap.keyset().contains(batchcount)){
			counterMap.put(batchcount, new Set<ID>(IDSet));
		}
		else if(counterMap.keyset().contains(batchcount) && counterMap.get(batchcount).size()<10000){
			for(id userid:IDSet){	
				counterMap.get(batchcount).add(userid);
			}
		}*/
    }
    global void finish(Database.BatchableContext BC) { 
        List<String> userIDList=new List<String>();
        if(ownerIDSet.size()>0){
            for(Id userId:ownerIDSet){
                userIDList.add(userId);
            }
        }
        System.debug('userIDList-->'+userIDList);
        System.debug('userIDList size-->'+userIDList.size());
        List<Report> rList = new List<Report>();
        rList = [Select id From Report WHERE DeveloperName =: Label.PvtEventsReportName LIMIT 1];
        numberOfUsers=!test.isRunningTest()?userIDList.size():11000;
        if(numberOfUsers>10000){
            System.debug('Problem in BatchNotificationPrivateEvents: Recipient list exceeded 10000 count');       
            String description = 'The recipent list exceeded the limit of 10000:'+userIDList.size();
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchNotificationPrivateEvents',ErrorDescription__c=description,FunctionName__c='finish');
            insert apexLogRecord;
            errorLogIdSet.add(apexLogRecord.Id);
            if(String.isNotBlank(emailId)) {            
                String mailBody = 'The recipient list size for custom motification has exceeded the limit of 10,000: '+userIDList.size();
                String subject = 'ISSUE: BatchNotificationPrivateEvents';
                sendEmail(mailbody, subject);
            }
        }                                                                                                                                                
        try{
            if(userIDList.size()>0){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndPoint(Url.getOrgDomainUrl().toExternalForm()
                                + '/services/data/v46.0/actions/standard/customNotificationAction');
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                req.setHeader('Content-Type', 'application/json');
                CustomNotificationType cst = [Select Id,CustomNotifTypeName from CustomNotificationType where developername='OldPersonalAppointments'];
                List<CustomNotificationActionInput> inputList = new List<CustomNotificationActionInput>();
                Map<Integer,List<String>> batchNumBatchSizeMap = new Map<Integer,List<String>>();
                batchNumBatchSizeMap=getUserIDMap(userIDList);
                for(Integer i:batchNumBatchSizeMap.keySet()){
                	CustomNotificationActionInput input = new CustomNotificationActionInput();
                    input.customNotifTypeId = cst.id;
                    input.recipientIds = batchNumBatchSizeMap.get(i);
                    input.title = Label.PvtEventNotificationTitle;
                    input.body = Label.PvtEventNotificationBody;
                    if(rList.size()>0){
                        input.targetId = rList[0].id;
                    }
                    inputList.add(input);
                }
                //action.inputs = new List<CustomNotificationActionInput>{input};
                CustomNotificationAction action = new CustomNotificationAction();
                action.inputs = inputList;
                req.setBody(JSON.serialize(action));
                HttpResponse res = h.send(req);
                System.debug(res.getBody());
                    ResponseClass parseResponse=new ResponseClass();
                    List<ResponseClass> responseList=new List<ResponseClass>();
                    if(res.getBody()!=null && res.getStatusCode()!= 200){
                        responseList = (List<ResponseClass>) System.JSON.deserialize(res.getBody(), List<ResponseClass>.class);
                        if(responseList[0]!=null && responseList[0].isSuccess!=true){
                            System.debug('Custom Notification action failed in BatchNotificationPrivateEvents ='+String.valueOf(responseList[0].errors)+' and output value is: '+String.valueOf(responseList[0].outputValues));       
                            String description = 'Custom Notification action failed: '+String.valueOf(responseList[0].errors)+'\n Message: '+ String.valueOf(responseList[0].outputValues);
                            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchNotificationPrivateEvents',ErrorDescription__c=description,FunctionName__c='finish');
                            insert apexLogRecord;
                            String mailbody='Custom Notification action failed in BatchNotificationPrivateEvents: '+String.valueOf(responseList[0].errors)+'\nMessage: '+ String.valueOf(responseList[0].outputValues)+'\nCheck apex log record: '+apexLogRecord.id;
                            String subject='FAILED: Private Event Notification Action!';
                            sendEmail(mailbody, subject);
                        }
                    }
                else{
                    if(emailId!=Label.OpptyPrimaryContactBatchEmail){
                        Integer numberOfUsersNotified=0;
                        for(Integer batchNumber: batchNumBatchSizeMap.keySet()){
            				numberOfUsersNotified=numberOfUsersNotified+batchNumBatchSizeMap.get(batchNumber).size();
        				}
                        sendEmail('BatchNotificationPrivateEvents successfully completed for '+numberOfUsersNotified+' users.', 'BatchNotificationPrivateEvents is completed');
                    }
                }
                
            }
        }
        catch(Exception ex){
            System.debug('Exception in BatchNotificationPrivateEvents ex.getMessage()='+ex.getMessage());       
            String description = '\nCause: '+ex.getCause()+'\nLine number : '+ ex.getLineNumber()+ '\nMessage: '+ ex.getMessage()+ '\nstackTrace: '+ex.getStackTraceString();
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchNotificationPrivateEvents',ErrorDescription__c=description,FunctionName__c='finish');
            insert apexLogRecord;
            errorLogIdSet.add(apexLogRecord.Id);
            if(errorLogIdSet!=null && errorLogIdSet.size()>0) {
                if(String.isNotBlank(emailId)) {
                    String mailbody=' Batch Failed!\n\nCheck Apex Logger records for details: '+ apexLogRecord.Id;
                    String status = 'BatchNotificationPrivateEvents';
                    String subject = 'FAILED: ' + status;
                    sendEmail(mailbody, subject);
                }
            }
        }
    }
    public void sendEmail(String mailbody, String subject){
        if(String.isNotBlank(emailId)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {emailId};
                mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    public Map<Integer, List<String>> getUserIDMap(List<String> userIDList){
        Integer perNotificationSize = Integer.valueOf(Label.PvtEventBellNotificationSize);
        System.debug('User list size for each custom notification action--->'+perNotificationSize);
        Map<Integer,List<String>> batchNumBatchSizeMap = new Map<Integer,List<String>>();
        Integer batchNum=0;
        Integer batchWiseCounter=0;
        List<String> batchWiseList = new List<String>();
        for(Integer i=1;i<=userIDList.size();i++) {
            batchWiseCounter++;
            batchWiseList.add(userIDList[i-1]);
            if(Math.mod(i,perNotificationSize)==0 || i==userIDList.size()) {
                batchNum++;       
                batchNumBatchSizeMap.put(batchNum,batchWiseList);
                batchWiseCounter=0;
                batchWiseList = new List<String>();
            }
        }
        for(Integer batchNumber: batchNumBatchSizeMap.keySet()){
            System.debug('List size for key '+batchnumber+' --> '+batchNumBatchSizeMap.get(batchNumber).size());
        }
        System.debug('batchNumBatchSizeMap='+batchNumBatchSizeMap);
        return batchNumBatchSizeMap;
    }
    public class CustomNotificationAction
    {
        public List<CustomNotificationActionInput> inputs { get; set; }
    }
    public class CustomNotificationActionInput
    {
        public String customNotifTypeId { get; set; }
        public List<String> recipientIds { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String targetId { get; set; }
    }
    public class ResponseClass {
        public String actionName;
        public List<Errors> errors;
        public Boolean isSuccess;
        public String outputValues;
    }
    public class Errors {
        public String statusCode;
        public String message;
        public List<Fields> fields;
    }
    public class Fields {
    }
}