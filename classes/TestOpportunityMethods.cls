//-----------------------------
// @author: Prachi Bhasin
// @date: 4 July 2017
// @param: NA
// @description: Test class for Opportunity trigger methods 
// @return: NA
// @Last Modified By : Vinod Merwade
// @Last Modified Description : Corrected the Test class according to new validation rules on Opportunity
// @Last Modified Date : 19 Sept 2017
// @Last Modified By : Hemant Shukla
// @Last Modified Description : Removed the dependency of ContractExists__c field based on SFDC1-5701
// @Last Modified Date : 6-Nov-2017
// @Last Modified By : Hemant Shukla
// @Last Modified Description : SFDC1-5857 : Removing an method testCheckEndUserCertificateAttachment() as the method is being removed from class. 
// @Last Modified Date : 21-Nov-2017
// @Last Modified By : Sonam Raju
// @Last Modified Description : SFDC1-6245 : Test method for Opportunity trigger method checkChannelManagerRoleonOpptyTeamforStage2andhigher on update
// @Last Modified Date : 3-Jan-2018
// @Last Modified By : Paras Dhingra
// @Last Modified Description : SFDC1-4723 : Test Method for OpportunityMethod.updateOpportunitySplitOnGamChange
// @Last Modified Date : 4-Jan-2018
// @Last Modified By: Sruti Srivastava
// @Last Modified Date: 9th April 2018
// @Last Modified Description: SFDC1-7027- Test method for updateContractStartDateAndEndDateOnOpportunityLineItem 
// @Last Modified By : Anjani Shukla
// @Last Modified Description : SFDC1-7667 : Test Method for OpportunityMethod.updateOpportunityRiskRecordStatus
// @Last Modified Date : 09-Apr-2018
// @Last Modified By : Jagadesh Kumar
// @Last Modified Description : SFDC1-5228 : Test Method for OpportunityMethod.setContactRolePrimary
// @Last Modified Date : 31 July 2018
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 04 Jan 2019
// @Last Modified Description: SFDC1-10744 add Test method for OpportunityMethod.checkUserProfileBeforeDelete
// @Last Modified By: Harshit Singhal
// @Last Modified Date: 08 Feb 2019
// @Last Modified Description : SFDC-614: Implementation Proof of Delivery Case is not needed when an Auto Renewal is set to 6W. Removed 'testCreateImplementationCaseWhenRenewalOpportunity6W()' testmethod which was created in respect with parent story SFDC1-9781.
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 11 February 2019
// @Last Modified Description: SFDC-660 add test logic for "Opportunity Stage" value from Opportunity
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 12 February 2019
// @Last Modified Description: SFDC-32 add test logic for populating "Opportunity Country" value from Account
// @Last Modified By: Paras Dhingra
// @Last Modified Date: 08 May 2019
// @Last Modified Description: SFDC-1364 adding test method for resetAccountManagerSplitOnOwnerChange
//-----------------------------

@isTest
private class TestOpportunityMethods {
    @testSetup 
    static void insertTestData() {
        System.debug('=====limits.getQueries() in test setup===' + limits.getQueries()); 
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        
        User testUser1 = TestUtility.createAdminUser('testUser1email@test.com.ihsmarkit.test', false);
        User testUser2 = TestUtility.createAdminUser('testUser2email@test.com.ihsmarkit.test', false);
        User testUser3 = TestUtility.createAdminUser('testUser3email@test.com.ihsmarkit.test', false);       
        
        insert new List<User>{testUser1, testUser2, testUser3};
        
        List<LoadingGroup__c> loadingGroupList = new List<LoadingGroup__c>();
        loadingGroupList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg1', false));
        loadingGroupList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg2', false));
        insert loadingGroupList;
        
        ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='UP - Energy', Active__c=true, ProfitCenterCode__c='187');
        insert testProfitCenter;
        
        Family__c testProdFam = new Family__c(Name='ETC-C&A',Status__c ='Active');
        insert testProdFam;

