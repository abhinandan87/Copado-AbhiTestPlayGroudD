/**
* @author: Ankita Singh
* @date: 18th June 2018
* @description: SFDC1-8559. This class extends the TriggerDispatcherBase to provide the dispatching functionality for the
*        trigger actions on the ContractAttachment object. The event handlers support allowing and preventing actions for 
*        reentrant scenarios. This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables 
*        need to be set to true before invoking the handlers and set to false after the invocation of the handlers. Resetting 
*        is MUST as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
* @companyname: VERTIBA
*/ 
public class ContractAttachmentDispatcher extends TriggerDispatcherBase {

    private static Boolean isAfterInsertProcessing = false;
    private static Boolean isAfterDeleteProcessing = false;
    private static Boolean isBeforeDeleteProcessing = false;
    private static Boolean isBeforeInsertProcessing = false;
    private static Boolean isBeforeUpdateProcessing = false; 
    private static Boolean isafterUpdateProcessing = false;
  /** 
  * @author: Ankita Singh
  * @date: 18 June 2018
  * @description: SFDC1-8559. Called by the trigger framework to carry out the actions after the record(s) are deleted. 
  * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got deleted.
  * @companyname: VERTIBA
  * @return: void
  */ 
    public virtual override void afterDelete(TriggerParameters tp) {
        if(!isAfterDeleteProcessing) {
            isAfterDeleteProcessing = true;
            execute(new ContractAttachmentAfterDeleteHandler(), tp, TriggerParameters.TriggerEvent.afterDelete);
            isAfterDeleteProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterDelete);
    }

    //-----------------------------
    // @author: Ankita Singh
    // @date: 18 June 2018
    // @description: SFDC1-8559. Called by the trigger framework to carry out the actions after the record(s) are Inserted.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got inserted.
    // @companyname: VERTIBA
    // @return: void
    //-----------------------------
    public virtual override void afterInsert(TriggerParameters tp) {
        if(!isAfterInsertProcessing ) {
            isAfterInsertProcessing = true;
            execute(new ContractAttachmentAfterInsertHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
            isAfterInsertProcessing = false;
        }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterInsert);
    }
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 07 November 2019
    // @description: SFDC-2037. Called by the trigger framework to carry out the actions before the record(s) are Inserted.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got inserted.
    // @return: void
    //-----------------------------
    public virtual override void beforeInsert(TriggerParameters tp) {
     if(!isBeforeInsertProcessing ) {
        isBeforeInsertProcessing = true;
        execute(new ContractAttachmentBeforeInsertHandler(), tp, TriggerParameters.TriggerEvent.beforeInsert);
        isBeforeInsertProcessing = false;
       }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
    }
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 07 November 2019
    // @description: SFDC-2037. Called by the trigger framework to carry out the actions after the record(s) are updated.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got inserted.
    // @return: void
    //-----------------------------
    public virtual override void afterUpdate(TriggerParameters tp) {
     if(!isafterUpdateProcessing ) {
        isafterUpdateProcessing = true;
        execute(new ContractAttachmentafterUpdateHandler(), tp, TriggerParameters.TriggerEvent.afterInsert);
        isafterUpdateProcessing = false;
       }
        else execute(null, tp, TriggerParameters.TriggerEvent.afterUpdate);
    }
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: o6 Oct 2021
    // @description: SFDC-4568. Called by the trigger framework to carry out the actions before the record(s) are updated.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @return: void
    //-----------------------------
    public virtual override void beforeUpdate(TriggerParameters tp) {
     if(!isBeforeUpdateProcessing ) {
        isBeforeUpdateProcessing = true;
        execute(new ContractAttachmentBeforeUpdateHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
        isBeforeUpdateProcessing = false;
       }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 06 Oct 2021
    // @description: SFDC-4568. Called by the trigger framework to carry out the actions before the record(s) are deleted.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that are deleted.
    // @return: void
    //-----------------------------
    public virtual override void beforeDelete(TriggerParameters tp) {
     if(!isBeforeDeleteProcessing ) {
        isBeforeDeleteProcessing = true;
        execute(new ContractAttachmentBeforeDeleteHandler(), tp, TriggerParameters.TriggerEvent.beforeDelete);
        isBeforeDeleteProcessing = false;
       }
        else execute(null, tp, TriggerParameters.TriggerEvent.beforeDelete);
    }
}