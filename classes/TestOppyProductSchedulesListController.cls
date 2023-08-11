@isTest
public class TestOppyProductSchedulesListController {
    
    @isTest
        public static void testMethod1(){
            test.startTest();
            TestBatchUpdateRollUpFieldOnParent.createTestCustomRollUpCustomSettings();
            ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='UP - Energy', Active__c=true, ProfitCenterCode__c='187');
            insert testProfitCenter;
            Family__c testProdFam = new Family__c(Name='ETC-C&A',Status__c ='Active');
            insert testProdFam;
            ProductGroup__c pg = TestUtility.createProductGroup('MRO',false,false);            
            Product2 testProd = TestUtility.createProduct('Test Product', false);
            testProd.FormerIpOwner__c = 'IHS Markit Global Inc.';
            testProd.Family__c = testProdFam.Id;
            testProd.ProfitCenters__c = testProfitCenter.Id;
            testProd.ProductGroup__c = pg.Id;
            insert testProd;
            Id standardId = Test.getStandardPricebookId();
            PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
            Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
            Integer nextFY = currentFY+1;
            Account testAccount = TestUtility.createTestAccount('testAccount', false);
            testAccount.DataGovernanceStatus__c = 'Approved';
            insert testAccount;
            
            Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);
            testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
            testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
            insert testOpportunity;
            
            OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, false);
            testOLI.IsProductatRisk__c = 'No';
            testOLI.RiskStatus__c = 'Closed - Downgraded';
            insert testOLI;
            ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY), testProd.Id, false);
            ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+1), testProd.Id, false);
            ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+2), testProd.Id, false);
            
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
                test.stopTest();
            List<OpportunityLineItemSchedule__c> olisList= OppyProductSchedulesListController.getOppyProdSchedules(testOLI.Id);
            system.assert(olisList.size()>0);
        }
}