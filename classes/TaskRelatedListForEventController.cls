//-----------------------------
// @author: Harshit Singhal
// @date: 27 Apr 2020
// @description: SFDC-2746 Controller class for lwc component - taskRelatedListForEvent
// -----------------------------
public with sharing class TaskRelatedListForEventController {
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: evtId - Id of event record
    // @description: SFDC-2746 Method fetches details of event record open in UI and pass the result to component
    // @return: evtObj - Event record with required details
    //------------------------------
    @AuraEnabled
    public static Event getEventDetails (Id evtId) {
        Event evtObj;
        if(evtId != null) {
            evtObj = [SELECT Id,Subject,MeetingNote__c,WhatId FROM Event WHERE Id=:evtId LIMIT 1];            
        }
        
        return evtObj;
    }
     
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: evtId - Id of event record
    // @description: SFDC-2746 Method returns Id of a meeting note record(if it exists) related to event record
    // @return: meetingNoteIdStr - Id of meeting note record
    //------------------------------
    @AuraEnabled(cacheable=true)
    public static Id getMeetingNoteId (Id evtId) {        
        String meetingNoteIdStr;
        if(evtId != null) {
            Event evtObj = [SELECT Id,Subject,MeetingNote__c,WhatId FROM Event WHERE Id=:evtId LIMIT 1];
            meetingNoteIdStr = evtObj.MeetingNote__c;
        }
        
        return meetingNoteIdStr;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: evtId - Id of event record
    // @description: SFDC-2746 Method returns tasks associated with MeetingNote record that is related to source event record. Tasks are identified on the basis of Task.MeetingNote__c=Event.MeetingNote__c lookup fields.
    // @return: taskList - List of tasks under the meeting note
    //------------------------------
    @AuraEnabled(cacheable=true)
    public static List<Task> getRelatedTasks (Id evtId) {        
        List<Task> taskList = new List<Task>();
        if(evtId != null) {
            Event evtObj = [SELECT Id,Subject,MeetingNote__c FROM Event WHERE Id=:evtId LIMIT 1];
            if(evtObj!=null && evtObj.MeetingNote__c!=null) {
                taskList.addAll([SELECT Id,Subject,Type,ActivityDate,Status,Priority,WhoId,Who.Name,WhatId,What.Name,MeetingNote__c FROM Task WHERE MeetingNote__c=:evtObj.MeetingNote__c]);
            }
        }        
        return taskList;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: taskId - Id of Task record
    // @description: SFDC-2746 Method to delete selected task record displayed in taskRelatedListForEvent component.
    // @return: None
    //------------------------------
    @AuraEnabled
    public static void deleteTask(Id taskId){
        if(taskId!=null) {
            Task taskRec = new Task(Id=taskId);
            delete taskRec;
        }
        return;
    }
    
}