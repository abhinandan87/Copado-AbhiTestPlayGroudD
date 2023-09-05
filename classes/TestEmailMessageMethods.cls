//-------------------------------------
//@author: Sruti Srivastava
//@date: 25 June 2018
//@description: Test class to test EmailMessageMethods
//@companyname: VERTIBA
//-------------------------------------

@isTest
private class TestEmailMessageMethods {

    //-------------------------------------
    //@author: Sruti Srivastava
    //@date: 25 June 2018
    //@description: Test class to test EmailMessageMethods
    //@param: NA
    //@return: void
    ////-------------------------------------
    @isTest
    static void testReexecuteCaseAssignmentRulesAndCaseStatusUpdate() {
        Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        ProductGroup__c testProductgroup = TestUtility.createProductGroup('FieldDirect', true, false);
        Group queue = [Select id, name from group where type = 'Queue' and developerName = 'FMMSERV' limit 1];
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        Case cas1 = TestUtility.createCase(caseRecordTypeId, testAccount.Id, testContact.Id, 
                                           UserInfo.getUserId(), 'Case1', false);
        cas1.ProductGroup__c = testProductgroup.id;
        cas1.SkillLevel__c = '2 - Technical';
        cas1.Status = 'Waiting - Customer';
        cas1.PreviousQueue__c = queue.Name;
        Case cas2 = TestUtility.createCase(caseRecordTypeId, testAccount.Id, testContact.Id, 
                                           UserInfo.getUserId(), 'Case2', false);
        cas2.ProductGroup__c = testProductgroup.id;
        cas2.SkillLevel__c = '1 - General';
        cas2.Status='Closed - Canceled';
        cas2.ClosedReason__c = 'No Action Required';
        cas2.ResolutionDescription__c = 'test';
        cas2.PreviousQueue__c = queue.Name;
        
        Case cas3 = TestUtility.createCase(caseRecordTypeId, testAccount.Id, testContact.Id, 
                                           UserInfo.getUserId(), 'Case3', false);
        cas3.ProductGroup__c = testProductgroup.id;
        cas3.SkillLevel__c = '1 - General';
        cas3.Status='Closed - Canceled';
        cas3.ClosedReason__c = 'No Action Required';
        cas3.ResolutionDescription__c = 'test';
        
        List<case> caseList = new List<Case>();
        caseList.add(cas1);
        caseList.add(cas2);
        caseList.add(cas3);
        insert caseList;
        
        List<EmailMessage> listEmails = new List<EmailMessage>();
        listEmails.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'test@xyz.org', 
                                        Subject = 'Test email', HtmlBody = 'Test email body', ParentId = cas2.Id));
        listEmails.add(new EmailMessage(FromAddress = 'test@abc1.org', Incoming = True, ToAddress= 'test@xyz.org', 
                                        Subject = 'Test email', HtmlBody = 'Test email body', ParentId = cas1.Id));
        listEmails.add(new EmailMessage(FromAddress = 'test@abc2.org', Incoming = True, ToAddress= 'test@xyz.org', 
                                        Subject = 'Test email', HtmlBody = 'Test email body', ParentId = cas3.Id));
        Test.startTest();
        insert listEmails;
        Test.stopTest();
        
        //Verifying if status on cases have been updated 
        Map<Id,Case> updatedListCase = new Map<Id, case>([select id, ownerId, status, PreviousQueue__c from Case where status like 'In Progress' or status like 'Re-opened']);
        System.assertEquals(updatedListCase.size(), 3, 'list should not be null');
        Case testCase = updatedListCase.get(cas1.id); // Status should be inProgress
        System.assertEquals(testCase.Status, 'In Progress', 'case status updated');
        System.assertEquals(testCase.ownerId, UserInfo.getUserId(),'check user should same');//User shouldnt be changed
        
        //verifying if Case owner is updated as expected
        testCase = updatedListCase.get(cas3.id); // Status should be Reopened
        System.assertEquals(testCase.Status, 'Re-opened', 'case status updated');
        System.assertNotEquals(testCase.ownerId.getsobjecttype(), User.sobjecttype,'check the owner not to be user');//Should not be user
        //In case this queue is used in settings as default queue in Case settings then below condition will fail.
        //So, commenting it out.
        //System.assertNotEquals(testCase.ownerId.getsobjecttype(), queue.Id);
        
        testCase = updatedListCase.get(cas2.id); // Status should be Reopened
        System.assertEquals(testCase.Status, 'Re-opened', 'case status udpated');
        System.assertEquals(testCase.ownerId, queue.Id, 'check Previous Owner');//Owner should be previous owner queue
    }  
    
    
    //-------------------------------------
    //@author: Mohit Modi
    //@date: 21 Aug 2018
    //@description: Test class to test preventDeletionEmailMessage
    //@param: NA
    //@return: void
    ////-------------------------------------
    @isTest
    static void testpreventDeletionEmailMessage() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact c = TestUtility.createContact(a.Id,'testUSer.testuser123@ihsmarkit.com.user' ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        User testUser1 = TestUtility.createTestUser('IHSMarkit Customer Care', 'testUSer.testuser123@ihsmarkit.com.user',true);
        
        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        System.runAs(testUser1 ) {
            Case testCase1 = new Case();
            testCase1.subject = 'Test subject testSetCaseAdditionalFieldsObject';
            testCase1.AccountId = a.Id;
            testCase1.contactId = c.Id;
            testCase1.ProductGroup__c = pg.Id;
            testCase1.RecordTypeId = CCId;
            insert testCase1;
            
            List<EmailMessage> listEmails = new List<EmailMessage>();
            listEmails.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'test@xyz.org', 
            Subject = 'Test email', HtmlBody = 'Test email body', ParentId = testCase1.Id));
            insert listEmails;
            
            Test.startTest();
                try {
                delete listEmails;
                } Catch (Exception e) {
                    Boolean ErrorStringContains = e.getmessage().Contains(System.Label.EmailMessageErrorMessage);
                    System.assertEquals(ErrorStringContains , true,'validate exception');
                }
            Test.stopTest();
        }
    }
    @isTEst
    static void testCompleteFirstResponseAssignment() {
         Account acc = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', true);
        Contact con = TestUtility.createContact(acc.Id,'testUSer.testuser123@ihsmarkit.com.user' ,true,'Test', 'testSetCaseAdditionalFieldsObject');        
        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        List<SlaProcess> lstEntitlementProcess = [SELECT Id, Name FROM SlaProcess WHERE Name='IHSM Entitlement Process' and IsActive = true LIMIT 1];
        Entitlement entl = new entitlement(name='Test Entilement',accountid=acc.id,SlaProcessId =lstEntitlementProcess[0].Id ,StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
    	insert entl;
        insert new EntitlementAssignment__c(SetupOwnerId=UserInfo.getOrganizationId(), EntitlementId__c=entl.Id);
        Id CCId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Case testCase1 = new Case();
        testCase1.subject = 'Test subject testSetCaseAdditionalFieldsObject';
        testCase1.AccountId = acc.Id;
        testCase1.contactId = con.Id;
        testCase1.ProductGroup__c = pg.Id;
        testCase1.RecordTypeId = CCId;
        //testCase1.entitlementId = entl.Id;
        insert testCase1;
        Test.startTest();
        List<CaseMilestone> lstMilestones = [Select Id, isCompleted from CaseMilestone where CaseId=:testCase1.Id and MilestoneType.Name = 'First Response Time'];
        System.assert(lstMilestones!=null && !lstMilestones.isEmpty(),'CaseMilestone is created');
        System.assertEquals(false, lstMilestones[0].isCompleted, 'Check Milestone isCompleted false');
        List<EmailMessage> listEmails = new List<EmailMessage>();
        listEmails.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'test@xyz.org', 
                                        Subject = 'Test email', HtmlBody = 'Test email body', ParentId = testCase1.Id));
        insert listEmails;  
        lstMilestones = [Select Id, isCompleted from CaseMilestone where CaseId=:testCase1.Id and MilestoneType.Name = 'First Response Time'];
        System.assertEquals(true, lstMilestones[0].isCompleted, 'Check Milestone isCompleted true');
        Test.stopTest();
        
    }
}