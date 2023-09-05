/*  @author: Akash Punera
*   @date: 15 Mar 2022
*   @description: Test class for BatchCreateDailySalesPlan
*/
@isTest(SeeAllData=false)
private class TestBatchCreateDailySalesPlan {
    @testSetup static void generateTestData() {
        Product2 objPro = TestUtility.createProduct('Test Product',false);
        BusinessLine__c objBl = TestUtility.createBusinessLine('Test Businessline', true);
        SubBusinessline__c objSbl= TestUtility.createSubBusinessLine('Test Sub-Businessline',true);
        productGroup__c objPg = TestUtility.createProductGroup('Test Product Group',true);
        objPro.subbusinessline__c = objSBl.id; 
        objPro.businessline2__c = objBl.id;
        objPro.productgroup__c = objPg.id;
        insert objPro;
    }
    @isTest
    static void testBatchExecute() {
        SalesPlan__c objSP = new SalesPlan__c(	Amount__c = 1200, productgroupname__c = 'Test Product Group', 
                             				 	Region__c = 'EMEA', type__c = 'Recurring', 
                                              	externalid__c = 'TestProductGroup_EMEA_Recurring_2022_1', 
                                              	period__c= date.parse('1/1/2022'));
        insert objSp;
        Test.startTest();
        BatchCreateDailySalesPlan batchCreatePlan = new BatchCreateDailySalesPlan();
        String batchId = Database.executeBatch(batchCreatePlan,200);
        System.assert(batchId!=null);
        BatchCreateDailySalesPlanScheduler createPlanSchedular = new BatchCreateDailySalesPlanScheduler();
        String cronExp = '0 0 23 * * ?'; 
        system.schedule('Test Create Plan', cronExp, createPlanSchedular); 
        List<AsyncApexJob> scheduledJob = [select ApexClassId, Id
                                           from AsyncApexJob  
                                           where JobType = 'ScheduledApex'];
        system.assert(scheduledJob.size() > 0);
        Test.stopTest();   
    }
    @isTest
    static void testUpsertWithError() {
        SalesPlan__c objSP = new SalesPlan__c(	Amount__c = 1200, productgroupname__c = 'Test Product Group', 
                             				 	Region__c = 'EMEAIncorrect', type__c = 'Incorrect', 
                                              	externalid__c = 'TestProductGroup_EMEA_R_2022_1', 
                                              	period__c= date.parse('1/1/2022'));
        List<SalesPLan__c> lstToUpsert = new List<SalesPlan__c>();
        lstToUpsert.add(objSp);
        Test.startTest();
        BatchCreateDailySalesPlan batchCreatePlan = new BatchCreateDailySalesPlan();
        batchCreatePlan.upsertSalesPlan(lstToUpsert);
        system.assert(batchCreatePlan.batchHasErrors);
        Test.stopTest();   
    }

}