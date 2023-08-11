//-----------------------------
// @author: Vishnu Vardhan Chowdary Andra
// @date: 17 December 2018
// @param: Trigger events
// @description: Product Login Contact Associationtrigger 
// @return: NA
//-----------------------------
trigger ProductLoginContactAssociationTrigger on ProductLoginContactAssociation__c (before insert) {
    //call trigger factory to create Product Login trigger dispatcher
    TriggerFactory.createTriggerDispatcher(ProductLoginContactAssociation__c.sObjectType);
}