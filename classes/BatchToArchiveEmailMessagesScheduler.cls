//-----------------------------
// @author: Amrender Singh
// @date: 12 oct 2021
// @description: SFDC-4755(Storing Email Message data against File Storage: implementation) This batch class will be used to Schedule to BatchToArchiveEmailMessages batch.
// 
//------------------------------
public class BatchToArchiveEmailMessagesScheduler implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        integer batchScope = Integer.valueOf(system.label.ArchiveEmailMessagesBatchSize);
        String whereClause = system.label.ArchiveEmailMessagesBatchWhereClause;
        if(whereClause=='null') {
            Database.executeBatch(new BatchToArchiveEmailMessages('',true),batchScope);
        } 
        else {
            Database.executeBatch(new BatchToArchiveEmailMessages(whereClause,true),batchScope);
        }
        
    }

}