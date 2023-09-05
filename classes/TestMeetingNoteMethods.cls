//-----------------------------
// @author: Harshit Singhal
// @date: 30 Mar 2020
// @param: NA
// @description: Test class for Meeting Note trigger methods 
// @return: NA
//-----------------------------
@isTest
public class TestMeetingNoteMethods {
    @testSetup 
    static void createTestData() {        
        TestEventMethods.setupBasicData();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @param: NA
    // @description: Test method for MeetingNote trigger method meetingNoteValidations.
    // @return: NA
    //-----------------------------
    private static testMethod void testMeetingNoteValidations() {
        //Query Sales User
        User testSalesUser = [SELECT Id,Name,Profile.Name FROM User WHERE Username='salesrepActivityManagement@testuser.com' LIMIT 1];
        
        //Query external contact
        Contact extContact = [SELECT Id,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        System.runAs(testSalesUser) {            
            //Sc1: Create a new event with custom meeting note populated
            Event evt = TestUtility.createEventWithWhoId('EventInsert',extContact.Id, true);
            MeetingNote__c mnObj = [SELECT Id,Name FROM MeetingNote__c WHERE RelatedEventId__c=:evt.Id LIMIT 1];
            mnObj.Name = 'Cannot Update Name Manually';
            try {
                update mnObj;                
            }
            catch(Exception ex) {
                String errorMessage = ex.getMessage();                
                //System.debug('Insert errorMessage='+errorMessage);
                System.assert(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION, Meeting Name cannot be modified.'),'Trigger validation to stop non Admin users to update Meeting Note manually is failing.');
            }
        }        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @param: NA
    // @description: Test method for MeetingNote trigger method createDefaultRelatedOpportunity.
    // @return: NA
    //-----------------------------
    private static testMethod void testCreateDefaultRelatedOpportunity() {
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create opp
        Opportunity testOpp1 = TestUtility.createOpportunity(extContact.AccountId, 'Test Opp1', false);
        Opportunity testOpp2 = TestUtility.createOpportunity(extContact.AccountId, 'Test Opp2', false);
        List<Opportunity> oppList = new List<Opportunity> {testOpp1, testOpp2};
        insert oppList;
            
        //Create event
        Event testEvtWithoutOpp = TestUtility.createEventWithWhoId('Test Event Without Opp',extContact.Id, false);
        Event testEvtWithOpp = TestUtility.createEventWithWhoId('Test Event With Opp',null, false);
        testEvtWithOpp.WhatId = testOpp1.Id;
        List<Event> insEvtList = new List<Event> {testEvtWithoutOpp, testEvtWithOpp};
        insert insEvtList;
        Set<Id> idSet = new Set<Id> {testEvtWithoutOpp.Id, testEvtWithOpp.Id};
            
        //Query Related Opportunities for both events
        for(RelatedOpportunity__c rlObj:[SELECT Id,MeetingNote__r.RelatedEventId__c FROM RelatedOpportunity__c WHERE MeetingNote__r.RelatedEventId__c IN :idSet]) {
            System.assertNotEquals(testEvtWithoutOpp.Id, rlObj.MeetingNote__r.RelatedEventId__c, 'Related Opportunity should not be created for this event with WhatId as blank.');
            System.assertEquals(testEvtWithOpp.Id, rlObj.MeetingNote__r.RelatedEventId__c, 'Related Opportunity should be created for event with WhatId as an opportunity.');
        }
               
        testEvtWithOpp.WhatId = testOpp2.Id;
        update testEvtWithOpp;
        
        //Query Related Opportunities for testEvtWithOpp Event
        System.assertEquals(1,[SELECT Id,MeetingNote__r.RelatedEventId__c FROM RelatedOpportunity__c WHERE MeetingNote__r.RelatedEventId__c=:testEvtWithOpp.Id AND Opportunity__c=:testOpp2.Id].size(), 'Related Opportunity record not created when Event.WhatId is updated to another opportunity.');
                
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @param: NA
    // @description: Test method for MeetingNote trigger method populateMeetingNoteOnRelatedEvent.
    // @return: NA
    //-----------------------------
    private static testMethod void testPopulateMeetingNoteOnRelatedEvent() {
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create event
        Event testEvt = TestUtility.createEventWithWhoId('Test Event',extContact.Id, false);
        insert testEvt;
        
        //Query Event
        Event queryEvt = [SELECT Id,NotesCompleted__c,MeetingNote__c,MeetingNote__r.RelatedEventId__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertNotEquals(null, queryEvt.MeetingNote__c, 'Meeting note not created automatically on event.');
        System.assertEquals(queryEvt.Id, queryEvt.MeetingNote__r.RelatedEventId__c, 'RelatedEventId__c should be populated on a Meeting Note related to an event.');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Mar 2020
    // @param: NA
    // @description: Test method for MeetingNote trigger method markNotesCompleted on insert and update
    // @return: NA
    //-----------------------------
    private static testMethod void testMarkNotesCompleted() {       
        
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create event
        Event testEvt = TestUtility.createEventWithWhoId('Test Event',extContact.Id, false);
        insert testEvt;
        
        //Query Event
        Event queryEvt = [SELECT Id,NotesCompleted__c,MeetingNote__c,MeetingNote__r.NotesCompleted__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertNotEquals(null, queryEvt.MeetingNote__c, 'Meeting note not created automatically on event.');
        System.assertEquals(false, queryEvt.MeetingNote__r.NotesCompleted__c, 'NotesCompleted__c should be false on a new Meeting Note.');
        
        //Fill meeting outcome on meetingnote
        MeetingNote__c mnObj = new MeetingNote__c(Id=queryEvt.MeetingNote__c, MeetingOutcome__c = 'test outcome of meeting');
        update mnObj;
        
        queryEvt = [SELECT Id,NotesCompleted__c,MeetingNote__c,MeetingNote__r.NotesCompleted__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertEquals(true, queryEvt.MeetingNote__r.NotesCompleted__c, 'NotesCompleted__c should be true on Meeting Note with a meeting outcome.');
        System.assertEquals(true, queryEvt.NotesCompleted__c, 'NotesCompleted__c should be true on Event with a meeting outcome.');
        
        mnObj.MeetingOutcome__c = '';
        update mnObj;
        
        queryEvt = [SELECT Id,NotesCompleted__c,MeetingNote__c,MeetingNote__r.NotesCompleted__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertEquals(false, queryEvt.MeetingNote__r.NotesCompleted__c, 'NotesCompleted__c should be false on Meeting Note without a meeting outcome.');
        System.assertEquals(false, queryEvt.NotesCompleted__c, 'NotesCompleted__c should be false on Event without a meeting outcome.');
    }
}