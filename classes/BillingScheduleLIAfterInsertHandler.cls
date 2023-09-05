//-----------------------------
// @author: Mohit Modi
// @date: 16 April 2018
// @description: This Class will hold all the methods related to Billing Schedule Line Items for afterInsert.
// @Last Modified By: Sruti Srivastava
// @Modification: SFDC1-9599- Added method rollupValuesToContractLineItem to be called after insert
// @Last Modified Date: 4 Sept 2018
// @return: None
// @Updatedescription : added 'CreateCloneBillingScheduleLIFromCLIandPreventBSLICreation' method to create the clone of BSL based on CLI Billing Period value.
//------------------------------
public class BillingScheduleLIAfterInsertHandler extends TriggerHandlerBase {
  
    public override void mainEntry(TriggerParameters tp) {
        BillingScheduleLineItemMethods.CreateCloneBillingScheduleLIFromCLIandPreventBSLICreation(tp);
        BillingScheduleLineItemMethods.rollupValuesToContractLineItem(tp);
    }
}