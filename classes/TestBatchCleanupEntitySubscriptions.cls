/**
* @author Paras Dhingra
* @date 17 Sep 2020
* @description SFDC-3387 test Class for batch and scheduler for EntitySubscription cleanup
* @companyname IHS Markit
*/
@isTest(SeeAllData=false)
public class TestBatchCleanupEntitySubscriptions {
    @isTest
    static void testExecute() {
        //create test data
        Account testAccount  = TestUtility.createTestAccount('Test PArent Account', true);
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        Profile salesProfile = [SELECT Id ,name FROM Profile WHERE Name like '%General%' limit 1];
        User testSalesUser = new User(Alias = 'standt', Email='ctcompletedTest@testorg.com', 
        EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = salesProfile.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='ctcompletedTest@ihsihs.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber='test'+String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c='test'+String.valueOf(Math.round(Math.random()*10000)));
        insert testSalesUser;
        //Forecasting placeholder oppy
        Id placeholderOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Forecasting Placeholder').getRecordTypeId();
        //create test oppies 5 with closedate less than threshold and 5 under threshold
        List<Opportunity> lstOpportunityToInsert = new List<Opportunity>();
        // close date in today and future
        for(Integer i=0; i<5;i++) {
            Opportunity oppy = TestUtility.createOpportunity(testAccount.Id, 'Test Oppy'+i, false);
            oppy.CloseDate = Date.today()+i;
            oppy.RecordTypeId = placeholderOppRecTypeId;
            oppy.StageName = '1-Open';
            oppy.OwnerId = testSalesUser.Id;
            lstOpportunityToInsert.add(oppy);
        }
        // close date in today and before threshold
        Integer dateThreshold = Integer.valueOf(System.Label.NumberOfDaysThreshold);
        for(Integer i=0; i<5;i++) {
            Opportunity oppy = TestUtility.createOpportunity(testAccount.Id,'Test Oppy old'+i , false);
            oppy.CloseDate = (Date.today()-dateThreshold-i-1);
            oppy.RecordTypeId = placeholderOppRecTypeId;
            oppy.StageName = '1-Open';
            oppy.OwnerId = testSalesUser.Id;
            lstOpportunityToInsert.add(oppy);
        }
        Test.startTest();        
        insert lstOpportunityToInsert;
        //assert Entity Subscriptions
        List<EntitySubscription> assertSubscriptions = [Select Id from EntitySubscription where SubscriberId=:testSalesUser.Id];
        System.assertEquals(10,assertSubscriptions.size(),'Checking size of Subs created');
        //close the oppies and start the batch
        for(Opportunity oppy: lstOpportunityToInsert) {
            oppy.StageName = '6W-Forecasting Placeholder';
            oppy.ByPassValidation__c = true;
        }
        update lstOpportunityToInsert;
        BatchCleanupEntitySubscriptionsScheduler ba = new BatchCleanupEntitySubscriptionsScheduler(); //Schedule apex class name
        ba.query = 'Select Id from User where Id=\''+testSalesUser.Id+'\'';
        String sch = '0 0 8 13 2 ?'; //schedule interval time
        String jobId = System.schedule('Run Job for BatchCleanupEntitySubscriptions', sch, ba); //system method to schedule apex class
        System.assert(jobId!=null);
        BatchCleanupEntitySubscriptions batchObj = new BatchCleanupEntitySubscriptions();
        batchObj.query = 'Select Id from User where Id=\''+testSalesUser.Id+'\'';
        batchObj.batchHasErrors = true;
        Id batchId = Database.executeBatch(batchObj);
        Test.stopTest();
        List<EntitySubscription> assertSubscriptions2 = [Select Id from EntitySubscription where SubscriberId=:testSalesUser.Id];
        System.assertEquals(5,assertSubscriptions2.size(),'Checking size of Subs after batch');
        
        
    }
}