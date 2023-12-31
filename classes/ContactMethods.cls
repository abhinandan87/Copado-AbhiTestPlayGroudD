//*********************************************************************************************************************
// @author Paras Dhingra adapted from Tran's code
// @date 26th June 2017
// @description SFDC1-402 Class created to add common methods to be used by Contact trigger handler classes
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 21 Aug 2018
// @Last Modified Description : SFDC1-8620 Resolving Apex security Risk - CRUD delete, adding isDeleteable() before delete operation
// @Last Modified Company : VERTIBA
//*********************************************************************************************************************

public class ContactMethods {
   
    /**
     * @author Tran-Vu Tran
     * @date 26th June 2017
     * description SFDC1-402 Update Contact Country lookup after MailingCountry value is added/changed
     * Lastmodifiedby : Mohit Modi, Removed the Query as it is not required, Also this method Needs to be in Before Insert and Before Update Trigger ONLY
     */
    public static void updateCountryLookup(TriggerParameters tp) {
        
        //As standard State and Country picklists are enabled, MailingCountry's new value is available in after triggers only
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
            tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            
           // Get all contacts in this trigger //
           // List<Contact> contacts = [SELECT Id, MailingCountry, MailingCountryCode, ContactCountry__c FROM Contact WHERE Id IN :tp.newList];
        
           // Processing contacts in this trigger
           List<Contact> contactsToUpdate = new List<Contact>();
           for (Contact c:(list<Contact>)tp.newList) {
                // Getting pre-update version of the contact object
                Contact oldContact;
                if (tp.oldMap != null && tp.oldMap.get(c.Id) != null) {
                    oldContact = (Contact)tp.oldMap.get(c.Id);
                }
                
                // If MailingCountry value changes
                if (tp.oldMap == null || tp.oldMap.get(c.Id) == null || oldContact.MailingCountryCode != c.MailingCountryCode) {
                    
                    // Country__c country = UtilityClass.getCountry(c.MailingCountry);

                    //2017-09-13 Tran-Vu Tran: change the logic to get Country by Country Code
                    Country__c country = UtilityClass.getCountryByIsoCode(c.MailingCountryCode);
                        
                    if (country != null) {
                        c.ContactCountry__c = country.Id;
                        System.debug('Contact Country' + c.ContactCountry__c);
                        contactsToUpdate.add(c);
                    }
                }
            }
        } 
    }

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-2299 Whenever a contact is created, whether manually by a user or through an integration/data migration, 
    //              an "Additional Contact Fields" record is automatically created and a link to this record is populated in the contact record.
    //              This field should not be editable by anyone except System Admin. This function creates an AdditionalContactFields record.
    // @return: None
    // @modified by : Paras Dhingra
    // @modified date: 07-09-2018
    // @description: Modified to accomodate migration changes and sync legacy fields with additional contact fields 
    //------------------------------
    public static void setAdditionalContactFieldsObject(TriggerParameters tp) {
        
        try {
        
            // List of Additional Contact Fields thats needs to be inserted 
            List<AdditionalContactFields__c> additionalContactFieldsToInsert = new List<AdditionalContactFields__c>();
            
            // Map of old values and new values
            Map<Id,Contact> mapNewContact = (Map<Id,Contact>) tp.newMap;
            Map<Id,Contact> mapOldContact = (Map<Id,Contact>) tp.oldMap;
            
            for(Contact newContact: mapNewContact.values()) {
                
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                    if(newContact.AdditionalContactFields__c == null) {
                        String additionalContactName = ('Additional Fields - ' + newContact.FirstName + ' ' + newContact.LastName).left(80);   
                        AdditionalContactFields__c acf = new AdditionalContactFields__c(Name = additionalContactName,
                                                                                        ContactReference__c = newContact.Id,
                                                                                        LegacyID__c= newContact.LegacyID__c,
                                                                                        LegacyIDUnique__c = newContact.LegacyIDUnique__c,
                                                                                        LegacySystem__c = newContact.LegacySystem__c);
                        additionalContactFieldsToInsert.add(acf);  
                    }
                }
            }
            
            // insert if the list has any records
            if(additionalContactFieldsToInsert != null && additionalContactFieldsToInsert.size() > 0) {
                System.debug('additionalContactFieldsToInsert.Size()=' + additionalContactFieldsToInsert.Size());
                insert additionalContactFieldsToInsert;
            }
            
        } catch(Exception ex) {
                //this will happen if any exception apart from DML exception has occurred
                UtilityClass.createApexLogRecord(ex, 'ContactMethods', 'setAdditionalContactFieldsObject');
        }
    }

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-2299 Whenever a contact is created, whether manually by a user or through an integration/data migration, 
    //              an "Additional Contact Fields" record is automatically created and a link to this record is populated in the contact record.
    //              This field should not be editable by anyone except System Admin. This function changes AdditionalContactFields object's Name when Contact's Name changes.
    // @return: None
    // @modified by : Paras Dhingra
    // @modified date: 07-09-2018
    // @description: Modified to accomodate migration changes and sync legacy fields with additional contact fields 
    //------------------------------
    public static void changeAdditionalContactFieldsObjectNameWhenContactFieldChanges(TriggerParameters tp) {

        try {
        
            // List of Additional Contact Fields thats needs to be inserted 
            List<AdditionalContactFields__c> additionalContactFieldsToUpdate = new List<AdditionalContactFields__c>();
            
            // Map of old values and new values
            Map<Id,Contact> mapNewContact = (Map<Id,Contact>) tp.newMap;
            Map<Id,Contact> mapOldContact = (Map<Id,Contact>) tp.oldMap;
            
            for(Contact newContact: mapNewContact.values()) {
                    
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    Contact oldContact = mapOldContact.get(newContact.Id);
                    if(newContact.AdditionalContactFields__c != null 
                       && (newContact.FirstName != oldContact.FirstName || newContact.LastName != oldContact.LastName ||
                          newContact.LegacyID__c != oldContact.LegacyID__c|| newContact.LegacyIDUnique__c != oldContact.LegacyIDUnique__c || newContact.LegacySystem__c != oldContact.LegacySystem__c)) {
                           String additionalContactName = ('Additional Fields - ' + newContact.FirstName + ' ' + newContact.LastName).left(80);
                           AdditionalContactFields__c acf = new AdditionalContactFields__c(Name = additionalContactName,
                                                                                           Id = newContact.AdditionalContactFields__c,
                                                                                           LegacyID__c= newContact.LegacyID__c,
                                                                                           LegacyIDUnique__c = newContact.LegacyIDUnique__c,
                                                                                           LegacySystem__c = newContact.LegacySystem__c);
                           additionalContactFieldsToUpdate.add(acf);  
                    }
                }
            }
            
            // update if the list has any records
            if(additionalContactFieldsToUpdate != null && additionalContactFieldsToUpdate.size() > 0) {
                update additionalContactFieldsToUpdate;
            }
            
        } catch(Exception ex) {
                //this will happen if any exception apart from DML exception has occurred
                UtilityClass.createApexLogRecord(ex, 'ContactMethods', 'changeAdditionalContactFieldsObjectNameWhenContactNameChanges');
              
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 25 Sep 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-2299 Whenever a contact is created, whether manually by a user or through an integration/data migration, 
    //              an "Additional Contact Fields" record is automatically created and a link to this record is populated in the contact record.
    //              This field should not be editable by anyone except System Admin. This function deletes AdditionalContactFields record before deleting a Contact.
    // @return: None
    //------------------------------
    public static void deleteAdditionalContactFieldsRecordWhenContactGetsDeleted(TriggerParameters tp) {

        try {
        
            // List of Additional Contact Fields thats needs to be inserted 
            List<AdditionalContactFields__c> additionalContactFieldsToDelete = new List<AdditionalContactFields__c>();
            
            // Map of old values 
            Map<Id,Contact> mapOldContact = (Map<Id,Contact>) tp.oldMap;
            
            for(Contact oldContact: mapOldContact.values()) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.beforeDelete) {
                    additionalContactFieldsToDelete.add(new AdditionalContactFields__c(Id = oldContact.AdditionalContactFields__c));  
                }
            }
            
            // delete if the list has any records
            if(additionalContactFieldsToDelete != null && additionalContactFieldsToDelete.size() > 0 && AdditionalContactFields__c.sObjectType.getDescribe().isDeletable()) {
                delete additionalContactFieldsToDelete;
            }
            
        } catch(Exception ex) {
                //this will happen if any exception apart from DML exception has occurred
                UtilityClass.createApexLogRecord(ex, 'ContactMethods', 'deleteAdditionalContactFieldsRecordWhenContactGetsDeleted');
              
        }
    }
    
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary Andra
    // @date: 18 Dec 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-10703 When a contact is created, or email is changed then, verify for existing Product Login and product Login contact Association
    // 			If product login exists, but there is no product login contact association then create one. Can email be same for 2 contacts?5
    // @return: None
    //------------------------------
    public static void createPLCAWhenProductLoginExistsForEmail (TriggerParameters tp) {
        try {
            Map<Id,Contact> mapOldContact = (Map<Id,Contact>) tp.oldMap;
            Map<String,Id> emailAddressContactIdMap = new Map<String,Id>();
            
            for (Contact newContact: (List <Contact>)tp.newList) {
                Contact oldContact = new Contact();
                if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldContact = mapOldContact.get(newContact.Id);
                }
                if(newContact.Email != null && newContact.Email != oldContact.Email) { 
                    emailAddressContactIdMap.put(newContact.Email, newContact.Id);
                }
            }
            if (!emailAddressContactIdMap.isEmpty()) {
                List<ProductLoginContactAssociation__C> plcaList = new List<ProductLoginContactAssociation__c>();
                for(ProductLogin__c productLogin : [select id, email__c, 
                                                    (select contact__c from ProductLoginContactAssociations1__r ) 
                                                 from ProductLogin__c where email__c in :emailAddressContactIdMap.keySet()]) {
                    //for sure contact will not be null, so not checking for null
                    Id contactId = emailAddressContactIdMap.get(productLogin.Email__c);
                    boolean matchFound = false;
                    for(ProductLoginContactAssociation__c plca : productLogin.ProductLoginContactAssociations1__r) {
                        //go through each plca and check for contact, if match is not found then create a new PLCA record, else continue
                        if(plca.Contact__c == contactId) {
                            matchFound = true;
                            break;
                        }
                    }
                    if (!matchFound) {
                        ProductLoginContactAssociation__c plca = new ProductLoginContactAssociation__c();
                        plca.ProductLogin__c = productLogin.Id;
                        plca.Contact__c = contactId;
                        plcaList.add(plca);
                    }
                }
                if (!plcaList.isEmpty()) {
                    insert plcaList;
                }
            }
        } catch (Exception e) {
            UtilityClass.createApexLogRecord(e, 'ContactMethods', 'createPLCAWhenProductLoginExistsForEmail');
        }
    }
}