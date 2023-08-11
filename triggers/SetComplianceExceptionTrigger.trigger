//-----------------------------
// @author: Priyanka Vyas
// @date: 22 Oct 2020
// @param: NA
// @description: SFDC-3123 trigger for SetComplianceException__e platform event 
// @return: NA
//-----------------------------
trigger SetComplianceExceptionTrigger on SetComplianceException__e (after insert) {
    if(System.Label.RunSetComplianceExceptionTrigger=='TRUE') {
        TriggerFactory.createTriggerDispatcher(SetComplianceException__e.sObjectType);
    }
}