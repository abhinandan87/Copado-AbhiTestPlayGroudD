//***************************************
// @author Jagadesh Kumar
// @date 04 Dec 2018
// @description SFDC1-405 Implementation of Trigger framework.
//***************************************
public class UserAfterInsertHandler extends TriggerHandlerBase {
    
	public override void mainEntry(TriggerParameters tp) {
        UserMethods.createContactForNewUser(tp);
       // UserMethods.autoAssignPermissionset(tp);
    }
}