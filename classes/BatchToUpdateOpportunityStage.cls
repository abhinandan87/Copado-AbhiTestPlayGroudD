//-----------------------------
// @author: Tran-Vu Tran
// @date: 21 March 2019
// @description: SFDC-1145 This batch class is to update Opportunity and convert existing Stage Name to the new Stage Name
//------------------------------

global class BatchToUpdateOpportunityStage implements Database.Batchable<sObject>{
	public String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)) {
            query = 'Select Id, StageName, Probability From Opportunity ' +
                'where StageName = \'3-Proposal Development and Delivery\' or StageName = \'4-Proposal Accepted and Verbal Commit\' ';
        }
            
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        System.debug('Number of records to be processed: ' + scope.size());

        List<Opportunity> opptysToBeUpdated = new List<Opportunity>();
        try {
            for (Opportunity oppty: scope) {
                switch on (oppty.StageName) {
                    when '3-Proposal Development and Delivery' {
                        oppty.StageName = '3-Proposal Development';
                        opptysToBeUpdated.add(oppty);
                    }
                    
                    when '4-Proposal Accepted and Verbal Commit' {
                        if (oppty.Probability < 75) {
                            oppty.StageName = '4.1-Proposal/Quote Delivery';
                        }
                        else {
                            oppty.StageName = '4.2-Verbal Commit';
                        }
                        
                        opptysToBeUpdated.add(oppty);
                    }
                }
            }
            
            if (opptysToBeUpdated.size() > 0) {
                database.update(opptysToBeUpdated);
            }
            
            System.debug('Processed '+ opptysToBeUpdated.size() + ' records');
            
        } catch(Exception ex) {
            System.debug('Exception when executing BatchToUpdateOpportunityStage: ' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchToUpdateOpportunityStage', 'execute'); 
        }

    }
    
    global void finish(Database.BatchableContext BC){ }
    
}