//-----------------------------
// @author: Harshit Singhal
// @date: 05 May 2020
// @description: SFDC-2761 One time batch to copy over meeting attendees as event relations on existing event records and populate RelatedEventId__c on Meeting Note record.
// -----------------------------
public class BatchCreateEventRelations implements Database.Batchable<sObject>, Database.Stateful {
    public Set<Id> errorLogIdSet = new Set<Id>();
    public Integer batchCount = 0;
    public Integer recordCountEventRelations = 0;
    public Integer recordCountMeetingNotes = 0;
    public Integer recordCountEvents = 0;
    public String query = '';
    public String emailId = '';
    
    public BatchCreateEventRelations(String q, String email) {
        query = String.isNotBlank(q) ? q : 'SELECT Id, AccountId, MeetingNote__c, MeetingNote__r.RelatedEventId__c, RecordType.Name, RecordTypeId, WhatId, IsChild, DurationInMinutes, StartDateTime, ShowAs, EndDateTime, IsReminderSet, PrivacyLevel__c, IsPrivate, ActivityDateTime, Location, Subject, IsAllDayEvent, Type, Description FROM Event  WHERE (MeetingNote__c!=null AND RecordType.Name=\'Standard\' AND MeetingNote__r.RelatedEventId__c=null AND IsChild=false)';
        emailId = String.isNotBlank(email) ? email : Label.OpptyPrimaryContactBatchEmail;        
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {  
        System.debug('START() METHOD');
        System.debug('query='+query);
        return Database.getQueryLocator(query);        
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug('EXECUTE() METHOD BEGINS');
        batchCount++;
        List<MeetingNote__c> updateMeetingNoteList = new List<MeetingNote__c>();
        Map<Id,Id> evtIdMtndNoteIdMap = new Map<Id,Id>();
        List<EventRelation> insertRelationList = new List<EventRelation>();
        for(Event evt: (List<Event>)scope) {
        //If meeting note exists, copy Meeting Attendees to Event Relations
            if(evt.MeetingNote__c!=null && evt.MeetingNote__r.RelatedEventId__c==null && !evt.IsChild) {
                evtIdMtndNoteIdMap.put(evt.Id, evt.MeetingNote__c);
                updateMeetingNoteList.add(new MeetingNote__c(Id=evt.MeetingNote__c, RelatedEventId__c=evt.Id));
            }
        }
        if(evtIdMtndNoteIdMap.size() > 0) {
            insertRelationList = EventMeetingNoteSyncUtility.createEventRelationsFromMeetingAttendees(evtIdMtndNoteIdMap);
        }
        //Collect and update event records for which EventRelations are going to be upserted in order to recalculate Privacy Level on them.
        Set<Id> evtIdUpdateSet = new Set<Id>();
        List<Event> eventUpdateList = new List<Event>();
        if(insertRelationList!=null && insertRelationList.size() > 0) {
            for(EventRelation evr: insertRelationList) {
                if(!evtIdUpdateSet.contains(evr.EventId)) {
                    eventUpdateList.add(new Event(Id=evr.EventId));
                }
                evtIdUpdateSet.add(evr.EventId);                
            }
        }try {
            if(insertRelationList!=null && insertRelationList.size() > 0) {
				recordCountEventRelations += insertRelationList.size();
                upsert insertRelationList;
            }
            if(updateMeetingNoteList.size() > 0) {
                recordCountMeetingNotes += updateMeetingNoteList.size();
                update updateMeetingNoteList;
            }
            if(eventUpdateList.size() > 0) {
                recordCountEvents += eventUpdateList.size();
                update eventUpdateList;
            }
        }
        catch(Exception ex) {
            System.debug('Exception in BatchCreateEventRelations. ex.getMessage()='+ex.getMessage());            
            
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchCreateEventRelations',ErrorDescription__c=description,FunctionName__c='execute');
            insert apexLogRecord;
            errorLogIdSet.add(apexLogRecord.Id);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('FINISH() METHOD');
        if(String.isNotBlank(emailId)) {            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String status = 'BatchCreateEventRelations Batch Completed.';
            String[] toAddresses = new String[] {emailId};
            mail.setToAddresses(toAddresses);
            String mailBody = ' Event Relations Count: ' + String.valueOf(recordCountEventRelations) + '\n'
                + ' Meeting Notes Count: ' + String.valueOf(recordCountMeetingNotes) + '\n'
            	+ ' Events Count: ' + String.valueOf(recordCountEvents) + '\n'
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