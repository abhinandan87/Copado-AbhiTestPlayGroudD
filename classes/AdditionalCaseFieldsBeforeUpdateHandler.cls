//-----------------------------
// @author: Vaishali Jain
// @date: 08 April 2021
// @param: TriggerParameters
// @description:  Before update dispatcher event handler class that calls the functions in AdditionalCaseFieldsMethods.
// @return: NA
//-----------------------------
public class AdditionalCaseFieldsBeforeUpdateHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        AdditionalCaseFieldsMethods.NotesMandatoryForResolvedbyIHSMarkitOPSTeam(tp);
    }
}