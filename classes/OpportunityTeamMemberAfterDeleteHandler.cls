//--------------------------------
// @author: Ankush Vedi
// @date: 25 March 2022
// @Description: SFDC-4968 -Trigger email when a team Member is added or removed from an Opportunity
//               
// @company: IHS Markit
//--------------------------------
public class OpportunityTeamMemberAfterDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {   
      	  OpportunityTeamMemberMethods.updateOppyTeamMembers(tp);
    }
}