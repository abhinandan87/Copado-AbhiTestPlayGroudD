//-----------------------------
// @author: Digvijay Singh
// @date: 11 June 2021
// @param: NA
// @description: SFDC-4166 Class to hold SetContractCountonAccount__e platform event trigger methods 
// @return: NA
//-----------------------------
public class SetContractCountonAccountMethods {
      /**
    * @author Digvijay Singh
    * @date 11 June 2021
    * @description SFDC-4166 Update Contract Count on  Account record 
    * @param TriggerParameters
    * @return void
    * @companyname IHS Markit
    */
    public static void calculateContractCountOnAccount(TriggerParameters tp) {
        List<SetContractCountonAccount__e> eventList = (List<SetContractCountonAccount__e>)tp.newList;
        try {
            List<Account> lstAccountToUpdate = new List<Account>();
            List<Id> lstAccountId = new List<Id>();
            for(SetContractCountonAccount__e event : eventList) {
                lstAccountId.add(event.AccountId__c);
            }
            if(!lstAccountId.IsEmpty()) {
                Map<Id,Account> mapIdtoAccount = new Map<Id,Account>([SELECT Id,(SELECT Id, Active__c FROM Contracts) FROM Account WHERE Id In: lstAccountId]);
                for(Account acc: mapIdtoAccount.values()) {
                    Integer count = 0;
                    acc.AccountContractsCount__c = mapIdtoAccount.get(acc.Id).Contracts.Size();
                    for(Contract cont : acc.contracts) {
                        if(cont.Active__c) {
                            count += 1; 
                        }
                    }
                    acc.AccountActiveContractsCount__c = count;
                    lstAccountToUpdate.add(acc);
                }
            }
            
            if(!lstAccountToUpdate.IsEmpty()) {
                update lstAccountToUpdate;
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'SetContractCountonAccountMethods', 'calculateContractCountOnAccount');
        } 
    }
}