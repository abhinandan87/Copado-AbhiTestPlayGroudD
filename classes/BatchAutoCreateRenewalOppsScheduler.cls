//-----------------------------
// @author: Harshit Singhal
// @date: 24 Aug 2020
// @description: SFDC-3186 Scheduler class for BatchAutoCreateRenewalOpps batch class. 
// 					- Scope size for batch is derived from AutomatedRenewalsConfig__c org default custom setting record. Default is 200.
//-----------------------------
public class BatchAutoCreateRenewalOppsScheduler implements Schedulable {        
    public void execute(SchedulableContext ctx) {        
        //Get batch scope size
        AutomatedRenewalsConfig__c renewalsOrgDefaultConfig = AutomatedRenewalsConfig__c.getOrgDefaults();
        Integer scopeSize=renewalsOrgDefaultConfig!=null && renewalsOrgDefaultConfig.RenewalsBatchSize__c!=null && Integer.valueOf(renewalsOrgDefaultConfig.RenewalsBatchSize__c)>0 ? Integer.valueOf(renewalsOrgDefaultConfig.RenewalsBatchSize__c) : 200;
        //Run batch
        Database.executeBatch(new BatchAutoCreateRenewalOpps(),scopeSize);
    }
}