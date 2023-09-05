//@author : Sharique Iqbal
//@date: 25 Feb 2021
//@description : SFDC- 3918- Fetch the opportunity Products which are at Risk
//@company : IHS Markit
//@param : String
//@return : String

public with sharing class OpportunityProductRiskController  {

 @AuraEnabled(cacheable=true)
 public static String getRiskProductName (String oppyId) {
      
      Integer count = 0;
      String riskyProductNames = '';  
      for (OpportunityLineItem oli : [SELECT Id, Product2.Name 
                                      FROM OpportunityLineItem
                                      WHERE OpportunityId = :oppyId AND IsProductatRisk__c = 'Yes' AND Status__c = 'Existing' AND RiskStatus__c = 'Open - Pending Resolution'
                                      ORDER By EstimatedValueatRisk__c desc]) {
          if (count < 3) {
            riskyProductNames = riskyProductNames +', '+ oli.Product2.Name;
          }
          count++;          
      } 
      
      if (count > 3) {
         riskyProductNames = riskyProductNames.substring(1) +' and +'+ (count-3)+' are';
      } else {      
         riskyProductNames = count != 0 ? (count == 1 ? riskyProductNames.substring(1)+' is' : riskyProductNames.substring(1)+' are') : '';      
      }
      system.debug('@@ return value--'+riskyProductNames);
      return riskyProductNames;
    }
}