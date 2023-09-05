/**
* @author: Ankita Singh
* @date: 18 June 2018
* @description: SFDC1-8559. After insert and After delete dispatcher event handler class that calls the functions in ContractAttachmentMethods.
* @companyname: VERTIBA
*/

public class ContractAttachmentMethods {
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 18 June 2018
    // @description: SFDC1-8559- Once the salesperson attaches the PO in custom attachments - and chooses the type 
    //              "Purchase Order" then a trigger will update  yes/no on field called "PO Attached" on the Contract and OM case
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @companyname: VERTIBA
	// @lastmodifiedby : Mohit Modi
	// @Lastmodified description : SFDC1-9507 : adding Consulting RecordType for PO Attached Functionality. 
    //-----------------------------
    /* SFDC-2530 Commenting since PO Attached field on Contract is now dependent on the Attachment on Contract Attachment record.
    public static void updateFieldOnContract(TriggerParameters tp) {     
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {            
            try {
                Set<Id> contractIds = new Set<Id>();
                Boolean isChanged = FALSE;
                List<Contract> contractList = new List<Contract>();
                for(ContractAttachment__c c :(List<ContractAttachment__c>) tp.newList) {
                    if(c.AttachmentType__c == 'Purchase Order') {
                        // collecting associated contract id
                        contractIds.add(c.Contract__c); 
                    }
                }
                if(contractIds != null && contractIds.size() > 0) {
                    // fetching contract PO Attached Info for newly added attachment
                    Map<Id,Contract> contractMap = new Map<Id,Contract>([Select Id,POAttached__c from Contract where Id In:contractIds AND recordtype.Name IN ('Order Form','Consulting') AND POAttached__c !='Yes']);
                    if(contractMap != null && contractMap.size() > 0) {
                        for(Id c : contractMap.keySet()) {
                            // setting PO Attached to Yes since they have new attachment added
                            contractMap.get(c).POAttached__c = 'Yes';
                            isChanged = TRUE;       
                        }
                        if(isChanged == TRUE) {
                            update contractMap.values();    
                        }
                    }
                }   
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'ContractAttachmentMethods','updateFieldOnContract'); 
            }     
        }
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {   
            try {
                Set<Id> contractIds = new Set<Id>();
                Map<Id,ContractAttachment__c> mapOldContract =  (Map<Id,ContractAttachment__c>)tp.oldMap;
                List<Contract> contractList = new List<Contract>();
                for(ContractAttachment__c c : mapOldContract.values()) {
                    if(c.AttachmentType__c == 'Purchase Order') {
                        // collecting associated contract id
                        contractIds.add(c.Contract__c); 
                    }
                }
                if(contractIds != null && contractIds.size() > 0) {
                    // fetching contract PO Attached Info for deleted attachment
                    List<Contract> contractAttachmentList = [Select Id,POAttached__c,(Select Id from ContractAttachments__r where AttachmentType__c = 'Purchase Order' ) from Contract where Id In:contractIds AND recordtype.Name IN ('Order Form','Consulting') ];
                    if(contractAttachmentList != null && contractAttachmentList.size() > 0) {
                        for(Contract c : contractAttachmentList) {
                            if(c.ContractAttachments__r == null || c.ContractAttachments__r.size() == 0) {
                                // updating the field PO Attachment to no since they dont have any assciated attachment
                                c.POAttached__c = 'No';
                                contractList.add(c);
                            }
                        }
                        if(contractList != null && contractList.size()>0) {
                            update contractList;
                        }
                    }
                }   
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'ContractAttachmentMethods','updateFieldOnContract'); 
            }     
        } 
        
    }*/
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 07 November 2019
    // @description: SFDC-2037- Set the record type on Contract Attachment record same as the record type of the parent contract.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------    
    public static void setRecordTypeFromContract(TriggerParameters tp) {                
        Set<Id> contractIds = new Set<Id>();        
        for(ContractAttachment__c conAttach : (List<ContractAttachment__c>) tp.newList) {
            System.debug('conAttach.RecordTypeId='+conAttach.RecordTypeId);
            contractIds.add(conAttach.contract__c);
        }
        if(contractIds.size() > 0) {
            Map<id, Contract> contractsMap = new Map<Id, Contract>([SELECT Id, RecordType.Name FROM Contract WHERE Id IN :contractIds]);            
            for(ContractAttachment__c conAttObj : (List<ContractAttachment__c>) tp.newList) {				
                if(contractsMap.containsKey(conAttObj.Contract__c) && String.isNotBlank(contractsMap.get(conAttObj.Contract__c).Recordtype.Name)) {
                    Id conAttRecordTypeId = Schema.SObjectType.ContractAttachment__c.getRecordTypeInfosByName().get(contractsMap.get(conAttObj.Contract__c).Recordtype.Name).getRecordTypeId();                    
                    if(conAttRecordTypeId != null) {
                        conAttObj.RecordTypeId = conAttRecordTypeId;
                    }
                }
            }
        }
    }
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 07 November 2019
    // @description: SFDC-2037- Update contract's status on the Contract Attachment AttachmentType picklist.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------   	
    public static void updateContinuationContracts(TriggerParameters tp) {
        Map<Id,ContractAttachment__c> oldMap = (Map<Id,ContractAttachment__c>)tp.oldMap;
        Set<Id> contractIds = new Set<Id>();
        List<ContractAttachment__c> conAttToProcess = new List<ContractAttachment__c>(); 
        List<Contract> contractsUpdateList = new List<Contract>();
        
        for(ContractAttachment__c conAttach : (List<ContractAttachment__c>)tp.newList) {
            ContractAttachment__c oldConAttach = (oldMap!=null && oldMap.size()>0) ? oldMap.get(conAttach.Id) : null;
            if(conAttach.Contract__c != null && 
               (oldConAttach == null || (conAttach.AttachmentType__c!=oldConAttach.AttachmentType__c && (conAttach.AttachmentType__c == 'Continuation Letter' || conAttach.AttachmentType__c == 'Signed Continuation Letter')))) {
                   conAttToProcess.add(conAttach);
                   contractIds.add(conAttach.Contract__c);    
               }            
        }
        if(contractIds.size() > 0) {
        	Map<Id,Contract> contractMap = new Map<Id,contract>([SELECT Id, RecordTypeId, ContractStatus__c, Status, NoInternalApprovalNeeded__c FROM Contract 
                                                                 WHERE Id IN :contractIds AND RecordTypeId =:ContractMethods.continuationLetterRecordTypeId]);
            for(ContractAttachment__c conAttachObj: conAttToProcess) {
                Contract conObj = contractMap.get(conAttachObj.Contract__c);
                if(conAttachObj.AttachmentType__c == 'Continuation Letter' && conObj != null && conObj.ContractStatus__c!='Sent to Customer' && conObj.ContractStatus__c!='Signed By Customer') {
                    conObj.ContractStatus__c = 'Sent to Customer';
                    contractsUpdateList.add(conObj);
                }
                if(conAttachObj.AttachmentType__c == 'Signed Continuation Letter' && conObj != null && conObj.ContractStatus__c!='Signed By Customer') {
                    conObj.ContractStatus__c = 'Signed By Customer';
                    contractsUpdateList.add(conObj);
                }
            }
        }
        
        if(contractsUpdateList.size() > 0) {
            update contractsUpdateList;
        }
    }
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 05 Oct 2021
    // @description: SFDC-4568- When Contract is at stage 11, only Admins/OM/CM users can edit Contract Attachment records.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    //-----------------------------   	
    public static void updateRestrictionOnContractStage11(TriggerParameters tp) {
        Map<Id,ContractAttachment__c> oldMap = (Map<Id,ContractAttachment__c>)tp.oldMap;

		if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            Profile prof = [Select Id, Name from Profile where Id=:UserInfo.getProfileId() limit 1];
            String profileName = prof.Name;
			System.debug('@PD--Profilename--'+profileName);
			//check if user is admin then do not process further
			if(GlobalVariables.allowContactAttchToUpdate || profileName.containsIgnoreCase('System Admin') || profileName.containsIgnoreCase('User Support') || profileName.containsIgnoreCase('Contract Management') || profileName.containsIgnoreCase('Order Management')
			  ) {
				//no validation checks are required for system admins/CM/OM 
				System.debug('$$ Checked bypassed');
				return;
			}
			
			validateContractAttachment ((List<ContractAttachment__c>)tp.newList, tp.tEvent);
		}

    }
     
    /*
    * @author: Sharique Iqbal
    * @date: 06 Oct 2021
    * @description: SFDC-4568 Restrict users to delete Contract Attachment records when Contract Stage is at 11
    * @param TriggerParameters
    * @return void
    * @companyname IHS Markit
    */
    public static void deletionRestrictedWhenContractStage11(TriggerParameters tp) {
        Map<Id,ContractAttachment__c> oldMap = (Map<Id,ContractAttachment__c>)tp.oldMap;
        List<ContractAttachment__c> conAttToProcess = new List<ContractAttachment__c>(); 
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeDelete) {
            Profile prof = [Select Id, Name from Profile where Id=:UserInfo.getProfileId() limit 1];
            String profileName = prof.Name;
            System.debug('@PD--Profilename--'+profileName);
            //check if user is admin then do not process further
            if(profileName.containsIgnoreCase('System Admin')|| profileName.containsIgnoreCase('User Support') || profileName.containsIgnoreCase('Order Management')) {
                //no validation checks are required for system admins
                System.debug('$$ Checked bypassed');
                return; 
            }
			validateContractAttachment ((List<ContractAttachment__c>)tp.oldList,tp.tEvent);
		}
	}
	
	   /*
    * @author: Sharique Iqbal
    * @date: 06 Oct 2021
    * @description: SFDC-4568 Restrict users to create Contract Attachment records when Contract Stage is at 11
    * @param TriggerParameters
    * @return void
    * @companyname IHS Markit
    */
    public static void creationRestrictionOnContractStage11(TriggerParameters tp) {
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
            Profile prof = [Select Id, Name from Profile where Id=:UserInfo.getProfileId() limit 1];
            String profileName = prof.Name;
            System.debug('@PD--Profilename--'+profileName);
            //check if user is admin then do not process further
            if(profileName.containsIgnoreCase('System Admin') || profileName.containsIgnoreCase('Contract Management') || profileName.containsIgnoreCase('Order Management')
               || profileName.containsIgnoreCase('General') || profileName.containsIgnoreCase('Sales Coordinator') || profileName.containsIgnoreCase('User Support') || profileName.containsIgnoreCase('Sales Ops')) {
                //no validation checks are required for system admins
                System.debug('$$Checked bypassed');
                return; 
            }
			validateContractAttachment ((List<ContractAttachment__c>)tp.newList,tp.tEvent);
		}
	}	
              
	
	public static void validateContractAttachment(List<ContractAttachment__c> conAttList, TriggerParameters.TriggerEvent evt) {
		
        Set<Id> contractIds = new Set<Id>();
        List<ContractAttachment__c> conAttToProcess = new List<ContractAttachment__c>(); 
		String ErrorMsg = (evt == TriggerParameters.TriggerEvent.beforeInsert) ? System.Label.ContractAttachmentCreationRestrictionError : System.Label.ContractAttachmentRestrictionError;
		
		for (ContractAttachment__c conAtt : conAttList) {
           if(conAtt.Contract__c != null) {
              conAttToProcess.add(conAtt);
              contractIds.add(conAtt.Contract__c);  
           }
        }
        if(contractIds.size() > 0) {
            Map<Id,Contract> contractMap = new Map<Id,contract>([SELECT Id, Status FROM Contract WHERE Id IN :contractIds]);
            for(ContractAttachment__c conAttachObj: conAttToProcess) {
                Contract conObj = contractMap.get(conAttachObj.Contract__c);
                if(conObj != null && conObj.Status == 'Complete') {
                    conAttachObj.addError(ErrorMsg);
                }    
            }  
        } 
	}	
 
}