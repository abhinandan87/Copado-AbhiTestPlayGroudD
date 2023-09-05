@isTest
public class CreateAndUpdateCustomMetadataTypesTest {
    
      public static testMethod void TestCustomMetaDataTypes(){
          Test.startTest();
              string body='{"totalSize":4,"done":true,"records":[{"attributes":{"type":"Division_Settings__mdt","url":"/services/data/v51.0/sobjects/Division_Settings__mdt/m016s0000004DNRAA2"},"Id":"m016s0000004DNRAA2","DeveloperName":"Indices","Label":"Indices","Active__c":true,"Opportunity_Amount_Field__c":"Amount"}]}';
              AccountLandingPageMock mockClass1 = new AccountLandingPageMock(body, 200);
              Test.setMock(HttpCalloutMock.class, mockClass1);
              CreateAndUpdateCustomMetadataTypes scheUpdateAccount = new CreateAndUpdateCustomMetadataTypes();
              String sch = '0 48 * * * ?';
              System.schedule('Schedule to update custom meta Name', sch, scheUpdateAccount);
          Test.stopTest();
    }  

}