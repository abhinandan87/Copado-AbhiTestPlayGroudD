/****************************
 * @author Tran-Vu Tran
 * @date 28th Jun 2017
 * @description Test class for unit testing on Contact Triggers
//----------------------------
************************/

@isTest(seeAllData=false)
private class TestContactTriggers {
		@isTest
        static void TestSyncContactCountryWithCountryChange() {

        // Test data setup
        TestUtility.loadCountryData();
        Contact cont = new Contact(FirstName = 'Test', LastName = 'Contact',
                                   EmailUnknown__c = true, Phone = '2813456789',
                                   MailingStreet='Test street 1',
                                   MailingCity = 'Toronto',
                                   MailingStateCode = 'ON',
                                   MailingCountryCode = 'CA');
        insert cont;

        // Verify that the ContactCountry reference to is Canada
        Contact assertContact1 = [Select Id, ContactCountry__r.Name, ContactCountry__r.CountryCode__c from Contact where Id=: cont.Id];
        System.debug('Contact Country: ' + assertContact1.ContactCountry__r.Name);
        System.debug('Contact Country Code: ' + assertContact1.ContactCountry__r.CountryCode__c);
        System.assertEquals('CA', assertContact1.ContactCountry__r.CountryCode__c, 'Checking contact country code');
            
        // Perform Test on update
        Test.startTest();
        cont.MailingCountryCode = 'IN';
        update cont;
        Test.stopTest();
        
        // Query the contact again to get updated value
        Contact assertContact2 = [Select Id, ContactCountry__c from Contact where Id=: cont.Id];
        Country__c targetCountry = [SELECT Id from Country__c WHERE CountryCode__c = 'IN'];

        // Verify that the ContactCountry reference to is now showing India
        System.assert(assertContact2.ContactCountry__c == targetCountry.Id);
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2017
    // @param: NA
    // @description: SFDC1-2299 Test method for Additional Contact Fields trigger method setAdditionalContactFieldsObject on insert
    // @return: NA
    //-----------------------------
	@isTest
    private static void testSetAdditionalContactFieldsObject() {
        
        System.debug('Logging for testSetAdditionalContactFieldsObject');

        Contact testContact = TestUtility.createContact(null, 'Test.SetAdditionalContactFieldsObject@ihsmarkit.com', true,
                                                        'Test', 'SetAdditionalContactFieldsObject');
        System.debug('testContact.Id=' + testContact.Id);
        System.debug('testContact.FirstName=' + testContact.FirstName);
        System.debug('testContact.LastName=' + testContact.LastName);
        
        List <Contact> testContactResult = [Select AdditionalContactFields__c, Id, Name from Contact where Id =: testContact.Id];
        System.debug('testContactResult[0].Id=' + testContactResult[0].Id);
        System.debug('testContactResult[0].Name=' + testContactResult[0].Name);
        System.debug('testContactResult[0].AdditionalContactFields__c=' + testContactResult[0].AdditionalContactFields__c);
        
        //Assert if contact is inserted
        System.assertEquals(1, testContactResult.size(),'checking if the contact is inserted');
        System.assert(testContactResult[0].AdditionalContactFields__c != null);
        
        //Assert if Additional Contact Field is inserted
        List <AdditionalContactFields__c> acfList = [Select Id from AdditionalContactFields__c where ContactReference__c =: testContact.Id];
        System.assertEquals(1, acfList.size(),'checking if the Addition Contact field is inserted');
        System.assertEquals(acfList[0].Id, testContactResult[0].AdditionalContactFields__c);
        
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2017
    // @param: NA
    // @description: SFDC1-2299 Test method for Additional Contact Fields trigger method changeAdditionalContactFieldsObjectNameWhenContactNameChanges on update. 
    //              To test if Contact Additional Fields Object Name chnages when Contact Name Changes
    // @return: NA
    //-----------------------------
	@isTest
    private static void testChangeAdditionalContactFieldsObjectNameWhenContactNameChanges() {
        
        Contact testContact = TestUtility.createContact(null, 'Test.ChangeAdditionalContactFields@ihsmarkit.com', true,
                                                        'Test', 'ChangeAdditionalContactFields');
        
        list <Contact> testContactResult =
            [Select AdditionalContactFields__c, AdditionalContactFields__r.Name, Id, FirstName, LastName from Contact where Id =: testContact.Id];
        
        //Assert if contact is inserted
        System.assertEquals(1, testContactResult.size(),'checking if the contact is inserted');
        System.assert(testContactResult[0].AdditionalContactFields__c != null);
        
        Contact c = testContactResult[0];
        System.assertEquals(c.AdditionalContactFields__r.Name, 'Additional Fields - ' + c.FirstName + ' ' + c.LastName);
        
        //Update Contact Name
        testContact.FirstName = 'Test';
        testContact.LastName = 'ChangeAdditionalContactFields2';
        update testContact;
        
        list <Contact> testContactResult2 =
            [Select AdditionalContactFields__c, AdditionalContactFields__r.Name, Id, FirstName, LastName from Contact where Id =: testContact.Id];
        
        //Assert if Additional Contact Field name gets updated
        Contact c2 = testContactResult2[0];
        System.assertEquals(c2.AdditionalContactFields__r.Name, 'Additional Fields - ' + c2.FirstName + ' ' + c2.LastName);
        
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2017
    // @param: NA
    // @description: SFDC1-2299 Test method for Additional Contact Fields trigger method deleteAdditionalContactFieldsRecordWhenContactGetsDeleted on Delete. 
    //               To test if Contact Additional Fields Object gets deleted when Contact gets deleted 
    // @return: NA
    //-----------------------------
	@isTest
    private static void testDeleteAdditionalContactFieldsRecordWhenContactGetsDeleted() {
        
        Contact testContact = TestUtility.createContact(null, 'Test.DeleteAdditionalContactFields@ihsmarkit.com', true,
                                                        'Test', 'DeleteAdditionalContactFields');
        
        list <Contact> testContactResult = [Select AdditionalContactFields__c, Id from Contact where Id =: testContact.Id];
        //Assert if contact is inserted
        System.assertEquals(1, testContactResult.size());
        System.assert(testContactResult[0].AdditionalContactFields__c != null);
        
        //Assert if Adiitional Contact Field is inserted
        AdditionalContactFields__c acf = [Select Id from AdditionalContactFields__c where ContactReference__c =: testContact.Id];
        System.assert(acf != null);
        System.assertEquals(acf.Id, testContactResult[0].AdditionalContactFields__c,'checking if Additional contact field is inserted');
        
        delete testContact;
        
        list <AdditionalContactFields__c> acfList = [Select Id from AdditionalContactFields__c where Id =: acf.Id];
        
        ////Assert if Adiitional Contact Field is deleted
        System.assertEquals(0, acfList.size(),'checking if the additional contact field is deleted');
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 19 Dec 2018
    // @param: NA
    // @description: SFDC1-10703 When a contact is created, check if there exists a product login with same email Id.
    // 		Then verify if product login contact association exists for the contact and the product login. If exists
    // 		dont do anything, else create one product login contact association.
    // @return: NA
    //-----------------------------
	@isTest
    private static void testCreatePLCAWhenProductLoginExistsForEmail() {
        Account a = TestUtility.createTestAccount(System.Label.CaseUnknownAccountName, true);
        //Create 2 product logins with differnet email Id. 
        List<ProductLogin__c> plList = new List<ProductLogin__c>();
        ProductLogin__c testProductLogin1 = TestUtility.createProductLogin('newcontact1@test.com', false);
        testProductLogin1.Email__c = 'pl.newcontact1@ihsmarkit.com';
        // testProductLogin1.Source__c = 'Manual';
        testProductLogin1.FirstName__c= 'testPLEmail1';
        ProductLogin__c testProductLogin2 = TestUtility.createProductLogin('newcontact2@test.com', false);
        testProductLogin2.Email__c = 'pl.newcontact2@ihsmarkit.com';
        // testProductLogin2.Source__c = 'Manual';
        testProductLogin2.FirstName__c= 'testPLEmail2';
        plList.add(testProductLogin1);
        plList.add(testProductLogin2);
        insert plList;
        Test.startTest();
        //Create a contact with above Email Ids and one with differnt email, check only one new PLCA is created. 
        List<Contact> contactList = new List<Contact>();
        Contact c1 = new Contact();
        c1.firstname = 'Test1';
        c1.lastname = 'Test1';
        c1.AccountId = a.Id;
        c1.Email = 'pl.newcontact1@ihsmarkit.com';
        Contact c2 = new Contact();
        c2.firstname = 'Test';
        c2.lastname = 'Test';
        c2.AccountId = a.Id;
        c2.Email = 'pl.newcontact@ihsmarkit.com';
        contactList.add(c1);
        contactList.add(c2);
        insert contactList;
		System.assertEquals(1, [select id from productLoginContactAssociation__c].size(),'checking if 1 PLCA is created');
        //update contact 2 with 2 email Id, check for a new PLCA is created.
        c2.Email = 'pl.newcontact2@ihsmarkit.com';
        update c2;
		System.assertEquals(2, [select id from productLoginContactAssociation__c].size(),'checking if 2 PLCA are created');
        Test.stopTest();
    }
}