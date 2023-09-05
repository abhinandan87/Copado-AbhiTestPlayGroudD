/*  @author: Neha Gupta
*   @date: 20 Jan 2021
*   @description: SFDC-3096 Test class for ContractGenerateDocumentClass
*/
@isTest
public class TestContractGenerateDocumentClass {
    private static testMethod void testgetContract() {
        Account acc = TestUtility.createTestAccount('Account Test1', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() - 180;
        testOpportunity.ContractStartDate__c = System.today() - 180;
        testOpportunity.ContractEndDate__c = System.today() - 60;
        insert testOpportunity;
        System.assert(testOpportunity.id!=null,'To check if opportunity inserted correctly');
        
        Contact testContact = TestUtility.createContact(acc.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id, IsPrimary=true);
        insert ocr;
        
        List<LoadingGroup__c> lgList = new List<LoadingGroup__c> ();
        lgList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg4', false));
        insert lgList;
        
        Id standardId = Test.getStandardPricebookId();
        List<Product2> productList = new List<Product2>();
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product1', lgList.get(0).id, false));
        insert productList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(0).id, false));
        insert pbeList;
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(0), false));
        insert oliList;
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();        
        
        //Create test contract of Trial recordtype        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
        
        Contract contr= new Contract();
        contr.AccountId=acc.id;
        contr.Opportunity__c=testOpportunity.id;
        insert contr;
        System.assert(contr.id!=null,'To check if contract is inserted');
        ContractGenerateDocumentClass.getContractInfo(contr.id);
    }
    
}