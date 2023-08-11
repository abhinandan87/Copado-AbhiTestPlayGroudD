//-----------------------------
// @author: Prachi Bhasin
// @date: 3 July 2017
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
// @Update author : Hemant Shukla
// @Updated On : 21 NOV 2017
// @description : SFDC1-5857 : Removing a method checkEndUserCertificateAttachment() as this validation is not longer needed.
// @Last Modified By : Prachi Bhasin
// @Last Modified Date: 20 Dec 2017
// @Last Modified Description: SFDC1-6411:Updated validation method checkPrimaryContact so that stage '3 - renewal pending' can bypass the validation.
// @Last Modified By : Sonam Raju
// @Last Modified Date: 3 Jan 2018
// @Last Modified Description: SFDC1-6245: When a Channel Partner owns an opportunity, it cannot be moved past Stage 2 if it doesn't have a Opportunity Team Member with a Channel Manager Role
// @Last Modified By : Paras Dhingra
// @Last Modified Date: 4th Jan 2018
// @Last Modified Description: SFDC-4723 Update Oppy split on GAM update
// @Last Modified By : Sonam Raju
// @Last Modified Date: 8th Mar 2018
// @Last Modified Description: SFDC1-6937 Added method to create Additional Opportunity Field record when a 'New Business' Opportunity is created
// @Last Modified By: Sruti Srivastava
// @Last Modified Date: 9th April 2018
// @Last Modified Description: SFDC1-7027- Added method updateContractStartDateAndEndDateOnOpportunityLineItem which updates
// Contract Start Date and End Date on Opportunity Line Items if 'ContractStartDate__c' 
// and 'ContractEndDate__c' field on Opportunity are updated.
// @Last Modified By : Anjani Shukla
// @Last Modified Date: 09 Apr 2018
// @Last Modified Description: SFDC1-7667 : Added Method 'updateOpportunityRiskRecordStatus' to update Opportunity Risk Record Status when New Business //                                          Opportunity is being set to 6L - Closed Lost and an Opportunity at Risk record exists with the status = "Open - //                                          Pending Resolution", then 
//                                          set the Status field to “Closed - Opportunity Lost”.
// @Last Modified By : Anjani Shukla
// @Last Modified Date : 05 Jun 2018
// @Last Modified Description - SFDC1-8392 : Update Account Manager on Opportunity when Account is updated.
// @Last Modified By : Anjani Shukla
// @Last Modified Date : 21 Jun 2018
// @Last Modified Description - SFDC1-8147 : Product Restriction - Added metohd updateOpportunityProductRestriction to restrict Opportunity Stage Change.
// @Last Modified By : Paras Dhingra
// @Last Modified Date : 28 Jun 2018
// @Last Modified Description - SFDC1-8243 : Updating fiscal year of Opportunity schedules on change of opportunity close date
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 21 Aug 2018
// @Last Modified Description : SFDC1-8620 Resolving Apex security Risk - CRUD delete, adding isDeleteable() before delete operation
// @Last Modified By : Prachi Bhasin
// @Last Modified Company : VERTIBA
// @Last Modified Date : 23 Aug 2018
// @Last Modified Description : SFDC1-9831, 9841, 9844, 9845 Oppty Process builder to code changes
// @Last Modified Company : VERTIBA
// @Last Modified By : Jagadesh Kumar
// @Last Modified Company : VERTIBA
// @Last Modified Date : 03 Sep 2018
// @Last Modified Description : SFDC1-9781 : Create Implementation Case when Markit Auto-Renewal is move to 6W-Renewal Won
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 22 Oct 2018
// @Last Modified Description: SFDC1-9347 add '6W-Forecasting Placeholder' and '6WP-Closed Won/Order Processed' to the list of Opportunity's Closed Won stage.
// 							Also moved the logic to a seperate method to be shared by other Opportunity and Contract methods
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 5th Dec 2018
// @Last Modified Description: SFDC1-10649 add Contract Management profile to the Allowed list for updating Auto-Renewal Opportunity fields
// 						(this will be combined with additional security on FLS to determine which field they can actually update)
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 14th Dec 2018
// @Last Modified Description: SFDC1-10757 add Order Management profile to the Allowed list for updating Auto-Renewal Opportunity fields
// 						(this will be combined with additional security on FLS to determine which field they can actually update)
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 04th Jan 2019
// @Last Modified Description: SFDC1-10744 add logic to check User profile before deleting Opportunity record
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 08th Jan 2019
// @Last Modified Description: SFDC1-10880 Skip the check on Product Restrictions when moving Opportunity stage from 6W to 6WP 
// 							(this is the logic when contract is already in flight, from requirement in SFDC1-5326 which was missing in the implementation for that story)
//
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 08 Feb 2019
// @Last Modified Description : SFDC-614: Implementation Proof of Delivery Case is not needed when an Auto Renewal is set to 6W. Deleted 'createImplementationCaseWhenRenewalOpportunity6W()' method which was created in respect with parent story SFDC1-9781.
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 8 Feb 2019
// @Last Modified Description: SFDC-132 Populate Opportunity Country, Opportunity Region, Opportunity Geography from Account Country field
//				 				upon creating new Opportunity or when the Opportunity's Owner/Account Manager changes
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 11 February 2019
// @modifiedDescription: SFDC-660 Populate hidden field "Opportunity Stage" value from Opportunity, this is used in Sales Classification formulas
//
// @modifiedBy: Paras Dhingra
// @modifiedDate: 06 May 2019
// @modifiedDescription: SFDC-1364 Reset Account Manager Split to avoid getting wiped off on owner change
// 
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 06 May 2019
// @modifiedDescription: SFDC-177 update originating contract's Continuation End Date value (from Renewal Opportunity) when it's empty or has a prior date
// 
// @modifiedBy: Paras Dhingra
// @modifiedDate: 13 Jun  2019
// @modifiedDescription: SFDC-1641 Updating the logic to bug such that stage change on oppy only syncs opportunity stage on oppy products and not other things

// @modifiedBy: Paras Dhingra
// @modifiedDate: 03 Jul  2019
// @modifiedDescription: SFDC-1621 fixing the bug which was not letting contract start date from syncing into contract

// @modifiedBy: Dev Aggarwal
// @modifiedDate: 07 Oct  2019
// @modifiedDescription: SFDC-2015 if the contract start date and end date on Line item is same as opportunity, only then the dates on the line items should be updated.
// 					   : SFDC-2008 Changing opportunity owner should be cascaed down to all line items which have same owner as opportunity.
// @modifiedBy: Paras Dhingra
// @modifiedDate: 22 Jun 2020
// @modifiedDescription: SFDC-3071 adding references of GlobalVariables.shouldContractValidationBypass to prevent firing of validation while modifying opportunity
// @modifiedBy: Akshay Dogra
// @modifiedDate: 10 Sept 2020
// @modifiedDescription: SFDC-3373 Modified method to create Additional Opportunity Field record when any record type Opportunity is created.

// @modifiedBy: Sharique Iqbal
// @modifiedDate: 28 Jan 2020
// @modifiedDescription: SFDC-2151 New logic to identify multiyear opportunities. If the difference between the 2 dates(CST & CED) is 2 years - then the Multiyear checkbox would be set to yes
//-----------------------------
public class OpportunityMethods {
    
