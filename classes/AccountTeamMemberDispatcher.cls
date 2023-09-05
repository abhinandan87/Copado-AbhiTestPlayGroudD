//-------------------------------------
//@author: Sharique Iqbal
//@date: 13th Jan 2022
//@description : This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the Account Team Member object.
//@company : IHS Markit
//
//-------------------------------------
public class AccountTeamMemberDispatcher extends TriggerDispatcherBase {
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    Private Static Boolean isAfterUpdateProcessing = false;
    
    //-------------------------------------
    // @author: Sharique Iqbal
    // @date: 12th Jan 2022
    // @description: Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-------------------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new AccountTeamMemberAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    //------------------------------------------------------------------------------
   //@author: Ankush Vedi
   // @date: 23 Feb 2022
   // @description: Called by the trigger framework to carry out the actions after the record(s) are updated. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was updated
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got Updated.
   //-------------------------------------------------------------------------------
     public virtual override void afterUpdate(TriggerParameters tp) {
                 system.debug('after update check');
        if(!isAfterUpdateProcessing ) {
            isAfterUpdateProcessing = true;
            execute(new AccountTeamMemberAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    //-------------------------------------
    // @author: Sharique Iqbal
    // @date: 13th Jan 2022
    // @description: Called by the trigger framework to carry out the actions after the record(s) are deleted. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was deleted
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got deleted.
    //-------------------------------------
    public virtual override void afterDelete(TriggerParameters tp) {
        if(!isAfterDeleteProcessing) {
            isAfterDeleteProcessing = true;
            execute(new AccountTeamMemberAfterDeleteHandler(), tp, TriggerParameters.TriggerEvent.afterDelete);
            isAfterDeleteProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
    }

}