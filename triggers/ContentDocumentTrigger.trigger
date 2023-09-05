//-----------------------------
// @author: Sharique Iqbal
// @date: 18 Aug 2021
// @param: Trigger events
// @description: SFDC-4182 ContentDocument trigger 
// @return: NA
//-----------------------------
trigger ContentDocumentTrigger on ContentDocument (before delete, after delete) {
    
    //call trigger factory to create ContentDocument trigger dispatcher
    TriggerFactory.createTriggerDispatcher(ContentDocument.sObjectType); 
}