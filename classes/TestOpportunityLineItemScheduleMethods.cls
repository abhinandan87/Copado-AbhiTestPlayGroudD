//
 // @auhor : Paras Dhingra
 // @date : 17th Sep 2017
 // @description : Test class for OpportunityLineItemScheduleMethods
 // //
@isTest
public class TestOpportunityLineItemScheduleMethods {
    
     //
     // @author Paras Dhingra
     // @date 17 Sep 2017
     // @description Test multiple methods OpportunityLineItemScheduleMethods.RollUpValuesToOppyProduct
     //              and OpportunityLineItemMethods.rollupValuesToOpportunity
     // @param null
     // @return void
     // @company IHS Markit
     //
     @isTest private static void TestRollUpValuesToOppyProduct() {
        //create test data
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
        Test.startTest();
        insert new List<PricebookEntry>{pbe1,pbe2};
        
        //Now create product schedules
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, '2017', '1 Year', '2017', p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, '2017', '3 Years', '2017', p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, '2018', '3 Years', '2017', p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, '2019', '3 Years', '2017', p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4};
        
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        OpportunityLineItem oli2 = TestUtility.createOpportunityLineItem(testOppy.id, pbe2,false);
        insert new List<OpportunityLineItem>{oli1,oli2};
        
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
       
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3,ops4};
        
		
        //assert Opportunity line Item
        list<OpportunityLineItem> assertOli1 = [Select Id, TotalPrice, Discount_Amount__c from OpportunityLineItem where id IN : new list<id>{oli1.id,oli2.id}];
        System.assertEquals(2000, assertOli1[0].TotalPrice,'Checking total price');
        System.assertEquals(223.23, assertOli1[0].Discount_Amount__c,'Checking Discount Amount');
        
        System.assertEquals(6000, assertOli1[1].TotalPrice,'Checking total price');
        System.assertEquals(969.69, assertOli1[1].Discount_Amount__c,'Checking Discount Amount');
        
        //assert opportunity 
        Opportunity assertOppy = [Select id, Amount from Opportunity where id=:testOppy.Id];
        System.assertEquals(8000, assertOppy.Amount,'Checking total contractvalue');
        ops4.SalesPrice__c = 1000;
        ops4.DiscountAmount__c = 1423.23;
        update ops4;
        
        OpportunityLineItem assertOli2 = [Select Id, TotalPrice, Discount_Amount__c from OpportunityLineItem where id=:oli2.id];
        System.assertEquals(5000, assertOli2.TotalPrice,'Checking total price');
        assertOppy = [Select id, Amount from Opportunity where id=:testOppy.Id];
        System.assertEquals(7000, assertOppy.Amount,'Checking total contractvalue');
        delete ops4;
        
        assertOppy = [Select id, Amount from Opportunity where id=:testOppy.Id];
        System.assertEquals(6000, assertOppy.Amount,'Checking total contractvalue');
        Test.stopTest();
    }
    //
    // @author Paras Dhingra
    // @date 12th July 2018
    // @description Test class for OpportunityLineItemScheduleMethods.populateAnnualizedValues
    // @param null
    // @return void
    // @company IHS Markit
    //
    @isTest private static void TestpopulateAnnualizedValues() {
        //create test data
        Product2 testProd = TestUtility.createProduct('Test Product', false);
		insert testProd;
		Id standardId = Test.getStandardPricebookId();
		PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
		testAccount.DataGovernanceStatus__c = 'Approved';
		insert testAccount;

		Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);
		testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
		testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        insert testOpportunity;
         
		OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
		ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY), testProd.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+1), testProd.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+2), testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3};
         OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps1.Id,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, testProd.Id,  String.valueof(currentFY), 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps2.Id,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, testProd.Id,  String.valueof(currentFY+1), 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps3.Id,2323.23,2000,
                                                                                            'Amount', 423.23, 0.0, testProd.Id,  String.valueof(currentFY+2), 1, 
                                                                                            testOLI.Id,false);
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3};
        Test.startTest();
        //assert that annualized fields are populated
        List<OpportunityLineItemSchedule__c> assertLstOPS = [Select id, AnnualizedUnitPrice__c, AnnualizedDiscountAmount__c,
                                                                ExternalListPrice__c,DiscountAmount__c
                                                                from OpportunityLineItemSchedule__c where 
                                                                    Opportunity__c=:testOpportunity.Id];
        Decimal annualizedTotalAmount = 0;
        for(OpportunityLineItemSchedule__c ops : assertLstOPS) {
            System.assertEquals(ops.AnnualizedUnitPrice__c,ops.ExternalListPrice__c,'Opp unit price and list price should be same.');
            System.assertEquals(ops.AnnualizedDiscountAmount__c,ops.DiscountAmount__c,'opp annual discount and discount amount should be same.');
            annualizedTotalAmount+=(ops.AnnualizedUnitPrice__c-ops.AnnualizedDiscountAmount__c);
        }
        List<OpportunityLineItem> assertLstOLI = [Select id, AnnualizedTotalAmount__c 
                                                    from OpportunityLineItem
                                                    where OpportunityID=:testOpportunity.Id];
        System.assertEquals(annualizedTotalAmount,assertLstOLI[0].AnnualizedTotalAmount__c,'Amount should be 0.');
        Test.stopTest();
    }
    
    //
    // @author Sharique Iqbal
    // @date 10th May 2021
    // @description Test class for OpportunityLineItemScheduleMethods.syncAutoRenewalPriceChangeOnlyLineItems
    // @param null
    // @return void
    // @company IHS Markit
    //
    @isTest private static void TestsyncAutoRenewalPriceChangeOnlyLineItemsWithDuplicates() {
        //create test data
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        insert testProd;
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Opportunity testOpportunityOld = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);
        testOpportunityOld.ContractStartDate__c =   date.newinstance(currentFY-1, 03,21 );
        testOpportunityOld.ContractEndDate__c = date.newinstance(currentFY, 10, 21);
        insert testOpportunityOld;
                
        Id OrderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(OrderFormRecordTypeId, testOpportunityOld.Id);
        
        ContractLineItem__c cli = TestUtility.createContractLineItem('test Product1', contractRecId, testProd.Id, false);
        cli.AssociatedProduct__c = testProd.Id;
        ContractLineItem__c cliDuplicate = TestUtility.createContractLineItem('test Product1', contractRecId, testProd.Id, false);
        cliDuplicate.AssociatedProduct__c = testProd.Id;
        List<ContractLineItem__c> listCLIToInsert = new List<ContractLineItem__c>{cli, cliDuplicate};
        insert listCLIToInsert;
        
        
        ContractLineItemSchedule__c cliSch = TestUtility.createContractLineItemSchedule(contractRecId,cli.Id, false);
        cliSch.SalesPrice__c = 1000;
        cliSch.InstallmentYear__c= String.valueof(currentFY);
        insert cliSch;
        
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY), testProd.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+1), testProd.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+2), testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3};
        
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);       
        testOpportunity.ContractStartDate__c =  date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);        
        testOpportunity.ContractBeingRenewed__c = contractRecId;
        testOpportunity.AutoRenewal__c =true;
        testOpportunity.PriceChangeOnly__c = true;
        insert testOpportunity;
        
        Test.startTest();
		
		
        
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, false);
        OpportunityLineItem testOLIDuplicate = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, false);
        List<OpportunityLineItem> listOLIToInsert = new List<OpportunityLineItem>{testOLI, testOLIDuplicate};
        insert listOLIToInsert;
        //System.debug('====testOLI===' + testOLI);
        
        
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps1.Id,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, testProd.Id,  String.valueof(currentFY), 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps2.Id,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, testProd.Id,  String.valueof(currentFY+1), 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps3.Id,2323.23,2000,
                                                                                            'Amount', 423.23, 0.0, testProd.Id,  String.valueof(currentFY+2), 1, 
                                                                                            testOLI.Id,false);
     
        System.debug('====testOpportunity.Id===' + testOpportunity.Id);
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3};
        ops1.TotalPrice__c = 1000;
        update ops1;
        ContractLineItemSchedule__c csch = [Select id,SalesPrice__c from ContractLineItemSchedule__c limit 1];
        //System.assertEquals(csch.SalesPrice__c, ops1.TotalPrice__c , 'ContractLineItem was not updated');
        System.assertEquals(csch.SalesPrice__c, ops1.TotalPrice__c , 'ContractLineItem Schedule price.');
        Test.stopTest();
    }
    
    @isTest private static void TestsyncAutoRenewalPriceChangeOnlyLineItemsWithoutDuplicates() {
        //create test data
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        insert testProd;
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Opportunity testOpportunityOld = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);
        testOpportunityOld.ContractStartDate__c =   date.newinstance(currentFY-1, 03,21 );
        testOpportunityOld.ContractEndDate__c = date.newinstance(currentFY, 10, 21);
        insert testOpportunityOld;
                
        Id OrderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(OrderFormRecordTypeId, testOpportunityOld.Id);
        
        ContractLineItem__c cli = TestUtility.createContractLineItem('test Product1', contractRecId, testProd.Id, true);
        
        
        ContractLineItemSchedule__c cliSch = TestUtility.createContractLineItemSchedule(contractRecId,cli.Id, false);
        cliSch.SalesPrice__c = 1000;
        cliSch.InstallmentYear__c= String.valueof(currentFY);
        insert cliSch;
        
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY), testProd.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+1), testProd.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, String.valueof(currentFY), '3 Years', String.valueof(currentFY+2), testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3};
        
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);       
        testOpportunity.ContractStartDate__c =  date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);        
        testOpportunity.ContractBeingRenewed__c = contractRecId;
        testOpportunity.AutoRenewal__c =true;
        testOpportunity.PriceChangeOnly__c = true;
        insert testOpportunity;
        
        Test.startTest();
		
		
        
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        //System.debug('====testOLI===' + testOLI);
        
        
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps1.Id,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, testProd.Id,  String.valueof(currentFY), 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps2.Id,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, testProd.Id,  String.valueof(currentFY+1), 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,ps3.Id,2323.23,2000,
                                                                                            'Amount', 423.23, 0.0, testProd.Id,  String.valueof(currentFY+2), 1, 
                                                                                            testOLI.Id,false);
     
        System.debug('====testOpportunity.Id===' + testOpportunity.Id);
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3};
        ops1.TotalPrice__c = 1500;
        update ops1;
        ContractLineItemSchedule__c csch = [Select id,SalesPrice__c from ContractLineItemSchedule__c limit 1];
        //System.assertEquals(csch.SalesPrice__c, ops1.TotalPrice__c , 'ContractLineItem was not updated');
        System.assertEquals(csch.SalesPrice__c, ops1.TotalPrice__c , 'ContractLineItem was not updated');
        Test.stopTest();
    }
}