/*  @author: Akash Punera
*   @date: 9 Jun 2022
*   @description: Test class for WorkRequestFormCountryHelper
*/
@isTest(SeeAllData=false)
private class TestWorkRequestFormCountryHelper {
    static WorkRequestForm__c wrf;
    @testSetup static void generateTestData() {
        Account acc = TestUtility.createTestAccount('TestAccount', true);
        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Oppy', true); 

        wrf = TestUtility.newWRF(new WorkRequestForm__c (FormType__c = 'APAC', Internal__c = false, RequestStatus__c = 'Draft', JobType__c ='Adhoc', WorldviewVIO__c = true,
                                                                            RoyaltyVendor__c = 'No Royalty Data', OpportunityName__c = testOpportunity.id, ReturnToSales__c = true,
                                                                            RequestedDueDate__c = System.today(),OutputType__c = 'Access',OutputMedium__c = 'Online System Access', 
                                                                            WorldViewSystemDataSet__c = 'WorldView OE Parts Research',
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
        
        CountrySelection__c cs = new CountrySelection__c(Geography__c = 'National', Country__c = 'Algeria', VehicleType__c = 'CARS;HCV;LCV', ISOCode__c = '000');
        cs.WorkRequestForm__c = wrf.Id;
        cs.DataType__c = 'Global VIO';
        cs.RequestType__c = 'Data Extract Global VIO (PARC)';
        insert cs;

        CountryOption__c co = new countryOption__c(RequestType__c = 'Data Extract Global VIO (PARC)');
        insert co;
    }
    @isTest
    private static void testGetCountryOptions() {
        Test.startTest();
        generateTestData();
        try{
            WorkRequestFormCountryHelper.getWRFRecordWithRequestTypes('');
        }catch(exception ex) {
            system.debug(ex.getMessage());
        }
        WorkRequestFormCountryHelper.getRequestType(wrf.id);
        WorkRequestFormCountryHelper.getCountryOptions('Data Extract Global VIO (PARC)','Global VIO',new list<CountrySelection__c>());
        List<CountryOption__c> objCo = WorkRequestFormCountryHelper.getCountryOptions('Data Extract Global VIO (PARC)','',new list<CountrySelection__c>());
        system.assert(objCo.size() > 0,'Country Option not found');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetCountrySelections() {
        Test.startTest();
        generateTestData();
        WorkRequestFormCountryHelper.getCountrySelectionsByDataType(wrf.id,'Global VIO','Data Extract Global VIO (PARC)');
        List<countrySelection__c> objCS = WorkRequestFormCountryHelper.getCountrySelections(wrf.id,'Data Extract Global VIO (PARC)');
        system.assert(objCS.size() > 0,'County selection record not found');
        Test.stopTest();
    }

    @isTest
    private static void testupsertCountrySelections() {
        Test.startTest();
        generateTestData();
        list<CountrySelection__c> listCS = new List<CountrySelection__c>();
        listCS = [SELECT id, Comments__c,RequestType__c,datatype__c, country__c,geography__c, VehicleType__c  FROM countrySelection__c];
        WorkRequestFormCountryHelper.getMapCountrySelections(listCS,listCS);
        WorkRequestFormCountryHelper.getMapCountrySelections(listCS,new list<countrySelection__c>());
        List<CountrySelection__c> listUpsert = WorkRequestFormCountryHelper.upsertCountrySelections(listCS,wrf.id,'Global VIO','Data Extract Global VIO (PARC)');
        List<CountryOption__c> listCO = WorkRequestFormCountryHelper.getDataTypes('Data Extract Global VIO (PARC)');
        system.assert(listCO.size() > 0, 'Country option not found');
        Test.stopTest();
    }
}