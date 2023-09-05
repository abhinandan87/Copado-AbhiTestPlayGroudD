//-----------------------------
// @author: Uttam Arya
// @date: 29 Aug 2017
// @param: NA
// @description: SFDC1-2243 Class to hold Event trigger methods 
// @return: NA
//-----------------------------
public class EventMethods {
    public static Boolean isRunningSyncMeetingNoteWithEvent = false;
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 Aug 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-2243 Whenever an Event is added to an opportunity,  
    //                  MISActivityAdded field is auto populated with the current timestamp. 
    //                  This is used for MIS pipeline reporting.
    // @return: None
    //
    // @Update by : Mohit Modi
    // @Updated date : 12 Sept 2018
    // @Updated description : SFDC1-9729 To set Activity Created field=true on related Opportunity when Event is Created
    // @updated by : Paras Dhingra
    // @updated date: 11/11/2019
    // @Updated description: SFDC-2259 To fix the code to avoid having duplicate oppy in the list to update
     // @Update by : Paras Dhingra
    // @Updated date : 06 Dec 2020
    // @Updated description : SFDC-2594 adding exemption to prevent validations from firing
    //------------------------------
    public static void populateEventAddedInOpportunityWhenEventIsInserted(TriggerParameters tp) {
    
        //map of Opportunity that needs to be updated
        Map<Id,Opportunity> mapOpportunityToUpdate = new Map <Id,Opportunity>();
        
        for(Event Event: (List <Event>) tp.newList) {
            if(Event.WhatId != null && String.valueOf(Event.WhatId).startsWith('006')) {
                Opportunity oppyToUpdate = new Opportunity(Id = Event.WhatId, MISActivityAdded__c = Datetime.now(), ActivityCreated__c=true);
                mapOpportunityToUpdate.put(Event.WhatId,oppyToUpdate);
            }
        }
        
        //update if map has any records
        if(mapOpportunityToUpdate != null && !mapOpportunityToUpdate.isEmpty()) {
            GlobalConstants.hasBeenValidatedOnce = true;
            update mapOpportunityToUpdate.values();
            GlobalConstants.hasBeenValidatedOnce = false;
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 15 Jun 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8541 Convert Process Builder flow "Event-Copy Activity Type from Standard Type" on Event object created in SFDC1-6039(Create Time Tracking Record) to a trigger
    //               This methods sets Activity Type field from standard Type field on Event object during before insert and update transactions.
    // 
    // @return: None
    // @LastModified By: Harshit Singhal
    // @LastModified Date: 19 May 2020
    // @LastModified Reason: SFDC-2997 For outlook synced events, Type should default to Meeting and not blank. Since outlook events do not have Rectypeid populated at sync, we have to do this for all events record types.
    //------------------------------
    public static void setActivityTypeFromType(TriggerParameters tp) {        
        Id stdEvtRecTypeId = EventMeetingNoteSyncUtility.stdEventRecTypeId;
        for(Event newEvt: (List<Event>)tp.newList) {
            //Before Insert
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
                //Set Type='Meeting' as default for outlook synced events. No RecordTypeId set during outlook sync.
                newEvt.Type = (String.isBlank(newEvt.Type) && !newEvt.IsChild) ? 'Meetings' : newEvt.Type;
                newEvt.ActivityType__c = newEvt.Type;
            }
            //Before update
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {                
                Event oldEvt = (Event)tp.oldMap.get(newEvt.Id);
                if(newEvt.Type!=oldEvt.Type) {                    
                    newEvt.ActivityType__c = newEvt.Type;
                }                   
            }
        }        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 31 Mar 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2748 Create meeting note automatically from an event. This can happen on after insert and after update based on certain criteria. 
    // @return: None
    //------------------------------
    public static void createMeetingNote(TriggerParameters tp) {
        GlobalConstants.isCreateMeetingNoteMethodExecuting = true;
        Set<Id> eventIdSetToProcess = new Set<Id>();        
        for(Event newEvt: (List<Event>)tp.newList) {
            if(EventMeetingNoteSyncUtility.shouldEventHaveMeetingNote(newEvt)) {
            //if(newEvt.MeetingNote__c == null && newEvt.RecordTypeId == stdEventRecTypeId && newEvt.AccountId != null && !newEvt.IsChild) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                    eventIdSetToProcess.add(newEvt.Id);                    
                }
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    Event oldEvent = (Event)tp.oldMap.get(newEvt.Id);
                    if(oldEvent.AccountId == null && oldEvent.AccountId != newEvt.AccountId) {
                        eventIdSetToProcess.add(newEvt.Id);                        
                    }
                }
            }
        }
        
        if(eventIdSetToProcess.size()>0) {
            
            //Get mappings from Custom Metadata
            Map<String,String> evtToMtngNoteCreationMap = EventMeetingNoteSyncUtility.EventMeetingNoteSyncFieldsMap;
            /*Map<String,String> evtToMtngNoteCreationMap = new Map<String,String>();
            for(EventMeetingNoteSyncMapping__mdt evtToMtngNoteCreationMapObj: [SELECT EventFieldAPI__c, MeetingNoteFieldAPI__c FROM EventMeetingNoteSyncMapping__mdt WHERE MapOnEventInsert__c=true]) {
                if(String.isNotBlank(evtToMtngNoteCreationMapObj.EventFieldAPI__c) && String.isNotBlank(evtToMtngNoteCreationMapObj.MeetingNoteFieldAPI__c)) {
                    evtToMtngNoteCreationMap.put(evtToMtngNoteCreationMapObj.EventFieldAPI__c, evtToMtngNoteCreationMapObj.MeetingNoteFieldAPI__c);
                }
            }*/
            
            //Create Meeting Note
            List<MeetingNote__c> insertMtngNoteList = new List<MeetingNote__c>();
            for(Id evtId:eventIdSetToProcess) {
                Event sourceObj = (Event)tp.newMap.get(evtId);
                
                MeetingNote__c targetObj = EventMeetingNoteSyncUtility.createMeetingNoteFromEvent(sourceObj, evtToMtngNoteCreationMap);
                /*//-----------------------------------------------
                MeetingNote__c targetObj = new MeetingNote__c(Account__c=sourceObj.AccountId, RelatedEventId__c=evtId);                
                
                //String defaultMeetingNoteName = 'Meeting with '+accNameMap.get(sourceObj.AccountId).Name;
                String defaultMeetingNoteName = sourceObj.Subject;
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
                //--------------------------------------------*/
                insertMtngNoteList.add(targetObj);
            }
            //Insert meeting notes
            if(insertMtngNoteList.size() > 0) {
                insert insertMtngNoteList;
            }
            //Update MeetingNote lookup on Event happens in MeetingNote After trigger
        }
        GlobalConstants.isCreateMeetingNoteMethodExecuting = false;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 31 Mar 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2748 Sync updates on event with related meeting note automatically. There is a custom metadata which contains field names for sync. Meeting Note Name is always synced by default.
    // @return: None
    //------------------------------
    public static void syncMeetingNoteWithEvent(TriggerParameters tp) {
        isRunningSyncMeetingNoteWithEvent = true;
        //Map<String,String> evtToMtngNoteSyncMap = new Map<String,String>();
        Map<String,String> evtToMtngNoteSyncMap = EventMeetingNoteSyncUtility.EventMeetingNoteSyncFieldsMap;
        List<MeetingNote__c> mtngNoteUpdateList = new List<MeetingNote__c>();
        
        //Get sync fields
        /*for(EventMeetingNoteSyncMapping__mdt evtToMtngNoteSyncMapObj: [SELECT EventFieldAPI__c, MeetingNoteFieldAPI__c FROM EventMeetingNoteSyncMapping__mdt WHERE SyncDirection__c IN ('Bidirectional','EventToMeetingNote')]) {
            if(String.isNotBlank(evtToMtngNoteSyncMapObj.EventFieldAPI__c) && String.isNotBlank(evtToMtngNoteSyncMapObj.MeetingNoteFieldAPI__c)) {
                evtToMtngNoteSyncMap.put(evtToMtngNoteSyncMapObj.EventFieldAPI__c, evtToMtngNoteSyncMapObj.MeetingNoteFieldAPI__c);
            }
        }        
        for(EventMeetingNoteSync__c csObj : [SELECT Id,Name,MeetingNoteFieldAPI__c,SyncDirection__c FROM EventMeetingNoteSync__c WHERE MeetingNoteFieldAPI__c!=null AND SyncDirection__c IN ('EventToMeetingNote','Bidirectional')]) {
            evtToMtngNoteSyncMap.put(csObj.Name, csObj.MeetingNoteFieldAPI__c);
        }*/
        
        //Check field updates and sync logic
        for(Event newEvt: (List<Event>)tp.newList) {
            if(newEvt.MeetingNote__c != null) {                
                Event oldEvt = (Event)tp.oldMap.get(newEvt.Id);
                MeetingNote__c mtngNoteObj = new MeetingNote__c(Id=newEvt.MeetingNote__c);
                Boolean isUpdateNeeded = false;
                
                //Check for field updates - which need transformations in target(NOT IN CUSTOM SETTING SYNC MAPPING)
                if(newEvt.Subject != oldEvt.Subject) {
                    //String defaultMeetingNoteName = 'Meeting with '+accNameMap.get(newEvt.AccountId).Name;                    
                    String defaultMeetingNoteName = newEvt.Subject;
                	mtngNoteObj.Name = defaultMeetingNoteName.length() > 80 ? defaultMeetingNoteName.left(77) + '...' : defaultMeetingNoteName;                	
                    isUpdateNeeded = true;
                }                
                if(newEvt.WhatId!=null && newEvt.WhatId != oldEvt.WhatId && String.valueOf(newEvt.WhatId.getSObjectType())=='Opportunity') {
                    mtngNoteObj.Opportunity__c = newEvt.WhatId;
                    isUpdateNeeded = true;
                }
                //Check for field updates - identical values in source and target
                for(String eventFieldAPI: evtToMtngNoteSyncMap.keySet()) {
                    if(newEvt.get(eventFieldAPI) != oldEvt.get(eventFieldAPI)) {
                        mtngNoteObj.put(evtToMtngNoteSyncMap.get(eventFieldAPI),newEvt.get(eventFieldAPI));
                        isUpdateNeeded = true;
                    }
                }
                if(isUpdateNeeded) {
                    mtngNoteUpdateList.add(mtngNoteObj);
                }
            }            
        }
        if(mtngNoteUpdateList.size() > 0) {
            update mtngNoteUpdateList;            
        }
        isRunningSyncMeetingNoteWithEvent = false;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 06 Apr 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2752 Enforce validation checks on event before deletion
    // 					1. Cannot delete an event with NotesCompleted__c=true
    // @return: None
    //------------------------------    
    public static void enforceDeleteValidations(TriggerParameters tp) {
        for(Event evtObj: (List<Event>) tp.oldList) {
            if(evtObj.NotesCompleted__c) {                
                evtObj.addError('You cannot delete an event with completed notes.');
            }
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 09 Apr 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2865 Method publishes platform events(SetupEvents__e) to update AccountId and PrivacyLevel__c information on Event record. Called in after insert and after update.
    // 				This is implemented via platform events to break the synchronous transaction because outlook sync events do not work well synchronously.    // 
    // @return: None
    //------------------------------
    public static void publishSetupEventPlatformEvents(TriggerParameters tp) {
        //System.debug('08Apr publishSetupEventPlatformEvents() BEGINS');
        if(Boolean.valueOf(Label.DoNotFireSetupEventPE) || (MeetingNoteMethods.isRunningPopulateMeetingNoteOnRelatedEvent && !BatchCreateMeetingNoteForEvent.isExecutingBatchCreateMeetingNoteForEvent) || SetupEventsMethods.isPlatformEventScopeActive) {
            System.debug('About to return. publishSetupEventPlatformEvents() ENDS');
            return;
        }
        List<SetupEvents__e> platfEvtList = new List<SetupEvents__e>();
        //Query child event relations
        Map<Id,Event> evtMap;
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            evtMap = new Map<Id,Event>([SELECT Id,RecordTypeId,IsChild,AccountId,WhoId,IsRecurrence2,PrivacyLevel__c,(SELECT Id,AccountId, IsInvitee, IsParent, IsWhat, RelationId, Response, Status,EventId FROM EventRelations ORDER BY IsWhat DESC) FROM Event WHERE Id IN :tp.newList]);
        }
        for(Event evt: (List<Event>)tp.newList) {
            if(evt.RecordTypeId==EventMeetingNoteSyncUtility.stdEventRecTypeId && !evt.IsChild) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert && (String.isBlank(evt.PrivacyLevel__c) || evt.MeetingNote__c!=null)) {
                    Boolean setPrivacyLevel = String.isBlank(evt.PrivacyLevel__c) && !evt.IsRecurrence2 ? true : false;
                    Boolean setMeetingNoteShare = EventMeetingNoteSyncUtility.shouldEventHaveMeetingNote(evt) ? true : false;
                    SetupEvents__e platEvtObj = new SetupEvents__e(EventId__c=evt.Id, SetPrivacyLevel__c=setPrivacyLevel, SetMeetingShare__c=setMeetingNoteShare);
                    //System.debug('INSERT Platform Event platEvtObj='+platEvtObj);
                    platfEvtList.add(platEvtObj);
                }
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    Event evtWithReationObj = evtMap.get(evt.Id);
                    Boolean setPrivacyLevel = EventMeetingNoteSyncUtility.checkIfEventSetupRequired(evtWithReationObj) ? true : false;
                    Boolean setMeetingNoteShare = EventMeetingNoteSyncUtility.shouldEventHaveMeetingNote(evt) || evt.MeetingNote__c!=null ? true : false;		//Since EventRelations are generated asynchronously for outlook sync events, run this for every update transaction on event that has a meeting note or is eligible to have a meeting note
					SetupEvents__e platEvtObj = new SetupEvents__e(EventId__c=evt.Id, SetPrivacyLevel__c=setPrivacyLevel, SetMeetingShare__c=setMeetingNoteShare);
                    //System.debug('UPDATE Platform Event platEvtObj='+platEvtObj);                    
                    platfEvtList.add(platEvtObj);                    
                }                
            }            
        }
        //System.debug('08Apr platfEvtList.size='+platfEvtList.size());
        //System.debug('08Apr platfEvtList='+platfEvtList);
        if(platfEvtList.size() > 0) {
            List<Database.SaveResult> results = EventBus.publish(platfEvtList);
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    //System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +err.getStatusCode() + ' - ' +err.getMessage());
                    }
                }       
            }    
        }
        //System.debug('08Apr publishSetupEventPlatformEvents() ENDS');        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 09 Apr 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2748 Delete related meeting note when event is deleted, if meeting outcome is not filled.
    // @return: None
    // @modifiedBy: Priyanka Vyas
    // @modificationDate: 01 Sep 2020
    // @modificationDescription: SFDC-3133 Collect the opportunity IDs of all Related Opportunities whose parent Meeting Note records are being
    // 							 deleted so that these opportunities can be re-evaluated during the event deletion process to check/uncheck activitycreated__c checkbox.
    // @LastModified By: Akash Punera
    // @LastModified Date: 22 Feb 2022
    // @LastModified Reason: SFDC-5373 Remove SOQL inside for loop
    //------------------------------    
    public static void deleteRelatedMeetingNote(TriggerParameters tp) {
		Set<ID> opportunityIDsOfRelatedOppy = new Set<ID>();
        List<Opportunity> opportunityListToUpdate=new List<Opportunity>();
        Map<Id, Opportunity> opportunityNamesMap;
		Set<ID> meetingNoteIDSet = new Set<ID>();        
        try{
            List<MeetingNote__c> deleteMeetingNoteList = new List<MeetingNote__c>();
            for(Event evt: (List<Event>)tp.oldList) {
                if(evt.MeetingNote__c != null && !evt.NotesCompleted__c) {
                    deleteMeetingNoteList.add(new MeetingNote__c(Id=evt.MeetingNote__c));
                    meetingNoteIDSet.add(evt.MeetingNote__c);
                }
            }
            List<RelatedOpportunity__c> RelatedOpportunityList = new List<RelatedOpportunity__c>();
            RelatedOpportunityList = [Select opportunity__c, meetingnote__c from RelatedOpportunity__c where opportunity__c!=null and MeetingNote__c in:meetingNoteIDSet];
            if(RelatedOpportunityList!=null && !RelatedOpportunityList.isEmpty()) {   
                for(RelatedOpportunity__c relatedOppy: RelatedOpportunityList){
                    if(relatedOppy.opportunity__c!=null) {
                        opportunityIDsOfRelatedOppy.add(relatedOppy.opportunity__c);
                    }
                }
            }
            for(Event oldEvent: (List<Event>)tp.oldList) {           
            	if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
            		if(oldEvent.WhatId!=null && String.valueOf(oldEvent.WhatId).startsWith('006') && oldEvent.IsChild==false) {
                        opportunityIDsOfRelatedOppy.add(oldEvent.WhatId);
                    }
                }
            }
            if(deleteMeetingNoteList.size() > 0) {
                delete deleteMeetingNoteList;
            }
            //To check ActivityCreated__c field on the Opportunity records and check/uncheck accordingly
            if(opportunityIDsOfRelatedOppy!=null && !opportunityIDsOfRelatedOppy.isEmpty() && opportunityIDsOfRelatedOppy.size()>0) {
                opportunityNamesMap = new Map<Id, Opportunity>([Select name from Opportunity where id in:opportunityIDsOfRelatedOppy]);
                opportunityListToUpdate=UtilityClass.setCreateActivityAsFalse(opportunityIDsOfRelatedOppy);
            }
            if(opportunityListToUpdate.size()>0) {
                update opportunityListToUpdate;
            }
        }
        catch(Exception ex){
            //SFDC-5373 Remove SOQL inside for loop/ populate opportunityNamesMap outside of loop
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,') && ex.getMessage().contains(Label.ActivityRequiredForStage5NewBusiness) && 
               opportunityIDsOfRelatedOppy!=null && !opportunityIDsOfRelatedOppy.isEmpty() && opportunityIDsOfRelatedOppy.size()>0) {
                   opportunityNamesMap = new Map<Id, Opportunity>([Select name from Opportunity where id in:opportunityIDsOfRelatedOppy]);
               }
            for(Event evt: (List<Event>)tp.oldList) {
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                    //ActivityRequiredForStage5NewBusiness validation rule on Opportunity handling.
                    if(ex.getMessage().contains(Label.ActivityRequiredForStage5NewBusiness)) {
                        
                    	String errorMessage=ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1];
                    	String opportunityIdInErrorMsg = ex.getMessage().split('; first error:')[0].split('with id ')[1];
                        if(opportunityNamesMap!=null && !opportunityNamesMap.isEmpty() && opportunityIdInErrorMsg.startsWith('006')) {
                            evt.addError('"'+opportunityNamesMap.get(opportunityIdInErrorMsg).name+'": '+errorMessage);
                        }
                        else {
                            evt.addError(ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1]);
                        }
                    }
                    else {
                        evt.addError(ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1]);
                    }
                }
                else {
               		evt.addError(ex.getMessage());
                }
            }
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 29 Apr 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2748 Enforce validations
    // 					- Do not allow users to populate MeetingNote__c lookup field manually on standard record type Event. Exception is System Administrator.
    // @return: None
	// @modifiedBy: Paras Dhingra
	// @modifiedDate: 12th Nov 2020
	// @description: SFDC-3331 - adding static variable to make sure validations are fired once in a transaction so that workflow update does not alter the flow
    //------------------------------   
    public static void enforceEventValidations(TriggerParameters tp) {
        if(GlobalVariables.hasEventValidationsFired) {
            return;
        }
        GlobalVariables.hasEventValidationsFired = true;
        for(Event newEvt: (List<Event>)tp.newList) {            
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {                
                EventMeetingNoteSyncUtility.cannotUpdateMeetingNoteManually(newEvt,null,'Insert');
            }
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                Event oldEvt = (Event)tp.oldMap.get(newEvt.Id);
                EventMeetingNoteSyncUtility.cannotUpdateMeetingNoteManually(newEvt,oldEvt,'Update');
            }            
        }
    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 25 Aug 2020
    // @param: TriggerParameters tp
    // @description: SFDC-3133 Change ActivityCreated__c on Opportunity when the WhatId on event is updated.
    // @return: None
    //------------------------------   
    public static void changeActivityCreatedCheckboxOnOpportunity(TriggerParameters tp) {
        Set<ID> OpportunityIDSetOld=new Set<ID>();
        Set<ID> OpportunityIDSetNew=new Set<ID>();
        List<Opportunity> opportunityListToUpdate=new List<Opportunity>();
        for(Event newEvent: (List<Event>)tp.newMap.values()) {            
            Event oldEvent = new Event();         
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            	oldEvent = (Event)tp.oldMap.get(newEvent.Id);
                if(oldEvent.WhatId!=null && String.valueOf(oldEvent.WhatId).startsWith('006') && oldEvent.WhatId!=newEvent.WhatId && oldEvent.IsChild==false) {
                    OpportunityIDSetOld.add(oldEvent.WhatId);
                }
                if(newEvent.WhatId!=null && String.valueOf(newEvent.WhatId).startsWith('006') && oldEvent.WhatId!=newEvent.WhatId && newEvent.IsChild==false) {
                    OpportunityIDSetNew.add(newEvent.WhatId);
                }
            }
        }
        if(OpportunityIDSetOld!=null && !OpportunityIDSetOld.isEmpty()) {
        	opportunityListToUpdate = UtilityClass.setCreateActivityAsFalse(OpportunityIDSetOld);
        }
        if(OpportunityIDSetNew.size()>0) {
            for(Opportunity opp:[Select id,name, ActivityCreated__c from Opportunity where id in: OpportunityIDSetNew]) {
                if(opp.ActivityCreated__c==false) {
                    opp.ActivityCreated__c=true;
                    opportunityListToUpdate.add(opp);
                }
            }
        }
        if(opportunityListToUpdate.size()>0) {
            update opportunityListToUpdate;
        }
    }
}