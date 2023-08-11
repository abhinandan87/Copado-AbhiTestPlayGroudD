/**
 * @Author Digvijay Singh
 * @Date 3 May 2021
 * @Description SFDC-4069 DeleteHandler class for ContractLineItem__c object 
 * @company IHS Markit
 * 
 */
public class ContractLineItemBeforeDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        ContractLineItemMethods.preventContractLineItemDeletion(tp);
    }
    
}