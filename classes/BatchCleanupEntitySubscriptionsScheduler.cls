/**
* @author Paras Dhingra
* @date 17 Sep 2020
* @description SFDC-3387 schedule class for entity subscription clean up batch BatchCleanupEntitySubscriptions
* @companyname IHS Markit
*/
global class BatchCleanupEntitySubscriptionsScheduler implements Schedulable {
    public string query;
    global void execute(SchedulableContext ctx) {
        BatchCleanupEntitySubscriptions batchUpdate = new BatchCleanupEntitySubscriptions();
        if(!String.isBlank(query)) {
            batchUpdate.query = query;
        }
        Integer batchsize = Integer.valueOf(System.Label.EntitySubscriptionBatchSize);
        ID batchprocessId = Database.executeBatch(batchUpdate,batchsize);
    }
    
}