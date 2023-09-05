/**
* @author: Vishnu vardhan Chowdary Andra
* @date: 29 August 2017
* @description: Class to test CaseContractsMethods.
* @companyname: VERTIBA
*/
@isTest
private class TestCaseContractsMethods {
	/**
     * @author: Vishnu vardhan Chowdary Andra
     * @date: 29 August 2017
     * @description: This method tests the CaseContractsMethods by creating/updating/deleting Case Contracts objects.
     * @companyname: VERTIBA 
     * @Last Modified Date : 23-Nov-2017
     * @lastmodifiedBy : Vishnu 
     * @Last Modified Description : fixing the errors in bitbucket
     */ 
    @isTest
    private static void testUpdateRollupSummariesInCase() {
        //create test data
        List<Product2> prodList = new List<Product2>();
        prodList.add(TestUtility.createProduct('Test Product', false));
        prodList.add(TestUtility.createProduct('Product Test', false));
        insert prodList;
        Id standardId = Test.getStandardPricebookId();
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        
        Contract contract1 = TestUtility.createContract(testAccount.Id, legalEntity.Id, country.Id, standardId);
        Contract contract2 = TestUtility.createContract(testAccount.Id, legalEntity.Id, country.Id, standardId);
        List<ContractLineItem__c> cliList = new List<ContractLineItem__c>();
        cliList.add(TestUtility.createContractLineItem('CLI1', contract1.Id, prodList.get(0).Id, false));
        cliList.add(TestUtility.createContractLineItem('CLI2', contract1.Id, prodList.get(1).Id, false));
        cliList.add(TestUtility.createContractLineItem('CLI3', contract2.Id, prodList.get(1).Id, false));
        insert cliList;
        
        Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.subject = 'Test subject';
        testCase.AccountId = testAccount.Id;
        testCase.contactId = testContact.Id;
        insert testCase;
        
        Test.startTest();
        //Case Contract is not added so values should be empty
        Case case1 = getCaseFromDatabase(testCase.id);
        System.debug(case1.Revenue__c+' case1 '+case1.ContractProductList__c); 
        System.assertEquals(null, case1.ContractProductList__c,'Value is not null');
        System.assertEquals(null, case1.Revenue__c,'Revenue Value is not null');
        
        //Creating case Contract, so case should be updated
        CaseContracts__c testCaseContracts1 = createCaseContracts(case1.id,contract1.id);
        case1 = getCaseFromDatabase(testCase.id);
        System.debug(case1.Revenue__c+' case2 '+case1.ContractProductList__c); 
        System.assert(case1.ContractProductList__c.contains('Test Product'),'Product Value does not match');
        System.assert(case1.ContractProductList__c.contains('Product Test'),'Product Value does not match2');
        System.assertEquals(case1.Revenue__c, 2000.0,'Revenue Value does not match');

        //Modifying Contract with different Contract
        testCaseContracts1.Contract__c = contract2.id;
        update testCaseContracts1;
        case1 = getCaseFromDatabase(testCase.id);
        System.debug(case1.Revenue__c+' case3 '+case1.ContractProductList__c); 
        System.assert(case1.ContractProductList__c.contains('Product Test'),'Product List does not contain record');
		System.assertEquals(false,case1.ContractProductList__c.contains('Test Product'),'List does not contain record');
        System.assertEquals(case1.Revenue__c, 1000.0,'Revenue does not match');
        
        //Test by adding a new record to existing one.
        CaseContracts__c testCaseContracts2 = createCaseContracts(case1.id,contract1.id);
        case1 = getCaseFromDatabase(testCase.id);
        System.debug(case1.Revenue__c+' case4 '+case1.ContractProductList__c); 
        System.assert(case1.ContractProductList__c.contains('Product Test'),'Product List does not contain record1');
        System.assert(case1.ContractProductList__c.contains('Test Product'),'List does not contain record1'); 
        System.assertEquals(case1.Revenue__c, 3000.0,'Revenue does not match1');
        
        //Test by deleting record.
        delete testCaseContracts2;
        case1 = getCaseFromDatabase(testCase.id);
        System.debug(case1.Revenue__c+' case5 '+case1.ContractProductList__c); 
        System.assert(case1.ContractProductList__c.contains('Product Test'),'Product List does not contain record2');
		System.assertEquals(false,case1.ContractProductList__c.contains('Test Product'),'List does not contain record2');
        System.assertEquals(case1.Revenue__c, 1000.0,'Revenue does not match2');
        
        Test.stopTest();
    }

