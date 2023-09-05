//-----------------------------
// @author: Anjali
// @date: 17 June 2021
// @param: TriggerParameters
// @description:  BeforeInsert dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA
//-----------------------------

public class OrderRequestBeforeInsertHandler extends TriggerHandlerBase {
     public override void mainEntry(TriggerParameters tp) {
         OrderRequestMethods.updateRequestor(tp); 
         OrderRequestMethods.updateonSubmit(tp);
    
    }

}