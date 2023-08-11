//--------------------------------------------------------------------
// @author: Anjali
// @date: 06 July 2021
// @description: This is test class for WorkRequestFormController
//--------------------------------------------------------------------
@isTest
public class TestOperationsQueue {
    
    @testSetup static void testData() {
        Account a = TestUtility.createTestAccount('testAccount', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;        
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
        Id PSRecordTypeId = Schema.SObjectType.WorkRequestForm__c.getRecordTypeInfosByName().get('Planning Solutions').getRecordTypeId();
        WorkRequestForm__c wrf = new WorkRequestForm__c();
        wrf.RecordTypeId = PSRecordTypeId;
        wrf.JobType__c = 'Ad Hoc';
        wrf.RoyaltyVendor__c='No Royalty Data';
        wrf.ReturnToSales__c=true;
        wrf.PrimarySalesContact__c=UserInfo.getUserId();
        wrf.RequestedDueDate__c = System.today() + 7;
        wrf.OutputType__c='Comma Delimited (CSV)';
        wrf.OutputMedium__c='CD ROM/DVD';
        wrf.PlanningSolutions__c = true;
        wrf.PlanningSolutionsProdRegions__c  ='Europe';
        wrf.RequestStatus__c='Submitted';
        wrf.OpportunityName__c= opp.Id;
        wrf.AccountName__c= a.Id;
        wrf.PlanningSolutionsEndDate__c=system.today()+10; 
        wrf.PlanningSolutionsStartDate__c = system.today(); 
        insert wrf;
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        User userObj =[Select Id,Name FROM User WHERE Id=:Userinfo.getUserId()];
        System.runAs(userObj) {
            ChangeLog__c changeLog = new ChangeLog__c();
            changeLog.ChangeDescription__c = 'Test';
            changeLog.WorkRequestForm__c = wrf.id;
            changeLog.RequestStatus__c='Draft';
            clList.add(changeLog);
            ChangeLog__c changeLog1 = new ChangeLog__c();
            changeLog1.ChangeDescription__c = 'Test';
            changeLog1.WorkRequestForm__c = wrf.id;
            changeLog1.RequestStatus__c='Submitted';
            clList.add(changeLog1);
            ChangeLog__c changeLog2 = new ChangeLog__c();
            changeLog2.ChangeDescription__c = 'Test';
            changeLog2.WorkRequestForm__c = wrf.id;
            changeLog2.RequestStatus__c='Submitted';
            changeLog2.Programmer__c = u.Id;
            clList.add(changeLog2);
            insert clList;
            OrderRequest__c orderReq = new OrderRequest__c();
            orderReq.WorkRequestForm__c = wrf.Id;
            orderReq.OrderRequestStatus__c = 'Submitted';
            insert orderReq;
        }
    }
	@isTest
    public static void testQueueValues(){
        List<Queues__mdt> lstOfQueue;
        Test.startTest();
        lstOfQueue = OperationsQueue.queueValues();
        Test.stopTest();
        system.assertNOTEquals(lstOfQueue.size(), 0, 'queueValues did not return correct no of records' );
    }
	@isTest
    public static void testGetWRFRecords(){
        list<WorkRequestForm__c> lstOfWRF;
        Test.startTest();
        lstOfWRF = OperationsQueue.getWRFRecords('All');
        Test.stopTest();
        system.assertEquals(lstOfWRF.size(), 1, 'getWRFRecords did not return correct no of records' );
    }
    @isTest
    public static void testGetWRFRecordswithsearchId(){
        list<WorkRequestForm__c> lstOfWRF;
        Test.startTest();
        lstOfWRF = OperationsQueue.getWRFRecords('Planning Solutions');
        Test.stopTest();
        system.assertEquals(lstOfWRF.size(), 1, 'getWRFRecords did not return correct no of records' );
    }
	@isTest
    public static void testGetchangeLogRecords(){
        list<changelog__c> clResults;
        Test.startTest();
        clResults = OperationsQueue.getchangeLogRecords('All');
        Test.stopTest();
        system.assertEquals(clResults.size(), 2, 'getchangeLogRecords did not return correct no of records' );
    }
    @isTest
    public static void testGetchangeLogRecordswithsearchId(){
        list<changelog__c> clResults;
        Test.startTest();
        clResults = OperationsQueue.getchangeLogRecords('Planning Solutions');
        clResults = OperationsQueue.getchangeLogRecords('Planning Solutions');
        Test.stopTest();
        system.assertEquals(clResults.size(), 2, 'getchangeLogRecords did not return correct no of records' );
    }
	@isTest
     public static void testGetOrderReqRecords(){
        list<OrderRequest__c> orResults;
        Test.startTest();
        orResults = OperationsQueue.getOrderReqRecords('All');
        Test.stopTest();
        system.assertEquals(orResults.size(), 1, 'getOrderReqRecords did not return correct no of records' );
    }  
	@isTest
    public static void testGetOrderReqRecordswithsearchId(){
        list<OrderRequest__c> orResults;
        Test.startTest();
        orResults = OperationsQueue.getOrderReqRecords('PAS');
        Test.stopTest();
        system.assertEquals(orResults.size(), 0, 'getOrderReqRecords did not return correct no of records' );
    }  

}