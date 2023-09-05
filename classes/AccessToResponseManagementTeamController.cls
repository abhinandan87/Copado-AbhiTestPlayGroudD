/*
* @Author : Sharique
* @date: 31/01/2022
* @description : Update 'Associated with Response Management Team' field
                 on Opportunity via LWC by Response Management Team
* @company : IHS Markit
*/
public without sharing class AccessToResponseManagementTeamController {
    
    static Boolean TgCustomSettingExists = false;
    static Boolean VrCustomSettingExists = false;
    
    @AuraEnabled
    public static string updateAssociatedWithResMmtTeam(string oppyId, Boolean value) {
        String message = '';
        Opportunity oppy = new Opportunity(Id=oppyId);
        Id currentUserId = UserInfo.getUserId();

        try{
            if(oppyId!=null) {
        		oppy.AssociatedwithResponseManagementTeam__c = value;
                
                /* Allow current user (Response Management Team) 
                  to bypass Oppy trigger and Validation rule to update AssociatedwithResponseManagementTeam__c field.*/
                bypassTriggerAndValidationRules(currentUserId,'Insert');
        		update oppy;
                bypassTriggerAndValidationRules(currentUserId,'Delete');
    		}
            // Split this message in Javascript by ':', get the first value(Success/Error) as Variant for Toast Message. 
            message = 'Success:'+System.Label.SuccessMessageAfterRecordUpdate;
        }
        catch(Exception e) {
        	if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
        	message = 'Error:'+e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':');
            } else if (e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
        	message = 'Error:'+e.getMessage().substringBetween('FIELD_FILTER_VALIDATION_EXCEPTION,',':');
            } 
            else  message = 'Error:'+e.getMessage();
        }
        finally  {
            bypassTriggerAndValidationRules(currentUserId,'Delete');
        }
        return message;
    }
    
    
    /*This methods will create/delete SystemMutedValidationRules and SystemMutedTriggers 
     * Custom Setting records before/after operation on opportunity.*/
       
    public static void bypassTriggerAndValidationRules(Id userId, String Operation) {
        if (Operation == 'Insert') {
               SystemMutedValidationRules__c smve = SystemMutedValidationRules__c.getInstance(userId);
              if (smve.Id == null) {
                smve.Opportunity__c = true;
                insert smve; 
              } else if (!smve.Opportunity__c) {
                smve.Opportunity__c = true;
                VrCustomSettingExists = true;
                update smve;
              }
            SystemMutedTriggers__c smt = SystemMutedTriggers__c.getInstance(userId);
              if (smt.Id == null) {
                smt.Opportunity__c = true;
                insert smt; 
              } else if(!smt.Opportunity__c) {
                smt.Opportunity__c = true;
                TgCustomSettingExists = true;
                update smt;
              }
        } 
        if (Operation == 'Delete') {
            SystemMutedValidationRules__c smve = SystemMutedValidationRules__c.getInstance(userId);
            if (!VrCustomSettingExists && smve.Id!=null) {
                delete smve;
            }  
            SystemMutedTriggers__c smt = SystemMutedTriggers__c.getInstance(userId);
            if (!TgCustomSettingExists && smt.Id!=null) {
                delete smt;
            }  
        }  
   }     

}