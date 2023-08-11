@isTest
public class AccountLandingPageControllerTest {
    @testSetup
    public static void createData(){
        
        Customer_Insight_Settings__c cs = new Customer_Insight_Settings__c();
        cs.Mapping_Key__c = 'AccountNumber';
        cs.Error_Message_From_Address__c = 'test@test.com';
        cs.Error_Message_To_Address__c = 'test@test.com';
        insert cs;

        Account accRecord1 = new Account();
        accRecord1.name = 'Test Account1';
        insert accRecord1;
        
        Account accRecord2 = new Account();
        accRecord2.name = 'Test Account2';
        accRecord2.parentId = accRecord1.Id;
        insert accRecord2;
        
        Account accRecord3 = new Account();
        accRecord3.name = 'Test Account3';
        accRecord3.parentId = accRecord2.Id;
        insert accRecord3;
        
        Account accRecord4 = new Account();
        accRecord4.name = 'Test Account4';
        accRecord4.parentId = accRecord3.Id;
        insert accRecord4;
    }

    @IsTest
    public static void getAccountTest(){
        Account accRecord = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
            String body = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/0011F00000gmcgwQAA"},"Id":"0011F00000gmcgwQAA","Name":"Test Account", "MI_Account_Manager__r " : { "attributes" : { "type" : "Account", "url" : "/services/data/v50.0/sobjects/Account/0014x000008INXCAA4" }, "Name" : "Acme (Sample)" }}]}';
            AccountLandingPageMock mockClass1 = new AccountLandingPageMock(body,200);
            Test.setMock(HttpCalloutMock.class, mockClass1);
            AccountLandingPageController.getAccount(accRecord.name, 'Test');
            AccountLandingPageController.getLocalAccount(accRecord.Id);
            AccountLandingPageController.getProductFamily();
        Test.stopTest();  
    }

    @IsTest
    public static void getDataSyncSummaryTest(){
        Account accRecord = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
            String body = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Data_Sync_Summary__c","url":"/services/data/v50.0/sobjects/Data_Sync_Summary__c/0011F00000gmcgwQAA"},"Id":"0011F00000gmcgwQAA","Name":"Test Summary", "Last_INFA_Data_Update__c":"2022-04-28T17:00:00.000Z" }]}';
            AccountLandingPageMock mockClass1 = new AccountLandingPageMock(body,200);
            Test.setMock(HttpCalloutMock.class, mockClass1);
            AccountLandingPageController.getDataSyncSummaryDate('Test');
        Test.stopTest();
    }

    @IsTest
    public static void sendErrorEmailTest(){
        Map<String, String> errorObject = new Map<String, String>();
        Test.startTest();
            AccountLandingPageController.sendErrorEmail(errorObject);
        Test.stopTest();
    }
}