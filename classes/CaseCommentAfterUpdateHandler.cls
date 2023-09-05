//-------------------------------------
// @Author : Digvijay Singh
// @Created Date: 23 March 2021
// @Description: SFDC-3511- After Update   class for Case Comments 
//-----------------------------
public  class CaseCommentAfterUpdateHandler  extends TriggerHandlerBase {

    public override void mainEntry(TriggerParameters tp) {
        CaseCommentMethods.updateFieldOnCaseOnNewComment(tp);  
        
    }
}