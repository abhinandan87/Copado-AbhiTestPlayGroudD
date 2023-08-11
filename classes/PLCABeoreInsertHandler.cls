//***************************************
// @author Vishnu Vardhan Chowdary
// @date 17 Dec 2018
// @description SFDC1-10703 Implementation of Trigger framework.
//***************************************
public class PLCABeoreInsertHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        ProductLoginContactAssociationMethods.populateUniqueProductLoginContactId(tp); 
    }
}