//-----------------------------
// @author: Tran-Vu Tran
// @date: 24th April 2018
// @param: NA
// @description: Test class for User trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestUserMethods {

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 24th April 2018
    // @param: NA
    // @description: SFDC1-808 Test method for User trigger method testUpdateUserRegionWhenAddressCountryChanges
    // @return: NA
    //-----------------------------
    private static testMethod void testUpdateUserRegionWhenAddressCountryChanges() {
        
        Test.startTest();

        // Test data setup
        TestUtility.loadCountryData();
        
        User aUser = TestUtility.createTestUserWithCountryCode('System Administrator', 'test.UserMethods@test.com', 'US', true);
        System.runAs(aUser) {
           
            List<User> testUsers = [Select Id, CountryCode, UserRegion__c from User where Id =: aUser.Id];
    
            //Assert if user account is inserted
            System.assertEquals(1, testUsers.size());
    
            User testUser = testUsers[0];
            System.debug('user.CountryCode: ' + testUser.CountryCode);
            System.debug('user.UserRegion__c: ' + testUser.UserRegion__c);
            
            //Assert if User's Region is populated
            System.assertEquals('Americas', testUser.UserRegion__c);
            
            testUser.CountryCode = 'GB';
            update testUser;

            list <User> testUserUpdateResult = [Select Id, CountryCode, UserRegion__c from User where Id =: testUser.Id];
            System.assertEquals(1, testUserUpdateResult.size());
            
            testUser = testUserUpdateResult[0];
    
            System.debug('user.CountryCode: ' + testUser.CountryCode);
            System.debug('user.UserRegion__c: ' + testUser.UserRegion__c);
    
            //Assert if User's Region is updated
            System.assertEquals('EMEA', testUser.UserRegion__c);
        }
        
        Test.stopTest();
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 05 Dec 2018
    // @param: NA
    // @description: SFDC1-9382 Test method for User trigger method createContactForNewUser
    // @return: NA
    //-----------------------------
	private static testMethod void testCreateContactForNewUser() {
        Test.startTest();
        Account a = TestUtility.createTestAccount(System.Label.NewUserContactAccount, false);
        a.type = System.Label.NewUserContactAccountType;
        insert a;
        User u = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUSer.testContact123@ihsmarkit.com',true);
        Set<Id> userIds = new Set<Id>();
        userIds.add(u.Id);
        //Call Future method manually to generate 'A contact already exists with this email address.' error, So that Code coverage will be done Database.SaveResult code 
        UserMethods.processUserRecordsForContactCreation(userIds,a.Id);
        Test.stopTest();
        List<Contact> conList = [SELECT Id FROM Contact Where AccountId =: a.Id];
        System.assertEquals(1, conList.size());
    }
}