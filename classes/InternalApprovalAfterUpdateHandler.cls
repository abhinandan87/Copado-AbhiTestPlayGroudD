//-----------------------------
// @author: Akshay Dogra
// @date: 02 July 2021
// @param: TriggerParameters
// @description:  Dispatcher event handler class that calls the functions in InternalApprovalMethods.
// @return: NA
//-----------------------------
public class InternalApprovalAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        InternalApprovalMethods.notifyContractOwner(tp);  
    } 
}