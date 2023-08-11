//@author: Arshad Qureshi
// @date: 14th July 2023
// @description: Test Class for TestBatchUpdateMobilityMatrics
//---------------------------------------------------------------------------------------------------------------------------
@isTest
public class TestBatchUpdateMobilityMatrics {
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
        opp.ContractStartDate__c = Date.newInstance(2021,8,1);
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
        
        
              
        // Create 1st Renewal Opportunityhttps://ihsmarkit--ea.sandbox.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
        Opportunity oppy1 = TestUtility.createRenewalOpportunity(acc1.Id, testContract.Id, true, false, false, true);
        oppy1.ContractStartDate__c = Date.newInstance(Date.today ().year () - 1,8,1);
        oppy1.CurrencyIsoCode = 'USD';
        oppy1.PreviousFiscalYearOpportunityLink__c = opp.Id;
        oppy1.BusinessLine__c='Automotive Insights';
        oppy1.ContractEndDate__c = oppy1.ContractStartDate__c + 1;
        oppy1.MobilitySalesNew__c = 0.0;
        oppy1.MobilitySalesRenewal__c= 0.0;
        oppy1.SalesNewSubscription__c = 0.0;
        oppy1.SalesPriceIncreaseDecrease__c=0.0;
        oppy1.CurrentYearTotalFirstYearValue__c = 0.0;
        oppy1.CurrentYearTotalFirstYearValueSub__c = 0.0;
        oppy1.SalesLostSubOnly__c = 0.0;
        oppy1.SalesLosttransonly__c = 0.0;
        oppy1.PriorYearTotalFirstYearValue__c=0.00;
        oppy1.PriorYearTotalFirstYearValueSub__c=0.00;
        oppy1.LostReasonCode__c='Customer exiting business';
        oppy1.LostReasonDescription__c='test';
        oppy1.StageName = '6W-Renewal Won';
        system.debug('oppy1.ContractStartDate__c'+oppy1.ContractStartDate__c);
        
        // CREATE OPPORTUNITY CONTACT ROLE (OPPORTUNITY PRIMARY CONTACT)
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.OpportunityId = oppy1.Id;
        ocr2.ContactId = con.Id;
        ocr2.IsPrimary = true;
        ocr2.Role = 'Opportunity Primary Contact';
        INSERT ocr2;
        
        oppy1.PrimaryContact__c = ocr2.Id;
       // Update oppy1;
       
        Test.startTest();
        // Create 2nd Renewal Opportunity
        Opportunity oppy2 = TestUtility.createRenewalOpportunity(acc1.Id, testContract.Id, true, false, false, true);
        oppy2.ContractStartDate__c = oppy1.ContractStartDate__c.addYears(1);
        oppy2.CurrencyIsoCode = 'USD' ;
        oppy2.PreviousFiscalYearOpportunityLink__c = oppy1.id ;
        oppy2.BusinessLine__c='Automotive Insights';
        oppy2.ContractEndDate__c = oppy2.ContractStartDate__c + 1;
        oppy2.MobilitySalesNew__c = 0.0;
        oppy2.MobilitySalesRenewal__c= 0.0;
        oppy2.SalesNewSubscription__c = 0.0;
        oppy2.SalesPriceIncreaseDecrease__c=0.0;
        oppy2.CurrentYearTotalFirstYearValue__c = 0.0;
        oppy2.CurrentYearTotalFirstYearValueSub__c = 0.0;
        oppy2.SalesLostSubOnly__c = 0.0;
        oppy2.SalesLosttransonly__c = 0.0;
        oppy2.PriorYearTotalFirstYearValue__c=0.00;
        oppy2.PriorYearTotalFirstYearValueSub__c=0.00;
        oppy2.StageName = '6W-Renewal Won';
        system.debug('oppy2.ContractStartDate__c'+oppy2.ContractStartDate__c);
        
        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.OpportunityId = oppy2.Id;
        ocr3.ContactId = con.Id;
        ocr3.IsPrimary = true;
        ocr3.Role = 'Opportunity Primary Contact';
        INSERT ocr3;
        
        oppy2.PrimaryContact__c = ocr3.Id;
        //Update oppy2;
        
        
        
        List<Opportunity> listOfOpportunities = new List<Opportunity>{oppy1,oppy2};
        UPDATE listOfOpportunities;
        
        
        //CREATE BUSINESS LINE
        BusinessLine__c bsLine = new BusinessLine__c();
        bsLine.Status__c='Active';
        bsLine.CurrencyIsoCode='USD';
        bsLine.Name='Automotive Insights';
        insert bsLine;
        
        //CREATE PROFIT CENTER
        ProfitCenter__c profitCenter1=new ProfitCenter__c();
        profitCenter1.Active__c=true;
        profitCenter1.CurrencyIsoCode='USD';
        profitCenter1.SaleType__c='Subscription';
        insert profitCenter1;
        
        
        
