//--------------------------------
// @author: Paras Dhingra
// @date: 12th Feb 2018
// @description: SFDC1-6857 Handler method for Opportunity Split trigger
// @Last Modified By : Jagadesh Kumar
// @Last Modified Date: 2nd May 2018
// @Last Modified Description: SFDC1-7037 Roll up SplitOwner name for Fields Sales Specialists, Account Managers and Overlay.
// @company: IHS Markit
//--------------------------------
public class OpportunitySplitAfterInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        
        OpportunitySplitMethods.updateOpportunityTeamAccess(tp);
        if(System.Label.MigrationSwitchOFFLogic !='TRUE'  || Test.isRunningTest()) {
            OpportunitySplitMethods.postChatterFeedItem(tp);
            OpportunitySplitMethods.autoFollowOpportunityOnInsert(tp);
        }
        OpportunitySplitMethods.updateOpptySplitTeamName(tp);
    }
}