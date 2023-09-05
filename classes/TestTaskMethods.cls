// @author: Uttam Arya
// @date: 31 Aug 2017
// @param: NA
// @description: Test class for Task trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestTaskMethods {
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 31 Aug 2017
    // @param: NA
    // @description: SFDC1-2243 Test method for Task trigger methods populateTaskAddedInOpportunityWhenTaskIsInserted on insert
    // @return: NA
    // 
    // @Updated by: Harshit Singhal
    // @Updated date: 15 Jun 2018
    // @Updated description: Updated to cover code changes made for SFDC1-8540 in populateTaskAddedInOpportunityWhenTaskIsInserted() method
    //-----------------------------
    @isTest
    private static void testpopulateTaskAddedInOpportunityWhenTaskIsInserted() {
        
        Account acct = TestUtility.createTestAccount('Test populateAdditionalFiledsLookupInAccount', true);
        Opportunity oppt = TestUtility.createOpportunity(acct.Id, 'Test Oppy Task', true);
        
        Task t = new Task(Account__c = acct.Id, Subject = 'Test Task', WhatId = oppt.Id);
        
        insert t;
        
        //Assert if MIS is inserted
        Opportunity opp = [select MISActivityAdded__c,ActivityCreated__c from Opportunity where Id =: oppt.Id];
        
        System.assertNotEquals(opp.MISActivityAdded__c,null,'MISActivityAdded__c should not be null');
        System.assertEquals(true,opp.ActivityCreated__c,'ActivityCreated__c should be true');
        
        acct.DataGovernanceStatus__c = 'Unapproved';
        update acct;
        
        t = new Task(Account__c = acct.Id, Subject = 'Test Task2', WhatId = oppt.Id);
        try { 
            insert t;
            Throw new AssertException ('Expected to fail, account is unapproved');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Opportunities can only be created for or associated with accounts that have been approved by Customer Master Data Team.');
            System.AssertEquals(expectedExceptionThrown, true,'Expected Exception is thrown');
        }
        
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 17 Jan 2018
    // @param: NA
    // @description: SFDC1-5027 Test method for Task trigger methods updateOpportunityActivityCheckOnTaskDeletion on Delete
    // @return: NA
    // @modified by: Priyanka Vyas
    // @date: 26 Aug 2020
    // @description: Commented and rewrote the method below against SFDC-3133. 
    //-----------------------------
    /*private static testMethod void testupdateOpportunityActivityCheckOnTaskDeletion() {
        
        Account acct = TestUtility.createTestAccount('Test populateAdditionalFiledsLookupInAccount', true);
        
        Opportunity oppt1 = TestUtility.createOpportunity(acct.Id, 'Test Oppy Task', false);
        oppt1.ActivityCreated__c = true;
        Opportunity oppt2 = TestUtility.createOpportunity(acct.Id, 'Test Oppy Task', false);
        oppt2.ActivityCreated__c = true;
        insert new list<opportunity> {oppt1,oppt2};
        
        test.startTest();
        
        Task t1 = new Task(Account__c = acct.Id, Subject = 'Test Task', WhatId = oppt1.Id);
        Task t2 = new Task(Account__c = acct.Id, Subject = 'Test Task', WhatId = oppt1.Id);
        Task t3 = new Task(Account__c = acct.Id, Subject = 'Test Task', WhatId = oppt2.Id);
        insert new List<Task>{t1,t2,t3};
        
        set<id> setOppID = new set<id>{oppt1.Id,oppt2.Id};
        
        List<Opportunity> opp = [select ActivityCreated__c from Opportunity where Id in : setOppID ];
        System.assertEquals(opp[0].ActivityCreated__c ,true);
        System.assertEquals(opp[1].ActivityCreated__c ,true);
        
        delete new list<task>{t1,t3};
        
        // Assert that the opportunity's ActivityCreated__c should be false if the last task is deleted, else it should be true.
        opp = [select ActivityCreated__c from Opportunity where Id in : setOppID ];
        System.assertEquals(opp[0].ActivityCreated__c ,true);
        System.assertEquals(opp[1].ActivityCreated__c ,false);
        
        test.stopTest();
    }*/
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 26 Aug 2020
    // @description: SFDC-3133 Test method for changeActivityCreatedOppyOnUpdate and updateOpportunityActivityCheckOnTaskDeletion methods to update ActivityCreated__c on Opportunity .
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testChangeActivityCreatedCheckboxOnOpportunity() {
        Set<ID> oppIDSet=new Set<ID>();
        //test.startTest();
        Account acc = TestUtility.createTestAccount('Test', true);
        Opportunity testOpp1 = TestUtility.createOpportunity(acc.id, 'Test Opp1', false);
        Opportunity testOpp2 = TestUtility.createOpportunity(acc.id, 'Test Opp2', false);
        Opportunity testOpp3 = TestUtility.createOpportunity(acc.id, 'Test Opp3', false);
        Opportunity testOpp4 = TestUtility.createOpportunity(acc.id, 'Test Opp4', false);
        Opportunity testOpp5 = TestUtility.createOpportunity(acc.id, 'Test Opp5', false);
        
        List<Opportunity> oppList = new List<Opportunity> {testOpp1, testOpp2, testOpp3, testOpp4,testOpp5};
            insert oppList;
			for(Opportunity opp:oppList) {
                oppIDSet.add(opp.id);
            }
            Event testEvt1 = new Event(Subject='Test1', WhatId=testOpp1.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
            insert testEvt1;
        	Event insertedEvent = [Select id, MeetingNote__c from event where id=:testEvt1.id];
        	Task t = new Task(WhatId=testOpp2.id, subject='test', Priority='Normal', Status='Open');
            insert t;
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            Contact markitContact = TestUtility.createContact(acc.Id,uniqueName + '@test' + orgId + '.org',true, 'FirstName', 'LastName');
            RelatedOpportunity__c testRO1 = new RelatedOpportunity__c(MeetingNote__c=insertedEvent.MeetingNote__c,Opportunity__c=testOpp3.Id);
            insert testRO1;
        	Task tsk1 = new Task(Type='Call', Subject='Meeting1', WhatId=testOpp1.id);
            Task tsk2 = new Task(Type='Call', Subject='Meeting2', WhatId=testOpp2.id);
            Task tsk3 = new Task(Type='Call', Subject='Meeting3', WhatId=testOpp3.id);
            Task tsk4 = new Task(Type='Call', Subject='Meeting4', WhatId=testOpp4.id);
            List<task> tskList=new List<task>{tsk1,tsk2,tsk3,tsk4};
                insert tskList;
            tsk4.WhatId=testOpp5.id;
            update tsk4;
        	Product2 prod = TestUtility.createProduct('Test Product', true);
        	Id stdPricebookId = Test.getStandardPricebookId();
        	PriceBook2 standardPB = new PriceBook2(Id = stdPricebookId, Name = 'Standard Price Book', isActive = true);
        	update standardPB;
        	test.startTest();
        	PricebookEntry pbe1 = TestUtility.createPriceBookEntry(stdPricebookId, prod.Id, true);

        	OpportunityLineItem testOLI = TestUtility.createOpportunityLineItem(testOpp5.Id, pbe1, true);
        	OpportunityContactRole ocr = TestUtility.createOpportunityContactRole(markitContact.id, testOpp5.id, true, 'Business User', true);
        	testOpp5.StageName = '5-Contracting';
        	testOpp5.ContractStartDate__c = Date.Today();
        	testOpp5.ContractEndDate__c = Date.Today() + 1;
        	update testOpp5;
        	try{
            List<task> taskDeletionList=new List<task>{tsk1,tsk2,tsk3,tsk4};
                delete taskDeletionList;
            }
        	catch (Exception e) {
            	Boolean expectedExceptionThrown =  e.getMessage().contains('On Stage 5-Contracting opportunity must have an activity referenced to it.');
            	System.AssertEquals(expectedExceptionThrown, true, 'expectedExceptionThrown should be true');
        	}
        List<Opportunity> oppyListFinal=[Select id,name,ActivityCreated__c from Opportunity where id in:oppIDSet];
        For(Opportunity O: oppyListFinal) {
            if(o.id==testOpp1.id) {
                System.assertEquals(o.ActivityCreated__c,true,'testOpp1 has ActivityCreated__c as true');
            }
            if(o.id==testOpp2.id) {
                System.assertEquals(o.ActivityCreated__c,true,'testOpp2 has ActivityCreated__c as true');
            }
            if(o.id==testOpp3.Id) {
               System.assertEquals(o.ActivityCreated__c,true,'testOpp3 has ActivityCreated__c as true');
            }
            if(o.id==testOpp4.Id) {
                System.assertEquals(o.ActivityCreated__c,false,'testOpp4 has ActivityCreated__c as false');
            }
            if(o.id==testOpp5.Id) {
                //System.assertEquals(o.ActivityCreated__c,false,'testOpp5 has ActivityCreated__c as false');
                System.assertEquals(o.ActivityCreated__c,true,'testOpp5 has ActivityCreated__c as true');
            }
        }
        test.stopTest();
    }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 11 June 2021
    // @description: SFDC-3979: Test method for notesCheckbox methods to  Notes / Comments Added Checkbox on Tasks.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testnotesCheckbox() {
        test.startTest();
        Account acc = TestUtility.createTestAccount('Test', true);
        Opportunity testOpp1 = TestUtility.createOpportunity(acc.id, 'Test Opp1', false);
        insert testOpp1;
        
        Task t = new Task(WhatId=testOpp1.id, subject='test', Priority='Normal', Status='Open', Description='ABCTest');
        Task t1 = new Task(WhatId=testOpp1.id, subject='test', Priority='Normal', Status='Open');
        List<task> tskList=new List<task>{t,t1};
        insert tskList;
        List<Task> t2 = [Select Id, NotesCompleted__c from Task Where Id in : tskList];
        System.assertEquals(True, t2[0].NotesCompleted__c,'Comments Checkbox should be checked');
        System.assertEquals(False, t2[1].NotesCompleted__c, 'Comments Checkbox should be unchecked');
    
        test.stopTest();
    }
}