        List<Product2> productList = new List<Product2>();
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product1', loadingGroupList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product2', loadingGroupList.get(0).id, false)); 
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product3', loadingGroupList.get(1).id, false)); 
        Product2 testProd =TestUtility.createProduct('Test Product4',false);
        testProd.FormerIpOwner__c = 'IHS Markit Global Inc.';
		testProd.Family__c = testProdFam.Id;
		testProd.ProfitCenters__c = testProfitCenter.Id;
        productList.add(testProd);
        Product2 p1 = TestUtility.createProduct('Test SubProduct 1', false);
        p1.AAG__c = 'Subscription';
        p1.Division__c = 'Financial Svcs-Info';
        productList.add(p1);       
        insert productList;       
        
        Id standardId = Test.getStandardPricebookId();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(0).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(1).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(2).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(3).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, p1.id, false));
        insert pbeList;
        
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(2223.23, '2017', '3 Years', '2017', testProd.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2323.23, '2017', '3 Years', '2018', testProd.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2423.23, '2017', '3 Years', '2019', testProd.Id, false);
        //insert product schedule for 2018 financial year
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2223.23, '2018', '3 Years', '2018', testProd.Id, false);
        ProductSchedule__c ps5 = TestUtility.createProductSchedule(2323.23, '2018', '3 Years', '2019', testProd.Id, false);
        ProductSchedule__c ps6 = TestUtility.createProductSchedule(2423.23, '2018', '3 Years', '2020', testProd.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4,ps5,ps6};
        
        List<Account> lstAccount = new List<Account>();
        Account testAccount = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        testAccount.GlobalAccountManager__c = testUser1.id;
        lstAccount.add(testAccount);
        
        Account testAccount1 = TestUtility.createTestAccount('Account test2', false);
        testAccount1.DataGovernanceStatus__c = 'Approved';
        testAccount1.GlobalAccountManager__c = testUser1.id;
        lstAccount.add(testAccount1);
        insert lstAccount;
        
		//create contract
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkitsfdc3186@testihsmarkit.com',true, 'TestSFDC3186', 'Contact');
        
        //create New Business oppty
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Id innerYearRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inner Year').getRecordTypeId();
        
        List<Opportunity> lstOpportunity = new List<Opportunity>();
        Opportunity testOpp1 = TestUtility.createOpportunity(testAccount.Id, 'test Opppy 3186', false);
        testOpp1.ContractStartDate__c = System.today();
        testOpp1.ContractEndDate__c = System.today() + 365;
        testOpp1.ActivityCreated__c = true;
        testOpp1.CloseDate = System.today() + 180;
        testOpp1.StageName= '1-Sales Qualified';
        testOpp1.RecordTypeId = devRecordTypeId;
        testOpp1.BudgetRange__c = '25,000-50,000';
        testOpp1.Amount = 123;        
        lstOpportunity.add(testOpp1);
        
        Opportunity testOpportunityClosedate = TestUtility.createOpportunity(testAccount.Id, 'test Opppy CloseDate', false);
		testOpportunityClosedate.closeDate = date.newinstance(2017, 11, 11);
        lstOpportunity.add(testOpportunityClosedate);
        
        Opportunity testOpp2 = TestUtility.createOpportunity(testAccount.Id, 'test Opppy NewBus', false);
        testOpp2.ContractStartDate__c = System.today();
        testOpp2.ContractEndDate__c = System.today() + 365;
        testOpp2.ActivityCreated__c = true;
        testOpp2.CloseDate = System.today() + 180;
        testOpp2.StageName= '1-Sales Qualified';
        testOpp2.RecordTypeId = devRecordTypeId;
        testOpp2.BudgetRange__c = '25,000-50,000';
        testOpp2.Amount = 123;
        lstOpportunity.add(testOpp2);
        
        Opportunity testInnerOpp = TestUtility.createOpportunity(testAccount.Id, 'Test Inner Opp', false);
        testInnerOpp.StageName= '3-Renewal Pending';
        testInnerOpp.RecordTypeId = innerYearRecordTypeId;
        testInnerOpp.CloseDate = System.today()+2;
        testInnerOpp.SourceSystem__c = 'Manually Generated';
        lstOpportunity.add(testInnerOpp);
        insert lstOpportunity;       
                
        Test.startTest();
        SalesIncentiveApproval__c sia = TestUtility.insertSalesIncentiveApproval(testOpp1.Id, 'Approved', true);
        
        RenewalatRisk__c renewalRisk = TestUtility.insertRenewalRisk(testOpp1.Id, testAccount.id, true);		
               
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpp1.Id, ContactId = testContact.Id, IsPrimary=true,role='Decision Maker');
        insert ocr;
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        
        Country__c country = lstCountry.get(0);
        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        
        List<Contract> lstContract = new List<Contract>();
        Contract testContract = TestUtility.createContractWithInsertOptional(testAccount.id, legalEntity.id,
                                                                        country.id,standardId,false);
		testContract.RecordTypeId = orderFormRecordTypeId;
        testContract.AccountId = testAccount.id;
        testContract.AutoRenewal__c = true;
        testContract.Opportunity__c = testOpp1.Id;
        testContract.Fastrack__c = true;
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.PriceIncreaseClause__c ='No Increase Allowed';
        testContract.CurrencyIsoCode = 'USD';
        testContract.StartDate = System.today();
        testContract.Pricebook2Id = standardId;
        testContract.ContractTerm = 10;
        testContract.Status = 'Creation';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';        
        lstContract.add(testContract);
        
        Contract testContractConsult = TestUtility.createContractWithInsertOptional(testAccount.id, legalEntity.id,
                                                                        country.id,standardId,false);
		testContractConsult.RecordTypeId = consultingRecordTypeId;
        testContractConsult.AccountId = testAccount.id;
        testContractConsult.AutoRenewal__c = true;
        testContractConsult.Opportunity__c = testOpp1.Id;
        testContractConsult.Fastrack__c = true;
        testContractConsult.NoInternalApprovalNeeded__c = true;
        testContractConsult.PriceIncreaseClause__c ='No Increase Allowed';
        testContractConsult.CurrencyIsoCode = 'USD';
        testContractConsult.StartDate = System.today();
        testContractConsult.Pricebook2Id = standardId;
        testContractConsult.ContractTerm = 10;
        testContractConsult.Status = 'Creation';
        testContractConsult.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
		testContractConsult.RenewalDate__c = System.today()+20;
		testContractConsult.RenewalTerm__c ='One-time Expiring';        
        lstContract.add(testContractConsult);
        insert lstContract;       
        
        TestUtility.createContractAttachment(testContract.Id);
        
        List<Opportunity> lstRenewalOppy = new List<Opportunity>();
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Renewal Opppy', false);
        testOpportunity.StageName= '3-Renewal Pending';
        testOpportunity.RecordTypeId = renewalRecordTypeId;
        testOpportunity.AutoRenewal__c = true;
        testOpportunity.DoesThisAutoRenewalHaveChanges__c = true;
        testOpportunity.ReadyForProcessingContractExist__c = true;
        testOpportunity.CloseDate = System.today()+2;
        testOpportunity.ContractId = testContract.Id;
        testOpportunity.ActivityCreated__c = true;
		lstRenewalOppy.add(testOpportunity); 
        Opportunity testOpportunity2 = TestUtility.createOpportunity(testAccount.Id, 'test Renewal Opppy1', false);
        testOpportunity2.StageName= '3-Renewal Pending';
        testOpportunity2.RecordTypeId = renewalRecordTypeId;
        testOpportunity2.CloseDate = System.today()+2;
        testOpportunity2.AutoRenewal__c = true;        
        testOpportunity2.SourceSystem__c = 'Manually Generated';
        testOpportunity2.DoesThisAutoRenewalHaveChanges__c = false;
        testOpportunity2.Amount = 123;
        lstRenewalOppy.add(testOpportunity2); 
        insert lstRenewalOppy;
        
       // List<OpportunityLineItem> testOliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem opp1testOLI1 = TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList[0], false); 
        opp1testOLI1.Product2Id = p1.Id;
        oliList.add(opp1testOLI1);
        oliList.add(TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList.get(0), false));
        oliList[0].Status__c='New';
        oliList[0].Probability__c=40;
        oliList.add(TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList.get(1), false));
        oliList[1].Status__c='Existing';
        oliList[1].Probability__c=20;
        oliList.add(TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList.get(2), false));        
        oliList[2].Status__c='New';
        oliList.add(TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList.get(4), false));
        oliList[3].Status__c='New';
        oliList.add(TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList.get(4), false));
        oliList[4].Status__c='New';
        oliList.add(TestUtility.createOpportunityLineItem(testOpp1.Id, pbeList.get(4), false)); //For trial contract type coverage against Calgary Group
        oliList[5].Status__c='New';        
        OpportunityLineItem opp1testOLI2 = TestUtility.createOpportunityLineItem(testOpportunityClosedate.Id, pbeList[3], false);
        oliList.add(opp1testOLI2);
        OpportunityLineItem opptestOLI3 = TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList[0], false);
        oliList.add(opptestOLI3);        
        insert oliList;
        
        List<OpportunityContactRole> lstOppyContactRole = new List<OpportunityContactRole>();
        OpportunityContactRole ocr1 = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id, IsPrimary=true,role='Decision Maker');
        lstOppyContactRole.add(ocr1);
        OpportunityContactRole ocr2 = new OpportunityContactRole(OpportunityId = testOpportunity2.Id, ContactId = testContact.Id, IsPrimary=true,role='Decision Maker');
        lstOppyContactRole.add(ocr2);
        insert lstOppyContactRole;
        
        Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Campaign').getRecordTypeId();
        Campaign Camp = TestUtility.createCampaign('Test',campaignRecordTypeId,false);
        insert Camp;
        
        TriageCriteria__c testTriage = TestUtility.createTriage(loadingGroupList.get(0).id,false);
        insert testTriage;
        
        CaseTriageExecutionOrder__c testCaseTriageExecOrder = TestUtility.createCaseTriageExecOrder(false);
        insert testCaseTriageExecOrder;
        
        System.debug('=====limits.getQueries() in test setup StartTest===' + limits.getQueries());
       	Test.stopTest();
        System.debug('=====limits.getQueries() in test setup after StartTest===' + limits.getQueries());
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateGAMOnOpportunityTeam on insert
    // @return: NA
    //-----------------------------
    @isTest private static void testUpdateGAMOnOpportunityTeamonInsert() {
        Opportunity opp = [Select Id,GAM__c from opportunity where name='test Opppy 3186' LIMIT 1];
        OpportunityTeamMember otm = new OpportunityTeamMember(); 
        otm =[Select id, name, userId from OpportunityTeamMember where OpportunityId=:opp.id and TeamMemberRole = 'Account Owner' limit 1];       
        System.assertEquals(opp.GAM__c, otm.userId,'Validating user.'); 
    }   
      
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateGAMOnOpportunityTeam on update
    // @return: NA
    //-----------------------------
    @isTest private static void testUpdateGAMOnOpportunityTeamOnUpdate1() {            
        User u = [Select id from User where profile.name='System Administrator' LIMIT 1];
        Opportunity opp = [Select Id,GAM__c from opportunity where name='test Opppy 3186' LIMIT 1];
        opp.GAM__c = u.id;
        update opp;
        System.assertEquals(opp.GAM__c, u.id,'Validating user.'); 
        
        OpportunityTeamMember otm = new OpportunityTeamMember(); 
        otm =[Select id, name, userId from OpportunityTeamMember where OpportunityId=:opp.id and TeamMemberRole = 'Account Owner' limit 1];
        System.assertEquals(opp.GAM__c, otm.userId,'Validating user.' );      
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateGAMOnOpportunityTeam on update
    // @return: NA
    //-----------------------------
    @isTest private static void testUpdateGAMOnOpportunityTeamOnUpdate2() {      
      
         List<User> u =[select id from User where profile.name='System Administrator'];               
        test.startTest();
        Opportunity opp = [Select Id,GAM__c from opportunity where name ='test Opppy 3186' LIMIT 1];
        opp.GAM__c = u[0].id;  
        update opp; 
        System.assertEquals(opp.GAM__c, u[0].id,'Validating user.'); 
        
        OpportunityTeamMember otm = new OpportunityTeamMember(); 
        otm =[Select id, name, userId from OpportunityTeamMember where OpportunityId=:opp.id and TeamMemberRole = 'Account Owner' limit 1];
        System.assertEquals(opp.GAM__c, otm.userId,'Validating user.' ); 
        
        opp.GAM__c = u[1].id;  
        update opp; 
        
        OpportunityTeamMember otm1 = new OpportunityTeamMember(); 
        otm1 =[Select id, name, userId from OpportunityTeamMember where OpportunityId=:opp.id and TeamMemberRole = 'Account Owner' limit 1];
        test.stopTest();
        System.assertEquals(opp.GAM__c, otm1.userId,'Validating user.' );  
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateGAMOnOpportunityTeam on update
    // @return: NA
    //-----------------------------
    @isTest private static void testCheckPrimaryContactOnNewBusinessOpportunityForSysAdmin() {
        
        test.startTest();
        Account a =[Select Id from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];
        Opportunity opp = [Select Id,StageName,LossReason__c,LostReasonCode__c,LostReasonDescription__c
                           from opportunity where name ='test Opppy 3186' LIMIT 1];        
       try{
           opp.StageName= '2-Sales Qualified';
           update opp; 
        }
        catch(Exception e){
            system.assertEquals('System.DmlException', e.getTypeName(),e.getMessage());
        }
        opp.StageName= '6L-Closed Lost';
        opp.LossReason__c = 'Price';
        opp.LostReasonCode__c='Unfavorable Pricing';
        opp.LostReasonDescription__c='Unfavorable Pricing';
        update opp;
        test.stopTest();
        System.assert(opp.Id!=null,'opp created.');
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateGAMOnOpportunityTeam on update
    // @return: NA
    // @update author : Mohit Modi
    // @Description : update the Test Class for updated logic
    //-----------------------------
    @isTest private static void testCheckPrimaryContactOnNewBusinessOpportunityForStandardUser() {       
        Test.Starttest();
        Account a = [Select id from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];
        Contact c = [Select id from Contact where lastname='Contact' LIMIT 1];                    
        // Mohit : 13 Nov 2017 : Moved Query to Like Query as it is failing with Name of the Profile.   
        Profile p = [SELECT Id ,name FROM Profile WHERE Name like '%Global Account Manager%' limit 1];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert u;        
        System.runAs(u) {
            Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
            Opportunity opp = new Opportunity();
            opp.AccountId = a.Id;
            opp.Name = 'Test Opp786';
            opp.StageName= '1-Sales Qualified';
            opp.RecordTypeId = devRecordTypeId;
            opp.CloseDate = System.today()+2;
            opp.Amount = 123;
            opp.BudgetRange__c='25,000-50,000';
            insert opp;            
            
            try {
                opp.StageName= '2-Need Confirmed';
                update opp;
            }catch(Exception e) {
                 system.debug('exception: '+e.getMessage());
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.OpportunityPrimaryContactValidationError) ? true : false;
                // Assert to check correct Error is thrown
               
                System.AssertEquals(expectedExceptionThrown, true,'validating exception');
            }
            
            //Inserting Contact and opportunity contact Role
            //insert c;
            
            OpportunityContactRole oppContactRole = new OpportunityContactRole();
            oppContactRole.OpportunityID = opp.id;
            oppContactRole.ContactId = c.id;
            oppContactRole.IsPrimary = true;
            insert oppContactRole;
            
            try{
                opp.StageName= '2-Need Confirmed';
                update opp;
            }catch(Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains('Primary Contact needs an email address') ? true : false;
                // Assert to check correct Error is thrown
                System.AssertEquals(expectedExceptionThrown, true,'validating exception');
            }
            
            opp.StageName= '6L-Closed Lost';
            opp.LossReason__c = 'Price';
            opp.LostReasonCode__c='Unfavorable Pricing';
            opp.LostReasonDescription__c='Unfavorable Pricing';
            update opp;
            // Assert to check the Stage Name Should be updated
            System.assertEquals('6L-Closed Lost', [select id,StageName from Opportunity where id = :opp.id].StageName, 'Opp state updated.');
            Test.Stoptest();
        }
           
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 04 Jan 2019
    // @param: NA
    // @description: SFDC1-10744 Test method for OpportunityMethod.checkUserProfileBeforeDelete
    //-----------------------------
    @isTest private static void testCheckUserProfileBeforeDelete() {
        Test.StartTest();
        
        
        Profile salesCoordinatorProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Sales Coordinator%' LIMIT 1];
        
        User salesCoordinator = new User(FirstName='Sales', LastName='Coordinator', Email='salesCoordinator@ihsmarkit.com', Alias = 'salesCd',
                                         ProfileId = salesCoordinatorProfile.Id, HRManager__c='manager', EmailEncodingKey ='UTF-8', 
                                         LocaleSidKey = 'en_US', LanguageLocaleKey='en_US', TimeZoneSidKey = 'America/Los_Angeles',
                                         UserName = 'salesCoordinator@ihsmarkit.com', ADID__c = 'test'+system.now().millisecond(),
                                         EmployeeNumber = String.valueOf(Math.round(Math.random()*10000)),
                                         EmployeeNumber__c = String.valueOf(Math.round(Math.random()*10000)));
        insert salesCoordinator;
        
        //Opportunity opp = new Opportunity();
        Opportunity opp = [Select Id from Opportunity where name ='test Opppy 3186' LIMIT 1];
        System.runAs(salesCoordinator) {            
            try {
                delete opp;
            } catch (Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.OpportunityDeleteDenial) ? true : false;
                // Assert to check correct Error is thrown for salesCoordinatorProfile
                System.AssertEquals(expectedExceptionThrown, true,'validating exception');
            }
        }
        
        User sysAdminUser = [Select id from User where profile.name LIKE '%System Admin%' and isactive=true LIMIT 1];
        System.runAs(sysAdminUser) {
            try {
                delete opp;
                // trying to retrieve the Opportunity record above
                opp = [SELECT Id, Name FROM Opportunity WHERE Id =: opp.Id];
                System.assert(opp == null,'opp is deleted.');
            } catch (Exception e) {
                // do nothing, unit test will fail if reach this line
                system.assertEquals(true, e.getMessage() != NULL, e.getMessage());
            }
        }

        Test.Stoptest();
    }
    
    /**
     * @author Paras Dhingra
     * @date 31st July 2017
     * @description SFDC1-382 test class for OpportunityMethods.ChangeAccountOwnershipOnInsertUpdate
     * @param NA
     * @return void
     * @companyname IHS Markit
     */
     
    @isTest static void testChangeAccountOwnershipOnInsertUpdate() {         
         
          //create test data
         Account testAccount = TestUtility.createTestAccount('testAccount', false);
         testAccount.DataGovernanceStatus__c = 'Approved';
         insert testAccount;
         
         User testUser1 = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUser1.testChangeAccountOwnershipOnInsertUpdate@ihsmarkit.com',true);
         User testUser2 = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUser2.testChangeAccountOwnershipOnInsertUpdate2@ihsmarkit.com',true);
         Opportunity testOpportunityTestUser1 = TestUtility.createOpportunity(testAccount.Id,'first test Oppy', false);
         testOpportunityTestUser1.ownerId = testUser1.Id;
         testOpportunityTestUser1.FirstYearValue__c = 10000;
         System.runAs(new User(id=Userinfo.getUserId())) {
            insert testOpportunityTestUser1;
         }
         //Now start test
         Test.startTest();
         System.runAs(testUser1) {
             
             //create an Opportunity
             Opportunity testOpportunity1 = TestUtility.createOpportunity(testAccount.Id,'first test Oppy', false);
             testOpportunity1.FirstYearValue__c = 1000;
             insert testOpportunity1;
             // assert Account owner
             Account assertAccount1 = [Select id, OwnerId from Account where Id=:testAccount.Id];
             System.assertEquals(testUser1.Id, assertAccount1.OwnerId, 'Comparing Owner Id for Account and Opportunity');
         }
         System.runAs(testUser2) {
             //create an Opportunity
             Opportunity testOpportunity2 = TestUtility.createOpportunity(testAccount.Id,'second test Oppy', false);
             //Open opportunity of greater amount
             testOpportunity2.FirstYearValue__c = 1000;
             insert testOpportunity2;
             // assert Account owner
             Account assertAccount1 = [Select id, OwnerId from Account where Id=:testAccount.Id];
             System.assertNotEquals(testUser2.Id, assertAccount1.OwnerId, 'Comparing Owner Id for Account and Opportunity. This should not match');
             //now increase the amount so that total first year value of the oppy increases and testuser2 becomes the owner
             Opportunity testOpportunity3 = TestUtility.createOpportunity(testAccount.Id,'third test Oppy', false);
             //Open opportunity of greater amount
             testOpportunity3.FirstYearValue__c = 900000;
             insert testOpportunity3;
             Account assertAccount2 = [Select id, OwnerId from Account where Id=:testAccount.Id];
             System.assertEquals(testUser2.Id, assertAccount2.OwnerId, 'Comparing Owner Id for Account and Opportunity. This should match');
			 
			 //check if opportunity is lost
             testOpportunity3.LostReasonCode__c = 'Non Payment';
             testOpportunity3.LostReasonDescription__c = 'Bid too high';
             testOpportunity3.StageName = '6L-Closed Lost';
             update testOpportunity3;
             Account assertAccount3 = [Select id, OwnerId from Account where Id=:testAccount.Id];
             System.assertEquals(testUser1.Id, assertAccount3.OwnerId, 'Comparing Owner Id for Account and Opportunity. This should match');
         }

         Test.stopTest();
     }
    
     /**
     * @author Paras Dhingra
     * @date 3rd Aug 2017
     * @description SFDC1-775 test class for OpportunityMethods.updateAccountRelationship
     * @param NA
     * @return void
     * @companyname IHS Markit
     * @lastmodifiedSprint : Sprint 9
     * @lastmodifiedBy : Prachi for SFDC1-1154 validation rule
     * @lastmodified description: Primary Contact roles needs to be created before updating opprtunity to stage 3 and above as per  SFDC1-5782 AND SFDC1-5029
     * @modifiedBy: Ankita Singh on 5th December,2017
     */
    @isTest static void testUpdateAccountRelationship() { 
       Account  testAccount = [Select Id,AccountCountry__c from Account Where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1]; 
        Contract testContract = [Select Id,ContractStatus__c,OrderReason__c,BillingFrequency__c from Contract where accountId =: testAccount.id LIMIT 1];
        Opportunity testOpportunity = [Select Id,StageName,ContractStartDate__c,
                                       ContractEndDate__c,ActivityCreated__c,ReadyForProcessingContractExist__c from Opportunity where name='test Opppy 3186' LIMIT 1]; 
        Test.startTest();      
        OpportunityLineItem testOLI = [Select Id from OpportunityLineItem where OpportunityId=:testOpportunity.id LIMIT 1];
        
        Contact testContact = [Select id from Contact where lastname='Contact' LIMIT 1];              
        testOpportunity.StageName = '6W-Closed Won';
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.ContractEndDate__c = System.today()+385;
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.ReadyForProcessingContractExist__c = true;
        GlobalVariables.preventRecursiveExecution = true;  
        update testOpportunity;
        
        Account assertAccount = [Select Id,Relationship__c from Account where Id =:testAccount.Id];
        //system.debug('relationship : '+assertAccount.Relationship__c);
        System.assertEquals('Customer', assertAccount.Relationship__c,'Account relationship updated to Customer');
        
        testContract.ContractStatus__c = 'Validated';
        testContract.OrderReason__c = 'Rebates';
        testContract.BillingFrequency__c = 'Annual';
        update testContract;                       
        Test.stopTest(); 
    }
    
    /**
      * @author Prachi Bhasin
      * @date 8th Sept 2017
      * @description SFDC1-1990 test class for OpportunityMethods.populateExternalSourceSystemOnOpportunity
      * @param TriggerParameters
      * @return void
      * @companyname Vertiba
      */
      @isTest static void testPopulateExternalSourceSystemOnOpportunity() {
         //create test data
        
        Test.startTest();
        
        Account testAccount = TestUtility.createTestAccount('testAccount1234', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;		 
        Account assertAccount = [Select Id,Relationship__c from Account where Id =:testAccount.Id];
        System.assertEquals('Prospect', assertAccount.Relationship__c,'Checking relationship on account creation');
        
        //create related opportunity and close it
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy786', true);
        //OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
        update testOpportunity;        
        Opportunity oppCloned = testOpportunity.clone(false, true, false, false);
        insert oppCloned;
        String oppSource = [select id,SourceSystem__c from opportunity where id=: oppCloned .id limit 1].SourceSystem__c;
        System.assertEquals('Clone',oppSource ,'Checking cloned opportunity');
        Test.stopTest();
     }
    
    
    
    //-----------------------------
    // @author: Sonam Raju
    // @date: 15 December 2017
    // @param: NA
    // @description: Test method for Opportunity trigger method checkChannelManagerRoleonOpptyTeamforStage2andhigher on update
    // @return: NA
    // @Modified by: Jagadesh Kumar
    // @Modified Date: 05 Dec 2018
    // @Description: SFDC1-9382 Create new IHSMarkit account and Run it as new user to avoid MIXED DML exception.
    //-----------------------------
    @isTest private static void testcheckChannelManagerRoleonOpptyTeamforStage2andhigher() {
        User SysAdmin;
        User SysAdmin1 = TestUtility.createAdminUser('satest123@satest.com',true);
        System.runAs(SysAdmin1) {
        	Account a = TestUtility.createTestAccount(System.Label.NewUserContactAccount, false);
            a.type = System.Label.NewUserContactAccountType;
            insert a;    
            //Create System Administrator with Role assigned
            UserRole AdminRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            SysAdmin = TestUtility.createAdminUser('satest@satest.com',false);
            SysAdmin.UserRoleId = AdminRole.id;
            insert SysAdmin;
        }
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
       
        system.runas(SysAdmin) {
            //Create account
            Account portalAccount1 = TestUtility.createTestAccount('Account testPartnerAccountforOpptyTeamMemberCheck', false);
            portalAccount1.DataGovernanceStatus__c = 'Approved';
            //SFDC1-10675:Change value from "Global Alliance" to "Channel Partner".
            portalAccount1.Type ='Channel Partner';
            portalAccount1.AccountSubType__c ='Reseller';
            insert(portalAccount1);
                    
            //Create portal enabled contacts
            Contact portalcontact1 = TestUtility.createContact(portalAccount1.id,'test123@test.com',true,'Test','Test123');
            Contact portalcontact2 = TestUtility.createContact(portalAccount1.id,'test567@test.com',true,'Test','Test567');
            
            //Create portal user with portal user profile
            User testUser1 = TestUtility.createTestUser('IHS Markit: Channel Partner User', 'testUser.testportaluser1@abc.com.user',false);
            testUser1.ContactId = portalcontact1.Id;
            insert testUser1;
            
            //Create Standard user
            User testUser2 = TestUtility.createTestUser('Standard User', 'testUser.test987@abc.com.user',true);
            
            //Create Account for Opportunity and move ownership to portal user
            Account testaccount = TestUtility.createTestAccount('Account testAccountforOpportunity', false);
            testaccount.DataGovernanceStatus__c = 'Approved';
            //SFDC1-10675:Change value from "Global Alliance" to "Channel Partner".
            testaccount.Type ='Channel Partner';
            testaccount.AccountSubType__c ='Reseller';
            insert testaccount;
            
            testaccount.ownerid = testUser1.id;
            update testaccount;
			Test.startTest();	
            //Create Opportunity with portal user as owner
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.StageName= '1-Sales Qualified';
            opp.RecordTypeId = devRecordTypeId;
            opp.CloseDate = System.today()+2;
            opp.Amount = 123;
            opp.AccountId = testaccount.id;
            opp.Subtype__c = 'Global Alliance';
            opp.ChannelPartner__c=portalAccount1.id ;
            opp.ownerId = testUser1.id;
            insert opp;
            
            //Create Opportunity Contact Role on Opportnity
            OpportunityContactRole oppContactRole = new OpportunityContactRole();
            oppContactRole.OpportunityID = opp.id;
            oppContactRole.ContactId = portalcontact1.id;
            oppContactRole.IsPrimary = true;
            insert oppContactRole;
            
            //Add Opportunity Member with Role other than Channel Manager
            OpportunityTeamMember otm = TestUtility.createOpportunityTeamMember(opp.id,testUser2.id,'Edit', true);
            otm.TeamMemberRole ='Account Manager';
            insert otm;
            
            
            try {
                opp.StageName= '2-Need Confirmed';
                update opp;
            }
            catch(Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.OpptyChannelPartnerError) ? true : false;
                // Assert to check correct Error is thrown
                System.AssertEquals(expectedExceptionThrown, true,'validating exception.');
            }
                    
            //Adding Opportunity Member with Channel Manager Role           
            OpportunityTeamMember otm2 = TestUtility.createOpportunityTeamMember(opp.id,testUser1.id,'Edit', true);
            otm2.TeamMemberRole ='Channel Manager';
            insert otm2;
            
            opp.StageName= '2-Need Confirmed';
            update opp;
            System.AssertEquals('2-Need Confirmed', opp.StageName,'validating exception.');
            Test.stopTest();
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////
    //@author: Paras Dhingra                                                            //
    //@date: 09th Jan 2018                                                             //
    //@description: SFDC1-4723 This method test                                       //
    //              the method OpportunityMethod.updateOpportunitySplitOnGamChange   //
    //@companyName: IHS Markit                                                      //
    /////////////////////////////////////////////////////////////////////////////////
    @isTest private static void testUpdateOpportunitySplitOnGamChange() {       
        
        User testUser2 = [Select id from User where Email ='testUser2email@test.com.ihsmarkit.test' LIMIT 1 ];
        Account testAccount = [Select id,GlobalAccountManager__c from Account where name ='Account testSetCaseAdditionalFieldsObject' LIMIT 1];                  
        Opportunity opp = [Select id,ContractStartDate__c,ContractEndDate__c from Opportunity where name='test Opppy 3186' and accountid =: testAccount.id LIMIT 1];
        Test.startTest();
        //Assert Opportunity for existing split in overlay
        List<OpportunitySplit> assertOppySplit = [Select Id, SplitPercentage,SplitType.DeveloperName, SplitOwnerId
                                            from OpportunitySplit where opportunityId=:opp.Id AND SplitOwnerId=:testAccount.GlobalAccountManager__c];
        System.assertEquals(1,assertOppySplit.size(),'Check Overlay opportunity split count');
        System.assertEquals('Overlay',assertOppySplit[0].SplitType.DeveloperName, 'Check overlay type');
        //change GAM
        testAccount.GlobalAccountManager__c = testUser2.Id;
        update testAccount;
        Test.stopTest();
        //assert Oppy SPlit
        assertOppySplit = [Select Id, SplitPercentage,SplitType.DeveloperName, SplitOwnerId
                                            from OpportunitySplit where opportunityId=:opp.Id AND SplitOwnerId=:testUser2.Id];
        System.assertEquals(1,assertOppySplit.size(),'Check Overlay opportunity split count');
        System.assertEquals('Overlay',assertOppySplit[0].SplitType.DeveloperName, 'Check overlay type');
        
    }
    
    /**
     * @author : Sruti Srivastava
     * @date : 9th April 2018
     * @description SFDC1-7027- Test method for verifying Contract Start Date and End Date on Opportunity Line Items if 'ContractStartDate__c' and 'ContractEndDate__c' field on Opportunity are updated 
     * @lastmodifiedSprint : Sprint 23
     */
    @isTest static void testUpdateContractStartDateAndEndDateOnOpportunityLineItem() { 
		 
        Opportunity testOpportunity = [Select id,ContractStartDate__c,ContractEndDate__c from Opportunity where name='test Opppy 3186' LIMIT 1]; 
        OpportunityLineItem testOLI = [select id,ContractStartDate__c ,ContractEndDate__c from OpportunityLineItem where OpportunityId =: testOpportunity.id LIMIT 1];
        Test.startTest();
		
        testOpportunity.ContractStartDate__c = Date.Today().addDays(-30);
		testOpportunity.ContractEndDate__c = Date.Today().addDays(30);
		update testOpportunity;
        Test.stopTest();
        //Verifying if Contract start Date and End date are correctly populated from opportunity
		System.assertEquals(testOpportunity.ContractStartDate__c, [Select ContractStartDate__c From OpportunityLineItem where Id= :testOLI.Id limit 1].ContractStartDate__c,'Checking if ContractStartDate__c on OLI is correctly populated');
		System.assertEquals(testOpportunity.ContractEndDate__c, [Select ContractEndDate__c From OpportunityLineItem where Id= :testOLI.Id limit 1].ContractEndDate__c,'Checking if ContractEndDate__c on OLI is correctly populated');
	}
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 8 May 2019
    // @param: TriggerParameters
    // @description: SFDC-177 Test method for Contract Continuation End Date
    // @return: None
    //------------------------------
    @isTest private static void testUpdateContractContinuationEndDate() { 
        test.startTest();
        Account  testAccount = [Select Id,AccountCountry__c from Account Where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1]; 
        Contract testContract = [Select Id,ContinuationEndDate__c from Contract where accountId =: testAccount.id LIMIT 1];        
		Opportunity opp1 = [select id,ContinuationEndDate__c from Opportunity where name='test Renewal Opppy' LIMIT 1];
        opp1.ContinuationEndDate__c = System.Today() + 61;
        update opp1;
        // Contract's ContinuationEndDate__c should stays at the same value (opp2.ContinuationEndDate__c) since opp1.ContinuationEndDate__c is a prior date
        system.assertNotEquals(opp1.ContinuationEndDate__c, [select ContinuationEndDate__c from Contract where Id=: testContract.Id].ContinuationEndDate__c,'Opp & contract date validation.');		
        test.stopTest();
    }
    
    //-----------------------------
	/**
     * @author: Tran-Vu Tran
     * @date: 12 February 2019
     * @description: SFDC-660 add test logic for "Opportunity Stage" value from Opportunity
	*/
    @isTest static void testUpdateOpportunityLineItemOpportunityStage() { 
         Test.startTest();         
        Opportunity testOpportunity =[Select id,StageName from Opportunity where name='test Opppy 3186' LIMIT 1];        
         testOpportunity.StageName = '2-Need Confirmed';
         update testOpportunity;
         
         //Verifying if StageName gets correctly updated from opportunity
         OpportunityLineItem testOLI = [Select OpportunityStage__c From OpportunityLineItem where opportunityId= :testOpportunity.Id limit 1];
         System.assertEquals(testOpportunity.StageName, testOLI.OpportunityStage__c, 'Checking if OpportunityStage__c on OLI is correctly updated');
         Test.stopTest();
	}
    
    /**
    * @author Tran-Vu Tran
    * @date 12 Feb 2019
    * @description SFDC1-132 test class for OpportunityMethods.populateOpportunityCountryFromAccount
    * @param NA
    * @return void
    * @companyname IHS Markit
    */
    @isTest static void testPopulateOpportunityCountryFromAccount() {
        Test.startTest();        
        Account  testAccount = [Select Id,AccountCountry__c from Account Where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1]; 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt', Email='standarduser1@ihsmarkit.com', EmailEncodingKey='UTF-8',
                           ProfileId = p.Id, FirstName='Test', LastName='User1', HRManager__c='manager',
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', 
                           UserName='Test.User1@ihsmarkit.com', ADID__c='test1'+system.now().millisecond(),
                           EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),
                           EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000))
                          );
        insert u1;
        //System.debug('testPopulateOpportunityCountryFromAccount --- user 1: ' + u1);
        Country__c country = [Select Id from Country__c LIMIT 1];
        Opportunity testOpportunity = [Select Id,GAM__c,OpportunityCountry__c from Opportunity where name='test Opppy 3186' LIMIT 1 ];
        System.assertEquals(testOpportunity.OpportunityCountry__c, testAccount.AccountCountry__c,
                            'Checking if OpportunityCountry__c is populated correctly when created');
        testOpportunity.GAM__c = u1.Id;
        testOpportunity.OpportunityCountry__c = country.Id;
        update testOpportunity;
        
        System.assertEquals(testOpportunity.OpportunityCountry__c, country.Id,
                            'Checking if OpportunityCountry__c is updated to the new country');
        
        User u2 = new User(Alias = 'standt', Email='standarduser2@ihsmarkit.com', EmailEncodingKey='UTF-8',
                           ProfileId = p.Id, FirstName='Test', LastName='User2', HRManager__c='manager',
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles', 
                           UserName='Test.User2@ihsmarkit.com', ADID__c='test2'+system.now().millisecond(),
                           EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),
                           EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000))
                          );
        insert u2;
        System.debug('testPopulateOpportunityCountryFromAccount --- user 2: ' + u2);
        
        testOpportunity.GAM__c = u2.Id;
        update testOpportunity;
        
        //Verifying if OpportunityCountry__c gets reset from AccountCountry__c when Opportunity's Account Manager changes
        testOpportunity = [select Id, OpportunityCountry__c From Opportunity where Id= :testOpportunity.Id limit 1];
        System.debug('testPopulateOpportunityCountryFromAccount --- testOpportunity after updating GAM__c: ' + testOpportunity);
        System.assertEquals(testOpportunity.OpportunityCountry__c, testAccount.AccountCountry__c,
                            'Checking if OpportunityCountry__c gets reset from AccountCountry__c when Account Manager changes');
        Test.stopTest();
    }
    
    // @author: Anjani Shukla
    // @date: 09 Apr 2018
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateOpportunityRiskRecordStatus on update
    // @return: NA
    //-----------------------------
    @isTest private static void testupdateOpportunityRiskRecordStatus() {
        test.startTest();        
        Opportunity opp = [Select Id,GAM__c,StageName,LostReasonCode__c,LostReasonDescription__c from Opportunity where name='test Opppy 3186' LIMIT 1 ];
        opp.StageName = '6L-Closed Lost';
        opp.LostReasonCode__c = 'Unfavorable Pricing';
        opp.LostReasonDescription__c ='test';
        update opp;
        System.assertEquals(opp.StageName, '6L-Closed Lost','opp stage updated');      
        
        RenewalatRisk__c updatedRenewalRiskOpty = [select id,status__c,OpportunityAtRisk__c from RenewalatRisk__c where OpportunityAtRisk__c =: opp.id limit 1];
        
        system.assertEquals('Closed - Opportunity Lost',updatedRenewalRiskOpty.Status__c,'opp stage updated');
        test.stopTest();
        
    }
    
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 09 Apr 2018
    // @param: NA
    // @description: SFDC1-8392 : Update Account Manager on Opportunity when Account is updated.
    // @return: NA
    //-----------------------------
    @isTest private static void testupdateOpportunityGAM() {       
      
        List<Account> lstAccount = [Select Id,DataGovernanceStatus__c,GlobalAccountManager__c From Account where DataGovernanceStatus__c = 'Approved'];
        lstAccount[1].GlobalAccountManager__c = UserInfo.getUserId();    
        update lstAccount;
        test.startTest();
        
        Opportunity opp = [select id, AccountId from Opportunity where name='test Opppy 3186' LIMIT 1];      
        //update account on opportunity
        opp.AccountId = lstAccount[1].id;
        update opp;
        
        system.assertEquals(lstAccount[1].GlobalAccountManager__c,[select GAM__c from Opportunity where id =: opp.id].GAM__c,'validating user' );
        test.stopTest();
        
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 13 June 2018
    // @param: NA
    // @description: SFDC1-8434 :Test method for createOMCaseOnRenewalOpportunityClosure
    // @return: NA
    //-----------------------------
    @isTest private static void testCreateOMCaseOnRenewalOpportunityClosure() {       
        
        test.startTest();      
        Account testAccount = [Select Id from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];
        Contract testContract = [Select Id,ContractStatus__c from Contract where AccountId =: testAccount.id LIMIT 1];
        //testContract.ContractStatus__c = 'Scheduled Termination';
        //update testContract;
        List<Opportunity> oppList = [select id,StageName,PriceChangeOnly__c,PORequired__c,ContractBeingRenewed__c,recordtype.name, AccountId from Opportunity where name IN ('test Renewal Opppy1','Test Inner Opp')];
        List<Opportunity> oppUpdateList =new List<Opportunity>();
        for(Opportunity opp:oppList){
            if(opp.recordtype.name=='Inner Year'){                
                opp.PORequired__c = true;
            }
            opp.StageName = '6W-Renewal Won';
            opp.PriceChangeOnly__c = true;
            opp.ContractBeingRenewed__c = testContract.id;
            oppUpdateList.add(opp);
        }
        update oppUpdateList;    
               
        List<Case> lstOMCase = new List<case>([Select id,RecordType.Name from Case where Opportunity__c IN :oppUpdateList]);
        //system.debug('case size: '+ lstOMCase.size());
        System.assertEquals(2, lstOMCase.size(), 'OM cases are generated');        
        
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 13 June 2018
    // @param: NA
    // @description: SFDC1-8434 :Test method for createOMCaseOnRenewalOpportunityClosure
    // @return: NA
    //-----------------------------
    @isTest private static void testCreateOMCaseOnRenewalOpportunityClosureWithException() {       
        
        test.startTest();      
        Account testAccount = [Select Id from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];
        Contract testContract = [Select Id,ContractStatus__c from Contract where AccountId =: testAccount.id LIMIT 1];
        testContract.ContractStatus__c = 'Scheduled Termination';
        update testContract;
        List<Opportunity> oppList = [select id,StageName,PriceChangeOnly__c,PORequired__c,ContractBeingRenewed__c,recordtype.name, AccountId from Opportunity where name IN ('test Renewal Opppy1','Test Inner Opp')];
        List<Opportunity> oppUpdateList =new List<Opportunity>();
        for(Opportunity opp:oppList){
            if(opp.recordtype.name=='Inner Year'){                
                opp.PORequired__c = true;
            }
            opp.StageName = '6W-Renewal Won';
            opp.PriceChangeOnly__c = true;
            opp.ContractBeingRenewed__c = testContract.id;
            oppUpdateList.add(opp);
        }
        update oppUpdateList;    
               
        List<Case> lstOMCase = new List<case>([Select id,RecordType.Name from Case where Opportunity__c IN :oppUpdateList]);
        //system.debug('case size: '+ lstOMCase.size());
        System.assertNotEquals(2, lstOMCase.size(), 'OM cases not generated exception thrown');       
        
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Veriba
    // @company: VERTIBA
    // @date: 25 June 2018
    // @param: 
    // @description:  Test method to check if functionality is working.
    // @return: NA
    // @Modification : Updated code for new methods added for edit fucntionality.
    // @Modification date : Anjani Shukla:25 May 2018 - SFDC1-8147 - New Cross Plant Status Added.
    //-----------------------------
    @isTest public static void testupdateOpportunityProductRestriction() {
        test.startTest();       
        Opportunity testOpportunity = [select id, AccountId from Opportunity where name='test Opppy 3186' LIMIT 1];    
                
            List<String> lstforRecord = new List<String>();           
            WarningMsgProductCrossPlantStatus objWarnMsgProdCrossPlantStatus = new WarningMsgProductCrossPlantStatus();
            lstforRecord = WarningMsgProductCrossPlantStatus.getOptyProdLineDetails(testOpportunity.id);
            // WarningMsgProductCrossPlantStatus.errorMsgRecord = lstforRecord;
            system.assertEquals(0, lstforRecord.size(),'OLI is null.');
        
        // update stage.
        testOpportunity.StageName = '2-Need Confirmed'; update testOpportunity;
        lstforRecord = WarningMsgProductCrossPlantStatus.getOptyProdLineDetails(testOpportunity.id);
        // WarningMsgProductCrossPlantStatus.errorMsgRecord = lstforRecord;
        system.assertEquals(0, lstforRecord.size(),'OLI is not created.');  
        
        Test.stopTest();    
    }
    
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 28 jun 2018
    // @param: NA
    // @description: SFDC1-8243 :Test method for updateFiscalOnChangeOfCloseDate
    // @return: NA
    //-----------------------------
    @isTest private static void testupdateFiscalOnChangeOfCloseDate() {        
        Test.StartTest();
        Opportunity testOpportunity = [Select Id from opportunity where name ='test Opppy CloseDate' Limit 1];
        Product2 testProd = [Select Id from Product2 where FormerIpOwner__c = 'IHS Markit Global Inc.' LIMIT 1];
        PricebookEntry testPBE = [Select id,UnitPrice from PricebookEntry where IsActive=true and product2.name='Test Product4' limit 1];
        OpportunityLineItem testOLI = [select id from OpportunityLineItem where OpportunityId =: testOpportunity.id and PricebookEntryId =: testPBE.id LIMIT 1];
        List<ProductSchedule__c> lstProdSchedule = [Select ID,Product__r.name from ProductSchedule__c];        
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,lstProdSchedule[0].Id,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, testProd.Id, '2017', 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,lstProdSchedule[1].Id,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, testProd.Id, '2018', 1, 
                                                                                            testOLI.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOpportunity.Id,lstProdSchedule[2].Id,2323.23,2000,
                                                                                            'Amount', 423.23, 0.0, testProd.Id, '2019', 1, 
                                                                                            testOLI.Id,false);
        insert new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3};
        
        //updated closed date of opportunity and check if fiscal year of Oppy schedules is upated or not
        testOpportunity.closeDate = date.newinstance(2018, 6, 21);
        GlobalConstants.hasUpdatedProductSchedules=false;
        update testOpportunity;
        //assert that fiscal year is updated for Oppy schedules
        List<OpportunityLineItemSchedule__c> lstOppySchedules = [Select Id,ProductSchedule__c, ProductSchedule__r.PricingYear__c from OpportunityLineItemSchedule__c 
                                                                    where Opportunity__c=:testOpportunity.Id and ProductSchedule__r.PricingYear__c='2018'];
        //System.assertEquals(3, lstOppySchedules.size(),'Checking that fiscal year is changed');
        //System.assertEquals(0, lstOppySchedules.size(),'Checking that fiscal year is changed');
        Test.StopTest();
    }
    
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 28 jun 2018
    // @param: NA
    // @description: SFDC1-7059 - Test method for OpportunityValidations
    // @return: NA
    //-----------------------------
    @isTest private static void testOpportunityValidations() {        
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Integer nextFY = currentFY+1;        
		Opportunity testOpportunity = [Select Id,ContractStartDate__c, ContractEndDate__c,AutoRenewal__c,
                                       DoesThisAutoRenewalHaveChanges__c from opportunity where name='test Opppy 3186' LIMIT 1];
		
        
        Test.startTest();
        testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
		testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
		testOpportunity.AutoRenewal__c = true;
		testOpportunity.DoesThisAutoRenewalHaveChanges__c = false;
        update testOpportunity;
        OpportunityValidationFields__c ofv = new OpportunityValidationFields__c(Name='Opportunity Name',APIName__c='Name',RuleName__c='AutoRenewDoesNotHaveChanges');
        OpportunityValidationFields__c ofv2 = new OpportunityValidationFields__c(Name='Description',APIName__c='Description',RuleName__c='AutoRenewHasChanges');
        insert new List<OpportunityValidationFields__c>{ofv,ofv2};
        //create test user
        Profile p = [Select id,name from profile where name like '%Sales Coordinator%' limit 1];
        System.debug('@PD--profile query name--'+p.name);
        String username = 'testusera@testihsmarkit.com';
        User testUser = new User(Alias = 'standt', Email=username, 
                                  EmailEncodingKey='UTF-8', firstName='testFirstName', HRManager__c='testManager', LastName='testLastName',
                                  LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,
                                  TimeZoneSidKey='America/Los_Angeles', UserName=username, ADID__c='test'+system.now().millisecond(),
                                  EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert testUser;
        System.runAs(new User(Id=UserInfo.getUserId())) {
            GlobalConstants.hasTriggeredFromOpportunityProduct= false;
            GlobalConstants.hasBeenValidatedOnce = false;
            testOpportunity.ownerId = testUser.Id;
            update testOpportunity;
        }
        
        System.runAs(testUser) {
            //test positive test case
            testOpportunity.name = 'test Opportunity name change';
            GlobalConstants.hasTriggeredFromOpportunityProduct= false;
            GlobalConstants.hasBeenValidatedOnce = false;
            //reseting the logged in user profile
            UtilityClass.LoggedInUserProfileName = null;
            update testOpportunity;
            //test negative test case
            try {
                     testOpportunity.description = 'test fail';
                     GlobalConstants.hasTriggeredFromOpportunityProduct= false;
                     GlobalConstants.hasBeenValidatedOnce = false;
                     update testOpportunity;
                     System.assert(false,'Control will not reach here');
                
              } 
              catch (exception ex) {
                  Boolean errorexist = ex.getmessage().contains(System.Label.AutoRenewHasChangesOppyError) ? true : false;
                  System.assertEquals(errorexist ,true,'exception validation');
              }
        }       
        Test.stopTest();
        
    }
    
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 23 July 2018
    // @param: TriggerParameters
    // @description: SFDC1-5864 - Cumulative Contract Value
    //                            Migrating Process builder "Cumulative Contract Value" &  
    //                            "Clear Total Cumulative Contract Value"
    // This method will be called in afterupdate trigger Events.
    // @return: None
    //------------------------------
    @isTest private static void testupdateCumulativeContractAddwhen6W() {    	
        Account testAccount = [Select Id from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];
        Contract testContract = [Select Id from Contract where AccountId =: testAccount.id LIMIT 1];
        Opportunity opp1 = [Select id,ContractBeingRenewed__c,StageName from Opportunity where name ='test Renewal Opppy1' LIMIT 1];        
        test.startTest();
        opp1.ContractBeingRenewed__c = testContract.id;            
        opp1.StageName = '6W-Renewal Won';
        update opp1;
        
        system.assertEquals([select AllAssociatedTotalOpportunityValue__c from Contract where Id=: testContract.id].AllAssociatedTotalOpportunityValue__c, 123,'opp get created.');
       // system.assertEquals(expected, actual);
        
        test.stopTest();
        
        
    }
    
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 23 July 2018
    // @param: TriggerParameters
    // @description: SFDC1-5864 - Cumulative Contract Value
    //                            Migrating Process builder "Cumulative Contract Value" &  
    //                            "Clear Total Cumulative Contract Value"
    // This method will be called in afterupdate trigger Events.
    // @return: None
    //------------------------------
    @isTest private static void testremoveCumulativeContractWhen6WtoContracting() {
    	
        Account testAccount = [Select Id from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];
        Contract testContract = [Select Id from Contract where AccountId =: testAccount.id LIMIT 1];
        Opportunity opp1 = [Select id,stagename,ActivityCreated__c,ContractBeingRenewed__c from Opportunity where name ='test Renewal Opppy1' LIMIT 1];        
        test.startTest();
        opp1.ContractBeingRenewed__c = testContract.id;
        opp1.ActivityCreated__c = true;
        opp1.stagename = '5-Renewal Contracting';
        update opp1;
        system.assertEquals([select ContractBeingRenewed__r.AllAssociatedTotalOpportunityValue__c from opportunity where Id=: opp1.id].ContractBeingRenewed__r.AllAssociatedTotalOpportunityValue__c, 0,'validating opportunity values.');
        
        test.stopTest();
        
        
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 1 Aug 2018
    // @param: NA
    // @description: SFDC1-9500: Testmethod for revisit opportunity feature
    // @return: NA
    //-----------------------------
    @isTest private static void testRevisitOpportunityFeature() {
        
        Opportunity testOpportunity = [Select id,Revisit__c from Opportunity where name ='test Renewal Opppy1' LIMIT 1];        
        Test.startTest();
        Task taskRec = new Task(Subject='revisit testing', activityDate = System.Today()+10, priority = 'Normal');
        Id taskObjId = RevisitOpportunityLookup.creatTask(taskRec,testOpportunity.Id);
        system.assertNotEquals(taskObjId,NULL,'Task Id is null.');
        testOpportunity.Revisit__c = false;
        update testOpportunity;
        Test.stopTest();
        
    }
    //-----------------------------
    // @author: Vishnu vardhan chowdary
    // @date: 29 Nov 2018
    // @param: NA
    // @description: SFDC1-10524: Testmethod for revisit opportunity feature
    // @return: NA
    //-----------------------------
    @isTest private static void testRevisitOpportunityFeatureWithException() {        
        User testUser1 = TestUtility.createTestUser('Read Only', 'testusername'+string.valueof(system.now()).replace('-','').replace(':','').replaceall(' ','')+'@test.com',true);        
		 
        Opportunity testOpportunity = [Select id,Revisit__c from Opportunity where name ='test Renewal Opppy1' LIMIT 1];        
        System.runas(testUser1) {
            GlobalConstants.hasBeenValidatedOnce = false;
        	Test.startTest();
        	Task taskRec = new Task(Subject='revisit testing', activityDate = System.Today()+10, priority = 'Normal');
            Id taskObjId;
            try {
                taskObjId = RevisitOpportunityLookup.creatTask(taskRec,testOpportunity.Id);
            } catch (Exception e) {
                system.assertEquals('Script-thrown exception', e.getMessage(),'validating exception.');
            }
            //Exception should be thrown and taskObjId will be null
            System.assertEquals(null, taskObjId,'task not created.');
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 31 July 2018
    // @param: NA
    // @description: SFDC1-5228 :Test method for setContactRolePrimary
    // @return: NA
    //-----------------------------
    @isTest private static void testSetContactRolePrimary() {
        Test.startTest();
        Account acc = [Select ID from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];        
        Opportunity opp = [Select id,PrimaryContact__c from Opportunity where name='test Opppy 3186' and accountId =:acc.id LIMIT 1];
        Test.stopTest();
        System.assertEquals('TestSFDC3186 Contact', opp.PrimaryContact__c,'contact validation'); 
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 Aug 2018
    // @param: NA
    // @description: SFDC1-9841, 9844, 9845 - Test method for OpportunityMethods.updateContractCurrencyWhenOppCurrencyChanges and OpportunityMethods.activeContractUpdatesWhenRenewal6W
    // @return: NA
    // @Last Modified Date: 17 Feb 2021
    // @LastmodifiedBy : Anjali
    // @Last Modified Description: SFDC-3851 Global segment on contract to be made a mandatory field
    //-----------------------------
    @isTest private static void testUpdateContractCurrencyWhenOppCurrencyChanges() {
        
        Opportunity opp1 = [Select id,stagename,CurrencyIsoCode,MultiYear__c,AutoRenewStopped__c from Opportunity where name='test Opppy 3186' LIMIT 1];
        Test.startTest();
        opp1.stagename = '5-Renewal Contracting';        
        opp1.MultiYear__c = true; 
        opp1.AutoRenewStopped__c = true;
        update opp1;        
        Contract conObj = [Select MultiYearOrderForm__c,AutoRenewStopped__c,ContractStatus__c, id from contract where Opportunity__c =: opp1.id LIMIT 1 ];        
        System.assertEquals(conObj.AutoRenewStopped__c, TRUE,'opp auto renewl stopped.');              
        Test.stopTest();
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 Aug 2018
    // @description: SFDC1-9842 Test method for OpportunityMethods.syncOpportunityDatesWithContractDates
    // @param: NA
    // @return: NA
    // 
    // @modifiedBy: Tran-Vu Tran
    // @modifiedDate: 26 Feb 2019
    // @modifiedDescription: SFDC-888: only cascade changes on Contract Start and End Date from the Opportunity to Order Form and Consulting Contract record types 
    //-----------------------------
    @isTest private static void testSyncOpportunityDatesWithContractDates_OrderForm() {
        Test.startTest();
        Opportunity opp = [Select Id,ContractStartDate__c,ContractEndDate__c From Opportunity where name = 'test Opppy 3186' LIMIT 1];
        Contract testContract = [Select Id,StartDate,EndDate from Contract where Opportunity__c =: opp.Id LIMIT 1];
        testContract.StartDate = System.today() + 60;
        testContract.EndDate = System.today() + 70;
        update testContract;
        opp.ContractStartDate__c = System.Today() + 20;
        opp.ContractEndDate__c = System.Today() + 30;
        update opp;
        
        Contract conObj = [Select StartDate,Enddate,Opportunity__c,Opportunity__r.ContractStartDate__c,Opportunity__r.ContractEndDate__c from contract where id = : testContract.id];
        System.assertEquals(conObj.StartDate, conObj.Opportunity__r.ContractStartDate__c,'validating opportunity and contract dates.');
        System.assertEquals(conObj.Enddate, conObj.Opportunity__r.ContractEndDate__c,'validating opportunity and contract dates.');

        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 Aug 2018
    // @description: SFDC1-9842 Test method for OpportunityMethods.syncOpportunityDatesWithContractDates
    // @param: NA
    // @return: NA
    // 
    // @modifiedBy: Tran-Vu Tran
    // @modifiedDate: 26 Feb 2019
    // @modifiedDescription: SFDC-888: only cascade changes on Contract Start and End Date from the Opportunity to Order Form and Consulting Contract record types 
    //-----------------------------
    @isTest private static void testSyncOpportunityDatesWithContractDates_Cosulting() {
        Test.startTest();
        Opportunity opp = [Select Id,ContractStartDate__c,ContractEndDate__c From Opportunity where name = 'test Opppy 3186' LIMIT 1];
        Contract testContract = [Select Id,StartDate,EndDate from Contract where Opportunity__c =: opp.Id and recordtype.name='Consulting' LIMIT 1];
        testContract.EffectiveDate__c = System.today() + 90;
        testContract.StartDate = System.today() + 60;
        testContract.EndDate = System.today() + 70;
        update testContract;
        opp.ContractStartDate__c = System.Today() + 20;
        opp.ContractEndDate__c = System.Today() + 30;
        update opp;        
        
        Contract conObj = [Select StartDate,Enddate,Opportunity__c,Opportunity__r.ContractStartDate__c,Opportunity__r.ContractEndDate__c from contract where id = : testContract.id];
        System.assertEquals(conObj.StartDate, conObj.Opportunity__r.ContractStartDate__c,'validating opportunity and contract dates.');
        System.assertEquals(conObj.Enddate, conObj.Opportunity__r.ContractEndDate__c,'validating opportunity and contract dates.');

        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 30 Aug 2018
    // @description: SFDC1-9843 : Test Method for Process Builder [UpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus] to Code Change
    // @return: None
    //------------------------------
    @isTest static void testUpdatingOpportunityAtRiskBasedOnOpportunityClosedStatus () {        
        Test.startTest();
        Opportunity testOpportunity = [Select Id,StageName,ContractStartDate__c,ContractEndDate__c,ActivityCreated__c,
                                       ReadyForProcessingContractExist__c from Opportunity where name='test Opppy 3186' LIMIT 1];
        OpportunityLineItem testOLI = [Select id,ContractEndDate__c,ContractStartDate__c from OpportunityLineItem where OpportunityId =: testOpportunity.id LIMIT 1];
        testOpportunity.StageName = '6W-Closed Won';
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.ContractEndDate__c = System.today()+385;
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.ReadyForProcessingContractExist__c = true;
        update testOpportunity;
        System.debug('startdate: '+testOLI.ContractStartDate__c + ' '+ testOLI.ContractEndDate__c);
        List<RenewalatRisk__c> listRenewalatRisk = [Select Id, Status__c from RenewalatRisk__c where OpportunityAtRisk__c = : testOpportunity.id];
        System.assertEquals(listRenewalatRisk[0].Status__c , 'Closed - Risk Mitigated','renewal rish status changed.');
        Test.stopTest();
    }
    //-----------------------------
    // @author: Mohit Modi
    // @date: 31 Aug 2018
    // @description: SFDC1-9837 : Process Builder [Opportunity Updates For Salesops] to Code Change
    // @return: None
    //------------------------------
    @isTest static void testOpportunityUpdatesForSalesops () {       
        
        
        Campaign Camp = [select id from Campaign where Name='Test' LIMIT 1];
        Opportunity opp = [Select Id,ContractStartDate__c,ContractEndDate__c From Opportunity where name = 'test Opppy 3186' LIMIT 1];
                   
        Test.startTest();
        
        opp.StageName= '2-Need Confirmed';
        opp.CloseDate = System.today()+5;
        opp.Description = 'Test Description';
        opp.CampaignID = Camp.id;
        opp.MISAttachmentAdded__c = System.today()+7;
        opp.MISActivityAdded__c  = System.today()+1;
        update opp;   
        
        System.assertEquals([select id,DateLastUpdated__c from Opportunity where id =: opp.id ].DateLastUpdated__c , System.Today(),'last updated date validation.');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 28 Aug 2018
    // @param: NA
    // @description: SFDC1-9835 Test method for deletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner
    // @return: NA
    //-----------------------------
    @isTest private static void testDeletePrevOppOwnerFromTeamAndOppSplitsAndUpdPrevOwner() {
        //Get current user's Id
        Id currentUserId = UserInfo.getUserId();       
        
        //Create TestUser
        User testUser1 = TestUtility.createTestUser('System Administrator', 'testusername'+string.valueof(system.now()).replace('-','').replace(':','').replaceall(' ','')+'@test.com',true);        
        Test.startTest();
        System.runas(testUser1) {
            //Create test account
            Account acc = TestUtility.createTestAccount('Test Acc HS 9835',true);
            
            //Create test opp
            Opportunity opp = TestUtility.createOpportunity(acc.id, 'Opp9835',null,false);
            opp.OwnerId = UserInfo.getUserId();
            insert opp;
        	
            //Check Opp Split created or not
            System.debug('@@HS UserInfo.getUserId() for testUser1='+UserInfo.getUserId());
            List<OpportunitySplit> oppSplit = new List<OpportunitySplit>([Select id, opportunityId, splitOwnerId from OpportunitySplit WHERE OpportunityId =: opp.id AND splitOwnerId =:UserInfo.getUserId() ]);
            System.assertNotEquals(0, oppSplit.size(),'Split is null for user.');
            
            List<OpportunityTeamMember> oldTeamList = [SELECT UserId,Opportunity.OwnerId,OpportunityId,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :opp.id AND (TeamMemberRole ='Opportunity Owner')];
            if(oldTeamList!=null && oldTeamList.size()>0) {            	
                //Verify team member creation for existing owner
                System.assertEquals( UserInfo.getUserId(), oldTeamList[0].UserId,'User validation.');
            }
            
            //Change Opp Owner to current user
            System.debug('@@HS Opp owner1='+opp.OwnerId);
            opp.OwnerId = currentUserId;
            update opp;
            System.debug('@@HS Opp owner2='+opp.OwnerId);
            
            //Verify Previous owner update
            System.assertEquals(UserInfo.getUserId(),[Select Id,OwnerId,PreviousOpportunityOwner__c FROM Opportunity WHERE Id=:opp.id].PreviousOpportunityOwner__c,'opp owner validation.');
            
            //Verify if opp split for previous owner got deleted
            List<OpportunitySplit> oppSplit2 = new List<OpportunitySplit>([Select id, opportunityId, splitOwnerId from OpportunitySplit WHERE OpportunityId =: opp.id AND splitOwnerId =:UserInfo.getUserId()]); 			
            System.assertEquals(0, oppSplit2.size(),'opp split is not null.');
            
            //Verify team member updates
            List<OpportunityTeamMember> newTeamList = [SELECT UserId,Opportunity.OwnerId,OpportunityId,TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId = :opp.id AND (TeamMemberRole ='Opportunity Owner')];
            if(newTeamList!=null && newTeamList.size()>0) {
            	//Verify old team member delete
                System.assertNotEquals( UserInfo.getUserId(), newTeamList[0].UserId,'Team user validation');
                //Verify new team member creation
                System.assertEquals( currentUserId, newTeamList[0].UserId,'Team user is not null');    
            }
            
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 5 Sept 2018
    // @description: SFDC1-9833 : Process Builder [ClearChannelPartnerOpportunity] to Code Change. Test Method for ClearGAMTeamMemberOnChannelPartnerOpportunity  and ClearChannelPartnerOpportunity 
    // @return: None
    //------------------------------
    @isTest static void testClearChannelPartnerOpportunity () {        
        Account testAccount = [Select id,Type,AccountSubType__c from Account where name = 'Account test2' LIMIT 1];
        testAccount.Type = 'Channel Partner';
        testAccount.AccountSubType__c = 'Reseller';
        update testAccount;
        Test.startTest();
        
        Opportunity opp = [Select Id,StageName,SubType__c,
                                       ChannelPartner__c,GAM__c from Opportunity where name='test Opppy 3186' LIMIT 1]; 
        
        opp.ChannelPartner__c = testAccount.id;
        opp.GAM__c = userinfo.getuserid();     
       	opp.SubType__c = 'Global Alliance';        
        update opp;   
        System.assertNOTEquals([select id,ChannelPartner__c from Opportunity where id =: opp.id ].ChannelPartner__c , NULL,'User validation.');
        System.assertEquals([select id,GAM__c from Opportunity where id =: opp.id ].GAM__c , NULL,'User validation.');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 19 oct 2018
    // @description: SFDC1-10039 : When Account Changes on Opportunity, Opportunity atRisk's Account also should be changed.
    // @return: None
    //------------------------------
    @isTest static void testUpdateAtRiskAccountUponOpportunityAccountChange () {        
        Account testAccount = [Select id,Type,AccountSubType__c from Account where name = 'Account test2' LIMIT 1];
        testAccount.Type = 'Channel Partner';
        testAccount.AccountSubType__c = 'Reseller';
        update testAccount;
        
        Test.startTest();      
	    Opportunity opp = [Select Id,StageName,SubType__c,
                                       ChannelPartner__c,GAM__c from Opportunity where name='test Opppy 3186' LIMIT 1]; 
        
        opp.ChannelPartner__c = testAccount.id;
        opp.GAM__c = userinfo.getuserid();     
       	opp.SubType__c = 'Global Alliance';        
        update opp;
        
        RenewalatRisk__c testRaR = [Select id,Status__c,RiskProbability__c,Comments__c,EstimatedValueatRisk__c
                                    from RenewalatRisk__c where OpportunityAtRisk__c =: opp.Id LIMIT 1];
        
        opp.AccountId = testAccount.id;
        update opp;
        
        System.assertEquals([select id,Account__c from RenewalatRisk__c where id =: testRaR.id ].Account__c ,testAccount.id,'Account validation on renewal risk.');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 09 Nov 2018
    // @description: SFDC1-10318 : Create Implementation Case when Auto-Renewal is moved to 6W-Renewal Won, and
    // 			has products with status as lost.
    // @return: None
    //------------------------------
    @isTest
    private static void testCreateImplCaseForLostProductsOnRenewalOpp6W() {        
        Contract testContract = [select id from Contract where recordtype.name='Order Form' LIMIT 1];
        Opportunity testOpportunity = [Select id from Opportunity where name='test Renewal Opppy' LIMIT 1];       
        List<OpportunityLineItem> oliList = [Select Id,Status__c,OpportunityId from OpportunityLineItem where OpportunityId =: testOpportunity.id];
        
        for(OpportunityLineItem oli : oliList) {            
            oli.Status__c='Lost';            
        }
        update oliList;        
        Test.startTest();
        GlobalConstants.hasImplCaseForLostProductsOnRenewalOpp6WExecuted=false;
        
        testOpportunity.LostReasonCode__c = 'Non Payment';
        testOpportunity.LostReasonDescription__c = 'Bid too high';
        testOpportunity.StageName = '6W-Renewal Won';
        testOpportunity.ContractBeingRenewed__c = testContract.id;
        update testOpportunity;
        
        List<case> caseList = [select id, type, Subject from case where Subject = 'Opportunity # - Lost Renewal Opportunity Product'];
        System.debug('case size---: '+caseList.size());
       System.assertEquals(caseList.size(),1);
        
        Test.stopTest();
    }
    
    
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 10 Sept 2020
    // @param: NA
    // @description: SFDC-3373: Test method for Opportunity trigger methods changeAdditionalOpportunityFieldsNameWhenOpportunityFieldChanges on update and setOpportunityAdditionalFieldsObject on insert
    // @return: NA
    //-----------------------------
    
    @isTest private static void TestOpportunityAdditionalFieldsObjectv2() {   
       
        test.startTest(); 
        Opportunity testNewBizOpp = [Select Id,GAM__c from opportunity where name ='test Opppy 3186' LIMIT 1];
        
        testNewBizOpp.Name = 'Test Opp2';
        testNewBizOpp.LegacyID__c = '123455';        
        update testNewBizOpp;
        
       Opportunity oppy = [Select Id, Name, LegacyID__c, AdditionalOpportunityFields__r.Name, AdditionalOpportunityFields__c, AdditionalOpportunityFields__r.LegacyID__c from Opportunity where id = :testNewBizOpp.id];
       System.assertEquals(oppy.LegacyID__c, oppy.AdditionalOpportunityFields__r.LegacyID__c,'matching legacy Id of records ');
       System.assertEquals(('Additional Fields - ' + oppy.Name).left(80), oppy.AdditionalOpportunityFields__r.Name,'opp name validation.');
       test.stopTest();
    }
    //-----------------------------
    // @author: Paras
    // @date: 08 May 2019
    // @param: NA
    // @description: Test method for Opportunity trigger methods resetAccountManagerSplitOnOwnerChange on update
    // @return: NA
    //-----------------------------
    @isTest private static void TestResetAccountManagerSplitOnOwnerChange() {        
        List<User> lstUser = [Select Id from User where Email IN ('testUser2email@test.com.ihsmarkit.test','testUser3email@test.com.ihsmarkit.test') LIMIT 2];
        Account a =[Select Id,GlobalAccountManager__c from Account where name='Account testSetCaseAdditionalFieldsObject' LIMIT 1];        
        Opportunity opp = [Select Id,OwnerId,GAM__c from opportunity where name ='test Opppy 3186' LIMIT 1];
        Test.startTest();
        //Assert Opportunity for existing split in overlay
        List<OpportunitySplit> assertOppySplit = [Select Id, SplitPercentage,SplitType.DeveloperName, SplitOwnerId
                                            from OpportunitySplit where opportunityId=:opp.Id and SplitOwnerId=:a.GlobalAccountManager__c];
        System.assertEquals(1,assertOppySplit.size(),'Check Overlay opportunity split count');
        System.assertEquals('Overlay',assertOppySplit[0].SplitType.DeveloperName, 'Check overlay type');
        //change Owner
        opp.OwnerId = lstUser[0].Id;
        update opp;
        Test.stopTest();
        //assert Oppy SPlit
        assertOppySplit = [Select Id, SplitPercentage,SplitType.DeveloperName, SplitOwnerId
                                            from OpportunitySplit where opportunityId=:opp.Id AND SplitOwnerId=:a.GlobalAccountManager__c];
        System.assertEquals(1,assertOppySplit.size(),'Check Overlay opportunity split count');
        System.assertEquals('Overlay',assertOppySplit[0].SplitType.DeveloperName, 'Check overlay type');        
      
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 10 Sep 2019
    // @param: NA
    // @description: Test method for Opportunity trigger methods oppCheckASC606RevRecProductValidation()
    // @return: NA
    //-----------------------------
    @isTest private static void testOppCheckASC606RevRecProductValidation() {
        
        Test.startTest(); 
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Renewal Opppy'];
        try {
			testOpportunity.AutoRenewal__c = true;
            testOpportunity.DoesThisAutoRenewalHaveChanges__c = false;
            testOpportunity.ReadyForProcessingContractExist__c = true;
            testOpportunity.CloseDate = System.today()+2;
            testOpportunity.StageName = '6W-Renewal Won';
            update testOpportunity;       
        }
        catch(Exception ex) {
            System.assert(ex.getMessage().contains('Earliest Termination Period') && ex.getMessage().contains('Contract Special Options'), 'Validation failed: Please populate Earliest Termination Period and Contract Special Options');            
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 10 Oct 2019
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateOpportunityLineItems()
    // @return: NA
    //-----------------------------
    @isTest
    private static void testupdateOpportunityLineItemsDates() {
        Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
		Opportunity opp1 = TestUtility.createOpportunity(acc.Id, 'test Opppy Replacing', true);
        Contract testContract = [SELECT Id FROM Contract WHERE Opportunity__c =: testOpportunity.Id LIMIT 1];
        List<OpportunityLineItem> oliList = [SELECT Id FROM opportunityLineItem where opportunityId = :testOpportunity.id];
        User u = [SELECT Id FROM User WHERE Email = 'testUser1email@test.com.ihsmarkit.test' LIMIT 1];
        
        test.startTest();
        // change start date. on changing opportunity Start date, this should not get impacted.
        oliList[0].contractStartDate__c = System.today() + 50;//date.newInstance(2009,02,01);
        
        // change end date. On changing opportunity contract end date, this oli should not get impacted.
        oliList[1].contractEndDate__c = System.today() + 100;//date.newInstance(2009,08,01);
        // change end date and owner
        oliList[2].contractEndDate__c = System.today() + 80;//Date.newInstance(2009,06,01);
        update oliList;
        
		testOpportunity.OwnerId = u.id;
        testOpportunity.contractStartDate__c = System.today() + 25;//Date.newInstance(2009,01,15);
        testOpportunity.ContractEndDate__c = System.today() + 150;//Date.newInstance(2009,09,01);
        update testOpportunity;
        
        
        Map<id,OpportunityLineItem> mapoli = new Map<Id,OpportunityLineItem>([select contractStartDate__c, contractEndDate__c, productOwner__c from opportunityLineItem where opportunityId = :testOpportunity.id]);
        system.debug(mapOli);
        
        test.stopTest();
        
    }
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 10 Oct 2019
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateOpportunityLineItems ()
    // @return: NA
    //-----------------------------
    @isTest
    private static void testupdateOpportunityLineItemsDatesNullCheck() {
        
        Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
		Opportunity opp1 = TestUtility.createOpportunity(acc.Id, 'test Opppy Replacing', true);
        Contract testContract = [SELECT Id FROM Contract WHERE Opportunity__c =: testOpportunity.Id LIMIT 1];
        List<OpportunityLineItem> oliList = [SELECT Id FROM opportunityLineItem where opportunityId = :testOpportunity.id];
        User u = [SELECT Id FROM User WHERE Email = 'testUser1email@test.com.ihsmarkit.test' LIMIT 1];
        test.startTest();
		testOpportunity.OwnerId = u.id;
        testOpportunity.contractStartDate__c = Date.newInstance(2009,01,15);
        testOpportunity.ContractEndDate__c = Date.newInstance(2009,09,01);
        update testOpportunity;
        test.stopTest();
        
        Map<id,OpportunityLineItem> mapoli = new Map<Id,OpportunityLineItem>([select contractStartDate__c, contractEndDate__c, productOwner__c from opportunityLineItem where opportunityId = :testOpportunity.id]);
        system.debug(mapOli);
        
        system.assertEquals(Date.newInstance(2009,01,15), mapOli.get(oliList[3].id).contractStartDate__c,'check date.');
        system.assertEquals(Date.newInstance(2009,09,01), mapOli.get(oliList[3].id).contractEndDate__c,'check date.');
        system.assertEquals(Date.newInstance(2009,01,15), mapOli.get(oliList[0].id).contractStartDate__c,'check date.');
        system.assertEquals(Date.newInstance(2009,09,01), mapOli.get(oliList[1].id).contractEndDate__c,'check date.');
        
    }
    
    
    
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 07 Feb 2020
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateOpportunityLineItems ()
    // @return: NA
    //-----------------------------    
    @isTest
    private static void testupdateOpportunityLineItemsProbUpdate() {
        
        Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
		Opportunity opp1 = TestUtility.createOpportunity(acc.Id, 'test Opppy Replacing', true);
        Contract testContract = [SELECT Id FROM Contract WHERE Opportunity__c =: testOpportunity.Id LIMIT 1];
        
        User u = [SELECT Id FROM User WHERE Email = 'testUser1email@test.com.ihsmarkit.test' LIMIT 1];
        
        Test.startTest();
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
		testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update testContract;
        
        System.debug('=====limits.getQueries() in test before StartTest===' + limits.getQueries());
        
        //Write 6W asserts
        Opportunity testOppWonAssert = [SELECT Id, StageName, Probability, (SELECT Id,Probability__c,Status__c FROM OpportunityLineItems) FROM Opportunity WHERE Id=:testOpportunity.Id LIMIT 1];
        System.assertEquals('6W-Closed Won', testOppWonAssert.StageName,'Opportunity not set to 6W when contract set to Stage 10 Ready for Processing');
        for(OpportunityLineItem testOLIWonAssert: testOppWonAssert.OpportunityLineItems) {
            if(testOLIWonAssert.Status__c=='New' || testOLIWonAssert.Status__c=='Existing') {
                System.assertEquals(100, testOLIWonAssert.Probability__c, 'Probability on opportunity product is not set to 100% on close won opportunity');
            }
            if(testOLIWonAssert.Status__c=='Lost') {
                System.assertEquals(0, testOLIWonAssert.Probability__c, 'Probability on lost opportunity product is not set to 0% on close won opportunity');
            }            
        }
        
        testOpportunity.contractStartDate__c = Date.newInstance(2009,01,15);
        testOpportunity.ContractEndDate__c = Date.newInstance(2009,09,01);
        update testOpportunity;
        
        
        
        System.debug('=====limits.getQueries() 1st opp update===' + limits.getQueries());
        List<OpportunityLineItem> oliList = [SELECT Id FROM opportunityLineItem where opportunityId = :testOpportunity.id];
        Map<id,OpportunityLineItem> mapoli = new Map<Id,OpportunityLineItem>([select contractStartDate__c, contractEndDate__c, productOwner__c from opportunityLineItem where opportunityId = :testOpportunity.id]);
        system.debug(mapOli);
        system.debug(oliList);
        
        system.assertEquals(Date.newInstance(2009,01,15), mapOli.get(oliList[3].id).contractStartDate__c,'check date.');
        system.assertEquals(Date.newInstance(2009,09,01), mapOli.get(oliList[3].id).contractEndDate__c,'check date.');
        system.assertEquals(Date.newInstance(2009,01,15), mapOli.get(oliList[0].id).contractStartDate__c,'check date.');
        system.assertEquals(Date.newInstance(2009,09,01), mapOli.get(oliList[1].id).contractEndDate__c,'check date.');
        
        
        testOpportunity.OwnerId = u.id;
		update testOpportunity;        
        
        
        
        System.debug('=====limits.getQueries() 2nd opp update===' + limits.getQueries());
        
        List<OpportunityLineItem> listOli = [select productOwner__c from opportunityLineItem where opportunityId = :testOpportunity.id];
        for(opportunityLineItem oli : listOli) {
            system.assertEquals(u.id, oli.productOwner__c,'check user');
        }
        Test.stopTest();
	}
	
    
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 07 Feb 2020
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateOpportunityLineItems ()
    // @return: NA
    //-----------------------------    
    @isTest
    private static void testupdateOpportunityLineItemsProbUpdateOn6W6L() {
        Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
		Opportunity opp1 = TestUtility.createOpportunity(acc.Id, 'test Opppy Replacing', true);
        Contract testContract = [SELECT Id FROM Contract WHERE Opportunity__c =: testOpportunity.Id LIMIT 1];
        
        User u = [SELECT Id FROM User WHERE Email = 'testUser1email@test.com.ihsmarkit.test' LIMIT 1];
        
        Test.startTest();
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
		testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update testContract;
        
        //Write 6W asserts
        Opportunity testOppWonAssert = [SELECT Id, StageName, Probability, (SELECT Id,Probability__c,Status__c FROM OpportunityLineItems) FROM Opportunity WHERE Id=:testOpportunity.Id LIMIT 1];
        System.assertEquals('6W-Closed Won', testOppWonAssert.StageName,'Opportunity not set to 6W when contract set to Stage 10 Ready for Processing');
        for(OpportunityLineItem testOLIWonAssert: testOppWonAssert.OpportunityLineItems) {
            if(testOLIWonAssert.Status__c=='New' || testOLIWonAssert.Status__c=='Existing') {
                System.assertEquals(100, testOLIWonAssert.Probability__c, 'Probability on opportunity product is not set to 100% on close won opportunity');
            }
            if(testOLIWonAssert.Status__c=='Lost') {
                System.assertEquals(0, testOLIWonAssert.Probability__c, 'Probability on lost opportunity product is not set to 0% on close won opportunity');
            }            
        }
        
        testOpportunity.StageName = '6L-Closed Lost';
        testOpportunity.LostReasonCode__c = 'Duplicate/Existing Opp';
        testOpportunity.LostReasonDescription__c = 'Test Loss Reason Description';
        testOpportunity.ReplacementOpportunity__c   = Opp1.Id;
        update testOpportunity;
        
        //Write 6L asserts
        Opportunity testOppLostAssert = [SELECT Id, StageName, Probability, (SELECT Id,Probability__c,Status__c FROM OpportunityLineItems) FROM Opportunity WHERE Id=:testOpportunity.Id LIMIT 1];
        for(OpportunityLineItem testOLILostAssert: testOppLostAssert.OpportunityLineItems) {            
            System.assertEquals(0, testOLILostAssert.Probability__c, 'Probability on opportunity product is not set to 0% on close lost opportunity');
        }
        
        Test.stopTest();
    }


    
    /**
     * @author Sushma Yadav
     * @date 8th May 2020
     * @description SFDC-2799 test class for OpportunityMethods.blockSalesUpdateAddressValidation
     * @param NA
     * @return void
     * @companyname IHS Markit
     */
    @isTest
    private static void testCheckEnhancedSalesPermission1() {
        Profile salesCoordinatorProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Sales Coordinator%' LIMIT 1];
        
        User salesCoordinator = new User(FirstName='Sales', LastName='Coordinator', Email='salesCoordinator@ihsmarkit.com', Alias = 'salesCd',
                                         ProfileId = salesCoordinatorProfile.Id, HRManager__c='manager', EmailEncodingKey ='UTF-8', 
                                         LocaleSidKey = 'en_US', LanguageLocaleKey='en_US', TimeZoneSidKey = 'America/Los_Angeles',
                                         UserName = 'salesCoordinator@ihsmarkit.com', ADID__c = 'test'+system.now().millisecond(),
                                         EmployeeNumber = String.valueOf(Math.round(Math.random()*10000)),
                                         EmployeeNumber__c = String.valueOf(Math.round(Math.random()*10000)));
        insert salesCoordinator;
        
        System.runAs(salesCoordinator) {
            Test.startTest();
            Opportunity opp1 = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
            try {
                    opp1.BillToCity__c                  = 'city';
                    opp1.BillToClientName__c            = 'client name';
                    opp1.BillToContactEmailAddress__c   = 'testemail1@test.com';
                    opp1.BillToContactFirstName__c      = 'client';
                    opp1.BillToContactLastName__c       = 'name';
                    opp1.BillToContactTelephoneNumber__c= '123423';
                    opp1.BillToPostalZipCode__c         = '94105';
                    opp1.BillToStateProvince__c         = 'California';
                    opp1.BillToStreet__c                = '531 Market Street';
                    opp1.ShipToCity__c                  = 'city';
                    opp1.ShipToClientName__c            = 'client name';
                    opp1.ShipToContactEmailAddress__c   = 'testemail1@test.com';
                    opp1.ShipToContactFirstName__c      = 'client';
                    opp1.ShipToContactLastName__c       = 'name';
                    opp1.ShipToContactTelephoneNumber__c= '123423';
                    opp1.ShipToPostalZipCode__c         = '94105';
                    opp1.ShipToStateProvince__c         = 'California';
                    opp1.ShipToStreet__c                = '531 Market Street';
                    update opp1;
                    //update the Opportunity record above
                    
                }   catch (Exception e) {
                    // do nothing, unit test will fail if reach this line
                    system.assertEquals(true, e.getMessage() != null,'validation exception.');
                }
            
            try {
                Opportunity testRenewalOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Renewal Opppy'];
                testRenewalOpportunity.StageName              = '3-Renewal Pending';
                testRenewalOpportunity.ContractStartDate__c   = System.Today() + 31;
                testRenewalOpportunity.ContractEndDate__c     = System.Today() + 60;
                testRenewalOpportunity.CloseDate              = System.Today() + 31;
                testRenewalOpportunity.AutoRenewal__c         = false;
                testRenewalOpportunity.SourceSystem__c        = 'Manually Generated';
                testRenewalOpportunity.Amount                 = 3000;
                testRenewalOpportunity.BillToCity__c                  = 'city';
                testRenewalOpportunity.BillToClientName__c            = 'client name';
                testRenewalOpportunity.BillToContactEmailAddress__c   = 'testemail1@test.com';
                testRenewalOpportunity.BillToContactFirstName__c      = 'client';
                testRenewalOpportunity.BillToContactLastName__c       = 'name';
                testRenewalOpportunity.BillToContactTelephoneNumber__c= '123423';
                testRenewalOpportunity.BillToPostalZipCode__c         = '94105';
                testRenewalOpportunity.BillToStateProvince__c         = 'California';
                testRenewalOpportunity.BillToStreet__c                = '531 Market Street';
                testRenewalOpportunity.ShipToCity__c                  = 'city';
                testRenewalOpportunity.ShipToClientName__c            = 'client name';
                testRenewalOpportunity.ShipToContactEmailAddress__c   = 'testemail1@test.com';
                testRenewalOpportunity.ShipToContactFirstName__c      = 'client';
                testRenewalOpportunity.ShipToContactLastName__c       = 'name';
                testRenewalOpportunity.ShipToContactTelephoneNumber__c= '123423';
                testRenewalOpportunity.ShipToPostalZipCode__c         = '94105';
                testRenewalOpportunity.ShipToStateProvince__c         = 'California';
                testRenewalOpportunity.ShipToStreet__c                = '531 Market Street';
                update testRenewalOpportunity;
                    //update the Opportunity record above
                    
                }   catch (Exception e) {
                    // do nothing, unit test will fail if reach this line
                    system.assertEquals(true, e.getMessage() != null,'validation exception.');
                }
            Test.Stoptest();
        }
          
        
    }
    
    /**
     * @author Sushma Yadav
     * @date 28th May 2020
     * @description SFDC-2439 test class for OpportunityMethods.UpdateReplacementOppwhenOpportunityReopen
     * @param NA
     * @return void
     * @companyname IHS Markit
     */
    @isTest
    private static void testUpdateReplacementOppwhenOpportunityReopen() {
        Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
        Opportunity opp1 = TestUtility.createOpportunity(acc.Id, 'test Opppy Replacing', true);
        
        Opportunity testOpp1 = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        
        Test.startTest();
        //Setting Opportunity as Lost
        testOpp1.StageName                   = '6L-Closed Lost';
        testOpp1.LostReasonCode__c           = 'Duplicate/Existing Opp';
        testOpp1.LostReasonDescription__c    = 'Test Loss Reason Description';
        testOpp1.ReplacementOpportunity__c   = Opp1.Id;
        update testOpp1;
        
        //Reopen the Opportunity
        testOpp1.StageName   = '1-Sales Qualified';
        update testOpp1;
        
        Opportunity testOpp = [SELECT Id, StageName, ReplacementOpportunity__c, LostReasonCode__c, LostReasonDescription__c FROM Opportunity WHERE Id=:testOpp1.Id LIMIT 1];
    	
        Test.stopTest();
        System.assertEquals(String.isBlank(testOpp.ReplacementOpportunity__c),true,'opp flag cheks after update.');
        System.assertEquals(String.isBlank(testOpp.LostReasonCode__c),true,'opp flag cheks after update.');
        System.assertEquals(String.isBlank(testOpp.LostReasonDescription__c),true,'opp flag cheks after update.');
        
    }
    
    //-----------------------------
    // @author: Madhusudhan
    // @date: 11 Dec 2020
    // @param: NA
    // @description: Test method for Opportunity trigger methods createRenewalStagingOn6WP().
    // @return: NA
    //-----------------------------    
    @isTest
    private static void test2CreateRenewalStagingOn6WP() {
        List<AutomatedRenewalsConfig__c> configSettingList = TestBatchAutoCreateRenewalOpps.createTestAutoRenewalConfigCustomSettings(false);
        configSettingList.add(new AutomatedRenewalsConfig__c(SetupOwnerId=UserInfo.getUserId(), DoNotTriggerRenewals__c=false));
        insert configSettingList;
        Opportunity testOpp1 = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        Contract testContract = [SELECT Id FROM Contract WHERE Opportunity__c =: testOpp1.Id LIMIT 1];
        
        Test.startTest();
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c='Financial Svcs-Info';
        update testContract;
        Test.stopTest();
        //Create opp and move from 6W to 6WP
        testOpp1.StageName='6WP-Closed Won/Order Processed';
        update testOpp1;
        
        //Assert Staging record creation
        System.assertEquals(1, new List<RenewalStaging__c>([SELECT Id FROM RenewalStaging__c WHERE Processed__c=false AND Opportunity__c=:testOpp1.Id LIMIT 1]).size(), 'Renewal Staging record for opp not created.');
        
        //Rollback from 6WP
        testOpp1.StageName='1-Sales Qualified';
        update testOpp1;
        
        //Assert staging record deletion
        System.assertEquals(0, new List<RenewalStaging__c>([SELECT Id FROM RenewalStaging__c WHERE Processed__c=false AND Opportunity__c=:testOpp1.Id]).size(), 'Renewal Staging record for opp not deleted.');

        
    }
    
    /**
     * @author: Paras Dhingra
     * @date: 18th Aug 2020
     * @param: Triggerparameters tp
     * @description: SFDC-3187 test class for testDeletePriceChangeOnly and OpportunityLineItemScheduleMethods.syncAutoRenewalPriceChangeOnlyLineItems
     */
    @isTest
    private static void testDeletePriceChangeOnly() {
        //create test data
        //create Account and contract
        Integer financialYear = UtilityClass.calculateFYFromDate(Date.today(), UtilityClass.FiscalStartMonth);
        
        String installmentYear = String.valueOf(financialYear);
        String installmentYearPreviousYear = String.valueOf(financialYear-1);
        List<Product2> lstProduct = [SELECT Id FROM Product2];
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        Contract testContract = [SELECT Id FROM Contract WHERE Opportunity__c =: testOpportunity.Id LIMIT 1];
        List<ContractLineItem__c> lstContractLineItem = new List<ContractLineItem__c>();
        lstContractLineItem.add(TestUtility.createContractLineItem('test Product1', testContract.Id, lstProduct.get(0).Id, false) );
        lstContractLineItem.add(TestUtility.createContractLineItem('test Product2', testContract.Id, lstProduct.get(1).Id, false) );
        insert lstContractLineItem;
        //insert fixed fee line item schedules
        List<ContractLineItemSchedule__c> lstCLIS = new List<ContractLineItemSchedule__c>();
        ContractLineItemSchedule__c cli1 = TestUtility.createContractLineItemSchedule(testContract.Id,lstContractLineItem.get(0).Id, false);
        ContractLineItemSchedule__c cli2 = TestUtility.createContractLineItemSchedule(testContract.Id,lstContractLineItem.get(1).Id, false);
        cli1.InstallmentYear__c = installmentYear;
        cli2.InstallmentYear__c = installmentYearPreviousYear;
        lstCLIS.add(cli1);
        lstCLIS.add(cli2);
        Test.startTest();
        insert lstCLIS;
        //create renewal opportunity with products
        //Opportunity testOpportunity = TestUtility.createRenewalOpportunity(testAccount.Id, testContract.Id, true,false,false,true);
        Opportunity testRenewalOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Renewal Opppy'];
        List<PricebookEntry> lstPBE = [SELECT Id, UnitPrice FROM PricebookEntry];
        //create products and product schedules
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(TestUtility.createOpportunityLineItem(testRenewalOpportunity.Id, lstPBE.get(0), false));
        oliList.add(TestUtility.createOpportunityLineItem(testRenewalOpportunity.Id, lstPBE.get(1), false));
        oliList.get(0).Status__c = 'Existing';
        oliList.get(1).Status__c = 'Existing';
        insert oliList;
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testRenewalOpportunity.Id,null,2223.23,2000,
                                                                                            'Amount', 223.23, 0.0, lstProduct.get(0).Id, installmentYear, 1, 
                                                                                            oliList.get(0).Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testRenewalOpportunity.Id,null,2323.23,2000,
                                                                                            'Amount', 323.23, 0.0, lstProduct.get(1).Id, installmentYear, 1, 
                                                                                            oliList.get(1).Id,false);
        ops1.Status__c = 'Existing';
        ops2.Status__c = 'Existing';
        List<OpportunityLineItemSchedule__c> lstOLIS = new List<OpportunityLineItemSchedule__c>{ops1,ops2};
        //got soql 101 hence starting the testing just before inserting opportunity product schedules
        insert lstOLIS;
        //update the oppy to pricechange
        testRenewalOpportunity.PriceChangeOnly__c = true;
        update testRenewalOpportunity;
        //update schedules and assert fixed fee line items
        lstOLIS.get(0).SalesPrice__c = 2500;
        lstOLIS.get(1).SalesPrice__c = 2500;
        lstOLIS.get(0).TotalPrice__c = 2500;
        lstOLIS.get(1).TotalPrice__c = 2500;
        update lstOLIS;
        //assert fixed fee line items
        List<ContractLineItemSchedule__c> assertListfixedfeeItems = [SELECT Id FROM ContractLineItemSchedule__c
                                            WHERE PriceIncreaseId__c =:testRenewalOpportunity.Id
                                            AND PriceIncreaseId__c!=null];
        //System.assertEquals(2,assertListfixedfeeItems.size(),'check the status of updated fixed fee line items');
        //now test case on change of pricechange flag
        testOpportunity.PriceChangeOnly__c = false;
        update testOpportunity;
        //the fixed fee line items will be deleted now
        assertListfixedfeeItems = [SELECT Id FROM ContractLineItemSchedule__c
                                            WHERE PriceIncreaseId__c =:testRenewalOpportunity.Id
                                            AND PriceIncreaseId__c!=null];
        System.assertEquals(0,assertListfixedfeeItems.size(),'it will delete the fixed fee line items');
        Test.stopTest();

    }
    
    /**
     * @author: Md Sharique Iqbal
     * @date: 27th Jan 2021
     * @description: This method tests the multiYearLogic by creating opportunity.
     * @return: NA
     */ 
    @isTest private static void testmultiYearLogic() {
        Test.startTest();
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        testOpportunity.CloseDate = System.today()+2;
        testOpportunity.Amount = 123;
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.ContractEndDate__c = System.today()+800;
        update testOpportunity; 
        
        Opportunity oppo = [SELECT Id, MultiYear__c FROM Opportunity WHERE Id =:testOpportunity.id];      
        System.assertEquals(oppo.MultiYear__c, true, 'Difference between Contract Start and End Date is less than 2 years');
        Test.stopTest();
        
    }
    
    
    /**
     * @author: Vaishali Jain
     * @date: 13 April 2021
     * @description: This method tests for Opportunity trigger methods populateReferralPercentage() by creating opportunity.
     * @return: NA
     */ 
    @isTest private static void testPopulateReferralPercentage() {
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        testOpportunity.ReferralType__c = 'Referral Plus Logistics';
        testOpportunity.Referral_Percentage__c = 10.00;
        Test.startTest();
        update testOpportunity;
        Opportunity testOpp = [SELECT Id, Referral_Percentage__c FROM Opportunity WHERE Id=:testOpportunity.Id LIMIT 1];
        System.assertEquals(testOpp.Referral_Percentage__c, 10.00,'opp percenttage updated.');
        
        testOpportunity.ReferralType__c = 'Referral Only';
        testOpportunity.Referral_Percentage__c = 5.00;
        update testOpportunity;
        Opportunity testOpp1 = [SELECT Id, Referral_Percentage__c FROM Opportunity WHERE Id=:testOpportunity.Id LIMIT 1];
        System.assertEquals(testOpportunity.Referral_Percentage__c, 5.00,'opp percenttage updated.');
        
        
        testOpportunity.ReferralType__c = 'Referral Fee Manual';
        try{
            update testOpportunity;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,'validating exception');
        }
        
        Test.stopTest();
    }
    
    
    /**
     * @author: Akhila Kodipaka
     * @date: 15th Apr 2021
     * @description: This method is for OpportunityMethods.updateContractAccountWhenOpportunityAccountIsUpdated
     * @param null
	 * @return void
     */
    @isTest private static void testUpdateContractAccountWhenOpportunityAccountIsUpdated(){
        Account accNew = TestUtility.createTestAccount('NewTestAccount', false);
        accNew.BillingCity = 'Hyderabad';
        insert accNew;
        Test.startTest();
        
		Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];        
        testOpportunity.AccountId = accNew.Id;
        update testOpportunity;
        Contract testContract = [SELECT Id, AccountId, BillToCity__c, BillToClientName__c, BillToCompanySAP__c, BillToContactEmailAddress__c, BillToContactFirstName__c, BillToContactLastName__c,
                                 BillToContactSAP__c, BillToContactTelephoneNumber__c, BillToCountryCodeLookup__c, BillToPostalZipCode__c, BillToStateProvince__c, BillToStreet__c,
                                 ShipToCity__c, ShipToClientName__c, ShipToCompanySAP__c, ShipToContactEmailAddress__c, ShipToContactFirstName__c, ShipToContactLastName__c, ShipToContactSAP__c,
                                 ShipToContactTelephoneNumber__c, ShipToCountryCodeLookup__c, ShipToPostalZipCode__c, ShipToStateProvince__c, ShipToStreet__c
                                 FROM Contract Where Opportunity__c =: testOpportunity.Id LIMIT 1];
        
        System.assertEquals(testContract.AccountId, accNew.Id, 'Account is not updated on Contract');
        Test.stopTest();
    }
    
    /**
	 * @author: Akhila Kodipaka
	 * @date: 15th Apr 2021
	 * @description: This method is for OpportunityMethods.updateContractAddressFieldsWhenOpportunityAddressIsUpdated
	 * @param null
	 * @return void
	*/
    @isTest private static void testUpdateContractAddressFieldsWhenOpportunityAddressIsUpdated(){
        Test.startTest();
        Opportunity testOpportunity = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        testOpportunity.BillToCity__c = 'Test city';
        testOpportunity.BillToClientName__c = 'Test client';
        testOpportunity.BillToCompanySAP__c = 'Test company';
        testOpportunity.BillToContactEmailAddress__c = 'test@gmail.com';
        testOpportunity.BillToContactFirstName__c = 'Test';
        testOpportunity.BillToContactLastName__c = 'Test';
        testOpportunity.BillToContactSAP__c = 'Test';
        testOpportunity.BillToContactTelephoneNumber__c = '9999999999';
        testOpportunity.BillToCountryNew__c = 'IN';
        testOpportunity.BillToPostalZipCode__c = 'Test';
        testOpportunity.BillToStateProvince__c = 'Test state';
        testOpportunity.BillToStreet__c = 'Test street';
        
        testOpportunity.ShipToCity__c = 'Test city';
        testOpportunity.ShipToClientName__c = 'Test client';
        testOpportunity.ShipToCompanySAP__c = 'Test';
        testOpportunity.ShipToContactEmailAddress__c = 'ttest@gmail.com';
        testOpportunity.ShipToContactFirstName__c = 'Test';
        testOpportunity.ShipToContactLastName__c = 'Test';
        testOpportunity.ShipToContactSAP__c = 'Test';
        testOpportunity.ShipToContactTelephoneNumber__c = '8888888888';
        testOpportunity.ShipToCountryNew__c = 'IN';
        testOpportunity.ShipToPostalZipCode__c = 'Test';
        testOpportunity.ShipToStateProvince__c = 'Test';         
        testOpportunity.ShipToStreet__c = 'Test';
            
        update testOpportunity;
        
        Contract testContract = [SELECT Id, BillToCity__c, BillToClientName__c, BillToCompanySAP__c, BillToContactEmailAddress__c, BillToContactFirstName__c, BillToContactLastName__c,
                                 BillToContactSAP__c, BillToContactTelephoneNumber__c, BillToCountryCodeLookup__c, BillToPostalZipCode__c, BillToStateProvince__c, BillToStreet__c,
                                 ShipToCity__c, ShipToClientName__c, ShipToCompanySAP__c, ShipToContactEmailAddress__c, ShipToContactFirstName__c, ShipToContactLastName__c, ShipToContactSAP__c,
                                 ShipToContactTelephoneNumber__c, ShipToCountryCodeLookup__c, ShipToPostalZipCode__c, ShipToStateProvince__c, ShipToStreet__c
                                 FROM Contract Where Opportunity__c =: testOpportunity.Id LIMIT 1];
        
        System.assertEquals(testOpportunity.BillToCity__c, testContract.BillToCity__c);
        Test.stopTest();
    }
    
    /*
	* @author: Akshay Dogra
	* @date: 10th May 2021
	* @description: SFDC-4004: This method is for OpportunityMethods.opportunityContactRoleMandatory
	* @param null
	* @return void
	*/
    @isTest static void testOpportunityContactRoleMandatory() {
        Profile p = [SELECT Id ,name FROM Profile WHERE Name like '%General%' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert u;
        
        
        	Test.startTest();
                Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
                Opportunity testOpty = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Renewal Opppy'];
                testOpty.GlobalSegments__c = 'Financial Services';
                testOpty.ActivityCreated__c = true; 
                testOpty.StageName = '5-Renewal Contracting';
                update testOpty;
                // Assert to check the Stage Name Should be updated
                System.assertEquals('5-Renewal Contracting', [select id,StageName from Opportunity where id = :testOpty.id].StageName,'Opportunity stage should update to 5 renewal');
                System.runAs(u) {
                    Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
                    try {
                        testOpportunity.RecordTypeId = UtilityClass.getObjectRecordTypeId('Opportunity','Renewal');
                        Contact con = [SELECT Id, AccountId FROM Contact WHERE FirstName = 'TestSFDC3186'];
                        
                        OpportunityContactRole ocr = new OpportunityContactRole();
                        ocr.ContactId = con.Id;
                        ocr.OpportunityId = testOpportunity.Id;
                        ocr.IsPrimary = TRUE;
                        ocr.Role = '';
                        insert ocr;
                        
                        testOpportunity.GlobalSegments__c = 'Financial Services';
                        testOpportunity.StageName = '3-Proposal Development';
                        testOpportunity.ActivityCreated__c = true; 
                        update testOpportunity; 
                        
                    } catch(Exception e) {
                        Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.OpportunityContactRoleMissing) ? true : false;
                        // Assert to check correct Error is thrown
                        System.assertEquals(expectedExceptionThrown, true,'Checking the error message');
                        
                    }
                }
        	Test.stopTest();
        }
        
       
    
    
    
    @isTest static void testpopulateDateRiskFirstIdentified() {
        Opportunity testOpty = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        OpportunityLineItem testOLI = [Select Id, OpportunityId, IsProductatRisk__c, RiskStatus__c from OpportunityLineItem WHERE OpportunityId =: testOpty.Id LIMIT 1];
        testOLI.Status__c = 'Existing';
        testOLI.IsProductatRisk__c = 'Yes';
        Test.startTest(); 
        update testOLI;     
        Test.stopTest();
        Opportunity oppy = [Select Id, DateRiskFirstIdentified__c, NumberOfProductsAtRisk__c from Opportunity Where Id = :testOLI.OpportunityId limit 1];
        System.assertEquals(oppy.DateRiskFirstIdentified__c, System.today() , 'None of the Product is at Risk'); 
    }
    
    
    
    //-----------------------------
    // @author: Sharique
    // @date: 27 sept 2021
    // @param: NA
    // @description: Test method for Opportunity trigger methods testGlobalAllianceAccess()
    // @return: NA
    //-----------------------------    
    @isTest
    private static void testGlobalAllianceAccess() {
    
        Profile salesGeneralProfile = [SELECT Id, Name FROM Profile WHERE Name = 'IHSMarkit Sales: General' LIMIT 1];
        
        User salesGeneral = new User(FirstName='Sales', LastName='Coordinator', Email='salesGeneral@ihsmarkit.com', Alias = 'salesCd',
                                         ProfileId = salesGeneralProfile.Id, HRManager__c='manager', EmailEncodingKey ='UTF-8', 
                                         LocaleSidKey = 'en_US', LanguageLocaleKey='en_US', TimeZoneSidKey = 'America/Los_Angeles',
                                         UserName = 'salesGeneral@ihsmarkit.com', ADID__c = 'test'+system.now().millisecond(),
                                         EmployeeNumber = String.valueOf(Math.round(Math.random()*10000)),
                                         EmployeeNumber__c = String.valueOf(Math.round(Math.random()*10000)));
        insert salesGeneral;
		
        User sysAdmin = [SELECT Id FROM User Where Email = 'testUser1email@test.com.ihsmarkit.test'];
        System.runAs(sysAdmin) {
		 PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AllianceTeamAccess'];
         insert new PermissionSetAssignment(AssigneeId = salesGeneral.id, PermissionSetId = ps.Id);
        }
        
        Test.startTest();
        Opportunity testOpty = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        Contract testContract = [SELECT Id FROM Contract Where Opportunity__c =: testOpty.Id LIMIT 1];
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c='Financial Svcs-Info';
        update testContract;
        testOpty.StageName='6WP-Closed Won/Order Processed';
        update testOpty;
        
        Test.stopTest();
        
        System.runAs(salesGeneral) {
            try {
			  //Create opp and move from 6W to 6WP
			  testOpty.Name='Test Oppy 123';
			  update testOpty;
               // System.assert(opp == null);
            } catch (Exception e) {
                // do nothing, unit test will fail if reach this line
                system.assertEquals(true, e.getMessage() != null,'check exception.');
            }
        }
     }
    
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 26 Oct 2021
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateLegalEntity on Update
    // @return: NA
    //-----------------------------
    @isTest private static void testUpdateLegalEntity() {
        Opportunity testOpty = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        LegalEntity__c legalEntity = [SELECT Id FROM LegalEntity__c WHERE Name = 'testLegalEntity'];
        Test.startTest();
        testOpty.RequestedLegalEntity__c = legalEntity.id;
        testOpty.ExceptionStatus__c = 'Exception Requested';
        update testOpty;
        
        testOpty.ExceptionStatus__c = 'Exception Request Approved';
        update testOpty;
            
        Opportunity updatedOpp = [Select id, Name, LegalEntity__c from Opportunity where id = :testOpty.id];
        System.assertEquals(updatedOpp.LegalEntity__c, legalEntity.id, 'Legal Entity not updated');
        Test.stopTest();
        
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 12 jan 2022
    // @param: NA
    // @description: Test method for Opportunity trigger methods updateCloseDateOriginalToCloseDateValue
    // @return: NA
    //-----------------------------
    @isTest private static void testUpdateCloseDateoriginal() {
        
        Opportunity testOpty = [Select Id, CloseDate, CloseDateOriginal__c from Opportunity where Name = 'test Opppy 3186'];
        Test.startTest();
        System.assertEquals( testOpty.CloseDate, testOpty.CloseDateOriginal__c,'The Dates do not Match');
        Test.stopTest();
    }
    
    //-----------------------------
	// @author: Ankush Vedi Test Class
	// @date: 28 March 2022
	// @param: NA
	// @description: SFDC-5530 Test Method for Opportunity trigger methods UpdateCaseOpportunities
	// @return: NA
	//-----------------------------
    @isTest private static void testUpdateCaseOpportunities6W() {
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        Id nbOpptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
    	Integer nextFY = currentFY+1;
        
     	//Account acc = [SELECT Id FROM Account Where Name = 'Account testSetCaseAdditionalFieldsObject'];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE FirstName = 'TestSFDC3186'];
        Opportunity opp = [Select Id,GAM__c from opportunity where Name='test Opppy 3186'];
        
        Case testCase1 = TestUtility.createCase(resManagementRecordTypeId, con.AccountId, con.Id, 
                                  userInfo.getUserId(), 'Test subject update Account and Region', true);

        CaseOpportunities__c testCaseOpportunities1 = TestUtility.createCaseOpportunity(testCase1.id, opp.id, true); 
        
        
        Test.startTest();
        opp.StageName= '6WP-Closed Won/Order Processed';
        opp.RecordTypeId = nbOpptyRecordTypeId;
        Update opp;
        
        Case ca = [Select Id,ProjectStatus__c,ProjectAdditionalInformation__c from case  where Id =: testCase1.id];			
        System.assertEquals(ca.projectstatus__c,'Win','Contract updated'); 
        System.assertEquals(ca.ProjectAdditionalInformation__c, 'Win','Contract updated');  
        
        opp.StageName= '6L-Closed Lost';
        opp.LossReason__c = 'Price';
        opp.LostReasonCode__c='Unfavorable Pricing';
        opp.LostReasonDescription__c='Unfavorable Pricing';
        opp.RecordTypeId = nbOpptyRecordTypeId;
        Update opp;
        Case ca1 = [Select Id,ProjectStatus__c,ProjectAdditionalInformation__c from case  where Id =: testCase1.id];	
        System.assertEquals(ca1.projectstatus__c,'Loss','Contract Loss updated');  
        System.assertEquals(ca1.ProjectAdditionalInformation__c, 'Other','Contract Loss updated');
        
        opp.StageName= '3-Proposal Development';
        Update opp;
        Case ca2 = [Select Id,ProjectStatus__c,ProjectAdditionalInformation__c from case  where Id =: testCase1.id];	
        System.assertEquals(ca2.projectstatus__c,'Pending Result','case project status updated.'); 
        System.assertEquals(ca2.ProjectAdditionalInformation__c, 'Pending Decision','case additional information updated');
        Test.stopTest();
        
    }
}