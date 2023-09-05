//--------------------------------
// @Author: Sruti Srivastava
// @Date: 4 Sept 2018
// @Description: SFDC1-9599: Handler method for Billing Schedule Line Item to run after records are deleted
// @Return: None
// @Company: Vertiba
//--------------------------------
public class BillingScheduleLIAfterDeleteHandler extends TriggerHandlerBase {
  
    public override void mainEntry(TriggerParameters tp) {
        BillingScheduleLineItemMethods.rollupValuesToContractLineItem(tp);
    }
}