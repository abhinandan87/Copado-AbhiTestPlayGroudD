//-----------------------------
// @author: Mohit Parnami
// @date: 15 Mar 2022
// @description: SFDC-4029 This scheduler class will be used to scheduled the BatchCreateRenewalQuota batch class 
//------------------------------
@isTest
private class TestBatchCreateRenewalQuotaScheduler {
	@isTest static void executeTest(){
        SchedulableContext sc = null;
        BatchCreateRenewalQuotaScheduler tsc = new BatchCreateRenewalQuotaScheduler();
        tsc.execute(sc);
    }
}