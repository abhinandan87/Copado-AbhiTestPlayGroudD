//-----------------------------
// @author Anjali
// @date 17 June 2021
// @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the Order request object. The event handlers support allowing and preventing actions for reentrant scenarios. 
//              This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
//              to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
//              as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
//-----------------------------
public class OrderRequestDispatcher extends TriggerDispatcherBase{
    private static Boolean isAfterUpdateProcessing = false; 
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false;
    
    public virtual override void beforeInsert(TriggerParameters tp) {   
        if(!isBeforeInsertProcessing) {
            isBeforeInsertProcessing = true;
            execute(new OrderRequestBeforeInsertHandler(), tp, TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
    }
    
    public virtual override void beforeUpdate(TriggerParameters tp) {  
        if(!isBeforeUpdateProcessing) {
            isBeforeUpdateProcessing = true;
            execute(new OrderRequestBeforeUpdateHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
    }
   
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new OrderRequestAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    
}