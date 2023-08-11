/*  @author: Paras Dhingra
*   @date: 04 Jun 2020
*   @description: SFDC-2003 Batch class to update Active trial contracts past contract end date
*/
global class BatchUpdateTrialContractStatus implements Database.Batchable<sObject>,Database.Stateful {
    public Boolean batchHasErrors = false;
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        if (String.isBlank(query)) {
            query = 'SELECT Id, Name,ContractStatus__c, EndDate FROM Contract '+ 
                    'WHERE EndDate < today '+
                    'AND RecordtypeID=:trialRecordTypeId '+
                    'AND Active__c=true';
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        try {
            System.debug('--Contract scope--'+scope);
            List<Contract> lstContractToUpdate = new List<Contract>();
            for(Contract cont: scope) {//check converted currency <100,000
                cont.ContractStatus__c = 'Expired';
                lstContractToUpdate.add(cont);
            }
            if(lstContractToUpdate!=null && !lstContractToUpdate.isEmpty()) {
                System.debug('--Contract list to update--'+lstContractToUpdate);
                //update lstContractToUpdate;
                Database.SaveResult[] srList = Database.update(lstContractToUpdate, false);
                List<ApexLogger__c> logRecList = new List<ApexLogger__c>();                
                Integer counter = 0;
                for (Database.SaveResult sr : srList) {                    
                    if (!sr.isSuccess()) {                        
                        for(Database.Error err : sr.getErrors()) {
                            logRecList.add(new ApexLogger__c(ClassName__c='BatchUpdateTrialContractStatus', FunctionName__c='Execute', LogRecordId__c=lstContractToUpdate[counter].Id, LogRecordName__c=lstContractToUpdate[counter].Name, ErrorDescription__c=err.getMessage()));
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
            UtilityClass.createApexLogRecord(ex, 'BatchUpdateTrialContractStatus', 'Execute');       
        }
        
    }
    global void finish(Database.BatchableContext BC) { 
        System.debug(LoggingLevel.INFO, 'BatchUpdateTrialContractStatus BATCH FINISH()');
        //Send Email if Errors in batch processing
        if(batchHasErrors) {            
            String[] toAddresses = new String[] {};
            toAddresses.addAll(System.Label.BatchErrorRecepient.split(','));
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.OpptyPrimaryContactBatchEmail);            
            mail.setSubject('BatchUpdateTrialContractStatus batch errors');
            mail.setPlainTextBody('Please see Apex Log records to view errors of BatchUpdateTrialContractStatus batch class job in detail.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}