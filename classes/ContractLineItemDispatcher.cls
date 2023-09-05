/**
 * @Author Jagadesh Kumar
 * @Date 20th Dec 2018
 * @Description SFDC1-10588 TriggerDispatcher class for ContractLineItem__c object 
 * @company vertiba
*/
public class ContractLineItemDispatcher extends TriggerDispatcherBase  {
    
    private static Boolean isBeforeUpdateProcessing = false;
    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterUpdateProcessing = false; 
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    
  /**
  * @author: Harshit Singhal
  * @date: 05 Oct 2020
  * @description: SFDC-3402. Called by the trigger framework to carry out the actions before the record(s) are Updated.
  * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
  * @return: void
  */
    public virtual override void beforeUpdate(TriggerParameters tp) {
        if(!isBeforeUpdateProcessing) {
            isBeforeUpdateProcessing = true;
            execute(new ContractLineItemBeforeUpdateHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
            isBeforeUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
    }
    
    /**
     * @Author Jagadesh Kumar
     * @Date 20th Dec 2018
     * @Description SFDC1-10588 Called by the trigger framework to carry out the actions after the record(s) are created. 
     *          If there is an   existing call running on the same context, 
     *          the rentrant call will utilize the handler that was createdin the original call.
     * @company vertiba
     * @Param TriggerParameters
     * @Return void
     */
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing) {
            isAfterInsertProcessing = true;
            execute(new ContractLineItemAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    
    /**
     * @Author Jagadesh Kumar
     * @Date 20th Dec 2018
     * @Description SFDC1-10588 Called by the trigger framework to carry out the actions after the record(s) are updated. 
     *          If there is an   existing call running on the same context, 
     *          the rentrant call will utilize the handler that was createdin the original call.
     * @company Vertiba
     * @Param TriggerParameters
     * @Return void
     */
    public virtual override void afterUpdate(TriggerParameters tp) {
        if(!isAfterUpdateProcessing) {
            isAfterUpdateProcessing = true;
            execute(new ContractLineItemAfterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterUpdate);
            isAfterUpdateProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    
    /**
     * @Author Jagadesh Kumar
     * @Date 20th Dec 2018
     * @Description SFDC1-10588 Called by the trigger framework to carry out the actions after the record(s) are deleted. 
     *          If there is an   existing call running on the same context, 
     *          the rentrant call will utilize the handler that was createdin the original call.
     * @company Vertiba
     * @Param TriggerParameters
     * @Return void
     */
    public virtual override void afterDelete(TriggerParameters tp) {
        if (!isAfterDeleteProcessing) {
            isAfterDeleteProcessing = true;
            execute(new ContractLineItemAfterDeleteHandler(), tp, TriggerParameters.TriggerEvent.afterDelete);
            isAfterDeleteProcessing = false;
        } else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
    }

    /** 
     * @author: Digvijay
    * @date: 3 May 2021
    * @description: SFDC-4069 DeleteHandler Called by the trigger framework to carry out the actions before the record(s) are deleted.
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got deleted.
    * @return: void
    */
    public virtual override void beforeDelete(TriggerParameters tp) {
        if(!isBeforeDeleteProcessing) {
            isBeforeDeleteProcessing = true;
            execute(new ContractLineItemBeforeDeleteHandler(), tp, TriggerParameters.TriggerEvent.beforeDelete);
            isBeforeDeleteProcessing = false;
        }
        else {
            execute(null, tp, TriggerParameters.TriggerEvent.beforeDelete);
        }
    }
    
}