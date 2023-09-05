@isTest
private class TestContractLineItemMethods {
    
    @isTest
    private static void testRollupProductInfoToContract() {
        
        TestBatchUpdateRollUpFieldOnParent.createTestCustomRollUpCustomSettings();
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount ;
        
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', true);
        
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = testContact.Id;
        ocr.OpportunityId = testOpportunity.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        Test.startTest();
        ProductGroup__C pg1 = new ProductGroup__C(name = 'Test PG1');
        insert pg1;
         
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.ProductGroup__c = pg1.Id;
        testProd.AAG__c = 'Subscription';
        
        insert testProd;
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id ofContractRecId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        List<Contract> ctList = [Select ProductGroup__c,AAG__c FROM Contract WHERE Id =:ofContractRecId];
        System.assertEquals('Test PG1', ctList.get(0).ProductGroup__c);
        List<ContractLineItem__c> cliList = [Select Id FROM ContractLineItem__c WHERE Contract__c =: ofContractRecId];
        delete cliList;
        Test.stopTest();
     }
	
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 06 Oct 2020
    // @description: SFDC-3403: Test method for lockCLIForCompletedContracts() method
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testLockCLIForCompletedContracts() {                        
        //Create Sales User
        Profile testSalesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%Sales: General%' limit 1];        
        User testSalesUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = testSalesProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihsihs.com',ADID__c='adIdtest'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*123456)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*1324567)));
        insert testSalesUser;
        //Create Account
        Account testAcc = TestUtility.createTestAccount('Test 3403 Account', false);
        testAcc.DataGovernanceStatus__c = 'Approved';
        insert testAcc;
        //Create contact
        Contact testContact = TestUtility.createContact(testAcc.Id,'con1@externalorg.com',true,'Contact1','Test 3403 Account');
        //Create product and pricebook entry
        Product2 p1 = TestUtility.createProduct('Test SubProduct 1', true);
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        pbe1.CurrencyIsoCode = 'USD';
        insert pbe1;
        //Create opprtunity
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Opportunity testOpportunity = TestUtility.createOpportunity(testAcc.Id, '3403 NewBiz Opp1', false);
		testOpportunity.ContractStartDate__c = date.newinstance(currentFY, 03, 20);
		testOpportunity.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpportunity.OwnerId = testSalesUser.Id;
        testOpportunity.ActivityCreated__c = true;
        insert testOpportunity;        
        //Create opportunity line item
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, pbe1, true);
        //Create primary opportunity contact
        OpportunityContactRole primaryOCR = new OpportunityContactRole(OpportunityId=testOpportunity.Id,ContactId=testContact.Id,IsPrimary=true);
        insert primaryOCR;
                
        Test.startTest();
        Id orderFormRecordTypeId =  Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        //Create contract
        Id contractOrderformRecId =  ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        
        //Mark Contract as complete
        Contract testContract = new Contract(Id=contractOrderformRecId);
        TestUtility.createContractAttachment(testContract.id);        
        TestUtility.markContractAsComplete(testContract, true);
        
        //Query CLI
        ContractLineItem__c testCLI = [SELECT Id,Name,Contract__r.Status FROM ContractLineItem__c WHERE Contract__c=:testContract.Id LIMIT 1];
        
        UtilityClass.LoggedInUserProfileName = null;
        System.runAs(testSalesUser) {
            try {
                //Update a non-calculated field on CLI as Sales General user
                testCLI.InvoiceRemarks__c = 'test';
                update testCLI;
                System.assert(false,'Control should not reach here. CLI Lock validation exception not thrown.');
            }
            catch(DMLException ex) {
                System.assertEquals('Contract Line Items are locked for editing after stage is completed',ex.getDmlMessage(0),'Contract Line Items locked validation exception should have occurred.');
            }            
        }
        Test.stopTest();
     }
    //-----------------------------
    // @author: Digvijay Singh
    // @date: 3 May 2021
    // @description: SFDC-4069: Test method for preventContractLineItemDeletion() method
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testCLIDeletion() {
        //Create Sales User
       Profile testSalesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%Sales: General%' limit 1];        
       User testSalesUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
           EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = testSalesProfile.Id, 
           TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihsihs.com',ADID__c='adIdtest'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*123456)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*1324567)));
       insert testSalesUser;
       
      
       //Create Account
       Account testAcc = TestUtility.createTestAccount('Test 3403 Account', false);
       testAcc.DataGovernanceStatus__c = 'Approved';
       insert testAcc;
       //Create contact
       Contact testContact = TestUtility.createContact(testAcc.Id,'con1@externalorg.com',true,'Contact1','Test 3403 Account');
       //Create product and pricebook entry
       Product2 p1 = TestUtility.createProduct('Test SubProduct 1', true);
       Id stdPricebookId = Test.getStandardPricebookId();
       PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
       pbe1.CurrencyIsoCode = 'USD';
       insert pbe1;
       //Create opprtunity
       Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
       Opportunity testOpportunity = TestUtility.createOpportunity(testAcc.Id, '3403 NewBiz Opp1', false);
       testOpportunity.ContractStartDate__c = date.newinstance(currentFY, 03, 20);
       testOpportunity.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
       testOpportunity.OwnerId = testSalesUser.Id;
       testOpportunity.ActivityCreated__c = true;
       insert testOpportunity;        
       //Create opportunity line item
       OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, pbe1, true);
       //Create primary opportunity contact
       OpportunityContactRole primaryOCR = new OpportunityContactRole(OpportunityId=testOpportunity.Id,ContactId=testContact.Id,IsPrimary=true);
       insert primaryOCR;
               
       Test.startTest();
       Id orderFormRecordTypeId =  Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
       //Create contract
       Id contractOrderformRecId =  ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
       
       //Mark Contract as complete
       Contract testContract = new Contract(Id=contractOrderformRecId);
       TestUtility.createContractAttachment(testContract.id);  
       TestUtility.markContractAsComplete(testContract, true);
       
       //Query CLI
       ContractLineItem__c testCLI = [SELECT Id,Name,Contract__r.Status FROM ContractLineItem__c WHERE Contract__c=:testContract.Id LIMIT 1];
       
       UtilityClass.LoggedInUserProfileName = null;
       System.runAs(testSalesUser) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: System.Label.ContractLineItemEditAccessPermissionSet];
        insert new PermissionSetAssignment(AssigneeId = testSalesUser.id, PermissionSetId = ps.Id);
        
           try {
               //Update a non-calculated field on CLI as Sales General user
               delete  testCLI;
           }
           catch(DMLException ex) {
               System.assertEquals('You are not authorized to Delete a Contract Line Item.',ex.getDmlMessage(0));
           }            
       }
       Test.stopTest();
    }
}