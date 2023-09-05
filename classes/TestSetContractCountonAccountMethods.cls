/**
    * @author Digvijay Singh
    * @date 11 June 2021
    * @description SFDC-4166 Test Class for SetContractCountonAccountMethods.calculateContractCountOnAccount
    * @companyname IHS Markit
    */
@isTest    
public class TestSetContractCountonAccountMethods {
       //-----------------------------
      //@author : Digvijay
      //@date : 11 June 2021
      //@description : SFDC1-3473 Test class for ContractMethods.updateAccountContractsCount
      //@param : TriggerParameters
      //@return : void
      //@companyname : IHS Markit
      private static testMethod Void testUpdateAccountContractsCount() {

        Account opptyacc = TestUtility.createTestAccount('Account testImplCaseFromOrderFormContract', false);
        opptyacc.DataGovernanceStatus__c = 'Approved';
        insert opptyacc;
        Opportunity testOpportunity = TestUtility.createOpportunity(opptyacc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;
          
        Opportunity assertOpportunity = [Select Id, AccountId, ProfitCenter__c, ProductFamily__c,FormerIP__c,(Select id from OpportunityLineItems) from Opportunity where name='test Opppy' ];
        Account acc = TestUtility.createTestAccount('Account testUpdateAccountContractsCount', false);
        insert acc;
        Opportunity testOpportunity1 = TestUtility.createOpportunity(acc.Id, 'test Oppty', true);
          
        Product2 testProd1 = TestUtility.createProduct('Test Product1', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd1.Id, true);
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract1 = TestUtility.createContractWithInsertOptional(assertOpportunity.AccountId, legalEntity.Id, country.Id, standardId,false);
        contract1.ContractApproved__c = true;
        contract1.Opportunity__c = assertOpportunity.Id;
        Test.StartTest();
        insert contract1;
        Test.StopTest();
        Contract contractRec =[Select Id, Account.AccountContractsCount__c FROM Contract Where Id=:contract1.Id];
        System.assertEquals(1, contractRec.Account.AccountContractsCount__c);
    } 
}