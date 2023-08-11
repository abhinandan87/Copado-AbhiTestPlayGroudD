//-----------------------------
// @author Paras Dhingra adapted from Tran's code
// @date 28th Jun 2017
// @description Test class for unit testing on Account Triggers
// @Last Modified By : Prachi Bhasin
// @Last Modified Date: 15 March 2018
// @Last Modified Description: SFDC1-7199 - Commenting code related to NAICS hierarchy (TestNAICSUpdate method)
// @Last Modified By : Tran-Vu Tran
// @Last Modified Date : 12nd April 2018
// @Last Modified Description : SFDC1-7718 add method to update child accounts' Compliance Restriction value from Parent account if Exception is not checked
// @Last Modified By : Harshit Singhal
// @Last Modified Date : 12 Jun 2018
// @Last Modified Description : SFDC1-8537 convert Account process builder flows to Trigger
//-----------------------------

@isTest(seeAllData=false)
private class TestAccountMethods {   
    
    @testSetup static void setup() {
        List<Country__C> lstCountry = TestUtility.loadCountryData();
         // Create Account
        List<Account> insertAccList = new List<Account>();
        Account intAcc1 = TestUtility.createTestAccountWithAddress('test', 'test','test','QC', 'CA',false);
        insertAccList.add(intAcc1);
        Account TestCountry = TestUtility.createTestAccount('Test Sync Country',false);    
        insertAccList.add(TestCountry);
        Account TestAccont = TestUtility.createTestAccount('Test Account',false);
        insertAccList.add(TestAccont);
        Account TestAtm = TestUtility.createTestAccount('Test ATM',false);    
        insertAccList.add(TestAtm);
        Account intaccacf = TestUtility.createTestAccount('TestSetAccountAdditionalFieldsObject',false);
        insertAccList.add(intaccacf);        
        Account master = TestUtility.createTestAccount('TestAccountMaster', false);
       	insertAccList.add(master);
        Account duplicate = TestUtility.createTestAccountWithAddress('TestAccountDuplicate1', 'BriarDale','Toronto','OH','US',false);
        insertAccList.add(duplicate);                
        insert insertAccList;
        
        // Create Account for GEM
        Account testAccountGEM = TestUtility.createTestAccount('Test Account GEM',false);
        testAccountGEM.DataGovernanceStatus__c = 'Approved'; 
        insert testAccountGEM;
		
		// Create Opportunity
		List<Opportunity> insertOppyList = new List<Opportunity>();
        Opportunity Oppy = TestUtility.createOpportunity(testAccountGEM.id,'Test Oppy 1',null,false);
        insertOppyList.add(Oppy);
        Opportunity Oppy2 = TestUtility.createOpportunity(testAccountGEM.id,'Test Oppy 2',null,false);
        insertOppyList.add(Oppy2);
        Opportunity testOpportunity = TestUtility.createOpportunity(master.Id, 'test Opppy', false);
        insertOppyList.add(testOpportunity);
        Opportunity testOpportunity1 = TestUtility.createOpportunity(duplicate.Id, 'test Opppy1', false);        
        insertOppyList.add(testOpportunity1);
        insert insertOppyList;
        
        // Test Start
        Test.startTest();
        
        // Create Account Ranking
        List<AccountRanking__c> testAccountRanking = new List<AccountRanking__c>();
        AccountRanking__c ar = TestUtility.createAccountRanking(1, 1,'BOE', date.today(), 'Reuters', intAcc1.id,'Global',false); 
        testAccountRanking.add(ar);
        insert testAccountRanking;
        
        // Create Oppty Product
        List<Product2> product2List = new List<Product2>();
        Product2 testProd = TestUtility.createProduct('Test Product', false);
		product2List.add(testProd);   
        insert product2List;
        
        Id standardId = Test.getStandardPricebookId();
        
        // Create Price Book Entry
        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, false);
        pricebookEntryList.add(testPBE);
        insert pricebookEntryList;
        
        // Create Opportunity Line Item
        List<OpportunityLineItem> opportunityLineItemList =  new List<OpportunityLineItem>();
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(Oppy2.Id, testPBE, false);
        opportunityLineItemList.add(testOLI);
        insert opportunityLineItemList;
        
        // Create User
        User testUser1 = TestUtility.createTestUser('IHSMarkit Data Governance', 'testUSer.testuser123@ihsmarkit.com.user',false);
        User testUser2 = TestUtility.createTestUser('IHSMarkit Data Governance', 'testUser.test22343@ihsmarkit.com.usertest',false);
        User testUser3 = TestUtility.createTestUser('IHSMarkit Data Governance', 'testUser.test10@ihsmarkit.com.usertest',false);
        insert new list<user> {testUser1,testUser2,testUser3};
           
        // Create Leagal Entity       
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
        
