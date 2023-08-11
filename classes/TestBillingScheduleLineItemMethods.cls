//-----------------------------
    // @author: Mohit Modi
    // @date: 16 April 2018
    // @description: SFDC1-7472 : Test method for BillingScheduleLineItemMethods Class
    // @return: None
    //------------------------------
@isTest
private class TestBillingScheduleLineItemMethods {
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 16 April 2018
    // @description: SFDC1-7472 : Test method for CreateCloneBillingScheduleLIFromCLIandPreventBSLICreation
    // @return: None
    //------------------------------
    @isTest
    static void testCreateCloneBillingScheduleLIFromCLIandPreventBSLICreation() {
    
        
        test.startTest();
        
        ContractLineItem__c  testCLI = [Select ID, BillingPeriods__c,BillingScheduleType__c, CurrencyIsoCode FROM ContractLineItem__c limit 1];
        // Creating the BSLI record with IsCreatedfromQuickAction__c = true as equal to be created by Quick Action
        BillingScheduleLineItem__c testBSLI = new BillingScheduleLineItem__c (CurrencyIsoCode = testCLI.CurrencyIsoCode,IsCreatedfromQuickAction__c = true,AUMBPS__c = 'test',AUMValue__c = 'test',Quantity__c = 4,ContractLineItem__c = testCLI.id,BillingStartDate__c = System.Today());
        insert testBSLI ;
        
        // Checking that the remaing BSLI record has to be created equal to CLI's Billing Period
        integer bSLIcreated = [select count() from BillingScheduleLineItem__c where ContractLineItem__c = : testCLI.id ];
        System.assertEquals(BSLIcreated ,testCLI.BillingPeriods__c,'Verify Billing period');
        
        // Updating Billing Period on CLI
        testCLI.BillingScheduleType__c = 'Quarterly';
        testCLI.BillingPeriods__c = 5;
        update testCLI;
        
        BillingScheduleLineItem__c testBSLI1 = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,AUMBPS__c = 'test',AUMValue__c = 'test',Quantity__c = 4,ContractLineItem__c = testCLI.id,BillingStartDate__c = System.Today().addMonths(10));
        insert testBSLI1 ;
        
        // Checking that the remaing BSLI record has to be created equal to CLI's Billing Period
        BSLIcreated = [select count() from BillingScheduleLineItem__c where ContractLineItem__c = : testCLI.id ];
        System.assertEquals(BSLIcreated ,testCLI.BillingPeriods__c,'Verify Billing period');
        
        // Updating Billing Period on CLI
        testCLI.BillingScheduleType__c = 'Semi-annual';
        testCLI.BillingPeriods__c = 6;
        update testCLI;
        
