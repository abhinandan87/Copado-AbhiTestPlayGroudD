@isTest
public class ActivityControllerTest {
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
    
    public static testMethod void getPipelineAccounts(){
        Account accRecord = [SELECT Id,name,parentId FROM Account WHERE name = 'Test Account4' LIMIT 1];
        Map<String, String> allOptions = new Map<String, String>{'field' => 'All Fields', 'value' => 'All Divisions', 'orgId' => 'All Divisions'};
        Map<String, String> mobileOption = new Map<String, String>{'field' => 'Automotive_Amount__c', 'value' => 'Mobility_Automotive_Amount__c', 'orgId' => 'Mobility'};
        Map<String, String> financialOption = new Map<String, String>{'field' => 'Financial_Services_Amount__c', 'value' => 'Financial_Services_Financial_Services_Amount__c', 'orgId' => 'Financial_Services'};
        Map<String, String> indiciesOption = new Map<String, String>{'field' => 'Amount', 'value' => 'Indices_Amount', 'orgId' => 'Indices'};

        List<Map<String, String>> allOptionsFamilies = new List<Map<String, String>>{allOptions};
        List<Map<String, String>> selectedProductFamilies = new List<Map<String, String>>{mobileOption, financialOption, indiciesOption};

        Test.startTest();
            string body='{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/0016s00000BNgvCAAT"},"Id":"0016s00000BNgvCAAT","Name":"Sunplex","CI_Activities__r":{"totalSize":8,"done":true,"records":[{"attributes":{"type":"Opportunity","url":"/sobjects/Account/0016s00000BNgvCAAT"},"Id":"0016s00000BNgvCAAT","Salesforce_Divisional_Org_ID__c" : "00D050000008aim","Salesforce_Divisional_Org_Name__c":"Indices,Platts","ESG_Activity__c":"true"}]}}]}';
            AccountLandingPageMock mockClass1 = new AccountLandingPageMock(body,200);
            Test.setMock(HttpCalloutMock.class, mockClass1);
            ActivityController.getAccountActivities(string.valueOf(accRecord.Id),'Current Quarter','100',allOptionsFamilies, 'Test');
            ActivityController.getAccountActivities(string.valueOf(accRecord.Id),'Next Quarter','100',allOptionsFamilies, 'Test');
            ActivityController.getAccountActivities(string.valueOf(accRecord.Id),'Next Year','100',selectedProductFamilies, 'Test');
            ActivityController.getAccountActivities(string.valueOf(accRecord.Id),'Next Two Years','100',selectedProductFamilies, 'Test');
        Test.stopTest();  
    } 
    
     public static testMethod void getStatus(){
        Test.startTest();
            ActivityController.getStatuses();
        Test.stopTest();  
    } 

}