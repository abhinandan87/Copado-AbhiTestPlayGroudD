//-----------------------------
//@Author : Manish Kumar
//@Date : 2nd Dec 2021
//@Description : Test class for CreateQuoteController
//@Company : IHS Markit
//-----------------------------
@isTest
public class TestCreateQuoteController {
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 2nd Dec 2021
    // @param: String
    // @description: Test method for CreateQuoteController.getOptyAndSessionId
    // @return: Wrapper Class
    //-----------------------------
    @isTest private static void testGetOptyAndSessionId() {
        //create test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD');
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',false);
        testOppy.LegalEntity__c = testLegalEntity.Id;
        insert testOppy;
        CreateQuoteController.wrapperClass wrpCon = CreateQuoteController.getOptyAndSessionId(testOppy.Id);
        system.assertEquals(wrpCon.oppy.Id, testOppy.Id, 'opty Id is not matching with wrapper class opty Id');
    }
}