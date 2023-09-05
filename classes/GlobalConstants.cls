//-----------------------------
// @author: Prachi Bhasin
// @date: 5 July 2017
// @param: NA
// @description: Class to hold Global contants which can be used for different classes 
// @return: NA
// @Modification : exemption for sys admin and sales ops profile removed as per SFDC1-5782 and SFDC1-5029
// @Modified by : Ankita Singh on 4th December,2017 
//-----------------------------
public class GlobalConstants {

 /*   public static boolean isPrimaryContactValidationRequired{
        get{
            if (isPrimaryContactValidationRequired == null){
                isPrimaryContactValidationRequired=true;
                List<Profile> lstProfiles = [Select name from Profile where id=:UserInfo.getProfileId()];
                system.debug('lstProfiles --'+lstProfiles );
                if(lstProfiles.size()>0){
                    Profile p = lstProfiles.get(0);
                if(p.Name.ContainsIgnoreCase('System Admin') || p.Name.ContainsIgnoreCase('IHSMarkit Sales: Sales Ops'))
                     isPrimaryContactValidationRequired = false;
                }
            }
            return isPrimaryContactValidationRequired ;           
        }
        set;
    }  */
    
    /*
    ** used in CreateCaseForSalesLedCampaign class
    ** As we are not deployin the processes via ant deployment, we have to deploy the process and related classes separately. Using this, we can deploy the classes w/o process being deployed
    ** and use the static variable state to check the assertion conditionally. 
    ** For each process separate variable should be created and set to True in the class which gets called from process. 
    */
    
    public static boolean hasCreateCaseForSalesLedCampaignprocessfired = false;
    
    /*
    ** used in UpdateActiveContractOnRenewalOpp6W class
    ** As we are not deploying the processes via ant deployment, we have to deploy the process and related classes separately. Using this, we can deploy the classes w/o process being deployed
    ** and use the static variable state to check the assertion conditionally. 
    ** For each process separate variable should be created and set to True in the class which gets called from process. 
    */
    public static boolean hasUpdateActiveContractOnRenewalOpp6WProcessFired = false;
    
    /*
    ** used in SetAutoCloseDateForRenewalOpportunity class
    ** As we are not deploying the processes via ant deployment, we have to deploy the process and related classes separately. Using this, we can deploy the classes w/o process being deployed
    ** and use the static variable state to check the assertion conditionally. 
    ** For each process separate variable should be created and set to True in the class which gets called from process. 
    */
    public static boolean hasAutoCloseRenewalOpportunityFired = false;
    
    /*
    ** used in OpportunityLineItemMethods class in preventOpportunityLineItemDeletion Method
    ** This Boolean will be used to bypass the deletion of Opportunity Products by any user. This will be used in many of the methods, where we need to allow the deletion of Opportunity Products.
    */
    public static boolean hasAllowedOpportunityProductDeletion = false;
    /*
    ** SFDC1-7082: Added to prevent rescursion of rollup opportunity product schedules
    **
    */
    public static Boolean preventOpportunityProductScheduleUpdate = false;
    /*
    ** SFDC1-8423: Added to prevent calling opportunity trigger twice
    **
    */
    public static Boolean hasUpdatedProductSchedules = false;
    
    /*
    ** SFDC1-9020 Added to Check whether the Implementation case validation is done or not while insert.
	** Insertion will happen from ContractMethods(While Case update to Validate) and CaseMethods(Direct insert while new Case creation)
    */
    public static Boolean hasImplementationCaseValidated = false;
	
	/*
    ** SFDC1-7060 Added to prevent opportunity validation firing when rolling up from opportunitylineItem
    */
    
    public static Boolean hasTriggeredFromOpportunityProduct = false;
    
    /*
    ** SFDC1-7060 Boolean flag to make sure opportunity validations are fired only once
    */
    public static Boolean hasBeenValidatedOnce = false;
    /*
    ** SFDC1-7060 Boolean flag to make sure opportunity validations are fired only once
    */
    public static Boolean disableOppyProductValidations = false;
     /*
    ** Check if logged in user has ignorevalidationrule permission set
    */
    public static Boolean hasIgnoreValidationPermission = FeatureManagement.checkPermission('IgnoreCaseValidationRules');
    /*
    ** SFDC1-9781 Boolean flag to make sure Create one Implementation Case when Markit Auto-Renewal is move to 6W-Renewal Won
    */
    public static Boolean hasImplementationCaseInsertedForPOD = false;

    /**
     * SFDC1-10184 Making sure that createImplCaseForLostProductsOnRenewalOpp6W in 
     * Opportunity Methods is executed only once.
     */
    public static Boolean hasImplCaseForLostProductsOnRenewalOpp6WExecuted = false;

    /**
     * When Product group and product family is changed from Rest API/Workbench, then 
     * SetAdditionalCaseFields is executed twice, and is trying to create two cases 
     * and is causing to fail. 
     */
    public static Boolean hasAdditionalCaseFieldsCreationExecuted = false;
    
    /**
     * SFDC-2417 Flag to stop rollup methods in OLI trigger which update parent opp from Opp Line Items. 
     * This is used when the update on opp line itesm is a result of cascade updates from parent opportunity 
     */    
    public static Boolean isOppLineItemUpdatedDueToParentOppCascade = false;
    
    /** 
     * SFDC-2417: Moved Inner Year OLI update Validation Rule to code. 
     * Creating a global constant to check AllowInnerYearOpptyLineItemUpdate permission on user and bypass validation.
	*/
    public static Boolean hasInnerYearOLIUpdatePermission = FeatureManagement.checkPermission('AllowInnerYearOpptyLineItemUpdate');
    
    /**
     * SFDC-2799: Enhanced Sales Permission
     * Creating a global constant to check Enhanced Sales Permssion
    */
    public static Boolean hasEnhancedSalesPermission = FeatureManagement.checkPermission('EnhancedSalesPermission');
    
    /** 
     * SFDC-2669: Flag to stop rollup method in OpportunityLineItemScheduleMethod class. 
     * Rollup method needs to be shutdown in case we are updating OpportunityLineItemSchedule from OpportunityLineItem.
	*/
    public static Boolean runRollupOpportunityLineItemSchedule = false;
    
    /** 
     * SFDC-2748: Global variable to be set to true when EventMethods.createMeetingNote() is running. 
     * This is to skip code validation in EventMeetingNoteSyncUtility.cannotUpdateMeetingNoteManually() method.
	*/
    public static Boolean isCreateMeetingNoteMethodExecuting = false;

    /**
     * SFDC-3032: AccountGovernance
     * Creating a global constant to check AccountGovernance
    */
    public static Boolean hasAccountGovernancePermission = FeatureManagement.checkPermission('AccountGovernance');
    /**
     * SFDC-3032: AccountGovernance
     * Creating a global constant to check AccountGovernance
    */
    public static Boolean updatingAccountOwnerFromTrigger = false;

    /**
     * SFDC-3278 Global constant to bypass validation on contract start and contract end date
     */
    public static Boolean byPassContractValidationDates = false;
    /**
     * SFDC- 3458 Global constant to reference IHS Markit Customer care queue and replace FM customer care queue with it
     */
    public static String iHSMarkitCustomerCareQueueLabel = System.Label.IHSMarkitCustomerCareQueue;
    /**
     * SFDC-1994 Update the Current Annual Value logic. Adding variable for History status
     */
    public static final String FIXED_FEE_HISTORY_STATUS = 'History';
    public static final String CONTRACT_LINE_ITEM_LOST_STATUS = 'Lost';
}