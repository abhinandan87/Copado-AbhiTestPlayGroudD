//-----------------------------
// @author Uttam Arya
// @date 22nd June 2017
// @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//				on the Case object. The event handlers support allowing and preventing actions for reentrant scenarios. 
//				This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
//				to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//				as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//-----------------------------
public class AdditionalCaseFieldsDispatcher extends TriggerDispatcherBase {
    
    private static Boolean isAfterInsertProcessing = false;
	private static Boolean isAfterUpdateProcessing = false; 
    private static Boolean isBeforeUpdateProcessing = false; 
    //-----------------------------
    // @author Uttam Arya
    // @date 22nd June 2017
    // @description Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //				existing call running on the same context, the rentrant call will utilize the handler that was created
    //				in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-----------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new AdditionalCaseFieldsAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    //-----------------------------
    // @author Vishnu Vardhan Chowdary Andra
    // @date 19 June 2018
    // @description Called by the trigger framework to carry out the actions after the record(s) are updated. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was updated
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new AdditionalCaseFieldsAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    
    //-----------------------------
    // @author Vaishali Jain
    // @date 12 April 2021
    // @description Called by the trigger framework to carry out the actions before the record(s) are updated.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------
    public virtual override void beforeUpdate(TriggerParameters tp) {
        if(!isBeforeUpdateProcessing) {
            isBeforeUpdateProcessing = true;
            execute(new AdditionalCaseFieldsBeforeUpdateHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
    }
}