//-----------------------------
// @author: Tran-Vu Tran
// @date: 2 April 2019
// @param: NA
// @description: SFDC-1132 Test Class for TestBatchToUpdateProductOpptyStage
// @return: NA
//----------------------------
@isTest
private class TestBatchToUpdateProductOpptyStage {
    static Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
    static Integer nextFY = currentFY+1;
    
	static Account testAcct;
    static Contact testCont;
    static Opportunity testOppty;
    static Id renewalOpptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();

    @testSetup
    static void DataSetup() {
        testAcct = TestUtility.createTestAccount('Test BatchToUpdateProductOpptyStage', true);
        testCont = TestUtility.createContact(testAcct.Id, 'test.contact@ihsmarkit.com', true, 'Test First', 'Test Last');
        
        testOppty = TestUtility.createOpportunity(testAcct.id, 'Test Oppty', null, false);
        testOppty.ContractStartDate__c = date.NewInstance(currentFY, 03, 21);
        testOppty.ContractEndDate__c = date.NewInstance(currentFY+2, 10, 21);
        testOppty.ActivityCreated__c = true;
        insert testOppty;
        
        OpportunityContactRole ocr = new OpportunityContactRole(IsPrimary = true, OpportunityId = testOppty.Id, ContactId = testCont.Id);
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        ProfitCenter__c testProfitCenter = new ProfitCenter__c(Name='UP - Energy', Active__c=true, ProfitCenterCode__c='187');
        insert testProfitCenter;
        
        Family__c testProdFamily = new Family__c(Name='ETC-C&A',Status__c ='Active');
        insert testProdFamily;
        
        ProductGroup__c testProdGroup = TestUtility.createProductGroup('MRO',false,false);
        
        Product2 testProd = TestUtility.createProduct('Test Product', false);
        testProd.FormerIpOwner__c = 'IHS Markit Global Inc.';
        testProd.Family__c = testProdFamily.Id;
        testProd.ProfitCenters__c = testProfitCenter.Id;
        testProd.ProductGroup__c = testProdGroup.Id;
        insert testProd;
        
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOppty.Id, testPBE, true);
        ProductSchedule__c testPS = TestUtility.createProductSchedule(2223.23, String.valueof(currentFY), '1 Year', String.valueof(currentFY), testProd.Id, false);
        insert testPS;
        
        OpportunityLineItemSchedule__c testOLIS = TestUtility.createOpportunityProductSchedule(testOppty.Id, testPS.Id, 2223.23, 2000, 'Amount', 223.23, 0.0,
                                                                                               testProd.Id, '2017', 1, testOLI.Id, false);
        insert testOLIS;
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 2 April 2019
    // @param: NA
    // @description: SFDC-1132 Test method for TestBatchToUpdateProductOpptyStage when Opportunity Stage changes to 6L
    //-----------------------------
    @isTest
    static void testBatchToUpdateProductOpptyStage_6L() {
        test.startTest();
        Opportunity testOppty = [select Id, StageName, Probability from Opportunity where Name = 'Test Oppty' limit 1];
        testOppty.StageName = '6L-Closed Lost';
        testOppty.LostReasonCode__c = 'Cutting Costs/Lost Budget';
        testOppty.LostReasonDescription__c = 'Close for testing';
        update testOppty;

        BatchToUpdateProductOpptyStage testBatch = new BatchToUpdateProductOpptyStage();
        testBatch.query = 'Select Id, OpportunityStage__c from OpportunityLineItem where OpportunityId=\'' + testOppty.Id +'\'';
        Database.executeBatch(testBatch, 1);
        
        Test.stopTest();
        System.assertEquals(0, [Select Count() from OpportunityLineItem where OpportunityId =: testOppty.Id and OpportunityStage__c != :testOppty.StageName],'OLI / Opportunity stage are not same.');
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 2 April 2019
    // @param: NA
    // @description: SFDC-1132 Test method for TestBatchToUpdateProductOpptyStage when Opportunity Stage changes to 6W for auto-renewal without changes
    //-----------------------------
    @isTest
    static void testBatchToUpdateProductOpptyStage_6W() {
        test.startTest();
        Opportunity testOppty = [select Id, StageName, Probability from Opportunity where Name = 'Test Oppty' limit 1];
        testOppty.RecordTypeId = renewalOpptyRecordTypeId;
        testOppty.AutoRenewal__c = true;
        testOppty.StageName = '6W-Renewal Won';

        update testOppty;

        BatchToUpdateProductOpptyStage testBatch = new BatchToUpdateProductOpptyStage();
        testBatch.query = 'Select Id, OpportunityStage__c from OpportunityLineItem where OpportunityId=\'' + testOppty.Id +'\'';
        Database.executeBatch(testBatch, 1);
        
        Test.stopTest();
        System.assertEquals(0, [Select Count() from OpportunityLineItem where OpportunityId =: testOppty.Id and OpportunityStage__c != :testOppty.StageName],'OLI / Opportunity stage are not same.');
    }
    //-----------------------------
    // @author: Sathish Edla  
    // @date: 17 Mar 2022
    // @description: This method is used to improve the test code coverage of BatchToUpdateProductOpptyStageScheduler class.
    //-----------------------------
    @isTest static void testBatchToUpdateProductOpptyStageScheduler(){
        test.startTest();
        SchedulableContext sc = null;
        BatchToUpdateProductOpptyStageScheduler tsc = new BatchToUpdateProductOpptyStageScheduler();
        tsc.execute(sc);
        String query = 'Select Id, OpportunityStage__c, Opportunity.StageName from OpportunityLineItem '
            + 'where OpportunityStage__c != \'\' and ' 
            + '((Opportunity.StageName like \'%6L%\' and (not(OpportunityStage__c like \'%6L%\'))) '
            + ' or (Opportunity.StageName like \'%6W%\' and (not(OpportunityStage__c like \'%6W%\'))) '
            + ' or (Opportunity.StageName like \'%6WP%\' and (not(OpportunityStage__c like \'%6WP%\'))))';
        List<OpportunityLineItem> lstOLI = Database.query(query);
        system.assertEquals(0, lstOLI.size(),'OLI Opportunity Stage and Opportunity Stage are same');
        test.stopTest();
    }
}