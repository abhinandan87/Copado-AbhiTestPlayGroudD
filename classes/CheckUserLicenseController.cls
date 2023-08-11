//
//@Author : Akash Punera
//@date: 26th Apr 2021
//@description : Custom layout controller to check if user has access to TCRM
//
public without sharing class CheckUserLicenseController {

    //
    //@Author : Akash Punera
    //@date: 26th Apr 2021
    //@description : This method will check if the logged in user has the permission set license assigned
    //@company : IHS Markit
    //@param : String 
    //@return : Boolean
    //
    @AuraEnabled
    public static boolean checkAssignment(string licenseName) {
        //Remove all spaces from the label
        String permissionSetStr = licenseName.replaceAll('\\s', '');
        List<String> permissionSets = permissionSetStr.split(',');
        Boolean hasAccess = false;

        List<PermissionSetAssignment> psaList = [SELECT Id 
                                                 FROM 	PermissionSetAssignment 
                                                 WHERE 	PermissionSet.name in :permissionSets
                                                 AND	assigneeid = :UserInfo.getUserId()];
        
        system.debug(psaList);
        
        //check if permission set license is assigned to logged in user
        if (psaList.size() > 0) {
            hasAccess = true;
        }
        return hasAccess;
    }

}