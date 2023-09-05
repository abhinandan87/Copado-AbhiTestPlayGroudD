//-----------------------------
// @author: Sushma Yadav
// @date: 24 Jan 2020
// @description: SFDC-2500 Auto Renewals with no change to go to 6WP when the have the External Source System = "SAP"
// -----------------------------

global class OpportunityUpdateBatchJob implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        string query;
        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        query = 'SELECT Id,StageName ' +
            'FROM Opportunity ' +
            'where StageName=\'6W-Renewal Won\' ' +
            ' AND AutoRenewal__c=true' +
            ' AND DoesThisAutoRenewalHaveChanges__c=false' + 
            ' AND SourceSystem__c=\'SAP\' ' +
            ' AND PORequired__c=false' +
            ' AND RecordTypeId =:renewalRecordTypeId';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        
        try {          
            for(Opportunity oppty : scope) {
                oppty.StageName = '6WP-Closed Won/Order Processed';
            }
            
            Database.SaveResult[] srList = Database.update(scope, false);
            List<ApexLogger__c> logRecList = new List<ApexLogger__c>();                
            Integer counter = 0;
            for (Database.SaveResult sr : srList) {                    
                if (!sr.isSuccess()) {                        
                    for(Database.Error err : sr.getErrors()) {                                
                        logRecList.add(new ApexLogger__c(ClassName__c='OpportunityUpdateBatchJob', FunctionName__c='Execute', LogRecordId__c=scope[counter].Id, LogRecordName__c=scope[counter].Name, ErrorDescription__c=err.getMessage()));
                    }
                }
                counter++;
            }
            if(logRecList.size() > 0) {
                insert logRecList;
            }
        }
        catch (Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'OpportunityUpdateBatchJob', 'Execute');                
        }
    }
    
    global void finish(Database.BatchableContext bc) {
    }
}