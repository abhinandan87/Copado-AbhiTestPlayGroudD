//-----------------------------
// @author: Harshit Singhal
// @date: 14 Jun 2019
// @description: SFDC-525 Batch to calculate current annual value on active Contracts. This marks the Fixed Fee Line Item Schedule to Current=true. 
// 							Then a rollup summary field on Contract is used to calculate the contract's current year value using this Current flag.
// @LastModifiedBy: Harshit Singhal
// @LastModifiedDate: 15 July 2019
// @LastModifiedDescription: SFDC-1763 Update CLIS records partially to avoid a complete single batch failure, SFDC-1745 Update query criteria such that non-active contracts are also processed
// @LastModifiedBy: Harshit Singhal
// @LastModifiedDate: 14 Jul 2020
// @LastModifiedDescription: SFDC-3002 
// 							1) Remove inner query from start method. Move it to execute method as a separate query. This will avoid query locator error in batch.
// 							2) Added a variable 'inputQuery' to add flexibility to run batch for selective data
// @LastModifiedBy: Paras Dhingra
// @LastModifiedDate: 6th Dec 2020
// @LastModifiedDescription: SFDC-1994 add exception for Lost Contract LineItem and Historical fixed fee line items
// -----------------------------
public class BatchCalculateContractCurrentValue implements Database.Batchable<sObject>, Database.Stateful {
    public Boolean batchHasErrors = false;
	public String inputQuery = '';
    public String fixedFeeHistoryStatus = GlobalConstants.FIXED_FEE_HISTORY_STATUS;
    public String contractLineItemLostStatus = GlobalConstants.CONTRACT_LINE_ITEM_LOST_STATUS;
    public Database.QueryLocator start(Database.BatchableContext bc) {       
        System.debug(LoggingLevel.INFO, 'BatchCalculateContractCurrentValue BATCH START()');
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        List<Id> contractRecTypeIdList = new List<Id>{orderFormRecordTypeId, consultingRecordTypeId};
        
        //String contractQuery = 'SELECT Id,(SELECT Id, Current__c FROM ContractLineItemSchedules__r) FROM Contract WHERE RecordTypeId IN :contractRecTypeIdList';
        //String contractQuery = 'SELECT Id,(SELECT Id, Name, Current__c, Contract__c, Contract__r.ContractNumber FROM ContractLineItemSchedules__r) FROM Contract WHERE RecordTypeId IN :contractRecTypeIdList';
        String contractQuery = String.isNotBlank(inputQuery) ? inputQuery : 'SELECT Id FROM Contract WHERE RecordTypeId IN :contractRecTypeIdList';
        System.debug(LoggingLevel.INFO, 'contractQuery='+contractQuery);
        return Database.getQueryLocator(contractQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        System.debug(LoggingLevel.INFO, 'BatchCalculateContractCurrentValue BATCH EXECUTE() BEGINS');
        String currentFiscalYear = String.valueOf(UtilityClass.calculateFYFromDate(System.today(), 12));        
        List<String> recurringProductsAAGTypeList = new List<String>{'Subscription','SubscriptionVar'};
        Map<Id,List<ContractLineItemSchedule__c>> contractCLISMap = new Map<Id,List<ContractLineItemSchedule__c>>();
        for(ContractLineItemSchedule__c clisObj: [SELECT Id, Name, Current__c, Contract__c, Contract__r.ContractNumber FROM ContractLineItemSchedule__c WHERE Contract__c IN :scope]) {
            if(!contractCLISMap.containsKey(clisObj.Contract__c)) {
                contractCLISMap.put(clisObj.Contract__c,new List<ContractLineItemSchedule__c>{ clisObj });
            }
            else {
                List<ContractLineItemSchedule__c> existingCLIS = contractCLISMap.get(clisObj.Contract__c);
                existingCLIS.add(clisObj);
                contractCLISMap.put(clisObj.Contract__c,existingCLIS);
            }
        }
            
        //Approach 2: Similar to AO batch
        Map<String,Id> toActivateRecurringCLIScheduleMap = new Map<String,Id>();
        Map<String,Id> toActivateNonRecurringCLIScheduleMap = new Map<String,Id>();
        
        List<ContractLineItemSchedule__c> recurringCLISchedulesPastList = [SELECT Id, Contract__c,ContractLineItem__c
                                                                            FROM ContractLineItemSchedule__c
                                                                            WHERE Contract__c IN :scope
                                                                            AND ContractLineItem__c != null
                                                                            AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                            AND InstallmentYear__c!=null
                                                                            AND InstallmentYear__c <= :currentFiscalYear
																			AND Status__c!=:fixedFeeHistoryStatus
																			AND ContractLineItem__r.Status__c!=:contractLineItemLostStatus
                                                                            ORDER BY Contract__c,ContractLineItem__c, InstallmentYear__c DESC, CreatedDate DESC
                                                                            ];
        for(ContractLineItemSchedule__c clisRecurringPast: recurringCLISchedulesPastList) {
            String key = String.valueOf(clisRecurringPast.Contract__c) + String.valueOf(clisRecurringPast.ContractLineItem__c);
            if(!toActivateRecurringCLIScheduleMap.containsKey(key)) {
                toActivateRecurringCLIScheduleMap.put(key,clisRecurringPast.Id);
            }
        }
        
        List<ContractLineItemSchedule__c> recurringCLISchedulesFutureList = [SELECT Id, Contract__c,ContractLineItem__c,ContractLineItem__r.AssociatedProduct__c
                                                                                FROM ContractLineItemSchedule__c
                                                                                WHERE Contract__c IN :scope
                                                                                AND ContractLineItem__c != null
                                                                                AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                                AND InstallmentYear__c!=null
                                                                                AND InstallmentYear__c > :currentFiscalYear
																				AND Status__c!=:fixedFeeHistoryStatus
																				AND ContractLineItem__r.Status__c!=:contractLineItemLostStatus                                                                                
                                                                                ORDER BY Contract__c,ContractLineItem__c, InstallmentYear__c ASC, CreatedDate DESC
                                                                            ];
        for(ContractLineItemSchedule__c clisRecurringFuture: recurringCLISchedulesFutureList) {
            String key = String.valueOf(clisRecurringFuture.Contract__c) + String.valueOf(clisRecurringFuture.ContractLineItem__c);
            if(!toActivateRecurringCLIScheduleMap.containsKey(key)) {
                toActivateRecurringCLIScheduleMap.put(key,clisRecurringFuture.Id);
            }
        }
        List<ContractLineItemSchedule__c> nonRecurringCLISchedulesCurrentList = [SELECT Id, Contract__c,ContractLineItem__c,ContractLineItem__r.AssociatedProduct__c
                                                                                FROM ContractLineItemSchedule__c
                                                                                WHERE Contract__c IN :scope
                                                                                AND ContractLineItem__c != null
                                                                                AND ContractLineItem__r.AssociatedProduct__r.AAG__c NOT IN :recurringProductsAAGTypeList
                                                                                AND InstallmentYear__c!=null
                                                                                AND InstallmentYear__c = :currentFiscalYear
                                                                                ORDER BY Contract__c,ContractLineItem__c, CreatedDate DESC
                                                                            ];                                                                            
        for(ContractLineItemSchedule__c clisNonRecurringCurrent: nonRecurringCLISchedulesCurrentList) {
            String key = String.valueOf(clisNonRecurringCurrent.Contract__c) + String.valueOf(clisNonRecurringCurrent.ContractLineItem__c);
            if(!toActivateNonRecurringCLIScheduleMap.containsKey(key)) {
                toActivateNonRecurringCLIScheduleMap.put(key,clisNonRecurringCurrent.Id);
            }
        }

        //Segregate schedules to be marked as Current from Non-current schedules
        List<ContractLineItemSchedule__c> clisToUpdateList = new List<ContractLineItemSchedule__c>();
        Set<Id> toActivateRecurringCLIScheduleIdSet = new Set<Id>();
        toActivateRecurringCLIScheduleIdSet.addAll(toActivateRecurringCLIScheduleMap.values());
        Set<Id> toActivateNonRecurringCLIScheduleIdSet = new Set<Id>();
        toActivateNonRecurringCLIScheduleIdSet.addAll(toActivateNonRecurringCLIScheduleMap.values());
		
        for(Contract conObj: (List<Contract>)scope) {            
            //for(ContractLineItemSchedule__c clisObj: conObj.ContractLineItemSchedules__r) {
            if(contractCLISMap.containsKey(conObj.Id) && contractCLISMap.get(conObj.Id)!=null) {
                for(ContractLineItemSchedule__c clisObj: contractCLISMap.get(conObj.Id)) {
                    if(toActivateRecurringCLIScheduleIdSet.contains(clisObj.Id) || toActivateNonRecurringCLIScheduleIdSet.contains(clisObj.Id)) {
                        if(!clisObj.Current__c) {
                            clisObj.Current__c = true;
                            clisToUpdateList.add(clisObj);
                        }                    
                    }
                    else {
                        if(clisObj.Current__c) {
                            clisObj.Current__c = false;
                            clisToUpdateList.add(clisObj);
                        }
                    }                    
                }                
            }
            
        }
		
        //Update the Schedules
        if(clisToUpdateList!=null && clisToUpdateList.size() > 0) {
            try {
                //update clisToUpdateList;                
                Database.SaveResult[] srList = Database.update(clisToUpdateList, false);
                List<ApexLogger__c> logRecList = new List<ApexLogger__c>();                
                Integer counter = 0;
                for (Database.SaveResult sr : srList) {                    
                    if (!sr.isSuccess()) {                        
                        for(Database.Error err : sr.getErrors()) {
                            //String description = '\n Error Record Id : '+clisToUpdateList[counter].Id+'\n Status Code: '+err.getStatusCode()+'\n Error Message : '+ err.getMessage()+ '\n Error Fields: '+ err.getFields();
                            //String description = '\n Fixed Fee Schedule Record Id : '+ clisToUpdateList[counter].Id + '\n Contract Number : ' + clisToUpdateList[counter].Contract__r.ContractNumber + '\n Error Message : ' + err.getMessage();
                            //logRecList.add(new ApexLogger__c(ClassName__c='BatchCalculateContractCurrentValue', FunctionName__c='Execute', ErrorDescription__c=description));
                            logRecList.add(new ApexLogger__c(ClassName__c='BatchCalculateContractCurrentValue', FunctionName__c='Execute', LogRecordId__c=clisToUpdateList[counter].Id, LogRecordName__c=clisToUpdateList[counter].Name, LogParentRecordId__c=clisToUpdateList[counter].Contract__c, LogParentRecordName__c=clisToUpdateList[counter].Contract__r.ContractNumber, ErrorDescription__c=err.getMessage()));
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
            catch (Exception ex) {
                batchHasErrors = true;
                UtilityClass.createApexLogRecord(ex, 'BatchCalculateContractCurrentValue', 'Execute');                
            }
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'BatchCalculateContractCurrentValue BATCH FINISH()');
        //Send Email if Errors in batch processing
        if(batchHasErrors) {            
            String[] toAddresses = new String[] {System.Label.OpptyPrimaryContactBatchEmail};
            //String[] toAddresses = new String[] {'harshit.singhal@ihsmarkit.com'};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.OpptyPrimaryContactBatchEmail);            
            mail.setSubject('Calculate Contract Current Value Batch Processing contains error');
            mail.setPlainTextBody('Please see Apex Log records to view errors of BatchCalculateContractCurrentValue batch class job in detail.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}