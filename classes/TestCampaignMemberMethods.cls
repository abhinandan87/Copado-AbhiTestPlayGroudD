//-----------------------------
// @author : Vaishali Jain
// @date : 10th Oct 2021
// @description : Test Class for CampaignMemberMethods
// @companyname : IHS Markit
//-----------------------------

@isTest
private class TestCampaignMemberMethods {
    
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 10th Oct 2021
    // @description: Method to create test data.
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    static void insertCommonCodeForCreatingCampaignMember() {
        Test.startTest();
        Account acc = TestUtility.createTestAccount('Account testImplCampaignMember', false);
        insert acc;
        
        Contact testContact = TestUtility.createContact(acc.Id, 'testihsmarkit@testihsmarkit.com',false, 'Test', 'Contact');
        insert testContact;
        
        Lead testLead = TestUtility.createLead('Roger', 'Smith', 'Test Company', 'IN', false);
        testLead.Email = 'testihsmarkit@Leadihsmarkit.com';
        insert testLead;
        
        Id campaignRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Campaign').getRecordTypeId();
        Campaign Camp= new Campaign(Name='Test',recordTypeId=campaignRecordTypeId);
        insert Camp; 
        
        CampaignMember cm = new CampaignMember(CampaignId = Camp.Id, ContactId = testContact.Id, LeadId = testLead.Id);
        insert cm;
        //Ankush - Code Coverage for CampaignMemberAfterUpdateHandler
        cm.LegacySystem__c = 'IHS Markit_Salesforce';
        update cm;
        CampaignMember assertCM = [Select id, LegacySystem__c from CampaignMember where id =: cm.Id];
        System.assertEquals('IHS Markit_Salesforce', assertCM.LegacySystem__c, 'Legacy System value is different');
        Test.stopTest();
    }
    
    @isTest
    static void testCamapaignMemberMethod() {
    
        Contact con = [SELECT Id FROM Contact where Name = :'Test Contact'];
        
        Lead ld = [SELECT Id FROM Lead where Name = :'Roger Smith'];
        
        Campaign camp = [Select Id FROM Campaign Where Name = :'Test' LIMIT 1];
        
        CampaignMember cm = [SELECT Id, CampaignId, ContactId, LeadId FROM CampaignMember WHERE CampaignId =: camp.Id];
        System.assertEquals(cm.ContactId, con.Id, 'Contact Name on Campaign record is different');
        System.assertEquals(cm.LeadId, ld.Id, 'Lead Name on Campaign record is different');
        
    }

}