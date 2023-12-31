/**
 * @Author:  Hemant Shukla
 * @Date:    2-Nov-2017
 * @description: Test class for CreateMeetingNoteEventController
**/

@IsTest
public class TestCreateMeetingNoteEventController {
    
    //
    // @Author: Hemant Shukla
    // @date: 2-Nov-2017
    // @description: To create a common Test records for all test methods
    // @param: null
    // @return: void
    // @Lastmodifiedby : Mohit Modi
    // @Lastupdated Date : 10 April 2018
    // @Lastupdated description: SFDC1-3843 : Changing the Field Type of ProductFamily__c from Picklist to Lookup
    //
    @testSetup static void setup() {
        
        Account a = TestUtility.createTestAccount('Meeting Notes Account 123',true);
        Opportunity o = TestUtility.createOpportunity(a.Id,'Test oppy meeting notes 123',null,true);
        
        Contact markitContact = TestUtility.createContact(a.Id,'hemant.shukla@ihsmarkit.com',true,'TestFirst','TestLast');
        Contact markitContact1 = TestUtility.createContact(a.Id,'testingmeetingnotes@gmail.com',true,'TestMFirst','TestMLast');
        
        //Assuming NRG recordtype exist in system
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;

        //creating product family to test other scenarions
        Family__c pf = new Family__c();
        pf.Name = 'NRG Family';
        pf.ProductGroup__c = pg.Id;
        insert pf;
        
        Event e1 = new Event(whatId = o.Id, Subject = 'blabla', DurationInMinutes = 60, ActivityDateTime = Datetime.now(), ProductFamilyLookup__c =pf.id /* ProductFamily__c = '3rd Party Index Management' */);
        insert e1;
        
        Event e2 = new Event(whoId = markitContact.Id, Subject = 'blabla', DurationInMinutes = 60, ActivityDateTime = Datetime.now(), ProductFamilyLookup__c =pf.id /* ProductFamily__c = '3rd Party Index Management' */ );
        insert e2;
        
        Event e3 = new Event(Subject = 'blabla', DurationInMinutes = 60, ActivityDateTime = Datetime.now(), ProductFamilyLookup__c =pf.id /* ProductFamily__c = '3rd Party Index Management'*/);
        insert e3;
        
        EventRelation evr1 = new EventRelation(EventId = e1.Id, RelationId = markitContact.Id);
        insert evr1;
        
    }
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for validateEventForMeetingCreation() method
     * @param: null
     * @return: void
    */
    @isTest static void testValidateEventForMeetingCreation() {
        
        Test.startTest();
        //This will have WhatId
        Event e1 = [Select Id, WhatId, WhoId from Event where whatId != null];
        String message;
        message = CreateMeetingNoteEventController.validateEventForMeetingCreation(e1.Id);
        System.assertEquals('This event is already linked to a meeting note.', message, message);        
        
        //This will have AccoutId via whoId - contact
        Event e2 = [Select Id, WhatId, WhoId from Event where whoId != null];
        message = CreateMeetingNoteEventController.validateEventForMeetingCreation(e2.Id);
        System.assertEquals('This event is already linked to a meeting note.', message, message);
        
        //This will neither have AccoutId not whatId
        Event e3 = [Select Id, WhatId, WhoId from Event where AccountId = null];
        message = CreateMeetingNoteEventController.validateEventForMeetingCreation(e3.Id);
        System.assertEquals('Please link this event to an Account or Opportunity.', message, message);
        Test.stopTest();
    }
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for getPrePopulatedMeetingNote() method
     * @param: null
     * @return: void
    */
    @isTest static void testGetPrePopulatedMeetingNote() {
        Test.startTest();
        
        //For Opportunity
        Event e1 = [Select Id, WhatId, WhoId from Event where whatId != null];
        Opportunity o = [Select Id, name from Opportunity limit 1];
        MeetingNote__c mnOpp = CreateMeetingNoteEventController.getPrePopulatedMeetingNote(e1.Id);
        
        String expectedName = System.now().date().format() +': Meeting for Opportunity: '+ o.name;
        System.assertEquals(expectedName , mnOpp.name, 'Meeting Note Name should match with the expected name in correct format');
        
        //For account
        Event e2 = [Select Id, WhatId, WhoId from Event where whoId != null];
        Account a = [Select Id, name from Account limit 1];
        MeetingNote__c mnAcc = CreateMeetingNoteEventController.getPrePopulatedMeetingNote(e2.Id);
        
        expectedName = 'Meeting with '+ a.name;
        System.assertEquals(expectedName , mnAcc.name, 'Meeting Note Name should match with the expected name in correct format');
        
        Test.stopTest();
         
    }    
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for getOpportunititesListToAdd() method
     * @param: null
     * @return: void
    */
    @isTest static void testGetOpportunititesListToAdd() {
        Test.startTest();
        
        Opportunity o = [Select Id, name from Opportunity limit 1];
        Account a = [Select Id, name from Account limit 1];
        
        //The blank option only
        List<Opportunity> opps = CreateMeetingNoteEventController.getOpportunititesListToAdd(new MeetingNote__c(Opportunity__c = o.id, Account__c = a.Id));
        System.assertEquals(1 , opps.size(), 'Opportunity record count should be 1');
        
        List<Opportunity> opps1 = CreateMeetingNoteEventController.getOpportunititesListToAdd(new MeetingNote__c(Account__c = a.Id));
        System.assertEquals(2 , opps1.size(), 'Opportunity record count should be 2');
        System.assertEquals(opps1[1].name, o.name, 'Verifying if the Opportunity Name is populated correctly');
        
        Test.stopTest();
    }    
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for addRelatedOpportunitiesForMeetingId() method
     * @param: null
     * @return: void
    */
    @isTest static void testAddRelatedOpportunitiesForMeetingId() {
        Test.startTest();
        Opportunity o = [Select Id, name from Opportunity limit 1];
        RelatedOpportunity__c ro = CreateMeetingNoteEventController.addRelatedOpportunitiesForMeetingId(null, o.id);
        system.assertEquals(o.id, ro.Opportunity__c, 'Matching the Opty Id with Related Opty Id');
        Test.stopTest();
    }
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for addMeetingAttendee() method
     * @param: null
     * @return: void
    */
    @isTest static void testAddMeetingAttendee() {
        Test.startTest();
        List<Contact> lstCon = [Select Id, name from Contact];
        cAttendee attendee1 = CreateMeetingNoteEventController.addMeetingAttendee(lstCon[0].id);
        system.assertEquals(lstCon[0].id, attendee1.Contact.Id, 'Contact Id is not matching');
        cAttendee attendee2 = CreateMeetingNoteEventController.addMeetingAttendee(lstCon[1].id);
        system.assertEquals(lstCon[1].id, attendee2.Contact.Id, 'Contact Id is not matching');
        Test.stopTest();
    }    
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for getMeetingAttendees() method
     * @param: null
     * @return: void
    */
    @isTest static void testGetMeetingAttendees() {
        Test.startTest();
        Event e1 = [Select Id, WhatId, WhoId from Event where whatId != null];
        List<cAttendee> attendeeList = CreateMeetingNoteEventController.getMeetingAttendees(e1.id, new MeetingNote__c());
        system.assertEquals(true, attendeeList[0].attendee.IHSMarkitEmployee__c, 'Employee should be IHSMarkit Employee');
        Test.stopTest();
    }
    
