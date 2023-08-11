//-----------------------------
// @author: Paras Dhingra
// @date: 24 Apr 2020
// @description: SFDC-2877 test class for ScheduleAutoRenewalAutoClose batch
//------------------------------
@isTest
private  class TestScheduleAutoRenewalAutoClose {
    @isTest
    private static void TestScheduleAutoRenewalAutoClose() {
        //create test data
        Account testAccount = TestUtility.createTestAccount('Test UpdateContractContinuationEndDate Account ', true);
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('Test Legal Entity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);

        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        List<Opportunity> lstOpportunityToInsert = new List<Opportunity>();
        Opportunity opp1 = new Opportunity();
        opp1.RecordTypeId = renewalRecordTypeId;
        opp1.AccountId = testAccount.Id;
        opp1.Name = 'Test Renewal Opp 1';
        opp1.StageName= '3-Renewal Pending';
        opp1.ContractStartDate__c = System.Today() + 12;
        opp1.ContractEndDate__c = System.Today() + 60;
        opp1.CloseDate = System.Today() + 2;
        opp1.ContinuationEndDate__c = System.Today() + 60;
        opp1.AutoRenewal__c = true;
        opp1.SourceSystem__c = 'Manually Generated';
        opp1.DoesThisAutoRenewalHaveChanges__c = false;
        opp1.Amount = 3000;
        opp1.PrimaryContact__c = 'Test Contact';
        lstOpportunityToInsert.add(opp1);

        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'test1';
        c.AccountId = testAccount.Id;
        c.Email = 'a@tst123example.com';
        insert c;
        Opportunity opp2 = new Opportunity();
        opp2.RecordTypeId = renewalRecordTypeId;
        opp2.AccountId = testAccount.Id;
        opp2.Name = 'Test Renewal Opp 2';
        opp2.StageName= '3-Renewal Pending';
        opp2.ContractStartDate__c = System.Today() + 31;
        opp2.ContractEndDate__c = System.Today() + 60;
        opp2.CloseDate = System.Today() + 31;
        opp2.ContinuationEndDate__c = System.Today() + 60;
        opp2.AutoRenewal__c = true;
        opp2.SourceSystem__c = 'SAP';
        opp2.DoesThisAutoRenewalHaveChanges__c = false;
        opp2.Amount = 3000;
        //opp2.ContractBeingRenewed__c = testContract.Id;
        opp2.PrimaryContact__c = 'Test Contact 2';
        lstOpportunityToInsert.add(opp2);
        insert lstOpportunityToInsert;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp1.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;  
        Test.startTest();
        ScheduleBatchAutoRenewalAutoClose ba = new ScheduleBatchAutoRenewalAutoClose(); //Schedule apex class name
        String sch = '0 0 8 13 2 ?'; //schedule interval time
        String jobId = System.schedule('Run Job for BatchAutoRenewalAutoClose', sch, ba); //system method to schedule apex class
        System.assert(jobId!=null);
        Database.executeBatch(new BatchAutoRenewalAutoClose(), 200);
        try{
        BatchAutoRenewalAutoClose BARAC = new BatchAutoRenewalAutoClose();
        BARAC.query = 'SELECT Id, StageName, Name,CloseDate  FROM Opportunity WHERE Id =\''+opp2.Id+'\'';
        Database.executeBatch(BARAC, 200);
        }catch(exception e){
            UtilityClass.createApexLogRecord(e, 'BatchAutoRenewalAutoClose', 'Finish');
        }
        Test.stopTest();
        //assert oppy
        Opportunity assertOppy1 = [Select Id, StageName from Opportunity where ID=:opp1.Id];
        System.assertEquals('6W-Renewal Won', assertOppy1.StageName,'Opportunity stage name is not correct');
        Opportunity assertOppy2 = [Select Id, StageName from Opportunity where ID=:opp2.Id];
        System.assertNotEquals('6W-Renewal Won', assertOppy2.StageName,'Opportunity stage name is not correct');
    }
}