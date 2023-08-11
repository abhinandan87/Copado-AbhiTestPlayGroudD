//-----------------------------
// @author: Sathish Edla
// @date: 30 Mar 2022
// @description: SFDC-5375 Extend the trigger framework to handle platform events.
//-----------------------------
@isTest
private class TestSetComplianceExceptionMethods {
    @isTest static void SetComplianceExceptionMethods() {
        Account parentAccount = TestUtility.createTestAccount('Test Account', true);
        Account childAccount = TestUtility.createTestAccount('Child Test Account', false);
        childAccount.ParentId = parentAccount.Id;
        insert childAccount;
        // Create a test event instance
        SetComplianceException__e objPlatformEvent = new SetComplianceException__e(AccountId__c = parentAccount.Id,
                                                                                   ComplianceRestriction__c = 'Test');
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(objPlatformEvent);
        Test.stopTest();
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
    @isTest static void SetComplianceExceptionDispatcher() {
        Account parentAccount = TestUtility.createTestAccount('Test Account', true);
        // Create a test event instance
        SetComplianceException__e objPlatformEvent = new SetComplianceException__e(AccountId__c = parentAccount.Id,
                                                                                   ComplianceRestriction__c = 'Test');
        Test.startTest();
        SetComplianceExceptionDispatcher.isAfterInsertProcessing = TRUE;
        // Publish test event
        Database.SaveResult sr = EventBus.publish(objPlatformEvent);
        Test.stopTest();
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
}