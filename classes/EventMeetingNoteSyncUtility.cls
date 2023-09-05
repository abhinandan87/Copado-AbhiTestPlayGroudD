//-----------------------------
// @author: Harshit Singhal
// @date: 27 Apr 2020
// @description: SFDC-2733 This is a utility class for Event MeetingNote sync functionality. It supports relevant methods in:
// 							- EventMethods Trigger helper
// 							- MeetingNoteMethods Trigger helper
// 							- SetupEventMethods PlatformEvent trigger helper
// 							- BatchSetupMeetingNoteEventSync batch class
// 							- BatchFillEventPrivacyLevel batch class
// -----------------------------
public class EventMeetingNoteSyncUtility {
       
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020    
    // @description: SFDC-2748 Property: Map of Event->MeetingNote fields map that should be synced during insert/update    
    //------------------------------    
    public static Map<String,String> EventMeetingNoteSyncFieldsMap {
        get {
            if(EventMeetingNoteSyncFieldsMap == null) {
                EventMeetingNoteSyncFieldsMap = new Map<String,String>();
                /*for(EventMeetingNoteSyncMapping__mdt evtToMtngNoteCreationMapObj: [SELECT EventFieldAPI__c, MeetingNoteFieldAPI__c FROM EventMeetingNoteSyncMapping__mdt WHERE MapOnEventInsert__c=true]) {
                    if(String.isNotBlank(evtToMtngNoteCreationMapObj.EventFieldAPI__c) && String.isNotBlank(evtToMtngNoteCreationMapObj.MeetingNoteFieldAPI__c)) {
                        EventMeetingNoteSyncFieldsMap.put(evtToMtngNoteCreationMapObj.EventFieldAPI__c, evtToMtngNoteCreationMapObj.MeetingNoteFieldAPI__c);
                    }
                }*/                
                for(EventMeetingNoteSync__c csObj : [SELECT Id,Name,MeetingNoteFieldAPI__c,SyncDirection__c FROM EventMeetingNoteSync__c WHERE MeetingNoteFieldAPI__c!=null AND SyncDirection__c IN ('EventToMeetingNote','Bidirectional')]) {
                    EventMeetingNoteSyncFieldsMap.put(csObj.Name, csObj.MeetingNoteFieldAPI__c);
                }
            }
            return EventMeetingNoteSyncFieldsMap;
        }
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020    
    // @description: SFDC-2748 Property: Id of Standard recordtype on Event object 
    //------------------------------    
    public static Id stdEventRecTypeId {
        get {
            if(stdEventRecTypeId == null) {
                stdEventRecTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            }
            return stdEventRecTypeId;
        }
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: Event record to be evaluated
    // @description: SFDC-2748 Method that returns true if an event record fulfills the criteria to have an automated meeting note created for itself. Else, returns false.
    // 				Criteria: 	
    // 					- Should not already have MeetingNote__c lookup populated
    // 					- Event should be of Standard recordtype(as it is default for Sales users)
    // 					- Event should not be a child event(For series events, 2nd occurrence and henceforth are child event records. 1st occurrence is the main/parent event.)
    // 					- Event should have a primary account associated with it either via RelatedTo(WhatId) or Name(WhoId) field. So that, meeting notes should be taken for an event that is associated to a client/customer.
    // @return: Boolean
    //------------------------------    
    public static Boolean shouldEventHaveMeetingNote(Event evt) {
        Boolean result = false;
        if(evt.MeetingNote__c == null && evt.RecordTypeId == stdEventRecTypeId && evt.AccountId != null && !evt.IsChild && !evt.IsRecurrence2) {
            result = true;
        }
        return result;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: None
    // @description: SFDC-2761 Creates default soql query for BatchSetupMeetingNoteEventSync class
    // @return: String finalQuery
    //------------------------------    
    public static String buildBatchSetupMeetingNoteEventSyncQuery() {
        Set<String> evtFieldSet = new Set<String>{ 'Id', 'AccountId', 'MeetingNote__c', 'MeetingNote__r.RelatedEventId__c', 'RecordType.Name', 'RecordTypeId', 'WhatId', 'IsChild', 'IsRecurrence2' };        
        evtFieldSet.addAll(EventMeetingNoteSyncFieldsMap.keySet());
        String selectFields = String.join(new List<String>(evtFieldSet), ', ');
        System.debug('selectFields='+selectFields);
        
        String selectQuery = 'SELECT ' + selectFields;        
        String fromQuery = ' FROM Event ';
        String whereQuery = ' WHERE (MeetingNote__c!=null AND RecordType.Name=\'Standard\' AND MeetingNote__r.RelatedEventId__c=null AND IsChild=false) OR (AccountId!=null AND RecordType.Name=\'Standard\' AND IsChild=false AND MeetingNote__c=null AND IsRecurrence2=false) ';
        String orderByQuery = ' ORDER BY MeetingNote__c ASC';
        String finalQuery = selectQuery + fromQuery + whereQuery + orderByQuery;        
        
        return finalQuery;        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: 
    // 			- sourceObj: Source event record for new Meeting Note record
    // 			- evtToMtngNoteCreationMap: EventFields -> MeetingNoteFields map used for initialising meetingnote record
    // 			
    // @description: SFDC-2748, SFDC-2761: Method to initialise a meeting note from a source event record based on sync fields given in a map
    // @return: targetObj - MeetingNote record to be created
    //------------------------------    
    public static MeetingNote__c createMeetingNoteFromEvent(Event sourceObj, Map<String,String> evtToMtngNoteCreationMap) {        
        
        //MeetingNote__c targetObj = new MeetingNote__c(Account__c=sourceObj.AccountId, RelatedEventId__c=sourceObj.Id);
        MeetingNote__c targetObj = new MeetingNote__c(Account__c=sourceObj.AccountId, RelatedEventId__c=sourceObj.Id, OwnerId=sourceObj.OwnerId);
        //String defaultMeetingNoteName = 'Meeting with '+accNameMap.get(sourceObj.AccountId).Name;
        String defaultMeetingNoteName = String.isNotBlank(sourceObj.Subject) ? sourceObj.Subject : '[No Subject]';
        targetObj.Name = defaultMeetingNoteName.length() > 80 ? defaultMeetingNoteName.left(77) + '...' : defaultMeetingNoteName;
        //Map opportunity in meeting note to create default related opportunity record in meeting note trigger
        if(sourceObj.WhatId!=null && String.valueOf(sourceObj.WhatId.getSObjectType())=='Opportunity') {
            targetObj.Opportunity__c = sourceObj.WhatId;                    
        }
        //Map fields as per sync mapping configuration
        for(String eventFieldAPI:evtToMtngNoteCreationMap.keySet()) {
            String mtngNoteFieldAPI = evtToMtngNoteCreationMap.get(eventFieldAPI);
            targetObj.put(mtngNoteFieldAPI, sourceObj.get(eventFieldAPI));
        }
        
        return targetObj;        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: evtIdMtndNoteIdMap - Map of EventId-> MeetingNoteId that contains Event record Id and its respective MeetingNote record id
    // @description: SFDC-2761 Method to copy Meeting Attendees from MeetingNote to Event as EventRelation records.
    // @return: evtRelList - List of EventRelation records to be added in Event
    //------------------------------    
    public static List<EventRelation> createEventRelationsFromMeetingAttendees(Map<Id,Id> evtIdMtndNoteIdMap) {
        List<EventRelation> evtRelList = new List<EventRelation>();
        if(evtIdMtndNoteIdMap!=null && evtIdMtndNoteIdMap.size() > 0) {
            Map<Id,Event> evtWithRelationsMap = new Map<Id,Event>([SELECT Id,(SELECT Id,EventId,RelationId,IsWhat,IsParent,IsInvitee FROM EventRelations WHERE IsWhat=false) FROM Event WHERE Id IN :evtIdMtndNoteIdMap.keySet()]);
            Map<Id,MeetingNote__c> mtngWithAttendeesMap = new Map<Id,MeetingNote__c>([SELECT Id,(SELECT Id,Contact__c FROM MeetingAttendees__r WHERE Contact__c!=null) FROM MeetingNote__c WHERE Id IN :evtIdMtndNoteIdMap.values()]);
            //Write logic to compare with existing relations and add new meeting attendees as event relations
            
            for(Id evtId:evtIdMtndNoteIdMap.keySet()) {
                Event evtObj = evtWithRelationsMap.get(evtId);
                MeetingNote__c mtngNoteObj = mtngWithAttendeesMap.get(evtIdMtndNoteIdMap.get(evtId));
                Map<Id,EventRelation> evtRelContactIdMap = new Map<Id,EventRelation>();
                //Collect pre-existing Event Relation records
                if(evtObj.EventRelations!=null && evtObj.EventRelations.size()>0) {
                    for(EventRelation evrObj: evtObj.EventRelations) {
                        //evtRelContactIdMap.put(evrObj.Id, evrObj.RelationId);
                        evtRelContactIdMap.put(evrObj.RelationId, evrObj);
                    }                    
                }
                //Collect unique meeting attendee contacts
                Map<Id,MeetingAttendee__c> contactIdMeetingAttendeeMap = new Map<Id,MeetingAttendee__c>();
                if(mtngNoteObj.MeetingAttendees__r!=null && mtngNoteObj.MeetingAttendees__r.size()>0) {
                    for(MeetingAttendee__c mtngAtt: mtngNoteObj.MeetingAttendees__r) {
                        contactIdMeetingAttendeeMap.put(mtngAtt.Contact__c,mtngAtt);                        
                    }                    
                }
                //For each unique meeting attendee, create event relation record if it does not exist
                for(Id contactId: contactIdMeetingAttendeeMap.keySet()) {
                    MeetingAttendee__c mtngAtt = contactIdMeetingAttendeeMap.get(contactId);
                    if(!evtRelContactIdMap.containsKey(contactId)) {
                        //Create new Event Relation record                        
                        //EventRelation evtRelObj = new EventRelation(EventId=evtId, RelationId=contactId, IsWhat=false, IsParent=true, IsInvitee=true);
                        EventRelation evtRelObj = new EventRelation(EventId=evtId, RelationId=contactId, IsWhat=false, IsParent=true, IsInvitee=false);
                        evtRelList.add(evtRelObj);
                    }
                    else {
						EventRelation existingEvr = evtRelContactIdMap.get(mtngAtt.Contact__c);
                        if(!existingEvr.IsParent) {
                        //if(!existingEvr.IsInvitee || !existingEvr.IsParent) {                            
                            //existingEvr.IsInvitee = true;
                            existingEvr.IsParent = true;
                            evtRelList.add(existingEvr);
                        }                      
                    }
                }
            }            
        }
        return evtRelList;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: evtObj - Source event record to be validated
    // @description: SFDC-2865 Validates if an event record has a correct accountId and PrivacyLevel__c set. If not it returns true to fire platform event(SetupEvents__e).
    // @return: fireEvent - Boolean flag based on which platform events are fired
    // @updated by: Harshit Singhal
    // @updated date: 23 Jun 2020
    // @updated desc: SFDC-3101 If event is related to lead, privacy level should be customer facing
    //------------------------------
    public static Boolean checkIfEventSetupRequired(Event evtObj) {
        //System.debug('07Apr checkIfEventSetupRequired() BEGINS');
        Boolean fireEvent = false;
        Boolean isPrimaryAccountCorrect = true;
        Boolean isPrivacyLevelCorrect = true;
        Set<Id> internalAccIds = UtilityClass.InternalAccountIds;
        
        List<EventRelation> evtRelList = new List<EventRelation>();
        if(evtObj != null && evtObj.EventRelations != null && evtObj.EventRelations.size() > 0 && evtObj.RecordTypeId==stdEventRecTypeId && !evtObj.IsChild && !evtObj.IsRecurrence2) {
            evtRelList = evtObj.EventRelations;
        }
        //Check Account correctness
        if(evtObj!=null && evtObj.AccountId!=null && internalAccIds.contains(evtObj.AccountId) && evtRelList!=null && evtRelList.size()>0) {
            for(EventRelation evtRelObj:evtRelList) {
                if(evtRelObj.isWhat && evtRelObj.AccountId==evtObj.AccountId) {
                    break;
                }
                if(!evtRelObj.IsWhat && evtRelObj.IsParent && evtRelObj.AccountId!=null) {
                    if(!internalAccIds.contains(evtRelObj.AccountId)) {
                        isPrimaryAccountCorrect = false;
                        break;
                    }
                }                
            }
        }
        //Check Privacy Level correctness
        String privacyLevel = '';
        if(evtObj != null && evtObj.RecordTypeId==stdEventRecTypeId && !evtObj.IsChild && !evtObj.IsRecurrence2) {            
            if(evtObj.AccountId == null) {
                Boolean hasInvitees = false;                
                Boolean hasLeadWhoId = false;
                for(EventRelation evtRelObj:evtRelList) {
                    if(evtRelObj.IsInvitee) {
                        hasInvitees = true;
                        //break;
                    }
                    if(String.valueOf(evtRelObj.RelationId).startsWithIgnoreCase('00Q')) {
                        hasLeadWhoId = true;
                    }
                }
                privacyLevel = hasLeadWhoId ? 'Customer-facing meeting' : (hasInvitees ? 'Internal meeting' : 'Personal appointment');
            }
            else {
                privacyLevel = (internalAccIds.contains(evtObj.AccountId) && isPrimaryAccountCorrect) ? 'Internal meeting' : 'Customer-facing meeting';
            }
            if(evtObj.PrivacyLevel__c != privacyLevel) {
                isPrivacyLevelCorrect = false;
            }    
        }
        //Check Attendees in EventRelations and MeetingShare records for MeetingNote__c
        
        //System.debug('07Apr isPrimaryAccountCorrect='+isPrimaryAccountCorrect);
        //System.debug('07Apr isPrivacyLevelCorrect='+isPrivacyLevelCorrect);
        if(!isPrimaryAccountCorrect || !isPrivacyLevelCorrect) {
            fireEvent = true;
        }
        //System.debug('07Apr fireEvent='+fireEvent);
        //System.debug('07Apr checkIfEventSetupRequired() ENDS');
        return fireEvent;
    }
	
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: evtIdSet - Set of event record Ids for which either correct primary account id needs to be set OR privacy level needs to be updated
    // @description: SFDC-2865 
    // 					1) Method to reshuffle EventRelation records in a way that Event.AccountId should be set per external account if an external contact exists in Event's Name field.
    // 					2) Method to populate PrivacyLevel__c field based on the AccountId populated on event record.
    // @return: None
    // @updated by: Harshit Singhal
    // @updated date: 23 Jun 2020
    // @updated desc: SFDC-3101 If event is related to lead, privacy level should be customer facing    
    //------------------------------
    public static void populatePrivacyLvlAccOnEvent(Set<Id> evtIdSet) {
        if(evtIdSet!=null && evtIdSet.size() > 0) {
            List<Event> evtList = new List<Event>();
            System.debug('08Apr Starting AccountId Checks');
            List<EventRelation> masterDeleteList = new List<EventRelation>();
            List<EventRelation> masterCloneList = new List<EventRelation>();
            Set<Id> internalAccIds = new Set<Id>();
            internalAccIds = UtilityClass.InternalAccountIds;
            evtList = [SELECT Id,AccountId,WhoId,RecordTypeId,IsChild,(SELECT Id,AccountId, IsInvitee, IsParent, IsWhat, RelationId, Response, Status,EventId FROM EventRelations ORDER BY IsWhat DESC) FROM Event WHERE Id IN :evtIdSet];
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
            for(Event evt: [SELECT Id,AccountId,(SELECT Id,IsInvitee,RelationId FROM EventRelations) FROM Event WHERE Id IN :evtIdSet]) {
                System.debug('evt.AccountId='+evt.AccountId);                
                String privacyLevel = '';
                if(evt.AccountId!=null) {
                    privacyLevel = internalAccIds.contains(evt.AccountId) ? 'Internal meeting' : 'Customer-facing meeting';
                }
                else {
                    Boolean hasLeadWhoId = false;
                    Boolean hasInvitees = false;
                    for(EventRelation evtRelObj : evt.EventRelations) {
                        if(evtRelObj.IsInvitee) {
                            hasInvitees = true;
                            //break;
                        }
                        if(String.valueOf(evtRelObj.RelationId).startsWithIgnoreCase('00Q')) {
                            hasLeadWhoId = true;
                        }
                    }
                    privacyLevel = hasLeadWhoId ? 'Customer-facing meeting' : (hasInvitees ? 'Internal meeting' : 'Personal appointment');
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
        }        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 29 Apr 2020
    // @param: 
    // 		newEvt - New copy of event record in update and insert triggerevent
    // 		oldEvt - Old copy of event record in update triggerevent
    // 		op - Whether validation is executing for Insert or Update operation on event.    // 		
    // @description: SFDC-2748 Method to enforce validation on Standard event records that MeetingNote__c field cannot be updated manually. 
    // 					Exceptions: System Admin profile, Automated Process user which is Salesforce backend user to perform platform event jobs, etc.
    // @return: None
    //------------------------------
    public static void cannotUpdateMeetingNoteManually(Event newEvt, Event oldEvt, String op) {        
        Id stdRecTypeId = EventMeetingNoteSyncUtility.stdEventRecTypeId;
        String userProfile = UserInfo.getName()=='Automated Process'? null : UtilityClass.LoggedInUserProfileName;
        String loggedUserName = UtilityClass.LoggedInUserName;
        //List<String> excludeProfiles = new List<String>();
        List<String> excludeProfiles = new List<String>{'System Administrator','IHSMarkit System Admin: API'};
        
        if(newEvt!=null && String.isNotBlank(op) && newEvt.RecordTypeId==stdRecTypeId && !excludeProfiles.contains(userProfile) && loggedUserName!='Automated Process') {
            //System.debug('CHECK FOR INSERT OR UPDATE');
            if(op=='Insert' && newEvt.MeetingNote__c!=null && !GlobalConstants.isCreateMeetingNoteMethodExecuting) {
                //System.debug('INSERT VALIDATION FIRED....');
                newEvt.addError('Meeting Note cannot be populated manually on an event.');
            }
            else if(op=='Update' && oldEvt!=null && newEvt.MeetingNote__c!=oldEvt.MeetingNote__c && !GlobalConstants.isCreateMeetingNoteMethodExecuting) {
                //System.debug('oldEvt.MeetingNote__c='+oldEvt.MeetingNote__c);
                //System.debug('UPDATE VALIDATION FIRED....');
                newEvt.addError('Meeting Note cannot be updated manually on an event.');
            }            
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 14 May 2020
    // @param: evtIdSet - Set of event record Ids for which sharing of related Meeting Note has to be checked and updated
    // @description: SFDC-2733 Method to share(via apex) the Meeting Note related to the event with users present as Attendees in the list. 
    // 					This allows any user attendee to add meeting outcome and related oportunities on Event.    // 					
    // @return: None
    //------------------------------
    public static void setupMeetingNoteSharing(Set<Id> evtIdSet) {
        if(evtIdSet!=null && evtIdSet.size() > 0) {
            //Collect events with meeting notes
            Map<Id,Id> evtIdMtngNoteId = new Map<Id,Id>();
            Map<Id,Event> evtMap = new Map<Id,Event>();
            
            //Filter events with meeting notes and their user attendee event relations.
            for(Event evtWithMeetingNote: [SELECT Id,MeetingNote__c,OwnerId,(SELECT Id,RelationId,EventId FROM EventRelations WHERE IsInvitee=true AND IsParent=false) FROM Event WHERE MeetingNote__c!=null AND Id IN :evtIdSet]) {
                //Process all events having meeting notes
                evtIdMtngNoteId.put(evtWithMeetingNote.Id, evtWithMeetingNote.MeetingNote__c);
                evtMap.put(evtWithMeetingNote.Id,evtWithMeetingNote);
            }
            //Fetch existing meeting note share records
            Map<Id,Map<Id,MeetingNote__Share>> mtngIdMtngShareMap = new Map<Id,Map<Id,MeetingNote__Share>>();
            if(evtIdMtngNoteId.size() > 0) {
                for(MeetingNote__Share mtnhShareObj: [SELECT Id,UserOrGroupId,ParentId,AccessLevel,RowCause FROM MeetingNote__Share WHERE ParentId IN :evtIdMtngNoteId.values() AND RowCause = :Schema.MeetingNote__Share.rowCause.EventAttendeeShare__c]) {
                    if(!mtngIdMtngShareMap.containsKey(mtnhShareObj.ParentId)) {
                        mtngIdMtngShareMap.put(mtnhShareObj.ParentId,new Map<Id,MeetingNote__Share>());
                    }
                    mtngIdMtngShareMap.get(mtnhShareObj.ParentId).put(mtnhShareObj.UserOrGroupId, mtnhShareObj);                    
                }
            }
            //Create new share and delete extra shares
            List<MeetingNote__Share> insMeetingNoteShareList = new List<MeetingNote__Share>();
            List<MeetingNote__Share> sharesToDelete = new List<MeetingNote__Share>();
            for(Event evt: evtMap.values()) {
                Set<Id> relevantAttendeeIds = new Set<Id>();
                //Create Share records as per attendees
                for(EventRelation userAttendee: evt.EventRelations) {
                    String relationIdStr = userAttendee.RelationId;
                    if(relationIdStr.startsWith('005')) {
                        /*//Check if share record already exists
                        if(mtngIdMtngShareMap.containsKey(evt.MeetingNote__c) && mtngIdMtngShareMap.get(evt.MeetingNote__c).containsKey(relationIdStr)) {
                            System.debug('SHARE RECORD EXISTS. Share Record='+mtngIdMtngShareMap.get(evt.MeetingNote__c).get(relationIdStr));
                            //Check if complete access is there
                            if(mtngIdMtngShareMap.get(evt.MeetingNote__c).get(relationIdStr).AccessLevel=='Edit') {
                                System.debug('SHARE RECORD EXISTS AND HAS ALL ACCESS. NO ACTION.');
                                continue;
                            }
                            else {
                                System.debug('SHARE RECORD EXISTS AND DOES NOT HAVE ALL ACCESS. Review and enhance access or create new apex share.');
                                //Review the access on existing share record and enhance it if needed or create another share record with explicit reason.
                            }
                        }*/
                        //If it does not exist
                        //System.debug('SHARE RECORD DOES NOT EXIST. CREATE NEW.');
                        relevantAttendeeIds.add(userAttendee.RelationId);
                        insMeetingNoteShareList.add(new MeetingNote__Share(UserOrGroupId=userAttendee.RelationId,ParentId=evt.MeetingNote__c, AccessLevel='Edit',RowCause=Schema.MeetingNote__Share.rowCause.EventAttendeeShare__c));
                    }
                }
                
                //Delete extra share records                
                if(mtngIdMtngShareMap.containsKey(evt.MeetingNote__c) && mtngIdMtngShareMap.get(evt.MeetingNote__c)!=null && mtngIdMtngShareMap.get(evt.MeetingNote__c).size()>0) {
                    Map<Id,MeetingNote__Share> mtngNoteShareMap = mtngIdMtngShareMap.get(evt.MeetingNote__c);                    
                    Set<Id> existingSharedAttendees = new Set<Id>();
                    existingSharedAttendees.addAll(mtngIdMtngShareMap.get(evt.MeetingNote__c).keySet());
                    existingSharedAttendees.removeAll(relevantAttendeeIds);
                    if(existingSharedAttendees.size() > 0) {
                        for(Id userId: existingSharedAttendees) {
                            sharesToDelete.add(mtngNoteShareMap.get(userId));
                        }
                    }                    
                }
            }
            //System.debug('insMeetingNoteShareList size='+insMeetingNoteShareList.size());
            //System.debug('insMeetingNoteShareList='+insMeetingNoteShareList);
            if(insMeetingNoteShareList.size() > 0) {
                insert insMeetingNoteShareList;
            }
            //System.debug('sharesToDelete size='+sharesToDelete.size());
            //System.debug('sharesToDelete='+sharesToDelete);
            if(sharesToDelete.size() > 0) {
                delete sharesToDelete;
            }            
        }        
    }
    
}