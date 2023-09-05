//
//@auhor Paras Dhingra
//@date 17th Sep 2017
//@description Test class for ProductSearchController
//@company IHS Markit
//
@isTest
public class TestProductSearchController {
	//
     //@author Paras Dhingra
     //@date 17 Sep 2017
     //@description Test multiple methods productSearchController.getProducts
     //             and productSearchController.getProductsAlreadyInOppy
     //@param null
     //@return void
     //@company IHS Markit
     //
     @isTest
    private static void TestGetProductDetails() {
        //create test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',true);
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD'); 
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.DiscountThreshold__c = 10;
        p1.LegalEntity__c = testLegalEntity.Id;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        p2.LegalEntity__c = testLegalEntity.Id;
        insert new List<Product2>{p1,p2};
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        insert new List<PricebookEntry>{pbe1,pbe2};
        
        //Now create product schedules
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, currentFiscalYear, '1 Year', currentFiscalYear, p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, currentFiscalYear, '3 Years', currentFiscalYear, p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, currentFiscalYear, '3 Years', String.valueOf(Integer.valueOf(currentFiscalYear)+1), p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, currentFiscalYear, '3 Years', String.valueOf(Integer.valueOf(currentFiscalYear)+2), p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4};
        String legalEntity = testLegalEntity.Id;
        Test.startTest();
        List<productSelectorWrapperClass> assertProd = productSearchController.getProducts ('','Test Product',
                                                                 '', '', '','', '', '', legalEntity,'',null,null,'','');     //SFDC-4730 change
        System.assertEquals(2, assertProd.size(),'check size');
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        insert oli1;
        List<string> productId = productSearchController.getProductsAlreadyInOppy(testOppy.Id);
        System.assertEquals(1, productId.size(), 'check size');
        System.assertEquals(p1.Id, productId[0],'check recordId');
        Test.stopTest();
        
    }
     //
     //@author Paras Dhingra
     //@date 09 Oct 2017
     //@description Test class for productSearchController.getAllLegalEntities
     //@param null
     //@return void
     //@company IHS Markit
     //
     @isTest
    private static void TestGetAllLegalEntities() {
       //create test data
        User testUser = TestUtility.createTestUser('IHSMarkit System Admin','testSaleuser@parastest.ocom',false);
        testUser.LegalEntity__c = 'IHSM test legalEntity2';
        insert testUser;
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD'); 
        LegalEntity__c testLegalEntity2 = TestUtility.createLegalEntity('IHSM test legalEntity2', 'USD'); 
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',false);
        testOppy.LegalEntity__c = testLegalEntity.Id;
        testOppy.OwnerId = testUser.Id;
        insert testOppy;
        Test.startTest();
        String legalEntity = testLegalEntity.Id;
        productSearchController.OpportunityLegalEntityWrapper assertWrapper = productSearchController.getAllLegalEntities(testOppy.Id);
        System.assertEquals(legalEntity,assertWrapper.oppyLegalEntity,'Compare Legal entity');
        System.assertEquals(2,assertWrapper.lstLegalEntity.size(),'Compare Legal entity list size');
        testOppy.LegalEntity__c = null;
        update testOppy;
        assertWrapper = productSearchController.getAllLegalEntities(testOppy.Id);
        System.assertEquals(testLegalEntity2.Id,assertWrapper.oppyLegalEntity,'Compare Legal entity');
        Test.stopTest();

    }
     //
     //@author Paras Dhingra
     //@date 09 Oct 2017
     //@description Test class for productSearchController.deleteProductsOnOppy
     //@param null
     //@return void
     //@company IHS Markit
     //@modified by : Ankita Singh due to change in the validation rule as per SFDC1-6247
    @isTest 
    private static void deleteProductsOnOppy() {
         //create test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',true);
        LegalEntity__c le1 = TestUtility.createLegalEntity('Legal Entity 1','USD');
        LegalEntity__c le2 = TestUtility.createLegalEntity('Legal Entity 2','USD');
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.DiscountThreshold__c = 10;
        p1.LegalEntity__c = le1.Id;
        
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        p2.LegalEntity__c = le1.Id;
        insert new List<Product2>{p1,p2};
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        insert new List<PricebookEntry>{pbe1,pbe2};
        //Now create product schedules
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, '2017', '1 Year', currentFiscalYear, p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, '2017', '3 Years', currentFiscalYear, p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, '2018', '3 Years', currentFiscalYear, p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, '2019', '3 Years', currentFiscalYear, p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4};
        
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        OpportunityLineItem oli2 = TestUtility.createOpportunityLineItem(testOppy.id, pbe2,false);
        oli1.Status__c = 'New';
        oli2.Status__c = 'New';
        insert new List<OpportunityLineItem>{oli1,oli2};
        Test.startTest();
        //create Opportunity product schedules
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps1.Id,1223.23,1000,
                                                                                            'Amount', 223.23, 0.0, p1.Id, '2017', 2, 
                                                                                            oli1.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps2.Id,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, p2.Id, '2017', 1, 
                                                                                            oli2.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps3.Id,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, p2.Id, '2018', 1, 
                                                                                            oli2.Id,false);
        OpportunityLineItemSchedule__c ops4 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps4.Id,2323.23,2000,
                                                                                            'Amount', 423.23, 0.0, p2.Id, '2019', 1, 
                                                                                            oli2.Id,false);
        ops1.Status__c='New';
        ops2.Status__c='New';
        ops3.Status__c='New';
        ops4.Status__c='New';
         insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3,ops4};
        // delete Opportunity line item and it's schedules
        productSearchController.deleteProductsOnOppy(testOppy.Id,le2.Id);
        //assert Opportunity
        Opportunity oppy = [Select id, (Select id from opportunityLineItems), (select Id from OpportunityProductSchedules__r) from Opportunity
                            where Id=:testOppy.Id];
        System.assertEquals(0, oppy.opportunityLineItems.size(),'check size');
        System.assertEquals(0, oppy.OpportunityProductSchedules__r.size(),'check size');
     }
    //@author Manish Kumar
    //@date 15 Oct 2021
    //@description Test class for productSearchController.getAllBusLineOnIBSSelection
    //@param null
    //@return void
    //@company IHS Markit
    //
    @isTest
    private static void TestgetAllInternalBusinessSegmentAAG() {
       //create test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1', true);
        BusinessLine__c bl = New BusinessLine__c();
        bl.Name = 'Test Business Line';
        bl.Status__c = 'Active';
        insert bl;
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.InternalBusinessSegment__c = 'Aerospace';
        p1.BusinessLine2__c = bl.id;
        insert p1;
        List<List<String>> result = productSearchController.getAllInternalBusinessSegmentAAG();
        System.assertNotEquals(Null, result[0], 'Size of IBS should not be Null');
        List<String> lstOfIBS = result[0];
        String ibs = lstOfIBS[0];
        List<String> lstOfBU = productSearchController.getAllBusLineOnIBSSelection(ibs);
        System.assertNotEquals(Null, lstOfBU[0], 'Size of BL should not be Null');
        String bu = lstOfBU[0];
        List<String> lstOfSBU = productSearchController.getAllSubBusLineOnBLSelection(ibs, bu);
        System.assertEquals(Null, lstOfSBU[0], 'Size of Sub BL should be Null');
    }
}