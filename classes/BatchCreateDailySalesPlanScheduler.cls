//-----------------------------
// @author: Akash Punera
// @date: 25 Apr 2022
// @description: SFDC-5710 This scheduler class will be used to scheduled the BatchCreateDailySalesPlan batch class 
//------------------------------
public class BatchCreateDailySalesPlanScheduler implements Schedulable {
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchCreateDailySalesPlan(), 200);
    }

}