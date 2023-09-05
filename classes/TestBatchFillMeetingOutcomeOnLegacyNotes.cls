//-----------------------------
// @author: Harshit Singhal
// @date: 20 May 2020
// @param: NA
// @description: Test Class for BatchFillMeetingOutcomeOnLegacyNotes class
// @return: NA
//----------------------------
@isTest
private class TestBatchFillMeetingOutcomeOnLegacyNotes {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 21 May 2020
    // @description: SFDC-2733 Setup test data
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    static void createTestData() {        
        //Create Acc
        Account testAcc = TestUtility.createTestAccount('Test Account1',true);
        //Create Opp
        Opportunity testOpp = TestUtility.createOpportunity(testAcc.Id, 'Test Oppy', true);
        //Create Meeting Notes
        List<MeetingNote__c> testMeetingNoteList = new List<MeetingNote__c>();
        Integer count=100;
        for(Integer i=0; i<100; i++) {
            MeetingNote__c mnObj = new MeetingNote__c(Account__c=testAcc.Id,Opportunity__c=testOpp.Id);
            mnObj.Name = 'TestMeetingNote'+String.valueOf(i);
            mnObj.Achieved__c = 'This was achieved in TestMeetingNote '+String.valueOf(i);
            mnObj.Info__c = 'This is info of TestMeetingNote '+String.valueOf(i);
            mnObj.NextSteps__c = 'This is next step of TestMeetingNote '+String.valueOf(i);
            testMeetingNoteList.add(mnObj);            
        }
        insert testMeetingNoteList;
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
        //Check meeting notes before batch
        for(MeetingNote__c mnObj:[SELECT Id,MeetingOutcome__c FROM MeetingNote__c Where Name Like 'TestMeetingNote%']) {
            System.assertEquals(null, mnObj.MeetingOutcome__c, 'Meeting outcome should be null.');
        }
        //Run batch
        Test.startTest();
		Id batchJobId = Database.executeBatch(new BatchFillMeetingOutcomeOnLegacyNotes(null,null));
        System.debug('batchJobId='+batchJobId);        
        Test.stopTest();
        
        //Check meeting outcome after batch has run
        for(MeetingNote__c mnObj:[SELECT Id,MeetingOutcome__c FROM MeetingNote__c Where Name Like 'TestMeetingNote%']) {
            System.assertNotEquals(null, mnObj.MeetingOutcome__c, 'Meeting outcome should be null.');
            System.assert(mnObj.MeetingOutcome__c.contains('This was achieved in TestMeetingNote'), 'Achieved__c was not merged in MeetingOutcome__c.');
            System.assert(mnObj.MeetingOutcome__c.contains('This is info of TestMeetingNote'), 'Info__c was not merged in MeetingOutcome__c.');
            System.assert(mnObj.MeetingOutcome__c.contains('This is next step of TestMeetingNote'), 'NextSteps__c was not merged in MeetingOutcome__c.');
        }
    }

}