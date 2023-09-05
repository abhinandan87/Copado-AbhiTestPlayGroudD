//------------------------------------------------
// @author: Priyanka Vyas
// @date: 14 Apr 2020
// @description:  SFDC-2565, SFDC-2699 Creation of Contact & Opportunity from utility bar
//------------------------------------------------
@isTest
public class TestQuickRecordCreationController {
    public static testMethod void testQuickRecordCreation() {
        test.startTest();
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        SObject acc = QuickRecordCreationController.fetchSObjectfields(testAccount.id);
        String orgId = UserInfo.getOrganizationId();
        String userId = UserInfo.getUserId();
        User user=QuickRecordCreationController.fetchCurrentUser(userId);
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        Contact newContact1;
        Contact newContact2;
        Opportunity opp1;
        Opportunity opp2;
        Opportunity opp3;
        Event newEvent1;
        Task newTask1;
        String accId=String.valueOf(acc.Id);
        String contactEmail=uniqueName + '@test' + orgId + '.com';
        newContact1 = QuickRecordCreationController.createContact('TestFirstName','TestMiddleName','TestLastName','999-888-1234',contactEmail,accId, 'test','FinTech','Analyst','Advisor','Accounting');
        try{		
            newContact2 = QuickRecordCreationController.createContact('TestFirstName','TestMiddleName','TestLastName','999-888-1234',null,accId, 'test','FinTech','Analyst','Advisor','Accounting');
        }Catch(Exception ex){
            System.debug('::: Error on quick create contact in test context: '+ex);
        }
        QuickRecordCreationController.fetchPickListValues('Opportunity', 'BudgetRange__c');
        opp1 = QuickRecordCreationController.createOpportunity('Opp1',accId, Date.newInstance(2016, 12, 9) ,'< 25,000');
        opp2 = QuickRecordCreationController.createOpportunity('Opp1',accId, Date.newInstance(2016, 12, 9) ,'--None--');
        String eventJSON='{"eventType": "Meeting", "eventSubject": "Call", "eventWhoId":"'+ newContact1.Id +'", "eventWhatId":"'+ opp1.Id+'", "StartDateTime":"'+Datetime.now()+'", "EndDateTime":"'+ DateTime.Now().AddDays(1)+'", "OwnerId":"'+UserInfo.getUserId()+'", "Location":"Test"}';
    	Event newEvent = QuickRecordCreationController.createEvent(eventJSON);
        String taskJSON='{"taskType": "Task", "taskSubject": "Call", "taskWhoId":"'+newContact1.Id+'", "taskWhatId":"'+ opp1.Id+'", "OwnerId":"'+ UserInfo.getUserId()+'", "ActivityDate":"'+Date.today()+'", "Priority": "Normal", "Status": "Open" }';
     	Task newTask = QuickRecordCreationController.createTask(taskJSON);
        String eWhoId=QuickRecordCreationController.fetchEventWhatId(newEvent.Id);
        String tWhoId=QuickRecordCreationController.fetchTaskWhatId(newTask.Id);
        String eventJSON1='{"eventType": "Call", "eventSubject": "Call", "eventWhoId":"'+ newContact1.Id +'", "eventWhatId":"'+ opp1.Id+'", "StartDateTime":"'+Datetime.now()+'", "EndDateTime":"'+ DateTime.Now().AddDays(1)+'", "OwnerId":"null"}';
        try{
            newEvent1 = QuickRecordCreationController.createEvent(eventJSON1);
        }
        catch(Exception ex){
            System.debug('::: Error on quick create event in test context: '+ex);
        }
        String taskJSON1='{"taskType": "Task", "taskSubject": "Call", "taskWhoId":"'+newContact1.Id+'", "taskWhatId":"'+ opp1.Id+'", "OwnerId":"null", "ActivityDate":"'+Date.today()+'", "Priority": "Normal"}';
        try{
            newTask1 = QuickRecordCreationController.createTask(taskJSON1);
        }
        catch(Exception ex){
            System.debug('::: Error on quick create task in test context: '+ex);
        }
        testAccount.DataGovernanceStatus__c ='Unapproved';
        update testAccount;
        try{		
            opp3 = QuickRecordCreationController.createOpportunity('Opp1',accId, Date.newInstance(2016, 12, 9) ,'--None--');
        }Catch(Exception ex){
            System.debug('::: Error on quick create opportunity in test context: '+ex);
        }
        test.stopTest(); 
        QuickRecordCreationController.checkCreationPermission('Contact');
        List<Profile> readOnlyProfiles = [select id, Name from Profile where Name = 'IHSMarkit: Read Only Profile'];
		User u = new User(FirstName='Test', Alias = 'standt', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = readOnlyProfiles[0].Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org', HRManager__c ='TestHR', ADID__c=uniqueName + '@test' + orgId + '.org', EmployeeNumber__c='123');
        System.runAs(u) {
        	QuickRecordCreationController.checkCreationPermission('Opportunity');
        }
        System.assert(newContact1!=null);
        System.assert(opp1!=null);
		System.assert(newTask!=null);
        System.assert(newEvent!=null);
        
    }
    
}