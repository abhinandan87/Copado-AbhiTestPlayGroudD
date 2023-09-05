/**
* @auhor Paras Dhingra
* @date 17th Sep 2017
* @description Test class for ProductEditController
* @company IHS Markit
* */
@isTest
public class TestProductEditController {
    /**
* @author Paras Dhingra
* @date 17 Sep 2017
* @description Test multiple methods for productEditController
* @param null
* @return void
* @company IHS Markit
*/
    @isTest private static void TestAddProducts() {
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD');
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',false);
        testOppy.CurrencyIsoCode = 'USD';
        testOppy.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
        testOppy.ContractEndDate__c = date.newinstance(currentFY, 10,21 );
        testOppy.ExceptionStatus__c = 'Exception Request Denied';   //Product Selection project change
        testOppy.RequestedLegalEntity__c = testLegalEntity.id;      //Product Selection project change
        insert testOppy;
         
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.DiscountThreshold__c = 10;
        p1.Division__c = 'Financial Services';
        p1.AAG__c = 'Subscription';
        p1.LegalEntity__c = testLegalEntity.Id;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        p2.Division__c = 'Resources';
        p2.AAG__c = 'Subscription';
        p2.LegalEntity__c = testLegalEntity.Id;
        insert new List<Product2>{p1,p2};
            Id stdPricebookId = Test.getStandardPricebookId();
        PriceBook2 standardPB = new PriceBook2(Id = stdPricebookId, Name = 'Standard Price Book', isActive = true);
        update standardPB;
        
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        pbe1.CurrencyIsoCode = 'USD';
        pbe2.CurrencyIsoCode = 'USD';
        insert new List<PricebookEntry>{pbe1,pbe2};
        //Now create product schedules
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, String.valueOf(currentFY), '1 Year', String.valueOf(currentFY), p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, String.valueOf(currentFY), '3 Years', String.valueOf(currentFY), p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, String.valueOf(currentFY), '3 Years', String.valueOf(currentFY + 1), p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, String.valueOf(currentFY), '3 Years', String.valueOf(currentFY + 2), p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4};
        Test.startTest();    
            List<ProductEditController.ProductLineItemWrapper> lstProdWrapper = ProductEditController.getProductDetails(new List<Id>{p1.Id,p2.Id},testOppy.Id,'IHSM test legalEntity');
        	System.assertEquals(2, lstProdWrapper.size(),'Product details are not correct');
        	lstProdWrapper[0].aag = 'Subscription';
        	lstProdWrapper[0].ProRationApplied = 'Yes';
        	String json = System.JSON.serialize(lstProdWrapper);
        	ProductEditController.saveProductsOnOpportunity(json, testOppy.Id, testLegalEntity.Id);
        	List<String> licenseTypes = ProductEditController.getLicenseTypes();
        	Decimal dConvertedVal = ProductEditController.getConvertedCurrencyRate('USD', 'INR', 100.0);
        Test.stopTest();
      }
    /**
* @author Ankush Agarwal
* @date 24 Sep 2021
* @description Test Indian Levy
* @param null
* @return void
* @company IHS Markit
*/
    @isTest private static void TestAddProductsIndianLevy() {
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHS Global Pte Ltd', 'USD'); 
        //Country Record
        Country__c indiaCountry = new Country__c(CountryCode__c = 'IN', Region__c = 'APAC', Geography__c = 'Singapore',
                                                 CurrencyIsoCode = 'USD', LegacyID__c = testLegalEntity.Id, Name = 'India');
        insert indiaCountry;
        Account testAccount = TestUtility.createTestAccount('Test Account 1', true);
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',false);
        testOppy.CurrencyIsoCode = 'USD';
        testOppy.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
        testOppy.ContractEndDate__c = date.newinstance(currentFY, 10,21 );
        testOppy.OpportunityCountry__c = indiaCountry.Id;
        insert testOppy;
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.DiscountThreshold__c = 10;
        p1.Division__c = 'Resources';
        p1.AAG__c = 'Subscription';
        p1.Mediatype__c = 'Online Access';
        p1.LegalEntity__c = testLegalEntity.Id;
        insert new List<Product2>{p1};
        
        Id stdPricebookId = Test.getStandardPricebookId();
        PriceBook2 standardPB = new PriceBook2(Id = stdPricebookId, Name = 'Standard Price Book', isActive = true);
        update standardPB;
        
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        pbe1.CurrencyIsoCode = 'INR';
        insert new List<PricebookEntry>{pbe1};
        //Now create product schedules
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, String.valueOf(currentFY), '1 Year', String.valueOf(currentFY), p1.Id, false);
        insert new List<ProductSchedule__c>{ps1};
        Test.startTest();    
            List<ProductEditController.ProductLineItemWrapper> lstProdWrapper = ProductEditController.getProductDetails(new List<Id>{p1.Id},testOppy.Id,'IHS Global Pte Ltd');
        	System.assertEquals(1, lstProdWrapper.size(),'Product details are not correct');
        	String json = System.JSON.serialize(lstProdWrapper);
        	ProductEditController.saveProductsOnOpportunity(json, testOppy.Id, testLegalEntity.Id);
        Test.stopTest();
      }
	        /**
    * @Author : Digvijay
    * @date: 3/09/2021
    * @description :test Method to check UnitListPrice adjustment  for Indian Levy product
                    for UnitListPrice of 1000 and Discount =200, the netsales price  with levycharges(2.0408 %) equals 816.53. Hence factor of 16.53 should
                    be adjusted to List
    * @company : IHS Markit
    * @return :void 
    */
    @isTest private static void testAddProductsindianLevyCalc() {
        ProductEditController.OpportunityLineItemScheduleWrapper wrapperObj = new ProductEditController.OpportunityLineItemScheduleWrapper();
        wrapperObj.externalListPrice = 1000;
        wrapperObj.discountPercent = 0.0;
        wrapperObj.discountAmount =200;
        wrapperObj.salesPrice = 816.53;
        wrapperObj.AnnualizedUnitPrice = 900;
        wrapperObj.AnnualizedTotalAmount = 1000;
        wrapperObj.AnnualizedDiscountAmount =200;
        wrapperObj.salesPrice = 816.53;
        Test.startTest();
        Decimal adjustedListPrice=ProductEditController.setUnitPriceasperLevyCharges(wrapperObj,1, False);            
        Decimal adjustedListPrice1=ProductEditController.setUnitPriceasperLevyCharges(wrapperObj,1, True);            
        System.assertEquals(adjustedListPrice,1016.53,'Adjusted List price is not correct');
        Test.stopTest();
        System.debug('Price..'+adjustedListPrice);
      }
}