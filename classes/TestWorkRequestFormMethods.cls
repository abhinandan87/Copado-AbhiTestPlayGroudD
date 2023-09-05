//-----------------------------
// @author: Akhila Kodipaka
// @date: 13 Jul 2021
// @param: NA
// @description: Test class for WorkRequestFormMethods class
// @return: NA
//------------------------------

@isTest
public class TestWorkRequestFormMethods {
    @testSetup static void testData() {
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
         Id recordTypeId = Schema.SObjectType.WorkRequestForm__c.getRecordTypeInfosByName().get('APAC').getRecordTypeId();
        WorkRequestForm__c wrf2 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC',recordTypeId = recordTypeId, Internal__c = false, RequestStatus__c = 'Draft', AdHocReport__c =true,
                                                                             JobType__c ='Adhoc',RoyaltyVendor__c = 'No Royalty Data', ReturnToSales__c = true,
                                                                             RequestedDueDate__c = System.today(),OutputType__c = 'Access',OutputMedium__c = 'Online System Access', OpportunityName__c = testOpportunity.id, 
                                                                             ProgrammerTeam__c ='APAC', NegotiatedDate__c = System.today(),CustomGeography__c=true,OEMGeographyDetails__c='test',DataType__c='AFS',RegistrationTypeStandard__c='OEM Custom Reg Types'));
                                                                             
        String testEmail = 'dgtest@test1ihsmarkit.com';
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        TestUtility.addWRApproverPermSet(myTestUser.Id);    
    }
    private static void CountrySelection(Id wrfId, String DataType, String RequestType) {
        CountrySelection__c cs = new CountrySelection__c(Geography__c = 'National', Country__c = 'Algeria', VehicleType__c = 'CARS;HCV;LCV', ISOCode__c = '000');
        cs.WorkRequestForm__c = wrfId;
        cs.DataType__c = DataType;
        cs.RequestType__c = RequestType;
        insert cs;
        CountrySelection__c ccs=[Select VehicleType__c from CountrySelection__c Where Id=:cs.Id];
        system.assertEquals('CARS;HCV;LCV', ccs.VehicleType__c);
    }
    @isTest
    private static void testGetOpportunityDetails() {
        Opportunity opp = [Select Id,ownerId FROM Opportunity LIMIT 1];
        Set<Id> opSet= new Set<Id>();
        opSet.add(opp.Id);
        Test.StartTest();
        Map<Id, Opportunity> op = WorkRequestFormMethods.getOpportunityDetails(opSet);
        system.assert(op.size()>0);
        Test.stopTest();
    }
    @isTest
    private static void testUpdateChangestoOpportunityWorkRequestForms() {
        WorkRequestForm__c wrf = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];
        Opportunity opp = [Select Id,name FROM Opportunity WHERE Name = 'test Oppy1'];
        Test.StartTest();
        wrf.OpportunityName__c = opp.Id;
        update wrf; 
        Test.stopTest();
        WorkRequestForm__c wrfObj = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];
        System.assertEquals(wrf.OpportunityName__c,wrfObj.OpportunityName__c,'Opportunity is updated');
    }
    @isTest
    private static void testUpdateOpportunityFieldsOnWRF() {
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
        System.assert(wrfList.size()>0);
        System.assert(opSet.size()>0);
    }
    @isTest
    private static void updateOwnerAssignment() {
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
        List<CountrySelection__c> csList = [Select Id,WorkRequestForm__c FROM CountrySelection__c WHERE WorkRequestForm__c =: wrf.Id];
        System.assertEquals(true, csList.size()>0, 'Country selections are added');
        Test.stopTest();       
    }
    @isTest
    private static void testCreateOppyWrkRequest() {
        Test.startTest();
        Opportunity opp = [Select Id,name FROM Opportunity WHERE Name = 'test Oppy'];
        WorkRequestForm__c wrf = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE WorldviewVIO__c = false LIMIT 1];
        List<OpportunityWorkRequestForm__c> oppWrf = [Select Id,Opportunity__c,WorkRequestForm__c FROM OpportunityWorkRequestForm__c where Opportunity__c =: opp.Id and WorkRequestForm__c =: wrf.Id];
        System.assertEquals(true, oppWrf.size()>0, 'OpportunityWorkRequestForm is created');
        Test.stopTest();
    }
    @isTest
    private static void testUpdateWRFormType() {
        Test.startTest();
        WorkRequestForm__c wrf = [Select Id,OpportunityName__c FROM WorkRequestForm__c WHERE Internal__c = true LIMIT 1];
        system.assert(wrf!=null);
        Test.stopTest();
    }
    @isTest
    private static void testUpdateonApprovalPending() {      
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser){  
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
    }
    @isTest
    private static void testCreatePLCJobs() {
        Test.StartTest();
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser){
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
    @isTest
    private static void testWipeOffUnSelectedRequestTypesFields() {
        Test.StartTest();
        User currentUser = [SELECT Id FROM User WHERE Alias = 'testA'];
        System.runAs(currentUser){
            WorkRequestForm__c wrf = [Select Id,AdHocReport__c,DataType__c,Mapping__c FROM WorkRequestForm__c WHERE AdHocReport__c = true LIMIT 1];
            wrf.Mapping__c=true;
            update wrf;
            Test.stopTest();
            WorkRequestForm__c wrfObj = [Select Id,RequestStatus__c,AdHocReport__c,DataType__c,Mapping__c,CustomGeography__c FROM WorkRequestForm__c WHERE AdHocReport__c = true LIMIT 1];
            system.assertNotEquals(wrfObj.DataType__c, null, 'Field is not wipped out');
        }
    }
    
}