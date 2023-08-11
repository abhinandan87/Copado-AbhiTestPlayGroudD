//-----------------------------
// @author: Manish Kumar
// @date: 5th Aug 2021
// @param: NA
// @description: Test class for FSA Products methods 
// @return: NA
//-----------------------------

@isTest
private class TestFSAProductMethods {
    
	//-----------------------------
	// @author: Manish Kumar
	// @date: 5th Aug 2021
	// @param: NA
	// @description: Test Method for FSA Products creation
	// @return: NA
	//-----------------------------
	@isTest
    	static void createFSAProducts() {
        
        //Create a test Account
        Account acct = TestUtility.createTestAccount('Test Account For Survey Response', true);
		
        //Create a Contact
        Contact con = TestUtility.createContact(acct.id,'testemail@test.com',true,'TestFirstName','TestLastName');
		
        //Create a Work Order
        WorkOrder workOrderObj = TestUtility.createFieldServiceActivity(con.id, true);
        //update workOrderObj;
        //workOrderDispatcher.isAfterUpdateProcessing = true;
        //update workOrderObj;
		
        //Create a Product Group
		ProductGroup__c productGroupObj = TestUtility.createProductGroup('Test Product Group 1', true);
        ProductGroup__c productGroupObj2 = TestUtility.createProductGroup('Test Product Group 2', true);
            
            //Create FSA Product
            FieldServiceActivityProduct__c fsaProductObj = TestUtility.createFSAProduct(workOrderObj.id, productGroupObj.id, true); 
            FieldServiceActivityAttendee__c fsaAttendee = New FieldServiceActivityAttendee__c();
        	fsaAttendee.FieldServiceActivity__c = workOrderObj.id;
        	fsaAttendee.Contact__c = con.id;
        	insert fsaAttendee;
        	workOrderObj.status = 'Delivered';
            update workOrderObj;
        	workOrderDispatcher.isAfterUpdateProcessing = true;
        	update workOrderObj;
            fsaProductObj.ProductGroup__c = productGroupObj2.Id;
            test.startTest();
            update fsaProductObj;
            List<FieldServiceActivityProduct__c> fsapList = new list<FieldServiceActivityProduct__c>();
            fsapList.add(fsaProductObj);
            for(FieldServiceActivityProduct__c fsap: fsapList) {
                System.assertEquals(productGroupObj2.Id, fsap.ProductGroup__c, 'Product group mathes after update');
            }
            test.stopTest();
        }
}