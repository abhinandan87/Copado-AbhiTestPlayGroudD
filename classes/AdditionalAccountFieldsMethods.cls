//-----------------------------
// @author: Uttam Arya
// @date: 22 Aug 2017
// @param: NA
// @description: SFDC1-2103 Class to hold Additional Account Fields trigger methods 
// @return: NA
//-----------------------------
public class AdditionalAccountFieldsMethods {

//-----------------------------
// @author: Uttam Arya
// @date: 22 Aug 2017
// @param: TriggerParameters tp
// @description: SFDC1-2103 Whenever a new account is created, whether through integration/data migration or manually by an Account Governance user,
//  an "Additional Account Fields" record is automatically created, and a link to that record is populated in the "Additional Account Fields" field.
//  This function populates the Additional Fields lookup in Account.
//
// @return: None
//------------------------------
    public static void populateAdditionalFiledsLookupInAccount(TriggerParameters tp) {
    
        //List of Accounts that needs to be updated    
        List <Account> AccountsToUpdate = new List <Account>(); 
        
        for(AdditionalAccountFields__c aaf: (List <AdditionalAccountFields__c>) tp.newList) {
            if(aaf.AccountReference__c != null) {
                AccountsToUpdate.add(new Account(Id = aaf.AccountReference__c, AdditionalAccountFields__c = aaf.Id));
            }
        }
        
        //update if list has any records
        if(AccountsToUpdate != null && AccountsToUpdate.size() > 0) {
            update AccountsToUpdate;
        }
    }
}