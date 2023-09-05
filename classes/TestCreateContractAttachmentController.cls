/**
* @author Uttam Arya
* @date: 18th Sep 2017 
* @description : SFDC1-2392 Test Controller class for Contract Attachment Aura Component
* @company : IHS Markit
* @Last Modified By : Mohit Modi
* @Last Modified Description : SFDC1-5803 - updated Test Method for 'findRecordTypes' as related Class has been updated.
* @Last Modified Date : 23-Nov-2017
*/
@isTest
public class TestCreateContractAttachmentController {
    
    @isTest
    static void testConntroller() {
        Id trialRecordTypeId;
        Id contractRecId;
        
        Test.startTest();
        trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
        contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
        
        String str = ContractRecordTypeSelectionController.findRecordTypes('Contract',testOpportunity.Id);
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);        
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        update testOpportunity;
        contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
        
        CreateContractAttachmentController.getRecordTypeId(contractRecId);
        Test.stopTest();
        
        contract cont =[Select Id, recordtypeId from contract Where Id=:contractRecId];
        system.assertEquals(trialRecordTypeId, cont.recordtypeId,'Record type should be Trial.');
    }
    
}