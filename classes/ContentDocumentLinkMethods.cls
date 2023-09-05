//-----------------------------
// @author: Uttam Arya
// @date: 29 Aug 2017
// @param: NA
// @description: SFDC1-2243 Class to hold ContentDocumentLink trigger methods 
// @return: NA
//-----------------------------
public class ContentDocumentLinkMethods {

   public static Set <Id> setContractAttId = new Set <Id>();
//-----------------------------
// @author: Uttam Arya
// @date: 22 Aug 2017
// @param: TriggerParameters tp
// @description: SFDC1-2243 Whenever an ContentDocumentLink is added to an opportunity,  
//                  MISContentDocumentLinkAdded field is auto populated with the current timestamp. 
//                  This is used for MIS pipeline reporting.
//
// @return: None
// @Modifiedby: Mohit Modi
// @Modified Description: 06 Nov 2017 : Added the logic to capture the attahment added on Opportunity Attachment as well.
// @Modified by: Paras Dhingra
// @Modified date: 16 July 2019
// @Modified description: Adding bypass to avoid firing auto-renewal validations on insert of opportunity attachment
//------------------------------
    public static void populateMISAttachmentAddedInOpportunityWhenAttachmentIsInsertedInLightning(TriggerParameters tp) {
    
        //List of Opportunity that needs to be updated    
        list <Opportunity > OpportunityToUpdate = new list<Opportunity>(); 
        set<id> setOpportunityAttId = new set<id>();
        
        String OppAttachmentkeyPrefix = UtilityClass.getObjectKeyPrefix('OpportunityAttachment__c');
        set<id> setOpportunityId = new set<id>();
        
        for(ContentDocumentLink ContentDocumentLink: (List <ContentDocumentLink>) tp.newList) {
            if(ContentDocumentLink.LinkedEntityId != null && String.valueOf(ContentDocumentLink.LinkedEntityId).startsWith('006')) {
                setOpportunityId.add(ContentDocumentLink.LinkedEntityId);
            }
            // Checking if attachment is added to Opportunity Attachment Record.
            if(ContentDocumentLink.LinkedEntityId != null && OppAttachmentkeyPrefix != NULL && String.valueOf(ContentDocumentLink.LinkedEntityId).startsWith(OppAttachmentkeyPrefix)) {
                setOpportunityAttId.add(ContentDocumentLink.LinkedEntityId);
            }
        }
        
        if(!setOpportunityAttId.isEmpty()) {
            for(OpportunityAttachment__c tempOppAttach : [select id,Opportunity__c from OpportunityAttachment__c where id in : setOpportunityAttId]) {
                setOpportunityId.add(tempOppAttach.Opportunity__c);
            }
        }
        
        for(id oppid : setOpportunityId) {
            OpportunityToUpdate.add(new Opportunity(Id = oppid , MISAttachmentAdded__c = Datetime.now()));
        }
        
        //update if list has any records
        if(OpportunityToUpdate != null && OpportunityToUpdate.size() > 0) {
            //adding bypass for uploading opportunity attachments such that validations are not fired SFDC-1710 #start
            GlobalConstants.hasTriggeredFromOpportunityProduct = true;
            update OpportunityToUpdate;
            GlobalConstants.hasTriggeredFromOpportunityProduct = false;
            // SFDC-1710 #stop
        }
    }
    
