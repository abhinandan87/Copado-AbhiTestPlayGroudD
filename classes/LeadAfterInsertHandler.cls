/**
* @author: Tran-Vu Tran
* @date: 12 Sep 2018
* @description: This class contains Lead after-insert method calls
*/

public class LeadAfterInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {

        LeadMethods.updateAccountGovernanceCaseLeadReference(tp);
        LeadMethods.useDefaultAssignmentRule(tp);
    }
}