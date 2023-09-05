//-----------------------------
// @author: Neelam Agrawal
// @date: 10 Feb 2022
// @param: NA
// @description:  SFDC-5361 Test Class for BatchUpdateRollUpFieldOnParent batch class
// @return: NA
@isTest(seealldata=false)
public class TestBatchUpdateRollUpFieldOnParent {
    
 @testSetup 
    public static void createTestData() {
        
        //Create custom setting records 
        TestBatchUpdateRollUpFieldOnParent.createTestCustomRollUpCustomSettings();
        //Account
        Account testAcc1 = TestUtility.createTestAccount('Test1 5361 Account1', false);
        testAcc1.DataGovernanceStatus__c = 'Approved';
        insert testAcc1;
        Account testAcc2 = TestUtility.createTestAccount('Test1 5361 Account2', false);
        testAcc2.DataGovernanceStatus__c = 'Approved';
        insert testAcc2;
        
        
        //Contact
        List<Contact> contactList = new List<Contact>();
        Contact testCon1 = TestUtility.createContact(testAcc1.Id,'con1@externalorg.com',false,'Contact1','Test 3186 Account');
        contactList.add(testCon1);
        Contact testCon2 = TestUtility.createContact(testAcc2.Id,'con2@externalorg.com',false,'Contact2','Test 3186 Account');
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
                          TimeZoneSidKey='America/Los_Angeles', UserName='admin2user3186@test.com',ADID__c='test2'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c='10020');
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
        
