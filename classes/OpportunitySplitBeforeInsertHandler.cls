//--------------------------------
// @author: Tran-Vu Tran
// @date: 12th Feb 2019
// @description: SFDC-615 Handler method for Opportunity Split before-insert trigger
//--------------------------------

public class OpportunitySplitBeforeInsertHandler extends TriggerHandlerBase{
	public override void mainEntry(TriggerParameters tp) {
        //SFDC-615 populate Split Country, Split Region, and Split Geography fields from Opportunity fields
        OpportunitySplitMethods.populateBeforeInsert(tp);
        OpportunitySplitMethods.teamMemberCountryPopulate(tp);
    }
}