    /**
     * @author: Vishnu vardhan Chowdary Andra
     * @date: 12 September 2017
     * @description: helper method to get case object from database.
     * @companyname: VERTIBA 
     */ 
    private static Case getCaseFromDatabase(Id caseId) {
        Case testCase = [Select id, ContractProductList__c, Revenue__c from case where id =: caseId];
        return testCase;
    }

    /**
     * @author: Vishnu vardhan Chowdary Andra
     * @date: 12 September 2017
     * @description: Helper method to insert case contract objects.
     * @companyname: VERTIBA 
     */ 
    private static CaseContracts__c createCaseContracts(id caseId, id contractId) {
        try {
            CaseContracts__c testCaseContracts = new CaseContracts__c();
            testCaseContracts.Case__c = caseId;
            testCaseContracts.Contract__c = contractId;
            insert testCaseContracts;
            return testCaseContracts;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.CaseContractDuplicateCheck) ? true : false;
            // Assert to check correct Error is thrown
            System.AssertEquals(expectedExceptionThrown, true,'Exception is thrown');
            return null;
        }
    }
    
    /**
     * @author: Vishnu vardhan Chowdary Andra
     * @date: 25 September 2017
     * @description: This method tests the ValidateIfCaseProductAlreadyExist by creating/updating Case Contract objects.
     * @companyname: VERTIBA 
     * @lastmodifiedSprint : Sprint 9
     */ 
    @isTest
    private static void testValidateIfCaseProductAlreadyExist() {
        //Create test data
        Id standardId = Test.getStandardPricebookId();
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        
        Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Onboarding').getRecordTypeId();
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.subject = 'Test subject';
        testCase.AccountId = testAccount.Id;
        testCase.contactId = testContact.Id;
        insert testCase;
        
        Contract contract1 = TestUtility.createContract(testAccount.Id, legalEntity.Id, country.Id, standardId);
        Contract contract2 = TestUtility.createContract(testAccount.Id, legalEntity.Id, country.Id, standardId);
        
        Test.startTest();
        //Creating case Contract, record to be inserted successfully
        CaseContracts__c testCaseContracts1 = createCaseContracts(testCase.id,contract1.id);
        System.assertNotEquals(null,testCaseContracts1.id,'Contract is not linked1'); 
        
        //Adding second case Contract, record to be inserted successfully 
        CaseContracts__c testCaseContracts2 = createCaseContracts(testCase.id,contract2.id);
        System.assertNotEquals(null,testCaseContracts2.id,'Contract is not linked2'); 
        
        //Add same case again, it should fail, Exception is caught and returned null.
		testCaseContracts1 = createCaseContracts(testCase.id,contract1.id);
        System.assertEquals(null,testCaseContracts1,'Contract is not linked3'); 
        
        //Modifying Contract with different Contract
        testCaseContracts2.Contract__c = contract1.id;
        try {
            update testCaseContracts2;
        } catch (Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(System.Label.CaseContractDuplicateCheck) ? true : false;
            // Assert to check correct Error is thrown
            System.AssertEquals(expectedExceptionThrown, true,'Exception is thrown');
        }
        
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 17th November 2021
    // @param: NA
    // @description: SFDC-4823 .Test method for method UpdateAccount to update Account and Region on Case from Contract linked
    // @return: NA
    //-----------------------------
	@isTest
    private static void accountUpdate() {
        
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account update on Case', true);
        Account a2 = TestUtility.createTestAccount('Account update on Case post addition', true);
        
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contract cons = TestUtility.createContractWithInsertOptional(a2.Id,legalEntity.Id, country.Id, standardId,true);       
        
        Contact con = TestUtility.createContact(a.Id, 'accountUpdatetest@ihsmarkit.com', true, 'Test', 'Contact');
        test.startTest();
        Case testCase = new Case();
        testCase.subject = 'Test subject update Account and Region';
        testCase.AccountId = a.Id;
        testCase.contactId = con.Id;
        testCase.RecordTypeId = resManagementRecordTypeId;
        insert testCase;
        
        CaseContracts__c testCaseContracts = createCaseContracts(testCase.id,cons.id);
        
        List<Case> cse = [Select id, AccountID, RequestRegion__c from Case where id = :testCase.Id];
        for(Case cases: cse) {
            System.assertEquals(cases.AccountId, a2.Id, 'The Account on the case should be updated to the Account A2 which is part of the Contract');
        }
        test.stopTest();
    }
    
        //-----------------------------
    // @author: Shikhar Singh
    // @date: 02nd December 2021
    // @param: NA
    // @description: SFDC-5051 .Test method for method UpdateAccount to update Account and Region on Case from Contract linked
    // @return: NA
    //-----------------------------
	@isTest
    private static void accountUpdateonDeletion() {
        //create Test Data
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        Account A = TestUtility.createTestAccount('Account update on Case', true);
        Account A2 = TestUtility.createTestAccount('Account update on Case post addition', true);
        Account A3 = TestUtility.createTestAccount('Account update on Case post addition1', true);
        Account A4 = TestUtility.createTestAccount('Account update on Case post addition2', true);
        
        Opportunity opp = Testutility.createOpportunity(A2.Id, 'Test Oppy',true);
        Opportunity opp1 = Testutility.createOpportunity(A3.Id, 'Test Oppy1',true);
        Opportunity opp2 = Testutility.createOpportunity(A.Id, 'Test Oppy2',true);
        
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contract cons = TestUtility.createContractWithInsertOptional(A2.Id,legalEntity.Id, country.Id, standardId,true);
        Contract cons1 = TestUtility.createContractWithInsertOptional(A3.Id,legalEntity.Id, country.Id, standardId,true);
        Contract cons2 = TestUtility.createContractWithInsertOptional(A4.Id,legalEntity.Id, country.Id, standardId,true);
        
        Contact con = TestUtility.createContact(a.Id, 'accountUpdatetest@ihsmarkit.com', true, 'Test', 'Contact');
        test.startTest();
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject update Account and Region';
        testCase1.AccountId = A.Id;
        testCase1.contactId = con.Id;
        testCase1.RecordTypeId = resManagementRecordTypeId;
        insert testCase1;
        
        CaseOpportunities__c testCaseOpportunities1 = new CaseOpportunities__c(Case__c = testCase1.id,Opportunity__c = opp.id); //A2
        insert testCaseOpportunities1;
        CaseOpportunities__c testCaseOpportunities2 = new CaseOpportunities__c(Case__c = testCase1.id,Opportunity__c = opp1.id); //A3
        insert testCaseOpportunities2;
        CaseContracts__c testCaseContracts1 = new CaseContracts__c(Case__c = testCase1.Id,Contract__c = cons1.Id); //A3
        insert testCaseContracts1;
        CaseContracts__c testCaseContracts2 = new CaseContracts__c(Case__c = testCase1.Id,Contract__c = cons2.Id);//A4
        insert testCaseContracts2;
        
        //Check deletion scenario with both Oppies and contracts linked but contract being the latest one
        delete testCaseContracts2;        
        List<Case> cse1 = [Select Id, AccountId FROM Case WHERE Id =:testCase1.Id];
        for(Case cases: cse1) {
            //System.assertEquals(cases.AccountId, A3.Id, 'The Account on the case should be updated to the Account A3 which is part of the case contract1');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 02nd December 2021
    // @param: NA
    // @description: SFDC-5051 .Test method for method UpdateAccount to update Account and Region on Case from Contract linked
    // @return: NA
    //-----------------------------
	@isTest
    private static void accountUpdateonDeletion1() {
        //create Test Data
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        Account A = TestUtility.createTestAccount('Account update on Case', true);
        Account A2 = TestUtility.createTestAccount('Account update on Case post addition', true);
        Account A3 = TestUtility.createTestAccount('Account update on Case post addition1', true);
        Account A4 = TestUtility.createTestAccount('Account update on Case post addition2', true);
        
        Opportunity opp = Testutility.createOpportunity(A2.Id, 'Test Oppy',true);
        Opportunity opp1 = Testutility.createOpportunity(A3.Id, 'Test Oppy1',true);
        Opportunity opp2 = Testutility.createOpportunity(A.Id, 'Test Oppy2',true);
        
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contract cons = TestUtility.createContractWithInsertOptional(A2.Id,legalEntity.Id, country.Id, standardId,true);
        Contract cons1 = TestUtility.createContractWithInsertOptional(A3.Id,legalEntity.Id, country.Id, standardId,true);
        Contract cons2 = TestUtility.createContractWithInsertOptional(A4.Id,legalEntity.Id, country.Id, standardId,true);
        
        Contact con = TestUtility.createContact(a.Id, 'accountUpdatetest@ihsmarkit.com', true, 'Test', 'Contact');
        test.startTest();
        Case testCase2 = new Case();
        testCase2.subject = 'Test subject update Account and Region';
        testCase2.AccountId = A.Id;
        testCase2.contactId = con.Id;
        testCase2.RecordTypeId = resManagementRecordTypeId;
        insert testCase2;
        
        CaseContracts__c testCaseContracts1 = new CaseContracts__c(Case__c = testCase2.Id,Contract__c = cons1.Id); //A3
        insert testCaseContracts1;
        CaseOpportunities__c testCaseOpportunities2 = new CaseOpportunities__c(Case__c = testCase2.id,Opportunity__c = opp1.id); //A3
        insert testCaseOpportunities2;
        CaseOpportunities__c testCaseOpportunities1 = new CaseOpportunities__c(Case__c = testCase2.id,Opportunity__c = opp.id); //A2
        insert testCaseOpportunities1;
        CaseContracts__c testCaseContracts2 = new CaseContracts__c(Case__c = testCase2.Id,Contract__c = cons2.Id);//A4
        insert testCaseContracts2;
        
        //Check deletion scenario with both Oppies and contracts linked but Oppy being the latest one
        delete testCaseContracts2;        
        List<Case> cse1 = [Select Id, AccountId FROM Case WHERE Id =:testCase2.Id];
        for(Case cases: cse1) {
            //System.assertEquals(cases.AccountId, A2.Id, 'The Account on the case should be updated to the Account A2 which is part of the case Oppy1');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 02nd December 2021
    // @param: NA
    // @description: SFDC-5051 .Test method for method UpdateAccount to update Account and Region on Case from Contract linked
    // @return: NA
    //-----------------------------
	@isTest
    private static void accountUpdateonDeletion2() {
        //create Test Data
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        Account A = TestUtility.createTestAccount('Account update on Case', true);
        Account A2 = TestUtility.createTestAccount('Account update on Case post addition', true);
        Account A3 = TestUtility.createTestAccount('Account update on Case post addition1', true);
        
        Opportunity opp = Testutility.createOpportunity(A2.Id, 'Test Oppy',true);
        Opportunity opp1 = Testutility.createOpportunity(A3.Id, 'Test Oppy1',true);
        
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contract cons1 = TestUtility.createContractWithInsertOptional(A3.Id,legalEntity.Id, country.Id, standardId,true);
        
        Contact con = TestUtility.createContact(a.Id, 'accountUpdatetest@ihsmarkit.com', true, 'Test', 'Contact');
        test.startTest();
        Case testCase3 = new Case();
        testCase3.subject = 'Test subject update Account and Region';
        testCase3.AccountId = A.Id;
        testCase3.contactId = con.Id;
        testCase3.RecordTypeId = resManagementRecordTypeId;
        insert testCase3;
        
        CaseOpportunities__c testCaseOpportunities1 = new CaseOpportunities__c(Case__c = testCase3.id,Opportunity__c = opp.id); //A2
        insert testCaseOpportunities1;
        CaseOpportunities__c testCaseOpportunities2 = new CaseOpportunities__c(Case__c = testCase3.id,Opportunity__c = opp1.id); //A3
        insert testCaseOpportunities2;
        CaseContracts__c testCaseContracts1 = new CaseContracts__c(Case__c = testCase3.Id,Contract__c = cons1.Id); //A3
        insert testCaseContracts1;
        
        //Check deletion scenario with only oppies left and update to latest one
        delete testCaseContracts1;        
        List<Case> cse1 = [Select Id, AccountId FROM Case WHERE Id =:testCase3.Id];
        for(Case cases: cse1) {
            //System.assertEquals(cases.AccountId, A3.Id, 'The Account on the case should be updated to the Account A3 which is part of the case Oppy2');
        }
        test.stopTest();
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 02nd December 2021
    // @param: NA
    // @description: SFDC-5051 .Test method for method UpdateAccount to update Account and Region on Case from Contract linked
    // @return: NA
    //-----------------------------
	@isTest
    private static void accountUpdateonDeletion3() {
        //create Test Data
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        Account A = TestUtility.createTestAccount('Account update on Case', true);
        Account A2 = TestUtility.createTestAccount('Account update on Case post addition', true);
        Account A3 = TestUtility.createTestAccount('Account update on Case post addition1', true);
        Account A4 = TestUtility.createTestAccount('Account update on Case post addition2', true);
        
        Opportunity opp = Testutility.createOpportunity(A2.Id, 'Test Oppy',true);        
        
        Id standardId = Test.getStandardPricebookId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD',true,
                                                                                     'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        Country__c country = (Country__c)TestUtility.loadCountryData().get(0);
        Contract cons1 = TestUtility.createContractWithInsertOptional(A3.Id,legalEntity.Id, country.Id, standardId,true);
        Contract cons2 = TestUtility.createContractWithInsertOptional(A4.Id,legalEntity.Id, country.Id, standardId,true);
        
        Contact con = TestUtility.createContact(a.Id, 'accountUpdatetest@ihsmarkit.com', true, 'Test', 'Contact');
        test.startTest();
        Case testCase4 = new Case();
        testCase4.subject = 'Test subject update Account and Region';
        testCase4.AccountId = A.Id;
        testCase4.contactId = con.Id;
        testCase4.RecordTypeId = resManagementRecordTypeId;
        insert testCase4;
        
        CaseContracts__c testCaseContracts1 = new CaseContracts__c(Case__c = testCase4.Id,Contract__c = cons1.Id); //A3
        insert testCaseContracts1;
        CaseContracts__c testCaseContracts2 = new CaseContracts__c(Case__c = testCase4.Id,Contract__c = cons2.Id);//A4
        insert testCaseContracts2;
        
        //Check deletion scenario with only Contracts left and update to latest one
        delete testCaseContracts2;        
        List<Case> cse1 = [Select Id, AccountId FROM Case WHERE Id =:testCase4.Id];
        for(Case cases: cse1) {
            //System.assertEquals(cases.AccountId, A3.Id, 'The Account on the case should be updated to the Account A3 which is part of the case Contract1');
        }
        test.stopTest();
    }
   
}