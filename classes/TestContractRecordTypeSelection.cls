//-----------------------------
// @author: Prachi Bhasin
// @date: 14 Sept 2017
// @param: NA
// @description: Test Class for ContractRecordTypeSelectionController 
// @return: NA
// @company: VERTIBA
// @lastModifiedBy: Prachi 
// @lastModifiedSprint: Sprint 11 SFDC1-5282 - Removing NDA from create contract wizard & SFDC1-4576 Sync contact roles from Opp to Contract
// @lastModifiedSprint: Sprint 12 SFDC1-710 -  Continuation letter related updates to creation method
// @lastModifiedSprint: Sprint 12 SFDC1-5490 - Client legal entity to be populated with Account
// @lastModifiedSprint: Sprint 13 SFDC1-5520 - Continuation Letter Contract Record Entry
// @Last Modified By : Prachi Bhasin
// @Last Modified Description : Added new test methods for SFDC1-5520
// @Last Modified Date : 17-Nov-2017
// @Last Modified By : Vishnu Vardhan Chowdary Andra
// @Last Modified Description : Updated testFindRecordTypes for new validation check. SFDC1-5640
// @Last Modified Date : 22-Nov-2017
// @Last Modified By : Mohit Modi
// @Last Modified Description : SFDC1-5803 - updated Test Method for 'findRecordTypes' as related Class has been updated.
// @Last Modified Date : 23-Nov-2017
// @Last Modified By : Prachi Bhasin
// @Last Modified Description : Added new assertions for SFDC1-710
// @Last Modified Date : 8-Dec-2017
//-----------------------------
@isTest
private class TestContractRecordTypeSelection {

    @isTest
    static void testFindRecordTypes() {

            Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
            acc.DataGovernanceStatus__c = 'Approved';
            insert acc;
            
            Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        	testOpportunity.SAP_BillingFrequency__c = 'Annual';
        	testOpportunity.SAP_ContractedPriceIncrease__c = 1.00;
        	testOpportunity.SAP_PaymentTerms__c = 'Due Now';
        	testOpportunity.SAP_PriceIncreaseClause__c = 'No Increase Allowed';
        	testOpportunity.SAP_RenewalNoticePeriod__c = 'N/A';
        	testOpportunity.SAP_TerminationNotice__c = 'N/A';
        	insert testOpportunity;
            Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
            
            String str = ContractRecordTypeSelectionController.findRecordTypes('Contract',testOpportunity.Id);
             
            Contract defaultContract = [Select id, accountId from contract where Id=: contractRecId];
            System.assertEquals(defaultContract.accountId,acc.id);

            Contact testContact = TestUtility.createContact(acc.Id, 'testihsmarkit@testihsmarkit.com',
                                                            true, 'Test', 'Contact');
            OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id, IsPrimary=false);
            insert ocr;
        
        Test.startTest();
            defaultContract.SAPPGId__c = 'New';
            defaultContract.Fastrack__c = true;
            update defaultContract;
            String returnstr = ContractRecordTypeSelectionController.findContractStartAndEndDate(testOpportunity.Id,trialRecordTypeId);
            System.assertEquals('NoPrimaryContactOnOpportunity', returnstr);
            ocr.IsPrimary=true;
            update ocr;
            returnstr = ContractRecordTypeSelectionController.findContractStartAndEndDate(testOpportunity.Id,trialRecordTypeId);
            System.assertEquals('NoProductOnOpportunity', returnstr);

