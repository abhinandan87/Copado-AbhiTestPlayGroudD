//-----------------------------
// @author: Sharique Iqbal
// @date: 18 Aug 2021
// @param: TriggerParameters
// @description:  In Lightning, when a file is deleted, ContentDocument Trigger is fired.
// @return: NA
//-----------------------------
public class ContentDocumentMethods {
    
    public static Set <Id> setContractAttId = new Set <Id>();
    public static Set<Id> setVOCAttdelId = new Set<Id>();
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 18 Aug 2021
    // @param: TriggerParameters
    // @description: Hold the Parent Ids before deleting the Files
    // @return: NA
    //-----------------------------
    public static void beforeDeleteOperations(TriggerParameters tp) {
        
      String ContractAttachmentPrefix = UtilityClass.getObjectKeyPrefix('ContractAttachment__c');
       String vocAttachmentPrefix = UtilityClass.getObjectKeyPrefix('VoiceofCustomer__c');
      set<id> ConDocIds = new set<id>();
 
      for(ContentDocument ConDoc: (List<ContentDocument>) tp.oldList) {
          ConDocIds.add(ConDoc.Id);
      }    
      for(ContentDocument ConDoc: [Select Id, (Select Id, LinkedEntityId from ContentDocumentLinks) from ContentDocument Where ID IN :ConDocIds ]) {
          for (ContentDocumentLink conDocLink : ConDoc.ContentDocumentLinks) {
            if(conDocLink.LinkedEntityId != null && ContractAttachmentPrefix != NULL && String.valueOf(conDocLink.LinkedEntityId).startsWith(ContractAttachmentPrefix)) {
               setContractAttId.add(conDocLink.LinkedEntityId);  
            }  
            
            // Checking if attachment is added to VOC Attachment Record.
           if(conDocLink.LinkedEntityId != null && vocAttachmentPrefix != NULL && String.valueOf(conDocLink.LinkedEntityId).startsWith(vocAttachmentPrefix)) {
               setVOCAttdelId.add(conDocLink.LinkedEntityId);
               System.debug('here..'+setVOCAttdelId);
           }
          }  
      }
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 18 Aug 2021
    // @param: TriggerParameters
    // @description: Count the no of files after a file has been deleted. 
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
                ((List<ContentDocument>) tp.oldList).get(0).addError(System.Label.ContractShouldHaveAtLeastOneFile);
               } else if(e.getMessage().contains(System.Label.ContractAttachmentRestrictionError)) {    
                ((List<ContentDocument>) tp.oldList).get(0).addError(System.Label.ContractAttachmentRestrictionError);
               } else ((List<ContentDocument>) tp.oldList).get(0).addError(System.Label.ContractShouldHaveAtLeastOneFile);     
        }
    }    
    
    //-----------------------------
    // @author: Digvijay Singh
    // @date: Nov 09 2022
    // @param: TriggerParameters
    // @description: reset flag on VOC once all attachements are deleted.
    // @return: NA
    //-----------------------------
    public static void afterVOCattachementDeleteOperations(TriggerParameters tp) {
      List <sObject> updateSobject = new List <sObject>();
         System.debug('setVOCAttdelId..'+setVOCAttdelId);
        if(setVOCAttdelId!=null && !setVOCAttdelId.IsEmpty()) {
              for(ContentDocumentLink cdobj:[Select Id ,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN :setVOCAttdelId]) {
                    if(setVOCAttdelId!=null && setVOCAttdelId.contains(cdobj.LinkedEntityId)) {
                        setVOCAttdelId.remove(cdobj.LinkedEntityId);
                    }
              }
        }

      if(setVOCAttdelId!=null && !setVOCAttdelId.isEmpty()) {
         for(Id vocId:setVOCAttdelId) {
            updateSobject.add(new VoiceofCustomer__c(Id=vocId,FileAttached__c='No'));
         }
      }

      if(!updateSobject.isEmpty()) {
         update updateSobject;
      }
	}
}