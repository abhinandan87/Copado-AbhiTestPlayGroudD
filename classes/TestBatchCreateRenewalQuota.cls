//-----------------------------
// @author: Neelam Agrawal
// @date: 05 July 2021
// @param: NA
// @description: Test Class for BatchCreateRenewalQuota
// @return: NA
//----------------------------
@isTest
private class TestBatchCreateRenewalQuota {
    @isTest
    static void testCreateRenewalQuota() {
        Profile p = [SELECT Id FROM Profile WHERE Name ='IHSMarkit Data Governance'];
        
        User testUser = new User(Alias = 'standt', Email='testUSer.testuser123@ihsmarkit.com.user', 
                                 EmailEncodingKey='UTF-8', firstName='testFirstName', HRManager__c='testManager', LastName='testLastName',
                                 LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,GlobalVertical__c='Financial Markets',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUSer.testuser123@ihsmarkit.com.user', ADID__c='test'+String.valueOf(Math.round(Math.random()*10000))+system.now().millisecond(),
                                 EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert testUser;
        System.runAs(testUser){
            Test.startTest();           
            List<Account> accList = new List<Account>();
            Account acc = TestUtility.createTestAccount('Account testCreateRenewalQuota Summary1', false);
            acc.DataGovernanceStatus__c = 'Approved';
            accList.add(acc);
            Account acc2 = TestUtility.createTestAccount('Account testCreateRenewalQuota Summary2', false);
            acc2.DataGovernanceStatus__c = 'Approved';
            accList.add(acc2);
            insert accList;
            Contact con = TestUtility.createContact(acc.Id,'oppty.primary@ihsmarkit.com',true,'TestOppty','TestPrimary');
            Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
            insert testOpportunity;
            OpportunityContactRole ocr = new OpportunityContactRole(IsPrimary = true, OpportunityId = testOpportunity.Id, ContactId=con.Id);
            insert ocr;
            testOpportunity.BudgetRange__c = '< 25,000';
            testOpportunity.ActivityCreated__c = true;
            testOpportunity.ContractStartDate__c = System.today()-30;
            testOpportunity.ContinuationEndDate__c=System.today()-30;
            Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            testOpportunity.RecordTypeId=RenewalOppRecordTypeId;
            update testOpportunity;
            String batchId = Database.executeBatch(new BatchCreateRenewalQuota(),200);
            Test.stopTest();
            List<Quota__c> quota = [Select id from Quota__c];
            System.assertEquals(true, quota.size()>0, 'Quota records are not created');
            
        }
    }
}