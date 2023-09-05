//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 21 Aug 2018
// @Last Modified Description : SFDC1-8620 Resolving Apex security Risk - CRUD delete, adding isDeleteable() before delete operation
// @Last Modified Company : VERTIBA
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 13 Sep 2018
// @Last Modified Description : SFDC1-8308 Updated method 'assignCasesViaTriage' to accomodate POL related changes.
// @Last Modified Company : VERTIBA
// 
// @LastModifiedBy: Tran-Vu Tran
// @LastModifiedDate: 18 Sep 2018
// @LastModifiedReason: SFDC1-9961, adding method to populate Related Lead/Case on Case closure
//                      (converted from Process Builder flow related to GDSA/Account Governance cases - original story SFDC1-965 & SFDC1-683)
// @LastModifiedDate: 20 Sep 2018
// @LastModifiedReason: SFDC1-9961, adding method to create New Account Request case when a Customer Care case was created under Unknown Account
//                      (converted from Process Builder flow related to GDSA/Account Governance cases - original story SFDC1-683)
// @Modified by: Paras Dhingra
// @Modified date: 07 Aug 2019
// @Modified Description : SFDC-175 added method call for preventAccountMisMatchOnCloseCase to validate customer care case closure
//
// @Modified by: Tran-Vu Tran
// @Modified date: 17 Sep 2019
// @Modified Description: SFDC-2036 Change the logic to retrieve UnknownAccountIDs from a query on Account records
//                      to the Custom Setting that holds the "Place Holder - Unknown Account" Account IDs, and move the static reference to Utility class
//                      
// @Modified by: Harshit Singhal
// @Modified date: 18 Jun 2020
// @Modified Description: SFDC-1652 Added a new method populateUserAsOwnerOnCaseClosure() to auto-assign cases to logged in user on closure if owned by a queue
// @Modified By : Paras Dhingra
// @Modified Date : 13th Oct 2020
// @Modified Description : SFDC-2723 Adding criteria to create OM Case when Auto Renewal flag is toggled 
//-----------------------------
public class CaseMethods {
    
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 June 2017
    // @param: TriggerParameters tp
    // @description: When the product is selected in a case, the function creates an additional case fields (record) 
    //               for the product that requires additional fields.
    // 
    // @edits: 31st July 2017 SFDC1-1159 Uttam Arya, When the Internal Partner is selected in a case, the function creates an additional case fields (record) 
    //               for the Internal Partner product that requires additional fields.
    //         2nd Aug 2017 SFDC1-1941 Uttam Arya, Change Record Name Convention-Additional Case Fields (CaseNumber instead of 'Yes')
    //         22nd Jan 2018 SFDC1-6729 Vishnu Vardhan, When the additnonal case type linking field is created with a product group, product family and case record type. 
    //              Now on creating with case, product group and different product family still creates additional case fields object. Adding extra condition to stop this.
    //         14th Feb 2018 SFDC1-6382 Vishnu Vardhan, Most of the earlier code is rewritten. Additnonal case type linking record 
    //              is used to determine, ACF record type. It is done based on product group, product family, internal case and case record type. 
    //              New case scenarios have come up as mentioned below. So plotting a table and where/how it is achieved in the code.
    //              Also, additional case fields record name has been changed to ACF-<<CaseNumber>>
    //          3rd Apr 2018 SFDC1-7120 Vishnu Vardhan, Removing internal partner related code.
    //          4rd Apr 2018 SFDC1-6382 Vishnu Vardhan, When a case is created and after that ACTL gets created or deleted then ACF was not 
    //              Getting created or deleted. Have added code to cover this scenario.
    //          06th Sep 2018 Paras Dhingra migration exercise Adding legacy id fields for AdditionalCaseFields 
    //          19th Nov 2018 SFDC1-10490: Vishnu Vardhan : Adding logic to avoid the re-execution of the method 
    //              and create duplicate case. Removing legacy related code 
    //---------------------------------------------------------------------------------------------------------------
    // Case Record| Product group  | Additional Case | Additional Case   | Action To be Taken | Achieved at line    |
    // Type       | Producy Family | Type Linking    | Field Record Type | on ACF Record      | number              |
    //---------------------------------------------------------------------------------------------------------------
    // Same       | Same           |    Filtering out these cases from furhter processing     | For loop at line 55 |
    // Either One changed          |    Not Found    |                   | Delete ACF         | If at line 94       |
    // Either One changed          |    Found, but OLD Case dont have ACF| Create ACF         | If at line 97       |
    // Same       | Changed        |    Found        | Different         | Delete and Recreate| If at line 112      |
    // Same       | Changed        |    Found        | Same              | Do Nothing         | If at line 91       |
    // Changed    | Changed        |    Found        | Different         | Delete and Recreate| If at line 112      |
    // Changed    | Changed        |    Found        | Same              | Do Nothing         | If at line 91       |
    // Changed    | Same           |    Found        | Same              | Do Nothing         | If at line 91       |
    // Changed    | Same           |    Found        | Different         | Change Record Type | If at line 105      |
    //---------------------------------------------------------------------------------------------------------------
    // @return: None
    //------------------------------
    public static void setCaseAdditionalFieldsObject(TriggerParameters tp) {
        if(GlobalConstants.hasAdditionalCaseFieldsCreationExecuted) {
            return;
        }
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = true;
        // Map of old values and new values
        Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;

        //Additinonal case fields whose record type or name will be changed and updated or deleted.
        Map<id,AdditionalCaseFields__c> existingAdditionalCaseFields = new Map<id,AdditionalCaseFields__c>();

        // List to hold Additional Case Fields thats needs to be Upserted and deleted.
        List<AdditionalCaseFields__c> additionalCaseFieldsToUpsert = new List<AdditionalCaseFields__c>();
        List<AdditionalCaseFields__c> additionalCaseFieldsToDelete = new List<AdditionalCaseFields__c>();
        
        //Set of Case Id whose Product Group/Product family/Case record type is updated
        Set <Id> updatedCases = new Set <Id>();
        
        // Build caseProductGroupMap to find unique product per case
        for(Case newCase: mapNewCase.values()) {
            Case oldCase = new Case();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
            }
            if(oldCase.ProductFamily__c != newCase.ProductFamily__c
               || oldCase.ProductGroup__c != newCase.ProductGroup__c
               || oldCase.RecordTypeId != newCase.RecordTypeId) {
                   //Intrested only in cases, that have changes in above fields
                   updatedCases.add(newCase.Id);
               }
        }
        
        if(updatedCases != null && updatedCases.size() > 0) {
            // Map to store (Product Group Id + Case Recordtype Id) / (Product Family Id + Case Recordtype Id) as key for ACF Record Id.
            Map<String, String> actlMap = prepareACTLMap();
            
            // If the event is after update, get old additional case fields. So that they can be updated or deleted.
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                // List of Additional Case Fields thats needs to be deleted/updated 
                existingAdditionalCaseFields = new Map<Id, AdditionalCaseFields__c>([Select Id, Case__c, RecordTypeId from AdditionalCaseFields__c where Case__c in :updatedCases]);
            }
            
