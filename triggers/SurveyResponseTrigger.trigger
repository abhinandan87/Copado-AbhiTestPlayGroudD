//-----------------------------
// @author: Manish Kumar
// @date: 29 July 2021
// @param: Trigger events
// @description: SFDC-4232 SurveyResponseTrigger
// @return: NA
//-----------------------------

trigger SurveyResponseTrigger on SurveyResponse__c (before insert, after insert, after update) {
    //call trigger factory to create Survey Response trigger dispatcher
    TriggerFactory.createTriggerDispatcher(SurveyResponse__c.sObjectType);
}