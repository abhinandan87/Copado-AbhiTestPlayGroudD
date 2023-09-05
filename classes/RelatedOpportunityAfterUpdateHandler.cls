//-----------------------------
// @author: Priyanka Vyas
// @date: 22 June 2020
// @param: TriggerParameters
// @description: SFDC-3115 AfterUpdate dispatcher event handler class that calls the functions in RelatedOpportunityMethods.
// @return: NA
//-----------------------------
public class RelatedOpportunityAfterUpdateHandler extends TriggerHandlerBase{
    public override void mainEntry(TriggerParameters tp) {
        RelatedOpportunityMethods.changeActivityCreatedOnOppyOnUpdate(tp);
    }
}