//--------------------------------------------------------------------
// @author: Anjali
// @date: 07 July 2021
// @description: This is test class for WorkRequestFormController
//--------------------------------------------------------------------
@isTest
private class TestWorkRequestFormController {
    @testSetup static void testData() {
        Account a = TestUtility.createTestAccount('testAccount', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert u;        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName= '1-Sales Qualified';
        opp.RecordTypeId = devRecordTypeId;
        opp.CloseDate = System.today()+2;
        opp.Amount = 123;
        opp.GAM__c = u.id;
        opp.AccountId = a.id;
        insert opp; 
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.WRFPlanningSolutions__c=true;
        insert testProd;
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry pbEntry = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id,
        Quantity = 5,
        LicenseType__c = 'N/A',
        PricebookEntryId = pbEntry.Id,
        TotalPrice = 5 * pbEntry.UnitPrice);
        insert oli;
        Id PSRecordTypeId = Schema.SObjectType.WorkRequestForm__c.getRecordTypeInfosByName().get('Planning Solutions').getRecordTypeId();
        WorkRequestForm__c wrf = new WorkRequestForm__c();
        wrf.RecordTypeId = PSRecordTypeId;
        wrf.JobType__c = 'Ad Hoc';
        wrf.RoyaltyVendor__c='No Royalty Data';
        wrf.ReturnToSales__c=true;
        wrf.PrimarySalesContact__c=UserInfo.getUserId();
        wrf.RequestedDueDate__c = System.today() + 7;
        wrf.OutputType__c='Comma Delimited (CSV)';
        wrf.OutputMedium__c='CD ROM/DVD';
        wrf.PlanningSolutions__c = true;
        wrf.PlanningSolutionsProdRegions__c  ='Europe';
        wrf.RequestStatus__c='Submitted';
        wrf.OpportunityName__c= opp.Id;
        wrf.AccountName__c= a.Id;
        wrf.PlanningSolutionsEndDate__c=system.today()+10; 
        wrf.PlanningSolutionsStartDate__c = system.today(); 
        insert wrf;
    }
	@isTest private static void testGetOpportunity() {
        String oppId = [Select Id from Opportunity LIMIT 1].Id;
        Opportunity oppyRec;
        Test.startTest();
        oppyRec = WorkRequestFormController.getOpportunity(oppId);
        Test.stopTest();
        system.assertNOTEquals(oppyRec.OwnerId,null, 'getOpportunity method didnot return the record');
    }
    
    @isTest private static void testFetchRecordTypeValues() {
        String oppId = [Select Id from Opportunity LIMIT 1].Id;
        Map<Id, String> recordtypemap;
        Test.startTest();
        recordtypemap = WorkRequestFormController.fetchRecordTypeValues('WorkRequestForm__c',oppId);
        Test.stopTest();
        system.assertEquals(recordtypemap.size(), 1, 'fetchRecordTypeValues method didnot return correct record type');
    }
    @isTest private static void testGetWorkRequestFormRecord() {
        String workReqId = [Select ID from WorkRequestForm__C LIMIT 1].Id;
        WorkRequestForm__c wrfRec;
        Test.startTest();
        wrfRec = WorkRequestFormController.getWorkRequestFormRecord(workReqId);
        Test.stopTest();
        system.assertEquals(wrfRec.PlanningSolutions__c, true, 'getWorkRequestFormRecord method did not return correctwork request form');
    }
    @isTest private static void testGetClonedRecordFromWRF() {
        String workReqId = [Select ID from WorkRequestForm__C LIMIT 1].Id;
        WorkRequestForm__c wrfRec;
        Test.startTest();
        wrfRec = WorkRequestFormController.getClonedRecordFromWRF(workReqId);
        Test.stopTest();
        system.assertEquals(wrfRec.RequestStatus__c, 'Submitted', 'Record is not cloned');
        
    }
    @isTest private static void testGetCloneRecordId() {
        String workReqId = [Select ID from WorkRequestForm__C LIMIT 1].Id;
        Id wrfRec;
        Test.startTest();
        wrfRec = WorkRequestFormController.getCloneRecordId(workReqId,'Clone');
        Test.stopTest();
        system.assertNotEquals(wrfRec, null, 'Record is not cloned');
        
    }
    
     @isTest private static void testGetCloneRecordIdforEstimate() {
        String workReqId = [Select ID from WorkRequestForm__C LIMIT 1].Id;
        Id wrfRec;
        Test.startTest();
        wrfRec = WorkRequestFormController.getCloneRecordId(workReqId,'ConvertEstimate');
        Test.stopTest();
        system.assertNotEquals(wrfRec, null, 'Record is not created');
        
    }
    
    @isTest private static void testGetVindicators() {
        List<Vindicator__mdt> listVindicators;
        Test.startTest();
        listVindicators = WorkRequestFormController.getVindicators('DRDTTYPE_01');
        Test.stopTest();
        system.assertNotEquals(listVindicators.size(), 0, 'getVindicators did not return list of vindicators');
    }
    
    @isTest private static void testSWSDeliveryTimings() {
        List<SWSDeliveryTimings__mdt> listDeliveryTimings;
        Test.startTest();
        listDeliveryTimings = WorkRequestFormController.getSWSDeliveryTimings();
        Test.stopTest();
        system.assertNotEquals(listDeliveryTimings.size(), 0, 'getSWSDeliveryTimings did not return list of delivery timings');
    }
    
    @isTest private static void testGetProductDetails() {
        Opportunity oppyRec =[SELECT Id FROM Opportunity LIMIT 1];
        List<opportunitylineitem> lineItemsLst ;
        Test.startTest();
        lineItemsLst = WorkRequestFormController.getProductDetails(oppyRec.Id);
        Test.stopTest();
        system.assertEquals(lineItemsLst.size(), 1, 'getProductDetails did not return opportunity line items');
    }
    
}