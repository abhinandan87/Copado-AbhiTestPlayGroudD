//-----------------------------
// @author: Madhusudhan karna
// @date: 06 May 2021
// @param: Trigger events
// @description:  BeforeInsert dispatcher event handler class that calls the functions in WorkRequestFormMethods.
// @return: NA
//-----------------------------
public with sharing class WorkRequestFormBeforeInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        WorkRequestFormMethods.updateWRFormType(tp);
        WorkRequestFormMethods.updateSubmittedDate(tp);
        WorkRequestFormMethods.updateonApprovalPending(tp); 
        WorkRequestFormMethods.validationRulesOnWRF(tp);
        WorkRequestFormMethods.updateOwnerAssignment(tp);
    }
}