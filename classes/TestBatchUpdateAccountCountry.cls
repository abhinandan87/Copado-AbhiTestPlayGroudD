/**
* @author Tran-Vu Tran
* @date 22nd April 2019
* @description SFDC-1381 test class for BatchUpdateAccountCountry
* @return void
* @companyname IHS Markit
*/
@isTest
private class TestBatchUpdateAccountCountry {
    
    private static testMethod void testBatchUpdateAccountCountryClass() {
        
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);

        Account testAccount = TestUtility.createTestAccountWithAddress('Test Account', '1234 Testing Street', 'Test City', '', country.CountryCode__c, true);

        Test.startTest();
        
        Account assertAccount = [Select Id, AccountCountry__c from Account where Id =: testAccount.Id];
        System.assertNotEquals(null, assertAccount.AccountCountry__c,
                               'Verifying AccountCountry__c lookup value is populated by trigger');
        
        testAccount.AccountCountry__c = null; // set AccountCountry__c = null to simulate when trigger is turned off
        update testAccount;
       
        BatchUpdateAccountCountry batchJob = new BatchUpdateAccountCountry();
        Id batchId = Database.executeBatch(batchJob, 1);
        
        Test.stopTest();
        
        assertAccount = [Select Id, AccountCountry__c from Account where Id =: testAccount.Id];
        System.assertNotEquals(null, assertAccount.AccountCountry__c,
                               'Verifying AccountCountry__c lookup value is populated by BatchUpdateAccountCountry batch job');
    }

}