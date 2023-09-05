//-----------------------------
// @author: Harshit Singhal
// @date: 27 Mar 2020
// @param: TriggerParameters
// @description: SFDC-2748 Class to hold MeetingNote trigger methods
// @return: NA
//-----------------------------
public class MeetingNoteMethods {
    public static Boolean isRunningPopulateMeetingNoteOnRelatedEvent = false;
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Mar 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2748 Using a dummy text field value RelatedEventId__c, update the the meeting note lookup on child event.
    // @return: None
    //------------------------------
    public static void populateMeetingNoteOnRelatedEvent(TriggerParameters tp) {
        isRunningPopulateMeetingNoteOnRelatedEvent = true;
        List<Event> updateEventList = new List<Event>();
        for(MeetingNote__c newMtngNote: (List<MeetingNote__c>)tp.newList) {
            if(String.isNotBlank(newMtngNote.RelatedEventId__c) && newMtngNote.RelatedEventId__c instanceOf Id) {
                Event evtObj = new Event(Id=newMtngNote.RelatedEventId__c, MeetingNote__c=newMtngNote.Id);
                updateEventList.add(evtObj);
            }
        }        
        update updateEventList;
        isRunningPopulateMeetingNoteOnRelatedEvent = false;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Mar 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2752 Update NotesCompleted__c to true only if MeetingOutcome__c is filled.
    // @return: None
    //------------------------------
    public static void markNotesCompleted(TriggerParameters tp) {
        for(MeetingNote__c newMtngNote: (List<MeetingNote__c>)tp.newList) {
            if(String.isNotBlank(newMtngNote.MeetingOutcome__c) && !newMtngNote.NotesCompleted__c) {
                newMtngNote.NotesCompleted__c = true;
            }
            else if(String.isBlank(newMtngNote.MeetingOutcome__c) && newMtngNote.NotesCompleted__c) {
                newMtngNote.NotesCompleted__c = false;
            }
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 03 Apr 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2748 Create defaul Related Opportunity record.
    // @return: None
    //------------------------------
    public static void createDefaultRelatedOpportunity(TriggerParameters tp) {
        List<RelatedOpportunity__c> insertRelatedOppList = new List<RelatedOpportunity__c>();
        Map<Id,RelatedOpportunity__c> mtngNoteIdRelatedOppMap = new Map<Id,RelatedOpportunity__c>();
        
        for(MeetingNote__c newMtngNote: (List<MeetingNote__c>)tp.newList) {
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert && newMtngNote.Opportunity__c!=null) {
                mtngNoteIdRelatedOppMap.put(newMtngNote.Id,new RelatedOpportunity__c(MeetingNote__c=newMtngNote.Id, Opportunity__c=newMtngNote.Opportunity__c));
            }
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                MeetingNote__c oldMtngNote = (MeetingNote__c)tp.oldMap.get(newMtngNote.Id);
                if(newMtngNote.Opportunity__c!=null && newMtngNote.Opportunity__c!=oldMtngNote.Opportunity__c) {
                    mtngNoteIdRelatedOppMap.put(newMtngNote.Id,new RelatedOpportunity__c(MeetingNote__c=newMtngNote.Id, Opportunity__c=newMtngNote.Opportunity__c));
                }
            }
        }
        //Do not create duplicates
        if(mtngNoteIdRelatedOppMap.size() > 0) {
            for(RelatedOpportunity__c rltdOpp: [SELECT Id,MeetingNote__c,Opportunity__c FROM RelatedOpportunity__c WHERE MeetingNote__c IN :mtngNoteIdRelatedOppMap.keySet() AND Opportunity__c!=null]) {
                System.debug('Apr3 rltdOpp.MeetingNote__c='+rltdOpp.MeetingNote__c);
                System.debug('Apr3 rltdOpp.Opportunity__c='+rltdOpp.Opportunity__c);
                //System.debug('Apr3 mtngNoteIdRelatedOppMap.get(rltdOpp.MeetingNote__c)='+mtngNoteIdRelatedOppMap.get(rltdOpp.MeetingNote__c));
                //System.debug('Apr3 mtngNoteIdRelatedOppMap.get(rltdOpp.MeetingNote__c).Opportunity__c='+mtngNoteIdRelatedOppMap.get(rltdOpp.MeetingNote__c).Opportunity__c);
                if(mtngNoteIdRelatedOppMap.containsKey(rltdOpp.MeetingNote__c) && rltdOpp.Opportunity__c == mtngNoteIdRelatedOppMap.get(rltdOpp.MeetingNote__c).Opportunity__c) {
                    mtngNoteIdRelatedOppMap.remove(rltdOpp.MeetingNote__c);
                }
                //System.debug('mtngNoteIdRelatedOppMap size='+mtngNoteIdRelatedOppMap.size());
                //System.debug('mtngNoteIdRelatedOppMap='+mtngNoteIdRelatedOppMap);
            }
        }
        //Insert new Related Opp records
        if(mtngNoteIdRelatedOppMap.size() > 0) {
            insert mtngNoteIdRelatedOppMap.values();
        }        
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Mar 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2752 Meeting Note trigger validations
    // 					1) Non-admin user cannot modify meeting note name. Exception - sync process between meeting note and event should skip this validation
    // @return: None
    //------------------------------
    public static void meetingNoteValidations(TriggerParameters tp) {
        if(!EventMethods.isRunningSyncMeetingNoteWithEvent) {
            for(MeetingNote__c newMtngNote: (List<MeetingNote__c>)tp.newList) {
                MeetingNote__c oldMtngNote = (MeetingNote__c)tp.oldMap.get(newMtngNote.Id);
                if(newMtngNote.Name!=oldMtngNote.Name &&  !UtilityClass.LoggedInUserProfileName.containsIgnoreCase('System Admin')) {
                    newMtngNote.addError('Meeting Name cannot be modified.');
                }
            }    
        }        
    }
}