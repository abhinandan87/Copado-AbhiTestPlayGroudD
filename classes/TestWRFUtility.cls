//-----------------------------
// @author: Akhila Kodipaka
// @date: 06 Jul 2021
// @param: NA
// @description: Test class for WRFUtility class
// @return: NA
//------------------------------

@isTest
public class TestWRFUtility {
    public static testMethod void testVisualization() {
        Test.StartTest();
        //test that queue routing is correct
        WorkRequestForm__c wrf = new WorkRequestForm__c (
            Name='Visualization',
            TableauVisualization__c = true,
            FormType__c='Stat'
        );
        //get list of queues
        Map<String, ID> queueMAP = new Map<String, ID>();
        for(group g:[select id,name from Group where Type='Queue']) {
            queueMAP.put(g.name,g.id);
        }
        Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment = new Map<String,WRFOwnerAssignments__mdt>(); 
        for(WRFOwnerAssignments__mdt assignment : [SELECT MasterLabel, QueueName__c FROM WRFOwnerAssignments__mdt]) {
            mapOfOwnerAssignment.put(assignment.MasterLabel,assignment);
        }
        Map<Id,User> mapofUsers = new Map<Id,User>([SELECT Id,userroleid,userrole.name,UserRegion__c FROM user WHERE (ID=:Userinfo.getUserid())]);
        //should be visualization queue
        Id i = WRFUtility.returnWRFOwnerId(wrf,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('Visualization'), wrf.ownerId);
        
        //should not be put in visualization queue
        wrf.Mapping__c = true;
        WRFUtility.returnWRFOwnerId(wrf,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertNotEquals(queueMap.get('Visualization'), wrf.ownerId);
        
        //should not be put in visualization queue
        wrf.TableauVisualization__c = false;
        wrf.OwnerId = queueMap.get('Visualization');
        WRFUtility.returnWRFOwnerId(wrf,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertNotEquals(queueMap.get('Visualization'), wrf.ownerId);
        Test.StopTest();
    }
    
    @isTest public static void testAPAC() {
        //get list of queues
        Map<String, ID> queueMAP = new Map<String, ID>();
        for(group g:[select id,name from Group where Type='Queue']) {
            queueMAP.put(g.name,g.id);
        }
        Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment = new Map<String,WRFOwnerAssignments__mdt>(); 
        for(WRFOwnerAssignments__mdt assignment : [SELECT MasterLabel, QueueName__c FROM WRFOwnerAssignments__mdt]) {
            mapOfOwnerAssignment.put(assignment.MasterLabel,assignment);
        }
        Map<Id,User> mapofUsers = new Map<Id,User>([SELECT Id,userroleid,userrole.name,UserRegion__c FROM user WHERE (ID=:Userinfo.getUserid())]);
        
        Test.StartTest();
        //create WRF with no request type
        WorkRequestForm__c wrf0 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false));
        //create WRF with each request type
        WorkRequestForm__c wrf1 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false, AdHocReport__c=true, 
                                                                             CustomGeography__c=true, CustomYearCoverage__c=true,
                                                                             Periodicity__c='Other', VehicleSegmentation__c='Other'));
        WorkRequestForm__c wrf2 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false, DataExtractGlobalVIOParc__c=true,
                                                                             CustomYearCoverage__c=true, Periodicity__c='Other', ForecastYears__c='Other',
                                                                             CustomGeography__c=true, VehicleSegmentation__c='Other', 
                                                                             AgeClasses__c='Custom Age Classes'));
        WorkRequestForm__c wrf3 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false, MarketInsightSystem__c=true));     
        WorkRequestForm__c wrf4 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false, PolkInsightChinaSystem__c=true));
        WorkRequestForm__c wrf5 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false, WorldviewVIO__c=true,
                                                                             WorldViewSystemDataSet__c=
                                                                             'WorldView North America VIO;WorldView Global VIO;WorldView OE Parts Research',
                                                                             VIOSelection__c = 'Selected',
                                                                             MotorcycleSelection__c = 'Selected',
                                                                             ParcSelection__c = 'Selected',
                                                                             GAMSSelection__c = 'Selected',
                                                                             TimePeriodsAftermarket__c ='Custom Selection (Use Textbox)'));
        WorkRequestForm__c wrf6 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC' , Internal__c = false, WorldviewVIO__c=true));
        
        
        
        //assert that routings were correct
        
        Id i = WRFUtility.returnWRFOwnerId(wrf0,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMAP.get('Salesforce Support'), wrf0.ownerid);
        
        i = WRFUtility.returnWRFOwnerId(wrf1,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMAP.get('APAC WRF'), wrf1.ownerid);
        
        i = WRFUtility.returnWRFOwnerId(wrf2,mapofUsers,queueMAP,mapOfOwnerAssignment);
        wrf2.OwnerId = Userinfo.getUserId();
        //XedeUtility.ProductionQueue(wrf2);  //SFDC-5577- WRF Decomission
        
        i = WRFUtility.returnWRFOwnerId(wrf3,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMAP.get('European WRF'), wrf3.ownerid);
        
        i = WRFUtility.returnWRFOwnerId(wrf4,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMAP.get('Market Reporting - OEM Stat'), wrf4.ownerid);
        
        i = WRFUtility.returnWRFOwnerId(wrf5,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMAP.get('Market Reporting - CAP'), wrf5.ownerid);
        
        i = WRFUtility.returnWRFOwnerId(wrf6,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMAP.get('Market Reporting - CAP'), wrf6.ownerid);
        Test.StopTest();
    }
    
    public static testMethod void testUKAftermarketAnalytics() {
        Map<String, ID> queueMAP = new Map<String, ID>();
        for(group g:[select id,name from Group where Type='Queue']) {
            queueMAP.put(g.name,g.id);
        }
        Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment = new Map<String,WRFOwnerAssignments__mdt>(); 
        for(WRFOwnerAssignments__mdt assignment : [SELECT MasterLabel, QueueName__c FROM WRFOwnerAssignments__mdt]){
            mapOfOwnerAssignment.put(assignment.MasterLabel,assignment);
        }
        Map<Id,User> mapofUsers = new Map<Id,User>([SELECT Id,userroleid,userrole.name,UserRegion__c FROM user WHERE (ID=:Userinfo.getUserid())]);
        Test.StartTest();
        //Test Analytics
        WorkRequestForm__c wrf1 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'UK' , Internal__c = false,
                                                                             Analytics__c = true, ModelSegmentation__c=true,
                                                                             DMSCodesProvided__c=true, KeywordTextSearchRequired__c=true,
                                                                             Retailers__c='Specific', EventJobTypeSpecific__c='Specific',
                                                                             CampaignSpecificReport__c=true));                                                           
        //  Job Type Conditions
        WorkRequestForm__c wrf2 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'UK' , Internal__c = false,
                                                                             PolkConnectSystem__c=true, JobTypeUK__c='Other'));
        
        WorkRequestForm__c wrf3 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c='Aftermarket', WorldviewVIO__c=true, Internal__c = false, Mapping__c = true,
                                                                             WorldViewSystemDataSet__c='WorldView North America VIO, WorldView Global VIO, WorldView OE Parts Research', VIOSelection__c='Selected', SelectedVIO__c=null,
                                                                             MotorcycleSelection__c='Selected', ParcSelection__c='Selected', GAMSSelection__c='Selected'));
        WorkRequestForm__c wrf4 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c='Aftermarket', WorldviewVIO__c=true,ParcDataFiles__c=true , DataExtractGlobalVIOParc__c=true, Internal__c = false,
                                                                             TimePeriodsAftermarket__c='Custom Selection (Use Textbox)', TimePeriodDescription__c=null, CustomYearCoverage__c=true, Periodicity__c='Other',
                                                                             ForecastYears__c='Other', CustomGeography__c=true, VehicleSegmentation__c = 'Other', AgeClasses__c='Custom Age Classes'));
        WorkRequestForm__c wrf5 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'Aftermarket' , Internal__c = false, Mapping__c = false, DataExtractGlobalVIOPARC__c = false, 
                                                                             CustomYearCoverage__c=true, Periodicity__c='Other', ForecastYears__c='Other',
                                                                             CustomGeography__c=true, VehicleSegmentation__c='Other', 
                                                                             AgeClasses__c='Custom Age Classes'));
        WorkRequestForm__c wrf6 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'Analytics' , Internal__c = false, ModelSegmentation__c = true, Loyalty__c = true, Profile__c = true ));
        WorkRequestForm__c wrf7 = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'Analytics' , Internal__c = false, ModelSegmentation__c = true, Loyalty__c = false, Profile__c = true));
        
        
        Id i = WRFUtility.returnWRFOwnerId(wrf1,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('PolkConnect Analytics'), wrf1.ownerId);
        
        i = WRFUtility.returnWRFOwnerId(wrf2,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('PolkConnect System'), wrf2.ownerId);
        
        i = WRFUtility.returnWRFOwnerId(wrf3,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('Jeff Allen'), wrf3.ownerId);
        
        i = WRFUtility.returnWRFOwnerId(wrf4,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('European WRF'), wrf4.ownerId);
        
        i = WRFUtility.returnWRFOwnerId(wrf5,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('Market Reporting - CAP'), wrf5.ownerId);
        
        i = WRFUtility.returnWRFOwnerId(wrf6,mapofUsers,queueMAP,mapOfOwnerAssignment);
        System.assertEquals(queueMap.get('Market Reporting - Loyalty'), wrf6.ownerId);
        
        i = WRFUtility.returnWRFOwnerId(wrf7,mapofUsers,queueMAP,mapOfOwnerAssignment);
        
        WRFUtility.getRequestTypes();
        Test.StopTest();
    }
}