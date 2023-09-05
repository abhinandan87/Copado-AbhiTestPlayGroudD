/**
* @author : Vaishali Jain
* @date : 29th Sep 2021
* @description : This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
*               on the CampaignMember object. The event handlers support allowing and preventing actions for reentrant scenarios. 
*               This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
*               to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
*               as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
* @companyname : IHS Markit
*/

public class CampaignMemberDispatcher extends TriggerDispatcherBase {
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    private static Boolean isAfterDeleteProcessing = false;
    
    
    /** 
    * @author Vaishali Jain
    * @date 29th Sep 2021
    * @description Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
    * @return void
    * @companyname IHS Markit
    */
        public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            // SFDC1-192 : Mohit: Logic has been moved to Before Events
            // SFDC1-8827: New logic to update Account Governance case's Lead Reference with the new Lead record Id
            execute(new CampaignMemberAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    /** 
    * @author Vaishali Jain
    * @date 29th Sep 2021
    * @description Called by the trigger framework to carry out the actions after the records are updated. If there is an
    *               existing call running on the same context, the rentrant call will utilize the handler that was created
    *               in the original call.
    * @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
    * @return void
    * @companyname IHS Markit
    */
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
           // SFDC1-192 : Mohit : Commenting as Logic has been moved to Before Events
          execute(new CampaignMemberAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    
}