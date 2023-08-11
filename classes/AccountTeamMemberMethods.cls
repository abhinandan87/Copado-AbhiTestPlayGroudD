//-----------------------------
// @author: Sharique
// @date: 13th Jan 2022
// @description: SFDC-5037 Add a new field in Accounts Object and call it "Account Team Members" 
//               that concatenates Account Team Members in a comma separated list.
                 
 //@Last Modified Description: SFDC-5485 Global Alliances - Upgrade (Amendments),
 // Add a new field in Accounts Object and call it "Account Team Members" that concatenates Alliance Lead members Account Team Members in a comma separated list*/
// @Last Modified By : Ankush Vedi
// @Last Modified Date : 25 Feb 2022
// @company: IHS Markit
//-----------------------------
public class AccountTeamMemberMethods {
    
  public static void updateAccTeamMembersNamesOnAcc(TriggerParameters tp) {
      set<Id> accIds = new set<Id>();
        
      //insert scenario
      if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
          for(AccountTeamMember atm : (List<AccountTeamMember>)tp.newList) {
              accIds.add(atm.AccountId);
          }
      }
      
      // Update Scenario Only for (Allaince Lead) //Ankush Vedi -- SFDC-5485 Global Alliances - Upgrade (Amendments).
      if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
      Map<Id,AccountTeamMember > mapOldAtm = (Map<Id,AccountTeamMember>)tp.oldMap;
          for(AccountTeamMember atm : (List<AccountTeamMember>)tp.newList) {
          If((atm.TeamMemberRole == 'Alliance Lead' && atm.TeamMemberRole != mapOldAtm.get(atm.id).TeamMemberRole ) || (atm.TeamMemberRole != 'Alliance Lead' && mapOldAtm.get(atm.id).TeamMemberRole  == 'Alliance Lead' ) )
              accIds.add(atm.AccountId);
          }
      }  
        
      // delete scenario
      if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
          for(AccountTeamMember atm : (List<AccountTeamMember>)tp.oldList) {
              accIds.add(atm.AccountId);
          }
      }
      if(!accIds.isEmpty()){
        fetchAtmNamesAndUpdateAccount(accIds);
      }  
  }
  
  /* @author: Sharique 
   * Date- 1st Feb 2022
   * SFDC-5037 (Bug-5464)
   * Description- This method is called from AccountMethods.updateAtmNamesOnMergedAccount 
                  during merge operation on Account*/
  @future
  public static void fetchAtmNamesAndUpdateAccountFuture(Set<Id> accIds) {    
     fetchAtmNamesAndUpdateAccount(accIds);
  }  
  
    
  public static void fetchAtmNamesAndUpdateAccount(Set<Id> accIds) {  
          
          List<Account> accToUpdate = new List<Account>(); //Ankush Vedi -- SFDC-5485 Global Alliances - Upgrade (Amendments).
          List<Account> accList = [SELECT Id,(SELECT Id, User.Name, TeamMemberRole FROM AccountTeamMembers ORDER BY User.Name ASC)    
                                   FROM Account 
                                   WHERE Id In :accIds];
          
          for(Account acc : accList) {
              String accountTeamMembers = '';
              String allianceLeadMembers = ''; //Ankush Vedi -- SFDC-5485 Global Alliances - Upgrade (Amendments).
              for(AccountTeamMember atm : acc.AccountTeamMembers) {
              system.debug('$$$-'+atm);
                  accountTeamMembers = accountTeamMembers + atm.User.Name + ', ';
                   If(atm.TeamMemberRole == 'Alliance Lead'){
                       allianceLeadMembers = allianceLeadMembers + atm.User.name  + ', ';
                   }
              }
              acc.AccountTeamMembers__c = accountTeamMembers.removeEnd(', ');
              acc.AccountTeamMemberforOppty__c = allianceLeadMembers.removeEnd(', ');
               accToUpdate.add(acc);
          }
          if(!accToUpdate.IsEmpty()) {
                update accToUpdate;
          }
    }
}