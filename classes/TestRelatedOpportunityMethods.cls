//-----------------------------
// @author: Priyanka Vyas
// @date: 24 June 2020
// @param: NA
// @description: SFDC-3115 Test Class for RelatedOpportunityMethods
// @return: NA
//-----------------------------
@isTest
public class TestRelatedOpportunityMethods {
    @isTest public static void checkRelatedOpportunityMethods() {
        Set<ID> oppIDSet=new Set<ID>();
        Account acc1 = TestUtility.createTestAccount('TestAcc1',false);
        Account acc2 = TestUtility.createTestAccount('TestAcc2',false);
        Account acc3 = TestUtility.createTestAccount('TestAcc3',false);
        List<Account> accList=new List<Account>{acc1, acc2, acc3};
        test.startTest();
        insert accList;
        Opportunity testOpp1 = TestUtility.createOpportunity(acc1.id, 'Test Opp1', false);
        Opportunity testOpp2 = TestUtility.createOpportunity(acc2.id, 'Test Opp2', false);
        Opportunity testOpp3 = TestUtility.createOpportunity(acc3.id, 'Test Opp3', false);
        Opportunity testOpp4 = TestUtility.createOpportunity(acc3.id, 'Test Opp4', false);
        Opportunity testOpp5 = TestUtility.createOpportunity(acc3.id, 'Test Opp5', false);
        testOpp5.ActivityCreated__c=true;
        List<Opportunity> oppList = new List<Opportunity> {testOpp1, testOpp2, testOpp3, testOpp4,testOpp5};
            insert oppList;
        for(Opportunity opp:oppList){
            oppIDSet.add(opp.id);
        }
        Event testEvt1 = new Event(Subject='Test1', WhatId=testOpp1.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
        insert testEvt1;
        Task t = new Task(WhatId=testOpp2.id, subject='test', Priority='Normal', Status='Open');
        insert t;
        RelatedOpportunity__c rlObj1=new RelatedOpportunity__c();
        rlObj1 = [SELECT Id, Opportunity__c FROM RelatedOpportunity__c WHERE MeetingNote__r.RelatedEventId__c=:testEvt1.id];
        if(rlObj1!=null){
            rlObj1.Opportunity__c=testOpp3.id;
        }
        update rlObj1;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Contact markitContact = TestUtility.createContact(acc3.Id,uniqueName + '@test' + orgId + '.org',true, 'FirstName', 'LastName');
        MeetingNote__c mn = new MeetingNote__c(Account__c = acc3.Id, Name = 'test1243', Opportunity__c = testOpp4.Id,InternalContactLookup__c = markitContact.Id);
        insert mn;
        RelatedOpportunity__c testRO1 = new RelatedOpportunity__c(MeetingNote__c=mn.Id,Opportunity__c=testOpp3.Id);
        RelatedOpportunity__c testRO2 = new RelatedOpportunity__c(MeetingNote__c=mn.Id,Opportunity__c=testOpp5.Id);
        RelatedOpportunity__c testRO3 = new RelatedOpportunity__c(MeetingNote__c=mn.Id,Opportunity__c=testOpp1.Id);
        RelatedOpportunity__c testRO4 = new RelatedOpportunity__c(MeetingNote__c=mn.Id,Opportunity__c=testOpp2.Id);
        List<RelatedOpportunity__c> ROList=new List<RelatedOpportunity__c>{testRO1,testRO2,testRO3,testRO4};
            insert ROList;
        List<RelatedOpportunity__c> ROListDeletion=new List<RelatedOpportunity__c>{testRO1,testRO2, rlObj1, testRO4};
            delete ROListDeletion;
        test.stopTest(); 	
        List<Opportunity> oppyListFinal=[Select id,name,ActivityCreated__c from Opportunity where id in:oppIDSet];
        For(Opportunity O: oppyListFinal){
            if(o.id==testOpp1.id){
                System.assertEquals(o.ActivityCreated__c,true,'opp should be active.');
            }
            if(o.id==testOpp2.id){
                System.assertEquals(o.ActivityCreated__c,true,'opp should be active.');
            }
            if(o.id==testOpp3.Id){
                System.assertEquals(o.ActivityCreated__c,false,'opp should be active.');
            }
            if(o.id==testOpp4.Id){
                System.assertEquals(o.ActivityCreated__c,true,'opp should be active.');
            }
            if(o.id==testOpp5.Id){
                System.assertEquals(o.ActivityCreated__c,false,'opp should be active.');
            }
        }
    }
    //-----------------------------
    // @author: Anjali
    // @date: 17 Feb 2021
    // @param: Trigger events
    // @description: SFDC-3135 : Test method for checkDuplicateRelatedOpportunityRec
    // @return: NA
    //------------------------------
    @isTest public static void testCheckDuplicateRelatedOpportunityRec() {
        Set<ID> oppIDSet=new Set<ID>();
        Account acc = TestUtility.createTestAccount('TestAcc1',false);
        Account acc2 = TestUtility.createTestAccount('TestAcc2',false);
        List<Account> accList=new List<Account>{acc, acc2};
        insert accList;
        Opportunity testOpp1 = TestUtility.createOpportunity(acc.id, 'Test Opp1', false);  
        Opportunity testOpp2 = TestUtility.createOpportunity(acc2.id, 'Test Opp2', false);
        testOpp1.ActivityCreated__c=true;  
        List<Opportunity> oppList = new List<Opportunity> {testOpp1, testOpp2};
        insert oppList;
        Event testEvt1 = new Event(Subject='Test1', WhatId=testOpp1.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
        insert testEvt1;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Contact markitContact = TestUtility.createContact(acc.Id,uniqueName + '@test' + orgId + '.org',true, 'FirstName', 'LastName');        
        MeetingNote__c mn = new MeetingNote__c(Account__c = acc.Id, Name = 'test1243',Opportunity__c = testOpp1.Id, InternalContactLookup__c = markitContact.Id);
        insert mn;
        RelatedOpportunity__c testRO1 = new RelatedOpportunity__c(MeetingNote__c=mn.Id,Opportunity__c=testOpp2.Id);
        insert testRO1;        
        RelatedOpportunity__c testRO2;
        try{
        Test.startTest();
         testRO2 = new RelatedOpportunity__c(MeetingNote__c=mn.Id,Opportunity__c=testOpp2.Id);
        insert testRO2;
        }catch(exception e) {
            system.assertEquals(true,e.getMessage().contains(System.Label.DuplicateRelatedOpportunity), 'exception message match with label');
        }
        System.assertEquals(testRO2.Id,null,'related opp is null.'); 
        Test.stopTest();
    }
}