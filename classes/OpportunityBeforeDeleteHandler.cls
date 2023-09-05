//-----------------------------
// @author: Tran-Vu Tran
// @date: 03 Jan 2019
// @param: TriggerParameters
// @description: BeforeDelete dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA
//-----------------------------

public class OpportunityBeforeDeleteHandler extends TriggerHandlerBase{
    
    public override void mainEntry(TriggerParameters tp) {
        OpportunityMethods.checkUserProfileBeforeDelete(tp); 
    }
}