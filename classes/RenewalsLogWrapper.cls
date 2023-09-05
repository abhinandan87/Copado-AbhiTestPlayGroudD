//-----------------------------
// @author: Harshit Singhal
// @date: 24 Aug 2020
// @description: SFDC-3186 Wrapper class to log results of Renewal Opportunities Automation batch job.
//-----------------------------
public class RenewalsLogWrapper {
    
    public RenewalStaging__c stagingObj;
    public Boolean isSuccess, isSuccessOpp, isSuccessOLI, isSuccessOCR, isSuccessOppSplit, isSuccessOppTeam;
    public Boolean isInValidOpp, isInValidOppProducts, isInValidContract, isOwnerInactive, hasNoSubscriptionProd, hasAnyNonFinProd, hasMixedProducts, hasOneTimeContract, hasNonBillableEvergreenContract, renewalPreExists, isProcessed, isError, isException,hasNoValidConsultingProducts, isConsultingContract, isOrderFormContract;
    public String exceptionReason, errorReason;
        
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Aug 2020
    // @param: None
    // @description: Constructor to initialise the values
    // @return: None
    //------------------------------
    public RenewalsLogWrapper() {
        isSuccess = false;
        isSuccessOpp = false;
        isSuccessOLI = false;
        isSuccessOCR = false;
        isSuccessOppSplit = false;
        isSuccessOppTeam = false;        
        isInValidOpp = false;
        isInValidOppProducts = false;
        isInValidContract = false;
        isOwnerInactive = false;
        hasNoSubscriptionProd = false;
        hasAnyNonFinProd = false;
        hasMixedProducts = false;
        hasOneTimeContract = false;
        hasNonBillableEvergreenContract = false;
        renewalPreExists = false;
        isProcessed = false;
        isError = false;
        isException = false;
        exceptionReason = '';
        errorReason = '';
        hasNoValidConsultingProducts = false;
        isConsultingContract = false;
        isOrderFormContract = false;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Aug 2020
    // @param: None
    // @description: Method to set fields(that represent success/error/exception of opp renewal process) on RenewalStaging__c record from wrapper variables
    // @return: RenewalStaging__c(Updated renewal staging record)
    //------------------------------
    public RenewalStaging__c getFinalStagingRecord() {
        if(stagingObj!=null) {
            stagingObj.Opportunity_Success__c = isSuccessOpp;
            stagingObj.OpportunityProductSuccess__c = isSuccessOLI;
            stagingObj.OpportunityContactRoleSuccess__c = isSuccessOCR;
            stagingObj.OpportunitySplitSuccess__c = isSuccessOppSplit;
            stagingObj.OpportunityTeamSuccess__c = isSuccessOppTeam;
            stagingObj.Success__c = isSuccess;
            
            stagingObj.OpportunityOwnerInactive__c = isOwnerInactive;
            stagingObj.HasNoSubscriptionProduct__c = hasNoSubscriptionProd;            
            stagingObj.hasNoValidConsultingProducts__c = hasNoValidConsultingProducts;
            stagingObj.HasMixedProducts__c = hasMixedProducts;
            stagingObj.HasOneTimeContract__c = hasOneTimeContract;
            stagingObj.HasNonBillableEvergreenContract__c = hasNonBillableEvergreenContract;
            stagingObj.RenewalPreexists__c = renewalPreExists;
            
            stagingObj.Exception__c = isException;
            stagingObj.ExceptionDescription__c = exceptionReason;            
            stagingObj.Error__c = isError;
            stagingObj.ErrorDescription__c = errorReason;
            
        }
        return stagingObj;
    }
}