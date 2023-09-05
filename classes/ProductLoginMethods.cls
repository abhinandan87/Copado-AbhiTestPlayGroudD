//-----------------------------
// @author: Uttam Arya
// @date: 13 April 2018
// @param: NA
// @description: Class to hold Product Login Fields trigger methods 
// @return: NA
//-----------------------------

public class ProductLoginMethods {
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 13 April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6347 Whenever an Product Login is created, whether through an integration/data migration or manually by a user an "Additional Product Login Fields" 
    //                          record belonging to the Product Login is automatically created and a link to the record is populated in the "Additional Product Login Fields" field on the Product Login record. 
    //                          This field should not be editable by anyone excluding the System Admin.
    //                          This function create an Additional User Fields lookup related to an Product Login.
    // 
    // @return: None
    //------------------------------
    public static void setProductLoginAdditionalFieldsObject(TriggerParameters tp) {
        
        try {
            
            // List of Additional Product Login Fields thats needs to be inserted 
            List<AdditionalProductLoginFields__c> additionalProductLoginFieldsToInsert = new List<AdditionalProductLoginFields__c>();
            
            // Map of old values and new values
            Map<Id,ProductLogin__c> mapNewProductLogin = (Map<Id,ProductLogin__c>) tp.newMap;
            Map<Id,ProductLogin__c> mapOldProductLogin = (Map<Id,ProductLogin__c>) tp.oldMap;
            
            for(ProductLogin__c newProductLogin: mapNewProductLogin.values()) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                    if(newProductLogin.AdditionalProductLoginFields__c == null) {
                        additionalProductLoginFieldsToInsert.add(new AdditionalProductLoginFields__c(Name = newProductLogin.Username__c, Username__c = newProductLogin.Username__c, 
                                                        ProductLogin__c = newProductLogin.Id, LegacyID__c = newProductLogin.LegacyID__c));  
                    }
                }
            }
            
