//-----------------------------
// @author: Akash Punera
// @date: 12 Jul 2021
// @description: SFDC-4029 This scheduler class will be used to scheduled the BatchCreateRenewalQuota batch class 
//------------------------------
global class BatchCreateRenewalQuotaScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchCreateRenewalQuota(), 200);
    }
}