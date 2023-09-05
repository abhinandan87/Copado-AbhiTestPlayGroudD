//-----------------------------
// @author: Akshay Dogra
// @date: 30 July 2021
// @param: TriggerParameters
// @description:  Dispatcher event handler class that calls the functions in ContractProductAlliancePartner.
// @return: NA
//-----------------------------
public class ContractProdAllianceBeforeInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        ContractProductAlliancePartnerMethods.restrictDuplicateRecord(tp);  
    } 
}