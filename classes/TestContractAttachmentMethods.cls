//-----------------------------
// @author: Ankita Singh
// @date: 19 June 2018
// @param: NA
// @description: Test class for ContractAttachment trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestContractAttachmentMethods {
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 18 June 2018
    // @param: NA
    // @description: SFDC1-8559.Test method for ContactAttachment trigger methods updateFieldOnContract on insert and delete
    // @return: NA
    //-----------------------------
    /*
	@isTest
    private static void testupdateFieldOnContract() {
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id OFRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract.recordtypeid = OFRecordTypeId;
        contract.POAttached__c = 'No';
        contract.Fastrack__c = true;
        insert contract;
        //Creating ContractAttachment
        Test.startTest();
        ContractAttachment__c ca = new ContractAttachment__c();
        ca.Name = 'Contract Attachment PO 1';
        ca.Contract__c = contract.id;
        ca.AttachmentType__c = 'Purchase Order';
        insert ca;
        // Assert output
        String c1 = [Select POAttached__c from contract where id=:contract.id][0].POAttached__c;
        system.assertEquals('Yes', c1);
        // deleting Contract Attachment 
        delete ca;
        // Assert Output
        String c2 = [Select POAttached__c from contract where id=:contract.id][0].POAttached__c;
        system.assertEquals('No', c2);
        Test.stopTest();
    }*/
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 08 November 2019
    // @param: NA
    // @description: SFDC1-2037.Test method for ContactAttachment trigger methods setRecordTypeFromContract on insert 
    // @return: NA
    //-----------------------------
	@isTest
    private static void testSetRecordTypeFromContract() {
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id OFRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract.recordtypeid = OFRecordTypeId;
        contract.POAttached__c = 'No';
        contract.Fastrack__c = true;
        insert contract;
        
        //Creating ContractAttachment
        Test.startTest();
        ContractAttachment__c ca = new ContractAttachment__c();
        ca.Name = 'Contract Attachment PO 1';
        ca.Contract__c = contract.id;
        ca.AttachmentType__c = 'Purchase Order';
        insert ca;
        Test.stopTest();
        
        List<ContractAttachment__c> ListCA = [select name, recordType.name from contractAttachment__c where id = :ca.id];
        system.assertEquals('Order Form', ListCA[0].recordType.name, 'Record type should be Order Form');
    }
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 08 November 2019
    // @param: NA
    // @description: SFDC1-2037.Test method for ContactAttachment trigger methods updateContinuationContracts (Signed By Customer) on insert. 
    // @return: NA
    //-----------------------------
	@isTest
    private static void testupdateContinuationContractsForSigned() {
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id CLRecordTypeId = ContractMethods.continuationLetterRecordTypeId;
        //LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity', 'USD', true, 'No', 'No', 'No', 'Yes', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract.recordtypeid = CLRecordTypeId;
        contract.POAttached__c = 'No';
        contract.Fastrack__c = true;
        insert contract;
        
        ContractAttachment__c ca = new ContractAttachment__c();
        ca.Name = 'Contract Attachment PO 1';
        ca.Contract__c = contract.id;
        ca.AttachmentType__c = 'Purchase Order';
        insert ca;
        //Creating ContractAttachment
        Test.startTest();
			ca.AttachmentType__c = 'Signed Continuation Letter';
        	update ca;
        Test.stopTest();
        
        List<ContractAttachment__c> ListCA = [select name, contract__r.ContractStatus__c from contractAttachment__c where id = :ca.id];
        system.assertEquals('Signed By Customer', ListCA[0].contract__r.contractStatus__c,'Contract status should be Signed By Customer');
    }
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 08 November 2019
    // @param: NA
    // @description: SFDC1-2037.Test method for ContactAttachment trigger methods updateContinuationContracts (Sent to Customer) on insert. 
    // @return: NA
    //-----------------------------
	@isTest
    private static void testupdateContinuationContractsForSent() {
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id CLRecordTypeId = ContractMethods.continuationLetterRecordTypeId;
        //LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity', 'USD', true, 'No', 'No', 'No', 'Yes', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract.recordtypeid = CLRecordTypeId;
        contract.POAttached__c = 'No';
        contract.Fastrack__c = true;
        insert contract;
        
        ContractAttachment__c ca = new ContractAttachment__c();
        ca.Name = 'Contract Attachment PO 1';
        ca.Contract__c = contract.id;
        ca.AttachmentType__c = 'Purchase Order';
        insert ca;
        //Creating ContractAttachment
        Test.startTest();
			ca.AttachmentType__c = 'Continuation Letter';
        	update ca;
        Test.stopTest();
        
        List<ContractAttachment__c> ListCA = [select name, contract__r.ContractStatus__c from contractAttachment__c where id = :ca.id];
        system.assertEquals('Sent to Customer', ListCA[0].contract__r.contractStatus__c,'Contract status should be Sent to Customer');
    }
    //-----------------------------
    // @author: Sharique
    // @date: 12 Oct 2021
    // @param: NA
    // @description: SFDC-4568.Test method for ContactAttachment trigger methods deletionRestrictedWhenContractStage11 
    // @return: NA
    //-----------------------------
	@isTest
    private static void TestDeletionRestrictedWhenContractStage11() {
        
        Profile p = [SELECT Id ,name FROM Profile WHERE Name like '%Sales Coordinator%' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert u;
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id CLRecordTypeId = ContractMethods.continuationLetterRecordTypeId;
        //LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity', 'USD', true, 'No', 'No', 'No', 'Yes', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        
        Test.startTest();
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract.recordtypeid = CLRecordTypeId;
        contract.POAttached__c = 'No';
        contract.Fastrack__c = true;
        insert contract;
        Test.stopTest();
         ContractAttachment__c ca = new ContractAttachment__c();
        System.runAs(u) {
         System.debug('$$$ userid--'+UserInfo.getUserId());
         System.debug('$$$ userName--'+UserInfo.getName()); 
       
        ca.Name = 'Contract Attachment PO 1';
        ca.Contract__c = contract.id;
        ca.AttachmentType__c = 'Purchase Order';
        insert ca;
             ContractAttachment__c caa= [select id,createdbyid,createdby.name from ContractAttachment__c limit 1];
             system.debug('$$$ ca---'+caa.createdby.name);
         
        try {
            delete ca;
           }
           catch (exception ex) {
                  Boolean errorexist = ex.getmessage().contains(System.Label.ContractAttachmentRestrictionError) ? true : false;
                  System.assertEquals(errorexist ,true, ex.getMessage());
              }
            
        }
        
     }
       //-----------------------------
    // @author: Sharique
    // @date: 12 Oct 2021
    // @param: NA
    // @description: SFDC-4568.Test method for ContactAttachment trigger methods updateRestrictionOnContractStage11 
    // @return: NA
    //-----------------------------
	@isTest
    private static void TestupdateRestrictionOnContractStage11() {
        
        Profile p = [SELECT Id ,name FROM Profile WHERE Name like '%Sales Coordinator%' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert u;
        
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id CLRecordTypeId = ContractMethods.continuationLetterRecordTypeId;
        //LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity', 'USD', true, 'No', 'No', 'No', 'Yes', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        
        Test.startTest();
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract.recordtypeid = CLRecordTypeId;
        contract.POAttached__c = 'No';
        contract.Fastrack__c = true;
        insert contract;
        Test.stopTest();
         ContractAttachment__c ca = new ContractAttachment__c();
        System.runAs(u) {
            ca.Name = 'Contract Attachment PO 1';
            ca.Contract__c = contract.id;
            ca.AttachmentType__c = 'Purchase Order';
            insert ca;
         
            try {
                delete ca;
            }
            catch (exception ex) {
                Boolean errorexist = ex.getmessage().contains(System.Label.ContractAttachmentRestrictionError) ? true : false;
                System.assertEquals(errorexist ,true, ex.getMessage());
            }
            
        }
        
     }
}