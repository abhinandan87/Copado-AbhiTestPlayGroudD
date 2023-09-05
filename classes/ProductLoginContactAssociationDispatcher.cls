//-----------------------------
// @author Vishnu Vardhan Chowdary
// @date 17 Dec 2018
// @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the Product Login Contact association object. The event handlers support allowing and preventing actions 
//              for reentrant scenarios. This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These 
//              variables need to be set to true before invoking the handlers and set to false after the invocation of the
//              handlers. Resetting is MUST as otherwise unit tests MAY fail. The actual actions should be placed in the 
//              handlers (in a separate class).
//-----------------------------
public class ProductLoginContactAssociationDispatcher extends TriggerDispatcherBase {
    
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false; 
    
    
    //-----------------------------
    // @author Vishnu Vardhan Chowdary
    // @date 17 Dec 2018
    // @description Called by the trigger framework to carry out the actions before the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-----------------------------
    public virtual override void beforeInsert(TriggerParameters tp) {
        if(!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            execute(new PLCABeoreInsertHandler(), tp, TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
    }
    
    //-----------------------------
    // @author Vishnu Vardhan Chowdary
    // @date 17 Dec 2018
    // @description Called by the trigger framework to carry out the actions before the records are updated. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------  
    /*public virtual override void beforeUpdate(TriggerParameters tp) {
        if(!isBeforeUpdateProcessing) {
            isBeforeUpdateProcessing = true;
            execute(new PLCABeforeUpdateHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
    }*/
}