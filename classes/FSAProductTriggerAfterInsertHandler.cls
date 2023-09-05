//***************************************
// @author Vaishali Jain
// @date 4th Junw 2021
// @description Implementation of Trigger framework. 
//***************************************/
public class FSAProductTriggerAfterInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        FSAProductMethods.updateFSAProductGroups(tp);
    }
}