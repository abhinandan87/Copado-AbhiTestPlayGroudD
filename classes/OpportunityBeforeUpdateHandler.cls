//-----------------------------
// @author Prachi Bhasin
// @date 4 July 2017
// @param: TriggerParameters
// @description:  BeforeUpdate dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA
// @Update author : Hemant Shukla
// @description : SFDC1-5436 : Calling an additonal method checkEndUserCertificateAttachment()
// @Update author : Sonam Raju
// @Updated On : 3 JAN 2018
// @description : SFDC1-6245 Calling an additonal method checkChannelManagerRoleonOpptyTeamforStage2andhigher()
// @Last Modified By : Anjani Shukla
// @Last Modified Date: 05 Jun 2018
// @Last Modified Description: SFDC1-8392 : Added Method - "updateOpportunityGAM" Update Account Manager on 
//                             Opportunity when Account is updated.
// @Last Modified By : Anjani Shukla
// @Last Modified Date: 21 Jun 2018
// @Last Modified Description: SFDC1-8147 : Added Method - "updateOpportunityProductRestriction" Updated to restrict Opportunity Stage 
//                                          change when New Bizz Oppty record type contains product which is Cross Plant Status.
// @Last Modified By : Paras Dhingra
// @Last Modified Date: 21 July 2018
// @Last Modified Description: SFDC1-7059, SFDC1-7060 : Added Method - "opportunityValidations" for auto renewal validations
// @Last Modified By : Jagadesh Kumar
// @Last Modified Date: 31 July 2018
// @Last Modified Description:SFDC1-5228 - Populate Primary Contact Name on Opportunity

// @Last Modified By: Mohit Modi
// @Last Modified Date: 31 Aug 2018
// @Last Modified Description : SFDC1-9839 : Process Builder [Populate Total Contract Value On Renewal] to Code Change, SFDC1-5906, This to bring the data from previous years contract into Renewal Opportunity as well as update the Total contract value on current year.SFDC1-7233 : Removed the dependency of Opportunity's 'Total Contract Value' field.
// @Last Modified Company : VERTIBA

// @Last Modified By: Mohit Modi
// @Last Modified Date: 31 Aug 2018
// @Last Modified Description : SFDC1-9837 : Process Builder [Opportunity Updates For Salesops] to Code Change, SFDC1-286;To know when certain fields on Opportunity were last updated and the last value for that update
// @Last Modified Company : VERTIBA
// 
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 28 Aug 2018
// @Last Modified Description: SFDC1-9836 : Added method 'deletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner' to populate previous owner on opportunity on opportunity owner change

// @Last Modified By: Mohit Modi
// @Last Modified Date: 3 Sept 2018
// @Last Modified Description : SFDC1-9833 : Process Builder [ClearChannelPartnerOpportunity] to Code Change,  SFDC1-5021-Clear ChannelPartner Field on Opportunity when Account Type is not Global Alliance. SFDC1-6280 - Clear Account Owner on Opportunity when it is a Global Alliance
// @Last Modified Company : VERTIBA
// @last Modified by : Mohit Modi
// @last modified description :30 Oct 2018 , SFDC1-10188 : Field 'Total Annual Contract Value' [TotalAnnualContractValue__c] added to Deletion list, So Commenting this Method.
// 
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 09 Sep 2019
// @Last Modified Description : SFDC-1973 Added method call oppCheckASC606RevRecProductValidation()
// @modifiedBy: Paras Dhingra
// @modifiedDate: 08 May 2020
// @modifiedDescription: SFDC-2566 This validation is a subset of method blockUpdatesToLostOpportunity hence commenting it
//-----------------------------
public class OpportunityBeforeUpdateHandler extends TriggerHandlerBase{
    
  public override void mainEntry(TriggerParameters tp) {
      //OpportunityMethods.blockSalesUpdateToLostRenewalOppyValidation(tp);
      OpportunityMethods.blockUpdatesToLostOpportunity(tp);
      OpportunityMethods.checkPrimaryContactOnNewBusinessOpportunity(tp);
      OpportunityMethods.checkChannelManagerRoleonOpptyTeamforStage2andhigher(tp);
      OpportunityMethods.updateOpportunityGAM(tp);
      OpportunityMethods.copyBilltoShiptoFromOriginatingContractToRenewalOpportunity(tp);
      OpportunityMethods.blockSalesUpdateAddressValidation(tp);
      
      
      if(System.Label.MigrationSwitchOppyProducts !='TRUE' || Test.isRunningTest()) {
          OpportunityMethods.updateOpportunityProductRestriction(tp);
      }
      OpportunityMethods.opportunityValidations(tp);
      OpportunityMethods.revisitOpportunityStageChanges(tp);
      OpportunityMethods.setContactRolePrimary(tp);
      // OpportunityMethods.PopulateTotalContractValueOnRenewal(tp);
      OpportunityMethods.OpportunityUpdatesForSalesops(tp);
      OpportunityMethods.deletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner(tp);
      OpportunityMethods.ClearChannelPartnerOpportunity(tp);
      OpportunityMethods.populateOpportunityCountryFromAccount(tp);
      OpportunityMethods.oppCheckASC606RevRecProductValidation(tp);
      OpportunityMethods.UpdateReplacementOppwhenOpportunityReopen(tp);
      OpportunityMethods.multiYearLogic(tp);
      OpportunityMethods.populateReferralPercentage(tp);
      OpportunityMethods.opportunityContactRoleMandatory(tp);
      OpportunityMethods.populateDateRiskFirstIdentified(tp);
      OpportunityMethods.globalAllianceAccess(tp);
      OpportunityMethods.checkEmptyRequestedLegalEntity(tp);  //SFDC-4885: Check empty Requested Legal Entity field on Exception Approval 
      OpportunityMethods.updateLegalEntity(tp); //SFDC-5282: Moved from afterUpdate to beforeUpdate
      OpportunityMethods.synergyCalculation(tp);
      if(!Test.IsRunningTest()){
          OpportunityMethods.updatePreviousFiscalYearOpportunityLink(tp);
      }
  }
}