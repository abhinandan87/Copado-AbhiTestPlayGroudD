// @author: Uttam Arya
// @date: 31 Aug 2017
// @param: NA
// @description: Test class for Event trigger methods 
// @return: NA
//-----------------------------

@isTest
public class TestEventMethods {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test setup method to setup basic data for Event trigger methods. Used in TestMeetingNoteMethods test class as well to create basic data.
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    public static void setupBasicData() {
        //Create Account - Internal & External
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
        
        //Create Account Hierarchy
        Account intAcc1SubAcc = TestUtility.createTestAccount('Internal Account1 SubAcc',false);
        intAcc1SubAcc.ParentId = intAcc1.Id;
        insert intAcc1SubAcc;
        
        //Create contacts in internal and external accounts
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
        
        Contact intAcc1SubAccCon1 = TestUtility.createContact(intAcc1SubAcc.Id,'con1intacc1subacc@polk.com',false,'Contact1','Internal Acc1 SubAcc');        
        contactList.add(intAcc1SubAccCon1);        
        
        insert contactList;
        
        //Add mapping fields to sync custom setting
        //SELECT Id, Name, MeetingNoteFieldAPI__c, SyncDirection__c FROM EventMeetingNoteSync__c
		EventMeetingNoteSync__c map1EtoMN = new EventMeetingNoteSync__c(Name='AccountId',MeetingNoteFieldAPI__c='Account__c',SyncDirection__c='EventToMeetingNote');
        EventMeetingNoteSync__c map2EtoMN = new EventMeetingNoteSync__c(Name='StartDateTime',MeetingNoteFieldAPI__c='StartDateTime__c',SyncDirection__c='EventToMeetingNote');
        EventMeetingNoteSync__c map3EtoMN = new EventMeetingNoteSync__c(Name='PrivacyLevel__c',MeetingNoteFieldAPI__c='PrivacyLevel__c',SyncDirection__c='EventToMeetingNote');
        EventMeetingNoteSync__c map4Bidirectional = new EventMeetingNoteSync__c(Name='Subject',MeetingNoteFieldAPI__c='Subject__c',SyncDirection__c='Bidirectional');
        EventMeetingNoteSync__c map5MNtoE = new EventMeetingNoteSync__c(Name='Description',MeetingNoteFieldAPI__c='Description__c',SyncDirection__c='MeetingNoteToEvent');
        EventMeetingNoteSync__c map6EtoMN = new EventMeetingNoteSync__c(Name='EndDateTime',MeetingNoteFieldAPI__c='EndDateTime__c',SyncDirection__c='EventToMeetingNote');
        List<EventMeetingNoteSync__c> syncMappings = new List<EventMeetingNoteSync__c> {map1EtoMN, map2EtoMN, map3EtoMN, map4Bidirectional, map5MNtoE, map6EtoMN};
        insert syncMappings;
        
        //Add acc names to custom setting - InternalAccount__c
        //SELECT Id, Name FROM InternalAccounts__c
        InternalAccounts__c intAccName1 = new InternalAccounts__c(Name=intAcc1.Name);
        InternalAccounts__c intAccName2 = new InternalAccounts__c(Name=intAcc2.Name);
        List<InternalAccounts__c> intAccNameList = new List<InternalAccounts__c> {intAccName1, intAccName2};
        insert intAccNameList;
        
        //Create a Sales user
        User salesUser = TestUtility.createTestUser('IHSMarkit Sales: General','salesrepActivityManagement@testuser.com',true);
    }
        
