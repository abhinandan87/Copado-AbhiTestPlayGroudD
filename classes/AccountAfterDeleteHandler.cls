//***************************************
// @author Uttam Arya
// @date 7th Feb 2017
// @description Re-structuring the trigger methods by using Trigger Handler framework. Org assessment 2016.   
// @Last Modified By : Madhusudhan Karna
// @Last Modified Date : 02 March 2021
// @Last Modified Description : SFDC-3599 - Delete AAF when an Account is merged or deleted 
//***************************************
public class AccountAfterDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
     Accountmethods.deleteAdditionalAccountRecords(tp);    
     Accountmethods.updateOpenContractAddress(tp);
     Accountmethods.updateContractCountOnMergedAccount(tp);
     Accountmethods.updateAtmNamesOnMergedAccount(tp);   
    }
}