            Product2 testProd = TestUtility.createProduct('Test Product', true);
            Id standardId = Test.getStandardPricebookId();
            PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);        
            OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
            update testOpportunity;
            
            Contact oppContact = TestUtility.createContact(acc.Id,'a@b.com',true,'first','last');
            
            OpportunityContactRole oppRole = new OpportunityContactRole(OpportunityId=testOpportunity.Id,ContactId=oppContact.Id, Role='Influencer');
            insert oppRole;
            
            OpportunityLineItemSchedule__c oppSchedule = new OpportunityLineItemSchedule__c(opportunity__c=testOpportunity.id);
            insert oppSchedule;
            contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
        Test.stopTest(); 
            List<ContractLineItem__c> lstContractLineItems = [Select id, name from ContractLineItem__c where contract__c =:contractRecId];
            System.assertEquals(lstContractLineItems.size(),1);
            
            String str1 = ContractRecordTypeSelectionController.setTrialRecordTypeId();
            String str2 = ContractRecordTypeSelectionController.findProductsRelatedToOpportunity(String.ValueOf(testOpportunity.Id));  
            String str3='["'+String.ValueOf(testOLI.id)+'"]';         
            String str4 = ContractRecordTypeSelectionController.createTrialContractRecord(testOpportunity.Id,str3);
            String str5 = ContractRecordTypeSelectionController.findContractStartAndEndDate(testOpportunity.Id,trialRecordTypeId);
            System.assertEquals(str5,'orderFormAlreadyPresent','No Contract with record type Order Form found.');
            
        
    }
    
    @isTest
    static void testDeleteExistingContractLineItemsAndSchedules() {

            Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
            acc.DataGovernanceStatus__c = 'Approved';
            insert acc;
        
            String testEmail = 'dgtest@ihsmarkit.com';
        	Contact myTestContact = TestUtility.createContact(acc.Id, testEmail, true, 'Test', 'Contact');
        
            Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
        	OpportunityContactRole ocr1 = new OpportunityContactRole();
            ocr1.ContactId = myTestContact.Id;
            ocr1.OpportunityId = testOpportunity.Id;
            ocr1.IsPrimary = TRUE;
            ocr1.Role = 'Decision Maker';
            insert ocr1;
        
            Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
            
            String str = ContractRecordTypeSelectionController.findRecordTypes('Contract',testOpportunity.Id);
            
            Contract defaultContract = [Select id, accountId from contract where Id=: contractRecId];
            System.assertEquals(defaultContract.accountId,acc.id);

        Test.startTest(); 
        	ContractRecordTypeSelectionController.isCommunity();
            Product2 testProd = TestUtility.createProduct('Test Product', true);
            Id standardId = Test.getStandardPricebookId();
            PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);        
            OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpportunity.Id, testPBE, true);
            //update testOpportunity;
            
            OpportunityLineItemSchedule__c oppSchedule = new OpportunityLineItemSchedule__c(opportunity__c=testOpportunity.id);
            insert oppSchedule;
        	ContractRecordTypeSelectionController.getActiveLegalEntityForOpp(testOpportunity.Id);
            contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
            
            List<ContractLineItem__c> lstContractLineItems = [Select id, name from ContractLineItem__c where contract__c =:contractRecId];
            System.assertEquals(lstContractLineItems.size(),1);
        	Contract ct = new Contract(Id = defaultContract.Id, Status='Complete',OrderReason__c= 'New', BillingFrequency__c = 'Multi Year',UsageReportsRequired__c='No', RenewalDate__c = system.Today()+365);
        	TestUtility.createContractAttachment(defaultContract.id);
            update ct;
        	Profile p = [SELECT Id ,name FROM Profile WHERE Name like '%General%' limit 1];
        	User u = new User(Alias = 'standt', Email='ctcompletedTest@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='ctcompletedTest@ihsihs.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
            insert u;
            Test.stopTest();
            ContractRecordTypeSelectionController.deleteExistingContractLineItemsAndSchedules(contractRecId);
            String returnval;
            System.runAs(u) {
                returnval=ContractRecordTypeSelectionController.deleteExistingContractLineItemsAndSchedules(defaultContract.Id);
            }
           System.assertEquals(returnval,'ContractCompleted','The contract is not Completed.');
       
    }
    
    @isTest
    static void testFindContractStartAndEndDate() {

            Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
            acc.DataGovernanceStatus__c = 'Approved';
            insert acc;
            
            Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', true);
            Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(trialRecordTypeId, testOpportunity.Id);
            
            String str = ContractRecordTypeSelectionController.findRecordTypes('Contract',testOpportunity.Id);
            
            Contract defaultContract = [Select id, accountId from contract where Id=: contractRecId];
            System.assertEquals(defaultContract.accountId,acc.id);

        Test.startTest();   
            String result = ContractRecordTypeSelectionController.findContractStartAndEndDate(testOpportunity.Id,trialRecordTypeId);
            delete defaultContract;
            result = ContractRecordTypeSelectionController.findContractStartAndEndDate(testOpportunity.Id,orderFormRecordTypeId);
            System.assertEquals(result,'NoPrimaryContactOnOpportunity','Primary Contact found on Opportunity.');
            result = ContractRecordTypeSelectionController.findContractStartAndEndDate(testOpportunity.Id,trialRecordTypeId);
            System.assertEquals(result,'contractDatesPresent','Valid Contract Dates Missing.');
            
        Test.stopTest();
    }
    
    @isTest
    static void testContractEndDateCalculation() {
        Test.startTest();
            String days = '3';
            String startDate = String.valueOf(System.Today());
            Date dateResult = ContractRecordTypeSelectionController.contractEndDateCalculation(days,startDate); 
           System.assertEquals(dateResult ,System.Today().addDays(2),'Contract End Date Mismatch');       
        Test.stopTest();
    }
    
    @isTest
    static void testCreateContinuationContractRecord() {

            Id continuationRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
            acc.DataGovernanceStatus__c = 'Approved';
            insert acc;
            
            Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
            testOpportunity.TotalDaysOfContinuation__c = 30;
            testOpportunity.ContractStartDate__c = System.Today();
            testOpportunity.ContractEndDate__c = System.Today()+30;
        	testOpportunity.ProductFamily__c = 'TEST'; //SFDC1-5228 JK : New
        	testOpportunity.ProductGroup__c = 'TEST';  //SFDC1-5228 JK : New
            insert testOpportunity;
            
            String str = ContractRecordTypeSelectionController.findRecordTypes('Contract',testOpportunity.id);            

        Test.startTest();
            Id orderForm = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpportunity.Id);
            testOpportunity.ContractBeingRenewed__c = orderForm;
            update testOpportunity;
            
            Contract orderFormCreated = [Select id, RecordtypeId from Contract where  id= : orderForm limit 1];
            System.assertEquals(orderFormCreated.RecordtypeId,orderFormRecordTypeId);
            
            String startDate = String.valueOf(System.Today());
            String endDate = String.valueOf(System.Today() + 30);
            String status = '30';
            String acceptanceObtained = 'Yes';

            Id continuationRecordId = ContractRecordTypeSelectionController.createContinuationContractRecord(testOpportunity.Id,startDate,endDate,status,acceptanceObtained);                        
            Date contractStartDate = ContractRecordTypeSelectionController.setContractStartDateFromOppty(testOpportunity.Id);
            Date contractStartDateCalculation = ContractRecordTypeSelectionController.contractContinuationStartDateCalculation(testOpportunity.Id);

            Id continuationRecordId2 = ContractRecordTypeSelectionController.createContinuationContractRecord(testOpportunity.Id,String.valueOf(contractStartDateCalculation),endDate,status,acceptanceObtained);                        
            
            Contract continuationLetterContractCreated = [Select id, Recordtype.Id, startDate, endDate from Contract where Id= : continuationRecordId2 limit 1];
            System.assertEquals(continuationLetterContractCreated.Recordtype.Id,continuationRecordTypeId);
            System.assertNotEquals(continuationLetterContractCreated.startDate,NULL,'Contract Start Date is Null');
            System.assertNotEquals(continuationLetterContractCreated.startDate,NULL,'Contract Start Date is Null');
            
            String contractRecordType = ContractRecordTypeSelectionController.setConLetterRecordTypeId();
            String totalContinuationDays = ContractRecordTypeSelectionController.findTotalDaysOfContinuation(testOpportunity.Id,startDate,endDate);
            System.debug('totalContinuationDays ..'+totalContinuationDays );
            System.assertEquals(totalContinuationDays ,'totalContinuationDays91','Incorrect Total Days of Continuation.');
            
        Test.stopTest();
    }
    
    @isTest
    static void testCreateDefaultRecord() {
        Id NDARecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('NDA').getRecordTypeId();
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', true,
                                                                                    'No', 'No', 'No', 'No', 'No', 'No', 'Yes');
        Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;
        
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.TotalDaysOfContinuation__c = 30;
        testOpportunity.ContractStartDate__c = System.Today();
        testOpportunity.ContractEndDate__c = System.Today()+30;
        testOpportunity.ProductFamily__c = 'TEST'; //SFDC1-5228 JK : New
        testOpportunity.ProductGroup__c = 'TEST';  //SFDC1-5228 JK : New
        insert testOpportunity;
        
        Test.startTest();
        Id ndaContract = ContractRecordTypeSelectionController.createDefaultRecord(NDARecordTypeId, testOpportunity.Id, legalEntity.Id);
        Contract ctrct = [select id, IHSMarkitLegalEntity__c from contract where id = :ndaContract];
        System.assertEquals(legalEntity.Id, ctrct.IHSMarkitLegalEntity__c);
        try{
            //To cover the Exception block
            ContractRecordTypeSelectionController.createDefaultRecord(null,testOpportunity.Id);
        } Catch(Exception e) {
            system.assertEquals('Script-thrown exception', e.getMessage(), 'System.NullPointerException occurs while fetching the substring of null recType');
        }
        Test.stopTest();
        
    }
    @isTest
    static void testGetLegalEntityAndExceptionStatus() {
        Account acc = TestUtility.createTestAccount('Account testGetLegalEntityAndExceptionStatus', true);
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Oppy', true);
		Opportunity oppy = ContractRecordTypeSelectionController.getLegalEntityAndExceptionStatus(testOpportunity.Id);
        System.assertEquals(Null, oppy.LegalEntity__c, 'Legal Entity should be Null');
    }
}