//-------------------------------------
// @Author : Sruti Srivastava
// @Created Date: 27 June 2018
// @Description: SFDC1-8538- AfterInsert class for EmailMessage 
//-----------------------------
public class EmailMessageAfterInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        if(System.Label.MigrationSwitchOffReopenCases=='FALSE') {
            EmailMessageMethods.updateCaseStatusAndReExecuteCaseAssignmentRules(tp);
            EmailMessageMethods.completeFirstResponseAssignment(tp);
        }
        
    }
}