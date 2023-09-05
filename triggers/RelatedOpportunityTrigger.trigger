//-----------------------------
// @author: Priyanka Vyas
// @date: 22 June 2020
// @param: Trigger events
// @description: Related Opportunity trigger 
// @return: NA
//-----------------------------
trigger RelatedOpportunityTrigger on RelatedOpportunity__c (after insert, after update, after delete,before insert,before update) {
    //call trigger factory to create case trigger dispatcher
    TriggerFactory.createTriggerDispatcher(RelatedOpportunity__c.sObjectType);
    
}