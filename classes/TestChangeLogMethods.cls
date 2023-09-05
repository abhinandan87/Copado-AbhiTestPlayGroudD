//--------------------------------------------------------------------
// @author: Anjali
// @date: 01 July 2021
// @description: This is test class for WorkRequestFormController
//--------------------------------------------------------------------
@isTest
private class TestChangeLogMethods {
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
        ChangeLog__c changeLog = new ChangeLog__c();
        changeLog.ChangeDescription__c = 'Test';
        changeLog.WorkRequestForm__c = wrf.id;
        changeLog.RequestStatus__c='Draft';
        insert changeLog;
        ChangeLog__c changeLog1 = new ChangeLog__c();
        changeLog1.ChangeDescription__c = 'Test';
        changeLog1.WorkRequestForm__c = wrf.id;
        changeLog1.RequestStatus__c='Submitted';
        insert changeLog1;
        User userObj =[Select Id,Name FROM User WHERE Id=:Userinfo.getUserId()];
        String testEmail = 'dgtest@test1ihsmarkit.com';
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        TestUtility.addWRApproverPermSet(myTestUser.Id); 
        
    }
    @isTest
    private static void testUpdateChangeRecords() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            WorkRequestForm__c wrf = [Select Id,ownerId FROM WorkRequestForm__c LIMIT 1];
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
            changeLog2.Programmer__c = currentUser.Id;
            clList.add(changeLog2);
            insert clList;
            changeLog2.RequestStatus__c='Approval Pending';
            update changeLog2;
            List<ChangeLog__c> changeLogList = [Select Id FROM ChangeLog__c WHERE WorkRequestForm__c =: wrf.Id];
             System.assertEquals(true, changeLogList.size()>0, 'changelogs are created');
        }
    }
    
    @isTest
    private static void testUpdateChangeDocument() {
        User userObj =[Select Id FROM User WHERE Id=:Userinfo.getUserId()];
        ChangeLog__c changeLog;
        Test.StartTest();
        changeLog = [Select Id,ChangeDocumentedBy__c FROM ChangeLog__c LIMIT 1];
        Test.StopTest();
        System.assertEquals(changeLog.ChangeDocumentedBy__c,userObj.Id , 'Changed Documented By is not updated to change log created user');
    }
    
    @isTest
    private static void testUpdateonSubmit() { 
        WorkRequestForm__c workReq = [Select Id,ownerId FROM WorkRequestForm__c LIMIT 1];
        ChangeLog__c changeLog = [Select Id,ChangeDocumentedBy__c,SubmittedDateTime__c,OwnerId FROM ChangeLog__c WHERE RequestStatus__c='Draft' LIMIT 1];
        Test.StartTest();
        changeLog.RequestStatus__c = 'Submitted';
        update changeLog;
        Test.StopTest();
        ChangeLog__c cLObj = [Select Id,OwnerId,SubmittedDateTime__c FROM ChangeLog__c where Id=:changeLog.Id];
        System.assertEquals(workReq.OwnerId,cLObj.OwnerId, 'Owner is not updated to the queue');
        
    }
    
    @isTest
    private static void testUpdateonApproval() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            ChangeLog__c changeLog = [Select Id,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            Test.StartTest();
            changeLog.RequestStatus__c = 'Approved without Job';
            update changeLog;
            Test.StopTest();
            ChangeLog__c cLObj = [Select Id,OwnerId FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,Userinfo.getUserId(), 'Owner is not updated to the current user');
        }
    }
    
    @isTest
    private static void testUpdateonApprovalwithProgrammer() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            User userObj = [Select Id from User where Email='standarduser@testorg.com' LIMIT 1];
            ChangeLog__c changeLog = [Select Id,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            Test.StartTest();
            changeLog.Programmer__c=userObj.Id;
            changeLog.RequestStatus__c = 'Approved without Job';
            update changeLog;
            Test.StopTest();
            ChangeLog__c cLObj = [Select Id,OwnerId FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,userObj.Id, 'Owner is not updated to the programmer');
        }
    }
    
    @isTest
    private static void testUpdateonApprovalAndCreateJobs() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            ChangeLog__c changeLog = [Select Id,PLCJob__c,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            User userObj = [Select Id from User where Email='standarduser@testorg.com' LIMIT 1];
            Test.StartTest();
            changeLog.NegotiatedDate__c =System.today()+10;
            changeLog.Team1__c='Planning Solutions';
            changeLog.RequestStatus__c = 'Approved';
            changeLog.Programmer__c=userObj.Id;
            update changeLog;
            Test.StopTest();
            PLCJob__c plcJob = [Select Id FROM PLCJob__c WHERE changeLog__c =: changeLog.Id];
            ChangeLog__c cLObj = [Select Id,OwnerId,PLCJob__c FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,userObj.Id, 'Owner is not updated to the programmer');
            System.assertEquals(cLObj.PLCJob__c,plcJob.Id, 'PLC job is not created');
        }
    }
    
    @isTest
    private static void testUpdateonApprovalPending() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            ChangeLog__c changeLog = [Select Id,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            Test.StartTest();
            changeLog.RequestStatus__c = 'Approval Pending';
            update changeLog;
            Test.StopTest();
            ChangeLog__c cLObj = [Select Id,OwnerId FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,Userinfo.getUserId(), 'Owner is not updated to the current user');
        }
    }
    
    @isTest
    private static void testUpdateonApprovalPendingwithProgrammer() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            User userObj = [Select Id from User where Email='standarduser@testorg.com' LIMIT 1];
            ChangeLog__c changeLog = [Select Id,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            Test.StartTest();
            changeLog.Programmer__c=userObj.Id;
            changeLog.RequestStatus__c = 'Approval Pending';
            update changeLog;
            Test.StopTest();
            ChangeLog__c cLObj = [Select Id,OwnerId FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,userObj.Id, 'Owner is not updated to the programmer');
        }
    }
    
    @isTest
    private static void testUpdateonRejected() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            ChangeLog__c changeLog = [Select Id,OwnerId,ChangeDocumentedBy__c FROM ChangeLog__c where RequestStatus__c='Submitted'];
            changeLog.RequestStatus__c = 'Approval Pending';
            update changeLog;
            Test.StartTest();
            changeLog.RequestStatus__c = 'Rejected';
            changeLog.ProductionComments__c = 'Rejecting';
            update changeLog;
            Test.StopTest();
            ChangeLog__c cLObj = [Select Id,OwnerId,ChangeDocumentedBy__c FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,cLObj.ChangeDocumentedBy__c , 'Changed Log Ownwr is not updated to change log documented by user');
        }
    }
    
    @isTest
    private static void testupdateNoofChangeLogs() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            ChangeLog__c changeLog = [Select Id,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            changeLog.RequestStatus__c = 'Approval Pending';
            update changeLog;
            Test.StartTest();
            delete changeLog;
            Test.StopTest();
            List<ChangeLog__c> changeLogLst =[Select Id FROM ChangeLog__c];
            WorkRequestForm__c workReq = [Select Id,ChangeLogs__c from WorkRequestForm__c];
            System.assertEquals(workReq.ChangeLogs__c,changeLogLst.size(), 'changelogs value is not updated in wrf');
        }
    }
    
    @isTest
    private static void testUpdateonApprovalwithJobandProgrammer() {
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        List<ChangeLog__c> clList = new List<ChangeLog__c>();
        System.runAs(currentUser) {
            WorkRequestForm__c workReq = [Select Id,ChangeLogs__c from WorkRequestForm__c LIMIT 1];
            PLCJob__c plc = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Week Days', CreatePeerReviewTask__c=true,WorkRequestForm__c=workReq.Id);
            insert plc;
            workReq.ChangeLogsPLC__c =1;
            update workReq;
            ChangeLog__c changeLog = [Select Id,OwnerId FROM ChangeLog__c where RequestStatus__c='Submitted'];
            Test.StartTest();
            changeLog.NegotiatedDate__c =System.today()+10;
            changeLog.Team1__c='Planning Solutions';
            changeLog.RequestStatus__c = 'Approved';
            update changeLog;
            Test.StopTest();
            WorkRequestForm__c wrObj = [Select ChangeLogsPLC__c FROM WorkRequestForm__c LIMIT 1];
            ChangeLog__c cLObj = [Select Id,OwnerId FROM ChangeLog__c where Id=:changeLog.Id];
            System.assertEquals(cLObj.OwnerId,Userinfo.getUserId(), 'Owner is not updated to the created user');
            System.assertEquals(wrObj.ChangeLogsPLC__c,2, 'new PLC is not inserted');
        }
    }
}