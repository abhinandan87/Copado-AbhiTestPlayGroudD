//-----------------------------
// @author: 
// @date: 05 July 2021
// @param: NA
// @description: Test Class for BatchUpdateQuotaHierarchy
// @return: NA
//----------------------------
@isTest(SeeAllData=false)
private class TestBatchUpdateQuotaHierarchy {
    @isTest
    static void testCreateRenewalQuota() {
        User testUser1 = TestUtility.createTestUser('IHSMarkit Data Governance', 'CreateRenewalQuota.testuser123@ihsmarkit.com.user',true);
        User testUser2 = TestUtility.createTestUser('IHSMarkit Data Governance', 'CreateRenewalQuota.test22343@ihsmarkit.com.usertest',true);
        User testUser3 = TestUtility.createTestUser('IHSMarkit Data Governance', 'CreateRenewalQuota.test10@ihsmarkit.com.usertest',true);
        List<Quota__c> quotaList= new List<Quota__c>();
        for(User uObj : [SELECT employeeNumber__c, Name 
                         FROM User
                         WHERE username like '%CreateRenewalQuota%' ]) {
                             Quota__c quota=new Quota__c(hierarchy__c=uObj.EmployeeNumber__c,source__c = 'Quota Database');
                             quotaList.add(quota);
                         }
        insert quotaList;
        SharedQuota__c sharedQuota = new SharedQuota__c(user__c = testUser1.id, sharewithuser__c = testUser3.id);
        insert sharedQuota;
        Test.startTest();
        String batchId = Database.executeBatch(new BatchUpdateQuotaHierarchy(),200);
        System.assert(batchId!=null);
        Test.stopTest();   
        
        
    }
    @isTest
    static void testScheduler() {
        User testUser1 = TestUtility.createTestUser('IHSMarkit Data Governance', 'CreateRenewalQuota.testuser123@ihsmarkit.com.user',true);
        User testUser2 = TestUtility.createTestUser('IHSMarkit Data Governance', 'CreateRenewalQuota.test22343@ihsmarkit.com.usertest',true);
        User testUser3 = TestUtility.createTestUser('IHSMarkit Data Governance', 'CreateRenewalQuota.test10@ihsmarkit.com.usertest',true);
        List<Quota__c> quotaList= new List<Quota__c>();
        for(User uObj : [SELECT employeeNumber__c, Name 
                         FROM User
                         WHERE username like '%CreateRenewalQuota%' ]) {
                             Quota__c quota=new Quota__c(hierarchy__c=uObj.EmployeeNumber__c);
                             quotaList.add(quota);
                         }
        insert quotaList;
        Test.startTest();
        BatchUpdateQuotaHierarchyScheduler UpdateHierarchySchedular = new BatchUpdateQuotaHierarchyScheduler();
        String cronExp = '0 0 23 * * ?'; 
        system.schedule('Test Update Hierarchy', cronExp, UpdateHierarchySchedular); 
        List<AsyncApexJob> scheduledJob = [select ApexClassId, Id
                                           from AsyncApexJob  
                                           where JobType = 'ScheduledApex'];
        system.assert(scheduledJob.size() > 0);
        Test.stopTest();   
        
        
    }
    
}