//-----------------------------
// @author: Sushma Yadav
// @date: 10 Feb 2020
// @param: NA
// @description: Test class for Sales Incentive Approval trigger methods 
// @date: 27 Feb 2020: SFDC-2680 Req update so achieving the result via custom button URL hacking
// @return: NA
//-----------------------------

@isTest
public class TestSalesIncentiveApprovalMethod {
    	/* private static testMethod void testpopulateIncentiveOwnerLookupSalesIncentive() {
        test.startTest();
        Account a = TestUtility.createTestAccount('Account testSetRenewalRiskOptysObject', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;      
              
        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName= '1-Sales Qualified';
        opp.RecordTypeId = devRecordTypeId;
        opp.CloseDate = System.today()+2;
        opp.Amount = 123;
        opp.AccountId = a.id;
        insert opp;       
        
        SalesIncentiveApproval__c sIA=new SalesIncentiveApproval__c();
        sIA.Opportunity__c=opp.id;
        sIA.CommissionStatus__c='Open';
        insert sIA;
        //Updated on 12th Feb2020
        List<SalesIncentiveApproval__c> lstSIA=[Select IncentiveOwner__c from SalesIncentiveApproval__c where Id=:sIA.Id];  
        System.assertEquals(UserInfo.getUserId(), lstSIA[0].IncentiveOwner__c); 

        test.stopTest();
        
    } */

    	//-----------------------------
   		// @author: Dev Aggarwal
   		// @date: 9 March 2020
  		// @param: TriggerParameters
   		// @description: SFDC-2681 - Create Data for Testing.
   	@testSetup
    private static void CreateTestDate() {
        Account a = TestUtility.createTestAccount('Account testSetRenewalRiskOptysObject', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;      
              
        
        Id NewBusRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opp = new Opportunity(name='Test Opp', StageName= '1-Sales Qualified', RecordTypeId = NewBusRecordTypeId,
                                         CloseDate = System.today()+2, Amount = 123, AccountId = a.id);
        insert opp;  
    }

    	//-----------------------------
   		// @author: Dev Aggarwal
   		// @date: 9 March 2020
  		// @param: TriggerParameters
   		// @description: SFDC-2681 - Test SubmitForApprovalMethod.
        // BUG-5241405: to avoid getting records locked upon save.
    	@isTest private static void testSubmitForApproval() {
        List<Opportunity> oppties = [Select id from Opportunity where name = 'Test Opp'];
        test.startTest();
        SalesIncentiveApproval__c sIA=new SalesIncentiveApproval__c();
        sIA.Opportunity__c=oppties[0].id;
        sIA.CommissionStatus__c='Open';
        sIA.Ready_for_Submission__c = true;
        insert sIA;
        test.stopTest();
        
        List<ProcessInstance> approvals = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId = :sia.id];
        system.assertEquals(0,approvals.size(),'Record is not submitted for approval');

    } 
}