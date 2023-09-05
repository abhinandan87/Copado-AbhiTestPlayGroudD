//-----------------------------
// @author: Dev Aggarwal
// @date: 9 March 2020
// @param: TriggerParameters
// @description: SFDC-228   AfterUpdate dispatcher event handler class that calls the functions in SalesIncentiveApprovalMethods.
// @return: NA
// BUG-5241405: to avoid getting records locked upon save.
//-----------------------------

public class SalesIncentiveAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
       // SalesIncentiveApprovalMethods.submitForApproval(tp);
	} 
}