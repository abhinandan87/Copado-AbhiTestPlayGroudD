//-----------------------------
// @author: Priyanka Vyas
// @date: 6th Aug 2020
// @param: NA
// @description: SFDC-3131 - Test class for OpportunityProductEditController.getOpportunityOPS 
//------------------- 
@isTest
public class TestOpportunityProductEditController {
    @testSetup static void setup() {
        test.startTest();
        ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='Test - Energy', Active__c=true, ProfitCenterCode__c='187',SaleType__c='Subscription');
        insert testProfitCenter;
        Family__c testProdFam = new Family__c(Name='Test-C&A',Status__c ='Active');
        insert testProdFam;
        ProductGroup__c pg = TestUtility.createProductGroup('MRO',false,false);
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.FormerIpOwner__c = 'Test Owner';
        testProd.Family__c = testProdFam.Id;
        testProd.ProfitCenters__c = testProfitCenter.Id;
        testProd.AAG__c = 'Subscription';
        testProd.ProductGroup__c = pg.Id;
        insert testProd;
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Integer nextFY = currentFY+1;
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Oppy', false);
        testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        Opportunity testOpportunity1 = TestUtility.createOpportunity(testAccount.Id, 'uOppy', false);
        testOpportunity1.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
        testOpportunity1.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        insert new list<Opportunity>{testOpportunity, testOpportunity1};
            
            OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        	testOLI.IsProRated__c = 'Yes';
        	update testOLI;
        
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '1 Year', String.valueof(currentFY), testProd.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+1), testProd.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+2), testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3};
            /*ProductSchedule__c pSch1 = [Select id, ProductTerm__c from ProductSchedule__c where id=:ps1.id];
        pSch1.ProductTerm__c='1 Year';
        update pSch1;*/
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps1.Id,2223.23,2000,
                                                                                           'Amount', 223.23, 0.0, testProd.Id, '2017', 1, 
                                                                                           testOLI.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps2.Id,2323.23,2000,
                                                                                           'Amount', 323.23, 0.0, testProd.Id, '2018', 1, 
                                                                                           testOLI.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps3.Id,2323.23,2000,
                                                                                           'Amount', 423.23, 0.0, testProd.Id, '2019', 1, 
                                                                                           testOLI.Id,false);
        ops1.Quantity__c = 1;
        ops2.Quantity__c = 1;
        ops3.Quantity__c = 1;
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3};
            test.stopTest();
    }
    
    @isTest static void testGetOpportunityOPS() { 
        test.startTest();
        List<Opportunity> OppyList = [Select Id, name, (select id from opportunitylineitems) from Opportunity where name='test Oppy' or name='uOppy' order by name asc];
        OpportunityProductEditController.OppyWrapper oppyWrapperObject = new OpportunityProductEditController.OppyWrapper();
        String sortOLIdirection='asc';
        String sortOLIByFieldName='Product2.Name';
        oppyWrapperObject=OpportunityProductEditController.getOpportunityOPS(OppyList[0].Id, sortOLIdirection, sortOLIByFieldName);
        oppyWrapperObject=OpportunityProductEditController.getOpportunityOPS(OppyList[1].id, sortOLIdirection, sortOLIByFieldName);

        //String JsonWrap =  JSON.serialize(oppyWrapperObject);
        //System.debug('@@@@@@ JsonWrap'+JsonWrap);
        //String returnVal = OpportunityProductEditController.saveProducts(OppyList[0].id,JsonWrap);
        test.stopTest();
        System.assertEquals(OppyList[0].OpportunityLineItems.size(), 1, 'The opportunity test Oppy has one line item');
        System.assertEquals(OppyList[1].OpportunityLineItems.size(), 0, 'The opportunity test Oppy no line item');
    }

