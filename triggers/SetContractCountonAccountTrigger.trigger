//-----------------------------
// @author: Digvijay Singh
// @date: 11 June 2021
// @param: NA
// @description: SFDC-4166 Class to hold SetContractCountonAccount__e platform event trigger methods 
// @return: NA
//-----------------------------
trigger SetContractCountonAccountTrigger on SetContractCountonAccount__e(after insert) {
    TriggerFactory.createTriggerDispatcher(SetContractCountonAccount__e.sObjectType);
}