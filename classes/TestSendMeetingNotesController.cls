//-----------------------------
// @author: Manish Kumar
// @date: 3rd Mar 2022
// @param: NA
// @description: SFDC-5428 Test class for SendMeetingNotesController 
// @return: NA
//-----------------------------

@isTest
private class TestSendMeetingNotesController {
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 3rd Mar 2022
	// @description: SFDC-5428 Test Method for SendMeetingNotesController.fetchMeetingNotesRecepients
	// @return: NA
	//-----------------------------
	
    @isTest static void testFetchMeetingNotesRecepients(){
        
        Account a = TestUtility.createTestAccount('Meeting Notes Account 123',true);
        Opportunity o = TestUtility.createOpportunity(a.id, 'Test Opportunity',null,true);
        Contact cont = TestUtility.createContact(a.Id,'testingmeetingnotes@ihsmarkit.com',true, 'FirstName', 'LastName');
        MeetingNote__c mn = TestUtility.createMeetingNote('MN with Opp',cont.Id,false);
        mn.Opportunity__c = o.Id;
        insert mn;
        String usrName = UserInfo.getName();
        event e1 = TestUtility.createEvent(60,true);
        event e2 = TestUtility.createEvent(60,false);
        e2.ParentId__c = e1.Id;
        e2.whoId = cont.Id;
        e2.Account__c = a.Id;
        e2.MeetingNote__c = mn.Id;
        insert e2;
        List<MeetingNotesWrapper> lstResult = SendMeetingNotesController.fetchMeetingNotesRecepients(e2.Id);
        System.assertEquals(usrName, lstResult[0].Name, 'User Name should be same');
    }
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 3rd Mar 2022
	// @description: SFDC-5428 Test Method for SendMeetingNotesController.searchContacts
	// @return: NA
	//-----------------------------
	
    @isTest static void testSearchContacts(){
        User usr = TestUtility.createAdminUser('testingmeetingnotes@ihsmarkit.com', false);
        usr.CompanyName = 'informa';
        insert usr;
        Account a = TestUtility.createTestAccount('Meeting Notes Account 123',true);
        Contact cont = TestUtility.createContact(a.Id,'testingmeetingnotes@ihsmarkit.com',true, 'FirstName', 'LastName');
        String contName = 'Name';
        List<String> lstEmailAddress = New List<String>();
        String emailAdd1 = 'TestContact1@ihsmarkit.com';
        String emailAdd2 = 'TestContact2@ihsmarkit.com';
        lstEmailAddress.add(emailAdd1);
        lstEmailAddress.add(emailAdd2);
        List<LookupSearchResult> results = SendMeetingNotesController.searchContacts(contName, lstEmailAddress); 
        System.assertEquals(usr.Email, results[0].subtitle, 'User email should be same');
    }
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 3rd Mar 2022
	// @description: SFDC-5428 Test Method for SendMeetingNotesController.sendEmail
	// @return: NA
	//-----------------------------
    
    @isTest static void testSendEmail(){
        Account a = TestUtility.createTestAccount('Meeting Notes Account 123',true);
        Contact markitContact = TestUtility.createContact(a.Id,'testingmeetingnotes@ihsmarkit.com',true, 'FirstName', 'LastName');
        MeetingNote__c mn = TestUtility.createMeetingNote('MN with Acc',markitContact.Id,false);
        mn.Account__c = a.Id;
        insert mn;
        String emailAdd = '[{"email":"testemail@ihsmarkit.com"}]';
        event e1 = TestUtility.createEvent(60,false);
        e1.MeetingNote__c = mn.Id;
        insert e1;
        String result = SendMeetingNotesController.sendEmail(e1.Id, emailAdd);
        System.assertEquals('Success', result, 'Return message is not Success');
    }
    
    //-----------------------------
	// @author: Manish Kumar
	// @date: 3rd Mar 2022
	// @description: SFDC-5428 Test Method for SendMeetingNotesController.hasMeetingOutcome
	// @return: NA
	//-----------------------------
	
    @isTest static void testHasMeetingOutcome(){
        Account a = TestUtility.createTestAccount('Meeting Notes Account 123',true);
        Contact markitContact = TestUtility.createContact(a.Id,'testingmeetingnotes@ihsmarkit.com',true, 'FirstName', 'LastName');
        MeetingNote__c mn = TestUtility.createMeetingNote('MN Without Acc And Opp',markitContact.Id,true);
        event e1 = TestUtility.createEvent(60,true);
        event e2 = TestUtility.createEvent(60,false);
        e2.MeetingNote__c = mn.Id;
        insert e2;
        String result1 = SendMeetingNotesController.hasMeetingOutcome(e1.Id);
        System.assertEquals('Related Meeting note not found', result1, 'Related Meeting note should not be found');
        String result2 = SendMeetingNotesController.hasMeetingOutcome(e2.Id);
        System.assertEquals('Meeting notes is blank. Please add it to send meeting notes', result2, 'Meeting notes should be blank');
        String result3 = SendMeetingNotesController.hasMeetingOutcome(a.Id);
        System.assertEquals('No matching event record found', result3, 'Matching event record should not be found');
    }

}