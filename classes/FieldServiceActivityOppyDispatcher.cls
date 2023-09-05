//-----------------------------
// @author : Shikhar Singh
// @date : 06 June 2022
// @description : This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the Account object. The FSAO handlers support allowing and prTasking actions for reentrant scenarios. 
//              This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
//              to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//              as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//-----------------------------
public class FieldServiceActivityOppyDispatcher extends TriggerDispatcherBase {
    
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    //-----------------------------
    // @author : Shikhar Singh
    // @date : 06 June 2022
    // @description : SFDC-5786 Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-----------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new FieldServiceActOppyAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    //-----------------------------
    // @author : Shikhar Singh
    // @date : 06 June 2022
    // @description : SFDC-5786 Called by the trigger framework to carry out the actions after the record(s) are deleted. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got deleted.
    //-----------------------------
    public virtual override void afterDelete(TriggerParameters tp) {
        if(!isAfterDeleteProcessing) {
            isAfterDeleteProcessing = true;
            execute(new FieldServiceActOppyAfterDeleteHandler(), tp, TriggerParameters.TriggerEvent.afterDelete);
            isAfterDeleteProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
    }
    //-----------------------------
    // @author : Shikhar Singh 
    // @date : 06 June 2022
    // @description : SFDC-5786 Called by the trigger framework to carry out the actions after the record(s) are updated. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new FieldServiceActOppyAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    
}