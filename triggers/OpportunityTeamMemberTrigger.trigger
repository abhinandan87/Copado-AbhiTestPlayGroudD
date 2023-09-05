Trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (after insert, after update, after delete) {
    
     TriggerFactory.createTriggerDispatcher(OpportunityTeamMember.sObjectType);
}