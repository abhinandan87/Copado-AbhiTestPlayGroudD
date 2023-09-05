//--------------------------------------------------------------------
// @author: Anjali
// @date: 05 July 2021
// @description: This is test class for WorkRequestFormController
//--------------------------------------------------------------------
@isTest
private class TestOrderRequestMethods {
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
        Id PASRecordTypeId = Schema.SObjectType.WorkRequestForm__c.getRecordTypeInfosByName().get('PAS').getRecordTypeId();
        WorkRequestForm__c wrf = new WorkRequestForm__c();
        wrf.RecordTypeId = PASRecordTypeId;
        wrf.JobType__c = 'Ad Hoc';
        wrf.RoyaltyVendor__c='No Royalty Data';
        wrf.ReturnToSales__c=true;
        wrf.PrimarySalesContact__c=UserInfo.getUserId();
        wrf.RequestedDueDate__c = System.today() + 7;
        wrf.OutputType__c='Comma Delimited (CSV)';
        wrf.OutputMedium__c='CD ROM/DVD';
        wrf.TLAS__c  = true;
        wrf.JobDescription__c = 'test';
        wrf.RequestStatus__c='Submitted';
        wrf.OpportunityName__c= opp.Id;
        wrf.AccountName__c= a.Id;
        insert wrf;
        List<OrderRequest__c> orderReqLst = new List<OrderRequest__c>();
        OrderRequest__c orderReq = new OrderRequest__c();
        orderReq.WorkRequestForm__c = wrf.Id;
        orderReq.OrderRequestStatus__c = 'Draft';
        orderReqLst.add(orderReq);
        OrderRequest__c orderReq1 = new OrderRequest__c();
        orderReq1.WorkRequestForm__c = wrf.Id;
        orderReq1.OrderRequestStatus__c = 'Submitted';
        orderReqLst.add(orderReq1);
        OrderRequest__c orderReq2 = new OrderRequest__c();
        orderReq2.WorkRequestForm__c = wrf.Id;
        orderReq2.OrderRequestStatus__c = 'Submitted';
        orderReqLst.add(orderReq2);
        insert orderReqLst;
        String testEmail = 'dgtest@testtest1ihsmarkit.com';
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        TestUtility.addWRApproverPermSet(myTestUser.Id); 
    }
    @isTest
    private static void testUpdateRequestor() {
        User userObj =[Select Id FROM User WHERE Id=:Userinfo.getUserId()];
        OrderRequest__c orderReq;
            Test.StartTest();
            orderReq = [Select Id,Requestor__c FROM OrderRequest__c LIMIT 1];
            Test.StopTest();
        System.assertEquals(orderReq.Requestor__c,userObj.Id , 'Requestor is not updated to Order Request created user');           
    }
    @isTest
    private static void testUpdateonSubmit() { 
        WorkRequestForm__c workReq = [Select Id,ownerId FROM WorkRequestForm__c LIMIT 1];
        OrderRequest__c orderReq = [Select Id,SubmittedDateTime__c,OwnerId FROM OrderRequest__c WHERE OrderRequestStatus__c='Draft' LIMIT 1];
        Test.StartTest();
        orderReq.OrderRequestStatus__c = 'Submitted';
        update orderReq;
        Test.StopTest();
        OrderRequest__c oRObj = [Select Id,OwnerId,SubmittedDateTime__c FROM OrderRequest__c where Id=:orderReq.Id];
        System.assertEquals(workReq.OwnerId,oRObj.OwnerId, 'Owner is not updated to the queue');
        
    }
    @isTest
    private static void testUpdateonApprovalwithoutJob() { 
        OrderRequest__c orderReq = [Select Id,OwnerId FROM OrderRequest__c WHERE OrderRequestStatus__c='Submitted' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser) {
            Test.StartTest();
            orderReq.OrderRequestStatus__c = 'Approved without Job';
            update orderReq;
            Test.StopTest();
            OrderRequest__c oRObj = [Select Id,OwnerId FROM OrderRequest__c where Id=:orderReq.Id];
            System.assertEquals(oRObj.OwnerId,Userinfo.getUserId(), 'Owner is not updated to the current user');
        }
    }
    @isTest
    private static void testUpdateonApprovalwithoutJobwithprogrammer() { 
        OrderRequest__c orderReq = [Select Id,OwnerId FROM OrderRequest__c WHERE OrderRequestStatus__c='Submitted' LIMIT 1];
        User userObj = [Select Id from User where Email='standarduser@testorg.com' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser) {
            Test.StartTest();
            orderReq.OrderRequestStatus__c = 'Approved without Job';
            orderReq.Programmer__c = userObj.Id;
            update orderReq;
            Test.StopTest();
            OrderRequest__c oRObj = [Select Id,OwnerId FROM OrderRequest__c where Id=:orderReq.Id];
            System.assertEquals(oRObj.OwnerId,userObj.Id, 'Owner is not updated to the current user');
        }
    }
    @isTest
    private static void testUpdateonRejected() { 
        OrderRequest__c orderReq = [Select Id,OwnerId FROM OrderRequest__c where OrderRequestStatus__c='Submitted' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser) {
            orderReq.OrderRequestStatus__c='Approval Pending';
            update orderReq;
            Test.StartTest();
            orderReq.OrderRequestStatus__c = 'Rejected';
            update orderReq;
            Test.StopTest();
            OrderRequest__c oRObj = [Select Id,OwnerId,CreatedById FROM OrderRequest__c where Id=:orderReq.Id];
            system.assertEquals(oRObj.ownerID, oRobj.CreatedById, 'Owner and created by are not same users');
        }
    }
    @isTest
    private static void testUpdateonApproval() { 
        OrderRequest__c orderReq = [Select Id,PLCJob__c,OwnerId FROM OrderRequest__c where OrderRequestStatus__c='Submitted' LIMIT 1];
        User userObj = [Select Id from User where Email='standarduser@testorg.com' LIMIT 1];
        Test.StartTest();
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser) {
            orderReq.NegotiatedDate__c =System.today()+10;
            orderReq.Team1__c='MCM-Analytics';
            orderReq.OrderRequestStatus__c = 'Approved';
            orderReq.Programmer__c=userObj.Id;
            update orderReq;
            Test.StopTest();
            PLCJob__c plcJob = [Select Id FROM PLCJob__c WHERE OrderRequest__c =: orderReq.Id];
            OrderRequest__c oRObj = [Select Id,OwnerId,PLCJob__c FROM OrderRequest__c where Id=:orderReq.Id];
            System.assertEquals(oRObj.OwnerId,userObj.Id, 'Owner is not updated to the programmer');
            System.assertEquals(oRObj.PLCJob__c,plcJob.Id, 'PLC job is not created');
        }
    }
}