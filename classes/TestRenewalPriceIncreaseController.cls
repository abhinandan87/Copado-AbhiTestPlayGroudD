/**
 * @Author: Paras Dhingra
 * @Date: 19th Aug 2020
 * @Description: SFDC-3187 test class controller for lightning component RenewalPriceIncrease
 */
@isTest
public with sharing class TestRenewalPriceIncreaseController {
    @isTest
    public static void testUpdateOppy() {
        Account testAccount = TestUtility.createTestAccount('Test Account',true);
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id,'first test Oppy', true);
        Test.startTest();

        //test negative test case
        String message = RenewalPriceIncreaseController.updateOppy(null);
        System.assertEquals('Opportunity not found', message,'Error message not generated');

        //test positive test case
        testOpportunity.CloseDate = testOpportunity.CloseDate + 30;
        message = RenewalPriceIncreaseController.updateOppy(testOpportunity);
        System.assertEquals('success', message,'Success message not generated');
        
        //test negative test case
        testOpportunity.AccountId = null;
        message = RenewalPriceIncreaseController.updateOppy(testOpportunity);
        System.assertNotEquals('success', message,'Success message generated');
        Test.stopTest();
    }
}