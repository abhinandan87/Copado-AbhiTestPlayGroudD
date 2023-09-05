//--------------------------------
// @author: Ankush Vedi
// @date: 23 Feb 2022
// @Description: SFDC-5485 Global Alliances - Upgrade (Amendments).
//Description-  Add a new field in Accounts Object 
//and call it "Account Team Members" that concatenates Alliance Lead members Account Team Members in a comma separated list
// @company: IHS Markit
//--------------------------------
public with sharing class AccountTeamMemberAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {      
        AccountTeamMemberMethods.updateAccTeamMembersNamesOnAcc(tp);

    }
}