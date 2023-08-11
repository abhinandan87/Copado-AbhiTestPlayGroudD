Trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, after update, after delete) {
    
     TriggerFactory.createTriggerDispatcher(AccountTeamMember.sObjectType);
}