//-----------------------------
// @author: Ankush Agarwal
// @date: 23th Sep 2021
// @param: NA
// @description: SFDC-400 - Test method for ProRation Logic 
//------------------- 
    @isTest static void testGetOpportunityOPSProRate() { 
        test.startTest();
        ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='Test - Energyv2', Active__c=true, ProfitCenterCode__c='185',SaleType__c='Subscription');
        insert testProfitCenter;
        Family__c testProdFam = new Family__c(Name='Test-C&A',Status__c ='Active');
        insert testProdFam;
        ProductGroup__c pg = TestUtility.createProductGroup('MRO',false,false);
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.FormerIpOwner__c = 'Test Owner';
        testProd.Family__c = testProdFam.Id;
        testProd.ProfitCenters__c = testProfitCenter.Id;
        testProd.ProductGroup__c = pg.Id;
        testProd.AAG__c = 'Subscription';
        testProd.Division__c = 'Resources';
        insert testProd;
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Integer nextFY = currentFY+1;
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Oppy', false);
        testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY, 10, 21);
        insert testOpportunity;
            
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '1 Year', String.valueof(currentFY), testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1};

        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps1.Id,2223.23,2000,
                                                                                           'Amount', 223.23, 0.0, testProd.Id, String.valueOf(currentFY), 1, 
                                                                                           testOLI.Id,false);
        insert new List<OpportunityLineItemSchedule__c>{ops1};
            
        testOpportunity.GlobalSegments__c = 'Financial Services';
        update testOpportunity;    

        OpportunityProductEditController.OppyWrapper oppyWrapperObject = new OpportunityProductEditController.OppyWrapper();
        String sortOLIdirection='asc';
        String sortOLIByFieldName='Product2.Name';
        oppyWrapperObject=OpportunityProductEditController.getOpportunityOPS(testOpportunity.Id, sortOLIdirection, sortOLIByFieldName);
        String sDelMessage = OpportunityProductEditController.deleteProductsOnOppy(testOpportunity.Id, '');
        List<String> licenseTypes = OpportunityProductEditController.getLicenseTypes();
        List<String> riskStatus = OpportunityProductEditController.getRiskStatus();
        //String JsonWrap =  JSON.serialize(oppyWrapperObject);
        //System.debug('@@@@@@ JsonWrap'+JsonWrap);
        //String returnVal = OpportunityProductEditController.saveProducts(OppyList[0].id,JsonWrap);
        test.stopTest();
        System.assertEquals(testOpportunity.GlobalSegments__c,'Financial Services','Global Segment is not correct' );
    }

    @isTest static void TestSaveProducts() { 
     
        List<Opportunity> OppyList = [Select Id, name, (select id,Status__c from opportunitylineitems) from Opportunity where name='test Oppy' or name='uOppy' order by name asc];
		Map<String,List<OpportunityLineItemSchedule__c>> mapOppyProductandSchedules = new Map<String,List<OpportunityLineItemSchedule__c>>();
        for(OpportunityLineItemSchedule__c ops : [Select id,opportunityProductID__c,Opportunity__c,ExternalListPrice__c,Quantity__c,discountType__c from OpportunityLineItemSchedule__c]) {
            if(mapOppyProductandSchedules.containsKey(ops.opportunityProductID__c)) {
                mapOppyProductandSchedules.get(ops.opportunityProductID__c).add(ops);
            }
            else {
                mapOppyProductandSchedules.put(ops.opportunityProductID__c,new List<OpportunityLineItemSchedule__c>{ops});
            }
        }
		
		opportunitylineitem oli = OppyList[0].opportunitylineitems[0];
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
	
        String JsonWrap =  '['+JSON.serialize(opsWrapObj)+']';
        test.startTest();
        String returnVal = OpportunityProductEditController.saveProducts(OppyList[0].id,JsonWrap);
        System.assertEquals(returnVal,'Records updated successfully', 'Error occurred while creating records');
        test.stopTest();
    }
    /**
    * @Author : Digvijay
    * @date: 3/09/2021
    * @description :test Method to check UnitListPrice adjustment  for Indian Levy product
                    for UnitListPrice of 1000 and Discount =200, the netsales price  with levycharges(2.0408 %) equals 816.53. Hence factor of 16.53 should
                    be adjusted to List
    * @company : IHS Markit
    * @param : OpportunityLineItemSchedule__c
    * @return :List<OpportunityLineItemSchedule__c>  
    */
    @isTest static void testIndianLevySaveProducts() { 
        Id standardId = Test.getStandardPricebookId();
        Product2 testProd=[Select Id from Product2 where Name='Test Product'];
        PricebookEntry testPBE = [Select Id ,Pricebook2Id , UnitPrice from PricebookEntry where Pricebook2Id=:standardId ];
        List<Opportunity> OppyList = [Select Id, name, (select id,Status__c from opportunitylineitems) from Opportunity where name='test Oppy'  order by name asc];
    
        OpportunityLineItem oli = TestUtility.createOpportunityLineItem(OppyList[0].Id, testPBE, false);
        oli.IsProRated__c = 'Yes';
        oli.Product2Id=testProd.Id;
        insert oli;
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '1 Year', String.valueof(currentFY), testProd.Id, false);
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(OppyList[0].Id,ps1.Id,1000,816.33,
                                                                                           'Amount', 200, 0.0, testProd.Id, '2017', 1, 
                                                                                           oli.Id,false);  
        ops1.Quantity__c = 1;
        ops1.AnnualizedDiscountAmount__c = 0;
        ops1.AnnualizedUnitPrice__c = 100;
        OPSWrapper opsWrapObj = new OPSWrapper();
        opsWrapObj.Status = oli.Status__c;
        opsWrapObj.oppyProduct = new OpportunityLineItem();
        opsWrapObj.oppyProduct = oli;
        opsWrapObj.isIndianLevyProd=true;
        opsWrapObj.mapOPSAll = new Map<String,List<OpportunityLineItemSchedule__c>>();
        opsWrapObj.lstOPS=new List<OpportunityLineItemSchedule__c>();
        opsWrapObj.lstOPS.add(ops1);
        String existingTerm = String.valueOf(opsWrapObj.lstOPS.size());
        opsWrapObj.productTermSelected = existingTerm;
        opsWrapObj.mapOPSAll.put(existingTerm,opsWrapObj.lstOPS);
        opsWrapObj.productQty = 0.0;
        opsWrapObj.isDeleted = false;
        opsWrapObj.productQty = opsWrapObj.lstOPS[0].Quantity__c;
        opsWrapObj.discountType = opsWrapObj.lstOPS[0].discountType__c;
        opsWrapObj.productTermSelected = String.valueOf(opsWrapObj.lstOPS.size());
        opsWrapObj.lstMapOPSIndex = new List<String>();
        String JsonWrap =  '['+JSON.serialize(opsWrapObj)+']';
        test.startTest();
        String returnVal = OpportunityProductEditController.saveProducts(OppyList[0].id,JsonWrap);
        oli=[Select Id , Product2.AAG__c, IsProRated__c, UnitListPrice__c from opportunitylineitem where Id=:oli.Id];
        System.assertEquals(oli.UnitListPrice__c,1016.33);
        List<OpportunityLineItemSchedule__c> lstLineItemSch=[Select Id ,SalesPrice__c,DiscountAmount__c, AnnualizedDiscountAmount__c, AnnualizedTotalAmount__c, Quantity__c from OpportunityLineItemSchedule__c where ProductSchedule__c=:ps1.Id];
        lstLineItemSch=OpportunityProductEditController.getUnitPriceasperLevyCharges(lstLineItemSch,oli);
        System.assertEquals(lstLineItemSch[0].ExternalListPrice__c,1000);
        test.stopTest();
    }
    //-----------------------------
