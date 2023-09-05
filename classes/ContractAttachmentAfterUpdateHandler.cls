//-----------------------------
// @author: Dev Aggarwal
// @date: 07 November 2019
// @param: TriggerParameters
// @description:  AfterUpdate dispatcher event handler class that calls the functions in ContractAttachmentMethods.
// @return: NA
//-----------------------------
public class ContractAttachmentAfterUpdateHandler extends TriggerHandlerBase {    
    public override void mainEntry(TriggerParameters tp) {
        ContractAttachmentMethods.updateContinuationContracts(tp);
    }
}