//-----------------------------
// @author Anjali 
// @date 24th May 2021
// @param: TriggerParameters
// @description:  AfterDelete dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA
//-----------------------------

public class ChangeLogAfterDeleteHandler extends TriggerHandlerBase{
    public override void mainEntry(TriggerParameters tp) {
        ChangeLogMethods.updateNoofChangeLogs(tp);
    }

}