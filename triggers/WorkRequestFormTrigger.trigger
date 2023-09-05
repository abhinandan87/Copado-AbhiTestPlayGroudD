//-----------------------------
// @author: Madhusudhan karna
// @date: 06 May 2021
// @param: Trigger events
// @description: Work Request Form trigger 
// @return: NA
//-----------------------------

trigger WorkRequestFormTrigger on WorkRequestForm__c(before insert, before update, before delete, after insert, after update) {
    
    //call trigger factory to create case trigger dispatcher
    TriggerFactory.createTriggerDispatcher(WorkRequestForm__c.sObjectType);

}