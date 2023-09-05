//***********************************************
// @author Manish Kumar
// @date 29th July 2021
// @description SFDC-4232 Trigger Event handler for Survey Response Trigger
// @LastModifiedBy: Neelam Agrawal
// @LastModifiedDate: 08 Nov 2021
// @LastModifiedReason: SFDC-4888 Adding populateNewAccountAndContactLookup to create new contact
//***********************************************
public class SurveyResponseBeforeInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        SurveyResponseMethods.populateNewAccountAndContactLookup(tp);
        SurveyResponseMethods.populateExistingAccountAndContactLookup(tp);
        SurveyResponseMethods.scoreAlertType(tp);
        SurveyResponseMethods.updateSurveyResponseOwner(tp);
    }
}