// @Author : Sruti Srivastava
// @Created Date: 10th April 2018
// @Description: SFDC1-7027- BeforeInsert class for OpportunityLineItem object 
// Added method populateContractStartDateAndEndDate which 
// populate Contract Start Date and End Date on Opportunity Line Items form Opportunity
// 
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 12 February 2019
// @modifiedDescription: SFDC-660 add logic to populate Opportunity Stage value from Opportunity

// @modifiedby: Paras Dhingra
// @modifiedDate: 26th July 2019
// @modified description : SFDC-1646 defaulting product owner to opportunity owner on insert. Adding call for method setDefaultProductOwner

// @modifiedby: Neelam Agrawal
// @modifiedDate: 12th April 2021
// @modified description : SFDC-4007 Default Value of 0.00 should update on insert. Adding call for method setDefaultParameter


public class OpportunityLineItemBeforeInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        OpportunityLineItemMethods.populateContractStartDateAndEndDate(tp);
        OpportunityLineItemMethods.populateOpportunityStage(tp);
        OpportunityLineItemMethods.setDefaultProductOwner(tp);
        OpportunityLineItemMethods.updateRiskStatus(tp);
        OpportunityLineItemMethods.setDefaultParameter(tp);
        OpportunityLineItemMethods.populateSynergyTypeandTheme(tp);
    }
}