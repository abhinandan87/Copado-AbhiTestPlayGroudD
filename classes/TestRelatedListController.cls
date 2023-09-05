//----------------------------------
// @author Priyanka Vyas
// @date 20th March 2020
// @description Test class for unit testing on RelatedListController
// ---------------------------------
@isTest
public class TestRelatedListController {
	@isTest
	static void TestfetchData() {
        
        Test.startTest();
        
        User testUser;
        System.runAs(new User(Id=userInfo.getUserId())) {
            testUser = TestUtility.createAdminUser('relatedlisttest=example@test.com', true);
        }
        System.runAs(testUser) {
            Account acct = TestUtility.createTestAccount('Test Sync Country', true);
            Opportunity oppy = TestUtility.createOpportunity(acct.id, 'Test Oppy', true);
            String infoJSON='{"pageNumber":1,"recordToDisplay":3,"objectType":"Opportunity","parentRecordId":"';
            infoJSON+=acct.id+'","parentField":"AccountId","queryColumns":"Name, SubBusinessLine__c, ProductGroup__c,StageName, CloseDate, Amount,  ProductFamily__c, Owner.Alias,OwnerId, Owner.Name, StageNumber__c","filter":"IsClosed=false","orderBy":"CloseDate DESC","recordId":null}';
            System.debug('infoJSON--->'+infoJSON);
            RelatedListController.fetchData(infoJSON);
            String infoJSON2='{"pageNumber":1,"recordToDisplay":3,"objectType":"Opportunity","parentRecordId":"';
            infoJSON2+=acct.id+'","parentField":"AccountId","queryColumns":"Name, SubBusinessLine__c, ProductGroup__c,StageName, CloseDate, Amount,  ProductFamily__c, Owner.Alias,OwnerId, Owner.Name, StageNumber__c","filter":"IsClosed=false","orderBy":"CloseDate DESC","recordId":"'+oppy.id+'"}';
            RelatedListController.deleteRecord(infoJSON2);
        	
            System.assertEquals(oppy.AccountId, acct.id,'Account Validation.');
        }
    	Test.stopTest();
    }    
    @isTest(SeeAllData='true')
    public static void testfetchReportId() {
    	Test.startTest();
            List <Report> reportList = [SELECT Id,DeveloperName FROM Report limit 1];
            String reportId = RelatedListController.fetchReportId(reportList[0].DeveloperName);

            System.assert(reportList.size()>0,'List have report Id.');
        Test.stopTest();
    }
}