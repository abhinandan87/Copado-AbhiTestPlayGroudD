//-----------------------------
// @author: Sushma Yadav
// @date: 24 Jan 2020
// @param: NA
// @description: Test Class for OpportunityUpdateBatchJob class
// @lastmodifiedBy: Neelam Agrawal
// @date: 09 Mar 2022
// @return: NA
//----------------------------
@isTest
private class TestOpportunityUpdateBatchJob {
    
    @isTest
    Private static void createTestData() {
        
        Account testAccount = TestUtility.createTestAccount('Account testSetCaseOpportunityUpdate', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
        Id renewRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opp1 = new Opportunity(Name = 'Test Opp1' , StageName= '3-Renewal Pending', RecordTypeId = renewRecordTypeId, CloseDate = System.today()+2,
                                           AutoRenewal__c = true, SourceSystem__c = 'SAP', DoesThisAutoRenewalHaveChanges__c = false,
                                           AccountId = testAccount.id);
        
        Opportunity Opp2 = new Opportunity(Name = 'Test Opp2' , StageName= '3-Renewal Pending', RecordTypeId = renewRecordTypeId, CloseDate = System.today()+2,
                                           AutoRenewal__c = true, SourceSystem__c = 'Manually Generated', DoesThisAutoRenewalHaveChanges__c = false,
                                           AccountId = testAccount.id);
        oppList.add(opp1);
        oppList.add(opp2);
        insert oppList;
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'test1';
        c.AccountId = testAccount.Id;
        c.Email = 'a@tst123example.com';
        insert c;
        
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = c.Id, OpportunityId = opp1.Id, IsPrimary = TRUE, Role = 'Decision Maker');
        
        OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = c.Id, Isprimary = True, OpportunityId = opp2.Id, Role = 'Decision maker');
        ocrList.add(ocr);
        ocrList.add(ocr1);
        insert ocrList;  
        
        for(Opportunity oppty: oppList) {
            oppty.stageName = '6W-Renewal Won';
        }
        update oppList;
        
        Test.startTest();
        OpportunityUpdateBacthJobScheduled sh1= new OpportunityUpdateBacthJobScheduled();
        String sch1 = '0 0 23 * * ?';
        System.schedule('test oppyupdate batch', sch1,sh1 );
        Id batchJobId = Database.executeBatch(new OpportunityUpdateBatchJob(), 1);
        system.debug('batchJobId='+batchJobId);		
        Test.stopTest();
        
        List<Opportunity> Oppties = [SELECT Id FROM Opportunity where id in :OppList and stageName = '6WP-Closed Won/Order Processed'];
        System.assertEquals(1, Oppties.size(),'Check Oppties size is 1');
        
    }
}