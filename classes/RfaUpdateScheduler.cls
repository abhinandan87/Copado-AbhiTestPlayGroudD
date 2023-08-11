/*  @author: Akash Punera
 *   @date: 5 Dec 2022
 *   @description: Scheduler to schedule the syncing of request/response updates to and from the hub
 */
public with sharing class RfaUpdateScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        System.enqueueJob(new RfaUpdateSchedulerQueueable());
    }
}