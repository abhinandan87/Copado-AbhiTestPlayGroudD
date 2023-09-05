//-----------------------------
// @author: Harshit Singhal
// @date: 27 Apr 2020
// @param: Trigger events
// @description: SFDC-2865 SetupEvents__e Platform Event trigger
// 
// @return: NA
//-----------------------------
trigger SetupEventsTrigger on SetupEvents__e (after insert) {
    TriggerFactory.createTriggerDispatcher(SetupEvents__e.sObjectType);
}