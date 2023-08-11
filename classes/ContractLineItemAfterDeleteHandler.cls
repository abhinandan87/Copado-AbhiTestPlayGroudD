/**
 * @Author Jagadesh Kumar
 * @Date 20th Dec 2018
 * @Description SFDC1-10588 AfterDeleteHandler class for ContractLineItem__c object 
 * @company IHS Markit
 * 
 */
public class ContractLineItemAfterDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        ContractLineItemMethods.rollupProductInfoToContract(tp);
    }
    
}