        // CREATE OPPORTUNITY PRODUCT
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.ProductCode = 'TESTPRODUCT';
        prod.IsActive = true;
        prod.BusinessLine2__c=bsLine.Id;
        prod.AAG__c='Subscription';
        prod.ProfitCenters__c=profitCenter1.Id;
        INSERT prod;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Test Product2';
        prod2.ProductCode = 'TESTPRODUCT';
        prod2.IsActive = true;
        prod2.AAG__c='Transaction';
        prod2.BusinessLine2__c=bsLine.Id;
        prod2.ProfitCenters__c=profitCenter1.Id;
        INSERT prod2;
        
        Product2 prod3 = new Product2();
        prod3.Name = 'Test Product3';
        prod3.ProductCode = 'TESTPRODUCT';
        prod3.IsActive = true;
        prod3.AAG__c='Subscription';
        prod3.BusinessLine2__c=bsLine.Id;
        prod3.ProfitCenters__c=profitCenter1.Id;
        INSERT prod3;
        
        // CREATE PRICEBOOK ENTRY
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100.00;
        pbe.IsActive = true;
        pbe.CurrencyIsoCode = 'USD';
        INSERT pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.Product2Id = prod2.Id;
        pbe2.UnitPrice = 200.00;
        pbe2.IsActive = true;
        pbe2.CurrencyIsoCode = 'USD';
        INSERT pbe2;
        
        PricebookEntry pbe3 = new PricebookEntry();
        pbe3.Pricebook2Id = Test.getStandardPricebookId();
        pbe3.Product2Id = prod3.Id;
        pbe3.UnitPrice = 300.00;
        pbe3.IsActive = true;
        pbe3.CurrencyIsoCode = 'USD';
        INSERT pbe3;
        
        
        // CREATE OPPORTUNITY PRODUCT / LINE ITEM
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = oppy1.Id;
        oli.Product2Id=prod.Id;
        oli.Quantity = 2;
        oli.PricebookEntryId = pbe.Id;
        oli.TotalPrice = oli.Quantity * pbe.UnitPrice;
        oli.FirstYear__c = oli.TotalPrice;
        oli.Status__c = 'New';
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppy1.Id;
        oli2.Product2Id=prod2.Id;
        oli2.Quantity = 2;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.TotalPrice = oli2.Quantity * pbe2.UnitPrice;
        oli2.FirstYear__c = oli2.TotalPrice;
        oli2.Status__c = 'New';
        
		OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = oppy1.Id;
        oli3.Product2Id=prod3.Id;
        oli3.Quantity = 2;
        oli3.PricebookEntryId = pbe3.Id;
        oli3.TotalPrice = oli3.Quantity * pbe3.UnitPrice;
        oli3.FirstYear__c = oli3.TotalPrice;
        oli3.Status__c = 'Lost';
        
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = oppy2.Id;
        oli4.Product2Id=prod.Id;
        oli4.Quantity = 2;
        oli4.PricebookEntryId = pbe.Id;
        oli4.TotalPrice = oli4.Quantity * pbe.UnitPrice;
        oli4.FirstYear__c = oli4.TotalPrice;
        oli4.Status__c = 'New';
        
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = oppy2.Id;
        oli5.Quantity = 2;
        oli5.Product2Id=prod2.Id;
        oli5.PricebookEntryId = pbe2.Id;
        oli5.TotalPrice = oli5.Quantity * pbe2.UnitPrice;
        oli5.FirstYear__c = oli5.TotalPrice;
        oli5.Status__c = 'Existing';
        
        OpportunityLineItem oli6 = new OpportunityLineItem();
        oli6.OpportunityId = oppy2.Id;
        oli6.Quantity = 2;
        oli6.Product2Id=prod3.Id;
        oli6.PricebookEntryId = pbe.Id;
        oli6.TotalPrice = oli6.Quantity * pbe3.UnitPrice;
        oli6.FirstYear__c = oli6.TotalPrice;
        oli6.Status__c = 'Existing';
        
        List<OpportunityLineItem> listOfOpportunityLineItems = new List<OpportunityLineItem>{oli,oli2,oli3,oli4,oli5,oli6};
        INSERT listOfOpportunityLineItems;
        Test.stopTest();   
    }
  
     @isTest
    static void unitTest() {
        List<Opportunity> listOfRenewalOpportunity = new List<Opportunity>();
        Map<Id, List<OpportunityLineItem>> mapOfOpportunityLineItems = new Map<Id, List<OpportunityLineItem>>();
        for (Opportunity oppty : [SELECT Id, Name,CurrencyIsoCode,BusinessLine__c,CurrentYearTotalFirstYearValue__c,MobilitySalesRenewal__c,CurrentYearTotalFirstYearValueSub__c,MobilitySalesNew__c,SalesNewSubscription__c,SalesPriceIncreaseDecrease__c,SalesLostSubOnly__c,SalesLosttransonly__c,PriorYearTotalFirstYearValue__c,PriorYearTotalFirstYearValueSub__c,PreviousFiscalYearOpportunityLink__c,ContractStartDate__c,ContractEndDate__c, (SELECT Id, Status__c,product2.BusinessLine2__r.name,FirstYear__c,ProductType__c FROM OpportunityLineItems where FirstYear__c != null) FROM Opportunity])
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
        Database.executeBatch(new BatchUpdateMobilityMatrics());
        //system.assertEquals(oppy2.PreviousFiscalYearOpportunityLink__c, oppy1.Id);
        Test.stopTest();
    }
}