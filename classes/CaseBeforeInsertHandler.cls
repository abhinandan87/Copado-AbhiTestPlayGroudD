//***************************************
// @author Uttam Arya
// @date 7th Feb 2017
// @description Re-structuring the trigger methods by using Trigger Handler framework. Org assessment 2016.
// @updated by : Mohit Modi
// @updated description : SFDC1-6009, To set the Contact Name same as Owner, if Contact Exists only for 'Sales Support' Recordtype, Valid for insert and Owner update only with a specified Account stored in Label.
// @updated date : 06 Feb 2018
// @Updated By : Jagadesh Kumar
// @Updated description SFDC1-8014 :Used to populate the Case lookup fields
// @Updated date : 30 May 2018
// @Updated By : Prachi Bhasin
// @Updated description SFDC1-8945 Adding call to populateOMDeliveryHelpDeskCaseFields method
// @Updated date : 12 July 2018
// @Updated by: Tran-Vu Tran
// @Updated description:
//  + SFDC1-8356: adding setCaseProductGroupForOrderManagementDeliveryHelpDesk
//  + SFDC1-8381: combining SFDC1-965 into setInternalCaseAccountAndContact
// @Updated date : 06 June 2018
// @LastModifieddate : 18 July 2018
// @LastModifieby : Mohit Modi
// @LastModifieddescription : SFDC1-9031-Commenting this Method as field ContractOwner__c and OpportunityOwner__c is nomore required.
// @LastModifieddate : 17 August 2018
// @LastModifieby : Vishnu Vardhan Chowdary
// @LastModifieddescription : SFDC1-8354: Adding entitlement Id to Customer Care and Salesforce helpdesk record types
// @LastModifieddate : 06 Sep 2018
// @LastModifieby : Jagadesh Kumar
// @LastModifieddescription : SFDC1-9035 OM/Delivery Help Desk 'OMD Status' to 'Status' field mapping
// @LastModifieddate : 14 Sep 2018
// @LastModifieby : Vishnu Vardhan Chowdary Andra
// @LastModifieddescription : SFDC1-9962 converting checkInternalUserforCaseSurvey process builder into trigger.
// @LastModifieddate : 18 Sep 2018
// @LastModifieby : Vishnu Vardhan Chowdary Andra
// @LastModifieddescription : SFDC1-9960 converting Duplicate and Delete Case Case Owner Change and 
// 		Update Case Moved From Delete or Duplicate Status process builder into trigger.
// @LastModifieddate : 10 Jan 2019
// @LastModifieby : Vishnu Vardhan Chowdary Andra
// @LastModifieddescription : SFDC1-10754 Removing the related account to contact validation. 
//***************************************
public class CaseBeforeInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        CaseMethods.setEntitlements(tp);
        CaseMethods.assignCasesViaTriage(tp);
        CaseMethods.setCaseProductGroupFromProductFamily(tp);
        CaseMethods.setCaseProductGroupForOrderManagementDeliveryHelpDesk(tp);
        CaseMethods.setContactNamefromOwner(tp);
      //CaseMethods.populateCaseLookUpFields(tp);
        CaseMethods.setInternalCaseAccountAndContact(tp);
        //CaseMethods.validateCaseContactAndAccountMatch(tp);
        CaseMethods.populateOMDeliveryHelpDeskCaseFields(tp);
        CaseMethods.setCaseStatusFromOMDStatusForOMDCaseType(tp);
        CaseMethods.checkInternalUserforCaseSurvey(tp);
        CaseMethods.updateCaseWhenMarkedToDeleteOrDuplicate(tp);
        CaseMethods.updateCaseWhenMovedFromDeleteOrDuplicate(tp);
        CaseMethods.populateUserAsOwnerOnCaseClosure(tp);
        //CaseMethods.updateOMDHEmail2Case(tp);
        CaseMethods.updateRecordTypeToJTL(tp);
        CaseMethods.assignOMDeliverHelpDeskCasetoCSQueue(tp);
        CaseMethods.assignDefaultValuesToOMDeliverHelpDeskCases(tp);
        CaseMethods.updateProductGroup(tp);
        CaseMethods.customerExperienceAutomation(tp);
        CaseMethods.calculateCaseAgeBusinessDays(tp);
    }
}