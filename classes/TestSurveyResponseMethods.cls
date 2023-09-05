//-----------------------------
// @author: Manish Kumar
// @date: 4th Aug 2021
// @param: NA
// @description: Test class for Survey Response trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestSurveyResponseMethods {
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 4th Aug 2021
	// @description: Test Method for Corporate Survey Response 
	// @return: NA
	//-----------------------------
	@isTest
    static void createCorpSurveyResponseWithAccountAndContact() {
        
        //Create an Account
        Account acct = TestUtility.createTestAccount('Test Account For Survey Response', true);
        
        //Create a Contact
        Contact con = TestUtility.createContact(acct.id,'testemail1@test.com',true,'TestFirstName','TestLastName');
        
        // Create Corporate Survey Responses
        id corpRecTypeId = UtilityClass.getObjectRecordTypeId('SurveyResponse__c','Corporate');
        SurveyResponse__c corpSurveyResponseForPromoter = TestUtility.createCorporateSurveyResponse(5,corpRecTypeId,true);
        SurveyResponse__c corpSurveyResponseForDetractor = TestUtility.createCorporateSurveyResponse(9,corpRecTypeId,true);
        system.assertEquals(corpRecTypeId, corpSurveyResponseForPromoter.RecordTypeId);
        system.assertEquals(corpRecTypeId, corpSurveyResponseForDetractor.RecordTypeId);
    
    }
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 4th Aug 2021
	// @description: Test Method for Corporate Survey Response 
	// @return: NA
	//-----------------------------
	@isTest
    static void createCorpSurveyResponseWithoutAccountAndContact() {
        
        //Create Corporate Survey Response without Account and Contact
        id corpRecTypeId = UtilityClass.getObjectRecordTypeId('SurveyResponse__c','Corporate');
        SurveyResponse__c corpSurveyResponse = TestUtility.createCorporateSurveyResponse(0,corpRecTypeId,true);
        system.assertEquals(corpRecTypeId, corpSurveyResponse.RecordTypeId,'Recrod type should be Corporate');
    
    }
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 5th Aug 2021
	// @description: Test Method for Transactional and Training Survey Response 
	// @return: NA
	//-----------------------------
    @isTest
    static void createSurveyResponse() {
        
        //Create a test Account
        Account acct = TestUtility.createTestAccount('Test Account For Survey Response', true);
        
        //Create a test Contact
        Contact con = TestUtility.createContact(acct.id,'testemail1@test.com',true,'TestFirstName','TestLastName');
        
        //Create a test Case
        id caseRecTypeId = UtilityClass.getObjectRecordTypeId('Case','Customer Care');
        id ownerId = UserInfo.getUserId();
        Case testCase = TestUtility.createCase(caseRecTypeId, acct.id, con.Id, OwnerId, 'Test Case' , true);
        
        //Create a test FSA
        WorkOrder testFSA = TestUtility.createFieldServiceActivity(con.id,true);
        
        //Create Transactional Survey Response
        id transRecTypeId = UtilityClass.getObjectRecordTypeId('SurveyResponse__c','Transactional');
        SurveyResponse__c transHotAlertSurveyResponse = TestUtility.createSurveyResponse(1,2,3,4,5,0,transRecTypeId,acct.id,con.id,testCase.id,testFSA.id,true);
        SurveyResponse__c transNeutralSurveyResponse = TestUtility.createSurveyResponse(5,4,5,4,8,0,transRecTypeId,acct.id,con.id,testCase.id,testFSA.id,true);
        SurveyResponse__c transCommendationSurveyResponse = TestUtility.createSurveyResponse(6,6,7,7,10,0,transRecTypeId,acct.id,con.id,testCase.id,testFSA.id,true);
        system.assertEquals(transRecTypeId, transHotAlertSurveyResponse.RecordTypeId,'Recrod type should be Transactional');
        system.assertEquals(transRecTypeId, transNeutralSurveyResponse.RecordTypeId,'Recrod type should be Transactional');
        system.assertEquals(transRecTypeId, transCommendationSurveyResponse.RecordTypeId,'Recrod type should be Transactional');
        
        //Create Training Survey Response
        id trainingRecTypeId = UtilityClass.getObjectRecordTypeId('SurveyResponse__c','Training');
        SurveyResponse__c trainingHotAlertSurveyResponse = TestUtility.createSurveyResponse(1,1,1,1,0,1,trainingRecTypeId,acct.id,con.id,testCase.id,testFSA.id,true);
        SurveyResponse__c trainingNeutralSurveyResponse = TestUtility.createSurveyResponse(1,1,1,1,8,5,trainingRecTypeId,acct.id,con.id,testCase.id,testFSA.id,true);
        SurveyResponse__c trainingCommendationSurveyResponse = TestUtility.createSurveyResponse(1,1,1,1,10,6,trainingRecTypeId,acct.id,con.id,testCase.id,testFSA.id,true);
        system.assertEquals(trainingRecTypeId, trainingHotAlertSurveyResponse.RecordTypeId,'Recrod type should be Training');
    	system.assertEquals(trainingRecTypeId, trainingNeutralSurveyResponse.RecordTypeId,'Recrod type should be Training');
        system.assertEquals(trainingRecTypeId, trainingCommendationSurveyResponse.RecordTypeId,'Recrod type should be Training');
    }
    
    //-----------------------------
	// @author: Shikhar Singh
	// @date: 22nd Oct 2021
	// @description: Test Method for Contact/Account update Rollup on Survey Response  
	// @return: NA
	//-----------------------------
	@isTest
	static void updateRollupFields() {
        //Create an Account
        Account acct = TestUtility.createTestAccount('Test Account For Survey Response1', true);
        Account acct2 = TestUtility.createTestAccount('Test Account For Survey Response2', true);
        //Create a Contact
        Contact con1 = TestUtility.createContact(acct.id,'testemail1@test.com',true,'TestFirstName','TestLastName');
		Contact con2 = TestUtility.createContact(acct.id,'testemail2@test.com',true,'Test','Contact 2');
		//Create a test Case
        id caseRecTypeId = UtilityClass.getObjectRecordTypeId('Case','Customer Care');
        id ownerId = UserInfo.getUserId();
        Case testCase = TestUtility.createCase(caseRecTypeId, acct.id, con1.Id, OwnerId, 'Test Case' , true);
        
        //Create a test FSA
        WorkOrder testFSA = TestUtility.createFieldServiceActivity(con1.id,true);
        
        //Create Transactional Survey Response
        id transRecTypeId = UtilityClass.getObjectRecordTypeId('SurveyResponse__c','Transactional');
        SurveyResponse__c transNeutralSurveyResponse = TestUtility.createSurveyResponse(5,4,5,4,8,0,transRecTypeId,acct.id,con1.id,testCase.id,testFSA.id,true);        
        // Create Corporate Survey Responses
        id corpRecTypeId = UtilityClass.getObjectRecordTypeId('SurveyResponse__c','Corporate');
        SurveyResponse__c corpSurveyResponseForDetractor = TestUtility.createCorporateSurveyResponse(9,corpRecTypeId,true);
        
        for(Contact c: [Select Id, Name, CorporateNPS__c FROM Contact WHERE LastName = 'TestLastName']){
            //System.assertEquals(100, c.CorporateNPS__c, 'Value should be 100');
        }
        
        Test.startTest();
        //update contact and Account on test survey
        corpSurveyResponseForDetractor.contact__c = con2.Id; 
        corpSurveyResponseForDetractor.Account__c=acct2.Id;
        transNeutralSurveyResponse.contact__c = con2.Id; 
        update corpSurveyResponseForDetractor;
        update transNeutralSurveyResponse;
        
        //check after replacing survey response from con1 to con2 so that values get updated accordingly
        for(Contact c1: [Select Id, Name, CorporateNPS__c FROM Contact WHERE LastName = 'TestLastName']){
        	System.assertEquals(null, c1.CorporateNPS__c, 'The score should be 0');
        }
        
        for(Contact c2: [Select Id, Name, CorporateNPS__c FROM Contact WHERE LastName = 'Contact 2']){
        	System.assertEquals(100.00, c2.CorporateNPS__c, 'The score should be 100');
        }
        Test.stopTest();
	}
}