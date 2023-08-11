//-----------------------------
// @author: Harshit Singhal
// @date: 25 Aug 2020
// @param: NA
// @description: SFDC-3186 Test Class for BatchAutoCreateRenewalOpps batch class
// @return: NA
//----------------------------
@isTest
public class TestBatchAutoCreateRenewalOpps {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @description: SFDC-3186 Setup test data for the  batch class
    // @param: none
    // @return: void
    //-----------------------------
    @testSetup 
    public static void createTestData() {
        //Create custom setting records - ValidAAGMapping, ValidGlobalSegments,3 types of ValueMappings
        Test.startTest();
        TestBatchAutoCreateRenewalOpps.createTestAutoRenewalCustomSettings();
        
        //Account
        Account testAcc = TestUtility.createTestAccount('Test 3186 Account', false);
        testAcc.DataGovernanceStatus__c = 'Approved';
        insert testAcc;
                
        //Contact
        List<Contact> contactList = new List<Contact>();
        Contact testCon1 = TestUtility.createContact(testAcc.Id,'con1@externalorg.com',false,'Contact1','Test 3186 Account');
        contactList.add(testCon1);
        Contact testCon2 = TestUtility.createContact(testAcc.Id,'con2@externalorg.com',false,'Contact2','Test 3186 Account');
        contactList.add(testCon2);
        insert contactList;
        
        //Users
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'adm1', Email='admin1user3186@test.com', 
                          EmailEncodingKey='UTF-8', firstName='test1',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin1user3186@test.com',ADID__c='test1'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        
        User u2 = new User(Alias = 'adm2', Email='admin2user3186@test.com', 
                          EmailEncodingKey='UTF-8', firstName='test2',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin2user3186@test.com',ADID__c='test2'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert new List<User> {u1,u2};
                
        //Legal Entity
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD'); 
                
        //Products - Set Global Segment and AAG
        Product2 p1 = TestUtility.createProduct('Test SubProduct 1', false);
        p1.DiscountThreshold__c = 10;
        p1.LegalEntity__c = testLegalEntity.Id;
        p1.AAG__c = 'Subscription';
        p1.Division__c = 'Financial Svcs-Info';
        Product2 p2 = TestUtility.createProduct('Test SubProduct 2', false);
        p2.DiscountThreshold__c = 12;
        p2.LegalEntity__c = testLegalEntity.Id;
        p2.AAG__c = 'SubscriptionVar';
        p2.Division__c = 'Financial Svcs-Info';
        Product2 p3 = TestUtility.createProduct('Test NonFin Product 3', false);
        p3.DiscountThreshold__c = 12;
        p3.LegalEntity__c = testLegalEntity.Id;
        p3.AAG__c = 'SubscriptionVar';
        p3.Division__c = 'Resources';        
        insert new List<Product2>{p1,p2,p3};
                    
        //Price Book Entry        
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        PricebookEntry pbe3 = TestUtility.createPriceBookEntry(stdPricebookId, p3.Id, false);
        pbe1.CurrencyIsoCode = 'USD';
        pbe2.CurrencyIsoCode = 'USD';
        pbe3.CurrencyIsoCode = 'USD';
        insert new List<PricebookEntry>{pbe1,pbe2,pbe3};
        
        //Product Schedules
        ProductSchedule__c p1ps1 = TestUtility.createProductSchedule(1000.10, '2020', '3 Years', '2020', p1.Id, false);
        ProductSchedule__c p1ps2 = TestUtility.createProductSchedule(1010.20, '2021', '3 Years', '2020', p1.Id, false);
        ProductSchedule__c p1ps3 = TestUtility.createProductSchedule(1020.30, '2022', '3 Years', '2020', p1.Id, false);
        ProductSchedule__c p2ps1 = TestUtility.createProductSchedule(2000.10, '2020', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p2ps2 = TestUtility.createProductSchedule(2020.20, '2021', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p2ps3 = TestUtility.createProductSchedule(2030.30, '2022', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p3ps1 = TestUtility.createProductSchedule(2000.10, '2020', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p3ps2 = TestUtility.createProductSchedule(2020.20, '2021', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p3ps3 = TestUtility.createProductSchedule(2030.30, '2022', '3 Years', '2020', p2.Id, false);
        //insert new List<ProductSchedule__c>{p1ps1,p1ps2,p1ps3,p2ps1,p2ps2,p2ps3,p3ps1,p3ps2,p3ps3};
        
        //Create New Business Opp        
        List<Opportunity> testOppList = new List<Opportunity>();
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Opportunity testOpp1 = TestUtility.createOpportunity(testAcc.Id, '3186+ NewBiz Opp1', false);
		testOpp1.ContractStartDate__c = date.newinstance(currentFY, 03, 20);
		testOpp1.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpp1.MISActivityAdded__c = DateTime.now();
        testOpp1.ActivityCreated__c = true;
        testOppList.add(testOpp1);
        Opportunity testOpp2 = TestUtility.createOpportunity(testAcc.Id, '3186+ NewBiz Opp2', false);
		testOpp2.ContractStartDate__c = date.newinstance(currentFY, 03, 20);
		testOpp2.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpp2.MISActivityAdded__c = DateTime.now();
        testOpp2.ActivityCreated__c = true;
        testOppList.add(testOpp2);
        insert testOppList;
        
        //Add opp products
        OpportunityLineItem opp1testOLI1 = TestUtility.createOpportunityLineItem(testOpp1.Id, pbe1, false);
        opp1testOLI1.Product2Id = p1.Id;
        OpportunityLineItem opp1testOLI2 = TestUtility.createOpportunityLineItem(testOpp1.Id, pbe2, false);
        opp1testOLI2.Product2Id = p2.Id;
        OpportunityLineItem opp2testOLI1 = TestUtility.createOpportunityLineItem(testOpp2.Id, pbe1, false);
        opp2testOLI1.Product2Id = p1.Id;
        OpportunityLineItem opp2testOLI2 = TestUtility.createOpportunityLineItem(testOpp2.Id, pbe2, false);
        opp2testOLI2.Product2Id = p2.Id;
        OpportunityLineItem opp2testOLI3 = TestUtility.createOpportunityLineItem(testOpp2.Id, pbe3, false);
        opp2testOLI3.Product2Id = p3.Id;
        List<OpportunityLineItem> testOliList = new List<OpportunityLineItem> {opp1testOLI1,opp1testOLI2,opp2testOLI1,opp2testOLI2,opp2testOLI3};
        insert testOliList;
        
        //Add opp prod schedules
        List<OpportunityLineItemSchedule__c> testOLISList = new List<OpportunityLineItemSchedule__c>();
        for(OpportunityLineItem testOLI:testOliList) {
            OpportunityLineItemSchedule__c testOLIS1 = TestUtility.createOpportunityProductSchedule(testOLI.OpportunityId,null,1200,1000,'Amount', 100, 0.0, testOLI.Product2Id, '2020', 1, testOLI.Id,false);
            testOLISList.add(testOLIS1);
            OpportunityLineItemSchedule__c testOLIS2 = TestUtility.createOpportunityProductSchedule(testOLI.OpportunityId,null,1220,1010,'Amount', 100, 0.0, testOLI.Product2Id, '2021', 1, testOLI.Id,false);
            testOLISList.add(testOLIS2);
            OpportunityLineItemSchedule__c testOLIS3 = TestUtility.createOpportunityProductSchedule(testOLI.OpportunityId,null,1220,1010,'Amount', 100, 0.0, testOLI.Product2Id, '2022', 1, testOLI.Id,false);
            testOLISList.add(testOLIS3);
        }
        insert testOLISList;
        
        /*Create an activity for opps
        List<Event> testEvtList = new List<Event>();
        Event testEvtOpp1 = TestUtility.createEventWithWhoId('Test Event1',null, false);
        testEvtOpp1.WhatId = testOpp1.Id;
        testEvtList.add(testEvtOpp1);
        Event testEvtOpp2 = TestUtility.createEventWithWhoId('Test Event2',null, false);
        testEvtOpp2.WhatId = testOpp2.Id;
        testEvtList.add(testEvtOpp2);
        insert testEvtList;*/
        
        //Add Splits, Team, OCR to opp
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        OpportunityContactRole primaryOCROpp1 = new OpportunityContactRole(OpportunityId=testOpp1.Id,ContactId=testCon1.Id,IsPrimary=true);
        ocrList.add(primaryOCROpp1);
        OpportunityContactRole primaryOCROpp2 = new OpportunityContactRole(OpportunityId=testOpp2.Id,ContactId=testCon2.Id,IsPrimary=true);
        ocrList.add(primaryOCROpp2);
        insert ocrList;
        Test.stopTest();
        //Create contract
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
        Contract testContractOpp1 = TestUtility.createContractWithInsertOptional(testAcc.Id, testLegalEntity.Id, null, stdPricebookId,false );
        testContractOpp1.Opportunity__c = testOpp1.Id;
        testContractOpp1.RecordTypeId = ofRecordTypeId;
        Contract testContractOpp2 = TestUtility.createContractWithInsertOptional(testAcc.Id, testLegalEntity.Id, null, stdPricebookId,false );
        testContractOpp2.Opportunity__c = testOpp2.Id;
        testContractOpp2.RecordTypeId = ofRecordTypeId;
        insert new List<Contract> {testContractOpp1,testContractOpp2};
                    System.debug('SOQL-setup->'+Limits.getQueries());

    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Main test method for the batch class. Covers the positive test case of creating a renewal opp for an existing opp.
    // 					- It also covers following classes - BatchAutoCreateRenewalOppsHelper, RenewalsLogWrapper, BatchAutoCreateRenewalOppsScheduler
    // @param: none
    // @return: void
    //-----------------------------
    @isTest
    private static void testMethodPositiveCreateRenewalOpp() {
        Test.startTest();
        //Mark Contract as active which in turn also marks opp as 6W        
        Contract testContractOpp1 = [SELECT Id,Opportunity__c FROM Contract WHERE Opportunity__r.Name='3186+ NewBiz Opp1' Limit 1];
        TestUtility.createContractAttachment(testContractOpp1.id);
        markContractAsComplete(testContractOpp1, true);
        //Mark opp as 6WP which in turn creates a Renewal Staging record.
        Opportunity testOpp = new Opportunity(Id=testContractOpp1.Opportunity__c);
        testOpp.StageName='6WP-Closed Won/Order Processed';
        update testOpp;
        // Test.startTest();
        System.assertNotEquals(null, [SELECT Id FROM RenewalStaging__c WHERE Processed__c=false AND Opportunity__c=:testOpp.Id LIMIT 1], 'Renewal Staging record for opp not created.');
        //Execute Batch
        BatchAutoCreateRenewalOpps obj=new BatchAutoCreateRenewalOpps();
        
        Id batchJobId=Database.executeBatch(obj);
        System.debug('batch Id='+batchJobId);
        
        //Schedule the batch
        String jobId = system.schedule('Test Schedule For BatchAutoCreateRenewalOpps', '0 0 0 3 9 ? 2040' , new BatchAutoCreateRenewalOppsScheduler());
        //Test.stopTest();      
        //Assert Staging records after batch execution
        RenewalStaging__c stagingObj = [Select Id,Processed__c,Success__c From RenewalStaging__c WHERE Opportunity__c=:testOpp.Id LIMIT 1];
        //System.assertEquals(true, stagingObj.Processed__c, 'Staging record should be marked Processed after batch executes.');
        //System.assertEquals(true, stagingObj.Success__c, 'Staging record should be be marked Success after batch executes.');        
        
        //Assert Renewal opp after batch execution
        
        if (stagingObj.Success__c) {
            Opportunity testRenewalOpp = [SELECT Id,Name,AccountId,ContractStartDate__c,ContractEndDate__c,CloseDate,
                                          (SELECT Id FROM OpportunityLineItems),
                                          (SELECT Id FROM OpportunityProductSchedules__r),
                                          (SELECT Id FROM OpportunityContactRoles),
                                          (SELECT Id FROM OpportunitySplits),
                                          (SELECT Id FROM OpportunityTeamMembers)
                                          
                                           FROM Opportunity 
                                           WHERE PreviousYearOpportunityLink__c=:testOpp.Id AND RecordType.Name='Renewal' 
                                           LIMIT 1];        
            Test.stopTest();    
            System.assertNotEquals(null, testRenewalOpp, 'Renewal opp not created.');        
            System.assertNotEquals(0, testRenewalOpp.OpportunityLineItems.size(), 'Opportunity Products not created for Renewal Opp.');
            System.assertNotEquals(0, testRenewalOpp.OpportunityProductSchedules__r.size(), 'Opportunity Product Schedules not created for Renewal Opp.');
            System.assertNotEquals(0, testRenewalOpp.OpportunityTeamMembers.size(), 'Opportunity Team Members not created for Renewal Opp.');
            System.assertNotEquals(0, testRenewalOpp.OpportunityContactRoles.size(), 'Opportunity Contact Roles not created for Renewal Opp.');
            System.assertNotEquals(0, testRenewalOpp.OpportunitySplits.size(), 'Opportunity Splits not created for Renewal Opp.');
        
        }
             
      }
     
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Test Method - Covers the exception scenario where Opp is not valid for renewal.
    // @param: none
    // @return: void
    //-----------------------------
    
    @isTest
    private static void testMethodOppException() {
        Test.startTest();       
        
        //Query test admin user
        List<User> testUserList = [SELECT Id,Username FROM User WHERE Username IN ('admin1user3186@test.com','admin2user3186@test.com')];
        User testUser1 = testUserList[0].Username=='admin1user3186@test.com' ? testUserList[0] : null ;
        User testUser2 = testUserList[1].Username=='admin2user3186@test.com' ? testUserList[1] : null ;
        
        //Query test opps
        Opportunity testOpp1,testOpp2;
        for(Opportunity testOpp: [SELECT Id,Name FROM Opportunity]) {
            if(testOpp.Name=='3186+ NewBiz Opp1') {
                testOpp1 = testOpp;
            }
            if(testOpp.Name=='3186+ NewBiz Opp2') {
                testOpp2 = testOpp;              
            }
        }
        //Change testOpp2 owner
        testOpp2.OwnerId = testUser1.Id;
        update testOpp2;
        
        //Mark user as inactive
        System.runAs(testUser2) {            
            testUser1.IsActive = false;
            update testUser1;            
        }
        
        
        //Create Staging record for both opps
        List<RenewalStaging__c> testRenewalStagingList = new List<RenewalStaging__c>();
        RenewalStaging__c testStagingRec1 = createTestRenewalStagingRecord(testOpp1, false);
        RenewalStaging__c testStagingRec2 = createTestRenewalStagingRecord(testOpp2, false);
        testRenewalStagingList.add(testStagingRec1);
        testRenewalStagingList.add(testStagingRec2);
        insert testRenewalStagingList;
        
        //Execute Batch
        BatchAutoCreateRenewalOpps obj=new BatchAutoCreateRenewalOpps();
        Id batchJobId=Database.executeBatch(obj);
        
        Test.stopTest();
        
        //Query and Assert Renewal Staging records
        for(RenewalStaging__c testStagingObj: [Select Id,Processed__c,Exception__c,ExceptionDescription__c,Opportunity__r.Name From RenewalStaging__c WHERE Processed__c=true]) {
            System.assertEquals(true, testStagingObj.Exception__c, 'Opp Level Validation exception should be thrown.');
            System.assertEquals(true, testStagingObj.ExceptionDescription__c.contains('Opp Level Validation failed'), 'Description should contain this msg - Opp Level Validation failed');
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Test Method - Covers the exception scenario where Opportunity Products are not valid for renewal.
    // @param: none
    // @return: void
    //-----------------------------
    
    @isTest
    private static void testMethodOppProductException() {
        Test.startTest();
        
        //Mark Contract as active which in turn also marks opp as 6W
        List<Contract> updContractList = new List<Contract>();
        Contract testContractOpp2 = [SELECT Id,Opportunity__c,Opportunity__r.Name FROM Contract WHERE Opportunity__r.Name='3186+ NewBiz Opp2' LIMIT 1];
        TestUtility.createContractAttachment(testContractOpp2.id);
        markContractAsComplete(testContractOpp2, true);
        
        //Mark opp as 6WP which in turn creates a Renewal Staging record.
        Opportunity testOpp2 = new Opportunity(Id=testContractOpp2.Opportunity__c);
        testOpp2.StageName='6WP-Closed Won/Order Processed';
        update testOpp2;
            
        //Execute Batch        
        BatchAutoCreateRenewalOpps obj=new BatchAutoCreateRenewalOpps();
        Id batchJobId=Database.executeBatch(obj);
            
        Test.stopTest();
        
        //Query and Assert Renewal Staging records
        RenewalStaging__c testStagingObj = [Select Id,Processed__c,Exception__c,ExceptionDescription__c,Opportunity__r.Name From RenewalStaging__c WHERE Opportunity__r.Name='3186+ NewBiz Opp2' AND Processed__c=true LIMIT 1];
        System.assertEquals(true, testStagingObj.Exception__c, 'Opp Product Level Validation exception should be thrown.');
        System.assertEquals(true, testStagingObj.ExceptionDescription__c.contains('Opp Product Level Validations failed'), 'Description should contain this msg - Opp Product Level Validations failed');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Test Method - Covers the exception scenario where Opportunity's active Order Form contract is not valid for renewal as Renewal Term='One-time Expiring'.
    // @param: none
    // @return: void
    //-----------------------------
    
    @isTest
    private static void testMethodOneTimeContractException() {
        Test.startTest();
        
        //Mark Contract as active which in turn also marks opp as 6W
        List<Contract> updContractList = new List<Contract>();
        Contract testContractOpp1 = [SELECT Id,Opportunity__c,Opportunity__r.Name FROM Contract WHERE Opportunity__r.Name='3186+ NewBiz Opp1' LIMIT 1];
        TestUtility.createContractAttachment(testContractOpp1.id);
        testContractOpp1 = markContractAsComplete(testContractOpp1, false);
        testContractOpp1.RenewalTerm__c = 'One-time Expiring';
        update testContractOpp1;
        
        //Mark opp as 6WP which in turn creates a Renewal Staging record.
        Opportunity testOpp1 = new Opportunity(Id=testContractOpp1.Opportunity__c);
        testOpp1.StageName='6WP-Closed Won/Order Processed';
        update testOpp1;
            
        //Execute Batch        
        BatchAutoCreateRenewalOpps obj=new BatchAutoCreateRenewalOpps();
        Id batchJobId=Database.executeBatch(obj);
        
        Test.stopTest();
        
        //Query and Assert Renewal Staging records
        RenewalStaging__c testStagingObj = [Select Id,Processed__c,Exception__c,ExceptionDescription__c,HasOneTimeContract__c,Opportunity__r.Name From RenewalStaging__c WHERE Processed__c=true AND Opportunity__r.Name='3186+ NewBiz Opp1' LIMIT 1];
        System.assertEquals(true, testStagingObj.Exception__c, 'Contract Level Validation exception should be thrown.');
        System.assertEquals(true, testStagingObj.ExceptionDescription__c.contains('Contract Level Validations failed'), 'Description should contain this msg - Contract Level Validations failed');
        System.assertEquals(true, testStagingObj.HasOneTimeContract__c, 'Has One-Time Contract? field on RenewalStaging__c record should be true.');
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 23 Oct 2020
    // @description: SFDC-3372 Test Method - Covers the exception scenario where Opportunity's active Order Form contract is not valid for renewal as its Renewal Term='Evergreen' and Billing Frequency='Non-Billable'.
    // @param: none
    // @return: void
    //-----------------------------
    
    @isTest
    private static void testMethodEvergreenContractException() {
        Test.startTest();
        
        //Mark Contract as active which in turn also marks opp as 6W
        List<Contract> updContractList = new List<Contract>();
        Contract testContractOpp1 = [SELECT Id,Opportunity__c,Opportunity__r.Name FROM Contract WHERE Opportunity__r.Name='3186+ NewBiz Opp1' LIMIT 1];
        TestUtility.createContractAttachment(testContractOpp1.id);
        testContractOpp1 = markContractAsComplete(testContractOpp1, false);
        testContractOpp1.RenewalTerm__c = 'Evergreen';
        testContractOpp1.BillingFrequency__c = 'Non-Billable';
        update testContractOpp1;
        
        //Mark opp as 6WP which in turn creates a Renewal Staging record.
        Opportunity testOpp1 = new Opportunity(Id=testContractOpp1.Opportunity__c);
        testOpp1.StageName='6WP-Closed Won/Order Processed';
        update testOpp1;
            
        //Execute Batch        
        BatchAutoCreateRenewalOpps obj=new BatchAutoCreateRenewalOpps();
        Id batchJobId=Database.executeBatch(obj);
        
        Test.stopTest();
        
        //Query and Assert Renewal Staging records
        RenewalStaging__c testStagingObj = [Select Id,Processed__c,Exception__c,ExceptionDescription__c,HasNonBillableEvergreenContract__c,Opportunity__r.Name From RenewalStaging__c WHERE Processed__c=true AND Opportunity__r.Name='3186+ NewBiz Opp1' LIMIT 1];
        System.assertEquals(true, testStagingObj.Exception__c, 'Contract Level Validation exception should be thrown.');
        System.assertEquals(true, testStagingObj.ExceptionDescription__c.contains('Contract Level Validations failed'), 'Description should contain this msg - Contract Level Validations failed');
        System.assertEquals(true, testStagingObj.HasNonBillableEvergreenContract__c, 'Has Non-Billable Evergreen Contract? field on RenewalStaging__c record should be true.');
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Helper Method - Updates the contract to Complete stage. This also updates the related opp to 6W stage.
    // @param: 
    // 			1) Contract testContract - Input contract
    // 			2) Boolean shouldUpdate - Boolean that indicates if update DML should be fired or not.
    // @return: Contract - Returns updated contract
    //-----------------------------
    public static Contract markContractAsComplete(Contract testContract, Boolean shouldUpdate) {
        testContract.ContractStatus__c = 'Validated';
        testContract.Status = 'Complete';
        testContract.OrderReason__c = 'New';
        testContract.Fastrack__c = true;
        testContract.AutoRenewal__c = true;
        testContract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.RenewalTerm__c = '18 Months';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        
        if(shouldUpdate) {
            update testContract;
        }
        return testContract;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Helper Method - Create Renewal Staging Records manually
    // @param: 
    // 			1) Opportunity opp - Opportunity for which staging record should be created
    // 			2) Boolean shouldInsert - Boolean that indicates if insert DML should be fired or not.
    // @return: RenewalStaging__c - Returns RenewalStaging__c record
    //-----------------------------
    public static RenewalStaging__c createTestRenewalStagingRecord(Opportunity opp, Boolean shouldInsert) {        
        RenewalStaging__c testStaging = new RenewalStaging__c(Opportunity__c=opp.Id);
        if(shouldInsert) {
            insert testStaging;
        }
        return testStaging;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Helper Method - Check SOQL limit and debug them
    // @param: none
    // @return: none
    //-----------------------------    
    static void checkQueryCount() {
        Integer aggQueryCount = Limits.getAggregateQueries();
        System.debug('**aggQueryCount='+aggQueryCount);
        Integer queryCount = Limits.getQueries();
        System.debug('**queryCount='+queryCount);
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Helper Method - Creates test records in AutomatedRenewalsMappings__c custom setting for value mappings, criteria mappings, field mappings(for objects - opp, opp product, opp product schedule, opp team member, opp split)
    // @param: Boolean shouldInsert - Boolean that indicates if insert DML should be fired or not.
    // @return: List<AutomatedRenewalsMappings__c> - Returns list of AutomatedRenewalsMappings__c custom setting records
    //-----------------------------
    public static List<AutomatedRenewalsMappings__c> createTestAutoRenewalMappingCustomSettings(Boolean shouldInsert) {
        //MAPPINGS custom setting
        List<AutomatedRenewalsMappings__c> mappingsList = new List<AutomatedRenewalsMappings__c>();
        
        //Criteria Mappings
        AutomatedRenewalsMappings__c segmentCriteria1 = new AutomatedRenewalsMappings__c(Name='ValidProductGlobalSegments1',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='Global Segment',SourceValue__c='Financial Services');
        mappingsList.add(segmentCriteria1);
        AutomatedRenewalsMappings__c segmentCriteria2 = new AutomatedRenewalsMappings__c(Name='ValidProductGlobalSegments2',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='Global Segment',SourceValue__c='Financial Svcs-Info');
        mappingsList.add(segmentCriteria2);
        AutomatedRenewalsMappings__c segmentCriteria3 = new AutomatedRenewalsMappings__c(Name='ValidProductGlobalSegments3',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='Global Segment',SourceValue__c='Financial Svcs-Processing');
        mappingsList.add(segmentCriteria3);
        AutomatedRenewalsMappings__c segmentCriteria4 = new AutomatedRenewalsMappings__c(Name='ValidProductGlobalSegments4',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='Global Segment',SourceValue__c='Financial Svcs-Solutions');
        mappingsList.add(segmentCriteria4);
        AutomatedRenewalsMappings__c aagCriteria1 = new AutomatedRenewalsMappings__c(Name='ValidProductAAG1',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='AAG',SourceValue__c='Subscription',RuleName__c='Subscription');
        mappingsList.add(aagCriteria1);
        AutomatedRenewalsMappings__c aagCriteria2 = new AutomatedRenewalsMappings__c(Name='ValidProductAAG2',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='AAG',SourceValue__c='SubscriptionVar',RuleName__c='Subscription');
        mappingsList.add(aagCriteria2);
        AutomatedRenewalsMappings__c aagCriteria3 = new AutomatedRenewalsMappings__c(Name='ValidProductAAG3',Active__c=true,CriteriaMapping__c=true,SourceObject__c='Product',SourceField__c='AAG',SourceValue__c='Consulting',RuleName__c='Non-Subscription');
        mappingsList.add(aagCriteria3);
        
        //Value Mappings
        AutomatedRenewalsMappings__c renTermCEDValue1 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping1',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='1 Month',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue1);
        AutomatedRenewalsMappings__c renTermCEDValue2 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping2',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='2 Months',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue2);
        AutomatedRenewalsMappings__c renTermCEDValue3 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping3',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='3 Months',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue3);
        AutomatedRenewalsMappings__c renTermCEDValue4 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping4',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='6 Months',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue4);
        AutomatedRenewalsMappings__c renTermCEDValue5 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping5',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='1 Year',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue5);
        AutomatedRenewalsMappings__c renTermCEDValue6 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping6',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='18 Months',TargetField__c='Contract End Date',TargetValue__c='18');
        mappingsList.add(renTermCEDValue6);
        AutomatedRenewalsMappings__c renTermCEDValue7 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping7',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='2 Years',TargetField__c='Contract End Date',TargetValue__c='24');
        mappingsList.add(renTermCEDValue7);
        AutomatedRenewalsMappings__c renTermCEDValue8 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping8',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='3 Years',TargetField__c='Contract End Date',TargetValue__c='36');
        mappingsList.add(renTermCEDValue8);
        AutomatedRenewalsMappings__c renTermCEDValue9 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping9',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='4 Years',TargetField__c='Contract End Date',TargetValue__c='48');
        mappingsList.add(renTermCEDValue9);
        AutomatedRenewalsMappings__c renTermCEDValue10 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping10',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='5 Years',TargetField__c='Contract End Date',TargetValue__c='60');
        mappingsList.add(renTermCEDValue10);
        AutomatedRenewalsMappings__c renTermCEDValue11 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping11',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='Evergreen',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue11);
        AutomatedRenewalsMappings__c renTermCEDValue12 = new AutomatedRenewalsMappings__c(Name='RenewalTermCEDMapping12',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='Not Applicable',TargetField__c='Contract End Date',TargetValue__c='12');
        mappingsList.add(renTermCEDValue12);
        
        AutomatedRenewalsMappings__c renTermSchedValue1 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping1',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='1 Month',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue1);
        AutomatedRenewalsMappings__c renTermSchedValue2 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping2',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='2 Months',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue2);
        AutomatedRenewalsMappings__c renTermSchedValue3 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping3',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='3 Months',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue3);
        AutomatedRenewalsMappings__c renTermSchedValue4 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping4',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='6 Months',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue4);
        AutomatedRenewalsMappings__c renTermSchedValue5 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping5',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='1 Year',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue5);
        AutomatedRenewalsMappings__c renTermSchedValue6 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping6',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='18 Months',TargetField__c='Schedules Count',TargetValue__c='2');
        mappingsList.add(renTermSchedValue6);
        AutomatedRenewalsMappings__c renTermSchedValue7 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping7',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='2 Years',TargetField__c='Schedules Count',TargetValue__c='2');
        mappingsList.add(renTermSchedValue7);
        AutomatedRenewalsMappings__c renTermSchedValue8 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping8',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='3 Years',TargetField__c='Schedules Count',TargetValue__c='3');
        mappingsList.add(renTermSchedValue8);
        AutomatedRenewalsMappings__c renTermSchedValue9 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping9',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='4 Years',TargetField__c='Schedules Count',TargetValue__c='4');
        mappingsList.add(renTermSchedValue9);
        AutomatedRenewalsMappings__c renTermSchedValue10 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping10',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='5 Years',TargetField__c='Schedules Count',TargetValue__c='5');
        mappingsList.add(renTermSchedValue10);
        AutomatedRenewalsMappings__c renTermSchedValue11 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping11',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='Evergreen',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue11);
        AutomatedRenewalsMappings__c renTermSchedValue12 = new AutomatedRenewalsMappings__c(Name='RenewalTermSchedulesMapping12',Active__c=true,ValueMapping__c=true,SourceField__c='Renewal Term',SourceValue__c='Not Applicable',TargetField__c='Schedules Count',TargetValue__c='1');
        mappingsList.add(renTermSchedValue12);
        
        AutomatedRenewalsMappings__c termNotceCloseDateValue1 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping1',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='5 days',TargetField__c='Close Date',TargetValue__c='5');
        mappingsList.add(termNotceCloseDateValue1);
        AutomatedRenewalsMappings__c termNotceCloseDateValue2 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping2',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='10 days',TargetField__c='Close Date',TargetValue__c='10');
        mappingsList.add(termNotceCloseDateValue2);
        AutomatedRenewalsMappings__c termNotceCloseDateValue3 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping3',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='15 days',TargetField__c='Close Date',TargetValue__c='15');
        mappingsList.add(termNotceCloseDateValue3);
        AutomatedRenewalsMappings__c termNotceCloseDateValue4 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping4',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='30 days',TargetField__c='Close Date',TargetValue__c='30');
        mappingsList.add(termNotceCloseDateValue4);
        AutomatedRenewalsMappings__c termNotceCloseDateValue5 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping5',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='45 days',TargetField__c='Close Date',TargetValue__c='45');
        mappingsList.add(termNotceCloseDateValue5);
        AutomatedRenewalsMappings__c termNotceCloseDateValue6 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping6',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='60 days',TargetField__c='Close Date',TargetValue__c='60');
        mappingsList.add(termNotceCloseDateValue6);
        AutomatedRenewalsMappings__c termNotceCloseDateValue7 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping7',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='90 days',TargetField__c='Close Date',TargetValue__c='90');
        mappingsList.add(termNotceCloseDateValue7);
        AutomatedRenewalsMappings__c termNotceCloseDateValue8 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping8',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='120 days',TargetField__c='Close Date',TargetValue__c='120');
        mappingsList.add(termNotceCloseDateValue8);
        AutomatedRenewalsMappings__c termNotceCloseDateValue9 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping9',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='180 days',TargetField__c='Close Date',TargetValue__c='180');
        mappingsList.add(termNotceCloseDateValue9);
        AutomatedRenewalsMappings__c termNotceCloseDateValue10 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping10',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='365 days',TargetField__c='Close Date',TargetValue__c='365');
        mappingsList.add(termNotceCloseDateValue10);
        AutomatedRenewalsMappings__c termNotceCloseDateValue11 = new AutomatedRenewalsMappings__c(Name='TerminationNoticeCloseDateMapping11',Active__c=true,ValueMapping__c=true,SourceField__c='Termination Notice',SourceValue__c='1095 days',TargetField__c='Close Date',TargetValue__c='1095');
        mappingsList.add(termNotceCloseDateValue11);
        
        //Field Mappings - Opp
        AutomatedRenewalsMappings__c oppDirectFieldMap1 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping1',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='ChannelPartner__c',SourceObject__c='Opportunity',SourceField__c='ChannelPartner__c',RuleName__c='DirectOppToOppMapping');
        mappingsList.add(oppDirectFieldMap1);
        AutomatedRenewalsMappings__c oppDirectFieldMap2 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping2',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='AccountId',SourceObject__c='Opportunity',SourceField__c='AccountId',RuleName__c='DirectOppToOppMapping');
        mappingsList.add(oppDirectFieldMap2);
        AutomatedRenewalsMappings__c oppDirectFieldMap3 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping3',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='OwnerId',SourceObject__c='Opportunity',SourceField__c='OwnerId',RuleName__c='DirectOppToOppMapping');
        mappingsList.add(oppDirectFieldMap3);
        AutomatedRenewalsMappings__c oppDirectFieldMap4 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping4',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='PreviousYearOpportunitylink__c',SourceObject__c='Opportunity',SourceField__c='Id',RuleName__c='DirectOppToOppMapping');
        mappingsList.add(oppDirectFieldMap4);
        AutomatedRenewalsMappings__c oppDirectFieldMap5 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping5',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='GAM__c',SourceObject__c='Opportunity',SourceField__c='Account.GlobalAccountManager__c',RuleName__c='DirectOppToOppMapping');
        mappingsList.add(oppDirectFieldMap5);
        
        AutomatedRenewalsMappings__c oppCondOppFieldMap1 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping21',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='AutoRenewal__c',SourceObject__c='Opportunity',SourceField__c='AutoRenewal__c',RuleName__c='ConditionalOppToOppMapping');
        mappingsList.add(oppCondOppFieldMap1);
        AutomatedRenewalsMappings__c oppCondOppFieldMap2 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping22',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='LegalEntity__c',SourceObject__c='Opportunity',SourceField__c='LegalEntity__c',RuleName__c='ConditionalOppToOppMapping');
        mappingsList.add(oppCondOppFieldMap2);
        AutomatedRenewalsMappings__c oppCondOppFieldMap3 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping23',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='SAP_RenewalTerm__c',SourceObject__c='Opportunity',SourceField__c='SAP_RenewalTerm__c',RuleName__c='ConditionalOppToOppMapping');
        mappingsList.add(oppCondOppFieldMap3);
        AutomatedRenewalsMappings__c oppCondOppFieldMap4 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping24',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='SAP_TerminationNotice__c',SourceObject__c='Opportunity',SourceField__c='SAP_TerminationNotice__c',RuleName__c='ConditionalOppToOppMapping');
        mappingsList.add(oppCondOppFieldMap4);
        
        AutomatedRenewalsMappings__c oppCondCtrctFieldMap1 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping61',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='AutoRenewal__c',SourceObject__c='Contract',SourceField__c='AutoRenewal__c',RuleName__c='ConditionalContractToOppMapping');
        mappingsList.add(oppCondCtrctFieldMap1);
        AutomatedRenewalsMappings__c oppCondCtrctFieldMap2 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping62',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='LegalEntity__c',SourceObject__c='Contract',SourceField__c='IHSMarkitLegalEntity__c',RuleName__c='ConditionalContractToOppMapping');
        mappingsList.add(oppCondCtrctFieldMap2);
        AutomatedRenewalsMappings__c oppCondCtrctFieldMap3 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping63',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='SAP_RenewalTerm__c',SourceObject__c='Contract',SourceField__c='RenewalTerm__c',RuleName__c='ConditionalContractToOppMapping');
        mappingsList.add(oppCondCtrctFieldMap3);
        AutomatedRenewalsMappings__c oppCondCtrctFieldMap4 = new AutomatedRenewalsMappings__c(Name='Opportunity Mapping64',Active__c=true,FieldMapping__c=true,TargetObject__c='Opportunity',TargetField__c='SAP_TerminationNotice__c',SourceObject__c='Contract',SourceField__c='TerminationNotice__c',RuleName__c='ConditionalContractToOppMapping');
        mappingsList.add(oppCondCtrctFieldMap4);
        
        //Field Mappings - Opp Prod
        AutomatedRenewalsMappings__c oppProdFieldMap1 = new AutomatedRenewalsMappings__c(Name='OpportunityProductMapping1',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItem',TargetField__c='Product2Id',SourceObject__c='OpportunityLineItem',SourceField__c='Product2Id',RuleName__c='OliToOliMapping');
        mappingsList.add(oppProdFieldMap1);
        AutomatedRenewalsMappings__c oppProdFieldMap2 = new AutomatedRenewalsMappings__c(Name='OpportunityProductMapping2',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItem',TargetField__c='PricebookEntryId',SourceObject__c='OpportunityLineItem',SourceField__c='PricebookEntryId',RuleName__c='OliToOliMapping');
        mappingsList.add(oppProdFieldMap2);
        AutomatedRenewalsMappings__c oppProdFieldMap3 = new AutomatedRenewalsMappings__c(Name='OpportunityProductMapping3',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItem',TargetField__c='Quantity',SourceObject__c='OpportunityLineItem',SourceField__c='Quantity',RuleName__c='OliToOliMapping');
        mappingsList.add(oppProdFieldMap3);
        AutomatedRenewalsMappings__c oppProdFieldMap4 = new AutomatedRenewalsMappings__c(Name='OpportunityProductMapping4',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItem',TargetField__c='TotalPrice',SourceObject__c='OpportunityLineItem',SourceField__c='TotalPrice',RuleName__c='OliToOliMapping');
        mappingsList.add(oppProdFieldMap4);
        
        //Field Mappings - Opp Prod Schedule
        AutomatedRenewalsMappings__c oppProdSchedFieldMap1 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping1',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='Product__c',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='Product__c');
        mappingsList.add(oppProdSchedFieldMap1);
        AutomatedRenewalsMappings__c oppProdSchedFieldMap2 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping2',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='CurrencyIsoCode',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='CurrencyIsoCode');
        mappingsList.add(oppProdSchedFieldMap2);
        AutomatedRenewalsMappings__c oppProdSchedFieldMap3 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping3',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='OwnerId',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='OwnerId');
        mappingsList.add(oppProdSchedFieldMap3);
        AutomatedRenewalsMappings__c oppProdSchedFieldMap4 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping4',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='PriceBookListPrice__c',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='PriceBookListPrice__c');
        mappingsList.add(oppProdSchedFieldMap4);
        AutomatedRenewalsMappings__c oppProdSchedFieldMap5 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping5',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='Quantity__c',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='Quantity__c');
        mappingsList.add(oppProdSchedFieldMap5);
        AutomatedRenewalsMappings__c oppProdSchedFieldMap6 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping6',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='TotalPrice__c',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='TotalPrice__c');
        mappingsList.add(oppProdSchedFieldMap6);
        AutomatedRenewalsMappings__c oppProdSchedFieldMap7 = new AutomatedRenewalsMappings__c(Name='OpportunityProductScheduleMapping7',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityLineItemSchedule__c',TargetField__c='ExternalListPrice__c',SourceObject__c='OpportunityLineItemSchedule__c',SourceField__c='ExternalListPrice__c');
        mappingsList.add(oppProdSchedFieldMap7);
        
        //Field Mappings - Opp Team
        AutomatedRenewalsMappings__c oppTeamFieldMap1 = new AutomatedRenewalsMappings__c(Name='OpportunityTeamMapping1',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityTeamMember',TargetField__c='UserId',SourceObject__c='OpportunityTeamMember',SourceField__c='UserId');
        mappingsList.add(oppTeamFieldMap1);
        AutomatedRenewalsMappings__c oppTeamFieldMap2 = new AutomatedRenewalsMappings__c(Name='OpportunityTeamMapping2',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityTeamMember',TargetField__c='TeamMemberRole',SourceObject__c='OpportunityTeamMember',SourceField__c='TeamMemberRole');
        mappingsList.add(oppTeamFieldMap2);
        AutomatedRenewalsMappings__c oppTeamFieldMap3 = new AutomatedRenewalsMappings__c(Name='OpportunityTeamMapping3',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityTeamMember',TargetField__c='OpportunityAccessLevel',SourceObject__c='OpportunityTeamMember',SourceField__c='OpportunityAccessLevel');
        mappingsList.add(oppTeamFieldMap3);
        
        //Field Mappings - Opp Split
        AutomatedRenewalsMappings__c oppSplitFieldMap1 = new AutomatedRenewalsMappings__c(Name='OpportunitySplitMapping1',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunitySplit',TargetField__c='SplitOwnerId',SourceObject__c='OpportunitySplit',SourceField__c='SplitOwnerId');
        mappingsList.add(oppSplitFieldMap1);
        AutomatedRenewalsMappings__c oppSplitFieldMap2 = new AutomatedRenewalsMappings__c(Name='OpportunitySplitMapping2',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunitySplit',TargetField__c='SplitPercentage',SourceObject__c='OpportunitySplit',SourceField__c='SplitPercentage');
        mappingsList.add(oppSplitFieldMap2);
        AutomatedRenewalsMappings__c oppSplitFieldMap3 = new AutomatedRenewalsMappings__c(Name='OpportunitySplitMapping3',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunitySplit',TargetField__c='SplitTypeId',SourceObject__c='OpportunitySplit',SourceField__c='SplitTypeId');
        mappingsList.add(oppSplitFieldMap3);
        
        //Field Mappings - Opp Contact Role
        AutomatedRenewalsMappings__c oppContactRoleFieldMap1 = new AutomatedRenewalsMappings__c(Name='OpportunityContactRoleMapping1',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityContactRole',TargetField__c='ContactId',SourceObject__c='OpportunityContactRole',SourceField__c='ContactId');
        mappingsList.add(oppContactRoleFieldMap1);
        AutomatedRenewalsMappings__c oppContactRoleFieldMap2 = new AutomatedRenewalsMappings__c(Name='OpportunityContactRoleMapping2',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityContactRole',TargetField__c='IsPrimary',SourceObject__c='OpportunityContactRole',SourceField__c='IsPrimary');
        mappingsList.add(oppContactRoleFieldMap2);
        AutomatedRenewalsMappings__c oppContactRoleFieldMap3 = new AutomatedRenewalsMappings__c(Name='OpportunityContactRoleMapping3',Active__c=true,FieldMapping__c=true,TargetObject__c='OpportunityContactRole',TargetField__c='Role',SourceObject__c='OpportunityContactRole',SourceField__c='Role');
        mappingsList.add(oppContactRoleFieldMap3);
        
        if(shouldInsert) {
            insert mappingsList;
        }
        
        return mappingsList;        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Helper Method - Creates test org default record in AutomatedRenewalsConfig__c custom setting
    // @param: Boolean shouldInsert - Boolean that indicates if insert DML should be fired or not.
    // @return: List<AutomatedRenewalsMappings__c> - Returns list of AutomatedRenewalsConfig__c custom setting records
    //-----------------------------
    public static List<AutomatedRenewalsConfig__c> createTestAutoRenewalConfigCustomSettings(Boolean shouldInsert) {
        //CONFIGS custom setting
        List<AutomatedRenewalsConfig__c> configsList = new List<AutomatedRenewalsConfig__c>();        
        //Org Default Config
        AutomatedRenewalsConfig__c orgDefaultSetting= new AutomatedRenewalsConfig__c(SetupOwnerId=UserInfo.getOrganizationId(), DoNotTriggerRenewals__c=false, RenewalsBatchSize__c=200, LogEmailRecipient__c='sfadmin@ihsmarkit.com');        
        configsList.add(orgDefaultSetting);
        if(shouldInsert) {
            insert configsList;            
        }
        return configsList;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 30 Aug 2020
    // @description: SFDC-3186 Helper Method - Creates test records in AutomatedRenewalsConfig__c and AutomatedRenewalsMappings__c custom settings
    // @param: none
    // @return: none
    //-----------------------------
    public static void createTestAutoRenewalCustomSettings() {
        createTestAutoRenewalConfigCustomSettings(true);
        createTestAutoRenewalMappingCustomSettings(true);
    }    

}