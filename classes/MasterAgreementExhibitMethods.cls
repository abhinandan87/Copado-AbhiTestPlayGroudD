/**
* @author Paras Dhingra
* @date 20th Jan 2020
* @description: SFDC-2198 handler class for Master Agreement Exhibit trigger
*/
public class MasterAgreementExhibitMethods {
    /**
    * @author Paras Dhingra
    * @date 20th Jan 2020
    * @description: SFDC-2198 method to validate only one type of MAE is attached to the order form
    */
	public static void validateMAERecords(Triggerparameters tp) {
        List<MasterAgreementExhibit__c> listMAERecords = (List<MasterAgreementExhibit__c>)tp.newList;
        Set<Id> setOrderFormConsultingIds = new Set<Id>();
        Map<Id,String> mapMAEDuplicateKey = new Map<Id,String>();
        Set<String> setMAEDuplicateKey = new Set<String>();
        //traverse the bulk to fetch all related order form and consulting record ids
        for(MasterAgreementExhibit__c mae : listMAERecords) {
            if(mae.OrderFormOrConsulting__c!=null) {
                setOrderFormConsultingIds.add(mae.OrderFormOrConsulting__c);
            }
        }
        //query existing MasterAgreement exhibits related to it
        System.debug('--mapMAEDuplicateKey--'+ mapMAEDuplicateKey);
        List<MasterAgreementExhibit__c> lstExistingRelatedMAEs = [SELECT 
                                                                  Id, 
                                                                  OrderFormOrConsulting__c, 
                                                                  MasterAgreementExhibitType__c
                                                                 FROM MasterAgreementExhibit__c 
                                                                 WHERE OrderFormOrConsulting__c in:setOrderFormConsultingIds ];
        //check if duplicate is found
        if(lstExistingRelatedMAEs!=null && !lstExistingRelatedMAEs.isEmpty()) {
            for(MasterAgreementExhibit__c mae: lstExistingRelatedMAEs) {
                setMAEDuplicateKey.add(mae.OrderFormOrConsulting__c + mae.MasterAgreementExhibitType__c);
            }     
            for(MasterAgreementExhibit__c mae : listMAERecords) {
                //Duplicate found
                if(setMAEDuplicateKey.contains(mae.OrderFormOrConsulting__c + mae.MasterAgreementExhibitType__c)) {
                    //add error for user to be displayed on page
                    mae.addError('An exhibit of type '+ mae.MasterAgreementExhibitType__c + ' already attached to this Contract');
                }
            }
        }
        
    }
}