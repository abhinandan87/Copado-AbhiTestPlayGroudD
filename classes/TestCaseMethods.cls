//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: NA
// @description: Test class for Case trigger methods 
// @return: NA
// @Update - 9 May 2018 Anjani Shukla - SFDC1-8195/96/97 - ContactId is required on Case and if IsInternal = true, 
//                                      Then Email must contain  @ihsmarkit.com
//-----------------------------

@isTest
private class TestCaseMethods {
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 June 2017
    // @param: NA
    // @description: Test method for Case trigger methods setCaseAdditionalFieldsObject on insert
    // @return: NA
    //-----------------------------
	@isTest
    private static void testSetCaseAdditionalFieldsObjectInsert() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        
        //Assuming NRG recordtype exist in system
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRG;
        
        Case testCase = new Case();
        testCase.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.ProductGroup__c = pg.Id;
        insert testCase;
        
        list <Case> testCaseResult = [Select AdditionalFields__c, Id from case where Id = :testCase.Id];
        list <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        
        System.assertEquals(1, testCaseResult.size(),'size does not match');
        System.assertEquals(1, additionalCaseFieldsList.size(),'size does not match1');
        System.assertEquals(additionalCaseFieldsList[0].Id, testCaseResult[0].AdditionalFields__c,'ACF doesn\'t match');
        
    }
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 June 2017
    // @param: NA
    // @description: Test method for Case trigger methods setCaseAdditionalFieldsObject on update when Product was null initailly
    // @return: NA
    //-----------------------------
	@isTest
    private static void testSetCaseAdditionalFieldsObjectUpdateNull() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        
        //Assuming NRG recordtype exist in system
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRG;
        
        Case testCase = new Case();
        testCase.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        insert testCase;
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        testCase.ProductGroup__c = pg.Id;
        update testCase;
        
        list <Case> testCaseResult = [Select ProductGroup__c, AdditionalFields__c, Id from case where Id = :testCase.Id];
        list <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        
        System.assertEquals(1, testCaseResult.size(),'size does not match');
        System.assertEquals(1, additionalCaseFieldsList.size(),'size does not match1');
        System.assertEquals(pg.Id, testCaseResult[0].ProductGroup__c,'product group does not match');
        System.assertEquals(additionalCaseFieldsList[0].Id, testCaseResult[0].AdditionalFields__c,'ACF does not match');
        
    }
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 June 2017
    // @param: NA
    // @description: Test method for Case trigger methods setCaseAdditionalFieldsObject on update when Product was set initailly
    // @return: NA
    //-----------------------------
	@isTest
    private static void testSetCaseAdditionalFieldsObjectUpdate() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        
        //Assuming NRG recordtype exist in system
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRG;
        
        //Assuming PETRA recordtype exist in system
        
        ProductGroup__c pgPETRA = new ProductGroup__c();
        pgPETRA.Name = 'PETRA';
        insert pgPETRA;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingPETRA = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingPETRA.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingPETRA.AdditionalCaseRecordType__c = 'PETRA';
        aCaseTypeLinkingPETRA.ProductGroup__c = pgPETRA.Id;
        insert aCaseTypeLinkingPETRA;
        
        Case testCase = new Case();
        testCase.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.ProductGroup__c = pg.Id;
        insert testCase;
        
        testCase.ProductGroup__c = pgPETRA.Id;
        update testCase;
        
        list <Case> testCaseResult = [Select ProductGroup__c, AdditionalFields__c, Id from case where Id = :testCase.Id];
        list <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        
        System.assertEquals(1, testCaseResult.size(),'size doesn\'t match');
        System.assertEquals(1, additionalCaseFieldsList.size(),'size doesn\'t match2');
        System.assertEquals(pgPETRA.Id, testCaseResult[0].ProductGroup__c,'product group doesn\'t match');
        System.assertEquals(additionalCaseFieldsList[0].Id, testCaseResult[0].AdditionalFields__c,'ACF doesn\'t match');
        
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary 
    // @date: 22 January 2018
    // @param: NA
    // @description: Test method for Case trigger method SetCaseAdditionalFieldsObjectInsert  before insert
    // when product group, family both are set in additional case type linking object.
    // 
    // @editdate: 07 Feb 2018
    // @description: adding test cases for new scenarios as per 6382.
    // 
    // @ModifiedBy: Vishnu Vardhan
    // @Date: 16 Aug 2018
    // @Description: SFDC1-8534, Verifying entitlement id, is set to Customer Care case 
    // @return: NA
    //-----------------------------
	@isTest
    private static void testSetCAFObjectInsertWithProductFamily() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');

        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;

        //creating product family to test other scenarions
        Family__c pf = new Family__c();
        pf.Name = 'NRG Family';
        pf.ProductGroup__c = pg.Id;
        insert pf;
        
        List<AdditionalCaseTypeLinking__c> actlList = new List<AdditionalCaseTypeLinking__c>();
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        //aCaseTypeLinkingNRG.ProductFamily__c = pf.id;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG1 = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG1.CaseRecordType__c = 'Onboarding';
        aCaseTypeLinkingNRG1.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG1.ProductGroup__c = pg.Id;
        aCaseTypeLinkingNRG1.ProductFamily__c = pf.id;

        actlList.add(aCaseTypeLinkingNRG);
        actlList.add(aCaseTypeLinkingNRG1);
        insert actlList;
        List<Case> caseList = new List<Case>();
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id OId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.ProductGroup__c = pg.Id;
        testCase1.RecordTypeId = CCId;
        
        Case testCase2 = new Case();
        testCase2.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase2.AccountId = a.Id;
        testCase2.contactId = c.Id;
        testCase2.ProductGroup__c = pg.Id;
        testCase2.ProductFamily__c = pf.Id;
        testCase2.RecordTypeId = CCId;
        caseList.add(testCase1);
        caseList.add(testCase2);
        insert caseList;

        Test.startTest();
        List<Id> caseIds = new List<Id>();
        caseIds.add(caseList.get(0).Id);
        caseIds.add(caseList.get(1).Id);
        List <Case> testCaseResult = [Select AdditionalFields__c, ProductFamily__c, Id, EntitlementId from case where Id in :caseIds];
        List <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c in :caseIds];
        Id eaID = EntitlementAssignment__c.getOrgDefaults().EntitlementId__c;
        System.assertEquals(2, testCaseResult.size(),'size doesn\'t match3');
        System.assertEquals(2, additionalCaseFieldsList.size(),'size doesn\'t match4');

        for(Case testCase:testCaseResult) {
            //as per the datasetup, If case dont have product family, then additional case should fall back on product group.
            //If product family exists then, additional case should be created.
            System.assertNotEquals(testCase.AdditionalFields__c, null,'ACF doesn\'t match2');
            System.assertEquals(eaID, testCase.EntitlementId,'Entitlement doesn\'t match');
        }
        //Test though Record type id or PF or Group changes, ACF record should not be recreated.
        testCase2.RecordTypeId = OId;
        testCase2.ProductFamily__c = pf.Id;
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        update testCase2;
        additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase2.Id];
        System.assertEquals(1, additionalCaseFieldsList.size(),'ACFsize doesn\'t match');
        //Deleting ACF record, when matching ACTL record is not available
        testCase2.ProductFamily__c = null;
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        update testCase2;
        additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase2.Id];
        System.assertEquals(0, additionalCaseFieldsList.size(),'ACFsize doesn\'t match');
        //Now update the record type for TestCase2 and test it. ACF should have been deleted.
        //Also we dont have a matching ACTl record for record type and product group
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary 
    // @date: 15 Febrauary 2018
    // @param: NA
    // @description: Above method couldnt cover all the scenarios and breaking the limits,
    // So adding new method
    //-----------------------------
	@isTest
    private static void testSetCAFObjectInsertWithProductFamily1() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');

        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        Family__c pf = new Family__c();
        pf.Name = 'NRG Family';
        pf.ProductGroup__c = pg.Id;
        insert pf;

        List<AdditionalCaseTypeLinking__c> actlList = new List<AdditionalCaseTypeLinking__c>();
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG1 = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG1.CaseRecordType__c = 'Onboarding';
        aCaseTypeLinkingNRG1.AdditionalCaseRecordType__c = 'Petra';
        aCaseTypeLinkingNRG1.ProductGroup__c = pg.Id;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG2 = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG2.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG2.AdditionalCaseRecordType__c = 'Petra';
        aCaseTypeLinkingNRG2.ProductGroup__c = pg.Id;
        aCaseTypeLinkingNRG2.ProductFamily__c = pf.Id;

        actlList.add(aCaseTypeLinkingNRG);
        actlList.add(aCaseTypeLinkingNRG1);
        actlList.add(aCaseTypeLinkingNRG2);
        insert actlList;
        List<Case> caseList = new List<Case>();
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id OId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.ProductGroup__c = pg.Id;
        testCase1.RecordTypeId = CCId;
        
        Case testCase2 = new Case();
        testCase2.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase2.AccountId = a.Id;
        testCase2.contactId = c.Id;
        testCase2.ProductGroup__c = pg.Id;
        testCase2.RecordTypeId = CCId;
        caseList.add(testCase1);
        caseList.add(testCase2);
        insert caseList;

        Test.startTest();

        List<Id> caseIds = new List<Id>();
        testCase1 = caseList.get(0);
        testCase2 = caseList.get(1);
        caseIds.add(testCase1.Id);
        caseIds.add(testCase2.Id);
        List <Case> testCaseResult = [Select AdditionalFields__c, ProductFamily__c, Id from case where Id in :caseIds];
        List <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c in :caseIds];
        
        System.assertEquals(2, testCaseResult.size(),'case size doesn\'t match');
        System.assertEquals(2, additionalCaseFieldsList.size(),'ACF size doesn\'t match3');

        testCase2 = testCaseResult.get(0);
        testCase1 = testCaseResult.get(1);
        testCase2.RecordTypeId = OId;
        testCase1.ProductFamily__c = pf.id;
        
        caseList = new List<Case>();
        caseList.add(testCase2);
        caseList.add(testCase1);
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        update caseList;
        testCaseResult = [Select AdditionalFields__c, Id from case where Id in :caseIds];
        for(Case testCase:testCaseResult) {
            if(testCase.Id == testCase1.id) {
                //Changing product family, so ACF record should be re-created. 
                System.assertNotEquals(testCase.AdditionalFields__c, testCase1.AdditionalFields__c,'ACF record doesn\'t match');
            } else {
                 //Changing record type, so record type in ACF should be changed.
                System.assertEquals(testCase.AdditionalFields__c, testCase2.AdditionalFields__c,'ACF doesn\'t match 4');
            }
        }

        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 20 July 2017
    // @param: NA
    // @description: Test method for Case trigger method updateDataGovernanceCaseAccountContact before insert
    // when Case Type = "Account Governance" and Subtype = "New" or "Account Maintenance"
    // @return: NA
    // @Update - 9 May 2018 Anjani Shukla - SFDC1-8195/96/97 - ContactId is required on Case and if IsInternal = true, 
    //                                      Then Email must contain  @ihsmarkit.com
    // @Update - 20 August 2018 Vishnu - SFDC1-8977 - Changing Data Governance to Account Governance
    //-----------------------------
	@isTest
    static void TestInternalCaseAccountContact() {

        // Test data setup
        Account acct = TestUtility.createTestAccount('Test Account', true);
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        String testEmail = 'dgtest@ihsmarkit.com';
        
        User myTestUser = TestUtility.createAdminUser(testEmail, true);

        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        
        String recordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Customer Master Data');
        System.debug('recordTypeId=' + recordTypeId);
        System.assert(recordTypeId != null,'Record type is null');
        
        Case dgCase = new Case(RecordTypeId = recordTypeId,
                               AccountId = acct.Id, ContactValidation__c = true,
                               Type = 'Customer Master Data', Subtype__c = 'Account Maintenance',
                               Description = 'Please update address'
                              );

        System.runAs(myTestUser) {
            Test.startTest();
            
            insert dgCase;
            
            // Reload dgCase from Database
            dgCase = [SELECT AccountId, CreatedById, ContactId FROM Case WHERE Id =: dgCase.Id];
            
            System.debug('dgCase.AccountId=' + dgCase.AccountId);
            System.assert(dgCase.AccountId != null,'Account is null');
            System.assertEquals(ihsMarkitAccount.Id, dgCase.AccountId,'AccountId is null');
    
            System.debug('dgCase.CreatedById=' + dgCase.CreatedById);
            System.assert(dgCase.CreatedById != null,'CreatedBy is null');
    
            User createdBy = UtilityClass.getUserById(dgCase.CreatedById);
            System.debug('dgCase.createdBy Name=' + createdBy.Name + ', Email=' + createdBy.Email);
            
            Contact userContact = UtilityClass.getContactByEmail(createdBy.Email);
            System.debug('userContact.Name=' + userContact.Name + ', Email=' + userContact.Email);
            System.assert(userContact != null,'userContact is null');
            
            System.debug('dgCase.ContactId=' + dgCase.ContactId);
            System.assertEquals(userContact.Id, dgCase.ContactId,'ContactId is null');
            
            System.assertEquals(userContact.Email, myTestContact.Email,'Email is not matching');
            
            Test.stopTest();
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 04 June 2018
    // @param: NA
    // @description: SFDC1-8381 Convert Process Builder flow "SetDefaultValuesForProductGroup" created in SFDC1-6418 to a trigger
    //-----------------------------
    @isTest
    static void testSetCaseProductGroupForOrderManagementDeliveryHelpDesk() {

        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                            '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                            'London', '', 'GB', true);
        String testEmail = 'test@ihsmarkit.com';
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        System.runAs(myTestUser) {
            Test.startTest();
    
            Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
            
            List<ProductGroup__c> productGroups = new List<ProductGroup__c> ();
            productGroups.add(new ProductGroup__c(Name = 'Order Mgmt. Helpdesk'));
            productGroups.add(new ProductGroup__c(Name = 'Delivery Helpdesk'));
            productGroups.add(new ProductGroup__c(Name = 'Retail Helpdesk'));
            insert productGroups;
            
            List<Case> testCases = new List<Case>();
            
            Case testCase1 = new Case();
            testCase1.subject = 'Test Product Group for Order Management case';
            testCase1.RecordTypeId = UtilityClass.caseRecordTypeOMDHelpDesk;
            testCase1.AccountId = ihsMarkitAccount.Id;
            testCase1.ContactId = myTestContact.Id;
            testCase1.TeamSelect__c = 'Order Management';
            testCase1.OrderManagementRegion__c = 'APAC';
            testCases.add(testCase1);

            Case testCase2 = new Case();
            testCase2.subject = 'Test Product Group for Delivery Helpdesk case';
            testCase2.RecordTypeId = UtilityClass.caseRecordTypeOMDHelpDesk;
            testCase2.AccountId = ihsMarkitAccount.Id;
            testCase2.ContactId = myTestContact.Id;
            testCase2.TeamSelect__c = 'Delivery';
            testCase2.DeliveryTeam__c = 'CD Distribution';
            testCases.add(testCase2);

            Case testCase3 = new Case();
            testCase3.subject = 'Test Product Group for Retail Helpdesk case';
            testCase3.RecordTypeId = UtilityClass.caseRecordTypeOMDHelpDesk;
            testCase3.AccountId = ihsMarkitAccount.Id;
            testCase3.ContactId = myTestContact.Id;
            testCase3.TeamSelect__c = 'Retail';
            testCase3.DeliveryTeam__c = 'RETAIL-Retail Purchasing';
            testCase3.Doc__c = 'DOC8381';
            testCase3.SDO__c = 'SDO8381';
            testCases.add(testCase3);
            
            insert testCases;

            ProductGroup__c orderMgmtHelpdesk = [Select Id, Name from ProductGroup__c where Name = 'Order Mgmt. Helpdesk'];
            testCase1 = [Select Id, ProductGroup__c from Case where Subject = 'Test Product Group for Order Management case'];        
            System.debug('Case created: ' + testCase1);
            System.debug('Product Group: ' + testCase1.ProductGroup__c);
            System.assertEquals(orderMgmtHelpdesk.Id, testCase1.ProductGroup__c,'Product group is not matching');

            ProductGroup__c deliveryHelpdesk = [Select Id, Name from ProductGroup__c where Name = 'Delivery Helpdesk'];
            testCase2 = [Select Id, ProductGroup__c from Case where Subject = 'Test Product Group for Delivery Helpdesk case'];        
            System.debug('Case created: ' + testCase2);
            System.debug('Product Group: ' + testCase2.ProductGroup__c);
            System.assertEquals(deliveryHelpdesk.Id, testCase2.ProductGroup__c,'Product group is not matching2');

            ProductGroup__c retailHelpdesk = [Select Id, Name from ProductGroup__c where Name = 'Retail Helpdesk'];
            testCase3 = [Select Id, ProductGroup__c from Case where Subject = 'Test Product Group for Retail Helpdesk case'];
            System.debug('Case created: ' + testCase3);
            System.debug('Product Group: ' + testCase3.ProductGroup__c);
            System.assertEquals(retailHelpdesk.Id, testCase3.ProductGroup__c,'Product group is not matching3');

            Test.stopTest();
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 20 Sep 2018
    // @description: SFDC1-9961, test method to create New Account Request case when a Customer Care case was created under Unknown Account
    //               (converted from Process Builder flow related to GDSA/Account Governance cases - original story SFDC1-683)
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
	@isTest
    static void testProcessNewAccountRequestCaseForCustomerCareCase() {
        // Setup test data 
        List<sObject> lstCountry = TestUtility.loadCountryData();
        Country__c country = (Country__c)lstCountry.get(0);
        
        Test.startTest();
        
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        String testEmail = 'dgtest@ihsmarkit.com';
        
        User myTestUser = TestUtility.createAdminUser(testEmail, true);

        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        
        System.runAs(myTestUser) {
            Account unknownAccount = TestUtility.createTestAccount('Unknown Test Account', false);
            unknownAccount.Type = 'Place Holder - Unknown Account';
            unknownAccount.DataGovernanceStatus__c = 'Approved';
            insert unknownAccount;
            
            if (unknownAccount.Id != null) {
                insert new PlaceHolderUnknownAccounts__c(Name = 'Unknown Test Account', AccountId__c = unknownAccount.Id);
            }
    
            Contact testContact = TestUtility.createContact(unknownAccount.id, 'test@ProcessNewAccountRequestCase.com', false,
                                                            'Test', 'ProcessNewAccountRequestCase');
            testContact.MailingStreet = '1234 Testing Street 1';
            testContact.MailingCity = 'Test City';
            testContact.MailingStateCode = 'TX';
            testContact.MailingCountryCode = 'US';
            insert testContact;
    
            Id caseRecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
            Case testCase = TestUtility.createCase(caseRecordTypeId, unknownAccount.Id, testContact.Id,
                                                   UserInfo.getUserId(), 'Test ProcessNewAccountRequestCaseForCustomerCareCase', false);
            testCase.AccountName__c = 'Test Case Account';
            testCase.ExternalOrgType__c = 'Others';
            testCase.InstitutionType__c = 'Other';
            testCase.PhoneNumber__c = '987-654-3210';
            testCase.Website__c = 'www.testing.co';
            testCase.Address1__c = '1234 Testing Street 1';
            testCase.Address2__c = 'Suite #2';
            testCase.City__c = 'Test City';
            testCase.Country__c = country.Id;
            testCase.Title__c = 'Mr' ;
            testCase.JobTitle__c= 'Board Member' ;
            testCase.JobFunction__c = 'Banking';
            testCase.BusinessSegment__c = 'Consumer Banking';
            testCase.GroupDesk__c = 'Active';
            testCase.ContactEmail1__c = 'abcTest@gmail.com';
            testCase.ContactName__c = 'Test';
            testCase.AccountOwnerManager__c = 'DivestedData';
            insert testCase;
    
            // search for the Account Governance case generated from the test Customer Care case above
            Case agCase = [Select Id, CaseReference__c, ContactReference__c from Case where CaseReference__c =: testCase.Id Limit 1];
            
            // expect the Account Governance case's Contact reference field is the testContact Id value
            System.assertEquals(agCase.ContactReference__c, testContact.Id,'Contact is not matching');
            
            // also expect the Account Governance case's Case reference field is the testCase Id value
            System.assertEquals(agCase.CaseReference__c, testCase.Id,'CaseId is not matching');
        }
        
        test.stopTest();
     }

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2018
    // @description: SFDC1-9961, test method when requesting New Account from a Lead
    //               (converted from Process Builder flow related to GDSA/Account Governance cases - original story SFDC1-2101)
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
	@isTest
    static void testProcessNewAccountRequestCaseFromLead() {
        // Setup test data 
        List<sObject> lstCountry = TestUtility.loadCountryData();
        Country__c country = (Country__c)lstCountry.get(0);
        
        Test.startTest();
        
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        String testEmail = 'dgtest@ihsmarkit.com';
        
        User myTestUser = TestUtility.createAdminUser(testEmail, true);

        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        
        System.runAs(myTestUser) {
            Lead testLead = new Lead();
            testLead = TestUtility.createLead('Test', 'ProcessNewAccountRequestCase', 'Testing ProcessNewAccountRequestCase Inc.', country.CountryCode__c, false);
            testLead.Email  = 'Test@ProcessNewAccountRequestCase.com';
            testLead.Description ='Unit Test for ProcessNewAccountRequestCase';
            testLead.BudgetRange__c = '< 25,000';
            testLead.LeadSource = 'Customer Care';
            
            insert testLead;
            
            Case agCase = new Case();
            agCase.AccountName__c = 'Test Case Account';
            agCase.ExternalOrgType__c = 'Others';
            agCase.InstitutionType__c = 'Other';
            agCase.PhoneNumber__c = '987-654-3210';
            agCase.Website__c = 'www.testing.co';
            agCase.Address1__c = '1234 Testing Street 1';
            agCase.Address2__c = 'Suite #2';
            agCase.City__c = 'Test City';
            agCase.Country__c = country.Id;
            agCase.Title__c = 'Mr' ;
            agCase.JobTitle__c= 'Board Member' ;
            agCase.JobFunction__c = 'Banking';
            agCase.BusinessSegment__c = 'Consumer Banking';
            agCase.GroupDesk__c = 'Active';
            agCase.ContactEmail1__c = 'abcTest@gmail.com';
            agCase.ContactName__c = 'Test';
            agCase.AccountOwnerManager__c = 'DivestedData';

            QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
            req.quickActionName = Schema.Lead.QuickAction.CreateAccountCase;
            req.record = agCase; // assign the Account Governance case instantiated above to the QuickAction
            req.contextId = testLead.Id; // set the Lead ID to set context for the QuickAction
            QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
            
            // search for the Account Governance case generated from the test Customer Care case above
            agCase = [Select Id, LeadReference__c from Case where LeadReference__c =: testLead.Id Limit 1];
            // expecting the Account Governance case's Lead reference field is the testLead Id value
            System.assertEquals(agCase.LeadReference__c, testLead.Id,'LeadId is not matching');
            
            // reloading testLead from database
            testLead = [Select Id, AccountRequested__c from Lead where Id =: testLead.Id Limit 1];
            // expecting the Account Requested flag is now set to TRUE
            System.assertEquals(true, testLead.AccountRequested__c,'requested Account is not matching');
        }
        
        test.stopTest();
     }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 18 Sep 2018
    // @description: SFDC1-9961, test method to populate related Lead/Case/Contact records upon GDSA/Account Governance Case closure
    //               (converted from Process Builder flow related to GDSA/Account Governance cases, original user stories SFDC1-965 & SFDC1-683)
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
	@isTest
    static void testPopulateRelatedLeadAndCaseAccountOnCaseClosure() {
        // Setup test data 
        List<sObject> lstCountry = TestUtility.loadCountryData();
        Country__c country = (Country__c)lstCountry.get(0);
        
        Test.startTest();
        
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        String testEmail = 'dgtest@ihsmarkit.com';
        
        User myTestUser = TestUtility.createAdminUser(testEmail, true);

        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        
        System.runAs(myTestUser) {
            Account unknownAccount = TestUtility.createTestAccount('Unknown Test Account', false);
            unknownAccount.Type = 'Place Holder - Unknown Account';
            unknownAccount.DataGovernanceStatus__c = 'Approved';
            insert unknownAccount;

            if (unknownAccount.Id != null) {
                insert new PlaceHolderUnknownAccounts__c(Name = 'Unknown Test Account', AccountId__c = unknownAccount.Id);
            }
            
            Contact testContact = TestUtility.createContact(unknownAccount.id, 'test@updateAccountGovernanceCaseLeadReference.com', false,
                                                            'Test', 'updateAccountGovernanceCaseLeadReference');
            testContact.MailingStreet = '1234 Testing Street 1';
            testContact.MailingCity = 'Test City';
            testContact.MailingStateCode = 'TX';
            testContact.MailingCountryCode = 'US';
            insert testContact;
    
            Id caseRecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
            Case testCase = TestUtility.createCase(caseRecordTypeId, unknownAccount.Id, testContact.Id,
                                                   UserInfo.getUserId(), 'Test updateAccountGovernanceCaseLeadReference', false);
            testCase.AccountName__c = 'Test Case Account';
            testCase.ExternalOrgType__c = 'Others';
            testCase.InstitutionType__c = 'Other';
            testCase.PhoneNumber__c = '987-654-3210';
            testCase.Website__c = 'www.testing.co';
            testCase.Address1__c = '1234 Testing Street 1';
            testCase.Address2__c = 'Suite #2';
            testCase.City__c = 'Test City';
            testCase.Country__c = country.Id;
            testCase.Title__c = 'Mr' ;
            testCase.JobTitle__c= 'Board Member' ;
            testCase.JobFunction__c = 'Banking';
            testCase.BusinessSegment__c = 'Consumer Banking';
            testCase.GroupDesk__c = 'Active';
            testCase.ContactEmail1__c = 'abcTest@gmail.com';
            testCase.ContactName__c = 'Test';
            testCase.AccountOwnerManager__c = 'DivestedData';
            insert testCase;
            
            Lead testLead = new Lead();
            testLead.CountryCode = country.CountryCode__c;
            
            QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
            req.quickActionName = Schema.Case.QuickAction.CreateALead;
            req.record = testLead; // assign the Lead instantiated above to the QuickAction
            req.contextId = testCase.Id; // set the Case ID to set context for the QuickAction
            QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
            
            // search for the Account Governance case generated from the test Customer Care case above
            Case agCase = [Select Id, CaseReference__c, LeadReference__c, ContactReference__c from Case where CaseReference__c =: testCase.Id Limit 1];
            
            // after the quick action was done, expect the Account Governance case's Lead reference field has the new Lead Id value
            System.assertEquals(testLead.Id, agCase.LeadReference__c,'Lead Ref is not matching');
    
            // also expect the Account Governance case's Case reference field is the testCase Id value
            System.assertEquals(testCase.Id, agCase.CaseReference__c,'Case Ref is not matching');
    
            // also expect the Account Governance case's Contact reference field is the testContact Id value
            System.assertEquals(testContact.Id, agCase.ContactReference__c,'Contact Ref is not matching');
            
            Account newAccount = new Account();
            newAccount.ExternalOrgType__c = 'Energy';
            newAccount.InstitutionType__c = 'Chemicals';
            newAccount.BillingCountryCode = country.CountryCode__c;
            
            req = new QuickAction.QuickActionRequest();
            req.quickActionName = Schema.Case.QuickAction.CreateUnapprovedAccount;
            req.record = newAccount; // assign the new Account instatiated above to the QuickAction
            req.contextId = agCase.Id; // set the Account Governance Case ID to set context for the QuickAction
            res = QuickAction.performQuickAction(req);
            
            newAccount.DataGovernanceStatus__c = 'Approved';
            update newAccount;
                    
            // reload agCase from database
            agCase = [Select Id, CaseReference__c, LeadReference__c from Case where Id =: agCase.Id Limit 1];
            agCase.TimeSpentMinutes__c = 1;
            agCase.Status = 'Closed - Resolved by IHS Markit';            
            update agCase;
            
            // reload testCase from database, expecting testCase.AccountId = newAccount.Id after the Account Governance case is closed
            testCase = [Select Id, AccountId from Case where Id =: testCase.Id Limit 1];
            System.assertEquals(newAccount.Id, testCase.AccountId,'accountId is not matching');
            
            // reload testLead from database, expecting testLead.Account__c = newAccount.Id after the Account Governance case is closed
            testLead = [Select Id, Account__c from Lead where Id =: testLead.Id Limit 1];
            System.assertEquals(newAccount.Id, testLead.Account__c,'AccountId is not matching2');
    
            // reload testContact from database, expecting testContact.AccountId = newAccount.Id after the Account Governance case is closed
            testContact = [Select Id, AccountId from Contact where Id =: testContact.Id Limit 1];
            System.assertEquals(newAccount.Id, testContact.AccountId,'accountId is not matching3');
        }
        
        test.stopTest();
     }

    //-----------------------------
    // @author: Hemant Shukla
    // @date: 18 Jan 2018
    // @param: NA
    // @description: Test method for Case trigger method fireCaseAssignmentRule after insert when case are created via quick action from Opportunity/Contract
    // @return: NA
    // @Update author: Ayan Mohanty
    // @Update date: 1 Feb 2018
    // @Update description: Updating the Test method to match account id to IHSMarkit Account Id
    // @Update author: Mohit Modi
    // @Update date: 06 Feb 2018
    // @Update description: SFDC1-6009 - Updating in Test method to account name using custom label
    // @Update author: Vishnu Vardhan Chowdary
    // @Update date: 11 Jul 2018
    // @Update description: SFDC1-6026 - Checking for email 2 case scenarion where case assignment rules
    //              shouldn't execute.
    // @Update author: Vishnu Vardhan Chowdary
    // @Update date: 07 Aug 2018
    // @Update description: SFDC1-9677 - Changing the record type to Sales Operations.
    //-----------------------------
	@isTest
    static void testFireCaseAssignmentRule() {
        
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress(label.CaseAccountNameForSalesSupport, 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
                                                                  
        String testEmail = 'dgtest@ihsmarkit.com';
        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        
        String recordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Sales Operations');
        List<Case> caseList = new List<Case> ();
        Case supportCase1 = new Case(Subject = 'Case from quick Action',
                                    RecordTypeId = recordTypeId,
                                    AccountId = ihsMarkitAccount.Id,
                                    ContactId = myTestContact.id,
                                    Type = 'Pricing',
                                    Description = 'Quick Action Case',
                                    AssignToQueue__c = true
                                    );
        caseList.add(supportCase1);
        Case supportCase2 = new Case(Subject = 'Case from quick Action',
                                    RecordTypeId = recordTypeId,
                                    AccountId = ihsMarkitAccount.Id,
                                    ContactId = myTestContact.id,
                                    Type = 'Pricing',
                                    Description = 'Quick Action Case',
                                    AssignToQueue__c = true,
                                    SuppliedEMail = testEmail
                                    );
        caseList.add(supportCase2);
        Test.startTest();
        insert caseList;
        List<Case> testCaseList = new List<Case>([select Id, OwnerID, SuppliedEMail from Case]);
        System.assertEquals(testCaseList.size(),2,'Case count is not matching');
        supportCase1 = testCaseList.get(0);
        supportCase2 = testCaseList.get(1);
        //Case assignment rule will be called when Supplied email is empty, and for
        //other one case assignment rule will not be set. So, will be the current user.
        System.assertNotEquals(userInfo.getUserId(),supportCase1.OwnerID,'OwnerId is not matching');
        System.assertEquals(userInfo.getUserId(),supportCase2.OwnerID,'OwnerId is not matching2');
        //system.assert(userInfo.getUserId() != [select Id, OwnerID from Case where Id = :supportCase.id].OwnerID);
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 06 Feb 2018
    // @param: NA
    // @description: Test method for Case trigger method setContactNamefromOwner after insert or update of Owner when case are created of SalesSupport RecordType    // 
    // 
    // @ModifiedBy: Harshit Singhal
    // @Date: 04 Jun 2018
    // @Description: SFDC1-8551, Updating test method to cover code changes made for Salesforce Helpdesk record type
    // 
    // @ModifiedBy: Vishnu Vardhan
    // @Date: 16 Aug 2018
    // @Description: SFDC1-8534, Verifying entitlement id, is set to Salesforce helpdesk 
    // 
    // @ModifiedBy: Sruti Srivastava
    // @Date: 11 Sept 2018
    // @Description: SFDC1-9761, Updating test method to cover code changes made for Salesforce Suggestion record type
    // 
    // @ModifiedBy: Harshit Singhal
    // @Date: 08 Jul 2020
    // @Description: SFDC-2375, Updated to remove test class code for Sales Operations record type from this method as it is not relevant.
    // @return: NA
    //-----------------------------
	@isTest
    static void testsetContactNamefromOwner() {
                
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress(label.CaseAccountNameForSalesSupport, 
                                                                            '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                            'London', '', 'GB', true);
        
        Contact ihsContact = TestUtility.createContact(ihsMarkitAccount.id,UserInfo.getUserEmail(),true,'TestConactfirstName','TestContactlastName');
        String recordTypeIdSH = UtilityClass.getObjectRecordTypeId('Case', 'Salesforce Helpdesk');
        String recordTypeIdSS = UtilityClass.getObjectRecordTypeId('Case', 'Salesforce - Suggestion');
        List<Case> insertCaseList = new List<Case>();        
        
        Case shCase1 = new Case(RecordTypeId = recordTypeIdSH,ObjectTool__c='Cases',BusinessArea__c='Configuration',Status='New',Subject='Test Subject',Description='Test Description', Origin='Quick Action');        
        Case objSuggestionCase = new Case(RecordTypeId = recordTypeIdSS,ObjectTool__c='Cases',BusinessArea__c='Sales',Status='New',Subject='Test Subject',Description='Test Description', Origin='Quick Action');        
        insertCaseList.add(shCase1);
        insertCaseList.add(objSuggestionCase);
        
        User uobj = TestUtility.createTestUser('System Administrator','testusername@ihsmarkit.com',true);
        Contact ihsContactUpdate = TestUtility.createContact(ihsMarkitAccount.id,'testusername@ihsmarkit.com',true,'TestConactfirstName1','TestContactlastName1');   
        
        Case shCase2 = new Case(RecordTypeId = recordTypeIdSH,ObjectTool__c='Cases',BusinessArea__c='Configuration',ContactId=ihsContactUpdate.Id,AccountId = ihsMarkitAccount.Id,Status='New',Subject='Test Subject2',Description='Test Description2', Origin='Quick Action');
        insertCaseList.add(shCase2);
        
        Test.startTest();
        //insert Cases;
        if(insertCaseList.size()>0) {
            insert insertCaseList;
        }
        system.assertEquals(ihsContact.id , [select Id, ContactId from Case where Id = :objSuggestionCase.id].ContactId,'contactId is not matching' );
        System.assertEquals(ihsMarkitAccount.Id,[select Id, AccountId from Case where Id = :objSuggestionCase.id].AccountId,'accountId is not matching');
        System.assertEquals(ihsContact.id ,[select Id, ContactId from Case where Id = :shCase1.id].ContactId,'contactId is not matching2' );
        System.assertEquals(ihsMarkitAccount.Id,[select Id, AccountId from Case where Id = :shCase1.id].AccountId,'accountId is not matching2');
        System.assertEquals(ihsContactUpdate.id ,[select Id, ContactId from Case where Id = :shCase2.id].ContactId,'contactId is not matching3' );
        Test.stopTest();        
    }
     
    //-----------------------------
    // @author: Vishnu Vardhan  
    // @date: 16 May 2018
    // @param: NA
    // @description:7183 test coverage for afterAllCaseClosedOnContract method on caseMethod class.
    //               Negative testing that contract should not be updated.  
    //-----------------------------
	@isTest
    private static void testafterAllCaseClosedOnOFContract() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        Contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        insert contract1;
        
        // creating case
        List<Case> caseList = new List<Case>();
        Id implementationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Test.startTest();
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 1';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.Contract__c= contract1.id;
        testCase1.ProductGroup__c = pg.id;
        testCase1.OnboardingCaseRequired__c=FALSE;
        testCase1.RecordTypeId = implementationRecordTypeId;
        insert testCase1;

        testCase1.status = 'Closed - Resolved by IHS Markit';
        update testCase1;

        Contract ctrct= [Select id, ContractStatus__c, Status from contract where ID =: contract1.id];
        System.assertEquals('Creation',ctrct.Status,'Contract Status is not matching');
        System.assertEquals('Open',ctrct.ContractStatus__c,'Contract Status is not matching2');

        Test.stopTest();
    }

    //-----------------------------
    // @author: Vishnu Vardhan  
    // @date: 16 May 2018
    // @param: NA
    // @description:7183 test coverage for afterAllCaseClosedOnContract method on caseMethod class.
    //               testing that contract should be updated.   
    //-----------------------------
	@isTest
    private static void testAfterAllCaseClosedOnContract() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@ihsmarkit.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                  'No', 'No', 'No', 'No', 'Yes', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id trailRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        contract1.RecordTypeId = trailRecordTypeId;
        contract1.Fastrack__c = TRUE;
        insert contract1;
        
        // creating case
        List<Case> caseList = new List<Case>();
        Id implementationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id caseOrderManagementRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Test.startTest();
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 1';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.Contract__c= contract1.id;
        testCase1.ProductGroup__c = pg.id;
        testCase1.OnboardingCaseRequired__c=FALSE;
        testCase1.RecordTypeId = implementationRecordTypeId;
        
        Case testCase2 = new Case();
        testCase2.subject = 'Test subject afterAllCaseClosedOnContract 2';
        testCase2.AccountId = a.Id;
        testCase2.contactId = c.Id;
        testCase2.Contract__c= contract1.id;
        testCase2.ProductGroup__c = pg.id;
        testCase2.OnboardingCaseRequired__c=FALSE;
        testCase2.RecordTypeId = implementationRecordTypeId;
        
        Case testCase3 = new Case();
        testCase3.subject = 'Test subject afterAllCaseClosedOnContract 3';
        testCase3.AccountId = a.Id;
        testCase3.contactId = c.Id;
        testCase3.Contract__c= contract1.id;
        testCase3.RecordTypeId = caseOrderManagementRecordId;
        
        caseList.add(testCase1);
        caseList.add(testCase2);
        caseList.add(testCase3);
        insert caseList;
        
        testCase2.status = 'Closed - Resolved by IHS Markit';
        testCase3.status = 'Rejected';
        testCase3.ReasonForRejection__c = 'RAD Approval Required';
        
        caseList = new List<Case>();
        caseList.add(testCase2);
        caseList.add(testCase3);
        update caseList;
        // Still 1 Test case is open here, Dont update contract.
        Contract ctrct= [Select id, ContractStatus__c, Status from contract where ID =: contract1.id];
        System.assertEquals('Creation',ctrct.Status,'contactstatus is not matching1');
        System.assertEquals('Open',ctrct.ContractStatus__c,'contractstatus is not matching2');

        testCase1.status = 'Closed - Resolved by IHS Markit';
        update testCase1;
        //Now contract has to be updated as per the requirement. 
        ctrct= [Select id, ContractStatus__c, Status from contract where ID =: contract1.id];
        // SFDC-1429 No longer need to move Trial & Continuation Letter Contract Stage to 11-Completed after all Implementation Cases are closed
        // System.assertEquals('Complete',ctrct.Status);
        // System.assertEquals('Delivered to Customer',ctrct.ContractStatus__c);
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan  
    // @date: 18 May 2018
    // @param: NA
    // @description:7740 test coverage for updateContractWhenOMCaseIsValidated method on caseMethod class.
    // @modified by: Vishnu Vardhan
    // @date: 14 Jun 2018
    // @description: SFDC1-8337: Updating test case for this story.
    //-----------------------------
	@isTest
    private static void testUpdateContractWhenOMCaseIsValidated() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@ihsmarkit.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        contract1.OrderReason__c = 'New';
        contract1.RenewalDate__c = System.today() + 30; // SFDC-1397 RenewalDate__c is required if RenewalTerm__c != 'One-time Expiring'
        contract1.BillingFrequency__c = 'Monthly'; // SFDC-1397 BillingFrequency__c is required if RenewalTerm__c != 'One-time Expiring'
        contract1.UsageReportsRequired__c = 'No'; // SFDC-1397 UsageReportsRequired__c is required if RenewalTerm__c != 'One-time Expiring'
        insert contract1;
        TestUtility.createContractAttachment(contract1.id);
        // creating case
        Id caseOrderManagementRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Test.startTest();
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 3';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.Contract__c= contract1.id;
        testCase1.status = 'New';
        testCase1.RecordTypeId = caseOrderManagementRecordId;
        testCase1.SAPProcessedContractNumber__c = 'CT123564';
        insert testCase1;

        testCase1.status = 'Validated';
        Update testCase1;
        // Contract status should be updated to Validated
        Contract ctrct = [Select id, ContractStatus__c from contract where ID =: contract1.id];
        System.assertEquals('Validated',ctrct.ContractStatus__c,'contractstatus is not matching1');

        //Now update Contract status should to Validated PO Pending
        testCase1.status = 'Validated PO Pending';
        update testCase1;
        //Now contract should be updated as Validated PO Pending. 
        ctrct= [Select id, Status, ContractStatus__c from contract where ID =: contract1.id];
        System.assertEquals('Validated PO Pending',ctrct.ContractStatus__c,'contractstatus is not matching2');
        
        ctrct.Status = 'Complete';
        ctrct.ContractStatus__c = 'Scheduled Termination';
        update ctrct;
        
        testCase1.status = 'Validated';
        Update testCase1;
        // Contract status should still be Scheduled Termination and not updated to Validated
        ctrct = [Select id, ContractStatus__c from contract where ID =: contract1.id];
        System.assertEquals('Scheduled Termination',ctrct.ContractStatus__c,'contractstatus is not matching3');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Sharique Iqbal  
    // @date: 4th Feb 2021
    // @param: NA
    // @description:SFDC-2551 test coverage for updateContractWhenOMCaseIsValidated method on caseMethod class.
    //-----------------------------
	@isTest
    private static void testUpdateContractWhenOMCaseIsValidatedByConsOps() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@ihsmarkit.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        contract1.OrderReason__c = 'New';
        contract1.RenewalDate__c = System.today() + 30; // SFDC-1397 RenewalDate__c is required if RenewalTerm__c != 'One-time Expiring'
        contract1.BillingFrequency__c = 'Monthly'; // SFDC-1397 BillingFrequency__c is required if RenewalTerm__c != 'One-time Expiring'
        contract1.UsageReportsRequired__c = 'No'; // SFDC-1397 UsageReportsRequired__c is required if RenewalTerm__c != 'One-time Expiring'
        insert contract1;
        
        // creating case
        Id caseOrderManagementRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Test.startTest();
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 3';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.Contract__c= contract1.id;
        testCase1.status = 'New';
        testCase1.RecordTypeId = caseOrderManagementRecordId;
        testCase1.SAPProcessedContractNumber__c = 'CT123564';
        insert testCase1;

        testCase1.status = 'Validated by ConsOps';
        Update testCase1;
        // Contract status should be updated to Validated by ConsOps
        Contract ctrct = [Select id, ContractStatus__c from contract where ID =: contract1.id];
        System.assertEquals('Validated by ConsOps',ctrct.ContractStatus__c,'Case record update failed');

        //Now update Contract status should to Validated-BSI Pending
        testCase1.status = 'Validated-BSI Pending';
        update testCase1;
        //Now contract should be updated as Validated-BSI Pending. 
        ctrct= [Select id, Status, ContractStatus__c from contract where ID =: contract1.id];
        System.assertEquals('Validated-BSI Pending',ctrct.ContractStatus__c,'Case record update failed');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan  
    // @date: 21 May 2018
    // @param: NA
    // @description:7740 test coverage for updateContractWhenOMCaseIsRejected method on caseMethod class.
    //-----------------------------
	@isTest
    private static void testupdateContractWhenOMCaseIsRejected() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@ihsmarkit.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Opportunity testOpportunity = TestUtility.createOpportunity(a.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        testOpportunity.ContractEndDate__c = System.today() + 180;
        testOpportunity.ContractStartDate__c = System.today();
        insert testOpportunity;
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        contract1.Opportunity__c = testOpportunity.id;
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        insert contract1;
        
        // creating case
        Id caseOrderManagementRecordId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Test.startTest();
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 3';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.Contract__c= contract1.id;
        testCase1.status = 'New';
        testCase1.RecordTypeId = caseOrderManagementRecordId;
        insert testCase1;
        
        testCase1.status = 'Rejected';
        testCase1.ReasonForRejection__c = 'Special Membership Authorization';
        Update testCase1;
        // Contract status should be updated to Rejected
        Contract ctrct = [Select id, ContractStatus__c, status from contract where ID =: contract1.id];
        System.assertEquals('Rejected',ctrct.ContractStatus__c,'contract status is not matching1');
        System.assertEquals('Creation',ctrct.status,'contract status is not matching2');
        Test.stopTest();
    }
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 21 March 2018
    // @param: NA
    // @description: SFDC1-7163: To test that validation exception is thrown if implementation 
    //              case has contract other than order form and onboardingCaserequired Field is checked
    //-----------------------------
    @isTest
    static void testOnboardingCaseNotCreatedForTrialContract() {
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact con = TestUtility.createContact(acc.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = con.Id, IsPrimary=true);
        insert ocr;

        Test.startTest();
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        OpportunityLineItem oli = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        List<Id> oliIds = new List<Id>();
        oliIds.add(oli.Id);
        Id trailRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Id trialContractRecId = ContractRecordTypeSelectionController.createTrialContractRecord(testOpportunity.Id,System.JSON.serialize(oliIds));
        // creating case
        Id implementationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();

        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 1';
        testCase1.AccountId = acc.Id;
        testCase1.Contract__c= trialContractRecId;
        testCase1.OnboardingCaseRequired__c=FALSE;
        testCase1.RecordTypeId = implementationRecordTypeId;
        insert testCase1;
        System.debug('Case created : '+testCase1);
        //This field will be checked after creating case, but not while inserting. That is the requirement
        System.debug('Validation exception should be done : ');
        testCase1.OnboardingCaseRequired__c = True;
        boolean exceptionRaised = false;
        try {
            //Verify that update will fail, as contract should be Order form record type id.
            update testCase1;
        } catch (Exception e) {
            exceptionRaised= true;
        }
        System.assert(exceptionRaised,'Exception is not raised');
        Test.stopTest();
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 21 March 2018
    // @param: NA
    // @description: SFDC1-7163: To test that case is either created or deleted when case has order form contract
    //               and onboardingCaseRequired Field is checked or unchecked
    //-----------------------------
    @isTest
    static void testOnboardingCaseCreatedForOrderFormContract() {
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact con = TestUtility.createContact(acc.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = con.Id, IsPrimary=true);
        insert ocr;
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();

        Id ofContractRecId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        // creating case
        Id implementationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id onBoardingRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();

        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 1';
        testCase1.AccountId = acc.Id;
        testCase1.Contract__c= ofContractRecId;
        testCase1.OnboardingCaseRequired__c=FALSE;
        testCase1.RecordTypeId = implementationRecordTypeId;
        insert testCase1;
        System.debug('Case created : '+testCase1);
        Test.startTest();
        //This field will be checked after creating case, but not while inserting. That is the requirement
        //Check that child case is created, and record type is Onboarding, account is related to account.
        System.debug('Create Child case : ');
        testCase1.OnboardingCaseRequired__c = True;
        update testCase1;
        Case childCase = [select id, recordTypeId, contactId, accountId from case where ParentId =: testCase1.id];
        System.assertEquals(null, childCase.ContactId,'contact Id is not matching');
        System.assertEquals(onBoardingRecordTypeId, childCase.recordTypeId,'RecordtypeId is not matching');
        System.assertEquals(testCase1.accountId, childCase.accountId,'accountId is not matching');
        System.debug('Before changing contact : ');
        //Verify that child case is updated with Contact.
        testCase1.contactId = con.Id;
        update testCase1;
        childCase = [select id, recordTypeId, contactId, accountId from case where ParentId =: testCase1.id];
        System.assertEquals(con.Id, childCase.ContactId,'contactId is not matching2');
        System.assertEquals(onBoardingRecordTypeId, childCase.recordTypeId,'RecordtypeId is not matching2');
        System.assertEquals(testCase1.accountId, childCase.accountId,'accountId is not matching2');
        System.debug('Before deleting child case : ');
        testCase1.OnboardingCaseRequired__c = False;
        //Check that child case is deleted
        update testCase1;
        List<Case> childCases = [select id, recordTypeId, contactId, accountId from case where ParentId =: testCase1.id];
        System.assert(childCases.isEmpty());
        Test.stopTest();
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 04 April 2018
    // @param: NA
    // @description: SFDC1-6382: To test that ACF deletion and creation works properly even when ACTL records get 
    //              changed in between, earlier this was never covered or tested. 
    //-----------------------------
    @isTest
    static void testSetCaseAdditionalFieldsObjectOnACTLChange() {
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id OId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRG;
        
        Case testCase = new Case();
        testCase.RecordTypeId = OId;
        testCase.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase.AccountId = a.Id;
        testCase.ProductGroup__c = pg.Id;
        insert testCase;
        
        Test.startTest();
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        list <Case> testCaseResult = [Select AdditionalFields__c, Id from case where Id = :testCase.Id];
        list <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        System.assertEquals(1, testCaseResult.size(),'list size is not matching');
        System.assertEquals(0, additionalCaseFieldsList.size(),'ACF list size is not matching');
        //Now insert a new ACTL record, 

        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRGOB = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRGOB.CaseRecordType__c = 'Onboarding';
        aCaseTypeLinkingNRGOB.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRGOB.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRGOB;
        
        //Earlier an exception was being thrown and it should be fixed now, and case should be updated.
        testCase.RecordTypeId = CCId;
        update testCase;
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        testCaseResult = [Select AdditionalFields__c, Id from case where Id = :testCase.Id];
        additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        System.assertEquals(1, testCaseResult.size(),'case list size is not matching');
        System.assertEquals(1, additionalCaseFieldsList.size(),'ACF list is not matching2');
        System.assertEquals(additionalCaseFieldsList[0].Id, testCaseResult[0].AdditionalFields__c,'ACF is not matching');
        
        delete aCaseTypeLinkingNRG;
        testCase.RecordTypeId = oId;
        update testCase;
        GlobalConstants.hasAdditionalCaseFieldsCreationExecuted = false;
        testCaseResult = [Select AdditionalFields__c, Id from case where Id = :testCase.Id];
        additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        
        System.assertEquals(1, testCaseResult.size(),'case list is not matching3');
        System.assertEquals(1, additionalCaseFieldsList.size(),' ACF list size is not matching');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 09 Mar 2018
    // @param: NA
    // @description: Test method for Case trigger methods assignCasesViaTriage on insert
    // @return: NA
    //-----------------------------
	@isTest
     private static void testAssignCasesViaTriageForMSERV() {
        ID CustomerCareRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        String testEmail = 'dgtest@test.com';
        c.EmailUnknown__c = TRUE;
        c.Phone = '1234567890';
        insert c;
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        Group g1;
        QueuesObject q1;
        List<Group> lstAllQueues;
        System.runAs(myTestUser) {
            List<String> lstQueueNames = new List<String>();
            lstQueueNames.add(System.label.DefaultMSERVQueue);
            
            lstAllQueues = new List<Group>([Select Id,name From Group where Type = 'Queue' and Name in : lstQueueNames LIMIT 1]);
        }
        ProductGroup__c prdGRP = new ProductGroup__c();
        insert prdGRP;
        ID IHSTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('IHS').getRecordTypeId();
        ID MarkitSERVTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('MarkitSERV').getRecordTypeId();
        Test.startTest();
        List<TriageCriteria__c> lstTRCCriteria = new List<TriageCriteria__c>();
        TriageCriteria__c trc1 = new TriageCriteria__c(RecordTypeId=MarkitSERVTriageRecordTypeId ,Priority__c=1,Queue__c=lstAllQueues[0].Name,Subject__c = 'hello');
        lstTRCCriteria.add(trc1);
        insert lstTRCCriteria ;
        CaseTriageExecutionOrder__c customSettingRec1 = new CaseTriageExecutionOrder__c(Name = '1',Field__c = 'Priority__c',ASC__c = true,DESC__c = false);
        insert customSettingRec1 ;
        
        CaseTriageMappingForAssignment__c customSettingRec2 = new CaseTriageMappingForAssignment__c(Name = '1',CaseField__c = 'Subject',TriageField__c = 'Subject__c');
        CaseTriageMappingForAssignment__c customSettingRec3 = new CaseTriageMappingForAssignment__c(Name = '2',CaseField__c = 'ProductGroup__c',TriageField__c = 'ProductGroup__c');
        List<CaseTriageMappingForAssignment__c> lstCaseTriageRecords = new List<CaseTriageMappingForAssignment__c>();
        lstCaseTriageRecords.add(customSettingRec2);
        lstCaseTriageRecords.add(customSettingRec3); 
        insert lstCaseTriageRecords;
        
        List<Case> lstCase = new List<Case>();
        Case testCase = new Case();
        testCase.subject = 'hello';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.RecordTypeId = CustomerCareRecordTypeId;
        testCase.Origin = System.Label.EmailFromValue;
        lstCase.add(testCase); 
        insert lstCase; 

        Case cse = [Select id, ownerId, owner.name, currentQueue__c from Case where id =: lstCase[0].id];        
        System.assertEquals(String.valueOf(cse.ownerId).substring(0,15) , String.valueOf(lstAllQueues[0].id).substring(0,15),'Results dont match'); 
        System.assertEquals(lstAllQueues[0].name, cse.currentQueue__c,'Queue does not match');
        Test.stopTest(); 
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 30 May 2018
    // @param: NA
    // @description: Test method for Case trigger methods assignCasesViaTriageforMarkit on insert
    // @return: NA
    //-----------------------------
	@isTest
     private static void testAssignCasesViaTriageForMarkit() {
        ID CustomerCareRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'Test123';
        c.AccountId = a.Id;
        String testEmail = 'dgtest@test.com';
        c.EmailUnknown__c = TRUE;
        c.Phone = '1234567890';
        insert c;
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        Group g1;
        QueuesObject q1;
        List<Group> lstAllQueues;
        System.runAs(myTestUser) {
            List<String> lstQueueNames = new List<String>();
            lstQueueNames.add(System.label.DefaultMarkitQueue);
            
            lstAllQueues = new List<Group>([Select Id,name From Group where Type = 'Queue' and Name in : lstQueueNames LIMIT 1]);
        }
        ProductGroup__c prdGRP = new ProductGroup__c();
        insert prdGRP;
        ID IHSTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('IHS').getRecordTypeId();
        ID MarkitSERVTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('Markit').getRecordTypeId();
        Test.startTest();
        List<TriageCriteria__c> lstTRCCriteria = new List<TriageCriteria__c>();
        TriageCriteria__c trc1 = new TriageCriteria__c(RecordTypeId=MarkitSERVTriageRecordTypeId ,Priority__c=1,Queue__c=lstAllQueues[0].Name,Subject__c = 'hello');
        lstTRCCriteria.add(trc1);
        insert lstTRCCriteria ;
        CaseTriageExecutionOrder__c customSettingRec1 = new CaseTriageExecutionOrder__c(Name = '1',Field__c = 'Priority__c',ASC__c = true,DESC__c = false);
        insert customSettingRec1 ;
        
        CaseTriageMappingForAssignment__c customSettingRec2 = new CaseTriageMappingForAssignment__c(Name = '1',CaseField__c = 'Subject',TriageField__c = 'Subject__c');
        CaseTriageMappingForAssignment__c customSettingRec3 = new CaseTriageMappingForAssignment__c(Name = '2',CaseField__c = 'ProductGroup__c',TriageField__c = 'ProductGroup__c');
        List<CaseTriageMappingForAssignment__c> lstCaseTriageRecords = new List<CaseTriageMappingForAssignment__c>();
        lstCaseTriageRecords.add(customSettingRec2);
        lstCaseTriageRecords.add(customSettingRec3); 
        insert lstCaseTriageRecords;
        
        List<Case> lstCase = new List<Case>();
        Case testCase = new Case();
        testCase.subject = 'hello';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.RecordTypeId = CustomerCareRecordTypeId;
        testCase.Origin = System.Label.EmailFromValueMarkit;
        lstCase.add(testCase); 
        insert lstCase; 

        Case cse = [Select id, ownerId,owner.name, currentQueue__c from Case where id =: lstCase[0].id];        
        System.assertEquals(String.valueOf(cse.ownerId).substring(0,15) , String.valueOf(lstAllQueues[0].id).substring(0,15),'Results dont match'); 
        System.assertEquals(lstAllQueues[0].name, cse.currentQueue__c,'Queue does not match');
        Test.stopTest(); 
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 09 Mar 2018
    // @param: NA
    // @description: Test method for Case trigger methods assignCasesViaTriage on insert
    // @return: NA
    //-----------------------------
	@isTest
     private static void testAssignCasesViaTriageForIHS() {
        ID CustomerCareRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        String testEmail = 'dgtest@test.com';
        c.EmailUnknown__c = TRUE;
        c.Phone = '1234567890';
        insert c;
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        Group g1;
        QueuesObject q1;
        List<Group> lstAllQueues;
        System.runAs(myTestUser) {
            List<String> lstQueueNames = new List<String>();
            lstQueueNames.add(System.label.TestDefaultIHSQueue);
            
            lstAllQueues = new List<Group>([Select Id,name From Group where Type = 'Queue' and Name in : lstQueueNames LIMIT 1]);
        }
        ProductGroup__c prdGRP = new ProductGroup__c();
        insert prdGRP;
        ID IHSTriageRecordTypeId = Schema.Sobjecttype.TriageCriteria__c.getRecordTypeInfosByName().get('IHS').getRecordTypeId();
        Test.startTest();
        List<TriageCriteria__c> lstTRCCriteria = new List<TriageCriteria__c>();
        TriageCriteria__c trc2 = new TriageCriteria__c(RecordTypeId=IHSTriageRecordTypeId ,Priority__c=1,Queue__c=lstAllQueues[0].Name,ProductGroup__c = prdGRP.Id);
        system.debug('trc2---'+trc2);
        lstTRCCriteria.add(trc2);
        insert lstTRCCriteria ;
        CaseTriageExecutionOrder__c customSettingRec1 = new CaseTriageExecutionOrder__c(Name = '1',Field__c = 'Priority__c',ASC__c = true,DESC__c = false);
        insert customSettingRec1 ;
        
        CaseTriageMappingForAssignment__c customSettingRec2 = new CaseTriageMappingForAssignment__c(Name = '1',CaseField__c = 'Subject',TriageField__c = 'Subject__c');
        CaseTriageMappingForAssignment__c customSettingRec3 = new CaseTriageMappingForAssignment__c(Name = '2',CaseField__c = 'ProductGroup__c',TriageField__c = 'ProductGroup__c');
        List<CaseTriageMappingForAssignment__c> lstCaseTriageRecords = new List<CaseTriageMappingForAssignment__c>();
        lstCaseTriageRecords.add(customSettingRec2);
        lstCaseTriageRecords.add(customSettingRec3); 
        insert lstCaseTriageRecords;
        
        List<Case> lstCase = new List<Case>(); 
        Case testCase1 = new Case();
        testCase1.subject = 'hello';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.ProductGroup__c = prdGRP.Id;
        testCase1.RecordTypeId = CustomerCareRecordTypeId; 
        testCase1.Origin = 'Internal'; 
        testCase1.OwnerId = myTestUser.Id;              
        lstCase.add(testCase1);
        insert lstCase; 
        
        testCase1.OwnerId = System.Label.ToBeAssignedQueueId;
        update testCase1;    

        Case cse1 = [Select id, ownerId, owner.name,currentQueue__c from Case where id =: testCase1.id];
        System.assertEquals(String.valueOf(cse1.ownerId).substring(0,15), String.valueOf(lstAllQueues[0].id).substring(0,15),'Results dont match');
        System.assertEquals(lstAllQueues[0].name, cse1.currentQueue__c,'Current queue does not match');
        Test.stopTest();    
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 30 May 2018
    // @param: NA
    // @description: Test method for Case trigger methods populateCaseLookUpFields on insert
    // @return: NA
    // @LastModifieddate : 18 July 2018
    // @LastModifieby : Mohit Modi
    // @LastModifieddescription : SFDC1-9031-Commenting this Method as field ContractOwner__c and OpportunityOwner__c is nomore required.
    //-----------------------------
    /*
	@isTest
    private static void testPopulateCaseLookUpFields() {
        String recordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Sales Support');
        Test.startTest();
        String testEmail = 'opptyOwnertest@ihsmarkit.com';
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        Account acc = TestUtility.createTestAccountWithAddress(label.CaseAccountNameForSalesSupport, 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        Contact con = TestUtility.createContact(acc.Id,'opptyOwnertest@ihsmarkit.com' ,true,'Test', 'testCaseOpptyOwner');
        Opportunity testOpportunity;
        Contract contract1;
        System.runAs(myTestUser) {
            testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
            //creating contract
            Product2 testProd = TestUtility.createProduct('Test Product', true);
            Id standardId = Test.getStandardPricebookId();
            PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
            
            LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
            List<Country__c> lstCountry = TestUtility.loadCountryData();
            Country__c country = lstCountry.get(0);
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            
            contract1 = TestUtility.createContractWithInsertOptional(acc.Id, legalEntity.Id, country.Id, standardId,FALSE);
            contract1.RecordTypeId = orderFormRecordTypeId;
            contract1.Fastrack__c = TRUE;
            Contract1.Status = 'Creation';
            contract1.ContractStatus__c = 'Open';
            insert contract1;
        }
        Case supportCase = new Case(Subject = 'Case from quick Action',
                                    RecordTypeId = recordTypeId,
                                    AccountId = acc.Id,
                                    ContactId = con.id,
                                    Opportunity__c = testOpportunity.Id,
                                    Contract__c = contract1.Id,
                                    Type = 'Sales OPs',
                                    Description = 'Related list Case',
                                    AssignToQueue__c = true
                                    );
        insert supportCase;
        Case c = [Select OpportunityOwner__c from Case where Id =: supportCase.Id];
        System.assert(c.OpportunityOwner__c != null);
        Test.stopTest();
    }
    */
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 03 July 2018
    // @param: NA
    // @description: Test method for Case trigger methods ValidateCaseContactAndAccountMatch on insert
    // @return: NA
    //-----------------------------
    /*private static void testValidateCaseContactAndAccountMatch() {
        Test.startTest();
        Id implementationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        List<Account> listAcct = new List<Account>();
        List<Case> listCase = new List<Case>();
        Account acc1 = TestUtility.createTestAccountWithAddress('TestImplementationAccount', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', false);
        Account acc2 = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        listAcct.add(acc1);
        listAcct.add(acc2);
        insert listAcct;
        Contact con = TestUtility.createContact(acc1.Id,'opptyOwnertest@ihsmarkit.com' ,true,'Test', 'testCaseOpptyOwner');
        Opportunity testOpportunity = TestUtility.createOpportunity(acc1.Id, 'test Opppy', true);
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract1 = TestUtility.createContractWithInsertOptional(acc1.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        Contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        insert contract1;
        Case case1 = new Case(Subject = 'Case Impl Record',
                                    RecordTypeId = implementationRecordTypeId,
                                    AccountId = acc1.Id,
                                    ContactId = con.id,
                                    Opportunity__c = testOpportunity.Id,
                                    Contract__c = contract1.Id,
                                    Type = 'Continuation',
                                    Description = 'Case Impl Record',
                                    AssignToQueue__c = true
                                    );
        listCase.add(case1);
        Case case2 = new Case(Subject = 'Case Impl Record',
                                    RecordTypeId = implementationRecordTypeId,
                                    AccountId = acc2.Id,
                                    ContactId = con.id,
                                    Opportunity__c = testOpportunity.Id,
                                    Contract__c = contract1.Id,
                                    Type = 'Continuation',
                                    Description = 'Case Impl Record',
                                    AssignToQueue__c = true
                                    );
        listCase.add(case2);
        String errMsg;
        try {
            insert listCase;
        } catch (DMLException e) {
            errMsg = e.getMessage();
        }
        System.assert(errMsg.contains(System.Label.CaseContactAndAccountMatchMSG));
        Test.stopTest();
    }*/
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 12 July 2018
    // @param: NA
    // @description: Test method for Case trigger methods populateOMDeliveryHelpDeskCaseFields on before insert
    // @return: NA
    //-----------------------------
	@isTest
    private static void testPopulateOMDeliveryHelpDeskCaseFields() {
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        List<Account> listAcct = new List<Account>();
        Account acc1 = TestUtility.createTestAccountWithAddress('TestImplementationAccount', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', false);
        Account acc2 = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        listAcct.add(acc1);
        listAcct.add(acc2);
        insert listAcct;
        
        User myTestUser = TestUtility.createAdminUser('opptyOwnertest@ihsmarkit.com', true);
        Contact con = TestUtility.createContact(acc1.Id,'opptyOwnertest@ihsmarkit.com' ,false,'Test', 'testCaseOpptyOwner');
        Contact con1 = TestUtility.createContact(acc1.Id,'abctest@ihsmarkit.com' ,false,'Tes1', 'testCaseOpptyOwner1');
        List<Contact> lstCon = new List<Contact>();
        lstCon.add(con);
        lstCon.add(con1);
        insert lstCon;
        
        Opportunity testOpportunity = TestUtility.createOpportunity(acc1.Id, 'test Opppy', true);
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        Test.startTest();

        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract1 = TestUtility.createContractWithInsertOptional(acc1.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contract1.RecordTypeId = orderFormRecordTypeId;
        contract1.Fastrack__c = TRUE;
        Contract1.Status = 'Creation';
        contract1.ContractStatus__c = 'Open';
        Contract1.SAPPGId__c = 'New';
        insert contract1;
        
        ContractContactRole cRoleObj = new ContractContactRole(contractId = contract1.Id,isprimary = true, contactid=con1.Id);
        insert cRoleObj;
        Test.stopTest();
        System.runAs(myTestUser) {
        Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId();
            Case case1 = new Case(Subject = 'Case OM/Delivery Helpdesk Record',
                                        RecordTypeId = recTypeId,
                                        AccountId = acc1.Id,                                        
                                        //Opportunity__c = testOpportunity.Id,
                                        Contract__c = contract1.Id,
                                        //Type = 'Continuation',
                                        Description = 'Case Impl Record',
                                        //AssignToQueue__c = true
                                        DeliveryTeam__c = 'CD Distribution'
                                        );
            insert case1;
            Case c = [select ContactId, ContactReference__c from case where id =: case1.id];
            system.assert(c.ContactReference__c  == con1.id,'Contact reference does not match');
        }
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 23 August 2018
    // @param: NA
    // @description: SFDC1-9441: To test that realted list of implementation case is copied 
    //              to the onboarding case.
    //-----------------------------
    @isTest
    static void testCreateRelatedListForOnboardingCase() {
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact con = TestUtility.createContact(acc.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = con.Id, IsPrimary=true);
        insert ocr;
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();

        Id ofContractRecId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        // creating case
        Id implementationRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id onBoardingRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();

        List<ProductGroup__c> productGroups = new List<ProductGroup__c> ();
        productGroups.add(new ProductGroup__c(Name = 'Order Mgmt. Helpdesk'));
        productGroups.add(new ProductGroup__c(Name = 'Delivery Helpdesk'));
        productGroups.add(new ProductGroup__c(Name = 'Retail Helpdesk'));
        insert productGroups;
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 1';
        testCase1.AccountId = acc.Id;
        testCase1.Contract__c= ofContractRecId;
        testCase1.OnboardingCaseRequired__c=FALSE;
        testCase1.RecordTypeId = implementationRecordTypeId;
        insert testCase1;

        Test.startTest();
        //Adding related Lists
        CaseOpportunities__c caseOpportunity = new CaseOpportunities__c(Case__c = testCase1.Id, Opportunity__c = testOpportunity.Id);
        CaseContracts__c caseContract = new CaseContracts__c(Case__c = testCase1.Id, Contract__c = ofContractRecId);
        insert caseOpportunity;
        insert caseContract;
        List<CaseProducts__c>  caseProductLists= new List<CaseProducts__c>();
        caseProductLists.add(new CaseProducts__c(Case__c = testCase1.Id, productGroup__c = productGroups.get(0).Id));
        caseProductLists.add(new CaseProducts__c(Case__c = testCase1.Id, productGroup__c = productGroups.get(1).Id));
        caseProductLists.add(new CaseProducts__c(Case__c = testCase1.Id, productGroup__c = productGroups.get(2).Id));
        insert caseProductLists;
        
        System.debug('Case created : '+testCase1);
        System.debug('Create Child case and related list: ');
        testCase1.OnboardingCaseRequired__c = True;
        update testCase1;

        Case childCase = [select id, recordTypeId, (Select Contract__c from CaseContracts__r),
                          (Select Product__C, ProductFamily__c, productGroup__c from CaseProducts__r),
                          (Select Opportunity__c from CaseOpportunities__r) from case where ParentId =: testCase1.id];
        System.assertEquals(onBoardingRecordTypeId, childCase.recordTypeId,'recordtypeId is not matching');
        System.assertEquals(1, childCase.CaseContracts__r.size(),'Casecontract size is not matching');
        System.assertEquals(1, childCase.CaseOpportunities__r.size(),'caseopportunity size is not matching');
        System.assertEquals(3, childCase.CaseProducts__r.size(),'caseproduct size is not matching');
        Test.stopTest();
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 24 August 2018
    // @param: NA
    // @description: SFDC1-8534: To test that CreateTimeTrackingEventForCase
    //-----------------------------    
    @isTest
    private static void testCreateTimeTrackingEventForCase() {
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');

        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        
        Test.startTest();
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.ProductGroup__c = pg.Id;
        testCase1.RecordTypeId = CCId;
        insert testCase1;
        
        Event eve = new Event(WhatId = testCase1.Id, Type = 'Proposal Delivery meeting',
                              StartDateTime = System.now()+(1/24/60), DurationInMinutes=10);
		insert eve;
        
        testCase1.TimeSpentMinutes__c = 30;
        update testCase1;
        List<Event> events = [select id, TimeSpentMinutes__c, WhatId, type from Event where WhatId = :testCase1.Id];
        System.assertEquals(events.size(), 2,'event list size not matching');
        eve = [select id, TimeSpentMinutes__c, WhatId from Event where WhatId = :testCase1.Id and type ='BAU'];
        System.assertNotEquals(null, eve,'Results dont match');
        System.assertEquals(eve.TimeSpentMinutes__c, testCase1.TimeSpentMinutes__c,'Time spent does not match');
        
        testCase1.TimeSpentMinutes__c = 50;
        update testCase1;
        eve = [select id, TimeSpentMinutes__c, WhatId from Event where WhatId = :testCase1.Id and type ='BAU'];
        System.assertNotEquals(null, eve,'Results dont match 2');
        System.assertEquals(eve.TimeSpentMinutes__c, testCase1.TimeSpentMinutes__c,'Time spent does not match 2');
        Test.stopTest();
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 06 Sep 2018
    // @param: None
    // @description: SFDC1-9035 OM/Delivery Help Desk 'OMD Status' to 'Status' field mapping
    //------------------------------
	@isTest
    private static void testSetCaseStatusFromOMDStatusForOMDCaseType() {
        Test.startTest();
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, 'statustest@ihsmarkit.com', true, 'Test', 'Contact');
        String recordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Order Management/Delivery Help Desk');
        System.debug('recordTypeId=' + recordTypeId);
        System.assert(recordTypeId != null,'result does not match');
        
        Case c = new Case(RecordTypeId = recordTypeId,
                               AccountId = ihsMarkitAccount.Id, 
                               TeamSelect__c = 'Delivery',
                               DeliveryTeam__c = 'CD Distribution',
                               OMDStatus__c = 'Waiting on Information - 3rd Party',
                               Description = 'Please update status'
                              );
        insert c;
        Case c1 = [Select status from case where Id =: c.Id];
        system.assertEquals('Waiting - 3rd Party', c1.Status,'Case status does not match');
        Test.stopTest();
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 14 Sep 2018
    // @param: None
    // @description: SFDC1-9962 Converting PB checkInternalUserforCaseSurvey to trigger. 
    //------------------------------
    @isTest
    public static void testCheckInternalUserforCaseSurvey() {
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        User myTestUser = TestUtility.createAdminUser('test@ihsmarkit.com', true);
        
        Test.startTest();
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.RecordTypeId = CCId;
        testCase1.contactValidation__c = true;
        testCase1.OwnerId = myTestUser.Id;
        testCase1.DoNotSurveyReason__c = 'Should be removed';
        testCase1.DoNotSurvey__c = true;
        insert testCase1;
        
        Case c1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, contactValidation__c from case where Id =: testCase1.Id];
        system.assertEquals(Null, c1.DoNotSurveyReason__c,'Do not surveyreason isnt null');
        system.assertEquals(false, c1.DoNotSurvey__c,'Dont not survey isnt false');
        system.assertEquals(false, c1.contactValidation__c,'Contact Validation isnt false');
        
        c.Email = '1test.2test@ihsmarkit.com';
        update c;
        
        testCase1.contactValidation__c = true;
        Update testCase1;
        
        c1 = [Select DoNotSurveyReason__c, DoNotSurvey__c from case where Id =: testCase1.Id];
        system.assertEquals('Internal Contact', c1.DoNotSurveyReason__c,'Do not surveyreason is different');
        system.assertEquals(true, c1.DoNotSurvey__c,'Do not survey isnt true');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 19 Sep 2018
    // @param: None
    // @description: SFDC1-9960 Converting PB related to Duplicate and Delete Case Case Owner Change and, 
    //          Update Case Moved From Delete or Duplicate Status. To avoid governor limts doing delete part in this story. 
    //------------------------------
    @isTest
    public static void testDeleteRelatedPBCode() {
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        User myTestUser = TestUtility.createAdminUser('test@ihsmarkit.com', true);

        Case testCase1 = new Case();
        testCase1.subject = 'Test subject testSetDelete';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.RecordTypeId = CCId;
        testCase1.Status = 'Delete';
        testCase1.ResolutionDescription__c = 'Delete Case';
        testCase1.OwnerId = myTestUser.Id;
        testCase1.DoNotSurveyReason__c = 'Delete Case';
        testCase1.DoNotSurvey__c = true;
        System.runAs(myTestUser) {
            Test.startTest();
            //When case is marked for deletion from quick action, then update the case owner to delete queue.
            insert testCase1;
            
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status from case where Id =: testCase1.Id];
            system.assertEquals(System.Label.DeleteQueueID, testCase1.OwnerId,'ownerId does not match');
            //When a deleted case, status is changed then we change the owner and other fields.
            testCase1.Status = 'New';
            update testCase1;
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status from case where Id =: testCase1.Id];
            system.assertEquals(myTestUser.Id, testCase1.OwnerId,'ownerId does not match2');
            system.assertEquals('In Progress', testCase1.Status,'status does not match');
            system.assertEquals(false, testCase1.DoNotSurvey__c,'Do Not Survey does not match');
            system.assert(String.isBlank(testCase1.ResolutionDescription__c),'Resolution does not match');
            system.assert(String.isBlank(testCase1.DoNotSurveyReason__c),'Do not survey reason does not match');
            
            //When case owner is set to delete queue, then few fields should be modified.
            testCase1.OwnerId = System.Label.DeleteQueueID;
            update testCase1;
            
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status, SkillLevel__c from case where Id =: testCase1.Id];
            system.assertEquals('Delete', testCase1.Status,'case status does not match');
            system.assertEquals(true, testCase1.DoNotSurvey__c,'Do not survey does not match');
            system.assertEquals('Deleted Case', testCase1.ResolutionDescription__c,'Resolution Description does not match');
            system.assertEquals('Deleted Case', testCase1.DoNotSurveyReason__c,'Do no survey reason does not match');
            system.assertEquals('1 - General', testCase1.SkillLevel__c,'skill level does not match');
            
            //When case owner is changed from delete queue, then few fields should be modified.
            testCase1.OwnerId = myTestUser.id;
            update testCase1;
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status from case where Id =: testCase1.Id];
            system.assertEquals('In Progress', testCase1.Status,'Case status is not in progress');
            system.assertEquals(false, testCase1.DoNotSurvey__c,'Do not survey does not match 2');
            system.assert(String.isBlank(testCase1.ResolutionDescription__c),'Resolution Description does not match2');
            system.assert(String.isBlank(testCase1.DoNotSurveyReason__c),'Do no survey reason does not match2');
            Test.stopTest();
        }
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 19 Sep 2018
    // @param: None
    // @description: SFDC1-9960 Converting PB related to Duplicate and Delete Case Case Owner Change and, 
    //          Update Case Moved From Delete or Duplicate Status.
    //          To avoid governor limts doing Duplicate part in this story. 
    //------------------------------
    @isTest
    public static void testDuplicateRelatedPBCode() {
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@3test.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        User myTestUser = TestUtility.createAdminUser('test@ihsmarkit.com', true);

        Case testCase = new Case();
        testCase.subject = 'Parent Case';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.RecordTypeId = CCId;
        testCase.Status = 'New';
        insert testCase;
        
        Case testCase1 = new Case();
        testCase1.ParentId=testCase.Id;
        testCase1.subject = 'Test subject testSetDuplicate';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.RecordTypeId = CCId;
        testCase1.Status = 'Duplicate';
        testCase1.ResolutionDescription__c = 'Duplicate Case';
        testCase1.OwnerId = myTestUser.Id;
        testCase1.DoNotSurveyReason__c = 'Duplicate Case';
        testCase1.DoNotSurvey__c = true;
        System.runAs(myTestUser) {
            Test.startTest();
            //When case is marked for Duplicate from quick action, then update the case owner to Duplicate queue.
            insert testCase1;
            
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status from case where Id =: testCase1.Id];
            system.assertEquals(System.Label.DuplicateQueueID, testCase1.OwnerId,'ownerId does not match');
            //When a Duplicate case, status is changed then we change the owner and other fields.
            testCase1.Status = 'New';
            update testCase1;
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status from case where Id =: testCase1.Id];
            system.assertEquals(myTestUser.Id, testCase1.OwnerId,'ownerId does not match2');
            system.assertEquals('In Progress', testCase1.Status,'status does not match');
            system.assertEquals(false, testCase1.DoNotSurvey__c,'Do not survey does not match');
            system.assert(String.isBlank(testCase1.ResolutionDescription__c),'Resolution description does not match');
            system.assert(String.isBlank(testCase1.DoNotSurveyReason__c),'Do not survey reason does not match');
            
            //When case owner is set to Duplicate queue, then few fields should be modified.
            testCase1.OwnerId = System.Label.DuplicateQueueID;
            update testCase1;
            
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status, SkillLevel__c from case where Id =: testCase1.Id];
            system.assertEquals('Duplicate', testCase1.Status,'case status does not match');
            system.assertEquals(true, testCase1.DoNotSurvey__c,'case does not match');
            system.assertEquals('Duplicate Case', testCase1.ResolutionDescription__c,'Resolution description2 does not match2');
            system.assertEquals('Duplicate Case', testCase1.DoNotSurveyReason__c,'Do not survey reason does not match2');
            system.assertEquals('1 - General', testCase1.SkillLevel__c,'skill level does not match');
            
            //When case owner is changed from Duplicate queue, then few fields should be modified.
            testCase1.OwnerId = myTestUser.id;
            update testCase1;
            testCase1 = [Select DoNotSurveyReason__c, DoNotSurvey__c, OwnerId, ResolutionDescription__c, Status from case where Id =: testCase1.Id];
            system.assertEquals('In Progress', testCase1.Status,'case status does not match2');
            system.assertEquals(false, testCase1.DoNotSurvey__c,'Do not survey3 does not match3');
            system.assert(String.isBlank(testCase1.ResolutionDescription__c),'Resolution description3 does not match3');
            system.assert(String.isBlank(testCase1.DoNotSurveyReason__c),'Do not survey reason does not match3');
            Test.stopTest();
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 19 Sep 2018
    // @param: NA
    // @description: SFDC1-9959: To test UpdateParentCaseStatusWhenOMDCaseResolved
    //-----------------------------
	@isTest
    private static void testUpdateParentCaseStatusWhenOMDCaseResolved() {
        Test.startTest();
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, 'statustest@ihsmarkit.com', true, 'Test', 'Contact');
        String ccrecordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Customer Care');
        String omdrecordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Order Management/Delivery Help Desk');
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        Case parentCase = new Case(RecordTypeId = ccrecordTypeId,
                                   AccountId = ihsMarkitAccount.Id,
                                   ContactId = myTestContact.Id,
                                   Type = 'Product Assistance',
                                   Subtype__c = 'Software Upgrade/Install',
                                   Subject = 'Parent cc case',
                                   Description = 'Parent cc case',
                                   ProductGroup__c = pg.Id,
                                   status = 'New');
        insert parentCase;
        Case childCse = new Case(RecordTypeId = omdrecordTypeId,
                               AccountId = ihsMarkitAccount.Id, 
                               TeamSelect__c = 'Delivery',
                               DeliveryTeam__c = 'CD Distribution',
                               Description = 'Please update status',
                               ParentId = parentCase.Id
                              );
        insert childCse;
        
        childCse.LoadingGroupName__c = 'CD Distribution';
        childCse.DeliveryRootCause__c = 'Bulk Change / Update';
        childCse.DeliveryCaseComments__c = 'Test';
        childCse.RootCauseCategory__c = 'Internal inquiry';
        childCse.OMDStatus__c = 'Resolved';
        update childCse;
        
        Case cse = [Select Id,status From Case Where Id =: parentCase.Id];
        System.assertEquals('In Progress', cse.Status,'Case Status does not match');
        Test.stopTest();
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 19 Sep 2018
    // @param: NA
    // @description: SFDC1-9959: To test UpdateParentCaseACFLookupIDForTheChildCase
    //----------------------------- 
	@isTest
    private static void testUpdateParentCaseACFLookupIDForTheChildCase() {
        Test.startTest();
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, 'statustest@ihsmarkit.com', true, 'Test', 'Contact');
        String ccrecordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Customer Care');
        String omdrecordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Order Management/Delivery Help Desk');
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingNRG.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingNRG.AdditionalCaseRecordType__c = 'NRG';
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRG;
        
        Case parentCase = new Case(RecordTypeId = ccrecordTypeId,
                                   AccountId = ihsMarkitAccount.Id,
                                   ContactId = myTestContact.Id,
                                   Type = 'Product Assistance',
                                   Subtype__c = 'Software Upgrade/Install',
                                   Subject = 'Parent cc case',
                                   Description = 'Parent cc case',
                                   ProductGroup__c = pg.Id);
        insert parentCase;
        Case childCse = new Case(RecordTypeId = omdrecordTypeId,
                               AccountId = ihsMarkitAccount.Id, 
                               TeamSelect__c = 'Delivery',
                               DeliveryTeam__c = 'CD Distribution',
                               OMDStatus__c = 'Waiting on Information - 3rd Party',
                               Description = 'Please update status',
                               ParentId = parentCase.Id
                              );
        insert childCse;
        AdditionalCaseFields__c acf = [Select ChildCase__c from AdditionalCaseFields__c where Case__c =: parentCase.Id];
        System.assertEquals(childCse.Id, acf.ChildCase__c,'Child case does not match');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Sruti Srivastava
    // @date: 3 Oct 2018
    // @param: NA
    // @description: Test method to test populateSAPProcessedContractNumOnOpportunityAndContract 
    //-----------------------------
	@isTest
    private static void testPopulateSAPProcessedContractNumOnOpportunityAndContract() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'1test.2test@ihsmarkit.com' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        Opportunity testOpportunity = TestUtility.createOpportunity(a.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;
        Id orderFormContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id ofContractRecId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormContractRecordTypeId, testOpportunity.Id);

        // creating case
        List<Case> caseList = new List<Case>();
        Id orderManagementRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
                
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject afterAllCaseClosedOnContract 1';
        testCase1.AccountId = a.Id;
        testCase1.contactId = c.Id;
        testCase1.Contract__c= ofContractRecId;
        testCase1.Opportunity__c = testOpportunity.Id; 
        testCase1.RecordTypeId = orderManagementRecordTypeId;
        testCase1.SAPProcessedContractNumber__c = '8982test7373';
        insert testCase1;
        
        Test.startTest();
        
        Contract ctrct= [Select id, ProcessedContracttext__c from contract where ID =: ofContractRecId];
        System.assertEquals('8982test7373',ctrct.ProcessedContracttext__c,'contracttext does not match 1');
        Opportunity oppty = [Select id, ProcessedContractNum__c, StageName from Opportunity where ID =: testOpportunity.Id];
        System.assertEquals('8982test7373',oppty.ProcessedContractNum__c,'contracttext does not match 2');
        
        oppty.StageName = '6L-Closed Lost';
        oppty.LossReason__c = 'Price';
        oppty.LostReasonCode__c='Unfavorable Pricing';
        oppty.LostReasonDescription__c='Unfavorable Pricing';
        update oppty;

        testCase1.SAPProcessedContractNumber__c = 'Not Updated';
        update testCase1;
        //Check that Processed Contract Text is not propogated when Opprtunity is in 6L status.
        ctrct= [Select id, ProcessedContracttext__c from contract where ID =: ofContractRecId];
        System.assertEquals('8982test7373',ctrct.ProcessedContracttext__c,'contracttext does not match 3');
        oppty = [Select id, ProcessedContractNum__c from Opportunity where ID =: testOpportunity.Id];
        System.assertEquals('8982test7373',oppty.ProcessedContractNum__c,'contracttext does not match 4');
        
        Test.stopTest();
    }
	//-----------------------------
    // @author: Jagadesh Kumar
    // @date: 08 Oct 2018
    // @param: None
    // @description: SFDC1-10048 When the OM user sets the status to Validated - the Opportunity needs to be set to 6WP.
    // 				only for cases where Auto Renewal = Yes and Does this Opportunity have changes? = No and the case type is Order Management.
    // @modified by: Paras Dhingra
    // @modified date: 02nd April 2020
    // @modified reason: SFDC-2396 Increasing the scope of OM case validation. OM case is the only touch point to set an Opportunity to 6WP
    //                  Renaming the method name to suit the new objective
    //------------------------------
	@isTest
    private static void testUpdateOppTo6WPClosedWonWhenOMCaseValidated() {
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount ;
        
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', true);
        
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = testContact.Id;
        ocr.OpportunityId = testOpportunity.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Contract testContract = TestUtility.createContractWithInsertOptional(testAccount.id, legalEntity.id,
                                                                        country.id,standardId,false);
        testContract.RecordTypeId = orderFormRecordTypeId;
        testContract.AccountId = testAccount.id;
        testContract.AutoRenewal__c = true;
        testContract.Opportunity__c = testOpportunity.Id;
        testContract.Fastrack__c = true;
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.PriceIncreaseClause__c ='No Increase Allowed';
        testContract.CurrencyIsoCode = 'USD';
        testContract.StartDate = System.today();
        testContract.Pricebook2Id = standardId;
        testContract.ContractTerm = 10;
        testContract.Status = 'Creation';
        testContract.OrderReason__c = 'New';
       
        
        insert testContract;
        TestUtility.createContractAttachment(testContract.id);
        
        testOpportunity.StageName = '6W-Closed Won';
        testOpportunity.ContractId = testContract.id;
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.ContractEndDate__c = System.today() + 30;
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.ReadyForProcessingContractExist__c = true;
        GlobalVariables.preventRecursiveExecution = true;  
        
        update testOpportunity;
        
        testContract.RenewalDate__c = System.today() + 30; // SFDC-1397 RenewalDate__c is required if RenewalTerm__c != 'One-time Expiring'
        testContract.BillingFrequency__c = 'Monthly'; // SFDC-1397 BillingFrequency__c is required if RenewalTerm__c != 'One-time Expiring'
        testContract.UsageReportsRequired__c = 'No'; // SFDC-1397 UsageReportsRequired__c is required if RenewalTerm__c != 'One-time Expiring'
        testContract.ContractStatus__c = 'Validated';
        Test.startTest();
        update testContract;
        
        
        Id renewRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Renewal Opp';
        opp1.StageName= '3-Renewal Pending';
        opp1.RecordTypeId = renewRecordTypeId;
        opp1.CloseDate = System.today()+2;
        opp1.AutoRenewal__c = true;
        opp1.SourceSystem__c = 'Manually Generated';
        opp1.DoesThisAutoRenewalHaveChanges__c = false;
        opp1.Amount = 100;
        opp1.AccountId = testAccount.id;
        opp1.ContractBeingRenewed__c = testContract.id;
        opp1.ActivityCreated__c = true;
        insert opp1;
        
        Contact testContact1 = TestUtility.createContact(testAccount.Id, 'testihsmarkit2@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = testContact1.Id;
        ocr1.OpportunityId = opp1.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.Role = 'Decision Maker';
        insert ocr1;  
        
        opp1.stagename = '6W-Renewal Won';
        update opp1;
        
        Case cse = [Select Id,status,Opportunity__r.Name from Case Where Opportunity__c =: opp1.Id];
        cse.Status = 'Validated';
        cse.SAPProcessedContractNumber__c = '123456';
        update cse;
        
        Opportunity op = [Select StageName from Opportunity Where Id =: opp1.Id];
        System.assertEquals('6WP-Closed Won/Order Processed', op.StageName,'Oppy stage does not match');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 22 Jun 2020
    // @param: None
    // @description: SFDC-1652 Test Method for CaseMethods.populateUserAsOwnerOnCaseClosure() method
    //------------------------------
	@isTest
    static void TestPopulateUserAsOwnerOnCaseClosure() {
        //create test data
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Account testAccount = TestUtility.createTestAccount('test account', true);
        Contact testContact = TestUtility.createContact(testAccount.Id,'testihsmarkit2@testihsmarkit.com', true,'Barry', 'Allen');
        //Add record type names in custom setting
        IncludeCaseAutoCloseReassignment__c ccRecTypeName = new IncludeCaseAutoCloseReassignment__c(Name='Customer Care');
        insert ccRecTypeName;
        
        Group testGroup;
        User testCustomerCareUser;
        UtilityClass.LoggedInUserProfileName = null;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            //Create a test queue
            testGroup = TestUtility.createQueue('Test CC Queue','Case',true);
            
            //Create test user - must be Non Sys Admin and non Api profile user
            testCustomerCareUser = TestUtility.createTestUser('IHSMarkit Customer Care', 'testsfdc1652@username.com',true);
            //Add user to test queue
            GroupMember member = TestUtility.addQueueMember(testGroup.Id, testCustomerCareUser.Id, true);
        }
        
        Test.startTest();

        //create test customer case with wrong account contact combination
        Case testCase = TestUtility.createCase(customerCaseRecordTypeId, testAccount.Id,testContact.Id, 
                                               testGroup.Id, 'Test Subject', true);
        
        //Assert - Check if case is assigned to test queue
        Case testCaseAssert1 = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE Id=:testCase.Id];
        System.assertEquals(testGroup.Id, testCaseAssert1.OwnerId, 'Case should be owned by queue on creation.');
        UtilityClass.LoggedInUserProfileName = null;
        System.runAs(testCustomerCareUser) {
            //close the case and detect exception
            testCase.ResolutionDescription__c = 'test';
            testCase.ClosedReason__c = 'Query Answered';
            testCase.Status = 'Closed - Resolved by IHS Markit';
            update testCase;                         
        }
        //Assert case owner as test user
        Case testCaseAssert2 = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE Id=:testCase.Id];
        System.assertEquals(testCustomerCareUser.Id, testCaseAssert2.OwnerId, 'Case owner should be updated to user closing the case.');        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 07 Aug 2019
    // @param: None
    // @description: SFDC-175 test class for CaseMethods.preventAccountMisMatchOnCloseCase
    //------------------------------
	@isTest
    static void TestPreventAccountMisMatchOnCloseCase() {
        //create test data
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        InternalAccounts__c setting = new InternalAccounts__c(name='Internal Account');
        insert setting;
        Account testAccount = TestUtility.createTestAccount('test account', false);
        Account testAccount2 = TestUtility.createTestAccount('test account2', false);
        Account testAccount3 = TestUtility.createTestAccount('Internal Account', false);
        List<Account> lstTestAccounts = new List<Account> {testAccount,testAccount2,testAccount3};
        insert lstTestAccounts;
        Contact testContact = TestUtility.createContact(testAccount.Id,'testihsmarkit2@testihsmarkit.com', true,
                                        'Barry', 'Allen');
        Contact testContact1 = TestUtility.createContact(testAccount3.Id,'test@test.com', true,
                                        'Barry', 'Allen');
        //create test case with wrong account contact combination
        List<case> caseInsertList=new List<case>();
        Case testCase = TestUtility.createCase(customerCaseRecordTypeId, testAccount2.Id,testContact.Id, 
                                  UserInfo.getUserId(), 'Test Subject', false);
        Case testCase2 = TestUtility.createCase(customerCaseRecordTypeId, testAccount3.Id,testContact1.Id, 
                                  UserInfo.getUserId(), 'Test Subject2', false);
        caseInsertList.add(testCase);
        caseInsertList.add(testCase2);
        List<case> caseUpdateList=new List<case>();
        Test.startTest();
        //close the case and detect exception
        insert caseInsertList;
        testCase.ResolutionDescription__c = 'test';
        testCase.ClosedReason__c = 'Query Answered';
        testCase.Status = 'Closed - Resolved by IHS Markit';
        caseUpdateList.add(testcase);
        testCase2.ResolutionDescription__c = 'test';
        testCase2.ClosedReason__c = 'Query Answered';
        testCase2.Status = 'Closed - Resolved by IHS Markit';
        caseUpdateList.add(testcase2);
        try {
          update caseUpdateList;
        } catch(DmlException ex) {
            System.assertEquals(ex.getDmlMessage(0),'The contact is not associated with the account entered.  Please update with a related account.' );
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Sushma Yadav
    // @date: 18 Jun 2020
    // @description: SFDC-1363, test method Lead to Customer Care conversion             
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
    
    @isTest
    private static void testupdateLeadStatus() {
        
        // Setup test data 
		List<sObject> lstCountry = TestUtility.loadCountryData();
		Country__c country = (Country__c)lstCountry.get(0);
        
		Test.startTest();
		
		Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                            '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                            'London', '', 'GB', true);

		String testEmail = 'test@ihsmarkit.com';
		User myTestUser = TestUtility.createAdminUser(testEmail, true);
		System.runAs(myTestUser) {
				
		Contact testContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
					
		Lead testLead = new Lead();
		testLead = TestUtility.createLead('Test', 'LeadToCustomerCareCase', 'Testing LeadToCase Inc.', country.CountryCode__c, false);
		testLead.Email  = 'Test@LeadToCase.com';
		testLead.Description ='Unit Test for LeadToCaseConversion';
		testLead.Account__c = ihsMarkitAccount.id;
		
		insert testLead;

		Id caseRecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();

		Case testCase = TestUtility.createCase(caseRecordTypeId, ihsMarkitAccount.Id, testContact.Id,
                                                   UserInfo.getUserId(), 'Test UpdateLeadStatus', false);
		//testCase.status = 'New';
		testCase.subject = 'Test';
		testCase.Description = 'Test Lead to Customer Care case';
		
		QuickAction.QuickActionRequest req = new QuickAction.QuickActionRequest();
		req.quickActionName = Schema.Lead.QuickAction.NewCase;
		req.record = testCase; // assign the Customer Care case instantiated above to the QuickAction
		req.contextId = testLead.Id; // set the Lead ID to set context for the QuickAction
		QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);

		testCase = [Select Id, LeadReference__c, LeadToCase__c, SourceLead__c from Case where LeadReference__c =: testLead.Id Limit 1];
		System.assertEquals(testCase.LeadReference__c, testLead.Id,'Lead Ref does not match');
		System.assertEquals(testCase.SourceLead__c, testLead.Id,'Lead source does not match');    
		System.assertEquals(true, testCase.LeadToCase__c,'Lead to case does not match');    
		
		Lead testUpdatedLead = [SELECT Id, Status, DisqualifedReason__c FROM Lead WHERE Id=:testLead.Id LIMIT 1];	
		System.assertEquals('Disqualify', testUpdatedLead.Status,'Lead Status does not match');
		System.assertEquals('Passed to Customer Care', testUpdatedLead.DisqualifedReason__c,'Disq reason does not match');    
		}
        
		test.stopTest();
	
	}
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 8 Jul 2020
    // @param: None
    // @description: SFDC-2375, New test method for setInternalCaseAccountAndContact() method. Cover case record types - Sales Operation, Sales Support, Contract Management.  
    //-----------------------------
    @isTest
    private static void testSetInternalCaseAccountAndContact() {
        //Create Account
        Account testAcc = TestUtility.createTestAccount('Test Account SFDC2375', true);
        //Create Contact
        String testEmail = 'testsfdc2375@ihsmarkit.com';
        Contact testContact = TestUtility.createContact(testAcc.Id, testEmail, true, 'Test', 'Contact SFDC2375');        
        //Create Opportunity
        Opportunity testOpp = TestUtility.createOpportunity(testAcc.Id, 'Test Opp SFDC2375', true);
        //Create OCR
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = testContact.Id;
        ocr.OpportunityId = testOpp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        //Create Product, PricebookEntry, Opp Product, Legal Entity, Country
        Product2 testProd = TestUtility.createProduct('Test Product SFDC2375', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpp.Id, testPBE, true);
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('TestLegalEntity SFDC2375','USD');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        
        //Create contract
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();        
        Contract testContract = TestUtility.createContractWithInsertOptional(testAcc.id, legalEntity.id,country.id,standardId,false);
        testContract.RecordTypeId = orderFormRecordTypeId;
        testContract.AutoRenewal__c = true;
        testContract.Opportunity__c = testOpp.Id;
        testContract.Fastrack__c = true;
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.PriceIncreaseClause__c ='No Increase Allowed';
        testContract.CurrencyIsoCode = 'USD';
        testContract.StartDate = System.today();
        testContract.ContractTerm = 10;
        testContract.Status = 'Creation';
        testContract.OrderReason__c = 'New';        
        insert testContract;
        
        //Create user
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        
        Test.startTest();
        
        List<Id> assertCaseIdList = new List<Id>();
        //Run as test user - create cases (OMDHD, SO, SS, CM) with contactid=null
        System.runAs(myTestUser) {
            //Create SO case using global action
            Case testSOCaseGlobAction = TestUtility.globalActionCreateSalesOperationsCase(new Case(Type = 'Pricing', Subject = 'Test SO Case Global Action',Description = 'Test description for Test SO Case Global Action'));
            assertCaseIdList.add(testSOCaseGlobAction.Id);
            //Create SS case using Opportunity quick action
            Case testSSCaseQuickActionOpp = TestUtility.quickActionOppCreateSalesSupportCase(new Case(Type='Invoice',Subject = 'Test SS Case Quick Action Opp', Description = 'Test description for Test SS Case Quick Action Opp'),testOpp);
            assertCaseIdList.add(testSSCaseQuickActionOpp.Id);
            //Create CM case like quick action with contract id filled
            Case testCMCaseQuickActionCtrct = TestUtility.quickActionCtrctCreateCMCase(new Case(Subject='Test CM Case Quick Action Contract',Description='Test description for Test CM Case Quick Action Contract'),testContract);
            assertCaseIdList.add(testCMCaseQuickActionCtrct.Id);
            //OMDHD case
            Case testOMDHDCase = new Case(RecordTypeId = UtilityClass.caseRecordTypeOMDHelpDesk, Contract__c = testContract.Id,DeliveryTeam__c = 'CD Distribution',
                                  Subject = 'Case OM/Delivery Helpdesk Record',
                                  Description = 'Case Impl Record');
            insert testOMDHDCase;
            assertCaseIdList.add(testOMDHDCase.Id);
        }
        //Assert if requestor contact, account is populated
        for(Case assertCase :[SELECT Id,RecordTypeId,ContactId,AccountId,AccountName__c FROM Case WHERE Id IN :assertCaseIdList]) {            
            System.assertEquals(testContact.Id, assertCase.ContactId, 'Requestor contact on case should be set to logged-in user contact.');
            System.assertEquals(testAcc.Id, assertCase.AccountId, 'Requestor account on case should be set to logged-in user contact account.');
            if(assertCase.RecordTypeId==UtilityClass.caseRecordTypeOMDHelpDesk || assertCase.RecordTypeId==UtilityClass.caseRecordTypeContractManagement) {
                System.assertEquals(System.Label.NewUserContactAccount, assertCase.AccountName__c, 'Requested Account Name field should be set to System.Label.NewUserContactAccount on OMDHD case and CM case.');
            }
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Sushma Yadav
    // @date: 22 Jul 2020
    // @description: SFDC-3004, test method update OMDH Case             
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
    /**
     * As Stephen wants Email2case functionality to be enabled later so commenting the code for now.
    @isTest
    private static void testUpdateOMDHEmail2Case() {
        Test.StartTest();
        Account a = TestUtility.createTestAccount('Account CheckEnhancedSalesPermission', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;

		Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testUpdateOMDHCase';
        c.AccountId = a.Id;
        String testEmail = 'sytest@test.com';
        c.EmailUnknown__c = TRUE;
        c.Phone = '1234567890';
        insert c;
		
		Profile sysAdminProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%System Admin%' LIMIT 1];

        User sysAdminUser = new User(FirstName='System', LastName='Admin', Email='sysAdmin@ihsmarkit.com', Alias = 'SysAdm',
                                         ProfileId = sysAdminProfile.Id, HRManager__c='manager', EmailEncodingKey ='UTF-8', 
                                         LocaleSidKey = 'en_US', LanguageLocaleKey='en_US', TimeZoneSidKey = 'America/Los_Angeles',
                                         UserName = 'sysAdmin@ihsmarkit.com', ADID__c = 'test'+system.now().millisecond(),
                                         EmployeeNumber = String.valueOf(Math.round(Math.random()*10000)),
                                         EmployeeNumber__c = String.valueOf(Math.round(Math.random()*10000)));
        insert sysAdminUser;
		
		String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName = 'CSOrderManagement' Limit 1].Id;
		
		System.runAs(sysAdminUser) {

		Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId();
            Case cas = new Case(Subject = 'Case OM/Delivery Helpdesk Record',
                                        RecordTypeId = recTypeId,
                                        AccountId = a.Id,                                        
                                        Description = 'Case OMDH Record',
                                        TeamSelect__c = 'Order Management',
										Origin = 'Email',
										OwnerId = queueId
                                        );
            insert cas;

			Case ca = [select OrderManagementRegion__c from case where id =: cas.id];
			system.assert(ca.OrderManagementRegion__c  == 'Markit');


		}
		Test.stopTest();
	}*/
    
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 10 Oct 2020
    // @param: NA
    // @description: SFDC-3366: Test method for Case trigger methods deleteMergedCaseRelatedACF after update
    // @return: NA
    //-----------------------------
    @isTest
    private static void testDeleteMergedCaseRelatedACF() {
        
        Id CCRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'Counterparty Manager-Core';
        insert pg;
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingRnC = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingRnC.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingRnC.AdditionalCaseRecordType__c = 'Reg and Compliance';
        aCaseTypeLinkingRnC.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingRnC;
        
        Case testCase = new Case();
        testCase.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.ProductGroup__c = pg.Id;
        testCase.RecordTypeId = CCRecordTypeId;
        testCase.Status = 'New';
        insert testCase;
        
        list <AdditionalCaseFields__c> additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        System.assertEquals(1, additionalCaseFieldsList.size(),'ACF list size does not match');
        
        Test.startTest();
        
        testCase.Status = 'Merged';
        update testCase;
        
        additionalCaseFieldsList = [Select Id from AdditionalCaseFields__c where Case__c = :testCase.Id];
        System.assertEquals(0, additionalCaseFieldsList.size(),'Case list size does not match');
        
        Test.stopTest();
    }
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 01 Apr 2021
    // @param: NA
    // @description: SFDC-3889: Test method for JTL case record type
    // @return: NA
    //-----------------------------
    @isTest
    private static void testUpdateRecordTypeToJTL() {
        Account a = TestUtility.createTestAccount('Account testUpdateRecordTypeToJTL', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testUpdateRecordTypeToJTL';
        c.AccountId = a.Id;
        
        Test.startTest();
        Case testCase = new Case();
        testCase.subject = 'Test subject testUpdateRecordTypeToJTL';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        testCase.SuppliedEmail = 'igl_comms@ihsmarkit.com';
        insert testCase;
        
        list <Case> testCaseResult = [Select SuppliedEmail, Id from case where Id = :testCase.Id];
        System.assertEquals('igl_comms@ihsmarkit.com', testCaseResult[0].SuppliedEmail,'Email id does not match');
        
        Test.stopTest();
    }


    //-----------------------------
    // @author: Digvijay Singh
    // @date: 12 April 2020
    // @param: NA
    // @description: SFDC-3268.Test method for Case trigger methods assignOMDeliverHelpDeskCasetoCSQueue on before insert
    // @return: NA
    //-----------------------------
	@isTest
    private static void testassignOMDeliverHelpDeskCasetoCSQueue() {
		Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);
        Contact objContact = TestUtility.createContact(ihsMarkitAccount.Id, 'statustest@ihsmarkit.com', true, 'Test', 'Contact');
        String omdrecordTypeId = UtilityClass.getObjectRecordTypeId('Case', 'Order Management/Delivery Help Desk');
		
		Test.StartTest();
		Case omdcase = new Case(RecordTypeId = omdrecordTypeId,
                               AccountId = ihsMarkitAccount.Id, 
                               TeamSelect__c = 'Delivery',
                               DeliveryTeam__c = 'CD Distribution',
                               Description = 'Please update status',
							   ContactId = objContact.Id
                              );
        insert omdcase;
        omdcase=[Select Id, OwnerId from Case where Id=:omdcase.Id];
		String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName =: System.Label.CSDeliveryQueue Limit 1].Id;
		System.assertEquals(queueId, omdcase.OwnerId,'queueownerId does not match');
		Test.StopTest();
		
	}
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 23 April 2020
    // @param: NA
    // @description: SFDC-3419 .Test method for methods updatePreviousOwnerName on before update
    // @return: NA
    //-----------------------------
	@isTest
   private static void testUpdatePreviousOwnerName() {

       Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);

       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
       insert u;
       
       Contact con = TestUtility.createContact(a.Id, 'statustest@ihsmarkit.com', true, 'Test', 'Contact');
             
       ProductGroup__c pg = new ProductGroup__c();
       pg.Name = 'NRG';
       insert pg;   
       
       test.startTest();
       Case testCase = new Case();
       testCase.subject = 'Test subject testSetCaseAdditionalFieldsObject';
       testCase.AccountId = a.Id;
       testCase.contactId = con.Id;
       testCase.ProductGroup__c = pg.Id;
       insert testCase;
       
       Case cse = [Select id, ownerid from Case where id = :testCase.Id];
       testCase.OwnerId = u.id;
       update testCase;
       test.stopTest();
       
       Case cse2 = [Select id, ownerid, PreviousOwnerName__c  from Case where id = :testCase.Id];
       System.assertEquals(cse.ownerid, cse2.PreviousOwnerName__c,'Case record was failed');     
   }
   
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 20 May 2021
    // @param: NA
    // @description: SFDC-4055 .Test method for method assignDefaultValuesToOMDeliverHelpDeskCases on before insert
    // @return: NA
    //-----------------------------
	@isTest
   private static void testAssignDefaultValuesToOMDeliverHelpDeskCases() {
    
       Account a = TestUtility.createTestAccount('Account testAssignDefaultValuesToOMDeliverHelpDeskCases', true);
       
       Contact con = TestUtility.createContact(a.Id, 'statustest@ihsmarkit.com', true, 'Test', 'Contact');
       String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName =: System.Label.GlobalDeliveryEMEAADAndMQueue Limit 1].Id;
       test.startTest();
       Case testCase = new Case();
       testCase.subject = 'Test subject testAssignDefaultValuesToOMDeliverHelpDeskCases';
       testCase.AccountId = a.Id;
       testCase.contactId = con.Id;
       testCase.OwnerID = queueId;
       testCase.RecordTypeId = UtilityClass.caseRecordTypeOMDHelpDesk;
       insert testCase;
       
       Case cse = [Select id, ownerid, TeamSelect__c, DeliveryTeam__c from Case where id = :testCase.Id];
       //String queueId = [select Id, Name, DeveloperName from Group where Type = 'Queue' and DeveloperName =: System.Label.GlobalDeliveryEMEAADAndMQueue Limit 1].Id;
       System.assertEquals(queueId,cse.ownerid,'ownerId does not match');
       System.assertEquals('Delivery',cse.TeamSelect__c,'Team select does not match');
       System.assertEquals('Global Delivery EMEA ADandM',cse.DeliveryTeam__c,'Delivery Team does not match');  
       test.stopTest();
        
   }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 20 August 2021
    // @param: NA
    // @description: SFDC-4228 Test method for method updateOppoStatusContract
    // @return: NA
    //-----------------------------
	@isTest
    private static void testUpdateOppoStatusContract() {
        Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        LegalEntity__c testLegalEntity = Testutility.createLegalEntity('IHS Markit Inc.','USD');
        Id standardPricebookId = Test.getStandardPricebookId();
        Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                            '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                            'London', '', 'GB', true);
        String testEmail = 'dabctest@ihsmarkit.com';
        Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        
        Contract testContract = Testutility.createContractWithInsertOptional(ihsMarkitAccount.Id, testLegalEntity.Id, null, standardPricebookId,false );
        testContract.recordTypeId =Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
        insert testContract;
        
        Opportunity testOpportunity = TestUtility.createRenewalOpportunity(ihsMarkitAccount.Id, testContract.Id, true,false,false,true);
        
        OpportunityContactRole ocr1 = new OpportunityContactRole();
        ocr1.ContactId = myTestContact.Id;
        ocr1.OpportunityId = testOpportunity.Id;
        ocr1.IsPrimary = TRUE;
        ocr1.Role = 'Decision Maker';
        insert ocr1;
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.ContractEndDate__c = System.today();
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.StageName= '6W-Renewal Won';
        update testOpportunity;
        
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject Case status 1';
        testCase1.Contract__c= testContract.id;
        testCase1.RecordTypeId = OMRecordTypeId;
        testCase1.Opportunity__c = testOpportunity.id;
        testCase1.ContactId = myTestContact.id;
        testCase1.Status = 'New';
        testCase1.ReasonforRejection__c = 'Incorrect Data Entry';
        insert testCase1;
        Test.startTest();
        
        testCase1.Status = 'Rejected';
        testCase1.CaseRejectionPastDue__c = True;
        update testCase1;
        Opportunity oppStage = [Select stageName from Opportunity where id=:testOpportunity.id];
        system.assertEquals('5-Renewal Contracting', oppStage.StageName , 'Oppy re-opened check');
        Test.stopTest();        
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 5th November 2021
    // @param: NA
    // @description: SFDC-4614 .Test method for method Product group assignment for GGRS onboarding queue on creation
    // @return: NA
    //-----------------------------
	@isTest
   private static void productGroupAssignment() {
    
       Account a = TestUtility.createTestAccount('Account productGroupAssignment', true);
       
       Contact con = TestUtility.createContact(a.Id, 'productgrouptest@ihsmarkit.com', true, 'Test', 'Contact');
       test.startTest();
       Case testCase = new Case();
       testCase.subject = 'Test subject productGroupAssignment';
       testCase.AccountId = a.Id;
       testCase.contactId = con.Id;
       testCase.OwnerID = System.Label.GRRSOnboardingQueue;
       testCase.RecordTypeId = UtilityClass.caseRecordTypeCustomerCare;
       insert testCase;
       
       Case cse = [Select id, ownerid, ProductGroup__c from Case where id = :testCase.Id];
       System.assertEquals(System.label.GRRSProductGroup, cse.ProductGroup__c, 'Custom Label product group ID and value on case should match');
       test.stopTest();
   }
    
     //-----------------------------
    // @author: Ankush Vedi
    // @date: 15-March-2022
    // @param: NA
    // @description: SFDC-5530 .Test method for method creating Date Case Last Opened
    // @return: NA
    //-----------------------------
	@isTest
   private static void testCalculateCaseAgeBusinessDays() {
    
       Account acc = TestUtility.createTestAccount('Account caseUpdateGrrs', true);
       Contact con = TestUtility.createContact(acc.Id, 'caseUpdateGrrs@ihsmarkit.com', true, 'Test', 'Contact');
       Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
       Case testCase = TestUtility.createCase(UtilityClass.caseRecordTypeCustomerCare,acc.id,con.id, UserInfo.getUserId(),'Test subject', true);
       test.startTest();
       testcase.SkillLevel__c ='1 - General'; 
       testcase.ResolutionDescription__c = 'test';
       testcase.recordtypeid = OMRecordTypeId;
       testcase.TeamCollaboration__c = 'Buisness Continuity';
       testcase.StandardResponsesUsed__c = '0-10';
       testcase.TotalQuestions__c = '0-10';
       testCase.Status = 'Closed - Resolved by IHS Markit';
       testcase.ClosedReason__c ='Data Republished'; 

	   update testCase;    
       testCase.Status = 'New';
       testcase.ClosedReason__c = null; 
	   update testCase;    
       Case cse = [Select id, DateCaseLastOpened__c from Case where id = :testCase.Id];
       System.assertEquals(System.today(), cse.DateCaseLastOpened__c.Date(), 'Date time dont match');
       test.stopTest();
   } 
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 13th April 2022
    // @param: NA
    // @description: SFDC-5340 .Test method for moveToDeleteQueueExistingOMCases Casemethods 
    // @return: NA
    //-----------------------------
	@isTest
   private static void testMoveToDeleteQueueExistingOMCases() {
    
       Account acc = TestUtility.createTestAccount('Account', true);
       Contact con = TestUtility.createContact(acc.Id, 'caseUpdateGrrs@ihsmarkit.com', true, 'Test', 'Contact');
       Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
       Test.startTest();
       Case testCase1 = TestUtility.createCase(OMRecordTypeId, acc.id, con.id, UserInfo.getUserId(),'firstCase', true);
       Case testCase2 = TestUtility.createCase(OMRecordTypeId, acc.id, con.id, UserInfo.getUserId(),'secondCase', true);
       Test.stopTest();
      
       Case cse = [Select id, ownerid from Case where id = :testCase1.Id];
       System.assertEquals(System.label.DeleteQueueID, cse.ownerid, 'Case didnt moved to delete queue');
       
   } 
}