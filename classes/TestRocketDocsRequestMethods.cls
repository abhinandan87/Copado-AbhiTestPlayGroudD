@isTest
private class TestRocketDocsRequestMethods {

    //-----------------------------
    // @author: Sharique
    // @date: 20 June 2022
    // @param: NA
    // @description: Test method for RocketDocs Request trigger methods
    // @return: NA
    //-----------------------------
    @testSetup static void testSetup() {
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        c.Phone = '12345';
        c.EmailUnknown__c = true;
        insert c;
        
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
        
        OpportunityContactRole oppContactRole = new OpportunityContactRole();
        oppContactRole.OpportunityID = opp.id;
        oppContactRole.ContactId = c.id;
        oppContactRole.IsPrimary = true;
        insert oppContactRole;
    }
    
    @isTest private static void testPrepopulateFieldsValues() {
        
        Opportunity oppy = [Select Id, AccountId FROM Opportunity Where Name= 'Test Opp' LIMIT 1];
        RocketDocs__Proposal_Request__c req = new RocketDocs__Proposal_Request__c();
        req.RocketDocs__Opportunity__c = oppy.Id;
        req.RocketDocs__Due_Date__c = System.today()+30;
        insert req;
           
        
    }
    
}