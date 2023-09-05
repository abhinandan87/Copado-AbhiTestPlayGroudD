//-----------------------------
// @author: Ankush Vedi	
// @date: 30 March 2022
// @description: Test class for OpportunityTeamMemberMethods trigger methods 
// @company: IHS Markit
//-----------------------------

@isTest
public class TestOpportunityTeamMemberMethods {
        @isTest
    	private static void TestUpdateOTMNameOnOppty() {
        	Id nbOpptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
  	      	Test.startTest();
            Account acc = TestUtility.createTestAccount('BARCLAYS PLC',true);
        	Contact con = TestUtility.createContact(acc.Id,'oppty.primary@ihsmarkit.com',true,'TestOppty','TestPrimary');
            //Create user
            User testUser1 = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUser.test987@abc.com.user',true);
        	Opportunity opp = TestUtility.createOpportunity(acc.id, 'BARCLAYS Opp',null,false);
            opp.ActivityCreated__c = true;
            opp.Description = 'test';
            opp.LeadSource = 'Marketing Generated';            
            insert opp;
            
            OpportunityContactRole ocr = TestUtility.createOpportunityContactRole(con.id, Opp.id,true,'Economic Buyer', true);
            //Add Opportunity Member 
            OpportunityTeamMember otm = TestUtility.createOpportunityTeamMember(opp.id,testUser1.id,'Edit', true);
            otm.TeamMemberRole ='Account Manager';
            insert otm;    
            Delete otm; 
            list<Opportunityteammember> otm2 = [Select Id from Opportunityteammember where opportunityId=:opp.Id ];
            System.assertEquals(1,otm2.size(),'Check Opportunity teammember count');
 	       	Test.stopTest();
        }
    	@isTest
    	private static void TestUpdateOTMNameOnOpptyemptyvalue() {            
        	Id nbOpptyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();   
            Test.startTest();
            Account acc = TestUtility.createTestAccount('BARCLAYS PLC',true);
        	Contact con = TestUtility.createContact(acc.Id,'oppty.primary@ihsmarkit.com',true,'TestOppty','TestPrimary');
            //Create user
            User testUser1 = TestUtility.createTestUser('IHSMarkit Sales: General', 'testUser.test987@abc.com.user',true);           
        	Opportunity opp = TestUtility.createOpportunity(acc.id, 'BARCLAYS Opp',null,false);
            opp.ActivityCreated__c = true;
            opp.Description = null;
            opp.LeadSource = null;            
            insert opp;            
            
            OpportunityContactRole ocr = TestUtility.createOpportunityContactRole(con.id, Opp.id,true,'Economic Buyer', true);
            //Add Opportunity Member 
            OpportunityTeamMember otm = TestUtility.createOpportunityTeamMember(opp.id,testUser1.id,'Edit', true);               
            otm.TeamMemberRole ='Account Manager';
            insert otm;  
            OpportunityTeamMember otm1 = TestUtility.createOpportunityTeamMember(opp.id,testUser1.id,'Edit', true);  
            otm1.TeamMemberRole ='Account Manager';
            insert otm1;  
            list<Opportunityteammember> otm2 = [Select Id from Opportunityteammember where opportunityId=:opp.Id ];
            System.assertEquals(2,otm2.size(),'Check Opportunity teammember count');
            Delete otm1;    
            Test.stopTest();                    	
        }
}