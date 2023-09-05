//-----------------------------
// @author: Sathish Edla
// @date: 30 Mar 2022
// @description: SFDC-5375 Extend the trigger framework to handle platform events.
//-----------------------------
public class SetupEventsDispatcher extends TriggerDispatcherBase {
    @testVisible private static Boolean isAfterInsertProcessing = false;
    
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new SetupEventsAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
}