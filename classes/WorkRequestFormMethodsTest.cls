@isTest
public class WorkRequestFormMethodsTest {
    @testSetup static void testData() {
        String userId = UserInfo.getUserId();
        String permissionsetId = [SELECT Id FROM PermissionSet where name='WRApprover'].Id;
       /* PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = userId,
            PermissionSetId = permissionsetId);
        insert psa;
        */
        Account acc = TestUtility.createTestAccount('TestAccount', true);
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Oppy', true); 
        Opportunity testOpportunity1 = TestUtility.createOpportunity(acc.Id, 'test Oppy1', true); 
        WorkRequestForm__c wrf = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC', Internal__c = false, RequestStatus__c = 'Draft', JobType__c ='Adhoc',
                                                                            RoyaltyVendor__c = 'No Royalty Data', OpportunityName__c = testOpportunity.id, ReturnToSales__c = true,
                                                                            RequestedDueDate__c = System.today(),OutputType__c = 'Access',OutputMedium__c = 'Online System Access', 
                                                                            ProgrammerTeam__c ='APAC', NegotiatedDate__c = System.today()));
        WorkRequestForm__c wrf1 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC', Internal__c = false, RequestStatus__c = 'Draft', WorldviewVIO__c =true,
                                                                             JobType__c ='Adhoc',RoyaltyVendor__c = 'No Royalty Data', PARCDataFiles__c = true, 
                                                                             DataExtractGlobalVIOPARC__c = true, MarketInsightSystem__c = true, ReturnToSales__c = true,
                                                                             RequestedDueDate__c = System.today(),OutputType__c = 'Access',OutputMedium__c = 'Online System Access',
                                                                             DataExtractNewReg__c = true, NewRegSystem__c = true, OpportunityName__c = testOpportunity.id, 
                                                                             ProgrammerTeam__c ='APAC', NegotiatedDate__c = System.today(),
                                                                             WorldViewSystemDataSet__c ='WorldView OE Parts Research;WorldView Global VIO'));
        WorkRequestForm__c intWrf = TestUtility.newWRF(new WorkRequestForm__c (Internal__c = true, RequestStatus__c = 'Draft', JobType__c ='Adhoc',
                                                                               RoyaltyVendor__c = 'No Royalty Data', ReturnToSales__c = true, 
                                                                               RequestedDueDate__c = System.today(),OutputType__c = 'Access',OutputMedium__c = 'Online System Access', 
                                                                               ProgrammerTeam__c ='APAC', NegotiatedDate__c = System.today()));
        
    }
    private static void CountrySelection(Id wrfId, String DataType, String RequestType) {
        CountrySelection__c cs = new CountrySelection__c(Geography__c = 'National', Country__c = 'Algeria', VehicleType__c = 'CARS;HCV;LCV', ISOCode__c = '000');
        cs.WorkRequestForm__c = wrfId;
        cs.DataType__c = DataType;
        cs.RequestType__c = RequestType;
        insert cs;
    }
    private static testMethod void testGetOpportunityDetails() {
        Opportunity opp = [Select Id,ownerId FROM Opportunity LIMIT 1];
        Set<Id> opSet= new Set<Id>();
        opSet.add(opp.Id);
        Test.StartTest();
        Map<Id, Opportunity> op = WorkRequestFormMethods.getOpportunityDetails(opSet);
        Test.stopTest();
    }
    private static testMethod void testUpdateChangestoOpportunityWorkRequestForms() {
        WorkRequestForm__c wrf = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];
		Opportunity opp = [Select Id,name FROM Opportunity WHERE Name = 'test Oppy1'];
        Test.StartTest();
        wrf.OpportunityName__c = opp.Id;
        update wrf; 
        Test.stopTest();
    }
    private static testMethod void testUpdateOpportunityFieldsOnWRF() {
		List<WorkRequestForm__c> wrfList = new List<WorkRequestForm__c>();
        Opportunity opp = [Select Id,name FROM Opportunity WHERE Name = 'test Oppy'];
        Set<Id> opSet= new Set<Id>();
        Test.StartTest();
        opSet.add(opp.Id);
        Map<Id, Opportunity> op = WorkRequestFormMethods.getOpportunityDetails(opSet);
        WorkRequestForm__c wrf = [Select Id,OwnerId,OpportunityName__c,AccountName__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];
        wrfList.add(wrf);
        WorkRequestFormMethods.updateOpportunityFieldsOnWRF(wrfList,op);
        Test.stopTest();
        /*Opportunity oppObj = [Select Id,name,AccountId FROM Opportunity WHERE Name = 'test Oppy'];
        WorkRequestForm__c wrfObj = [Select Id,AccountName__c,OwnerId FROM WorkRequestForm__c WHERE Id =: wrf.Id];
        System.assertEquals(oppObj.AccountId, wrfObj.AccountName__c, 'Account name is copied from Opportunity to WRF');*/
    }
    private static testMethod void updateOwnerAssignment() {
        Opportunity opp = [Select Id,name FROM Opportunity WHERE Name = 'test Oppy'];
        Set<Id> opSet= new Set<Id>();
        opSet.add(opp.Id);
        Test.StartTest();
        Map<Id, Opportunity> op = WorkRequestFormMethods.getOpportunityDetails(opSet);
        WorkRequestForm__c wrf = [Select Id,OwnerId FROM WorkRequestForm__c WHERE WorldviewVIO__c = true LIMIT 1];
        
        CountrySelection(wrf.id,'Global VIO','Data Extract Global VIO (PARC)');
        CountrySelection(wrf.id,'New Regs','New Reg System');
        CountrySelection(wrf.id,'Used Regs','Data Extract');
        CountrySelection(wrf.id,'New Regs','MarketInsight System');
        CountrySelection(wrf.id,'Global VIO','MarketInsight VIO System');
        CountrySelection(wrf.id,'Global VIO','WorldView Global VIO');
        CountrySelection(wrf.id,'Global VIO','WorldView OE Parts Research');
        
        wrf.RequestStatus__c = 'Submitted';
        wrf.PrimarySalesContact__c = [SELECT Id FROM user WHERE ID=:Userinfo.getUserid()].Id;
        update wrf;
        Test.stopTest();
    }
    private static testMethod void testCreateOppyWrkRequest() {
        Test.startTest();
        Opportunity opp = [Select Id,name FROM Opportunity WHERE Name = 'test Oppy'];
        WorkRequestForm__c wrf = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];
        Test.stopTest();
    }
    private static testMethod void testUpdateWRFormType() {
        Test.startTest();
        WorkRequestForm__c wrf = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE Internal__c = true LIMIT 1];
        Test.stopTest();
    }
    private static testMethod void testUpdateonApprovalPending() {       
        WorkRequestForm__c wrf = [Select Id,RequestStatus__c,PrimarySalesContact__c,ProgrammerAssigned__c,RejectionComments__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];        
        Test.StartTest();
        wrf.RequestStatus__c = 'Submitted';
        wrf.PrimarySalesContact__c = [SELECT Id FROM user WHERE ID=:Userinfo.getUserid()].Id;
        update wrf;
        wrf.RequestStatus__c='Approval Pending';
        update wrf;
        wrf.ProgrammerAssigned__c = [SELECT Id FROM user WHERE ID=:Userinfo.getUserid()].Id;
        update wrf;
        wrf.RequestStatus__c = 'Rejected';
        wrf.RejectionComments__c = 'Rejected';
        update wrf;
        Test.stopTest();
        WorkRequestForm__c wrfObj = [Select Id,RequestStatus__c,PrimarySalesContact__c,OwnerId FROM WorkRequestForm__c WHERE Id =: wrf.Id];
        System.assertEquals('Rejected', wrfObj.RequestStatus__c, 'Request status is rejected');
        System.assertEquals(wrf.PrimarySalesContact__c, wrfObj.OwnerId, 'Owner is updated');
    }
    private static testMethod void testCreatePLCJobs() {
        Test.StartTest();
        WorkRequestForm__c wrf = [Select Id,RequestStatus__c,PrimarySalesContact__c,ProgrammerAssigned__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];        
        wrf.RequestStatus__c = 'Submitted';
        wrf.PrimarySalesContact__c = [SELECT Id FROM user WHERE ID=:Userinfo.getUserid()].Id;
        wrf.ProgrammerAssigned__c = [SELECT Id FROM user WHERE ID=:Userinfo.getUserid()].Id;
        update wrf;
        wrf.RequestStatus__c='Approved';
        update wrf;
        Test.stopTest();
        WorkRequestForm__c wrfObj = [Select Id,RequestStatus__c,ProgrammerAssigned__c FROM WorkRequestForm__c WHERE Id =: wrf.Id];        
        List<PLCJob__c> plcJob = [Select Id FROM PLCJob__c WHERE WorkRequestForm__c =: wrf.Id];
        System.assertEquals(wrfObj.RequestStatus__c, 'Approved', 'Work request form is approved');
        System.assertEquals(true, plcJob.size()>0, 'PLC job is created');
    }    
}