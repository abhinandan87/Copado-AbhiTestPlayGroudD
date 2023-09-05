trigger FieldServiceActivityProductTrigger on FieldServiceActivityProduct__c (after insert, after update) {
    TriggerFactory.createTriggerDispatcher(FieldServiceActivityProduct__c.sObjectType);
}