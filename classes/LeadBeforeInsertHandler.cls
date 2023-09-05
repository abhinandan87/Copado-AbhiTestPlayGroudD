/**
// @author : Mohit Modi
// @date : 3 Nov 2017
// @description : SFDC1-1081 Before insert handler for Lead trigger, SFDC1-192 - Moved to Before Events
// @LastModifiedBy : Sruti Srivastava
// @LastModifiedOn : 21 Sept 2018
// @LastModifiedDescription : SFDC1-8820: Added method populateNamedAccountOnLead on beofre insert
// @companyname : Vertiba
*/

public class LeadBeforeInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        LeadMethods.updateCountryLookup(tp);
		LeadMethods.updatetoNewLeadSourcefield(tp);
        LeadMethods.populateNamedAccountOnLead(tp);
    }
}