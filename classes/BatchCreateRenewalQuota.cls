//-------------------------------------
// @author: Mohit Parnami
// @date: 14 June 2021
// @description: SFDC-4123 This class upserts Quota records of Renewal Opportunities. 
// @Last Modified By : Akash Punera
// @Last Modified Date : 20 June 2022
// @Last Modified Description : SFDC-5841 Updated filter logic to include account managers and remove error oppies
// -------------------------------------------------
global class BatchCreateRenewalQuota implements Database.Batchable<sObject>, Database.Stateful {
    global  Map<String, Decimal> mapSplitOwnerToRenewalQuota;

    global BatchCreateRenewalQuota() {
        mapSplitOwnerToRenewalQuota = new Map<String, Decimal>();
    }
	public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, SplitOwnerId, SplitPercentage, OpportunityId, convertcurrency(Opportunity.SalesRenewal__c), convertcurrency(Opportunity.SalesLostBus__c), Opportunity.ContinuationEndDate__c,'; 
        query += ' Opportunity.ContractStartDate__c,Opportunity.SalesRenewalUSD__c, SplitOwner.EmployeeNumber__c';
        query += ' From OpportunitySplit';
        query += ' WHERE Opportunity.RecordType.Name = \'Renewal\'';
        
        //SFDC-5841 added filters for renewal quota
        query += 'AND Opportunity.lostReasonCode__c not in (\'Created in Error\',\'Duplicate/Existing Opp\')';
        query += ' AND (not opportunity.account.type like \'Place Holder -%\')';
            
        query += ' AND (SplitOwner.GlobalVertical__c = \'Financial Markets\' OR SplitOwner.GlobalVertical__c = \'Financial Services: Financial Market Technologies\' OR SplitOwner.GlobalVertical__c = \'Financial Services: Financial Markets\')';
        //query += ' AND SplitType.MasterLabel = \'Sales Specialists\''; SFDC-5841 Commenting the Sales Specialists filter 
        query += ' AND Opportunity.ContractStartDate__c != null';
        query += ' AND ((Opportunity.ContractStartDate__c <=  NEXT_N_YEARS:2';
        query += ' AND Opportunity.ContractStartDate__c >=  LAST_N_YEARS:2)';
        query += '  OR (Opportunity.ContinuationEndDate__c <= NEXT_N_YEARS:2 AND Opportunity.ContinuationEndDate__c >=  LAST_N_YEARS:2))';

        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OpportunitySplit> lstOppSplit) {
        List<Quota__c> listQuotaToUpsert = new List<Quota__c>();
        Map<String, OpportunitySplit> mapKeyToOppSplit = new Map<String, OpportunitySplit>();
        Map<String, Date> mapKeyToDate = new Map<String, Date>();

        for(OpportunitySplit oppSplit : lstOppSplit) {
            if(oppSplit.SplitOwner != null && oppSplit.SplitOwner.EmployeeNumber__c != null) {
                String key = '';
                //If extended opportunity, use ContinuationEndDate__c field to calculate quota
                if(oppSplit.Opportunity.ContinuationEndDate__c != null) {
                    key = oppSplit.SplitOwner.EmployeeNumber__c + '_' + oppSplit.Opportunity.ContinuationEndDate__c.Year() + '_' + oppSplit.Opportunity.ContinuationEndDate__c.Month() + '_011';
                    //+ oppSplit.SplitOwner.QuotaManager__r.EmployeeNumber__c + '_'
                    mapKeyToDate.put(key, oppSplit.Opportunity.ContinuationEndDate__c);
                } else {
                    key = oppSplit.SplitOwner.EmployeeNumber__c + '_' + oppSplit.Opportunity.ContractStartDate__c.Year() + '_' + oppSplit.Opportunity.ContractStartDate__c.Month() + '_011';
                    //+ oppSplit.SplitOwner.QuotaManager__r.EmployeeNumber__c + '_'
                    mapKeyToDate.put(key, oppSplit.Opportunity.ContractStartDate__c);
                }
                
                Decimal renewalQuota =  ((oppSplit.Opportunity.SalesRenewalUSD__c + oppSplit.Opportunity.SalesLostBus__c) * oppSplit.SplitPercentage)/100;
                if(renewalQuota != null) {
                    if(!mapSplitOwnerToRenewalQuota.containsKey(key)) {
                        mapSplitOwnerToRenewalQuota.put(key, renewalQuota);
                    } else {
                        Decimal totalRenewalOpp = mapSplitOwnerToRenewalQuota.get(key) + renewalQuota;
                        mapSplitOwnerToRenewalQuota.put(key, totalRenewalOpp);
                    }
                }
                
                mapKeyToOppSplit.put(key, oppSplit);
            }
        }
        //system.debug('===mapSplitOwnerToRenewalQuota size===' + mapSplitOwnerToRenewalQuota.size());
        //system.debug('===mapSplitOwnerToRenewalQuota===' + mapSplitOwnerToRenewalQuota);
        for(String key : mapSplitOwnerToRenewalQuota.keySet()) {
            if(mapKeyToOppSplit.containsKey(key)) {
                Quota__c renQuota = new Quota__c(OverlayQuota__c = 0, DirectQuota__c = 0, TeamQuota__c = 0, AllocateQuota__c = 0, OpenPositionQuota__c = 0, IndividualQuota__c = 0, OpenPositionCount__c =0);
                renQuota.ExternalId__c = key+'_024_R';//Create quota with businessline as other
                renQuota.OwnerId = mapKeyToOppSplit.get(key).SplitOwnerId != null ? mapKeyToOppSplit.get(key).SplitOwnerId : null;
                //renQuota.Manager__c = mapKeyToOppSplit.get(key).SplitOwnerId != null && mapKeyToOppSplit.get(key).SplitOwner.QuotaManager__c != null ? mapKeyToOppSplit.get(key).SplitOwner.QuotaManager__c : null;
                renQuota.QuotaAmount__c = mapSplitOwnerToRenewalQuota.get(key);
                renQuota.OfferingType__c = 'Renewal';
                renQuota.Source__c = 'Salesforce';
                renQuota.GlobalVertical__c = 'Financial Markets';
                if(mapKeyToDate.get(key) != null) {
                    renQuota.QuotaPeriod__c = mapKeyToDate.get(key) != null ? mapKeyToDate.get(key).toStartOfMonth() : null;
                }
                
                //renQuota.QuotaPeriod__c = mapKeyToOppSplit.get(key).Opportunity.ContractStartDate__c != null ? mapKeyToOppSplit.get(key).Opportunity.ContractStartDate__c.toStartOfMonth() : null;
                
                listQuotaToUpsert.add(renQuota);
            }
        }
        //system.debug('===listQuotaToUpsert size===' + listQuotaToUpsert.size());
        //system.debug('===listQuotaToUpsert===' + listQuotaToUpsert);
        if(!listQuotaToUpsert.isEmpty()) {
            upsert listQuotaToUpsert ExternalId__c;
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('@HS BATCH FINISH()');
        //Call Support Overview Batch here in next phase
        //Database.executeBatch(new BatchCalCasesSummarySupportOverview(), 1);        
    }
}