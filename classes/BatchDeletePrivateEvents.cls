/**
 * @Author:  Priyanka Vyas
 * @Date:    27th May 2020
 * @description: SFDC-2872 Batch class to delete the personal appointments from last week and before. 
  				 Must be scheduled every Saturday at 1:00 AM GMT as SF Admin.
				 It deletes all the personal appointment events which have enddate < last week's Friday
**/
global class BatchDeletePrivateEvents implements Database.Batchable<SObject>, Database.Stateful{
    public Set<Id> ownerIDSet=new Set<Id>();
    public Set<Id> errorLogIdSet = new Set<Id>();
    public static Boolean isExecutingBatchDeletePrivateEvents = false;
    public Integer batchCount = 0;
    public String emailId = '';
    public Integer recordCount = 0;
    public String soqlquery='';
    public Date endDateForDeletion;
    public Datetime StartDateForPvtEventsDeletion;
    public Set<ID> userIDSet=new Set<ID>();
    global BatchDeletePrivateEvents(String email){
        Integer daysbeforenotification = Integer.valueOf(Label.DaysBeforePvtEventsNotificationBatch);
        Integer daysOfGap=Integer.valueOf(Label.DaysGapBetweenPvtEventBatches);
        //endDateForDeletion=(System.now()-daysbeforenotification-daysOfGap).format('yyyy-MM-dd');
        endDateForDeletion=(System.today()-daysbeforenotification-daysOfGap);
        //StartDateForPvtEventsDeletion=Datetime.valueOf((System.Label.StartDateForPvtEventsDeletion)).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
		StartDateForPvtEventsDeletion=Datetime.valueOfGMT(Label.StartDateForPvtEventsDeletion);
        List<PermissionSetAssignment> psaList=new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> psaListToExclude=new List<PermissionSetAssignment>();
       	If(Test.isRunningTest()){
           psaList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OutlookSyncEnabled' and Assignee.IsActive=true];
    	}
        else{
        	psaList = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'OutlookSyncEnabled' and Assignee.IsActive=true and SystemModstamp<:endDateForDeletion];
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
		/*for(String userid:userIDSet){
            userIDList.add('\''+userid+ '\'');
		}*/
        emailId = String.isNotBlank(email) ? email : Label.OpptyPrimaryContactBatchEmail;
        soqlquery = 'SELECT Id, OwnerId FROM Event where PrivacyLevel__c=\'Personal appointment\' and isChild=false and EndDate<:endDateForDeletion and OwnerId in: userIDSet and createddate>=:StartDateForPvtEventsDeletion and NotesCompleted__c=false and RecordType.developerName=\'Standard\' and SourceGlobalAction__c=false';
        
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        System.debug(database.getquerylocator(soqlquery));
        return database.getquerylocator(soqlquery);
    }
    global void execute(Database.BatchableContext BC, List<Event> scope) { 
        batchCount++;
        List<event> eventdeleteList=new List<event>();
        if(scope.size()>0){
            for(Event e:scope){
                eventdeleteList.add(e);
            }
        }
        try{
            if(eventdeleteList.size()>0){
                recordCount += eventdeleteList.size();
                delete eventdeleteList;
            }
        }
        Catch(Exception ex){
            System.debug('Exception in BatchDeletePrivateEvents ex.getMessage()='+ex.getMessage());            
            
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchDeletePrivateEvents',ErrorDescription__c=description,FunctionName__c='execute');
            insert apexLogRecord;
            errorLogIdSet.add(apexLogRecord.Id);
        }
    }
    global void finish(Database.BatchableContext BC) { 
         if(String.isNotBlank(emailId)) {            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String status = 'BatchDeletePrivateEvents Batch Completed.';
            String[] toAddresses = new String[] {emailId};
            mail.setToAddresses(toAddresses);
            String mailBody = 'Personal appointments count: ' + String.valueOf(recordCount) + '\n'
                + 'Total Batches Executed: ' + String.valueOf(batchCount) + '\n';
            if(errorLogIdSet!=null && errorLogIdSet.size()>0){
            	mail.setSubject('FAILED: ' + status);
            	mailBody += 'Batches Failed: '+ errorLogIdSet.size() + '\nCheck Apex Logger records for details.';
            }
            else {
                mail.setSubject('SUCCESS: ' + status);
                mail.setPlainTextBody(mailBody);
            }
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
    }
}