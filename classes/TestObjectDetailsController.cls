//-----------------------------
// @author: Neelam Agrawal
// @date: 21 Mar 2022
// @param: NA
// @description: Test class for ObjectDetailsController class 
// @return: NA
//-----------------------------

@isTest
public class TestObjectDetailsController {

    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 21 Mar 2022
    // @param: NA
    // @description: Test method for getProductGroup method
    // 
    public static testMethod void testfetchObjectName() {
        ObjectDetailsController obj= new ObjectDetailsController();
		ObjectDetailsController.Objects obj1= new ObjectDetailsController.Objects('Case','Case'); 
        ObjectDetailsController.Objects obj2= new ObjectDetailsController.Objects('Opportunity','Opportunity');  
        Integer check= obj1.compareTo(obj2);
        System.assertEquals(-1, check);
        obj.selectedObjName='Case';
        obj.getPicklistValues();
    }
}