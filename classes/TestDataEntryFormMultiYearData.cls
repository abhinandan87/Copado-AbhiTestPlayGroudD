//-----------------------------
// @author: Harshit Singhal
// @date: 11 Jun 2020
// @param: NA
// @description: SFDC-1810 Test Class for DataEntryFormMultiYearData class
// @return: NA
//----------------------------
@isTest
private class TestDataEntryFormMultiYearData {
    @testSetup
    static void createTestData() {
        
        //Create Account
        Account testAccount = TestUtility.createTestAccount('Account TestBatchCurrentAnnualValue', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        
		//Create Contact        
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',true, 'Test', 'Contact');
        
        //Create Opportunity
        Opportunity testOppy = TestUtility.createOpportunity(testAccount.Id, 'Test Opportunity 1',false);
        testOppy.BudgetRange__c = '< 25,000';
        testOppy.ActivityCreated__c = true;
        testOppy.CloseDate = System.today() + 180;
        insert testOppy;
        
        //Create Opportunity Contact Role
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOppy.Id, ContactId = testContact.Id, IsPrimary=true);
        insert ocr;
        
        //Create Products
        Product2 p1 = TestUtility.createProduct('Test Product 1', false);
        p1.AAG__c='Subscription';
        p1.DiscountThreshold__c = 10;
        Product2 p2 = TestUtility.createProduct('Test Product 2', false);
        p2.DiscountThreshold__c = 12;
        p1.AAG__c='Consulting';
        insert new List<Product2>{p1,p2};
        
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        insert new List<PricebookEntry>{pbe1,pbe2};
        
        Integer currentYear = System.today().year();
            
        //Now create product schedules
        ProductSchedule__c ps1 = TestUtility.createProductSchedule(1223.23, String.valueOf(currentYear), '1 Year', String.valueOf(currentYear), p1.Id, false);
        ProductSchedule__c ps2 = TestUtility.createProductSchedule(2223.23, String.valueOf(currentYear), '5 Years', String.valueOf(currentYear), p2.Id, false);
        ProductSchedule__c ps3 = TestUtility.createProductSchedule(2323.23, String.valueOf(currentYear+1), '5 Years', String.valueOf(currentYear), p2.Id, false);
        ProductSchedule__c ps4 = TestUtility.createProductSchedule(2423.23, String.valueOf(currentYear+2), '5 Years', String.valueOf(currentYear), p2.Id, false);        
        ProductSchedule__c ps5 = TestUtility.createProductSchedule(5423.23, String.valueOf(currentYear+3), '5 Years', String.valueOf(currentYear), p2.Id, false);
        ProductSchedule__c ps6 = TestUtility.createProductSchedule(6423.23, String.valueOf(currentYear+4), '5 Years', String.valueOf(currentYear), p2.Id, false);
        insert new List<ProductSchedule__c>{ps1,ps2,ps3,ps4,ps5};
        
        //Create OLIs
        OpportunityLineItem oli1 = TestUtility.createOpportunityLineItem(testOppy.id, pbe1,false);
        OpportunityLineItem oli2 = TestUtility.createOpportunityLineItem(testOppy.id, pbe2,false);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oli1,oli2};
        insert new List<OpportunityLineItem>{oli1,oli2};
        
