//-----------------------------
// @author Priyanka Vyas
// @date 22 June 2020
// @description This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
//              on the Related Opportunity object.
//-----------------------------
public class RelatedOpportunityDispatcher extends TriggerDispatcherBase {
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isBeforeInsertProcessing = false; 
    private static Boolean isBeforeUpdateProcessing = false; 
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new RelatedOpportunityAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new RelatedOpportunityAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    public virtual override void afterDelete(TriggerParameters tp) {
        if(!isAfterDeleteProcessing ) {
            isAfterDeleteProcessing = true;
            execute(new RelatedOpportunityAfterDeleteHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterDeleteProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    public virtual override void beforeInsert(TriggerParameters tp) {
        if(!isBeforeInsertProcessing ) {
            isBeforeInsertProcessing = true;
            execute(new RelatedOpportunityBeforeInsertHandler(), tp, TriggerParameters.TriggerEvent.beforeInsert);
            isBeforeInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
    }
    public virtual override void beforeUpdate(TriggerParameters tp) {
        if(!isBeforeUpdateProcessing ) {
            isBeforeUpdateProcessing = true;
            execute(new RelatedOpportunityBeforeUpdateHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
    }
    
    
}