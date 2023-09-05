@isTest
public class TestBatchDeletionPrivateEvents {
	@testSetup static void setupEventData() {
        List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='System Administrator'].Id;
        for(integer i=1; i<=2; i++)
        {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            User tuser = new User(  firstname = 'test'+i,
                                  lastName = 'user'+i,
                                  email = uniqueName + '@test' + orgId + '.org',
                                  Username = uniqueName + '@test' + orgId + '.org',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = 'test',
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  ProfileId = pid,
                                  HRManager__c='testManager',
                                  ADID__c='test'+String.valueOf(Math.round(Math.random()*10000))+system.now().millisecond(),
                                  EmployeeNumber=String.valueOf(Math.round(Math.random()*10000))+i,
                                  EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000))+i);
            users.add(tuser);
        }
        	insert users;
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'OutlookSyncEnabled'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'DoNotDeletePrivateEvents'];
            PermissionSetAssignment psa1=new PermissionSetAssignment(AssigneeId = users[0].id, PermissionSetId = ps1.Id);
            PermissionSetAssignment psa2=new PermissionSetAssignment(AssigneeId = users[1].id, PermissionSetId = ps2.Id);
        	PermissionSetAssignment psa3=new PermissionSetAssignment(AssigneeId = users[1].id, PermissionSetId = ps1.Id);
        	List<PermissionSetAssignment> psaList=new List<PermissionSetAssignment>();
            psaList.add(psa1);
        	psaList.add(psa2);
        	psaList.add(psa3);
            System.runAs ( users[1] ) {
                insert psaList;
            }
            Id standardRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
            List<Event> eventList=new List<Event>();
            Event e1=new Event(Subject='Test-1',Type='Meetings', PrivacyLevel__c='Personal appointment',ownerid=users[0].id, startdatetime=DateTime.now().addDays(-20), enddatetime=DateTime.now().addDays(-20), RecordTypeId=standardRecordTypeId, SourceGlobalAction__c=false);
            Event e2=new Event(Subject='Test-2',Type='Meetings',PrivacyLevel__c='Personal appointment',ownerid=users[0].id, startdatetime=DateTime.now().addDays(-21), enddatetime=DateTime.now().addDays(-21), RecordTypeId=standardRecordTypeId, SourceGlobalAction__c=false);
            Event e3=new Event(Subject='Test-3',Type='Meetings',PrivacyLevel__c='Personal appointment', ownerid=users[1].id, startdatetime=DateTime.now().addDays(-22), enddatetime=DateTime.now().addDays(-22), RecordTypeId=standardRecordTypeId, SourceGlobalAction__c=false);
            Event e4=new Event(Subject='Test-4',Type='Meetings',PrivacyLevel__c='Personal appointment',ownerid=users[1].id, startdatetime=DateTime.now().addDays(-23), enddatetime=DateTime.now().addDays(-23), RecordTypeId=standardRecordTypeId, SourceGlobalAction__c=false);
            eventList.add(e1);
            eventList.add(e2);
            eventList.add(e3);
            eventList.add(e4);
            insert eventList;
    }
    testmethod static void testDeletion(){
        BatchDeletePrivateEventsScheduler b = new BatchDeletePrivateEventsScheduler();
        b.email='test@test.com';
        String sch1 ='0 0 1 ? * SAT'; 
        System.schedule('Schedule to delete the private events', sch1, b);
        test.startTest();
            BatchDeletePrivateEvents b1 = new BatchDeletePrivateEvents('test@test.com');
            database.executeBatch(b1,20);
        test.stopTest();
        
        List<Event> eList=[Select id from Event];
        System.assertEquals(eList.size(),2);
    }
}