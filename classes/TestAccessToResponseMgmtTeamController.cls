//-----------------------------
// @author: Sharique Iqbal
// @date: 4th Fev 2022
// @param: NA
// @description: Test Class for AccessToResponseManagementTeamController

@isTest
public class TestAccessToResponseMgmtTeamController {
     
    @isTest
     static void testupdateAssociatedWithResMmtTeam() { 
		
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
    	Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Oppy', false);
        testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        insert testOpportunity;
        
        Test.startTest(); 
        AccessToResponseManagementTeamController.updateAssociatedWithResMmtTeam (testOpportunity.Id, True);
        Test.stopTest();
         
        Opportunity  oppy = [Select Id,AssociatedwithResponseManagementTeam__c from Opportunity where Name= 'test Oppy']; 
        System.assertEquals(True, oppy.AssociatedwithResponseManagementTeam__c, 'Opportunity was not updated!!');  
     }
    
    @isTest
     static void testupdateAssociatedWithResMmtTeamWithCSRec() { 
		  
        Id currentUserId = UserInfo.getUserId();
        SystemMutedValidationRules__c smve = SystemMutedValidationRules__c.getInstance(currentUserId);
        smve.Opportunity__c = false;//SFDC-5428
        insert smve; 
        SystemMutedTriggers__c smt = SystemMutedTriggers__c.getInstance(currentUserId);
        smt.Opportunity__c = false;//SFDC-5428
        insert smt;

        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
    	Opportunity testOpportunity = TestUtility.createOpportunity(testAccount.Id, 'test Oppy', false);
        testOpportunity.ContractStartDate__c = 	date.newinstance(currentFY, 03,21 );
        testOpportunity.ContractEndDate__c = date.newinstance(currentFY+2, 10, 21);
        insert testOpportunity;
        
        Test.startTest(); 
        AccessToResponseManagementTeamController.updateAssociatedWithResMmtTeam (testOpportunity.Id, True);
        Test.stopTest();
        
        Opportunity  oppy = [Select Id,AssociatedwithResponseManagementTeam__c from Opportunity where Name= 'test Oppy']; 
        System.assertEquals(True, oppy.AssociatedwithResponseManagementTeam__c, 'Opportunity was not updated!!'); 
     }     
}