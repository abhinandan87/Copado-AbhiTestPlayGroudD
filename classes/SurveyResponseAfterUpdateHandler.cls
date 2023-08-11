//***********************************************
// @author Neelam Agrawal
// @date 25th Oct 2021
// @description SFDC-4821 Trigger Event handler for Survey Response Trigger
//***********************************************
public class SurveyResponseAfterUpdateHandler extends TriggerHandlerBase {
	
    public override void mainEntry(TriggerParameters tp) {
        SurveyResponseMethods.updateRollupFields(tp);
    }
}