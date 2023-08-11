/*
* @Author : Manish Kumar
* @Date : 2nd Dec 2021
* @Description : Test Class for ProductSelectionController
* @company : IHS Markit
*/
@isTest
private class TestProductSelectionController {
    
    @testSetup static void setup() {
        //create test data
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Account acc = TestUtility.createTestAccount('Test Account for Product Selection', true);
        LegalEntity__c leUS = TestUtility.createLegalEntity('Markit Group Limited US', 'USD');
        LegalEntity__c leIndia = TestUtility.createLegalEntity('IHS Global Pte Ltd', 'USD');
        LegalEntity__c leMarkitSERV = TestUtility.createLegalEntity('MarkitSERV Ltd', 'USD');
        
        Country__c countryUS = New Country__c();
        countryUS.Name = 'United States';
        countryUS.CountryCode__c = 'US';
        countryUS.Geography__c = 'United States';
        countryUS.Region__c = 'Americas';
        insert countryUS;
        Country__c countryIndia = New Country__c();
        countryIndia.Name = 'India';
        countryIndia.CountryCode__c = 'IN';
        countryIndia.Geography__c = 'Singapore';
        countryIndia.Region__c = 'APAC';
        insert countryIndia;
		Country__c countryROW = New Country__c();
		countryROW.Name = 'Rest of the World';
		countryROW.CountryCode__c = 'RT';
		countryROW.Geography__c = '#N/A';
		countryROW.Region__c = 'EMEA';
		insert countryROW;
        
        id newBusinessRecTypeId = UtilityClass.getObjectRecordTypeId('Opportunity','New Business');
        Opportunity oppyUS = TestUtility.createOpportunity(acc.Id, 'Test Opportunity for US', false);
        oppyUS.RecordTypeId = newBusinessRecTypeId;
        oppyUS.ExceptionStatus__c = 'Exception Request Denied';
        oppyUS.RequestedLegalEntity__c = leUS.Id;
        oppyUS.CurrencyIsoCode = 'USD';
        oppyUS.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
        oppyUS.OpportunityCountry__c = countryUS.Id;
        insert oppyUS;
        test.startTest();
        Opportunity oppyIndia = TestUtility.createOpportunity(acc.Id, 'Test Opportunity for India', false);
        oppyIndia.RecordTypeId = newBusinessRecTypeId;
        //oppy.ExceptionStatus__c = 'Exception Request Denied';
        //oppy.RequestedLegalEntity__c = leIndia.Id;
        //oppy.CurrencyIsoCode = 'USD';
        //oppy.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
        oppyIndia.OpportunityCountry__c = countryIndia.Id;
        insert oppyIndia;
        
        Product2 prod1 = TestUtility.createProduct('Test Product1', false);
        prod1.legalEntity__c = leIndia.Id;
        insert prod1;
        Product2 prod2 = TestUtility.createProduct('Test Product2', false);
        prod2.legalEntity__c = leIndia.Id;
        insert prod2;
        ProductExtensions__c pe1 = New ProductExtensions__c();
        pe1.product__c = prod1.Id;
        pe1.Status__c = 'Active';
        pe1.LegalEntity__c = leUS.Id;
        insert pe1;
        
        Id stdPricebookId = Test.getStandardPricebookId();
        PriceBook2 standardPB = new PriceBook2(Id = stdPricebookId, Name = 'Standard Price Book', isActive = true);
        update standardPB;
        
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, prod1.Id, false);
        pbe1.CurrencyIsoCode = oppyUS.CurrencyIsoCode;
        insert pbe1;
        
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, String.valueOf(currentFY), '1 Year', String.valueOf(currentFY), prod1.Id, true);
        
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(oppyUS.Id, pbe1, true);
        
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(oppyUS.Id,ps1.Id,2223.23,2000,
                                                                                           'Amount', 223.23, 0.0, prod1.Id, '2017', 1, 
                                                                                           testOLI.Id,false);
        ops1.Quantity__c = 1;
        insert ops1;
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 2nd Dec 2021
    // @param: NA
    // @description: Test method for ProductSelectionController.productSelectionRuleEngine
    // @return: NA
    //-----------------------------
	@isTest
    static void testProductSelectionRuleEngine(){
        test.startTest();
        
        Opportunity oppyUS = [Select id, OpportunityCountry__r.Region__c from Opportunity where Name = 'Test Opportunity for US' LIMIT 1];
        System.assertEquals('Americas', oppyUS.OpportunityCountry__r.Region__c, 'Region should be Americas');
        
        Opportunity oppyIndia = [Select id, OpportunityCountry__r.Region__c from Opportunity where Name = 'Test Opportunity for India' LIMIT 1];
        System.assertEquals('APAC', oppyIndia.OpportunityCountry__r.Region__c, 'Region should be APAC');
        
        List<Id> listOfProductIds = New List<Id>();
        Product2 prod1 = [Select id, isActive from Product2 where Name = 'Test Product1' LIMIT 1];
        System.assertEquals(true, prod1.isActive, 'Product Status should be Active');
        listOfProductIds.add(prod1.Id);
        
        LegalEntity__c leUS = [Select id, Status__c from LegalEntity__c where Name = 'Markit Group Limited US' LIMIT 1];
        System.assertEquals('Active', leUS.Status__c, 'Status should be Active');
        
        LegalEntity__c leIndia = [Select id, Status__c from LegalEntity__c where Name = 'IHS Global Pte Ltd' LIMIT 1];
        System.assertEquals('Active', leUS.Status__c, 'Status should be Active');
        
        LegalEntity__c leMarkitSERV = [Select id, Status__c from LegalEntity__c where Name = 'MarkitSERV Ltd' LIMIT 1];
        System.assertEquals('Active', leUS.Status__c, 'Status should be Active');
        
        Country__c CountryIndia = [Select id, Name, Region__c from Country__c where Name = 'India' LIMIT 1];
        System.assertEquals('APAC', CountryIndia.Region__c, 'Region should be APAC');
        
        Country__c CountryUS = [Select id, Name, Region__c from Country__c where Name = 'United States' LIMIT 1];
        System.assertEquals('Americas', CountryUS.Region__c, 'Region should be Americas');
        
        Country__c CountryROW = [Select id, Name, Region__c from Country__c where Name = 'Rest of the World' LIMIT 1];
		System.assertEquals('EMEA', CountryROW.Region__c, 'Region should be EMEA');
        
        ProductSelectionCriteria__c psc3 = New ProductSelectionCriteria__c();
        psc3.stepNumber__c = 3;
        psc3.order__c = 1;
        psc3.BillingCountry__c = CountryUS.Id;
        psc3.TargetLegalEntity__c = leUS.Id;
        insert psc3;
        
        ProductSelectionCriteria__c psc4 = New ProductSelectionCriteria__c();
        psc4.stepNumber__c = 4;
        psc4.order__c = 1;
        psc4.TargetLegalEntity__c = leIndia.Id;
        psc4.Region__c = 'APAC';
        insert psc4;
        
        LegalEntityResultWrapper lerw1 = ProductSelectionController.productSelectionRuleEngine(oppyUS.Id, listOfProductIds);
        System.assertEquals('Success', lerw1.result, 'Result should be Success');
        
        ProductSelectionCriteria__c psc2 = New ProductSelectionCriteria__c();
        psc2.stepNumber__c = 2;
        psc2.order__c = 1;
        psc2.ProductLegalEntity__c = leMarkitSERV.Id;
        insert psc2;
        
        ProductSelectionCriteria__c psc1 = New ProductSelectionCriteria__c();
        psc1.stepNumber__c = 1;
        psc1.order__c = 1;
        psc1.BillingCountry__c = CountryIndia.Id;
        psc1.TargetLegalEntity__c = leIndia.Id;
        insert psc1;
        
        LegalEntityResultWrapper lerw2 = ProductSelectionController.productSelectionRuleEngine(oppyIndia.Id, listOfProductIds);
        System.assertEquals('Success', lerw2.result, 'Result should be Success');
        
        ProductSelectionCriteria__c psc0 = New ProductSelectionCriteria__c();
        psc0.stepNumber__c = 0;
        psc0.order__c = 1;
        psc0.FormerIpOwner__c = 'IHS Consulting';
        insert psc0;
        LegalEntityResultWrapper lerw3 = ProductSelectionController.productSelectionRuleEngine(oppyUS.Id, listOfProductIds);
        System.assertEquals('Success', lerw3.result, 'Result should be Success');
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 2nd Dec 2021
    // @param: NA
    // @description: Test method for ProductSelectionController.saveProductsOnOpportunity
    // @return: NA
    //-----------------------------
	@isTest
    static void testSaveProductsOnOpportunity(){
        test.startTest();
        Opportunity oppy = [Select id, OpportunityCountry__r.Region__c from Opportunity where Name = 'Test Opportunity for US' LIMIT 1];
        System.assertEquals('Americas', oppy.OpportunityCountry__r.Region__c, 'Region should be Americas');
        LegalEntity__c le = [Select id, Status__c from LegalEntity__c where Name = 'Markit Group Limited US' LIMIT 1];
        System.assertEquals('Active', le.Status__c, 'Status should be Active');
        List<String> listOfProductIds = New List<String>();
        Product2 prod1 = [Select id, isActive from Product2 where Name = 'Test Product1' LIMIT 1];
        System.assertEquals(true, prod1.isActive, 'Product Status should be Active');
        listOfProductIds.add(prod1.Id);
        String result1 = ProductSelectionController.saveProductsOnOpportunity(listOfProductIds, oppy.Id, le.Id, false, false);
        System.assertEquals('Records added successfully', result1, 'Verify if products added successfully');
        String result2 = ProductSelectionController.saveProductsOnOpportunity(listOfProductIds, oppy.Id, le.Id, false, true);
        System.assertEquals('Records updated successfully', result2, 'Verify if products updated successfully');
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 2nd Dec 2021
    // @param: NA
    // @description: Test method for ProductSelectionController.getOppCountry
    // @return: NA
    //-----------------------------
	@isTest
    static void testGetOppCountry(){
        test.startTest();
        Opportunity oppy = [Select id, OpportunityCountry__r.Region__c from Opportunity where Name = 'Test Opportunity for US' LIMIT 1];
        System.assertEquals('Americas', oppy.OpportunityCountry__r.Region__c, 'Region should be Americas');
        String oppCountry = ProductSelectionController.getOppCountry(oppy.Id);
        System.assertEquals('United States', oppCountry, 'OppCountry should be United States');
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 3rd Dec 2021
    // @param: NA
    // @description: Test method for ProductSelectionController.exceptionApprovalEmail
    // @return: NA
    //-----------------------------
	@isTest
    static void testExceptionApprovalEmail(){
        test.startTest();
        Opportunity oppy = [Select id, OpportunityCountry__r.Region__c, (select id, Status__c from opportunitylineitems) from Opportunity where Name = 'Test Opportunity for US' LIMIT 1];
        System.assertEquals('Americas', oppy.OpportunityCountry__r.Region__c, 'Region should be Americas');
        LegalEntity__c le = [Select id, Status__c from LegalEntity__c where Name = 'Markit Group Limited US' LIMIT 1];
        System.assertEquals('Active', le.Status__c, 'Status should be Active');
        
        Map<String,List<OpportunityLineItemSchedule__c>> mapOppyProductandSchedules = new Map<String,List<OpportunityLineItemSchedule__c>>();
        for(OpportunityLineItemSchedule__c ops : [Select id,opportunityProductID__c,Opportunity__c,ExternalListPrice__c,Quantity__c,discountType__c from OpportunityLineItemSchedule__c]) {
            if(mapOppyProductandSchedules.containsKey(ops.opportunityProductID__c)) {
                mapOppyProductandSchedules.get(ops.opportunityProductID__c).add(ops);
            }
            else {
                mapOppyProductandSchedules.put(ops.opportunityProductID__c,new List<OpportunityLineItemSchedule__c>{ops});
            }
        }
        
        opportunitylineitem oli = oppy.opportunitylineitems[0];
        OPSWrapper opsWrapObj = new OPSWrapper();
		opsWrapObj.Status = oli.Status__c;
		opsWrapObj.oppyProduct = new OpportunityLineItem();
		opsWrapObj.oppyProduct = oli;
		opsWrapObj.mapOPSAll = new Map<String,List<OpportunityLineItemSchedule__c>>();
		opsWrapObj.lstOPS = mapOppyProductandSchedules.get(oli.Id);
		String existingTerm = String.valueOf(opsWrapObj.lstOPS.size());
		opsWrapObj.productTermSelected = existingTerm;
		opsWrapObj.mapOPSAll.put(existingTerm,opsWrapObj.lstOPS);
		opsWrapObj.productQty = 0.0;
        opsWrapObj.isDeleted = false;
        opsWrapObj.productQty = opsWrapObj.lstOPS[0].Quantity__c;
        opsWrapObj.discountType = opsWrapObj.lstOPS[0].discountType__c;
        opsWrapObj.productTermSelected = String.valueOf(opsWrapObj.lstOPS.size());
        opsWrapObj.lstMapOPSIndex = new List<String>();
        String wrapperJSON = '['+JSON.serialize(opsWrapObj)+']';
        
        Boolean result = ProductSelectionController.exceptionApprovalEmail(oppy.Id, 'Testing', le.Id, '1', 'India', '22012212', wrapperJSON);
        System.assertEquals(true, result, 'result should be true');
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 3rd Dec 2021
    // @param: NA
    // @description: Test method for ProductSelectionController.getListLegalEntity
    // @return: NA
    //-----------------------------
	@isTest
    static void testGetListLegalEntity(){
        test.startTest();
        List<id> listOfProductIds = New List<id>();
        Product2 prod1 = [Select id, isActive from Product2 where Name = 'Test Product1' LIMIT 1];
        System.assertEquals(true, prod1.isActive, 'Product Status should be Active');
        listOfProductIds.add(prod1.Id);
        //For Single Product
        LegalEntityResultWrapper lerw1 = ProductSelectionController.getListLegalEntity(listOfProductIds);
        System.assertEquals('SUCCESS', lerw1.result, 'Result should be SUCCESS');
        Product2 prod2 = [Select id, isActive from Product2 where Name = 'Test Product2' LIMIT 1];
        System.assertEquals(true, prod2.isActive, 'Product Status should be Active');
        listOfProductIds.add(prod2.Id);
        //For Multiple Products
        LegalEntityResultWrapper lerw2 = ProductSelectionController.getListLegalEntity(listOfProductIds);
        System.assertEquals('SUCCESS', lerw2.result, 'Result should be SUCCESS');
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 3rd Dec 2021
    // @param: NA
    // @description: Test method for ProductSelectionController.updateLegalEntityOnOppy
    // @return: NA
    //-----------------------------
	@isTest
    static void testUpdateLegalEntityOnOppy(){
        test.startTest();
        Opportunity oppy = [Select id, OpportunityCountry__r.Region__c from Opportunity where Name = 'Test Opportunity for US' LIMIT 1];
        System.assertEquals('Americas', oppy.OpportunityCountry__r.Region__c, 'Region should be Americas');
        LegalEntity__c le = [Select id, Status__c from LegalEntity__c where Name = 'Markit Group Limited US' LIMIT 1];
        System.assertEquals('Active', le.Status__c, 'Status should be Active');
        String result = ProductSelectionController.updateLegalEntityOnOppy(oppy.Id, le.Id);
        System.assertEquals('Records updated successfully', result, 'Verify if Legal Entity updated successfully');
        test.stopTest();
    }      
}