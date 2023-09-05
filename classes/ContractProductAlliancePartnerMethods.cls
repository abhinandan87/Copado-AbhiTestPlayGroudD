//-----------------------------
// @author: Akshay Dogra
// @date: 30 July 2021
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
//-----------------------------
public class ContractProductAlliancePartnerMethods {
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 30 July 2021
    // @param: TriggerParameters tp
    // @description: SFDC-4235: Alliances Validation Tracking - method to restrict duplicate record insertion
    // @return: NA
    //------------------------------
    public static void restrictDuplicateRecord(TriggerParameters tp) {
        List<ContractProductAlliancePartner__c> cPAPList = new List<ContractProductAlliancePartner__c>();
        Set<String> newKeySet = new Set<String>();
        Set<String> existingKeySet = new Set<String>();
        if (Trigger.isBefore && ( Trigger.isInsert || Trigger.isUpdate )) {
            cPAPList = Trigger.New;
        } 
        if ( Trigger.IsAfter && Trigger.isUndelete ) {
            cPAPList = Trigger.New;
        }
        for ( ContractProductAlliancePartner__c con : cPAPList ) {
            if ( con.AlliancePartnerKey__c != null ) {
                newKeySet.add(con.AlliancePartnerKey__c);
            }
        }
        List<ContractProductAlliancePartner__c> existingCPAPList = [Select Id, AlliancePartnerKey__c From ContractProductAlliancePartner__c 
                                                                    Where AlliancePartnerKey__c IN: newKeySet AND AlliancePartnerKey__c != null];
        
        for (ContractProductAlliancePartner__c con : existingCPAPList ) {
            existingKeySet.add(con.AlliancePartnerKey__c);
        }
        for ( ContractProductAlliancePartner__c con : cPAPList ) {
            if ( existingKeySet.contains( con.AlliancePartnerKey__c ) ) {
                con.AlliancePartner__c.addError(' A duplicate record for this alliance partner already exist. Please choose a different alliance partner or edit the already existing record. ');
            } else {
                existingKeySet.add(con.AlliancePartnerKey__c);
            }
        }
    }
}