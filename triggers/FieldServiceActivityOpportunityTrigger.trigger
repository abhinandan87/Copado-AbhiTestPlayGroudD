/**
* @author: Shikhar Singh
* @date: 06 June 2022
* @param: Trigger events
* @description: SFDC-5786. Trigger for Field Service Activity Opportunities 
* @companyname: NA
*/
trigger FieldServiceActivityOpportunityTrigger on FieldServiceActivityOpportunity__c (after insert,after update, after delete) {
    //call trigger factory to create case trigger dispatcher
    TriggerFactory.createTriggerDispatcher(FieldServiceActivityOpportunity__c.sObjectType);
}