// @Author : Paras Dhingra
// @Created Date: 23rd July 2018
// @Description: SFDC1-7059, SFDC1-7060 BeforeUpdate class for OpportunityLineItem object 
// added call for Opportunity product validations for auto-renewal opportunities
// 
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 12 February 2019
// @modifiedDescription: SFDC-660 add logic to populate Opportunity Stage value from Opportunity

// @modifiedby: Neelam Agrawal
// @modifiedDate: 12th April 2021
// @modified description : SFDC-4007 Default Value of 0.00 should update on insert. Adding call for method setDefaultParameter
// @modifiedby: Digvijay Singh
// @modifiedDate:28  March 2022
// @modified description : SFDC-5600 , No Synergy recalulation required on lineItem update

public class OpportunityLineItemBeforeUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        OpportunityLineItemMethods.innerYearOppyProductValidations(tp);
        OpportunityLineItemMethods.oppyProductValidations(tp);
        OpportunityLineItemMethods.populateOpportunityStage(tp);
        OpportunityLineItemMethods.updateRiskStatus(tp);
        OpportunityLineItemMethods.setDefaultParameter(tp);
        //OpportunityLineItemMethods.populateSynergyTypeandTheme(tp);
        
    }
}