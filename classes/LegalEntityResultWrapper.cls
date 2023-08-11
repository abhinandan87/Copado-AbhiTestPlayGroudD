public with sharing class LegalEntityResultWrapper {
    @AuraEnabled public String result;
    @AuraEnabled public String recommendedLegalEntity;
    @AuraEnabled public String errorMessage;
    @AuraEnabled public List<LegalEntity__c> lstRecommendedLegalEntity;
}