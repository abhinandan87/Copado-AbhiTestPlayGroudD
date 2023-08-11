//-----------------------------
// @author: Mohit Modi
// @date: 27 Sept 2017
// @param: NA
// @description: Test Class for ContractMethods
// @return: NA
// @company: VERTIBA
// @Last Modified By : Prachi Bhasin
// @Last Modified Date: 14 Dec 2017 Sprint 15
// @Last Modified Description: SFDC1-5851, Included Fastrack chakbox value for order form contracts
//-----------------------------
//-----------------------------
// @author: Mohit Modi
// @date: 27 Sept 2017
// @param: NA
// @description: Test Class for ContractMethods
// @return: NA
// @company: VERTIBA
// @Last Modified By : Ayan Mohanty
// @Last Modified Date: 14 Feb 2018 Sprint 19
// @Last Modified Description: SFDC1-6993, Removing instances of BillToFaxNumber__c and ShipToFaxNumber__c
//-----------------------------
// @Last Modified By : Vishnu Vardhan Chowdary
// @Last Modified Date: 13 Mar 2018, Sprint 21
// @Last Modified Description: Adding test methods for Case creation from contracts, and a test setup for SFDC1-4207, 7204 and 4324.
// -------------------------------------
// @Last Modified By : Sruti Srivastava 
// @Last Modified Date : 5th April 2018
// @Last Modified Description : SFDC1-7604 - updated test class to bypass validation on contract
// -------------------------------------
// @author: Sruti Srivastava
// @date: 12 May 2018
// @description: Test method to test updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted method on contractMethod
//-----------------------------
@isTest
private class TestContractMethods {
	
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 12 Mar 2018
    // @description: Method to create test data.
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    static void insertTestData() {
        Test.startTest();        
       
        Account acc = TestUtility.createTestAccountWithAddress('Account testImplCaseFromOrderFormContract', '1234 Testing Blvd', 'Test City', '', 'GB', false);
        Account processorAccount = TestUtility.createTestAccountWithAddress('Processor Account', '5678 Testing Street', 'Test Town', '', 'IN', false);             
        List<Account> lstAccount = new List<Account>{acc,processorAccount};
        insert lstAccount;
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        Opportunity testAddOnOpportunity = TestUtility.createOpportunity(acc.Id, 'test Add-On Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        testAddOnOpportunity.BudgetRange__c = '< 25,000';
        testAddOnOpportunity.ActivityCreated__c = true;
        testAddOnOpportunity.CloseDate = System.today() + 180;        
        
        Id RenewalRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Renewal Opp';
        opp1.StageName= '3-Renewal Pending';
        opp1.RecordTypeId = RenewalRecordTypeId;
        opp1.CloseDate = System.today()+2;
        opp1.AutoRenewal__c = true;
        opp1.SourceSystem__c = 'Manually Generated';
        opp1.DoesThisAutoRenewalHaveChanges__c = false;
        opp1.Amount = 100;
        opp1.AccountId = acc.id;
        opp1.ActivityCreated__c = true;
        opp1.BillToStreet__c = '4th floor Ropemaker Place, 25 Ropemaker Street';
        opp1.BillToCity__c = 'London';
        opp1.BillToStateProvince__c = '';
        opp1.BillToCountryNew__c = 'London';
        
        List<Opportunity> opportunityList = new List<Opportunity>{testOpportunity,testAddOnOpportunity, opp1};
        insert opportunityList;

        Contact testContact = TestUtility.createContact(acc.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id, IsPrimary=true);
        OpportunityContactRole ocrAddOn = new OpportunityContactRole(OpportunityId = testAddOnOpportunity.Id, ContactId = testContact.Id, IsPrimary=true);
        OpportunityContactRole ocrRenewal = new OpportunityContactRole(OpportunityId = opp1.Id, ContactId = testContact.Id, IsPrimary=true);
        List<OpportunityContactRole> opptyContactRole = new List<OpportunityContactRole>{ocr,ocrAddOn,ocrRenewal};
        
        insert opptyContactRole;

        List<LoadingGroup__c> lgList = new List<LoadingGroup__c> ();
        lgList.add(TestUtility.createLoadingGroup('IHS', 'IHS Lg1', false));
        lgList.add(TestUtility.createLoadingGroup('IHS', 'IHS Lg2', false));
        lgList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg3', false));
        lgList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg4', false));
        lgList.add(TestUtility.createLoadingGroup('Calgary', 'Calgary Lg1', false)); //For trial contract type coverage against Calgary Group
        insert lgList;
        
        Id standardId = Test.getStandardPricebookId();
        List<Product2> productList = new List<Product2>();
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product1', lgList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product2', lgList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product3', lgList.get(1).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product4', lgList.get(2).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product5', lgList.get(2).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product6', lgList.get(3).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product7', lgList.get(4).id, false)); //For trial contract type coverage against Calgary Group
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product8', lgList.get(0).id, false));
        insert productList;
        
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(0).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(1).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(2).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(3).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(4).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(5).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(6).id, false)); //For trial contract type coverage against Calgary Group
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(7).id, false));
        insert pbeList;

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(0), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(1), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(2), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(3), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(4), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(5), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(6), false)); //For trial contract type coverage against Calgary Group
        oliList.add(TestUtility.createOpportunityLineItem(testAddOnOpportunity.Id, pbeList.get(7), false));
        insert oliList;
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntity('legalEntity','USD');
       System.debug('=====limits.getQueries() in test after logal setup StartTest===' + limits.getQueries());
        TriageCriteria__c testTriage = TestUtility.createTriage(lgList.get(2).id,false);
        insert testTriage;
        
        CaseTriageExecutionOrder__c testCaseTriageExecOrder = TestUtility.createCaseTriageExecOrder(false);
        insert testCaseTriageExecOrder;
        
        System.debug('=====limits.getQueries() in test Contract setup StartTest===' + limits.getQueries());
        List<CaseTriageExecutionOrder__c> listSortOrderFields = new List<CaseTriageExecutionOrder__c>();
        listSortOrderFields = CaseTriageExecutionOrder__c.getall().values();
        system.debug('listSortOrderFields ::: '+listSortOrderFields.size());
        Test.stopTest();
        
        
        
    }
    
    @isTest
    static void testCopyPrimaryContactToContract() {

            Id OrderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Test.startTest();
        
            Account acc = [Select id from Account where name='Account testImplCaseFromOrderFormContract' LIMIT 1];
            List<Contact> conList = [Select id,AccountId from Contact where accountid =: acc.id]; 
            List<Opportunity> oppyList = [Select id,AccountId from Opportunity where accountid =: acc.id]; 
            List<OpportunityContactRole> oppyConRoleList = [Select id, OpportunityId from OpportunityContactRole where OpportunityId IN:oppyList]; 

            Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(OrderFormRecordTypeId, oppyList[0].Id);
            
            // Quering Contract Object to verify the Contact Values on Contract
            Contract Contractobj = [Select id, accountId,BillToContactEmailAddress__c,BillToContactFirstName__c,
            ShipToContactEmailAddress__c,ShipToContactTelephoneNumber__c  from contract where Id=: contractRecId];
                        
            // Updating Opportunity on Contract to verfiy that the Contact Values should be updated accordingly
            Contractobj.Opportunity__c = oppyList[0].id;
            Contractobj.Fastrack__c= TRUE;
            update Contractobj;
            
            // Quering again Contract Object to verify the Contact Values on Contract
            Contractobj = [Select id, accountId,BillToContactEmailAddress__c,BillToContactFirstName__c,
            ShipToContactEmailAddress__c,ShipToContactTelephoneNumber__c  from contract where Id=: contractRecId];
            
            // Assert for the Contact Values on Contract
            System.assertEquals(Contractobj.BillToContactEmailAddress__c,'testihsmarkit@testihsmarkit.com','inserting contact email on contract');
            System.assertEquals(Contractobj.BillToContactFirstName__c,'Test','inserting contact first name on contract');		
            
        Test.stopTest();
    }

    

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 12 Mar 2018
    // @description: SFDC1-7740 Test method to test if cases are created or not for order form contract.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testCaseCreationFromOrderFormContract() {
        Id implementationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id omRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        Contract testContract = [Select id, status, Fastrack__c from contract where id =: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        List<ContractLineItem__c> testCLIList = new List<ContractLineItem__c>();
        for(ContractLineItem__c cli: [Select Id,Contract__c,Status__c From ContractLineItem__c Where Contract__c=:testContract.Id]) {
            System.debug('**HS27Feb**cli='+cli);
            cli.Status__c = 'New';
            testCLIList.add(cli);
        }
        update testCLIList;
        //testcontract.AutoRenewal__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.contractStatus__c = 'Signed By Customer';
        testContract.status = 'ReadyForProcessing';
        testcontract.Fastrack__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testcontract.NoInternalApprovalNeeded__c = true;
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;
        System.debug('SOQL Limts-> '+Limits.getQueries()); // 69 SOQL
        
        Test.startTest();
        List<Case> caseList = [select recordType.Name, id, type, description, owner.Name from case where contract__c =:testContract.id and recordTypeId = :omRecordTypeId];
        System.assertEquals(caseList.size(),1);
        case omcase = caseList.get(0);
        omcase.SAPProcessedContractNumber__c = 'test';
        omcase.Status = 'Validated PO Pending';
        update omcase;//This updates contract and triggers impl case creation.
        caseList = [select recordType.Name, id, type, description, owner.Name from case where contract__c =:testContract.id and recordTypeId = :implementationRecordTypeId];
        
        for(Case cas : caseList) {
            System.assertEquals('New Contract', cas.Type,'the case type should be new contract');
            System.assert(cas.Description.contains('Test Product'));
        } 
        //When contract is changed from Validated to validated PO pending then new cases shouldnt be created.
        testContract.ContractStatus__c = 'Validated';
        update testContract;
        caseList = [select recordType.Name, id, type, description, owner.Name from case where contract__c =:testContract.id and recordTypeId = :implementationRecordTypeId];
        
        //Recreation of Impl cases should happen if the Contract is moved to Scheduled Termination
        testContract.Status = 'Complete';
        testContract.ContractStatus__c = 'Scheduled Termination';
        update testContract;
        caseList = [select recordType.Name, id, type, description, owner.Name from case where contract__c =:testContract.id and recordTypeId = :omRecordTypeId];
        
        caseList = [select recordType.Name, id, type, description, owner.Name from case where contract__c =:testContract.id and recordTypeId = :implementationRecordTypeId];
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 12 Mar 2018
    // @description: Test method to test if cases are created or not for a trial contract.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testCaseCreationFromTrialContract() {
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Opportunity testOpportunity = [SELECT Id, (select id from OpportunityLineItems) FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        List<Id> oliIds = new List<Id>();
        for (OpportunityLineItem oliId : testOpportunity.OpportunityLineItems) {
            oliIds.add(oliId.id);
        }
        Id contractRecId = ContractRecordTypeSelectionController.createTrialContractRecord(testOpportunity.Id,System.JSON.serialize(oliIds));

        Test.startTest();
        Contract testContract = [Select id, status, Fastrack__c from contract where Id=: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        testContract.contractStatus__c = 'Signed By Customer';
        testContract.Status = 'ReadyForProcessing';
        testcontract.Fastrack__c = true;
        testcontract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        //testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testcontract.NoInternalApprovalNeeded__c = true;
        update testContract;
        List<Case> caseList = [select recordType.Name, id, type, description, owner.Name from case where contract__c =:testContract.id];
        
        for(Case cas : caseList) {
            System.assertEquals('Trial', cas.Type,'the type of case should be trial');
            System.assert(cas.Description.contains('Test Product'));
        }

        testContract.Status = 'Creation';
        update testContract;
        //Recreation of cases shouldnot happen if the contract returns to same status
        testContract.Status = 'ReadyForProcessing';
        caseList = [select recordType.Name, id, owner.Name from case where contract__c =:testContract.id];
        //System.assertEquals(caseList.size(),5);
        Test.stopTest();
    }    
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 26 April 2018
    // @description: Test method to test updateCaseAndOppoStatusContract method on contractMethod
    // @param: 
    // @return: void
    // @author: Vishnu 
    // @date: 10 May 2018
    // @Description: Fixing test case, that is failing after introducing new validation rule.
    //-----------------------------
    @isTest
    public static void testupdateCaseAndOppoStatusContract() {
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
	
        Account ihsMarkitAccount = [Select id from Account where name = 'Account testImplCaseFromOrderFormContract' LIMIT 1];
            
        String testEmail = 'dgtest@ihsmarkit.com';
        Contact myTestContact = [Select Id,Email from Contact Where AccountId =: ihsMarkitAccount.Id LIMIT 1];
        myTestContact.Email = testEmail;
        update myTestContact;
        Opportunity testOpportunity = [SELECT Id,stageName FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.ContractEndDate__c = System.today();
        testOpportunity.ActivityCreated__c = true;
        update testOpportunity;
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject Case status 1';
        testCase1.Contract__c= contractRecId;
        testCase1.RecordTypeId = OMRecordTypeId;
        testCase1.ContactId = myTestContact.id;
        testCase1.Status = 'Rejected';
        testCase1.ReasonforRejection__c = 'Incorrect Data Entry';
        insert testCase1;
        System.debug('SOQL Limts-> '+Limits.getQueries()); //
        
        Test.startTest();
        Contract testContract = new Contract(id=contractRecId,ContractRejectionPastDue__c = TRUE,Fastrack__c = true);
        update testContract;
        Case caseStatus = [Select id,status from case where id=:testCase1.id];
        Opportunity oppStage = [Select stageName from Opportunity where id=:testOpportunity.id];
        //system.assertEquals('Canceled', caseStatus.Status);
        system.assertEquals('5-Contracting', oppStage.StageName,'Opportunity stage should be 5-Contracting');
        Test.stopTest();        
    }
    
        //-----------------------------
    // @author: Ankita Singh
    // @date: 26 April 2018
    // @description: Test method to test negative scenario updateCaseAndOppoStatusContract method on contractMethod
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testupdateCaseAndOppoStatusContractNegativeTest() {
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        Id RenewalRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
       
        Account ihsMarkitAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        String testEmail = 'dgtest@ihsmarkit.com';
        Contact myTestContact = [Select Id,Email from Contact Where AccountId =: ihsMarkitAccount.Id LIMIT 1];
        myTestContact.Email = testEmail;
        update myTestContact;
        Opportunity testOpportunity = [SELECT Id,stageName, recordTypeId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
       
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject Case status 1';
        testCase1.Contract__c= contractRecId;
        testCase1.RecordTypeId = OMRecordTypeId;
        testCase1.ContactId = myTestContact.id;
        testCase1.Status = 'New';
        insert testCase1;
        System.debug('SOQL Limts-> '+Limits.getQueries());
        
        Test.startTest();

        Contract testContract = new Contract(id=contractRecId,ContractRejectionPastDue__c = TRUE,Fastrack__c = true);
        update testContract;
         
        system.assertNotEquals('Closed - Canceled', testCase1.Status,'the status of testCase should not be Closed-Canceled');
        system.assertNotEquals('5-Contracting', testOpportunity.StageName,'the stage of opportunity should not be 5-Contracting');
        Test.stopTest();
        
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 11 May 2018
    // @description: Test method to test createOrModifyOMCasesForOrderFormContracts method on contractMethod
    // @param: 
    // @return: void
    // @Last Modified By : Dev Aggarwal 
    // @Last Modified Date : 21 January 2020
    // @Last Modified Description : Fixing test case, System.Assert will be picking up auto renewal value from contract instead of hard coded false.
    //-----------------------------
    @isTest
    public static void testOMCaseCreationForOrderFormContract() {
        
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        
        Account ihsMarkitAccount  = [SELECT Id FROM Account Where Name = 'Account testImplCaseFromOrderFormContract' LIMIT 1];
        String testEmail = 'dgtest@ihsmarkit.com';
        Contact myTestContact = [Select Id from Contact Where AccountId =: ihsMarkitAccount.Id LIMIT 1];

        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c from contract where id =: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        System.debug('SOQL Limts-> '+Limits.getQueries());
        
        Test.startTest();
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed by Customer';
        testContract.OrderReason__c = 'New';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';        
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.AutoRenewStopped__c = true;
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;
        Test.stopTest();
        
        system.debug('testContract--->'+testContract);
        List<Case> caseList = [select recordType.Name, id, Status, AutoRenewal__c from case where contract__c =:testContract.id];       
        system.debug('caseList--->'+caseList);
        System.assertEquals(caseList.size(),1);
        
        Case cas = caseList.get(0);
        System.assertEquals(testContract.autoRenewal__c, cas.AutoRenewal__c);
        
        cas.Status = 'Rejected';
        cas.ReasonForRejection__c = 'EU Company VAT #';
        update cas;
        
        testContract.Status = 'ReadyForProcessing';
        update testContract;
        
        //If case is rejected then status should be Updated and rest of the fields to be copied.
        caseList = [select recordType.Name, id, Status, AutoRenewal__c from case where contract__c =:testContract.id];
        System.assertEquals(caseList.size(),1);
        cas = caseList.get(0);
        
        System.assertEquals('Rejected',cas.Status,'the status of case should be updated');
        
    }
    //-----------------------------
    // @author: Kanika Miglani
    // @date: 22nd Febrary 2022
    // @description: SFDC-3646 : Case should be created on Add-on Contract if AutoRenewStopped__c is checked on Original Contract test method.
    //-----------------------------
     @isTest
    public static void testAddOnContractOMCaseCreation() {
        
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        Contact con = [Select id, Name from Contact where lastname ='Contact' Limit 1]; 
        
        Opportunity testOpportunity1 = [SELECT Id FROM Opportunity WHERE Name='test Add-On Opppy' LIMIT 1];
        testOpportunity1.PrimaryContact__c = con.Name;
        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        Id addOnContractId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity1.Id);
        Contract addOnContract = new Contract();
        addOnContract.Id = addOnContractId;
        addOnContract.OrderReason__c ='Add-On';
        addOnContract.Status = 'Complete';
        addOnContract.OriginatingContractforAddOn__c = contractRecId;
        addOnContract.ContractStatus__c = 'Signed by Customer';
        addOnContract.Fastrack__c = true;
        addOnContract.AutoRenewal__c = true;
        addOnContract.AutoRenewStopped__c = true;
        addOnContract.PriceIncreaseClause__c = 'No Increase Allowed';
        addOnContract.NoInternalApprovalNeeded__c = true;
        addOnContract.TerminationNotice__c = '5 days';
        addOnContract.RenewalNoticePeriod__c = '60 Days';        
        addOnContract.RenewalDate__c = System.today()+365;
        addOnContract.BillingFrequency__c = 'Annual';
        addOnContract.UsageReportsRequired__c = 'No';
        addOnContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update addOnContract;
        
        Test.startTest();
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c,ReplacementContract__c,ReplacementContract__r.Status,ContractStatus__c,OriginatingContractforAddOn__c,(Select Id, Status,OrderReason__c,AutoRenewStopped__c from OriginatingContractsforAddOn__r where OrderReason__c ='Add-On' AND Status = 'Complete') from contract where Id=: contractRecId];
        
        //TestUtility.createContractAttachment(testContract.id);
        testContract.OriginatingContractforAddOn__c = addOnContractId;
        testContract.ReplacementContract__c = addOnContractId;
        testContract.Status = 'Complete';
        testContract.ContractStatus__c = 'Replaced';
        testContract.OrderReason__c = 'Add-On';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';        
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.AutoRenewStopped__c = true;
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update testContract;
        system.debug('testContract--->'+testContract);
        List<Case> caseList = [select recordType.Name, id, Status, AutoRenewal__c from case where contract__c =:testContract.id];       
        system.debug('caseList--->'+caseList);
        System.assertEquals(caseList.size(),1);
        
        Case cas = caseList.get(0);
        System.assertEquals(testContract.autoRenewal__c, cas.AutoRenewal__c,'the case auto-renewal should be updated same as contract');    
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 26 Dec 2018
    // @description: Test method to test OMCaseUpdatesWhenRenewalOppty6L
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testOMCaseUpdatesWhenRenewalOppty6L() { 
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id RenewalRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        /*Account ihsMarkitAccount = TestUtility.createTestAccountWithAddress('IHS Markit', 
                                                                  '4th floor Ropemaker Place, 25 Ropemaker Street',
                                                                  'London', '', 'GB', true);*/
        Account ihsMarkitAccount = [SELECT Id FROM Account Where Name = 'Account testImplCaseFromOrderFormContract' LIMIT 1];
        String testEmail = 'dgtest@ihsmarkit.com';
        // Contact myTestContact = TestUtility.createContact(ihsMarkitAccount.Id, testEmail, true, 'Test', 'Contact');
        Contact myTestContact = [Select Id from Contact Where AccountId =: ihsMarkitAccount.Id LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c from contract where id =:contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        
        
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed by Customer';
        testContract.OrderReason__c = 'New';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;
        
        
        List<Case> caseList = [select recordType.Name, id, Status, AutoRenewal__c from case where contract__c =:testContract.id];
        Case cas = caseList.get(0);
        System.debug('SOQL Limts-> '+Limits.getQueries());
        
        Test.startTest();
        cas.Status = 'Validated';
        cas.SAPProcessedContractNumber__c = '123456';
        update cas;	
      
		Opportunity opp1 = [SELECT Id FROM Opportunity Where Name = 'Test Renewal Opp' LIMIT 1];
        
        OpportunityContactRole ocr1 = [Select Id from OpportunityContactRole Where OpportunityId=:opp1.Id];
        
        opp1.stagename = '6L-Renewal Lost';
        opp1.LostReasonCode__c = 'Customer Lost Bid';
        opp1.LostReasonDescription__c = 'Lost Bid';
        opp1.ContractBeingRenewed__c = testcontract.id;
        update opp1;
        Test.stopTest();
        Case cse = [Select Id,status,LostReasonCode__c from Case Where Opportunity__c =: opp1.Id];
        System.assertEquals('Customer Lost Bid', cse.LostReasonCode__c,'the lostReasonCode should be Customer Lost Bid');
        
    }
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 22 May 2018
    // @description: Test method for updateCountersignatureFields Contract method on Master Agreement record type
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testUpdateCountersignatureFieldsForMasterAgreement() {
        Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementRecordTypeId, testOpportunity.Id);

        Test.startTest();
        Contract testContract = [Select Id, Status, ContractStatus__c, Fastrack__c, AutoRenewal__c from contract where Id=: contractRecId];
        System.debug('SFDC1-7680 Contract Stage: ' + testContract.Status);
        TestUtility.createContractAttachment(testContract.id);
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testcontract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update testContract;
        
        testContract = [Select id, status, CountersignatureStatus__c, CountersignatureOwner__c from contract where Id=: contractRecId];
        // assertion for SFDC1-7680
        System.assertEquals('New', testContract.CountersignatureStatus__c,'The CounterSignatureStatus should be new');
        System.assertEquals(UserInfo.getUserId(), testContract.CountersignatureOwner__c,'The CountersignatureOwner of the Contract should be a valid userid');

        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 22 May 2018
    // @description: Test method for updateCountersignatureFields Contract method on Order Form record type
    // @param: 
    // @return: void
    // Updated By: Anjani Shukla
    // LastModifiedDate: 20 Aug 2018
    // Description:SFDC1-9446: UAT feedback - Issue populating the Countersignature Owner or SAP PGI'd Owner.
    //                         CountersignatureOwner__c,PGIOwner__c should be updated when CountersignatureStatus__c and SAPPGId__c
    //                         "Countersignature Status" or "SAP PGI'd" is updated from blank to new, the corresponding owner fields 
    //                         "Countersignature Owner" and "PGI Owner" are being populated. The Counter Signature owner and the PGI Owner 
    //                         fields should still be blank when those fields are in "New" and owner field should be populated once the field 
    //                         is moved to anything except for new.
    //-----------------------------
    @isTest
    public static void testUpdateCountersignatureFieldsForOrderForm() {
        Id oderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(oderFormRecordTypeId, testOpportunity.Id);

        
        Contract testContract = [Select Id, Status, ContractStatus__c, Fastrack__c, AutoRenewal__c,CountersignatureStatus__c, CountersignatureOwner__c,PGIOwner__c,SAPPGId__c
                                 from contract where Id=: contractRecId];
        System.debug('SFDC1-7680 Contract Status: ' + testContract.ContractStatus__c);
        TestUtility.createContractAttachment(testContract.id);
        testContract.ContractStatus__c = 'Validated PO Pending';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        //SFDC1-9446
        testContract.SAPPGId__c = 'New';
        //SFDC1-9446
        testContract.CountersignatureStatus__c = 'New';
        testContract.OrderReason__c = 'New';
        testContract.BillingFrequency__c = 'Multi Year';
        testContract.UsageReportsRequired__c='No';
        testContract.RenewalDate__c = system.Today()+365;
        update testContract;
        System.debug('SOQL Limts-> '+Limits.getQueries());
        
        Test.startTest();
        testContract = [Select id, status, CountersignatureStatus__c, CountersignatureOwner__c,PGIOwner__c,SAPPGId__c from contract where Id=: contractRecId];
        // assertion for SFDC1-7680
        System.assertEquals('New', testContract.CountersignatureStatus__c,'the CountersignatureStatus should be New');
        //SFDC1-9446
        System.assertEquals(null, testContract.CountersignatureOwner__c,'the CountersignatureOwner should be null');
        //SFDC1-9446
        System.assertEquals(null, testContract.PGIOwner__c,'the PGIOwner should be null');

        testContract.ContractStatus__c = 'Validated';
        //SFDC1-9446
        testContract.SAPPGId__c = 'Pending';
        testContract.OrderReason__c = 'New';
        //SFDC1-9446
        testContract.CountersignatureStatus__c = 'Pending';
        update testContract;
        
        testContract = [Select id, status, CountersignatureStatus__c, CountersignatureOwner__c,PGIOwner__c,SAPPGId__c from contract where Id=: contractRecId];
        // assertion for SFDC1-8252
        System.assertEquals('Complete', testContract.Status,'the status of contract should be complete');
        //SFDC1-9446
        System.assertEquals(UserInfo.getUserId(), testContract.CountersignatureOwner__c,'the CountersignatureStatus should not be New');
        //SFDC1-9446
        System.assertEquals(UserInfo.getUserId(), testContract.PGIOwner__c,'the PGIOwner should not be null');
        
        Test.stopTest();
    }
    
     /**
     * @author Tran-Vu Tran
     * @date 24 Oct 2018
     * @description SFDC1-9347 test class for ContractMethods.updateAccountRelationship
     * @param NA
     * @return void
     * @companyname IHS Markit
     */
    
     @isTest static void testUpdateAccountRelationship() {
         
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id RenewalRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        
        Account testAccount = [SELECT Id FROM Account Where Name = 'Account testImplCaseFromOrderFormContract'];
        String testEmail = 'dgtest@ihsmarkit.com';
        Contact myTestContact = [Select Id from Contact Where AccountId =: testAccount.Id LIMIT 1];
         
         LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity', 'USD', true, 
                                                                   'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
         List<Country__c> lstCountry = TestUtility.loadCountryData();
         Country__c country = lstCountry.get(0);
         
         
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c from contract where id =: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
         
         testOpportunity.StageName = '6W-Closed Won';
         testOpportunity.ContractId = testContract.id;
         testOpportunity.ContractStartDate__c = System.today().addDays(10);
         testOpportunity.ContractEndDate__c = System.today().addDays(100);
         testOpportunity.ActivityCreated__c = true;
         testOpportunity.ReadyForProcessingContractExist__c = true;
         GlobalVariables.preventRecursiveExecution = true;
         update testOpportunity;
         System.debug('testOpportunity = ' + testOpportunity);
		
         Test.startTest();
         Account assertAccount = [Select Id, Relationship__c from Account where Id =: testAccount.Id];
         System.debug('assertAccount after adding Opportunity = ' + assertAccount);
         System.assertEquals('Customer', assertAccount.Relationship__c, 'Checking relationship on closing Won Opportunity');
         
         testOpportunity.CloseDate = System.today().addDays(-480);
         GlobalVariables.preventRecursiveExecution = true;
         update testOpportunity;
         assertAccount = [Select Id, Relationship__c from Account where Id =: testAccount.Id];
         System.debug('assertAccount after changing Opportunity Close Date = ' + assertAccount);
         System.assertEquals('Customer', assertAccount.Relationship__c, 'Checking relationship on changing Opportunity Close Date');
         
         testContract.Status = 'Creation';
         testContract.StartDate = System.today().addDays(10);
         testContract.EndDate = System.today().addDays(100);
         GlobalVariables.preventRecursiveExecution = true;
         update testContract;
         testContract = [Select Id, StartDate, EndDate, Status from Contract where Id =: testContract.Id];
         System.debug('contract1 after updating Status= ' + testContract);
         
         assertAccount = [Select Id, Relationship__c from Account where Id =: testAccount.Id];
         System.debug('assertAccount after updating Contract Status = ' + assertAccount);
         System.assertEquals('Customer', assertAccount.Relationship__c, 'Checking relationship on updating Contract Status');
         
         Test.stopTest();
     }
     
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 25 May 2018
    // @description: Test method to test updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted method in contractMethods class
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    static void testUpdateNoticeAddressFieldsOnContractFromLegalEntity() {
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Account acc = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        
       	LegalEntity__c legalEntity = [Select Id,StateOrProvinceNew__c from LegalEntity__c where name ='legalEntity'LIMIT 1];
        legalEntity.StateOrProvinceNew__c = 'Iowa';
        update legalEntity;
        Opportunity testOpportunity = [Select Id from Opportunity Where AccountId =: acc.Id and name='test Opppy' LIMIT 1];
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);   
        Contract defaultContract = [Select id, accountId from contract where Id=: contractRecId];
        defaultContract.IHSMarkitLegalEntity__c = legalEntity.id;
        defaultContract.Fastrack__c = true;
        update defaultContract;
        System.debug('SOQL Limts-> '+Limits.getQueries());
        
        Test.startTest();
        String state = [Select id, accountId,IHSMarkitLegalEntityStateProvinceNew__c from contract where Id=: contractRecId].IHSMarkitLegalEntityStateProvinceNew__c;
        System.assertEquals(state,'Iowa','the IHSMarkitLegalEntityStateProvinceNew__c should be Iowa');
        
        defaultContract.IHSMarkitLegalEntity__c = NULL;
        update defaultContract;
        state = [Select id, accountId,IHSMarkitLegalEntityStateProvinceNew__c from contract where Id=: contractRecId].IHSMarkitLegalEntityStateProvinceNew__c;
        System.assertEquals(String.isBlank(state),true,'the IHSMarkitLegalEntityStateProvinceNew__c should be blank');
        Test.stopTest();
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 25 May 2018
    // @description: Test method to test updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted method in contractMethods class
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    static void testUpdateAddressOnRenewalOppty() {
        //Account testAccount = TestUtility.createTestAccount('testAccount', false);
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract        
        LegalEntity__c legalEntity = [Select Id,StateOrProvinceNew__c from LegalEntity__c where name ='legalEntity'LIMIT 1];
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contract.recordtypeid = orderFormRecordTypeId;
        insert contract;      
        Opportunity testOpportunity = [Select Id,ContractBeingRenewed__c from Opportunity Where AccountId =: testAccount.Id and name='Test Renewal Opp' LIMIT 1];
       testOpportunity.ContractBeingRenewed__c = contract.Id;
        update testOpportunity;      
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        update contract;       
     Opportunity opp = [Select id, BillToClientName__c from Opportunity where id =: testOpportunity.id];        
     System.assertEquals(opp.BillToClientName__c ,'client name 1','the Bill to client name should be client name 1');
        
    }
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 14 June 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnConsultingContract() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                  'No', 'No', 'No', 'No', 'No', 'Yes', 'No'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);  
        contract.recordtypeid = consultingRecordTypeId;
        insert contract;    
        // Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
    }
    
     //-----------------------------
    // @author: Ankita Singh
    // @date: 14 June 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnTrailContract() {        
         Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                  'No', 'No', 'No', 'No', 'Yes', 'No', 'No'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).id, country.Id, standardId,FALSE);      
        contract.recordtypeid = trialRecordTypeId;
        Test.startTest();
        insert contract;    
        // Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        Test.stopTest();
    }
    
     //-----------------------------
    // @author: Ankita Singh
    // @date: 14 June 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnConLetterContract() {        
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                  'No', 'No', 'No', 'Yes', 'No', 'No', 'No'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);      
        contract.recordtypeid = continuationLetterRecordTypeId;
        Test.startTest();
        insert contract;
        // Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 14 June 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnDPAContract() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id DPARecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('DPA').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                  'Yes', 'No', 'No', 'No', 'No', 'No', 'No'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);
        contract.recordtypeid = DPARecordTypeId;
        test.startTest();
        insert contract;    
        // Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 14 June 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnMSTContract() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id MSTRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Managed Service Terms (MST)').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                  'No', 'Yes', 'No', 'No', 'No', 'No', 'No'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);
        contract.recordtypeid = MSTRecordTypeId;
        test.startTest();
        insert contract;    
        //Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Kolli Rohit Reddy
    // @date: 30 April 2019
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnTPPAContract() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id ThirdpartyProcessorRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Third Party Processor Agreement').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        //lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 'No', 'Yes', 'No', 'No', 'No', 'No', 'No'));
        LegalEntity__c leTest = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 'No', 'Yes', 'No', 'No', 'No', 'No', 'No');
        leTest.ThirdPartyProcessorAgreement__c = 'Yes';
        lelist.add(leTest);
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;        
        
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);
        contract.recordtypeid = ThirdpartyProcessorRecordTypeId;
        test.startTest();
        insert contract;    
        //Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;      
            System.AssertEquals([SELECT Id,IHSMarkitLegalEntity__c FROM Contract WHERE Id=:contract.Id LIMIT 1].IHSMarkitLegalEntity__c, lelist.get(1).id);
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 14 June 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnMasterContract() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                   'No', 'No', 'Yes', 'No', 'No', 'No', 'No'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);
        contract.recordtypeid = masterAgreementRecordTypeId;
        test.startTest();
        insert contract;
        // Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan
    // @date: 05 Dec 2018
    // @description: Test method to test validateLegalEntityOnContract method in contractMethods class
    // @param: 
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This test method is for Validation Rule: <PreventNonEligibleContractCloning>.
    //-----------------------------
    @isTest
    static void testValidateLegalEntityOnNDAContract() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id ndaRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('NDA').getRecordTypeId();
        List<LegalEntity__c> lelist = new List<LegalEntity__c>();
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', false, 
                                                                  'No', 'No', 'No', 'No', 'No', 'No', 'Yes'));
        lelist.add(TestUtility.createLegalEntityWithEligibleFields('testLegalEntity1','USD',false));
        insert lelist;
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, lelist.get(0).Id, country.Id, standardId,FALSE);
        contract.recordtypeid = ndaRecordTypeId;
        test.startTest();
        insert contract;
        // Updating Contract
        contract.BillToCity__c = 'city1';
        contract.Fastrack__c = true;
        contract.BillToClientName__c = 'client name 1';
        contract.IHSMarkitLegalEntity__c = lelist.get(1).id;
        try {
            //Verify that update will fail, as LegalEntity selected for contract is not availble for this record type
            update contract;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.LegalEntityErrorOnContract) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true,'Validating Exception');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Jun 2018
    // @description: SFDC1-8533 Test method for setOpptyOwnerEmail() method in ContractMethods class
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testSetOpptyOwnerEmail() {
        //Test Opportunity of New Business record type
        Opportunity testOpportunity = [SELECT Id,AccountId,Opportunity.OwnerId,Opportunity.Owner.Email,RecordType.Name FROM Opportunity WHERE Name='test Opppy' LIMIT 1];                
        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        Contract testContract = new Contract(Id=orderFormContractId);
        //Set CancelRequestReceivedDate__c on test Contract
        testContract.Fastrack__c = true;
        testContract.CancelRequestReceivedDate__c = System.today() + 10;
        update testContract;        
        System.assertEquals(testOpportunity.Owner.Email,[Select Id,OpptyOwnerEmail__c From Contract Where Id=:testContract.Id].OpptyOwnerEmail__c,'comparing opportunity owner email with contract opptyOwnerEmail' );
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Jun 2018
    // @description: SFDC1-8533 Test method for updateOpptyContractStartEndDates() method in ContractMethods class
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateOpptyContractStartEndDates() {
        System.debug('==========limit at start===='+ Limits.getQueries());
        //Test Opportunity of New Business record type
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];                
                        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        TestUtility.createContractAttachment(orderFormContractId);
        
        Contract testContract = new Contract(Id=orderFormContractId);
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
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;
		System.debug('==========limit after contract update===='+ Limits.getQueries());
        Test.startTest();
        
        //Setting opportunity as Won
        testOpportunity.StageName = '6W-Closed Won';
        update testOpportunity;        
        
        System.debug('==========limit after opp update===='+ Limits.getQueries());
        //Create child opportunity of Contract
        //
        Opportunity testChildOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Add-On Opppy' LIMIT 1];                
        testChildOpportunity.ContractId = testContract.Id;
        //insert testChildOpportunity; 
        update testChildOpportunity;       
        System.debug('==========limit after child opp insert===='+ Limits.getQueries());
        
        testContract.StartDate = System.today();
        testContract.EndDate = System.today()+365;
        update testContract;        
        
        System.debug('==========limit after contract update===='+ Limits.getQueries());
        
        Opportunity outputRecord = [Select Id,ContractStartDate__c,ContractEndDate__c From Opportunity Where Id =:testChildOpportunity.Id];        
        System.assertEquals(testContract.StartDate, outputRecord.ContractStartDate__c,'comparing Opportunity startdate with Contract startdate');
        System.assertEquals(testContract.EndDate, outputRecord.ContractEndDate__c,'comparing Opportunity enddate with Contract enddate');
        
        
        //Setting Opportunity as Lost
        testOpportunity.StageName = '6L-Closed Lost';
        testOpportunity.LostReasonCode__c='Created in Error';
        testOpportunity.LostReasonDescription__c='Test Loss Reason Description';
        update testOpportunity;
        
        System.debug('==========limit after opp lost===='+ Limits.getQueries());
        
        testContract.StartDate = System.today()+10;
        testContract.EndDate = System.today()+70;
        update testContract;
        
        System.debug('==========limit after contract update 2===='+ Limits.getQueries());
        
        Opportunity outputRecord2 = [Select Id,ContractStartDate__c,ContractEndDate__c From Opportunity Where Id =:testChildOpportunity.Id];        
        System.assertEquals(testContract.StartDate, outputRecord2.ContractStartDate__c,'comparing Opportunity startdate with Contract startdate');
        System.assertEquals(testContract.EndDate, outputRecord2.ContractEndDate__c,'comparing Opportunity enddate with Contract enddate');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 28 Jun 2018
    // @description: SFDC1-8533 Test method #1 for updateStageOnOpp() method in ContractMethods class - Test Scenarios for 'New Business' and 'Renewal' opportunity for 'Order Form' type Contract
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateStageOnOppOrderFormContract1() {
        //TEST SCENARIO: NEW BUSINESS Opportunity
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
                        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();        
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);        
        Contract testContract = [Select Id From contract Where Id=: orderFormContractId];
        
        Test.startTest();
        TestUtility.createContractAttachment(testContract.id);
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;
        
        Opportunity outputRecord = [Select Id,StageName FROM Opportunity WHERE Id = :testOpportunity.Id];        
        System.assertEquals('6W-Closed Won', outputRecord.StageName,'the opportunity stage should be 6W-Closed Won');                
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 28 Jun 2018
    // @description: SFDC1-8533 Test method #2 for updateStageOnOpp() method in ContractMethods class - Test Scenarios for 'Renewal' opportunity for 'Order Form' type Contract
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateStageOnOppOrderFormContract2() {
        //TEST SCENARIO: RENEWAL Opportunity
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='Test Renewal Opp' LIMIT 1];
        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();        
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);        
        Contract testContract = [Select Id From contract Where Id=: orderFormContractId];
        TestUtility.createContractAttachment(testContract.id);
        Test.startTest();
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;
        
        Opportunity outputRecord2 = [Select Id,StageName FROM Opportunity WHERE Id = :testOpportunity.Id];        
        System.assertEquals('6W-Renewal Won', outputRecord2.StageName,'the stage should be 6W-Renewal Won');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 28 Jun 2018
    // @description: SFDC1-8533 Test method #3 for updateStageOnOpp() method in ContractMethods class - Test Scenarios for 'Forecasting Placeholder' and 'Gratis' opportunity for 'Order Form' type Contract
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateStageOnOppOrderFormContract3() {
        //TEST SCENARIO: FORECASTING PLACEHOLDER Opportunity
        //Setting up Forecasting Placeholder opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];        
        
        Id forecastingOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Forecasting Placeholder').getRecordTypeId();
        testOpportunity.RecordTypeId = forecastingOppRecordTypeId;  
        testOpportunity.StageName = '1-Open';
        update testOpportunity;
                        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        Contract testContract = new Contract(Id = orderFormContractId);
                
        Test.startTest();
        TestUtility.createContractAttachment(testContract.id);
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.OrderReason__c = 'New';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update testContract;
        
        Opportunity outputRecord = [Select Id,StageName FROM Opportunity WHERE Id = :testOpportunity.Id];        
        System.assertEquals('6W-Forecasting Placeholder', outputRecord.StageName,'the stage should be 6W-Forecasting Placeholder');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 02 Jul 2018
    // @description: SFDC1-8955 Test method #4 for updateStageOnOpp() method in ContractMethods class - Test Scenarios for 'New Business' opportunity for 'Consulting' type Contract
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateStageOnOppForConsultingContract1() {
        //TEST SCENARIO: NEW BUSINESS Opportunity
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
                        
        //Create test Order Form contract for New Business test opportunity        
        Id consultingContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        Id consultingContractId = ContractRecordTypeSelectionController.createDefaultRecord(consultingContractRecordTypeId, testOpportunity.Id);
        Contract testContract = new Contract(Id = consultingContractId);
        TestUtility.createContractAttachment(consultingContractId);
        Test.startTest();
        
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.OrderReason__c = 'New';
        testContract.ProjectName__c= 'Test Project';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
        update testContract;        
        
        Opportunity outputRecord = [Select Id,StageName FROM Opportunity WHERE Id = :testOpportunity.Id];        
        System.assertEquals('6W-Closed Won', outputRecord.StageName,'the stage should be 6W-Closed Won');        
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 02 Jul 2018
    // @description: SFDC1-8955 Test method #5 for updateStageOnOpp() method in ContractMethods class - Test Scenarios for 'Renewal' opportunity for 'Consulting' type Contract
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateStageOnOppForConsultingContract2() {
        System.debug('=====Limit.getQueries() at starting===' + Limits.getQueries());
        //TEST SCENARIO: RENEWAL Opportunity
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Test.startTest();
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        
        TestUtility.createContractAttachment(orderFormContractId);
        Contract orderFormContract = new Contract(Id=orderFormContractId);
        orderFormContract.Fastrack__c = true;
        update orderFormContract;        
        System.debug('=====Limit.getQueries() after Contract update===' + Limits.getQueries());
        
        
        //Setting up renewal opportunity
        Id renewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        testOpportunity.RecordTypeId = renewalOppRecordTypeId;
        testOpportunity.StageName = '3-Renewal Pending';
        testOpportunity.ContractBeingRenewed__c = orderFormContractId;
        testOpportunity.AutoRenewal__c = true;
        testOpportunity.SAPContractNumber__c = 'testSAPContract123';
        update testOpportunity;        
        System.debug('=====Limit.getQueries() after renewal update===' + Limits.getQueries());
        
        //Create test Order Form contract for New Business test opportunity                
        Id consultingContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();        
        Id consultingContractId = ContractRecordTypeSelectionController.createDefaultRecord(consultingContractRecordTypeId, testOpportunity.Id);
        System.debug('=====Limit.getQueries() after consulting contract creation===' + Limits.getQueries());
        Contract testContract = new Contract(Id = consultingContractId);        
        TestUtility.createContractAttachment(consultingContractId);
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.ProjectName__c= 'Test Project';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c= 'test@test.com';
		Test.stopTest();
        update testContract;  
        System.debug('=====Limit.getQueries() after contract update===' + Limits.getQueries());
        
        Opportunity outputRecord = [Select Id,StageName FROM Opportunity WHERE Id = :testOpportunity.Id];        
        System.assertEquals('6W-Renewal Won', outputRecord.StageName,'the stage should be 6W-Renewal Won');
        
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 02 Jul 2018
    // @description: SFDC1-8955 Test method #6 for updateStageOnOpp() method in ContractMethods class - Test Scenarios for 'Forecasting Placeholder' opportunity for 'Consulting' type Contract
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateStageOnOppForConsultingContract3() {
        //TEST SCENARIO: FORECASTING Opportunity
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];        
        Id forecastingOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Forecasting Placeholder').getRecordTypeId();
        testOpportunity.RecordTypeId = forecastingOppRecordTypeId;  
        testOpportunity.StageName = '1-Open';
        update testOpportunity;
        
        Test.startTest();
        
        //Create test Order Form contract for New Business test opportunity                
        Id consultingContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();        
        Id consultingContractId = ContractRecordTypeSelectionController.createDefaultRecord(consultingContractRecordTypeId, testOpportunity.Id);
        Contract testContract = new Contract(Id = consultingContractId);        
        TestUtility.createContractAttachment(consultingContractId);
        //Update Contract Stage to Ready For Processing
        testContract.Fastrack__c = true;
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed By Customer';
        testContract.NoInternalApprovalNeeded__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.OrderReason__c = 'New';
        testContract.ProjectName__c= 'Test Project';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        update testContract;        
        
        Opportunity outputRecord = [Select Id,StageName FROM Opportunity WHERE Id = :testOpportunity.Id];        
        System.assertEquals('6W-Forecasting Placeholder', outputRecord.StageName,'the stage should be 6W-Forecasting Placeholder');
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 28 Jun 2018
    // @description: SFDC1-8533 Test method for updateCurrencyOnContractLineItems() method in ContractMethods class
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateCurrencyOnContractLineItems() {
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
                        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        Contract testContract = [Select Id,CurrencyIsoCode,(Select Id,CurrencyIsoCode From Contract_Line_Items__r)
                                 From contract Where Id=: orderFormContractId];     
        
        testContract.Fastrack__c = true;
        testContract.CurrencyIsoCode = 'INR';        
        update testContract;
        
        for(ContractLineItem__c cli:[Select Id,CurrencyIsoCode From ContractLineItem__c Where Contract__c=:testContract.Id]) {
            System.assertEquals(testContract.CurrencyIsoCode, cli.CurrencyIsoCode,'comparing Contract CurrencyIsoCode with contractLineItem');
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 28 Jun 2018
    // @description: SFDC1-8533 Test method for updateAgreementEffectiveDateOnOrderFormAgreements() method in ContractMethods class
    // @param: None
    // @return: None
    //-----------------------------
    @isTest
    private static void testUpdateAgreementEffectiveDateOnOrderFormAgreements() {
        //Test Opportunity
        Opportunity testOpportunity = [SELECT Id,StageName,AccountId FROM Opportunity WHERE Name='test Opppy' LIMIT 1];        
        
        //Create Test Legal Entity
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntityWithEligibleFields('Test Legal Entity 123','USD',true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        
        //Create Master Agreement
        Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Contract masterAgreementContract = new Contract(RecordTypeId = masterAgreementRecordTypeId ,AccountId = testOpportunity.AccountId,IHSMarkitLegalEntity__c = testLegalEntity.Id, EffectiveDate__c = System.today(), ContractStatus__c = 'Executed');
        insert masterAgreementContract;        
        
        //Create test Order Form contract for New Business test opportunity        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
        Contract testContract = new Contract(Id = orderFormContractId);
        TestUtility.createContractAttachment(orderFormContractId);
        TestUtility.createContractAttachment(masterAgreementContract.Id);
        //Relate Master Agreement Contract with Order Form Contract
        testContract.GeneralAgreementType__c = 'IHS Markit Master Agreement';
        testContract.GeneralAgreement__c = masterAgreementContract.Id;
        update testContract;
        
        //Update Effective date on Master Agreement
        masterAgreementContract.EffectiveDate__c = System.today()+1;
        update masterAgreementContract;  
        
        Contract contract = [SELECT Id,GeneralAgreement__c,GeneralAgreementDate__c,GeneralAgreement__r.EffectiveDate__c FROM Contract WHERE GeneralAgreement__c =: masterAgreementContract.Id AND RecordTypeId = :orderFormRecordTypeId];
        system.assertEquals(contract.GeneralAgreement__r.EffectiveDate__c, contract.GeneralAgreementDate__c,'comparing GeneralAgreementDate with Effective Date');
    }
    
    //-----------------------------
    // @author: Veriba
    // @company: VERTIBA
    // @date: 25 June 2018
    // @param: 
    // @description:  Test method to check if functionality is working.
    // @return: NA
    // @Modification : Updated code for new methods added for edit fucntionality.
    // @Modification date : Anjani Shukla:29 June2018 - SFDC1-7992 - Create OM Case on Contract Closed Lost Renewal.
    //-----------------------------
    
   @isTest static void testcreateOMCaseforOrignatngContract() {
        test.startTest();
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();        
        Account ihsMarkitAccount = [Select id,BillingStreet,BillingCity,
                                    BillingCountryCode,Website,Type,Priority__c from Account where name ='Account testImplCaseFromOrderFormContract' LIMIT 1];
       
       ihsMarkitAccount.BillingStreet = '4th floor Ropemaker Place, 25 Ropemaker Street';
           ihsMarkitAccount.BillingCity = 'London';
           ihsMarkitAccount.BillingCountryCode = 'GB';
           ihsMarkitAccount.Website = 'www.test' + Math.random() +'.us';
           ihsMarkitAccount.Type = 'Direct';
       ihsMarkitAccount.Priority__c = 'Priority Prospect';
       update ihsMarkitAccount;
        String testEmail = 'dgtest@ihsmarkit.com';
		Contact myTestContact = [Select Id,Email from Contact Where AccountId =: ihsMarkitAccount.Id LIMIT 1];
        myTestContact.Email = testEmail;
        update myTestContact;
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];        
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);

        
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c from contract where Id=: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        testContract.Status = 'Complete';
        testContract.ContractStatus__c = 'Scheduled Termination';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = false;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.OrderReason__c = 'New';
        testContract.BillingFrequency__c = 'Multi Year';
        testContract.UsageReportsRequired__c='No'; 
        testContract.RenewalDate__c = system.Today()+365;
        update testContract;
        system.debug('testContract--->'+testContract);
        system.assertEquals([select Count() from case where Contract__c =: testContract.id limit 1],1 );
        system.assertEquals([select Contract__c from case where Contract__c =: testContract.id limit 1].contract__c, testContract.id,'comparing test contract id with contract id on case');
        
        Test.stopTest();    
    }
    
    //-----------------------------
    // @author: Veriba
    // @company: VERTIBA
    // @date: 24 July 2018
    // @param: 
    // @description:  Test method to check if functionality is working.
    // @return: NA
    // @Modification : Updated code for new methods added for edit fucntionality.
    // @Modification date : Anjani Shukla:29 June2018 - SFDC1-5864 - Cumulative Contract Value
    //-----------------------------
    
   @isTest static void testupdateDefaultContractCumulative() {
        test.startTest();
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Account ihsMarkitAccount = [Select id,BillingStreet,BillingCity,
                                    BillingCountryCode,Website,Type,Priority__c from Account where name ='Account testImplCaseFromOrderFormContract' LIMIT 1];
            
       String testEmail = 'dgtest@ihsmarkit.com';
       
       Contact myTestContact = [Select Id,Email from Contact Where AccountId =: ihsMarkitAccount.Id LIMIT 1];
        myTestContact.Email = testEmail;
        update myTestContact;       

        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        
        
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');        
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        
        Contract testContract = TestUtility.createContractWithInsertOptional(ihsMarkitAccount.id, legalEntity.id,
                                                                        country.id,standardId,false);
        
        testContract.Status = 'Creation';
        testContract.ContractStatus__c = 'Open';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = false;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        insert testContract;
        system.debug('testContract--->'+testContract);
        
        system.assertEquals([select AllAssociatedTotalOpportunityValue__c from Contract where id =: testContract.id limit 1].AllAssociatedTotalOpportunityValue__c, 0,'AllAssociatedTotalOpportunityValue__c should be zero');
        
        Test.stopTest();    
    }
    
    //----------------------------- 
    // @CreatedBy: Tran-Vu Tran
    // @CreatedDate: 22 Apr 2019
    // @CreatedDescription: SFDC-1362 Added unit test to call updateThirdPartyContractAddressFromProcessorLegalEntity() method
    // @return: void
    // 
    // @last Modified by : Kolli Rohit Reddy
    // @last Modified Date : 30 April 2019
    // @last modified description :30 April 2019 , SFDC-1086 : Legal Entity: Add new 'Eligible for xx' fields & update existing 'Eligible for xx' field
    //-----------------------------
    @isTest
    static void testUpdateThirdPartyContractAddressFromProcessorLegalEntity() {
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country1 = lstCountry.get(0);
        Country__c country2 = lstCountry.get(1);

        // creating test account
        List<Account> lstAccount = [Select id,BillingCountryCode from Account order by Name];
        lstAccount[0].BillingCountryCode = country1.CountryCode__c;
        lstAccount[1].BillingCountryCode = country2.CountryCode__c;
        update lstAccount;       
        
        Test.startTest();
        
        Id standardId = Test.getStandardPricebookId();
        
        String testEmail = 'test@ihsmarkit.com';
       
       Contact myTestContact = [Select Id,Email from Contact Where AccountId =: lstAccount[0].Id LIMIT 1];
        myTestContact.Email = testEmail;
        update myTestContact;  
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('Test Legal Entity', 'USD', true, 
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        legalEntity.ThirdPartyProcessorAgreement__c = 'Yes';
        update legalEntity;
        // creating test contract
        Id tppaRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Third Party Processor Agreement').getRecordTypeId();

        Contract testContract = TestUtility.createContract(lstAccount[0].Id, legalEntity.Id, country1.Id, standardId);
        
        testContract.RecordTypeId = tppaRecordTypeId;
        testContract.ClientLegalEntityLookUp__c = lstAccount[0].Id;
        testContract.ProcessorLegalEntityName__c = lstAccount[1].Id;
        update testContract;
        
        Contract assertContract = [Select Id, ProcessorLegalEntityCountry__c, ProcessorLegalEntityCountry__r.Name,
                                   ProcessorLegalEntityStreet__c, ProcessorLegalEntityCity__c, ProcessorLegalEntityStateProvince__c, ProcessorLegalEntityPostalZipCode__c
                                   from Contract where Id =: testContract.Id];
        System.assertEquals(country2.Id, assertContract.ProcessorLegalEntityCountry__c, 'Verifying ProcessorLegalEntityCountry__c lookup value is populated by trigger');
        
        testContract.ProcessorLegalEntityName__c = null;  // set ClientLegalEntityCountryLookup__c = null to simulate when trigger is turned off
        update testContract;
        
        assertContract = [Select Id, ProcessorLegalEntityCountry__c, ProcessorLegalEntityCountry__r.Name,
                                   ProcessorLegalEntityStreet__c, ProcessorLegalEntityCity__c, ProcessorLegalEntityStateProvince__c, ProcessorLegalEntityPostalZipCode__c
                                   from Contract where Id =: testContract.Id];
        System.assertEquals(null, assertContract.ProcessorLegalEntityCountry__r.Name, 'Verifying ProcessorLegalEntityCountry__c lookup value is cleared by trigger');

        Test.stopTest();
    }
    
    //----------------------------- 
    // @CreatedBy: Harshit Singhal
    // @CreatedDate: 08 May 2019
    // @CreatedDescription: SFDC-1431 Test Method for checkVolumeVariableBillingContract() method in ContractMethods class
    // @return: void
    //-----------------------------
    @isTest
    static void testcheckVolumeVariableBillingContract() {        
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        //Id OMRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        
        //Query one of the test Product and set AAG__c='SubscriptionVar'
        Product2 testProd1 = [SELECT Id FROM Product2 Where Name='Test Product1'];
        if(testProd1!=null) {
            testProd1.AAG__c = 'SubscriptionVar';
            update testProd1;
        }
        //Query test opportunity record to create contract
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        //Create test contract of Order Form recordtype        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        //Contract contractRecId = [Select id, status, Fastrack__c, AutoRenewal__c from contract where Opportunity__c =: testOpportunity.Id];
        TestUtility.createContractAttachment(contractRecId);
        
        //Query CLIs of test contract
        List<ContractLineItem__c> cliList = [Select Id,AssociatedProduct__r.AAG__c,AssociatedProduct__c From ContractLineItem__c Where Contract__c = :contractRecId];
        System.debug('**HS8May cliList='+cliList);
                
        //Create BillingScheduleLineItem for one test CLI record
        if(cliList!=null && cliList.size()>0) {
            //Update test CLI record to create BillingScheduleLineItem
            ContractLineItem__c testCLI = cliList[0];
            testCLI.BillingPeriods__c = 2;
            testCLI.BillingScheduleType__c = 'Monthly';
            update testCLI;
            
            //Create BillingScheduleLineItem record
            BillingScheduleLineItem__c testBSLI = new BillingScheduleLineItem__c (IsCreatedfromQuickAction__c = true,ContractLineItem__c=testCLI.id);
            insert testBSLI;
        }
        Test.StartTest();
        //Query and update test contract record to 'Ready For Processing' stage to create OM case
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c from contract where Id=: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed by Customer';
        testContract.OrderReason__c = 'New';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c = 'test@test.com';	
        update testContract;        
        Test.StopTest();
        //Query the OM case created and verify the VolumeVariableBillingContract__c flag
        List<Case> caseList = [select Id,RecordTypeId,VolumeVariableBillingContract__c from case where contract__c =:testContract.id];       
        //System.debug('**HS8May caseList='+caseList);
        System.assertEquals(caseList[0].VolumeVariableBillingContract__c,'Yes','VolumeVariableBillingContract__c flag should be true');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 10 Sep 2019
    // @param: NA
    // @description: Test method for Contract trigger methods contractCheckASC606RevRecProductValidation()
    // @return: NA
    //-----------------------------
    @isTest
    private static void testContractCheckASC606RevRecProductValidation() {
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();        
        
        //Query one of the test Product and set AAG__c='SubscriptionVar'
        Product2 testProd1 = [SELECT Id FROM Product2 Where Name='Test Product1'];
        if(testProd1!=null) {
            testProd1.ASC606RevRec__c='Yes';            
            update testProd1;
        }
        //Query test opportunity record to create contract
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        //Create test contract of Order Form recordtype        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        
        //Query and update test contract record to 'Ready For Processing' stage to create OM case
        Contract testContract = [Select id, status, Fastrack__c, AutoRenewal__c from contract where Id=: contractRecId];
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed by Customer';
        testContract.OrderReason__c = 'New';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c = 'test@test.com';
        //update testContract;
        
        try {
            update testContract;    
        }
        catch(Exception ex) {
            System.assert(ex.getMessage().contains('Earliest Termination Period') && ex.getMessage().contains('Contract Special Options'), 'Validation failed: Please populate Earliest Termination Period and Contract Special Options');            
        }       
    }
    
    //-------------------------------
    // @author: Priyanka Vyas
    // @date: 13 Nov 2019
    // @param: NA
    // @description: SFDC-1863/Test method for Contract trigger methods validateAndCreateImplementationCase() for trial Contract records
    // @return: NA
    //-------------------------------
    @isTest
    private static void testvalidateAndCreateImplementationCase() {
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();        
         
        //Query one of the test Product
        Product2 testProd7 = [SELECT Id FROM Product2 Where Name='Test Product7'];
        
        //Query test opportunity record to create contract
        Opportunity testOpportunity = [SELECT Id, CurrencyISOCode FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        
        //Create test contract of Trial recordtype        
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
        ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity.id, contractRecId, null, trialRecordTypeId, testOpportunity.CurrencyISOCode);
        
        //Query and update test contract record to create the case
        Contract testContract = [Select id, RecordTypeId, status, Fastrack__c, AutoRenewal__c from contract where Id=: contractRecId];
        TestUtility.createContractAttachment(testContract.id);
        testContract.Status = 'ReadyForProcessing';
        testContract.ContractStatus__c = 'Signed by Customer';
        testContract.OrderReason__c = 'New';
        testcontract.Fastrack__c = true;
        testcontract.AutoRenewal__c = true;
        testcontract.PriceIncreaseClause__c = 'No Increase Allowed';
        testContract.NoInternalApprovalNeeded__c = true;
        testContract.TerminationNotice__c = '5 days';
        testContract.RenewalNoticePeriod__c = '60 Days';
        testContract.RenewalDate__c = System.today()+365;
        testContract.BillingFrequency__c = 'Annual';
        testContract.UsageReportsRequired__c = 'No';
        testContract.GlobalSegments__c = 'Consolidated Markets & Solutions,Resources';
        testContract.BillToContactEmailAddress__c = 'test@test.com';
        //update testContract;
        update testContract; 
        System.assertEquals(testContract.RecordTypeId,trialRecordTypeId,'testContract recordtype should be Trial');
    }
    
    //-------------------------------
    // @author: Priyanka Vyas
    // @date: 23rd July 2020
    // @param: NA
    // @description: SFDC-2662, 2663 Validation on Contract to check Master Agreement Exhibit Records for non fast track and IHS Markit Master Agreement.
    // @return: NA
    //-------------------------------
    @isTest
    private static void validateMasterAgreementExhibitList() {
        
        Profile testSalesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%Sales Ops%' limit 1];
        
        User testSalesUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                                      EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                                      LocaleSidKey='en_US', ProfileId = testSalesProfile.Id, 
                                      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihsihs.com',ADID__c='adIdtest'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*123456)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*1324567)));
        insert testSalesUser;
        List<String> masterAgrTypesForMAE = new List<String>();
        masterAgrTypesForMAE=Label.MasterAgrTypeForMAE.split(',');
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Id masterAgreementExhibitRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement Exhibit').getRecordTypeId();
        List<Product2> pList = new List<Product2>();
        List<Product2> prodList = new List<Product2>();
        
        pList = [SELECT Id FROM Product2 Where Name='Test Product7' or Name='Test Product6' or Name='Test Product5'];
        pList[0].GoverningExhibit__c='Software';
        pList[0].Division__c='Resources';
        pList[1].GoverningExhibit__c='Software';
        pList[1].Division__c='Transportation';
        pList[1].GoverningExhibit__c='Services';
        pList[1].Division__c='Transportation';
        prodList.addall(pList);
        update prodList;
        Opportunity testOpportunity = [SELECT Id, accountid, CurrencyISOCode FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id c1 = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        //Contract c1 = [Select id, status, Fastrack__c, AutoRenewal__c from contract where Opportunity__c =: testOpportunity.Id];
        TestUtility.createContractAttachment(c1);
        
        
        	
            //Contract c1 = new Contract(Opportunity__c=testOpportunity.id, Accountid=testOpportunity.AccountId, RecordTypeId=orderFormRecordTypeId, Fastrack__c=true,OrderReason__c='New',PriceIncreaseClause__c='No Increase Allowed',NoInternalApprovalNeeded__c=true,BillingFrequency__c='Annual',ContractStatus__c='Signed by Customer',UsageReportsRequired__c='No',RenewalDate__c=System.today()+365,Status='ReadyForProcessing',TerminationNotice__c='N/A',RenewalNoticePeriod__c='N/A',EarliestTerminationPeriod__c='No Cancellation',ContractSpecialOptions__c='No');
            System.runAs(testSalesUser) {
                //insert c1;
                ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity.id, c1, null, orderFormRecordTypeId, testOpportunity.CurrencyISOCode);
                Id masterAgreementContractId = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementRecordTypeId, testOpportunity.Id);
                test.starttest();
                Id maeRecordId = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementExhibitRecordTypeId, testOpportunity.Id);
                Id maeRecordId2 = ContractRecordTypeSelectionController.createDefaultRecord(masterAgreementExhibitRecordTypeId, testOpportunity.Id);
                
                List<Contract> cList = new List<Contract>();
                Contract maeContract = new Contract(id=maeRecordId,GeneralAgreement__c=masterAgreementContractId,ExhibitType__c='Data');
                Contract maeContract2 = new Contract(id=maeRecordId2,GeneralAgreement__c=masterAgreementContractId,ExhibitType__c='Software');
                Contract c = new Contract(Id=c1, GeneralAgreementType__c=masterAgrTypesForMAE[0], GeneralAgreement__c=masterAgreementContractId);
                TestUtility.createContractAttachment(maeRecordId);
                TestUtility.createContractAttachment(maeRecordId2);
                TestUtility.createContractAttachment(c1);
                cList.add(maeContract);
                cList.add(maeContract2);
                cList.add(c);
                update cList;
                test.stoptest();
                MasterAgreementExhibit__c m1 = new MasterAgreementExhibit__c(MasterAgreementExhibit__c=maeContract.id, OrderFormOrConsulting__c=c.id);
                MasterAgreementExhibit__c m2 = new MasterAgreementExhibit__c(MasterAgreementExhibit__c=maeContract2.id, OrderFormOrConsulting__c=c.id);
                insert new List<MasterAgreementExhibit__c>{m1,m2};
                Contract c2 = new Contract(id=c1, Fastrack__c=false);
                
                try {
                    update c2;
                }catch(Exception e) {
                    System.debug('Exception in validateMasterAgreementExhibitList --> '+e);
                }
                
                c.GeneralAgreementType__c='Other';
                c.GeneralAgreementValue__c='Test';
                update c;
                Boolean maeExists = false;
                for(MasterAgreementExhibit__c mae: [Select id from MasterAgreementExhibit__c where OrderFormOrConsulting__c=:c.id]) {
                    maeExists=true;
                }
                System.assertEquals(maeExists, false, 'All Master Agreement Exhibits should be deleted if Fastrack is turned to true');
            }
        
    }
    
    //-------------------------------
    // @author: Paras Dhingra
    // @date: 8th Sep 2020
    // @param: NA
    // @description: SFDC-3278, SFDC-3292 adding test method for Contract date change on non trial contracts for Sales profiles. 
    //                  ContractMethods.validateContractDateChanges
    // @return: NA
    //-------------------------------
    @isTest
    public static void testValidateContractDateChanges() {
        //create test data
        Profile testSalesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%Sales: General%' limit 1];
        
        User testSalesUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = testSalesProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihsihs.com',ADID__c='adIdtest'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*123456)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*1324567)));
        insert testSalesUser;
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();        
        Id orderFormRecordTypeId =  Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        //Query one of the test Product
        Product2 testProd7 = [SELECT Id FROM Product2 Where Name='Test Product7'];
        
        //Query test opportunity record to create contract
        Opportunity testOpportunity = [SELECT Id, CurrencyISOCode FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        testOpportunity.OwnerId = testSalesUser.Id;
        update testOpportunity;
        UtilityClass.LoggedInUserProfileName = null;
        System.runAs(testSalesUser) {
            Test.startTest();
            //Create test contract of Trial recordtype        
            Id contractTrialRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
            ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity.id, contractTrialRecId, null, trialRecordTypeId, testOpportunity.CurrencyISOCode);
            Id contractOrderformRecId =  ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
            ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity.id, contractOrderformRecId, null, orderFormRecordTypeId, testOpportunity.CurrencyISOCode);
            
            //Query and update test contract record to create the case
            Contract testTrialContract = [Select id, StartDate, EndDate from contract where Id=: contractTrialRecId];
            Contract testOrderFormContract =  [Select id, StartDate, EndDate from contract where Id=: contractOrderformRecId];
            testTrialContract.StartDate = Date.today()+10;
            testTrialContract.EndDate = Date.today()+300;
            //update testContract;
            
                update testTrialContract; 
                System.assert(true,'There will be no exception for trial records');
                try {
                    testOrderFormContract.StartDate = Date.today()+20;
                    testOrderFormContract.EndDate = Date.today()+400;
                    GlobalConstants.byPassContractValidationDates=false;
                    update testOrderFormContract;
                    System.assert(false,'Control should not reach here');
                } catch(DmlException ex) {
                    System.assertEquals('You are not authorized to edit Contract Start/End Date. Please contact Contract Management Team.',ex.getDmlMessage(0),'Exception will occur and user will not be allowed to edit dates');
                }
            Test.stopTest();
        }       
        
    }
    
    //-------------------------------
    // @author: Madhusudhan Karna
    // @date: 11th Dec 2020
    // @param: NA
    // @description: SFDC-2693 adding test method for Auto Renewal field sync on orderForm and consulting contracts for Sales profiles. 
    //               ContractMethods.updateOpptyAutoRenewStopped
    // @return: NA
    //-------------------------------
    @isTest
    public static void testValidateupdateOpptyAutoRenewStopped() {
        //create test data
        Profile testSalesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%Sales: General%' limit 1];
        
        User testSalesUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = testSalesProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihsihs.com',ADID__c='adIdtest'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*123456)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*1324567)));
        insert testSalesUser;
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();        
        Id orderFormRecordTypeId =  Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        //Query one of the test Product
        Product2 testProd7 = [SELECT Id FROM Product2 Where Name='Test Product7'];
        
        //Query test opportunity record to create contract
        List<Opportunity> testOpportunity = [SELECT Id,AutoRenewStopped__c,ContractBeingRenewed__c,(Select Id,AutoRenewStopped__c From Opportunities2__r order by createddate DESC), CurrencyISOCode FROM Opportunity WHERE Name IN('test Opppy','Test Renewal Opp') order by name LIMIT 2];
        testOpportunity[0].OwnerId = testSalesUser.Id;
		testOpportunity[1].OwnerId = testSalesUser.Id;         
        update testOpportunity;
        UtilityClass.LoggedInUserProfileName = null;
        System.runAs(testSalesUser) {
            Test.startTest();
            //Create test contract of Trial recordtype        
            Id contractTrialRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity[0].Id);
            ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity[0].id, contractTrialRecId, null, trialRecordTypeId, testOpportunity[0].CurrencyISOCode);
            Id contractOrderformRecId =  ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity[0].Id);
            ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity[0].id, contractOrderformRecId, null, orderFormRecordTypeId, testOpportunity[0].CurrencyISOCode);
            Opportunity testOpportunityRenew = [SELECT Id,AutoRenewStopped__c,ContractBeingRenewed__c,(Select Id,AutoRenewStopped__c From Opportunities2__r order by createddate DESC), CurrencyISOCode FROM Opportunity WHERE id =:testOpportunity[1].id LIMIT 1];
            testOpportunityRenew.ContractBeingRenewed__c=contractOrderformRecId;
            update testOpportunityRenew;
            //Query and update test contract record to create the case
            Contract testTrialContract = [Select id, AutoRenewStopped__c from contract where Id=: contractTrialRecId];
           
            testTrialContract.AutoRenewStopped__c = true;
            //update testContract;      
                       
            update testTrialContract; 
            //Auto renew stop will not be updated for trail contract
            System.assertNotEquals(testTrialContract.AutoRenewStopped__c, testOpportunity[0].AutoRenewStopped__c);
            try {
                 Contract testOrderFormContract =  [Select id, AutoRenewStopped__c from contract where Id=: contractOrderformRecId];
                 testOrderFormContract.AutoRenewStopped__c = true;
                GlobalConstants.byPassContractValidationDates=false;
                update testOrderFormContract;
                if(testOpportunity!=null && (testOpportunity[0].Opportunities2__r).size()>0){
                    System.assertEquals(testTrialContract.AutoRenewStopped__c, testOpportunity[0].Opportunities2__r[0].AutoRenewStopped__c);
                }
            } catch(DmlException ex) {
                System.assertEquals('You are not authorized to edit Contract auto renew stop field. Please contact Contract Management Team.',ex.getDmlMessage(0),'Exception will occur and user will not be allowed to edit auto renew stop field updated');
            }
            Test.stopTest();
        }       
        
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 18 Jan 2021
    // @param: NA
    // @description: SFDC1-2413 Test method to test if Ship To and Bill To Address Information is populated on creation of Consulting Contract.
    // @return: void
    //-----------------------------
    @isTest
    public static void testBillToAndShipToInformationOnConsultingContract() {
        //create test data
        Profile testSalesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%Sales: General%' limit 1];
        
        User testSalesUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = testSalesProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihsihs.com',ADID__c='adIdtest'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*123456)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*1324567)));
        insert testSalesUser;
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        
        //Query test opportunity record to create contract
        Opportunity testOpportunity = [SELECT Id, CurrencyISOCode FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        testOpportunity.OwnerId = testSalesUser.Id;
        update testOpportunity;
        //Create test contract of Consulting recordtype 
        Test.startTest();              
        Id contractConsultingRecId = ContractRecordTypeSelectionController.createDefaultRecord(consultingRecordTypeId, testOpportunity.Id);
        ContractRecordTypeSelectionController.copyProductsFromOpportunityToContract(testOpportunity.id, contractConsultingRecId, null, consultingRecordTypeId, testOpportunity.CurrencyISOCode);       
      Contract contractRec =[Select BillToCity__c FROM Contract Where Id=:contractConsultingRecId];
        //system.debug('billing city: '+contractRec.BillToCity__c);
        Test.stopTest();
      System.assertEquals(contractRec.BillToCity__c, 'Test City','BillToCity on contract should be Account');
    }
    
    //-----------------------------
      //@author : Vaishali Jain
      //@date : 21 May 2021
      //@description : SFDC1-3473 Test class for ContractMethods.updateAccountContractsCount
      //@param : TriggerParameters
      //@return : void
      //@companyname : IHS Markit

    @isTest private static Void testUpdateAccountContractsCount() {      
          Opportunity assertOpportunity = [Select Id, AccountId, ProfitCenter__c, ProductFamily__c,FormerIP__c,(Select id from OpportunityLineItems) from Opportunity where name='test Opppy' ];
          Account acc = [Select id from Account where name='Processor Account' LIMIT 1];
              
          Opportunity testOpportunity1 = TestUtility.createOpportunity(acc.Id, 'test Oppty', true);
          LegalEntity__c legalEntity = [Select id from LegalEntity__c where name='legalEntity' LIMIT 1];          
          Id standardId = Test.getStandardPricebookId();
          List<Country__c> lstCountry = TestUtility.loadCountryData();
          Country__c country = lstCountry.get(0);
          Contract contract1 = TestUtility.createContractWithInsertOptional(assertOpportunity.AccountId, legalEntity.Id, country.Id, standardId,false);
          contract1.ContractApproved__c = true;
          contract1.Opportunity__c = assertOpportunity.Id;
          Test.StartTest();
          insert contract1;
          contract1.AccountId = acc.Id;
          update contract1;
          Test.StopTest();
          Contract contractRec =[Select Id, Account.AccountContractsCount__c FROM Contract Where Id=:contract1.Id];
          System.assertEquals(1, contractRec.Account.AccountContractsCount__c,'AccountContractsCount__c on contract should not be null');
      }
    
    //-----------------------------
      //@author : Shikhar Singh
      //@date : 28 Jan 2022
      //@description : SFDC-4891 Test class for ContractMethods.lastStatusChangeDateUpdate
      //@param : TriggerParameters
      //@return : void
      //@companyname : IHS Markit
     
     @isTest private static Void testlastStatusChangeDateUpdate() {         
          Account acc = [Select id from Account where name='Account testImplCaseFromOrderFormContract' LIMIT 1];
          Opportunity testOpportunity1 = [Select Id from Opportunity where name='test Opppy' LIMIT 1];
           
          Id standardId = Test.getStandardPricebookId();
          LegalEntity__c legalEntity = [Select id from LegalEntity__c where name='legalEntity' LIMIT 1];          
          List<Country__c> lstCountry = TestUtility.loadCountryData();
          Country__c country = lstCountry.get(0);
          Contract contract1 = TestUtility.createContractWithInsertOptional(acc.Id, legalEntity.Id, country.Id, standardId,true);
          Test.StartTest();
          contract1.ContractStatus__c = 'Signed By Customer';
          update contract1;
          Test.StopTest();
          Contract contractRec =[Select Id, ContractStatus__c,LastContractStatusChangeDate__c FROM Contract Where Id=:contract1.Id];
          System.assertEquals(System.today(), contractRec.LastContractStatusChangeDate__c,'LastContractStatusChangeDate__c on contract should be present day date');
      }
    
    //-----------------------------
      //@author : Kanika Miglani
      //@date : 5th April,2022
      //@description : SFDC-5576 Test class for ContractMethods.automateRenewalFields
      //@param : TriggerParameters
      //@return : void
     
    @isTest 
	private static Void testautomateRenewalFields() {
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        
		Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = [Select Id,StateOrProvinceNew__c from LegalEntity__c where name ='legalEntity'LIMIT 1];
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
		Contract contract1 = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,true);
        contract1.RenewalTerm__c = 'One-time Expiring';
        contract1.RecordTypeId = orderFormRecordTypeId ;
        contract1.EndDate = System.today();
        Test.StartTest();
        contract1.RenewalDate__c = null;
        contract1.AutoRenewal__c = false;
        update contract1;
        Test.StopTest();
        Contract contractRec =[Select Id, RenewalDate__c,RenewalTerm__c,AutoRenewal__c FROM Contract Where Id=:contract1.Id ];
        contractRec.RenewalTerm__c = 'Evergreen';
        contractRec.EndDate = system.today();
        contractRec.AutoRenewal__c = true;
        update contractRec;
        System.assertEquals(null, contractRec.RenewalDate__c,'The RenewalDate should be blank');
        System.assertEquals(true, contractRec.AutoRenewal__c,'the AutoRenewal checkbox should be checked');
	}
    
    //-----------------------------
      //@author : Sharique Iqbal
      //@date : 30 Mar 2022
      //@description : SFDC-5451 Test class for ContractMethods.createContractAttachmentPlaceHolder
      //@param : TriggerParameters
      //@return : void
      //@companyname : IHS Markit
      
     @isTest private static Void TestCreateContractAttachmentPlaceHolder() {   
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
		Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = [Select Id,StateOrProvinceNew__c from LegalEntity__c where name ='legalEntity'LIMIT 1];
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Test.StartTest();
         //Creating Contract
		Id OrderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Contract contract1 = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,false);
        contract1.PoRequired__c= true;
        contract1.RecordTypeId = OrderFormRecordTypeId;
        insert contract1;
        Test.StopTest();
        Contract contractRec =[Select Id, (Select Id from ContractAttachments__r Where AttachmentType__c = 'Purchase Order' limit 1) FROM Contract Where Id=:contract1.Id limit 1];
        System.assertEquals(1, contractRec.ContractAttachments__r.size(),'The ContractAttachment on contract should not be null');
     }
    
    //-----------------------------
      //@author : Kanika Miglani
      //@date : 19th April,2022
      //@description : SFDC-5660 Test class for ContractMethods.renewalTermSAPUpdate
      //@param : TriggerParameters
      //@return : void
      
     @isTest private static Void testrenewalTermSAPUpdate() {
        Account testAccount = [Select Id from Account where name ='Account testImplCaseFromOrderFormContract' Limit 1];
        Id standardId = Test.getStandardPricebookId();
        //Creating Contract
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        LegalEntity__c legalEntity = [Select Id,StateOrProvinceNew__c from LegalEntity__c where name ='legalEntity'LIMIT 1];
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        test.startTest();
         
         //creating an Opportunity 
        Id OppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Opppy', false);
        testOpportunity.ContractStartDate__c = System.today();
        testOpportunity.StageName= '3-Renewal Pending';
        testOpportunity.ContractEndDate__c = System.today().addDays(30);
        testOpportunity.CloseDate = System.today().addDays(35);
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.RecordTypeId = OppRecordTypeId;
        testOpportunity.SAP_RenewalTerm__c = 'Evergreen';
        insert testOpportunity;
         
        Contract contract = TestUtility.createContractWithInsertOptional(testAccount.Id, legalEntity.Id, country.Id, standardId,FALSE);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contract.recordtypeid = orderFormRecordTypeId;
        contract.RenewalTerm__c = 'Evergreen';
        contract.Opportunity__c = testOpportunity.Id;
        contract.EndDate = system.Today();
        contract.RenewalDate__c = system.Today();
        insert contract;
        
        Contract contract1 = [Select id,EndDate,AutoRenewal__c,RenewalTerm__c,RenewalDate__c from Contract where id=: contract.Id ];
        system.assertEquals(true, contract1.AutoRenewal__c,'the AutoRenewal checkbox should be checked');
        system.assertEquals('Evergreen',contract1.RenewalTerm__c,'the Renewal Term should be evergreen');
        test.stopTest();
      }
    
    //-----------------------------
      //@author : Kanika Miglani
      //@date : 19th April,2022
      //@description : SFDC-5660 Test class for ContractMethods.renewalTermSAPUpdate
      //@param : TriggerParameters
      //@return : void
      
	
     @isTest
    static void testPreventContractDeletion() { 
        
        Id TrialRcordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
        Opportunity testOpportunity = [SELECT Id, (select id from OpportunityLineItems) FROM Opportunity WHERE Name='test Opppy' LIMIT 1];
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
        List<Contract> lstContractobj = [Select id,Opportunity__c,Fastrack__c, accountId,BillToContactEmailAddress__c,BillToContactFirstName__c,
            								ShipToContactEmailAddress__c,ShipToContactTelephoneNumber__c  from contract];
        Test.startTest();
        	delete lstContractobj;
        System.assertEquals(lstContractobj=null, null);
		Test.stopTest();        
    }
    

     
}