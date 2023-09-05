//-----------------------------
// @author: Tran-Vu Tran
// @date: 22 March 2019
// @param: NA
// @description: SFDC-1145 Test Class for TestBatchToUpdateOpportunityStage
// @return: NA
//----------------------------
@isTest
private class TestBatchToUpdateOpportunityStage {
    static Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
    static Integer nextFY = currentFY+1;
    
	static Account testAcct;
    static Contact testCont;
    static Opportunity testOppty;
    
    static void DataSetup() {
        testAcct = TestUtility.createTestAccount('Test BatchToUpdateOpportunityStage', true);
        testCont = TestUtility.createContact(testAcct.Id, 'test.contact@ihsmarkit.com', true, 'Test First', 'Test Last');
        
        testOppty = TestUtility.createOpportunity(testAcct.id, 'Test Oppty', null, false);
        testOppty.ContractStartDate__c = date.NewInstance(currentFY, 03, 21);
        testOppty.ContractEndDate__c = date.NewInstance(currentFY+2, 10, 21);
        testOppty.ActivityCreated__c = true;
        insert testOppty;
        
        OpportunityContactRole ocr = new OpportunityContactRole(IsPrimary = true, OpportunityId = testOppty.Id, ContactId = testCont.Id);
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
    // @date: 22 March 2019
    // @param: NA
    // @description: SFDC-1145 Test method for TestBatchToUpdateOpportunityStage
    // when converting Stage '3-Proposal Development and Delivery' to Stage '3-Proposal Development'
    //-----------------------------
    @isTest
    static void testBatchToUpdateOpportunity_Stage3() {
        DataSetup();

        // Start test for converting Stage '3-Proposal Development and Delivery' to Stage '3-Proposal Development'
        test.startTest();
        testOppty.StageName = '3-Proposal Development and Delivery';
        update testOppty;

        BatchToUpdateOpportunityStage testBatch = new BatchToUpdateOpportunityStage();
        testBatch.query = 'Select Id, StageName, Probability From Opportunity where Id=\'' + testOppty.Id +'\'';
        Database.executeBatch(testBatch, 1);
        
        Test.stopTest();
        testOppty = [Select Id, StageName, Probability from Opportunity where Id =: testOppty.Id];
        System.assertEquals('3-Proposal Development', testOppty.StageName,'Opportunity Stage is not updated to Proposal Development');
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 22 March 2019
    // @param: NA
    // @description: SFDC-1145 Test method for TestBatchToUpdateOpportunityStage
    // when converting Stage '4-Proposal Accepted and Verbal Commit' with Probability = 50% to Stage '4.1-Proposal/Quote Delivery'
    //-----------------------------
    @isTest
    static void testBatchToUpdateOpportunity_Stage4_1() {
        DataSetup();

        // Start test for converting Stage '4-Proposal Accepted and Verbal Commit' with Probability = 50% to Stage '4.1-Proposal/Quote Delivery'
        test.startTest();
        testOppty.StageName = '4-Proposal Accepted and Verbal Commit';
        testOppty.Probability = 50;
        update testOppty;

        BatchToUpdateOpportunityStage testBatch = new BatchToUpdateOpportunityStage();
        testBatch.query = 'Select Id, StageName, Probability From Opportunity where Id=\'' + testOppty.Id +'\'';
        Database.executeBatch(testBatch, 1);
        
        Test.stopTest();
        testOppty = [Select Id, StageName, Probability from Opportunity where Id =: testOppty.Id];
        System.assertEquals('4.1-Proposal/Quote Delivery', testOppty.StageName,'Opportunity Stage is not updated to Proposal Quote Delivery');
    }

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 22 March 2019
    // @param: NA
    // @description: SFDC-1145 Test method for TestBatchToUpdateOpportunityStage
    // when converting Stage '4-Proposal Accepted and Verbal Commit' with Probability = 75% to Stage '4.2-Verbal Commit'
    //-----------------------------
    @isTest
    static void testBatchToUpdateOpportunity_Stage4_2() {
        DataSetup();

        // Start test for converting Stage '4-Proposal Accepted and Verbal Commit' with Probability = 75% to Stage '4.2-Verbal Commit'
        test.startTest();
        testOppty.StageName = '4-Proposal Accepted and Verbal Commit';
        testOppty.Probability = 75;
        update testOppty;

        BatchToUpdateOpportunityStage testBatch = new BatchToUpdateOpportunityStage();
        testBatch.query = 'Select Id, StageName, Probability From Opportunity where Id=\'' + testOppty.Id +'\'';
        Database.executeBatch(testBatch, 1);
        
        Test.stopTest();
        testOppty = [Select Id, StageName, Probability from Opportunity where Id =: testOppty.Id];
        System.assertEquals('4.2-Verbal Commit', testOppty.StageName,'Opportunity Stage is not updated to Verbal Commit');
    }

}