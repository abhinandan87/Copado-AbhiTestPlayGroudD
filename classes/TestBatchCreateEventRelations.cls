//-----------------------------
// @author: Harshit Singhal
// @date: 20 May 2020
// @param: NA
// @description: Test Class for BatchCreateEventRelations class
// @return: NA
//----------------------------
@isTest
private class TestBatchCreateEventRelations {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 21 May 2020
    // @description: SFDC-2733 Setup test data
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    static void createTestData() {        
        //Create Account
        List<Account> insertAccList = new List<Account>();
        Account intAcc1 = TestUtility.createTestAccount('Internal Account1',false);
        insertAccList.add(intAcc1);
        Account intAcc2 = TestUtility.createTestAccount('Internal Account2',false);
        insertAccList.add(intAcc2);
        Account extAcc1 = TestUtility.createTestAccount('External Account1',false);
        insertAccList.add(extAcc1);
        Account extAcc2 = TestUtility.createTestAccount('External Account2',false);
        insertAccList.add(extAcc2);
        
        insert insertAccList;
        
        //Add Contacts
        List<Contact> contactList = new List<Contact>();
        Contact intAcc1Con1 = TestUtility.createContact(insertAccList[0].Id,'con1intacc1@ihsmarkit.com',false,'Contact1','Internal Acc1');
        Contact intAcc1Con2 = TestUtility.createContact(insertAccList[0].Id,'con2intacc1@ihsmarkit.com',false,'Contact2','Internal Acc1');
        contactList.add(intAcc1Con1);
        contactList.add(intAcc1Con2);
        Contact intAcc2Con1 = TestUtility.createContact(insertAccList[1].Id,'con1intacc2@ihsmarkit.com',false,'Contact1','Internal Acc2');
        Contact intAcc2Con2 = TestUtility.createContact(insertAccList[1].Id,'con2intacc2@ihsmarkit.com',false,'Contact2','Internal Acc2');
        contactList.add(intAcc2Con1);
        contactList.add(intAcc2Con2);
        Contact extAcc1Con1 = TestUtility.createContact(insertAccList[2].Id,'con1extacc1@ext.com',false,'Contact1','External Acc1');
        Contact extAcc1Con2 = TestUtility.createContact(insertAccList[2].Id,'con2extacc1@ext.com',false,'Contact2','External Acc1');
        contactList.add(extAcc1Con1);
        contactList.add(extAcc1Con2);
        Contact extAcc2Con1 = TestUtility.createContact(insertAccList[3].Id,'con1extacc2@ext.com',false,'Contact1','External Acc2');
        Contact extAcc2Con2 = TestUtility.createContact(insertAccList[3].Id,'con2extacc2@ext.com',false,'Contact2','External Acc2');
        contactList.add(extAcc2Con1);
        contactList.add(extAcc2Con2);
        
        insert contactList;
        
        //Create Events such that they have a meeting note
        List<Event> evtWithInternalWhoIdList = new List<Event>();        
        Integer countEvtWithIntWhoId = 50;
        for(Integer i=0;i<countEvtWithIntWhoId;i++) {
            String evtSubject = 'Test EventInternalWhoId'+String.valueOf(i);
            Event evtObj = TestUtility.createEventWithWhoId(evtSubject,intAcc1Con1.Id, false);
            evtWithInternalWhoIdList.add(evtObj);
        }
        insert evtWithInternalWhoIdList;
        
        //Delete MeetingNote.RelatedEventId__c field value. This makes sure that the related event records are processed by this batch job.
        List<MeetingNote__c> mnUpdList = new List<MeetingNote__c>();
        for(Event evt: [SELECT Id,MeetingNote__c FROM Event WHERE Id IN :evtWithInternalWhoIdList]) {
            System.assertNotEquals(null, evt.MeetingNote__c);
            MeetingNote__c mtngObj = new MeetingNote__c(Id=evt.MeetingNote__c);
            mtngObj.RelatedEventId__c = null;
            mnUpdList.add(mtngObj);
        }
        update mnUpdList;
        
        //Create MeetingAttendees on meeting notes
        List<MeetingAttendee__c> mtndAttList = new List<MeetingAttendee__c>();
        for(MeetingNote__c mnObj: mnUpdList) {
            for(Contact con: contactList) {
                MeetingAttendee__c mtngAtt = new MeetingAttendee__c(MeetingNote__c=mnObj.Id,Contact__c=con.Id);
            	mtndAttList.add(mtngAtt);
            }
        }
        insert mtndAttList;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 21 May 2020
    // @description: SFDC-2733 Main test method that runs the batch class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    static void testBatch() {
        //Before Batch Asserts
        for(Event evt:[SELECT Id,(SELECT Id,RelationId,IsParent,IsWhat FROM EventRelations WHERE IsWhat=false AND IsParent=true) FROM Event WHERE Subject='Test EventInternalWhoId%']) {
            System.assertEquals(1, evt.EventRelations.size(), 'There should be just single Event Relation record of Primary WhoId on event itself before batch runs.');
        }
        //Run batch
        Test.startTest();
        Id batchJobId = Database.executeBatch(new BatchCreateEventRelations(null,null));
        System.debug('batchJobId='+batchJobId);
        Test.stopTest();
        
        //After batch asserts
        for(Event evt:[SELECT Id,(SELECT Id,RelationId,IsParent,IsWhat FROM EventRelations WHERE IsWhat=false AND IsParent=true) FROM Event WHERE Subject='Test EventInternalWhoId%']) {
            System.assert(evt.EventRelations.size()>1, 'There should be new Event Relation records created from MeetingAttendees of MeetingNote after batch runs.');
        }
    }

}