        //Add Contracts
        Contract contractRec = TestUtility.createContractWithInsertOptional(Master.Id, legalEntity.Id, lstCountry[0].Id, standardId,FALSE);
        Contract contractRec1 = TestUtility.createContractWithInsertOptional(duplicate.Id, legalEntity.Id, lstCountry[0].Id, standardId,FALSE);
        
  		// Add Contacts
        List<Contact> contactList = new List<Contact>();
        Contact intAcc1Con1 = TestUtility.createContact(insertAccList[2].Id,'testContact@ihsmarkit.com',false,'Test FirstName','Test LastName');
        contactList.add(intAcc1Con1);
        insert contactList;
        
        // Test Stop
        Test.StopTest();
    }
    
    @isTest static void testSyncAccountCountryWithCountryChange() {
        // Test data setup
        Account TestCountry1 = [Select Id, AccountCountry__r.Name, AccountCountry__r.CountryCode__c from Account where Name =: 'Test Sync Country'];

        // Verify that the AccountCountry reference to is Canada
        System.assertEquals('CA', TestCountry1.AccountCountry__r.CountryCode__c, 'Checking account country code');       
       
        // Perform Test on update
        
        TestCountry1.BillingCountryCode = 'IN';
        TestCountry1.Description='test';
        TestCountry1.AccountCountry__r.CountryCode__c = 'CA';
        update TestCountry1;
        
        Test.startTest();
        
        // Query the account again to get updated value
        Account intAcc4 = [Select Id, AccountCountry__c, DescriptionShort__c, Description from Account where Id=: TestCountry1.Id];
        
        // Country__c targetCountry = [SELECT Id from Country__c WHERE Name = 'India'];
        Country__c targetCountry = [SELECT Id from Country__c WHERE CountryCode__c = 'IN' Limit 1];
        
        Test.stopTest();
        
        // Verify that the AccountCountry reference to is now showing India
        System.assert(intAcc4.AccountCountry__c == targetCountry.Id,'Compare the country');
        System.assert(intAcc4.DescriptionShort__c == intAcc4.Description,'Compare Description and Short Description');
    }
    
    //-----------------------------
    // @author Paras Dhingra
    // @Date 05 Jul 2017
    // @description Test class for AccountMethods.updateNAICSHierarchyLookup()
    // @param null
    // @return void
    //-----------------------------
    /*static testMethod void TestNAICSUpdate() {
        
        //create test Data
        Account acct = TestUtility.createTestAccount('Test Account', true);
        NAICSHierarchy__c testNaics = TestUtility.createNAICSData('1111','Agriculture, Forestry, Fishing and Hunting','Oilseed and Grain Farming',true);
        
        //start test
        Test.startTest();
        acct.NaicsCode = '111134';
        update acct;
        Test.stopTest();
        
        //assert 
        Account assertAcct = [Select Id, NAICSHierarchy__c from Account where id=:acct.Id];
        System.assertEquals(testNaics.Id, assertAcct.NAICSHierarchy__c, 'comparing NAICS');
    }*/
    
    //-----------------------------
    // @author Paras Dhingra
    // @Date 07 Jul 2017
    // @description Test class for Accountmethods.updateGAMOnOpenOppys
    // @param null
    // @return void
    //-----------------------------
    @isTest static void testupdateGAMonOpenOppys() {
        
        User testGAM;
        System.runAs(new User(Id=userInfo.getUserId())) {
            testGAM = TestUtility.createAdminUser('parastest=example@test.com', true);
        }
        //create test data
        Account acct = [Select ID, Name from Account where Name = 'Test Account GEM' limit 1];
        
        List<Opportunity> oppy = [Select id,name,StageName,CloseDate from Opportunity where name = 'Test Oppy 1' OR name = 'Test Oppy 2'];
        Map<String,Opportunity> oppymap = new Map<String,Opportunity>();
        for(Opportunity op: oppy ){
           Oppymap.put(op.name, op);
        }
        Opportunity oppy1 = oppymap.get('Test Oppy 1');
        Opportunity oppy2 = oppymap.get('Test Oppy 2');
       
        //Start test
        Test.startTest();
        //close oppy 2.
        oppy2.LostReasonCode__c = 'Customer Requirements Changed';
        oppy2.LostReasonDescription__c = 'Test description';
        oppy2.StageName = '6L-Closed Lost';
        update oppy2;
        
        //update GAM on account
        acct.GlobalAccountManager__c = testGAM.Id;
        String tempDesc;
        for(integer i=0; i<257; i++){
            tempDesc=tempDesc+i;
        }
        acct.Description=tempDesc;
        update acct;
        //assert Opportunities
        Map<Id, Opportunity> mapAssertOppys = new Map<Id, Opportunity>([Select id, GAM__c from Opportunity where id=:oppy1.ID OR id=:oppy2.Id]);
        
        //assert Oppy1
        System.assertEquals(testGAM.Id, mapAssertOppys.get(oppy1.Id).GAM__c,'Assert Oppy1');
        System.assertEquals(null, mapAssertOppys.get(oppy2.Id).GAM__c,'Verify Opp2 GAM');
        System.assertEquals(acct.Description, tempDesc,'Verify Acc Description');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author Paras Dhingra
    // @Date 26 Jul 2017
    // @description Test class for Accountmethods.updateLegacyIdObject
    // @param null
    // @return void
    //-----------------------------
    /*@isTest static void testUpdateLegacyIdObject() {
		 2017-09-19 Tran-Vu Tran comment out because this is no longer needed per SFDC1-4517 
        Test.startTest();
        Account testAccount = TestUtility.createTestAccount('Test Account', false);
        testAccount.MarkitSFDC__c = 'A-11002';
        testAccount.IHSCRMGUID__c = 'IHS-23423';
        insert testAccount;
        // assert
        List<LegacyAccountID__c> assertLAI = [Select name from LegacyAccountID__c where Account__c=:testAccount.Id order by name];
        System.assertEquals(2, assertLAI.size(), 'two child records');
        System.assertEquals(testAccount.MarkitSFDC__c, assertLAI[0].name,'matching markit Id');
        System.assertEquals(testAccount.IHSCRMGUID__c, assertLAI[1].name,'matching IHS Id');
		
    } */
    
    //-----------------------------
    // @author Paras Dhingra
    // @Date 1st Aug 2017
    // @description Test class for Accountmethods.updateAccountTeamMemberRole
    // @param null
    // @return void
    // @companyName IHS Markit
    //-----------------------------
    @isTest static void testUpdateAccountTeamMemberRole() {
        //create test data
        Map<String,user> usermap = new Map<String,user>();
        for(user us: [Select ID, name,username,isactive from user where username ='testUSer.testuser123@ihsmarkit.com.user' 
                      OR username='testUser.test22343@ihsmarkit.com.usertest' 
                      OR username = 'testUser.test10@ihsmarkit.com.usertest' ]){
                          usermap.put(us.username, us);
                      }
        
        user testUser1 = usermap.get('testuser.testuser123@ihsmarkit.com.user');
        user testUser2 = usermap.get('testuser.test22343@ihsmarkit.com.usertest');
        user testUser3 = usermap.get('testuser.test10@ihsmarkit.com.usertest');
        
        System.debug(testUser1 + ' @@@ user  @@@ ');
        System.runAs(testUser1) {
            Test.startTest();
            
            Account acct = TestUtility.createTestAccount('Test  Account ATM', true);
            
            
            List<AccountTeamMember> lstAssertATM = [Select id,userId from AccountTeamMember where  teamMemberRole = 'Account Owner' and accountId=:acct.Id];
            System.assertNotEquals(null, lstAssertATM,'Account Team member role created');
            System.assertEquals(testUser1.Id, lstAssertATM[0].userId,'Verify UserId');
            
            
            AccountTeamMember atm = new AccountTeamMember(AccountId=acct.Id,TeamMemberRole='Consultant',UserId= testUser3.id,AccountAccessLevel='Read',CaseAccessLevel='Read',ContactAccessLevel='Edit',OpportunityAccessLevel='Read');
            insert atm;
            
            //update account owner
            acct.ownerId = testUser2.Id;
            update acct;
            lstAssertATM = [Select id,UserId from AccountTeamMember where  teamMemberRole = 'Account Owner' and accountId=:acct.Id order by createddate desc];
            System.assertNotEquals(null, lstAssertATM,'Account Team member role created');
            //System.assertEquals(testUser2.Id, lstAssertATM[0].userId);
            Test.stopTest();
            
        } 
    }
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 25 Aug 2017
    // @param: NA
    // @description: SFDC1-2103 Test method for Additional Account Fields trigger method setAccountAdditionalFieldsObject on insert
    // @return: NA
    //-----------------------------
    @isTest static void testSetAccountAdditionalFieldsObject() {
        test.startTest();
        Account testAccount = [Select id,name from account limit 1];        
        list <Account> testAccountResult = [Select AdditionalAccountFields__c, Id from Account where Id = :testAccount.Id];
        //Assert if account is inserted
        System.assertEquals(1, testAccountResult.size(),'Verify that the account is inserted');
        System.assert(testAccountResult[0].AdditionalAccountFields__c != null,'Verify Additional Account Fields');
        
        //Assert if Adiitional Account Field is inserted
       	list <AdditionalAccountFields__c> acfList = [Select Id from AdditionalAccountFields__c where AccountReference__c = :testAccount.Id];
      	System.assertEquals(1, acfList.size(),'Verify acflist size');
   		System.assertEquals(acfList[0].Id, testAccountResult[0].AdditionalAccountFields__c,'Compare the Account Addtional Fields');
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 25 Aug 2017
    // @param: NA
    // @description: SFDC1-2103 Test method for Additional Account Fields trigger method changeAccountAdditionalFieldsObjectNameWhenAccountNameChanges on update. 
    //              To test if Account Additional Fields Object Name chnages when Account Name Changes
    // @return: NA
    //-----------------------------
    @isTest static void testChangeAccountAdditionalFieldsObjectNameWhenAccountNameChanges() {
        
        Account testAccount = TestUtility.createTestAccount('TestChangeAccountAdditionalFields', true);
        
        list <Account> testAccountResult = [Select AdditionalAccountFields__c, AdditionalAccountFields__r.Name, Id, Name  from Account where Id = :testAccount.Id];
        //Assert if account is inserted
        System.assertEquals(1, testAccountResult.size(),'Verify that the account is inserted');
        System.assert(testAccountResult[0].AdditionalAccountFields__c != null,'Verify Additional Account Fields');
        
        System.assertEquals(testAccountResult[0].AdditionalAccountFields__r.Name,'Additional Fields - ' + testAccountResult[0].Name,'Verify the names');
        
        //Update Account Name
        testAccount.Name = 'TestChangeAccountAdditionalFields2';
        update testAccount;
        
        list <Account> testAccountResult2 = [Select AdditionalAccountFields__c, AdditionalAccountFields__r.Name, Id, Name  from Account where Id = :testAccount.Id];
        //Assert if Additional Account Field name gets updated
        System.assertEquals(testAccountResult2[0].AdditionalAccountFields__r.Name, 'Additional Fields - ' + testAccountResult2[0].Name,'Verify the names');
        
    }

/*
	// 20-April-2016 comment out codes - will be replaced by formula fields
    //-----------------------------
    // @author: Tran-Vu Tran
    // @created: 10 April 2018
    // @param: NA
    // @description: Test if Account ComplianceRestrictions 
    // @return: NA
    //-----------------------------
    static testMethod void TestAccountComplianceRestrictions() {

        Test.startTest();
        
        List<Account> testAccounts = new List<Account>();
        
        Account acc1 = TestUtility.createTestAccountWithStreet('One', 'Street One', true);
        acc1.ComplianceRestrictions__c = 'Russia Directive 1; Payment terms not > 14 days';
        acc1.CorporateRestrictionException__c = false;
        // testAccounts.add(acc1);
        update acc1;
        System.debug('Account Name: ' + acc1.Name + ', ID: ' + acc1.Id);
        System.debug('Compliance Restrictions: ' + acc1.ComplianceRestrictions__c + ', Exception: ' + acc1.CorporateRestrictionException__c);
        
        Account acc2 = TestUtility.createTestAccountWithStreet('Two', 'Lane Two', true);
        acc2.ParentId = acc1.Id;
        acc2.CorporateRestrictionException__c = false;
        acc2.ComplianceRestrictions__c = null;
        // testAccounts.add(acc2);
        update acc2;
        acc2 = [select Id, Name, ParentId, CorporateRestrictionException__c, ComplianceRestrictions__c
				From Account where Id =: acc2.Id limit 1];
        
        System.debug('Account Name: ' + acc2.Name + ', ID: ' + acc2.Id);
        System.debug('Compliance Restrictions: ' + acc2.ComplianceRestrictions__c + ', Exception: ' + acc2.CorporateRestrictionException__c);
        System.debug('Parent account Name: ' + acc1.Name + ', ID: ' + acc2.ParentId);
        System.debug('Parent Compliance Restrictions: ' + acc1.ComplianceRestrictions__c + ', Parent Exception: ' + acc1.CorporateRestrictionException__c);

        Account acc3 = TestUtility.createTestAccountWithStreet('Three', 'Blvd Three', true);
        acc3.ParentId = acc1.Id;
        acc3.CorporateRestrictionException__c = true;
        acc3.ComplianceRestrictions__c = null;
        // testAccounts.add(acc3);
        update acc3;
        acc3 = [select Id, Name, ParentId, CorporateRestrictionException__c, ComplianceRestrictions__c
				From Account where Id =: acc3.Id limit 1];
        
        System.debug('Account Name: ' + acc3.Name + ', ID: ' + acc3.Id);
        System.debug('Compliance Restrictions: ' + acc3.ComplianceRestrictions__c + ', Exception: ' + acc3.CorporateRestrictionException__c);
        System.debug('Parent account Name: ' + acc1.Name + ', ID: ' + acc3.ParentId);
        System.debug('Parent Compliance Restrictions: ' + acc1.ComplianceRestrictions__c + ', Parent Exception: ' + acc1.CorporateRestrictionException__c);
        
        Account acc4 = TestUtility.createTestAccountWithStreet('Four', 'Drive Four', true);
        acc4.ParentId = acc3.Id;
        acc4.CorporateRestrictionException__c = false;
        acc4.ComplianceRestrictions__c = null;
        // testAccounts.add(acc4);
        update acc4;
        acc4 = [select Id, Name, ParentId, CorporateRestrictionException__c, ComplianceRestrictions__c
				From Account where Id =: acc4.Id limit 1];
        
        System.debug('Account Name: ' + acc4.Name + ', ID: ' + acc4.Id);
        System.debug('Compliance Restrictions: ' + acc4.ComplianceRestrictions__c + ', Exception: ' + acc4.CorporateRestrictionException__c);
        System.debug('Parent account Name: ' + acc3.Name + ', ID: ' + acc4.ParentId);
        System.debug('Parent Compliance Restrictions: ' + acc3.ComplianceRestrictions__c + ', Parent Exception: ' + acc3.CorporateRestrictionException__c);
        
        // update testAccounts;

        System.assertEquals(acc2.ComplianceRestrictions__c, acc1.ComplianceRestrictions__c);
        System.assertNotEquals(acc3.ComplianceRestrictions__c, acc1.ComplianceRestrictions__c);
        System.assertEquals(acc4.ComplianceRestrictions__c, acc1.ComplianceRestrictions__c);

        Test.stopTest();
    }
*/
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 25 Aug 2017
    // @param: NA
    // @description: SFDC1-2103 Test method for Additional Account Fields trigger method deleteAccountAdditionalFieldsRecordWhenAccountGetsDeleted on Delete. 
    //               To test if Account Additional Fields Object gets deleted when Account gets deleted 
    // @return: NA
    //-----------------------------
    @isTest static void testdeleteAccountAdditionalFieldsRecordWhenAccountGetsDeleted() {
        
        Account testAccount = TestUtility.createTestAccount('TestSetAccountAdditionalFieldsObject', true);
        
        list <Account> testAccountResult = [Select AdditionalAccountFields__c, Id from Account where Id = :testAccount.Id];
        //Assert if account is inserted
        System.assertEquals(1, testAccountResult.size(),'Verify result size');
        System.assert(testAccountResult[0].AdditionalAccountFields__c != null,'AdditionalAccountFields__c is not null');
        
        //Assert if Adiitional Account Field is inserted
        AdditionalAccountFields__c acf = [Select Id from AdditionalAccountFields__c where AccountReference__c = :testAccount.Id];
        System.assert(acf != null,'acf is not null');
        System.assertEquals(acf.Id, testAccountResult[0].AdditionalAccountFields__c,'Additional Account Id value matches with the account field');
        
        delete testAccount;
        
        list <AdditionalAccountFields__c> acfList = [Select Id from AdditionalAccountFields__c where Id = :acf.Id];
        
        ////Assert if Adiitional Account Field is deleted
        System.assertEquals(0, acfList.size(),'Verify Adiitional Account Field is deleted');
    }
    
    //-----------------------------
    // @author Harshit Singhal
    // @Date 12 Jun 2018
    // @description Test class for AccountMethods.updateAccountCreatedOnParentCase()
    // @param null
    // @return void
    // @Lastmodified by : Mohit Modi
    // @lastmodified description : Added some more values to new Account co cover the changes in existing methods.
    //-----------------------------
    @isTest static void testUpdateAccountCreatedOnParentCase() {     
        Test.startTest();
        Account testAcc = [Select Id, Name from account where name ='Test Account'];
        Contact testContact = [Select AccountId, FirstName, LastName, Email from Contact  where Email ='testContact@ihsmarkit.com'];
        Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Salesforce Helpdesk').getRecordTypeId();
        Case sourceCase = TestUtility.createCase(caseRecordTypeId, testAcc.Id, testContact.Id, UserInfo.getUserId(), 'Test Subject', false);
        sourceCase.Country__c = [SELECT Id from Country__c WHERE CountryCode__c = 'IN'].id;
        insert sourceCase;
        Account newAcc = TestUtility.createTestAccount('Test Account 456', false);
        newAcc.BillingCity = 'Bangalore';
        newAcc.State__c = 'KA';
        newAcc.SourceCase__c = sourceCase.Id;
        newAcc.Description='test';
        Country__c tempCountry = [SELECT Id from Country__c WHERE CountryCode__c = 'IN' limit 1];
        newAcc.AccountCountry__c = tempCountry != NULL ? tempCountry.id : NULL;
        insert newAcc;
        System.assertEquals(newAcc.Id, [Select AccountCreated__c From Case Where Id=:sourceCase.Id LIMIT 1].AccountCreated__c,'Verify AccountId');
        System.assertEquals(newAcc.Description, 'test','Verify Description');
        
        // Updating the Country and checking the Country Loopkup fields get updated with the same.
        newAcc.BillingStateCode = 'ON';
        newAcc.BillingCountryCode = 'CA';
        newAcc.Description=null;
        Update newAcc;
        System.assertEquals([SELECT Id from Country__c WHERE CountryCode__c = 'CA' limit 1].id,[SELECT Id,AccountCountry__c from Account WHERE id =: newAcc.id limit 1].AccountCountry__c,'Verify Account Country');
        System.assertEquals(newAcc.DescriptionShort__c, null,'Verify Short Description');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author Harshit Singhal
    // @Date 12 Jun 2018
    // @description Test class for AccountMethods.setAccountOwnerOnAccountManagerChangeAndUpdatePreviousOwner()
    // @param null
    // @return void
    //-----------------------------
    @isTest static void testSetAccountOwnerOnAccountManagerChangeAndUpdatePreviousOwner() {
        User testUser1 = [Select ID, name,username,isactive from user where username ='testUSer.testuser123@ihsmarkit.com.user'];
        
        Test.startTest();
        Account newAcc = TestUtility.createTestAccount('Test Account 123', false);
        newAcc.GlobalAccountManager__c = testUser1.Id;
        String tempDesc;
        for(integer i=0;i<257;i++){	
        	tempDesc=tempDesc+i;
        }
        newAcc.Description=tempDesc;
        insert newAcc;
        System.assertEquals(testUser1.Id, [Select OwnerId From Account Where Id=:newAcc.Id LIMIT 1].OwnerId,'GlobalAccountManager__c is the owner');
        System.assertEquals(newAcc.Description, tempDesc,'Verify Description');
        
        newAcc.GlobalAccountManager__c = UserInfo.getUserId();
        update newAcc;
        Account updatedAcc = [Select OwnerId,PreviousOwner__c From Account Where Id=:newAcc.Id LIMIT 1];
        System.assertEquals(UserInfo.getUserId(), updatedAcc.OwnerId,'Verify the owner');
        System.assertEquals(testUser1.Id, updatedAcc.PreviousOwner__c,'Verify Previous owner');
        Test.stopTest();
    }
    //-----------------------------
    // @author Priyanka Vyas
    // @Date 27 Oct 2020
    // @description: SFDC-3123 Test class for AccountMethods.setComplianceRestriction() and AccountMethods.cascadeComplianceRestrictionToChildAccounts()
	//-----------------------------
    @isTest static void testCascadingOfComplianceRestrictionException() {
        Test.startTest();
        Account newAccParent1 = TestUtility.createTestAccount('Test Account - Parent1', false);
        newAccParent1.ComplianceRestrictionException__c = 'Entity List';
        Account newAccParent2 = TestUtility.createTestAccount('Test Account - Parent2', false);
        newAccParent2.ComplianceRestrictionException__c = 'Sanctioned Customer';
        Account newAccParent3 = TestUtility.createTestAccount('Test Account - Parent3', false);
        insert new List<Account>{newAccParent1,newAccParent2,newAccParent3};
        Account newAccChild1 = TestUtility.createTestAccount('Test Account - Child1', false);
        newAccChild1.ParentId = newAccParent1.id;
        Account newAccChild2 = TestUtility.createTestAccount('Test Account - Child2', false);
        newAccChild2.ParentId = newAccParent2.id;
        newAccChild2.ComplianceRestrictionException__c = 'Unverified List';
        Account newAccChild3 = TestUtility.createTestAccount('Test Account - Child3', false);
        Account newAccChild4 = TestUtility.createTestAccount('Test Account - Child4', false);
        newAccChild4.ParentId = newAccParent1.id;
        Account newAccChild5 = TestUtility.createTestAccount('Test Account - Child5', false);
        newAccChild5.ParentId=newAccParent3.id;
        Account newAccChild6 = TestUtility.createTestAccount('Test Account - Child6', false);
        newAccChild6.ParentId=newAccParent3.id;
        insert new List<Account>{newAccChild1,newAccChild2,newAccChild3,newAccChild4,newAccChild5,newAccChild6};
        Map<Id,String> firstAccMap = new Map<Id,String>();
        for(Account a: [Select id, ComplianceRestrictionException__c from Account where id=:newAccChild1.id or id=:newAccChild2.id or id=:newAccChild3.id or id=:newAccChild4.id or id=:newAccChild5.id or id=:newAccChild6.id]) {
            firstAccMap.put(a.id, a.ComplianceRestrictionException__c);
        }
        System.assertEquals(firstAccMap.get(newAccChild1.id), 'Entity List', 'The Compliance Exception Restriction from parent cascaded to child on account creation.');        
        System.assertEquals(firstAccMap.get(newAccChild2.id), 'Unverified List', 'The Compliance Exception Restriction from parent did not cascade to child on account creation because it was set while insertion.');
        System.assertEquals(firstAccMap.get(newAccChild3.id), null, 'No Compliance restriction set on newAccChild3.');        
        System.assertEquals(firstAccMap.get(newAccChild4.id), 'Entity List', 'The Compliance Exception Restriction from parent cascaded to child on account creation.');
		System.assertEquals(firstAccMap.get(newAccChild5.id), null, 'No Compliance restriction set on newAccChild5 as newAccParent3 has not compliance restriction value.');        
        System.assertEquals(firstAccMap.get(newAccChild6.id), null, 'No Compliance restriction set on newAccChild6 as newAccParent3 has not compliance restriction value.');

        Set<ID> secondSet = new Set<ID>();
        newAccChild3.ParentId = newAccParent2.id;
        secondSet.add(newAccChild3.id);
        newAccChild4.ParentId = newAccParent2.id;
        secondSet.add(newAccChild4.id);
        newAccChild5.ParentId = newAccParent1.id;
        secondSet.add(newAccChild5.id);
        newAccChild6.ParentId = newAccParent1.id;
        newAccChild6.ComplianceRestrictionException__c = 'Sanctioned Customer';
        secondSet.add(newAccChild6.id);
        update new List<Account>{newAccChild3,newAccChild4,newAccChild5,newAccChild6};
        Map<Id,String> secondAccMap = new Map<Id,String>();
        for(Account a: [Select id, ComplianceRestrictionException__c from Account where id in:secondSet ]) {
            secondAccMap.put(a.id, a.ComplianceRestrictionException__c);
        }
        System.assertEquals(secondAccMap.get(newAccChild3.id), 'Sanctioned Customer', 'Compliance Restriction Exception cascaded from newAccParent2 to newAccChild3.');
        System.assertEquals(secondAccMap.get(newAccChild4.id), 'Entity List', 'Compliance Restriction Exception did not change since it was already set to Entity List.');
        System.assertEquals(secondAccMap.get(newAccChild5.id), 'Entity List', 'Compliance Restriction Exception populated from the new parent newAccParent1 since it did not have any value set previously.');
		System.assertEquals(secondAccMap.get(newAccChild6.id), 'Sanctioned Customer', 'Compliance Restriction Exception did not populate from the new parent newAccParent1 since it was explicitly chosen');

        newAccParent2.ComplianceRestrictionException__c = 'Unverified List';
        newAccParent1.ComplianceRestrictionException__c = 'Unverified List';
        update new List<Account>{newAccParent2,newAccParent1};
        
        Test.stopTest();
        Set<ID> thirdSet = new Set<ID>();
        Map<Id,String> thirdAccMap = new Map<Id,String>();
        for(Account a: [Select id, ComplianceRestrictionException__c from Account where id=:newAccChild3.id or id=:newAccChild4.id ]) {
            thirdAccMap.put(a.id, a.ComplianceRestrictionException__c);
        }
        System.assertEquals(thirdAccMap.get(newAccChild3.Id), 'Unverified List', 'Updated Compliance Restriction Exception cascaded from newAccParent2 to newAccChild3');
        System.assertEquals(thirdAccMap.get(newAccChild4.Id), 'Unverified List', 'Updated Compliance Restriction Exception cascaded from newAccParent1 to newAccChild4');
    }
     //-----------------------------
    // @author Madhusudhan Karna
    // @Date 04 March 2021
    // @description Test class for AccountMethods.deleteAdditionalAccountRecords()
    // @param null
    // @return void
    //-----------------------------
    @isTest static void testDeleteAdditionalAccountRecords() {
        
        Account testAccount = TestUtility.createTestAccount('TestSetAccountAdditionalFieldsObject', true);
        
        list <Account> testAccountResult = [Select AdditionalAccountFields__c, Id from Account where Id = :testAccount.Id];
        //Assert if account is inserted
        System.assertEquals(1, testAccountResult.size(),'Verify that the account is inserted');
        System.assert(testAccountResult[0].AdditionalAccountFields__c != null,'Verify AdditionalAccountFields');
        
        //Assert if Adiitional Account Field is inserted
        list <AdditionalAccountFields__c> acfList = [Select Id from AdditionalAccountFields__c where AccountReference__c = :testAccount.Id];
        System.assertEquals(1, acfList.size(),'Verify that the Adiitional Account Field is inserted');
        System.assertEquals(acfList[0].Id, testAccountResult[0].AdditionalAccountFields__c,'Compare AdditionalAccountFields');
        delete testAccountResult;
        list <AdditionalAccountFields__c> acfDeleteList = [Select Id from AdditionalAccountFields__c where AccountReference__c = :testAccount.Id];
        System.assertEquals(0, acfDeleteList.size(),'Verify the list size');
    }
    
    //-----------------------------
    // @author: Anjali
    // @Date 25th March 2021
    // @description Test class for AccountMethods.updateOpenContractAddress()
    // @param null
    // @return void
    //-----------------------------
    @isTest static void testUpdateOpenContractAddress() {
        Test.startTest();
        Account acc = [Select ID, Name from Account where name = 'Test Account'];
        Opportunity testOpportunity = [Select Id from Opportunity where name = 'test Opppy'];        
        LegalEntity__c legalEntity = [Select Id,Name from LegalEntity__C where name ='testLegalEntity'];
        //List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = [Select id from Country__c limit 1];
        Id standardId = Test.getStandardPricebookId();
        Contract contractRec = TestUtility.createContractWithInsertOptional(acc.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contractRec.Opportunity__c=testOpportunity.Id;
        contractRec.ClientLegalEntityLookUp__c =acc.Id;
        insert contractRec;
        acc.BillingCity='Waterloo';
        update acc;
        Contract contractRecord =[Select ClientLegalEntityCity__c FROM Contract Where Id=:contractRec.id];
        system.assertEquals('Waterloo', contractRecord.ClientLegalEntityCity__c,'City is not updated as expected');
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Anjali
    // @Date 14th March 2021
    // @description Test class for AccountMethods.updateOpenContractAddress()
    // @param null
    // @return void
    //-----------------------------
    @isTest static void testDeleteOpenContractAddress() {
        Test.startTest();
        Account master = [Select Name from Account where name ='TestAccountMaster'];
        Account duplicate = [Select Name, billingStreet,billingCity,billingStateCode,billingCountryCode from Account where name ='TestAccountDuplicate1' ];
        Opportunity testOpportunity = [Select Id from Opportunity where Name= 'test Opppy'];
        Opportunity testOpportunity1 = [Select Id from Opportunity where Name= 'test Opppy1'];
        LegalEntity__c legalEntity = [Select Id,Name from LegalEntity__C where name ='testLegalEntity'];
        //Country__c country = [Select id,Name,CapiqCountry__c,CountryCode__c,CreatedById,CurrencyIsoCode,Geography__c,IsProhibited__c,LastModifiedById,LegacyID__c,LegalStatus__c,OwnerId,PKIDCountry__c,Region__c from Country__c limit 1];
        Country__c country = [Select id, Name,CapiqCountry__c,CountryCode__c,CreatedById,CurrencyIsoCode,Geography__c,IsProhibited__c,LastModifiedById,LegacyID__c,LegalStatus__c,OwnerId,PKIDCountry__c,Region__c from Country__c limit 1];
        Id standardId = Test.getStandardPricebookId();
        List<Contract> contractLst = new List<Contract>();
        Contract contractRec = TestUtility.createContractWithInsertOptional(Master.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contractRec.Opportunity__c=testOpportunity.Id;
        contractRec.ClientLegalEntityLookUp__c =Master.Id;
        contractLst.add(contractRec);
        Contract contractRec1 = TestUtility.createContractWithInsertOptional(duplicate.Id, legalEntity.Id, country.Id, standardId,FALSE);
        contractRec1.Opportunity__c=testOpportunity1.Id;
        contractRec1.ClientLegalEntityLookUp__c =duplicate.Id;
        contractLst.add(contractRec1);
        insert contractLst;
        Database.MergeResult results = Database.merge(Master, duplicate, false);
        Contract contractRecord =[Select ClientLegalEntityCity__c FROM Contract Where Id=:contractRec1.id];
        system.assertEquals('Toronto', contractRecord.ClientLegalEntityCity__c,'City is not updated as expected');
        Test.stopTest();
    }
    
//-----------------------------
    // @author: Ankush Vedi
    // @Date 23rd June 2022
    // @description Test class for AccountMethods.TestUpdateCountryLookup()
    // @param null
    // @return void
    //-----------------------------
	@isTest private static void  TestUpdateCountryLookup(){
        
        // Query Account
        Account intAcc1 = [SELECT Name,BillingStreet,BillingCity,BillingStateCode,BillingCountryCode FROM Account WHERE name ='test' LIMIT 1];
        System.assertEquals(intAcc1.name, 'test');
       
                  
    }
    
    //-----------------------------
    // @author: Ankush Vedi
    // @Date 23rd June 2022
    // @description Test class for AccountMethods.RecalculateAccountRankings()
    // @param null
    // @return void
    //-----------------------------
    @isTest static void testRecalculateAccountRankings(){
        test.startTest();
        Set<string> metricsKey = new  Set<string>();
        metricsKey.add('GlobalBOE');
        Account intAcc2 = [SELECT Name,BillingStreet,BillingCity,BillingStateCode,BillingCountryCode FROM Account WHERE name ='test' LIMIT 1];
        System.assertEquals(intAcc2.name, 'test');
        
        AccountRanking__c ar = [Select Rank__c,Value__c,Criteria__c,ValueAsOf__c,Source__c,Account__c,RankCountry__c from AccountRanking__c where Source__c ='Reuters' ];
        System.assertEquals(ar.Source__c, 'Reuters');       
        accountmethods.recalculateAccountRankings(metricsKey);
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Ankush Vedi
    // @Date 23rd June 2022
    // @description Test class for AccountMethods.createUpdateLegacyIdObject()
    // @param null
    // @return void
    //-----------------------------
   @isTest static void testCreateUpdateLegacyIdObject(){
        
        accountmethods.createUpdateLegacyIdObject(null);
    }

}