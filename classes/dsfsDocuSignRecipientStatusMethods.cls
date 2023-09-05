//-----------------------------
// @author: Ankita Singh
// @date: 11 April 2018
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
// 
// @modifiedDate: 20 July 2018
// @modifiedBy: Tran-Vu Tran
// @description: SFDC1-7947 Add logic to convert document to file and link to the Contract Attachment upon signature complete
// 
// @modifiedDate: 12 Nov 2018
// @modifiedBy: Tran-Vu Tran
// @description: SFDC1-10300 Add logic to update Contract Status to "Signed by Contract Owner" and "Sent to Customer" for Continuation Letter.
// 
// @modifiedDate: 30 April 2019
// @modifiedBy: Tran-Vu Tran
// @modifiedDescription: SFDC-17 Continuation Letter: Customers do not need to sign document.
//-----------------------------
public class dsfsDocuSignRecipientStatusMethods {

    //-----------------------------
    // @author: Ankita Singh
    // @date: 11 April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7213 : When a customer signs a Contract in docusign,the Contract Status should automatically be updated 
    //                            to "Signed by Customer".
    // @modifiedDate: 12 Nov 2018
    // @modifiedBy: Tran-Vu Tran
    // @description: SFDC1-10300 Add logic to update Contract Status to "Sent to Customer" for Continuation Letter.
    // @return: None
    // 
    // @modifiedDate: 11 Mar 2019
    // @modifiedBy: Harshit Singhal
    // @description: SFDC-895 Added code to update continuation letter contract stage to 'Completed' when contract is signed by contract owner
    // @return: None
    // 
    // @modifiedDate: 08 Nov 2019
    // @modifiedBy: Harshit Singhal
    // @description: SFDC-2037 Removed code to update Contract Status and Stage for continuations. Moved code to create files in Contract Attachment record in a separate method 'createContractAttachmentFilesFromDocusignStatus()'. 
    // 				This method, if it is not a continuation letter contract, moves Contract Status to 'Signed By Customer' and creates file under Contract Attachment record when Customer signs the contract via Docusign.
    // 				For continuation letter, Contract Status is updated by Contract Attachment trigger code. Files are created under Contract Attachment record via 'updateContractAttachmentType()' method. 
    // @return: None
    // 
    // @modifiedDate: 17 Dec 2019
    // @modifiedBy: Harshit Singhal
    // @description: SFDC-490 Do not update contract status on Order form to 'Signed By Customer' if existing status is 'Validated'/'Validated PO Pending'/'Delivered to Customer'
    // 
    // @modifiedDate: 06 Feb 2020
    // @modifiedBy: Harshit Singhal
    // @description: SFDC-2542 Do not update contract status on Consulting Contract to 'Signed By Customer' if existing status is 'Validated'/'Validated PO Pending'/'Delivered to Customer'
    // @modifiedDate:7th May 2020
    // @modifiedBy:Paras Dhingra
    // @description: SFDC-2873 Adding status Validated-POD Pending in the list in line with Validated PO Pending
    // @modifiedDate: 15 Sep 2020
    // @modifiedBy: Harshit Singhal
    // @description: SFDC-3317 Create contract attachments when an internal IHS Markit employee signs a contract via Docusign. 
    // 					This internal signing flow happens outside of Salesforce where Contract Management team directly sends the contracts to internal signatories using Docusign portal and by selecting the SF contract manually in the portal.
    //------------------------------ 
    
