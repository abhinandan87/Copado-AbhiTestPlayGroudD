//-----------------------------
// @author: Tran-Vu Tran
// @date: 26 March 2019
// @description: SFDC-1132 This scheduler class will be used to schedule the BatchToUpdateProductOpptyStage class
//------------------------------

global class BatchToUpdateProductOpptyStageScheduler implements Schedulable {
    public Integer batchSize = 0;
    
    global void execute(SchedulableContext sc) {
        BatchToUpdateProductOpptyStage batchClass = new BatchToUpdateProductOpptyStage();
        
        if (batchSize == 0) {
            batchSize = 1;
        }
        database.executebatch(batchClass, batchSize);
    }
}