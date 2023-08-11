// @author: Sharique
// @date: 6th Oct 2021
// @param: TriggerParameters
// @description:  BeforeDelete dispatcher event handler class that calls the functions in ContractAttachmentMethods.
// @return: NA
//-----------------------------
public class ContractAttachmentBeforeDeleteHandler extends TriggerHandlerBase {    
    public override void mainEntry(TriggerParameters tp) {
       ContractAttachmentMethods.deletionRestrictedWhenContractStage11(tp);   
    }
}