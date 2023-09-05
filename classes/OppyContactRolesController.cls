/**
 * @author: Sharique Iqbal
 * @date : 2nd Dec 2021
 * @description: SFDC-4199 Controller for lightning component to fetch related
 * 				Opportunity Contact Roles
*/

public class OppyContactRolesController {
	@AuraEnabled(cacheable=true)
    public static List<OpportunityContactRole> getOppyContactRoles(String recId){
        System.debug('$$$ getOppyContactRoles Called');
        Id oppyId = [Select id, Opportunity__c from Feedback__c where Id = :recId].Opportunity__c;
        List<OpportunityContactRole> lstOppyContctRoles = [Select id, ContactId,Contact.Name,IsPrimary,Role,Contact.Email,
                                          Contact.Account.Name, Contact.AccountId, Contact.Phone FROM OpportunityContactRole where OpportunityId=:oppyId ];
      
        return lstOppyContctRoles;
    }
}