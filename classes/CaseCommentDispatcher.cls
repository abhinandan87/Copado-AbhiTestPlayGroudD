//-------------------------------------
//@author: Digvijay Singh
//@date: 23 March 2021
//@description : SFDC-3511 This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the EmailMessage object. The event handlers support allowing and preventing actions for reentrant scenarios. 
//              This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
//              to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//              as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//-------------------------------------

public class CaseCommentDispatcher extends TriggerDispatcherBase {
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false;
    
    //-------------------------------------
    //@author: Digvijay Singh
    //@date: 23 March 2021
    // @description: Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-------------------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new CaseCommentAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else {
            execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
        }
    }
    
    //-------------------------------------
    //@author: Digvijay Singh
    //@date: 23 March 2021
    // @description: Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-------------------------------------
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new CaseCommentAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else {
            execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
        }
    }
}