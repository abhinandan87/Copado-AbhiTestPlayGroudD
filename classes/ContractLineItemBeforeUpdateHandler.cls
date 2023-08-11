/**
 * @Author Harshit Singhal
 * @Date 05 Oct 2020
 * @Description SFDC-3403 BeforeUpdateHandler class for ContractLineItem__c object
 * @company Vertiba
*/
public class ContractLineItemBeforeUpdateHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        ContractLineItemMethods.lockCLIForCompletedContracts(tp);
    }
}