//-----------------------------
// @author Prachi Bhasin
// @date 3 July 2017
// @param: TriggerParameters
// @description:  AfterUpdate dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA
// @Last Modified By : Mohit Modi
// @Last Modified Date: 28 Mar 2018
// @Last Modified Description: SFDC1-7635 : Added Method 'updateReferredByOnOpportunityTeam' to Update Opportunity Team based on the 'Referred By' field on Opportunity.
// @Last Modified By: Sruti Srivastava
// @Last Modified Date: 9th April 2018
// @Last Modified Description: SFDC1-7027- Added method updateContractStartDateAndEndDateOnOpportunityLineItem which updates
// Contract Start Date and End Date on Opportunity Line Items if 'ContractStartDate__c' 
// and 'ContractEndDate__c' field on Opportunity are updated
// @Last Modified By : Anjani Shukla
// @Last Modified Date: 09 Apr 2018
// @Last Modified Description: SFDC1-7667 : Added Method 'updateOpportunityRiskRecordStatus' to update Opportunity Risk Record Status when New Business //                                          Opportunity is being set to 6L - Closed Lost and an Opportunity at Risk record exists with the status = "Open - //                                          Pending Resolution", then 
//                                          set the Status field to “Closed - Opportunity Lost”.
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 23 Aug 2018
// @Last Modified Description : SFDC1-9831, 9841, 9844, 9845, 9840 and 9838 added call to methods activeContractUpdatesWhenRenewal6W and updateContractCurrencyWhenOppCurrencyChanges
// @Last Modified Company : VERTIBA

// @Last Modified By: Mohit Modi
// @Last Modified Date: 30 Aug 2018
// @Last Modified Description : SFDC1-9843 : Process Builder [UpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus] to Code Change, SFDC1-6708:the status field on the Opportunity at Risk record to be set to "Closed - Mitigated" when a New Business opportunity is set to 6W. When a New Business Opportunity is set to 6L, then the status field on the OPP record should be set to "Closed - Terminated". SFDC1-7667 When New Business is set to 6L and OaR record exists - set the Status
// @Last Modified Company : VERTIBA

// @Last Modified By : Jagadesh Kumar
// @Last Modified Company : VERTIBA
// @Last Modified Date : 03 Sep 2018
// @Last Modified Description : SFDC1-9781 : Create Implementation Case when Markit Auto-Renewal is move to 6W-Renewal Won
//
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 28 Aug 2018
// @Last Modified Description: SFDC1-9835 : Added method 'deletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner' to delete opp team member and opp split on opp owner change 

// @Last Modified By: Mohit Modi
// @Last Modified Date: 30 Aug 2018
// @Last Modified Description : SFDC1-9833 : Process Builder [ClearChannelPartnerOpportunity] to Code Change,  SFDC1-5021-Clear ChannelPartner Field on Opportunity when Account Type is not Global Alliance. SFDC1-6280 - Clear Account Owner on Opportunity when it is a Global Alliance
// @Last Modified Company : VERTIBA
// @Last Modified Description: SFM-159 :    Added Method 'changeAdditionalOpportunityFieldsNameWhenOpportunityFieldChanges' to update Opportunity Additional Fields in sync.
// @Last Modified By: Vishnu Vardhan chowdary
// @Last Modified Company : VERTIBA
// @Last Modified Date : 03 Sep 2018
// @Last Modified Description : SFDC1-10184 : Create Implementation Cases when Markit Auto-Renewal is moved to 6W-Renewal Won and has lost products
// 
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 08 Feb 2019
// @Last Modified Description : SFDC-614: Implementation Proof of Delivery Case is not needed when an Auto Renewal is set to 6W. Removed 'createImplementationCaseWhenRenewalOpportunity6W()' method call from handler which was created in respect with parent story SFDC1-9781.
// @Last Modified By: Paras Dhingra
// @Last Modified Date: 06 May 2019
// @Last Modified Description : SFDC-1364 Method to reset account manager split in case oppy owner is changed
// 
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 06 May 2019
// @modifiedDescription: SFDC-177 added method call updateOriginatingContractContinuationEndDate
// @Last Modified Date: 16 Jul 2020
// @Last Modified Description: SFDC- 1142 Disable code that adds the Referred By user to Opportunity Team
//								Referred by field changed from a User lookup to a Contact lookup
// @Last Modified By: Manish Kumar
// @Last Modified Date: 13 Oct 2021
// @Last Modified Description : SFDC-4730 Method to update the Legal Entity from Requested Legal Entity when Exception is approved
// @Last Modified By: Manish Kumar
// @Last Modified Date: 23rd March 2022
// @Last Modified Description : SFDC-5500 Method to update the Prior Approved checkbox field on OLI
// @Last Modified By: Ankush Agarwal
// @Last Modified Date: 16th June 2023
// @Last Modified Description : Method to recalculate Rollup fields on Opportunity Closed Lost
//-----------------------------
public class OpportunityAfterUpdateHandler extends TriggerHandlerBase{
    
