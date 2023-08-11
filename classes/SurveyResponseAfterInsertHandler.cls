//***********************************************
// @author Manish Kumar
// @date 29th July 2021
// @description SFDC-4232 Trigger Event handler for Survey Response Trigger
//***********************************************
public class SurveyResponseAfterInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
       	SurveyResponseMethods.updateRollupFields(tp);
    }
}