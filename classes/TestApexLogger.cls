@isTest(seeAllData=false)
public  class TestApexLogger {
    public TestApexLogger() {

    }
    
    @isTest
    static void testApexLogger() {
        // Test data setup
        TestUtility.loadCountryData();
        Account acct = TestUtility.createTestAccount('Test Account for Logger', true);
        Test.StartTest();
        try {
             throw new TriggerException('Test Exception to be caught');
        }Catch(Exception ex) {
            try {
                ApexLogger.logError(new LogMessage('TestApexLogger','testApexLogger',ex));
                ApexLogger.logandthrowError(new LogMessage('TestApexLogger','testApexLogger',ex,acct,'Test Error'));
            }Catch(Exception exc) {
				system.assertEquals('Test Error', exc.getMessage(), 'Exception will occur and error thrown');
            }
        }
        List<ApexLogger__c> lstapexLogger=[Select Id from ApexLogger__c where className__c='TestApexLogger'];
        System.assertNotEquals(null,lstapexLogger,'No record found in Apex Logger.');
        Test.StopTest();

    }
    
	@isTest
    static void testApexLogger2() {
        // Test data setup
        TestUtility.loadCountryData();
        Account acct = TestUtility.createTestAccount('Test Account for Logger', true);
        Test.StartTest();
        try {
             throw new TriggerException('Test Exception to be caught');
        }Catch(Exception ex) {
           ApexLogger.logandAddError(new LogMessage('TestApexLogger','testApexLogger',ex,acct,'Test Message'));
           
        }
        List<ApexLogger__c> lstapexLogger=[Select Id from ApexLogger__c where className__c='TestApexLogger'];
        System.assertNotEquals(null,lstapexLogger,'No record found in Apex Logger.');
        Test.StopTest();

    }


}