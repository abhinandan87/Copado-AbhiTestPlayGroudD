/**
// @author : Mohit Modi
// @date : 3 Nov 2017
// @description : SFDC1-1081 before update handler for Lead trigger, SFDC1-192 - Moved to Before Events
// @LastModifiedBy : Sruti Srivastava
// @LastModifiedOn : 21 Sept 2018
// @LastModifiedDescription : SFDC1-8820: Added method populateNamedAccountOnLead on beofre update
// @companyname : Vertiba
*/

public class LeadBeforeUpdateHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        LeadMethods.updateCountryLookup(tp);
		LeadMethods.populateNamedAccountOnLead(tp);
        LeadMethods.LeadTime(tp);
    }
}