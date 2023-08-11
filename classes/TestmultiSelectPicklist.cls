//-----------------------------
// @author: Neelam Agrawal
// @date: 09 Mar 2022
// @param: NA
// @description: Test class for multiSelectPicklist class 
// @return: NA
//-----------------------------

@isTest(SeeAllData=false)
private class TestmultiSelectPicklist {
    //-----------------------------
	// @author: Neelam Agrawal
	// @date: 09 Mar 2022
	// @param: NA
	// @description: Test setup
    
    @testSetup static void setup() {
        User u1 = TestUtility.createAdminUser('adminuser@sfdc.test',true);
        User u2= TestUtility.createTestUser('IHSMarkit Customer Care','customercaretest@sfdc.test',true);
        User u3= TestUtility.createTestUser('Contract Manager','salescordinator@sfdc.test',true);
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
        testProd.ProductGroup__c=pg.Id;
        update testProd;
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
        
        ContractLineItem__c  cli= TestUtility.createContractLineItem('cli1',contract1.Id,testProd.Id,true);
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
    }
    
    //-----------------------------
	// @author: Neelam Agrawal
	// @date: 09 Mar 2022
	// @param: NA
	// @description: Test method for getProductGroup method
	// 
    static testmethod void testgetProductGroup(){
        test.startTest();
        Contract con= [Select Id from Contract Limit 1];
        List<String> productname = multiSelectPicklist.getProductGroup(con.Id);
        System.assertEquals(productname, new List<String>{'NRG'});
        test.stopTest();
    }
    
    //-----------------------------
	// @author: Neelam Agrawal
	// @date: 09 Mar 2022
	// @param: NA
	// @description: Test method for getProductGroupAlliance method
	// 
    static testmethod void testgetProductGroupAlliance(){
        test.startTest();
        ContractProductAlliancePartner__c conProductAlliance= [SELECT Id, ProductGroupText__c from ContractProductAlliancePartner__c Limit 1];
        List<String> ProductGroupName=multiSelectPicklist.getProductGroupAlliance(conProductAlliance.Id);
        System.assertEquals(ProductGroupName, new List<String>{conProductAlliance.ProductGroupText__c});
        List<String> ProductGroupName2=multiSelectPicklist.getProductGroupAll(conProductAlliance.Id);
        System.assertEquals(ProductGroupName2, new List<String>{'NRG'});    
        test.stopTest();
    }
    
    //-----------------------------
	// @author: Neelam Agrawal
	// @date: 09 Mar 2022
	// @param: NA
	// @description: Test method for getProfile method
	// 
    static testmethod void testgetProfile1(){
        test.startTest();
        User testUser1 = [SELECT Id,Username FROM User where username='customercaretest@sfdc.test'];
        System.runAs(testUser1) { 
        Boolean profiletype=multiSelectPicklist.getProfile();
        System.assertEquals(profiletype, true);
        }
        test.stopTest();
    }
    
    //-----------------------------
	// @author: Neelam Agrawal
	// @date: 09 Mar 2022
	// @param: NA
	// @description: Test method for getProfile method
	// 
    static testmethod void testgetProfile2() {              
		test.startTest();
        User testUser2 = [SELECT Id,Username FROM User where Email='adminuser@sfdc.test'];
        system.debug('testUser2' + testUser2);
        System.runAs(testUser2) { 
        Boolean profiletype=multiSelectPicklist.getProfile();
        System.assertEquals(profiletype, true);
        }
        test.stopTest();  
    }
    
    //-----------------------------
	// @author: Neelam Agrawal
	// @date: 09 Mar 2022
	// @param: NA
	// @description: Test method for getProfile method
	// 
    static testmethod void testgetProfile3() {      
        test.startTest();
        User testUser3 = [SELECT Id,Username FROM User where username='salescordinator@sfdc.test'];
        System.runAs(testUser3) { 
        Boolean profiletype=multiSelectPicklist.getProfile();
        System.assertEquals(profiletype, false);
        }
        test.stopTest();  
    }
}