            for(Id caseId: updatedCases) {
                Case newCase = mapNewCase.get(caseId);
                Case oldCase = new Case();
                AdditionalCaseFields__c oldAcf = null;

                System.debug('@@@UA CaseId: ' + caseId);
                String newACFRecordTypeId = getACFRecordTypeId (newCase, actlMap);
                String oldACFRecordTypeId = '';
                //If the event is after update get old values
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldCase = mapOldCase.get(newCase.Id);
                    oldACFRecordTypeId = getACFRecordTypeId(oldCase, actlMap);
                }
                oldAcf = existingAdditionalCaseFields.get(oldCase.AdditionalFields__c);
                if(String.isBlank(newACFRecordTypeId) && String.isBlank(oldACFRecordTypeId)) {
                    //Both dont have any ACTL Records. Can ignore, there can be a scenario when
                    // case was created there was ACTL record and now it is deleted, 
                } else if (String.isBlank(newACFRecordTypeId)) {
                    // Old ACLT has a record type and new one dont have, Delete old ACF record.
                } else if (String.isBlank(oldACFRecordTypeId)) {
                    // new ACLT has a record type and old one done have, Create new ACF record. Or New case is created
                    additionalCaseFieldsToUpsert.add(
                       new AdditionalCaseFields__c(RecordTypeId = newACFRecordTypeId, 
                                                    Name = 'ACF - ' + newCase.CaseNumber, Case__c = newCase.Id));
                } else if (newACFRecordTypeId.equals(oldACFRecordTypeId)) {
                    if(oldAcf == null) { 
                        // Create Case that does not have matching ACTL.
                        // Create ACTL for above case with ACF record type as X, create another ACTL with ACF record type as X
                        // Now Change case to match second ACTL. Earlier ACF record was not getting generated.
                        // So added below condition.
                        additionalCaseFieldsToUpsert.add(
                        new AdditionalCaseFields__c(RecordTypeId = newACFRecordTypeId, 
                                                    Name = 'ACF - ' + newCase.CaseNumber, Case__c = newCase.Id));
                    }
                    //Though, PF or PG or case RT got changed, still ACF RT is same. 
                    continue;
                } else if (oldCase.ProductFamily__c == newCase.ProductFamily__c 
                           && oldCase.ProductGroup__c == newCase.ProductGroup__c) { 
                    //At this point newACFRecordTypeId!=oldACFRecordTypeId; So, not chekcing
                    //Only Case record type is changed. So, Change ACF record type and do not recreate ACF.
                    oldAcf.RecordTypeId = newACFRecordTypeId;
                    additionalCaseFieldsToUpsert.add(oldAcf);
                    continue; //If continue is not there then, ACF will be deleted.
                } else {
                    //Either Product group or Product family is changed. Recreate ACF.
                    additionalCaseFieldsToUpsert.add(
                       new AdditionalCaseFields__c(RecordTypeId = newACFRecordTypeId, 
                                                    Name = 'ACF - ' + newCase.CaseNumber, Case__c = newCase.Id));
                }
                if(oldAcf!=null) { 
                    additionalCaseFieldsToDelete.add(oldAcf);
                }
            }
            
            // upsert/delete if list has any records. First delete and then upsert
            if(additionalCaseFieldsToDelete != null && additionalCaseFieldsToDelete.size() > 0 && AdditionalCaseFields__c.sObjectType.getDescribe().isDeletable()) {
                delete additionalCaseFieldsToDelete;
            }
            if(additionalCaseFieldsToUpsert != null && additionalCaseFieldsToUpsert.size() > 0) {
                upsert additionalCaseFieldsToUpsert;
            }
        }
    }

    //-----------------------------
    // @author : Vishnu Vardhan Chowdary Andra
    // @date : 07-Feb-2018
    // @param : Cas - Case for which additional case fields object type is being figured.
    //          actlMap - Map containing key as Product families Id + CaseRecord type ID and
    //                  product group id+ case record type id's as key and their values as additional case field record type. 
    // @description : SFDC1-6382: Moving a common piece of code into a seperate method. Based on the prodcut
    //          family or product group of a case, and case record type, additional case field record type is found in the 
    //          actl map and is returned. If no match is found, then empty string is returned implying case dont have ACF.
    // @LastModifiedDate : 3rd Apr 2018
    // @LastModifiedDescription: SFDC1-7120 Vishnu Vardhan, Removing internal partner related code
    // @LastModifiedDate : 26 Jun 2018
    // @LastModifiedDescription: SFDC1-8397: When product family is not setup, then fallback on product group while selecting
    //                      ACTL record.
    // @LastModifiedBy: Vishnu  Vardhan Chowdary
    // @return : String - Id for the additional Case field record type.
    //-----------------------------
    private static String getACFRecordTypeId(Case cas, Map<String, String> actlMap) {
        String recordId = null;
        if(cas !=null && cas.ProductFamily__c != null) {
            recordId = actlMap.get(String.valueOf(cas.ProductFamily__c) + String.valueOf(cas.RecordTypeId));
        }
        if(String.isBlank(recordId) && cas !=null && cas.ProductGroup__c != null) {
            recordId = actlMap.get(String.valueOf(cas.ProductGroup__c) + String.valueOf(cas.RecordTypeId));
        }
        return recordId;
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 07 Feb 2018
    // @param: 
    // @description: SFDC1-6382 Moving ACTL object map creation into a seperate method
    // @return: Map containing key as Product families Id + CaseRecord type ID and
    //      product group id+ case record type id's as key and their values as additional case field record type
    //------------------------------
    public static Map<String, String> prepareACTLMap() {
        // Query all Additional Case Type Linking
        List<AdditionalCaseTypeLinking__c> aCaseTypeLinkings = [SELECT AdditionalCaseRecordType__c,CaseRecordType__c,ProductFamily__c,ProductGroup__c FROM AdditionalCaseTypeLinking__c];
        // Map to store (Product Group Id + Case Recordtype Id) / (Product Family Id + Case Recordtype Id) as key for Additional Case Type Linking
        Map<String, String> actlMap = new Map<String, String>();

        for(AdditionalCaseTypeLinking__c actl: aCaseTypeLinkings) {
            System.debug('@@@UA actl: ' + actl);

            if( actl.ProductFamily__c != null 
               && Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(actl.CaseRecordType__c) != null 
               && Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName().get(actl.AdditionalCaseRecordType__c) != null) {
                   actlMap.put(String.valueOf(actl.ProductFamily__c) + Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(actl.CaseRecordType__c).getRecordTypeId(), 
                               Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName().get(actl.AdditionalCaseRecordType__c).getRecordTypeId());
               }

            if( actl.ProductGroup__c != null && actl.ProductFamily__c == null 
               && Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(actl.CaseRecordType__c) != null 
               && Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName().get(actl.AdditionalCaseRecordType__c) != null) {
                   actlMap.put(String.valueOf(actl.ProductGroup__c) + Schema.Sobjecttype.Case.getRecordTypeInfosByName().get(actl.CaseRecordType__c).getRecordTypeId(), 
                               Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName().get(actl.AdditionalCaseRecordType__c).getRecordTypeId());
               }
        }
        System.debug('@@@UA actlMap: ' + actlMap);
        return actlMap;
    }

    //-----------------------------
    // @author: Paras Dhingra
    // @date: 30 June 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-441 Update Milestones when the criteria are met 
    //                
    // @return: None
    //------------------------------
    public static void updateCaseMilestones(TriggerParameters tp) {
        
        // list will contain the casemilestones to be updated
        Set<CaseMilestone> setCaseMilestoneToBeUpdated = new set<CaseMilestone>();
        
        //fetch all milestones related to case
        List<CaseMilestone> lstCaseMilestone = [Select id, CaseId, CompletionDate, MilestoneType.Name from CaseMilestone where Caseid IN:tp.newMap.keySet() and isCompleted=false];
        
        //Proceed only if associated milestones exist
        if(lstCaseMilestone!=null &&!lstCaseMilestone.isEmpty()) {
            
            //traverse all caseMilestones
            for(CaseMilestone cm : lstCaseMilestone) {
                
                Case newCase = (Case)tp.newMap.get(cm.CaseId);
                Case oldCase = (Case)tp.oldMap.get(cm.CaseId);
                
                //close all milestones in case the case is closed
                if(newCase.IsClosed) {
                    
                    cm.CompletionDate = System.now();
                    setCaseMilestoneToBeUpdated.add(cm);
                    
                    //skip the for loop iteration as milestones already got closed
                    continue;
                }
                
                //close first touch
                //update has happened
                if(cm.MilestoneType.Name== 'First Touch' && tp.tEvent==TriggerParameters.TriggerEvent.afterUpdate) {
                    
                    //in case update has happened the first touch milestone will be closed
                    cm.CompletionDate = System.now();
                    setCaseMilestoneToBeUpdated.add(cm);
                }
                
                //close assigned
                String ownerId = newCase.OwnerID;
                
                if(cm.MilestoneType.Name == 'Assignment' && 
                   (oldCase.OwnerID <> newCase.OwnerID || ownerId.startsWith('005'))) {
                       
                       cm.CompletionDate = System.now();
                       setCaseMilestoneToBeUpdated.add(cm);
                   }
                
            }
            
            //check and update the list
            if(setCaseMilestoneToBeUpdated!=null && !setCaseMilestoneToBeUpdated.isEmpty()) {
                
                List<CaseMilestone> lstUpdateCaseMilestone = new List<CaseMilestone>();
                lstUpdateCaseMilestone.addAll(setCaseMilestoneToBeUpdated);
                
                //Update the final list
                update lstUpdateCaseMilestone;
            }
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 01 June 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8381 Convert Process Builder flow "SetDefaultValuesForProductGroup" created in SFDC1-6418 to a trigger
    //  SFDC1-6418 set Product Group value depending on Case Record Type, Team Select and Customer Care Initiated values:
    //  1. If Record Type == "Order Management/Delivery Help Desk" AND Team Select == "Order Management" AND CustomerCareInitiated == FALSE, then set Produc Group value == "Order Mgmt. Helpdesk".
    //  2. If Record Type == "Order Management/Delivery Help Desk" AND Team Select == "Delivery" AND CustomerCareInitiated == FALSE, then set  Product Group value == "Delivery Helpdesk"
    //  3. If Record Type == "Order Management/Delivery Help Desk" AND Team Select == "Retail" AND CustomerCareInitiated == FALSE, then set Product Group value == "Retail Helpdesk"
    // @return: None
    //------------------------------
    public static void setCaseProductGroupForOrderManagementDeliveryHelpDesk(TriggerParameters tp) {
        
        // Map of old values and new values
        List<Case> listNewCase = tp.newList;
        Map<Id, Case> mapOldCase = (Map<Id,Case>) tp.oldMap;

        getProductGroupIds();
                
        for (Case newCase : listNewCase) {
            
            if (newCase.RecordTypeId != UtilityClass.caseRecordTypeOMDHelpDesk) {
                continue; // skip the logic below if this is not "Order Management/Delivery Help Desk" case record type
            }
            
            Case oldCase = null;
            if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
            }
            
            if (newCase.CustomerCareInitiated__c == false &&
                (oldCase == null || oldCase.TeamSelect__c != newCase.TeamSelect__c)) {

                if (newCase.TeamSelect__c == 'Order Management') {
                    newCase.ProductGroup__c = productGroupIdOrderMgmtHelpdesk;
                } else if (newCase.TeamSelect__c == 'Delivery') {
                    newCase.ProductGroup__c = productGroupIdDeliveryHelpdesk;
                } else if (newCase.TeamSelect__c == 'Retail') {
                    newCase.ProductGroup__c = productGroupIdRetailHelpdesk;
                }
            }
        }
    }
    
    // Static references to Product Group IDs
    public static Id productGroupIdOrderMgmtHelpdesk;
    public static Id productGroupIdDeliveryHelpdesk;
    public static Id productGroupIdRetailHelpdesk;
    public static Boolean productGroupIdsLoaded = false;

    public static void getProductGroupIds() {
        
        if ((productGroupIdOrderMgmtHelpdesk == null || productGroupIdDeliveryHelpdesk == null || productGroupIdRetailHelpdesk == null) 
            && productGroupIdsLoaded == false) {

            productGroupIdsLoaded = true; // prevent the method to be run multiple times when no matching product group was found 
                
            Map<String, ProductGroup__c> productGroups = new Map<String, ProductGroup__c>();
            
            // reload from database
            for (ProductGroup__c pg : [select Id, Name from ProductGroup__c where Name in ('Order Mgmt. Helpdesk', 'Delivery Helpdesk', 'Retail Helpdesk')]) {
                
                productGroups.put(pg.Name, pg);
            }
                
            ProductGroup__c pgOrderMgmtHelpdesk = productGroups.get('Order Mgmt. Helpdesk');
            if (pgOrderMgmtHelpdesk != null) {
                productGroupIdOrderMgmtHelpdesk = pgOrderMgmtHelpdesk.Id;
            }
            
            ProductGroup__c pgDeliveryHelpdesk = productGroups.get('Delivery Helpdesk');
            if (pgDeliveryHelpdesk != null) {
                productGroupIdDeliveryHelpdesk = pgDeliveryHelpdesk.Id;
            }
            
            ProductGroup__c pgRetailHelpdesk = productGroups.get('Retail Helpdesk');
            if (pgRetailHelpdesk != null) {
                productGroupIdRetailHelpdesk = pgRetailHelpdesk.Id;
            }
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 18 July 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-204 & SFDC1-965 Update Case's Account and Contact lookup 
    // for Account Governance cases when the criteria are met 
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 01 June 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8356 update logic to populate Order Management/Delivery Help Desk case's account and contact
    // 1. The Contact Name on parent Customer Care case to be mapped to the "Contact Reference" of OM/Del Heldpesk child case
    // 2. The Account Name on parent Customer Care case to be mapped to the "Account Reference" of OM/Del heldpesk child case
    // 3. The Created By on parent Customer Care case to be mapped to the "Contact Name" and its related account to be mapped to the "Account Name" of the OM/Del Heldpesk child case
    // 
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 20 August 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8977: Changing Data Governance to Account Governance.
    // @return: None
    // @LastModifiedBy: Harshit Singhal
    // @LastModifiedDate: 07 Jul 2020
    // @LastModifiedReason: SFDC-2375 - Added logic to populate ContactId and AccountId from logged-in user if already blank for 4 more case record types - Sales Operations, Sales Support, OM Delivery Helpdesk, Contract Management
    //------------------------------    
    public static void setInternalCaseAccountAndContact(TriggerParameters tp) {
        //Harshit: Skip this method for email 2 case by checking SF Admin User
        if(UserInfo.getUserId() != Label.Email2CaseUserId || Test.isRunningTest()) {            
            // Look up for a contact record with email address matching to the user's email address
            Contact userContact = UtilityClass.getContactByEmail(UserInfo.getUserEmail());
            List<Case> newList = tp.newList;
            
            for (Case c : newList) {
    
                if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
                    if (c.RecordTypeId == UtilityClass.caseRecordTypeAccountGovernance || // always run for Account Governance case type 
                        (c.CustomerCareInitiated__c == true && c.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk) || // and only if CustomerCareInitiated is true for "OM/D Help Desk" case record type
                        (c.ContactId==null && (c.RecordTypeId == UtilityClass.caseRecordTypeSalesSupport || c.RecordTypeId == UtilityClass.caseRecordTypeSalesOperations || c.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk || c.RecordTypeId == UtilityClass.caseRecordTypeContractManagement))) { 
                            c.ContactId = userContact != null ?  userContact.Id : null;
                            c.AccountId = userContact != null && userContact.AccountId != null ?  userContact.AccountId : null;
                            c.AccountName__c = (c.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk || c.RecordTypeId == UtilityClass.caseRecordTypeContractManagement) && c.Contract__c!=null ? System.Label.NewUserContactAccount : c.AccountName__c;
                            /* SFDC-2375 Errors should not come on creation, accept the case and these users should be caught from an exceptions report.
                            if(c.ContactId==null) {
                                c.addError('Please create a contact with email address matching to your email address under IHS Markit account then try again.');                                
                            }
                            if(c.AccountId == null) {
                                c.addError('The contact matching to your email address does not have an account linked to it, please update that contact\'s account to IHS Markit.');
                            }
                            */
                        }
                }
            }        
        }
    }

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 20 Sep 2018
    // @description: SFDC1-9961, adding method to create New Account Request case when a Customer Care case was created under Unknown Account
    //               (converted from Process Builder flow related to GDSA/Account Governance cases - original user story SFDC1-683)
    // @modifiedBy: Tran-Vu Tran
    // @modifiedDate: 10 Dec 2018
    // @description: SFDC1-10391 Address, Phone Number, Website, and Institution Type are required for New Account request
    // @modifiedBy: Tran-Vu Tran
    // @modifiedDate: 17 Sep 2019
    // @description: SFDC-2036 change the logic to retrieve UnknownAccountIDs from a query on Account records
    //              to the Custom Setting that holds the "Place Holder - Unknown Account" Account IDs, and move the static reference to Utility class
    // @param: TriggerParameters tp
    // @return: None
    //------------------------------
    public static void processNewAccountRequestCase(TriggerParameters tp) {
        try {
            Map<Id, Case> mapNewCase = (Map<Id, Case>) tp.newMap;
            //System.debug('tp.newMap: ' + tp.newMap);

            if (!UserInfo.getUserName().containsIgnoreCase('sfadmin')) {
                // list of Account Governance cases to insert
                List<Case> casesToInsert = new List<Case>();
                
                // list of originating leads to update
                List<Lead> leadsToUpdate = new List<Lead>();
                Set<Id> setExistingAccountGovernanceCase = new Set<ID>();
                List<Case> existingAccountGovernanceCase = new List<Case> (
                    [SELECT Id, CaseReference__c FROM Case
                     WHERE CaseReference__c!=null
                        AND CaseReference__c IN: mapNewCase.keySet()
                        AND RecordTypeId =: UtilityClass.caseRecordTypeAccountGovernance]
                );
                if(existingAccountGovernanceCase!=null) {
                    for(Case cse: existingAccountGovernanceCase) {
                        setExistingAccountGovernanceCase.add(cse.CaseReference__c);
                    }
                }
                for (Case newCase : mapNewCase.values()) {
                    if (newCase.RecordTypeId == UtilityClass.caseRecordTypeCustomerCare 
                        && (existingAccountGovernanceCase!=null && !setExistingAccountGovernanceCase.contains(newCase.Id))) {
                        if (newCase.AccountId != null 
                            && UtilityClass.UnknownAccountIDs != null && UtilityClass.UnknownAccountIDs.contains(newCase.AccountId)) {
                            // creating new Account Governance case
                            Case agCase = new Case(
                                RecordTypeId = UtilityClass.caseRecordTypeAccountGovernance,
                                CaseReference__c = newCase.Id,
                                ContactReference__c = newCase.ContactId,
                                Origin = 'Case',
                                Status = 'New',
                                Type = 'Customer Master Data',
                                SubType__c = 'New Account',
                                Subject = 'Create New Account for ' + newCase.AccountName__c,
                                AccountName__c = newCase.AccountName__c,
                                ExternalOrgType__c = newCase.ExternalOrgType__c,
                                InstitutionType__c = newCase.InstitutionType__c,
                                Website__c = newCase.Website__c,
                                PhoneNumber__c = newCase.PhoneNumber__c, 
                                Address1__c = newCase.Address1__c,
                                Address2__c = newCase.Address2__c,
                                City__c = newCase.City__c,
                                State__c = newCase.State__c,
                                Postal__c = newCase.Postal__c,
                                Country__c = newCase.Country__c,
                                Title__c = newCase.Title__c,
                                JobTitle__c = newCase.JobTitle__c,
                                JobFunction__c = newCase.JobFunction__c,
                                BusinessSegment__c = newCase.BusinessSegment__c,
                                GroupDesk__c = newCase.GroupDesk__c,
                                ContactEmail1__c = newCase.ContactEmail1__c,
                                ContactName__c = newCase.ContactName__c,
                                AccountOwnerManager__c = newCase.AccountOwnerManager__c,
                                Description = 'Create New Account for ' + newCase.AccountName__c
                            );
                            
                            //System.debug('agCase: ' + agCase);
                            
                            casesToInsert.add(agCase);
                            //System.debug('casesToInsert: ' + casesToInsert);
                        }
                    }
                    
                    if (newCase.RecordTypeId == UtilityClass.caseRecordTypeAccountGovernance && tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                        if (newCase.LeadReference__c != null) {
                            Lead leadObj = new Lead(Id = newCase.LeadReference__c, AccountRequested__c = true);
                            leadsToUpdate.add(leadObj);
                        }
                    }
                }
                
                if (casesToInsert.size() > 0) {
                    insert casesToInsert;
                }
                
                if (leadsToUpdate.size() > 0) {
                    update leadsToUpdate;
                }
            }
                    } catch (Exception e) {
                //System.debug('Exception: ' + e.getMessage());
                UtilityClass.createApexLogRecord(e,'CaseMethods','processNewAccountRequestCase');
                throw e; 
            }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 18 Sep 2018
    // @description: SFDC1-9961, method to populate related Lead/Case/Contact records upon GDSA/Account Governance Case closure
    //               (converted from Process Builder flow related to GDSA/Account Governance cases, original user stories SFDC1-965 & SFDC1-683)
    // @param: TriggerParameters tp
    // @return: None
    //------------------------------
    public static void populateRelatedLeadAndCaseAccountOnCaseClosure(TriggerParameters tp) {
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            
            try {
                // Map of old values and new values
                Map<Id, Case> mapNewCase = (Map<Id, Case>) tp.newMap;
                Map<Id, Case> mapOldCase = (Map<Id, Case>) tp.oldMap;
        
                // Set of Account Governance case IDs that were closed
                Set <Case> closedCases = new Set <Case>();
                
                // Maps to hold Lead, Case and Contact related to the closed cases
                Map<Id, Case> relatedLeadToCaseMap = new Map<Id, Case>();
                Map<Id, Case> relatedCaseToCaseMap = new Map<Id, Case>();
                Map<Id, Case> relatedContactToCaseMap = new Map<Id, Case>();
                
                for (Case newCase: mapNewCase.values()) {
    
                    Case oldCase = mapOldCase.get(newCase.Id);
                    
                    if (newCase.Subtype__c == 'New Account' && newCase.Status != oldCase.Status
                        && newCase.IsClosed && newCase.AccountCreated__c != null) {
                        closedCases.add(newCase);
                        
                        if (newCase.LeadReference__c != null) {
                            relatedLeadToCaseMap.put(newCase.LeadReference__c, newCase);
                        }
    
                        if (newCase.CaseReference__c != null) {
                            relatedCaseToCaseMap.put(newCase.CaseReference__c, newCase);
                        }
    
                        if (newCase.ContactReference__c != null) {
                            relatedContactToCaseMap.put(newCase.ContactReference__c, newCase);
                        }
                    }
                }
                
                if (closedCases.size() > 0) {
                    
                    List<Lead> leadsToUpdate = new List<Lead>();
                    if (relatedLeadToCaseMap.size() > 0) {
                        for (Id leadId: relatedLeadToCaseMap.keySet()) {
                            Case closedCase = relatedLeadToCaseMap.get(leadId);
                            if (closedCase != null) {
                                Lead leadToUpdate = new Lead(
                                    Id = leadId,
                                    Account__c = closedCase.AccountCreated__c
                                );
                                leadsToUpdate.add(leadToUpdate);
                            }
                        }
                    }
                    if (leadsToUpdate.size() > 0) {
                        update leadsToUpdate;
                    }
    
                    List<Case> casesToUpdate = new List<Case>();
                    if (relatedCaseToCaseMap.size() > 0) {
                        for (Id caseId: relatedCaseToCaseMap.keySet()) {
                            Case closedCase = relatedCaseToCaseMap.get(caseId);
                            if (closedCase != null) {
                                Case caseToUpdate = new Case(
                                    Id = caseId,
                                    AccountId = closedCase.AccountCreated__c
                                );
                                casesToUpdate.add(caseToUpdate);
                            }
                        }
                    }
                    if (casesToUpdate.size() > 0) {
                        update casesToUpdate;
                    }
                    
                    List<Contact> contactsToUpdate = new List<Contact>();
                    if (relatedContactToCaseMap.size() > 0) {
                        for (Id contactId: relatedContactToCaseMap.keySet()) {
                            Case closedCase = relatedContactToCaseMap.get(contactId);
                            if (closedCase != null) {
                                Contact contactToUpdate = new Contact(
                                    Id = contactId,
                                    AccountId = closedCase.AccountCreated__c
                                );
                                contactsToUpdate.add(contactToUpdate);
                            }
                        }
                    }
                    if (contactsToUpdate.size() > 0) {
                        update contactsToUpdate;
                    }
                }
            }
            catch (Exception e) {
                // System.debug('Exception: ' + e.getMessage());
                UtilityClass.createApexLogRecord(e,'CaseMethods','populateRelatedLeadAndCaseAccountOnCaseClosure'); 
            }            
        }
    }
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 11 Oct 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-5616 When the product family is selected in a case, the function auto populates the product group
    // @return: None
    //------------------------------
    public static void setCaseProductGroupFromProductFamily(TriggerParameters tp) {
        
        // Map to store Product Family Id per Case 
        Map<Id, Id> caseFamilyMap = new Map<Id, Id>();
        
        // Build casefamilyMap to find unique product family per case
        for(Case newCase: (list <Case>) tp.newList) {
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                
                Case oldCase = (Case) tp.oldMap.get(newCase.Id);
                
                //reset product family lookup, incase product group is changed
                if(newCase.ProductFamily__c != null 
                   && newCase.ProductFamily__c == oldCase.ProductFamily__c 
                   && newCase.ProductGroup__c != null 
                   && newCase.ProductGroup__c != oldCase.ProductGroup__c) {
                       newCase.ProductFamily__c = null;
                   }
            }
            if(newCase.ProductFamily__c != null) {
                caseFamilyMap.put(newCase.Id, newCase.ProductFamily__c);
            }
        }
        
        if(caseFamilyMap != null && caseFamilyMap.size() > 0) {
            // Query Product families realted to cases in trigger
            Map<Id, Family__c> productFamilyMap = new Map<Id, Family__c>([Select Id, Name, ProductGroup__c
                                                                          from Family__c where Id in :caseFamilyMap.values()]);
            for(Case newCase: (list <Case>) tp.newList) {
                if(caseFamilyMap.get(newCase.Id) != null & productFamilyMap.get(caseFamilyMap.get(newCase.Id)) != null) {
                    newCase.ProductGroup__c = productFamilyMap.get(caseFamilyMap.get(newCase.Id)).ProductGroup__c;
                }
            }
        }
    } 
    
    
    //-----------------------------
    // @author: Hemant Shukla
    // @date: 18 Jan 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6629, To fire the case Assignment rules which are created in Quick Actions
    // @Update author: Vishnu Vardhan Chowdary
    // @Update date: 11 Jul 2018
    // @Update description: SFDC1-6026 - Adding an additional check for email 2 case scenarion where 
    //              case assignment rules shouldn't execute.
    // @Update author: Vishnu Vardhan Chowdary
    // @Update date: 07 Aug 2018
    // @Update description: SFDC1-9677 - Changing the record type to Sales Operations.
    // @return: None
    // @Modified by: Paras Dhingra
    // @Modified Date: 06-07-2020
    // @Modified Description: Add contract management so that it will fire assignment rules for new Contract Management 
    //                      Global action SFDC-1997
    //------------------------------
    Public static void fireCaseAssignmentRule(TriggerParameters tp) {
        
        List<Case> cases = new List<Case>();
        Id salesOprtationsRTId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Sales Operations').getRecordTypeId();
        Id contractManagementId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Contract Management').getRecordTypeId();
        for(Case obj : (list <Case>) tp.newList) {
            
            //Do only when Sales Operations case are created via quick action. AssignToQueue__c field will be true only for those criteria.
            if(obj.AssignToQueue__c && (Obj.RecordTypeId == salesOprtationsRTId || Obj.RecordTypeId == contractManagementId)
              && obj.SuppliedEmail == null ) {// Dont want email 2 cases go through 
                case c = new case(Id = obj.Id);
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                c.setOptions(dmo);
                cases.add(c);
            }    
        }
        
        if(!cases.isEmpty()) {
            update cases;
        }   
    } 
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 06 Feb 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6009, To set the Contact Name same as Owner, if Contact Exists only for 'Sales Support' Recordtype, Valid for insert and Owner update only with a specified Account stored in Label.    // 
    // 
    // @modified by: Harshit Singhal
    // @date: 04 Jun 2018
    // @description: SFDC1-8551, Modified the existing method to set contact name on 'Salesforce Helpdesk' record type cases based on current/logged-in user when the case gets created from Global Quick Action 'Create Salesforce Helpdesk Case'
    // 
    // @modified by: Harshit Singhal
    // @date: 08 Jun 2018
    // @description: SFDC1-8256, Modified the existing method to set account Id on 'Sales Support' record type cases from related Contact's account
    //
    // @modified by: Vishnu Vardhan Chowdary Andra
    // @date: 07 Aug 2018
    // @description: SFDC1-9677, Record type got changed from Sales Support to Sales Operations
    //
    // @modified by: Sruti Srivastava
    // @date: 11 Sept 2018
    // @description: SFDC1-9761, Modified the existing method to set contact name on 'Salesforce Suggestion' record type cases based on current/logged-in user when the case gets created from Global Quick Action 'Create Salesforce Helpdesk Case'
    // 
    // @LastModifiedBy: Harshit Singhal
    // @LastModifiedDate: 07 Jul 2020
    // @LastModifiedReason: SFDC-2375 - For Sales Operations case record types, removed the logic(to populate ContactId and AccountId from case owner) from this method and moved setInternalCaseAccountAndContact() method to streamline code. New logic runs on logged-in user and not case owner.
    // 
    // @return: None
    //------------------------------
    public static void setContactNamefromOwner(TriggerParameters tp) {      
        Id salesforceHelpdeskRTId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Salesforce Helpdesk').getRecordTypeId();        
        Id salesforceSuggestionRTId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Salesforce - Suggestion').getRecordTypeId();        
        
        set<Id> setOwnerID = new set<ID>();     
        map<id,string> mapOwnerIdEmail= new map<id,string>();
        map<string,Contact> mapSalesforceHelpdeskAndSuggestionEmailContactObj= new map<string,Contact>();
        
        //Harshit: Skip this method for email 2 case by checking SF Admin User
        if(UserInfo.getUserId() != Label.Email2CaseUserId || Test.isRunningTest()) {            
            for(Case obj : (list <Case>) tp.newList) {                            
                //for the Insert Record, for only Salesforce Helpdesk RecordType, find contact based on logged-in user
                if(!setOwnerID.contains(UserInfo.getUserId()) && (obj.RecordTypeId == salesforceHelpdeskRTId
                || obj.RecordTypeId == salesforceSuggestionRTId) && tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert 
                && obj.Origin == 'Quick Action' && obj.ContactId == null) {                   
                    setOwnerID.add(UserInfo.getUserId());
                }            
            }
            
            //fetching the Email for the Case Owners
            if(!setOwnerID.isEmpty()) {
                for(User userobj : [select id, Email from User where id in :setOwnerID ]) {            
                    mapOwnerIdEmail.put(userobj.id,userobj.Email);
                }            
            }
            
            //fetching the ContactIds for the Case Owners'Email
            if(!mapOwnerIdEmail.isEmpty()) {
                //for(Contact Contactobj : [select id,Accountid,Account.Name, email from contact where email in : mapOwnerIdEmail.values() and Account.Name =: label.CaseAccountNameForSalesSupport]) {
                for(Contact Contactobj : [select id,Accountid,Account.Name, email from contact where email in : mapOwnerIdEmail.values()]) {                    
                    mapSalesforceHelpdeskAndSuggestionEmailContactObj.put(Contactobj.Email,Contactobj);
                }            
            }
            
            //setting up the Case's Contact if Correct Email is found        
            for(Case obj : (list <Case>) tp.newList) {                
                //Insert case for 'Salesforce Helpdesk' RecordType
                Id currentUserId = UserInfo.getUserId();
                if((obj.RecordTypeId == salesforceHelpdeskRTId || obj.RecordTypeId == salesforceSuggestionRTId) 
                    && tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert 
                && obj.Origin == 'Quick Action' && obj.ContactId == null && mapOwnerIdEmail.containskey(currentUserId)) {
                    obj.contactId = mapSalesforceHelpdeskAndSuggestionEmailContactObj.containsKey(mapOwnerIdEmail.get(currentUserId)) ? mapSalesforceHelpdeskAndSuggestionEmailContactObj.get(mapOwnerIdEmail.get(currentUserId)).Id : NULL;
                    obj.AccountId = mapSalesforceHelpdeskAndSuggestionEmailContactObj.containsKey(mapOwnerIdEmail.get(currentUserId)) ? mapSalesforceHelpdeskAndSuggestionEmailContactObj.get(mapOwnerIdEmail.get(currentUserId)).AccountId : NULL;
                }            
            }
        }
    }
       
    //------------------------------
    // @author: Vishnu Vardhan
    // @date: 13 May 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7183: Once all the implementation cases status is set to closed, then related parent contract 
    //                      record status to be set to "Delivered to Customer" and stage to 'Completed'.
    // @updatedBy: Tran-Vu Tran
    // @updatedOn: 16 May 2019
    // @updatedDescription: SFDC-1429 No longer need to move Trial & Continuation Letter Contract Stage to 11-Completed after all Implementation Cases are closed
    // @return: None
    //------------------------------
    public static void afterAllCaseClosedOnContract(TriggerParameters tp) {
        // Map of old values and new values
        Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        List<Id> contractIds = new List<Id>(); 
        Id caseImplemetationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        
        Id continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Id orderFormRecordTypeId = Schema.Sobjecttype.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            for(Case newCase: mapNewCase.values()) {
                Case oldCase = new Case();
                oldCase = mapOldCase.get(newCase.Id);
                if(newCase.isClosed 
                   && newCase.RecordTypeId == caseImplemetationRecordTypeId 
                   && newCase.Contract__c != null 
                   && newCase.Status != oldCase.Status) {
                       //Collecting the contract ids for verifying if related cases are closed.
                       contractIds.add(newCase.Contract__c); 
                   }
            }
            
            if(!contractIds.isEmpty()) {
                List<contract> contractsToUpdate = new List<contract>();
                for(Contract ctrct: [Select id, ContractStatus__c, status, recordTypeId, 
                                     (Select isClosed, recordTypeId from Cases__r where recordTypeId = :caseImplemetationRecordTypeId ) from contract where id In :contractIds]) {
                    /* SFDC-1429 No longer need to move Trial & Continuation Letter Contract Stage to 11-Completed after all Implementation Cases are closed
                     * if(ctrct.RecordTypeId == trialRecordTypeId || ctrct.RecordTypeId == continuationLetterRecordTypeId) { 
                        //Checking only for trial and continuation letter record type.
                        boolean updateStatus = true;
                        updateStatus = checkIfAllImplementationCasesAreClosed(ctrct.Cases__r,caseImplemetationRecordTypeId);                       
                        if(updateStatus) {
                            ctrct.ContractStatus__c = 'Delivered to Customer';
                            ctrct.status = 'Complete';
                            contractsToUpdate.add(ctrct);
                            
                        }
                    } */
                    if(ctrct.RecordTypeId == orderFormRecordTypeId) { 
                        //Checking only for order form record type.
                        boolean updateStatus = true;
                        updateStatus = checkIfAllImplementationCasesAreClosed(ctrct.Cases__r,caseImplemetationRecordTypeId);
                        system.debug('updateStatus @725---'+updateStatus); 
                        if(updateStatus) {
                            ctrct.SAPPGId__c = 'New';
                            contractsToUpdate.add(ctrct);
                            system.debug('contractsToUpdate---'+contractsToUpdate);
                        }
                    }
                }
                try {
                    if(!contractsToUpdate.isEmpty()) {
                        update contractsToUpdate;
                    }
                }
                catch(exception e) {
                    UtilityClass.createApexLogRecord(e, 'CaseMethods', 'afterAllCaseClosedOnContract');       
                }
            }
        }
    }

    //------------------------------
    // @author: Vishnu Vardhan
    // @date: 18 May 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7740: Once the Order Management case is set to Validated or Validated PO Pending, 
    //                      then update related Contract of Order Form status to Validated or Validated PO Pending.
    // @modified by: Vishnu Vardhan
    // @date: 14 Jun 2018
    // @description: SFDC1-8337: When case is set to Validated PO Pending, then Contract should be set to Validated PO Pending
    // @modified by: Sruti Srivastava
    // @date: 3 July 2018
    // @Description: SFDC1-8960 -Update status on Consulting Contracts, when status on OM Case changes to Validated or //"Validated PO Pending"
    // Consulting contracts
    // @lastmodified by: Vishnu Vardhan
    // @lastmodifieddate: 16 Aug 2018
    // @lastmodifieddescription: SFDC1-10182: When a case is in Scheduled Termination status, then dont update its status.
    // @Modified By : Jagadesh Kumar
    // @Modification Date: 29 OCT 2018  
    // @Modification Description:SFDC1-10129-When renewal status to 6L, both OM and implementation case should not be created together.    
    // @Modified By : Harshit Singhal
    // @Modification Date: 26 Feb 2019 
    // @Modification Description:SFDC-662: Add logic to create implementation case for order form contracts which are 'Validated' or 'Validated PO Pending'
    // @Modified By : Paras Dhingra
    // @Modification Date: 1st May 2020
    // @Modification Description:SFDC-2873: Add Validated-POD Pending with Validated PO Pending conditions
    // @Modified By : Paras Dhingra
    // @Modified Date : 13th Oct 2020
    // @Modified Description : SFDC-2723 Adding criteria to make sure Auto renewal stopped type cases not considered in the logic
    // @Modified By : Sharique Iqbal    
    // @Modified Date : 1st Feb 2021
    // @Modified Description : SFDC-2515- New Contract/OM Case Statuses
    // @Modified By : Anjali    
    // @Modified Date : 14th April 2021
    // @Modified Description : SFDC-3936- To remove New Contract/OM Case Statusesfrom creating an OM Case
    // 
    //------------------------------
    public static void updateContractWhenOMCaseIsValidated(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate ) {
            try { 
                Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
                Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
                Map<Id,String> mapContractIdAndStatus = new Map<Id,String>();
                Id caseOMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();               
                Set<Id> terminatedFilteredContractId = new  Set<Id>();          
                
                Map<Id,Id> mapOMCaseContractIdAndOMCaseOpportunityId = new Map<Id,Id>();
                Map<Id,Opportunity> mapOMCaseOpportunity = new Map<Id,Opportunity>();
                Set<Id> validatedFilteredContractId = new  Set<Id>();
                Id renewalOppRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                
                
                for(Case newCase: mapNewCase.values()) {
                    Case oldCase = new Case();
                    oldCase = mapOldCase.get(newCase.Id);
                    if(newCase.RecordTypeId == caseOMRecordTypeId
                       && newCase.Contract__c != null 
                       && newCase.Status != oldCase.Status 
                       && (newCase.Status == 'Validated' || newCase.Status == 'Validated PO Pending' || newCase.Status == 'Validated-POD Pending' || newCase.Status == 'Validated-BSI Pending' || newCase.Status == 'Validated by ConsOps')
                       && newCase.Type != 'Auto Renewal Stopped change') {
                           //Case should be OM type, status should be changed, should have contract. 
                           //new status should be 'Validated' and 'Validated PO Pending'. 
                           //Old status shouldnt be one of them.
                           mapContractIdAndStatus.put(newCase.Contract__c, newCase.Status); 
                           mapOMCaseContractIdAndOMCaseOpportunityId.put(newCase.Contract__c, newCase.Opportunity__c);
                       }
                }               
                
                if(!mapContractIdAndStatus.isEmpty()) {
                    Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                    Id consultingRecordTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();                    
                    Map<Id,Contract> mapContractsToUpdate = new Map<Id,Contract>();                    
                    for(Contract ctrct: [Select id, ContractStatus__c,RecordTypeId from contract where id In :mapContractIdAndStatus.keySet() 
                                         AND (recordTypeId = :orderFormRecordTypeId OR RecordTypeId =:consultingRecordTypeId)]) {
                                             
                        if (ctrct.ContractStatus__c != 'Scheduled Termination' && 
                            ctrct.ContractStatus__c != 'Unscheduled Termination' && 
                            ctrct.ContractStatus__c != mapContractIdAndStatus.get(ctrct.id)) {
                                //For Contract if status is Scheduled Termination or Unscheduled Termination
                                //Then dont update the status to Validated or Validated PO Pending
                                                        
                                ctrct.ContractStatus__c = mapContractIdAndStatus.get(ctrct.id);                                
                                mapContractsToUpdate.put(ctrct.Id,ctrct);
                        }
                        if(ctrct.ContractStatus__c == 'Scheduled Termination') {
                            terminatedFilteredContractId.add(ctrct.id);                
                        }
                    }
                    System.debug('Scheduled Termination contract to process for implementation case type :'+terminatedFilteredContractId);
                    if(!mapContractsToUpdate.isEmpty()) {
                        update mapContractsToUpdate.values();
                        
                        validatedFilteredContractId.addAll(mapContractsToUpdate.keySet());
                        //Get OM Opportunity Details
                        for(Opportunity omCaseOpp:[Select Id, AutoRenewal__c, DoesThisAutoRenewalHaveChanges__c, RecordType.Name From Opportunity where Id IN :mapOMCaseContractIdAndOMCaseOpportunityId.values()]){
                            mapOMCaseOpportunity.put(omCaseOpp.id, omCaseOpp);
                        }
                        //Filter out all consulting contracts & those order form contracts which belong to Auto Renewal opps with No Change
                        //Remove contracts with cases status as Validated-BSI Pending or Validated by ConsOps
                        for(Id contractId: mapContractsToUpdate.keySet()) {
                            Opportunity omCaseOppObj = mapOMCaseOpportunity.get(mapOMCaseContractIdAndOMCaseOpportunityId.get(contractId));
                            if(mapContractsToUpdate.get(contractId).RecordTypeId == consultingRecordTypeId || (omCaseOppObj != null && omCaseOppObj.RecordTypeId == renewalOppRecordTypeId && omCaseOppObj.AutoRenewal__c == true && omCaseOppObj.DoesThisAutoRenewalHaveChanges__c == false)
                              || (mapContractIdAndStatus.get(contractId)=='Validated-BSI Pending' ||mapContractIdAndStatus.get(contractId)=='Validated by ConsOps') ) {
                                validatedFilteredContractId.remove(contractId);
                            }
                        }
                    }
                    
                    //Collect contracts to be validated for creation of implementation cases
                    Set<Id> finalFilteredContractId = new Set<Id>();
                    finalFilteredContractId.addAll(terminatedFilteredContractId);
                    finalFilteredContractId.addAll(validatedFilteredContractId);
                    
                    if(finalFilteredContractId.size() > 0) {                        
                        ContractMethods.validateAndCreateImplementationCase(finalFilteredContractId);
                    }
                }
            } catch(DMLException e) {
                if(e.getMessage().contains(System.Label.CaseContactAndAccountMatchMSG)) {
                    ((List<Case>) tp.newList).get(0).addError(System.Label.CaseContactAndAccountMatchMSG);
                } else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                   ((List<Case>) tp.newList).get(0).addError(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));  
                } else {
                    ((List<Case>) tp.newList).get(0).addError(e.getMessage());
                }
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'CaseMethods','updateContractWhenOMCaseIsValidated'); 
            }
        }
    }

    //------------------------------
    // @author: Vishnu Vardhan
    // @date: 21 May 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8120: When the Order Management case is set to rejected, 
    //                      then update related Order Form Contract status to rejected.
    // @return: None
    // @LastModifiedDate : 29 Jun 2018
    // @LastModifiedDescription: SFDC1-8957 Prachi Bhasin, Adding Consulting record type
    // @LastModifiedDate : 31 Jul 2018
    // @LastModifiedDescription: SFDC1-8120 Vishnu, Removing if Condition. so that Status will be updated for both 
    //              Consulting and Order form record type
    // @Modified by: Paras Dhingra
    // @Modified date: 27/11/2020
    // @Modified Description: SFDC-2723 adding exception for Auto renewal stopped change case
    //------------------------------
    public static void updateContractWhenOMCaseIsRejected(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate ) {
            try { 
                Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
                Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
                //Set<id> contractIds = new Set<Id>();
                Map<Id,Case> mapContractIdAndRejectionReason = new Map<Id,Case>();
                
                Id caseOMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();

                for(Case newCase: mapNewCase.values()) {
                    Case oldCase = new Case();
                    oldCase = mapOldCase.get(newCase.Id);
                    if( newCase.RecordTypeId == caseOMRecordTypeId 
                       && newCase.Contract__c != null 
                       && newCase.Status != oldCase.Status 
                       && newCase.Status == 'Rejected'
                       && newCase.Type != 'Auto Renewal Stopped change') {
                           //Case should be OM type, status should be changed, should have contract. 
                           //new status should be 'Rejected'.             
                           mapContractIdAndRejectionReason.put(newCase.Contract__c,newCase);                     
                       }
                }               
                if(mapContractIdAndRejectionReason!=NULL && !mapContractIdAndRejectionReason.isEmpty()) {
                    Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                    Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                    List<Id> lstContractRecordTypeIds = new List<Id>();
                    lstContractRecordTypeIds.add(consultingRecordTypeId);
                    lstContractRecordTypeIds.add(orderFormRecordTypeId);
                    List<contract> contractsToUpdate = new List<contract>();                        
                    for(Contract ctrct: [Select id, ContractStatus__c,AdditionalRejectionInformation__c,RecordTypeId, status from contract where id In :mapContractIdAndRejectionReason.keyset() and recordTypeId IN :lstContractRecordTypeIds and ContractStatus__c != 'Rejected']) {                        
                        ctrct.ContractStatus__c = 'Rejected';
                        ctrct.ReasonforRejection__c = mapContractIdAndRejectionReason.get(ctrct.id).ReasonforRejection__c;
                        ctrct.AdditionalRejectionInformation__c= mapContractIdAndRejectionReason.get(ctrct.id).AdditionalRejectionInformation__c;
                        //Earlier this was happening in field update for OF. So didnt add it. but due to validation rule it is throwing error and had to add it.
                        //if(String.valueOf(ctrct.RecordTypeId).substring(0,15) == String.valueOf(consultingRecordTypeId).substring(0,15)) {
                        ctrct.Status = 'Creation';
                        //}
                        contractsToUpdate.add(ctrct);
                    }
                    if(!contractsToUpdate.isEmpty()) {                       
                        update contractsToUpdate;                        
                    }
                    
                }
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'CaseMethods','updateContractWhenOMCaseIsRejected'); 
            }
        }
    }
    //-----------------------------/
    // @author:Vishnu Vardhan Chowdary
    // @date: 15 MARCH 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7163: This requirement is for Implementation case with contract as order form
    //          1. If Onboarding case required is checked then create Onboarding case
    //          2. If Onboarding case required is un-checked then delete Onboarding case
    //          3. If account/contact/contract is changed in parent case, update child case.
    // @return: None
    // @lastmodifiedby : Mohit Modi
    // @lastmodifieddescription : SFDC1-9440, Added more default fields from Implementation Case to Onboarding Case
    // @lastmodifiedby : Sruti Srivastava
    // @lastmodifieddescription : SFDC1-9466, Onboarding Case Owner should be parent case owner
    //------------------------------
    public static void upsertOnboardingCaseFromImplementationCase(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate ) {
            try { 
                Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
                Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
                Set<Case> listFilteredCases = new Set<Case>();
                
                Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                Id caseImplemetationRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
                for(Case caseObj : mapNewCase.values()) {
                    Case oldCase = mapOldCase.get(caseObj.id);
                    //OnboardingCaseRequired__c is checked then create child case, if unchecked delete child case
                    //If account, Contact, Contract are changed in parent, change them in child record.
                    if(caseObj.RecordTypeId == caseImplemetationRecordId
                        && caseObj.Contract__c != null
                        && (caseObj.OnboardingCaseRequired__c != oldCase.OnboardingCaseRequired__c
                              || caseObj.AccountId != oldCase.AccountId
                              || caseObj.ContactId != oldCase.ContactId
                              || caseObj.Contract__c != oldCase.Contract__c)
                           ) {
                               listFilteredCases.add(caseObj);
                    }
                }
                if(listFilteredCases.isEmpty()) {
                    System.debug('No cases to process');
                    return;
                }
                List<Case> deleteCases = new List<Case>();
                List<Case> upsertCases = new List<Case>();
                System.debug('Cases to process '+listFilteredCases);
                Map<Id, Case> parentIdToCase = new Map<Id, Case>();
                for(Case cas : [Select id, ParentId, AccountId, Contract__c, ContactId from Case where ParentId in :listFilteredCases]) {
                    parentIdToCase.put(cas.ParentId, cas);
                }
                
                Id caseOnboardingRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
                
                for(Case caseObj : listFilteredCases) {
                    Case oldCase = mapOldCase.get(caseObj.id);
                    Case childCase = parentIdToCase.get(caseObj.Id);
                    if(childCase == null && caseObj.OnboardingCaseRequired__c) {
                        childCase = new Case();
                        childCase.RecordTypeId = caseOnboardingRecordId;
                        childCase.AccountId = caseObj.AccountId;
                        childCase.Contract__c = caseObj.Contract__c;
                        childCase.ContactId = caseObj.ContactId;
                        childCase.Status = 'New';
                        childCase.ParentId = caseObj.Id;
                        childCase.OwnerId = caseObj.OwnerId;
                        childCase.Subject = caseObj.Subject;
                        childCase.Description = caseObj.Description;
                        childCase.Type = caseObj.Type;
                        upsertCases.add(childCase);
                    } else if (childCase != null && !caseObj.OnboardingCaseRequired__c) {
                        deleteCases.add(childCase);
                    } else if (childCase != null && (
                        caseObj.AccountId != oldCase.AccountId
                        || caseObj.ContactId != oldCase.ContactId
                        || caseObj.Contract__c != oldCase.Contract__c)) {
                            childCase.AccountId = caseObj.AccountId;
                            childCase.ContactId = caseObj.ContactId;
                            childCase.Contract__c = caseObj.Contract__c;
                            upsertCases.add(childCase);
                    }
                }
                System.debug('delete child cases'+deleteCases);
                if(!deleteCases.isEmpty() && Case.sObjectType.getDescribe().isDeletable()) {
                    delete deleteCases;
                }
                System.debug('upsert child cases'+upsertCases);
                if(!upsertCases.isEmpty()) {
                    upsert upsertCases;
                }
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'CaseMethods','upsertOnboardingCaseFromImplementationCase'); 
            }
        }
    }

    //-----------------------------/
    // @author:Vishnu Vardhan Chowdary
    // @date: 21 MARCH 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7163: Verify that onboarding case required can be checked for
    //          implementation cases where contract is of order form type only.
    // @return: None
    //------------------------------
    public static void validateIfOBCaseCanCreateFromImplCase(TriggerParameters tp) {
        //SFDC1-9712 Ignore the validation rule if logged in user has IgnoreCaseValidationRules permission set
        // Mohit : Added !Test.isRunningTest() for TestClass Failure
        if(GlobalConstants.hasIgnoreValidationPermission && !Test.isRunningTest()) {
            return;
        }
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate ) {
            try { 
                Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
                Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
                Set<Case> listFilteredCases = new Set<Case>();
                
                Id caseImplemetationRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
                for(Case caseObj : mapNewCase.values()) {
                    Case oldCase = mapOldCase.get(caseObj.id);
                    System.debug('Case Obj:'+caseObj);
                    System.debug('oldCase:'+oldCase);
                    if(caseObj.RecordTypeId == caseImplemetationRecordId
                       && caseObj.Contract__c != null
                       && caseObj.OnboardingCaseRequired__c != oldCase.OnboardingCaseRequired__c
                       && caseObj.OnboardingCaseRequired__c) {
                           //only for implementation case, has contract and OnboardingCaseRequired is checked now.
                           listFilteredCases.add(caseObj);
                    }
                }
                if(listFilteredCases.isEmpty()) {
                    System.debug('No cases to process');
                    return;
                }
                Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                System.debug('Cases to verify '+listFilteredCases);
                for(Case cas : [Select id, Contract__r.RecordTypeId from Case where id in :listFilteredCases and Contract__r.RecordTypeId != :orderFormRecordTypeId]) {
                    //if(cas.Contract__r.RecordTypeId != orderFormRecordTypeId) {
                        Case caseObj = mapNewCase.get(cas.id);
                        caseObj.addError(System.Label.OnboardingCaseCreationValidationError);
                    //}
                }
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'CaseMethods','validateIfOBCaseCanCreateFromImplCase'); 
            }
        }
    }
