//-----------------------------
// @author: Tran-Vu Tran
// @date: 16 April 2019
// @description: SFDC-1381 This batch class is to update Account Country lookup field from the standard Billing Country picklist value
// Normally the process should be done by Account trigger, but if data migration occurs when the triggers are turned off then data may be out-of-sync
//------------------------------

global class BatchUpdateAccountCountry implements Database.Batchable<sObject>{
	public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)) {
            query = 'Select Id, BillingCountry, BillingCountryCode, AccountCountry__r.Name, AccountCountry__r.CountryCode__c From Account ' +
                'where BillingCountry != null and AccountCountry__c = null';
        }
            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        System.debug('Number of records to be processed: ' + scope.size());

        List<Account> acctsToBeUpdated = new List<Account>();
        try {
            for (Account acct: scope) {
                Country__c country = UtilityClass.getCountryByIsoCode(acct.BillingCountryCode);
                if (country != null) {
                    acct.AccountCountry__c = country.Id;
                    acctsToBeUpdated.add(acct);
                }
            }
            
            if (acctsToBeUpdated.size() > 0) {
                database.update(acctsToBeUpdated);
            }
            
            System.debug('Processed '+ acctsToBeUpdated.size() + ' records');
            
        } catch(Exception ex) {
            System.debug('Exception when executing BatchUpdateAccountCountry: ' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchUpdateAccountCountry', 'execute'); 
        }

    }
    
    global void finish(Database.BatchableContext BC){ }
    
}