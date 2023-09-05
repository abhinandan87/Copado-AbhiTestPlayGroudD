/**
* @author: Mohit Modi
* @date: 27 September 2017
* @description: SFDC1-4363. Before Update dispatcher event handler class that calls the functions in ContractMethods.
* @companyname: VERTIBA
* @lastModifiedBy: Prachi Bhasin
* @lastModifiedSprint: Sprint 26 SFDC1-8056 added call to method updatePGIOwnerField
*/
public class ContractBeforeUpdateHandler extends TriggerHandlerBase {
    /** 
    * @author: Mohit Modi
    * @date: 27 September 2017
    * @description: SFDC1-4363. Handler class called by the trigger framework to carry out the specific actions on
    *    Contract object before Update
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * 
    * @updated by: Harshit Singhal
    * @updated date:21 Jun 2018
    * @updated description: SFDC1-8533 Added call to setOpptyOwnerEmail() method
    * 
    * @updatedBy: Tran-Vu Tran
    * @updatedDate: 22 Apr 2019
    * @updatedDescription: SFDC-1362 Added call to updateThirdPartyContractAddressFromProcessorLegalEntity() method
    * 	and commented out call for updateAddressFieldsOnContractFromProcessorLegalEntity() method
    * 
    * @updatedBy: Harshit Singhal
    * @updatedDate: 09 Sep 2019
    * @updatedDescription: SFDC-1973 Added method call contractCheckASC606RevRecProductValidation()
    * 
    * @return: void
    */
    public override void mainEntry(TriggerParameters tp) {
        ContractMethods.CopyPrimaryContactToContract(tp);
        ContractMethods.updatePGIOwnerField(tp);
        ContractMethods.updateCountersignatureFields(tp);
        ContractMethods.updateNoticeAddressFieldsOnContractFromLegalEntity(tp);
        ContractMethods.updateClientStateOfIncorporationFromClientLegalEntity(tp);
        ContractMethods.populateBillToFieldsonContractwithGlobalAllianceFields (tp); 
        //ContractMethods.validateLegalEntityOnContract(tp);
        ContractMethods.setOpptyOwnerEmail(tp);
        ContractMethods.updateThirdPartyContractAddressFromProcessorLegalEntity(tp);
        ContractMethods.contractCheckASC606RevRecProductValidation(tp);
        ContractMethods.blockSalesGeneralOnCompletedContract(tp);
        ContractMethods.masterAgreementExhibitCheck(tp);
        ContractMethods.validateContractDateChanges(tp);
        ContractMethods.updateRenewalOwner(tp);
        ContractMethods.autoPolupatePriceIncreaseReviewDate(tp);
        ContractMethods.populateStatusRejectionInfo(tp);
        ContractMethods.lastStatusChangeDateUpdate(tp);
        ContractMethods.automateRenewalFields(tp);
    }
}