    public static void changeContractStatus(TriggerParameters tp) {
        Map<Id, dsfs__DocuSign_Recipient_Status__c> mapNewDocSignRS = (Map<Id, dsfs__DocuSign_Recipient_Status__c>)tp.newMap;
        Map<Id, dsfs__DocuSign_Recipient_Status__c> mapOldDocSignRS = (Map<Id, dsfs__DocuSign_Recipient_Status__c>)tp.oldMap;
        
        List<Contract> contractListToUpdate = new List<Contract>();
        List<Id> signedByCustomerDocuSignStatusIDs = new List<Id>(); // list of IDs to hold the "Completed" DocuSign Status record IDs signed by  customer
        List<Id> signedByIHSDocuSignStatusIDs = new List<Id>(); // list of IDs to hold the "Completed" DocuSign Status record IDs signed by internal IHS employees
        List<Id> toQueryDocuSignStatusIDs = new List<Id>();
        
        // which Contracts need to be updated to "Signed by Customer" (when the recipient's email address does not contain @ihsmarkit.com)                
        List<Id> docusignStatusIdsForAttachments = new List<Id>();

        for (dsfs__DocuSign_Recipient_Status__c drs : mapNewDocSignRS.values() ) {
            
            dsfs__DocuSign_Recipient_Status__c oldDocSignRS;
            if (mapOldDocSignRS != null) {
                oldDocSignRS = mapOldDocSignRS.get(drs.id);
            }
			
            if (drs.dsfs__Parent_Status_Record__c != null 
                && (oldDocSignRS == null || (oldDocSignRS != null && oldDocSignRS.dsfs__Recipient_Status__c != drs.dsfs__Recipient_Status__c))) {
                    switch on (drs.dsfs__Recipient_Status__c) {
                        when 'Completed' {
                            if (drs.dsfs__DocuSign_Recipient_Email__c != null) {                                
                                if (!drs.dsfs__DocuSign_Recipient_Email__c.containsIgnoreCase('@ihsmarkit.com') && !drs.dsfs__DocuSign_Recipient_Email__c.containsIgnoreCase('@markit.com')) {
                                    signedByCustomerDocuSignStatusIDs.add(drs.dsfs__Parent_Status_Record__c);                                    
                                }
                                else {
                                    signedByIHSDocuSignStatusIDs.add(drs.dsfs__Parent_Status_Record__c);
                                }
                                toQueryDocuSignStatusIDs.add(drs.dsfs__Parent_Status_Record__c);
                            }
                        }
                    }
                }
        }
        
        Map<Id,dsfs__DocuSign_Status__c> allDocuSignStatusMap = new Map<Id,dsfs__DocuSign_Status__c>([SELECT dsfs__Contract__c, dsfs__Contract__r.RecordTypeId, dsfs__Contract__r.ContractStatus__c, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c 
                                                                                 FROM dsfs__DocuSign_Status__c 
                                                                                 WHERE Id IN :toQueryDocuSignStatusIDs]);
        
        // processing "Signed by Customer" DocuSign Status records
        if (signedByCustomerDocuSignStatusIDs != null && signedByCustomerDocuSignStatusIDs.size() > 0) {
            List<String> skipContractStatusOFList = new List<String>{'Validated','Validated PO Pending','Delivered to Customer','Validated-POD Pending'};
            for(Id signedByCustomerDSSId: signedByCustomerDocuSignStatusIDs) {
                dsfs__DocuSign_Status__c dssObj = allDocuSignStatusMap.get(signedByCustomerDSSId);
                Boolean skipContractStatusUpdate = false;
                
                if(dssObj!=null && dssObj.dsfs__Contract__c!=null && 
                   dssObj.dsfs__Contract__r.ContractStatus__c!='Signed By Customer' && 
                   dssObj.dsfs__Contract__r.RecordTypeId!=ContractMethods.continuationLetterRecordTypeId) {
                       //skipContractStatusUpdate = dssObj.dsfs__Contract__r.RecordTypeId==ContractMethods.orderFormRecordTypeId && skipContractStatusOFList.contains(dssObj.dsfs__Contract__r.ContractStatus__c)? true:false;
                       skipContractStatusUpdate = (dssObj.dsfs__Contract__r.RecordTypeId==ContractMethods.orderFormRecordTypeId || dssObj.dsfs__Contract__r.RecordTypeId==ContractMethods.consultingRecordTypeId) && skipContractStatusOFList.contains(dssObj.dsfs__Contract__r.ContractStatus__c)? true:false;
                       if(!skipContractStatusUpdate) {
                           contractListToUpdate.add(new Contract(Id = dssObj.dsfs__Contract__c, ContractStatus__c = 'Signed By Customer'));    
                       }                       
                       docusignStatusIdsForAttachments.add(signedByCustomerDSSId);
                }
            }
        }
        //Gather DSS records for contracts which are signed by internal IHS employees. Then, upload these internally signed contracts as contract attachments.
        if(signedByIHSDocuSignStatusIDs.size() > 0) {
            for(Id signedByIHSDSSId: signedByIHSDocuSignStatusIDs) {
                dsfs__DocuSign_Status__c dssObj = allDocuSignStatusMap.get(signedByIHSDSSId);
                //if(dssObj!=null && dssObj.dsfs__Contract__c!=null && (dssObj.dsfs__Contract__r.RecordTypeId==ContractMethods.orderFormRecordTypeId || dssObj.dsfs__Contract__r.RecordTypeId==ContractMethods.consultingRecordTypeId)) {
                if(dssObj!=null && dssObj.dsfs__Contract__c!=null) {
                    docusignStatusIdsForAttachments.add(signedByIHSDSSId);                    
                }
            }            
        }
        try {
            if (contractListToUpdate.size() > 0 || contractListToUpdate != null) {
            	update contractListToUpdate ;   
            }
        }
        catch(Exception e) {
            System.debug('Exception in dsfsDocuSignRecipientStatusMethods.changeContractStatus: ' + e.getMessage() + e.getStackTraceString());
            UtilityClass.createApexLogRecord(e, 'dsfsDocuSignRecipientStatusMethods', 'changeContractStatus');
        }
		//Create files under contract attachment for non-Continuation contract record types        
        createContractAttachmentFilesFromDocusignStatus(docusignStatusIdsForAttachments);
    }
	    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 30 July 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7947 after DocuSign Status record is created,
    // 				if the recipient's email address is internal, update the matching Contract Attachment Type to "Countersigned Contract"
    // 				else leave Contract Attachment Type as "Client Signed Contract" 
    // @modifiedDate: 30 April 2019
    // @modifiedBy: Tran-Vu Tran
    // @modifiedDescription: SFDC-17 Continuation Letter: Customers do not need to sign document.
    // 	Below are the attachment types needed at each step in the signature process:
    // 		1. Send With Docusign to Opportunity Owner: Type='Other'
    // 		2. IHS Markit's Opportunity Owner signs Continuation Letter: Type='Signed Continuation Letter'
    // 		3. Customer signs Continuation Letter: Type='Countersigned Contract'
    // @return: None
    // @Last Modified By: Harshit Singhal
    // @Last Modified Date: 08 Nov 2019
    // @Last Modified Description: SFDC-2037 Redesigned this method to update Contract Attachment type picklist as per new Continuation Letter signing process. 
    // 								Create files under contract attachment record, when sent to customer and signed by customer.
    //------------------------------ 
    public static void updateContractAttachmentType(TriggerParameters tp) {        
        List <ContractAttachment__c> contractAttachmentsToUpdate = new List <ContractAttachment__c>();
        List<Id> docusignStatusIdsForAttachments = new List<Id>();
        // getting all Envelope IDs for the recipients
        Set<String> envelopeIDs = new Set<String>();
        Map<String, ContractAttachment__c> caMap = new Map<String, ContractAttachment__c>();
        for (dsfs__DocuSign_Recipient_Status__c drs: (List<dsfs__DocuSign_Recipient_Status__c>) tp.newList) {
            if (drs.dsfs__Envelope_Id__c != null && (drs.dsfs__Recipient_Status__c == 'Sent' || drs.dsfs__Recipient_Status__c == 'Completed')) {
                envelopeIDs.add(drs.dsfs__Envelope_Id__c);
            }
        }
        // retrieving all Contract Attachment records with the matching envelope IDs for the recipients
        if(envelopeIDs.size() > 0) {
            for(ContractAttachment__c ca: [SELECT DocuSignEnvelopeId__c, AttachmentType__c, Contract__r.RecordTypeId FROM ContractAttachment__c WHERE DocuSignEnvelopeId__c in: envelopeIDs]) {
                caMap.put(ca.DocuSignEnvelopeId__c, ca);
            }    
        }
        for(dsfs__DocuSign_Recipient_Status__c drs : (List<dsfs__DocuSign_Recipient_Status__c>)tp.newList) {
            if(drs.dsfs__DocuSign_Recipient_Email__c != null) {
				ContractAttachment__c ca = caMap.get(drs.dsfs__Envelope_Id__c);
                if(ca != null && ca.Contract__r.RecordTypeId == ContractMethods.continuationLetterRecordTypeId && !drs.dsfs__DocuSign_Recipient_Email__c.containsIgnoreCase('@ihsmarkit.com')) {
                    if(drs.dsfs__Recipient_Status__c == 'Sent') {
                        if(ca.AttachmentType__c != 'Continuation Letter') {
                            ca.AttachmentType__c = 'Continuation Letter';
                            contractAttachmentsToUpdate.add(ca);    
                        }                        
                        docusignStatusIdsForAttachments.add(drs.dsfs__Parent_Status_Record__c);                                                
                    }
                    if(drs.dsfs__Recipient_Status__c == 'Completed') {
                        if(ca.AttachmentType__c != 'Signed Continuation Letter') {
                            ca.AttachmentType__c = 'Signed Continuation Letter';
                            contractAttachmentsToUpdate.add(ca);    
                        }
                        docusignStatusIdsForAttachments.add(drs.dsfs__Parent_Status_Record__c);
                    }
                }
            }
        }
		
        try {
            if (contractAttachmentsToUpdate != null && contractAttachmentsToUpdate.size() > 0) {
                update contractAttachmentsToUpdate;
            }
        }
        catch(Exception e) {
            System.debug('Exception in dsfsDocuSignRecipientStatusMethods.updateContractAttachmentType: ' + e.getMessage() + e.getStackTraceString());
            UtilityClass.createApexLogRecord(e, 'dsfsDocuSignRecipientStatusMethods', 'updateContractAttachmentType');
        }
		//Create Files under Contract Attachment records
		createContractAttachmentFilesFromDocusignStatus(docusignStatusIdsForAttachments);
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 08 Nov 2019
    // @param: TriggerParameters tp
    // @description: SFDC-2037 Method to create/copy files under Contract Attachment record from Attachments under Docusign Status record
    //-----------------------------
    public static void createContractAttachmentFilesFromDocusignStatus(List<Id> docuSignStatusIDsForAttachments) {		
        List<ContentVersion> filesToInsert = new List <ContentVersion>();
        Set<Id> parentIDs = new Set<Id>();
        Map<String, ContractAttachment__c> caMap = new Map<String, ContractAttachment__c> ();
        
        if (docuSignStatusIDsForAttachments != null && docuSignStatusIDsForAttachments.size() > 0) {
            List<dsfs__DocuSign_Status__c> listDocuSignStatusToAttachFile = [SELECT dsfs__Contract__c, dsfs__DocuSign_Envelope_ID__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE Id IN :docuSignStatusIDsForAttachments];
            Set<String> docuSignEnvelopeIDs = new Set<String>();
            //Get Envelope Ids
            for (dsfs__DocuSign_Status__c dss : listDocuSignStatusToAttachFile) {
                docuSignEnvelopeIDs.add(dss.dsfs__DocuSign_Envelope_ID__c);
            }
            //Get contract attachment records based on envelope Ids
            for (ContractAttachment__c conAtt : [select DocuSignEnvelopeId__c, Id, Name, AttachmentType__c from ContractAttachment__c where DocuSignEnvelopeId__c in : docuSignEnvelopeIDs] ) {
                caMap.put(conAtt.DocuSignEnvelopeId__c, conAtt);
            }
            //Get standard attachments records with attachment body            
            Map<Id, Attachment> attMap = new Map<Id, Attachment>();
            for (Attachment att : [Select Id, Name, Body, OwnerId, ParentId From Attachment where ParentId in :docuSignStatusIDsForAttachments]) {
                attMap.put(att.ParentId, att);
            }
            for (dsfs__DocuSign_Status__c dss: listDocuSignStatusToAttachFile) {
                if (dss.dsfs__Contract__c != null && dss.dsfs__DocuSign_Envelope_ID__c != null) {
                    Attachment att = attMap.get(dss.Id);
                    ContractAttachment__c ca = caMap.get(dss.dsfs__DocuSign_Envelope_ID__c);
                    
                    if (att != null && ca != null) {
                        string docName = att.Name.replace('.pdf', ' (' + DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')  + ').pdf');
                        
                        ContentVersion cv = new ContentVersion();
                        cv.ContentLocation = 'S';
                        cv.PathOnClient = docName;
                        //cv.Origin = 'H';
                        //cv.DocumentType__c = 'Contract Attachment';
                        cv.Title = docName;
                        cv.OwnerId = att.OwnerId;
                        cv.VersionData = att.Body;
                        // this hold the Contract Attachment Id to be linked back once the document file has been inserted
                        cv.ParentID__c = ca.Id;
                        cv.FirstPublishLocationId = cv.ParentID__c;
                        
                        parentIDs.add(ca.Id); // keep the list of Parent IDs to retrieve data after records have been inserted 
                        
                        //System.debug('adding ContentVersion: ' + cv);
                        filesToInsert.add(cv);
                    }
                    
                }
            }
            
        }
        
        if(filesToInsert.size() > 0) {
            try {
                insert filesToInsert;
                /*
                //Create ContentDocumemtLink records
                List<ContentVersion> newFiles = [select Id, ContentDocumentId, ParentID__c from ContentVersion where ParentID__c in : parentIDs];
                List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
                for (ContentVersion cv : newFiles) {                
                    // creating Content Document Link from the parent Contract Attachment to the new document file
                    ContentDocumentLink cl = new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId,LinkedEntityId = cv.ParentID__c,ShareType = 'I',Visibility = 'InternalUsers');                
                    docLinks.add(cl);
                }
                insert docLinks;
				*/
            }
            catch(Exception e) {
                System.debug('Exception in dsfsDocuSignRecipientStatusMethods.getContractAttachmentFilesFromDocusignStatus: ' + e.getMessage() + e.getStackTraceString());
                UtilityClass.createApexLogRecord(e, 'dsfsDocuSignRecipientStatusMethods', 'getContractAttachmentFilesFromDocusignStatus');
            }
        }        
    }

     //-----------------------------
    // @author: Paras Dhingra
    // @date: 22 Jul 2020
    // @param: TriggerParameters tp
    // @description: SFDC-2397 automate continuation letter movement to stage-10 from stage-9 when docusign is sent
    // @return: NA
    //-----------------------------
    public static void moveContractToStage10( TriggerParameters tp) {
        List <ContractAttachment__c> contractAttachmentsToUpdate = new List <ContractAttachment__c>();
        Id continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
        List<Id> docusignStatusIdsForAttachments = new List<Id>();
        // getting all Envelope IDs for the recipients
        Set<String> docusignStatusIds = new Set<String>();
        Map<String, ContractAttachment__c> caMap = new Map<String, ContractAttachment__c>();
        for (dsfs__DocuSign_Recipient_Status__c drs: (List<dsfs__DocuSign_Recipient_Status__c>) tp.newList) {
            if (drs.dsfs__Parent_Status_Record__c!= null && (drs.dsfs__Recipient_Status__c == 'Sent')) {
                docusignStatusIds.add(drs.dsfs__Parent_Status_Record__c	);
            }
        }
        System.debug('@PD--docusignStatus Parent Ids'+ docusignStatusIds);
        // retrieving all Contract records with the matching envelope IDs for the recipients
        List<Contract> lstContractsToQuery = [SELECT Id, Status FROM Contract 
                                                WHERE 
                                                ID IN (SELECT dsfs__Contract__c FROM dsfs__DocuSign_Status__c WHERE Id IN :docusignStatusIds )
                                                AND Status = 'Generation' 
                                                AND RecordTypeId =:continuationLetterRecordTypeId];
        System.debug('@PD- contract list after query-'+lstContractsToQuery);
        if(lstContractsToQuery!=null && !lstContractsToQuery.isEmpty()) {
            //move all matching contracts to stage 10
            for(Contract cont: lstContractsToQuery) {
                cont.Status = 'ReadyForProcessing';
            }
            System.debug('@PD- contract list-'+lstContractsToQuery);
            update lstContractsToQuery;
        }
    }
    
}