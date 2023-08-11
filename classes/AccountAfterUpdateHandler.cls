//***************************************
// @author Uttam Arya
// @date 6th Feb 2017
// @description SFDC1-405 Implementation of Trigger framework.
// @edits: 24th Aug 2017 SFDC1-2103 Uttam Arya, Adding a call to function to change Account Additional Fields Object Name When Account Name Changes (changeAccountAdditionalFieldsObjectNameWhenAccountNameChanges)
// @Last Modified By : Tran-Vu Tran
// @Last Modified Date : 12nd April 2018
// @Last Modified Description : SFDC1-7718 add method to update child accounts' Compliance Restriction value from Parent account if Exception is not checked
// @Last Modified By : Priyanka Vyas
// @Last Modified Date : 22 Oct 2020
// @Last Modified Description : SFDC-3123 - Cascade the value of Compliance Restriction Exception to child accounts. 
//***************************************

public class AccountAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
       // AccountMethods.updateCountryLookup(tp); 
        AccountMethods.updateGAMOnOpenOppys(tp);
        Accountmethods.reinsertExistingAtms(tp);    
        Accountmethods.updateAccountTeamMemberRole(tp);
        Accountmethods.changeAccountAdditionalFieldsObjectNameWhenAccountFieldChanges(tp);
        Accountmethods.cascadeComplianceRestrictionToChildAccounts(tp);
        Accountmethods.updateOpenContractAddress(tp);
        // 20-April-2016 comment out codes - will be replaced by formula fields
        // Accountmethods.updateChildAccountsComplianceRestriction(tp);
    }

}