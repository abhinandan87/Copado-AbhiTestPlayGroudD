//-----------------------------
// @author: Tran-Vu Tran
// @date: 26 March 2019
// @description: SFDC-1132 This batch class is to sync Opportunity Stage values from Opportunity to Opportunity Product records
// This is neccessary when the Opportunity Stage was changed to a Closed stage that Sales user does not have permission to update the record afterward
//------------------------------

global class BatchToUpdateProductOpptyStage  implements Database.Batchable<sObject>{
	public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)) {
            query = 'Select Id, OpportunityStage__c, Opportunity.StageName from OpportunityLineItem '
                + 'where OpportunityStage__c != \'\' and ' 
                + '((Opportunity.StageName like \'%6L%\' and (not(OpportunityStage__c like \'%6L%\'))) '
                + ' or (Opportunity.StageName like \'%6W%\' and (not(OpportunityStage__c like \'%6W%\'))) '
                + ' or (Opportunity.StageName like \'%6WP%\' and (not(OpportunityStage__c like \'%6WP%\'))))';
        }
            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope) {
        System.debug('BatchToUpdateProductOpptyStage - Number of records to be processed: ' + scope.size());

        List<OpportunityLineItem> olisToBeUpdated = new List<OpportunityLineItem>();
        try {
            for (OpportunityLineItem oli: scope) {
                if (oli.OpportunityStage__c != oli.Opportunity.StageName) {
                    oli.OpportunityStage__c = oli.Opportunity.StageName;
                    olisToBeUpdated.add(oli);
                }
            }
            
            if (olisToBeUpdated.size() > 0) {
                database.update(olisToBeUpdated);
            }
            
            System.debug('BatchToUpdateProductOpptyStage - Processed '+ olisToBeUpdated.size() + ' records');
            
        } catch(Exception ex) {
            System.debug('BatchToUpdateProductOpptyStage - Exception when executing: ' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchToUpdateProductOpptyStage', 'execute'); 
        }

    }
    
    global void finish(Database.BatchableContext BC){ }
    
}