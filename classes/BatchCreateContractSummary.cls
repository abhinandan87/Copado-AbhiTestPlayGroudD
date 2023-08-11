//-----------------------------
// @author: Harshit Singhal
// @date: 12 July 2018
// @description: SFDC1-5228 This class creates Approved Contract Summary data for all accounts
// @Last Modified By : Uttam Arya
// @Last Modified Date : 7 March 2019
// @Last Modified Description- SFDC-899 - Products not appearing under the Contract Summary. Changed the contract selection filter to select from Renewal Date greater than today 
//                    instead of EndDate and added contractStatusIncludeList = {'Validated','Validated PO Pending','Invoiced'}
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 23 Apr 2019
// @Last Modified Description: SFDC-900: Changes in calculation of Recurring and Non-recurring contracts schedules
// @Last Modified By : Uttam Arya
// @Last Modified Date : 1 May 2019
// @Last Modified Description- SFDC-1471 - In the Active Contract Summary section - instead of using the contract end date - using Renewal Date
// @LastModifiedBy: Paras Dhingra
// @LastModifiedDate: 6th Dec 2020
// @LastModifiedDescription: SFDC-1994 add exception for Lost Contract LineItem and Historical fixed fee line items
//-----------------------------
global class BatchCreateContractSummary implements Database.Batchable<sObject> {
    global String errorMsgs = '';
    public String fixedFeeHistoryStatus = GlobalConstants.FIXED_FEE_HISTORY_STATUS;
    public String contractLineItemLostStatus = GlobalConstants.CONTRACT_LINE_ITEM_LOST_STATUS;
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //return Database.getQueryLocator('SELECT Id FROM Account WHERE Number_of_Approved_Contracts__c >= 0');
        System.debug('@HS BATCH START()');
        return Database.getQueryLocator('SELECT Id FROM Account');
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('@HS BATCH EXECUTE() BEGINS');
        //PART 1 Variables
        Set<id> accountIDs = new Set<Id>();
        Map<String, ApprovedContractSummary__c> acsMap = new Map<String, ApprovedContractSummary__c>();
        List<ApprovedContractSummary__c> acsMapBillingSchedule = new List<ApprovedContractSummary__c>();
        List<String> recurringProductsAAGTypeList = new List<String>{'Subscription','SubscriptionVar'};
        
        //PART 1: Collect accounts, delete existing contract summaries and create dummy Approved Contract Summary records
        System.debug('@HS scope size='+scope.size());
        for(sObject acc: scope) {
            Account a = (Account) acc;
            accountIDs.add(a.id);
        }
        
        if(accountIDs != null && accountIDs.size() > 0) {
            //Pre clean all the Aproved Contract Summary data
            List<ApprovedContractSummary__c> acsToDeletePreClean = [SELECT id FROM ApprovedContractSummary__c WHERE Account__c in :accountIDs];            
            System.debug('@HS acsToDeletePreClean='+acsToDeletePreClean);
            if(acsToDeletePreClean != null && acsToDeletePreClean.size() > 0) {
                delete acsToDeletePreClean;
            }
            
            //Fetch active Contract records            
            List<Contract> contractsList = [SELECT Id, AccountId, EndDate, ContractNumber, BillingFrequency__c, RenewalDate__c,
                                            (SELECT ContractLineItem__r.AssociatedProduct__r.ProductGroup__r.Name FROM ContractLineItemSchedules__r), 
                                            (Select Id From Contract_Line_Items__r)                                            
                                            FROM Contract 
                                            WHERE Account.Id in :accountIDs 
                                            AND Active__c=true
                                            ORDER BY RenewalDate__c DESC
                                           ];
            System.debug('@HS contractsList size='+contractsList.size());
            System.debug('@HS contractsList='+contractsList);
            
            Map<Id, Contract> mapContracts =  new Map <Id, Contract>();            
            //Prepare unique Approved Contract Summary records from CLI Schedules
            for (Contract con : contractsList) {
                if(con.Contract_Line_Items__r != null && con.Contract_Line_Items__r.size() > 0) {                           //Added a condition to check atleast one child line item to properly implement ContractAprroved=true condition in new org
                    mapContracts.put(con.Id,con);
                    for(ContractLineItemSchedule__c  cbs: con.ContractLineItemSchedules__r) {
                        String prodGroupName = cbs.ContractLineItem__r.AssociatedProduct__r.ProductGroup__r.Name;       //?? Add null checkS
                        String Key = con.AccountId + prodGroupName;
                        System.debug('@HS Contract Id: ' + Con.Id + 'Product Group: ' + prodGroupName);
                        acsMap.put(key, new ApprovedContractSummary__c( Account__c = con.AccountId, AnnualContractValue__c = null, ProductFamily__c = prodGroupName
                                                                       , EarliestContractEndDate__c = con.RenewalDate__c, BillingFrequency__c = con.BillingFrequency__c
                                                                       , Key__c = Key,ContractNumber__c = con.ContractNumber));
                    }
                }
            }
            System.debug('@HS mapContracts size='+mapContracts.size());
            System.debug('@HS mapContracts='+mapContracts);
            System.debug('@HS acsMap size='+acsMap.size());
            System.debug('@HS acsMap='+acsMap);
            
            //Insert Approved Contract Summary records
            if(acsMap != null && acsMap.size() > 0) {
                Schema.SObjectField f = ApprovedContractSummary__c.Fields.Key__c;
                List<Database.UpsertResult> upsertResult = Database.upsert(acsMap.values(), f, false);
                for(Integer i=0;i< upsertResult.size();i++) {
                    if(!upsertResult.get(i).isSuccess()) {
                        Database.Error error = upsertResult.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        errorMsgs += 'ACS rec: '+', '+failedDML+'<\br>';
                        System.debug('@HS Error during acs record upsert. DML Error='+failedDML);
                    }
                }
                System.debug('@HS After acsMap upsert Error Messages='+errorMsgs);
                System.debug('@HS UPSERT1 complete.');                
            }
            
            //PART 2: Fetch current year Schedules using Instalment Year
            String CURRENTYEAR = String.valueOf(UtilityClass.calculateFYFromDate(System.today(), 12));
            Map<String,Id> toQueryRecurringCLIScheduleMap = new Map<String,Id>();
            
            List<ContractLineItemSchedule__c> recurringCLISchedulesPastList = [SELECT Id, Contract__c,ContractLineItem__c,ContractLineItem__r.AssociatedProduct__c
                                                                               FROM ContractLineItemSchedule__c
                                                                               WHERE Contract__r.AccountId = :accountIDs 
                                                                               AND Contract__r.Active__c=true
                                                                               AND ContractLineItem__c != null
                                                                               AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                               AND InstallmentYear__c <= :CURRENTYEAR 
                                                                               AND InstallmentYear__c!=null
                                                                               AND Status__c!=:fixedFeeHistoryStatus
                                                                               AND ContractLineItem__r.Status__c!=:contractLineItemLostStatus
                                                                               ORDER BY Contract__c,ContractLineItem__c, InstallmentYear__c DESC, CreatedDate DESC
                                                                              ];
            for(ContractLineItemSchedule__c clisRecurringPast: recurringCLISchedulesPastList) {
                String key = String.valueOf(clisRecurringPast.Contract__c) + String.valueOf(clisRecurringPast.ContractLineItem__r.AssociatedProduct__c);
                if(!toQueryRecurringCLIScheduleMap.containsKey(key)) {
                    toQueryRecurringCLIScheduleMap.put(key,clisRecurringPast.Id);
                }                
            }
            System.debug('recurringCLISchedulesPastList size='+recurringCLISchedulesPastList.size());
            System.debug('AFTER PAST:toQueryRecurringCLIScheduleMap size='+toQueryRecurringCLIScheduleMap.size());            
            
            List<ContractLineItemSchedule__c> recurringCLISchedulesFutureList = [SELECT Id, Contract__c,ContractLineItem__c,ContractLineItem__r.AssociatedProduct__c
                                                                                 FROM ContractLineItemSchedule__c
                                                                                 WHERE Contract__r.AccountId = :accountIDs 
                                                                                 AND Contract__r.Active__c=true
                                                                                 AND ContractLineItem__c != null
                                                                                 AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                                 AND InstallmentYear__c > :CURRENTYEAR
                                                                                 AND InstallmentYear__c!=null
                                                                                 AND Status__c!=:fixedFeeHistoryStatus
                                                                                 AND ContractLineItem__r.Status__c!=:contractLineItemLostStatus
                                                                                 ORDER BY Contract__c,ContractLineItem__c, InstallmentYear__c ASC, CreatedDate DESC
                                                                                ];
            for(ContractLineItemSchedule__c clisRecurringFuture: recurringCLISchedulesFutureList) {
                String key = String.valueOf(clisRecurringFuture.Contract__c) + String.valueOf(clisRecurringFuture.ContractLineItem__r.AssociatedProduct__c);
                if(!toQueryRecurringCLIScheduleMap.containsKey(key)) {
                    toQueryRecurringCLIScheduleMap.put(key,clisRecurringFuture.Id);
                }
            }
            System.debug('recurringCLISchedulesFutureList size='+recurringCLISchedulesFutureList.size());
            System.debug('AFTER FUTURE:toQueryRecurringCLIScheduleMap size='+toQueryRecurringCLIScheduleMap.size());            
                        
            /*
            //PART 2: Fetch current year Schedules using Billing Date
            Map<String,Date> billingDateMap = new Map<String,Date>();
            Set<Id> recurringCLIScheduleIds = new Set<Id>();
            AggregateResult[] groupedContractsCLIScheduleMaxDatePast = [SELECT MAX(BillingDate__c) maxBillingDate, Contract__c, ContractLineItem__r.AssociatedProduct__c productId
                                                                       FROM ContractLineItemSchedule__c
                                                                       WHERE Contract__r.AccountId = :accountIDs 
                                                                        AND Contract__r.Active__c=true
                                                                        AND ContractLineItem__c != null    
                                                                        AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                        AND BillingDate__c <= Today
                                                                       GROUP BY Contract__c,ContractLineItem__r.AssociatedProduct__c];
            
            AggregateResult[] groupedContractsCLIScheduleMinDateFuture = [SELECT MIN(BillingDate__c) minBillingDate, Contract__c, ContractLineItem__r.AssociatedProduct__c productId
                                                                       FROM ContractLineItemSchedule__c
                                                                       WHERE Contract__r.AccountId = :accountIDs 
                                                                        AND Contract__r.Active__c=true
                                                                        AND ContractLineItem__c != null    
                                                                        AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                        AND BillingDate__c > Today
                                                                       GROUP BY Contract__c,ContractLineItem__r.AssociatedProduct__c];
            
            for(AggregateResult ar: groupedContractsCLIScheduleMaxDatePast) {
                Date maxBillingDate = ar.get('maxBillingDate') != null? Date.valueOf(ar.get('maxBillingDate')) : null;
                String contractId = ar.get('Contract__c') != null ? String.valueOf(ar.get('Contract__c')) : '';
                String productId = ar.get('productId') != null ? String.valueOf(ar.get('productId')) : '';
                if(!billingDateMap.containsKey(contractId+productId)) {
                    billingDateMap.put(contractId+productId, maxBillingDate);
                    System.debug('Contract Id='+contractId+' ; maxBillingDate='+maxBillingDate);
                }
            }
            for(AggregateResult ar: groupedContractsCLIScheduleMinDateFuture) {
                Date minBillingDate = ar.get('minBillingDate') != null? Date.valueOf(ar.get('minBillingDate')) : null;
                String contractId = ar.get('Contract__c') != null ? String.valueOf(ar.get('Contract__c')) : '';
                String productId = ar.get('productId') != null ? String.valueOf(ar.get('productId')) : '';
                if(!billingDateMap.containsKey(contractId+productId)) {
                    billingDateMap.put(contractId+productId, minBillingDate);
                    System.debug('Contract Id='+contractId+' ; minBillingDate='+minBillingDate);
                }
            }            
            */
            
            //PART 3:
            //Fetch totals of Recurring and Non-Recurring CLIS records
            Map<String, ApprovedContractSummary__c> mapACSContractValue = new Map<String, ApprovedContractSummary__c>();
            AggregateResult[] groupedContractsBillingScheduleTotalsRecurring = [SELECT SUM(SalesPrice__c) sumAnnualRev, Contract__r.AccountId accountid,  ContractLineItem__r.AssociatedProduct__r.ProductGroup__r.Name pf
                                                                                FROM ContractLineItemSchedule__c 
                                                                                WHERE Contract__r.AccountId = :accountIDs 
                                                                                AND Contract__r.Active__c=true
                                                                                AND ContractLineItem__c != null    
                                                                                AND ContractLineItem__r.AssociatedProduct__r.AAG__c IN :recurringProductsAAGTypeList
                                                                                AND Id IN :toQueryRecurringCLIScheduleMap.values()
                                                                                AND Status__c!=:fixedFeeHistoryStatus
                                                                                AND ContractLineItem__r.Status__c!=:contractLineItemLostStatus
                                                                                GROUP BY Contract__r.AccountId, ContractLineItem__r.AssociatedProduct__r.ProductGroup__r.Name];
            
            AggregateResult[] groupedContractsBillingScheduleTotalsNonRecurring = [SELECT SUM(SalesPrice__c) sumAnnualRev, Contract__r.AccountId accountid,  ContractLineItem__r.AssociatedProduct__r.ProductGroup__r.Name pf
                                                                                   FROM ContractLineItemSchedule__c 
                                                                                   WHERE Contract__r.AccountId = :accountIDs 
                                                                                   AND Contract__r.Active__c=true
                                                                                   AND ContractLineItem__c != null    
                                                                                   AND ContractLineItem__r.AssociatedProduct__r.AAG__c NOT IN :recurringProductsAAGTypeList
                                                                                   AND InstallmentYear__c = :CURRENTYEAR
                                                                                   GROUP BY Contract__r.AccountId, ContractLineItem__r.AssociatedProduct__r.ProductGroup__r.Name];
            
            //Process Contracts that contain Subscription/Recurring type products
            for (AggregateResult ar : groupedContractsBillingScheduleTotalsRecurring) {
                Decimal SumAnnualRevenue = ar.get('sumAnnualRev') != null? Decimal.valueOf(double.valueOf(ar.get('sumAnnualRev'))): 0;
                String AccountId = ar.get('accountid') != null? String.valueof(ar.get('accountid')): '';
                String PFamlies = ar.get('pf') != null? String.valueof(ar.get('pf')): '';
                List<String> familyList  = PFamlies.split(',');                 //?? Is this split on prod group name required?
                for(String pf: familyList) {
                    String Key = AccountId + pf;
                    mapACSContractValue.put(Key, new ApprovedContractSummary__c(RevenueType__c= 'Recurring', Account__c=AccountId,AnnualContractValue__c=SumAnnualRevenue,ProductFamily__c=pf, Key__c = Key));
                }                
                System.debug('@HS PF: ' + PFamlies + ' Recurring Amount: ' + SumAnnualRevenue);            
            }
            
            //Process Contracts that contain One off/Non-Recurring type products
            for(AggregateResult ar : groupedContractsBillingScheduleTotalsNonRecurring) { 
                
                Decimal SumAnnualRevenue = ar.get('sumAnnualRev') != null? Decimal.valueOf(double.valueOf(ar.get('sumAnnualRev'))): 0;
                String AccountId = ar.get('accountid') != null? String.valueof(ar.get('accountid')): '';
                String PFamlies = ar.get('pf') != null? String.valueof(ar.get('pf')): '';
                List<String> familyList  = PFamlies.split(',');
                for(String pf: familyList) {
                    String Key = AccountId + pf;
                    if(mapACSContractValue.get(Key) == null){
                        mapACSContractValue.put(Key, new ApprovedContractSummary__c(RevenueType__c= 'Non-recurring',Account__c=AccountId,AnnualContractValue__c=SumAnnualRevenue,ProductFamily__c=pf, Key__c = Key));
                    }
                    else {
                        String revenueTypeStr = mapACSContractValue.get(Key).RevenueType__c;
                        revenueTypeStr += ' & Non-recurring';
                        mapACSContractValue.put(Key, new ApprovedContractSummary__c(RevenueType__c= revenueTypeStr,Account__c=AccountId,AnnualContractValue__c= (SumAnnualRevenue + mapACSContractValue.get(Key).AnnualContractValue__c),ProductFamily__c=pf, Key__c = Key));
                    }
                }                
                System.debug('PF: ' + PFamlies + ' Non-recurring Amount: ' + SumAnnualRevenue);             
            }
            
            //Finally Update ACS records
            acsMapBillingSchedule.addAll(mapACSContractValue.values());
            
            if(acsMapBillingSchedule != null && acsMapBillingSchedule.size() > 0) {
                Schema.SObjectField f = ApprovedContractSummary__c.Fields.Key__c;
                List<Database.UpsertResult> upsertResult = Database.upsert(acsMapBillingSchedule, f, false);
                for(Integer i=0;i< upsertResult.size();i++) {
                    if(!upsertResult.get(i).isSuccess()) {
                        Database.Error error = upsertResult.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        errorMsgs += 'ACS rec: ' + acsMapBillingSchedule.get(i).Id+', '+failedDML+'<\br>';
                        System.debug('@HS Failure in acsMapBillingSchedule Map UPSERT2. Error='+failedDML);
                    }
                }
                System.debug('@HS UPSERT2 complete.');                
            }
        }
        System.debug('@HS BATCH EXECUTE() ENDS');
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('@HS BATCH FINISH()');
        //Call Support Overview Batch here in next phase
        //Database.executeBatch(new BatchCalCasesSummarySupportOverview(), 1);        
    }
}