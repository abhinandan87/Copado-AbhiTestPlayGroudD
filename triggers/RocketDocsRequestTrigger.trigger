trigger RocketDocsRequestTrigger on RocketDocs__Proposal_Request__c (before insert) {
  TriggerFactory.createTriggerDispatcher(RocketDocs__Proposal_Request__c.sObjectType);
}