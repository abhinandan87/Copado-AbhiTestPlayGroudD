/**
* @Author:  Priyanka Vyas
* @Date:    25th May 2020
* @description: SFDC-2872 Scheduler for Batch class: BatchNotificationPrivateEvents to send notification about the deletion of the personal appointments. 
				Must be scheduled every Monday at 1:00 AM GMT as SF Admin.
				It notifies about all the personal appointment events which have enddate < last week's friday
**/
public class BatchNotificationPrivateEventsScheduler implements Schedulable {
    public String email='';
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchNotificationPrivateEvents(email));
    }
}