        //Product Schedules
        ProductSchedule__c p1ps1 = TestUtility.createProductSchedule(1000.10, '2020', '3 Years', '2020', p1.Id, false);
        ProductSchedule__c p1ps2 = TestUtility.createProductSchedule(1010.20, '2021', '3 Years', '2020', p1.Id, false);
        ProductSchedule__c p1ps3 = TestUtility.createProductSchedule(1020.30, '2022', '3 Years', '2020', p1.Id, false);
        ProductSchedule__c p2ps1 = TestUtility.createProductSchedule(2000.10, '2020', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p2ps2 = TestUtility.createProductSchedule(2020.20, '2021', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p2ps3 = TestUtility.createProductSchedule(2030.30, '2022', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p3ps1 = TestUtility.createProductSchedule(2000.10, '2020', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p3ps2 = TestUtility.createProductSchedule(2020.20, '2021', '3 Years', '2020', p2.Id, false);
        ProductSchedule__c p3ps3 = TestUtility.createProductSchedule(2030.30, '2022', '3 Years', '2020', p2.Id, false);
        
        //Create New Business Opp        
        List<Opportunity> testOppList = new List<Opportunity>();
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
        Opportunity testOpp1 = TestUtility.createOpportunity(testAcc1.Id, '3186+ NewBiz Opp1', false);
        testOpp1.ContractStartDate__c = date.newinstance(currentFY, 03, 20);
        testOpp1.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpp1.MISActivityAdded__c = DateTime.now();
        testOpp1.ActivityCreated__c = true;
        testOppList.add(testOpp1);
        Opportunity testOpp2 = TestUtility.createOpportunity(testAcc2.Id, '3186+ NewBiz Opp2', false);
        testOpp2.ContractStartDate__c = date.newinstance(currentFY, 03, 20);
        testOpp2.ContractEndDate__c = date.newinstance(currentFY+3, 03, 19);
        testOpp2.MISActivityAdded__c = DateTime.now();
        testOpp2.ActivityCreated__c = true;
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
        
        //Add opp prod schedules
        List<OpportunityLineItemSchedule__c> testOLISList = new List<OpportunityLineItemSchedule__c>();
        for(OpportunityLineItem testOLI:testOliList) {
            OpportunityLineItemSchedule__c testOLIS1 = TestUtility.createOpportunityProductSchedule(testOLI.OpportunityId,null,1200,1000,'Amount', 100, 0.0, testOLI.Product2Id, '2020', 1, testOLI.Id,false);
            testOLISList.add(testOLIS1);
            OpportunityLineItemSchedule__c testOLIS2 = TestUtility.createOpportunityProductSchedule(testOLI.OpportunityId,null,1220,1010,'Amount', 100, 0.0, testOLI.Product2Id, '2021', 1, testOLI.Id,false);
            testOLISList.add(testOLIS2);
            OpportunityLineItemSchedule__c testOLIS3 = TestUtility.createOpportunityProductSchedule(testOLI.OpportunityId,null,1220,1010,'Amount', 100, 0.0, testOLI.Product2Id, '2022', 1, testOLI.Id,false);
            testOLISList.add(testOLIS3);
        }
        insert testOLISList;  
        
        Product2 pr= [Select id,Division__c from Product2 where name='Test NonFin Product 3' Limit 1];
        pr.Division__c='resourcestest';
        update pr;
        
        Account acc= [Select Id,DataGovernanceStatus__c from Account where name='Test1 5361 Account2'];
        acc.DataGovernanceStatus__c='Unapproved';
        update acc;
        

    }
    
    @isTest
    public static void testMethodPositiveCreateRenewalOpp() {
   
        Test.startTest();
        BatchUpdateRollUpFieldOnOppyScheduler sh1= new BatchUpdateRollUpFieldOnOppyScheduler();
        BatchUpdateRollUpFieldContractScheduler sh2= new BatchUpdateRollUpFieldContractScheduler();
        String sch1 = '0 0 23 * * ?';
        String sch2 = '0 0 14 * * ?';
        System.schedule('test oppyupdate batch', sch1,sh1 );
        System.schedule('test contractupdate batch', sch2,sh2 );
        BatchUpdateRollUpFieldOnParent obj= new BatchUpdateRollUpFieldOnParent(new batchParameter('Opportunity','OpportunityLineItem','OpportunityId','','AND Status__c!=\'Lost\''));
        Database.executeBatch(obj,200);
        Test.stopTest();
        
        
    }
    
    public static List<CustomRollUpConfiguration__c> createTestCustomRollUpCustomSettings(){
        List<CustomRollUpConfiguration__c> mappingList= new List<CustomRollUpConfiguration__c>();    
        CustomRollUpConfiguration__c mapping1= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem1', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.Family__r.name', ParentField__c='ProductFamily__c');
        mappingList.add(mapping1);  
        CustomRollUpConfiguration__c mapping2= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem2', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.ProductGroup__r.name', ParentField__c='ProductGroup__c');
        mappingList.add(mapping2);  
        CustomRollUpConfiguration__c mapping3= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem3', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.FormerIPOwner__c', ParentField__c='formerIP__c');
        mappingList.add(mapping3);  
        CustomRollUpConfiguration__c mapping4= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem4', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.SubBusinessLine__r.Name', ParentField__c='SubBusinessLine__c');
        mappingList.add(mapping4);  
        CustomRollUpConfiguration__c mapping5= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem5', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.Division__c', ParentField__c='GlobalSegments__c');
        mappingList.add(mapping5);  
        CustomRollUpConfiguration__c mapping6= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem6', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.InternalBusinessSegment__c', ParentField__c='InternalBusinessSegment__c');
        mappingList.add(mapping6);
        CustomRollUpConfiguration__c mapping7= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem7', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.ProfitCenters__r.name', ParentField__c='ProfitCenter__c');
        mappingList.add(mapping7);   
        CustomRollUpConfiguration__c mapping8= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem8', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='PricebookEntry.Product2.BusinessLine2__r.Name', ParentField__c='BusinessLine__c');
        mappingList.add(mapping8); 
        CustomRollUpConfiguration__c mapping9= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem9', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='SynergyType__c', ParentField__c='SynergyType__c');
        mappingList.add(mapping9);   
        CustomRollUpConfiguration__c mapping10= new CustomRollUpConfiguration__c(Name='Opportunity to OpportunityLineItem10', Active__c=true, ChildObject__c='OpportunityLineItem', ParentObject__c='Opportunity', ChildField__c='SynergyTheme__c', ParentField__c='SynergyTheme__c');
        mappingList.add(mapping10);
        CustomRollUpConfiguration__c contractMapping1= new CustomRollUpConfiguration__c(Name='Contract to ContractLineItem1', Active__c=true, ChildObject__c='ContractLineItem__c', ParentObject__c='Contract', ChildField__c='AssociatedProduct__r.Family__r.Name', ParentField__c='ProductFamily__c');
        mappingList.add(contractMapping1);  
        CustomRollUpConfiguration__c contractMapping2= new CustomRollUpConfiguration__c(Name='Contract to ContractLineItem2', Active__c=true, ChildObject__c='ContractLineItem__c', ParentObject__c='Contract', ChildField__c='AssociatedProduct__r.ProductGroup__r.Name', ParentField__c='ProductGroup__c');
        mappingList.add(contractMapping2);   
        CustomRollUpConfiguration__c contractMapping3= new CustomRollUpConfiguration__c(Name='Contract to ContractLineItem4', Active__c=true, ChildObject__c='ContractLineItem__c', ParentObject__c='Contract', ChildField__c='AssociatedProduct__r.SubBusinessLine__r.name', ParentField__c='SubBusinessLine__c');
        mappingList.add(contractMapping3);  
        CustomRollUpConfiguration__c contractMapping4= new CustomRollUpConfiguration__c(Name='Contract to ContractLineItem5', Active__c=true, ChildObject__c='ContractLineItem__c', ParentObject__c='Contract', ChildField__c='	AssociatedProduct__r.Division__c', ParentField__c='GlobalSegments__c');
        mappingList.add(contractMapping4);  
        CustomRollUpConfiguration__c contractMapping5= new CustomRollUpConfiguration__c(Name='Contract to ContractLineItem6', Active__c=true, ChildObject__c='ContractLineItem__c', ParentObject__c='Contract', ChildField__c='AssociatedProduct__r.InternalBusinessSegment__c', ParentField__c='InternalBusinessSegment__c');
        mappingList.add(contractMapping5);
        CustomRollUpConfiguration__c contractMapping6= new CustomRollUpConfiguration__c(Name='Contract to ContractLineItem8', Active__c=true, ChildObject__c='ContractLineItem__c', ParentObject__c='Contract', ChildField__c='AssociatedProduct__r.BusinessLine2__r.Name', ParentField__c='BusinessLine__c');
        mappingList.add(contractMapping6);
        insert mappingList;
        return mappingList;
    }
}