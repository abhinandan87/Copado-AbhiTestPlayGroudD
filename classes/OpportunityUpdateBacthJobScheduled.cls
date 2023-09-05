//-----------------------------
// @author: Sushma Yadav
// @date: 24 Jan 2020
// @description: SFDC-2500 Auto Renewals with no change to go to 6WP when the have the External Source System = "SAP"
// -----------------------------

global class OpportunityUpdateBacthJobScheduled implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        OpportunityUpdateBatchJob obj = new OpportunityUpdateBatchJob();
        DataBase.executeBatch(obj);
    }
}