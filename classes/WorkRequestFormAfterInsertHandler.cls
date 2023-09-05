//-----------------------------
// @author: Anjali
// @date: 24 May 2021
// @param: Trigger events
// @description:  AfterInsert dispatcher event handler class that calls the functions in WorkRequestFormMethods.
// @return: NA

//-----------------------------
public class WorkRequestFormAfterInsertHandler extends TriggerHandlerBase{
    public override void mainEntry(TriggerParameters tp) {
        WorkRequestFormMethods.createOppyWrkRequest(tp); 
    }
    

}