    // @return: None
    // @Modifiedby: Sharique Iqbal
    // @Modified Description: Added the logic Mark PO Attached as Yes when an attahment added on Contract Attachment Record.
    // @ Story: SFDC-2530 
    public static void updateContractOncePOIsAttached(TriggerParameters tp) {
        
        String ContractAttachmentPrefix = UtilityClass.getObjectKeyPrefix('ContractAttachment__c');
        set<id> setContractAttId = new set<id>();
        List <sObject> updateSobject = new List <sObject>();
        String profileName = UtilityClass.LoggedInUserProfileName;
        Boolean profileCheck =  (profileName.containsIgnoreCase('System Admin') || profileName.containsIgnoreCase('Contract Management') || profileName.containsIgnoreCase('Order Management')
               				  || profileName.containsIgnoreCase('General') || profileName.containsIgnoreCase('Sales Coordinator') || profileName.containsIgnoreCase('User Support') || profileName.containsIgnoreCase('Sales Ops')) ? True : False;
        for(ContentDocumentLink ContentDocumentLink: (List <ContentDocumentLink>) tp.newList) {
           // Checking if attachment is added to Contract Attachment Record.
           if(ContentDocumentLink.LinkedEntityId != null && ContractAttachmentPrefix != NULL && String.valueOf(ContentDocumentLink.LinkedEntityId).startsWith(ContractAttachmentPrefix)) {
               setContractAttId.add(ContentDocumentLink.LinkedEntityId);
           }
        }
                
        if(!setContractAttId.isEmpty()) {
            for(ContractAttachment__c contrtAttach : [select Id, Contract__c, CurrentPO__c, AttachmentType__c, (Select Id From ContentDocumentLinks) from ContractAttachment__c where id in : setContractAttId]) {
                contrtAttach.TotalFilesAttached__c = contrtAttach.ContentDocumentLinks.size(); 
                if (contrtAttach.AttachmentType__c == 'Purchase Order') {
                    contrtAttach.POAttached__c = 'Yes';
                    if (contrtAttach.CurrentPO__c == 'Yes') {
                        Contract ctrt = new Contract (Id = contrtAttach.Contract__c, POAttached__c = 'Yes');
                        updateSobject.add(ctrt);
                    }
                }
                updateSobject.add(contrtAttach);
            }
        }

        if (!updateSobject.isEmpty()) {
            if (profileCheck) {
             GlobalVariables.allowContactAttchToUpdate = True;
            }    
            update updateSobject;  
            GlobalVariables.allowContactAttchToUpdate = False;
        }
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 18 Aug 2021
    // @param: TriggerParameters
    // @description: Hold the Parent Ids before Removing(delinking) the File from parent 
    // @return: NA
    //-----------------------------
    public static void beforeDeleteOperations(TriggerParameters tp) {
        
      String ContractAttachmentPrefix = UtilityClass.getObjectKeyPrefix('ContractAttachment__c');
 
      for(ContentDocumentLink ContentDocumentLink: (List <ContentDocumentLink>) tp.oldList) {
           // Checking if attachment is added to Contract Attachment Record.
           if(ContentDocumentLink.LinkedEntityId != null && ContractAttachmentPrefix != NULL && String.valueOf(ContentDocumentLink.LinkedEntityId).startsWith(ContractAttachmentPrefix)) {
               setContractAttId.add(ContentDocumentLink.LinkedEntityId);
           }
      } 
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 18 Aug 2021
    // @param: TriggerParameters
    // @description: Count the no of files after a file has been delinked. 
    // @return: NA
    //-----------------------------
    public static void afterDeleteOperations(TriggerParameters tp) {
      List <sObject> updateSobject = new List <sObject>();
      try {
           if(!setContractAttId.isEmpty()) {
             for(ContractAttachment__c contrtAttach : [select Id, Contract__c, (Select Id From ContentDocumentLinks) from ContractAttachment__c where Id IN : setContractAttId]) {
                contrtAttach.TotalFilesAttached__c = contrtAttach.ContentDocumentLinks.size(); 
                updateSobject.add(contrtAttach);
             }
           }
           if (!updateSobject.isEmpty()) {
              GlobalVariables.shouldContractValidationBypass = True;
              update updateSobject;  
              GlobalVariables.shouldContractValidationBypass = False;
           }
      } catch (Exception e) {
               if(e.getMessage().contains(System.Label.ContractShouldHaveAtLeastOneFile)) {    
                ((List<ContentDocumentLink>) tp.oldList).get(0).addError(System.Label.ContractShouldHaveAtLeastOneFile);
               } else if(e.getMessage().contains(System.Label.ContractAttachmentRestrictionError)) {    
                ((List<ContentDocumentLink>) tp.oldList).get(0).addError(System.Label.ContractAttachmentRestrictionError);
               } else ((List<ContentDocumentLink>) tp.oldList).get(0).addError(System.Label.ContractShouldHaveAtLeastOneFile);     
        }
    }  
    
    // @return: None
    // @Modifiedby: Digvijay Singh
    // @Modified Description: Added the logic Mark File Attached as Yes when an attahment added on VOC.
    // @ Story: US-5320681 
    public static void updateVOCOnceFileIsAttached(TriggerParameters tp) {

        String vocAttachmentPrefix = UtilityClass.getObjectKeyPrefix('VoiceofCustomer__c');
        System.debug('VOC..pref'+vocAttachmentPrefix);
        set<id> setVOCAttId = new set<id>();
        List <sObject> updateSobject = new List <sObject>();

         for(ContentDocumentLink ContentDocumentLink: (List <ContentDocumentLink>) tp.newList) {
           // Checking if attachment is added to VOC Record.
           if(ContentDocumentLink.LinkedEntityId != null && vocAttachmentPrefix != NULL && String.valueOf(ContentDocumentLink.LinkedEntityId).startsWith(vocAttachmentPrefix)) {
               setVOCAttId.add(ContentDocumentLink.LinkedEntityId);
           }
         }
        
        System.debug('VOC..pref'+setVOCAttId);

          if(!setVOCAttId.isEmpty()) {
            for(VoiceofCustomer__c vocobj  : [select Id, FileAttached__c from VoiceofCustomer__c where id in : setVOCAttId]) {
                if(vocobj.FileAttached__c=='No' || String.isBlank(vocobj.FileAttached__c)) {
                    vocobj.FileAttached__c='Yes';
                    updateSobject.add(vocobj);
                }
            }

            if(!updateSobject.isEmpty()) {
                update updateSobject;
            }
          }
    }
    
   
}