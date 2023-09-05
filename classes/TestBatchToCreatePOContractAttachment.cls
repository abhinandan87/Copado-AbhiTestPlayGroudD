@isTest
public class TestBatchToCreatePOContractAttachment {
    //-----------------------------
    // @author: Sharique
    // @date: 24 May 2021
    // @description: SFDC-3186 Setup test data for the  batch class
    // @param: none
    // @return: void
    //-----------------------------
    @testSetup 
    public static void createTestData() {
                
        //Account
        Account testAcc = TestUtility.createTestAccount('Test 3186 Account', false);
        testAcc.DataGovernanceStatus__c = 'Approved';
        insert testAcc;
                
        //Contact
        List<Contact> contactList = new List<Contact>();
        Contact testCon1 = TestUtility.createContact(testAcc.Id,'con1@externalorg.com',false,'Contact1','Test 3186 Account');
        contactList.add(testCon1);
        Contact testCon2 = TestUtility.createContact(testAcc.Id,'con2@externalorg.com',false,'Contact2','Test 3186 Account');
        contactList.add(testCon2);
        insert contactList;
        
        //Users
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u1 = new User(Alias = 'adm1', Email='admin1user3186@test.com', 
                          EmailEncodingKey='UTF-8', firstName='test1',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin1user3186@test.com',ADID__c='test1'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        
        User u2 = new User(Alias = 'adm2', Email='admin2user3186@test.com', 
                          EmailEncodingKey='UTF-8', firstName='test2',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin2user3186@test.com',ADID__c='test2'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert new List<User> {u1,u2};
                
        //Legal Entity
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD'); 
                
        //Products - Set Global Segment and AAG
        Product2 p1 = TestUtility.createProduct('Test SubProduct 1', false);
        p1.DiscountThreshold__c = 10;
        p1.LegalEntity__c = testLegalEntity.Id;
        p1.AAG__c = 'Subscription';
        p1.Division__c = 'Financial Svcs-Info';
        Product2 p2 = TestUtility.createProduct('Test SubProduct 2', false);
        p2.DiscountThreshold__c = 12;
        p2.LegalEntity__c = testLegalEntity.Id;
        p2.AAG__c = 'SubscriptionVar';
        p2.Division__c = 'Financial Svcs-Info';
        Product2 p3 = TestUtility.createProduct('Test NonFin Product 3', false);
        p3.DiscountThreshold__c = 12;
        p3.LegalEntity__c = testLegalEntity.Id;
        p3.AAG__c = 'SubscriptionVar';
        p3.Division__c = 'Resources';        
        insert new List<Product2>{p1,p2,p3};
                    
        //Price Book Entry        
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, p1.Id, false);
        PricebookEntry pbe2 = TestUtility.createPriceBookEntry(stdPricebookId, p2.Id, false);
        PricebookEntry pbe3 = TestUtility.createPriceBookEntry(stdPricebookId, p3.Id, false);
        pbe1.CurrencyIsoCode = 'USD';
        pbe2.CurrencyIsoCode = 'USD';
        pbe3.CurrencyIsoCode = 'USD';
        insert new List<PricebookEntry>{pbe1,pbe2,pbe3};
        
        //Create New Business Opp        
        List<Opportunity> testOppList = new List<Opportunity>();
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Opportunity testOpp1 = TestUtility.createOpportunity(testAcc.Id, '3186+ NewBiz Opp1', false);
        testOpp1.ContractStartDate__c = system.today();//date.newinstance(currentFY, 03, 20);
        testOpp1.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpp1.PrimaryContact__c = 'test1 HS';
        testOppList.add(testOpp1);
        Opportunity testOpp2 = TestUtility.createOpportunity(testAcc.Id, '3186+ NewBiz Opp2', false);
        testOpp2.ContractStartDate__c = system.today();//date.newinstance(currentFY, 03, 20);
        testOpp2.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpp2.PrimaryContact__c = 'test1 HS';
        testOppList.add(testOpp2);
        insert testOppList;
        
        //Add opp products
        OpportunityLineItem opp1testOLI1 = TestUtility.createOpportunityLineItem(testOpp1.Id, pbe1, false);
        opp1testOLI1.Product2Id = p1.Id;
        OpportunityLineItem opp1testOLI2 = TestUtility.createOpportunityLineItem(testOpp1.Id, pbe2, false);
        opp1testOLI2.Product2Id = p2.Id;
        OpportunityLineItem opp2testOLI1 = TestUtility.createOpportunityLineItem(testOpp2.Id, pbe1, false);
        opp2testOLI1.Product2Id = p1.Id;
        OpportunityLineItem opp2testOLI2 = TestUtility.createOpportunityLineItem(testOpp2.Id, pbe2, false);
        opp2testOLI2.Product2Id = p2.Id;
        OpportunityLineItem opp2testOLI3 = TestUtility.createOpportunityLineItem(testOpp2.Id, pbe3, false);
        opp2testOLI3.Product2Id = p3.Id;
        List<OpportunityLineItem> testOliList = new List<OpportunityLineItem> {opp1testOLI1,opp1testOLI2,opp2testOLI1,opp2testOLI2,opp2testOLI3};
        insert testOliList;
                       
        //Add Splits, Team, OCR to opp
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole>();
        OpportunityContactRole primaryOCROpp1 = new OpportunityContactRole(OpportunityId=testOpp1.Id,ContactId=testCon1.Id,IsPrimary=true);
        ocrList.add(primaryOCROpp1);
        OpportunityContactRole primaryOCROpp2 = new OpportunityContactRole(OpportunityId=testOpp2.Id,ContactId=testCon2.Id,IsPrimary=true);
        ocrList.add(primaryOCROpp2);
        insert ocrList;
                
        //Create contract
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
        Contract testContractOpp1 = TestUtility.createContractWithInsertOptional(testAcc.Id, testLegalEntity.Id, null, stdPricebookId,false );
        testContractOpp1.Opportunity__c = testOpp1.Id;
        testContractOpp1.PORequired__c = true;
        testContractOpp1.status = 'Draft';
        testContractOpp1.ContractStatus__c = 'Open';
        testContractOpp1.Startdate =  System.today().addMonths(1);
        testContractOpp1.EffectiveDate__c = System.today().addMonths(1); //System.today().addMonths(-11);
        testContractOpp1.Enddate = System.today().addMonths(13);
        testContractOpp1.RecordTypeId = ofRecordTypeId;
        
        Contract testContractOpp11 = TestUtility.createContractWithInsertOptional(testAcc.Id, testLegalEntity.Id, null, stdPricebookId,false );
        testContractOpp11.Opportunity__c = testOpp1.Id;
        testContractOpp11.PORequired__c = true;
        testContractOpp11.status = 'Draft';
        testContractOpp11.ContractStatus__c = 'Open';
        testContractOpp11.Startdate =  System.today().addYears(-2).addMonths(1);
        testContractOpp11.EffectiveDate__c =  System.today().addYears(-2).addMonths(1);
        testContractOpp11.Enddate = System.today().addYears(-1).addMonths(1);
        testContractOpp11.RecordTypeId = ofRecordTypeId;
        
        Contract testContractOpp2 = TestUtility.createContractWithInsertOptional(testAcc.Id, testLegalEntity.Id, null, stdPricebookId,false );
        testContractOpp2.Opportunity__c = testOpp1.Id;
        testContractOpp2.PORequired__c = true;
        testContractOpp2.status = 'Draft';
        testContractOpp2.ContractStatus__c = 'Open';
        testContractOpp2.Startdate =  System.today().addYears(-2).addMonths(1);
        testContractOpp2.EffectiveDate__c = System.today().addYears(-2).addMonths(1);
        testContractOpp2.Enddate = System.today().addYears(2).addMonths(1);
        testContractOpp2.RecordTypeId = ofRecordTypeId;
        
        Contract testContractOpp3 = TestUtility.createContractWithInsertOptional(testAcc.Id, testLegalEntity.Id, null, stdPricebookId,false );
        testContractOpp3.Opportunity__c = testOpp1.Id;
        testContractOpp3.PORequired__c = true;
        testContractOpp3.status = 'Draft';
        testContractOpp3.ContractStatus__c = 'Open';
        testContractOpp3.Startdate =  System.today().addYears(-1);
        testContractOpp3.EffectiveDate__c =  System.today().addYears(-1);
        testContractOpp3.Enddate = System.today().addYears(2);
        testContractOpp3.CACreationDate__c = System.today();
        testContractOpp3.RecordTypeId = ofRecordTypeId;
        
        insert new List<Contract> {testContractOpp1,testContractOpp11,testContractOpp2,testContractOpp3};
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 26 May 2021
    // @description: SFDC-2539 Main test method for the batch class
    // @param: none
    // @return: void
    //-----------------------------
    @isTest
    private static void testMethodGenerateContractAttach() {
       
        List <Contract> testContractList = new List <Contract>();
        for(Contract crt : [SELECT Id,Recordtype.Name,ContractStatus__c,status,PORequired__c, StartDate, EndDate, Renewaldate__c, CACreationDate__c, POAttached__c, Active__c,Account.Name FROM Contract]) {
          crt.ContractStatus__c = 'Validated';
          crt.OrderReason__c = 'New';
          crt.BillingFrequency__c = 'Annual';
          crt.UsageReportsRequired__c = 'No';
          crt.RenewalTerm__c = '1 Year';
          crt.RenewalDate__c = System.today().addYears(4);
          testContractList.add(crt);
        } 
        TestUtility.createMultiContractAttachment(testContractList);
        Test.startTest();
        update testContractList;
        
        //Execute Batch
        BatchToCreateContractAttachment obj=new BatchToCreateContractAttachment();
        Id batchJobId=Database.executeBatch(obj);
        System.debug('batch Id='+batchJobId);
        List <ContractAttachment__c> contractAtt = [Select id from ContractAttachment__c];
        Test.stopTest();
        System.assertEquals(True, contractAtt.size() > 0, 'No Contract Attachment was created');
       
    }
}