  public static Boolean isAccountManagersPresent = false;
  public static boolean isOpportunityOwnerChanged = false;
//-----------------------------
// @author: Prachi Bhasin
// @date: 2 July 2017
// @param: TriggerParameters tp
// @description: When the GAM is updated on Opportunity, this method updates this user's name as the GAM Opportunity Team Member
// @return: None
// @Updated By : Mohit Modi
// @description: SFDC1- 1036 : updated the Team Role 'GAM' to 'Account Owner' for the Opportunity Team Member Roles
//------------------------------
    public static void updateGAMOnOpportunityTeam(TriggerParameters tp) {
        Map<Id,Id> opportunityGAMMap = new Map<Id,Id>();
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>)tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>)tp.oldMap;
        Map<Id,OpportunityTeamMember> mapOppIdAndTeamMember = new Map<Id,OpportunityTeamMember>();
        
        List<OpportunityTeamMember> listTeamToBeInserted = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> listTeamToBeDeleted = new List<OpportunityTeamMember>();        
        try{
            for(Opportunity newOpp: mapNewOpportunity.values()) {
                Opportunity oldOpportunity = new Opportunity();
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldOpportunity = mapOldOpportunity.get(newOpp.Id);
                }
                
                if(newOpp.GAM__c != oldOpportunity.GAM__c)
                    opportunityGAMMap.put(newOpp.Id, newOpp.GAM__c);
            }
            if(!opportunityGAMMap.isEmpty()) {
                List<OpportunityTeamMember> listExistingGAMOnOpportunity = new List<OpportunityTeamMember>();
                listExistingGAMOnOpportunity = [Select Id,TeamMemberRole,UserId,OpportunityId from OpportunityTeamMember where opportunityId IN: opportunityGAMMap.keyset() AND TeamMemberRole=: 'Account Owner' ];
                for(OpportunityTeamMember oppTeamMember : listExistingGAMOnOpportunity) {
                    mapOppIdAndTeamMember.put(oppTeamMember.OpportunityId,oppTeamMember);
                }
                
                for(Id oppId: opportunityGAMMap.keyset()) {
                    if(mapOppIdAndTeamMember.containsKey(oppId) && opportunityGAMMap.get(oppId)!=null) {
                        OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(oppId,opportunityGAMMap.get(oppId),'Edit','Account Owner'); 
                        listTeamToBeInserted.add(oppTeamMember);
                        listTeamToBeDeleted.add(mapOppIdAndTeamMember.get(oppId));
                    }
                    else if(!mapOppIdAndTeamMember.containsKey(oppId) && opportunityGAMMap.get(oppId)!=null) {
                        OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(oppId,opportunityGAMMap.get(oppId),'Edit','Account Owner');                
                        listTeamToBeInserted.add(oppTeamMember);
                    }
                    else if(mapOppIdAndTeamMember.containsKey(oppId) && opportunityGAMMap.get(oppId) == null) {
                        OpportunityTeamMember oppTeamMember = mapOppIdAndTeamMember.get(oppId);
                        listTeamToBeDeleted.add(oppTeamMember);
                    }           
                }
                
                if(listTeamToBeInserted.size()>0) {
                    insert listTeamToBeInserted;
                }
                if(listTeamToBeDeleted.size()>0 && OpportunityTeamMember.sObjectType.getDescribe().isDeletable()) {
                    delete listTeamToBeDeleted;
                }
            }
        }
        catch(Exception e) {
            System.debug('Error at line 82, method updateGAMOnOpportunityTeam, class OpportunityMethods');
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='OpportunityMethods',ErrorDescription__c='Error at line 65: '+e.getMessage(),FunctionName__c='updateGAMOnOpportunityTeam');
            insert apexLogRecord;          
        }
    }
    
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 2 July 2017
    // @param: Id Opportunity Id,Id User Id,String Opportunity Access Level,String Team Member Role
    // @description: This method adds an OpportunityTeamMember to Opportunity 
    // @return: None
    //------------------------------
    public static OpportunityTeamMember createOpportunityTeamMember(Id OpportunityId, Id UserId, String OpportunityAccessLevel, String TeamMemberRole) {
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
        oppTeamMember.OpportunityId = OpportunityId;
        oppTeamMember.UserId = UserId;
        oppTeamMember.TeamMemberRole = TeamMemberRole;
        oppTeamMember.OpportunityAccessLevel= OpportunityAccessLevel;
        oppTeamMember.OpportunityGAMValue__c = TRUE;
        return oppTeamMember;
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: TriggerParameters tp 
    // @description: This method checks a primary contact is present or not on New Business Opportunity when it is moving to Stage-2 
    // @return: None
    // @Update Author: Mohit Modi
    // @Description : SFDC1-2502,SFDC1-480 : Added the logic for checkeing the Valid Email Address and Status for the Primary Contact on Opportunity
    // @Modification : exemption for sys admin and sales ops profile removed as per SFDC1-5782 and SFDC1-5029
    // @Modified by : Ankita Singh on 4th December,2017 
    // @lastmodifiedby : Mohit Modi
    // @lastmodifieddate : 23 May 2018
    // @lastmodifieddescription : SFDC1-6971-Adding StageName change check to resolve query issue.As this method is called from beforeUpdate handler
    // @lastmodifiedby : Paras Dhingra
    // @lastmodifieddate : 05th Feb 2021
    // @lastmodifieddescription : SFDC-3903 adding validation bypass for admin users
    //------------------------------
    public static void checkPrimaryContactOnNewBusinessOpportunity(TriggerParameters tp) {
        //if user has validation by pass custom permission then skip validation
        if(UtilityClass.hasValidationBypassPermission) {
            return;
        }
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>)tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>)tp.oldMap;     
        Map<Id,Opportunity> stage2NewBusinessOpportunity = new Map<Id,Opportunity>();
        
        Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        
        try{
            for(Opportunity opp: mapNewOpportunity.values()) {        
                if(mapOldOpportunity != NULL && mapOldOpportunity.get(opp.id).StageName != opp.StageName && 
                ((opp.RecordTypeId == NewBusinessOppRecordTypeId ) && !(opp.StageName == '1-Sales Qualified' || opp.StageName == '6L-Closed Lost')) ||
                ((opp.RecordTypeId == RenewalOppRecordTypeId ) && !(opp.StageName == '3-Renewal Pending'))) {
                    stage2NewBusinessOpportunity.put(opp.id,opp);
                }
            }
            if(stage2NewBusinessOpportunity.size()>0) {
            
                List<OpportunityContactRole> listOpportunityContactRole = new List<OpportunityContactRole>([SELECT IsPrimary,OpportunityID,ContactId,Contact.Email,Contact.Status__c FROM OpportunityContactRole where OpportunityID IN: stage2NewBusinessOpportunity.keyset() AND IsPrimary =: TRUE]);
            
                Map<Id,Boolean> mapOpportunityAndPrimaryContact = new Map<Id,Boolean>();
                Map<Id,String> mapOpportunityAndPrimaryContactEmailValue = new Map<Id,String>();
                Map<Id,String> mapOpportunityAndPrimaryContactStatus = new Map<Id,String>();
            
                for(OpportunityContactRole oppContactRole: listOpportunityContactRole) {
                    mapOpportunityAndPrimaryContact.put(oppContactRole.OpportunityID,oppContactRole.IsPrimary);
                    mapOpportunityAndPrimaryContactEmailValue.put(oppContactRole.OpportunityID,oppContactRole.Contact.Email);
                    mapOpportunityAndPrimaryContactStatus.put(oppContactRole.OpportunityID,oppContactRole.Contact.Status__c);                   
                }
                
                for(Opportunity opp: stage2NewBusinessOpportunity.values()) {
                    String ErrorString = '';
                    
                    if(!mapOpportunityAndPrimaryContact.containsKey(opp.Id) ||(mapOpportunityAndPrimaryContact.containsKey(opp.Id) && mapOpportunityAndPrimaryContact.get(opp.Id) == false)) {
                    
                        ErrorString = System.Label.OpportunityPrimaryContactValidationError;
                    }
                    if((mapOpportunityAndPrimaryContactEmailValue.containsKey(opp.Id) && String.ISBLANK(mapOpportunityAndPrimaryContactEmailValue.get(opp.Id)))) {
                    
                        ErrorString = '\nPrimary Contact needs an email address.';
                    }
                    if(opp.RecordTypeId == RenewalOppRecordTypeId && mapOpportunityAndPrimaryContactStatus.containsKey(opp.Id) && (String.ISBLANK(mapOpportunityAndPrimaryContactStatus.get(opp.Id)) || mapOpportunityAndPrimaryContactStatus.get(opp.Id) == 'Inactive')) {
                    
                        ErrorString = '\nPrimary Contact should be Active for Renewal Opportunity.';
                    }
                    if(ErrorString != '') {
                    
                        opp.addError(ErrorString);
                    }
                }
            }
        }
        catch(Exception e) {
            UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'checkPrimaryContactOnNewBusinessOpportunity');
        }
    }
    
     /**
     * @author Paras Dhingra
     * @date 26th June 2017
     * @description SFDC1-382 method to change ownership of account
     *  with highest open opportunity owner
     * @param TriggerParameters
     * @return void
     * @companyname IHS Markit
     * @Update author : Mohit modi
     * @description : SFDC1-2098 : Updating the Code/Query for resolving the bug. Changing the Amount field to Amount__c
     * @Update author : Mohit modi
     * @description : SFDC1-4308 : Updating the Code resolving the bug. Changing in Error Catching Method
	 * @Modified by : Paras Dhingra
	 * @Modified date : 29th May 2020
     * @description : SFDC-1974 : Adding condition for owner change to recalculate account owner
	 * @Modified by : Paras Dhingra
	 * @Modified date : 22nd July 2020
     * @description : SFDC-3032 : Changing the logic for calculation for make highest first year value aggregated user as account owner
     */
     
     public static void changeAccountOwnershipOnInsertUpdate(TriggerParameters tp) {
         
         //check if it's an insert or update
         try {
            //map to store Account and opportunity Values
            Map<id,id> mapAccountIdOpportunityId = new Map<id,id>();
            //fetch the accountIds of opportunities
            List<Id> lstAccountsToBeUpdated = new List<Id>();
            Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>)tp.oldMap;
            //iterate through new list and update opportunity owner
            for(Opportunity opp: (List<Opportunity>)tp.newList) {
                if((tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) || 
                    (   tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate 
                        && ((opp.Amount__c != mapNewOpportunity.get(opp.Id).Amount__c) || (opp.ownerId != mapNewOpportunity.get(opp.Id).ownerId)|| (opp.StageName != mapNewOpportunity.get(opp.Id).StageName)) 
                        && !opp.StageName.containsignorecase('6W')
                    )
                    ) {
                    lstAccountsToBeUpdated.add(opp.accountId);
                    mapAccountIdOpportunityId.put(opp.accountId,opp.id);    
                }               
            }
            //process the records if list is not empty
            if(lstAccountsToBeUpdated!=null && !lstAccountsToBeUpdated.isEmpty()) { 
                //SFDC1-2098 : Updating the Query for resolving the bug. Changing the Amount field to Amount__c
                //SFDC1-10407 : Adding ByPassValidation__c field to byPass the Validation Rule while changing the Owner using Apex
                AggregateResult[] groupedOpportunityOwners = [SELECT Sum(FirstYearValue__c) sumOfFirstYearValue,  AccountID accountRecordId, OwnerId ownerRecordId FROM Opportunity 
                                                                WHERE IsClosed = false AND FirstYearValue__c!=null AND AccountID in : lstAccountsToBeUpdated AND Owner.IsActive=true AND Account.GlobalAccountManager__c = null
                                                                GROUP BY AccountID, OwnerId ORDER BY AccountID, SUM(FirstYearValue__c) DESC LIMIT 10000];
                                                                //limit is added just in case there are too many records returned
                //Aggregate result traverse and update accounts
                Map<String,Account> mapAccountsToUpdate = new Map<String,Account>();
                if(groupedOpportunityOwners!=null && !groupedOpportunityOwners.isEmpty()) {
                    for(AggregateResult accountResult : groupedOpportunityOwners) {
                        Id accountId = (Id)accountResult.get('accountRecordId');
                        if(!mapAccountsToUpdate.containsKey(accountId)) {
                            //only process the accountId once because order by will return highest sum oppy owner first
                            String ownerRecordId = (Id)accountResult.get('ownerRecordId');
                            Account tempAccountToUpdate = new Account(Id = accountId,ownerId = ownerRecordId);
                            mapAccountsToUpdate.put(accountId, tempAccountToUpdate);
                        }
                    }
                    if(mapAccountsToUpdate!=null && !mapAccountsToUpdate.isEmpty()) {
                        GlobalConstants.updatingAccountOwnerFromTrigger = true;
                        update mapAccountsToUpdate.values();
                        GlobalConstants.updatingAccountOwnerFromTrigger = false;
                    }
                }
                /*List<Account> lstAccountOwnershipUpdate = [Select id, OwnerId, ByPassValidation__c,
                                                          (select id, OwnerId,convertCurrency(FirstYearValue__c) from Opportunities where isClosed = false and Owner.IsActive=true ORDER By FirstYearValue__c DESC limit 1 )
                                                          from account where GlobalAccountManager__c=null and id in : lstAccountsToBeUpdated];
                if(lstAccountOwnershipUpdate!=null && !lstAccountOwnershipUpdate.isEmpty()) {
                    List<Account> lstAccountOwnersToBeUpdated = new List<Account>();
                    for(Account acc: lstAccountOwnershipUpdate) {
                        if(acc.Opportunities!=null && !acc.Opportunities.isEmpty()) {
                            if(acc.OwnerId!=acc.Opportunities[0].OwnerId) {
                                acc.OwnerId = acc.Opportunities[0].OwnerId;
                                acc.ByPassValidation__c = true;
                                lstAccountOwnersToBeUpdated.add(acc);
                            }
                        }
                    }
                    if(lstAccountOwnersToBeUpdated!=null && !lstAccountOwnersToBeUpdated.isEmpty()) {
                        list<Account> lstAccounttobeRevertedByPassValidation = new list<Account>();
                        
                        Database.SaveResult[] lstSR = Database.update (lstAccountOwnersToBeUpdated,false);
                        //show error message based on the list success or error
                        for(Integer i=0; i<lstAccountOwnersToBeUpdated.size(); i++) {
                            Database.SaveResult dsr = lstSR[i];
                            if(!dsr.isSuccess()) {
                                for(Database.Error err: dsr.getErrors()) {
                                    tp.newMap.get(mapAccountIdOpportunityId.get(lstAccountOwnersToBeUpdated[i].id)).addError(err.getMessage());
                                }
                            }
                            // Reverting the ByPassValidation__c to False Only for the Success Records
                            else {
                                lstAccountOwnersToBeUpdated[i].ByPassValidation__c = false;
                                lstAccounttobeRevertedByPassValidation.add(lstAccountOwnersToBeUpdated[i]);
                            }
                        }
                        if(lstAccounttobeRevertedByPassValidation!=null && !lstAccounttobeRevertedByPassValidation.isEmpty()) {
                            update lstAccounttobeRevertedByPassValidation;
                        }
                        
                    }
                }*/
            }
             
         }
         catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            tp.newList[0].addError(System.Label.OpportunityGenericError+description);
         }
         
     }

    /*
    * @author: Tran-Vu Tran
    * @date: 03 Jan 2019
    * @description: SFDC1-10744 add logic to check User profile before deleting Opportunity record
    * @param TriggerParameters
    * @return void
    * @companyname IHS Markit
    */
    public static void checkUserProfileBeforeDelete(TriggerParameters tp) {
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeDelete) {
            string profileName = UtilityClass.LoggedInUserProfileName;
            if (!profileName.containsIgnoreCase('System Admin')) {
                for (Opportunity opp: (List<Opportunity>)tp.oldList) {
                    opp.addError(System.Label.OpportunityDeleteDenial);
                }
            }
        }
    }
    
     /**
      * @author Paras Dhingra
      * @date 2nd August 2017
      * @description SFDC1-775 update Account Relationship field for accounts according to related opportunities and contracts
      * @param TriggerParameters
      * @return void
      * @companyname IHS Markit
	  * @modifiedby: Paras Dhingra
	  * @modifiedDate: 16 Sep 2020
	  * @modifiedDescription:SFDC-3210 changing the logic for the Account relationship field
      */
      
	public static void updateAccountRelationship(TriggerParameters tp) {
        
        if(GlobalVariables.preventRecursiveExecution) {
            GlobalVariables.preventRecursiveExecution = false;
            
            //generate accountId list
            Set<Id> setAccountId = new Set<Id>();
            Map<Id, Opportunity> oldOpps = (Map<Id, Opportunity>) tp.oldMap;
            for (Opportunity opp : (List<Opportunity>)tp.newList) {
                
                Opportunity oldOpp;
                if (oldOpps != null && !oldOpps.isEmpty()) {
                    oldOpp = oldOpps.get(opp.Id);
                }
                
                // checking if Opportunity's Stage or Closed Date changed
                if (oldOpp == null || (opp.IsWon && !oldOpp.IsWon) || (!opp.IsWon && oldOpp.IsWon) || (opp.StageName != oldOpp.StageName)) {
                    setAccountId.add(opp.accountID);
                }
            }
            //System.debug('--setAccountID--'+setAccountId);
            
            try {
                if (setAccountId.size() > 0) {
	                updateAccountRelationship(setAccountId);
                }
            } catch(Exception ex) {
                String description = '\n Cause: '+ ex.getCause() +'\n Message: '+ ex.getMessage();
                tp.newList[0].addError(System.Label.OpportunityGenericError+description);
                UtilityClass.createApexLogRecord(ex, 'OpportunityMethods', 'updateAccountRelationship'); 
            }
        }
    }   
      
     /**
      * @author: Paras Dhingra
      * @date: 2nd August 2017
      * @description SFDC1-775 update Account Relationship field for accounts according to related opportunities
      * @modifiedBy: Tran-Vu Tran
      * @modifiedDate: 23rd Oct 2018
      * @modifiedDescription: SFDC1-9347 moving the logic to a seperate method to be shared by other Opportunity and Contract methods
      * @param Set<Id>: set of Account IDs to be queried
      * @return void
      * @companyname IHS Markit
      * @modifiedby: Paras Dhingra
      * @modifiedDate: 16 Sep 2020
      * @modifiedDescription:SFDC-3210 changing the logic for the Account relationship field
      * @modifiedby: Harshit Singhal
      * @modifiedDate: 24 Sep 2020
      * @modifiedDescription: SFDC-3210 change the filter criteria for contracts
      */
	    public static void updateAccountRelationship(Set<Id> setAccountsToBeQueried) {
    	    //Set<String> closedWonStage = new Set<String> {'6W-Closed Won', '6W-Renewal Won', '6W-Forecasting Placeholder', '6WP-Closed Won/Order Processed'};            
            Id renewalRecordTypeID = UtilityClass.oppyRecordTypeRenewalId;
            Set<Id> contractRecTypeIdSet = new Set<Id>();
            contractRecTypeIdSet.add(UtilityClass.trialContractRecordTypeId);
            contractRecTypeIdSet.add(UtilityClass.consultingContractRecordTypeId);
            contractRecTypeIdSet.add(UtilityClass.orderFormContractRecordTypeId);
            
            
            if(setAccountsToBeQueried!=null && !setAccountsToBeQueried.IsEmpty()) {
            //query accounts and its children
            /*List<Account> lstAccountsData = [Select Id, Relationship__c, Name,OpenOpportunityCount__c,ClosedWonOpportunityCount__c,
                                             (select Id from Opportunities where RecordTypeId=:renewalRecordTypeID and IsClosed=false),
                                             (Select Id from Contracts where Active__c = True)
                                             from Account where Id in: setAccountsToBeQueried];*/
                
            List<Account> lstAccountsData = [SELECT Id, Relationship__c, Name,OpenOpportunityCount__c,ClosedWonOpportunityCount__c,
                                             (SELECT Id,RecordTypeId,IsClosed,IsWon FROM Opportunities WHERE RecordTypeId=:renewalRecordTypeID AND IsClosed=false),
                                             (SELECT Id,Active__c FROM Contracts WHERE RecordTypeId IN :contractRecTypeIdSet)
                                             FROM Account WHERE Id IN :setAccountsToBeQueried];
            
            List<Account> lstAccountsToBeUpdated = new List<Account>();
            
            if (lstAccountsData != null && !lstAccountsData.isEmpty()) {
                
                //Date todayLastYear = System.today().addDays(-365);
                
                for(Account acc : lstAccountsData) {
                    String currentRelationship = acc.RelationShip__c;
                    String toBeRelationship = 'Prospect';
                    
                    Boolean hasContract = acc.Contracts!=null && acc.Contracts.size()>0 ? true : false;                    
                    Boolean hasOpenRenewalOpp = acc.Opportunities!=null && acc.Opportunities.size()>0 ? true : false;
                    Boolean hasOpenOpp = acc.OpenOpportunityCount__c>0 ? true : false;
                    Boolean hasWonOpp = acc.ClosedWonOpportunityCount__c>0 ? true : false;
                    Boolean hasActiveContract = false;                    
                    if(hasContract) {
                        for(Contract contractObj: acc.Contracts) {
                            if(contractObj.Active__c) {
                                hasActiveContract = true;
                                break;
                            }
                        }
                    }
                    
                    if(hasActiveContract || hasOpenRenewalOpp) {
                        toBeRelationship = 'Customer';
                    }
                    else if(hasOpenOpp) {
                        toBeRelationship = 'Prospect (Open Pipe)';
                    }
                    else if(hasContract || hasWonOpp) {
                        toBeRelationship = 'Prospect (Previous Customer)';
                    }
                    
                    if(String.isBlank(currentRelationship) || !toBeRelationship.equals(currentRelationship)) {
                        acc.RelationShip__c = toBeRelationship;
                        lstAccountsToBeUpdated.add(acc);
                    }
                    
                    /*
                    //by default all accounts are prospect
                    if((acc.Opportunities!=null && acc.Opportunities.size()>0) ||(acc.Contracts!=null && acc.Contracts.size()>0) ) {
                        //it is an active customer
                        acc.RelationShip__c = 'Customer';
                        lstAccountsToBeUpdated.add(acc);
                        continue;//move to next account
                    }
                    if(acc.OpenOpportunityCount__c>0) {
                        acc.RelationShip__c = 'Prospect (Open Pipe)';
                        lstAccountsToBeUpdated.add(acc);
                        continue;//move to next account
                    }
                    if(acc.ClosedWonOpportunityCount__c>0) {
                        acc.RelationShip__c = 'Prospect (Previous Customer)';
                        lstAccountsToBeUpdated.add(acc);
                        continue;
                    }
                    acc.Relationship__c = 'Prospect';
                    lstAccountsToBeUpdated.add(acc);
                    */
                    
                    /*if ((acc.Opportunities == null || acc.Opportunities.size() == 0)
                        && (acc.Contracts == null || acc.Contracts.size() == 0)
                        && acc.Relationship__c!='Prospect') {
                        //System.debug('CASE 1: Updating account ' + acc.Name + ' to "Prospect"');
                        acc.Relationship__c = 'Prospect';
                        lstAccountsToBeUpdated.add(acc);
                    }
                    else if (acc.Contracts != null && !acc.Contracts.isEmpty() && acc.Relationship__c != 'Customer') {
                        //System.debug('CASE 2: Updating account ' + acc.Name + ' to "Customer"');
                        acc.Relationship__c = 'Customer';
                        lstAccountsToBeUpdated.add(acc);
                        continue;
                    }
                    else if (acc.Opportunities != null && acc.Opportunities.size() > 0) {
                        if (acc.Opportunities[0].CloseDate < todayLastYear
                            && (acc.Contracts == null || acc.Contracts.isEmpty())
                            && acc.Relationship__c  !='Previous Customer') {
	                        //System.debug('CASE 3: Updating account ' + acc.Name + ' to "Previous Customer"');
                            acc.Relationship__c = 'Previous Customer';
                            lstAccountsToBeUpdated.add(acc);
                        }
                        else if (acc.Opportunities[0].CloseDate >= todayLastYear && acc.Relationship__c != 'Customer') {
	                        //System.debug('CASE 4: Updating account ' + acc.Name + ' to "Customer"');
                            acc.Relationship__c = 'Customer';
                            lstAccountsToBeUpdated.add(acc);
                        }
                    }*/
                }
                
                if (lstAccountsToBeUpdated != null && lstAccountsToBeUpdated.size() > 0) {
                    update lstAccountsToBeUpdated;
                }
            }
        }
    }
    
      /**
      * @author Prachi Bhasin
      * @date 8th Sept 2017
      * @description SFDC1-1990 Populate External Source System on Create
      * @param TriggerParameters
      * @return void
      * @companyname Vertiba
      */
      
      public static void populateExternalSourceSystemOnOpportunity(TriggerParameters tp) {
        try {
            for(Opportunity opp : (List<Opportunity>)tp.newList) {
                    if(opp.Isclone() && opp.getCloneSourceId()!=NULL)
                        opp.SourceSystem__c = 'Clone';
                }  
            }
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            tp.newList[0].addError(System.Label.OpportunityGenericError+description);
        }
          
      }

    /**
     * @author: Vishnu vardhan Chowdary Andra
     * @date: 13 September 2017
     * @description: SFDC1-2207, SFDC1-1085: When GAM is changed an accuont then account trigger
     *      gets executed and updates GAM on all the open opportunities. But when opportunity is
     *      created from account or directly, then account's GAM is not cascaded to the opportunity.
     *      This method is written to populate opportunity's GAM when it is created.    
     * @companyname: VERTIBA 
    */
    public static void updateGAMOnOpportunityCreation(TriggerParameters tp) {
        Set<Id> setAccountId = new Set<Id>();
        //Collect all the accounts and get the GAM details
        for(Opportunity opp : (List<Opportunity>)tp.newList) {
            setAccountId.add(opp.accountID);
        }
        if(!setAccountId.isEmpty()) {
            Map<Id, Account> accountsMap = new Map<Id,Account>(
                    [Select Id, GlobalAccountManager__c, GlobalAccountManager__r.Name from Account where id in:setAccountId]);
            if(accountsMap!=null && !accountsMap.isEmpty()) {
                //For each opportunity, get the account from MAP and update GAM.
                for(Opportunity opp : (List<Opportunity>)tp.newList) {
                    Account account = accountsMap.get(opp.AccountId);
                    if(account != null && account.GlobalAccountManager__c != null) {
                        //As per the SFDC1-413 'Account GAM always wins over opportunity GAM'
                        //So not checking if opportunity has GAM or not.
                        opp.GAM__c = account.GlobalAccountManager__c;
                        //SFDC-5890 bug fix-
                        opp.AccountManagers__c = account.GlobalAccountManager__r.Name;
                        isAccountManagersPresent = true;
                    }
                }
            }
        }
    }
    /**
     * @author: Sonam Raju
     * @date: 13 December 2017
     * @description: SFDC1-6245 When a Channel Partner owns an opportunity, 
     * it cannot be moved past Stage 2 if it doesn't have a Opportunity Team Member with a Channel Manager Role
     * @companyname: VERTIBA 
    */
   
    public static void checkChannelManagerRoleonOpptyTeamforStage2andhigher(TriggerParameters tp) {
        set<string> teamMemberRoleSet = new set<string>();
        Map<Id,Opportunity> MapOpptyWithStage2orHigher = new Map<Id,Opportunity>();
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>)tp.oldMap;
        try{ 
            
            for(Opportunity opp: (List<Opportunity>)tp.newList) {
                if((!((opp.StageName.contains('1-'))||(opp.StageName.contains('3-Renewal Pending')))) && (opp.StageName!=mapOldOpportunity.get(opp.Id).StageName)) {
                        MapOpptyWithStage2orHigher.put(Opp.Id, opp);
                }
            }
            if(MapOpptyWithStage2orHigher.size() >0) {
                Profile pf = [SELECT Id,name FROM Profile where Name like 'IHS Markit: Channel Partner User%'];
                for(Opportunity opp: [ select id,owner.Profile.Name, owner.profileId, ( Select Id,TeamMemberRole,UserId,OpportunityId from OpportunityTeamMembers) from opportunity where Id IN: MapOpptyWithStage2orHigher.keyset() ]) {
                    if(opp.owner.ProfileId == pf.id) {
                        if(opp.OpportunityTeamMembers.size() > 0 ) {
                            for(OpportunityTeamMember opptyTeamMember : opp.OpportunityTeamMembers ) {
                                teamMemberRoleSet.add(opptyTeamMember.TeamMemberRole);
                                }
                            if(!teamMemberRoleSet.contains('Channel Manager')) {
                                tp.newMap.get(opp.id).addError(System.Label.OpptyChannelPartnerError);
                            }
                            } 
                        else {
                                tp.newMap.get(opp.id).addError(System.Label.OpptyChannelPartnerError);
                            }
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('Error at line 384, method checkChannelManagerRoleonOpptyTeamforStage2andhigher, class OpportunityMethods');
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='OpportunityMethods',ErrorDescription__c=e.getMessage(),FunctionName__c='checkChannelManagerRoleonOpptyTeamforStage2andhigher');
            insert apexLogRecord;     
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 12 February 2019
    // @description: SFDC-615 Add logic to update SplitCountry field when Opportunity Owner or Account Manager changes
    // This method will be called in afterupdate trigger Events.
    // @return: None
    //------------------------------
    /*
    public static void updateOpportunitySplits(TriggerParameters tp) {
        
        Map<Id, Opportunity> mapNewOpportunity = (Map<Id, Opportunity>)tp.newMap;
        Map<Id, Opportunity> mapOldOpportunity = (Map<Id, Opportunity>)tp.oldMap;
        Map<Id, OpportunitySplit> mapOpportunitySplits = new Map<Id, OpportunitySplit>();
        Set<Id> setOpportunityIds = new Set<Id>();
        
        try{
            // Add all opportunity to a set, if OpportunityCountry__c has been modified
            if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                for (Opportunity newOpp: mapNewOpportunity.values()) {
                    Opportunity oldOppty = mapOldOpportunity.get(newOpp.Id);
                    if (oldOppty != null &&
                        (newOpp.OpportunityCountry__c != oldOppty.OpportunityCountry__c)
                       ) {
                           setOpportunityIds.add(newOpp.Id);
                       }
                }
            }
            
            // Querying related Opportunity Split records 
            if (!setOpportunityIds.isEmpty()) {
                for (OpportunitySplit split : [Select Id, SplitCountry__c, OpportunityId, Opportunity.OpportunityCountry__c
                                                from OpportunitySplit where opportunityId in: setOpportunityIds ]) {
                    // if the values changed
                    if (split.SplitCountry__c !=  split.Opportunity.OpportunityCountry__c
                       ) { // then update the field values on Opportunity Split record as well
                           mapOpportunitySplits.put(split.Id, new OpportunitySplit(Id = split.Id, SplitCountry__c = split.Opportunity.OpportunityCountry__c));
                       }
                }
                
                //  Update opportunity Products
                if(!mapOpportunitySplits.isEmpty()) {
                    update mapOpportunitySplits.values();
                }
            }
        }
        catch(Exception e) {
            System.debug('Exception in OpportunityMethods.updateOpportunitySplits');
            UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updateOpportunitySplits');
        }
    }
	*/

    //-----------------------------
    // @author: Paras Dhingra
    // @date: 04th Jan 2018
    // @param: TriggerParameters
    // @description: SFDC1-4723 Update Overlay oppy split on GAM update
    // @return: None
    //------------------------------
    public static void updateOpportunitySplitOnGamChange(TriggerParameters tp) {
        List<OpportunitySplit> listOppySplitToInsert = new List<OpportunitySplit>();
        
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>)tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>)tp.oldMap;
        Set<Id> setOppyChanged = new Set<Id>();
        //query overlay split type id
        Id overlaySplitTypeId = UtilityClass.OverlayId;
        try {
            for(Opportunity newOppy: mapNewOpportunity.values()) {
                
                Opportunity oldOppy = new Opportunity();
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldOppy = mapOldOpportunity.get(newOppy.Id);
                }
                if(newOppy.GAM__c!=oldOppy.GAM__c) {
                    
                    // oppy changed.. add it to overlay delete list
                    setOppyChanged.add(newOppy.Id);
                    //add new GAM as overlay split member
                    if(newOppy.GAM__c!=null) {
                        OpportunitySplit newOppySplit = new OpportunitySplit();
                        newOppySplit.OpportunityID = newOppy.Id;
                        newOppySplit.SplitTypeId = overlaySplitTypeId;
                        newOppySplit.SplitOwnerId = newOppy.GAM__c;
                        newOppySplit.SplitPercentage = 100.00;
                        listOppySplitToInsert.add(newOppySplit);
                    }
                    
                }
            }
            //query old split related to GAM and delete them 
            if(setOppyChanged!=null && !setOppyChanged.isEmpty()) {
                List<OpportunitySplit> listOppySplitToDelete = new List<OpportunitySplit>();
                listOppySplitToDelete = [Select Id from OpportunitySplit 
                                        where  OpportunityID IN:setOppyChanged AND SplitTypeId=:overlaySplitTypeId];
                if(listOppySplitToDelete!=null && !listOppySplitToDelete.isEmpty()) {
                   delete listOppySplitToDelete; 
                }
            }
            //create new Opportunity Splits
            if(listOppySplitToInsert!=null && !listOppySplitToInsert.isEmpty()) {
                insert listOppySplitToInsert;
            }
        } 
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            tp.newList[0].addError(System.Label.OpportunityGenericError+description);
            
        }
    }
    //-----------------------------
    // @author: Sonam Raju adapted from Uttam's code
    // @date: 8 Mar 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6937 When a 'New Business 'Opportunity is created, manually or from an external system 
    //                          we need to create an additional opportunity fields record which can hold aditional 
    //                          opportunity associated information.
    // @return: None
    //  @modified by : Paras Dhingra
    // @modified date: 07-09-2018
    // @description: Modified to accomodate migration changes and sync legacy fields with additional opportunity fields 
	// @modifiedBy: Akshay Dogra
	// @modifiedDate: 10 Sept 2020
	// @modifiedDescription: SFDC-3373 Modified method to create Additional Opportunity Field record when any record type Opportunity is created.
    //------------------------------
    public static void setOpportunityAdditionalFieldsObject(TriggerParameters tp) {
    
        try {
        
            // List of Additional Opportunity Fields thats needs to be inserted 
            List<AdditionalOpportunityFields__c> additionalOpportunityFieldsToInsert = new List<AdditionalOpportunityFields__c>();
            
            // Map of old values and new values
            Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            
            for(Opportunity newOpportunity: mapNewOpportunity.values()) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                    if(newOpportunity.AdditionalOpportunityFields__c == null) {
                        String additionalOpportunityName = ('Additional Fields - ' + newOpportunity.Name).left(80);
                        additionalOpportunityFieldsToInsert.add(new AdditionalOpportunityFields__c(Name = additionalOpportunityName, OpportunityReference__c = newOpportunity.Id,
                                                                LegacyID__c= newOpportunity.LegacyID__c, LegacyIDUnique__c = newOpportunity.LegacyIDUnique__c,
                                                                LegacyReference__c = newOpportunity.LegacyReference__c, LegacySystem__c = newOpportunity.LegacySystem__c ));
                    }
                }
            }
            
            // insert if list has any records
            if(additionalOpportunityFieldsToInsert != null && additionalOpportunityFieldsToInsert.size() > 0) {
                insert additionalOpportunityFieldsToInsert;
            }
            
        } catch(Exception ex) {
                //this will happen if any exception apart from DML exception has occurred
                UtilityClass.createApexLogRecord(ex, 'OpportunityMethods', 'setOpportunityAdditionalFieldsObject');
              
        }
    }
     //-----------------------------
    // @author: Uttam Arya
    // @date: 11 Sep 2018
    // @param: TriggerParameters tp
    // @description: SFM-159 Whenever a opportunity is created, whether manually by a user or through an integration/data migration, 
    //              an "Additional Opportunity Fields" record is automatically created and a link to this record is populated in the opportunity record.
    //              This field should not be editable by anyone except System Admin. This function changes AdditionalOpportunityFields object's Name when Opportunity's Name changes.         
    //------------------------------
    public static void changeAdditionalOpportunityFieldsNameWhenOpportunityFieldChanges(TriggerParameters tp) {

        try {
        
            // List of Additional Opportunity Fields thats needs to be inserted 
            List<AdditionalOpportunityFields__c> additionalOpportunityFieldsToUpdate = new List<AdditionalOpportunityFields__c>();
            
            // Map of old values and new values
            Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            
            System.debug('@@@UA: changeAdditionalOpportunityFieldsNameWhenOpportunityFieldChanges');
            
            for(Opportunity newOpportunity: mapNewOpportunity.values()) {
                    
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    Opportunity oldOpportunity = mapOldOpportunity.get(newOpportunity.Id);
                    if(newOpportunity.AdditionalOpportunityFields__c != null
                       && (newOpportunity.Name != oldOpportunity.Name
                            || newOpportunity.LegacyID__c != oldOpportunity.LegacyID__c
                            || newOpportunity.LegacyIDUnique__c != oldOpportunity.LegacyIDUnique__c 
                            || newOpportunity.LegacySystem__c != oldOpportunity.LegacySystem__c)) {
                                String additionalOpportunityName = ('Additional Fields - ' + newOpportunity.Name).left(80);
                                AdditionalOpportunityFields__c aof = new AdditionalOpportunityFields__c(Name = additionalOpportunityName,
                                                                                                        Id = newOpportunity.AdditionalOpportunityFields__c,
                                                                                                        LegacyID__c= newOpportunity.LegacyID__c,
                                                                                                        LegacyIDUnique__c = newOpportunity.LegacyIDUnique__c,
                                                                                                        LegacySystem__c = newOpportunity.LegacySystem__c,
                                                                                                        LegacyReference__c = newOpportunity.LegacyReference__c);
                                additionalOpportunityFieldsToUpdate.add(aof);  
                    }
                }
            }
            
            // update if the list has any records
            if(additionalOpportunityFieldsToUpdate != null && additionalOpportunityFieldsToUpdate.size() > 0) {
                update additionalOpportunityFieldsToUpdate;
            }
            
        } catch(Exception ex) {
                //this will happen if any exception apart from DML exception has occurred
                UtilityClass.createApexLogRecord(ex, 'OpportunityMethods', 'changeAdditionalOpportunityFieldsObjectNameWhenOpportunityNameChanges');
              
        }
    }
    //-----------------------------
    // @author: Mohit Modi
    // @date: 28 March 2018
    // @param: TriggerParameters
    // @description: SFDC1-7635 Update Opportunity Team based on the 'Referred By' field on Opportunity.
    //                This method will be called in afterupdate and afterInsert trigger Events.
	// @Last Modified Date: 16 Jul 2020
    // @Last Modified Description: SFDC- 1142 Disable code that adds the Referred By user to Opportunity Team
    //					Referred by field changed from a User lookup to a Contact lookup      
    // @return: None
    //------------------------------
    /**
     public static void updateReferredByOnOpportunityTeam(TriggerParameters tp) {
        Map<Id,Id> opportunityRefferedByMap = new Map<Id,Id>();
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>)tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>)tp.oldMap;
        Map<Id,OpportunityTeamMember> mapOppIdAndTeamMember = new Map<Id,OpportunityTeamMember>();
        
        List<OpportunityTeamMember> listTeamToBeInserted = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> listTeamToBeDeleted = new List<OpportunityTeamMember>();        
        try{
            // Checking for the After Update and if Opportunity ReferredBy field has been updated.
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.ReferredBy__c != mapOldOpportunity.get(newOpp.Id).ReferredBy__c) {
                        opportunityRefferedByMap.put(newOpp.Id, newOpp.ReferredBy__c);
                    }
                }
            }
            // Checking for the After Insert and if Opportunity created with ReferredBy field filled.
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.ReferredBy__c != NULL) {
                        opportunityRefferedByMap.put(newOpp.Id, newOpp.ReferredBy__c);
                    }
                }
            }
            
            if(!opportunityRefferedByMap.isEmpty()) {
                // Querying the existing Team Members with the same Role
                for(OpportunityTeamMember oppTeamMember : [Select Id,TeamMemberRole,UserId,OpportunityId from OpportunityTeamMember where opportunityId IN: opportunityRefferedByMap.keyset() AND TeamMemberRole=: 'Referred By' ]) {
                    mapOppIdAndTeamMember.put(oppTeamMember.OpportunityId,oppTeamMember);
                }
                
                for(Id oppId: opportunityRefferedByMap.keyset()) {
                    // AlreadyExist = TRUE &&  ChangedUser == TRUE : Delete the Existing and Create NEW TeamMember
                    if(mapOppIdAndTeamMember.containsKey(oppId) && opportunityRefferedByMap.get(oppId)!=null) {
                        OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(oppId,opportunityRefferedByMap.get(oppId),'Edit','Referred By'); 
                        listTeamToBeInserted.add(oppTeamMember);
                        listTeamToBeDeleted.add(mapOppIdAndTeamMember.get(oppId));
                    }
                    // AlreadyExist = FALSE &&  ChangedUser == TRUE : Only Create NEW TeamMember
                    else if(!mapOppIdAndTeamMember.containsKey(oppId) && opportunityRefferedByMap.get(oppId)!=null) {
                        OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(oppId,opportunityRefferedByMap.get(oppId),'Edit','Referred By');                
                        listTeamToBeInserted.add(oppTeamMember);
                    }
                    // AlreadyExist = TRUE &&  ChangedUser == FALSE , Removed the Existing User : Only Delete Existing TeamMember
                    else if(mapOppIdAndTeamMember.containsKey(oppId) && opportunityRefferedByMap.get(oppId) == null) {
                        OpportunityTeamMember oppTeamMember = mapOppIdAndTeamMember.get(oppId);
                        listTeamToBeDeleted.add(oppTeamMember);
                    }           
                }
                
                if(listTeamToBeInserted.size()>0) {
                    insert listTeamToBeInserted;
                }
                if(listTeamToBeDeleted.size()>0 && OpportunityTeamMember.sObjectType.getDescribe().isDeletable()) {
                    delete listTeamToBeDeleted;
                }
            }
        }
        catch(Exception e) {
            UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updateReferredByOnOpportunityTeam');
        }
    }*/
    
    //-----------------------------
    // @author: Sruti Srivastava
    // @date: 9th April 2018
    // @param: TriggerParameters
    // @description: SFDC1-7027 - Update Contract Start Date and End Date on Opportunity Line Items if 'ContractStartDate__c' 
    // and 'ContractEndDate__c' field on Opportunity are updated
    // 
    // @modifiedBy: Tran-Vu Tran
    // @modifiedDate: 12 February 2019
    // @modifiedDescription: SFDC-660 populate hidden field "Opportunity Stage" value from Opportunity, this is used in Sales Classification formulas
    // and rename method to updateOpportunityLineItems
    //  @modifiedBy: Paras Dhingra
    // @modifiedDate: 13 Jun  2019
    // @modifiedDescription: SFDC-1641 Updating the logic to bug such that stage change on oppy only syncs opportunity stage on oppy products and not other things
    // 
    // @modifiedBy: Dev Aggarwal
    // @modifiedDate: 07 October 2019
    // @modifiedDescription: SFDC- 2015 : Contract start date and end date on Line Item should only be updated if they had the same values as opportunity before update.
    //					   : SFDC- 2008 : Changing opportunity owner should be cascaded to line items if both opportunity and line items have same owners.
    //  
    // This method will be called in afterupdate trigger Events.
    // @return: None
    // 
    // @modifiedBy: Harshit Singhal
    // @modifiedDate: 27 Jan 2020
    // @modifiedDescription: SFDC-2417 Added code to cascade probability changes to opp products. Bypassed certain validations and rollups using GlobalConstants class.
    //------------------------------
    public static void updateOpportunityLineItems(TriggerParameters tp) {
       
       Map<Id, Opportunity> mapNewOpportunity = (Map<Id, Opportunity>)tp.newMap;
       Map<Id, Opportunity> mapOldOpportunity = (Map<Id, Opportunity>)tp.oldMap;
       Map<Id, OpportunityLineItem> mapOpportunityLineItems = new Map<Id, OpportunityLineItem>();
       Set<Id> setOpportunityIds = new Set<Id>();
       Set<Id> setOpportunityIdsStageChanged = new Set<Id>();
       Set<Id> setOpportunityIdsDatesChanged = new Set<Id>();
       Set<Id> setopportunityIdsOwnerChanged = new Set<Id>();
       Set<Id> setopportunityIdsProbChangedOnWonLost = new Set<Id>();
       try {
       // Add all opportunity to a set, if Contract Start Date or End Date or StageName has been modified
       if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
           for (Opportunity newOpp: mapNewOpportunity.values()) {
               Opportunity oldOppty = mapOldOpportunity.get(newOpp.Id);
               if(newOpp.ContractStartDate__c != oldOppty.ContractStartDate__c
                  || newOpp.ContractEndDate__c != oldOppty.ContractEndDate__c) {
                      setOpportunityIdsDatesChanged.add(newOpp.Id);
                      setOpportunityIds.add(newOpp.Id);
                  }
               if(newOpp.StageName != oldOppty.StageName) {
                   setOpportunityIds.add(newOpp.Id);
                   setOpportunityIdsStageChanged.add(newOpp.Id);
               }
               if(newOpp.OwnerId != oldOppty.OwnerId) {
                   setOpportunityIds.add(newOpp.id);
                   setopportunityIdsOwnerChanged.add(newOpp.id);
               }
               if(newOpp.Probability != oldOppty.Probability && (newOpp.Probability==0 || newOpp.Probability==100)) {
                   setOpportunityIds.add(newOpp.id);
                   setopportunityIdsProbChangedOnWonLost.add(newOpp.id);
               }
           }
       }
       
       // Querying related Opportunity Line Items 
       if (!setOpportunityIds.isEmpty()) {
           for (OpportunityLineItem oli : [Select Id,Probability__c, Status__c, ContractStartDate__c, ContractEndDate__c, OpportunityStage__c, OpportunityId,
                                           Opportunity.Probability, Opportunity.ContractStartDate__c, Opportunity.ContractEndDate__c, Opportunity.StageName,
                                           ProductOwner__c, opportunity.OwnerId from OpportunityLineItem where opportunityId in: setOpportunityIds ]) {
                                               // if dates have been changed.
                                               if(setOpportunityIdsDatesChanged.contains(oli.OpportunityId)) {
                                                   
                                                   // If start date was null before the modification or if its null after the  modification.
                                                   if(mapOldOpportunity.get(oli.OpportunityId).contractStartDate__c== null && oli.opportunity.contractStartDate__c != null  ) {
                                                       mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,ContractStartDate__c = oli.Opportunity.ContractStartDate__c));
                                                   }
                                                   else if(mapOldOpportunity.get(oli.opportunityId).contractStartDate__c != null && oli.opportunity.contractStartDate__c == null) {
                                                       if(mapOpportunityLineItems.containsKey(oli.id)) {
                                                           mapOpportunityLineItems.get(oli.id).contractStartDate__c = null;
                                                       }
                                                       else {
                                                           mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,ContractStartDate__c = null));
                                                       }
                                                   }
                                                   // start date has been changed and were same earlier.
                                                   else if(  oli.ContractStartDate__c!=oli.opportunity.contractStartDate__c ) {
                                                       //if(oli.ContractStartDate__c.isSameDay(mapOldOpportunity.get(oli.opportunityId).contractStartDate__c)) {
                                                       if(oli.ContractStartDate__c!=null && oli.ContractStartDate__c.isSameDay(mapOldOpportunity.get(oli.opportunityId).contractStartDate__c)) {
                                                           mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,ContractStartDate__c = oli.Opportunity.ContractStartDate__c));
                                                       }
                                                       // if products start day lies before the new opportunity start date, throw error.
                                                       else if (oli.ContractStartDate__c < oli.opportunity.contractStartDate__c) {
                                                           mapNewOpportunity.get(oli.opportunityId).addError(System.label.LineItemDatesOutOfRangeError);
                                                       }
                                                   }
                                                   //End Dates 
                                                   // If End date was null before the modification or if its null after the  modification.
                                                   if(mapOldOpportunity.get(oli.OpportunityId).contractEndDate__c== null && oli.opportunity.contractEndDate__c != null  ) {
                                                       if(mapOpportunityLineItems.containsKey(oli.id)) {
                                                           mapOpportunityLineItems.get(oli.id).contractEndDate__c = oli.opportunity.contractEndDate__c;
                                                       }
                                                       else {
                                                           mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,contractEndDate__c = oli.Opportunity.contractEndDate__c));
                                                       }
                                                   }
                                                   else if(mapOldOpportunity.get(oli.opportunityId).contractEndDate__c != null && oli.opportunity.contractEndDate__c == null) {
                                                       
                                                       if(mapOpportunityLineItems.containsKey(oli.id)) {
                                                           mapOpportunityLineItems.get(oli.id).contractEndDate__c = null;
                                                       }
                                                       else {
                                                           mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,contractEndDate__c = null));
                                                       }
                                                   }
                                                   // End date has been changed and were same earlier.
                                                   //else if(!oli.contractEndDate__c.isSameDay(oli.opportunity.contractEndDate__c)) {
                                                   else if(oli.contractEndDate__c!=null && !oli.contractEndDate__c.isSameDay(oli.opportunity.contractEndDate__c)) {
                                                       if(oli.contractEndDate__c.isSameDay(mapOldOpportunity.get(oli.opportunityId).contractEndDate__c)) {
                                                           if(mapOpportunityLineItems.containsKey(oli.id)) {
                                                               mapOpportunityLineItems.get(oli.id).contractEndDate__c = oli.opportunity.contractEndDate__c;
                                                           }
                                                           else {
                                                               mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,contractEndDate__c = oli.Opportunity.contractEndDate__c));     
                                                           }
                                                       }
                                                       // if products end day lies before the new opportunity end date, throw error.
                                                       else if (oli.contractEndDate__c > oli.opportunity.contractEndDate__c) {
                                                           mapNewOpportunity.get(oli.opportunityId).addError(System.label.LineItemDatesOutOfRangeError);
                                                       }
                                                   }
                                               }                    
                                               
                                               
                                               // update the Line item product owner if opportunity owner and Product owner are same.
                                               if(setopportunityIdsOwnerChanged.contains(oli.opportunityId)) {
                                                   if(oli.ProductOwner__c == null || (oli.ProductOwner__c != oli.Opportunity.OwnerId && oli.ProductOwner__c == mapoldOpportunity.get(oli.OpportunityId).ownerId) ) {
                                                       if(mapOpportunityLineItems.containsKey(oli.id)) {
                                                           mapOpportunityLineItems.get(oli.id).ProductOwner__c = oli.opportunity.ownerId;
                                                       }
                                                       else {
                                                           mapOpportunityLineItems.put(oli.id, new OpportunityLineItem(id = oli.id, ProductOwner__c = oli.opportunity.ownerId));
                                                       } 
                                                   }
                                               }
                                               
                                               if(oli.OpportunityStage__c != oli.Opportunity.StageName 
                                                  && setOpportunityIdsStageChanged.contains(oli.OpportunityId)) {
                                                      mapOpportunityLineItems.put(oli.Id, new OpportunityLineItem(Id = oli.Id,
                                                                                                                  OpportunityStage__c = oli.Opportunity.StageName)
                                                                                 ); 
                                                  }
                                               if(setopportunityIdsProbChangedOnWonLost.contains(oli.OpportunityId)) {
                                                   //Set OLI probability to Opportunity probability for New and Existing products when Opportunity is closed won or closed lost
                                                   if(oli.Opportunity.Probability!=oli.Probability__c && ((oli.Opportunity.Probability==100 && oli.Status__c!='Lost') || oli.Opportunity.Probability==0)) {
                                                       mapOpportunityLineItems.put(oli.id, new OpportunityLineItem(id = oli.id, Probability__c = oli.Opportunity.Probability));
                                                   }
                                                   //Set OLI probability to 0 if product is lost
                                                   if(oli.Opportunity.Probability==100 && oli.Status__c=='Lost' && oli.Probability__c!=0) {
                                                       mapOpportunityLineItems.put(oli.id, new OpportunityLineItem(id = oli.id, Probability__c = 0));
                                                   }
                                               }
                                               
                                           }
           
           //  Update opportunity Products
           if(!mapOpportunityLineItems.isEmpty()) {
               GlobalConstants.isOppLineItemUpdatedDueToParentOppCascade = true;
               GlobalConstants.disableOppyProductValidations = true;
               update mapOpportunityLineItems.values();
               GlobalConstants.isOppLineItemUpdatedDueToParentOppCascade = false;
               GlobalConstants.disableOppyProductValidations = false;
           }
       }
       }
        catch(DMLException dmlEx) {
            System.debug('DML Exception in OpportunityMethods.updateOpportunityLineItems'+dmlEx.getMessage());
            if(tp.newList!=null && tp.newList.size()==1) {
            	((List<Opportunity>) tp.newList).get(0).addError(dmlEx.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));
            }
            else {
                throw new TriggerException(dmlEx.getMessage());
            }            
            //throw new TriggerException('DMLEXCEPTION:'+dmlEx.getDmlMessage(0));
            //throw new TriggerException(dmlEx.getMessage());
            //UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updateOpportunityLineItems');
        }
        catch(Exception e) {
            System.debug('Exception in OpportunityMethods.updateOpportunityLineItems');
            throw new TriggerException(e.getMessage());
            //UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updateOpportunityLineItems');
        }
   }
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 09 April 2018
    // @param: TriggerParameters
    // @description: SFDC1-7667 : Added Method 'updateOpportunityRiskRecordStatus' to update Opportunity Risk Record Status when New Business Opportunity is 
    //                            being set to 6L - Closed Lost and an Opportunity at Risk record exists with the status = "Open - Pending Resolution", then 
    //                            set the Status field to “Closed - Opportunity Lost”.
    // @return: None
    //------------------------------
    public static void updateOpportunityRiskRecordStatus(TriggerParameters tp) {
        
        // stores risk renewal record (Opportunity at Risk).
        Map<Id,RenewalatRisk__c> mapOpportunityRiskRecord;
        
        // Map of old values and new values
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
        
        // Store opportunity id which has status updated to 6L-Closed Lost, Record Type is New Business and Renewal Record exist.
        Set<Id> validOptyIds = new Set<Id>();
        
        // Checking for the After Update and if Opportunity ReferredBy field has been updated.
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {  
            if(!mapNewOpportunity.isEmpty() && !mapOldOpportunity.isEmpty()) {
                for(Opportunity checkOptyStatus: mapNewOpportunity.values()) {
                    //Check if Status is updated to 6L-Closed Lost and record type is new Business.
                    if(checkOptyStatus.OpportunityRecordType__c == 'New Business' && 
                       checkOptyStatus.StageName == '6L-Closed Lost' && 
                       mapOldOpportunity.get(checkOptyStatus.id).StageName != '6L-Closed Lost' &&
                       checkOptyStatus.Countofrenewalatrisk__c != 0 ) {
                          validOptyIds.add(checkOptyStatus.id);     
                      }    
                }
            }
            
            
            // Null check for Set created above.
            if(validOptyIds != null && !validOptyIds.isEmpty()) {
                //get Opportuntiy Risk Record if Opportunity from New Map has status update.
                mapOpportunityRiskRecord = new Map<Id,RenewalatRisk__c> ( [select id,Account__c,OpportunityAtRisk__c,Status__c 
                                                                           from RenewalatRisk__c where OpportunityAtRisk__c IN : validOptyIds 
                                                                           and Status__c ='Open - Pending Resolution'] );
               
            } 
            
            try {
                if( mapOpportunityRiskRecord != null && !mapOpportunityRiskRecord.isEmpty()) {
                    // update status for Opportunity risk record.
                    for(RenewalatRisk__c updateStatusOptyRiskRecord: mapOpportunityRiskRecord.values()) {
                        updateStatusOptyRiskRecord.status__c = 'Closed - Opportunity Lost';     
                    }    
                }
            
                // Initiate DML operation.
                if(mapOpportunityRiskRecord != null && !mapOpportunityRiskRecord.isEmpty() ) {
                    update mapOpportunityRiskRecord.values();
                    system.debug('mapOpportunityRiskRecord---->'+mapOpportunityRiskRecord);
                }
            } catch(Exception e) {
                UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updateOpportunityRiskRecordStatus');
            }
        }             
    }

    //-----------------------------
    // @Author: Tran-Vu Tran
    // @Date: 8 Jan 2019
    // @Description: SFDC-132 populate Opportunity Country, Opportunity Region, Opportunity Geography from Account Country field
    // 					upon creating new Opportunity or when the Opportunity's Owner/Account Manager changes
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @return: Void
    //-----------------------------
    public static void populateOpportunityCountryFromAccount(TriggerParameters tp) {

        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            
            try {
                
                Set<Id> accountIds = new Set<Id>();
                for (Opportunity oppty : (List<Opportunity>)tp.newList) {
                    accountIds.add(oppty.AccountId);
                }
                
                Map<Id, Account> accounts = New Map<Id, Account>(
                    [select Id, BillingCountryCode, AccountCountry__c from Account where Id in : accountIds]
                );
                
                for (Opportunity oppty : (List<Opportunity>)tp.newList) {
                    Opportunity oldOpportunity;
                    if (tp.oldMap == null // new Opportunity
                        || ((oldOpportunity = (Opportunity) tp.oldMap.get(oppty.Id)) != null
                            && (oldOpportunity.GAM__c != oppty.GAM__c || oldOpportunity.OwnerId != oppty.OwnerId))
                       ) {
                           Account acc = accounts.get(oppty.AccountId);
                           if (acc != null) {
                               if (acc.AccountCountry__c != null) {
                                   oppty.OpportunityCountry__c = acc.AccountCountry__c;
                               }
                               else { // sometime Account.Country__c value is not populated, especially when account was migrated with trigger turned off
                                   Country__c country = UtilityClass.getCountryByIsoCode(acc.BillingCountryCode); // lookup country using BillingCountryCode
                                   if (country != null) {
                                       oppty.OpportunityCountry__c = country.Id;
                                   }
                               }
                           }
                    }
                }
            }
            catch (Exception e) {
                System.debug('OpportunityMethods.populateOpportunityCountryFromAccount error: ' + e.getMessage());
                UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'populateOpportunityCountryFromAccount'); 
            }
        }
    }
    
    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 6 June 2018
    // @Description :SFDC1-5785 Copy Bill to and Ship to fields to Renewal Opportunity from 
    // Originating contract(SFDC1-7542: converting process builder 'CopyBilltoShiptoFromOriginatingContractToRenewalOpportunity ' 
    // to this method
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    // 
    // @ModifiedBy: Tran-Vu Tran
    // @ModifiedDate: 1 April 2019
    // @ModifiedDescription: SFDC-492 Do not update Opportunity Bill To/Ship To fields from Originating Contract when External Source System = "SAP"
    //-----------------------------
    public static void  copyBilltoShiptoFromOriginatingContractToRenewalOpportunity(TriggerParameters tp) {
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
           tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
        { 
            try {
                Set<id> setContractId = new Set<id>();
                Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                List<Opportunity> listOpportunities = new List<Opportunity>();
                Map<Id, Opportunity> mapOldOpportunity = (Map<Id, Opportunity>)tp.oldMap;
                for (Opportunity a:(List<Opportunity>)tp.newList) {

                    Opportunity oldOpportunity;
                    if (tp.oldMap != null && tp.oldMap.get(a.Id) != null) {
                        oldOpportunity = (Opportunity)tp.oldMap.get(a.Id);
                    }
                    
                    if (tp.oldMap == null && a.ContractBeingRenewed__c != null // for beforeInsert
                        && a.RecordTypeId == renewalRecordTypeId) {
                            listOpportunities.add(a);
                            setContractId.add(a.ContractBeingRenewed__c);
                        }
                    else
                        if (tp.oldMap != null // for beforeUpdate, 
                            && (oldOpportunity.ContractBeingRenewed__c != a.ContractBeingRenewed__c // when the Originating Contact changes
                                || oldOpportunity.SourceSystem__c != a.SourceSystem__c) // or when the External Source System changes (also need to consider as per SFDC-492)
                            && a.RecordTypeId == renewalRecordTypeId) {
                                listOpportunities.add(a);
                                setContractId.add(a.ContractBeingRenewed__c);
                    }
                }
                
                if (listOpportunities!=NULL && listOpportunities.size() > 0) {
                    Map<Id,Contract> mapContract = new Map<Id,Contract> (
                        [Select Id,
                         BillToClientName__c, BillToCompanySAP__c, BillToContactSAP__c, BillToContactFirstName__c, BillToContactLastName__c, BillToContactEmailAddress__c, BillToContactTelephoneNumber__c,
                         BillToStreet__c, BillToCity__c, BillToStateProvince__c, BillToPostalZipCode__c, BillToCountryCodeLookup__c,
                         ShipToClientName__c, ShipToCompanySAP__c, ShipToContactSAP__c, ShipToContactFirstName__c, ShipToContactLastName__c, ShipToContactEmailAddress__c, ShipToContactTelephoneNumber__c,
                         ShipToStreet__c, ShipToCity__c, ShipToStateProvince__c, ShipToPostalZipCode__c, ShipToCountryCodeLookup__c
                         from Contract where Id in : setContractId]
                    );
                    
                    for (Opportunity opp : listOpportunities ) {
                        if (opp.SourceSystem__c != 'SAP') {
                            // SFDC-492 only populate Opportunity Bill To/Ship To fields from Originating Contract when External Source System is not "SAP"
                            Contract  contractObj = mapContract.get(opp.ContractBeingRenewed__c);
                            if (contractObj != null) {
                                opp.BillToClientName__c=contractObj.BillToClientName__c;
                                opp.BillToCompanySAP__c=contractObj.BillToCompanySAP__c;
                                opp.BillToContactSAP__c=contractObj.BillToContactSAP__c;
                                opp.BillToContactFirstName__c=contractObj.BillToContactFirstName__c;
                                opp.BillToContactLastName__c=contractObj.BillToContactLastName__c;
                                opp.BillToContactEmailAddress__c=contractObj.BillToContactEmailAddress__c;
                                opp.BillToContactTelephoneNumber__c=contractObj.BillToContactTelephoneNumber__c;
                                opp.BillToStreet__c=contractObj.BillToStreet__c;
                                opp.BillToCity__c=contractObj.BillToCity__c;
                                opp.BillToStateProvince__c=contractObj.BillToStateProvince__c;
                                opp.BillToPostalZipCode__c=contractObj.BillToPostalZipCode__c;
                                opp.BillToCountryNew__c=contractObj.BillToCountryCodeLookup__c!=null?UtilityClass.getCountryById(contractObj.BillToCountryCodeLookup__c).Name:'';
                                opp.ShipToClientName__c=contractObj.ShipToClientName__c;
                                opp.ShipToCompanySAP__c=contractObj.ShipToCompanySAP__c;
                                opp.ShipToContactSAP__c=contractObj.ShipToContactSAP__c;
                                opp.ShipToContactFirstName__c=contractObj.ShipToContactFirstName__c;
                                opp.ShipToContactLastName__c=contractObj.ShipToContactLastName__c;
                                opp.ShipToContactEmailAddress__c=contractObj.ShipToContactEmailAddress__c;
                                opp.ShipToContactTelephoneNumber__c=contractObj.ShipToContactTelephoneNumber__c;
                                opp.ShipToCity__c=contractObj.ShipToCity__c;
                                opp.ShipToStreet__c=contractObj.ShipToStreet__c;
                                opp.ShipToStateProvince__c=contractObj.ShipToStateProvince__c;
                                opp.ShipToPostalZipCode__c=contractObj.ShipToPostalZipCode__c;
                                opp.ShipToCountryNew__c=contractObj.ShipToCountryCodeLookup__c!=null?UtilityClass.getCountryById(contractObj.ShipToCountryCodeLookup__c).Name:'';
                            }
                            else { // if the orginating contract was removed for some reason, clear all these values (but only when External Source System is not "SAP") 
                                opp.BillToClientName__c = null;
                                opp.BillToCompanySAP__c = null;
                                opp.BillToContactSAP__c = null;
                                opp.BillToContactFirstName__c = null;
                                opp.BillToContactLastName__c = null;
                                opp.BillToContactEmailAddress__c = null;
                                opp.BillToContactTelephoneNumber__c = null;
                                opp.BillToStreet__c = null;
                                opp.BillToCity__c = null;
                                opp.BillToStateProvince__c = null;
                                opp.BillToPostalZipCode__c = null;
                                opp.BillToCountryNew__c = null;
                                opp.ShipToClientName__c = null;
                                opp.ShipToCompanySAP__c = null;
                                opp.ShipToContactSAP__c = null;
                                opp.ShipToContactFirstName__c = null;
                                opp.ShipToContactLastName__c = null;
                                opp.ShipToContactEmailAddress__c = null;
                                opp.ShipToContactTelephoneNumber__c = null;
                                opp.ShipToCity__c = null;
                                opp.ShipToStreet__c = null;
                                opp.ShipToStateProvince__c = null;
                                opp.ShipToPostalZipCode__c = null;
                                opp.ShipToCountryNew__c = null;
                            }
                        } // else, if (opp.SourceSystem__c == 'SAP') don't touch anything
                    }     
                }
            }
            catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'OpportunityMethods','CopyBilltoShiptoFromOriginatingContractToRenewalOpportunity'); 
            }
        }
    }
    
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 09 April 2018
    // @param: TriggerParameters
    // @description: SFDC1-8392 : Update Account Manager on Opportunity when Account is updated.  
    // @return: None
    //------------------------------
    public static void updateOpportunityGAM(TriggerParameters tp) {
    	// Map of old values and new values
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;  
        
        // Opportunity Ids.
        Set<Id> accountIdsLstToUpdate = new Set<Id>();
        Map<Id,Account> accountMaptoUpdate;
		// Checking for the After Update and if Opportunity ReferredBy field has been updated.
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {  
        	if(!mapNewOpportunity.isEmpty() && !mapOldOpportunity.isEmpty()) {
            	//verify if opportunity account is updated.
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.AccountId != null && mapOldOpportunity.get(newOpp.id).AccountId != null && newOpp.AccountId != mapOldOpportunity.get(newOpp.id).AccountId) {
                        if(newOpp.StageName != '6L-Closed Lost' && 
                           newOpp.StageName != '6W-Renewal Won' && 
                           newOpp.StageName != '6W-Closed Won'  && 
                           newOpp.StageName != '6L-Renewal Lost' &&
                           newOpp.StageName != '6WP-Closed Won/Order Processed'
                          ) {
                        	// Capture list opty
                        	accountIdsLstToUpdate.add(newOpp.AccountId);
                        } 
                    }    
                }
            }
            
            if(accountIdsLstToUpdate != null && !accountIdsLstToUpdate.isEmpty()) {
            	accountMaptoUpdate = new Map<Id,Account>([select id,GlobalAccountManager__c
                                                           from Account where id IN: accountIdsLstToUpdate ]);    
            }
            
            if(accountMaptoUpdate != null && !accountMaptoUpdate.isEmpty()) {
                for(opportunity updateGAM: mapNewOpportunity.values()) {
                	//Assign GAM for Updated account.        
                	updateGAM.GAM__c = accountMaptoUpdate.get(updateGAM.Accountid).GlobalAccountManager__c;
                }     
            }
        }
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 13 June 2018
    // @param: TriggerParameters
    // @description: SFDC1-8434 : An Order Management case will need to be generated when an Opportunity is set to 6W.  
    // @return: None
    // @Last Modified By : Prachi Bhasin
    // @Last Modified Date : 26 July 2018
    // @Last Modified Description - SFDC1-9411 - Mapping more fields for case creation
    // @Last Modified By : Mohit Modi
    // @Last Modified Date : 29 Nov 2018
    // @Last Modified Description - SFDC1-10379 - Added 'ContinuationEndDate__c' to Case from Renewal Opportunity
    // @Last Modified By : Uttam Arya
    // @Last Modified Date : 13 Feb 2019
    // @Last Modified Description- SFDC-256 - Removed SourceSystem__c filtering for SAP to Case from Renewal Opportunity to Create Order Management Case for SAP ARNC when PO Required is True
    // @Last Modified By : Uttam Arya
    // @Last Modified Date : 20 Feb 2019
    // @Last Modified Description- SFDC-138 - Adding the auto renewal opportunity contract start and contract end date to the OM case created when the auto-renewal contract is moved to stage 6W closed won.
    // @Last Modified By : Dev Aggarwal
    // @Last Modified Date : 20 January 2020
    // @Last Modified Description- SFDC-1909 - Changed logic for auto renewal flag on OM Case.
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date : 02 Apr 2020
    // @Last Modified Description: SFDC-2512 Stop creation of duplicate OM cases when opp Stage is moved back and forth to 6W-Renewal Won
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date : 07 Sep 2020
    // @Last Modified Description: SFDC-3352 Added isExecutingBatchAutoRenewalAutoClose boolean check. This variable will make sure that OM case logic is not skipped for opp batches that have partial DML success in each execute method call.
    //------------------------------
    public static void createOMCaseOnRenewalOpportunityClosure(TriggerParameters tp) {
        // Map of old values and new values        
        if(GlobalVariables.preventRecursiveTranstion || GlobalVariables.isExecutingBatchAutoRenewalAutoClose) {                       
            try {
                Set<Id> oppsToProcessIdSet = new Set<Id>();
                List<Case> lstOMCaseToBeCreated = new List<Case>();
                Id OMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
                Id innerYearRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inner Year').getRecordTypeId();                
                Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                // Opportunity Ids.
                Set<Id> accountIdsLstToUpdate = new Set<Id>();
                Set<Id> contrtIdForStatusUpdate = new Set<Id>();
                List<Contract> contractUpdateLst = new List<Contract>();
                Map<Id,Account> accountMaptoUpdate;                
                // Checking for the After Update
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    for(Opportunity newOpp: (List<Opportunity>)tp.newMap.values()) {
                        Opportunity oldOpp = (Opportunity) tp.oldMap.get(newOpp.Id);                            
                        /*if((newOpp.StageName != oldOpp.StageName && newOpp.StageName == '6W-Renewal Won' && newOpp.AutoRenewal__c==TRUE && newOpp.DoesThisAutoRenewalHaveChanges__c== FALSE && newOpp.SourceSystem__c!= 'SAP')
                           || (newOpp.StageName != oldOpp.StageName && newOpp.StageName == '6W-Renewal Won' && newOpp.AutoRenewal__c==TRUE && newOpp.DoesThisAutoRenewalHaveChanges__c== FALSE && newOpp.SourceSystem__c == 'SAP' && newOpp.PORequired__c)
                           || (newOpp.RecordTypeId == innerYearRecordTypeId && newOpp.StageName != oldOpp.StageName && newOpp.StageName == '6W-Renewal Won' && newOpp.PORequired__c)) {
                               oppsToProcessIdSet.add(newOpp.Id);
                           }*/
                        if(newOpp.StageName != oldOpp.StageName && newOpp.StageName == '6W-Renewal Won') {
                           //for renewals
                            if(newOpp.RecordTypeId == innerYearRecordTypeId && newOpp.PORequired__c) {
                                oppsToProcessIdSet.add(newOpp.Id);
                                continue;
                            }
                            if(newOpp.RecordTypeId == renewalRecordTypeId && newOpp.AutoRenewal__c==TRUE && newOpp.DoesThisAutoRenewalHaveChanges__c== FALSE ) {
                                if(newOpp.SourceSystem__c!= 'SAP') {
                                    oppsToProcessIdSet.add(newOpp.Id);
                                    contrtIdForStatusUpdate.add(newOpp.ContractBeingRenewed__c);//SFDC-4516
                                } 
                                else {
                                    //Decimal convertedFirstYear = newOpp.FirstYearValue__c * UtilityClass.mapCurrencyIsoCodeConversionRate.get(newOpp.CurrencyISOCode);
                                    if(Date.today()>=newOpp.ContractStartDate__c || newOpp.PORequired__c || newOpp.BSI__c!=null) {
                                        oppsToProcessIdSet.add(newOpp.Id);
                                        continue;
                                    }
                                }  
                            }
                        }
                           
                    }
                    if(oppsToProcessIdSet.size() > 0) {
                       /* Map<Id,Case> oppIdExistingOMCaseMap = new Map<Id,Case>();
                        for(Case omCase:[SELECT Id,Opportunity__c,Status FROM Case WHERE RecordType.Name='Order Management' AND Opportunity__c IN :oppsToProcessIdSet]) {
                            oppIdExistingOMCaseMap.put(omCase.Opportunity__c, omCase);
                        } */
                        for(Id oppId:oppsToProcessIdSet) {
                            Opportunity newOpp = (Opportunity)tp.newMap.get(oppId); 
                           // if(!oppIdExistingOMCaseMap.containsKey(oppId)) {
                                Case cse = new Case( AutoRenewalWithChange__c = newOpp.DoesThisAutoRenewalHaveChanges__c,
                                                    ComplianceRestrictions__c = newOpp.ComplianceRestrictions__c,
                                                    PORequired__c = newOpp.PORequired__c,
                                                    Contract__c=newOpp.ContractBeingRenewed__c,
                                                    Opportunity__c = newOpp.Id,
                                                    RecordTypeId = OMRecordTypeId,
                                                    AccountId = newOpp.AccountId,
                                                    BSIMembership__c  = newOpp.BSI__c,
                                                    Status = 'New',
                                                    Subject = 'Closed Won - Auto Renewal',
                                                    Type = 'Closed Won Auto Renewal', //SFDC-3598 change
                                                    ContinuationEndDate__c = newOpp.ContinuationEndDate__c, 
                                                    ContractStartDate__c = newOpp.ContractStartDate__c, 
                                                    ContractEndDate__c = newOpp.ContractEndDate__c);
                                if(newOpp.PriceChangeOnly__c) {
                                    cse.PriceChangeOnly__c = newOpp.PriceChangeOnly__c;
                                }
                                if(newOpp.ContractBeingRenewed__c != null && !String.isBlank(newOpp.ContractBeingRenewed__c)) {
                                    cse.autoRenewal__c = newOpp.OriginatingContractsAutoRenewal__c;
                                }
                                else {
                                    cse.AutoRenewal__c = newOpp.AutoRenewal__c;
                                }
                                if(newOpp.RecordTypeId == innerYearRecordTypeId && newOpp.PORequired__c) {
                                    cse.Subject = 'Inner Year - PO Required';  
                                    cse.Type = 'Inner Year PO Required'; //SFDC-3598 change
                                }
                                if(UtilityClass.OrderManagementQueueId!= NULL) {
                                    cse.OwnerId=UtilityClass.OrderManagementQueueId ;
                                }
                                else {
                                    cse.OwnerId = UserInfo.getUserId();
                                }   
                                lstOMCaseToBeCreated.add(cse);
                         //   }                            
                        }                                                        
                    }
                 
                    //SFDC-4516- Update Contract Status to Validated while moving the Oppy from lost to won.
                    System.debug('$$$$contrtIdForStatusUpdate---'+contrtIdForStatusUpdate);
                    if (contrtIdForStatusUpdate.size() > 0) {
                        for(Contract contrt : [Select id,ContractStatus__c from Contract where Id IN :contrtIdForStatusUpdate AND ContractStatus__c = 'Scheduled Termination']) {
                            System.debug('$$$$ insde---'+contrt);
                            contrt.ContractStatus__c = 'Validated';
                            contrt.ByPassValidationsForProcessBuilder__c = true;
                            contractUpdateLst.add(contrt);
                        }
                    }
                    if(contractUpdateLst != null && contractUpdateLst.size()>0) {                        
                        GlobalVariables.allowSalesGeneralToUpdateContractStatus = true;
                        update contractUpdateLst; 
                    } 
                    
                    if(lstOMCaseToBeCreated != null && lstOMCaseToBeCreated.size()>0) {                        
                        GlobalVariables.preventRecursiveTranstion = false; 
                        insert lstOMCaseToBeCreated;                      
                    }            
                }
            }
            catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'OpportunityMethods','createOMCaseOnRenewalOpportunityClosure'); 
            }
        }
    }
	
	//-----------------------------
    // @author: Anjani Shukla
    // @date: 21 June 2018
    // @param: TriggerParameters
    // @description: SFDC1-8147 : check for Product Restrictions on Opportunities.  
    // @return: None
    // 
    // @Last Modified By: Tran-Vu Tran
    // @Last Modified Date: 08th Jan 2019
    // @Last Modified Description: SFDC1-10880 Skip the check on Product Restrictions when moving Opportunity stage from 6W to 6WP 
    // 							(this is the logic when contract is already in flight, from requirement in SFDC1-5326 which was missing in the implementation for that story)
    //------------------------------
    public static void updateOpportunityProductRestriction(TriggerParameters tp) {
    	// Map of old values and new values
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;  
        
        // Opportunity Ids.
        Set<Id> accountIdsLstToUpdate = new Set<Id>();
        Map<Id,Account> accountMaptoUpdate;
        
        Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
		Id renewOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        // Id ForecastPlaceOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Forecasting Placeholder').getRecordTypeId();
        
        //Check if opportunity has bad product 
        List<String> prodErrOptyLst = new List<String>();
        // Checking for the Before Update and if Opportunity Stage - Need To Confirmed.
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {  
        	if (!mapNewOpportunity.isEmpty() && !mapOldOpportunity.isEmpty()) {
                //verify if opportunity is updated.
                for (Opportunity newOpp: mapNewOpportunity.values()) {

					// Validate New Business opportunity and when StageName is changed
                    if (newOpp.RecordTypeId == NewBusinessOppRecordTypeId &&
                        newOpp.StageName != mapOldOpportunity.get(newOpp.id).StageName &&
                        !newOpp.StageName.containsIgnoreCase('6WP') // SFDC1-10880 skip the check on Product Restrictions below if new Stage Name is 6WP
                       ) {
                           // Getting the list of Products for which Stage can not be Changed.
                           prodErrOptyLst = WarningMsgProductCrossPlantStatus.getOptyProdLineDetails(newOpp.id);
                           if (prodErrOptyLst != null && prodErrOptyLst.size() > 0) {
                               newOpp.addError('Stage can not be modified until '+ prodErrOptyLst + ' '+' product(s) is removed. Please remove Opportunity Product to proceed further.');
                           }
                       }

					// Validate Renewal opportunity and when StageName is changed
                    if (newOpp.RecordTypeId == renewOppRecordTypeId &&
                        newOpp.StageName != mapOldOpportunity.get(newOpp.id).StageName &&
                        !newOpp.StageName.containsIgnoreCase('6WP') // SFDC1-10880 skip the check on Product Restrictions below if new Stage Name is 6WP
                       ) {
                           // Getting the list of Products for which Stage can not be Changed.
                           prodErrOptyLst = WarningMsgProductCrossPlantStatus.getOptyProdLineDetails(newOpp.id);
                           if (prodErrOptyLst != null && prodErrOptyLst.size() > 0) {
                               newOpp.addError('Stage can not be modified until '+ prodErrOptyLst + ' '+' product(s) is removed. Please remove Opportunity Product to proceed further.');    
                           }
                       }
                    
                    // TODO: the 2 IF blocks above appear to have duplicated logic => see if they can be combined into 1 block
                }
            }           
        }
    }
    
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 23rd Jun 2018
    // @param: TriggerParameters
    // @description: SFDC1-8243 - Update Opportunity product shedules on change of close date 
    // and when contract start and contract end date are not populated
    // This method will be called in afterupdate trigger Events.
    // @return: None
    // @Last Modified By: Dev Aggarwal
    // @Last Modified Date: 10th Feb 2020
    // @Last Modified Description: SFDC-2623 - added code to update the Status on Opportunity product shedules.
    // @Last Modified By: Dev Aggarwal
    // @Last Modified Date: 14th Feb 2020
    // @Last Modified Description: SFDC-2669 - removed code to update Opportunity Product schedules as they will be cascaded down from Oppy Product.
    //------------------------------
    public static void updateFiscalOnChangeOfCloseDate(TriggerParameters tp) {
        if(!GlobalConstants.hasUpdatedProductSchedules) {
            GlobalConstants.hasUpdatedProductSchedules=true;
            try {
                //fetch the opportunities where closed date is changed
                Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
                Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap; 
                List<OpportunityLineItemSchedule__c> lstOLISToBeChanged = new List<OpportunityLineItemSchedule__c>();
                Integer fiscalStartMonth = UtilityClass.FiscalStartMonth;
                List<opportunityLineItemSchedule__c> lstOppyProdScheduleToUpdate = new List<opportunityLineItemSchedule__c>();
                Set<String> setPricingYear = new Set<String>();
                Set<Id> setProductIds = new Set<Id>();
                Map<Id,String> mapOppyFiscal = new Map<Id,String>();
                for(Opportunity oppy : mapNewOpportunity.values()) {
                    Opportunity oldOppy = mapOldOpportunity.get(oppy.Id);
                    if(oldOppy!=null && oldOppy.CloseDate!=oppy.CloseDate && oppy.contractStartDate__c==null) {
                        //calculate fiscal year of old closedate and new close date
                        //Integer oldOppyFiscal = UtilityClass.calculateFYFromDate(oldOppy.closeDate, fiscalStartMonth);
                        //if(oldOppyFiscal!=newOppyFiscal) {
                        Integer newOppyFiscal = UtilityClass.calculateFYFromDate(oppy.closeDate, fiscalStartMonth);
                        mapOppyFiscal.put(oppy.Id,String.valueOf(newOppyFiscal));
                        //}
                    }
                    
                }
                System.debug('@PD--mapOppyFiscal--'+ mapOppyFiscal);
                if(mapOppyFiscal!=null && !mapOppyFiscal.IsEmpty()) {
                    //query related opportunity product schedule records to update
                    Map<String,ProductSchedule__c> mapMultiKeyProductSchedule = new Map<String,ProductSchedule__c>();
                    lstOLISToBeChanged = [Select id, DiscountPercent__c,DiscountAmount__c,DiscountType__c,ExternalListPrice__c,
                                                 InstallmentYears__c, OpportunityProductID__c,PriceBookListPrice__c, ProductSchedule__r.Product__c,ProductSchedule__c,
                                                 ProductSchedule__r.ProductTerm__c, ProductSchedule__r.Year__c,
                                                 SalesPrice__c, TotalPrice__c, Quantity__c,AnnualizedDiscountAmount__c, AnnualizedUnitPrice__c, 
                                                 AnnualizedTotalAmount__c, ProRatedDiscountAmount__c, ProRatedUnitPrice__c,Opportunity__c
                                                 from OpportunityLineItemSchedule__c
                                                 where Opportunity__c IN: mapOppyFiscal.keyset()
                                                 order by InstallmentYears__c ASC];
                    System.debug('@PD--lstOLISToBeChanged--'+lstOLISToBeChanged);
                    List<ProductSchedule__c> lstProdSchedules = [Select id,Product__c,InstallmentYear__c,PricingYear__c,Year__c,ProductTerm__c,ListPrice__c 
                                                                    from ProductSchedule__c  
                                                                    where isactive__c = true AND PricingYear__c IN:mapOppyFiscal.values() 
                                                                    AND Product__c IN (Select Product2ID from OpportunityLineItem where OpportunityID in:mapOppyFiscal.keyset() ) 
                                                                    order by InstallmentYear__c,ProductTerm__c ASC];
                    System.debug('@PD--lstProdSchedules--'+lstProdSchedules);
                    
                    
                    if(lstProdSchedules!=null && !lstProdSchedules.isEmpty()) {
                        for(ProductSchedule__c ps : lstProdSchedules) {
                            String PSKey = String.valueOf(ps.Product__c) + ps.PricingYear__c + ps.Year__c + ps.ProductTerm__c ;
                            mapMultiKeyProductSchedule.put(PSKey,ps);
                        }
                        System.debug('@PD--mapMultiKeyProductSchedule--'+mapMultiKeyProductSchedule);
                        for(OpportunityLineItemSchedule__c olis : lstOLISToBeChanged) {
                            String OlisPSKey = String.valueOf(olis.ProductSchedule__r.Product__c) + mapOppyFiscal.get(olis.Opportunity__c) + olis.ProductSchedule__r.Year__c + olis.ProductSchedule__r.ProductTerm__c;
                            System.debug('--@PD OlisPSKey--'+OlisPSKey );
                             if(mapMultiKeyProductSchedule!=null && mapMultiKeyProductSchedule.containsKey(OlisPSKey)) {
                             
                                ProductSchedule__c ps = mapMultiKeyProductSchedule.get(OlisPSKey);
                                olis.ProductSchedule__c = ps.Id;
                                olis.InstallmentYears__c = ps.InstallmentYear__c;
                                olis.PriceBookListPrice__c = ps.ListPrice__c; 
                                lstOppyProdScheduleToUpdate.add(olis);
                            }
                        }
                        System.debug('@PD--lstOppyProdScheduleToUpdate--'+lstOppyProdScheduleToUpdate);
                        update lstOppyProdScheduleToUpdate;
                    
                    }                             
                 
                }
            }
            catch(Exception ex) {
               UtilityClass.createApexLogRecord(ex,'OpportunityMethods','updateFiscalOnChangeOfCloseDate');  
            }            
        }

    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 21st July 2018
    // @param: TriggerParameters
    // @description: SFDC1-7059, SFDC1-7060 - Adding validations for auto renew and opening certain fields from editing
    // @updatedBy: Tran-Vu Tran
    // @updatedOn: 5th Dec 2018
    // @updateDescription: SFDC1-10649 add Contract Management profile to the Allowed list for updating Auto-Renewal Opportunity fields
    //                      (this will be combined with additional security on FLS to determine which field they can actually update)
    // @updatedBy: Tran-Vu Tran
    // @updatedOn: 14th Dec 2018
    // @updatedDescription: SFDC1-10757 add Order Management profile to the Allowed list for updating Auto-Renewal Opportunity fields
    //                      (this will be combined with additional security on FLS to determine which field they can actually update)
    // This method will be called in before update trigger Events.
    // @author: Paras Dhingra
    // @date: 17th dec 2019
    // @modified by: SFDC-2356 Adding exception for Sales coordinator for legalentity__c field
    // @return: None
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date: 23 Jul 2020
    // @Last Modified Description: SFDC-3072 Add User Support profile to exclusions wherever Sales Ops or Contract Management checks are already present
    //------------------------------
    public static void opportunityValidations(TriggerParameters tp) {
        //the validation is not fired directly from opportunity change
        if(GlobalConstants.hasTriggeredFromOpportunityProduct) {
            return;
        }
        if(GlobalConstants.hasBeenValidatedOnce) {
            return;
        }
        
        GlobalConstants.hasBeenValidatedOnce = true;
        //get logged in user profile name
        String profileName = UtilityClass.LoggedInUserProfileName;
        System.debug('@PD--Profilename--'+profileName);
        //get all the valid fields on this object
        Map <String, Schema.SobjectField > oppyFields = Opportunity.sObjectType.getDescribe().fields.getMap();
        //check if user is admin then do not process further
        if(profileName.containsIgnoreCase('System Admin') || profileName.containsIgnoreCase('Sales Ops') || profileName.containsIgnoreCase('User Support') || GlobalConstants.hasEnhancedSalesPermission || profileName.containsIgnoreCase('Data Governance')// SFDC1-10688: move Sales Ops to higher level so they're not restricted by this validation method
          ) {
            //no validation checks are required for system admins
            return;
        }
        //control reached here not admin
        //fetch custom opportunity validation custom settings
        List<OpportunityValidationFields__c> oppyValidationFields = OpportunityValidationFields__c.getAll().values();
        Set<String> setHasChangesAPIs = new Set<String>();
        Set<String> setDoesNotHaveChangesAPIs = new Set<String>();
        for(OpportunityValidationFields__c ovf : oppyValidationFields) {
            String apiname = ovf.APIName__c.toLowerCase();
            if(ovf.RuleName__c=='AutoRenewHasChanges') {
                setHasChangesAPIs.add(apiname);
            }
            if(ovf.RuleName__c=='AutoRenewDoesNotHaveChanges') {
                setDoesNotHaveChangesAPIs.add(apiname);
            }
        }
        //Adding fix exception for SFDC-2356
        if(profileName.containsIgnoreCase('Sales Coordinator')) {
            setHasChangesAPIs.add('legalentity__c');
        }
        //iterate the opportunity and validate each of them
        for(Opportunity oppy : (List<Opportunity>) tp.newList) {
            Boolean hasError = false;
            Boolean isAllowed = false;
            //fetch old opportunity
            Opportunity oldOppy = (Opportunity) tp.OldMap.get(oppy.Id);
            //check if the auto-renew is checked then proceed for further checks
            if(oppy.AutoRenewal__c==true) {
               //make further checks
               System.debug('@pd--profilename--'+profileName);
               if(profileName.containsIgnoreCase('General') || profileName.containsIgnoreCase('Sales Coordinator')
                  || profileName.containsIgnoreCase('Contract Management') // SFDC1-10649 add Contract Management profile to the Allowed list
                  || profileName.containsIgnoreCase('User Support')
                  || profileName.containsIgnoreCase('Data Governance')  //SFDC-3645 : Account merge access, currently getting error due to validation on Auto-Renewal Opty
                  || (profileName.containsIgnoreCase('Order Management') // SFDC1-10048,4228 When OM Case is Validated/Rejected, we need to allow OM team to move Oppty to 6WP/5-contracting and populate the SAP Processed Contract number
                      && (oppy.StageName == '6W-Renewal Won' || oppy.StageName == '6WP-Closed Won/Order Processed' || oppy.StageName == '5-Renewal Contracting'))
                 ) {
                   isAllowed=true;
               }
               if(!isAllowed) {
                   //not allowed to edit the opportunity
                   oppy.addError(System.Label.AutoRenewOppyAccessError);// TODO add label
                   //no further processing required on this oppy record
                   continue;
               }
               for(string fieldName : oppyFields.keySet()) {
                    Schema.DescribeFieldResult dfr = oppyFields.get(fieldName).getDescribe();
                    if(oldOppy.get(fieldName)!=oppy.get(fieldName) && !dfr.IsCalculated()) {
                    //locked field edited
                        if(oppy.DoesThisAutoRenewalHaveChanges__c && !setHasChangesAPIs.contains(fieldName)) {
                            //rule specific custom message can be added later on
                            System.debug('@PD--Error Field--'+fieldName);
                            hasError = true;
                            break;
                        }
                        if(!oppy.DoesThisAutoRenewalHaveChanges__c && !setDoesNotHaveChangesAPIs.contains(fieldName)) {
                            //rule specific custom message can be added later on
                            System.debug('@PD--Error Field2--'+fieldName);
                            hasError = true;
                            break;
                        }
                    }
                }
            }
            //check if if oppy has error
            if(hasError) {
                oppy.addError(System.Label.AutoRenewHasChangesOppyError); // todo add label    
            }
            
        }
    
    }
	
	//-----------------------------
    // @author: Anjani Shukla
    // @date: 23 July 2018
    // @param: TriggerParameters
    // @description: SFDC1-5864 - Cumulative Contract Value
    //                            Migrating Process builder "Cumulative Contract Value" &  
    //                            "Clear Total Cumulative Contract Value". 
	//
    // This method will be called in afterupdate trigger Events.
    // @return: None
    //------------------------------
    public static void updateCumulativeContract(TriggerParameters tp) {
        try {
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {  
            //fetch the opportunities where closed date is changed
            List<Opportunity> newOptyLst = (List<Opportunity>) tp.newList;
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap; 
            Set<Id> contractBeingRenewedLst = new Set<Id>();
            
            //The Cumulative Contract Value should update on the Contract when 
            //Auto Renewal = True and Stage = Completed.
                if(newOptyLst != null) {
                    for(Opportunity newOpty: newOptyLst) {
                        //Addition Renewal Contract Value from Originating Contract Cumulative Contract Value.
                        if(newOpty.AutoRenewal__c && !newOpty.DoesThisAutoRenewalHaveChanges__c &&
                           newOpty.StageName != mapOldOpportunity.get(newOpty.id).StageName &&
                           newOpty.StageName == '6W-Renewal Won' &&
                           newOpty.ContractBeingRenewed__c != null
                          ) {
                        	//update
                        	contractBeingRenewedLst.add(newOpty.ContractBeingRenewed__c);
                            
                        }
                        //Subtract Renewal Contract Value from Originating Contract Cumulative Contract Value.
                        else if(newOpty.AutoRenewal__c && !newOpty.DoesThisAutoRenewalHaveChanges__c &&
                           newOpty.StageName != mapOldOpportunity.get(newOpty.id).StageName &&
                           (newOpty.StageName == '3-Renewal Pending' || newOpty.StageName == '5-Renewal Contracting') &&
                           newOpty.ContractBeingRenewed__c != null
                          ) {
                        	//update
                        	contractBeingRenewedLst.add(newOpty.ContractBeingRenewed__c);
                            
                              
                        }
                    }    
                }
                
                
                //get Contract details
                Map<Id,Contract> contractRenewedMap = new Map<Id,Contract>();
                //get Details for Contract being Renewed
                if(contractBeingRenewedLst != null && !contractBeingRenewedLst.isEmpty() ) {
                	contractRenewedMap = new Map<Id,Contract>([select Id,AllAssociatedTotalOpportunityValue__c,
                                                               AutoRenewal__c,ContractStatus__c,
                                                               FirstYearContractValue__c,
                                                               Name,Opportunity__c,Status,
                                                               Opportunity__r.ContractBeingRenewed__c,
                                                               Opportunity__r.StageName,
                                                               Opportunity__r.DoesThisAutoRenewalHaveChanges__c,
                                                               Opportunity__r.Amount__c,TotalContractValue__c
                                                               from Contract 
                                                               where ID IN: contractBeingRenewedLst ]);	    
                }
                
                system.debug('contractRenewedMap==>'+contractRenewedMap);
                
                
                //List to update
                List<Contract> updateContractLst = new List<Contract>();
                
                if(newOptyLst != null) {
                    for(Opportunity opty: newOptyLst) {
                        //Addition - when renewal opporutnity is moved to 6W, then add opty amount to contract cumulative field 
                        if(contractBeingRenewedLst != null && !contractBeingRenewedLst.isEmpty() && opty.StageName == '6W-Renewal Won' && opty.ContractBeingRenewed__c!=null ) {
                            	Contract updateContract = new Contract(id=contractRenewedMap.get(opty.ContractBeingRenewed__c).id);   
                                updateContract.AllAssociatedTotalOpportunityValue__c = contractRenewedMap.get(opty.ContractBeingRenewed__c).AllAssociatedTotalOpportunityValue__c 
                                                                                       + opty.Amount__c; 
                                updateContractLst.add(updateContract);
                                system.debug('updateContract==>'+updateContract);
                            }
                            //Subtract - when renewal opporutnity is moved to renewal contracting or renewal pending from 6W, then subtract opty amount from //contract cumulative field
                            else if(contractBeingRenewedLst != null && !contractBeingRenewedLst.isEmpty() &&
                               mapOldOpportunity.get(opty.id).stagename == '6W-Renewal Won' &&
                               opty.StageName != mapOldOpportunity.get(opty.id).stagename && 
                               (opty.StageName == '3-Renewal Pending' || 
                                opty.StageName == '5-Renewal Contracting')
                              ) {
                                Contract updateContract = new Contract(id=contractRenewedMap.get(opty.ContractBeingRenewed__c).id);   
                                updateContract.AllAssociatedTotalOpportunityValue__c = contractRenewedMap.get(opty.ContractBeingRenewed__c).AllAssociatedTotalOpportunityValue__c 
                                                                                       - opty.Amount__c; 
                                updateContractLst.add(updateContract);
                                system.debug('updateContract==>'+updateContract);
                            }
                       }
                    } 
                
                    if(updateContractLst != null) {
                        //adding check to prevent exception from firing
                        GlobalVariables.shouldContractValidationBypass = true;
                        update updateContractLst;
                        GlobalVariables.shouldContractValidationBypass = false;    
                    }
                } 
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex,'OpportunityMethods','updateCumulativeContract');  
        }            
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 1st August 2018
    // @param: TriggerParameters
    // @description: SFDC1-9500 - When 'Revisit' checkbox is unchecked, the probability of opportunity should be rolled back to previous value
    // This method will be called in before update trigger Events.
    // @return: None
    //------------------------------
    public static void revisitOpportunityStageChanges(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Opportunity> lstOppToBeUpdated = new List<Opportunity>();
            for(Opportunity opp: mapNewOpportunity.values()) {
                if(opp.Revisit__c ==FALSE && opp.Revisit__c != mapOldOpportunity.get(opp.Id).Revisit__c) {
                    lstOppToBeUpdated.add(opp);
                }           
            }
            if(lstOppToBeUpdated!= NULL && lstOppToBeUpdated.size()>0) {
                //List<OpportunityStage> oppStage = [Select Id, ApiName, DefaultProbability, MasterLabel from OpportunityStage];
                Map<String, Decimal> mapStageProbability = new Map<String,Decimal>();
                for(OpportunityStage oppStage: [Select Id, ApiName, DefaultProbability, MasterLabel from OpportunityStage]) {
                    mapStageProbability.put(oppStage.MasterLabel, oppStage.DefaultProbability);
                }
                System.debug('mapStageProbability---'+mapStageProbability);
                for(Opportunity opp:lstOppToBeUpdated) {
                    opp.Probability = mapStageProbability.get(opp.StageName);               
                }
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex,'OpportunityMethods','updateCumulativeContract');  
        }
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 1st August 2018
    // @param: TriggerParameters
    // @description: SFDC1-9500 - When 'Revisit' checkbox is unchecked, the task corresponding to 'Revisit' should be marked as completed.
    // This method will be called in after update trigger Events.
    // @return: None
    //------------------------------
    public static void revisitOpportunityTaskChanges(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Opportunity> lstOppWhereRevisitUnchecked = new List<Opportunity>();
            for(Opportunity opp: mapNewOpportunity.values()) {
                if(opp.Revisit__c ==FALSE && opp.Revisit__c != mapOldOpportunity.get(opp.Id).Revisit__c) {
                    lstOppWhereRevisitUnchecked.add(opp);
                }           
            }
            if(lstOppWhereRevisitUnchecked!=null && lstOppWhereRevisitUnchecked.size()>0) {
                List<Task> lstTaskToBeUpdated = new List<Task>();
                lstTaskToBeUpdated = [Select Id, Status, TaskToRevisitOpportunity__c from Task where WhatId IN :lstOppWhereRevisitUnchecked And TaskToRevisitOpportunity__c = true];
                for(Task taskObj : lstTaskToBeUpdated) {
                    taskObj.Status = 'Completed';
                }
                if(lstTaskToBeUpdated!= NULL && lstTaskToBeUpdated.size()>0) {
                    update lstTaskToBeUpdated;
                }
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex,'OpportunityMethods','updateCumulativeContract');  
        }
    }
	//-----------------------------
    // @author: Jagadesh Kumar
    // @date: 31 Jul 2018
    // @param: TriggerParameters
    // @description: SFDC1-5228 - Populate Primary Contact Name on Opportunity 
    // @return: None
    //------------------------------
    public static void setContactRolePrimary(TriggerParameters tp) {
        System.debug('@HS setContactRolePrimary() Trigger Method Begins');
        Set<Id> opptyIds = new Set<Id>();
        for(Opportunity oppy : (List<Opportunity>) tp.newList) {
            if(oppy.IsClosed == false) {
                opptyIds.add(oppy.Id);
            }
        }
        if(opptyIds.size() > 0) {
            // retrieve all Opportunity Contact Role against the Opportunities
            Map<Id,OpportunityContactRole> mapOppCR = new Map<ID,OpportunityContactRole>([Select Id, IsPrimary, OpportunityId, Contact.Name from OpportunityContactRole where IsPrimary = true and OpportunityId in :opptyIds]);
            // if Opportunity Contact Role records found
            if(!mapOppCR.isEmpty()) {
                // loop through all Opportunity Contact Role records found
                for(OpportunityContactRole oppCR : mapOppCR.values()) {
                    Opportunity opp = (Opportunity)tp.newMap.get(oppCR.OpportunityId);
                    if(opp!= null && opp.PrimaryContact__c != oppCR.Contact.Name) {
                        opp.PrimaryContact__c = oppCR.Contact.Name;
                    }
                }
            }
        }
        System.debug('@HS setContactRolePrimary() Trigger Method Ends');
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9831- Opportunity process builder to code -Active Contract updates when a Renewal Oppty is 6W
    // @modified by: Paras Dhingra
    // @modified date: 24/09/2019
    // @modified description: SFDC-1931 Marking the status as replaced for Consulting as well auto renewal with changes
    // @return: None
    //------------------------------
    public static void activeContractUpdatesWhenRenewal6W(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Id> lstOppyId = new List<Id>();
            List<Contract> lstContract = new List<Contract>();
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Set<Id> setOrderFormConsultingRecordTypeIds = new Set<Id>{orderFormRecordTypeId,consultingRecordTypeId};
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
                Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if(opp.RecordTypeId == RenewalOppRecordTypeId 
                    && (opp.AutoRenewal__c == false || opp.DoesThisAutoRenewalHaveChanges__c)                 
                    && opp.StageName =='6W-Renewal Won' 
                    && opp.StageName != mapOldOpportunity.get(opp.Id).StageName
                    && opp.ContractBeingRenewed__c != NULL) {
                    lstOppyId.add(opp.Id);               
                    }                   
                }
                if(lstOppyId!=null && lstOppyId.size()>0) {
                    //query related oppies and related orderform/consulting
                    
                    //UpdateActiveContractOnRenewalOpp6W.updateOriginatingContract(lstId);//TODO remove this class
                    For(Opportunity opp : [Select Id, ContractBeingRenewed__c,ContractBeingRenewed__r.ReplacementContract__c, (Select Id from Contracts__r where RecordTypeId IN:setOrderFormConsultingRecordTypeIds and Status='ReadyForProcessing' limit 1) 
                                           From Opportunity 
                                           where Id In:lstOppyId ]) {
                                               
                                               if(!opp.Contracts__r.isEmpty()) {
                                                   if(opp.ContractBeingRenewed__r.ReplacementContract__c==null) {
                                                       lstContract.add(new Contract(Id = opp.ContractBeingRenewed__c,ReplacementContract__c = opp.Contracts__r[0].Id, ContractStatus__c = 'Replaced'));               
                                                   }
                                                   
                                               }     
                                           }
                } 
                if(lstContract!=null && lstContract.size()>0) {
                    GlobalVariables.shouldContractValidationBypass = true;//adding flag to prevent validation from firing from oppy
                    update lstContract;
                    GlobalVariables.shouldContractValidationBypass = false;
                    // Check if update was successful --> replacement contract linked with Originating contract
            
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','activeContractUpdatesWhenRenewal6W');        
        }           
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9841, 9844, 9845 - Opportunity process builder to code -Update multi year, currency and legal entity from oppty to contract
    // @return: None
    // @updatedBy: Jagadesh Kumar
    // @updatedOn: 03rd Jan 2019
    // @updateDescription: SFDC1-10736: Cascade 'Auto renew stopped' field from Opportunity to Contract
    // 					
    //------------------------------
    public static void updateContractCurrencyWhenOppCurrencyChanges(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Id> lstId = new List<Id>();
            List<Contract> lstContract = new List<Contract>();
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
                Id orderForm = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if((opp.CurrencyISOCode != mapOldOpportunity.get(opp.Id).CurrencyISOCode) || (opp.LegalEntity__c != mapOldOpportunity.get(opp.Id).LegalEntity__c) || (opp.MultiYear__c != mapOldOpportunity.get(opp.Id).MultiYear__c && opp.MultiYear__c == TRUE) || (opp.AutoRenewStopped__c != mapOldOpportunity.get(opp.Id).AutoRenewStopped__c)) {
                        lstId.add(opp.Id);              
                    }                   
                }
                if(lstId!=null && lstId.size()>0) {
                    lstContract = [Select Id, CurrencyISOCode,IHSMarkitLegalEntity__c,Opportunity__r.LegalEntity__c,Opportunity__c,RecordTypeId,Opportunity__r.CurrencyISOCode,MultiyearOrderForm__c,Opportunity__r.MultiYear__c,AutoRenewStopped__c,Opportunity__r.AutoRenewStopped__c  from Contract where Opportunity__c IN: lstId];
                    if(lstContract!=null && lstContract.size()>0) {
                        for(Contract con:lstContract) {
                            if(con.CurrencyISOCode != con.Opportunity__r.CurrencyISOCode)
                                con.CurrencyISOCode = con.Opportunity__r.CurrencyISOCode;
                            if((con.MultiyearOrderForm__c != con.Opportunity__r.MultiYear__c) && con.RecordTypeId == orderForm)
                                con.MultiyearOrderForm__c = con.Opportunity__r.MultiYear__c;
                            if(con.IHSMarkitLegalEntity__c != con.Opportunity__r.LegalEntity__c)
                                con.IHSMarkitLegalEntity__c = con.Opportunity__r.LegalEntity__c;
                            if(con.AutoRenewStopped__c != con.Opportunity__r.AutoRenewStopped__c && (con.RecordTypeId == orderForm || con.RecordTypeId == consultingRecordTypeId)) {
                            	con.AutoRenewStopped__c = con.Opportunity__r.AutoRenewStopped__c; 
                            }
                        }
                        GlobalVariables.shouldContractValidationBypass = true;//adding flag to prevent validation from firing from oppy
                        update lstContract;
                        GlobalVariables.shouldContractValidationBypass = false;
                    }                   
                }               
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','updateContractCurrencyWhenOppCurrencyChanges');        
        }           
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 06 May 2019
    // @param: TriggerParameters
    // @description: SFDC-177 update originating contract's Continuation End Date value (from Renewal Opportunity) when it's empty or has a prior date
    // 					This method will be called in afterInsert and afterUpdate trigger Events.
    // @return: None
    //------------------------------
    public static void updateOriginatingContractContinuationEndDate(TriggerParameters tp) {
        // get all the originating contract IDs
        Set<Id> contractIDs = new Set<Id>();
        for (Opportunity opp : (List<Opportunity>)tp.newList) {
            contractIDs.add(opp.ContractBeingRenewed__c);
        }
        
        // retrieve data for the originating contracts
        Map<Id, Contract> opptyOriginatingContracts = new Map<Id, Contract>(
            [Select Id, ContinuationEndDate__c from Contract where Id in : contractIDs]
        );
        
        List<Contract> contractsToUpdate = new List<Contract>();
        try {
            if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert || tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                for (Opportunity newOpp: (List<Opportunity>)tp.newList) {
                    Opportunity oldOpp = (tp.oldMap != null) ? (Opportunity)tp.oldMap.get(newOpp.Id) : null;
                    //System.debug('oldOpp: ' + oldOpp);
			        //System.debug('newOpp.ContinuationEndDate__c: ' + newOpp.ContinuationEndDate__c);
                    
                    Contract origContract = opptyOriginatingContracts.get(newOpp.ContractBeingRenewed__c);
                    if (oldOpp == null // after insert new opportunity
                        || (oldOpp != null && oldOpp.ContinuationEndDate__c != newOpp.ContinuationEndDate__c // after update existing opportunity
                            && origContract != null // if there is an originating contract linked to it
                            && (origContract.ContinuationEndDate__c == null // and the contract's Continuation End Date value is empty
                                || origContract.ContinuationEndDate__c < newOpp.ContinuationEndDate__c)) // or prior to the opportunity's Continuation End Date
                       ){
                           Contract contract = new Contract(Id = newOpp.ContractBeingRenewed__c, ContinuationEndDate__c = newOpp.ContinuationEndDate__c);
                           System.debug('adding contract to update list: ' + contract);
                           contractsToUpdate.add(contract);
                       }
                }
            }
            
            if (!contractsToUpdate.isEmpty() && contractsToUpdate.size() > 0) {
                System.debug('updating contracts: ' + contractsToUpdate);
                GlobalVariables.shouldContractValidationBypass = true;//adding flag to prevent validation from firing from oppy
                Database.update(contractsToUpdate, false); // update the Contract records, set All-or-None to false to allow the updates to succeed if anyone of them fails
                GlobalVariables.shouldContractValidationBypass = false;
            }
        }
        catch(Exception e) {
            System.debug('Exception in OpportunityMethods.updateOriginatingContractContinuationEndDate');
            UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updateOriginatingContractContinuationEndDate');
        }
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 23 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-Opportunity process builder to code
    // @return: None
    // @Last Modified By : Jagadesh Kumar
	// @Last Modified Date : 12 Oct 2018
	// @Last Modified Description : SFDC1-10171 : When Opportunity move 6L allow sales general and sales coordinator to move the originating contract to scheduled termination. 
	// ----------------------------
    public static void updateStatusOfContractBeingRenewed(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Id> lstId = new List<Id>();
            List<Contract> lstContract = new List<Contract>();
            Map<Id,Contract> renewalLostContractMap = new Map<Id,Contract>();
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
                Id renewalOppRecType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if((opp.RecordTypeId == renewalOppRecType) && opp.StageName != mapOldOpportunity.get(opp.Id).StageName && opp.StageName == '6L-Renewal Lost' && opp.ContractBeingRenewed__c != Null) {
                        // Set ByPassValidationsForProcessBuilder__c = true to bypass the 'ContractStatusOnlySignedByCustomerForSG' validation rule so that when Opportunity move to 6L 
                        // Sales general and Sales coordinator profile users can move contract status to Scheduled Termination.
                        Contract c = new Contract (id = opp.ContractBeingRenewed__c, ContractStatus__c = 'Scheduled Termination',ByPassValidationsForProcessBuilder__c = true);   
                        lstContract.add(c); 
                        renewalLostContractMap.put(opp.ContractBeingRenewed__c, new Contract (id = opp.ContractBeingRenewed__c, ByPassValidationsForProcessBuilder__c = false));
                    }                   
                }
                if(lstContract!=NULL && lstContract.size()>0) {
                    GlobalVariables.shouldContractValidationBypass = true;//adding flag to prevent validation from firing from oppy  
                    update lstContract;
                    // Turn off the ByPassValidationsForProcessBuilder__c = false once contract status moved to Scheduled Termination.
                    
                    update renewalLostContractMap.values();
                    GlobalVariables.shouldContractValidationBypass = false;
                }
            }
        } catch(DMLException e) {
            if(e.getMessage().contains(System.Label.CaseContactAndAccountMatchMSG)) {
                ((List<Opportunity>) tp.newList).get(0).addError(System.Label.CaseContactAndAccountMatchMSG);
            } else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));  
            } else {
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage());
            }
        } catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','updateStatusOfContractBeingRenewed');        
        }           
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 27 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9838 Opportunity process builder to code for 'PopulateContractWhenOpportunityIsLost'
    // @return: None
    // @Last Modified By : Jagadesh Kumar
	// @Last Modified Date : 26 Oct 2018
	// @Last Modified Description : SFDC1-10245 : When Opportunity move 6L allow sales general and sales coordinator to move the contract to Canceled when status is Open. 
    //------------------------------
    public static void populateContractWhenOpportunityIsLost(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Id> lstId = new List<Id>();
            Id orderFormRecType = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            List<Contract> lstContract = new List<Contract>();
            Map<Id,Contract> newOpptyLostContractMap = new Map<Id,Contract>();
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if(opp.StageName != mapOldOpportunity.get(opp.Id).StageName && ( opp.StageName == '6L-Renewal Lost' || opp.StageName == '6L-Closed Lost' || opp.StageName == '6L-Forecasting Placeholder')) {
                        //Contract c = new Contract (id = opp.ContractBeingRenewed__c, ContractStatus__c = 'Scheduled Termination');   
                        lstId.add(opp.Id);                     
                    }                   
                }
                if(lstId!=NULL && lstId.size()>0) {
                    lstContract = [Select Id, ContractStatus__c, RecordTypeId, Opportunity__c, ByPassValidationsForProcessBuilder__c from Contract where Opportunity__c IN : lstId AND ContractStatus__c = 'Open' AND RecordTypeId=:orderFormRecType];
                    if(lstContract!=NULL && lstContract.size()>0) {
                        // Set ByPassValidationsForProcessBuilder__c = true to bypass the 'ContractStatusOnlySignedByCustomerForSG' validation rule so that when Opportunity move to 6L 
                        // Sales general and Sales coordinator profile users can move contract status to Canceled.
                        for(Contract conObj:lstContract) {
                            conObj.ContractStatus__c = 'Created in Error';
                            conObj.ByPassValidationsForProcessBuilder__c = true;
                            newOpptyLostContractMap.put(conObj.Id, new Contract (id = conObj.Id, ByPassValidationsForProcessBuilder__c = false));
                        }
                        update lstContract;
                        // Turn off the ByPassValidationsForProcessBuilder__c = false once contract status moved to Canceled.
                    	update newOpptyLostContractMap.values();
                    }
                }
            }
        } catch(DMLException e) {
            if(e.getMessage().contains(System.Label.CaseContactAndAccountMatchMSG)) {
                ((List<Opportunity>) tp.newList).get(0).addError(System.Label.CaseContactAndAccountMatchMSG);
            } else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));  
            } else {
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage());
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','populateContractWhenOpportunityIsLost');        
        }           
    }
    
    //-----------------------------
    // @author: Akhila Kodipaka
    // @date: 25 Mar 2021
    // @param: TriggerParameters
    // @description: SFDC-3539 Client legal details should cascade on changing Account lookup on Contract.
    //-----------------------------
    //--- part 1 - capturing opportunity account update
    
    public static void updateContractAccountWhenOpportunityAccountIsUpdated(TriggerParameters tp) {
        try{
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Id> oppyIdList = new List<Id>();
            List<Contract> contractListToUpdate = new List<Contract>();
            Set<id> setAccountId = new set<id>();
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if(opp.AccountId != mapOldOpportunity.get(opp.Id).AccountId) {
                        oppyIdList.add(opp.Id);     
                        setAccountId.add(opp.AccountId);
                    }                   
                }
            }
            if(oppyIdList!=NULL && oppyIdList.size()>0) {
                contractListToUpdate = [Select Id,ContractStatus__c, AccountId, Opportunity__c,Opportunity__r.AccountId, ByPassValidationsForProcessBuilder__c from Contract where Opportunity__c IN : oppyIdList and StatusCode !='Activated'];
                Map<Id,Account> mapAccValues = new Map<Id,Account>([Select Name,AccountCountry__c,BillingCity,BillingStreet,BillingCountry,BillingPostalCode,BillingState from Account where Id IN : setAccountId]);
                if(contractListToUpdate!=NULL && contractListToUpdate.size()>0) {
                    for(Contract conObj:contractListToUpdate) {
                        Account clientLegObj = mapAccValues.get(conObj.Opportunity__r.AccountId);
                        conObj.AccountId = conObj.Opportunity__r.AccountId;
                        conObj.ShipToCity__c = clientLegObj.BillingCity;
                        conObj.ShipToClientName__c  = clientLegObj.Name;   
                        conObj.ShipToCountryCodeLookup__c = clientLegObj.AccountCountry__c;   
                        conObj.ShipToPostalZipCode__c = clientLegObj.BillingPostalCode;   
                        conObj.ShipToStateProvince__c = clientLegObj.BillingState;   
                        conObj.ShipToStreet__c  = clientLegObj.BillingStreet;
                        
                        /* Commenting these fields as part of SFDC-4136
                        conObj.ShipToCompanySAP__c = '';
                        conObj.ShipToContactEmailAddress__c = '';
                        conObj.ShipToContactFirstName__c = '';
                        conObj.ShipToContactLastName__c = '';
                        conObj.ShipToContactSAP__c = '';
                        conObj.ShipToContactTelephoneNumber__c = '';
                        */
                        
                        conObj.BillToCity__c = clientLegObj.BillingCity;
                        conObj.BillToClientName__c  = clientLegObj.Name;   
                        conObj.BillToCountryCodeLookup__c = clientLegObj.AccountCountry__c;   
                        conObj.BillToPostalZipCode__c = clientLegObj.BillingPostalCode;   
                        conObj.BillToStateProvince__c = clientLegObj.BillingState;   
                        conObj.BillToStreet__c  = clientLegObj.BillingStreet; 
                        
                        /* Commenting these fields as part of SFDC-4136
                        conObj.BillToCompanySAP__c = '';
                        conObj.BillToContactEmailAddress__c ='';
                        conObj.BillToContactFirstName__c = '';
                        conObj.BillToContactLastName__c = '';
                        conObj.BillToContactSAP__c = '';
                        conObj.BillToContactTelephoneNumber__c = '';
                        */
                        
                        conObj.ClientLegalEntityLookUp__c = conObj.Opportunity__r.AccountId;
                        conObj.ClientLegalEntityStreet__c = clientLegObj.BillingStreet;
                        conObj.ClientLegalEntityCity__c = clientLegObj.BillingCity;
                        conObj.ClientLegalEntityStateProvince__c = clientLegObj.BillingState;
                        conObj.ClientLegalEntityZipPostalCode__c = clientLegObj.BillingPostalCode;
                        conObj.ClientLegalEntityCountryLookup__c = clientLegObj.AccountCountry__c;
                        
                        conObj.ClientNoticeAddressStreet__c = clientLegObj.BillingStreet;
                        conObj.ClientNoticeAddressCity__c = clientLegObj.BillingCity;
                        conObj.ClientNoticeAddressStateProvince__c = clientLegObj.BillingState;
                        conObj.ClientNoticeAddressZipPostalCode__c = clientLegObj.BillingPostalCode;
                        conObj.ClientNoticeAddressCountryLookup__c = clientLegObj.AccountCountry__c;   
                    }
                    update contractListToUpdate;
                }
            }
        }
        catch(DMLException e) {
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                System.debug('DMLException');
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));  
            } else {
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage());
            }
        }
    }
    
    //--- part 2 - capturing opportunity field updates
    public static void updateContractAddressFieldsWhenOpportunityAddressIsUpdated(TriggerParameters tp) {
        try{
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            List<Id> oppyIdList = new List<Id>();
            List<Contract> contractListToUpdate = new List<Contract>();
            Set<id> setOppId = new set<id>();
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if((opp.BillToCity__c != mapOldOpportunity.get(opp.Id).BillToCity__c || 
                        opp.BillToClientName__c != mapOldOpportunity.get(opp.Id).BillToClientName__c || 
                        opp.BillToCompanySAP__c != mapOldOpportunity.get(opp.Id).BillToCompanySAP__c||
                        opp.BillToContactEmailAddress__c != mapOldOpportunity.get(opp.Id).BillToContactEmailAddress__c||
                        opp.BillToContactFirstName__c != mapOldOpportunity.get(opp.Id).BillToContactFirstName__c ||
                        opp.BillToContactLastName__c != mapOldOpportunity.get(opp.Id).BillToContactLastName__c ||
                        opp.BillToContactSAP__c != mapOldOpportunity.get(opp.Id).BillToContactSAP__c||
                        opp.BillToContactTelephoneNumber__c != mapOldOpportunity.get(opp.Id).BillToContactTelephoneNumber__c||
                        opp.BillToCountryNew__c!= mapOldOpportunity.get(opp.Id).BillToCountryNew__c||
                        opp.BillToPostalZipCode__c != mapOldOpportunity.get(opp.Id).BillToPostalZipCode__c||
                        opp.BillToStateProvince__c!=mapOldOpportunity.get(opp.Id).BillToStateProvince__c||
                        opp.BillToStreet__c!=mapOldOpportunity.get(opp.Id).BillToStreet__c ||
                        opp.ShipToCity__c !=mapOldOpportunity.get(opp.Id).ShipToCity__c ||
                        opp.ShipToClientName__c !=mapOldOpportunity.get(opp.Id).ShipToClientName__c ||
                        opp.ShipToCompanySAP__c!=mapOldOpportunity.get(opp.Id).ShipToCompanySAP__c ||
                        opp.ShipToContactEmailAddress__c!=mapOldOpportunity.get(opp.Id).ShipToContactEmailAddress__c||
                        opp.ShipToContactFirstName__c!=mapOldOpportunity.get(opp.Id).ShipToContactFirstName__c||
                        opp.ShipToContactLastName__c!=mapOldOpportunity.get(opp.Id).ShipToContactLastName__c ||
                        opp.ShipToContactSAP__c!=mapOldOpportunity.get(opp.Id).ShipToContactSAP__c||
                        opp.ShipToContactTelephoneNumber__c!=mapOldOpportunity.get(opp.Id).ShipToContactTelephoneNumber__c||
                        opp.ShipToCountryNew__c !=mapOldOpportunity.get(opp.Id).ShipToCountryNew__c ||
                        opp.ShipToPostalZipCode__c!=mapOldOpportunity.get(opp.Id).ShipToPostalZipCode__c||
                        opp.ShipToStateProvince__c!=mapOldOpportunity.get(opp.Id).ShipToStateProvince__c ||
                        opp.ShipToStreet__c!=mapOldOpportunity.get(opp.Id).ShipToStreet__c)&& (opp.AccountId == mapOldOpportunity.get(opp.Id).AccountId)) {
                            setOppId.add(opp.Id);                          
                        }                     
                }
            }
            if(setOppId!=NULL && setOppId.size()>0) {
                contractListToUpdate = [Select Id,ContractStatus__c, AccountId, Opportunity__c,Opportunity__r.AccountId, ByPassValidationsForProcessBuilder__c from Contract where Opportunity__c IN : setOppId and StatusCode !='Activated'];
                Map<Id,Opportunity> mapOppValues = new Map<Id,Opportunity>([Select BillToCity__c,ShipToCountryNew__c,BillToCountryNew__c,BillToClientName__c,BillToCompanySAP__c,BillToContactEmailAddress__c,BillToContactFirstName__c,BillToContactLastName__c,BillToContactSAP__c,BillToContactTelephoneNumber__c,BillToPostalZipCode__c,BillToStateProvince__c,BillToStreet__c,ShipToCity__c,ShipToClientName__c,ShipToCompanySAP__c,ShipToContactEmailAddress__c,ShipToContactFirstName__c,ShipToContactLastName__c,ShipToContactSAP__c,ShipToContactTelephoneNumber__c,ShipToPostalZipCode__c,ShipToStateProvince__c,ShipToStreet__c from Opportunity where Id IN : setOppId]);
                if(contractListToUpdate!=NULL && contractListToUpdate.size()>0) {
                    for(Contract Contractobj:contractListToUpdate) {
                        Opportunity opp = mapOppValues.get(Contractobj.Opportunity__c);
                        if(opp.BillToCity__c!=mapOldOpportunity.get(opp.Id).BillToCity__c) {
                            Contractobj.BillToCity__c = opp.BillToCity__c;
                        }
                        if(opp.BillToClientName__c!=mapOldOpportunity.get(opp.Id).BillToClientName__c) {
                            Contractobj.BillToClientName__c  = opp.BillToClientName__c;
                        }
                        if(opp.BillToCompanySAP__c!=mapOldOpportunity.get(opp.Id).BillToCompanySAP__c) {
                            Contractobj.BillToCompanySAP__c = opp.BillToCompanySAP__c;     
                        }
                        if(opp.BillToContactEmailAddress__c != mapOldOpportunity.get(opp.Id).BillToContactEmailAddress__c) {
                            Contractobj.BillToContactEmailAddress__c = opp.BillToContactEmailAddress__c;  
                        }
                        if(opp.BillToContactFirstName__c != mapOldOpportunity.get(opp.Id).BillToContactFirstName__c) {
                            Contractobj.BillToContactFirstName__c = opp.BillToContactFirstName__c;
                        }
                        if(opp.BillToContactLastName__c != mapOldOpportunity.get(opp.Id).BillToContactLastName__c) {
                            Contractobj.BillToContactLastName__c  = opp.BillToContactLastName__c;
                        }
                        if(opp.BillToContactSAP__c != mapOldOpportunity.get(opp.Id).BillToContactSAP__c) {
                            Contractobj.BillToContactSAP__c = opp.BillToContactSAP__c;
                        }
                        if(opp.BillToContactTelephoneNumber__c != mapOldOpportunity.get(opp.Id).BillToContactTelephoneNumber__c) {
                            Contractobj.BillToContactTelephoneNumber__c  = opp.BillToContactTelephoneNumber__c;   
                        }
                        if(opp.BillToCountryNew__c!= mapOldOpportunity.get(opp.Id).BillToCountryNew__c) {
                            Contractobj.BillToCountryCodeLookup__c = UtilityClass.getCountry(opp.BillToCountryNew__c) == null ? (UtilityClass.getCountryByIsoCode(opp.BillToCountryNew__c) == null ? null : UtilityClass.getCountryByIsoCode(opp.BillToCountryNew__c).Id) : UtilityClass.getCountry(opp.BillToCountryNew__c).Id;       
                        }
                        if(opp.BillToPostalZipCode__c != mapOldOpportunity.get(opp.Id).BillToPostalZipCode__c) {
                            Contractobj.BillToPostalZipCode__c = opp.BillToPostalZipCode__c;   
                        }
                        if(opp.BillToStateProvince__c!=mapOldOpportunity.get(opp.Id).BillToStateProvince__c) {
                            Contractobj.BillToStateProvince__c = opp.BillToStateProvince__c;   
                        }
                        if(opp.BillToStreet__c!=mapOldOpportunity.get(opp.Id).BillToStreet__c) {
                            Contractobj.BillToStreet__c  = opp.BillToStreet__c;
                        }
                        
                        if(opp.ShipToCity__c !=mapOldOpportunity.get(opp.Id).ShipToCity__c) {
                            Contractobj.ShipToCity__c = opp.ShipToCity__c;
                        }
                        if(opp.ShipToClientName__c !=mapOldOpportunity.get(opp.Id).ShipToClientName__c) {
                            Contractobj.ShipToClientName__c  = opp.ShipToClientName__c;   
                        }
                        if(opp.ShipToCompanySAP__c!=mapOldOpportunity.get(opp.Id).ShipToCompanySAP__c) {
                            Contractobj.ShipToCompanySAP__c = opp.ShipToCompanySAP__c;   
                        }
                        if(opp.ShipToContactEmailAddress__c!=mapOldOpportunity.get(opp.Id).ShipToContactEmailAddress__c) {
                            Contractobj.ShipToContactEmailAddress__c = opp.ShipToContactEmailAddress__c;   
                        }
                        if(opp.ShipToContactFirstName__c!=mapOldOpportunity.get(opp.Id).ShipToContactFirstName__c) {
                            Contractobj.ShipToContactFirstName__c = opp.ShipToContactFirstName__c;   
                        }
                        if(opp.ShipToContactLastName__c!=mapOldOpportunity.get(opp.Id).ShipToContactLastName__c) {
                            Contractobj.ShipToContactLastName__c  = opp.ShipToContactLastName__c;
                        }
                        if(opp.ShipToContactSAP__c!=mapOldOpportunity.get(opp.Id).ShipToContactSAP__c) {
                            Contractobj.ShipToContactSAP__c = opp.ShipToContactSAP__c;
                        }
                        if(opp.ShipToContactTelephoneNumber__c!=mapOldOpportunity.get(opp.Id).ShipToContactTelephoneNumber__c) {
                            Contractobj.ShipToContactTelephoneNumber__c  = opp.ShipToContactTelephoneNumber__c;   
                        }
                        if(opp.ShipToCountryNew__c !=mapOldOpportunity.get(opp.Id).ShipToCountryNew__c) {
                            Contractobj.ShipToCountryCodeLookup__c = UtilityClass.getCountry(opp.ShipToCountryNew__c) == null ? (UtilityClass.getCountryByIsoCode(opp.ShipToCountryNew__c) == null ? null : UtilityClass.getCountryByIsoCode(opp.ShipToCountryNew__c).Id) : UtilityClass.getCountry(opp.ShipToCountryNew__c).Id;  
                        }
                        if(opp.ShipToPostalZipCode__c!=mapOldOpportunity.get(opp.Id).ShipToPostalZipCode__c) {
                            Contractobj.ShipToPostalZipCode__c = opp.ShipToPostalZipCode__c;
                        }
                        if(opp.ShipToStateProvince__c!=mapOldOpportunity.get(opp.Id).ShipToStateProvince__c) {   
                            Contractobj.ShipToStateProvince__c = opp.ShipToStateProvince__c;   
                        }
                        if(opp.ShipToStreet__c!=mapOldOpportunity.get(opp.Id).ShipToStreet__c) {
                            Contractobj.ShipToStreet__c  = opp.ShipToStreet__c;  
                        }
                    }
                    update contractListToUpdate;
                }
            }
        }
        catch(DMLException e) {
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                System.debug('DMLException');
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));  
            } else {
                ((List<Opportunity>) tp.newList).get(0).addError(e.getMessage());
            }
        }
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 28 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9840 Opportunity process builder to code, to sync oppty contract start and end date with contract dates
    // @return: None
    // @Modified By: Jagadesh Kumar
    // @Modified date: 11th Jan 2019
    // @description: SFDC1-10826:Contract Start and End Date need to stay in synch on Opportunity and Contract for stage '6W-Closed Won','6W-Renewal Won'
    // 
    // @Modified By: Tran-Vu Tran
    // @Modified Date: 25th Feb 2019
    // @description: SFDC-888: only cascade changes on Contract Start and End Date from the Opportunity to Order Form and Consulting Contract record types.
    // 			If user is Sales General, don't include completed contracts (because they should not be allow to update those records).
    //
    // @Modified By: Tran-Vu Tran
    // @Modified Date: 18th March 2019
    // @description: SFDC-918 & SFDC-1144 add new Sales Stage values for "New Business" Opportunity
    // @modifiedBy: Paras Dhingra
    // @modifiedDate: 03 Jul  2019
    // @modifiedDescription: SFDC-1621 fixing the bug which was not letting contract start date from syncing into contract
    // @modifiedBy: Paras Dhingra
    // @modifiedDate: 7th Sep 2020
    // @modifiedDescription: SFDC-3278 adding renewal date code to prevent validation rule from breaking the sync code
    // @modifiedBy: Madhusudhan karna
    // @modifiedDate: 2nd Dec 2020
    // @modifiedDescription: SFDC-3488 CSD, CED on CLI should also be updated along with Contract Dates 
    //------------------------------
    public static void syncOpportunityDatesWithContractDates(TriggerParameters tp) {
        try {
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            Map<Id,Opportunity> mapIdOppty = new Map<Id,Opportunity>();
            Set<String> setOpptyStageName = new Set<String>{
                '1-Sales Qualified', '1-Open', '2-Need Confirmed',
                '3-Proposal Development and Delivery', '3-Renewal Pending', '3-Proposal Development',
                '4-Proposal Accepted and Verbal Commit', '4.1-Proposal/Quote Delivery', '4.2-Verbal Commit',
                '5-Contracting', '5-Renewal Contracting', '6W-Closed Won', '6W-Renewal Won', '6WP-Closed Won/Order Processed'
                };
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if(setOpptyStageName.contains(opp.StageName) 
                    && (opp.ContractStartDate__c != mapOldOpportunity.get(opp.Id).ContractStartDate__c 
                     || opp.ContractEndDate__c != mapOldOpportunity.get(opp.Id).ContractEndDate__c )) {   
                        mapIdOppty.put(opp.Id,opp);                     
                    }                   
                }
                
                if(mapIdOppty!=NULL && mapIdOppty.size()>0) {
                // SFDC-3488 CLI object CSD, CED fields are added as inner query to sync with CLI record, when opportunity CSD and CED updated 
                    List<Contract> listContract = [Select Id, Status, StartDate, EndDate, Opportunity__c,(Select StartDate__c, EndDate__c from Contract_Line_Items__r
), RecordTypeId,EffectiveDate__c,RenewalDate__c,
                    RenewalTerm__c from Contract where Opportunity__c IN : mapIdOppty.keyset()];
                    
                    string profileName = UtilityClass.LoggedInUserProfileName;
                    boolean skipCompletedContract = profileName.containsIgnoreCase('General');
                    
                    if(listContract != NULL && listContract.size()>0) {
                        List<Contract> contractToUpdate = new List<Contract>();
                        List<ContractLineItem__c> contractLineItemToUpdate=new list<ContractLineItem__c>();
                        for (Contract conObj: listContract) {
                            if (skipCompletedContract && conObj.Status == 'Complete') {
                                continue; // SFDC-888: skip Completed contracts for Sales General profile
                            }
                            
                            // SFDC-888: only cascade changes on Contract Start and End Date to Order Form and Consulting Contract record types
                            if (conObj.RecordTypeId == ContractMethods.orderFormRecordTypeId
                                || conObj.RecordTypeId == ContractMethods.consultingRecordTypeId ) {
                                   conObj.EndDate = mapIdOppty.get(conObj.Opportunity__c).ContractEndDate__c;
                                   conObj.StartDate = mapIdOppty.get(conObj.Opportunity__c).ContractStartDate__c;
                                   //effective date should always be before or equal for contract startdate fix for SFDC-1621
                                   if(conObj.EffectiveDate__c > conObj.StartDate) {
                                       conObj.EffectiveDate__c = conObj.StartDate;
                                   }
                                   if((conObj.RenewalDate__c==null || conObj.RenewalDate__c<=conObj.EndDate) && conObj.RenewalTerm__c!='One-time Expiring' ) {
                                       conObj.RenewalDate__c = (conObj.EndDate+1);
                                   }
                                   if(conObj.RenewalDate__c!=null && conObj.RenewalTerm__c=='One-time Expiring') {
                                        conObj.RenewalDate__c=null;
                                    }
                                   contractToUpdate.add(conObj);
                                    // SFDC-3488 adding CLI records to list, if related opportunity CSD and CED are updated 
                                   for(ContractLineItem__c lineItem : conObj.Contract_Line_Items__r){
                                       lineItem.StartDate__c = mapIdOppty.get(conObj.Opportunity__c).ContractStartDate__c;
                                       lineItem.EndDate__c = mapIdOppty.get(conObj.Opportunity__c).ContractEndDate__c;
                                       contractLineItemToUpdate.add(lineItem);
                                   }
                               }
                        }
                        if (!contractToUpdate.isEmpty()) {
                            GlobalConstants.byPassContractValidationDates = true;
                            update contractToUpdate;
                            if(!contractLineItemToUpdate.isEmpty()){
                                update  contractLineItemToUpdate;
                            }
                            GlobalConstants.byPassContractValidationDates = false;
                        }
                        
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---' + e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','populateContractWhenOpportunityIsLost');        
        }           
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 30 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9843 : Process Builder [UpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus] to Code Change, SFDC1-6708:the status field on the Opportunity at Risk record to be set to "Closed - Mitigated" when a New Business opportunity is set to 6W. When a New Business Opportunity is set to 6L, then the status field on the OPP record should be set to "Closed - Terminated". SFDC1-7667 When New Business is set to 6L and OaR record exists - set the Status
    // @return: None
    //------------------------------
    public static void UpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus (TriggerParameters tp) {
        try {
            Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            set<ID> setOppId = new set<ID>();
            List<RenewalatRisk__c> lstOppatRisk = new List<RenewalatRisk__c>();
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if(opp.StageName == '6W-Closed Won' && opp.RecordtypeId == NewBusinessOppRecordTypeId
                    && opp.StageName != mapOldOpportunity.get(opp.Id).StageName) {   
                        setOppId.add(opp.Id);                     
                    }                   
                }
                if(setOppId !=NULL && setOppId.size()>0) {
                    lstOppatRisk = [Select Id, Status__c from RenewalatRisk__c where OpportunityAtRisk__c IN : setOppId and Status__c != 'Closed - Risk Mitigated'];
                    if(lstOppatRisk !=NULL && lstOppatRisk.size()>0) {
                        for(RenewalatRisk__c atRiskObj:lstOppatRisk) {
                            atRiskObj.Status__c = 'Closed - Risk Mitigated';
                        }
                        update lstOppatRisk ;
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','UpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus');        
        }           
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 31 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9839 : Process Builder [Populate Total Contract Value On Renewal] to Code Change, SFDC1-5906, This to bring the data from previous years contract into Renewal Opportunity as well as update the Total contract value on current year.SFDC1-7233 : Removed the dependency of Opportunity's 'Total Contract Value' field.
    // @return: None
    // @last Modified by : Mohit Modi
    // @last modified description :30 Oct 2018 , SFDC1-10188 : Field 'Total Annual Contract Value' [TotalAnnualContractValue__c] added to Deletion list, So Commenting this Method.
    //------------------------------
    /*
    public static void PopulateTotalContractValueOnRenewal (TriggerParameters tp) {
        try {
            Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            map<Id,Id> mapOppIdcontractId = new map<Id,Id>();
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if(opp.RecordtypeId == RenewalOppRecordTypeId && opp.PreviousYearOpportunitylink__c != NULL && 
                     opp.AutoRenewal__c  && opp.ContractBeingRenewed__c != NULL && 
                     ( mapOldOpportunity == NULL || ( mapOldOpportunity != NULL && opp.ContractBeingRenewed__c != mapOldOpportunity.get(opp.Id).ContractBeingRenewed__c  ))) {   
                        mapOppIdcontractId.put(opp.Id,opp.ContractBeingRenewed__c);                     
                    }
                    if(opp.RecordtypeId == RenewalOppRecordTypeId && opp.PreviousYearOpportunitylink__c != NULL && 
                     opp.AutoRenewal__c  && opp.ContractBeingRenewed__c == NULL ) {   
                        opp.TotalAnnualContractValue__c = 0 ;                    
                    }                   
                }
            }
            
            if(mapOppIdcontractId !=NULL && mapOppIdcontractId.size()>0) {
                Map<id,Contract> mapcontract = new Map<id,Contract>([Select Id, FirstYearContractValue__c from Contract where id IN : mapOppIdcontractId.values()]);
                
                if(mapcontract !=NULL && mapcontract.size()>0) {
                    for(Opportunity opp : (List<Opportunity>) tp.newList) {
                        // checking if Contracts available for the Updated Opportuntiy
                        if(mapOppIdcontractId.containskey(opp.id) && mapcontract.containskey(mapOppIdcontractId.get(opp.id))) {
                            opp.TotalAnnualContractValue__c = mapcontract.get(mapOppIdcontractId.get(opp.id)).FirstYearContractValue__c;
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','PopulateTotalContractValueOnRenewal');        
        }           
    }
    */
    //-----------------------------
    // @author: Mohit Modi
    // @date: 31 Aug 2018
    // @param: TriggerParameters
    // @description: SFDC1-9837 : Process Builder [Opportunity Updates For Salesops] to Code Change, SFDC1-286;To know when certain fields on Opportunity were last updated and the last value for that update
    // @return: None
    //------------------------------
    public static void OpportunityUpdatesForSalesops (TriggerParameters tp) {
        try {
            
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
			
            Set<String> StageNamestoIgnore = new Set<String>(Label.StageNamestoIgnoreForOpportunityUpdatesForSalesops.Split(','));
            System.debug('StageNamestoIgnore----'+StageNamestoIgnore);
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    
                    // For Stage Change
                    if( mapOldOpportunity != NULL && opp.StageName != mapOldOpportunity.get(opp.Id).StageName  &&
                    StageNamestoIgnore.Contains(opp.StageName) == false ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Stage changed';
                    } 
                    
                    // For Product Change
                    if( mapOldOpportunity != NULL && opp.ProductCount__c != mapOldOpportunity.get(opp.Id).ProductCount__c ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Product changed';
                    }
                    
                    // For Amount Change
                    if( mapOldOpportunity != NULL && opp.Amount != mapOldOpportunity.get(opp.Id).Amount ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Value changed';
                    } 

                    // For Description Change
                    if( mapOldOpportunity != NULL && opp.Description != mapOldOpportunity.get(opp.Id).Description ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Description updated';
                    }

                    // For Campaign Change
                    if( mapOldOpportunity != NULL && opp.CampaignID != mapOldOpportunity.get(opp.Id).CampaignID ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Campaign added';
                    }

                    // For Attachment Change
                    if( mapOldOpportunity != NULL && opp.MISAttachmentAdded__c != mapOldOpportunity.get(opp.Id).MISAttachmentAdded__c ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Attachment added';
                    }

                    // For Close Date Change
                    if( mapOldOpportunity != NULL && opp.CloseDate != mapOldOpportunity.get(opp.Id).CloseDate  &&
                    StageNamestoIgnore.Contains(opp.StageName) == false ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Close Date';
                    }

                    // For Activity Change
                    if( mapOldOpportunity != NULL && opp.MISActivityAdded__c != mapOldOpportunity.get(opp.Id).MISActivityAdded__c  &&
                    StageNamestoIgnore.Contains(opp.StageName) == false ) { 
                        opp.DateLastUpdated__c = System.Today();
                        opp.LastUpdatedItem__c = 'Activity added';
                    }                   
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','OpportunityUpdatesForSalesops');        
        }           
    }
    
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Aug 2018
    // @param: TriggerParameters
    // @description: 
    // 				SFDC1-9835 Delete Previous Opp Owner from OppTeam and Opp Splits on event after update
    // 				SFDC1-9836 Update previous owner field with old opportunity owner on event before update
    // @return: None
    //------------------------------
    public static void deletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner(TriggerParameters tp) {
        isOpportunityOwnerChanged = true;
        System.debug('@HS deletePrevOppOwnerFromTeamAndOppSplits() BEGINS');
        Set<Id> oppChangedIdSet = new Set<Id>();
        for(Opportunity newOppy : (List<Opportunity>) tp.newList) {
            Opportunity oldOppy = (Opportunity) tp.oldMap.get(newOppy.Id);
            //Check if owner is changed on opportunity            
            if(oldOppy != null && oldOppy.OwnerId != newOppy.OwnerId) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                	oppChangedIdSet.add(newOppy.Id);    
                }
                if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                    newOppy.PreviousOpportunityOwner__c = oldOppy.OwnerId;
                }
            }
        }
        //Process opps on which owner is changed
        if(oppChangedIdSet.size() > 0) {
            //Map<Id,Opportunity> oppIdOppMap = new Map<Id,Opportunity>([SELECT Id,OwnerId,(SELECT UserId,TeamMemberRole FROM OpportunityTeamMembers) FROM Opportunity WHERE Id IN :oppChangedIdSet]);
            List<OpportunityTeamMember> OppTeamMemberListtobedeleted = new List<OpportunityTeamMember> ();
            List<OpportunityTeamMember> OppTeamMemberListToBeUpdated = new List<OpportunityTeamMember> ();
            List<Id> lstUsersToBeDeletedFromOppSplit = new List<Id>();
            List<OpportunityTeamMember> OppTeamMemberList = new list<OpportunityTeamMember>([SELECT UserId,Opportunity.OwnerId,OpportunityId FROM OpportunityTeamMember WHERE OpportunityId IN :oppChangedIdSet AND (TeamMemberRole ='Opportunity Owner') ]);        
            
            for(OpportunityTeamMember oppTeamMem:OppTeamMemberList) {                
                if(oppTeamMem.UserId != oppTeamMem.Opportunity.OwnerId) {
                    OppTeamMemberListtobedeleted.add(oppTeamMem);
                    lstUsersToBeDeletedFromOppSplit.add(oppTeamMem.UserId);
                }
            }
            try {
                //Delete Opp Splits for prev owner
                List<OpportunitySplit> oppSplitsToDelete = new List<OpportunitySplit>([SELECT id, opportunityId, splitOwnerId FROM OpportunitySplit WHERE OpportunityId IN :oppChangedIdSet AND splitOwnerId IN :lstUsersToBeDeletedFromOppSplit]);
                //System.debug('@HS oppSplitsToDelete.size()='+oppSplitsToDelete.size());
                //System.debug('@HS oppSplitsToDelete='+oppSplitsToDelete);
                if(oppSplitsToDelete.size() > 0) {
                	delete oppSplitsToDelete;    
                }                
                
                //System.debug('@HS OppTeamMemberListtobedeleted.size()='+OppTeamMemberListtobedeleted.size());
                //System.debug('@HS OppTeamMemberListtobedeleted='+OppTeamMemberListtobedeleted);
                //Delete prev owners from Opp Team Members list                
                if(OppTeamMemberListtobedeleted.size() > 0) {
                	//delete OppTeamMemberListtobedeleted; 
                	for(OpportunityTeamMember oppTeamMember: OppTeamMemberListtobedeleted) {
                        oppTeamMember.TeamMemberRole = label.OldOpportunityOwnerNewRole;
                        oppTeamMember.OpportunityAccessLevel = 'Edit';
                        OppTeamMemberListToBeUpdated.add(oppTeamMember);
                    }
                	update OppTeamMemberListToBeUpdated;  
                }
            	
                //Create new owner as Opp Team member
                List<OpportunityTeamMember> newTeamMemberList = new List<OpportunityTeamMember>();
                for(Id newOppId : oppChangedIdSet) {
                    Opportunity oppRecord = (Opportunity) tp.newMap.get(newOppId);
                    OpportunityTeamMember otm = new OpportunityTeamMember();
                    otm.UserId = oppRecord.OwnerId;
                    otm.TeamMemberRole ='Opportunity Owner';
                    otm.OpportunityId = oppRecord.Id;
                    newTeamMemberList.add(otm);
                }
                //System.debug('@HS newTeamMemberList.size()='+newTeamMemberList.size());
                //System.debug('@HS newTeamMemberList='+newTeamMemberList);
                if(newTeamMemberList.size() > 0) {
                	insert newTeamMemberList;    
                }                
            }
            catch(Exception ex) {
                String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
                System.debug('Exception in deletePrevOppOwnerFromTeamAndOppSplits() method. Description:'+description);
                throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
            }            
        }
        System.debug('@HS deletePrevOppOwnerFromTeamAndOppSplits() ENDS');
    }
	
	//-----------------------------
    // @author: Mohit Modi
    // @date: 3 Sept 2018
    // @param: TriggerParameters
    // @description: SFDC1-9833 : Process Builder [ClearChannelPartnerOpportunity] to Code Change,  SFDC1-5021-Clear ChannelPartner Field on Opportunity when Account Type is not Global Alliance. SFDC1-6280 - Clear Account Owner on Opportunity when it is a Global Alliance
    // @return: None
    //------------------------------
    public static void ClearChannelPartnerOpportunity (TriggerParameters tp) {
        try {
            
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
      
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate || tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    
                    if( opp.SubType__c == 'Direct Sale'  && 
                        ( mapOldOpportunity == NULL || ( mapOldOpportunity != NULL && opp.SubType__c != mapOldOpportunity.get(opp.Id).SubType__c))) { 
                        opp.ChannelPartner__c = NULL;
                    }
                    
                    if( opp.SubType__c == 'Global Alliance' && opp.ChannelPartner__c != NULL && 
                        ( mapOldOpportunity == NULL || ( mapOldOpportunity != NULL && opp.SubType__c != mapOldOpportunity.get(opp.Id).SubType__c))) { 
                        opp.GAM__c = NULL;
                    }                   
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','ClearChannelPartnerOpportunity');        
        }           
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 3 Sept 2018
    // @param: TriggerParameters
    // @description: SFDC1-9833 : Process Builder [ClearChannelPartnerOpportunity] to Code Change,SFDC1-6280 - Clear Account Owner on Opportunity when it is a Global Alliance
    // @return: None
    //------------------------------
    public static void ClearGAMTeamMemberOnChannelPartnerOpportunity (TriggerParameters tp) {
        try {
            
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            set<id> setOppId = new Set<id>();
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    
                    if( mapOldOpportunity != NULL && opp.SubType__c != mapOldOpportunity.get(opp.Id).SubType__c  &&
                    opp.SubType__c == 'Global Alliance' && opp.ChannelPartner__c != NULL ) { 
                        setOppId.add(opp.id);
                    }                   
                }
                
                if(setOppId != NULL && !setOppId.isEmpty()) {
                    List<OpportunityTeamMember> listExistingGAMOnOpportunity = [Select Id,TeamMemberRole,UserId,OpportunityId from OpportunityTeamMember where opportunityId IN: setOppId AND TeamMemberRole=: 'Account Owner' ];
                    
                    if(listExistingGAMOnOpportunity != NULL && !listExistingGAMOnOpportunity.isEmpty()) {
                        delete listExistingGAMOnOpportunity;
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','ClearGAMTeamMemberOnChannelPartnerOpportunity');        
        }           
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 19 oct 2018
    // @param: TriggerParameters
    // @description: SFDC1-10039 : When Account Changes on Opportunity, Opportunity atRisk's Account also should be changed.
    // @return: None
    //------------------------------
    public static void UpdateAtRiskAccountUponOpportunityAccountChange(TriggerParameters tp) {
        try {
            
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            map<id,id> mapOppIdAccId = new map<id,id>();
            list<RenewalatRisk__c> ListOppRisk = new List<RenewalatRisk__c>();
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {               
                for(Opportunity opp : (List<Opportunity>) tp.newList) {
                    if( mapOldOpportunity != NULL && opp.AccountId != mapOldOpportunity.get(opp.Id).AccountId ) { 
                        mapOppIdAccId.put(opp.id,opp.AccountId);
                    }                   
                }
                
                if(mapOppIdAccId != NULL && !mapOppIdAccId.isEmpty()) {
                    for (RenewalatRisk__c OppatRisk : [Select Id,Account__c,OpportunityAtRisk__c from RenewalatRisk__c where OpportunityAtRisk__c IN: mapOppIdAccId.keyset()]) {
                        if(OppatRisk.Account__c != NULL ) {
                            OppatRisk.Account__c = mapOppIdAccId.get(OppatRisk.OpportunityAtRisk__c);
                            ListOppRisk.add(OppatRisk);
                        }
                    }
                }
                
                if(ListOppRisk != NULL && !ListOppRisk.isEmpty()) {
                    update ListOppRisk;
                }
            }
        }
        catch(Exception e) {
            System.debug('exception ---'+e.getMessage()); 
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','UpdateAtRiskAccountUponOpportunityAccountChange');        
        }           
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 09 Nov 2018
    // @param: TriggerParameters
    // @description: SFDC1-10184 : When Renewal Opportunity is 6w, then check for Lost Opporturtunity products, 
    // 		if any of them belong to Markit loading group category then create implementation case one per 
    // 		Loading group. Got clear confirmation from BSA that SFDC1-9781 is a totally different requirement and 
    // 		they dont happen together. 
    // @return: None
    // 
    // @LastModifiedBy: Harshit Singhal
    // @LastModifiedDate: 02-May-2019
    // @LastModifiedDescription: SFDC-1024: Updated Type and Description on Implementation cases getting created due to lost products on Renewal Opportunity
    // 
    // @LastModifiedBy: Akshay Dogra
    // @LastModifiedDate: 04-Dec-2020
    // @LastModifiedDescription: SFDC-3092: Added Contract Start Date and End Date on Implementation cases getting created due to lost products on Renewal Opportunity
    // @Modified By : Neelam Agrawal
    // @date: 07 Jan 2022
    // @description: SFDC-5508: Added conditions to generate implementation cases for continuation and trial contract
    //------------------------------
    public static void createImplCaseForLostProductsOnRenewalOpp6W(TriggerParameters tp) {
        try {
            if(GlobalConstants.hasImplCaseForLostProductsOnRenewalOpp6WExecuted) {
                return;
            }
            GlobalConstants.hasImplCaseForLostProductsOnRenewalOpp6WExecuted = true;
            Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
            Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
            Map<Id, Case> lodingGrpCaseMap = new Map<Id, Case>();
            Set<Id> OpportunityIds = new Set<Id>();
            Map<string,id> caseQueue = new Map<string, id>();
            Map<Id,List<TriageCriteria__c>> mapLoadingGrpToTrc = new Map<Id, List<TriageCriteria__c>>();
            // Checking for the After Update
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.recordTypeId == RenewalOppRecordTypeId &&
                       newOpp.StageName != mapOldOpportunity.get(newOpp.id).StageName && 
                       newOpp.StageName == '6W-Renewal Won' ) {
                           OpportunityIds.add(newOpp.Id);
                       }
                }
                if(OpportunityIds.size() > 0) {
                    //SFDC-3388 Triage Record Mapping for Implementation Case assignment
                    for (TriageCriteria__c trc : caseMethodHelperForQueries.allTriageList) {
                        if (trc.loadinggroup__c != null && trc.queue__c != null && trc.ContractRecordType__c != null) {
                            if  (!mapLoadingGrpToTrc.containsKey(trc.loadinggroup__c)) {
                                mapLoadingGrpToTrc.put(trc.loadinggroup__c, new List<TriageCriteria__c>());
                            }
                            mapLoadingGrpToTrc.get(trc.loadinggroup__c).add(trc);
                        }    
                    }
                    for(Group g : [select Id,Name,DEVELOPERNAME from Group where Type = 'Queue' ]) {
                      caseQueue.put(g.Name,g.id);
                    }

                    Id caseImplemetationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
                    for(Opportunity opp : [Select Id, ContractBeingRenewed__c, ContractBeingRenewed__r.RecordTypeId, ContractBeingRenewed__r.recordType.Name, AccountId,  ContractStartDate__c, ContractEndDate__c, 
                                           (Select Product2.Name, Product2.LoadingGroup__c,Product2.ProductGroup__c From OpportunityLineItems 
                                            Where //Product2.LoadingGroup__r.LoadingGroupCategory__c = 'Markit' and 
                                            Status__c = 'Lost'), (Select ContactId from OpportunityContactRoles where IsPrimary = true)
                                           From Opportunity where Id in :OpportunityIds]) {
                                               if(opp.OpportunityLineItems.size() > 0 && opp.ContractBeingRenewed__r.RecordTypeId == orderFormRecordTypeId) {
                                                   Id contactId = null;
                                                   if(opp.OpportunityContactRoles.size() > 0) {
                                                       contactId = opp.OpportunityContactRoles.get(0).ContactId;
                                                   }
                                                   for(OpportunityLineItem oli : opp.OpportunityLineItems) {
                                                       Id loadingGrp = oli.Product2.LoadingGroup__c;
                                                       // SFDC-3388 Check if triage criteria record is present for this loading grp.
                                                       if (mapLoadingGrpToTrc.containsKey(loadingGrp)) {
                                                           List<TriageCriteria__c> trgList= mapLoadingGrpToTrc.get(loadingGrp);
                                                           for(TriageCriteria__c trc:trgList) {
                                                           if(trc.ContractRecordType__c.containsIgnoreCase(opp.ContractBeingRenewed__r.recordType.Name)) {
                                                           //Case created for each different product Markit loading group
                                                               if(!lodingGrpCaseMap.containskey(loadingGrp)) {
                                                                   Id queueId = caseQueue.containsKey(trc.Queue__c)? caseQueue.get(trc.Queue__c) : UtilityClass.FMOnboardingQueueId;
                                                                   Case cse = new Case(OwnerId = queueId,
                                                                                       Contract__c = opp.ContractBeingRenewed__c,
                                                                                       AccountId = opp.AccountId,
                                                                                       Opportunity__c = opp.Id,
                                                                                       ContractStartDate__c = opp.ContractStartDate__c,
                                                                                       ContractEndDate__c = opp.ContractEndDate__c,
                                                                                       ContactId = contactId,
                                                                                       Status = 'New',
                                                                                       Origin = 'Internal',
                                                                                       Priority = 'Medium',
                                                                                       Type = 'Lost Renewal Product',
                                                                                       LoadingGroupOnboarding__c = oli.Product2.LoadingGroup__c,
																					   //SFDC-4279: Auto populate Prodcut group
                                                                                       ProductGroup__c = oli.Product2.ProductGroup__c,
                                                                                       //DeliveryTeam__c = 'Markit',
                                                                                       Subject = 'Opportunity # - Lost Renewal Opportunity Product',
                                                                                       Description = 'Following products have been lost: \r\n'+ oli.Product2.Name,
                                                                                       RecordTypeId = caseImplemetationRecordTypeId);
                                                                   lodingGrpCaseMap.put(oli.Product2.LoadingGroup__c,cse);
                                                               } else {
                                                                   Case c = lodingGrpCaseMap.get(oli.Product2.LoadingGroup__c);
                                                                   c.Description = c.Description+ '\n' + oli.Product2.Name;
                                                                   if (c.ProductGroup__c != oli.Product2.ProductGroup__c){
																      c.ProductGroup__c = null;
																   }
                                                               }
                                                           }
                                                       }
                                                       }
                                                   }
                                               }                          
                                           }
                }
                System.debug('---------------------------------'+lodingGrpCaseMap);
                if(!lodingGrpCaseMap.isEmpty()) {
                    insert lodingGrpCaseMap.values();
                } 
            }
        } catch (Exception e) {
            UtilityClass.createApexLogRecord(e,'OpportunityMethods','createImplCaseForLostProductsOnRenewalOpp6W'); 
        }
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 06 May 2019
    // @param: TriggerParameters
    // @description: SFDC-1364 : Prevent account managers from gettting wiped from the account manager splits
    // @return: None
	// @modifiedBy: Paras Dhingra
	// @modifiedDate: 30th Apr 2020
	// @modifiedDescription: SFDC-2738 - Account owner role is blanking out on opportunity owner change
    //------------------------------
    public static void resetAccountManagerSplitOnOwnerChange(TriggerParameters tp) {

        Set<Id> setOpportunityOwnerChanged = new Set<Id>();
        List<Opportunity> lstExistingOpportunity = new List<Opportunity>();
        List<OpportunitySplit> lstDeleteAMOppySplit = new List<OpportunitySplit>();
        List<OpportunitySplit> lstInsertAMOppySplit = new List<OpportunitySplit>();
        List<OpportunityTeamMember> lstInsertAMOppyTeamMember = new List<OpportunityTeamMember>();
        Boolean accountManagerSplitFound = false;
        for(Opportunity newOppy : (List<Opportunity>)tp.newMap.values()) {
            Opportunity oldOppy = (Opportunity)tp.oldMap.get(newOppy.Id);
             if(oldOppy.OwnerId!=newOppy.OwnerId && newOppy.GAM__c!=null) {
                setOpportunityOwnerChanged.add(newOppy.Id);
             }
        }
        if(setOpportunityOwnerChanged!=null && !setOpportunityOwnerChanged.isEmpty()) {
             lstExistingOpportunity = [Select 
                                        Id, GAM__c, OwnerId, 
                                        (Select Id, SplitOwnerId, SplitTypeId, Split,SplitNote, SplitPercentage from OpportunitySplits
                                            where SplittypeId=:UtilityClass.OverlayId)
                                        from Opportunity where Id IN: setOpportunityOwnerChanged
                                        ];
        }
        System.debug('--lstExistingOpportunity--'+lstExistingOpportunity);
        //check if opportunity owner is changed or not. if changed then process underlying opportunitysplits with accountmanager splits
        if(lstExistingOpportunity!=null && !lstExistingOpportunity.isEmpty()) {
            for(Opportunity oppy: lstExistingOpportunity) {
                //if owner is changed then find existing accountmanage splits and add them to delete list
                if(oppy.OpportunitySplits!=null && !oppy.OpportunitySplits.isEmpty()) {
                    //delete the account manager splits and create new
                    for(OpportunitySplit oppySplit: oppy.OpportunitySplits) {
                        if(oppySplit.SplitOwnerId == oppy.GAM__c) {
                            //keep account team is checked don't change the splits
                            accountManagerSplitFound=true;
                            
                        }
                    }
                    if(!accountManagerSplitFound) {
                        //keep opportunity team is unchecked
                        lstInsertAMOppySplit.add(new OpportunitySplit(SplitPercentage=100,SplitTypeId = UtilityClass.overlayId,OpportunityId = oppy.Id, SplitOwnerId=oppy.GAM__c));
                        OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(oppy.Id,oppy.GAM__c,'Edit','Account Owner'); 
                        lstInsertAMOppyTeamMember.add(oppTeamMember);
                        lstDeleteAMOppySplit.add(oppy.OpportunitySplits);
                    }
                } else {
                    //add one account manager split and continue on to next opportunity
                    lstInsertAMOppySplit.add(new OpportunitySplit(SplitPercentage=100,SplitTypeId = UtilityClass.overlayId,OpportunityId = oppy.Id, SplitOwnerId=oppy.GAM__c));
                    OpportunityTeamMember oppTeamMember = createOpportunityTeamMember(oppy.Id,oppy.GAM__c,'Edit','Account Owner'); 
                    lstInsertAMOppyTeamMember.add(oppTeamMember);
                }
            }
            System.debug('--lstDeleteAMOppySplit--'+lstDeleteAMOppySplit);
            System.debug('--lstInsertAMOppySplit--'+lstInsertAMOppySplit);
            if(lstDeleteAMOppySplit!=null && !lstDeleteAMOppySplit.isEmpty()) {
                delete lstDeleteAMOppySplit;
            }
            if(lstInsertAMOppyTeamMember!=null && !lstInsertAMOppyTeamMember.isEmpty()) {
                insert lstInsertAMOppyTeamMember;
            }
            if(lstInsertAMOppySplit!=null && !lstInsertAMOppySplit.isEmpty()) {
                insert lstInsertAMOppySplit;
            }
        }
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 06 Sep 2019
    // @param: TriggerParameters
    // @description: SFDC-1973 : Opp validation to make EarliestTerminationPeriod__c and ContractSpecialOptions__c fields required if opp is auto-renewal without change
    //  and atleast one oppy product has ASC606RevRec__c=yes
    // @return: None
    //------------------------------
    public static void oppCheckASC606RevRecProductValidation(TriggerParameters tp) {
        Set<Id> oppIdSet = new Set<Id>();
        Id renewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Map<Id,Opportunity> newOppMap = (Map<Id,Opportunity>)tp.newMap;
        for(Opportunity opp : newOppMap.values()) {
			Opportunity oldOpp = (Opportunity) tp.oldMap.get(opp.Id);			
            //Opp conditions to apply ASC606RevRecProduct validation
            if(opp.RecordTypeId==renewalOppRecordTypeId && opp.AutoRenewal__c && !opp.DoesThisAutoRenewalHaveChanges__c && 
               opp.StageName=='6W-Renewal Won' && opp.StageName!=oldOpp.StageName && 
               (String.isBlank(opp.EarliestTerminationPeriod__c) || String.isBlank(opp.ContractSpecialOptions__c))) {
                   oppIdSet.add(opp.Id);    
            }
        }
        //System.debug('HS06Sep oppIdSet='+oppIdSet);
        if(oppIdSet.size() > 0) {
            //Map<Id,Boolean> oppIdFlagMap = checkIfOppyHasASC606RevRecProduct(oppIdSet);            
            Map<Id,Boolean> oppIdFlagMap = checkIfOppyHasASC606RevRecProduct(oppIdSet,'OppTrigger');            
            //System.debug('HS06Sep oppIdFlagMap='+oppIdFlagMap);
            for(Id oppId: oppIdFlagMap.keySet()) {
                if(oppIdFlagMap!=null && oppIdFlagMap.containsKey(oppId) && oppIdFlagMap.get(oppId)) {
                    Opportunity oppToError = newOppMap.get(oppId);
                    String errorMsg = oppToError.EarliestTerminationPeriod__c==null && oppToError.ContractSpecialOptions__c==null ? 'Please populate Earliest Termination Period and Contract Special Options.': (oppToError.EarliestTerminationPeriod__c==null ? 'Please populate Earliest Termination Period.':'Please populate Contract Special Options.');
                    oppToError.addError(errorMsg);
                }                    
            }
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 06 Sep 2019
    // @param: Set of Opportunity Ids
    // @description: SFDC-1973 : Method to find if any of the opportunity product has ASC606RevRec__c='Yes'. Helper method for OpportunityMethods.checkIfOLIHasASC606RevRec().
    // @return: Map<Id,Boolean> - Map of opp Id as key and a boolean flag as value
    //------------------------------
    public static Map<Id,Boolean> checkIfOppyHasASC606RevRecProduct(Set<Id> oppIdSet, String sourceMethod) {
    //public static Map<Id,Boolean> checkIfOppyHasASC606RevRecProduct(Set<Id> oppIdSet) {
        Map<Id,Boolean> oppIdFlagMap = new Map<Id,Boolean>();
        if(oppIdSet!=null && oppIdSet.size()>0) {
            //List<Opportunity> oppList = [SELECT Id,(SELECT Id,Product2Id,Product2.Name,Product2.ASC606RevRec__c FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :oppIdSet];
            List<Opportunity> oppList = [SELECT Id,(SELECT Id,Product2Id,Product2.Name,Product2.ASC606RevRec__c FROM OpportunityLineItems WHERE Status__c!='Lost'),RecordType.Name,AutoRenewal__c,DoesThisAutoRenewalHaveChanges__c FROM Opportunity WHERE Id IN :oppIdSet];
            for(Opportunity opp: oppList) {
                
                if((sourceMethod=='OppTrigger') || (sourceMethod=='ContractTrigger' && !(opp.RecordType.Name=='Renewal' && opp.AutoRenewal__c && !opp.DoesThisAutoRenewalHaveChanges__c))) {
                    Boolean oppHasASC606RevRecProduct = false;
                    if(opp.OpportunityLineItems!=null && opp.OpportunityLineItems.size()>0) {
                        for(OpportunityLineItem oli: opp.OpportunityLineItems) {
                            if(oli.Product2!=null && oli.Product2.ASC606RevRec__c=='Yes') {
                                System.debug('HS06Sep oli.Product2.Name='+oli.Product2.Name);
                                oppHasASC606RevRecProduct = true;
                                break;
                            }
                        }
                    }
                    oppIdFlagMap.put(opp.Id, oppHasASC606RevRecProduct);    
                }
                
            }
        }
        return oppIdFlagMap;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Jan 2020
    // @param: TriggerParameters
    // @description: SFDC-2417 Moved Opp Validation Rule(SalesRenewalOpptyLockStage6L) to code
	// @modifiedBy: Paras Dhingra
	// @modifiedDate: 08 May 2020
	// @modifiedDescription: This validation is a subset of method blockUpdatesToLostOpportunity hence commenting it
    //-----------------------------
    /*public static void blockSalesUpdateToLostRenewalOppyValidation(TriggerParameters tp) {
        if(GlobalConstants.isOppLineItemUpdatedDueToParentOppCascade) {
            //To skip validation when cascade update from parent opp leads to OLI update which further leads to parent opp update. 
            return;
        }
        String profileName = UtilityClass.LoggedInUserProfileName;
        if(!(profileName.containsIgnoreCase('Sales: General') || profileName.containsIgnoreCase('Sales Coordinator'))) {
            return;
        }
        for(Opportunity newOpp : (List<Opportunity>) tp.newList) {
            Opportunity oldOpp = (Opportunity)tp.oldMap.get(newOpp.Id);
            if(oldOpp.StageName == '6L-Renewal Lost') {
                newOpp.addError(System.Label.SalesCannotUpdateLostRenewalOpp);
            }
        }
    }*/
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 05 Feb 2020
    // @param: TriggerParameters
    // @description: SFDC-2589 Moved Opp Validation Rule(SalesStage6LLockFields) to code
	// @modifiedBy: Paras Dhingra
	// @modifiedDate: 08 May 2020
    // @modifiedDescription: SFDC-2566 Added an exception for Attachment count to avoid errors during attachment creation
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date: 23 Jul 2020
    // @Last Modified Description: SFDC-3072 Add User Support profile to exclusions
    //-----------------------------
    public static void blockUpdatesToLostOpportunity(TriggerParameters tp) {
        if(GlobalConstants.isOppLineItemUpdatedDueToParentOppCascade || GlobalConstants.hasEnhancedSalesPermission) {
            //To skip validation when cascade update from parent opp leads to OLI update which further leads to parent opp update. 
            return;
        }
        String profileName = UtilityClass.LoggedInUserProfileName;
        if(profileName.containsIgnoreCase('System Admin') || profileName.containsIgnoreCase('Sales Ops') || profileName.containsIgnoreCase('User Support') ) {
            return;
        }
        for(Opportunity newOpp : (List<Opportunity>) tp.newList) {
            Opportunity oldOpp = (Opportunity)tp.oldMap.get(newOpp.Id);
            if(oldOpp.StageName == '6L-Renewal Lost' || oldOpp.StageName == '6L-Closed Lost') {
                System.debug('--@PD inside if checking field change--');
                if(newOpp.ActivityCreated__c != oldOpp.ActivityCreated__c || newOpp.MISActivityAdded__c != oldOpp.MISActivityAdded__c || newOpp.OaRStatus__c != oldOpp.OaRStatus__c || newOpp.DiscountApprovalAttachmentCount__c != oldOpp.DiscountApprovalAttachmentCount__c || newOpp.MISAttachmentAdded__c != oldOpp.MISAttachmentAdded__c  ) {
                    continue;
                }
                else {
                	newOpp.addError(System.Label.CannotUpdateLostOpp);    
                }                
            }
        }
    }
    
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 10 Feb 2020
    // @param: TriggerParameters
    // @description: SFDC-2592 
    //-----------------------------
    
    public static void setToOppLostSalesIncentiveApproval(TriggerParameters tp) {
        Set<Id> oppIDSet=new Set<ID>();
        Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        for(Opportunity oppy:(List<Opportunity>)tp.newList) {
            if(oppy.RecordTypeId == NewBusinessOppRecordTypeId || oppy.RecordTypeId == RenewalOppRecordTypeId) {	
            	if(oppy.StageName=='6L-Closed Lost' || oppy.StageName=='6L-Renewal Lost') {
                    oppIDSet.add(oppy.id);
            	}
            }
        }        
        List<SalesIncentiveApproval__c> salesIncApprovalListBefore=new List<SalesIncentiveApproval__c>();
        if(oppIDSet.size()>0) {
            salesIncApprovalListBefore=[Select id, CommissionStatus__c from SalesIncentiveApproval__c where Opportunity__c in:oppIDSet AND CommissionStatus__c!='Opportunity Lost'];
            if(salesIncApprovalListBefore.size()>0) {
                for(SalesIncentiveApproval__c sIA:salesIncApprovalListBefore) { 
                    	sIA.CommissionStatus__c='Opportunity Lost';
                } 
            }
            update salesIncApprovalListBefore;
        }
    }
    
    //-----------------------------
    // @author: Sushma Yadav
    // @date: 07 May 2020
    // @param: TriggerParameters
    // @description: SFDC-2799 BillTo & ShipTo validation rule thru code
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date: 23 Jul 2020
    // @Last Modified Description: SFDC-3072 Add User Support profile to exclusions
    //-----------------------------
    public static void blockSalesUpdateAddressValidation(TriggerParameters tp) {
        Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();		
        String profileName = UtilityClass.LoggedInUserProfileName;	
        
        	if(profileName.containsIgnoreCase('System Admin') || GlobalConstants.hasEnhancedSalesPermission || profileName.containsIgnoreCase('Sales Ops') || profileName.containsIgnoreCase('User Support')) {
            return;
        	}
        
        for(Opportunity oppy : (List<Opportunity>) tp.newList) {
			if(oppy.RecordTypeId == RenewalOppRecordTypeId && oppy.AutoRenewal__c==false) {		
        		for(Opportunity newOpp : (List<Opportunity>) tp.newList) {
            		Opportunity oldOpp = (Opportunity)tp.oldMap.get(newOpp.Id);
			        	if(newOpp.BillToCity__c != oldOpp.BillToCity__c || newOpp.BillToClientName__c != oldOpp.BillToClientName__c || 
                           newOpp.BillToContactEmailAddress__c != oldOpp.BillToContactEmailAddress__c || newOpp.BillToContactFirstName__c != oldOpp.BillToContactFirstName__c ||
                           newOpp.BillToContactLastName__c != oldOpp.BillToContactLastName__c || newOpp.BillToContactTelephoneNumber__c != oldOpp.BillToContactTelephoneNumber__c ||
                           newOpp.BillToPostalZipCode__c != oldOpp.BillToPostalZipCode__c || newOpp.BillToStateProvince__c != oldOpp.BillToStateProvince__c || 
                           newOpp.BillToStreet__c != oldOpp.BillToStreet__c || newOpp.ShipToCity__c != oldOpp.ShipToCity__c || 
                           newOpp.ShipToClientName__c != oldOpp.ShipToClientName__c || newOpp.ShipToPostalZipCode__c != oldOpp.ShipToPostalZipCode__c || 
                           newOpp.ShipToContactEmailAddress__c != oldOpp.ShipToContactEmailAddress__c || newOpp.ShipToContactFirstName__c != oldOpp.ShipToContactFirstName__c ||
                           newOpp.ShipToContactLastName__c != oldOpp.ShipToContactLastName__c || newOpp.ShipToContactTelephoneNumber__c != oldOpp.ShipToContactTelephoneNumber__c ||
                           newOpp.ShipToStateProvince__c != oldOpp.ShipToStateProvince__c || newOpp.ShipToStreet__c != oldOpp.ShipToStreet__c) {

                				newOpp.addError(System.Label.SalesCannotUpdateBillToShipToFields);
            				}
        
				}
    		}
		}
    }
    
    //-----------------------------
    // @author: Sushma Yadav
    // @date: 27 May 2020
    // @param: TriggerParameters
    // @description: Deactivated WF UpdateLostCodeandReasonwhenOpportunityReopen for story SFDC-2439
    //-----------------------------
    public static void UpdateReplacementOppwhenOpportunityReopen(TriggerParameters tp) {	
	
    List<Opportunity> OppyToUpdate=new List<Opportunity>();
	Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
    Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
    Id ForecastPlaceOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Forecasting Placeholder').getRecordTypeId();    
        for(Opportunity newOpp:(List<Opportunity>)tp.newList) {
			Opportunity oldOpp = (Opportunity)tp.oldMap.get(newOpp.Id);
            	if(newOpp.RecordTypeId == NewBusinessOppRecordTypeId || newOpp.RecordTypeId == RenewalOppRecordTypeId || newOpp.RecordTypeId == ForecastPlaceOppRecordTypeId) {
					if(!newOpp.StageName.contains('6L') && oldOpp.StageName.contains('6L')) {
					newOpp.ReplacementOpportunity__c=null;
                    newOpp.LostReasonCode__c=null;
                    newOpp.LostReasonDescription__c=null;
					}
				}
			}        		
		}
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 10 Aug 2020
    // @param: TriggerParameters
    // @description: SFDC-3186 Create a record in Renewal Staging object when an opp is moved from 6W to 6WP. Delete the unprocessed staging record if opp is moved back from 6WP to any other stage.
    //-----------------------------
    public static void createRenewalStagingOn6WP(TriggerParameters tp) {
        Id newBizOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id renewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        
        List<String> validFromStageNames = new List<String> {'6W-Closed Won','6W-Renewal Won'};
        //
        List<RenewalStaging__c> renewalsStagingListInsert = new List<RenewalStaging__c>();
        Set<Id> oppIdsMovedBackFrom6WP = new Set<Id>();
        
        //Skip renewals if custom setting is set to Do Not Trigger
        Boolean skipRenewalsStagingCreation = false;
        AutomatedRenewalsConfig__c renewalsOrgConfig = AutomatedRenewalsConfig__c.getOrgDefaults();
        AutomatedRenewalsConfig__c renewalsUserConfig = AutomatedRenewalsConfig__c.getInstance();
        if((renewalsOrgConfig!=null && renewalsOrgConfig.DoNotTriggerRenewals__c) || (renewalsUserConfig!=null && renewalsUserConfig.DoNotTriggerRenewals__c)) {
            skipRenewalsStagingCreation=true;
        }        
            
        for(Opportunity newOpp:(List<Opportunity>)tp.newList) {
            Opportunity oldOpp = (Opportunity)tp.oldMap.get(newOpp.Id);
            if(newOpp.StageName!=oldOpp.StageName && (newOpp.RecordTypeId == newBizOppRecordTypeId || newOpp.RecordTypeId == renewalOppRecordTypeId)) {
                if(!skipRenewalsStagingCreation && newOpp.StageName.containsIgnoreCase('6WP') && validFromStageNames.contains(oldOpp.StageName)) {
                    RenewalStaging__c stagingObj = new RenewalStaging__c(Opportunity__c=newOpp.Id,OppId__c=newOpp.Id, Processed__c=false, Exception__c=false, HasMixedProducts__c=false, Error__c=false);
                    renewalsStagingListInsert.add(stagingObj);                    
                }
                if(oldOpp.StageName.containsIgnoreCase('6WP') && !newOpp.StageName.containsIgnoreCase('6WP')) {
                    //delete unprocessed Renewal Staging records
                    oppIdsMovedBackFrom6WP.add(newOpp.Id);
                }                
            }            
        }
        if(renewalsStagingListInsert.size() > 0) {
            insert renewalsStagingListInsert;
        }
        if(oppIdsMovedBackFrom6WP.size()>0) {
            List<RenewalStaging__c> renewalsStagingListDelete = [SELECT Id FROM RenewalStaging__c WHERE Opportunity__c IN :oppIdsMovedBackFrom6WP AND Processed__c=false];
            if(renewalsStagingListDelete!=null && renewalsStagingListDelete.size()>0) {
                delete renewalsStagingListDelete;
            }
        }
    }
    /**
     * @author: Paras Dhingra
     * @date: 18th Aug 2020
     * @param: Triggerparameters tp
     * @description: SFDC-3187 if an opportunity is moved from price change only to some other type then check for 
     */
    public static void deletePriceChangeOnly(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            List<ContractLineItemSchedule__c> lstFixedFeeItemsToDelete = new List<ContractLineItemSchedule__c>();
            Set<Id> oppyToQuery = new Set<Id>();
            for(Opportunity newOppy : (List<Opportunity>)tp.newList) {
                Opportunity oldOppy = (Opportunity)tp.oldMap.get(newOppy.Id);
                //check if price change only flag is toggled and moved from true to false
                if(newOppy.PriceChangeOnly__c!=true 
                    && newOppy.PriceChangeOnly__c!=oldOppy.PriceChangeOnly__c 
                    && newOppy.ContractBeingRenewed__c!=null) {
                        oppyToQuery.add(newOppy.Id);
                }
            }
            if(oppyToQuery!=null && !oppyToQuery.isEmpty()) {
                lstFixedFeeItemsToDelete = [SELECT Id FROM ContractLineItemSchedule__c
                                            WHERE PriceIncreaseId__c IN : oppyToQuery
                                            AND PriceIncreaseId__c!=null];
                if(lstFixedFeeItemsToDelete!=null && !lstFixedFeeItemsToDelete.isEmpty()) {
                    delete lstFixedFeeItemsToDelete;//delete all Fixed fee items created via fixed fee logic
                }
            }
        }
        
    }
    
    /*-----------------------------
    @Author: Sharique Iqbal
    @Date: 28 Jan 2021
    @Description: SFDC-2151 New logic to identify multiyear opportunities
                  If the difference between the 2 dates(CST & CED) is 2 years - then the Multiyear checkbox would be set to yes                     
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void multiYearLogic(TriggerParameters tp) {

        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                                   
            for (Opportunity oppty : (List<Opportunity>)tp.newList) {
                if (oppty.ContractStartDate__c != null && oppty.ContractEndDate__c != null
                    && oppty.ContractStartDate__c.addYears(2).daysBetween(oppty.ContractEndDate__c) >= -1) {  
                       oppty.MultiYear__c = true;         
                } 
                else {
                       oppty.MultiYear__c = false; 
                } 
            }
        }
    }
    /*-----------------------------
    @Author: Vaishali Jain
    @Date: 09 April 2021
    @Description:                      
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void populateReferralPercentage(TriggerParameters tp) {
        for(Opportunity newOppty : (List<Opportunity>)tp.newList) {
            if(newOppty.ReferralType__c == 'Referral Fee Manual' && newOppty.Referral_Percentage__c == null ) {
                newOppty.addError('Please Fill Referral Percentage');
            }
            else if(newOppty.ReferralType__c == 'Referral Only') {
               newOppty.Referral_Percentage__c = 5.00;
            }
            else if(newOppty.ReferralType__c == 'Referral Plus Logistics') {
               newOppty.Referral_Percentage__c = 10.00;
            }
         }
    }
    /*
    * @author: Akshay Dogra
    * @date: 10th May 2021
    * @param: Triggerparameters tp
    * @description: SFDC-4004:This method checks for decision making contact roles before moving the Stage of the Opportunity
    */
    public static void opportunityContactRoleMandatory(TriggerParameters tp) {
        //if user has validation by pass custom permission then skip validation
        if(UtilityClass.hasValidationBypassPermission) {
            return;
        } 
        String profileName = UtilityClass.LoggedInUserProfileName;
        //check if user is admin then do not process further
        if(profileName.containsIgnoreCase('System Admin')) {
              //no validation checks are required for system admins
              return;
          }
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            
            Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
            Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            
            List<Opportunity> lstOppyContactRole = new List<Opportunity>();
            Set<Id> oppyToQuery = new Set<Id>();
            Set<String> OpportunityContactRoleValues = new Set<String>(Label.OpportunityContactRoleValues.Split(','));
            List<String> OpportunityClosedStatus = Label.OpportunityClosedStatus.split(','); 
            for(Opportunity newOppy : (List<Opportunity>)tp.newList) {
                Opportunity oldOppy = (Opportunity)tp.oldMap.get(newOppy.Id);
                if(oldOppy != NULL && newOppy.StageName != oldOppy.StageName && newOppy.GlobalSegments__c != null && newOppy.GlobalSegments__c.containsIgnoreCase('Financial Services') &&
                   (
                       (newOppy.RecordTypeId == NewBusinessOppRecordTypeId && !(newOppy.StageName == '2-Need Confirmed' || newOppy.StageName == '1-Sales Qualified' || OpportunityClosedStatus.contains(newOppy.StageName))) 
                       ||
                       (newOppy.RecordTypeId == RenewalOppRecordTypeId && !(newOppy.StageName == '3-Renewal Pending' || OpportunityClosedStatus.contains(newOppy.StageName)))
                   )) {
                       oppyToQuery.add(newOppy.Id);
                   }
            }
            if(oppyToQuery!=null && !oppyToQuery.isEmpty()) {
                lstOppyContactRole = [Select Id, (SELECT Role FROM OpportunityContactRoles WHERE Role IN: OpportunityContactRoleValues)
                                      FROM Opportunity WHERE Id IN : oppyToQuery];
                System.debug('LstOppyContactRole'+lstOppyContactRole);
                for(Opportunity opp: lstOppyContactRole) {
                    if(opp.OpportunityContactRoles != null && opp.OpportunityContactRoles.size()<1) {
                        System.debug('ABC###'+opp.OpportunityContactRoles);
                        tp.newMap.get(opp.id).addError(System.Label.OpportunityContactRoleMissing);
                    }
                }
            }
        }
    }
    /*-----------------------------
    @Author: Sharique Iqbal
    @Date: 04 April 2021
    @Description:                      
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void populateDateRiskFirstIdentified(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
           Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
           for(Opportunity newOppty : (List<Opportunity>)tp.newList) {
               Opportunity oldOppy = (Opportunity)tp.oldMap.get(newOppty.Id);
               if (oldOppy.DateRiskFirstIdentified__c == null && newOppty.NumberOfProductsAtRisk__c > 0 && oldOppy.NumberOfProductsAtRisk__c == 0) {
                  newOppty.DateRiskFirstIdentified__c = system.today();   
               }
          }
        }
    }

     /*-----------------------------
    @Author: Sharique Iqbal
    @Date: 22 Sept 2021
    @Description: Allow Alliance Team to edit Global Alliance fields when Oppy is 6WP
    @return: Void
    -----------------------------*/
    public static void globalAllianceAccess(TriggerParameters tp) {
    Map <String, Schema.SobjectField > oppyFields = Opportunity.sObjectType.getDescribe().fields.getMap();
    Set <String> setGlobalAllianceFields = new  Set <String>(); 
    Set<Id> setGlobalAllianceTeam = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    Boolean hasError = false;
    
    for(Opportunity oppy : (List<Opportunity>)tp.newList) {
        Opportunity oldOppy = (Opportunity)tp.oldMap.get(oppy.Id);
        if (oldOppy.StageName == '6WP-Closed Won/Order Processed' || oldOppy.StageName == '6W-Forecasting Placeholder') {
            oppIds.add(oppy.id);
        }
    }    
    
    if (!oppIds.isEmpty()) {    
        for(Schema.FieldSetMember fieldSetMemberObj : SObjectType.Opportunity.FieldSets.GlobalAllianceFields.getFields()) {
          setGlobalAllianceFields.add(fieldSetMemberObj.getFieldPath().toLowercase()); //api name
        }    
        
        for (PermissionSetAssignment usr : [SELECT AssigneeId FROM PermissionSetAssignment where PermissionSet.Name ='AllianceTeamAccess']) {
          setGlobalAllianceTeam.add(usr.AssigneeId); // User id from Permission set
        }
    }    
    // Alliance Team member to Edit Global alliance fields SFDC-2548    
    if(setGlobalAllianceTeam.contains(UserInfo.getUserId())) {
       for(Opportunity oppy : (List<Opportunity>)tp.newList) {
           if (oppIds.contains(oppy.Id)) {
              Opportunity oldOppy = (Opportunity)tp.oldMap.get(oppy.Id);
              for(string fieldName : oppyFields.keySet()) {
                  Schema.DescribeFieldResult dfr = oppyFields.get(fieldName).getDescribe();
                  if(oldOppy.get(fieldName)!=oppy.get(fieldName) && !dfr.IsCalculated()) {
                      //locked field edited
                      if( !setGlobalAllianceFields.contains(fieldName)) {
                          //rule specific custom message can be added later on
                          System.debug('@PD--Error Field--'+fieldName);               
                          hasError = true;
                          break;
                      }
                  }
              }
           }   
         //check if if oppy has error
         if(hasError) {
            oppy.addError(System.Label.GlobalAllianceFieldError); // todo add label    
         }   
        }
      }
    }
    /*-----------------------------
    @Author: Manish Kumar
    @Date: 13 Oct 2021
    @Description: SFDC-4731 Update the Legal Entity and Requested Legal Entity fields on Exception Approval                
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void updateLegalEntity(TriggerParameters tp) {
        //SFDC-5282 Change Start
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        //if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
        	//List<Opportunity> lstToUpdateOpty = New List<Opportunity>();
        	if(!mapNewOpportunity.isEmpty() && !mapOldOpportunity.isEmpty()) {
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.ExceptionStatus__c == 'Exception Request Approved' && mapOldOpportunity.get(newOpp.id).ExceptionStatus__c != 'Exception Request Approved'){
            			newOpp.LegalEntity__c = mapOldOpportunity.get(newOpp.id).RequestedLegalEntity__c;
                   		newOpp.RequestedLegalEntity__c = null;
                    }
                }
            }
            //for(Opportunity newOppty : (List<Opportunity>)tp.newList) {
                //Opportunity cloneOpty = newOppty.clone(true,true);
                //if(cloneOpty.ExceptionStatus__c == 'Exception Request Approved' && mapOldOpportunity.get(newOppty.id).ExceptionStatus__c != 'Exception Request Approved'){
                   //cloneOpty.LegalEntity__c = newOppty.RequestedLegalEntity__c;
                   //cloneOpty.RequestedLegalEntity__c = null;
                   //lstToUpdateOpty.add(cloneOpty);
               	//}
         	 //}
             //if(!lstToUpdateOpty.isEmpty()){
             	//update lstToUpdateOpty;
             //}
             //SFDC-5282 Change End
        }
    }
    /*-----------------------------
    @Author: Manish Kumar
    @Date: 27 Oct 2021
    @Description: SFDC-4885 Check empty Requested Legal Entity field on Exception Approval                
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void checkEmptyRequestedLegalEntity(TriggerParameters tp) {
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            if(!mapNewOpportunity.isEmpty() && !mapOldOpportunity.isEmpty()) {
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.ExceptionStatus__c == 'Exception Request Approved' && mapOldOpportunity.get(newOpp.id).ExceptionStatus__c != 'Exception Request Approved' && mapOldOpportunity.get(newOpp.id).RequestedLegalEntity__c == null){
            			newOpp.addError(System.Label.EmptyRequestedLegalEntityErrorMessage);
                    }
                }
        	}
    	}
    }
    
    /*-----------------------------
    @Author: Shikhar Singh
    @Date: 11 January 2022
    @Description: SFDC-4213 "Close Date - Original" should be first close date populated while creation of record manually or via integration except lead conversion which follows a different calculation               
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void updateCloseDateOriginalToCloseDateValue(TriggerParameters tp) {
        for(Opportunity newOpp: (List<Opportunity>)tp.newList) {
                newOpp.CloseDateOriginal__c = newOpp.CloseDate;
        }
    }
    
    /*-----------------------------
    @Author: Neelam Agrawal
    @Date: 02 Mar 2022
    @Description: SFDC-5474 Update OpportunityLineItem when synergy value is updated             
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    @Modified By : Digvijay Singh
    @Date: 28-March 2022
    @Descciption :- SFDC-5600,Synergy recaluctaion on line Items
    -----------------------------*/
    public static void updateSynergyOnOppyLineItem(TriggerParameters tp) {
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
        List<Opportunity> oppyList = new List<Opportunity>();
        List<OpportunityLineItem> opptyLineItemList= new List<OpportunityLineItem>();
        List<OpportunityLineItem> opptyLineItemneedSynergycal= new List<OpportunityLineItem>();
        List<OpportunityLineItem> opptyLineItemtoupdate= new List<OpportunityLineItem>();
      
        for(Opportunity opp: mapNewOpportunity.values()) {
            System.debug('Synergy Flag '+mapNewOpportunity.get(opp.id).Synergy1__c );
            if(mapNewOpportunity.get(opp.id).Synergy1__c!= mapOldOpportunity.get(opp.id).Synergy1__c) {               
                    oppyList.add(opp);              
            }
        }
        
        if(oppyList.size() > 0) {
             opptyLineItemList = [Select Id,SynergyType__c,Status__c , Product2Id ,SynergyTheme__c,OpportunityId from OpportunityLineItem where OpportunityId in: oppyList and Status__c!='Lost'];
        }
                                                          
        for(OpportunityLineItem oli:opptyLineItemList ) {
            if(mapNewOpportunity.get(oli.OpportunityId).Synergy1__c=='No') {
                oli.SynergyType__c='';
                oli.SynergyTheme__c=''; 
                opptyLineItemtoupdate.add(oli);               
            } else if(mapNewOpportunity.get(oli.OpportunityId).Synergy1__c=='Yes') {
                opptyLineItemneedSynergycal.add(oli);
            }           
        }
        
        //SFDC-5600 , running the rule engine on OpportunityLineItems where synergy is updated to Yes from No
        if(!opptyLineItemneedSynergycal.isEmpty()) {
            opptyLineItemneedSynergycal=(List<OpportunityLineItem>)OpportunityLineItemMethods.populateSynergyTypeandTheme(opptyLineItemneedSynergycal,false);
            opptyLineItemtoupdate.addAll(opptyLineItemneedSynergycal);
        }
        if(!opptyLineItemtoupdate.isEmpty()) {
            update opptyLineItemtoupdate;
        }
    }
    
    /*-----------------------------
    @Author: Neelam Agrawal
    @Date: 02 Mar 2022
    @Description: SFDC-5474 Synergy Theme and Type must be re-evaluated when Synergy is set to Yes OR No             
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void synergyCalculation(TriggerParameters tp) {
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
        for(Opportunity opp: mapNewOpportunity.values()) {
            if(mapNewOpportunity.get(opp.id).Synergy1__c!= mapOldOpportunity.get(opp.id).Synergy1__c) {
                if(mapNewOpportunity.get(opp.id).Synergy1__c== 'No') {
                    opp.SynergyTheme__c='';
                    opp.SynergyType__c='';
                }
            }
        }
    }
    
    /*-----------------------------
    @Author: Manish Kumar
    @Date: 22nd March 2022
    @Description: SFDC-5500 Update the Prior Approved Checkbox to TRUE when Exception Request on Opty got Approved
    @             or delete the recently added products if the Exception request got rejected by the Tax team.
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void updatePriorApproved(TriggerParameters tp) {
        Map<Id,Opportunity> mapOldOpportunity = (Map<Id,Opportunity>) tp.oldMap;
        Map<Id,Opportunity> mapNewOpportunity = (Map<Id,Opportunity>) tp.newMap;
        List<OpportunityLineItem> lstOfApprovedOptyProducts = New List<OpportunityLineItem>();
        List<OpportunityLineItem> lstOfDeniedOptyProducts = New List<OpportunityLineItem>();
        List<OpportunityLineItem> lstToUpdateOptyProducts = New List<OpportunityLineItem>();
        List<OpportunityLineItem> lstToDeleteOptyProducts = New List<OpportunityLineItem>();
        Set<Id> setOfApprovedOptyIds = New Set<Id>();
        Set<Id> setOfDeniedOptyIds = New Set<Id>();

        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
        	if(!mapNewOpportunity.isEmpty() && !mapOldOpportunity.isEmpty()) {
                for(Opportunity newOpp: mapNewOpportunity.values()) {
                    if(newOpp.ExceptionStatus__c == 'Exception Request Approved' && mapOldOpportunity.get(newOpp.id).ExceptionStatus__c != 'Exception Request Approved') {
                        setOfApprovedOptyIds.add(newOpp.Id);
                    }
                    else if(newOpp.ExceptionStatus__c == 'Exception Request Denied' && mapOldOpportunity.get(newOpp.id).ExceptionStatus__c != 'Exception Request Denied') {
                        setOfDeniedOptyIds.add(newOpp.Id);
                	}
                }
                if(setOfApprovedOptyIds.size() > 0){
                	lstOfApprovedOptyProducts = [Select id, OpportunityId, PriorApproved__c from OpportunityLineItem where OpportunityId = :setOfApprovedOptyIds and PriorApproved__c = false order by OpportunityId];
                }
                if(setOfDeniedOptyIds.size() > 0){
                	lstOfDeniedOptyProducts = [Select id, OpportunityId, PriorApproved__c, Opportunity__r.LegalEntity__c, Opportunity__r.RequestedLegalEntity__c from OpportunityLineItem where OpportunityId = :setOfDeniedOptyIds and PriorApproved__c = false order by OpportunityId];
                }
                
                for(OpportunityLineItem oli1 : lstOfApprovedOptyProducts) {
                	oli1.PriorApproved__c = True;
                    lstToUpdateOptyProducts.add(oli1);
                }
                for(OpportunityLineItem oli2 : lstOfDeniedOptyProducts) {
                    if(oli2.Opportunity__r.LegalEntity__c == oli2.Opportunity__r.RequestedLegalEntity__c) {
                       lstToDeleteOptyProducts.add(oli2);
                    }
                }
            }
        }
        if(lstToUpdateOptyProducts.size() > 0) {
            update lstToUpdateOptyProducts;
        }
    	if(lstToDeleteOptyProducts.size() > 0) {
            delete lstToDeleteOptyProducts;
        }
    }
    
    /*-----------------------------
    @Author: Ankush Vedi
    @Date: 24th March 2022
    @Description: SFDC-5530 -Response Management Process Optimization - Case
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/     
     public static void updateCaseOpportunities(TriggerParameters tp) {
        
        Map<Id,Opportunity> mapoldoppty = (map<ID,Opportunity>)tp.oldMap;
        Set<Id> opptyId = new Set<Id>();
        Set<Id> lostOpptyId = new Set<Id>();
        Set<Id> wonOpptyId = new Set<Id>();
        Set<Id> nonLostWonOpptyId = new Set<Id>();
        List<case> caseToUpdate = new List<case>();
        List<String> Oppy6WStages = Label.Oppy6WStages.split(',');
        
        Id caseRMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        
        for(opportunity op : (List<Opportunity>)tp.newList) {
            
            if(Oppy6WStages.contains(op.StageName) && !Oppy6WStages.contains(mapoldoppty.get(op.id).StageName)) {
                wonOpptyId.add(op.Id);
            } else if(op.StageName.contains('6L') && !mapoldoppty.get(op.id).StageName.contains('6L')) {
                lostOpptyId.add(op.Id);
            } else if(op.stagename != mapoldoppty.get(op.id).StageName){
                nonLostWonOpptyId.add(op.Id);                
            }
        }
        
        opptyId.addAll(wonOpptyId);
        opptyId.addAll(lostOpptyId);
        opptyId.addAll(nonLostWonOpptyId);
        
        if(opptyId.size()>0){
            
            for(CaseOpportunities__c caOppy : [select id, Case__c, Opportunity__c from CaseOpportunities__c where Opportunity__c IN :opptyId AND Case__r.RecordTypeID =: CaseRMRecordTypeId]) {
                
                if(wonOpptyId.contains(caOppy.Opportunity__c)){
                    Case cps = new case(Id =  caOppy.Case__c, ProjectStatus__c = 'WIN', ProjectAdditionalInformation__c = 'WIN');
                    caseToUpdate.add(cps);
                } else if(lostOpptyId.contains(caOppy.Opportunity__c)){
                    Case cps = new case(Id =  caOppy.Case__c, ProjectStatus__c = 'Loss', ProjectAdditionalInformation__c = 'Other');
                    caseToUpdate.add(cps);
                } else if(nonLostWonOpptyId.contains(caOppy.Opportunity__c)){
                    Case cps = new case(Id =  caOppy.Case__c, ProjectStatus__c = 'pending result', ProjectAdditionalInformation__c = 'pending decision');
                    caseToUpdate.add(cps);
                }
            }
       }
        if(caseToUpdate.size()>0) {
            update caseToUpdate;
        }
    }
    /*-----------------------------
    @Author: Arshad Qureshi
    -----------------------------*/     
    public static void updatePreviousFiscalYearOpportunityLink(TriggerParameters tp) {
        Set<Id> oppIDSet=new Set<ID>();
        List<Opportunity> lstOppyToUpdate = new List<Opportunity>();
        set<Id> setContractId= new Set<Id>();
        Map<Id,Map<Date,Opportunity>> contractOpportunityMap = new Map<Id,Map<Date,Opportunity>>();
        List<Opportunity> lstOppyPreviousFiscalYearToUpdate= new List<Opportunity>();
        Map<id,contract> oppyInContract=new Map<id,contract>();
        System.debug('inside--->previousYear');
        
        Id NewBusinessOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Id InnerYearOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inner Year').getRecordTypeId();
        
               
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate && !Test.IsRunningTest())) {
            lstOppyToUpdate = tp.newList;
        }
        /*		if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) { 
lstOppyToUpdate = tp.oldList;
}*/
        try
        {
            
            for(Opportunity oppy: lstOppyToUpdate) {
                if(oppy.BusinessLine__c!=null){
                    if(oppy.BusinessLine__c.contains('Automotive Insights')) {
                        if((oppy.PreviousFiscalYearOpportunityLink__c==null) && (oppy.RecordTypeId == NewBusinessOppRecordTypeId || oppy.RecordTypeId ==RenewalOppRecordTypeId || oppy.RecordTypeId ==InnerYearOppRecordTypeId)) {
                            //  oppIDSet.add(oppy.id);
                            setContractId.add(oppy.ContractBeingRenewed__c);
                            system.debug('ContractID'+setContractId);
                        }
                    }
                }
            }
            if(setContractId!=null){
                List<Contract> contractWithOpportunities=[Select Id,StartDate,ContractStatus__c,Opportunity__c,Opportunity__r.ContractStartDate__c,
                                                          (Select id,BusinessLine__c,ContractBeingRenewed__r.Opportunity__c,AverageDiscountPercentage__c,AccountId,CloseDate,ContractStartDate__c,ContractBeingRenewed__c from Opportunities2__r order by ContractStartDate__c)
                                                          from contract where ID IN:setContractId];
                system.debug('inside-->contractWithOpportunities'+contractWithOpportunities);
                if(!contractWithOpportunities.isEmpty() && contractWithOpportunities!=null){
                    for(Contract con : contractWithOpportunities){
                        if(!contractOpportunityMap.containsKey(con.Id)){
                            Map<Date,Opportunity> opportunityStartDateMap= new Map<Date,Opportunity>();
                            if(!oppyInContract.containsKey(con.Id)){
                                oppyInContract.put(con.id,con);
                            }
                            for(Opportunity renewalOppy : con.Opportunities2__r){
                                if(renewalOppy.ContractStartDate__c!=null){
                                    opportunityStartDateMap.put(renewalOppy.ContractStartDate__c,renewalOppy);
                                } 
                            }
                            if(opportunityStartDateMap!=null){
                                contractOpportunityMap.put(con.Id,opportunityStartDateMap);
                            }
                        }
                        
                    }
                    if(contractOpportunityMap!=null){
                        System.debug('inside-->contractOpportunityMap'+contractOpportunityMap);
                        for(Opportunity oppy: lstOppyToUpdate) {
                            if(oppy.BusinessLine__c!=null){
                                if(oppy.BusinessLine__c.contains('Automotive Insights')) {
                                    if(oppy.PreviousFiscalYearOpportunityLink__c==null) {
                                        if(contractOpportunityMap.containsKey(oppy.ContractBeingRenewed__c))
                                        {
                                            Map<Date,Opportunity> opportunityContractStartDateMap= new Map<Date,Opportunity>();
                                           //wrapper list
                                           List<OppyDetailsWrapper> lstOppyDetailWrap=new List<OppyDetailsWrapper>();
                                            opportunityContractStartDateMap=contractOpportunityMap.get(oppy.ContractBeingRenewed__c);
                                            if(opportunityContractStartDateMap!=null){
                                                 
                                               // Date minDate=oppy.ContractStartDate__c;
                                                //  String OppyIdInContract='';
                                                for(Date oppyContractStartDate: opportunityContractStartDateMap.keySet()){
                                                    OppyDetailsWrapper objOppyDetailWrap = new OppyDetailsWrapper(opportunityContractStartDateMap.get(oppyContractStartDate).Id,oppyContractStartDate);                               
                                                    lstOppyDetailWrap.add(objOppyDetailWrap);
                                                  //  Integer previousYearDifference= oppy.ContractStartDate__c.year() - oppyContractStartDate.year();
                                                    /*
                                                    if(minDate>oppyContractStartDate){
                                                        minDate=oppyContractStartDate;
                                                        // OppyIdInContract=opportunityContractStartDateMap.get(minDate).ContractBeingRenewed__r.Opportunity__c;
                                                    }
                                                    system.debug('previousYearDifference-->'+oppy.ContractStartDate__c.year() +' '+ oppyContractStartDate.year());
                                                    if(previousYearDifference == 1)
                                                    {
                                                        oppy.PreviousFiscalYearOpportunityLink__c=opportunityContractStartDateMap.get(oppyContractStartDate).Id;
                                                        System.debug('previous fiscal year oppy link -->'+oppy.PreviousFiscalYearOpportunityLink__c);
                                                    }*/
                                                          
                                                }
                                                    if(oppyInContract.containsKey(oppy.ContractBeingRenewed__c) && (oppy.Id!=oppyInContract.get(oppy.ContractBeingRenewed__c).id))
                                                    {
                                                       OppyDetailsWrapper objOppyDetailWrap1 = new OppyDetailsWrapper(oppyInContract.get(oppy.ContractBeingRenewed__c).Opportunity__c,oppyInContract.get(oppy.ContractBeingRenewed__c).Opportunity__r.ContractStartDate__c);                               
                                                       lstOppyDetailWrap.add(objOppyDetailWrap1); 
                                                    }
                                                
                                                //Sorting and updating previous fiscal year oppy link
                                                if(!lstOppyDetailWrap.isEmpty()){
                                                    lstOppyDetailWrap.sort();
                                                    System.debug('wrapper-->'+lstOppyDetailWrap);
                                                    integer i=0;
                                                    ID previousOppyLink=null;
                                                    for(OppyDetailsWrapper wrapper : lstOppyDetailWrap)
                                                    {
                                                        if(i==0)
                                                        {
                                                            previousOppyLink=wrapper.oppyId;
                                                            i++;
                                                        }
                                                        else{
                                                            if(wrapper.oppyId.equalsIgnoreCase(oppy.Id))
                                                            {
                                                                System.debug('inside wrapper -->'+previousOppyLink);
                                                                oppy.PreviousFiscalYearOpportunityLink__c=previousOppyLink;
                                                                break;
                                                            }
                                                            previousOppyLink=wrapper.oppyId;
                                                        }       
                                                    }
                                                    System.debug('oppy -->'+oppy);
                                                    System.debug('oppy previous link -->'+ oppy.PreviousFiscalYearOpportunityLink__c);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        catch(Exception e) {
            UtilityClass.createApexLogRecord(e, 'OpportunityMethods', 'updatePreviousFiscalYearOpportunityLink');
            System.debug('Exception in OpportunityMethods.updatePreviousFiscalYearOpportunityLink: ' + e.getMessage());
        }
    }
        //----------------------------
    // @author: Ankush Agarwal
    // @date: 16th June,2023
    // @param: TriggerParameters
    // @description: US-5856599 : Opportunity - Mobility Metrics Rollup on Opportunity Lost  
    // @return: none
    //----------------------------
    public static void performRollupCalculationonClosedLostOppies(TriggerParameters tp){
        List<Opportunity> lstOppyToUpdate = new List<Opportunity>();
        Map<Id,Opportunity> mapoldoppty = (map<ID,Opportunity>)tp.oldMap;
        set<Id> setOppyID = new Set<Id>();
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
               lstOppyToUpdate = tp.newList;
        }
        for(Opportunity opp : lstOppyToUpdate){
            if((opp.StageName.contains('6L') && !mapoldoppty.get(opp.id).StageName.contains('6L'))
              || (mapoldoppty.get(opp.id).StageName.contains('6L') && opp.StageName != mapoldoppty.get(opp.id).StageName)){
                setOppyID.add(opp.Id);
                  System.debug('setOppyID ===> ' +setOppyID);
            }
        }
        
        if(setOppyID != null && !setOppyID.isEmpty()) {
            OpportunityLineItemMethods.performRollupCalculationsforOpportunity(setOppyID);
        }
    }
    
}