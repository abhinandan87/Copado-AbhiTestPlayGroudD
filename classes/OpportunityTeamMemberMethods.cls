//-----------------------------
// @author: Ankush Vedi
// @date: 25 March 2022
// @description: SFDC-4968- Email triggered when the Opportunity team member added or removed from the oppty
// @company: IHS Markit
//-----------------------------

public class OpportunityTeamMemberMethods {

    public static void updateOppyTeamMembers(TriggerParameters tp) {
        
        Map<Id, List<Id>> opportunityToUserIdsMap = new Map<Id, List<Id>>();
        Map<Id, Id> oppymap = new Map<Id, id>();      
        Set<Id> userIds = new Set<Id>();        
        Set<String> setOfOpportunityIds = new Set<String>();
        Map<Id , Opportunity> mapOfOpportunity = new Map<Id , Opportunity>();        
        List<OpportunityTeamMember> lstOpportunityTeamMember = new List<OpportunityTeamMember>();
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
            lstOpportunityTeamMember = (List<OpportunityTeamMember>)tp.newList  ;
        }
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
            lstOpportunityTeamMember = (List<OpportunityTeamMember>)tp.oldList  ;
        }      
        
        for(OpportunityTeamMember otm : lstOpportunityTeamMember) {
            userIds.add(otm.UserId);   
            oppymap.put(otm.UserId , otm.OpportunityId);
            setOfOpportunityIds.add(otm.OpportunityId);
        } 
        
        if(setOfOpportunityIds.size() > 0) {
            mapOfOpportunity = new Map<Id , Opportunity>([Select id , Opportunitynum__c , Name ,CloseDate,LeadSource,SalesSpecialists__c,AccountManagers__c,OpportunityGeography__c
                                                ,CreatedDate,LastModifiedBy.Name,Owner.Name,Description,Account.Name from Opportunity where Id in :setOfOpportunityIds]);
        }
        
        if(userIds.size() > 0) {
            notifyOpportunityTeamMembers(userIds, tp, oppymap , mapOfOpportunity);
        }
    }
    
    public static void notifyOpportunityTeamMembers(Set<Id> userIds , TriggerParameters tp, Map<Id, Id> oppymap ,Map<Id , Opportunity> mapOfOpportunity) {
        
        list<Messaging.SingleEmailMessage> lstMail = new list<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName  = 'OpportunityTeamMemberChangeNotificationEmail' LIMIT 1];        
        String userProfileName = [select Name from profile where id =: userinfo.getProfileId()].name;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-replysfdc@ihsmarkit.com'];
        System.debug('@@@@##'+ userProfileName);
        if((userProfileName != 'System Administrator' && userProfileName != 'IHSMarkit System Admin: API') || test.isRunningTest()) {
            for (String userId : userIds) { 
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                mail.setTargetObjectId(userId);             
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                mail.setReplyTo ('noreply@salesforce.com');
             // mail.setSenderDisplayname('IHS Markit Salesforce Notification');
                
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                String htmlBody = emailTemplate.HTMLValue;
                
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {    					   
                    mail.setSubject('Added to an Opportunity Team '+ mapOfOpportunity.get(oppymap.get(userId)).Opportunitynum__c + ' - ' + mapOfOpportunity.get(oppymap.get(userId)).Account.Name);
                    htmlBody = htmlBody.replace('{changed}' , 'added to');
                }                
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {                        
                    mail.setSubject('Removed from an Opportunity Team ' + + mapOfOpportunity.get(oppymap.get(userId)).Opportunitynum__c + ' - ' + mapOfOpportunity.get(oppymap.get(userId)).Account.Name);
                    htmlBody = htmlBody.replace('{changed}' , 'removed from');
                }                  
                if (mapOfOpportunity.get(oppymap.get(userId)).Opportunitynum__c != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.Opportunitynum__c}' , mapOfOpportunity.get(oppymap.get(userId)).Opportunitynum__c);
                }                  
                if (mapOfOpportunity.get(oppymap.get(userId)).Name != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.Name}' , mapOfOpportunity.get(oppymap.get(userId)).Name);
                }                
                if (mapOfOpportunity.get(oppymap.get(userId)).Account.name != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.Account}' , mapOfOpportunity.get(oppymap.get(userId)).Account.name);
                }                  
                if (mapOfOpportunity.get(oppymap.get(userId)).CloseDate != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.CloseDate}' , mapOfOpportunity.get(oppymap.get(userId)).CloseDate.format());
                }                
                if (mapOfOpportunity.get(oppymap.get(userId)).LeadSource != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.LeadSource}' , mapOfOpportunity.get(oppymap.get(userId)).LeadSource);
                }                
                else{
                    htmlBody = htmlBody.replace('{!Opportunity.LeadSource}' , '');
                }                
                if (mapOfOpportunity.get(oppymap.get(userId)).CreatedDate != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.CreatedDate}' , mapOfOpportunity.get(oppymap.get(userId)).CreatedDate.format());
                }                
                if (mapOfOpportunity.get(oppymap.get(userId)).LastModifiedBy.name != Null){
                    htmlBody = htmlBody.replace('{!Opportunity.LastModifiedBy}' , mapOfOpportunity.get(oppymap.get(userId)).LastModifiedBy.name);
                }                
                if (mapOfOpportunity.get(oppymap.get(userId)).SalesSpecialists__c != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.SalesSpecialists__c}' , mapOfOpportunity.get(oppymap.get(userId)).SalesSpecialists__c);
                }                
                else{
                    htmlBody = htmlBody.replace('{!Opportunity.SalesSpecialists__c}' , '');
                }
                if (mapOfOpportunity.get(oppymap.get(userId)).AccountManagers__c != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.AccountManagers__c}' , mapOfOpportunity.get(oppymap.get(userId)).AccountManagers__c);
                }                
                else{
                    htmlBody = htmlBody.replace('{!Opportunity.AccountManagers__c}' , '');
                }
                if (mapOfOpportunity.get(oppymap.get(userId)).OpportunityGeography__c != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.OpportunityGeography__c}' , mapOfOpportunity.get(oppymap.get(userId)).OpportunityGeography__c);
                }                
                else{
                    htmlBody = htmlBody.replace('{!Opportunity.OpportunityGeography__c}' , '');
                }
                if (mapOfOpportunity.get(oppymap.get(userId)).Description != Null) {
                    htmlBody = htmlBody.replace('{!Opportunity.Description}' , mapOfOpportunity.get(oppymap.get(userId)).Description);
                }                
                else{
                    htmlBody = htmlBody.replace('{!Opportunity.Description}' , '');
                }
                
                mail.setHTMLbody(htmlBody);    
                lstMail.add(mail);          
            }
           
        }
        if(lstMail.size() >0) {
            Messaging.sendEmail(lstMail);
        }    
    }    
}