    public override void mainEntry(TriggerParameters tp) {
        OpportunityMethods.updateContractAccountWhenOpportunityAccountIsUpdated(tp);
        OpportunityMethods.updateContractAddressFieldsWhenOpportunityAddressIsUpdated(tp);
        OpportunityMethods.createRenewalStagingOn6WP(tp);
        OpportunityMethods.resetAccountManagerSplitOnOwnerChange(tp);
        OpportunityMethods.updateOpportunitySplitOnGamChange(tp);
        OpportunityMethods.updateGAMOnOpportunityTeam(tp);
        OpportunityMethods.changeAccountOwnershipOnInsertUpdate(tp);
        OpportunityMethods.updateAccountRelationship(tp);
        //OpportunityMethods.updateReferredByOnOpportunityTeam(tp);
        OpportunityMethods.updateOpportunityLineItems(tp);
        OpportunityMethods.updateOpportunityRiskRecordStatus(tp);
        OpportunityMethods.createOMCaseOnRenewalOpportunityClosure(tp);
        OpportunityMethods.updateFiscalOnChangeOfCloseDate(tp);
        OpportunityMethods.updateCumulativeContract(tp);
        OpportunityMethods.revisitOpportunityTaskChanges(tp);
        OpportunityMethods.activeContractUpdatesWhenRenewal6W(tp);
        OpportunityMethods.updateContractCurrencyWhenOppCurrencyChanges(tp);
		OpportunityMethods.updateOriginatingContractContinuationEndDate(tp);
        OpportunityMethods.updateStatusOfContractBeingRenewed(tp);
        OpportunityMethods.populateContractWhenOpportunityIsLost(tp);
        OpportunityMethods.syncOpportunityDatesWithContractDates(tp);
        OpportunityMethods.UpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus(tp);
		OpportunityMethods.deletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner(tp);
        OpportunityMethods.ClearGAMTeamMemberOnChannelPartnerOpportunity(tp);
        OpportunityMethods.changeAdditionalOpportunityFieldsNameWhenOpportunityFieldChanges(tp);
        OpportunityMethods.UpdateAtRiskAccountUponOpportunityAccountChange(tp);
        OpportunityMethods.createImplCaseForLostProductsOnRenewalOpp6W(tp);
        OpportunityMethods.setToOppLostSalesIncentiveApproval(tp);
        OpportunityMethods.deletePriceChangeOnly(tp);
        OpportunityMethods.updateSynergyOnOppyLineItem(tp);
        //OpportunityMethods.updateLegalEntity(tp);  //SFDC-5282: Moved from afterUpdate to beforeUpdate
        OpportunityMethods.updatePriorApproved(tp); //SFDC-5500: Update Prior Approved checkbox on OLI
        OpportunityMethods.updateCaseOpportunities(tp);
        OpportunityMethods.performRollupCalculationonClosedLostOppies(tp);
       
    }
}