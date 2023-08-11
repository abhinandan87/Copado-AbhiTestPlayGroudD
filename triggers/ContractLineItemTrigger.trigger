//-----------------------------
// @author: Jagadesh Kumar
// @date: 20 Dec 2018
// @param: Trigger events
// @description: ContractLineItem__c trigger 
// @return: NA
//-----------------------------
trigger ContractLineItemTrigger on ContractLineItem__c (before update, after insert, after update, after delete,before delete) {
	//call trigger factory to create Contract trigger dispatcher
    TriggerFactory.createTriggerDispatcher(ContractLineItem__c.sObjectType);
}