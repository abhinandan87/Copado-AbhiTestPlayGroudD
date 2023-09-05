/***************************************
// @author Vaishali Jain
// @date 29th July 2021
// @description Implementation of Trigger framework. 
//***************************************/
public class FSATriggerAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        FieldServiceActivityMethods.updateFSAAttendeeUsers(tp);
    }
}