//-----------------------------
// @author: Uttam Arya
// @date: unknown
// @param: NA
// @description: Class to hold Global variables which can be used for different classes 
// @return: NA
// @updated: SFDC1-7592 migrated from Markit legacy codes
// @updateBy: Tran-Vu Tran on 30 March 2018
//-----------------------------

public without sharing class GlobalVariables
{
    public static boolean skipAccountRanking = false;
    
    // keeping the list of accounts waiting to be updated, to avoid being updated multiple times
    public static Set<Id> AccountsWaitingForUpdate = new Set<Id>();
    // To stop oppty trigger from firing multiple times
    public static boolean preventRecursiveTranstion = true;
    // To stop oppty trigger from firing multiple times
    public static boolean preventRecursiveExecution = true;
     /** 
     * SFDC-3071,SFDC-2713 Global Variable
	*/
    public static Boolean shouldContractValidationBypass = false;
    //SFDC-3352 Boolean flag that indicates if execute method in BatchAutoRenewalAutoClose class is running. Created so that partial Opp update transaction in batch does not bypass OM case creation process.
    public static Boolean isExecutingBatchAutoRenewalAutoClose = false;
    
    //SFDC-3403 Boolean flag that indicates if ContractLineItem__c validations should be bypassed. 
    public static Boolean shouldCLIValidationBypass = false;
    //SFDC-3331 Boolean flag to make sure event validations are fired only once in trigger 
    public static Boolean hasEventValidationsFired = false;
    
    //SFDC-4568 Boolean flag to update contractAttachment record while adding a file in it.
    public static Boolean allowContactAttchToUpdate = false;
    
    //SFDC-4516 Boolean flag to allow Sales General profile to update Contract Status
    public static Boolean allowSalesGeneralToUpdateContractStatus = false;
    
    //SFDC-5721 Boolean flag to bypass multiple iterations of methods causing SOQL  error.
    public static Boolean hasrollupValuesToOpportunityCompleted= false;
    public static Boolean hasrollupProductInfoToOpportunityCICompleted= false;
    public static Boolean hasrollupProductInfoToOpportunityCompleted= false;
    
}