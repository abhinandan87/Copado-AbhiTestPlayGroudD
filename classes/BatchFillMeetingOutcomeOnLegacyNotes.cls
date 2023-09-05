//-----------------------------
// @author: Harshit Singhal
// @date: 23 Apr 2020
// @description: SFDC-2761 One time batch to:
// 							1) Query all existing meeting notes in the system and merge - Achieved__c, Info__c, NextSteps__c - into new textarea field MeetingOutcome__c
// -----------------------------
public class BatchFillMeetingOutcomeOnLegacyNotes implements Database.Batchable<sObject>, Database.Stateful {
    public Set<Id> errorLogIdSet = new Set<Id>();
    public Integer batchCount = 0;
    public Integer recordCount = 0;
    public String query = '';
    public String emailId = '';
    
    public BatchFillMeetingOutcomeOnLegacyNotes(String q, String email) {        
        query = String.isNotBlank(q) ? q : 'SELECT Id, Achieved__c, Info__c, NextSteps__c, MeetingOutcome__c, RelatedEventId__c FROM MeetingNote__c WHERE RelatedEventId__c=null';
        emailId = String.isNotBlank(email) ? email : Label.OpptyPrimaryContactBatchEmail;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {  
        System.debug('START() METHOD');
        System.debug('query='+query);
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('EXECUTE() METHOD BEGINS');
        String ACHIEVED_HEADER = '**Achieved:**';
        String INFO_HEADER = '**Info:**';
        String NEXTSTEPS_HEADER = '**Next Steps:**';
        batchCount++;
        List<MeetingNote__c> mtngNoteUpdList = new List<MeetingNote__c>();
        for(MeetingNote__c mtngNote: (List<MeetingNote__c>)scope) {
            if(String.isBlank(mtngNote.MeetingOutcome__c) 
               || (String.isNotBlank(mtngNote.MeetingOutcome__c) && !mtngNote.MeetingOutcome__c.contains(ACHIEVED_HEADER) && !mtngNote.MeetingOutcome__c.contains(INFO_HEADER) && !mtngNote.MeetingOutcome__c.contains(NEXTSTEPS_HEADER)) ) {
                
                   String meetingOutcome = String.isNotBlank(mtngNote.MeetingOutcome__c) ? mtngNote.MeetingOutcome__c + '\n\n' : '';
                   
                   if(String.isNotBlank(mtngNote.Achieved__c)) {
                       meetingOutcome += ACHIEVED_HEADER + '\n\n' + mtngNote.Achieved__c + '\n\n';                
                   }
                   if(String.isNotBlank(mtngNote.Info__c)) {
                       meetingOutcome += INFO_HEADER + '\n\n' + mtngNote.Info__c + '\n\n';                
                   }
                   if(String.isNotBlank(mtngNote.NextSteps__c)) {
                       meetingOutcome += NEXTSTEPS_HEADER + '\n\n' + mtngNote.NextSteps__c + '\n\n';
                   }
                   if(String.isNotBlank(meetingOutcome)) {
                       mtngNote.MeetingOutcome__c = meetingOutcome;
                       mtngNoteUpdList.add(mtngNote);
                   }
            }
        }
        if(mtngNoteUpdList.size() > 0) {
            recordCount += mtngNoteUpdList.size();
            try {
                update mtngNoteUpdList;
            }
            catch(Exception ex) {
                String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
                ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchFillMeetingOutcomeOnLegacyNotes',ErrorDescription__c=description,FunctionName__c='execute');
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
            String status = 'BatchFillMeetingOutcomeOnLegacyNotes Batch Completed.';
            String[] toAddresses = new String[] {emailId};
            mail.setToAddresses(toAddresses);
            String mailBody = 'Total MeetingNotes Updated: '+ String.valueOf(recordCount)+ '\n' 
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