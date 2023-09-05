/**
 * @author Paras Dhingra adapted from Tran's code
 * @date 08th Aug 2017
 * @description SFDC1-1081 Test class for unit testing on Lead Methods
 * @companyname IHS Markit
 **/
@isTest 
public class TestLeadMethods {
	@isTest
    static void TestUpdateCountryLookup() {
        // Test data setup
        TestUtility.loadCountryData();
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'roger@test.ihsm.com';
        
        Test.startTest();
        insert testLead;

        //assert the lead
        Lead assertLead = [Select id, Country__r.CountryCode__c from Lead where id =: testLead.Id];
        System.assertEquals('IN', assertLead.Country__r.CountryCode__c,'Country Code mismatch');
        
        testLead.CountryCode = 'IT';
        update testLead;
        
        assertLead = [Select id, Country__r.CountryCode__c from Lead where id =: testLead.Id];
        System.assertEquals('IT', assertLead.Country__r.CountryCode__c,'Country Code mismatch');
        
        Test.stopTest();
    }
    @isTest
    static void testUpdateLeadDescriptionOnOpty() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testemail1@test.com',false,'TestFirstName','TestLastName');
        con.Phone = '123423';
        con.Fax = '321412321';
        
        insert con;
            
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
        
        
        TestUtility.loadCountryData();
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'roger@test.ihsm.com';
        testLead.Description ='test';
        testLead.BudgetRange__c = '< 25,000';
        insert testLead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.id);
        lc.setAccountId(acc.id);
        lc.setContactId(con.id);
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(true,lcr.isSuccess(),'Lead Conversion error');
        System.assertnotEquals(lcr.opportunityid,null,'Opportunity missing');
        System.assertEquals([select description from opportunity where id =: lcr.opportunityid ].description,testLead.Description,'Description missing');
        System.assertEquals([select CloseDateOriginal__c from opportunity where id =: lcr.opportunityid ].CloseDateOriginal__c,System.today() + 60,'CloseDateOriginal__c mismatch');
        System.assertEquals([select CloseDate from opportunity where id =: lcr.opportunityid ].CloseDate,System.today() + 60,'CloseDate Mismatch');
        System.assertEquals([select SourceSystem__c from opportunity where id =: lcr.opportunityid].SourceSystem__c,'Lead Generated');
        
       
        Test.stopTest();
    }
    
    //SFDC1-5436 - Move all Lead Process Builder to Trigger
	@isTest
    static void testupdatetoNewLeadSourcefieldPB() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testCloseSourceCaseOnLead', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testinglead@ihsmarkit.com',false,'TestFirstLeadName','TestLastLeadName');
        con.Phone = '123423';
        con.Fax = '321412321';
        
        insert con;
            
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test LeadOpppy', true);
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        String ProfileName = 'IHSMarkit Sales: General';
        Profile p = [SELECT Name FROM Profile WHERE Name LIKE '%General%'];
        
        User testSalesUser = new User(Alias = 'standt', Email='testSalesGeneral-999@ihsmarkit.com', 
                                  EmailEncodingKey='UTF-8', firstName='testFirstName', HRManager__c='testManager', LastName='testLastName',
                                  LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testSalesGeneral-999@ihsmarkit.com', ADID__c='test'+system.now().millisecond(),                               EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)) );
         
         insert testSalesUser;
        
        TestUtility.loadCountryData();
        Lead testLead;
        system.runAs(testSalesUser) {
            testLead = TestUtility.createLead('Roger', 'Smith', 'Testing Company', 'IN', false);
            testLead.CountryCode = 'IN';
            testLead.Email  = 'rogerleadtest@ihsmarkit.com';
            testLead.Description ='test';
            testLead.BudgetRange__c = '< 25,000';
            testLead.LeadSource = 'Rep Generated';
            insert testLead;
        }       
        system.assertEquals([select leadsource from lead where id=: testLead.id ].leadsource,'Rep Generated');
        test.stopTest();
     } 
    
    //SFDC1-5436 - Move all Lead Process Builder to Trigger
	@isTest
    static void testupdatetoNewLeadSourcefieldMarketPB() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testCloseSourceCaseOnLead', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testinglead@ihsmarkit.com',false,'TestFirstLeadName','TestLastLeadName');
        con.Phone = '123423';
        con.Fax = '321412321';
        
        insert con;
        
        Profile pMarket = [SELECT Id,Name FROM Profile WHERE Name LIKE '%Marketing%' limit 1];
        User testSalesUser = new User(Alias = 'standt', Email='testMarketing-999@ihsmarkit.com', 
                                  EmailEncodingKey='UTF-8', firstName='testFirstName', HRManager__c='testManager', LastName='testLastName',
                                  LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pMarket.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testMarketing-999@ihsmarkit.com', ADID__c='test'+system.now().millisecond(),                                  EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
         
         insert testSalesUser;
        
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test LeadOpppy', true);
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
                
        TestUtility.loadCountryData();
        Lead testLead;
        system.runAs(testSalesUser) {
            testLead = TestUtility.createLead('Roger', 'Smith', 'Testing Company', 'IN', false);
            testLead.CountryCode = 'IN';
            testLead.Email  = 'rogerleadtest@ihsmarkit.com';
            testLead.Description ='test';
            testLead.BudgetRange__c = '< 25,000';
            testLead.LeadSource = 'Marketing Generated';
            insert testLead;
        }       
        system.assertEquals([select leadsource from lead where id=: testLead.id ].leadsource,'Marketing Generated');
        test.stopTest();
     } 
    
    //SFDC1-5436 - Move all Lead Process Builder to Trigger
	@isTest
    static void testupdatetoNewLeadSourcefieldCCPB() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testCloseSourceCaseOnLead', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testinglead@ihsmarkit.com',false,'TestFirstLeadName','TestLastLeadName');
        con.Phone = '123423';
        con.Fax = '321412321';
        
        insert con;
            
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test LeadOpppy', true);
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        //User testSalesGeneralUser = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUser.SalesGeneral@ihsmarkit.com.user',true);
        //User testUser1 = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUSer.testuser123@ihsmarkit.com.user',true);
        String ProfileName = 'IHSMarkit Sales: General';
        Profile p = [SELECT Name FROM Profile WHERE Name LIKE '%Customer Care%' limit 1];
        
        User testSalesUser = new User(Alias = 'standt', Email='testCustomerCare-999@ihsmarkit.com', 
                                  EmailEncodingKey='UTF-8', firstName='testFirstName', HRManager__c='testManager', LastName='testLastName',
                                  LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testCustomerCare-999@ihsmarkit.com', ADID__c='test'+system.now().millisecond(),                                  EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
         
         insert testSalesUser;
        
        TestUtility.loadCountryData();
        Lead testLead;
        system.runAs(testSalesUser) {
            testLead = TestUtility.createLead('Roger', 'Smith', 'Testing Company', 'IN', false);
            testLead.CountryCode = 'IN';
            testLead.Email  = 'rogerleadtest@ihsmarkit.com';
            testLead.Description ='test';
            testLead.BudgetRange__c = '< 25,000';
            testLead.LeadSource = 'Customer Care';
            insert testLead;
        }       
        system.assertEquals([select leadsource from lead where id=: testLead.id ].leadsource,'Customer Care');
        test.stopTest();
     } 
    
     //SFDC1-8326 - On lead Conversion, associated campaign should created Campaign INfluence records with same count.
	 @isTest
     static void testCampaignInflCreationOnLeadConvert() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testemail1@test.com',false,'TestFirstName','TestLastName');
        con.Phone = '123423';
        con.Fax = '321412321';
        
        insert con;
            
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
        
         List<Campaign> insertCampaign = New List<Campaign>();
        
        TestUtility.loadCountryData();
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'roger@test.ihsm.com';
        testLead.Description ='test';
        testLead.BudgetRange__c = '< 25,000';
        insert testLead; 
         
         
        Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Campaign').getRecordTypeId();
        Campaign Camp1 = new Campaign(Name='Test 1',recordTypeId=campaignRecordTypeId);
        //camp1.
        insertCampaign.add(Camp1); 
        
        Campaign Camp2 = new Campaign(Name='Test 2',recordTypeId=campaignRecordTypeId);
        insertCampaign.add(Camp2); 
         
         insert insertCampaign;  
        
         List<CampaignMember> campMemberLst = new List<CampaignMember>();
         CampaignMember campMembr1 = new CampaignMember();
         campMembr1.CampaignId = insertCampaign[0].id;
         campMembr1.LeadId = testLead.id;
         campMembr1.Status = 'Sent';
         campMembr1.CurrencyIsoCode = 'USD';
         campMemberLst.add(campMembr1);
         CampaignMember campMembr2 = new CampaignMember();
         campMembr2.CampaignId = insertCampaign[1].id;
         campMembr2.LeadId = testLead.id;
         campMembr2.Status = 'Sent';
         campMembr2.CurrencyIsoCode = 'USD';
         campMemberLst.add(campMembr2);
         
         insert campMemberLst; 
         
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.id);
        lc.setAccountId(acc.id);
        lc.setContactId(con.id);
        //lc.setOpportunityId(testOpportunity.id);
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(true,lcr.isSuccess(),'Lead Conversion error');
        
     }    
     
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 12th Sep 2018
    // @description: SFDC1-8827 after a lead is created, check if the Lead was converted from a Customer Care case
    //                and if there is an Account Governance case generated from that Customer Care case 
    //                then update the Lead Reference on that Account Governance case with the Id of this Lead record
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
	@isTest
    static void testUpdateAccountGovernanceCaseLeadReference() {
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
            req.record = testLead; // assign the Lead instatiated above to the QuickAction
            req.contextId = testCase.Id; // set the Case ID to set context for the QuickAction
            QuickAction.QuickActionResult res = QuickAction.performQuickAction(req);
            
            testLead = [Select Id, Company, AccountRequested__c, LeadSource, SourceCase__c from Lead where Id =: testLead.Id Limit 1];
            System.debug('testLead: ' + testLead);
            
            // reload agCase from database
            Case agCase = [Select Id, CaseReference__c, LeadReference__c from Case where CaseReference__c =: testCase.Id Limit 1];
            
            System.debug('agCase: ' + agCase);
            // after the quick action was done, expect the Account Governance case's Lead reference field has the new Lead Id value
            System.assertEquals(testLead.Id, agCase.LeadReference__c,'New Lead ID missing');
        }

        test.stopTest();
     }
    @isTest
    static void testUseDefaultAssignmentRule() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account TestUseDefaultAssignmentRule', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id, 'TestingLead@ihsmarkit.com', false, 'TestFirstLeadName', 'TestLastLeadName');
        con.Phone = '281-234-5678';
        con.Fax = '713-456-7890';
        
        insert con;
            
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test LeadOpppy', true);
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        String ProfileName = 'IHSMarkit Sales: General';
        Profile p = [SELECT Name FROM Profile WHERE Name LIKE '%Customer Care%' limit 1];
        
        User testSalesUser = new User(Alias = 'standt', Email='testCustomerCare-999@ihsmarkit.com', 
                                  EmailEncodingKey='UTF-8', firstName='testFirstName', HRManager__c='testManager', LastName='testLastName',
                                  LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName='testCustomerCare-999@ihsmarkit.com', ADID__c='test'+system.now().millisecond(),                                  EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
         
        insert testSalesUser;
        
        TestUtility.loadCountryData();
        Lead testLead;
        system.runAs(testSalesUser) {
            testLead = TestUtility.createLead('Roger', 'Smith', 'Testing Company', 'IN', false);
            testLead.CountryCode = 'IN';
            testLead.Email  = 'rogerleadtest@ihsmarkit.com';
            testLead.Description ='test';
            testLead.BudgetRange__c = '< 25,000';
            testLead.LeadSource = 'Customer Care';
            insert testLead;
        }
        
        testLead = [select leadsource, OwnerId from lead where id=: testLead.id limit 1];
        system.assertNotEquals(testLead.OwnerId, testSalesUser.Id);
        test.stopTest();
     }
    
    //-----------------------------
    // @author: Sruti Srivastava
    // @date: 21 Sep 2018
    // @description: SFDC1-8820: Test method for testPopulateNamedAccountOnLead
    // @param: none
    // @return: void
    //-----------------------------
	@isTest
    static void testPopulateNamedAccountOnLead() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testCloseSourceCaseOnLead', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testingcontact1@test.com',false,'TestFirstLeadName','TestLastLeadName');
        con.Phone = '123423';
        con.Fax = '321412321';
        insert con;
        insert (new NamedAccountDomain__c(Domain__c = 'test.ihsmarkit.com', Region__c='APAC'));  
        Test.startTest();
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test LeadOpppy', true);
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        TestUtility.loadCountryData();
        Lead testLead;
        
        testLead = TestUtility.createLead('test', 'sruti', 'Testing Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'testleadtest1@test.ihsmarkit.com';
        testLead.Description ='test';
        testLead.BudgetRange__c = '< 25,000';
        testLead.LeadSource = 'Rep Generated';
        insert testLead;
        
        test.stopTest(); 
        Lead obj = [select NamedAccount__c, CalculatedRegion__c from lead where id=: testLead.id ];
        //Named account should be populated
        system.assert(obj.NamedAccount__c.containsIgnoreCase('Named Account'));
     }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 25 Jun 2021
    // @description: SFDC-4046: Test method for testLeadTime
    // @param: none
    // @return: void
    //-----------------------------
	@isTest
    static void testLeadTime() {
        // Test data setup
        User myTestUser = TestUtility.createAdminUser('opptyOwnertest@ihsmarkit.com', true);
        User myTestUser1 = TestUtility.createAdminUser('opptyOwnertest@ihsmarkit.com', true);
        List<String> SDRLeadQueue = Label.SDRLeadQueue.split(',');
        ID SDRLeadID = [Select Id From Group where Type = 'Queue' and Id in : SDRLeadQueue LIMIT 1].Id;
        
        TestUtility.loadCountryData();
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'roger@test.ihsm.com';
        testLead.Status = 'Prioritized';
        testLead.OwnerId = myTestUser.id;
        
        Test.startTest();
        insert testLead;
        
        //SDRAssignmentTime__c
        testLead.OwnerId = SDRLeadID;
        Update testLead;
        Lead ld = [select Id, SDRQueueassignment__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld.SDRQueueassignment__c, Null,'SDRQueueassignment__c not working');
        System.assertNotEquals(ld.SDRQueueassignment__c,'','SDRQueueassignment__c not working');
        
        //SDRTimetoPickup__c
        testLead.Status = 'Pre-SalesWorking';
        Update testLead;
        Lead ld1 = [select Id, PreSalesWorking__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld1.PreSalesWorking__c, Null,'PreSalesWorking__c not working');
        System.assertNotEquals(ld1.PreSalesWorking__c, '','PreSalesWorking__c not working');
        System.assertNotEquals(ld1.PreSalesWorking__c, '0','PreSalesWorking__c not working');
        
        //SDRQualificationTime__c        
        testLead.Status = 'Pre-SalesQualified';
        Update testLead;
        Lead ld2 = [select Id, PreSalesQualifiedDisqualified__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld2.PreSalesQualifiedDisqualified__c, Null,'PreSalesQualifiedDisqualified__c not working');
        System.assertNotEquals(ld2.PreSalesQualifiedDisqualified__c, '' ,'PreSalesQualifiedDisqualified__c not working');
        System.assertNotEquals(ld2.PreSalesQualifiedDisqualified__c, '0','PreSalesQualifiedDisqualified__c not working');
        
        //LMTAssignmentTime__c
        testLead.OwnerId = System.Label.LMTLeadQueue;
        Update testLead;
        testLead.OwnerId = myTestUser.id;
        Update testLead;
        Lead ld3 = [select Id, FirstSalesRepQueueAssignment__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld3.FirstSalesRepQueueAssignment__c, Null,'FirstSalesRepQueueAssignment__c not working');
        System.assertNotEquals(ld3.FirstSalesRepQueueAssignment__c, '','FirstSalesRepQueueAssignment__c not working');
        System.assertNotEquals(ld3.FirstSalesRepQueueAssignment__c, '0','FirstSalesRepQueueAssignment__c not working');
        
        //SalesAssignmentTime__c
        testLead.OwnerId = myTestUser1.id;
        Update testLead;
        Lead ld4 = [select Id, LastSalesRepQueueAssignment__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld4.LastSalesRepQueueAssignment__c, Null,'LastSalesRepQueueAssignment__c not working');
        System.assertNotEquals(ld4.LastSalesRepQueueAssignment__c, '','LastSalesRepQueueAssignment__c not working');
        System.assertNotEquals(ld4.LastSalesRepQueueAssignment__c, '0','LastSalesRepQueueAssignment__c not working');
        
        //SalesTimetoPickup__c
        testLead.Status = 'SalesWorking';
        Update testLead;
        Lead ld5 = [select Id, SalesWorking__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld5.SalesWorking__c, Null,'SalesWorking__c not working');
        System.assertNotEquals(ld5.SalesWorking__c, '','SalesWorking__c not working');
        System.assertNotEquals(ld5.SalesWorking__c, '0','SalesWorking__c not working');
        
        //SalesQualificationTime__c
        testLead.Status = 'Disqualify';
        testLead.DisqualifedReason__c = 'Already Purchased';
        Update testLead;
        Lead ld6 = [select Id, SalesConvertedDisqualified__c from lead where id=: testLead.id ];
        System.assertNotEquals(ld6.SalesConvertedDisqualified__c, Null,'SalesConvertedDisqualified__c not working');
        System.assertNotEquals(ld6.SalesConvertedDisqualified__c, '','SalesConvertedDisqualified__c not working');
        System.assertNotEquals(ld6.SalesConvertedDisqualified__c, '0','SalesConvertedDisqualified__c not working');
        
        Test.stopTest();
    }
      //-----------------------------
      // @author : Digvijay Singh
      // @date :  14th March 2022
      // @description : SFDC-5523 :Test method to check  If “Synergy” Lead is converted to an existing Renewal Oppy then the oppy will be 
      //                tagged as “Synergy”=Yes
      // @param : TriggerParameters
      // @return : void
      //-----------------------------
		@isTest
    static void updateSynergyFlagonOpportunity() {
        // Test data setup
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Contact con = TestUtility.createContact(acc.id,'testemail1@test.com',false,'TestFirstName','TestLastName');
        con.Phone = '123423';
        con.Fax = '321412321';
        
        insert con;
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
        TestUtility.loadCountryData();
            
        Test.startTest();
        
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'roger@test.ihsm.com';
        testLead.Description ='test';
        testLead.BudgetRange__c = '< 25,000';
        testLead.RecordTypeId=Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPG Referral Leads').getRecordTypeId();
        insert testLead;
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.id);
        lc.setAccountId(acc.id);
        lc.setContactId(con.id);
        lc.setOwnerId(UserInfo.getUserId());
        lc.setConvertedStatus('Converted');
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assertEquals(true,lcr.isSuccess(),'Lead Conversion error');
        //System.assertEquals([select Synergy1__c from opportunity where id =: lcr.opportunityid].Synergy1__c,'Yes');
        
       
        Test.stopTest();
    }
        
    //-----------------------------
    // @author: Ankush Agarwal
    // @date: 03 Mar 2022
    // @description: Test method for LeadDispatcher delete Methods
    // @param: none
    // @return: void
    //-----------------------------
	@isTest
    static void testLeadDelete() {
        // Test data setup
        User myTestUser = TestUtility.createAdminUser('opptyOwnertest@ihsmarkit.com', true);
        
        TestUtility.loadCountryData();
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.CountryCode = 'IN';
        testLead.Email  = 'roger@test.ihsm.com';
        testLead.Status = 'Prioritized';
        testLead.OwnerId = myTestUser.id;
        
        Test.startTest();
        insert testLead;
        delete testLead;
        List<Lead> leadList = [select Id, Email from Lead];
        system.assertEquals(leadList.size(),0,'Lead still exists');
        Test.stopTest();
    }
    
}