    /**
     * @Author: Hemant Shukla
     * @date: 2-Nov-2017
     * @description: Test Method for saveMeetingNotesAndRelatedData() method
     * @param: null
     * @return: void
    */
    @isTest static void testSaveMeetingNotesAndRelatedData() {
        Test.startTest();
        Event e1 = [Select Id, WhatId, WhoId from Event where whatId != null];
        MeetingNote__c mn1 = new MeetingNote__c(Name = 'TestMN', NextSteps__c = 'NS', Achieved__c = 'AC', Info__c = 'info');
        MeetingNote__c mn2 = new MeetingNote__c(Name = 'TestMN', NextSteps__c = 'NS', Achieved__c = 'AC', Info__c = 'info');
        MeetingNote__c mn3 = new MeetingNote__c(Name = 'TestMN', NextSteps__c = 'NS', Achieved__c = 'AC', Info__c = 'info');
        //First Screen
        CreateMeetingNoteEventController.ResponseWrapper rw1 = CreateMeetingNoteEventController.saveMeetingNotesAndRelatedData(mn1, null, null, e1.Id); 
        system.assertEquals('Attempt to de-reference a null object', rw1.message, 'Verifying if the message is null');
        
        //Second Screen
        Opportunity o = [Select Id, name from Opportunity limit 1];
        CreateMeetingNoteEventController.ResponseWrapper rw2 = CreateMeetingNoteEventController.saveMeetingNotesAndRelatedData(mn2, new list<String>{o.Id}, null, e1.Id);
        system.assertEquals('success', rw2.message, 'Message should be success');
        
        //Third Screen
        List<cAttendee> attendeeList = new List<cAttendee>();
        List<Contact> lstCon = [Select Id, name from Contact limit 1];
        attendeeList.add(New cAttendee(new MeetingAttendee__c() , lstCon[0] , true)); 
        String jsonLstAttendees = JSON.serialize(attendeeList);
        CreateMeetingNoteEventController.ResponseWrapper rw3 = CreateMeetingNoteEventController.saveMeetingNotesAndRelatedData(mn3, new list<String>{o.Id}, jsonLstAttendees, e1.Id);
        system.assertEquals('success', rw3.message, 'Message should be success');
        
        Test.stopTest();
    }
}