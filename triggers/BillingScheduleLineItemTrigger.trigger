trigger BillingScheduleLineItemTrigger on BillingScheduleLineItem__c(before insert, after insert, after update, after delete) {

    TriggerFactory.createTriggerDispatcher(BillingScheduleLineItem__c.sObjectType);
}