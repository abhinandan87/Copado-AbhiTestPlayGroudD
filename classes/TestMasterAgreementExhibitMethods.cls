/**
* @author Paras Dhingra
* @date 20th Jan 2020
* @description: SFDC-2198 test class for MasterAgreementExhibitMethods
*/
@istest
public class TestMasterAgreementExhibitMethods {
    /**
    * @author Paras Dhingra
    * @date 22nd Jan 2020
    * @description: SFDC-2198 Test setup to create test data for testclass
	*/
    @testSetup 
    static void insertCommonCodeForCreatingContract() {
        Test.startTest();
        Account acc = TestUtility.createTestAccount('Account test', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;
        Contact testContact = TestUtility.createContact(acc.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id, IsPrimary=true);
        insert ocr;

        List<LoadingGroup__c> lgList = new List<LoadingGroup__c> ();
        lgList.add(TestUtility.createLoadingGroup('IHS', 'IHS Lg1', false));
        lgList.add(TestUtility.createLoadingGroup('IHS', 'IHS Lg2', false));
        lgList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg3', false));
        lgList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg4', false));
        lgList.add(TestUtility.createLoadingGroup('Calgary', 'Calgary Lg1', false)); 
        insert lgList;
        
        Id standardId = Test.getStandardPricebookId();
        List<Product2> productList = new List<Product2>();
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product1', lgList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product2', lgList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product3', lgList.get(1).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product4', lgList.get(2).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product5', lgList.get(2).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product6', lgList.get(3).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product7', lgList.get(4).id, false)); 
        insert productList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(0).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(1).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(2).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(3).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(4).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(5).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(6).id, false)); 
        insert pbeList;

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(0), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(1), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(2), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(3), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(4), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(5), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(6), false));
        insert oliList;
        Test.stopTest();
    }
    /**
    * @author Paras Dhingra
    * @date 22nd Jan 2020
    * @description: SFDC-2198 test method to verify the validation added in the code
	*/
    @isTest
    static void testvalidateMAERecords() {
        Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Id masterAgreementExhibitRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement Exhibit').getRecordTypeId();
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id OrderFormId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementRecordTypeId, testOpportunity.Id);
		Id maeRecordId1 = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementExhibitRecordTypeId, testOpportunity.Id);
        Id maeRecordId2 = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementExhibitRecordTypeId, testOpportunity.Id);
        Id maeRecordId3 = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementExhibitRecordTypeId, testOpportunity.Id);
        Id maeRecordId4 = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementExhibitRecordTypeId, testOpportunity.Id);
        
        Set<Id> setMAEIds = new Set<Id>{maeRecordId1,maeRecordId2,maeRecordId3,maeRecordId4};
        Contract testOrderFormcontract = [Select Id, GeneralAgreement__c from Contract where Id=:OrderFormId limit 1];
        testOrderFormcontract.GeneralAgreement__c =contractRecId ;
        update testOrderFormcontract;
        List<Contract> testupdateContracts = [Select Id, ExhibitType__c from contract where Id IN:setMAEIds];
        testupdateContracts[0].ExhibitType__c = 'Data';
        testupdateContracts[0].GeneralAgreement__c = contractRecId;
        testupdateContracts[1].ExhibitType__c = 'Data';
        testupdateContracts[1].GeneralAgreement__c = contractRecId;
        testupdateContracts[2].ExhibitType__c = 'Software';
        testupdateContracts[2].GeneralAgreement__c = contractRecId;
        testupdateContracts[3].ExhibitType__c = 'Software';
        testupdateContracts[3].GeneralAgreement__c = contractRecId;
        testupdateContracts.add(testOrderFormcontract);
        update testupdateContracts;
        Test.startTest();
		//insert the Master agreement exhibits
		MasterAgreementExhibit__c mae1 = new MasterAgreementExhibit__c(OrderFormOrConsulting__c=OrderFormId, MasterAgreementExhibit__c=maeRecordId1);
        insert mae1;
        MasterAgreementExhibit__c mae2 = new MasterAgreementExhibit__c(OrderFormOrConsulting__c=OrderFormId, MasterAgreementExhibit__c=maeRecordId2);
        try { 
            insert mae2;
        } catch(DMLException ex) {
           System.assertEquals('An exhibit of type Data already attached to this Contract', ex.getDmlMessage(0), 'DML Exception is occured') ;
        }
        
        try {
            mae1.MasterAgreementExhibit__c = maeRecordId2;
            update mae1;
            insert mae2;
        } catch(DMLException ex) {
           System.assertEquals('An exhibit of type Data already attached to this Contract', ex.getDmlMessage(0), 'DML Exception is occured') ;
        }
        MasterAgreementExhibit__c mae3 = [Select Id, Name, OrderFormOrConsulting__c, MasterAgreementExhibit__c  from MasterAgreementExhibit__c order by CreatedDate desc limit 1];
        mae3.MasterAgreementExhibit__c = maeRecordId3;
        update mae3;
		MasterAgreementExhibit__c mae4 = new MasterAgreementExhibit__c(OrderFormOrConsulting__c=OrderFormId, MasterAgreementExhibit__c=maeRecordId1);
        MasterAgreementExhibitDispatcher.isBeforeInsertProcessing = true;
        insert mae4;
        MasterAgreementExhibitDispatcher.isBeforeUpdateProcessing = true;
        update mae4;
        Test.stopTest();
    }

}