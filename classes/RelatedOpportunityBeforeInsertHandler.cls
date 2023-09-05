//-----------------------------
// @author: Anjali
// @date: 17 Feb 2021
// @param: TriggerParameters
// @description: SFDC-3135 BeforeInsert dispatcher event handler class that calls the functions in RelatedOpportunityMethods.
// @return: NA
//-----------------------------
public class RelatedOpportunityBeforeInsertHandler extends TriggerHandlerBase{
     public override void mainEntry(TriggerParameters tp) {
        RelatedOpportunityMethods.checkDuplicateRelatedOpportunityRec(tp);
    }

}