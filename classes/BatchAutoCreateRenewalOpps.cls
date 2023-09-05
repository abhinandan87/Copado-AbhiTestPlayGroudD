//-----------------------------
// @author: Harshit Singhal
// @date: 24 Aug 2020
// @description: SFDC-3186 Batch class that runs once daily to automatically create renewal opportunities for opps that move from 6W to 6WP and meet given business criteria.
//-----------------------------
public class BatchAutoCreateRenewalOpps implements Database.Batchable<sObject>, Database.Stateful {
    public String inpQuery;
    public Integer totalCount=0, exceptionCount=0, successCount=0, errorCount = 0;
    public List<String> emailList;
    //Chained variables
    public Boolean isChained = false;
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Aug 2020
    // @param: BatchableContext - Batch context variable
    // @description: Method to collect RenewalStaging__c records that contains opportunity id which was moved from 6W to 6WP and should now be processed for Renewals creation. Batch can be run with custom input query as well for selective records.
    // @return: List<RenewalStaging__c> - List of staging records to be processed by execute() method
    //------------------------------
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        String defaultQuery = 'SELECT Id, Name, Opportunity__c FROM RenewalStaging__c WHERE Processed__c=false AND Opportunity__c!=null';
        String batchQuery = String.isNotBlank(inpQuery) ? inpQuery : defaultQuery;
        System.debug('batchQuery='+batchQuery);
        return Database.getQueryLocator(batchQuery);
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Aug 2020
    // @param: 
    // 			BatchableContext - Batch context variable
    // 			List<sObject> - List of RenewalStaging__c records  collected in start() method
    // @description: Method to:
    // 				1) Prepare Log Wrapper for each RenewalStaging__c record and add it to a list
    // 				2) Call main method 'BatchAutoCreateRenewalOppsHelper.validateAndCreateRenewalOpps' which validates each master opp and creates renewal opp for each valid master opp
    // 				3) Update the staging records with success/error/exception details
    // 				4) If there are errors, this method collects all such opps and reruns the batch with scope size=1 in finish() method to execute all error opps again and avoid failures for success opps.
    // @return: List<RenewalStaging__c> - List of staging records to be processed by execute() method
    //------------------------------
    public void execute(Database.BatchableContext bc, List<sObject> scope) {        
        //System.debug('isChained='+isChained);
        List<Opportunity> inputOppsList = new List<Opportunity>();        
        
        //Prepare list of opportunities and data wrapper map
        List<RenewalsLogWrapper> wrapperList = new List<RenewalsLogWrapper>();
        Map<Id,RenewalsLogWrapper> inputWrapperMap = new Map<Id,RenewalsLogWrapper>();
        for(RenewalStaging__c stageObj: (List<RenewalStaging__c>)scope) {
            RenewalsLogWrapper wrapObj = new RenewalsLogWrapper();
            wrapObj.stagingObj = stageObj;
            wrapperList.add(wrapObj);
            inputWrapperMap.put(stageObj.Opportunity__c, wrapObj);
            inputOppsList.add(new Opportunity(Id=stageObj.Opportunity__c));
        }
        
        //Main method to validate and create renewal opps
        Map<Id,RenewalsLogWrapper> outputWrapperMap = BatchAutoCreateRenewalOppsHelper.validateAndCreateRenewalOpps(inputOppsList, inputWrapperMap);
        
        //Batch results logging - Update staging records with success and exceptions. For errors, reprocess them with batch size 1.
        List<RenewalStaging__c> stagingUpdateList = new List<RenewalStaging__c>();        
        for(RenewalsLogWrapper wrapObj: outputWrapperMap.values()) {
            totalCount++;
            
            RenewalStaging__c stagingObjTemp = wrapObj.getFinalStagingRecord();            
            
            if(wrapObj.isException) {
                exceptionCount++;
                stagingObjTemp.Processed__c = true;
                stagingUpdateList.add(stagingObjTemp);
            }
            if(wrapObj.isSuccess) {
                successCount++;
                stagingObjTemp.Processed__c = true;
                stagingUpdateList.add(stagingObjTemp);
            }
            if(wrapObj.isError) {
                errorCount++;
                //Mark processed only when isChained=true
                if(isChained) {
                    stagingObjTemp.Processed__c = true;
                    stagingUpdateList.add(stagingObjTemp);
                }
            }
        }
        //Update Staging records
        if(stagingUpdateList.size()>0) {
            //System.debug('stagingUpdateList size='+stagingUpdateList.size());
            //System.debug('stagingUpdateList='+stagingUpdateList);
            update stagingUpdateList;            
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Aug 2020
    // @param: BatchableContext - Batch context variable
    // @description: Method to:
    // 					1) Send batch execution completion email with total,success, error, exception opps count
    // 					2) If there were errors in execute method, this method chains this batch with scope size=1 to process error and success opps separately.
    // @return: List<RenewalStaging__c> - List of staging records to be processed by execute() method
    //------------------------------
    public void finish(Database.BatchableContext bc) {        
        //System.debug('isChained='+isChained);
        
        AutomatedRenewalsConfig__c renewalsOrgDefaultConfig = AutomatedRenewalsConfig__c.getOrgDefaults();        
        String emailId = renewalsOrgDefaultConfig!=null && String.isNotBlank(renewalsOrgDefaultConfig.LogEmailRecipient__c) ? renewalsOrgDefaultConfig.LogEmailRecipient__c : Label.OpptyPrimaryContactBatchEmail;
        emailList = emailList==null ? new List<String>() : emailList;
        emailList.add(emailId);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String status = isChained ? 'CHAINED BatchAutoCreateRenewalOpps Batch Completed.' : 'BatchAutoCreateRenewalOpps Batch Completed.';
        //String[] toAddresses = new String[] {emailId};
        mail.setToAddresses(emailList);
        String mailBody = 'Total Opps Count: ' + String.valueOf(totalCount) + '\n';
        mailBody += 'Success Opps Count: ' + String.valueOf(successCount) + '\n';
        mailBody += 'Exception Opps Count: ' + String.valueOf(exceptionCount) + '\n';
        
        if(errorCount>0) {
            mail.setSubject('FAILED: ' + status);
            mailBody += 'Error Opps count: '+ errorCount + '\n\n Check Renewal Staging Error Logs for details.';            
        }
        else {
            mail.setSubject('SUCCESS: ' + status);            
        }
        mail.setPlainTextBody(mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        //CHAINING LOGIC - Reprocess error records with batch size 1
        if(errorCount>0 && !isChained) {
            //Chain the errors with batch size=1, so that only error opps throw error and not the whole batch
            BatchAutoCreateRenewalOpps chainedBatchObj = new BatchAutoCreateRenewalOpps();
            chainedBatchObj.isChained = true;
            
            Database.executeBatch(chainedBatchObj, 1);
        }
    }
}