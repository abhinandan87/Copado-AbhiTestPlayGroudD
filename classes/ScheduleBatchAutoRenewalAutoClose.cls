//-----------------------------
// @author: Paras Dhingra
// @date: 24 Apr 2020
// @description: SFDC-2877 This scheduler class will be used to schedule the BatchAutoRenewalAutoClose batch class 
//------------------------------
global with sharing class ScheduleBatchAutoRenewalAutoClose implements System.Schedulable {
    global void execute(SchedulableContext ctx) {
        Integer batchSize = Integer.valueOf(System.Label.AutoRenewalAutoCloseBatchSize.trim());
        Database.executeBatch(new BatchAutoRenewalAutoClose(), batchSize);
    }
}