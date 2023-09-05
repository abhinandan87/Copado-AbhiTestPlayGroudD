//***************************************
// @author: Uttam Arya
// @date: 1st Nov 2017
// @description: Trigger Handler Base class for before insert trigger as per Trigger Handler framework.
// @updated by : Mohit Modi
// @updated description : SFDC1-6009, To set the Contact Name same as Owner, if Contact Exists only for 'Sales Support' Recordtype, Valid for insert and Owner update only with a specified Account stored in Label.
// @updated date : 06 Feb 2018
// @Modified by : Vishnu Vardhan Chowdary Andra
// @Modified date: 21 March 2018
// @Modification reason : SFDC1-7163: adding validateIfOBCaseCanCreateFromImplCase
// @Modified by : Prachi Bhasin
// @Modified date: 3 May 2018
// @Modification reason : SFDC1-7574: adding assignCasesViaTriage
//***************************************
// @Modified by: Tran-Vu Tran
// @Modified description:
// 	+ SFDC1-8356: adding setCaseProductGroupForOrderManagementDeliveryHelpDesk
// 	+ SFDC1-8381: combining SFDC1-965 into setInternalCaseAccountAndContact
// @Modified date : 06 June 2018 
// @LastModifieddate : 06 Sep 2018
// @LastModifieby : Jagadesh Kumar
// @LastModifieddescription : SFDC1-9035 OM/Delivery Help Desk 'OMD Status' to 'Status' field mapping
// @LastModifieddate : 14 Sep 2018
// @LastModifieby : Vishnu Vardhan Chowdary Andra
// @LastModifieddescription : SFDC1-9962 converting checkInternalUserforCaseSurvey process builder into trigger.
// @LastModifieddate : 18 Sep 2018
// @LastModifieby : Vishnu Vardhan Chowdary Andra
// @LastModifieddescription : SFDC1-9960 converting Duplicate and Delete Case Case Owner Change and 
// 				Update Case Moved From Delete or Duplicate Status process builder into trigger.
// @LastModifiedBy : Harshit Singhal
// @LastModifiedDate : 08 Jul 2020
// @LastModifiedDescription : SFDC-2375 Removed method call setContactNamefromOwner() from before update context as part of cleanup. There is no code in the method for update scenario.
// @LastModifiedBy : Priyanka Vyas
// @LastModifiedDate : 19 Aug 2020
// @LastModifiedDescription : SFDC-2648 Rewrote preventAccountMisMatchOnCloseCase as preventAccConMisMatchOnCustomerCareCaseClosure and included Contact Valdiation checkbox check for Customer Care cases.
//***************************************

public class CaseBeforeUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        System.debug('@@@UA');
        CaseMethods.assignCasesViaTriage(tp);
        CaseMethods.setCaseProductGroupFromProductFamily(tp);
        CaseMethods.setCaseProductGroupForOrderManagementDeliveryHelpDesk(tp);        
        CaseMethods.validateIfOBCaseCanCreateFromImplCase(tp);
        CaseMethods.setCaseStatusFromOMDStatusForOMDCaseType(tp);
        CaseMethods.checkInternalUserforCaseSurvey(tp);
        CaseMethods.updateCaseWhenMarkedToDeleteOrDuplicate(tp);
        CaseMethods.updateCaseWhenMovedFromDeleteOrDuplicate(tp);
        //CaseMethods.preventAccountMisMatchOnCloseCase(tp);
        CaseMethods.preventAccConMisMatchOnCustomerCareCaseClosure(tp);
        CaseMethods.populateUserAsOwnerOnCaseClosure(tp);
        CaseMethods.updateCustomLastmodifiedonCase(tp);
        CaseMethods.updatePreviousOwnerName(tp);
        CaseMethods.customerExperienceAutomation(tp);
        CaseMethods.calculateCaseAgeBusinessDays(tp);
    }
}