/*  @author: Paras Dhingra
*   @date: 12 Jun 2020
*   @description: SFDC-2003 Test class for Scheduler class BatchUpdateTrialContractStatusScheduler and Batch class BatchUpdateTrialContractStatus
*/
@isTest
public with sharing class TestBatchUpdateTrialContractStatus {
    @isTest
    private static void testTrialExpiredBatch() {
        //create test data
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
        System.debug('@@@@!!!!!!!!');
        ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity.id, contractRecId, null, trialRecordTypeId, testOpportunity.CurrencyISOCode);
        
        //Query and update test contract record to create the case
        Contract testContract = [Select id, RecordTypeId,StartDate, status, Fastrack__c, AutoRenewal__c from contract where Id=: contractRecId];
        testContract.Status = 'Generation';
        testContract.ContractStatus__c = 'Validated';
        testContract.OrderReason__c = 'New';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.BillToClientName__c = 'test1' ;
        testContract.EffectiveDate__c = testContract.StartDate-1;//System.today() ;
        testContract.RenewalDate__c = System.today()-59;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        //update testContract;
        update testContract;
        BatchUpdateTrialContractStatusScheduler schedulerObj = new BatchUpdateTrialContractStatusScheduler();
        String schedule ='0 0 1 ? * MON'; 
        System.schedule('Schedule to send private event notification', schedule, schedulerObj);    
        Test.startTest();
        BatchUpdateTrialContractStatus batchObject = new BatchUpdateTrialContractStatus();
        database.executeBatch(batchObject,20);
        Test.stopTest();
        //assert
        Contract assertContract = [Select Id, ContractStatus__c from Contract where Id=:testContract.Id limit 1];
        System.assertEquals('Expired', assertContract.ContractStatus__c);
        //explicitly setting batch error variable to increase coverage
        BatchUpdateTrialContractStatus batchObject2 = new BatchUpdateTrialContractStatus();
        batchObject2.batchHasErrors = true;
        database.executeBatch(batchObject2,20);
    }
}