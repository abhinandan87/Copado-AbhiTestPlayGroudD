//-----------------------------
// @author: Paras Dhingra
// @date: 29 Apr 2020
// @description: SFDC-2734 Wrapper class for VF component for custom send meeting note functionality for event management
// @ModifiedBy: Paras Dhingra
// @ModifiedDate: 22 Jun 2020
// @ModifiedDescription: SFDC-2397 modify the wrapper to make sure that Meeting outcome structure holds

// @ModifiedBy: Tran-Vu Tran
// @ModifiedDate: 14 Aug 2020
// @ModifiedDescription: SFDC-3231 add meeting Organizer to be displayed on the email template
// @ModifiedBy: Paras Dhingra
// @ModifiedDate: 10 Nov 2020
// @ModifiedDescription: SFDC-3331 fix child meeting events on the send meeting notes template
//------------------------------	
	global with sharing class ActivitiesEmailTemplateWrapper {
    global String subject {get;set;}
    global String startDate {get;set;}
    global String location {get;set;}
    global String client {get;set;}
    global String ihsMarkit {get;set;}
    global String organizer {get;set;}
    global String meetingOutCome {get;set;}
    global MeetingNote__c meetingNote {get;set;}
    global ActivitiesEmailTemplateWrapper(String eventId) {
        List<String> client = new List<String>();
        List<String> ihsMarkit = new List<String>();
        //fetch event and event relation to populate the wrapper
        Event evt;
        Event tempEvent = [SELECT Id, Subject, StartDateTime, Location, Owner.Name, 
        MeetingNote__r.MeetingOutCome__c, MeetingNote__c,IsChild,ParentID__c 
        FROM event WHERE ID=:eventId limit 1];
        evt = tempEvent; 
        if(tempEvent.IsChild) {
            evt  = [SELECT Id, Subject, StartDateTime, Location, Owner.Name, 
            MeetingNote__r.MeetingOutCome__c, MeetingNote__c,IsChild,ParentID__c 
            FROM event WHERE ID=:tempEvent.ParentID__c limit 1];
        }
        MeetingNote__c mtngNote = [SELECT Id, MeetingOutCome__c
                                   FROM MeetingNote__c WHERE Id=: evt.MeetingNote__c];
        this.subject = evt.Subject;
        this.startDate = evt.StartDateTime.format();
        this.location = evt.Location;
        this.organizer = evt.Owner.Name;
        this.meetingOutCome = evt.MeetingNote__r.MeetingOutCome__c;
        this.meetingNote = mtngNote;
        //query event relation
        List<EventRelation> lstEventRelation = [SELECT 
                                                Id, RelationId, Relation.Name, EventId, IsWhat, IsParent, IsInvitee, AccountId, Status 
                                                FROM EventRelation 
                                                WHERE IsWhat=false 
                                                AND (IsParent=true OR IsInvitee=true)
                                                AND EventId=: evt.Id
                                                ];
        Set<Id> setContactsToQuery = new Set<Id>();
        client = new List<String>();
        ihsMarkit = new List<String>();
        if(lstEventRelation!=null && !lstEventRelation.isEmpty()) {
            for(EventRelation evtRelation : lstEventRelation) {
                //if it is a user then it is internal
                String relationIdValue = String.valueOf(evtRelation.RelationId);
                if(relationIdValue.startsWith('005')) {
                    ihsMarkit.add(evtRelation.Relation.Name);
                }
                //if it is a lead then it is external
                if(relationIdValue.startsWith('00Q')) {
                    client.add(evtRelation.Relation.Name);
                }
                //if it is a contact then we have to check it's email
                if(relationIdValue.startsWith('003')) {
                    setContactsToQuery.add(evtRelation.RelationId);
                }
            }
        }
        if(setContactsToQuery!=null && !setContactsToQuery.isEmpty()) {
            Set<String> setDomainNames = new Set<String>(SendMeetingNotesController.lstAllowedContactDomains);
            //query contacts with email
            List<Contact> lstContact = [Select Id, Email,Name from Contact where Id IN:setContactsToQuery];
            if(lstContact!=null && !lstContact.isEmpty()) {
                for(Contact cnt : lstContact) {
                    if(cnt.Email!=null && setDomainNames.contains(cnt.Email.split('@',2)[1])) {
                        //it is internal contact
                        ihsMarkit.add(cnt.Name);
                    } else {
                        client.add(cnt.Name);
                    }
                }
            }
        }
        this.client = String.join(client,', ' );
        this.ihsMarkit = String.join(ihsMarkit,', ');
    }

}