//-----------------------------
// @author: Harshit Singhal
// @date: 03 Jul 2019
// @description: SFDC-525 This scheduler class will be used to schedule the BatchCalculateContractCurrentValue batch class 
//------------------------------
global class BatchCalculateContractCurrentValueSched implements Schedulable {
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchCalculateContractCurrentValue(), 200);
    }
}