//-----------------------------
// @author: Akshay Dogra
// @date: 30 July 2021
// @param: Trigger events
// @description: Contract Product Alliance Partner trigger 
// @return: NA
//-----------------------------
trigger ContractProductAlliancePartnerTrigger on ContractProductAlliancePartner__c (before insert, before update) {

    //call trigger factory to create Internal Approval trigger dispatcher
	TriggerFactory.createTriggerDispatcher(ContractProductAlliancePartner__c.sObjectType);
}