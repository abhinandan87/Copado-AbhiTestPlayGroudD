//-----------------------------
// @author: Harshit Singhal
// @date: 23 Apr 2020
// @description: SFDC-2761 This is to duplicate the function of platform events(SetupEvents__e) for bulk events as Platform events have governor limits. One time batch to:
// 							1) Batch to update PrivacyLevel__c on Events for one time when bulk(all users) sync is turned on with outlook.
// 							2) Rearrange EventRelations if it there is an external
// -----------------------------
public class BatchFillEventPrivacyLevel implements Database.Batchable<sObject>, Database.Stateful {
    public Set<Id> errorLogIdSet = new Set<Id>();
    public Integer batchCount = 0;
    public Integer recordCount = 0;
    public String query = '';
    public String emailId = '';
    
    public BatchFillEventPrivacyLevel(String q, String email) {
        String defaultQuery = 'SELECT Id,AccountId,WhoId,PrivacyLevel__c,RecordTypeId,IsChild,IsRecurrence2,' 
            + '(SELECT Id,AccountId, IsInvitee, IsParent, IsWhat, RelationId, Response, Status,EventId FROM EventRelations ORDER BY IsWhat DESC)' 
            + ' FROM Event' 
            + ' WHERE PrivacyLevel__c=null AND RecordType.Name=\'Standard\' AND IsChild=false AND IsRecurrence2=false';
        
        query = String.isNotBlank(q) ? q : defaultQuery;
        emailId = String.isNotBlank(email) ? email : Label.OpptyPrimaryContactBatchEmail;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('query='+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('EXECUTE() METHOD BEGINS');
        batchCount++;
        Set<Id> evtIdSet = new Set<Id>();
        for(Event evt: (List<Event>)scope) {
            if(EventMeetingNoteSyncUtility.checkIfEventSetupRequired(evt)) {
            	evtIdSet.add(evt.Id);
            }
        }
        if(evtIdSet.size() > 0) {
            recordCount += evtIdSet.size();
            try {
                EventMeetingNoteSyncUtility.populatePrivacyLvlAccOnEvent(evtIdSet);
            }
            catch(Exception ex) {
                String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
                ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchFillEventPrivacyLevel',ErrorDescription__c=description,FunctionName__c='execute');
                insert apexLogRecord;
                errorLogIdSet.add(apexLogRecord.Id);                
            }
        }
        System.debug('EXECUTE() METHOD ENDS');
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('FINISH() METHOD');
        if(String.isNotBlank(emailId)) {            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String status = 'BatchFillEventPrivacyLevel Batch Completed.';
            String[] toAddresses = new String[] {emailId};
            mail.setToAddresses(toAddresses);
            String mailBody = 'Total Event Records: '+ String.valueOf(recordCount)+ '\n' 
                + ' Total Batches Executed: ' + String.valueOf(batchCount) + '\n';
                
            if(errorLogIdSet!=null && errorLogIdSet.size()>0) {
                mail.setSubject('FAILED: ' + status);
                mailBody += ' Batches Failed: '+ errorLogIdSet.size() + '\n\n Check Apex Logger records for details.';
                mail.setPlainTextBody(mailBody);
            }
            else {
                mail.setSubject('SUCCESS: ' + status);
                mail.setPlainTextBody(mailBody);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

}