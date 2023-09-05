//-----------------------------
// @author: Ankita Singh
// @date: 06 March 2018
// @description: SFDC1-4702. Creating this class to handle after update event.
// @companyname: VERTIBA
// @ModifiedBy: Tran-Vu Tran
// @ModifiedDate: 22 Oct 2018
// @ModifiedDescription: SFDC1-9347 add method to update Account Relationship according to related Opportunities and Contracts
// @companyname: IHS Markit
//-----------------------------
public class ContractAfterUpdateHandler extends TriggerHandlerBase {
    //-----------------------------
    // @author: Ankita Singh
    // @date: 06 March 2018
    // @description: SFDC1-4702. Handler class called by the trigger framework to carry out the specific actions on
    //    Contract object after update
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @companyname: VERTIBA
    // @return: void
    //
    // @author: Vishnu Vardhan
    // @date: 10 May 2018
    // @description: SFDC1-7738. Adding entry to call createOrModifyOMCasesForOrderFormContracts
    // 
    // @author: Sruti Srivastava
	// @date: 11th May 2018
	// @description: SFDC1-7855-Adding entry to call updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted	
	// 
	// @updated by: Harshit Singhal
	// @updated date: 26 Jun 2018
	// @update description: SFDC1-8533 Added following method calls
	// 							1) updateTotalAnnualContractValueOnOpp()
	// 							2) updateOpptyContractStartEndDates()
	// 							3) updateCurrencyOnContractLineItems()
	// 							4) updateStageOnOpp() - to update Stage to 6W on 'Gratis','New Business','Renewal','Forecasting Placeholder' Opportunity records if related Order Form Contract's Status is changed to 'Ready For Processing'
	// 							5) updateAgreementEffectiveDateOnOrderFormAgreements()
    // @last Modified by : Mohit Modi
    // @last modified description :30 Oct 2018 , SFDC1-10188 : Field 'Total Annual Contract Value' [TotalAnnualContractValue__c] added to Deletion list, So Commenting this Method.
    // @modified : Paras Dhingra
    // @modifiedDate: 3rd April 2020
    // @description: removing updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted as it is no longer needed as per SFDC-2396
	// @Modified by : Madhusudhan Karna
    // @modifiedDate : 04 Dec 2020
    // @description: SFDC-2693 AutoRenewStopped Should be synced to opportunity auto-renewal stopped field from contract auto-renewal stopped field
    // @Modified by : Neelam agrawal
    // @modifiedDate : 17 Nov 2021
    // @description: SFDC-4987: Update ReadyForProcessingContractExist__c field on Opp when Contract stage move backword
    //-----------------------------
    public override void mainEntry(TriggerParameters tp) {
        ContractMethods.createCaseFromContract(tp); 
        ContractMethods.updateCaseAndOppoStatusContract(tp);
        //ContractMethods.updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted(tp);
        ContractMethods.updateAddressOnRenewalOppty(tp);
       // ContractMethods.updateTotalAnnualContractValueOnOpp(tp);
        ContractMethods.updateOpptyContractStartEndDates(tp);   
        ContractMethods.updateCurrencyOnContractLineItems(tp);
        ContractMethods.updateStageOnOpp(tp);
        ContractMethods.updateAgreementEffectiveDateOnOrderFormAgreements(tp);
		ContractMethods.updateDefaultContractCumulative(tp);
        ContractMethods.updateAccountRelationship(tp);
        ContractMethods.removeMasterAgreementExhibitOnFastrack(tp);
        ContractMethods.updateOpptyAutoRenewStopped(tp);
        ContractMethods.createOrModifyOMCasesForOrderFormContracts(tp);
        ContractMethods.updateAccountContractsCount(tp);
        ContractMethods.updateFieldOnOppOnContractStageChange(tp);
    }
}