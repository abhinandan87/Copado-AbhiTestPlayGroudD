/**
* @auhor Ankush Agarwal
* @date 3rd Apr 2022
* @description Test class for OpportunityAddProductControllerLWC
* @company IHS Markit
* */
@isTest
public class TestOpportunityAddProductControllerLWC {

    @isTest
	private static void testAddProducts() {
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
         
        Test.startTest();    
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
            OpportunityAddProductControllerLWC.OppyWrapper lstProdWrapper = OpportunityAddProductControllerLWC.getProductDetails(new List<Id>{p1.Id,p2.Id},testOppy.Id,'IHSM test legalEntity');
        	System.assertEquals(2, lstProdWrapper.lstOPSWrapper.size(), 'Product List Created');
        	//lstProdWrapper.aag = 'Subscription';
        	lstProdWrapper.canBeProRated = true;
        	lstProdWrapper.isProRated = 'Yes';
        	String json = System.JSON.serialize(lstProdWrapper.lstOPSWrapper);
        	OpportunityAddProductControllerLWC.saveProductsOnOpportunity(json, testOppy.Id, testLegalEntity.Id);
        	List<String> licenseTypes = OpportunityAddProductControllerLWC.getLicenseTypes();
            List<OpportunityLineItem> oppyProductList = [Select Id, OpportunityId from OpportunityLineItem where OpportunityId =:testOppy.Id];
            String jsonOLI = System.JSON.serialize(oppyProductList);
        	String msg = OpportunityAddProductControllerLWC.deleteOppyProducts(jsonOLI);
            System.assertEquals('Products deleted successfully from Opportunity', msg, 'Products deleted successfully');
        	Decimal dConvertedVal = OpportunityAddProductControllerLWC.getConvertedCurrencyRate('USD', 'INR', 100.0);
        Test.stopTest();
      }

    @isTest
	private static void testAddProductsIndianLevy() {
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
            OpportunityAddProductControllerLWC oAPCObj = new OpportunityAddProductControllerLWC();
            OpportunityAddProductControllerLWC.OppyWrapper lstProdWrapper = OpportunityAddProductControllerLWC.getProductDetails(new List<Id>{p1.Id},testOppy.Id,'IHS Global Pte Ltd');
        	System.assertEquals(1, lstProdWrapper.lstOPSWrapper.size(), 'Product List Created');
        	String json = System.JSON.serialize(lstProdWrapper.lstOPSWrapper);
        	OpportunityAddProductControllerLWC.saveProductsOnOpportunity(json, testOppy.Id, testLegalEntity.Id);
        Test.stopTest();
      }

	@isTest
    private static void testAddProductsindianLevyCalc() {
        OpportunityLineItemSchedule__c opsObj = new OpportunityLineItemSchedule__c();
        opsObj.ExternalListPrice__c = 1000;
        opsObj.DiscountPercent__c = 0.0;
        opsObj.DiscountAmount__c =200;
        opsObj.SalesPrice__c = 816.53;
        opsObj.Quantity__c = 1;
        opsObj.CurrencyIsoCode = 'USD';
        opsObj.AnnualizedUnitPrice__c = 900;
        opsObj.AnnualizedDiscountAmount__c =200;
        List<OpportunityLineItemSchedule__c> opsList = new List<OpportunityLineItemSchedule__c>();
        opsList.add(opsObj);
        //Formula fields need to be recalculated as record is not yet inserted     
        List<FormulaRecalcResult> results = Formula.recalculateFormulas(opsList);
        Test.startTest();
			Decimal adjustedListPrice=OpportunityAddProductControllerLWC.setUnitPriceasperLevyCharges(opsList[0],1, False);            
			Decimal adjustedListPrice1=OpportunityAddProductControllerLWC.setUnitPriceasperLevyCharges(opsList[0],1, True);            
			System.assertEquals(adjustedListPrice,1016.53, 'Adjusted List Price is calculated');
        Test.stopTest();
	}
}