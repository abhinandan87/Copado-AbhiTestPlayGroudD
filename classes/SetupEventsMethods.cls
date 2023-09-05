//-----------------------------
// @author: Harshit Singhal
// @date: 09 Apr 2020
// @param: NA
// @description: SFDC-2865 Class to hold SetupEvents__e platform event trigger methods 
// @return: NA
//-----------------------------
public class SetupEventsMethods {
    //Boolean variable to stop recursive SetupEvents__e event publishing in Event trigger
    public static Boolean isPlatformEventScopeActive = false;
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 14 May 2020
    // @param: TriggerParameters
    // @description: SFDC-2733 Method to create apex sharing records with Reason='EventAttendeeShare' for the related Meeting Note on the event based on user attendees in the event. 
    // @return: None
    //------------------------------
    public static void shareMeetingNoteWithEventAttendees(TriggerParameters tp) {
        List<SetupEvents__e> peList = (List<SetupEvents__e>)tp.newList;
        System.debug('shareMeetingNoteWithEventAttendees() METHOD BEGINS');
        Set<Id> evtIdSet = new Set<Id>();
        //List<MeetingNote__Share> meetingNoteShareList = new List<MeetingNote__Share>();
        for(SetupEvents__e peObj:peList) {
            if(peObj.SetMeetingShare__c) {
            	evtIdSet.add(peObj.EventId__c);    
            }            
        }
        if(evtIdSet.size() > 0) {            
            try {
                isPlatformEventScopeActive = true;
                EventMeetingNoteSyncUtility.setupMeetingNoteSharing(evtIdSet);
                isPlatformEventScopeActive = false;
            }
            catch(Exception ex) {
                System.debug('Exception in SetupEventsMethods. ex.getMessage()='+ex.getMessage());
                UtilityClass.createApexLogRecord(ex, 'SetupEventsMethods', 'shareMeetingNoteWithEventAttendees');
            }
        }
        System.debug('shareMeetingNoteWithEventAttendees() METHOD ENDS');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 09 Apr 2020
    // @param: TriggerParameters
    // @description: SFDC-2865 Method to populate primary account on events/meetings. It also sets the correct privacy level on an event. 
    // @return: None
    //------------------------------
    public static void populatePrimaryAccPrivacyLvl(TriggerParameters tp) {
        List<SetupEvents__e> peList = (List<SetupEvents__e>)tp.newList;
        System.debug('populatePrimaryAccPrivacyLvl() METHOD BEGINS');
        Set<Id> evtIdSet = new Set<Id>();        
        
        for(SetupEvents__e peObj:peList) {
            if(peObj.SetPrivacyLevel__c) {
            	evtIdSet.add(peObj.EventId__c);    
            }
        }
        if(evtIdSet.size() > 0) {
            try {
                isPlatformEventScopeActive = true;
                EventMeetingNoteSyncUtility.populatePrivacyLvlAccOnEvent(evtIdSet);
                isPlatformEventScopeActive = false;
            }
            catch(Exception ex) {
                System.debug('Exception in SetupEventsMethods. ex.getMessage()='+ex.getMessage());
                UtilityClass.createApexLogRecord(ex, 'SetupEventsMethods', 'populatePrimaryAccPrivacyLvl');
            }            
            /*System.debug('08Apr Starting AccountId Checks');
            List<EventRelation> masterDeleteList = new List<EventRelation>();
            List<EventRelation> masterCloneList = new List<EventRelation>();
            Set<Id> internalAccIds = new Set<Id>();
            internalAccIds = UtilityClass.InternalAccountIds;
            evtList = [SELECT Id,AccountId,WhoId,(SELECT Id,AccountId, IsInvitee, IsParent, IsWhat, RelationId, Response, Status,EventId FROM EventRelations ORDER BY IsWhat DESC) FROM Event WHERE Id IN :evtIdSet];
            for(Event evtObj:evtList) {
                System.debug('evtObj.AccountId='+evtObj.AccountId);
                List<EventRelation> evtRelList = new List<EventRelation>();	
                if(evtObj.EventRelations != null && evtObj.EventRelations.size() > 0) {
                    evtRelList = evtObj.EventRelations;
                }
                System.debug('evtObj.EventRelations='+evtObj.EventRelations);
                if(internalAccIds.contains(evtObj.AccountId) && evtRelList!=null && evtRelList.size()>0) {
                    List<EventRelation> externalContactList = new List<EventRelation>();
                    List<EventRelation> internalContactList = new List<EventRelation>();
                    List<EventRelation> internalContactCloneList = new List<EventRelation>();
                    for(EventRelation evtRelObj:evtRelList) {
                        //If WhatId has set the AccountId then skip iterations for event relations as WhatId holds the highest precedence to set AccountId
                        if(evtRelObj.isWhat && evtRelObj.AccountId==evtObj.AccountId) {
                            System.debug('08Apr Event AccountId is set by WhatId, so no update');
                            break;
                        }
                        if(!evtRelObj.IsWhat && evtRelObj.IsParent && evtRelObj.AccountId!=null) {
                            if(!internalAccIds.contains(evtRelObj.AccountId)) {
                                externalContactList.add(evtRelObj);
                            }
                            else {
                                internalContactList.add(evtRelObj);
                                EventRelation evtRelClone = evtRelObj.clone();                                
                                evtRelClone.Id=null;
                                internalContactCloneList.add(evtRelClone);                                
                            }
                        }
                    }
                    if(externalContactList.size() > 0 && internalContactList.size() > 0 && internalContactCloneList.size() > 0 && internalContactCloneList.size() == internalContactList.size()) {
                        System.debug('08Apr Event needs AccountId reshuffling');
                        masterDeleteList.addAll(internalContactList);
                        masterCloneList.addAll(internalContactCloneList);       
                    }
                    System.debug('internalContactList='+internalContactList);
                    System.debug('internalContactCloneList='+internalContactCloneList);
                }
            }
            if(masterDeleteList.size() > 0 && masterDeleteList.size() == masterCloneList.size()) {
                delete masterDeleteList;
                insert masterCloneList;
            }
            
            //Update Privacy Level on Event            
            System.debug('08Apr Starting Privacy Checks');
            List<Event> updateEventList = new List<Event>();
            for(Event evt: [SELECT Id,AccountId,(SELECT Id,IsInvitee FROM EventRelations WHERE IsInvitee=true LIMIT 1) FROM Event WHERE Id IN :evtIdSet]) {
                System.debug('evt.AccountId='+evt.AccountId);
                String privacyLevel = '';
                if(evt.AccountId!=null) {
                    privacyLevel = internalAccIds.contains(evt.AccountId) ? 'Internal meeting' : 'Customer-facing meeting';
                }
                else {
                    privacyLevel = (evt.EventRelations!=null && evt.EventRelations.size()>0) ? 'Internal meeting' : 'Personal appointment';
                }
                System.debug('privacyLevel='+privacyLevel);
                if(String.isNotBlank(privacyLevel)) {
                    updateEventList.add(new Event(Id=evt.Id,PrivacyLevel__c=privacyLevel));
                }           
            }
            if(updateEventList.size()>0) {
                System.debug('PrivacyLevel updateEventList='+updateEventList);
                update updateEventList;
            }
			*/
        }
        System.debug('populatePrimaryAccPrivacyLvl() METHOD ENDS');
    }

}