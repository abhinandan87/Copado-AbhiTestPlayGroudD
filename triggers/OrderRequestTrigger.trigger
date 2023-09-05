//-----------------------------
// @author: Anjali
// @date: 17 June 2021
// @param: Trigger events
// @description: Order Request trigger 
// @return: NA
//-----------------------------
trigger OrderRequestTrigger on OrderRequest__c (after update, after insert, before update,before insert,after delete) {
        //call trigger factory to create Order Request trigger dispatcher
        TriggerFactory.createTriggerDispatcher(OrderRequest__c.sObjectType);

}