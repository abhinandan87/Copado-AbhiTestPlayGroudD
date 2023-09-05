/*  @author: Akash Punera
 *   @date: 5 Dec 2022
 *   @description: Helper to schedule push and pull sync
 */
public with sharing class RfaUpdateSchedulerQueueable implements Queueable, Database.AllowsCallouts {
    /*  @author: Akash Punera
     *   @date: 5 Dec 2022
     *   @description: Queue Push and pull services
     */
    public void execute(QueueableContext context) {
        //Pull records from Hub
        RfaPushUpdates obj = new RfaPushUpdates();
        obj.pushUpdatesToHub();
        //Enqueue Job to push updates to hub, this has to be async as callouts cannot be made after DML
        if(!Test.isRunningTest()) {
            System.enqueueJob(new RfaPullRecords());
        }
    }
}