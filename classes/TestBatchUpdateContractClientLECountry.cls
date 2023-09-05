/**
* @author Tran-Vu Tran
* @date 22nd April 2019
* @description SFDC-1381 test class for BatchUpdateAccountCountry
* @return void
* @companyname IHS Markit
*/
@isTest
private class TestBatchUpdateContractClientLECountry {
    @isTest
    private static void TestBatchUpdateContractClientLECountryClass() {
        
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);

        // creating test account
        Account testAccount = TestUtility.createTestAccountWithAddress('Test Account', '1234 Testing Street', 'Test City', '', country.CountryCode__c, true);

        Test.startTest();
        
        Account assertAccount = [Select Id, AccountCountry__c from Account where Id =: testAccount.Id];
        System.assertNotEquals(null, assertAccount.AccountCountry__c, 'Verifying AccountCountry__c lookup value is populated by trigger');
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        Contact testContact = TestUtility.createContact(testAccount.Id, 'test@ihsmarkit.com', true, 'Test', 'Contact');
                                                                                     
        // creating test opportunity                                                                                     
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', true);
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = testContact.Id;
        ocr.OpportunityId = testOpportunity.Id;
        ocr.IsPrimary = true;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity', 'USD', true, 
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        // creating test opportunity
        Contract testContract = TestUtility.createContract(testAccount.Id, legalEntity.Id, country.Id, standardId);
        
        testContract.ClientLegalEntityLookUp__c = testAccount.Id;
        update testContract;
        
        Contract assertContract = [Select Id, ClientLegalEntityCountryLookup__c from Contract where Id =: testContract.Id];
        System.assertNotEquals(null, assertContract.ClientLegalEntityCountryLookup__c, 'Verifying ClientLegalEntityCountry__c lookup value is populated by trigger');
        
        testContract.ClientLegalEntityCountryLookup__c = null;  // set ClientLegalEntityCountryLookup__c = null to simulate when trigger is turned off
        update testContract;
            
        BatchUpdateContractClientLECountry batchJob = new BatchUpdateContractClientLECountry();
        Id batchId = Database.executeBatch(batchJob, 1);
        
        Test.stopTest();
        
        assertContract = [Select Id, ClientLegalEntityCountryLookup__c from Contract where Id =: testContract.Id];
        System.assertNotEquals(null, assertContract.ClientLegalEntityCountryLookup__c,
                               'Verifying ClientLegalEntityCountry__c lookup value is populated by BatchUpdateContractClientLECountry');
    }

}