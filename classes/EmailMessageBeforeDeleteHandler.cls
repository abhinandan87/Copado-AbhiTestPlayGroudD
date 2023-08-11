//-------------------------------------
// @Author : Mohit Modi
// @Created Date: 21 Aug 2018
// @Description: SFDC1-9218- before delete class for EmailMessage 
//-----------------------------
public class EmailMessageBeforeDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        EmailMessageMethods.preventDeletionEmailMessage(tp);
    }
}