//-----------------------------
// @author: Sathish Edla
// @date: 30 Mar 2022
// @description: SFDC-5375 Extend the trigger framework to handle platform events.
//-----------------------------
@isTest
private class TestSetApexLoggerEventMethods {
    @isTest static void SetApexLoggerEventMethods() {
        // Create a test event instance
        SetApexLoggerEvent__e objPlatformEvent = new SetApexLoggerEvent__e(ClassName__c = 'TestClass',
                                                                           ErrorMessage__c = 'Test Error', 
                                                                           ExceptionType__c = 'Apex', 
                                                                           MethodName__c = 'Test Method', 
                                                                           UserId__c = system.UserInfo.getUserId());
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(objPlatformEvent);
        Test.stopTest();
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
}