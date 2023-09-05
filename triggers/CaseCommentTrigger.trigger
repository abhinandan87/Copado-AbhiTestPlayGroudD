//-----------------------------
// @author: Digvijay Singh
// @date: 23 March 2021
// @param: Trigger events
// @description: SFDC-3511 Case Comment trigger 
// @return: NA
//-----------------------------
trigger CaseCommentTrigger on CaseComment (after insert, after update)  {
    TriggerFactory.createTriggerDispatcher(CaseComment.sObjectType);    
}