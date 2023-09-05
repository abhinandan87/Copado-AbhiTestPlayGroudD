//-----------------------------
// @author: Harshit Singhal
// @date: 30 Mar 2020
// @param: NA
// @description: Test class for SetupEvents__e platform event trigger methods
// @return: NA
//-----------------------------
@isTest
public class TestSetupEventsMethods {
    @testSetup 
    static void createTestData() {        
        TestEventMethods.setupBasicData();        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 12 May 2020
    // @param: NA
    // @description: Test method for SetupEvents__e platform event trigger method populatePrimaryAccPrivacyLvl().
    // @return: NA
    //-----------------------------
    @isTest private static void testShareMeetingNoteWithEventAttendees() {
        System.debug('testShareMeetingNoteWithEventAttendees() TEST BEGINS');
        //Query Sales User
        User testSalesUser = [SELECT Id,Name,Profile.Name FROM User WHERE Username='salesrepActivityManagement@testuser.com' LIMIT 1];
        System.debug('testSalesUser='+testSalesUser);
        //Query external contact
        Contact extContact = [SELECT Id,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        System.debug('***Create Events in TEST');
        //Sc1: Create a new event with custom meeting note populated
        Event testEvt1 = TestUtility.createEventWithWhoId('EventInsert1',extContact.Id, false);
        Event testEvt2 = TestUtility.createEventWithWhoId('EventInsert2',null, false);
        List<Event> insEvtList = new List<Event> {testEvt1, testEvt2};
        insert insEvtList;
        
        Id meetingNoteIdTestEvt1;
        Set<Id> evtIdSet = new Set<Id>();
        for(Event evt:[SELECT Id,MeetingNote__c FROM Event WHERE Id IN :insEvtList]) {
            evtIdSet.add(evt.Id);
            if(evt.Id==testEvt1.Id) {
                meetingNoteIdTestEvt1 = evt.MeetingNote__c;
                System.assertNotEquals(null, evt.MeetingNote__c, 'Meeting note was not created for event.');
            }
            if(evt.Id==testEvt2.Id) {
                System.assertEquals(null, evt.MeetingNote__c, 'Meeting note should not be created for the event.');
            }            
        }
        
        EventRelation evrSalesUserEvt1 = new EventRelation(RelationId=testSalesUser.Id,EventId=testEvt1.Id,IsParent=false,IsWhat=false,IsInvitee=true);
        EventRelation evrSalesUserEvt2 = new EventRelation(RelationId=testSalesUser.Id,EventId=testEvt2.Id,IsParent=false,IsWhat=false,IsInvitee=true);
        List<EventRelation> evrList = new List<EventRelation> {evrSalesUserEvt1, evrSalesUserEvt2};
        insert evrList;
        
        //CALLING THE MAIN METHOD MANUALLY WHICH PLATFORM EVENT WILL INVOKE MANUALLY - Update Event record and insert event relations, if done in same block then new Event Relations are lost
        EventMeetingNoteSyncUtility.setupMeetingNoteSharing(evtIdSet);
        
        //Query MeetingNote__Share record for SalesUser
        List<MeetingNote__Share> mnShareLst = [SELECT Id,UserOrGroupId,UserOrGroup.Name,ParentId,Parent.RelatedEventId__c,Parent.Name FROM MeetingNote__Share WHERE RowCause=:Schema.MeetingNote__Share.rowCause.EventAttendeeShare__c];
        System.debug('mnShareLst='+mnShareLst);        	        
        System.assertEquals(testSalesUser.Id, mnShareLst[0].UserOrGroupId, 'Meeting Note is not shared with event attendee via apex sharing.');
        
        //Fire platform events explicitly for Update
        Test.getEventBus().deliver();
		        
        //Query MeetingNote__Share record for SalesUser
        mnShareLst = [SELECT Id,UserOrGroupId,UserOrGroup.Name,ParentId,Parent.RelatedEventId__c,Parent.Name FROM MeetingNote__Share WHERE RowCause=:Schema.MeetingNote__Share.rowCause.EventAttendeeShare__c];
        System.debug('mnShareLst='+mnShareLst);        
              
        
        System.debug('testShareMeetingNoteWithEventAttendees() TEST ENDS');
    }
    
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 12 May 2020
    // @param: NA
    // @description: Test method for SetupEvents__e platform event trigger method populatePrimaryAccPrivacyLvl().
    // @return: NA
    //-----------------------------
    @isTest private static void testPopulatePrimaryAccPrivacyLvl() {
        //Query Sales User
        User testSalesUser = [SELECT Id,Name,Profile.Name FROM User WHERE Username='salesrepActivityManagement@testuser.com' LIMIT 1];        
        
        //Query an Internal Acc
        Account intAcc = [SELECT Id,Name FROM Account WHERE Name='Internal Account2' LIMIT 1];
        
        //Query external and internal contacts
        Contact extContact, intContact;
        for(Contact cntct: [SELECT Id,Email,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' or Email like '%con1intacc1subacc@polk.com%']) {
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
        List<Event> evtList = new List<Event> {externalMeeting, internalMeeting};
        insert evtList;
        
        Test.stopTest();

        //Assertions
        List<Id> evtIdList = new List<Id> {externalMeeting.Id, internalMeeting.Id };
        List<Event> evtAssertList = [SELECT Id,AccountId,PrivacyLevel__c FROM Event WHERE Id IN :evtIdList];
        
		Event qryEvtInsert = evtAssertList[0];
        System.debug('08May qryEvtInsert='+qryEvtInsert);
        System.assertEquals(extContact.AccountId, qryEvtInsert.AccountId, 'Account Id on external event not set correctly.');
        System.assertEquals('Customer-facing meeting',qryEvtInsert.PrivacyLevel__c, 'Privacy Level not set correctly on external event.');        
        
    }
}