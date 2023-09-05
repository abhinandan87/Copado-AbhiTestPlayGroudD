@isTest
public class TestActivitiesEmailTemplateController {
    
    @istest 
    public static void testMethod1(){
        // create Account
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        // create contact
        Contact testContact = TestUtility.createContact(testAccount.id,'test@test.com', true, 'Test','Contact');
        // create an event record
        Event testEvent = TestUtility.createEventWithWhoId('Test Event meetingNote',testContact.id,true);
        test.startTest();
        List<MeetingNote__c> mtngNote = [SELECT Id, MeetingOutCome__c, Subject__c
                                         FROM MeetingNote__c WHERE RelatedEventId__c= 'testEvent.Id' LIMIT 1];
        test.stopTest();
        
        ActivitiesEmailTemplateWrapper templatewrapper = new ActivitiesEmailTemplateWrapper(testEvent.Id);
        ActivitiesEmailTemplateController objAETC = new ActivitiesEmailTemplateController();
        objAETC.eventId = testEvent.Id ;
        objAETC.wrapperObj = null;
        ActivitiesEmailTemplateWrapper obj =  objAETC.wrapperObj;
        objAETC.wrapperObj = obj;
        System.assertEquals(objAETC.eventId,testEvent.Id );
    }
}