/**
* @Author:  Priyanka Vyas
* @Date:    25th May 2020
* @description: SFDC-2872 Scheduler for Batch class: BatchDeletePrivateEvents to delete the personal appointments from last week and before. 
				Must be scheduled every Saturday at 1:00 AM GMT as SF Admin.
				It deleted all the personal appointment event which have enddate < last week's friday
**/
public class BatchDeletePrivateEventsScheduler implements Schedulable{
	public String email='';
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchDeletePrivateEvents(email));
    }
}