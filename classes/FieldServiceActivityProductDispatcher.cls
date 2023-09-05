//-----------------------------
// @author : Vaishali Jain
// @date : 8th June 2021
// @description : This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the FSA Product object. The FieldServiceActivityProduct__c handlers support allowing and prTasking actions for reentrant scenarios. 
//              This is controlled by the flag isAfterXxxxx member variables. These variables need to be set
//              to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//              as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//-----------------------------
public class FieldServiceActivityProductDispatcher extends TriggerDispatcherBase {
    
    @testVisible private static Boolean isAfterInsertProcessing = false;
    @testVisible private static Boolean isAfterUpdateProcessing = false;
    //-----------------------------
    // @author : Vaishali Jain
    // @date : 8th June 2021
    // @description : Called by the trigger framework to carry out the actions after the record(s) are created.
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-----------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new FSAProductTriggerAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    //-----------------------------
    // @author : Vaishali Jain
    // @date : 8th June 2021
    // @description : 
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new FSAProductTriggerAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
}