//@author: Kanika Miglani
// @date: 30th May 2023
// @description: Test Class for BatchUpdatePriorYearOppyLink
//---------------------------------------------------------------------------------------------------------------------------
@isTest
public class TestBatchUpdatePriorYearOppyLink {
@testSetup
    static void createRecords() {
 
        // CREATE ACCOUNT
        Account acc1 = new Account();
        //acc1.parentid = 'Test Parent'; 
        acc1.Name = 'Test Account';
        acc1.BillingStreet = 'No Lane';
        acc1.BillingCity = 'Hyderabad';
        acc1.BillingState = 'Telangana';
        acc1.BillingCountry = 'India';
        acc1.BillingCountryCode = 'IN';
        acc1.DataGovernanceStatus__c = 'Approved';
        insert acc1;
        
        // CREATE CONTACT
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc1.Id;
        con.Email = 'test-contact@sfdc.com';
        INSERT con;
        
        // CREATE OPPORTUNITY
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.CloseDate = Date.newInstance(2022,12,31);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        opp.AccountId = acc1.Id;
        opp.ContractStartDate__c = Date.newInstance(2022,8,1);
        opp.BusinessLine__c = 'Automotive Insights';
        opp.ByPassValidation__c = true;
        opp.StageName = '1-Sales Qualified';
        opp.PreviousFiscalYearOpportunityLink__c = null ;
        opp.ContractEndDate__c = Date.newInstance(2023,8,1);
        INSERT opp;
        
        // Create Contract 
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id orderFormContractId = ContractRecordTypeSelectionController.createDefaultRecord(orderFormRecordTypeId, opp.Id);
        Contract testContract = new Contract(Id = orderFormContractId);
       
        // CREATE OPPORTUNITY CONTACT ROLE (OPPORTUNITY PRIMARY CONTACT)
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp.Id;
        ocr.ContactId = con.Id;
        ocr.IsPrimary = true;
        ocr.Role = 'Opportunity Primary Contact';
        INSERT ocr;
        
        opp.PrimaryContact__c = ocr.Id;
        Update Opp;
        
        
              
        // Create 1st Renewal Opportunity
        Opportunity oppy1 = TestUtility.createRenewalOpportunity(acc1.Id, testContract.Id, true, false, false, true);
        oppy1.ContractStartDate__c = system.today();
        oppy1.CurrencyIsoCode = 'USD';
        oppy1.PreviousFiscalYearOpportunityLink__c = null ;
        oppy1.ContractEndDate__c = system.today() + 1;
        system.debug('oppy1.ContractStartDate__c'+oppy1.ContractStartDate__c);
        Test.startTest();
        // Create 2nd Renewal Opportunity
        Opportunity oppy2 = TestUtility.createRenewalOpportunity(acc1.Id, testContract.Id, true, false, false, true);
        oppy2.ContractStartDate__c = oppy1.ContractStartDate__c.addYears(1);
        oppy2.CurrencyIsoCode = 'USD' ;
        oppy2.PreviousFiscalYearOpportunityLink__c = null ;
        oppy2.ContractEndDate__c = oppy2.ContractStartDate__c + 1;
        system.debug('oppy2.ContractStartDate__c'+oppy2.ContractStartDate__c);
        
        List<Opportunity> listOfOpportunities = new List<Opportunity>{oppy1,oppy2};
        UPDATE listOfOpportunities;
        
        // CREATE OPPORTUNITY PRODUCT
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.ProductCode = 'TESTPRODUCT';
        prod.IsActive = true;
        INSERT prod;
        
        // CREATE PRICEBOOK ENTRY
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100.00;
        pbe.IsActive = true;
        pbe.CurrencyIsoCode = 'USD';
        INSERT pbe;
        
        // CREATE OPPORTUNITY PRODUCT / LINE ITEM
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = oppy1.Id;
        oli.Quantity = 2;
        oli.PricebookEntryId = pbe.Id;
        oli.TotalPrice = oli.Quantity * pbe.UnitPrice;
        oli.FirstYear__c = oli.TotalPrice;
        oli.Status__c = 'New';
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppy1.Id;
        oli2.Quantity = 2;
        oli2.PricebookEntryId = pbe.Id;
        oli2.TotalPrice = oli2.Quantity * pbe.UnitPrice;
        oli2.FirstYear__c = oli2.TotalPrice;
        oli2.Status__c = 'Lost';
        
		OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = oppy1.Id;
        oli3.Quantity = 2;
        oli3.PricebookEntryId = pbe.Id;
        oli3.TotalPrice = oli3.Quantity * pbe.UnitPrice;
        oli3.FirstYear__c = oli3.TotalPrice;
        oli3.Status__c = 'Lost';
        
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = oppy2.Id;
        oli4.Quantity = 2;
        oli4.PricebookEntryId = pbe.Id;
        oli4.TotalPrice = oli4.Quantity * pbe.UnitPrice;
        oli4.FirstYear__c = oli4.TotalPrice;
        oli4.Status__c = 'New';
        
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = oppy2.Id;
        oli5.Quantity = 2;
        oli5.PricebookEntryId = pbe.Id;
        oli5.TotalPrice = oli5.Quantity * pbe.UnitPrice;
        oli5.FirstYear__c = oli5.TotalPrice;
        oli5.Status__c = 'Lost';
        
        OpportunityLineItem oli6 = new OpportunityLineItem();
        oli6.OpportunityId = oppy2.Id;
        oli6.Quantity = 2;
        oli6.PricebookEntryId = pbe.Id;
        oli6.TotalPrice = oli6.Quantity * pbe.UnitPrice;
        oli6.FirstYear__c = oli6.TotalPrice;
        oli6.Status__c = 'Lost';
        
        List<OpportunityLineItem> listOfOpportunityLineItems = new List<OpportunityLineItem>{oli,oli2,oli3,oli4,oli5,oli6};
        INSERT listOfOpportunityLineItems;
        Test.stopTest();   
    }
    
     @isTest
    static void unitTest() {
        List<Opportunity> listOfRenewalOpportunity = new List<Opportunity>();
        Map<Id, List<OpportunityLineItem>> mapOfOpportunityLineItems = new Map<Id, List<OpportunityLineItem>>();
        for (Opportunity oppty : [SELECT Id, Name,PreviousFiscalYearOpportunityLink__c,ContractStartDate__c,ContractEndDate__c, (SELECT Id, Status__c,FirstYear__c FROM OpportunityLineItems where FirstYear__c != null) FROM Opportunity WHERE PreviousFiscalYearOpportunityLink__c = null])
		{
  			mapOfOpportunityLineItems.put(oppty.Id, oppty.OpportunityLineItems);
            system.debug('oppty==>'+oppty);
            listOfRenewalOpportunity.add(oppty);
            system.debug('listOfRenewalOpportunity'+listOfRenewalOpportunity);
            system.debug('listOfRenewalOpportunity.size()'+listOfRenewalOpportunity.size());
         }
       
        system.debug('OpportunityLineItem-->oppLineItem'+mapOfOpportunityLineItems);
        system.debug('listOfRenewalOpportunity'+listOfRenewalOpportunity);
        Test.startTest();
        Database.executeBatch(new BatchUpdatePriorYearOppyLink());
        //system.assertEquals(oppy2.PreviousFiscalYearOpportunityLink__c, oppy1.Id);
        Test.stopTest();
    }
}