    //-----------------------------
    // @author: Uttam Arya
    // @date: 31 Aug 2017
    // @param: NA
    // @description: SFDC1-2243 Test method for Event trigger methods populateEventAddedInOpportunityWhenEventIsInserted on insert
    // @return: NA
    // @updated date: 11/11/2019
    // @updated by: Paras Dhingra
    // @updated description : SFDC-2259 adding fix for bulkification
    //-----------------------------
    @isTest
    private static void testpopulateEventAddedInOpportunityWhenEventIsInserted() {
        
        Account acct = TestUtility.createTestAccount('Test populateAdditionalFiledsLookupInAccount', true);
        Opportunity oppt = TestUtility.createOpportunity(acct.Id, 'Test Oppy Event', true);
        
        Event e1 = new Event(Account__c = acct.Id, Subject = 'Test Event', DurationInMinutes = 60, ActivityDateTime = Datetime.now(), WhatId = oppt.Id);
        Event e2 = new Event(Account__c = acct.Id, Subject = 'Test Event2', DurationInMinutes = 60, ActivityDateTime = Datetime.now(), WhatId = oppt.Id);
        List<Event> lstEventToTestBulkification = new List<Event>();
        lstEventToTestBulkification.add(e1);
        lstEventToTestBulkification.add(e2);
        insert lstEventToTestBulkification;
        
        //Assert if MIS is inserted
        Opportunity opp = [select MISActivityAdded__c from Opportunity where Id =: oppt.Id];
        
        System.assertNotEquals(opp.MISActivityAdded__c,null, 'Verifying if the MISActivityAdded__c on Opportunity is populated correctly');
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Jun 2018
    // @param: NA
    // @description: SFDC1-8541 Test method for Event trigger method setActivityTypeFromType() on insert and update
    // @return: NA
    //-----------------------------
    @isTest
    private static void testSetActivityTypeFromType() {        
        
        //Insert Event        
        Event e = new Event(Subject = 'Test Event 123', DurationInMinutes = 60, ActivityDateTime = Datetime.now(), RecordTypeId=EventMeetingNoteSyncUtility.stdEventRecTypeId);
        insert e;
        System.assertEquals('Meetings', [Select Id,ActivityType__c From Event Where Id=:e.Id].ActivityType__c, 'Verifying if the Activity Type is Meetings');
        
        //Update Event
        e.Type = 'Test Type 2';
        update e;
        System.assertEquals('Test Type 2', [Select Id,ActivityType__c From Event Where Id=:e.Id].ActivityType__c, 'Verifying if the Activity Type is updated correctly');
    }
    
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for deleteRelatedMeetingNote() method in EventMethods class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testDeleteRelatedMeetingNote() {
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create event
        Event testEvt = TestUtility.createEventWithWhoId('Test Event',extContact.Id, false);
        insert testEvt;
        
        //Query Event
        Event queryEvt = [SELECT Id,Subject,MeetingNote__c,MeetingNote__r.Name,MeetingNote__r.Opportunity__c,MeetingNote__r.StartDateTime__c,MeetingNote__r.EndDateTime__c,MeetingNote__r.Description__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertNotEquals(null, queryEvt.MeetingNote__c, 'Meeting note not created automatically on event.');
        
        //Delete event
        delete testEvt;
        
        //Assertion
        System.assertEquals(0, [SELECT Id FROM MeetingNote__c WHERE Id=:queryEvt.MeetingNote__c].size(), 'Related meeting note not deleted on deleting the parent event.');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for syncMeetingNoteWithEvent() method in EventMethods class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testEnforceDeleteValidations() {
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create event
        Event testEvt = TestUtility.createEventWithWhoId('Test Event',extContact.Id, false);
        insert testEvt;
        
        //Query Event
        Event queryEvt = [SELECT Id,Subject,MeetingNote__c,MeetingNote__r.Name,MeetingNote__r.Opportunity__c,MeetingNote__r.StartDateTime__c,MeetingNote__r.EndDateTime__c,MeetingNote__r.Description__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertNotEquals(null, queryEvt.MeetingNote__c, 'Meeting note not created automatically on event.');
        
        //Fill meeting outcome on meetingnote
        MeetingNote__c mnObj = new MeetingNote__c(Id=queryEvt.MeetingNote__c, MeetingOutcome__c = 'test outcome of meeting');
        update mnObj;
        
        //Try to delete parent event
        try {
        	delete testEvt;    
        }
        catch(Exception ex) {
            String errorMessage = ex.getMessage();
            System.assert(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot delete an event with completed notes.'),'Trigger validation to stop users from deleting an event with completed notes is failing.');
        }
    }
	
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for syncMeetingNoteWithEvent() method in EventMethods class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testSyncMeetingNoteWithEvent() {
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
                
        //Create opp
        Opportunity testOpp = TestUtility.createOpportunity(extContact.AccountId, 'Test Opp', true);        
        
        //Create event
        Event testEvt = TestUtility.createEventWithWhoId('Test Event',extContact.Id, false);        
        insert testEvt;
        
        //Update event - Subject, WhatId(Opp), any custom setting sync field
        testEvt.Subject = 'Test Event Updated Subject';
        testEvt.WhatId = testOpp.Id;
        testEvt.StartDateTime = System.now()+3;
        testEvt.EndDateTime = System.now()+4;
        testEvt.Description = 'test description';
        update testEvt;
        
        //Assertions
        Event assertEvt = [SELECT Id,Subject,MeetingNote__c,MeetingNote__r.Name,MeetingNote__r.Opportunity__c,MeetingNote__r.StartDateTime__c,MeetingNote__r.EndDateTime__c,MeetingNote__r.Description__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertNotEquals(null, assertEvt.MeetingNote__c, 'Meeting note not created automatically on event.');
        System.assertEquals(testEvt.Subject, assertEvt.MeetingNote__r.Name, 'Meeting Note name not correct.');
        System.assertEquals(testEvt.StartDateTime, assertEvt.MeetingNote__r.StartDateTime__c, 'Meeting Note StartDateTime not in sync with event.');
        System.assertEquals(testEvt.EndDateTime, assertEvt.MeetingNote__r.EndDateTime__c, 'Meeting Note EndDateTime not in sync with event.');
        System.assertEquals(testEvt.EndDateTime, assertEvt.MeetingNote__r.EndDateTime__c, 'Meeting Note EndDateTime not in sync with event.');
        System.assertNotEquals(testEvt.Description, assertEvt.MeetingNote__r.Description__c, 'Meeting note description should not be in sync with event description.');
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for createMeetingNote() method in EventMethods class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testCreateMeetingNote() {
        
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create opp
        Opportunity testOpp = TestUtility.createOpportunity(extContact.AccountId, 'Test Opp', true);        
        
        //Sc1: Create event
        Event testEvt = TestUtility.createEventWithWhoId('Test Event',null, false);
        testEvt.WhatId = testOpp.Id;
        insert testEvt;
        //Sc1 Assertions
        Event assertEvt = [SELECT Id,Subject,MeetingNote__c,MeetingNote__r.RelatedEventId__c,MeetingNote__r.Name,MeetingNote__r.Opportunity__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];
        System.assertNotEquals(null, assertEvt.MeetingNote__c, 'Meeting note not created automatically on event insert.');
        System.assertEquals(testEvt.Id, assertEvt.MeetingNote__r.RelatedEventId__c, 'RelatedEventId__c field not populated on newly created Meeting note of the event.');
        System.assertEquals(testEvt.Subject, assertEvt.MeetingNote__r.Name, 'Meeting Note name not correct.');
        System.assertEquals(testOpp.Id, assertEvt.MeetingNote__r.Opportunity__c, 'Opportunity Id missing on meeting note created from event.');
        Id oldMeetingNoteId = assertEvt.MeetingNote__c;
        
        //Sc2: Update event
        //Delete meetint note
        MeetingNote__c mnDel = new MeetingNote__c(Id=assertEvt.MeetingNote__c);      
        delete mnDel;
        //Update event WhatId and WhoId so that Event.AccountId=null
        //testEvt.WhoId = null;
        testEvt.WhatId = null;
        update testEvt;
        //Again add a WhoId to Event to generate a new MeetingNote
        testEvt.WhoId = extContact.Id;
        update testEvt;
        //Sc2 Assertions
        assertEvt = [SELECT Id,Subject,MeetingNote__c,MeetingNote__r.Name,MeetingNote__r.Account__c FROM Event WHERE Id=:testEvt.Id LIMIT 1];        
        System.assertNotEquals(null, assertEvt.MeetingNote__c, 'Meeting note not created automatically on event update.');
        System.assertNotEquals(oldMeetingNoteId, assertEvt.MeetingNote__c, 'New meeting note was not created on event update.');
        System.assertEquals(extContact.AccountId, assertEvt.MeetingNote__r.Account__c, 'Account__c on meeting note not in sync with related event.');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for publishSetupEventPlatformEvents() method in EventMethods class.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testPublishSetupEventPlatformEvents() {
        //Query Sales User
        User testSalesUser = [SELECT Id,Name,Profile.Name FROM User WHERE Username='salesrepActivityManagement@testuser.com' LIMIT 1];        
        
        //Query an Internal Acc
        Account intAcc = [SELECT Id,Name FROM Account WHERE Name='Internal Account2' LIMIT 1];
        
        //Query external and internal contacts
        Contact extContact, intContact;
        for(Contact cntct: [SELECT Id,Email,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' OR Email Like '%con1intacc1subacc@polk.com%']) {
            if((cntct.Email).contains('con1extacc1@ext.com')) {
                extContact = cntct;
            }
            else if((cntct.Email).contains('con1intacc1subacc@polk.com')) {
                intContact = cntct;
            }
        }
        System.assertNotEquals(null, extContact, 'External contact not found.');
        System.assertNotEquals(null, intContact, 'Internal contact not found.');
        
        Test.startTest();
        
        //Sc1: Insert event
        Event externalMeeting = TestUtility.createEventWithWhoId('ExternalMeeting',extContact.Id, false);
        Event internalMeeting = TestUtility.createEventWithWhoId('InternalMeeting',intContact.Id, false);
        Event personalAppointment = TestUtility.createEventWithWhoId('PersonalAppointment',null, false);                
        Event internalMeetingWithAttendee = TestUtility.createEventWithWhoId('InternalMeetingWithAttendee',null, false);
        Event externalMeetingWithIternalPrimaryContact = TestUtility.createEventWithWhoId('ExternalMeetingWithIternalPrimaryContact',intContact.Id, false);
        List<Event> evtList = new List<Event> {externalMeeting, internalMeeting, personalAppointment, internalMeetingWithAttendee, externalMeetingWithIternalPrimaryContact};
        insert evtList;
        
        EventRelation attendeeRelation = new EventRelation(EventId=internalMeetingWithAttendee.Id, RelationId=testSalesUser.Id,IsInvitee=true);
        EventRelation contactRelation = new EventRelation(EventId=externalMeetingWithIternalPrimaryContact.Id, RelationId=extContact.Id,IsInvitee=false, IsWhat=false, IsParent=true);
        List<EventRelation> evtRelList = new List<EventRelation> {attendeeRelation, contactRelation};
        insert evtRelList;
        
        //Assert to check that initially primary contact is internal, hence AccountId on event will also be internal.
        Event qryTestEvent = [SELECT Id,AccountId,PrivacyLevel__c FROM Event WHERE Id=:externalMeetingWithIternalPrimaryContact.Id LIMIT 1];
        System.debug('08May qryTestEvent='+qryTestEvent);
        System.assertEquals(intContact.AccountId, qryTestEvent.AccountId, 'Event primary account is not set to an internal account though primary contact is internal.');
                
       	//Sc2: Update event
        
        //Dummy update to fire update trigger on event and fire platform event to reset AccountId and PrivacyLevel__c as per external contact
        update externalMeetingWithIternalPrimaryContact;        
        //Assign WhatId to event
        internalMeeting.WhatId = intAcc.Id;
        update internalMeeting;
        
        Test.stopTest();
        //Assertions
        List<Id> evtIdList = new List<Id> {externalMeeting.Id, internalMeeting.Id, personalAppointment.Id, internalMeetingWithAttendee.Id, externalMeetingWithIternalPrimaryContact.Id };
        List<Event> evtAssertList = [SELECT Id,AccountId,PrivacyLevel__c FROM Event WHERE Id IN :evtIdList];
        
        Event qryEvtInsert = evtAssertList[0];
        System.debug('08May qryEvtInsert='+qryEvtInsert);
        System.assertEquals(extContact.AccountId, qryEvtInsert.AccountId, 'Account Id on external event not set correctly.');
        System.assertEquals('Customer-facing meeting',qryEvtInsert.PrivacyLevel__c, 'Privacy Level not set correctly on external event.');
        
        qryEvtInsert = evtAssertList[1];
        System.debug('08May qryEvtInsert='+qryEvtInsert);
        System.assertEquals(intAcc.Id, qryEvtInsert.AccountId, 'Account Id on internal event not set correctly.');
        System.assertEquals('Internal meeting',qryEvtInsert.PrivacyLevel__c, 'Privacy Level not set correctly on internal event.');
        
        qryEvtInsert = evtAssertList[2];
        System.debug('08May qryEvtInsert='+qryEvtInsert);
        System.assertEquals(null, qryEvtInsert.AccountId, 'Account Id should be null on personal appointment.');
        System.assertEquals('Personal appointment',qryEvtInsert.PrivacyLevel__c, 'Privacy Level not set correctly on personal appointment event.');
        
        qryEvtInsert = evtAssertList[3];
        System.debug('08May qryEvtInsert='+qryEvtInsert);
        System.assertEquals(null, qryEvtInsert.AccountId, 'Account Id should be null on event with blank WhoId and WhatId.');
        System.assertEquals('Internal meeting',qryEvtInsert.PrivacyLevel__c, 'Privacy Level not set correctly on internal event.');
                
        qryEvtInsert = evtAssertList[4];
        System.debug('08May qryEvtInsert='+qryEvtInsert);
        System.assertEquals(extContact.AccountId, qryEvtInsert.AccountId, 'Account Id did not get updated to external account by Platform Event.');
        System.assertEquals('Customer-facing meeting',qryEvtInsert.PrivacyLevel__c, 'Privacy Level not updated to customer-facing meeting by platform event.');
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for enforceEventValidations() method in EventMethods class for Sales User scenario.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testEnforceEventValidationsForSalesUser() {
        
        //Query Sales User
        User testSalesUser = [SELECT Id,Name,Profile.Name FROM User WHERE Username='salesrepActivityManagement@testuser.com' LIMIT 1];
        
        //Query external contact
        Contact extContact = [SELECT Id,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        System.runAs(testSalesUser) {
            //Create an unrelated meeting note 
        	MeetingNote__c manualNote = TestUtility.createTestManualMeetingNote('ManualMeetingNote', true);
        	
            //Sc1: Create a new event with custom meeting note populated
            Event evtInsert = TestUtility.createEventWithWhoId('EventInsert',extContact.Id, false);
            evtInsert.MeetingNote__c = manualNote.Id;
            try {
                insert evtInsert;                
            }
            catch(Exception ex) {
                String errorMessage = ex.getMessage();                
                //System.debug('Insert errorMessage='+errorMessage);
                System.assert(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION, Meeting Note cannot be populated manually on an event.'),'Trigger validation to stop non Admin users to update Meeting Note manually is failing.');
            }
            
            
            //Sc2: Create a new event with WhoId filled, then manually update the meeting note lookup to custom meeting note
            Event evtUpdate = TestUtility.createEventWithWhoId('EventUpdate',extContact.Id, true);
            evtUpdate.MeetingNote__c = manualNote.Id;            
            try {
                update evtUpdate;
            }
            catch(Exception ex) {
                String errorMessage = ex.getMessage();
                //System.debug('Update errorMessage='+errorMessage);
                System.assert(errorMessage.containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION, Meeting Note cannot be updated manually on an event.'),'Trigger validation to stop non Admin users to update Meeting Note manually is failing.');
            }
        }
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @description: SFDC-2733 Test method for enforceEventValidations() method in EventMethods class for System Admin scenario.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testEnforceEventValidationsBypassSysAdmin() {
        //Query external contact
        Contact extContact = [SELECT Id,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        
        //Create an unrelated meeting note 
        MeetingNote__c manualNoteAdmin = TestUtility.createTestManualMeetingNote('ManualMeetingNoteAdmin', true);
        
        //Sc1: Create a new event with custom meeting note populated
        Event evtInsertAdmin = TestUtility.createEventWithWhoId('EventInsertAdmin',extContact.Id, false);
        evtInsertAdmin.MeetingNote__c = manualNoteAdmin.Id;
        insert evtInsertAdmin;
        
        Event qryEvtInsertAdmin = [SELECT Id,MeetingNote__c FROM Event WHERE Id=:evtInsertAdmin.Id LIMIT 1];
        System.assertEquals(manualNoteAdmin.Id, qryEvtInsertAdmin.MeetingNote__c, 'System Admin unable to populate meeting note manually on a new event.');
        
        //Sc2: Create a new event with WhoId filled, then manually update the meeting note lookup to custom meeting note
        Event evtUpdateAdmin = TestUtility.createEventWithWhoId('EventUpdateAdmin',extContact.Id, true);
        evtUpdateAdmin.MeetingNote__c = manualNoteAdmin.Id;
        update evtUpdateAdmin;
        
        Event qryEvtUpdateAdmin = [SELECT Id,MeetingNote__c FROM Event WHERE Id=:evtUpdateAdmin.Id LIMIT 1];
        System.assertEquals(manualNoteAdmin.Id, qryEvtUpdateAdmin.MeetingNote__c, 'System Admin unable to update meeting note manually on existing event.');        
    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 26 Aug 2020
    // @description: SFDC-3133 Test method for changeActivityCreatedOppyOnUpdate and changeActivityCreatedOppyOnDelete methods to update ActivityCreated__c.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    private static void testChangeActivityCreatedCheckboxOnOpportunity() {
        Set<ID> oppIDSet=new Set<ID>();
        test.startTest();
        Account acc = [Select id from account where name='Internal Account1'];
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
        Task t = new Task(WhatId=testOpp2.id, subject='test', Priority='Normal', Status='Open');
        insert t;
        Event evt1 = new Event(Type='Meeting', Subject='Meeting1', WhatId=testOpp1.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
        Event evt2 = new Event(Type='Meeting', Subject='Meeting2', WhatId=testOpp2.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
        Event evt3 = new Event(Type='Meeting', Subject='Meeting3', WhatId=testOpp3.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
        Event evt4 = new Event(Type='Meeting', Subject='Meeting4', WhatId=testOpp4.id,StartDateTime=System.now(),EndDateTime=System.now()+1);
        List<event> evtList=new List<Event>{evt1,evt2,evt3,evt4};
            insert evtList;
        Set<Id> evtIdSet = new Set<Id>();
        for(event e:evtList) {
            evtIdSet.add(e.id);
        }
        evt4.WhatId=testOpp5.id;
        update evt4;
        
        List<Event> deleteEventList = [Select id, whatid, what.name from Event where id in:evtIdSet];
        delete deleteEventList;
        
        List<Opportunity> oppyListFinal=[Select id,name,ActivityCreated__c from Opportunity where id in:oppIDSet];
        For(Opportunity O: oppyListFinal) {
            if(o.id==testOpp1.id){
                System.assertEquals(o.ActivityCreated__c,true,'testOpp1 has ActivityCreated__c as true');
            }
            if(o.id==testOpp2.id) {
                System.assertEquals(o.ActivityCreated__c,true,'testOpp2 has ActivityCreated__c as true');
            }
            if(o.id==testOpp3.Id) {
                System.assertEquals(o.ActivityCreated__c,false,'testOpp3 has ActivityCreated__c as false');
            }
            if(o.id==testOpp4.Id) {
                System.assertEquals(o.ActivityCreated__c,false,'testOpp4 has ActivityCreated__c as false');
            }
            if(o.id==testOpp5.Id) {
                System.assertEquals(o.ActivityCreated__c,false,'testOpp5 has ActivityCreated__c as false');
            }
        }
        test.stopTest();
    }
}