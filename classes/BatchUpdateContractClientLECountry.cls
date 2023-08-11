//-----------------------------
// @author: Tran-Vu Tran
// @date: 16 April 2019
// @description: SFDC-1381 This batch class is to update Contract's Client Legal Entity Country from the Client Legal Entity's Country lookup values 
// Normally the process should be done by trigger when adding Client Legal Entity to the Contract record,
// but if data migration occurs when the triggers are turned off then the values may be out-of-sync
//------------------------------

global class BatchUpdateContractClientLECountry implements Database.Batchable<sObject>{
	public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)) {
            query = 'Select Id, ClientLegalEntityLookUp__r.AccountCountry__c, ClientLegalEntityCountryLookup__c from Contract ' +
                'where ClientLegalEntityLookUp__c != null and ClientLegalEntityLookUp__r.AccountCountry__c != null and ClientLegalEntityCountryLookup__c = null';
        }
            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        System.debug('Number of records to be processed: ' + scope.size());

        List<Contract> contractsToBeUpdated = new List<Contract>();
        try {
            for (Contract contract: scope) {
                if (contract.ClientLegalEntityCountryLookup__c != contract.ClientLegalEntityLookUp__r.AccountCountry__c) {
                    contract.ClientLegalEntityCountryLookup__c = contract.ClientLegalEntityLookUp__r.AccountCountry__c;
                    contractsToBeUpdated.add(contract);
                }
            }
            
            if (contractsToBeUpdated.size() > 0) {
                database.update(contractsToBeUpdated);
            }
            
            System.debug('Processed '+ contractsToBeUpdated.size() + ' records');
            
        } catch(Exception ex) {
            System.debug('Exception when executing BatchUpdateContractClientLECountry: ' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchUpdateContractClientLECountry', 'execute'); 
        }

    }
    
    global void finish(Database.BatchableContext BC){ }
    
}