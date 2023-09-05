/*  @author: Paras Dhingra
*   @date: 12 Jun 2020
*   @description: SFDC-2003 Scheduler class for the batch class BatchUpdateTrialContractStatus
*/
global with sharing class BatchUpdateTrialContractStatusScheduler implements System.Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchUpdateTrialContractStatus());
    }
}