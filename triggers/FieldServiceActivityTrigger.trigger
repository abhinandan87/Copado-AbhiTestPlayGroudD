trigger FieldServiceActivityTrigger on WorkOrder (after Update) {
    TriggerFactory.createTriggerDispatcher(WorkOrder.sObjectType);
}