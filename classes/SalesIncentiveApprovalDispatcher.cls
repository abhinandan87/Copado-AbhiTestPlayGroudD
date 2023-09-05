//-----------------------------
    // @author: Sushma Yadav
    // @date: 10 Feb 2020
    // @description Called by the trigger framework to carry out the actions before the record(s) are inserted. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
//-----------------------------

public class SalesIncentiveApprovalDispatcher extends TriggerDispatcherBase {
	private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    
    //-----------------------------
    // @author Dev Aggarwal
    // @date 9 March 2020
    // @description Called by the trigger framework to carry out the actions after the record(s) are created. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    //-----------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new SalesIncentiveAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    //-----------------------------
    // @author Dev Aggarwal
    // @date 9 March 2020
    // @description Called by the trigger framework to carry out the actions after the records are updated. If there is an
    //              existing call running on the same context, the rentrant call will utilize the handler that was created
    //              in the original call.
    // @param TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //----------------------------- 
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new SalesIncentiveAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
}