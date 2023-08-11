/**
 * @Author Jagadesh Kumar
 * @Date 20th Dec 2018
 * @Description SFDC1-10588 AfterUpdateHandler class for ContractLineItem__c object 
 * @company Vertiba
 */
public class ContractLineItemAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        ContractLineItemMethods.rollupProductInfoToContract(tp);
    }
    
}