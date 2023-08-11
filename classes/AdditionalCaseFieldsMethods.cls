//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: NA
// @description: Class to hold Additional Case Fields trigger methods 
// @return: NA
//-----------------------------
public class AdditionalCaseFieldsMethods {

//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: TriggerParameters tp
// @description: When the product is selected the function create a Additional Case Fields with the 
//              recordtype of the product ContainsAdditionalFields__c is set in product table. 
//              This function populate the Additional Fields lookup in case. 
// @return: None
//------------------------------
    public static void populateAdditionalFiledsLookupInCase(TriggerParameters tp) {
    
        //List of Cases that needs to be updated    
        List <Case> casesToUpdate = new List <Case>(); 
        
        for(AdditionalCaseFields__c acf: (List <AdditionalCaseFields__c>) tp.newList) {
            if(acf.Case__c != null) {
                casesToUpdate.add(new Case(Id = acf.Case__c, AdditionalFields__c = acf.Id));
            }
        }
        
        //update if list has any records
        if(casesToUpdate != null && casesToUpdate.size() > 0) {
            update casesToUpdate;
        }
    }

    // @author: Vishnu vardhan Chowdary Andra
	// @date: 19 June 2018
	// @description: SFDC1-265: When delivery queue is changed in delivery record type additonal case, then update the 
    //		owner of case(parent) with the corresponding delivery queue. For each delivery queue pick list there is a 
    // 		corresponding queue (same name) created, to which case is assigned.
    // 		Earlier this was done as part of process builder, moving to code.
	// @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
	// @companyname: VERTIBA
	// @return: void
    /*public static void populateDeliveryQueuesInCase(TriggerParameters tp) {
        Map<Id,AdditionalCaseFields__c> mapNewACFCase = (Map<Id,AdditionalCaseFields__c>) tp.newMap;
        Map<Id,AdditionalCaseFields__c> mapOldACFCase = (Map<Id,AdditionalCaseFields__c>) tp.oldMap;
        Set<String> queueNames = new Set<String>();
        Id deliveryRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Delivery').getRecordTypeId();
        List<AdditionalCaseFields__c> acfList = new List<AdditionalCaseFields__c>();
        System.debug('Entering populateDeliveryQueuesInCase');
        for(AdditionalCaseFields__c newACFCase: mapNewACFCase.values()) {
            AdditionalCaseFields__c oldACFCase = new AdditionalCaseFields__c();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                oldACFCase = mapOldACFCase.get(newACFCase.Id);
            }
            if(newACFCase.RecordTypeId == deliveryRecordTypeId 
               && newACFCase.DeliveryQueue__c != null
               && newACFCase.DeliveryQueue__c != oldACFCase.DeliveryQueue__c) {
                   //Collecting queue to fetch from Database.
                   queueNames.add(newACFCase.DeliveryQueue__c); 
                   acfList.add(newACFCase);
               }
        }
        System.debug('acfList to insert'+acfList);
        System.debug('queueNames to get'+queueNames);
        if(!queueNames.isEmpty()) {
            List<Case> caseList = new List<Case>();
            Map<String,Id> queueIdMap = new map<String,Id>();
            for(Group queue : [Select Name, Id From Group where Type = 'Queue' and name in :queueNames]) {
                queueIdMap.put(queue.Name, queue.id);
            }
            for(AdditionalCaseFields__c additionalCaseField : acfList) {
                case cas = new Case(Id = additionalCaseField.Case__c);
                cas.OwnerId = queueIdMap.get(additionalCaseField.DeliveryQueue__c);
                caseList.add(cas);
            }
            //Update case.
            if(!caseList.isEmpty()) {
                System.debug('cases to insert'+caseList);
                update caseList;
            }
        }
        System.debug('Exiting populateDeliveryQueuesInCase');
    }*/

