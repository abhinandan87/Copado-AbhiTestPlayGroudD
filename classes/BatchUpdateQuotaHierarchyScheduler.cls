//-----------------------------
// @author: Akash Punera
// @date: 12 Jul 2021
// @description: SFDC-4029 This scheduler class will be used to scheduled the BatchUpdateQuotaHierarchy batch class 
//------------------------------
global class BatchUpdateQuotaHierarchyScheduler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchUpdateQuotaHierarchy(), 200);
    }
}