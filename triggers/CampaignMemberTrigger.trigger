/**
* @author Vaishali Jain
* @date 29th Sep 2021
* @description SFDC-4662 CampaignMember trigger to handle CampaignMember DML events
*/
trigger CampaignMemberTrigger on CampaignMember (after insert,after update) {
    TriggerFactory.createTriggerDispatcher(CampaignMember.sObjectType);
}