            // insert if list has any records
            if(additionalProductLoginFieldsToInsert != null && additionalProductLoginFieldsToInsert.size() > 0) {
                insert additionalProductLoginFieldsToInsert;
            }
            
        } catch(Exception ex) {
            //this will happen if any exception apart from DML exception has occurred
            //UtilityClass.createApexLogRecord(ex, 'ProductLoginMethods', 'setProductLoginAdditionalFieldsObject');
            ApexLogger.logError(new LogMessage('ProductLoginMethods','setProductLoginAdditionalFieldsObject',ex,tp.newList.get(0),null ));
        }
    }
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 13 April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6347 Whenever an Product Login is created, whether through an integration/data migration or manually created by a user an "Additional Product Login Fields" 
    //                          record belonging to the Product Login is automatically created and a link to the record is populated in the "Additional Product Login Fields" field. 
    //                          This function populate the Additional Fields lookup in Product Login.
    //                          This function change Account User Additional Fields Object Name When username changes in Product Login Object
    // 
    // @return: None
    //------------------------------
    public static void changeProductLoginAdditionalFieldsObjectNameWhenUsernameChanges(TriggerParameters tp) {
        
        try {
            
            // List of Additional Product Login Fields thats needs to be updated 
            List<AdditionalProductLoginFields__c> additionalProductLoginFieldsToUpdate = new List<AdditionalProductLoginFields__c>();
            
            // Map of old values and new values
            Map<Id,ProductLogin__c> mapNewProductLogin = (Map<Id,ProductLogin__c>) tp.newMap;
            Map<Id,ProductLogin__c> mapOldProductLogin = (Map<Id,ProductLogin__c>) tp.oldMap;
            
            for(ProductLogin__c newProductLogin: mapNewProductLogin.values()) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    if(newProductLogin.AdditionalProductLoginFields__c != null && newProductLogin.Username__c != mapOldProductLogin.get(newProductLogin.Id).Username__c) {
                        additionalProductLoginFieldsToUpdate.add(new AdditionalProductLoginFields__c(Name = newProductLogin.Username__c, Username__c = newProductLogin.Username__c, Id = newProductLogin.AdditionalProductLoginFields__c));
                    }
                }
            }
            
            // insert if list has any records
            if(additionalProductLoginFieldsToUpdate != null && additionalProductLoginFieldsToUpdate.size() > 0) {
                update additionalProductLoginFieldsToUpdate;
            }
            
        } catch(Exception ex) {
            //this will happen if any exception apart from DML exception has occurred
            //UtilityClass.createApexLogRecord(ex, 'ProductLoginMethods', 'changeProductLoginAdditionalFieldsObjectNameWhenUsernameChanges');
        	ApexLogger.logError(new LogMessage('ProductLoginMethods','changeProductLoginAdditionalFieldsObjectNameWhenUsernameChanges',ex,tp.newList.get(0),null ));
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 06 Aug 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-9572 Whenever Changes to Product Login email trigger relinking to Contact Record via (Product Login Contact Association)
    // If the Email Changes has contact exists in DB then it creates the Product Login Contact Association,
    // If the Email Changes has contact NOT exists in DB then it first create Contact and then creates the Product Login Contact Association
    // @lastModifiedBy: Vishnu Vardhan Chowdary
    // @lastModifiedDate: 11 Dec 2018
    // @LastModifiedDescription: SFDC1-10703, Earlier this method was called only when Product login is updated with different email. 
    // 		Now we are calling it when product login is created. 
    // @lastModifiedBy: Vishnu Vardhan Chowdary
    // @lastModifiedDate: 17 Dec 2018
    // @LastModifiedDescription: SFDC1-10703, Removing the Contact creation logic and changing the methods name.
    // @return: None
    //------------------------------
    public static void insertPLContactAssociation(TriggerParameters tp) {
        try {
            // Map of old values and new values
            Map<Id,ProductLogin__c> mapNewProductLogin = (Map<Id,ProductLogin__c>) tp.newMap;
            Map<Id,ProductLogin__c> mapOldProductLogin = (Map<Id,ProductLogin__c>) tp.oldMap;
            Map<String,Contact> emailContactMap = new Map<String,Contact>();
            Map<String,ProductLoginContactAssociation__c> associationMap = new Map<String,ProductLoginContactAssociation__c>();
            Set<Id> emailChangeprodLoginIds = new Set<Id>();
            Set<String> emailChangeSet = new Set<String>();
            
            for(ProductLogin__c newProductLogin: mapNewProductLogin.values()) {
                ProductLogin__c oldProductLogin = new ProductLogin__c();
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldProductLogin = mapOldProductLogin.get(newProductLogin.Id);
                }
                if(newProductLogin.Email__c != null && newProductLogin.Email__c != oldProductLogin.Email__c) {
                    emailChangeprodLoginIds.add(newProductLogin.Id);
                    emailChangeSet.add(newProductLogin.Email__c);
                }
            }
            if(emailChangeprodLoginIds.size() > 0) {
                //Check whether updated Email Address has Contact exists in DB or not
                for(Contact con : [SELECT Id,Email,lastName from Contact where Email IN : emailChangeSet]) {
                    emailContactMap.put(con.Email,con);
                }
                //For Email Update Product Login's Loop through to Validate PLContactAsociation
                //Check If Updated Email Address Contact existis in DB then
                //   Check Product Login and Contact has PLContactAsociation exists or not,If not exists will 
                //   insert PLContactAsociation.
                List<ProductLogin__c> productloginList = [SELECT Id,Email__c,FirstName__c,LastName__c,
                                                          (SELECT Contact__c,ProductLogin__c FROM ProductLoginContactAssociations1__r) 
                                                          FROM ProductLogin__c WHERE ID IN : emailChangeprodLoginIds];
                for(ProductLogin__c login : productloginList) {
                    if(emailContactMap.get(login.Email__c) != null) { //Contact exists for the Email
                        checkPLContactAssociation(login, emailContactMap, associationMap);
                        System.debug('--------associationMap---------****'+associationMap);
                    } 
                }
            }
            System.debug('-----final associationMap ---'+associationMap);
            if(associationMap.size() > 0) {
                insert associationMap.values();
            }
        } catch(Exception ex) {
            //this will happen if any exception apart from DML exception has occurred
            //UtilityClass.createApexLogRecord(ex, 'ProductLoginMethods', 'insertPLContactAssociationWhenEmailChanges');
        	ApexLogger.logError(new LogMessage('ProductLoginMethods','insertPLContactAssociationWhenEmailChanges',ex,tp.newList.get(0),null ));
        }
    }
    
    //Check for Product login and Contact association exists or not.
    private static void checkPLContactAssociation(ProductLogin__c login, Map<String,Contact> emailContactMap, Map<String,ProductLoginContactAssociation__c> associationMap) {
        boolean existsAsso = false;
        if(login.ProductLoginContactAssociations1__r != null && login.ProductLoginContactAssociations1__r.size() > 0) {
            for(ProductLoginContactAssociation__c plcAsso : login.ProductLoginContactAssociations1__r) {
                if(login.Id == plcAsso.ProductLogin__c && emailContactMap.get(login.Email__c).Id == plcAsso.Contact__c) {
                    existsAsso = true;
                }  
            }
        }
        if(!existsAsso) {
            ProductLoginContactAssociation__c lcAsso = new ProductLoginContactAssociation__c();
            lcAsso.ProductLogin__c = login.Id;
            lcAsso.Contact__c = emailContactMap.get(login.Email__c).Id;
            String key = login.Id + ':' + emailContactMap.get(login.Email__c).Id;
            associationMap.put(key,lcAsso);
        }
    }
}