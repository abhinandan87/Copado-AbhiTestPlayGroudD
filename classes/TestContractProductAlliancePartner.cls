//-----------------------------
// @author: Akshay Dogra
// @date: 20 Sept 2021
// @param: NA
// @description: Test class for Contract Product Alliance Partner trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestContractProductAlliancePartner {
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 20 Sept 2021
    // @param: None
    // @description: SFDC-4235 test class for ContractProductAlliancePartnerMethods.restrictDuplicateRecord
    //------------------------------
    private static testMethod void testrestrictDuplicateRecord() {
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        a.Type = 'Global Alliance - Core';
        a.DataGovernanceStatus__c = 'Approved';
        insert a;
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        Contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        insert contract1;
        
        ContractProductAlliancePartner__c cpap = new ContractProductAlliancePartner__c();
        cpap.AlliancePartner__c = a.Id;
        cpap.ProductGroupText__c = pg.Id;
        cpap.Contract__c = contract1.Id;
        cpap.AlliancePartnerApprovalDate__c = System.today();
        insert cpap;
        
        ContractProductAlliancePartner__c cpap1 = new ContractProductAlliancePartner__c();
        cpap1.AlliancePartner__c = a.Id;
        cpap1.ProductGroupText__c = pg.Id;
        cpap1.Contract__c = contract1.Id;
        cpap1.AlliancePartnerApprovalDate__c = System.today();
        Test.startTest();
        try{
            insert cpap1;
            
        }
        catch (Exception e)
        {
            System.Assert(e.getMessage().contains(' A duplicate record for this alliance partner already exist. Please choose a different alliance partner or edit the already existing record. '));
        }
        Test.stopTest(); 
    }
    //-----------------------------
    // @author: Sathish Edla  
    // @date: 17 Mar 2022
    // @description: This method is used to improve the test code coverage of ContractProductAlliancePartnerDispatcher class.
    //-----------------------------
    @isTest static void testContractProductAlliancePartnerDispatcher(){
        ProductGroup__c objProductGroup = new ProductGroup__c();
        objProductGroup.Name = 'NRG';
        insert objProductGroup;
        
        Account objAccount = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        objAccount.Type = 'Global Alliance - Core';
        objAccount.DataGovernanceStatus__c = 'Approved';
        insert objAccount;
        
        Contact objContact = TestUtility.createContact(objAccount.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        Product2 objProduct = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();        
        PricebookEntry objPBE = TestUtility.createPriceBookEntry(standardId, objProduct.Id, true);  
        
        LegalEntity__c objLegalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c objCountry = lstCountry.get(0);
        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        test.startTest();
        Contract objContract = TestUtility.createContractWithInsertOptional(objAccount.Id, objLegalEntity.Id, objCountry.Id, standardId,FALSE);
        objContract.RecordTypeId = orderFormRecordTypeId;
        objContract.Fastrack__c = TRUE;
        objContract.Status = 'Creation';
        objContract.ContractStatus__c = 'Open';
        insert objContract;
        
        ContractProductAlliancePartner__c objCPAP1 = new ContractProductAlliancePartner__c();
        objCPAP1.AlliancePartner__c = objAccount.Id;
        objCPAP1.ProductGroupText__c = objProductGroup.Id;
        objCPAP1.Contract__c = objContract.Id;
        objCPAP1.AlliancePartnerApprovalDate__c = System.today();
        insert objCPAP1;
        update objCPAP1;
        
        ContractProductAlliancePartner__c objCPAP2 = new ContractProductAlliancePartner__c();
        objCPAP2.AlliancePartner__c = objAccount.Id;
        objCPAP2.ProductGroupText__c = objProductGroup.Id;
        objCPAP2.Contract__c = objContract.Id;
        objCPAP2.AlliancePartnerApprovalDate__c = System.today();
        ContractProductAlliancePartnerDispatcher.isBeforeInsertProcessing = true;
        insert objCPAP2;
        ContractProductAlliancePartnerDispatcher.isBeforeUpdateProcessing = true;
        update objCPAP2;
        List<ContractProductAlliancePartner__c> lstCPAP = [Select Id FROM ContractProductAlliancePartner__c];
        system.assertEquals(2, lstCPAP.size(), 'Verifying the count of created records');
        test.stopTest();        
    }
}