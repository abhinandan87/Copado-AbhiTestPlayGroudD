//-----------------------------
// @author: Madhusudhan karna
// @date: 06 May 2021
// @param: Trigger events
// @description:  BeforeUpdate dispatcher event handler class that calls the functions in WorkRequestFormMethods.
// @return: NA

//-----------------------------
public class WorkRequestFormBeforeUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        WorkRequestFormMethods.updateSubmittedDate(tp);
        WorkRequestFormMethods.updateonApprovalPending(tp);
        WorkRequestFormMethods.validationRulesOnWRF(tp);
        WorkRequestFormMethods.updateOwnerAssignment(tp); //Akhila
        WorkRequestFormMethods.createPLCJobs(tp);
        WorkRequestFormMethods.handleOnOppChangeOnWRF(tp);
        WorkRequestFormMethods.wipeOffUnSelectedRequestTypesFields(tp);
    }
}