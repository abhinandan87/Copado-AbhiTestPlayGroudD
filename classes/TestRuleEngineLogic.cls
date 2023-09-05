//-----------------------------
// @author: Digvijay Singh
// @date: 25 Jan 2022
// @param: NA
// @description: Test class for RuleEngineLogic methods 
// @return: NA 
//                                      T
//-----------------------------

@isTest
private class TestRuleEngineLogic  {

    //-----------------------------
    // @author: Digvijay Singh
    // @date: 25 Jan 2022
    // @description: Test Setup
    // @return: NA 
    //                                      
    //-----------------------------
     @testSetup static void setup() {
         
        RuleDefinition__c robj=new RuleDefinition__c();
        robj.BusinessFunctionality__c='OpportunityLineItemSynergyRules';
        robj.RuleObject__c='OpportunityLineItem';
        robj.Name='OpportunityLineItemSynergyRules';
        insert robj;
        
        List<RuleEntry__c> listruleEntry=new List<RuleEntry__c >();
        RuleEntry__c rentryObj1= new RuleEntry__c(RuleDefinition__c=robj.Id,CriteriaCondition__c='Product2.Division__c=Resources|Product2.MaterialCode__c = 2000028208',
        OutputColumns__c='SynergyType__c=P/R ET Mobility & energy futures - Cross Sell #45| SynergyTheme__c=Energy Transition');
        listruleEntry.add(rentryObj1);
        RuleEntry__c rentryObj2= new RuleEntry__c(RuleDefinition__c=robj.Id,CriteriaCondition__c='Product2.Division__c=Resources|ProductGroup__c.Name IN: Agri Consulting, Agri Multi-Client Studies,Coal Consulting, Crop Forecasting Consulting,EWP Consulting, Expert Connect-UPS',
        OutputColumns__c='SynergyType__c=P/R Cons Financials - Cross Sell #80| SynergyTheme__c=Consulting');
        RuleEntry__c rentryObj3= new RuleEntry__c(RuleDefinition__c=robj.Id,CriteriaCondition__c='Product2.Division__c=Resources|ProductGroup__c.Name = Commodities & Food |Product2.Name Contains: Sugar',
        OutputColumns__c='SynergyType__c=P/R NEC Sugar Economics / Analytics - Cross Sell #4| SynergyTheme__c=Non-Energy Commodities Penetration');
        listruleEntry.add(rentryObj2);
        listruleEntry.add(rentryObj3);
        
        insert listruleEntry;
        //adding more atttributes to product
        ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='UP - Energy', Active__c=true, ProfitCenterCode__c='187');
        insert testProfitCenter;
        Family__c testProdFam = new Family__c(Name='ETC-C&A',Status__c ='Active');
        insert testProdFam;
        ProductGroup__c pg = TestUtility.createProductGroup('Agri Consulting',false,false);//SFDC1-5228 JK- New
        //create test data
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.FormerIpOwner__c = 'IHS Markit Global Inc.';
        testProd.Division__c='Resources';
        testProd.MaterialCode__c = '2000028208';
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
        testOpportunity.ContractStartDate__c =  date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        testOpportunity.Synergy1__c='Yes';
        insert testOpportunity;
         
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, false);
        testOLI.IsProductatRisk__c = 'No';
        testOLI.RiskStatus__c = 'Closed - Downgraded';
        insert testOLI;
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY), testProd.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+1), testProd.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+2), testProd.Id, false);
        //insert product schedule for 2018 financial year
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2223.23, String.valueof(nextFY), '3 Years', String.valueof(nextFY), testProd.Id, false);
        ProductSchedule__c ps5 = TestUtility.createProductSchedule(2223.23, String.valueof(nextFY), '3 Years', String.valueof(nextFY+1), testProd.Id, false);
        ProductSchedule__c ps6 = TestUtility.createProductSchedule(2223.23, String.valueof(nextFY), '3 Years', String.valueof(nextFY+2), testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4,ps5,ps6};
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps1.Id,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, testProd.Id, '2017', 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps2.Id,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, testProd.Id, '2018', 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps3.Id,2323.23,2000,
                                                                                            'Amount', 423.23, 0.0, testProd.Id, '2019', 1, 
                                                                                            testOLI.Id,false);
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3};
        
    }

    //-----------------------------
    // @author: Digvijay Singh
    // @date: 25 Jan 2022
    // @description: Test method for runtheBusinessLogic
    // @return: NA 
    //                                      
    //-----------------------------
     private static testMethod void testruntheBusinessLogic() {
     
        OpportunityLineItem testOLI = [Select Id,Product2Id, OpportunityId from OpportunityLineItem limit 1];
        Product2 testProd=new Product2(Id=testOLI.Product2Id );
        testOLI.Description= 'Test';
        
        Test.startTest();
        update testOLI;
        testOLI = [Select Id,SynergyTheme__c,SynergyType__c,Product2Id, OpportunityId from OpportunityLineItem limit 1];
        System.assertEquals(testOLI.SynergyTheme__c, 'Energy Transition');
        System.assertEquals(testOLI.SynergyType__c, 'P/R ET Mobility & energy futures - Cross Sell #45');
        testProd.MaterialCode__c ='87676';
        update testProd;
        testOLI.Description= 'Test2';
        update testOLI;
        Opportunity testoppy=[Select Id,Synergy1__c,SynergyTheme__c,SynergyType__c from Opportunity Limit 1];
        testoppy.Synergy1__c='No';
        update testoppy;
        testoppy.Synergy1__c='Yes';
        update testoppy;
        testOLI = [Select Id,SynergyTheme__c,SynergyType__c,Product2Id, OpportunityId from OpportunityLineItem limit 1];
        System.assertEquals(testOLI.SynergyTheme__c, 'Consulting');
        System.assertEquals(testOLI.SynergyType__c, 'P/R Cons Financials - Cross Sell #80');
        Test.stopTest();       
     }
     
}