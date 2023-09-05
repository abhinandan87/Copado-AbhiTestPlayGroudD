//-----------------------------
// @author: Jagadesh Kumar
// @date: 06 June 2018
// @param: NA
// @description: Test class for Internal Approval trigger methods 
// @return: NA
//-----------------------------
@isTest
public class TestInternalApprovalMethods {
	//-----------------------------
    // @author: Jagadesh Kumar
    // @date: 06 June 2018
    // @param: NA
    // @description: Test method for Internal Approval trigger methods populateContractOwner on insert
    // @return: NA
    //-----------------------------
    @isTest
    private static void testpopulateContractOwner() {
        Test.startTest();
        Account a = TestUtility.createTestAccount('Internal Approval Account', true);
        Contact c1 = new Contact();
        c1.firstname = 'Internal1';
        c1.lastname = 'Approval1';
        c1.Email = 'Internal.Approval@ihsmarkit.com';
        c1.AccountId = a.Id;
        insert c1;
        
        User testCustomerCareUser = TestUtility.createTestUser('IHSMarkit Customer Care', 'testsfdc1652@username.com',true);
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.OwnerId = testCustomerCareUser.Id;
        insert contract1;
        
        InternalApproval__c inApproval = new InternalApproval__c();
        inApproval.Contact__c = c1.Id;
        inApproval.Contract__c = contract1.Id;
        inApproval.ApprovalType__c = 'Business Line Leader';
        insert inApproval;
        InternalApproval__c ia = [SELECT Id,ContractOwner__c FROM InternalApproval__c WHERE ID =: inApproval.Id];
        System.assertEquals(ia.ContractOwner__c,contract1.OwnerId,'Owner is missing');
        Test.stopTest();
    }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 07 July 2021
    // @param: NA
    // @description: Test method for Internal Approval trigger methods notifyContractOwner on Update
    // @return: NA
    //-----------------------------
    @isTest
    private static void testnotifyContractOwner() {
        //cannot assert feedItems as it requires seeAlldata = true and we cannot create mock feedItems for it
        //create test data
        Test.startTest();
        Account a = TestUtility.createTestAccount('Internal Approval Account', true);
        Contact c1 = new Contact();
        c1.firstname = 'Internal1';
        c1.lastname = 'Approval1';
        c1.Email = 'Internal.Approval@ihsmarkit.com';
        c1.AccountId = a.Id;
        insert c1;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,TRUE);
        
        InternalApproval__c inApproval = new InternalApproval__c();
        inApproval.Contact__c = c1.Id;
        inApproval.Contract__c = contract1.Id;
        inApproval.ApprovalType__c = 'Business Line Leader';
        insert inApproval;
        
        inApproval.ApprovalType__c = 'Approved';
        try {
            Update inApproval;
        }
        catch(exception e) {
            System.assertEquals(e.getMessage(),'Internal Approval has been provided by user', 'No chatter post');
                }
        Test.stopTest();
    }
}