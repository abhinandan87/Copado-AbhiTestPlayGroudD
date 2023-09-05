//-----------------------------
// @author: Harshit Singhal
// @date: 05 May 2020
// @description: SFDC-2761 Batch to create automated meeting notes for events that pass the critria - AccountId!=null AND IsChild=false AND RecordType=Standard AND MeetingNote__c=null
// -----------------------------
public class BatchCreateMeetingNoteForEvent implements Database.Batchable<sObject>, Database.Stateful {
    public static Boolean isExecutingBatchCreateMeetingNoteForEvent = false;		//Variable to help fire platform events in EventMethods trigger helper if PrivacyLevel__c needs to be updated or MeetingNote__Share records need to be checked.
    public Set<Id> errorLogIdSet = new Set<Id>();
    public Integer batchCount = 0;
    public Integer recordCount = 0;
    public String query = '';
    public String emailId = '';
    
    public BatchCreateMeetingNoteForEvent(String q, String email) {
        query = String.isNotBlank(q) ? q : 'SELECT Id, AccountId, MeetingNote__c, MeetingNote__r.RelatedEventId__c, RecordType.Name, RecordTypeId, WhatId, IsChild, DurationInMinutes, StartDateTime, ShowAs, EndDateTime, IsReminderSet, PrivacyLevel__c, IsPrivate, ActivityDateTime, Location, Subject, IsAllDayEvent, Type, Description, IsRecurrence2, OwnerId FROM Event WHERE (AccountId!=null AND RecordType.Name=\'Standard\' AND IsChild=false AND MeetingNote__c=null AND IsRecurrence2=false)';
        emailId = String.isNotBlank(email) ? email : Label.OpptyPrimaryContactBatchEmail;        
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {  
        System.debug('START() METHOD');
        System.debug('query='+query);
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        isExecutingBatchCreateMeetingNoteForEvent = true;
        batchCount++;
        List<MeetingNote__c> upsertMeetingNoteList = new List<MeetingNote__c>();
        for(Event evt: (List<Event>)scope) {
            //Create meeting note if it does not exist on relevant event
            if(EventMeetingNoteSyncUtility.shouldEventHaveMeetingNote(evt)) {
                Map<String,String> evtToMtngNoteCreationMap = EventMeetingNoteSyncUtility.EventMeetingNoteSyncFieldsMap;
                MeetingNote__c mtngNote = EventMeetingNoteSyncUtility.createMeetingNoteFromEvent(evt, evtToMtngNoteCreationMap);
                upsertMeetingNoteList.add(mtngNote);
            }
        }
        try {
            if(upsertMeetingNoteList.size() > 0) {
                recordCount += upsertMeetingNoteList.size();
                upsert upsertMeetingNoteList;
            }
        }
        catch(Exception ex) {
            System.debug('Exception in BatchCreateMeetingNoteForEvent. ex.getMessage()='+ex.getMessage());            
            
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchCreateMeetingNoteForEvent',ErrorDescription__c=description,FunctionName__c='execute');
            insert apexLogRecord;
            errorLogIdSet.add(apexLogRecord.Id);
        }
        finally {
            isExecutingBatchCreateMeetingNoteForEvent = false;
        }
        System.debug('EXECUTE() METHOD ENDS');
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('FINISH() METHOD');
        if(String.isNotBlank(emailId)) {            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String status = 'BatchCreateMeetingNoteForEvent Batch Completed.';
            String[] toAddresses = new String[] {emailId};
            mail.setToAddresses(toAddresses);
            String mailBody = ' Meeting Notes Count: ' + String.valueOf(recordCount) + '\n'
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