//-----------------------------
    // @author: Prachi Bhasin
    // @date: 09 Apr 2018
    // @param: TriggerParameters
    // @description: This method assigns cases via custom assignment rules of Triage object
    // @return: None
    //------------------------------
    public static void assignCasesViaTriage(TriggerParameters tp) {
    //If the RunCustomCaseAssignmentRule label contains 'True', then this logic will run else not, only for Customer Cases
        if(System.Label.RunCustomCaseAssignmentRule.containsIgnoreCase('TRUE')) {
            Long starttime = DateTime.now().getTime();
            System.debug(' XXX Starttime: ' + starttime);
            String cpuTime = ' XXX Limits CPU Time 1: ' + Limits.getCpuTime();
            List<Case> listNewCase = (List<Case>) tp.newList;
            //The below four list of cases are created, to divide the cases coming in. They will be divided on the basis of whether
            //they are coming via email to case or they are internal
            List<Case> casesToMatchIHS = new List<Case>(); 
            List<Case> casesToMatchMSERV = new List<Case>();            
            List<Case> casesToMatchMarkit = new List<Case>();
            List<Case> casesToMatchPOLK = new List<Case>();
            
            //Id's of customer case record type and Different triage record types.
            ID CustomerCareRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
            ID IHSTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('IHS').getRecordTypeId();
            ID MSERVTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('MarkitSERV').getRecordTypeId();
            ID POLKTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('POLK').getRecordTypeId();
            
            // picking the cases for which triage assignment rules should be executed, and dividing them between 3 different queues
            // only MarkitSERV rules will be evaluated for cases in list casesToMatchMSERV
            // only IHS rules will be evaluated for cases in list casesToMatchIHS
            // only Markit rules will be evaluated for cases in list casesToMatchMarkit
            // EmailFromValue label contains value 'Email:support@markitserv' which depicts that case via email-2-case and was directed to support@markitserv.com
            // EmailFromValueMarkit label contains value 'Email:support@ihsmarkit' which depicts that case via email-2-case
            for(Case c : listNewCase) {
                //If the case is being created via email-to-case for the first time i.e. end user has sent the mail to create a case
                //and case origin is Email: support@markitserv.com then below if will execute. Standard Case assignment rule entry 1 will execute
                //in this case and then directly this method is called
                if(c.Origin == System.Label.EmailFromValue && tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
                    casesToMatchMSERV.add(c);
                    system.debug('inside if--'+TriggerParameters.TriggerEvent.beforeInsert);                
                }
                //If a case is being edited, and this case was created initially via email to case
                //and case origin is Email: support@markitserv.com then below if will execute. STandard case assignment rule entry 3 will execute,
                //which in turn will execute workflow 'RunCustomAssignmentRule' and set RunCaseAssignmentRule__c  to true.
                else if (c.Origin == System.Label.EmailFromValue && c.RunCaseAssignmentRule__c == TRUE) {
                    c.RunCaseAssignmentRule__c = FALSE;
                    casesToMatchMSERV.add(c);              
                }
                //If the case is being created via email-to-case for the first time i.e. end user has sent the mail to create a case
                //and case origin is Email: support@ihsmarkit.com then below if will execute. Standard Case assignment rule entry 2 will execute
                //in this case and then directly this method is called
                else if (c.Origin == System.Label.EmailFromValueMarkit && tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
                    casesToMatchMarkit.add(c);
                    system.debug('inside if--'+TriggerParameters.TriggerEvent.beforeInsert);                
                }
                //If a case is being edited, and this case was created initially via email to case
                //and case origin is Email: support@ihsmarkit.com then below if will execute. STandard case assignment rule entry 3 will execute,
                //which in turn will execute workflow 'RunCustomAssignmentRule' and set RunCaseAssignmentRule__c  to true.
                else if (c.Origin == System.Label.EmailFromValueMarkit && c.RunCaseAssignmentRule__c == TRUE) {
                    c.RunCaseAssignmentRule__c = FALSE;
                    casesToMatchMarkit.add(c);              
                }
                //If a case is being created or edited, and this case was created in the system directly, below else if is called
                //Standard case assignment rule entry 3 will execute,
                //which in turn will execute workflow 'RunCustomAssignmentRule' and set RunCaseAssignmentRule__c  to true.
                else if (c.Origin != System.Label.EmailFromValue && c.RunCaseAssignmentRule__c == TRUE &&  String.valueOf(c.RecordTypeId).substring(0,15) == String.valueOf(CustomerCareRecordTypeId).substring(0,15)) {
                    //Cases to be matched for IHS and POLK record type are processed here, this is because both of them have no differentiator.
                    c.RunCaseAssignmentRule__c = FALSE;
                    casesToMatchIHS.add(c);              
                }
            }
            //If at all we have any cases to be assigned the below code is executed
            if((casesToMatchIHS!= NULL && casesToMatchIHS.size()>0) || (casesToMatchMSERV!= NULL && casesToMatchMSERV.size()>0) || (casesToMatchMarkit!= NULL && casesToMatchMarkit.size()>0)) {
                try {
                    //Changes made here : converted to a static query to get all triage records : starts changes to global class se pick kare
                    List<TriageCriteria__c> lstAllTriageRecords = new List<TriageCriteria__c>();
                    lstAllTriageRecords = caseMethodHelperForQueries.allTriageList;
                    //Changes made here : converted to a static query to get all triage records : ends
                                       
                    List<TriageCriteria__c> lstMSERVTriage = new List<TriageCriteria__c>();
                    List<TriageCriteria__c> lstIHSTriage = new List<TriageCriteria__c>();
                    List<TriageCriteria__c> lstMarkitTriage = new List<TriageCriteria__c>();
                    
                    List<String> lstNameOfAllQueues = new List<String>();
                    //Adding FM | MSERV and FM | Customer Care queue by default
                    lstNameOfAllQueues.add(System.Label.MSERVTriageDefaultQueue);
                    lstNameOfAllQueues.add(System.Label.IHSTriageDefaultQueue);
                    
                    // Make different data sets for IHS,Markit and MSERV triage records by categroizing them on basis of Triage record type\
                    //After getting all the triage records we are checking their rec type, below code will execute
                    //lstIHSTriage will contain only triage records where record type is IHS or POLK
                    //lstMarkitTriage will contain only triage records where record type is Markit
                    //lstMSERVTriage will contain only triage records where record type is MarkitSERV
                    for(TriageCriteria__c trc :lstAllTriageRecords) {
                        //store the value of queue from all triage records in below list
                        lstNameOfAllQueues.add(trc.Queue__c);
                        
                        if(String.valueOf(trc.RecordTypeId).substring(0,15) == String.valueOf(IHSTriageRecordTypeId).substring(0,15) ||
                           String.valueOf(trc.RecordTypeId).substring(0,15) == String.valueOf(POLKTriageRecordTypeId).substring(0,15)) {
                            lstIHSTriage.add(trc);
                        }
                        else if (String.valueOf(trc.RecordTypeId).substring(0,15) == String.valueOf(MSERVTriageRecordTypeId).substring(0,15)) {
                            lstMSERVTriage.add(trc);
                        }
                        else {
                            lstMarkitTriage.add(trc);
                        }
                    }
                    //Since we only have queue names from picklist but for owner assignment of case we need queue id. Hence we query
                    //that and put that in map 'mapOfAllQueues'
                    List<Group> lstAllQueues = new List<Group>([Select Id,name,DeveloperNAME From Group where Type = 'Queue' and ( name in :lstNameOfAllQueues OR DeveloperNAME  in :lstNameOfAllQueues)]);
                    Map<String, Id> mapOfAllQueues = new Map<String, Id>();
                    for(Group grp: lstAllQueues) {
                        if(grp.Name.contains('/')) {
                            mapOfAllQueues.put((grp.DeveloperNAME), grp.Id);
                            }
                        else {
                            mapOfAllQueues.put((grp.NAME), grp.Id); 
                            }                                                 
                    }
                    //here we call other methods namely 'assignMarkitSERVCasesViaTriage' and 'assignIHSCasesViaTriage'
                    System.debug(' mapOfAllQueues: ' + mapOfAllQueues.keyset());
                    if(casesToMatchIHS!= NULL && casesToMatchIHS.size()>0) {
                        assignIHSCasesViaTriage(mapOfAllQueues,casesToMatchIHS,lstIHSTriage);
                    }
                    if(casesToMatchMSERV!= NULL && casesToMatchMSERV.size()>0) {
                        assignMarkitSERVCasesViaTriage(mapOfAllQueues,casesToMatchMSERV,lstMSERVTriage,System.Label.MSERVTriageDefaultQueue);
                    }
                    if(casesToMatchMarkit!= NULL && casesToMatchMarkit.size()>0) {
                        assignMarkitSERVCasesViaTriage(mapOfAllQueues,casesToMatchMarkit,lstMarkitTriage,System.Label.IHSTriageDefaultQueue);
                    }
                    cpuTime += ' CPU Time 1e: ' + Limits.getCpuTime();
                    System.debug(' XXX Endtime: ' + DateTime.now().getTime());
                    Long totalTime = DateTime.now().getTime() - starttime;
                    System.debug(' XXX Total time (ms): ' + totalTime);
                    System.debug(cpuTime);              
                }
                catch(Exception e) {
                    System.debug('Error at line 1105, method assignCasesViaTriage, class CaseMethods');
                    ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='CaseMethods',ErrorDescription__c=e.getMessage(),FunctionName__c='assignCasesViaTriage');
                    insert apexLogRecord;   
                }          
            }  
        }           
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 09 Apr 2018
    // @param: TriggerParameters
    // @description: This method assigns cases via custom assignment rules of Triage object
    // @return: None
    // @LastModifiedBy: Prachi Bhasin
    // @LastModifiedSprint: Sprint 30
    // @LastModifiedReason: SFDC1-9206 Update default queue to be 'FM | Customer Care' rather than 'To Be Assigned'
    // @LastModifiedBy: Vishnu Vardhan Chowdary Andra
    // @LastModifiedDate: 12-Oct-2018
    // @LastModifiedReason: SFDC1-10055 'To Be Assigned', should not be part of previous or current queue fields.
    // @LastModifiedBy: Mohit Modi
    // @LastModifiedDate: 25-Oct-2018
    // @LastModifiedReason: SFDC1-10055 : Adding Current Queue if No Triage Record is Matched.
    //------------------------------
    public static void assignIHSCasesViaTriage( Map<String, Id> mapOfAllQueues,List<Case> casesToMatchIHS,List<TriageCriteria__c> lstIHSTriage) {
        System.debug(' lstIHSTriage: ' +lstIHSTriage);
        Id defaultQueueId = mapOfAllQueues.get(System.Label.IHSTriageDefaultQueue);
        for(Case csObj: casesToMatchIHS) {
            csObj.OwnerId = defaultQueueId;
            csObj.CurrentQueue__c = System.Label.IHSTriageDefaultQueue;
            Boolean breakMe = false;
            for(TriageCriteria__c trcMatched: lstIHSTriage) { 
                if((trcMatched.Subtype__c==NULL || (trcMatched.Subtype__c==csObj.Subtype__c))
                        && (trcMatched.ProductFamily__c==NULL ||  (trcMatched.ProductFamily__c==csObj.ProductFamily__c))
                        && (trcMatched.Subject__c==NULL ||  ((csObj.Subject).containsIgnoreCase(trcMatched.Subject__c)))
                        && (trcMatched.Type__c==NULL ||  (trcMatched.Type__c==csObj.Type))
                        && (trcMatched.SkillLevel__c==NULL ||  (trcMatched.SkillLevel__c==csObj.SkillLevel__c))
                        && (trcMatched.ProductGroup__c==NULL ||  (trcMatched.ProductGroup__c==csObj.ProductGroup__c))) {
                    System.debug(' trcMatched ' +trcMatched);     
                    csObj.OwnerId = mapOfAllQueues.get(trcMatched.Queue__c);
                    csObj.CurrentQueue__c = trcMatched.Queue__c;
                    System.debug(' csObj.OwnerId ' +csObj.OwnerId ); 
                    breakme = true;
                }
                if(breakme)
                    break;
            }
        }
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 09 Apr 2018
    // @param: TriggerParameters
    // @description: This method assigns cases via custom assignment rules of Triage object
    // @return: None
    // @LastModifiedBy: Vishnu Vardhan Chowdary Andra
    // @LastModifiedDate: 12-Oct-2018
    // @LastModifiedReason: SFDC1-10055 'To Be Assigned', should not be part of previous or current queue fields. 
    // @LastModifiedBy: Mohit Modi
    // @LastModifiedDate: 25-Oct-2018
    // @LastModifiedReason: SFDC1-10055 : Adding Current Queue if No Triage Record is Matched.
    //------------------------------
    public static void assignMarkitSERVCasesViaTriage(Map<String, Id> mapOfAllQueues,List<Case> casesToMatchMSERV,List<TriageCriteria__c> lstMSERVTriage,String defaultQueue) {
        for(Case csObj: casesToMatchMSERV) {
            csObj.OwnerId = mapOfAllQueues.get(defaultQueue);
            csObj.CurrentQueue__c = defaultQueue;
            Boolean breakMe = false;
            for(TriageCriteria__c trcMatched: lstMSERVTriage) {             
                if((trcMatched.Subtype__c==NULL || (trcMatched.Subtype__c==csObj.Subtype__c))
                        && (trcMatched.ProductFamily__c==NULL ||  (trcMatched.ProductFamily__c==csObj.ProductFamily__c))
                        && (trcMatched.Subject__c==NULL ||  ((csObj.Subject).containsIgnoreCase(trcMatched.Subject__c)))
                        && (trcMatched.Type__c==NULL ||  (trcMatched.Type__c==csObj.Type))
                        && (trcMatched.SkillLevel__c==NULL ||  (trcMatched.SkillLevel__c==csObj.SkillLevel__c))
                        && (trcMatched.ProductGroup__c==NULL ||  (trcMatched.ProductGroup__c==csObj.ProductGroup__c))) {
                    csObj.OwnerId = mapOfAllQueues.get(trcMatched.Queue__c);
                    csObj.CurrentQueue__c = trcMatched.Queue__c;
                    break;
                }
            }           
        }
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 May 2018
    // @param: list of cases, Id of 'Implementation' case record type
    // @description: This method checks if all the implementation cases related to a contract are closed or not
    // @return: Boolean
    //------------------------------
    public static boolean checkIfAllImplementationCasesAreClosed(List<case> lstCase, Id caseRecordTypeId) {
        Boolean updateStatus =true;
        for(Case cas : lstCase) {
            if(cas.RecordTypeId == caseRecordTypeId 
                && !cas.isClosed) { //Will the current one will be updated to DB by now or should get case from map and check
                updateStatus = false;
                break;
                }
        }
        system.debug('updateStatus @1031---'+updateStatus);    
        return updateStatus;
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 30 May 2018
    // @param: list of cases, Id of 'Sales Support' case record type
    // @description: SFDC1-8014 This method is used to populate the Case lookup fields
    // @LastModifieddate : 18 July 2018
    // @LastModifieby : Mohit Modi
    // @LastModifieddescription : SFDC1-9031-Commenting this Method as field ContractOwner__c and OpportunityOwner__c is nomore required.
    //------------------------------
    /*
    public static void populateCaseLookUpFields(TriggerParameters tp) {
        Id recordtypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Sales Support').getRecordTypeId();
        Set<Id> opptyIdSet = new Set<Id>();
        Set<Id> contractIdSet = new Set<Id>();
        Map<String,Id> emailContactIdMap= new Map<String,Id>();
        Map<Id,String> ownerEmailMap = new Map<Id,String>();
        if(tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
            for (Case c : (List<Case>)tp.newList) {
                if(c.RecordTypeId == recordtypeId && c.Opportunity__c != null && c.OpportunityOwner__c == null) {
                    opptyIdSet.add(c.Opportunity__c);
                }
                if(c.RecordTypeId == recordtypeId && c.Contract__c != null && c.ContractOwner__c == null) {
                    contractIdSet.add(c.Contract__c);
                }
            }
            if(opptyIdSet.size() > 0) {
                for(Opportunity oppty : [SELECT OwnerId,Owner.Email FROM Opportunity WHERE ID IN : opptyIdSet]) {
                    ownerEmailMap.put(oppty.Id, oppty.Owner.Email);
                }
            }
            if(contractIdSet.size() > 0) {
                for(Contract con : [SELECT OwnerId,Owner.Email FROM Contract WHERE ID IN : contractIdSet]) {
                    ownerEmailMap.put(con.Id, con.Owner.Email);                    
                }
            }
            if(ownerEmailMap.size() > 0) {
                for(Contact con : [select Id,email from contact where email in : ownerEmailMap.values()]) {
                    emailContactIdMap.put(con.Email,con.Id);
                }
                //Update the Opportunity owner and Contract Owner
                for (Case c : (List<Case>)tp.newList) {
                    if(c.RecordTypeId == recordtypeId && c.Opportunity__c != null && c.OpportunityOwner__c == null) {
                        c.OpportunityOwner__c = emailContactIdMap.get(ownerEmailMap.get(c.Opportunity__c));
                    }
                    if(c.RecordTypeId == recordtypeId && c.Contract__c != null && c.ContractOwner__c == null) {
                        c.ContractOwner__c = emailContactIdMap.get(ownerEmailMap.get(c.Contract__c));
                    }
                }
            }
        }
    }
    */
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 03 July 2018
    // @param: list of cases, 'Implementation' case record type
    // @description: SFDC1-9020 This method is used to validate the Case Account and Case->Contact->Account/Case->Contact->Related Accounts 
    // @LastModifiedBy: Mohit Modi
    // @LastModifiedDate: 01 Aug 2018
    // @LastModifiedReason: SFDC1-9595- Adding Onboarding Case for the Validation with Implementation Case, and updated ContactAndAccountShouldMatch to exclude Onboarding Case.
    //------------------------------
    /**
     * SFDC1-10754: As per Comments from Debbie, removing Implementation case from validating contact with related account.
     * As per Description from Alia, Onboarding should also not have this validation. And Account has to be auto populated. 
     * If user changes the account to a different, it is still fine. 
     * public static void validateCaseContactAndAccountMatch(TriggerParameters tp) {
        // SFDC1-9712 Ignore the validation rule if logged in user has IgnoreCaseValidationRules permission set
        // Mohit : Added !Test.isRunningTest() for TestClass Failure
        if(GlobalConstants.hasIgnoreValidationPermission && !Test.isRunningTest()) {
            return;
        }
        if(!GlobalConstants.hasImplementationCaseValidated) {
            
            Set<Id> accts = new Set<Id>();
            Map<Id,String> acctTypeMap = new Map<Id,String>();
            Id implementationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
            Id onboardingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
            if(tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
                for(Case c : (List<Case>)tp.newList) {
                    if(c.RecordTypeId == implementationRecordTypeId || c.RecordTypeId == onboardingRecordTypeId ) {
                        accts.add(c.AccountId);
                    }
                }
                if(accts.size() > 0) {
                    for(Account acc : [SELECT Id,Type FROM Account where Id IN : accts]) {
                        acctTypeMap.put(acc.Id , acc.Type);
                    }
                }
                try {
                    validateCaseContactAndAccount((List<Case>)tp.newList,acctTypeMap);  
                } Catch(DMLException e) {
                    System.debug('Exception:Validation failed while inserting Implementation Case Records, class CaseMethods');
                    ((List<Case>)tp.newList).get(0).addError(e.getMessage());
                }
            }
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 03 July 2018
    // @param: list of cases, 'Implementation' case record type
    // @description: SFDC1-9020 This method is used to validate the Case Account and Case->Contact->Account/Case->Contact->Related Accounts 
    //               This method will be called in ContractMethods once OrderManagement Case set Status 'Validated/'
    // 
    // @LastModifiedBy: Sruti Srivastava
    // @LastModifiedDate: 20 July 2018
    // @LastModifiedSprint: Sprint 30
    // @LastModifiedReason: SFDC1-9309- bypassing validation if parent case is an Order Management case
    // @LastModifiedBy: Mohit Modi
    // @LastModifiedDate: 01 Aug 2018
    // @LastModifiedReason: SFDC1-9595- Adding Onboarding Case for the Validation with Implementation Case, and updated ContactAndAccountShouldMatch to exclude Onboarding Case.
    //------------------------------
    public static void validateCaseContactAndAccount(List<Case> implementationCaseList,Map<Id,String> acctTypeMap) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> parentCaseIds = new Set<Id>();
        Id implementationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id caseOMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Id onboardingRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();

        for(Case c : implementationCaseList) {
            if((c.RecordTypeId == implementationRecordTypeId || c.RecordTypeId == onboardingRecordTypeId ) && c.ContactId != null && c.AccountId != null) {
                contactIds.add(c.ContactId);
            }
            if(c.ParentId != null) {
                parentCaseIds.add(c.ParentId);
            }
        }
        Map<Id, Case> mapOMCases = new Map<Id, Case>();
        if(!parentCaseIds.isEmpty()) {
            mapOMCases.putAll([Select Id, RecordTypeId From Case where ID IN: parentCaseIds AND RecordTypeId =: caseOMRecordTypeId]);
        }
        
        if(contactIds.size() > 0) {
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id,AccountId, 
                                                                     (SELECT Id,AccountId,Account.Name FROM AccountContactRelations) 
                                                                     FROM Contact WHERE Id in :contactIds]);
            for(Case c : implementationCaseList) {
                Boolean acctConMatch = false;
                //bypassing validation if parent case is an Order Management case
                if(c.ContactId != null && c.AccountId != null && contactMap.get(c.ContactId) != null && 
                                    ( c.RecordTypeId == implementationRecordTypeId || c.RecordTypeId == onboardingRecordTypeId )
                                    && (c.ParentId == null ||
                                    (c.ParentId != null && (mapOMCases == null || 
                                                            (mapOMCases != null &&  !mapOMCases.containsKey(c.ParentId)))))) {
                    Contact con = contactMap.get(c.ContactId);
                    if(c.AccountId == con.AccountId) {
                        System.debug('*** case Account and Contact Account match found ***');
                        acctConMatch = true;
                    } else {//Check for Related accounts
                        List<AccountContactRelation> actConRel = con.AccountContactRelations;
                        for(AccountContactRelation rel : actConRel) {
                            if(c.AccountId == rel.AccountId) {
                                System.debug('*** case Account and Contact Related Account match found ***');
                                acctConMatch = true;    
                            }
                        }
                    }
                    if(!acctConMatch && acctTypeMap.get(c.AccountId) != 'Place Holder - Unknown Account' && acctTypeMap.get(c.AccountId) != 'Place Holder - General Service Account') { //No matches found then don't create Implementation case type.
                        System.debug('Exception:Validation failed for inserting Implementation Case Records, class CaseMethods');
                        //Throw the exception to rollback the transaction in both case and Contract records and show the validation message.
                        throw new DMLException(System.Label.CaseContactAndAccountMatchMSG);
                    }
                }
            }
        }
    }*/
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 12 July 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8945 Populating fields on OM/Delivery Helpdesk case when created from order form
    // @LastModifiedBy:Prachi Bhasin
    // @LastModifiedDate: 31 Aug 2018
    // @LastModifiedSprint: Sprint 33
    // @LastModifiedReason: SFDC1-9021- Populating fields on Contract Management case when created from order form
    // @LastModifiedBy:Paras Dhingra
    // @LastModifiedDate: 25-Jan-2018
    // @LastModifiedSprint: Hotfix
    // @LastModifiedReason: SFDC1-10994- If contractId is null (in case of email-to-case) or if contactId is already populated then this method will not do anything
    // @LastModifiedBy: Harshit Singhal
    // @LastModifiedDate: 07 Jul 2020
    // @LastModifiedReason: SFDC-2375 - For OMDHD and CM case record types, logic to populate ContactId and AccountId was moved to setInternalCaseAccountAndContact() method to streamline code
    //------------------------------
    public static void populateOMDeliveryHelpDeskCaseFields(TriggerParameters tp) {
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId();
        Id recTypeContractManagementId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Management').getRecordTypeId();        

        List<Id> contractIds = new List<Id>();
        if(tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
            for (Case c : (List<Case>)tp.newList) {
                //adding a check so that nulls are not added to the list
                if(c.Contract__c!=null) {   
                    if(String.valueOf(c.RecordTypeId).substring(0,15) == String.valueOf(recTypeId).substring(0,15) ||
                        String.valueOf(c.RecordTypeId).substring(0,15) == String.valueOf(recTypeContractManagementId ).substring(0,15)) {
                        contractIds.add(c.Contract__c);
                    }   
                }
                                
            }
            if(contractIds!=NULL && contractIds.size()>0) {
                List<ContractContactRole> lstPrimaryContacts = new List<ContractContactRole>([Select id,contactid,ContractId  from ContractContactRole where ContractId IN : contractIds AND isprimary =:true]);
                Map<Id,Id> mapContractIdPrimaryContactId = new Map<Id,Id>();
                for(ContractContactRole contactRole:lstPrimaryContacts) {
                    mapContractIdPrimaryContactId.put(contactRole.ContractId,contactRole.contactid);            
                }                
                for (Case c : (List<Case>)tp.newList) {           
                    if(c.RecordTypeId == recTypeId || c.RecordTypeId == recTypeContractManagementId ) {                        
                        if(mapContractIdPrimaryContactId.containsKey(c.Contract__c)) {
                            c.ContactReference__c = mapContractIdPrimaryContactId.get(c.Contract__c);
                        }
                    }
                }
            }
        }
    }

    //-----------------------------/
    // @author:Vishnu Vardhan Chowdary
    // @date: 23 August 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9441: When Onboarding cases are created from Implementation cases then 
    //          copy Case Products, Case Opportunitites and Case Contracts from parent to child case.
    //          If there is any change in the parent related lists, after the child case is created, 
    //          then all those changes can be ignored. 
    // @return: None
    //------------------------------
    public static void createRelatedListForOnboardingCase(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ) {
            try {
                Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
                //Get related list from parent Cases and 
                //add them to child Cases.
                Map<Id,Id> parentChildMaps = new Map<Id,Id>();//<ParentId, ChildId>
                Id caseOnboardingRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
                for(Case caseObj : mapNewCase.values()) {
                    if(caseObj.RecordTypeId == caseOnboardingRecordId
                       && caseObj.ParentId != null) {
                           parentChildMaps.put(caseObj.ParentId, caseObj.Id);
                    }
                }
                if(parentChildMaps.isEmpty()) {
                    System.debug('No cases to process');
                    return;
                }

                List<CaseOpportunities__c> caseOpportunityLists = new List<CaseOpportunities__c>();
                List<CaseProducts__c>  caseProductLists= new List<CaseProducts__c>();
                List<CaseContracts__c> caseContractLists = new List<CaseContracts__c>();
                Map<Id, Case> parentIdToCase = new Map<Id, Case>();
                Id caseImplementationRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();

                for(Case cas : [Select id, (Select Contract__c from CaseContracts__r),
                                (Select Product__C, ProductFamily__c, productGroup__c from CaseProducts__r),
                                (Select Opportunity__c from CaseOpportunities__r) from Case 
                                where Id in :parentChildMaps.keySet() and recordTypeId = :caseImplementationRecordId]) {
                    Id ChildId = parentChildMaps.get(cas.Id);
                    for(CaseContracts__c caseContract : cas.CaseContracts__r) {
                        caseContractLists.add(new CaseContracts__c(
                            Case__c = ChildId, Contract__c = caseContract.Contract__c));
                    }
                    for(CaseOpportunities__c caseOpportunity : cas.CaseOpportunities__r) {
                        caseOpportunityLists.add(new CaseOpportunities__c(
                            Case__c = ChildId, Opportunity__c = caseOpportunity.Opportunity__c));
                    }
                    for(CaseProducts__c caseProduct : cas.CaseProducts__r) {
                        caseProductLists.add(new CaseProducts__c(
                            Case__c = ChildId, productGroup__c = caseProduct.productGroup__c,
                            ProductFamily__c = caseProduct.ProductFamily__c, Product__C = caseProduct.Product__C));
                    }
                }

                if(!caseOpportunityLists.isEmpty()) {
                    System.debug('caseOpportunitys that will be created ->'+caseOpportunityLists);
                    insert caseOpportunityLists;
                }
                if(!caseContractLists.isEmpty()) {
                    System.debug('caseContracts that will be created ->'+caseContractLists);
                    insert caseContractLists;
                }
                if(!caseProductLists.isEmpty()) {
                    System.debug('caseProducts that will be created ->'+caseProductLists);
                    insert caseProductLists;
                }
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'CaseMethods','createRelatedListForOnboardingCase'); 
            }
        }
    }

    //-----------------------------
    // @author: Vishnu vardhan chowdary andra
    // @date: 16 August 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8534 Converting PB to trigger. For Customer care and salesforce helpdesk
    //          record type update the entitlement id. Original Story SFDc1-441
    //------------------------------
    public static void setEntitlements(TriggerParameters tp) {
        Set<String> caseClosedStatuses = UtilityClass.getCaseClosedStatuses();
        Id cutomerCareRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id salesforceHelpdeskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Salesforce Helpdesk').getRecordTypeId();
        Id eaID = EntitlementAssignment__c.getOrgDefaults().EntitlementId__c;
        if(tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
            for (Case c : (List<Case>)tp.newList) {
                if(!caseClosedStatuses.contains(c.Status) && (c.RecordTypeId == cutomerCareRecordTypeId || c.RecordTypeId == salesforceHelpdeskRecordTypeId)) {
                    c.EntitlementId = eaID;
                }
            }
        }
    }

    //-----------------------------
    // @author: Vishnu vardhan chowdary andra
    // @date: 24 August 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8534 Converting PB to trigger. Create an event when time spent minutes 
    //          is populated or modified in a case. Original Story SFDC1-6039
    // @LastModifiedDate : 31 Oct 2018
    // @LastModifiedDescription: SFDC1-10172: Time spent minutes will be part of BAU event type.
    //      Only that event has to be updated or created. If there exists a non bau event dont update
    //      instead create a new one. 
    // @LastModifiedBy: Vishnu  Vardhan Chowdary
    // @LastModifiedBy: Priyanka Vyas
    // @LastModifiedDate: 27th August 2020
    // @LastModifiedDescription: SFDC-3338 The record type of the time tracking events should be 'Time Tracking' only
    //------------------------------
    public static void createTimeTrackingEventForCase(TriggerParameters tp) {
        Id timeTrackingRecordTypeId = Schema.Sobjecttype.Event.getRecordTypeInfosByName().get('Time Tracking').getRecordTypeId();
        Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        Set<Id> caseIds = new Set<Id>(); 
        for(Case newCase: mapNewCase.values()) {
            Case oldCase = new Case();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
            }
            if(newCase.TimeSpentMinutes__c != oldCase.TimeSpentMinutes__c ) {
                caseIds.add(newCase.Id);
            }
        }
        if(caseIds.isEmpty()) {
            return;
        }
        List<Event> events = new List<Event>();
        //Updating existing BAU events
        for(Event eve: [select id, TimeSpentMinutes__c, WhatId from Event where WhatId in :caseIds and Type = 'BAU']) {
            Case cas = mapNewCase.get(eve.WhatId);
            eve.TimeSpentMinutes__c = cas.TimeSpentMinutes__c;
            events.add(eve);
            caseIds.remove(cas.Id);
        }
        //Creating new events for left over cases
        for(Id caseId : caseIds) {
            Case cas = mapNewCase.get(caseId);
            Event eve = new Event();
            eve.DurationInMinutes = 0;
            eve.StartDateTime = System.now()+(1/24/60);
            eve.TimeSpentMinutes__c = Cas.TimeSpentMinutes__c;
            eve.Type = 'BAU';
            eve.RecordTypeId=timeTrackingRecordTypeId;
            eve.WhatId = caseId;//Related To ID
            events.add(eve);
        }
        if(!events.isEmpty()) {
            upsert events;
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 06 Sep 2018
    // @param: None
    // @description: SFDC1-9035 OM/Delivery Help Desk 'OMD Status' to 'Status' field mapping
    //------------------------------
    public static void setCaseStatusFromOMDStatusForOMDCaseType(TriggerParameters tp) {
        try {
            Id caseOMDRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId();
            if(tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent==TriggerParameters.TriggerEvent.beforeUpdate) {
                for (Case c : (List<Case>)tp.newList) {
                    if(c.Status != 'Merged' && c.RecordTypeId == caseOMDRecordTypeId && String.isNotBlank(c.OMDStatus__c) && String.isNotBlank(UtilityClass.caseOMDStatusMap.get(c.OMDStatus__c))) {
                    c.Status = UtilityClass.caseOMDStatusMap.get(c.OMDStatus__c);
                    }
                }
            }
        } catch(Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseMethods','setCaseStatusFromOMDStatusForOMDCaseType'); 
        }
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 24 August 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9962 Converting PB checkInternalUserforCaseSurvey to trigger. 
    //          If ContactEmail contains @IHSMarkit.com and contactValidation__c is true, and 
    //          owner is not a delete or duplicate queue. Then update 'Do Not Survey Reason' to 'Internal Contact' 
    //          and Do Not Survey to true.
    //          If contactEmail dont have @IHSMarkit.com and Case.Owner is not a group then 
    //          update Contact Validation to false, Do Not Survey Reason to null/empty and Do Not Survey to false.
    //          is populated or modified in a case. Original Story SFDC1-1352
    // @Modified by: Priyanka Vyas
    // @date: 24 August 2020
    // @description: SFDC-2648: Uncheck ContactValidation__c on Customer Care case type if Case Account is not an internal account
    //------------------------------
    public static void checkInternalUserforCaseSurvey(TriggerParameters tp) {
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id customerExpRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Experience').getRecordTypeId();

        for(Case newCase: (list <Case>) tp.newList) {
            Case oldCase = new Case();
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
            }
            String ownerId = newCase.OwnerId;

            //contactValidation__c, ContactEmail, Ownerid is changed and 
            //contactValidation__c is True, ContactEmail @ihsmarkit.com and 
            //OwnerId is not equal to delete and duplicate group. 
            if((oldCase.contactValidation__c != newCase.contactValidation__c || 
               oldCase.ContactEmail__c != newCase.ContactEmail__c ||
               oldCase.OwnerId != ownerId) && 
               (newCase.contactValidation__c && String.isNotBlank(newCase.ContactEmail__c) && 
               newCase.ContactEmail__c.endsWithIgnoreCase('@ihsmarkit.com') && 
               ownerId != System.Label.DuplicateQueueID && 
               ownerId != System.Label.DeleteQueueID)) {
                   newCase.DoNotSurveyReason__c = 'Internal Contact';
                   newCase.DoNotSurvey__c = true;
            } else if((oldCase.ContactEmail__c != newCase.ContactEmail__c ||
               oldCase.OwnerId != ownerId) && 
               (String.isNotBlank(newCase.ContactEmail__c) && 
               !newCase.ContactEmail__c.endsWithIgnoreCase('@ihsmarkit.com') && 
               String.isNotBlank(ownerId) && 
               !ownerId.startsWithIgnoreCase('00G'))) {
                   //OwnerId or contactEmail changed and contactemail dont end with @ihsmarkit.com
                   //OwnerId is not group then change below fields.
                   newCase.DoNotSurveyReason__c = Null;
                   newCase.DoNotSurvey__c = false;
                   if(newCase.RecordTypeId!=customerCaseRecordTypeId || newCase.RecordTypeId != customerExpRecordTypeId){
                        newCase.contactValidation__c = false;
                   }
            }
            if((newCase.RecordTypeId == customerCaseRecordTypeId && newCase.RecordTypeId == customerExpRecordTypeId) && newCase.AccountId!=null && newCase.ContactValidation__c==true) {
                if((oldCase.ContactEmail__c != newCase.ContactEmail__c || oldCase.accountid != newCase.accountid ||
                       oldCase.OwnerId != ownerId) && 
                       (String.isNotBlank(newCase.ContactEmail__c) && 
                        !(UtilityClass.InternalAccountIds).contains(newCase.AccountId) &&
                        String.isNotBlank(ownerId) && 
                        !ownerId.startsWithIgnoreCase('00G'))){
                            newCase.ContactValidation__c=false;
                }
            }
        }
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 18 September 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9960 Converting PB Duplicate and Delete Case Case Owner Change to triggers. 
    //          When a case is created or updated and staus is set to delete and do not survey is true and
    //          Resolution description is set to 'Delete Case'  and do not survey reason is set to 'Delete Case'
    //          then Change queue owner to 'Delete Queue'. Same for Duplicate Case. or 
    //          When a case owner is set to delete or duplicate queue then update 5 fields Status, 
    //          Skill, Do not survey, do not survey reason, resolution description.
    //------------------------------
    public static void updateCaseWhenMarkedToDeleteOrDuplicate(TriggerParameters tp) {
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        for(Case newCase: (list <Case>) tp.newList) {
            Case oldCase = new Case();
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
            }
            String ownerId = newCase.OwnerId;

            //Status, ResolutionDescription__c, DoNotSurvey__c, DoNotSurveyReason__c is changed 
            //then check for their values and set to case owner as delete or duplicate queue. 
            if(oldCase.Status != newCase.Status || 
               oldCase.ResolutionDescription__c != newCase.ResolutionDescription__c ||
               oldCase.DoNotSurvey__c != newCase.DoNotSurvey__c ||
               oldCase.DoNotSurveyReason__c != newCase.DoNotSurveyReason__c) {
                   //Donot survey is true, status = delete, Do Not Survey Reason = Delete Case,
                   //Resolution Description = Delete Case and Owner is not Delete queue 
                   //then set Case owner to delete queue. 
                   if(newCase.Status == 'Delete' && newCase.DoNotSurvey__c &&
                     newCase.ResolutionDescription__c.equalsIgnoreCase('Delete Case') &&
                     newCase.DoNotSurveyReason__c.equalsIgnoreCase('Delete Case')&& 
                     ownerId != System.Label.DeleteQueueID) {
                       newCase.OwnerId = System.Label.DeleteQueueID;
                   } else if(newCase.Status == 'Duplicate' && newCase.DoNotSurvey__c &&
                     newCase.ResolutionDescription__c.equalsIgnoreCase('Duplicate Case') &&
                     newCase.DoNotSurveyReason__c.equalsIgnoreCase('Duplicate Case')&& 
                     ownerId != System.Label.DuplicateQueueID) {
                       //Donot survey is true, status = Duplicate, Do Not Survey Reason = Duplicate Case,
                       //Resolution Description = Duplicate Case and Owner is not Duplicate queue 
                       //then set Case owner to Duplicate queue.
                       newCase.OwnerId = System.Label.DuplicateQueueID;
                   }
               } else if(oldCase.OwnerId != ownerId && 
                    ownerId == System.Label.DeleteQueueID) {
                    //Ownerid is changed and set to delete queue
                    newCase.DoNotSurveyReason__c = 'Deleted Case';
                    newCase.ResolutionDescription__c = 'Deleted Case';
                    newCase.DoNotSurvey__c = true;
                    newCase.Status = 'Delete';
                    newCase.SkillLevel__c = '1 - General';
               } else if(oldCase.OwnerId != ownerId && 
                    ownerId == System.Label.DuplicateQueueID) {
                    //Ownerid is changed and set to Duplicate queue
                    newCase.DoNotSurveyReason__c = 'Duplicate Case';
                    newCase.ResolutionDescription__c = 'Duplicate Case';
                    newCase.DoNotSurvey__c = true;
                    newCase.Status = 'Duplicate';
                    newCase.SkillLevel__c = '1 - General';
               }
        }
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 18 September 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9960 Converting PB Update Case Moved From Delete or Duplicate Status to triggers. 
    //          When a case is moved from Delete and duplicate queues or status is changed, 
    //          then assign case to current user, update do not survey, do not survey reason, 
    //          resolution description and status fields. 
    // @LastModifiedDate : 18 Dec 2018
    // @LastModifiedDescription: SFDC1-10714: When moving a case from a delete/duplicate queue - the Case Owner always gets updated to the user moving the case and not the user selected
    // @LastModifiedBy: Harshit Singhal
    //------------------------------
    public static void updateCaseWhenMovedFromDeleteOrDuplicate(TriggerParameters tp) {
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        for(Case newCase: (list <Case>) tp.newList) {
            Case oldCase = new Case();
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                oldCase = mapOldCase.get(newCase.Id);
            }
            String ownerId = newCase.OwnerId;

            //Status, ownerId is changed then check for previous status and ownerId
            if(oldCase.Status != newCase.Status || 
               oldCase.OwnerId != ownerId) {
                   //If old status = delete or duplicate and new status is not delete or duplicate 
                   //then update, Do Not Survey Reason = '', Statue to inprogress,
                   //Do not survey to false, Resolution Description = '', Owner to current user. 
                   if((oldCase.Status == 'Delete' || oldCase.Status == 'Duplicate') &&
                      (newCase.Status != 'Delete' && newCase.Status != 'Duplicate')) {
                          if(newCase.OwnerId == oldCase.OwnerId || newCase.OwnerId == null) {
                              newCase.OwnerId = UserInfo.getUserId();    
                          }
                           newCase.DoNotSurveyReason__c = '';
                           newCase.ResolutionDescription__c = '';
                           newCase.DoNotSurvey__c = false;
                           newCase.Status = 'In Progress';
                   } else if((oldCase.OwnerId == System.Label.DuplicateQueueID || oldCase.OwnerId == System.Label.DeleteQueueID) &&
                      (newCase.OwnerId != System.Label.DuplicateQueueID && newCase.OwnerId != System.Label.DeleteQueueID)) {
                          //If old OwnerId = delete or duplicate queue and new OwnerId is not delete or duplicate queue
                          //then update, Do Not Survey Reason = '', Statue to inprogress,
                          //Do not survey to false, Resolution Description = '', Owner to current user. 
                           //newCase.OwnerId = UserInfo.getUserId();
                           newCase.DoNotSurveyReason__c = '';
                           newCase.ResolutionDescription__c = '';
                           newCase.DoNotSurvey__c = false;
                           newCase.Status = 'In Progress';
                   }
               }
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 19 Sep 2018
    // @param: None
    // @description: SFDC1-9959 Convert Process Builder 'Set Parent Case Status To "In Progress" When Resolved'.
    //               When OMD case status change to 'Resolved/Completed', then Update the Parent Case status to 'In Progress'
    //------------------------------
    public static void updateParentCaseStatusWhenOMDCaseResolved(TriggerParameters tp) {
        try {
            Id caseOMDRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId();
            Set<Id> caseIds = new Set<Id>();
            Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
            if(tp.tEvent==TriggerParameters.TriggerEvent.afterInsert) {
                for (Case c : (List<Case>)tp.newList) {
                    if(c.RecordTypeId == caseOMDRecordTypeId && 
                       c.status == 'Resolved/Completed' && 
                       String.isNotBlank(c.TeamSelect__c) && 
                       c.ParentId != NULL) {
                        caseIds.add(c.ParentId);
                    }
                }
            }
            if(tp.tEvent==TriggerParameters.TriggerEvent.afterUpdate) {
                for (Case c : (List<Case>)tp.newList) {
                    if(c.RecordTypeId == caseOMDRecordTypeId &&
                      c.status != mapOldCase.get(c.id).status &&
                      c.status == 'Resolved/Completed' &&
                      String.isNotBlank(c.TeamSelect__c) &&
                      c.ParentId != NULL) {
                        caseIds.add(c.ParentId);
                    }
                }
            }
            if(caseIds.size() > 0) {
                List<Case> caseList = new List<Case>();
                for(Id caseId : caseIds) {
                    Case cse = new Case(Id = caseId, Status = 'In Progress');
                    caseList.add(cse);
                }
                update caseList;
            }
        } catch(Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseMethods','updateParentCaseStatusWhenOMDCaseResolved'); 
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 19 Sep 2018
    // @param: None
    // @description: SFDC1-9959 Convert Process Builder 'Update Parent Case ACF Lookup ID for the Child case'
    //               When Case is inserted and ParentCase is associated to it, Check if Parent Case ACF record and populate the 
    //               ChildCase__c field on ACF record if it is NULL
    //------------------------------
    public static void UpdateParentCaseACFLookupIDForTheChildCase(TriggerParameters tp) {
        try {
            Map<Id, Id> parentChildCaseMap = new Map<Id, Id>();
            if(tp.tEvent==TriggerParameters.TriggerEvent.afterInsert) {
                for (Case c : (List<Case>)tp.newList) {
                    if(c.ParentId != NULL) {
                        parentChildCaseMap.put(c.ParentId,c.Id);
                    }
                }
                if(parentChildCaseMap.size() > 0) {
                    List<AdditionalCaseFields__c> acfList = [Select Id, Case__c, ChildCase__c From AdditionalCaseFields__c Where Case__c IN : parentChildCaseMap.keyset() AND  ChildCase__c = NULL];
                    if(acfList.size() > 0) {
                        for(AdditionalCaseFields__c acf : acfList) {
                            acf.ChildCase__c = parentChildCaseMap.get(acf.Case__c);
                        }
                        update acfList;
                    }                     
                }
            }
        } catch(Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseMethods','UpdateParentCaseACFLookupIDForTheChildCase'); 
        }
    }
    
    //-----------------------------
    // @author: Sruti Srivastava
    // @date: 3 Oct 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9453 This method is used to populate the ProcessedContractNumber on Opportunity and Contract
    // @LastModifiedDate : 31 Oct 2018
    // @LastModifiedDescription: SFDC1-10144: When Opportunity is 6L then dont update contract or opportunity
    // @LastModifiedBy: Vishnu  Vardhan Chowdary
    // @return null
    // @modified by: Priyanka Vyas
    // @modified date: 21st July 2020
    // @modifiedDescription: Added a check to compare the 'SAP Processed Contract #' fields on Contract and Opportunity with 'SAP Processed Contract Num' input on the Case record.
    // @modified reason: SFDC-3223 Error For OM user when copying SAP Processed Contract Num from Contract to OM case
    //------------------------------
    public static void populateSAPProcessedContractNumOnOpportunityAndContract(TriggerParameters tp) {
        Id recordtypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        Map<Id,Opportunity> mapOpportunityToUpdate = new Map<Id,Opportunity>();
        Map<Id,Contract> mapContractToUpdate = new Map<Id,Contract>();
        Map<Id,Case> updatedCases = new Map<Id, Case>();
        List<Case> updatedCasesList = new List<Case>();
        System.Savepoint sp = Database.setSavepoint();
        try {
            for (Case c : (List<Case>)tp.newList) {
                Case oldCase;
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldCase = mapOldCase.get(c.Id);
                }
                if(c.RecordTypeId == recordtypeId &&  !String.isBlank(c.SAPProcessedContractNumber__c ) && 
                    (oldCase == null || 
                    (oldCase != null && c.SAPProcessedContractNumber__c != oldCase.SAPProcessedContractNumber__c))) {
                    updatedCases.put(c.id, c);
                }
            }
            if(updatedCases.isEmpty()) {
                return;//No cases to process
            }
            //6L Opp cant be updated by many profiles and is causing issues when Case record is updated. 
            //If the opportunity is 6L, then dont update SAP Processed Contract number for it or contract.
            //SFDC1-10144: Mentioned in the comments by Christine Hotz
            for (Case cas : [select id, Opportunity__c, Opportunity__r.StageName, Contract__c, Opportunity__r.ProcessedContractNum__c, Contract__r.ProcessedContracttext__c, SAPProcessedContractNumber__c from Case where id in :updatedCases.values()]) {
                if(cas.Opportunity__c != null && String.isNotEmpty(cas.Opportunity__r.StageName)
                    && !cas.Opportunity__r.StageName.startsWithIgnoreCase('6L')) {
                    updatedCasesList.add(cas);
                }
            }
            for(Case c : updatedCasesList) {
                if(c.Opportunity__c != null && c.Opportunity__r.ProcessedContractNum__c!=c.SAPProcessedContractNumber__c) {
                    mapOpportunityToUpdate.put(c.Opportunity__c, new Opportunity(Id = c.Opportunity__c, ProcessedContractNum__c = c.SAPProcessedContractNumber__c));
                }
                if(c.Contract__c != null && c.Contract__r.ProcessedContracttext__c!=c.SAPProcessedContractNumber__c) {
                    mapContractToUpdate.put(c.Contract__c, new Contract(Id = c.Contract__c, ProcessedContracttext__c = c.SAPProcessedContractNumber__c));
                }
            }
            if(!mapOpportunityToUpdate.isEmpty()) {
                update mapOpportunityToUpdate.values();
            }
            if(!mapContractToUpdate.isEmpty()) {
                update mapContractToUpdate.values();
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            String errMessage = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
            ex.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):ex.getMessage();
            tp.newList[0].addError('Error: '+errMessage);
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 08 Oct 2018
    // @param: None
    // @description: SFDC1-10048 When the OM user sets the status to Validated - the Opportunity needs to be set to 6WP.
    //              only for cases where Auto Renewal = Yes and Does this Opportunity have changes? = No and the case type is Order Management.
    // @modified by: Paras Dhingra
    // @modified date: 02nd April 2020
    // @modified reason: SFDC-2396 Increasing the scope of OM case validation. OM case is the only touch point to set an Opportunity to 6WP
    //                  Renaming the method name to suit the new objective
    // @Modified by: Paras Dhingra
    // @Modified date: 27/11/2020
    // @Modified Description: SFDC-2723 adding exception for Auto renewal stopped change case
    //------------------------------
    public static void updateOppTo6WPClosedWonWhenOMCaseValidated(TriggerParameters tp) {
        try {
            Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
            Id caseOMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
            Set<Id> opptyIds = new Set<Id>();
            if(tp.tEvent==TriggerParameters.TriggerEvent.afterUpdate) {
                for (Case c : (List<Case>)tp.newList) {
                    if(c.RecordTypeId == caseOMRecordTypeId &&
                       c.status != mapOldCase.get(c.id).status &&
                       (c.Status == 'Validated' /*|| c.Status == 'Validated PO Pending'*/)
                       && c.Type!='Auto Renewal Stopped change') {
                           opptyIds.add(c.Opportunity__c);
                       }
                }
                if(opptyIds.size() > 0) {
                    Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                    Id NewBusinessOppyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
                    List<Opportunity> opptyList = [Select Id, AutoRenewal__c, DoesThisAutoRenewalHaveChanges__c , recordTypeId,
                                                    ContractBeingRenewed__c,StageName /*, (Select Id From Contracts__r)*/ From Opportunity Where Id IN : opptyIds];
                    List<Opportunity> updateOpptyList = new List<Opportunity>();
                    for(Opportunity oppty : opptyList) {
                        if((oppty.recordTypeId == RenewalOppRecordTypeId || oppty.recordTypeId == NewBusinessOppyRecordTypeId)&&
                           oppty.StageName.containsIgnoreCase('6W-') 
                           /* && oppty.AutoRenewal__c &&*/
                           /*!oppty.DoesThisAutoRenewalHaveChanges__c &&*/
                           /*oppty.ContractBeingRenewed__c != NULL &&*/
                           /*oppty.Contracts__r.size() == 0*/) { //No changes to the existing contract, we just Renewed the existing contract and Updated a OM Case to 'Validated'/'Validated PO Pending'
                           updateOpptyList.add(new Opportunity(Id= oppty.Id, StageName ='6WP-Closed Won/Order Processed'));
                        }
                    }
                    System.debug('updateOpptyList ----'+updateOpptyList);
                    if(updateOpptyList.size() > 0) {
                        update updateOpptyList;
                    }
                }
            }
        } catch(Exception e) {
            System.debug('Exception ---'+e.getMessage());
            UtilityClass.createApexLogRecord(e,'CaseMethods','updateOppTo6WPClosedWonWhenOMCaseValidated'); 
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 17 Jun 2020
    // @param: None
    // @description: SFDC-1652 Populate logged in user as case owner if queue owns it and case is being closed
    // @update date: 02 Jul 2020
    // @update by: Harshit Singhal
    // @update description: SFDC-3169 Exclude delete, duplicate queue scenarios. Add exclusions to case statuses - Auto Close, Delete, Duplicate.
    //-----------------------------    
    public static void populateUserAsOwnerOnCaseClosure(TriggerParameters tp) {       
        //System.debug('18Jun populateUserAsOwnerOnCaseClosure() METHOD BEGINS');
        List<String> excludeProfiles = new List<String> {'System Administrator','IHSMarkit System Admin: API'};
        List<String> excludeClosedCaseStatuses = new List<String> {'Auto-Closed – No Action Taken', 'Delete', 'Duplicate','Merged'};
        for(Case newCase: (List<Case>)tp.newList) {
            Case oldCase = tp.tEvent==TriggerParameters.TriggerEvent.beforeUpdate ? (Case)tp.oldMap.get(newCase.Id) : null;
            String caseOwnerStr = newCase.OwnerId;
            if(!caseOwnerStr.startsWithIgnoreCase('005') && !UtilityClass.deleteDuplicateCaseQueueIds.contains(newCase.OwnerId) && UtilityClass.ClosedCaseStatuses.contains(newCase.Status) && !excludeClosedCaseStatuses.contains(newCase.Status) 
               && UtilityClass.IncludedCaseRecTypes.contains(newCase.RecordTypeId) && !excludeProfiles.contains(UtilityClass.LoggedInUserProfileName) 
               && (tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert || (tp.tEvent==TriggerParameters.TriggerEvent.beforeUpdate && newCase.Status!=oldCase.Status && !UtilityClass.ClosedCaseStatuses.contains(oldCase.Status) ))) {            
                    newCase.OwnerId = UserInfo.getUserId();                    
            }
        }
        //System.debug('18Jun populateUserAsOwnerOnCaseClosure() METHOD ENDS');
    }

    //-----------------------------
    // @author: Paras Dhingra
    // @date: 07 Aug 2019
    // @param: None
    // @description: SFDC-175 Do not allow customer care users to close case if contact does not match the account
    // @modifiedBy : Paras Dhingra
    // @modifiedDate : 21/08/2019
    // @description : SFDC-1905 hotfix to make sure validation is fired only when accountId is not null
    // @modifiedBy : Priyanka Vyas
    // @modifiedDate : 19/08/2020
    // @description : SFDC-2648 Commented the method and rewrote it with added validation in preventAccConMisMatchOnCustomerCareCaseClosure method below.
    //------------------------------
    /*public static void preventAccountMisMatchOnCloseCase(TriggerParameters tp) {
        //initialize
        String accountMisMatchError = System.Label.CaseAccountMisMatchError;
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Set<String> caseClosedStatuses = UtilityClass.getCaseClosedStatuses();
        Set<Id> setContactIdToQuery = new Set<Id>();
        Map<Id,Set<Id>> mapContactAccountRelationShip = new Map<Id,Set<ID>>();
        List<Case> lstCasesToValidate = new List<Case>();
        for(Case cse: (List<Case>)tp.newMap.values()) {
            if(cse.RecordTypeId == customerCaseRecordTypeId && caseClosedStatuses.contains(cse.Status) && cse.ContactId!=null && cse.AccountId!=null ) {
                //check if contact is matched with correct accountId
                setContactIdToQuery.add(cse.contactId); 
                lstCasesToValidate.add(cse);  
            }
        }
        if(lstCasesToValidate!=null && !lstCasesToValidate.isEmpty() && !setContactIdToQuery.isEmpty()) {
             //query contact account relationship
            List<Contact> lstContactsWithRelationShip = [Select Id, (Select AccountId from AccountContactRelations)
                                                                            from Contact where Id In:setContactIdToQuery];
            if(lstContactsWithRelationShip!=null && !lstContactsWithRelationShip.isEmpty()) {
                for(Contact con : lstContactsWithRelationShip) {
                    for( AccountContactRelation acr : con.AccountContactRelations) {
                        if(mapContactAccountRelationShip.containsKey(con.Id)) {
                            mapContactAccountRelationShip.get(con.Id).add(acr.AccountId);
                        } 
                        else {
                            mapContactAccountRelationShip.put(con.Id, new Set<Id>{acr.AccountId});
                        }
                    }
                }        
                for(Case cse : lstCasesToValidate) {
                    Set<Id> setAccountRelatedToCase = new Set<Id>();
                    setAccountRelatedToCase.addAll(mapContactAccountRelationShip.get(cse.ContactId));
                    if(!setAccountRelatedToCase.contains(cse.AccountId)) {
                        tp.newMap.get(cse.Id).addError(accountMisMatchError);
                    }
                }
            } 


        }
                                                              
    }*/
    //-----------------------------
    // @author: Sushma Yadav
    // @date: 18 Jun 2020
    // @param: None
    // @description: SFDC-1363 Disqualify Lead when Customer Care Case created from Lead Quick Action button
    //------------------------------  
    
    public static void updateLeadStatus(TriggerParameters tp) {
        Map<Id, Id> leadSourceCaseMap = new Map<Id, Id>();
            for(Case newCase:(List<Case>)tp.newList) {
                if(newCase.RecordTypeId == UtilityClass.caseRecordTypeCustomerCare && newCase.LeadToCase__c == true && newCase.SourceLead__c != null && newCase.LeadReference__c != null) {
                    leadSourceCaseMap.put(newCase.LeadReference__c, newCase.Id);
                }
            }

        List<Lead> leadToUpdate = new List<Lead>();
        
            if(leadSourceCaseMap.size() > 0) {
                leadToUpdate=[Select id, status, DisqualifedReason__c from Lead where Id in : leadSourceCaseMap.KeySet() AND status='Prioritized'];
                    if(leadToUpdate.size()>0) {
                        for(Lead lead:leadToUpdate) {
                            lead.status               = 'Disqualify';
                            lead.DisqualifedReason__c = 'Passed to Customer Care';
                        }   
                    }                
                update leadToUpdate;
            }         
    }
    
    //-----------------------------
    // @author: Sushma Yadav
    // @date: 21 Jul 2020
    // @param: None
    // @description: SFDC-3004 Update Team Select & Order Management Region for Email2Case OMDH
    //------------------------------ 
    /**
     * As Stephen wants Email2case functionality to be enabled later so commenting the code for now.
     * Also commented this method in CaseBeforeInsertHandler
     
    public static void updateOMDHEmail2Case(TriggerParameters tp) {
        if((UserInfo.getUserId() == Label.Email2CaseUserId || Test.isRunningTest()) && tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
        
            List<Case> listNewCase = tp.newList;
            
            getProductGroupIds();
            
            String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName = 'CSOrderManagement' Limit 1].Id;
            
                for (Case newCase : listNewCase) {            
                    if(newCase.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk && newCase.Origin == 'Email' && newCase.OwnerId == queueId) {
                        newCase.TeamSelect__c               = 'Order Management';
                        newCase.OrderManagementRegion__c    = 'Markit';
                        newCase.ProductGroup__c             = productGroupIdOrderMgmtHelpdesk;
                    }
                    if(newCase.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk && newCase.Origin == 'Case' && newCase.OwnerId == queueId) {
                        newCase.TeamSelect__c   = 'Order Management';
                        newCase.ProductGroup__c = productGroupIdOrderMgmtHelpdesk;
                    }
                }         
            }                    
        }*/
    //------------------------------------------------------------------------------------------
    // @modifiedBy : Priyanka Vyas
    // @modifiedDate : 18/08/2020
    // @description : SFDC-2648 Rewrote preventAccountMisMatchOnCloseCase and included Contact Valdiation checkbox check
    //                only for Customer Care cases.
    //------------------------------------------------------------------------------------------
    public static void preventAccConMisMatchOnCustomerCareCaseClosure(TriggerParameters tp) {
        String accountMisMatchError = System.Label.CaseAccountMisMatchError;
        String InternalAccountOnCaseConfirmation = System.Label.InternalAccountOnCaseConfirmation;
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id customerExpRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Experience').getRecordTypeId();
        //Set<String> caseClosedStatuses = UtilityClass.getCaseClosedStatuses();
        List<String> closeStatusOnCCCaseUI = Label.CloseStatusOnCCCaseUI.split(','); 
        List<String> closeStatusAccountContactMismatchValidation = Label.CloseStatusAccountContactMismatchValidation.split(','); 
        Set<Id> setContactIdToQuery = new Set<Id>();
        Map<Id,Set<Id>> mapContactAccountRelationShip = new Map<Id,Set<ID>>();
        List<Case> lstCasesToValidate = new List<Case>();
        for(Case cse: (List<Case>)tp.newMap.values()) {
            if((cse.RecordTypeId == customerCaseRecordTypeId || cse.RecordTypeId == customerExpRecordTypeId) && (closeStatusOnCCCaseUI.contains(cse.Status) || closeStatusAccountContactMismatchValidation.contains(cse.Status)) && cse.ContactId!=null && cse.AccountId!=null) {
                setContactIdToQuery.add(cse.contactId); 
                lstCasesToValidate.add(cse);
            }
        }
        if(lstCasesToValidate!=null && !lstCasesToValidate.isEmpty() && !setContactIdToQuery.isEmpty()) {
            List<Contact> lstContactsWithRelationShip = [Select Id, (Select AccountId from AccountContactRelations)
                                                         from Contact where Id In:setContactIdToQuery];
            if(lstContactsWithRelationShip!=null && !lstContactsWithRelationShip.isEmpty()) {
                for(Contact con : lstContactsWithRelationShip) {
                    for( AccountContactRelation acr : con.AccountContactRelations) {
                        if(mapContactAccountRelationShip.containsKey(con.Id)) {
                            mapContactAccountRelationShip.get(con.Id).add(acr.AccountId);
                        } 
                        else {
                            mapContactAccountRelationShip.put(con.Id, new Set<Id>{acr.AccountId});
                        }
                    }
                }        
                for(Case cse : lstCasesToValidate) {
                    Set<Id> setAccountRelatedToCase = new Set<Id>();
                    if(mapContactAccountRelationShip!=null && !mapContactAccountRelationShip.isEmpty() && mapContactAccountRelationShip.get(cse.ContactId)!=null && cse.AccountId!=null){
                        setAccountRelatedToCase.addAll(mapContactAccountRelationShip.get(cse.ContactId));
                        Boolean isInternalContact=false;
                        for(Id accId:setAccountRelatedToCase){
                            if((UtilityClass.InternalAccountIds).contains(accId)){
                                isInternalContact=true;
                            }
                        }
                        //Throws the error when case account & case contact, both are internal but Contact Validation checkbox is not checked
						//@modifiedDate : 20/07/2021 SFDC-4328 Ignore the validation rule if logged in user has IgnoreCaseValidationRules permission set
                        if((UtilityClass.InternalAccountIds).contains(cse.AccountId) && cse.ContactValidation__c == false && isInternalContact==true && !GlobalConstants.hasIgnoreValidationPermission) {
                            if(closeStatusOnCCCaseUI.contains(cse.Status)){
                                tp.newMap.get(cse.Id).addError(InternalAccountOnCaseConfirmation);
                            }
                        }
                        // Throws the validation check error when:
                        // 1. the case account is external & case contact is external which is not an associated contact of case Account
                        // 2. the case account is internal & case Contact is external
                        // Skips the scenario where case account is external & case contact is internal
                        if(!setAccountRelatedToCase.contains(cse.AccountId) && isInternalContact==false) {
                            if(closeStatusAccountContactMismatchValidation.contains(cse.Status)){
                                tp.newMap.get(cse.Id).addError(accountMisMatchError);
                            }                                
                        }
                    }
                }
            } 
         }
    }
    
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 07 Oct 2020
    // @param: None
    // @description: SFDC-3366 Delete ACF on child Case when child Case is Merged
    //------------------------------  
    public static void deleteMergedCaseRelatedACF(TriggerParameters tp) {       
        Map<Id,Case> mapNewCase = (Map<Id,Case>) tp.newMap;
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;       
        List<AdditionalCaseFields__c> deleteACFList = new List<AdditionalCaseFields__c>();
        for(Case newCase: mapNewCase.values()) {
            Case oldCase = mapOldCase.get(newCase.Id);          
            if(oldCase!=null && oldCase.Status != newCase.Status && newCase.Status == 'Merged' && newCase.AdditionalFields__c != null) {
                AdditionalCaseFields__c existingACF = new AdditionalCaseFields__c(id=newCase.AdditionalFields__c);
                deleteACFList.add(existingACF);            
            }
        }       
        if(!deleteACFList.isEmpty()) {
            delete deleteACFList;
        }       
    }

 //-----------------------------
    // @author: Digvijay Singh
    // @date: 25 March 2021
    // @param: None
    // @description: SFDC-3511 updating LastModifiedDateForRelatedData__c on Case.
    //------------------------------ 
    public static void updateCustomLastmodifiedonCase(TriggerParameters tp) { 
        List<Case> listNewCase = tp.newList;
        for(Case objcase : listNewCase) {
            objcase.LastModifiedDateForRelatedData__c = System.Now();
        }

    }
    
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 01 Apr 2021
    // @param: None
    // @description: SFDC-3889 JTL case record type.
    // @Modified By : Neelam agrawal
    // @Modification Date: 12 Oct 2021
    // @Modification Description:SFDC-4794 JTL Record Type Cases - from address update
    //------------------------------

    public static void updateRecordTypeToJTL(TriggerParameters tp) {
        for(Case newCase: (List<Case>)tp.newList) {
            if(!String.isBlank(newCase.SuppliedEmail) && System.Label.JTLSuppliedEmail.containsIgnoreCase(newCase.SuppliedEmail)){
                newCase.recordTypeId = UtilityClass.caseRecordTypeJoinerTransferLeaver;
            }
        }
    }

    //-----------------------------
    // @author: Digvijay Singh
    // @date: 08 April 2021
    // @description: SFDC-3268 Assign 'Order Management/Delivery Help Desk' Cases to "CS|Delivery" queue on Creation.
    // @return: None
    //-----------------------------
    public static void assignOMDeliverHelpDeskCasetoCSQueue(TriggerParameters tp) {
       String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName =: System.Label.CSDeliveryQueue Limit 1].Id;
        for(Case newCase: (List<Case>)tp.newList) {
            String strOwnerId = newCase.ownerId;
            if (newCase.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk && newCase.TeamSelect__c == 'Delivery' && strOwnerId.startsWith('005')) {
                newCase.OwnerID = queueId;
            }
        }

    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 22 April 2021
    // @description: SFDC-3419 On change of Owner, update the previous owner name in case of a user
    // @return: None
    //-----------------------------
    public static void updatePreviousOwnerName(TriggerParameters tp) {
        for(Case newCase: (List<Case>)tp.newList) {
            Case oldCase = (Case)tp.oldMap.get(newCase.Id);
            String strOldOwnerId = oldCase.OwnerId;
            if (newCase.OwnerId != oldCase.OwnerId && strOldOwnerId.startsWith('005')) {
                newCase.PreviousOwnerName__c = oldCase.OwnerId;
            }
        }
    }
    
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 18 May 2021
    // @description: SFDC-4055 OMDH case - Default field values to be filled on Creation.
    // @return: None
    //-----------------------------
    public static void assignDefaultValuesToOMDeliverHelpDeskCases(TriggerParameters tp) {
        String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName =: System.Label.GlobalDeliveryEMEAADAndMQueue Limit 1].Id;
        for(Case newCase: (List<Case>)tp.newList) {
            if(newCase.RecordTypeId == UtilityClass.caseRecordTypeOMDHelpDesk && newCase.OwnerID == queueId) {
                newCase.TeamSelect__c = 'Delivery';
                newCase.DeliveryTeam__c = 'Global Delivery EMEA ADandM'; 
                //newCase.OwnerID = queueId;
            }
        }
    }
            //-----------------------------
    // @author: Akshay Dogra
    // @date: 20 August 2021
    // @description: SFDC-4228 Updating opportunity when CaseRejectionPastDue__c is set to true by Time trigger after 10 days
	// @return: None
    //-----------------------------
    public static void updateOppoStatusContract(TriggerParameters tp) { 
        // Initializing variables
    
        Set<Id> opportunityId = new Set<Id>();
        List<Opportunity> recordsToUpdate = new List<Opportunity>();
        String oppRecordTypeRenewal = 'Renewal';
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        // fetching relevant ids to fetchopportunity associated with case
        for(Case c: [ Select Id, CaseRejectionPastDue__c, Opportunity__c, contract__r.recordtypeId From Case Where Id IN : (List<Case>)tp.newList ]) {
            Case oldCase = (Case)tp.oldMap.get(c.Id);  
            if(c.CaseRejectionPastDue__c && c.CaseRejectionPastDue__c != oldCase.CaseRejectionPastDue__c && (c.contract__r.RecordTypeId == orderFormRecordTypeId || c.contract__r.RecordTypeId == consultingRecordTypeId)) {
                opportunityId.add(c.Opportunity__c);
            }
        }
            // Opportunity stage change for relevant record 
            if(opportunityId.size() > 0 && opportunityId != null) {
                    for(Opportunity o : [Select Id , StageName , recordType.DeveloperName, DoesThisAutoRenewalHaveChanges__c, AutoRenewal__c from Opportunity where Id In:opportunityId]) {
                        if(o.recordType.DeveloperName == oppRecordTypeRenewal && !o.DoesThisAutoRenewalHaveChanges__c && o.AutoRenewal__c) {
                            o.StageName = '5-Renewal Contracting';
                            recordsToUpdate.add(o);
                        } 
                    }
                }
            try {
                if(recordsToUpdate.size()>0) {
                    System.debug('UpdateRecord' + recordsToUpdate.size());
                    update recordsToUpdate;
                }
            }
            catch(Exception e) {
                UtilityClass.createApexLogRecord(e,'ContractMethods','updateOppoStatusContract');
            }
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 28th Oct 2021
    // @description: SFDC-4516 When a new OM case is created, non-validated OM cases should move to Delete queue.
	// @return: None
    //-----------------------------
    public static void moveToDeleteQueueExistingOMCases(TriggerParameters tp) {      
        Id caseOMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();               
        Map <Id,Id> mapOppyIdsToCaseId = new Map <Id,Id>();
        List <Case> caseToUpdate = new List<Case>();
        
        for(Case caseObj : (list <Case>) tp.newList) {                
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert && caseObj.RecordTypeId == caseOMRecordTypeId ) {            
              mapOppyIdsToCaseId.put(caseObj.Opportunity__c,caseObj.Id);  
            }
        }
   
        if (mapOppyIdsToCaseId.size () > 0) {
            for (Case cse : [Select Id, Status from Case Where RecordTypeId = :caseOMRecordTypeId AND Opportunity__c IN :mapOppyIdsToCaseId.keySet() AND Id NOT IN :mapOppyIdsToCaseId.values()]) {
                if (!(cse.Status.startsWithIgnoreCase('validated') || System.Label.OMCaseStatus.split(',').contains(cse.Status))) {
                    cse.OwnerId = System.Label.DeleteQueueID;
                caseToUpdate.add(cse);
            }
        }    
        }    
        
        if (!caseToUpdate.isEmpty()) {
            update caseToUpdate;
        }
    } 
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 5th November 2021
    // @description: SFDC-4614 Updating case productgroup and loading group when case is created from a specific GRRS Emailtocase
	// @return: None
    //-----------------------------
    public static void updateProductGroup(TriggerParameters tp) { 
        
        Id customerCareRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        for(Case cases: (List<Case>)tp.newList){
            if(cases.RecordTypeId == customerCareRecordTypeId && cases.ownerId == System.Label.GRRSOnboardingQueue){
                cases.ProductGroup__c = System.Label.GRRSProductGroup;
            }
        }  
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 10th March 2022
    // @description: SFDC-4998 Customer Experience
	// @return: None
    //-----------------------------
    public static void customerExperienceAutomation(TriggerParameters tp) { 
        
        Id customerExpRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Experience').getRecordTypeId();
        Set<String> setCaseNums = new Set<String>();
        Map<String,Id> mapCaseNumToCaseId = new Map<String,Id>();
        Map<Id,Case> mapOldCase = (Map<Id,Case>) tp.oldMap;
        
        //fetch Queue Id of Customer Experience Queue Name
        Id customerExpQueueId = [Select Id from Group Where Type='Queue' and DeveloperName = :System.Label.CCCustomerExperience LIMIT 1].Id;
        
        // Get Case Id from Case Number.
        for(Case cases: (List<Case>)tp.newList){
            if (cases.DevelopmentSystem__c == 'Salesforce' && cases.DevelopmentSystemID__c != null) {
              setCaseNums.add(cases.DevelopmentSystemID__c);
            }
        }
        
        if (setCaseNums.size() >0) {
            for(Case cases: [Select Id,CaseNumber from Case where CaseNumber IN :setCaseNums]){
                 mapCaseNumToCaseId.put(cases.CaseNumber,cases.Id);
            }
        }    
        
        for(Case cases: (List<Case>)tp.newList){
            if(cases.RecordTypeId == customerExpRecordTypeId) {
                // populate DevelopmentTicketURL__c field based on ticket no.
                if (cases.DevelopmentSystem__c == 'JIRA' && cases.DevelopmentTicketURL__c == null) {
                    cases.DevelopmentTicketURL__c = System.Label.JiraUrl + cases.DevelopmentSystemID__c;
                } else 
                if (cases.DevelopmentSystem__c == 'Salesforce' && cases.DevelopmentTicketURL__c == null && mapCaseNumToCaseId.containsKey(cases.DevelopmentSystemID__c)) {
                    String caseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapCaseNumToCaseId.get(cases.DevelopmentSystemID__c);
                    cases.DevelopmentTicketURL__c = caseUrl;
                } else 
                if (cases.DevelopmentSystem__c == 'WRIKE' && cases.DevelopmentTicketURL__c == null) {
                    cases.DevelopmentTicketURL__c = System.Label.WrikeUrl + cases.DevelopmentSystemID__c;
                }
            } 
            
            // If any case that are assigned to this Customer Exp. queue should automatically
            // be converted to a Customer Experience Record type
            if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                Case oldCase = mapOldCase.get(cases.Id);
                if (cases.RecordTypeId != customerExpRecordTypeId 
                    && cases.OwnerId == customerExpQueueId && oldCase.OwnerId != customerExpQueueId) {
                    cases.RecordTypeId = customerExpRecordTypeId;
                }
            }
        }  
    }
    
    //-----------------------------
    // @author: Ankush Vedi
    // @date: 24th March 2022
    // @description: SFDC-5530 Insert and Updating case to get the last open case date.
	// @return: None
    //-----------------------------
    public static void calculateCaseAgeBusinessDays(TriggerParameters tp) {
        
        Map<Id,Case> mapOldCase = (Map<Id,Case>)tp.oldMap;
        List<String> caseClosed	= Label.CaseClosed.split(',');
        List<String> caseOpned	= Label.CaseOpned.split(',');
        Id caseRMRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        
        for(Case ca : (List<Case>)tp.newList) {
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert){
                ca.DateCaseLastOpened__c =  Datetime.now();
            } else if(caseOpned.contains(ca.Status) && caseClosed.contains(mapOldCase.get(ca.id).Status)){
                ca.DateCaseLastOpened__c =  Datetime.now();
            }
        } 
    }  
}