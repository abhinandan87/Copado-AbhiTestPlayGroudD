//-----------------------------
// @author: Harshit Singhal
// @date: 18 May 2020
// @param: NA
// @description: Test Class for BatchCreateMeetingNoteForEvent class
// @return: NA
//----------------------------
@isTest
private class TestBatchCreateMeetingNoteForEvent {
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 21 May 2020
    // @description: SFDC-2733 Setup test data
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    static void createTestData() {        
        TestEventMethods.setupBasicData();        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 21 May 2020
    // @description: SFDC-2733 Main test method that runs the batch class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    static void testBatch() {
        //Query a contact for whoId
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        //Query an opp for whatId
        Opportunity testOpp = TestUtility.createOpportunity(extContact.AccountId, 'Test Oppy Event', true);
        
        //Sc1: Create events with who Id
        List<Event> evtWithWhoIdList = new List<Event>();        
        Integer countEvtWithWhoId = 150;
        for(Integer i=0;i<countEvtWithWhoId;i++) {
            String evtSubject = 'Test EventWhoId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,extContact.Id, false);
            evtWithWhoIdList.add(evtObj);
        }
        
        //Sc2: Create events with what Id
        List<Event> evtWithWhatIdList = new List<Event>();        
        Integer countEvtWithWhatId = 150;
        for(Integer i=0;i<countEvtWithWhatId;i++) {
            String evtSubject = 'Test EventWhatId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,null, false);            
            evtObj.WhatId = testOpp.Id;
            evtWithWhatIdList.add(evtObj);
        }
        
        //Sc3: Create events with WhoId and WhatId as null
        List<Event> evtWithNoWhoWhatIdList = new List<Event>();        
        Integer countEvtWithNoWhoWhatId = 150;
        for(Integer i=0;i<countEvtWithNoWhoWhatId;i++) {
            String evtSubject = 'Test EventNoWhoWhatId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,null, false);                        
            evtWithNoWhoWhatIdList.add(evtObj);
        }
        List<Event> insertAllEvents = new List<Event>();
        insertAllEvents.addAll(evtWithWhoIdList);
        insertAllEvents.addAll(evtWithWhatIdList);
        insertAllEvents.addAll(evtWithNoWhoWhatIdList);
        insert insertAllEvents;
        
        Set<Id> evtIdSet = new Set<Id>();
        for(Event evt:insertAllEvents) {
        	evtIdSet.add(evt.Id);    
        }        
        System.debug('18May evtIdSet size='+evtIdSet.size());
        System.debug('18May evtIdSet='+evtIdSet);
        
        //Manually delete all meeting notes created by trigger automatically
        List<MeetingNote__c> mtngnoteList = [SELECT Id FROM MeetingNote__c WHERE RelatedEventId__c=:evtIdSet];
        System.assertEquals(countEvtWithWhoId+countEvtWithWhatId,mtngnoteList.size(),'MeetingNotes not correctly created for all events');
        delete mtngnoteList;
        
        //Run batch
        Test.startTest();        
        Id batchJobId = Database.executeBatch(new BatchCreateMeetingNoteForEvent(null,null), countEvtWithWhoId+countEvtWithWhatId+countEvtWithNoWhoWhatId);
        System.debug('batchJobId='+batchJobId);        
        Test.stopTest();
        
        
        
        //Assert checks for all first two scenarios
        for(Event evtAssert: [SELECT Id,MeetingNote__c FROM Event WHERE Id IN :evtWithWhoIdList OR Id IN :evtWithWhatIdList]) {
            System.assertNotEquals(null, evtAssert.MeetingNote__c, 'Meeting Note not created for event with Contact in WhoId or Opp in WhatId');
        }
        //Assert checks for third scenario
        for(Event evtAssert: [SELECT Id,MeetingNote__c FROM Event WHERE Id IN :evtWithNoWhoWhatIdList]) {
            System.assertEquals(null, evtAssert.MeetingNote__c, 'Meeting Note was created for a wrong event with AccountId as null.');
        }
        
        //Schedule the batch
        String jobId = system.schedule('Test Schedule For BatchCreateMeetingNoteForEvent', '0 0 0 3 9 ? 2040' , new BatchCreateMeetingNoteForEventScheduler());
    }
}