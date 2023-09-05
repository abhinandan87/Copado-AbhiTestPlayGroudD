/**
* @author Paras Dhingra
* @date 20th Jan 2020
* @description  Implementing trigger framework from new object SFDC-2198
*				This class extends the TriggerDispatcherBase to provide the dispatching functionality for the trigger actions 
*				on the Account object. The event handlers support allowing and preventing actions for reentrant scenarios. 
*				This is controlled by the flag isBeforeXxxxx and isAfterXxxxx member variables. These variables need to be set
*				to true before invoking the handlers and set to false after the invocation of the handlers. Resetting is MUST
*				as otherwise unit tests MAY fail. The actual actions should be placed in the handlers (in a separate class).
*/
public class MasterAgreementExhibitDispatcher extends TriggerDispatcherBase  {
    @testVisible private static Boolean isBeforeInsertProcessing = false;
	@testVisible private static Boolean isBeforeUpdateProcessing = false;
    
    /** 
	* @author Uttam Arya
	* @date 6th Feb 2017
	* @description Called by the trigger framework to carry out the actions before the records are inserted. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting inserted.
	*/
	public virtual override void beforeInsert(TriggerParameters tp) {
		if(!isBeforeInsertProcessing) {
			isBeforeInsertProcessing = true;
			execute(new MasterAgreementExhibitBeforeInsHandler(), tp, TriggerParameters.TriggerEvent.beforeInsert);
			isBeforeInsertProcessing = false;
		}
		else execute(null, tp, TriggerParameters.TriggerEvent.beforeInsert);
	}
	
	/** 
	* @author Paras Dhingra
	* @date 20th Jan 2020
	* @description Called by the trigger framework to carry out the actions before the records are updated. If there is an
	*				existing call running on the same context, the rentrant call will utilize the handler that was created
	*				in the original call.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
	*/
	public virtual override void beforeUpdate(TriggerParameters tp) {
		if(!isBeforeUpdateProcessing) {
			isBeforeUpdateProcessing = true;
			execute(new MasterAgreementExhibitBeforeUpdHandler(), tp, TriggerParameters.TriggerEvent.beforeUpdate);
			isBeforeUpdateProcessing = false;
		}
		else execute(null, tp, TriggerParameters.TriggerEvent.beforeUpdate);
	}

}