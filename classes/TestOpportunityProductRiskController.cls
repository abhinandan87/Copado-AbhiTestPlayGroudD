//-----------------------------
// @author: Sharique Iqbal
// @date: 13th March 2021
// @param: NA
// @description: Test class for OpportunityProductRiskController class
//------------------- 
@isTest
private class TestOpportunityProductRiskController {

    @testSetup static void setup() {
        //adding more atttributes to product
        ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='UP - Energy', Active__c=true, ProfitCenterCode__c='187');
        insert testProfitCenter;
        Family__c testProdFam = new Family__c(Name='ETC-C&A',Status__c ='Active');
        insert testProdFam;
        
        ProductGroup__c pg = TestUtility.createProductGroup('MRO',false,false);//SFDC1-5228 JK- New
        //create test data
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.FormerIpOwner__c = 'IHS Markit Global Inc.';
        testProd.Family__c = testProdFam.Id;
        testProd.ProfitCenters__c = testProfitCenter.Id;
        testProd.ProductGroup__c = pg.Id;//SFDC1-5228 JK- New
        insert testProd;
        
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Integer nextFY = currentFY+1;
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;

        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);
        testOpportunity.ContractStartDate__c =   date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        insert testOpportunity;
         
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        testOLI.Status__c = 'Existing';
        testOLI.IsProductatRisk__c = 'Yes';
        testOLI.RiskStatus__c = 'Open - Pending Resolution';
        testOLI.AnnualizedUnitPrice__c = 1200;
        testOLI.AnnualizedDiscountAmount__c = 10 ;
        testOLI.Quantity = 1;
        
        update testOLI;
    }
        
    private static testMethod void testGetRiskProductName () {
        Test.startTest();
        String riskyProductNames = '';
        Opportunity oppy = [Select Id from Opportunity where name='test Opppy'];
        riskyProductNames = OpportunityProductRiskController.getRiskProductName (oppy.id);
        System.debug('@@@@riskyProductNames-'+riskyProductNames);
        System.assert(riskyProductNames != '','No Product at Risk');
        Test.stopTest();  
    }
}