//-----------------------------
// @author: Ankita Singh
// @date: 11 April 2018
// @param: NA
// @description: Test class for Docu Sign Recipient Status trigger methods 
// @return: NA
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 13 Nov 2019
// @Description: SFDC-2037 Cleaned up test class as per valid scenarios in DocusignRecipientStatus trigger code
//-----------------------------

@isTest
private class TestdsfsDocuSignRecipientStatusMethods{
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 13 Nov 2019
    // @param: NA
    // @description:SFDC-2037 Test coverage for updateContractAttachmentType() and createContractAttachmentFilesFromDocusignStatus() methods in dsfsDocuSignRecipientStatusMethods class. Testing by Continuation Letter contract.
    //-----------------------------
    @isTest
    private static void testDocusignFlowForContinuationLetter() {
        
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
        
        //creating docusign status and docusign Recipient status object record
        Test.startTest();
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Subject__c = 'Please sign the document';
        ds.dsfs__Sender__c = 'Sales';
        ds.dsfs__Contract__c = contract.id;
        ds.dsfs__Company__c = testAccount.id;
        ds.dsfs__DocuSign_Envelope_ID__c = 'B1F8E324-D40E-415B-8CCD-185EAF4DWXYZ';
        insert ds;
        
        Attachment testAtt = new Attachment();
        testAtt.Body = Blob.valueOf('This is test attachment');
        testAtt.Name = String.valueOf('TestContinuationAttachment.pdf');
        testAtt.ParentId = ds.Id;
        insert testAtt;
                
        dsfs__DocuSign_Recipient_Status__c drsCustomer = new dsfs__DocuSign_Recipient_Status__c();
        drsCustomer.dsfs__Parent_Status_Record__c = ds.id;
        drsCustomer.Name='Customer';
        drsCustomer.dsfs__DocuSign_Recipient_Email__c = 'test@yahoo.com';
        drsCustomer.dsfs__Recipient_Status__c = 'Sent';
        drsCustomer.dsfs__DocuSign_Recipient_Id__c = 'B1F8E324-D40E-415B-8CCD-185EAF4DWXYZ';
        drsCustomer.dsfs__Envelope_Id__c = ds.dsfs__DocuSign_Envelope_ID__c;
        insert drsCustomer;
        
        ContractAttachment__c sentConAttachment = [SELECT Id, AttachmentType__c FROM ContractAttachment__c WHERE DocuSignEnvelopeId__c=:ds.dsfs__DocuSign_Envelope_ID__c Limit 1];
        String sentContractAttachmentType = sentConAttachment.AttachmentType__c;
        System.assertEquals('Continuation Letter', sentContractAttachmentType, 'Verifying if the Sent Contract Attachment Type is populated correctly');
        
        List<ContentVersion> sentFiles = [Select Id From ContentVersion Where FirstPublishLocationId=:sentConAttachment.Id];
        System.assertEquals(1,sentFiles.size(), 'Verifying if the first file is attached successfully');
        
        //Simulate customer sign by updating dsfs__Recipient_Status__c to 'Completed'
        drsCustomer.dsfs__Recipient_Status__c = 'Completed';
        update drsCustomer;
        
        ContractAttachment__c signedConAttachment = [SELECT Id, AttachmentType__c FROM ContractAttachment__c WHERE DocuSignEnvelopeId__c=:ds.dsfs__DocuSign_Envelope_ID__c Limit 1];
        String signedContractAttachmentType = signedConAttachment.AttachmentType__c;
        System.assertEquals('Signed Continuation Letter', signedContractAttachmentType, 'Verifying if the Signed Contract Attachment Type is populated correctly');
        
        List<ContentVersion> sentAndSignedFiles = [Select Id From ContentVersion Where FirstPublishLocationId=:signedConAttachment.Id];
        System.assertEquals(2,sentAndSignedFiles.size(), 'Verifying if the second file is attached successfully');
        
        Test.stopTest();
    }
	
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 13 Nov 2019
    // @param: NA
    // @description:SFDC-2037 Test coverage for changeContractStatus() and createContractAttachmentFilesFromDocusignStatus() methods in dsfsDocuSignRecipientStatusMethods class. Testing by Order Form contract. 
    //-----------------------------
    @isTest
    private static void testChangeContractStatus() {
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
        
        //creating docusign status and docusign Recipient status object record
        Test.startTest();
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Subject__c = 'Please sign the document';
        ds.dsfs__Sender__c = 'Sales';
        ds.dsfs__Contract__c = contract.id;
        ds.dsfs__Company__c = testAccount.id;
        ds.dsfs__DocuSign_Envelope_ID__c = 'B1F8E324-D40E-415B-8CCD-185EAF4DABCD';
        insert ds;
        
        Attachment testAtt = new Attachment();
        testAtt.Body = Blob.valueOf('This is test OF attachment');
        testAtt.Name = String.valueOf('TestOrderFormAttachment.pdf');
        testAtt.ParentId = ds.Id;
        insert testAtt;
        
        dsfs__DocuSign_Recipient_Status__c drsCustomer = new dsfs__DocuSign_Recipient_Status__c();
        drsCustomer.dsfs__Parent_Status_Record__c = ds.id;
        drsCustomer.Name='Customer';
        drsCustomer.dsfs__DocuSign_Recipient_Email__c = 'test@yahoo.com';
        drsCustomer.dsfs__Recipient_Status__c = 'Sent';
        drsCustomer.dsfs__DocuSign_Recipient_Id__c = 'B1F8E324-D40E-415B-8CCD-185EAF4DABCD';
        drsCustomer.dsfs__Envelope_Id__c = ds.dsfs__DocuSign_Envelope_ID__c;
        insert drsCustomer;
        
        String conStatus= [Select ContractStatus__c from contract where ID=: contract.id].ContractStatus__c;
        System.assertNotEquals('Signed By Customer', conStatus, 'Verifying if the Contract Status is not Signed By Customer');
        
        drsCustomer.dsfs__Recipient_Status__c = 'Completed';
        update drsCustomer;
        
        conStatus= [Select ContractStatus__c from contract where ID=: contract.id].ContractStatus__c;        
        System.assertEquals('Signed By Customer', conStatus, 'Verifying if the Contract Status is Signed By Customer');
        
        ContractAttachment__c conAttachmentOF = [SELECT Id, AttachmentType__c FROM ContractAttachment__c WHERE DocuSignEnvelopeId__c=:ds.dsfs__DocuSign_Envelope_ID__c Limit 1];        
        List<ContentVersion> signedFiles = [Select Id From ContentVersion Where FirstPublishLocationId=:conAttachmentOF.Id];
        System.assertEquals(1,signedFiles.size(), 'Verifying if the signed file is attached successfully');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 16 Sep 2020
    // @param: NA
    // @description:SFDC-3317 Test method to cover changeContractStatus() and createContractAttachmentFilesFromDocusignStatus() methods. 
    // 				This test method covers scenario where Contract Management sends the contract for internal signatures using Docusign portal independent of Salesforce. Once signed, the signed document should be attached under Contract Attachments.
    //-----------------------------
    @isTest
    private static void testExternalDocusignFlow() {
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
        
        //creating docusign status and docusign Recipient status object record
        Test.startTest();
        
        dsfs__DocuSign_Status__c ds = new dsfs__DocuSign_Status__c();
        ds.dsfs__Subject__c = 'Please sign the document';
        ds.dsfs__Sender__c = 'Sales';
        ds.dsfs__Contract__c = contract.id;
        ds.dsfs__Company__c = testAccount.id;
        ds.dsfs__DocuSign_Envelope_ID__c = 'B1F8E324-D40E-415B-8CCD-185ESFDC3317';
        insert ds;
        
        Attachment testAtt = new Attachment();
        testAtt.Body = Blob.valueOf('This is test OF attachment');
        testAtt.Name = String.valueOf('TestOrderFormAttachment.pdf');
        testAtt.ParentId = ds.Id;
        insert testAtt;
        
        dsfs__DocuSign_Recipient_Status__c drsCustomer = new dsfs__DocuSign_Recipient_Status__c();
        drsCustomer.dsfs__Parent_Status_Record__c = ds.id;
        drsCustomer.Name='Customer';
        drsCustomer.dsfs__DocuSign_Recipient_Email__c = 'test@ihsmarkit.com';
        drsCustomer.dsfs__Recipient_Status__c = 'Completed';
        drsCustomer.dsfs__DocuSign_Recipient_Id__c = 'B1F8E324-D40E-415B-8CCD-185ESFDC3317';
        drsCustomer.dsfs__Envelope_Id__c = ds.dsfs__DocuSign_Envelope_ID__c;
        insert drsCustomer;
                
        ContractAttachment__c conAttachmentOF = [SELECT Id, AttachmentType__c FROM ContractAttachment__c WHERE DocuSignEnvelopeId__c=:ds.dsfs__DocuSign_Envelope_ID__c Limit 1];        
        List<ContentVersion> signedFiles = [Select Id From ContentVersion Where FirstPublishLocationId=:conAttachmentOF.Id];
        System.assertEquals(1,signedFiles.size(), 'Verifying if the signed file is attached successfully');
        
        Test.stopTest();
    }
}