/**
 * @Author : Mohit Modi
 * @Date : 14 Nov 2017
 * @Description : SFDC1-5723 Method to check the Record access for the given user, This Class will be used in multiple Lightning Components
 *    to check the record access before proceed further.
 * @company : Vertiba
 */
public class ProductSelectorController {

    /**
     * @author : Mohit Modi
     * @date : 14 Nov 2017
     * @description : SFDC1-5723 Method to check the Record access for the given user
     * @param : User Id, Record Id
     * @return : Boolean
     * @companyname : Vertiba
     * @Last Modified By : Prachi Bhasin
     * @Last Modified Date: 23 April 2018
     * @Last Modified Description: SFDC1-6568 -When oppty stage is 6WP, nobody should be able to add products
	 * @Last Modified By : Jagadesh Kumar
     * @Last Modified Date: 08 May 2018
     * @Last Modified Description: SFDC1-7676 -Inner Year Record
     * @Last Modified By : Jagadesh Kumar
     * @Last Modified Date: 04 June 2018
     * @Last Modified Description: SFDC1-8505 -In order to add new products to an Auto Renewal, you must first click the Change Auto Renew? button.
     * 
     * @Last Modified By : Tran-Vu Tran
     * @Last Modified Date: 05 March 2019
     * @Last Modified Description: SFDC-701 Allow Sales Ops to edit Opportunity Products on any Sales Stage including 6WP
     * @Last Modified By : Harshit Singhal
     * @Last Modified Date: 23 Jul 2020
     * @Last Modified Description: SFDC-3072 Add User Support profile to exclusions already existing for Sales Ops
     * @Last Modified By : Sharique Iqbal
     * @Last Modified Date: 13 Mar 2021
     * @Last Modified Description: SFDC-3412 Enable Edit Product button for Sales Profile when Auto Renewal doesn't have any changes
     * @Last Modified Date: 18 Oct 2021
     * @Last Modified Description: SFDC-4731 Method to check whether previous Exception Request is in progress or not
     */
     @auraEnabled
     public static ProductSelectorValidatorWrapper checkRecordAccessforUser (Id usrId, id recordId, String actionType) {
         Boolean accessresult = UtilityClass.checkRecordAccessforUser(usrId, recordId);
         Opportunity opp = [Select id, StageName,RecordType.Name,AutoRenewal__c,DoesThisAutoRenewalHaveChanges__c,PriceChangeOnly__c from Opportunity where id=:recordId];
         String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
         ProductSelectorValidatorWrapper wrapper = new ProductSelectorValidatorWrapper();
         System.debug('ProfileName'+profileName);
         Boolean finalResult;
         
         if (!accessresult /*&& actionType == 'Add Products'*/) {
             //user does not have edit access to opportunity
             wrapper.isSuccess = false;
             wrapper.validationMessage = 'You don\'t have access to add/edit products on this Opportunity.';
             return wrapper;// return from here as no further checks are required
         }
         wrapper.isSuccess = true; //setting access level to true as user has edit access to opportunity
         
         if (accessresult) {
             if (opp.StageName == '6WP-Closed Won/Order Processed' 
                 && !profileName.contains('System Administrator') 
                 && !profileName.contains('IHSMarkit System Admin')
                 && !profileName.contains('User Support')
                 && !profileName.contains('Sales Ops')) { //SFDC-701 Allow Sales Ops to edit Opportunity Products on any Sales Stage including 6WP
                    wrapper.isSuccess = false;
                    wrapper.validationMessage = 'You don\'t have access to add/edit products on a closed Opportunity.';
                    return wrapper;
                 }
             
             // Inner Year record Check
             if (opp.RecordType.Name == 'Inner Year' && !profileName.contains('System Administrator') && !profileName.contains('IHSMarkit System Admin') && !profileName.contains('Sales Ops') && !profileName.contains('User Support') && !GlobalConstants.hasEnhancedSalesPermission) {
                 wrapper.isSuccess = false;
                 wrapper.validationMessage = 'You don\'t have access to add/edit products on an Inner Year Opportunity.';
                 return wrapper;
             }
             
             if (actionType == 'Add Products' && opp.AutoRenewal__c && !opp.DoesThisAutoRenewalHaveChanges__c && opp.RecordType.Name == 'Renewal') {
                 wrapper.isSuccess = false;
                 wrapper.validationMessage = 'In order to add new products to an Auto Renewal, you must first click the "Amend Auto Renewal" button.'; 
             }
             
             //adding check for price change auto-renewal opportunities
             if (actionType == 'Edit Products'
                 && opp.AutoRenewal__c
                 && !opp.PriceChangeOnly__c
                 && !opp.DoesThisAutoRenewalHaveChanges__c 
                 && opp.RecordType.Name == 'Renewal'
                 && !profileName.contains('System Admin')
                 && !profileName.contains('Global Account Manager')
                 && !profileName.contains('Product Manager')
                 && !profileName.contains('Sales Coordinator')
                 && !profileName.contains('Sales Ops')
                 && !profileName.contains('General')) {
                 wrapper.isSuccess = false;
                 wrapper.validationMessage = 'Auto renewal opportunities cannot be updated. Please use "Amend Auto Renewal" button';
             }
         }
         
         return wrapper;
     }
     
     /**
     * @author : Paras Dhingra
     * @date : 20 Nov 2017
     * @description : SFDC1-5824 Method to check whether user is logged in from community or not
     * @param : void
     * @return : Boolean
     * @companyname : IHS Markit
     */
    @auraEnabled
    public static boolean isCommunity() {        
		return UtilityClass.isCommunity();
	}
    
    public class ProductSelectorValidatorWrapper {
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String validationMessage;
        
    }
    
    /**
     * @author : Manish Kumar
     * @date : 18 Oct 2021
     * @description : SFDC-4731 Method to check whether previous Exception Request is in progress or not
     * @param : String
     * @return : String
     * @companyname : IHS Markit
     */
    @auraEnabled
    public static String exceptionRequestCheck (string oppyId) {
        String excepRequest = '';
        Opportunity oppy = [Select ExceptionStatus__c from Opportunity where id = :oppyId];
        excepRequest = oppy.ExceptionStatus__c;
        return excepRequest; 
    }
     
}