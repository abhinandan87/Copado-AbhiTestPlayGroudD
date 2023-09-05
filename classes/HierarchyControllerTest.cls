@IsTest
public class HierarchyControllerTest {
    @testSetup
    public static void createData() {

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

    public static testMethod void getHierarchyAccounts() {
        //Account accRecord = [select Id,name,parentId from Account where name = 'Test Account4' limit 1];
        Account accRecord = [select Id, name, parentId from Account where name = 'Test Account4' limit 1];
        Test.startTest();
            string body = '{"totalSize" : 1,"done" : true, "records" : [ {"attributes" : { },"Id" : "0016s00000BNguxAAD","Platts_Salesforce_Record_ID__c" :"' + accRecord.id + '","Name" : "Openlane", "Parent" : {"attributes" : { },"Name" : "Yearin","Id" : "0016s00000BNguyAAD","Ratings_Account_Manager__r" : {"attributes" : {}, "Name" : "Mary Davis" }},"Ratings_Account_Manager__r" : {"attributes" : { }, "Name" : "Maria Johnson" } } ]}';
            AccountLandingPageMock mockClass1 = new AccountLandingPageMock(body, 200);
            Test.setMock(HttpCalloutMock.class, mockClass1);
            Map<string, string> accountMap = new Map<string, string>();
            accountMap.put('Id', string.valueOf(accRecord.Id));
            accountMap.put('parentId', string.valueOf(accRecord.parentId));
            HierarchyController.getColumns();
            List<Map<string, string>> accountsList = HierarchyController.getHierarchyAccounts(string.valueOf(accRecord.Id), 'Test');
        Test.stopTest();
        System.assert(accountsList != null);
        String divisionId = null;
        for (Map<string, string> accountDetailsMap : accountsList) {
            if (accountDetailsMap.containsKey('DivisionId')) {
                divisionId = accountDetailsMap.get('DivisionId');
            }
        }
        System.assertEquals(accRecord.id, divisionId);
    }

}