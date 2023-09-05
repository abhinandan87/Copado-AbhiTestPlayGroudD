/**
 * @Author Jagadesh Kumar
 * @Date 20th Dec 2018
 * @Description SFDC1-10588 AfterInsertHandler class for ContractLineItem__c object 
 * @company Vertiba
*/
public class ContractLineItemAfterInsertHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        ContractLineItemMethods.rollupProductInfoToContract(tp);
    }
    
}