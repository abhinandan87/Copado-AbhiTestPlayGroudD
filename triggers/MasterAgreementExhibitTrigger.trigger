trigger MasterAgreementExhibitTrigger on MasterAgreementExhibit__c (before insert, before update) {
    	TriggerFactory.createTriggerDispatcher(MasterAgreementExhibit__c.sObjectType);
}