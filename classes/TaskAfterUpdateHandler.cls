//-----------------------------
// @author: Priyanka
// @date: 26 Aug 2020
// @param: TriggerParameters
// @description: SFDC-3133 AfterUpdate dispatcher task handler class that calls the functions in TaskMethods.
// @return: NA
//-----------------------------
public class TaskAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
       TaskMethods.changeActivityCreatedCheckboxOnOpportunity(tp);
    }
}