/**
 * @Author:  Paras Dhingra
 * @Date:    08th April 2020
 * @description: SFDC-2734 controller for SendMeetingNotes LWC component. Refactored from SendMeetingNoteEmailToTeamMembers
 * @Modified by: Paras Dhingra
 * @Modified Date: 11 Nov 2020
 * @description: SFDC-3331 - fixing Sendmeeting notes for child events
**/
public with sharing class SendMeetingNotesController {
    private final static Integer MAX_RESULTS = 10;
    private final static String contactIcon = 'standard:contact';
    private final static List<String> lstBypassCompanies =  System.label.ByPassMeetingNotes.toLowerCase().split(',');
    public final static List<String>  lstAllowedContactDomains = System.label.IHSMarkitDomains.toLowerCase().split(',');
    /**
     * @Author: Paras Dhingra
     * @date: 08th April 2020
     * @description: Send meeting notes component 
     * @param: eventId-
     * @return: List<MeetingNotesWrapper>, AccountTeamMembers or OpportunityTeamMembers based on selected action. 
     * */
    @AuraEnabled(cacheable =true)
    public static List<MeetingNotesWrapper> fetchMeetingNotesRecepients(String eventId) {
        System.debug('--eventID--'+eventId);
        List<MeetingNotesWrapper> recipients = new List<MeetingNotesWrapper>();
        Map<String,MeetingNotesWrapper> mapRecipients = new Map<String,MeetingNotesWrapper>();
        try {
            Event relatedEvent;
            Event tempEvent = [SELECT MeetingNote__c,AccountId,IsChild,ParentID__c  FROM event WHERE Id=:eventId limit 1];
            relatedEvent = tempEvent;
            if(tempEvent.IsChild) {
                //query relatedEvent
                System.debug('@PD==calling from child==');
                relatedEvent = [SELECT MeetingNote__c,AccountId,IsChild,ParentID__c  FROM event WHERE Id=:tempEvent.ParentID__c limit 1];
            }
            Set<String> setBypassCompanies = new Set<String>(lstBypassCompanies);
            MeetingNote__c meetingNote = [SELECT Id, Account__c, NumberOfOpportunities__c, (Select Id, Opportunity__c From RelatedOpportunities__r) 
                                          FROM MeetingNote__c 
                                          WHERE Id =:relatedEvent.MeetingNote__c
                                          Limit 1
                                          ];
            
            
            for(AccountTeamMember atm: [Select Id,AccountId,TeamMemberRole,UserId, User.Name, User.Email,User.companyName
                                            From AccountTeamMember 
                                            Where AccountId =: relatedEvent.AccountId ]) {
    
                    //recipients.add(new MeetingNotesWrapper(atm.User.Name, atm.User.Email, setBypassCompanies.contains(atm.User.companyName.toLowerCase())));
                    Boolean shouldBypass = atm.User.companyName==null?false:setBypassCompanies.contains(atm.User.companyName.toLowerCase());
                    mapRecipients.put(atm.User.Email,new MeetingNotesWrapper(atm.User.Name, atm.User.Email,shouldBypass));
                }
                //Set<Id> setAlreadyAddedUsers = new Set<Id>();
                Set<Id> oppIds = new Set<Id>();
                for(RelatedOpportunity__c ro : meetingNote.RelatedOpportunities__r) {
                    oppIds.add(ro.Opportunity__c);
                }   
                for(OpportunityTeamMember otm:  [Select Id,Name,OpportunityId,TeamMemberRole,UserId, User.Name, User.Email,User.companyName
                                                  From OpportunityTeamMember 
                                                  Where OpportunityId IN: oppIds ]) {
                    
                    //To avoid same users to get added twice in list. As one user can be a part of Two Opportunity team.
                    /*if(!setAlreadyAddedUsers.contains(otm.UserId)) {
                        recipients.add(new MeetingNotesWrapper(otm.User.Name, otm.User.Email, setBypassCompanies.contains(otm.User.companyName.toLowerCase())));
                        setAlreadyAddedUsers.add(otm.UserId);
                    }*/
                    Boolean shouldBypass = otm.User.companyName==null?false:setBypassCompanies.contains(otm.User.companyName.toLowerCase());
                    mapRecipients.put(otm.User.Email,new MeetingNotesWrapper(otm.User.Name, otm.User.Email, shouldBypass));
                } 	
            System.debug('--recepients--'+mapRecipients);

        } catch(Exception ex) {
            System.debug('Error occurred'+ex.getMessage());
        }

	    return mapRecipients.values();
    }
    /**
     * @Author: Paras Dhingra
     * @date: 14th April 2020
     * @description: Search internal contacts. This implementation will be different for every lookup utility reuse
     * @param: searchTerm, selectedIds
     * @return: List<LookupSearchResult>, Contacts already selected 
     * */
    @AuraEnabled
    public static List<LookupSearchResult> searchContacts(String searchTerm, List<String> emailsAlreadySelected) {
        System.debug('--email--'+emailsAlreadySelected);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        searchTerm = '%'+searchTerm+'%';
        List<Contact> lstContact = new List<Contact>();
        /*List<Contact> lstContact = [SELECT Id, Name, Email 
                                    FROM Contact 
                                    WHERE Name LIKE :searchTerm 
                                    AND Account.Name ='IHS Markit Limited'
                                    AND email NOT IN: emailsAlreadySelected
                                    LIMIT :MAX_RESULTS ];*/
        String queryContact = 'SELECT Id, Name, Email FROM Contact Where Name LIKE \'%' + searchTerm + '%\'';
        queryContact += ' AND ( ';
        Integer count =0;
        for(String str : lstAllowedContactDomains) {
            queryContact += ' Email like \'%' + str + '%\' ';
            if(count < (lstAllowedContactDomains.size()-1)) {
                queryContact += ' OR ';
            }
            count++;
        }
        queryContact += ' ) LIMIT ' + string.valueOf(MAX_RESULTS);
        lstContact = Database.query(queryContact);
        Set<String> setEmailToQueryInUser = new Set<String>();
        for(Contact cont: lstContact) {
            setEmailToQueryInUser.add(cont.Email);
        }
        List<User> lstUser = [Select Id, Email from User where Email IN: setEmailToQueryInUser and CompanyName IN : lstBypassCompanies];
        Set<String> setStringBlockedUser = new Set<String>();
        if(lstUser!=null && !lstUser.isEmpty()) {
            for(User usr: lstUser) {
                setStringBlockedUser.add(usr.Email);
            }
        }
        // prepare search results wrapper to return
        for(Contact cont  : lstContact) {
            //set css to warning if user belongs to blocked company
            String css = setStringBlockedUser.contains(cont.Email)?'slds-theme_warning':'';
            results.add(
                new LookupSearchResult(
                    cont.Id,
                    css, //sobjectype is not required hence repurposing sobjecttype field to set blocked CSS
                    contactIcon,
                    cont.Name,
                    cont.Email
                )
            );
        }
        results.sort();
        return results;
    }
     /**
     * @Author: Paras Dhingra
     * @date: 15th April 2020
     * @description: SFDC-2734 This method adds a recipient into list to send an email to meeting note attendees
     * @param: eventId, jsonLstRecipients
     * @return: String
    */
    @AuraEnabled
    public static String sendEmail(String eventId, String jsonLstRecipients) {
        Event evt; 
        Event tempEvent = [SELECT MeetingNote__c,AccountId,IsChild,ParentID__c  FROM event WHERE Id=:eventId limit 1];
        evt = tempEvent;
        if(tempEvent.IsChild) {
            //query relatedEvent
            evt = [SELECT MeetingNote__c,AccountId,IsChild,ParentID__c  FROM event WHERE Id=:tempEvent.ParentID__c limit 1];
        }
        MeetingNote__c mn = new MeetingNote__c();
        if(evt.MeetingNote__c!=null) {
            mn = [Select Id, Account__c, Account__r.Owner.Email
                             From  MeetingNote__c
                             Where ID =:evt.MeetingNote__c];
        }
        List<MeetingNotesWrapper> lstRecipients = new List<MeetingNotesWrapper>();
        if(!String.isEmpty(jsonLstRecipients)) {
            lstRecipients = (List<MeetingNotesWrapper>) JSON.deserializeStrict(jsonLstRecipients, List<MeetingNotesWrapper>.class);
        }    
        else {
            return 'No Recipients';
        }    
        
        try {   
            // Get the email template
            EmailTemplate template = [select id, HtmlValue, Body 
                                      From EmailTemplate 
                                      Where DeveloperName = 'ActivitiesManagementTemplate' 
                                      LIMIT 1];
            
            set<String> toAddressesSet = new set<String>(); 
            // need dummy contact
            Contact dummy = [select id, email from Contact limit 1]; /* where email = 'sfadmin@markit.com' */
            
            for(MeetingNotesWrapper rec : lstRecipients) {
                if(rec.cellCSS=='') {
                    toAddressesSet.add(rec.email);
                }
                
            }
            
            //Adding the additional users into set to send the email. Current user and Owner of Associated account to MN. 
            toAddressesSet.add(UserInfo.getUserEmail());
            if(evt.MeetingNote__c!=null && mn.Account__c != null) {
                toAddressesSet.add(mn.Account__r.Owner.Email);
            }
            
            List<String> toAddresses = new List<String>(toAddressesSet);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            if(toAddresses.size() > 0) {
                mail.setTargetObjectId(dummy.Id);
                mail.setTemplateId(template.Id);            
                mail.setToAddresses(toAddresses);
                mail.setWhatId(eventId);
                mail.setSaveAsActivity(false);
            }
            
            // Send the emails in a transaction, then roll it back, doesn't actually send email that way
            Savepoint sp = Database.setSavepoint();
            // This actually populates the template into the email message (#winning http://opfocus.com/blog/sending-emails-in-salesforce-to-non-contacts-using-apex/)
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            Database.rollback(sp);
            
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(mail.getToAddresses());
            emailToSend.setPlainTextBody(mail.getPlainTextBody());
            String emailBody = mail.getHTMLBody();
            emailToSend.setHTMLBody(emailBody);
            emailToSend.setSubject(mail.getSubject());
            emailToSend.setSaveAsActivity(false);

            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{emailToSend});
            
            return 'Success';
        }
        Catch(exception e) {
            System.debug('=================Error:' + e.getMessage());
            return e.getMessage();
        }    
    }
    /**
     * @Author: Paras Dhingra
     * @date: 12 May 2020
     * @description: SFDC-2795 Validate if meeting notes is blank
     * @param: eventId
     * @return: string
    */
    @AuraEnabled
    public static string hasMeetingOutcome(String eventId) {
        String message = 'Validated';
        List<Event> evt = [Select MeetingNote__c,MeetingNote__r.MeetingOutCome__c from Event where Id=:eventId limit 1];
        if(evt!=null && !evt.isEmpty()) {
            if(evt[0].MeetingNote__c==null) {
                message = 'Related Meeting note not found';
                return message;
            }
            if(String.isBlank(evt[0].MeetingNote__r.MeetingOutCome__c)) {
                message = 'Meeting notes is blank. Please add it to send meeting notes';
                return message;
            }
        } else {
            message = 'No matching event record found';
        }
        return message;
        
    }
        
}