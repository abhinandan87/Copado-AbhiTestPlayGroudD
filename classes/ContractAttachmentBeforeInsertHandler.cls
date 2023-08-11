//-----------------------------
// @author: Dev Aggarwal
// @date: 07 November 2019
// @param: TriggerParameters
// @description:  Before dispatcher event handler class that calls the functions in ContractAttachmentMethods.
// @return: NA
//-----------------------------
public class ContractAttachmentBeforeInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        ContractAttachmentMethods.setRecordTypeFromContract(tp);
        ContractAttachmentMethods.creationRestrictionOnContractStage11(tp);
    }
}