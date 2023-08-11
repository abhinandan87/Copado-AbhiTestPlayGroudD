/**
* @author Paras Dhingra
* @date 3rd August 2017
* @description SFDC1-775 update relationship for accounts
* @companyname IHS Markit
* @Last Modified By : Anjani Shukla
* @Last Modified Date : 21 Aug 2018
* @Last Modified Description - SFDC1-8621- Apex Serious Security Risk - Sharing - Updated Class for Sharing Keyword
* @Last Modified By: Tran-Vu Tran
* @Last Modified Date: 22 Oct 2018
* @Last Modified Description: SFDC1-9347 add '6W-Forecasting Placeholder' and '6WP-Closed Won/Order Processed' to the list of Opportunity's Closed Won stage
* 							Also modified the logic to make a seperate call to Opportunity Method
*/
global without sharing class BatchUpdateAccountRelationship implements Database.Batchable<sObject> {
    public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        Set<Id> setAccountsToBeQueried = new Set<Id>();
        for(Account acc: scope) {
            setAccountsToBeQueried.add(acc.Id);
        }
        
        try {
            OpportunityMethods.updateAccountRelationship(setAccountsToBeQueried);
        } catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'BatchUpdateAccountRelationship', 'execute'); 
        }

    }
    
    global void finish(Database.BatchableContext BC){
    }
}