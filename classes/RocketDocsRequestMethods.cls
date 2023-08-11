public class RocketDocsRequestMethods {
    
    public static void prepopulateFieldsValues(TriggerParameters tp) {
        
        Set <Id> oppIds = new Set <Id>();
        for (RocketDocs__Proposal_Request__c rpr : (List<RocketDocs__Proposal_Request__c>)tp.newList) {
          if (rpr.RocketDocs__Opportunity__c != null) {
              oppIds.add(rpr.RocketDocs__Opportunity__c);
          }
        }
   
        Map <Id,Opportunity> OppyMap = new  Map <Id,Opportunity>([Select Id, CurrencyIsoCode, Account.BillingStreet, Account.BillingCity, 
                                                                  Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, 
                                                                  Owner.Email, Owner.HRJobTitle__c,Owner.HRBusinessLine__c,Owner.Phone,Owner.MobilePhone, 
                                                                   (SELECT id, Contact.Name,Contact.FirstName, Contact.Email, Contact.LastName, Contact.Title, Contact.Phone  
                                                                    FROM OpportunityContactRoles where IsPrimary=true LIMIT 1)
                                                                  FROM Opportunity WHERE Id IN : oppIds]);
     
       for (RocketDocs__Proposal_Request__c rpr : (List<RocketDocs__Proposal_Request__c>)tp.newList) {
          if (rpr.RocketDocs__Opportunity__c != null && OppyMap.containsKey(rpr.RocketDocs__Opportunity__c)) {
             Opportunity oppy = OppyMap.get(rpr.RocketDocs__Opportunity__c);
             rpr.OpportunityOwnerEmail__c  = oppy.Owner.Email ;
             rpr.OpportunityOwnerHRTitle__c  = oppy.Owner.HRJobTitle__c ;
             rpr.Opportunity_Owner_Department__c = oppy.Owner.HRBusinessLine__c ;
             rpr.OpportunityOwnerPhoneNumber__c  = oppy.Owner.Phone ;
             rpr.OpportunityOwnerMobileNumber__c = oppy.Owner.MobilePhone;
             rpr.AccountCountry__c  = oppy.Account.BillingCountry ;
             rpr.AccountState__c  = oppy.Account.BillingState  ;
             rpr.AccountStreet__c  = oppy.Account.BillingStreet;
             rpr.AccountCity__c  = oppy.Account.BillingCity ;
             rpr.AccountZip__c  = oppy.Account.BillingPostalCode ;
             rpr.CurrencyIsoCode = oppy.CurrencyIsoCode;
             
             if(oppy.OpportunityContactRoles.size() > 0) {
               rpr.PrimaryContactFullName__c  = oppy.OpportunityContactRoles[0].Contact.Name;
               rpr.PrimaryContactPhone__c  = oppy.OpportunityContactRoles[0].Contact.Phone;
               rpr.PrimaryContactTitle__c  = oppy.OpportunityContactRoles[0].Contact.Title;
               rpr.PrimaryContactEmail__c  = oppy.OpportunityContactRoles[0].Contact.Email;
               rpr.PrimaryContactFirstName__c =  oppy.OpportunityContactRoles[0].Contact.FirstName;
             }
         }
      }
   }    
}