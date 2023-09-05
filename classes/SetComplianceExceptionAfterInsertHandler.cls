//-----------------------------
// @author: Sathish Edla
// @date: 30 Mar 2022
// @description: SFDC-5375 Extend the trigger framework to handle platform events.
//-----------------------------
public class SetComplianceExceptionAfterInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        SetComplianceExceptionMethods.cascadeComplianceRestrictionToChildAccounts(tp);        
    }
}