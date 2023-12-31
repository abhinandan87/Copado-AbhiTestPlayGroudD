//-----------------------------
// @author: Anjani Shukla
// @date: 29 Sept 2017
// @param: TriggerParameters
// @description:  AfterInsert dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA
//-----------------------------

public class ChangeLogBeforeUpdateHandler extends TriggerHandlerBase {
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 29 Sept 2017
    // @param: TriggerParameters
    // @description:  BeforeUpdate - This method is used in WRF POLK.
    // @return: NA
    //-----------------------------
    public override void mainEntry(TriggerParameters tp) {
        ChangeLogMethods.updateonSubmit(tp);
        ChangeLogMethods.updateonApproval(tp);
        ChangeLogMethods.updateonApprovalAndCreateJobs(tp);
        ChangeLogMethods.updateonRejected(tp);
    }
    
}