//-----------------------------
// @author: Harshit Singhal
// @date: 18 Oct 2019
// @param: NA
// @description: SFDC-2007 Test Class for OrderFormData class
// @return: NA
//----------------------------
@isTest
private class TestOrderFormData {
    @testSetup
    static void createTestData() {
        //Create Account
        Account testAccount = TestUtility.createTestAccount('Account TestBatchCurrentAnnualValue', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
		//Create Contact        
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',true, 'Test', 'Contact');
        
        //Create Opportunity
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',true);
        
        //Create Opportunity Contact Role
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOppy.Id, ContactId = testContact.Id, IsPrimary=false);
        insert ocr;
        
        //Create Products
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.AAG__c='Subscription';
        p1.DiscountThreshold__c = 10;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        p1.AAG__c='Consulting';
        insert new List<Product2>{p1,p2};
        
        //Create Terms And Conditions
        TermsConditions__c testTnc1 = TestUtility.createTermsNCondition('Test Tnc 1 - Text',false);
        TermsConditions__c testTnc2 = TestUtility.createTermsNCondition('Test Tnc 2 - Text',false);
        insert new List<TermsConditions__c>{testTnc1, testTnc2};
        
        //Create Product Specific Terms And Conditions
        ProductswithTermsConditions__c ptnc1 = TestUtility.createProductTnC(p1.Id, testTnc1.Id, false);
        ProductswithTermsConditions__c ptnc2 = TestUtility.createProductTnC(p1.Id, testTnc2.Id, false);
        ProductswithTermsConditions__c ptnc3 = TestUtility.createProductTnC(p2.Id, testTnc1.Id, false);
        insert new List<ProductswithTermsConditions__c>{ptnc1, ptnc2, ptnc3};
            
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        insert new List<PricebookEntry>{pbe1,pbe2};
            
        //Create OLIs
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        OpportunityLineItem oli2 = TestUtility.createOpportunityLineItem(testOppy.id, pbe2,false);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oli1,oli2};
        insert new List<OpportunityLineItem>{oli1,oli2};
            
        //Create mapping custom setting records for - Opp Product to Contract Line Item setting
        List<OpportunityToContractLineItemMapping__c> oppProdToContractLineItemMapping = new List<OpportunityToContractLineItemMapping__c>();
        //oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='',OpportunityLineItemField__c='',ContractLineItemField__c=''));
        
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='Status',OpportunityLineItemField__c='Status__c',ContractLineItemField__c='Status__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='Discount',OpportunityLineItemField__c='DiscountPercentage__c',ContractLineItemField__c='Discount__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='DiscountType',OpportunityLineItemField__c='DiscountType__c',ContractLineItemField__c='DiscountType__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='OppProductId',OpportunityLineItemField__c='Id',ContractLineItemField__c='OpportunityProductId__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='Quantity',OpportunityLineItemField__c='Quantity',ContractLineItemField__c='Quantity__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='MaterialCode',OpportunityLineItemField__c='MaterialCode__c',ContractLineItemField__c='MaterialCode__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='UpdatedListPrice',OpportunityLineItemField__c='UnitListPrice__c',ContractLineItemField__c='UnitListPriceNew__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='ContractStartDate',OpportunityLineItemField__c='ContractStartDate__c',ContractLineItemField__c='StartDate__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='ContractEndDate',OpportunityLineItemField__c='ContractEndDate__c',ContractLineItemField__c='EndDate__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='TotalPrice',OpportunityLineItemField__c='TotalPrice',ContractLineItemField__c='TotalPriceFromOpportunityLineItem__c'));
               
        insert oppProdToContractLineItemMapping;
    }
    
    @isTest
    static void createOFContractRunOrderFormDataClass() {
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractRecId;
        Test.startTest();
        //Query Opportunity
        List<Opportunity> testOppList = [Select Id From Opportunity WHERE Name ='Test Opportunity 1'];
        for(Opportunity testOpp:testOppList) {
            //Create Order Form Contract
            orderFormContractRecId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpp.Id);            
        }
        //Setup docgen related parameters
        OrderFormData ofmydApexObj = new OrderFormData();
        Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
        requestInfo.RecordId = orderFormContractRecId;
        
        Set<String> gd = ofmydApexObj.getGlobalDescribe();
        System.debug('gd='+gd);
		System.assertEquals(1, gd.size());
        ofmydApexObj.describeObjects(new List<String>(gd));
        
        List<Loop.ExternalData.Relationship> relationships = new List<Loop.ExternalData.Relationship>();
        for(String str: gd) {
            Loop.ExternalData.Relationship relationship = new Loop.ExternalData.Relationship();
            relationship.Name = str;
            relationships.add(relationship);
        }
        requestInfo.Relationships = relationships;        
               
        Loop.ExternalData.QueryResultSet queryRS = ofmydApexObj.query(requestInfo);
        System.debug('queryRS.results='+queryRS.results);
        System.debug('queryRS.results.size()='+queryRS.results.size());
        System.assert(queryRS.results.size()>0);

        Test.stopTest();
    }

}