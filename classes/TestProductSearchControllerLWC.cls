//-----------------------------
// @author: Pankhuri Jain
// @date: 25th Apr 2022
// @description: Test class for ProductSearchControllerLWC 
//------------------- 
@isTest
public class TestProductSearchControllerLWC {
	
    @isTest
    static void testGetProductDetails() {
        //Creating test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',true); 
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.DiscountThreshold__c = 10;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        insert new List<Product2>{p1,p2};
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        insert new List<PricebookEntry>{pbe1,pbe2};
        
        //Creating product schedules
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, currentFiscalYear, '1 Year', currentFiscalYear, p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, currentFiscalYear, '3 Years', currentFiscalYear, p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, currentFiscalYear, '3 Years', String.valueOf(Integer.valueOf(currentFiscalYear)+1), p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, currentFiscalYear, '3 Years', String.valueOf(Integer.valueOf(currentFiscalYear)+2), p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4};
        Test.startTest();      
        List<productSelectorWrapperClass> assertProd = ProductSearchControllerLWC.getProducts ('','Test Product','', '', '','', '', '','','','');     
        System.assertEquals(2, assertProd.size(),'check size');
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        insert oli1;
        List<string> productId = productSearchControllerLWC.getProductsAlreadyInOppy(testOppy.Id);
        System.assertEquals(1, productId.size(), 'check size');
        System.assertEquals(p1.Id, productId[0],'check recordId');
        Test.stopTest();
     
    }
    
    @isTest
    static void testGetProductDetails2() {
        //Creating test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',true); 
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.DiscountThreshold__c = 10;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        insert new List<Product2>{p1,p2};
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        insert new List<PricebookEntry>{pbe1,pbe2};
        
        //Creating product schedules
        String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY].FiscalYearSettings.Name;
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, currentFiscalYear, '1 Year', currentFiscalYear, p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, currentFiscalYear, '3 Years', currentFiscalYear, p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, currentFiscalYear, '3 Years', String.valueOf(Integer.valueOf(currentFiscalYear)+1), p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, currentFiscalYear, '3 Years', String.valueOf(Integer.valueOf(currentFiscalYear)+2), p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4};
        Test.startTest();         
        List<productSelectorWrapperClass> assertProd = ProductSearchControllerLWC.getProducts ('Data Lake Platform/Auto','Test Product','2000040046', 'Automotive Insights', 'Auto: Data Lake','Auto Data Lake Subs', 'Online Access', 'Data Lake Platform/Automotive','Data Lake','Automotive','Subscription');     
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        insert oli1;
        System.assertNotEquals(null, oli1.id,'Record Id cannot be null');
        List<string> productId = productSearchControllerLWC.getProductsAlreadyInOppy(testOppy.Id);
        Test.stopTest();
     
    }
    
    //-----------------------------
    // @author: Pankhuri Jain
    // @date: 26th Apr 2022
    // @param: null
    // @description:Test method for ProductSearchControllerLWC.getIbsBsSubBsLines 
    //------------------- 
    @isTest
    static void testGetIbsBsSubBsLines() {
        //Creating test data
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1', true);
        BusinessLine__c bl = New BusinessLine__c();
        bl.Name = 'Automative Insights';
        bl.Status__c = 'Active';
        insert bl;
        SubBusinessLine__c sbl = new SubBusinessLine__c();
        sbl.Name = 'Auto: Advisory';
        insert sbl;
        SubBusinessLine__c sbl2 = new SubBusinessLine__c();
        sbl2.Name = 'Auto: Commercial';
        insert sbl2;
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.InternalBusinessSegment__c = 'Automotive';
        p1.BusinessLine2__c = bl.id;
        p1.SubBusinessLine__c = sbl.id;
        insert p1;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.InternalBusinessSegment__c = 'Automotive';
        p2.BusinessLine2__c = bl.id;
        p2.SubBusinessLine__c = sbl2.id;
        insert p2;
        Map<String, Map<String, List<String>>> result = productSearchControllerLWC.getIbsBsSubBsLines();
        System.assertNotEquals(Null, result.size(), 'Size of IBS should not be Null');
    }
    
}