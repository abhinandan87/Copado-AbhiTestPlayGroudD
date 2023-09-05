//-----------------------------
// @author: Paras Dhingra
// @date: 22 April 2020
// @description: SFDC-2877 Decommision the workflow and move the Autorenewals Auto close logic to batch to prevent any gaps
// @Last Modified By : Harshit Singhal
// @Last Modified Date : 07 Sep 2020
// @Last Modified Description: SFDC-3352 Added code to set boolean variable isExecutingBatchAutoRenewalAutoClose to true/false in execute method. This is done so that OM case creation logic in opp trigger is not skipped due to partial DML success in batch.
//------
global  class BatchAutoRenewalAutoClose implements Database.Batchable<sObject>,Database.Stateful {
    public Boolean batchHasErrors = false;
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        if (String.isBlank(query)) {
            query = 'SELECT Id, StageName, Name,CloseDate  FROM Opportunity '+ 
                    'WHERE AutoRenewal__c=true '+
                    'AND isClosed=false '+
                    'AND DoesThisAutoRenewalHaveChanges__c=false '+
                    'AND RecordtypeID=:renewalRecordTypeId '+
                    'AND PrimaryContact__c!=null '+
                    'AND ContractStartDate__c!=null '+
                    'AND (FirstYearValue__c=null OR FirstYearValue__c<USD100000) '+
                    'AND (ContractStartDate__c = NEXT_N_DAYS:14 OR ContractStartDate__c <= Today) ' ;
        }
            
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {        
        try {
            GlobalVariables.isExecutingBatchAutoRenewalAutoClose = true;
            System.debug('--Opportunity scope--'+scope);
            List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
            for(Opportunity oppy: scope) {//check converted currency <100,000
                    oppy.stageName = '6W-Renewal Won';
                    oppy.IsThisRenewalAutoClosed__c = true;
                    oppy.CloseDate = Date.today();
                    lstOpportunityToUpdate.add(oppy);
            }
            if(lstOpportunityToUpdate!=null && !lstOpportunityToUpdate.isEmpty()) {
                System.debug('--Opportunity list to update--'+lstOpportunityToUpdate);
                //update lstOpportunityToUpdate;
                Database.SaveResult[] srList = Database.update(lstOpportunityToUpdate, false);
                List<ApexLogger__c> logRecList = new List<ApexLogger__c>();                
                Integer counter = 0;
                for (Database.SaveResult sr : srList) {                    
                    if (!sr.isSuccess()) {                        
                        for(Database.Error err : sr.getErrors()) {
                            logRecList.add(new ApexLogger__c(ClassName__c='BatchAutoRenewalAutoClose', FunctionName__c='Execute', LogRecordId__c=lstOpportunityToUpdate[counter].Id, LogRecordName__c=lstOpportunityToUpdate[counter].Name, ErrorDescription__c=err.getMessage()));
                        }
                    }
                    counter++;
                }
                //Insert Error Log records
                if(logRecList.size() > 0) {
                    batchHasErrors = true;
                    insert logRecList;
                }
            }

            
        } catch(Exception ex) {
            System.debug('--Exception caught in batch--'+ex.getMessage());
            batchHasErrors = true;
            UtilityClass.createApexLogRecord(ex, 'BatchAutoRenewalAutoClose', 'Execute');       
        }
        finally {
            GlobalVariables.isExecutingBatchAutoRenewalAutoClose = false;
        }
    }
    global void finish(Database.BatchableContext BC) { 
        System.debug(LoggingLevel.INFO, 'BatchAutoRenewalAutoClose BATCH FINISH()');
        //Send Email if Errors in batch processing
        if(batchHasErrors) {            
            String[] toAddresses = new String[] {'paras.dhingra@ihsmarkit.com'};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.OpptyPrimaryContactBatchEmail);            
            mail.setSubject('paras.dhingra@ihsmarkit.com');
            mail.setPlainTextBody('Please see Apex Log records to view errors of BatchAutoRenewalAutoClose batch class job in detail.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}