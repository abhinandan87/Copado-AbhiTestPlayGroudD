//-----------------------------
// @author: Akshay Dogra
// @date: 29 Aug 2021
// @description: SFDC-4235: Alliance Validation
// @companyname : IHS Markit
//-----------------------------
public class multiSelectPicklist {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getProductGroup(String contractId) {
        List<String> ProductGroupName = new List<String>();
        Set<String> mySet = new Set<String>();
        List<ContractLineItem__c> productGroupValue = [SELECT ProductGroup__c from ContractLineItem__c Where Contract__c =: contractId ];
        for(ContractLineItem__c CLI : productGroupValue) {
            if(String.isNotBlank(CLI.ProductGroup__c)) {
                mySet.add(CLI.ProductGroup__c);
            }
        }
        ProductGroupName.addAll(myset);
        ProductGroupName.sort();
        return ProductGroupName;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getProductGroupAlliance(String Id) {
        
        List<String> ProductGroupName = new List<String>();
        
        List<ContractProductAlliancePartner__c> productGroupValue = [SELECT ProductGroupText__c from ContractProductAlliancePartner__c Where Id =: Id ];
        for(String str : productGroupValue[0].ProductGroupText__c.split(',')) {
            ProductGroupName.add(str);
        }
        ProductGroupName.sort();
        return ProductGroupName;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getProductGroupAll(String allianceId) {
        List<String> ProductGroupName = new List<String>(); 
        List<String> Contract = new List<String>();
        
        List<ContractProductAlliancePartner__c> contractId = [SELECT contract__c from ContractProductAlliancePartner__c Where Id =: allianceId ];
        for(ContractProductAlliancePartner__c CPAId : contractId) {
            Contract.add(CPAId.contract__c);
        }
        
        List<ContractLineItem__c> productGroupValue = [SELECT ProductGroup__c from ContractLineItem__c Where Contract__c =: Contract ];
        
        for(ContractLineItem__c CLI : productGroupValue) {
            if(String.isNotBlank(CLI.ProductGroup__c)) {
                ProductGroupName.add(CLI.ProductGroup__c);
            }
        }
        ProductGroupName.sort();
        return ProductGroupName;
    }
    @AuraEnabled
    public static Boolean getProfile() {
        Boolean profileBoolean = false;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        if ( profileName.contains('Admin') ) { 
            profileBoolean = true;
        }
        else if (profileName.contains('General') ) {
            profileBoolean = true;
        }
        else if (profileName.contains('IHSMarkit Customer Care') ) {
            profileBoolean = true;
        }
        else {
            profileBoolean = false;
        }
        system.debug('ProfileName'+profileBoolean);
        return profileBoolean;
    }
}