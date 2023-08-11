/**
* @author: Sushma Yadav
* @date: 10 Feb 2020
* @param: Trigger events
* @description: SFDC-2626. trigger for Sales Incentive Approval
* @description: SFDC-2626: Adding before insert event
*/

trigger SalesIncentiveApprovalTrigger on SalesIncentiveApproval__c (before insert, after Insert, after Update) {
	//call trigger factory to create SalesIncentiveApproval trigger dispatcher
    TriggerFactory.createTriggerDispatcher(SalesIncentiveApproval__c.sObjectType);
}