	// @author: Vishnu vardhan Chowdary Andra
	// @date: 13 August 2018 
	// @description: Converting process builders to triggers. SFDC1-6880, SFDC1-6470, SFDC1-7096. When few fields 
	// 			or populated/edited in ACF case (parent is Customer Care and ACF is OM/Retail/Delivery RT). Then 
	// 			create/update a OMDH case accordingly.
	// @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
	// @companyname: VERTIBA
	// @return: void
	public static void createOrUpdateOMDHCaseFromACF(TriggerParameters tp) {
        Map<Id,AdditionalCaseFields__c> mapNewACFCase = (Map<Id,AdditionalCaseFields__c>) tp.newMap;
        Map<Id,AdditionalCaseFields__c> mapOldACFCase = (Map<Id,AdditionalCaseFields__c>) tp.oldMap;
        Set<Id> acfIds = new Set<Id>();
        Id omRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Order Management Helpdesk').getRecordTypeId();
        Id deliveryRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Delivery Helpdesk').getRecordTypeId();
        Id retailRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Retail').getRecordTypeId();
        
        System.debug('Entering createOrUpdateOMDHChildCase');
        for(AdditionalCaseFields__c newACFCase: mapNewACFCase.values()) {
            AdditionalCaseFields__c oldACFCase = new AdditionalCaseFields__c();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                oldACFCase = mapOldACFCase.get(newACFCase.Id);
            }
            if(newACFCase.RecordTypeId == omRecordTypeId && 
               	((newACFCase.ChildCase__c == null && newACFCase.OMRegion__c != null 
                && newACFCase.SFDCContract__c != null && newACFCase.SAPContractOrder__c != null )
                || (newACFCase.ChildCase__c != null && 
                    (newACFCase.OMRegion__c != oldACFCase.OMRegion__c
                	|| newACFCase.SFDCContract__c != oldACFCase.SFDCContract__c
                	|| newACFCase.SAPContractOrder__c != oldACFCase.SAPContractOrder__c)))) {
                    //To create a child case, SFDCContract__c, SAPContractOrder__c, OMRegion__c should not be null. 
                    //To update, even if these fields are changed and even empty, update child case. 
                    acfIds.add(newACFCase.Id); 
            } else if (newACFCase.RecordTypeId == deliveryRecordTypeId && 
                		((newACFCase.ChildCase__c == null && newACFCase.DeliveryTeam__c != null)
                		||(newACFCase.ChildCase__c != null && 
                           	(newACFCase.DeliveryTeam__c != oldACFCase.DeliveryTeam__c
                			|| newACFCase.DocNumber__c != oldACFCase.DocNumber__c
                			|| newACFCase.SDONumber__c != oldACFCase.SDONumber__c
                			|| newACFCase.Subscription__c != oldACFCase.Subscription__c
                			|| newACFCase.GEDOrderInvoice__c != oldACFCase.GEDOrderInvoice__c
                			|| newACFCase.RMA__c != oldACFCase.RMA__c)))) {
                //To create a child case, DeliveryTeam__c should not be null. 
                //To update, if DeliveryTeam__c, DocNumber__c, SDONumber__c, RMA__c, GEDOrderInvoice__c, 
                //Subscription__c fields are changed and even empty, update child case. 
                acfIds.add(newACFCase.Id); 
            } else if (newACFCase.RecordTypeId == retailRecordTypeId && 
                       	((newACFCase.ChildCase__c == null && newACFCase.DeliveryTeam__c != null 
                			&& newACFCase.SDONumber__c != null && newACFCase.DocNumber__c != null )
                		||(newACFCase.ChildCase__c != null && 
                           	(newACFCase.DeliveryTeam__c != oldACFCase.DeliveryTeam__c
                			|| newACFCase.DocNumber__c != oldACFCase.DocNumber__c
                			|| newACFCase.SDONumber__c != oldACFCase.SDONumber__c
                			|| newACFCase.Subscription__c != oldACFCase.Subscription__c
                			|| newACFCase.GEDOrderInvoice__c != oldACFCase.GEDOrderInvoice__c
                			|| newACFCase.RMA__c != oldACFCase.RMA__c)))) {
                //To create a child case, DeliveryTeam__c,DocNumber__c,SDONumber__c should not be null. 
                //To update, if DeliveryTeam__c, DocNumber__c, SDONumber__c, RMA__c, GEDOrderInvoice__c,
                // Subscription__c fields are changed and even empty, update child case. 
                acfIds.add(newACFCase.Id); 
            }
        }
        System.debug('acfIds to get'+acfIds);
        if(!acfIds.isEmpty()) {
            Id ccRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName(). get('Customer Care').getRecordTypeId();
            Id omdhRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName(). get('Order Management/Delivery Help Desk').getRecordTypeId();
            List<Case> caseList = new List<Case>();
            for (AdditionalCaseFields__c acf: [select id, ChildCase__c, SFDCContract__c, OMRegion__c, SAPContractOrder__c, 
                	RecordTypeId, DeliveryTeam__c, DocNumber__c, GEDOrderInvoice__c, RMA__c, SDONumber__c, Subscription__c,
                 	Case__c, Case__r.Description, Case__r.BusinessHoursId, Case__r.AccountId, Case__r.ContactId, Case__r.subject
                	from AdditionalCaseFields__c where Id in : acfIds and 
                	Case__r.RecordTypeId =: ccRecordTypeId]) {
                Case childCase = new Case();
                if(acf.childCase__c == null ) {
                    //Some common code when case is created
                    childCase.BusinessHoursId = acf.Case__r.BusinessHoursId;
                    childCase.AccountReference__c = acf.Case__r.AccountId;
                    childCase.AdditionalFields__c = acf.Id;
                    childCase.ContactReference__c = acf.Case__r.ContactId;
                    childCase.CustomerCareInitiated__c = true;
                    childCase.Description = acf.Case__r.Description;
                    childCase.Origin = 'Case';
                    childCase.RecordTypeId = omdhRecordTypeId;
                    childCase.Subject = acf.Case__r.Subject;
                    childCase.ParentId = acf.Case__c;
                    childCase.OMDStatus__c = 'New';
                    if (acf.RecordTypeId == omRecordTypeId) {
                        childCase.TeamSelect__c = 'Order Management';
                    } else if (acf.RecordTypeId == deliveryRecordTypeId) {
                        childCase.TeamSelect__c = 'Delivery';
                    } else if (acf.RecordTypeId == retailRecordTypeId) {
                        childCase.TeamSelect__c = 'Retail';
                    }
                } else {
                    childCase.id = acf.ChildCase__c;
                }
                //Common code for edit and creation of child case
                if (acf.RecordTypeId == omRecordTypeId) {
                    childCase.Contract__c = acf.SFDCContract__c;
                    childCase.OrderManagementRegion__c = acf.OMRegion__c;
                    childCase.SAPContractOrder__c = acf.SAPContractOrder__c;
                } else { // Common for Retail and delviery
                    childCase.DeliveryTeam__c = acf.DeliveryTeam__c;
                    childCase.Doc__c = acf.DocNumber__c;
                    childCase.GEDOrderInvoice__c = acf.GEDOrderInvoice__c;
                    childCase.RMA__c = acf.RMA__c;
                    childCase.SDO__c = acf.SDONumber__c;
                    childCase.Subscription__c = acf.Subscription__c;
                }
                caseList.add(childCase);
            }
            //Update cases.
            if(!caseList.isEmpty()) {
                System.debug('cases to upsert'+caseList);
                upsert caseList;
            }
        }
        System.debug('Exiting populateDeliveryQueuesInCase');
    }
    
    public static void NotesMandatoryForResolvedbyIHSMarkitOPSTeam(TriggerParameters tp) {
        Map<Id,AdditionalCaseFields__c> mapNewACFCase = (Map<Id,AdditionalCaseFields__c>) tp.newMap;
        Id nrgRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('NRG').getRecordTypeId();
        Set<Id> caseSetId = new Set<Id>();
        for(AdditionalCaseFields__c acf: mapNewACFCase.values()) {
            if(acf.ResolvedbyIHSMarkitOPSTeam__c == 'Resolved by CC & OPS' && acf.RecordTypeId == nrgRecordTypeId) {
                if(acf.Case__c != null)
                caseSetId.add(acf.Case__c);
            }
        }
        if(caseSetId.size()>0) {
            Map<Id,Case> caseListMap = new Map<Id,Case>([Select id,(Select id from AttachedContentNotes) from case Where Id IN: caseSetId]);
            for(AdditionalCaseFields__c acfields: mapNewACFCase.values()) {
                if(caseListMap.get(acfields.Case__c).AttachedContentNotes.size()==0) {
                    acfields.addError('When "Resolved by CC & OPS" is selected in "Resolved by IHS Markit OPS" then Notes(at Case level) should be populated');
                }
            }   
        }
     }
}