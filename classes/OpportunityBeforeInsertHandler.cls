//-----------------------------
// @author Prachi Bhasin
// @date 4 July 2017
// @param: TriggerParameters
// @description:  BeforeInsert dispatcher event handler class that calls the functions in OpportunityMethods.
// @return: NA

// @Last Modified By: Mohit Modi
// @Last Modified Date: 31 Aug 2018
// @Last Modified Description : SFDC1-9839 : Process Builder [Populate Total Contract Value On Renewal] to Code Change, SFDC1-5906, This to bring the data from previous years contract into Renewal Opportunity as well as update the Total contract value on current year.SFDC1-7233 : Removed the dependency of Opportunity's 'Total Contract Value' field.
// @Last Modified Company : VERTIBA

// @Last Modified By: Mohit Modi
// @Last Modified Date: 3 Sept 2018
// @Last Modified Description : SFDC1-9833 : Process Builder [ClearChannelPartnerOpportunity] to Code Change,  SFDC1-5021-Clear ChannelPartner Field on Opportunity when Account Type is not Global Alliance. SFDC1-6280 - Clear Account Owner on Opportunity when it is a Global Alliance
// @Last Modified Company : VERTIBA
// @last Modified by : Mohit Modi
// @last modified description :30 Oct 2018 , SFDC1-10188 : Field 'Total Annual Contract Value' [TotalAnnualContractValue__c] added to Deletion list, So Commenting this Method.
//-----------------------------
public class OpportunityBeforeInsertHandler extends TriggerHandlerBase{
    
    public override void mainEntry(TriggerParameters tp) {
        OpportunityMethods.populateExternalSourceSystemOnOpportunity(tp); 
        OpportunityMethods.updateGAMOnOpportunityCreation(tp);
        OpportunityMethods.copyBilltoShiptoFromOriginatingContractToRenewalOpportunity(tp);
       // OpportunityMethods.PopulateTotalContractValueOnRenewal(tp);
        OpportunityMethods.ClearChannelPartnerOpportunity(tp);
        OpportunityMethods.populateOpportunityCountryFromAccount(tp);
        OpportunityMethods.multiYearLogic(tp);
        OpportunityMethods.populateReferralPercentage(tp);
        OpportunityMethods.updateCloseDateOriginalToCloseDateValue(tp);
        OpportunityMethods.updatePreviousFiscalYearOpportunityLink(tp);
    }
}