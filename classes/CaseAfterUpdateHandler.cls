//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: TriggerParameters
// @description:  AfterUpdate dispatcher event handler class that calls the functions in CaseMethods.
// @return: NA
// @Modified by : Paras Dhingra
// @Modified date: 30th Jun 2017
// @Modification reason : SFDC1-441 Adding updateCaseMilestone method invocation
// @Modified by : Ankita Singh
// @Modified date: 13 March 2018
// @Modification reason : SFDC1-7182,7184: Adding validateImplementationCaseClose method invocation &&
// SFDC1-7183/7185: Adding afterAllCaseClosedOnContract method invocation
// @Modified by : Vishnu Vardhan Chowdary Andra
// @Modified date: 20 March 2018
// @Modification reason : SFDC1-7163: adding upsertOnboardingCaseFromImplementationCase
// @Modified by : Vishnu Vardhan Chowdary Andra
// @Modified date: 13 April 2018
// @Modification reason : SFDC1-7826: Removing Code written for 7182,7183,7184,7185.
// @Modified by : Vishnu Vardhan Chowdary Andra
// @Modified date: 16 May 2018
// @Modification reason : SFDC1-7183: adding afterAllCaseClosedOnContract
// @Modified by : Vishnu Vardhan Chowdary Andra
// @Modified date: 18 May 2018
// @Modification reason : SFDC1-7740: adding updateContractWhenOMCaseIsValidated
// @Modified by : Vishnu Vardhan Chowdary Andra
// @Modified date: 21 May 2018
// @Modification reason : SFDC1-8120: adding updateContractWhenOMCaseIsRejected
// @LastModifiedBy: Vishnu Vardhan Chowdary
// @LastModifiedDate: 24 August 2018
// @LastModifiedReason: SFDC1-8534, Adding methods for creating event for time tracking
// 
// @LastModifiedBy: Tran-Vu Tran
// @LastModifiedDate: 18 Sep 2018
// @LastModifiedReason: SFDC1-9961, adding methods Populate Related Lead/Case on Case closure
// (converted from Process Builder flow related to GDSA/Account Governance cases)
// @LastModifiedBy: Sruti Srivastava
// @LastModifiedDate: 3 Oct 2018
// @LastModifiedReason: SFDC1-9453, Adding methods to populate the ProcessedContractNumber on Opportunity and Contract

// @LastModifiedBy: Paras Dhingra
// @LastModifiedDate: 15 May 2019
// @LastModifiedReason: SFDC1-1336 Adding method to create account governance case on update of case as well

// @LastModifiedBy: Akshay Dogra
// @LastModifiedDate: 07 Oct 2020
// @LastModifiedReason: SFDC-3366 Adding deleteMergedCaseRelatedACF() to delete ACF on child Case when child Case is Merged
//-----------------------------

public class CaseAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        
        CaseMethods.setCaseAdditionalFieldsObject(tp);
        CaseMethods.updateCaseMilestones(tp);
        CaseMethods.updateContractWhenOMCaseIsValidated(tp);
        CaseMethods.updateContractWhenOMCaseIsRejected(tp);
        CaseMethods.populateRelatedLeadAndCaseAccountOnCaseClosure(tp);
        CaseMethods.processNewAccountRequestCase(tp);
        CaseMethods.afterAllCaseClosedOnContract(tp);
        CaseMethods.upsertOnboardingCaseFromImplementationCase(tp);
        CaseMethods.createTimeTrackingEventForCase(tp);
        CaseMethods.updateParentCaseStatusWhenOMDCaseResolved(tp);
        CaseMethods.populateSAPProcessedContractNumOnOpportunityAndContract(tp);
        CaseMethods.updateOppTo6WPClosedWonWhenOMCaseValidated(tp);
        CaseMethods.deleteMergedCaseRelatedACF(tp);
        CaseMethods.updateOppoStatusContract(tp);
    }
}