        BillingScheduleLineItem__c testBSLI2 = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,AUMBPS__c = 'test',AUMValue__c = 'test',Quantity__c = 4,ContractLineItem__c = testCLI.id,BillingStartDate__c = System.Today().addMonths(20));
        insert testBSLI2 ;
        
        // Checking that the remaing BSLI record has to be created equal to CLI's Billing Period
        BSLIcreated = [select count() from BillingScheduleLineItem__c where ContractLineItem__c = : testCLI.id ];
        System.assertEquals(BSLIcreated ,testCLI.BillingPeriods__c,'Verify Billing period');
        
        //Reducing the Billing Period on CLI
        testCLI.BillingPeriods__c = 1;
        update testCLI;
        
        try {
             //Trying to insert new BSLI using Quick action after reducing the CLI Billing Period, Error Should be thrown.
             BillingScheduleLineItem__c testBSLI3 = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,AUMBPS__c = 'test',AUMValue__c = 'test',Quantity__c = 4,ContractLineItem__c = testCLI.id);
             insert testBSLI3 ;
        } catch (exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.BSLIErrorOnQuickActionOnCLI) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Verify Billing period');
        }
    }
    
    //-----------------------------
    // @Author: Sruti Srivastava
    // @Date: 4 Sept 2018
    // @description: SFDC1-9599 : Test method for rollupValuesToContractLineItem
    // @return: None
    //------------------------------
    @isTest
    static void testRollupValuesToContractLineItemOnInsert() {    
        ContractLineItem__c testCLI = [Select Id,CurrencyIsoCode FROM ContractLineItem__c limit 1];
        
        //Creating the BSLI record, 4 BillingScheduleLineItem are created based on BillingPeriods on Contract Line item
        BillingScheduleLineItem__c testBSLI = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,
                                                                              AUMBPS__c = 'test',AUMValue__c = 'test',
                                                                              Quantity__c = 1,ContractLineItem__c = testCLI.id,CurrencyIsoCode = testCLI.CurrencyIsoCode,
                                                                             TotalUpdated__c = 90);
        test.startTest();
        insert testBSLI;
        // Checking if BillingScheduleTotal on ContractLineItem got rolled up correctly
        ContractLineItem__c objCLIUpdated = [select BillingScheduleTotal__c from ContractLineItem__c limit 1 ];
        system.assertEquals(objCLIUpdated.BillingScheduleTotal__c, 360,'Verify Billing schedule total');
        test.stopTest();
        
    }
    
    //-----------------------------
    // @Author: Sruti Srivastava
    // @Date: 4 Sept 2018
    // @description: SFDC1-9599 : Test method for rollupValuesToContractLineItem when records are updated
    // @return: None
    //------------------------------
    @isTest
    static void testRollupValuesToContractLineItemOnUpdate() {
        ContractLineItem__c testCLI = [Select Id,CurrencyIsoCode,Contract__r.CurrencyIsoCode,Contract__r.Currency__c FROM ContractLineItem__c limit 1];      
        //Creating the BSLI record, 4 BillingScheduleLineItem are created based on BillingPeriods on Contract Line item
        BillingScheduleLineItem__c testBSLI = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,
                                                                              AUMBPS__c = 'test',AUMValue__c = 'test',
                                                                              Quantity__c = 1,ContractLineItem__c = testCLI.id,CurrencyIsoCode = testCLI.CurrencyIsoCode,
                                                                             TotalUpdated__c = 90);
        
        insert testBSLI;
        
        // Checking if BillingScheduleTotal on ContractLineItem got rolled up correctly on insert
        ContractLineItem__c objCLIUpdated = [select BillingScheduleTotal__c from ContractLineItem__c limit 1 ];
        system.assertEquals(objCLIUpdated.BillingScheduleTotal__c, 360,'Verify Billing schedule total');
        
        test.startTest();
        
        testBSLI.TotalUpdated__c = 50;
        update testBSLI;
        
        test.stopTest();
        // Checking if BillingScheduleTotal on ContractLineItem got rolled up correctly on update
        ContractLineItem__c objCLIUpdated2 = [select BillingScheduleTotal__c from ContractLineItem__c limit 1 ];
        system.assertEquals(objCLIUpdated2.BillingScheduleTotal__c, 320,'Verify Billing schedule total');
    }

    //-----------------------------
    // @Author: Sruti Srivastava
    // @Date: 4 Sept 2018
    // @description: SFDC1-9599 : Test method for rollupValuesToContractLineItem which is caled 
    // @return: None
    //------------------------------
    @isTest
    static void testRollupValuesToContractLineItemOnDelete() {
        ContractLineItem__c testCLI = [Select Id, CurrencyIsoCode FROM ContractLineItem__c limit 1];
        //Creating the BSLI record, 4 BillingScheduleLineItem are created based on BillingPeriods on Contract Line item
        BillingScheduleLineItem__c testBSLI = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,
                                                                              AUMBPS__c = 'test',AUMValue__c = 'test',
                                                                              Quantity__c = 1,ContractLineItem__c = testCLI.id,CurrencyIsoCode = testCLI.CurrencyIsoCode,
                                                                             TotalUpdated__c = 90);
        
        insert testBSLI;
        
        // Checking if BillingScheduleTotal on ContractLineItem got rolled up correctly on insert
        ContractLineItem__c objCLIUpdated = [select BillingScheduleTotal__c from ContractLineItem__c limit 1 ];
        system.assertEquals(objCLIUpdated.BillingScheduleTotal__c, 360,'Verify Billing schedule total');
        
        test.startTest();
        // all records are deleted
        delete [select Id From BillingScheduleLineItem__c];
        
        test.stopTest();
        // Checking if BillingScheduleTotal on ContractLineItem showing correct value on delete
        ContractLineItem__c objCLIUpdated2 = [select BillingScheduleTotal__c from ContractLineItem__c limit 1 ];
        system.assertEquals(objCLIUpdated2.BillingScheduleTotal__c, 0,'Verify Billing schedule total');
    }
    
     //-----------------------------
    // @Author: Sruti Srivastava
    // @Date: 4 Sept 2018
    // @description: SFDC1-9599 : Testsetup method for creating test data for rollupValuesToContractLineItem which is caled 
    // @return: None
    //------------------------------
    @testSetup static void createTestData() {
        Account a = TestUtility.createTestAccount('Account testrollpu', true);
        Contact c = TestUtility.createContact(a.Id,'1testing@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        
        Opportunity testOpportunity1 = TestUtility.createOpportunity(a.Id, 'test Opppy', false);
        testOpportunity1.CurrencyIsoCode = 'USD';
        insert testOpportunity1;
        
        /*OpportunityContactRole oppContactRole1 = new OpportunityContactRole ();
        oppContactRole1.OpportunityId = testOpportunity1.id;
        oppContactRole1.ContactId = c.id;
        oppContactRole1.IsPrimary = true;        
        insert new List<OpportunityContactRole> {oppContactRole,oppContactRole1};			
		*/
        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id trailRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,false);
        contract1.Opportunity__c = testOpportunity1.Id;
        insert contract1;
        
        // Creating the CLI record
        ContractLineItem__c  testCLI = TestUtility.createContractLineItem('TestCLI',contract1.id,testProd.id,false);
        testCLI.BillingPeriods__c = 4;
        testCLI.BillingScheduleType__c = 'Monthly';
        insert testCLI;
        
    }
}