//-------------------------------------
//@author: Sruti Srivastava
//@date: 27 June 2018
//@description : SFDC1-8538 This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the EmailMessage object. The event handlers support allowing and preventing actions for reentrant scenarios. 
//              This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
//              to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//              as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//@company : Vertiba
//-------------------------------------

public class EmailMessageDispatcher extends TriggerDispatcherBase {
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    
    //-------------------------------------
    // @author: Sruti Srivastava
    // @date: 27 June 2018
    // @description: Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-------------------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new EmailMessageAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    //-------------------------------------
    // @author:  Mohit Modi
    // @date: 21 Aug 2018
    // @description: Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-------------------------------------
    public virtual override void beforeDelete(TriggerParameters tp) {
        if(!isBeforeDeleteProcessing ) {
            isBeforeDeleteProcessing = true;
            execute(new EmailMessageBeforeDeleteHandler(), tp, TriggerParameters.TriggerEvent.beforeDelete);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeDelete);
    }
}