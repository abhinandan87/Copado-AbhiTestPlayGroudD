//-----------------------------
// @author: Harshit Singhal
// @date: 20 May 2020
// @param: NA
// @description: Test Class for BatchFillEventPrivacyLevel class
// @return: NA
//----------------------------
@isTest
private class TestBatchFillEventPrivacyLevel {
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
        //Query an external account
        Account extAcc = [SELECT Id FROM Account WHERE Name='External Account1' LIMIT 1];
        //Query a contact for whoId
        Contact intContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email='con1intacc1@ihsmarkit.com' LIMIT 1];
        //Query an opp for whatId
        Opportunity testOpp = TestUtility.createOpportunity(extAcc.Id, 'Test Oppy Event', true);
        
        //Sc1: Create events with internal contact as who Id. Thus, Privacy Level = Internal Meeting
        List<Event> evtWithInternalWhoIdList = new List<Event>();        
        Integer countEvtWithIntWhoId = 50;
        for(Integer i=0;i<countEvtWithIntWhoId;i++) {
            String evtSubject = 'Test EventIntrnalWhoId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,intContact.Id, false);
            evtWithInternalWhoIdList.add(evtObj);
        }
        
        //Sc2: Create events with opportunity as what Id. Thus, Privacy Level = Customer-facing meeting
        List<Event> evtWithWhatIdList = new List<Event>();        
        Integer countEvtWithWhatId = 50;
        for(Integer i=0;i<countEvtWithWhatId;i++) {
            String evtSubject = 'Test EventWhatId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,null, false);            
            evtObj.WhatId = testOpp.Id;
            evtWithWhatIdList.add(evtObj);
        }
        
        //Sc3: Create events with WhoId and WhatId as null. Thus, Privacy Level = Personal appointment
        List<Event> evtWithNoWhoWhatIdList = new List<Event>();        
        Integer countEvtWithNoWhoWhatId = 50;
        for(Integer i=0;i<countEvtWithNoWhoWhatId;i++) {
            String evtSubject = 'Test EventNoWhoWhatId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,null, false);                        
            evtWithNoWhoWhatIdList.add(evtObj);
        }
        
        List<Event> insertAllEvents = new List<Event>();
        insertAllEvents.addAll(evtWithInternalWhoIdList);
        insertAllEvents.addAll(evtWithWhatIdList);
        insertAllEvents.addAll(evtWithNoWhoWhatIdList);
        insert insertAllEvents;
        
        //Assert - To see if Privacy Level is null before batch is run
        for(Event evtAssert: [SELECT Id,PrivacyLevel__c FROM Event WHERE Id IN :insertAllEvents]) {
            System.assertEquals(null, evtAssert.PrivacyLevel__c, 'Privacy Level should be null before batch is run.');
        }
        
        //Set one of the global variable to true, so that platform events are not published to populate PrivacyLevel__c on event
        BatchCreateMeetingNoteForEvent.isExecutingBatchCreateMeetingNoteForEvent = true;
        
        //Run batch
        Test.startTest();
        Id batchJobId = Database.executeBatch(new BatchFillEventPrivacyLevel(null,null));
        System.debug('batchJobId='+batchJobId);
        Test.stopTest();
        
        //Assert - To see if Privacy Level is populated after batch is run
        for(Event evtAssert: [SELECT Id,PrivacyLevel__c,AccountId FROM Event WHERE Id IN :insertAllEvents]) {
            System.assertNotEquals(null, evtAssert.PrivacyLevel__c, 'Privacy Level should not be null after batch is run.');
            if(evtAssert.AccountId==null) {
                System.assertEquals('Personal appointment', evtAssert.PrivacyLevel__c, 'Privacy level not set to Personal appointment.');                
            }
            if(evtAssert.AccountId==intContact.AccountId) {
                System.assertEquals('Internal meeting', evtAssert.PrivacyLevel__c, 'Privacy level not set to Internal meeting.');                
            }
            if(evtAssert.AccountId==extAcc.Id) {
                System.assertEquals('Customer-facing meeting', evtAssert.PrivacyLevel__c, 'Privacy level not set to Customer-facing meeting.');                
            }
        }
        
        //Schedule the batch
        String jobId = system.schedule('Test Schedule For BatchFillEventPrivacyLevel', '0 0 0 3 9 ? 2040' , new BatchFillEventPrivacyLevelScheduler());
    }

}