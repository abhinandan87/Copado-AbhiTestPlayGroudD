//--------------------------------
// @author: Sharique Iqbal
// @date: 13th Jan 2022
// @Description: SFDC-5037 Add a new field in Accounts Object and call it "Account Team Members" 
//               that concatenates Account Team Members in a comma separated list.
// @company: IHS Markit
//--------------------------------
public class AccountTeamMemberAfterDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {   
        AccountTeamMemberMethods.updateAccTeamMembersNamesOnAcc(tp);
    }
}