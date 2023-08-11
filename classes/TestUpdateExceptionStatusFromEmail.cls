/**
 * @CreatedBy: Manish Kumar
 * @CreatedDate : 31st March 2022
 * @Description: SFDC-5500 Test Class for UpdateExceptionStatusFromEmail
 */
@istest
public class TestUpdateExceptionStatusFromEmail {
    
   @isTest static void TestinBoundEmail() {
       test.startTest();
       Account acc = TestUtility.createTestAccount('Test Account for Product Selection', true);
       LegalEntity__c leUS = TestUtility.createLegalEntity('Markit Group Limited US', 'USD');
       Integer currentFY = UtilityClass.calculateFyFromDate(Date.Today(), UtilityClass.FiscalStartMonth);
       Country__c countryUS = New Country__c();
       countryUS.Name = 'United States';
       countryUS.CountryCode__c = 'US';
       countryUS.Geography__c = 'United States';
       countryUS.Region__c = 'Americas';
       insert countryUS;
       
       id newBusinessRecTypeId = UtilityClass.getObjectRecordTypeId('Opportunity','New Business');
       Opportunity oppyUS1 = TestUtility.createOpportunity(acc.Id, 'Test Opportunity for US', false);
       oppyUS1.RecordTypeId = newBusinessRecTypeId;
       oppyUS1.ExceptionStatus__c = 'Exception Requested';
       oppyUS1.RequestedLegalEntity__c = leUS.Id;
       oppyUS1.CurrencyIsoCode = 'USD';
       oppyUS1.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
       oppyUS1.OpportunityCountry__c = countryUS.Id;
       insert oppyUS1;
       
       Opportunity oppyUS2 = TestUtility.createOpportunity(acc.Id, 'Test Opportunity for US', false);
       oppyUS2.RecordTypeId = newBusinessRecTypeId;
       oppyUS2.ExceptionStatus__c = 'Exception Requested';
       oppyUS2.RequestedLegalEntity__c = leUS.Id;
       oppyUS2.CurrencyIsoCode = 'USD';
       oppyUS2.ContractStartDate__c = date.newinstance(currentFY, 03,21 );
       oppyUS2.OpportunityCountry__c = countryUS.Id;
       insert oppyUS2;
       
       Messaging.InboundEmail email1 = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env1 = new Messaging.InboundEnvelope();
       email1.subject = 'Opportunity ' + oppyUS1.Id + ' has been Approved';
       email1.fromAddress = 'someaddress@email.com';
       email1.plainTextBody = 'Approved';
       UpdateExceptionStatusFromEmail emailObj1 = New UpdateExceptionStatusFromEmail();
       Messaging.InboundEmailResult result1 = emailObj1.handleInboundEmail(email1, env1);
       System.assertEquals(true, result1.success, 'result should be true');
       
       Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();
       email2.subject = 'Opportunity ' + oppyUS2.Id + ' has been Rejected';
       email2.fromAddress = 'someaddress@email.com';
       email2.plainTextBody = 'Rejected';
       UpdateExceptionStatusFromEmail emailObj2 = New UpdateExceptionStatusFromEmail();
       Messaging.InboundEmailResult result2 = emailObj2.handleInboundEmail(email2, env2);
       System.assertEquals(true, result2.success, 'result should be true');
       test.stopTest();
   }
}