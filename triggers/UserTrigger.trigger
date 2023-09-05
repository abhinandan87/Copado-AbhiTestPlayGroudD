//-----------------------------
// @author: Tran-Vu Tran
// @date: 24th April 2018
// @param: Trigger events
// @description: User trigger 
// @return: NA
//-----------------------------

trigger UserTrigger on User(before insert, before update, after insert, after update) {
    //call trigger factory to create User trigger dispatcher
    TriggerFactory.createTriggerDispatcher(User.sObjectType);
}