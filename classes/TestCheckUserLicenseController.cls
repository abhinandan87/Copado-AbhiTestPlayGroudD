//
//@auhor Akash Punera
//@date 29th Apr 2021
//@description Test class for CheckUserLicenseController
//@company IHS Markit
//
@isTest(seeAllData = false)
public class TestCheckUserLicenseController {
    //
    //@auhor Akash Punera
    //@date 29th Apr 2021
    //@description Test method to test checkAssignment method
    //@Param none
    //@company IHS Markit
    //
	@isTest
    private static void TestcheckAssignment() {
        
        PermissionSetAssignment newPsa;
        PermissionSet psl = [SELECT 	id 
                             FROM		PermissionSet
                             WHERE		name = 'EinsteinAnalyticsPlusAdmin'];
        
        List<PermissionSetAssignment> assignedLicense = [SELECT 	id 
                                                         FROM 	permissionSetAssignment
                                                         WHERE 	AssigneeId =:UserInfo.getUserId() 
                                                         AND	PermissionSetId = :psl.id];
        
        if(assignedLicense.size() == 0) {
            newPsa = new PermissionSetAssignment(AssigneeId = Userinfo.getUserId(), PermissionSetId = psl.id);
            insert newPsa;
        }else{
            newPsa = assignedLicense[0];
        }
                                       
        Boolean tcrmTabsDisplayed = CheckUserLicenseController.checkAssignment('EinsteinAnalyticsPlusAdmin');
        system.assertEquals(true, tcrmTabsDisplayed, 'User does not have EinsteinAnalyticsPlusAdmin permission set');
        delete newPsa;
        
        tcrmTabsDisplayed = CheckUserLicenseController.checkAssignment('EinsteinAnalyticsPlusAdmin');
        system.assertEquals(false, tcrmTabsDisplayed, 'User should not have EinsteinAnalyticsPlusAdmin permission set');
        
    }
}