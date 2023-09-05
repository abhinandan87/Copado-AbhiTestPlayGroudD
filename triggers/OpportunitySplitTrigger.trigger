Trigger OpportunitySplitTrigger on OpportunitySplit (after insert, after update, after delete, before insert, before update) {
    
     TriggerFactory.createTriggerDispatcher(OpportunitySplit.sObjectType);
     
}