// @author: Manish Kumar
// @date: 8th Nov 2021
// @param: String
// @description: SFDC-4909 - Test method for OpportunityProductEditController.updateLegalEntityNull 
//------------------- 
    @isTest static void testUpdateLegalEntityNull() { 
        
        Id standardId = Test.getStandardPricebookId();
        Opportunity opty = [Select id, Name, legalEntity__c from Opportunity where name = 'test Oppy' limit 1];
        system.assertEquals('test Oppy', opty.Name,'Opportunity name is not correct');
        Product2 testProd = [Select Id, Name from Product2 where Name='Test Product'];
        system.assertEquals('Test Product', testProd.Name,'Product name is not correct');
        PricebookEntry testPBE = [Select Id ,Pricebook2Id , UnitPrice from PricebookEntry where Pricebook2Id=:standardId ];
        system.assertEquals(standardId, testPBE.Pricebook2Id,'There is problem with pricebook Id');
        OpportunityLineItem oli = TestUtility.createOpportunityLineItem(opty.Id, testPBE, false);
        oli.Product2Id = testProd.Id;
        insert oli;
        
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '1 Year', String.valueof(currentFY), testProd.Id, false);
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(opty.Id,ps1.Id,1000,816.33,
                                                                                           'Amount', 200, 0.0, testProd.Id, '2017', 1, 
                                                                                           oli.Id,false);  
        ops1.Quantity__c = 1;
        ops1.AnnualizedDiscountAmount__c = 0;
        ops1.AnnualizedUnitPrice__c = 100;
        OPSWrapper opsWrapObj = new OPSWrapper();
        opsWrapObj.Status = oli.Status__c;
        opsWrapObj.oppyProduct = new OpportunityLineItem();
        opsWrapObj.oppyProduct = oli;
        opsWrapObj.isIndianLevyProd=true;
        opsWrapObj.mapOPSAll = new Map<String,List<OpportunityLineItemSchedule__c>>();
        opsWrapObj.lstOPS=new List<OpportunityLineItemSchedule__c>();
        opsWrapObj.lstOPS.add(ops1);
        String existingTerm = String.valueOf(opsWrapObj.lstOPS.size());
        opsWrapObj.productTermSelected = existingTerm;
        opsWrapObj.mapOPSAll.put(existingTerm,opsWrapObj.lstOPS);
        opsWrapObj.productQty = 0.0;
        opsWrapObj.isDeleted = false;
        opsWrapObj.productQty = opsWrapObj.lstOPS[0].Quantity__c;
        opsWrapObj.discountType = opsWrapObj.lstOPS[0].discountType__c;
        opsWrapObj.productTermSelected = String.valueOf(opsWrapObj.lstOPS.size());
        opsWrapObj.lstMapOPSIndex = new List<String>();
        String JsonWrap =  '['+JSON.serialize(opsWrapObj)+']';
        test.startTest();
        String returnVal = OpportunityProductEditController.saveProducts(opty.id,JsonWrap);
        system.assertEquals('Records updated successfully', returnVal,'Records not updated successfully');
        oli=[Select Id from opportunitylineitem where Id=:oli.Id];
        if(oli!=null){
            delete oli;
            string message = OpportunityProductEditController.updateLegalEntityNull(opty.id);
            system.assertEquals('Records updated successfully', message,'Records not updated successfully');
        }
        test.stopTest();
    }
}