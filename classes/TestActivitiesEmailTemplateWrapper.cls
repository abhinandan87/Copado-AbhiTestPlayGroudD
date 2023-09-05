@isTest
public class TestActivitiesEmailTemplateWrapper {
	
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 14th March 2022
    // @description: Org Assessment 2022 Test class coverage
    // @param: None
    // @return: None
    //-----------------------------
    private static testMethod void ActivitiesEmailTemplateWrapper() {
        // create Account
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        // create contact
        Contact testContact = TestUtility.createContact(testAccount.id,'test@test.com', true, 'Test','Contact');
        // create an event record
        Event testEvent = TestUtility.createEventWithWhoId('Test Event meetingNote',testContact.id,true);
        test.startTest();
        List<MeetingNote__c> mtngNote = [SELECT Id, MeetingOutCome__c, Subject__c
                                         FROM MeetingNote__c WHERE RelatedEventId__c= 'testEvent.Id' LIMIT 1];
        for(MeetingNote__c mn: mtngNote) {
            System.assertEquals('testEvent.Subject', 'mtngNote.Subject__c' , 'event subject matches the meeting note subject');
        }
        
        test.stopTest();
        
        ActivitiesEmailTemplateWrapper templatewrapper = new ActivitiesEmailTemplateWrapper(testEvent.Id);
    }
}