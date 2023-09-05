trigger SetApexLoggerEventsTrigger on SetApexLoggerEvent__e (after Insert) {
    TriggerFactory.createTriggerDispatcher(SetApexLoggerEvent__e.sObjectType);
}