//-----------------------------
// @author: Harshit Singhal
// @date: 27 March 2020
// @param: Trigger events
// @description: SFDC-2748 MeetingNote trigger
// 
// @return: NA
//-----------------------------
trigger MeetingNoteTrigger on MeetingNote__c (before insert, after insert, before update, after update) {
	//call trigger factory to create MeetingNote trigger dispatcher
    TriggerFactory.createTriggerDispatcher(MeetingNote__c.sObjectType);
}