        //create Opportunity product schedules        
        OpportunityLineItemSchedule__c ops1 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps1.Id,1223.23,1000,'Amount', 223.23, 0.0, p1.Id, String.valueOf(currentYear), 2, oli1.Id,false);
        OpportunityLineItemSchedule__c ops2 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps2.Id,2223.23,2000,'Amount', 223.23, 0.0, p2.Id, String.valueOf(currentYear), 1, oli2.Id,false);
        OpportunityLineItemSchedule__c ops3 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps3.Id,2323.23,2000,'Amount', 323.23, 0.0, p2.Id, String.valueOf(currentYear+1), 1, oli2.Id,false);
        OpportunityLineItemSchedule__c ops4 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps4.Id,2323.23,2000,'Amount', 423.23, 0.0, p2.Id, String.valueOf(currentYear+2), 1, oli2.Id,false);
        OpportunityLineItemSchedule__c ops5 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps5.Id,5423.23,2000,'Amount', 423.23, 0.0, p2.Id, String.valueOf(currentYear+3), 1, oli2.Id,false);
        OpportunityLineItemSchedule__c ops6 = TestUtility.createOpportunityProductSchedule(testOppy.Id,ps6.Id,6423.23,2000,'Amount', 423.23, 0.0, p2.Id, String.valueOf(currentYear+4), 1, oli2.Id,false);
        
        List<OpportunityLineItemSchedule__c> oliScheduleList = new List<OpportunityLineItemSchedule__c>{ops1,ops2,ops3,ops4,ops5,ops6};
        insert oliScheduleList;
        
        //Create mapping custom setting records for - Opp Product to Contract Line Item setting
        List<OpportunityToContractLineItemMapping__c> oppProdToContractLineItemMapping = new List<OpportunityToContractLineItemMapping__c>();
        //oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='',OpportunityLineItemField__c='',ContractLineItemField__c=''));
        
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='Status',OpportunityLineItemField__c='Status__c',ContractLineItemField__c='Status__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='Discount',OpportunityLineItemField__c='DiscountPercentage__c',ContractLineItemField__c='Discount__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='DiscountType',OpportunityLineItemField__c='DiscountType__c',ContractLineItemField__c='DiscountType__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='OppProductId',OpportunityLineItemField__c='Id',ContractLineItemField__c='OpportunityProductId__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='Quantity',OpportunityLineItemField__c='Quantity',ContractLineItemField__c='Quantity__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='MaterialCode',OpportunityLineItemField__c='MaterialCode__c',ContractLineItemField__c='MaterialCode__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='UpdatedListPrice',OpportunityLineItemField__c='UnitListPrice__c',ContractLineItemField__c='UnitListPriceNew__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='ContractStartDate',OpportunityLineItemField__c='ContractStartDate__c',ContractLineItemField__c='StartDate__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='ContractEndDate',OpportunityLineItemField__c='ContractEndDate__c',ContractLineItemField__c='EndDate__c'));
        oppProdToContractLineItemMapping.add(new OpportunityToContractLineItemMapping__c(Name='TotalPrice',OpportunityLineItemField__c='TotalPrice',ContractLineItemField__c='TotalPriceFromOpportunityLineItem__c'));
               
        insert oppProdToContractLineItemMapping;
        
        //Create mapping custom setting records for - Opp Product Schedules to Contract Line Item Schedules setting
        List<OpportunityToContractScheduleMapping__c> oppProdToContractScheduleMapping = new List<OpportunityToContractScheduleMapping__c>();
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='InstallmentYear',ContractScheduleField__c='InstallmentYear__c',OpportunityScheduleField__c='InstallmentYears__c'));
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='DiscountAmount',ContractScheduleField__c='DiscountAmount__c',OpportunityScheduleField__c='DiscountAmount__c'));
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='DiscountPercent',ContractScheduleField__c='DiscountPercent__c',OpportunityScheduleField__c='DiscountPercent__c'));
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='DiscountType',ContractScheduleField__c='DiscountType__c',OpportunityScheduleField__c='DiscountType__c'));
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='ExternalListPrice',ContractScheduleField__c='ExternalListPrice__c',OpportunityScheduleField__c='ExternalListPrice__c'));
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='SalesPrice',ContractScheduleField__c='SalesPrice__c',OpportunityScheduleField__c='TotalPrice__c'));
        oppProdToContractScheduleMapping.add(new OpportunityToContractScheduleMapping__c(Name='CurrencyIsoCode',ContractScheduleField__c='CurrencyIsoCode',OpportunityScheduleField__c='CurrencyIsoCode'));
        
        insert oppProdToContractScheduleMapping;   
    }
    
    @isTest
    static void createOMCaseAndRunApexDataClass() {
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractRecId;
       // Test.startTest();
        //Query Opportunity
        List<Opportunity> testOppList = [Select Id From Opportunity Where Name='Test Opportunity 1' LIMIT 1];
        Test.startTest();
        for(Opportunity testOpp:testOppList) {
            //Create Order Form Contract
            orderFormContractRecId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, testOpp.Id);            
        }       
        //Query Order Form contract
         
        Contract testContract = new Contract(Id=orderFormContractRecId);
         TestUtility.createContractAttachment(orderFormContractRecId);
        //Update  contract to Stage 10 to generate OM case
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
        update testContract;
        Test.stopTest(); 
        //Check if OM case got generated
        Id omRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
        List<Case> caseList = [SELECT Id,RecordType.Name FROM Case WHERE Contract__c =:testContract.id AND RecordTypeId = :omRecordTypeId];
        System.assertEquals(caseList.size(),1);
        //Setup docgen related parameters
        DataEntryFormMultiYearData defmydApexObj = new DataEntryFormMultiYearData();
        Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
        requestInfo.RecordId = caseList[0].Id;
        
        Set<String> gd = defmydApexObj.getGlobalDescribe();
		System.assertEquals(2, gd.size());
        defmydApexObj.describeObjects(new List<String>(gd));
        List<Loop.ExternalData.Relationship> relationships = new List<Loop.ExternalData.Relationship>();
        for(String str: gd) {
            Loop.ExternalData.Relationship relationship = new Loop.ExternalData.Relationship();
            relationship.Name = str;
            relationships.add(relationship);
        }
        requestInfo.Relationships = relationships;   
        Set<String> relationshipSet = defmydApexObj.getChildRelationships('Totals');
        System.assertEquals(1, relationshipSet.size());
        //Test.stopTest(); 
        Loop.ExternalData.QueryResultSet queryRS = defmydApexObj.query(requestInfo);
        System.assert(queryRS.results.size()>0);
        		       
    }

}