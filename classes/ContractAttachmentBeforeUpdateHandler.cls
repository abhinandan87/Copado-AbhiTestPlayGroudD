//-----------------------------
// @author: Sharique Iqbal
// @date: 06 Oct 2021
// @param: TriggerParameters
// @description:  Before dispatcher event handler class that calls the functions in ContractAttachmentMethods.
// @return: NA
//-----------------------------
public class ContractAttachmentBeforeUpdateHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        ContractAttachmentMethods.updateRestrictionOnContractStage11(tp);
    }
}