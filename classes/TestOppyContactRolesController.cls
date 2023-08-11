//-----------------------------
// @author: Sharique Iqbal
// @date: 7th Dec 2021
// @description: Test class for LWC Controller-OppyContactRolesController 
// @company: IHS Markit
//-----------------------------
@isTest
public class TestOppyContactRolesController{
	@isTest
    public static void TestMethod1() {
        
        Account testAccount  = testUtility.createTestAccount('test Account', True );
        Contact con = testUtility.createContact(testAccount.Id, 'mark@test.com', true, 'Mark', 'Wood');
        Opportunity testOpportunity = testUtility.createOpportunity(testAccount.Id, 'test Opportunity', true);
        OpportunityContactRole ocr = new OpportunityContactRole();
         ocr.ContactId = con.Id;
         ocr.IsPrimary = True;
         ocr.Role = 'Business User';
         ocr.OpportunityID = testOpportunity.Id;
        insert ocr;
        
        Feedback__c fdbk =  new Feedback__c();
        fdbk.Opportunity__c = testOpportunity.Id;
        insert fdbk;
        List <OpportunityContactRole> conRolesList = OppyContactRolesController.getOppyContactRoles(fdbk.Id);
        System.assertEquals(conRolesList.size()>0,True, 'Unable to fetch Opportunity ContactRoles');
    }
}