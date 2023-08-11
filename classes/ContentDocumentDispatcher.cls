//-----------------------------
// @author Sharique
// @date 18th Aug 2021
// @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//				on the ContentDocument object. The event handlers support allowing and preventing actions for reentrant scenarios. 
//				This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
//				to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//				as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//-----------------------------
public class ContentDocumentDispatcher extends TriggerDispatcherBase {
    
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;

    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 18 Aug 2021
    // @description Called by the trigger framework to carry out the actions before the record(s) are deleted. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) to be deleted.
    //-----------------------------
    public virtual override void beforeDelete(TriggerParameters tp) {
        if (!isBeforeDeleteProcessing) {
            isBeforeDeleteProcessing = true;
            execute(new ContentDocumentBeforeDeleteHandler(), tp, TriggerParameters.TriggerEvent.beforeDelete);
            isBeforeDeleteProcessing = false;
        } else execute(null, tp, TriggerParameters.TriggerEvent.beforeDelete);
    }
    //-----------------------------
    // @author Sharique Iqbal
    // @date 18th Aug 2021
    // @description SFDC1-4182 Called by the trigger framework to carry out the actions after the record(s) are deleted. If there is an
    //				existing call running on the same context, the rentrant call will utilize the handler that was created
    //				in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got deleted.
    //-----------------------------
    public virtual override void afterDelete(TriggerParameters tp) {
        if(!isAfterDeleteProcessing) {
            isAfterDeleteProcessing = true;
            execute(new ContentDocumentAfterDeleteHandler(), tp, TriggerParameters.TriggerEvent.afterDelete);
            isAfterDeleteProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
    }
    
}