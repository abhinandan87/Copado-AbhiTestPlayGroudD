//-----------------------------
// @author: Akhila Kodipaka
// @date: 21 May 2021
// @param: Trigger events
// @description:  AfterUpdate dispatcher event handler class that calls the functions in WorkRequestFormMethods.
// @return: NA

//-----------------------------
public class WorkRequestFormAfterUpdateHandler extends TriggerHandlerBase { 
    public override void mainEntry(TriggerParameters tp) {
       // WorkRequestFormMethods.updateonApprovalPending(tp); 
       WorkRequestFormMethods.handleOnOppChangeOnWRF(tp);
    }
}