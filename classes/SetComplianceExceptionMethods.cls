//-----------------------------
// @author: Priyanka Vyas
// @date: 22 Oct 2020
// @param: NA
// @description: SFDC-3123 Class to hold SetComplianceException__e platform event trigger methods 
// @return: NA
//-----------------------------
public class SetComplianceExceptionMethods {
    public static void cascadeComplianceRestrictionToChildAccounts(TriggerParameters tp) {
        List<SetComplianceException__e> eventList = (List<SetComplianceException__e>)tp.newList;
        if(!AccountMethods.continueComplianceCascade) {
            AccountMethods.continueComplianceCascade=true;
        }
        List<Account> accountsToUpdate = new List<Account>();
        List<Account> childAccounts = new List<Account>();
        Map<Id,String> complianceRestrictionOnAccountMap = new Map<Id,String>();
        for (SetComplianceException__e event: eventList) {
            complianceRestrictionOnAccountMap.put(event.AccountId__c, event.ComplianceRestriction__c);
        }
        childAccounts = [Select id, parentid, ComplianceRestrictionException__c, parent.ComplianceRestrictionException__c from Account WHERE ParentId in:complianceRestrictionOnAccountMap.keyset()];
        for(Account childAcc : childAccounts) {
            childAcc.ComplianceRestrictionException__c=complianceRestrictionOnAccountMap.get(childAcc.ParentId);
            accountsToUpdate.add(childAcc);
        }
        if(accountsToUpdate.size()>0) {
            update accountsToUpdate;
        }
    }
}