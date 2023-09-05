//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: TriggerParameters
// @description:  AfterInsert dispatcher event handler class that calls the functions in CaseMethods.
// @return: NA
// @Modified by : Paras Dhingra
// @Modified date: 30th Jun 2017
// @Modification reason : SFDC1-441 Adding updateCaseMilestone method invocation
// @Modified by : Hemant Shukla
// @Modified date: 18 Jan, 2018
// @Modification reason : SFDC1-6629, added a new method fireCaseAssignmentRule(). 
// 				To fire the case Assignment rules which are created in Quick Actions
// @LastModifiedBy: Vishnu Vardhan Chowdary
// @LastModifiedDate: 23 August 2018
// @LastModifiedReason: SFDC1-9441, When an onboarding case is created from implementation case
// 			then copy the related lists from parent to child.
// @LastModifiedBy: Vishnu Vardhan Chowdary
// @LastModifiedDate: 24 August 2018
// @LastModifiedReason: SFDC1-8534, Adding methods for creating event for time tracking
//-----------------------------
// 
// @LastModifiedBy: Tran-Vu Tran
// @LastModifiedDate: 20 Sep 2018
// @LastModifiedReason: SFDC1-9961, adding method to create New Account Request case when a Customer Care case was created under Unknown Account
//						(converted from Process Builder flow related to GDSA/Account Governance cases - original story SFDC1-683)
// @LastModifiedBy: Sruti Srivastava
// @LastModifiedDate: 3 Oct 2018
// @LastModifiedReason: SFDC1-9453, Adding methods to populate the ProcessedContractNumber on Opportunity and Contract
// -----------------------------
public class CaseAfterInsertHandler extends TriggerHandlerBase {

    public override void mainEntry(TriggerParameters tp) {
        CaseMethods.setCaseAdditionalFieldsObject(tp);
        CaseMethods.updateCaseMilestones(tp);
        CaseMethods.processNewAccountRequestCase(tp);
        CaseMethods.fireCaseAssignmentRule(tp);
        CaseMethods.createRelatedListForOnboardingCase(tp);
        CaseMethods.createTimeTrackingEventForCase(tp);
        CaseMethods.updateParentCaseStatusWhenOMDCaseResolved(tp);
        CaseMethods.UpdateParentCaseACFLookupIDForTheChildCase(tp);
        CaseMethods.populateSAPProcessedContractNumOnOpportunityAndContract(tp);
        CaseMethods.updateLeadStatus(tp);
        CaseMethods.moveToDeleteQueueExistingOMCases(tp);
        
    }
}