//-----------------------------
// @author: Tran-Vu Tran
// @date: 24 April 2018
// @param: NA
// @description: Class to hold User Account trigger methods 
// @return: NA
//-----------------------------

public class UserMethods {

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 24 April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-808 Whenever an User record is created, 
    //              this function populates the User's Region field from Address' Country picklist.
    // @return: None
    //------------------------------
    public static void updateUserRegionWhenAddressCountryChanges(TriggerParameters tp) {
        
        try {
            // Map of old values and new values
            List<User> listNewUsers = (List<User>) tp.NewList;
            Map<Id, User> mapOldUsers = (Map<Id, User>) tp.oldMap;

            if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || 
                tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                
                for (User newUser : listNewUsers) {

                    User oldUser = null;
                    
                    if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                        oldUser = mapOldUsers.get(newUser.Id);
                    }

                    if (oldUser == null // this is a new inserted record
                        || (oldUser != null && // for updating an existing user
                            (oldUser.CountryCode != newUser.CountryCode // Country picklist value changed
                             || (oldUser.CountryCode != null && oldUser.UserRegion__c == null))) // or Country was populated but User Region was not
                       ) {
                        
                        // update Region field
                        Country__c country = UtilityClass.getCountryByIsoCode(newUser.CountryCode);
                           
                        if (country != null) {
                            newUser.UserRegion__c = country.Region__c;
                        }
                    }
                }
            }
            
        } catch(Exception ex) {
            //this will happen if any exception apart from DML exception has occurred
           // UtilityClass.createApexLogRecord(ex, 'UserMethods', 'updateUserRegionWhenAddressCountryChanges');
            ApexLogger.logandAddError(new LogMessage('UserMethods','updateUserRegionWhenAddressCountryChanges',ex,tp.newList.get(0),null ));  
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 04 Dec 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9382 Whenever an User record is created, 
    //               It insert a Contact record related to the 'IHS Markit' account.
    // @return: None
    //------------------------------
    public static void createContactForNewUser(TriggerParameters tp) {
        try {
            Set<Id> userIds = new Set<Id>();
            if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                //Fetch the 'IHS Markit' account to associate Contact, if there are no accounts log the errormessage with user Ids
                if(UtilityClass.IHSMarkitAccountList.size() > 0) {
                	//Create Contact only for the 'Salesforce' UserLicense, Since Community users will be created from the Contact.
                    for(User newUser : [SELECT Id,Profile.UserLicense.Name FROM User Where Id IN :tp.NewList]) {
                        if(newUser.Profile.UserLicense.Name == 'Salesforce') {
                            userIds.add(newUser.Id);
                       }
                    }
                    if(userIds.size() > 0) {
                        //Call future method to create Contact to avoid Mixed DML exception
                        System.debug('*********** Creating contact record for New User ***********');
                    	processUserRecordsForContactCreation(userIds,UtilityClass.IHSMarkitAccountList.get(0).Id);    
                    }
                } else {
                    String errDescription = 'Account id not found for Account:'+System.Label.NewUserContactAccount + 'and Type:'+System.Label.NewUserContactAccountType;
                    errDescription += 'for Users' + tp.newMap.keyset();
                    if( errDescription.length() <= 32760){
                        errDescription = errDescription.substring(0,errDescription.length());
                    } else {
                       	errDescription = errDescription.substring(0,32760); 
                    }
                    System.debug(errDescription);    
                   // ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='UserMethods',ErrorDescription__c=errDescription,FunctionName__c='createContactForNewUser');
                    //insert apexLogRecord;
                    ApexLogger.logError(new LogMessage('UserMethods','createContactForNewUser',null,null,errDescription ));  
                }       
            } 
        } catch(Exception ex) {
            System.debug('Exception occured while creating new User '+ex);
            //UtilityClass.createApexLogRecord(ex, 'UserMethods', 'createContactForNewUser');
            ApexLogger.logandAddError(new LogMessage('UserMethods','createContactForNewUser',ex,tp.newList.get(0),null ));  
       } 
    }
    
    @future
    public static void processUserRecordsForContactCreation(Set<Id> userIds , Id accountId) {
        List<Contact> conList = new List<Contact>();
        for(User newUser : [SELECT Id,FirstName,LastName,Email,Title,MobilePhone,Phone,Department,Division,SubDivision__c FROM User Where Id IN :userIds]) {
        	Contact con = new Contact(firstName = newUser.FirstName, 
                                                      lastName = newUser.LastName,
                                                      Email = newUser.Email,
                                                      AccountId = accountId,
                                                      Title = newUser.Title,
                                     				  MobilePhone = newUser.MobilePhone,
                                                      Phone = newUser.Phone,
                                                      Department = newUser.Department,
                                     				  Division__c = newUser.Division,
                                     				  SubDivision__c = newUser.SubDivision__c);
            conList.add(con);    
        }
        if(conList.size() > 0) {
            Database.SaveResult[] srList = Database.insert(conList, false);
            list<apexlogger__c> lstApexlogger = new list<apexlogger__c>();
            for(Integer i=0;i<srList.size();i++) {
                if(!srList.get(i).isSuccess()) {
                    Database.Error error =srList.get(i).getErrors().get(0);
                    String errDescription = 'Error on : ' + conList[i].FirstName+' '+conList[i].LastName + ' : ' +error.getMessage();
                    if( errDescription.length() <= 32760) {
                        errDescription = errDescription.substring(0,errDescription.length());
                    }
                    System.debug('******errDescription ***********'+errDescription);
                    //ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='UserMethods',ErrorDescription__c=errDescription,FunctionName__c='createContactForNewUser');                        
                    //lstApexlogger.add(apexLogRecord);
                    ApexLogger.logError(new LogMessage('UserMethods','createContactForNewUser',null,null,errDescription ));  
                }
           	}
            /*if(!lstApexlogger.isEmpty()) {
                insert lstApexlogger;
            }*/
		}
    }
    
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 09 Nov 2022
    // @param: TriggerParameters tp
    // @description: 5282569-[CROW-A] Auto assign MFA permission set group - IHSM
    // @return: None
    //------------------------------
    /*
    public static void autoAssignPermissionset(TriggerParameters tp) {
        if(!test.isRunningTest() ) {
            try {
                // Map of old values and new values
                List<User> listNewUsers = (List<User>) tp.NewList;
                Map<Id, User> mapOldUsers = (Map<Id, User>) tp.oldMap;
                String adminProfile = System.Label.AdminProfileId;
                String SystemAdminAPIProfile = System.Label.SystemAdminAPIProfile;
                List<PermissionSetAssignment> psAssignList = new List<PermissionSetAssignment>();
                // Fetch Nonadmin PS group 
                PermissionSetGroup nonadminPSGroup = [Select Id, DeveloperName from PermissionSetGroup where DeveloperName ='Standard_NonAdmin_Permissions'];
                //Fetch MFA PS 
                PermissionSet mfaPS = [Select id, Name from PermissionSet where name = 'MultiFactor_Authentication'];
                if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {              
                    for (User newUser : listNewUsers) {
                        PermissionSetAssignment psAssign = new PermissionSetAssignment();
                        //check user type
                        if (newUser.ProfileId == adminProfile || newUser.ProfileId == SystemAdminAPIProfile) {
                            psAssign = new PermissionSetAssignment(AssigneeId = newUser.Id , PermissionSetId = mfaPS.Id ); 
                        } 
                        else {
                            psAssign = new PermissionSetAssignment(AssigneeId = newUser.Id , PermissionSetGroupId = nonadminPSGroup.Id );
                        } 
                        psAssignList.add(psAssign);
                    }
                    
                }
                else if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    Map<String,String> userPSMap = new Map<String,String>();
                    List<PermissionSetAssignment> existingPSAssignment  = [Select Id,AssigneeId,PermissionSetId,PermissionSetGroupId from PermissionSetAssignment where AssigneeId IN:listNewUsers 
                                                                           AND (PermissionSetId =: mfaPS.Id OR PermissionSetGroupId=:nonadminPSGroup.Id )];
                    for(PermissionSetAssignment psObj:existingPSAssignment){
                        if(String.isBlank(psObj.PermissionSetGroupId)) {
                            String key = psObj.AssigneeId + '-' + psObj.PermissionSetId;
                            userPSMap.put(key,psObj.PermissionSetId);                        
                        }
                        else {
                            String key = psObj.AssigneeId + '-' + psObj.PermissionSetGroupId;
                            userPSMap.put(key,psObj.PermissionSetGroupId); 
                        }
                        
                    }                
                    for (User newUser : listNewUsers) {
                        PermissionSetAssignment psAssign = new PermissionSetAssignment();
                        // user is activated
                        if(newUser.IsActive == true && mapOldUsers.get(newUser.Id).IsActive != true){
                            if (newUser.ProfileId == adminProfile || newUser.ProfileId == SystemAdminAPIProfile) {
                                String key = newUser.Id + '-' + mfaPS.Id;
                                if(!userPSMap.containsKey(key)) {
                                    psAssign = new PermissionSetAssignment(AssigneeId = newUser.Id , PermissionSetId = mfaPS.Id ); 
                                    psAssignList.add(psAssign); 
                                }
                            } 
                            else {
                                String key = newUser.Id + '-' + nonadminPSGroup.Id;
                                if(!userPSMap.containsKey(key)) {
                                    psAssign = new PermissionSetAssignment(AssigneeId = newUser.Id , PermissionSetGroupId = nonadminPSGroup.Id );
                                    psAssignList.add(psAssign);
                                }
                            } 
                        }                  
                    }
                }  
                if(psAssignList != null && psAssignList.size()>0) {
                    insert psAssignList;
                }
                
            } catch(Exception ex) {
                ApexLogger.logandAddError(new LogMessage('UserMethods','autoAssignPermissionset',ex,tp.newList.get(0),null ));  
            }
        }
        
    } */
}