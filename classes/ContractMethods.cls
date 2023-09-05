/**
* @author: Mohit Modi
* @date: 27 September 2017
* @description: SFDC1-4363. Before insert and Before update dispatcher event handler class that calls the functions in ContractMethods.
* @companyname: VERTIBA
* @LastModifiedby: Prachi Bhasin
* @ModifiedDate: 26 Feb 2018
* @description: SFDC1-4739: Adding preventContractDeletion method
* @LastModifiedby: Vishnu Vardhan, Ankita
* @ModifiedDate: 13 Mar 2018
* @description: SFDC1-4324, 4702, 7204: Adding new methods to execute after Update handler.
* @LastModifiedby: Mohit Modi
* @ModifiedDate: 24 April 2018
* @description: SFDC1-8059 : updated preventContractDeletion method, Removed all the profiles and added a reverse check for allowing only System Admin profile to delete the Contract.
* @author: Sruti Srivastava
* @date: 11th May 2018
* @description: SFDC1-7855-When an "Order Form" Contract record is updated "Completed" 
* the Opportunity should be updated to 6WP
*
* @ModifiedBy: Tran-Vu Tran
* @ModifiedDate: 22 May 2018
* @Description: implementation for SFDC1-7680 Update Countersignature Status and Countersignature Owner
* 				and SFDC1-8252 Update Contract Stage
* @ModifiedBy: Sruti Srivastava
* @ModifiedDate: 2 July 2018
* @Description: SFDC1-8960 - Update Contract Stage to "Complete", when Contract Status is updated to "Validated" for Consulting contracts
* @ModifiedBy: Jagadesh Kumar
* @ModifiedDate: 03 July 2018
* @Description: SFDC1-9020 - To validate the Case Account and Case->Contact->Account/Case->Contact->Related Accounts 
* @ModifiedBy: Tran-Vu Tran
* @ModifiedDate: 22 Oct 2018
* @ModifiedDescription: SFDC1-9347 add method to update Account Relationship according to related Opportunities and Contracts
* @ModifiedBy: Sruti Srivastava
* @ModifiedDate: 12 Oct 2018
* @Description: SFDC1-10185 - Contract should be complete and the Opportunity to 6WP when the Contract 
				has the Status "Validated PO Pending" 
* @Modified By : Sruti Srivastava
* @ModifiedDate: 30 Oct 2018
* @Description: SFDC1-10212: Update currency from Contract
* @modifiedby: Paras Dhingra
* @modifiedDate: 26th July 2019
* @modified description : SFDC-1358 Adding consulting record type to set Opportunity as 6WP when case is set to validated 
* @modifiedby : Paras Dhingra
* @modified date: 31st July 2019
* @modified description: Replacing channel partner formula fields ChannelPartnerCompanyName__c =>ChannelPartnerName__c and BPNum__c => ChannelPartnerBPNumber__c
* @Modified By : Paras Dhingra
* @Modified Date : 13th Oct 2020
* @Modified Description : SFDC-2723 Adding criteria to create OM Case when Auto Renewal flag is toggled
*/

public class ContractMethods {

    // Static reference to "Continuation Letter" Contract Record Type Id
    public static Id continuationLetterRecordTypeId {
        get {
            if (continuationLetterRecordTypeId == null) {
                continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
            }
            return continuationLetterRecordTypeId;
        }
        
        set;
    }
    
    // Static reference to "Order Form" Contract Record Type Id
    public static Id orderFormRecordTypeId {
        get {
            if (orderFormRecordTypeId == null) {
                orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            }
            return orderFormRecordTypeId;
        }
        
        set;
    }
    
    // Static reference to "Consulting" Contract Record Type Id
    public static Id consultingRecordTypeId {
        get {
            if (consultingRecordTypeId == null) {
                consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            }
            return consultingRecordTypeId;
        }
        
        set;
    }
    
    // Static reference to "Trial" Contract Record Type Id
    public static Id trialContractRecordTypeId {
        get {
            if (trialContractRecordTypeId == null) {
                trialContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
            }
            return trialContractRecordTypeId;
        }
        
        set;
    }
    
    // Static reference to "Renewal" Opportunity Record Type Id
    public static Id renewalOpportunityRecordTypeId {
        get {
            if (renewalOpportunityRecordTypeId == null) {
                renewalOpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            }
            return renewalOpportunityRecordTypeId;
        }
        
        set;
    }
    
	// create a Map of Loading grp Id vs Product grp Id from a Product record.
	static Map<Id,Set<Id>> loadingIdToProdGroupId = new Map<Id, Set<Id>>();
    
    /** 
    * @author: Mohit Modi
    * @date: 27 September 2017
    * @description: SFDC1-4363. When a Contract record is created/updated the Opportunity, Copy the Primary Contact Values to Contract Record
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @return: void
    */
    /** 
    * @author: Mohit Modi
    * @date: 27 September 2017
    * @description: SFDC1-4363. When a Contract record is created/updated the Opportunity, Copy the Primary Contact Values to Contract Record
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @LastModifiedby: Ayan Mohanty
    * @ModifiedDate: 14th Feb 2018
    * @description: SFDC1-6993: Removing BillToFaxNumber__c and ShipToFaxNumber__c instances
    * @return: void
    */
    public static void CopyPrimaryContactToContract(TriggerParameters tp) {
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
            tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
        {   
            set<id> setOpportunityid = new set<id>();
            List<Contract> listContracts = (List<Contract>) tp.newList;
            Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
            map<id,OpportunityContactRole> mapOpportunityIdOpportunityContactRole = new map<id,OpportunityContactRole>();

            //1. Collect all the OpportunityIds for the Contracts
            for(Contract Contractobj : listContracts ) {
                if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert && !String.isBlank(Contractobj.Opportunity__c))
                {
                    setOpportunityid.add(Contractobj.Opportunity__c);
                }
                if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate && !String.isBlank(Contractobj.Opportunity__c) &&
                    Contractobj.Opportunity__c != mapOldContract.get(Contractobj.id).Opportunity__c)
                {
                    setOpportunityid.add(Contractobj.Opportunity__c);
                }
            }
            
            if(!setOpportunityid.isEmpty())
            {
                // Quering the Opportunity Contact Role Records with Contact Values
                for( OpportunityContactRole OpportunityContactRoleobj : [select id,ContactId,IsPrimary,OpportunityId,Contact.FirstName,
                                                                           Contact.LastName,Contact.Fax,Contact.Email,Contact.Phone from OpportunityContactRole
                                                                           where IsPrimary = true AND OpportunityId in : setOpportunityid])
                {
                    mapOpportunityIdOpportunityContactRole.put(OpportunityContactRoleobj.OpportunityId ,OpportunityContactRoleobj);
                }
                
                for(Contract Contractobj : listContracts ) {
                    
                   if(mapOpportunityIdOpportunityContactRole.containskey(Contractobj.Opportunity__c))
                   {
                       // Adding Bill To Fields from Primary Contact to Contract
                       Contractobj.BillToContactEmailAddress__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.Email;
                       Contractobj.BillToContactFirstName__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.FirstName;
                       Contractobj.BillToContactLastName__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.LastName;
                       Contractobj.BillToContactTelephoneNumber__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.Phone;
                       //Contractobj.BillToFaxNumber__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.Fax;
                       
                       // Adding Ship To Fields from Primary Contact to Contract
                       Contractobj.ShipToContactEmailAddress__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.Email;
                       Contractobj.ShipToContactFirstName__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.FirstName;
                       Contractobj.ShipToContactLastName__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.LastName;
                       Contractobj.ShipToContactTelephoneNumber__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.Phone ;
                       //Contractobj.ShipToFaxNumber__c = mapOpportunityIdOpportunityContactRole.get(Contractobj.Opportunity__c).Contact.Fax;
                       
                   }
                }
            }
        }
    } 
    /** 
    * @author: Prachi Bhasin
    * @date: 26 Feb 2018
    * @description: SFDC1-4739- Do not allow certain profiles to delete contract.
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @return: void
    * @author : Mohit Modi
    * @description : SFDC1-8059 : Removed all the profiles and added a reverse check for allowing only System Admin profile to delete the Contract.
    * @date : 24 April 2018
    */
    public static void preventContractDeletion(TriggerParameters tp) {
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        system.debug('ProfileName'+profileName);
        List<Contract> listContracts = (List<Contract>) tp.oldList;
        for(Contract contractObj : listContracts ) {
            if(!profileName.contains('System Admin')){
                contractObj.addError('You are not authorized to Delete a Contract.');
            }
        }               
    }

    //-----------------------------
    // @author: Ankita Singh, Vishnu vardhan chowdary
    // @date: 13 March 2018
    // @description: SFDC1-4702, 7204, 4324 - Create child cases based on the contract status 'ReadyForProcessing'
    // 			and Record type. If the Contract is moved back to 'ReadyForProcessing' again, then dont recreate 
    // 			case, instead first check and then either create/ignore/delete the case.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @companyname: VERTIBA
    // @author: Vishnu Vardhan
    // @date: 13 April 2018
    // @description: SFDC-7826: Removing all the code written for 4702, 7204.
    // @author: Vishnu Vardhan
    // @date: 18 May 2018
    // @description: SFDC-7740: Adding the code for OF Contracts.
    // @author: Vishnu Vardhan
    // @date: 24 May 2018
    // @description: SFDC-4324: Changing code for Continuation letter Contracts. To get CLI from original contract
    // @author: Vishnu Vardhan
    // @date: 29 Jun 2018
    // @description: SFDC-8902, 8948: Populating new fields in implementation case
    // @Modified By : Vishnu Vardhan Chowdary Andra
    // @Modification Date: 13 Jul 2018
    // @Modification Description: SFDC1-9241 - If Contract Status is Scheduled Termination, then ignore existing
    // 				Impl cases and create new ones.
    // @Modified By : Vishnu Vardhan Chowdary Andra
    // @Modification Date: 24 Jul 2018
    // @Modification Description: SFDC1-9470 - If Contract Status is Validated PO Pending, then create imple cases
    // @Modified By : Vishnu Vardhan Chowdary Andra
    // @Modification Date: 16 OCT 2018
    // @Modification Description: SFDC1-10144 - OM Case generaetd with Contract Status Scheduled Termination is 
    // 		then moved to Validated PO Pending or Validated, then it was updating contract to same status and 
    // 		triggering the creating of impl cases and deletion of OM cases except one. As earlier assumption, was
    // 		only one OM case will be there. Now fixed it. 
    // @Modified By : Jagadesh Kumar
    // @Modification Date: 29 OCT 2018	
    // @Modification Description:SFDC1-10129-When renewal status to 6L, both OM and implementation case should not be created together.
    // @Modified By : Jagadesh Kumar
    // @Modification Date: 12 Nov 2018
    // @Modification Description:SFDC1-10373 exception handling changes added
    // @return: void
    //-----------------------------
    public static void createCaseFromContract(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {   
               List<Contract> listContracts = (List<Contract>) tp.newList;
               Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
               Set<ID> listFilteredContractId = new  Set<Id>();
               Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
               Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
               Id continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();

               for(Contract Contractobj : listContracts ) {
                   Contract oldContract = mapOldContract.get(Contractobj.id);
                   if(Contractobj.status != oldContract.status 
                      && Contractobj.status == 'ReadyForProcessing'
                      && (Contractobj.recordTypeId == trialRecordTypeId || Contractobj.recordTypeId == continuationLetterRecordTypeId)) {
                          listFilteredContractId.add(Contractobj.id);
                   }
               }
               if(listFilteredContractId.isEmpty()) {
                   System.debug('No Contracts to process');
                   return;
               }
               System.debug('Contracts to process '+listFilteredContractId);
               try {
               		validateAndCreateImplementationCase(listFilteredContractId);
               } catch(DMLException e) {
                    if(e.getMessage().contains(System.Label.CaseContactAndAccountMatchMSG)) {
                        ((List<Contract>) tp.newList).get(0).addError(System.Label.CaseContactAndAccountMatchMSG);
                    } else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                       ((List<Contract>) tp.newList).get(0).addError(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':'));  
                    } else {
                        ((List<Contract>) tp.newList).get(0).addError(e.getMessage());
                    }
                } catch (Exception e) {
                    UtilityClass.createApexLogRecord(e,'ContractMethods','createCaseFromContract'); 
                }
        }
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 29 Oct 2018
    // @description: Validate and Create implementation case and also SFDC1-10129 changes-method will be called from CaseMethod
    //               to Create 'Implementation' Case only when OM case is Validated AND Contract is 'Scheduled Termination'
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @companyname: VERTIBA
    // @Modified By : Jagadesh Kumar
    // @date: 21st Jan 2019
    // @description:SFDC1-10975:Added null check when OM case is moved to Validated/validated PO Pending and Oppty is 6L , Contract is 'Scheduled Termination' 
    // @Modified By : Harshit Singhal
    // @date: 26 Feb 2019
    // @description: SFDC-662: Chenged contracts query to include RecordType and ContractStatus
    // @LastModified By: Harshit Singhal
	// @LastModified Date: 04 Nov 2019
	// @LastModified Description: SFDC-1863: Modifications for Implementation cases created for IHS Trials
	// @LastModified By: Dev Aggarwal
	// @LastModified Date: 13 February 2020
	// @LastModified Description: SFDC-1625: Commented out the code for Deletion.
	// @Modified By : Paras Dhingra
	// @Modified Date : 13th Oct 2020
	// @Modified Description : SFDC-2723 Adding criteria to remove Auto renewal stopped type OM cases from the query
    // -------------------------
	public static void validateAndCreateImplementationCase(Set<Id> listFilteredContractId) {
        Id implementationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Implementation').getRecordTypeId();
        Id orderManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId(); 
        Id continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();       
        Map<string,id> caseQueue = new Map<string, id>();
        List<Case> caseToBeInserted = new List<Case>();
        List<Case> caseToBeDeleted = new List<Case>();
		Map<Id,List<TriageCriteria__c>> mapLoadingGrpToTrc = new Map<Id, List<TriageCriteria__c>>();
        Map <String,List<String>> mapLoadgrpCategoryToCtrctRT = new Map <String,List<String>>();
        
        //List of contracts that will be processed, Closed cases can be ignored.
        List <Contract> contractList = [select id, accountId, account.Name,account.Type, StartDate, EndDate, recordTypeId, recordType.Name, OriginalContract__c, OriginalContract__r.RecordTypeId, ContractNumber, ContractStatus__c, Opportunity__r.RecordTypeId,
                                        (Select ContactId from ContractContactRoles where IsPrimary = true limit 1),
                                        (select id, recordTypeId, LoadingGroupOnboarding__c, isClosed from Cases__r where recordTypeId in (:implementationRecordTypeId, :orderManagementRecordTypeId) and Type != 'Auto Renewal Stopped change' order by lastModifiedDate)
                                        FROM Contract where id IN: listFilteredContractId];
        listFilteredContractId = new Set<id>();
        //Prepare list of Contract ids from which loading group will be taken
        //Map<Id,String> acctTypeMap = new Map<Id,String>();//AccountId and Account Type Map Used while insert Implementation case Type records
        for(Contract ctrct: contractList) {
            if(ctrct.recordTypeId != continuationLetterRecordTypeId) {
                listFilteredContractId.add(ctrct.id);
            }
            else if(ctrct.recordTypeId == continuationLetterRecordTypeId && ctrct.OriginalContract__c != null && ctrct.OriginalContract__r.RecordTypeId == orderFormRecordTypeId) {
                listFilteredContractId.add(ctrct.OriginalContract__c);
            }
            //acctTypeMap.put(ctrct.accountId,ctrct.account.Type);
        }
		Map<id,Contract> contractMap = new Map<id, Contract>([select id,ContractStatus__c,RecordTypeId,
                                              (Select id, associatedProduct__r.Name, associatedProduct__r.loadingGroup__c, associatedProduct__r.loadingGroup__r.name, associatedProduct__r.loadingGroup__r.loadingGroupCategory__c, associatedProduct__r.loadingGroup__r.DeliveryTeam__c,Status__c,associatedProduct__r.ProductGroup__c From Contract_Line_Items__r) 
                                              FROM Contract where id IN: listFilteredContractId]);
        
        //SFDC-3388 Implementation Case assignment
        for (TriageCriteria__c trc : caseMethodHelperForQueries.allTriageList) {
            if (trc.loadinggroup__c != null && trc.queue__c != null && trc.ContractRecordType__c != null) {
               if (!mapLoadgrpCategoryToCtrctRT.containsKey(trc.LoadingGroupCategory__c)) {
                    mapLoadgrpCategoryToCtrctRT.put(trc.LoadingGroupCategory__c, new List<String>());
                } 
                mapLoadgrpCategoryToCtrctRT.get(trc.LoadingGroupCategory__c).add(trc.ContractRecordType__c); 
                if  (!mapLoadingGrpToTrc.containsKey(trc.loadinggroup__c)) {
                    mapLoadingGrpToTrc.put(trc.loadinggroup__c, new List<TriageCriteria__c>());
                }
                mapLoadingGrpToTrc.get(trc.loadinggroup__c).add(trc);
            }    
        }
		
        //Get Queues for case ownership
        Set<String> queueNameSet = new Set<String>();
        queueNameSet.add(Label.DefaultQueueMarkitImplCase);
        queueNameSet.add(Label.DefaultQueueIHSImplCaseTrials);
        queueNameSet.add(Label.DefaultQueueIHSImplCaseContinuation);
        
        for(Group g : [select Id,Name,DEVELOPERNAME from Group where Type = 'Queue' ]) {//AND DEVELOPERNAME in :queueNameSet]) {
            caseQueue.put(g.Name,g.id);
        }

        for(Contract ctrct: contractList) {
            List<Case> existingCaseList = ctrct.Cases__r;
            Map<id,Case> casesToRemove = new Map<id,Case>(ctrct.Cases__r);
            Id parentCaseId = null;
            Id caseOwnerId;
			
            if(ctrct.RecordTypeId == orderFormRecordTypeId && ctrct.ContractStatus__c == 'Scheduled Termination') {
                existingCaseList = null;//If Scheduled Termination is the status then ignore existing cases. Create new.
            }
            if((ctrct.RecordTypeId == orderFormRecordTypeId || (ctrct.recordTypeId == continuationLetterRecordTypeId && ctrct.OriginalContract__c != null && ctrct.OriginalContract__r.RecordTypeId == orderFormRecordTypeId)) && existingCaseList != null && !existingCaseList.isEmpty()) {
                for(Integer i=0; i<existingCaseList.size();i++) {
                    case tempCase = existingCaseList.get(i);
                    if(tempCase.recordTypeId == orderManagementRecordTypeId) {
                        //Om case will be used as parent case for all newly created cases.
                        //After entire process is done, left over cases will be deleted. So, removing OM cases.
                        //ordering by modified date, this will give us, which case triggered this update.
                        //parentCaseId = existingCaseList.remove(i).Id;
                        parentCaseId = existingCaseList[i].id;
                        casesToRemove.remove(existingCaseList[i].id);
                        //break;//removing the break as there can be more than one OM case
                    } else if (tempCase.recordTypeId == implementationRecordTypeId && tempCase.IsClosed) {
                        //Moving the condition from query as OM cases will be in closed status.
                        //Also any closed IMPL cases should be ignored, as they might have been 
                        //created from earlier OM cases.
                       // existingCaseList.remove(i);
                       casesToRemove.remove(existingCaseList[i].id);
                    }
                }
            }
            if(existingCaseList != null) {
                existingCaseList.clear();
                existingCaseList.addall(casesToRemove.values());
        	}
            //Existing cases for the contract will be transferred into a map where 
            //Key is loading group id or OMRecord for order form with IHS and values as cases
            Map<String,Case> loadingIdToCaseMap = createLoadingIdToCaseMap (existingCaseList);
            System.debug('loading Id To Case Map:'+loadingIdToCaseMap);
            
            Map<Id, List<String>> loadingIdProductMap = new Map<Id, List<String>>();
            //get all the available loading groups for this contract. if Contract is CL then get from related contract.
            Map<String,Set<Id>> loadingGroups = new Map<String, Set<Id>>();
            if(ctrct.recordTypeId != continuationLetterRecordTypeId) {
                loadingGroups = getLoadingGroupCategoriesForThisContract(contractMap.get(ctrct.id), false);
                loadingIdProductMap = getLoadingIdToProductMap(contractMap.get(ctrct.id), false);
            }
            else if(ctrct.recordTypeId == continuationLetterRecordTypeId && ctrct.OriginalContract__c != null && ctrct.OriginalContract__r.RecordTypeId == orderFormRecordTypeId) {
                loadingGroups = getLoadingGroupCategoriesForThisContract(contractMap.get(ctrct.OriginalContract__c), true);
                loadingIdProductMap = getLoadingIdToProductMap(contractMap.get(ctrct.OriginalContract__c), true);
            }
            System.debug('Contract will have cases for:'+loadingGroups);
            
            /* Create Implementation case for each loading group
            // If two products belongs to same loading group, create 1 Imp case 
            // If two products belongs to different loading group, create 2 Imp cases*/
            for (String loadingGrpCatrgy : loadingGroups.keySet()) {
                System.debug('$$ loadingGrpCatrgy--'+loadingGrpCatrgy);
                Set<Id> loadingGroupIds = loadingGroups.get(loadingGrpCatrgy);
                for(Id loadingGroupId : loadingGroupIds) {
                    System.debug('$$ loading group id-'+loadingGroupId);                    
                    if (mapLoadingGrpToTrc.containsKey(loadingGroupId)) {
                        List<TriageCriteria__c> trgList= mapLoadingGrpToTrc.get(loadingGroupId);
                        for(TriageCriteria__c trc:trgList){
                            if(trc.ContractRecordType__c.containsIgnoreCase(ctrct.recordType.Name)) { 
                            System.debug('$$ Valid loading group id-'+loadingGroupId);
                            Case cas = loadingIdToCaseMap.remove(loadingGroupId);
                            //SFDC-3388- Get queue Id from Triage Criteria
                            String QueueName= trc.Queue__c;
                            caseOwnerId = getQueueId(QueueName,caseQueue); 
                            if(cas == null) { //Then create new case, else continue
                                cas = createCase (ctrct, caseOwnerId, implementationRecordTypeId, 
                                                  loadingGroupId, parentCaseId, loadingIdProductMap.get(loadingGroupId), loadingGrpCatrgy, loadingIdToProdGroupId.get(loadingGroupId));
                                System.debug('Adding case'+cas);
                                caseToBeInserted.add(cas);
                            }
                        }  
                        }
                          
                }
                }    
					                
				
			}
            /*
            if (loadingGroups.containsKey(Label.MarkitLoadingGrpCategory)) {
                if(ctrct.recordTypeId != continuationLetterRecordTypeId) {
                    System.debug('have a markit case ');
                    Set<Id> loadingGroupIds = loadingGroups.get(Label.MarkitLoadingGrpCategory);
                    //4324, 7740 - (If the loading Group names/record id are same AND Loading Group Category == "Markit"), then create only ONE Implementation Case (child case)
                    //4324, 7740 - (If the loading Group names/record id are not same AND Loading Group Category == "Markit") , Create an Implementation Case (child Case) for every Loading Group
                    for(Id loadingGroupId : loadingGroupIds) {
                        System.debug('have a markit case for loading group id'+loadingGroupId);
                        Case cas = loadingIdToCaseMap.remove(loadingGroupId);
                        if(cas == null) { //Then create new case, else continue
                            cas = createCase (ctrct, caseQueue.get(Label.DefaultQueueMarkitImplCase), implementationRecordTypeId, 
                                              loadingGroupId, parentCaseId, loadingIdProductMap.get(loadingGroupId), Label.MarkitLoadingGrpCategory);
                            //cas.Type = caseType;
                            System.debug('Adding case for Markit'+cas);
                            caseToBeInserted.add(cas);
                        }
                    }    
                }                
            } 
            if (loadingGroups.containsKey(Label.IHSLoadingGrpCategory)) {
                //7740 - If the Loading Group Category == "IHS", then as of now ignore, 
                if(ctrct.recordTypeId == orderFormRecordTypeId) {
                    continue;
                } else {
                    System.debug('have a IHS case for loading group id');
                    Set<Id> loadingGroupIds = loadingGroups.get(Label.IHSLoadingGrpCategory);
                    //4324 - (If the loading Group names/record id are same AND Loading Group Category == "IHS"), then create only ONE Implementation Case (child case)
                    //4324 - (If the loading Group names/record id are not same AND Loading Group Category == "IHS") , Create an Implementation Case (child Case) for every Loading Group
                    for(Id loadingGroupId : loadingGroupIds) {
                        Case cas = loadingIdToCaseMap.remove(loadingGroupId);
                        System.debug('have a IHS case for '+loadingGroupId);
                        if(cas == null) { //Then create new case, else continue
                            System.debug('Adding case for IHS2'+cas);
                            
                            //Set owner of case based on contract record type
                            Id ownerId; 
                            if(ctrct.recordTypeId == continuationLetterRecordTypeId) {
                                ownerId = caseQueue.get(Label.DefaultQueueIHSImplCaseContinuation);
                            }
                            else {
                                ownerId = caseQueue.get(Label.DefaultQueueIHSImplCaseTrials);
                            }
                            cas = createCase (ctrct, ownerId, implementationRecordTypeId,loadingGroupId, parentCaseId, loadingIdProductMap.get(loadingGroupId), Label.IHSLoadingGrpCategory);                            
                            caseToBeInserted.add(cas);
                        }
                    }
                }
            }
            if (loadingGroups.containsKey(Label.CalgaryLoadingGrpCategory)) {
                if(ctrct.RecordTypeId == trialRecordTypeId) {
                    Set<Id> loadingGroupIds = loadingGroups.get(Label.CalgaryLoadingGrpCategory);
                    for(Id loadingGroupId : loadingGroupIds) {
                        Case cas = loadingIdToCaseMap.remove(loadingGroupId);
                        if(cas == null) {
                            cas = createCase (ctrct, caseQueue.get(Label.DefaultQueueIHSImplCaseTrials), implementationRecordTypeId,loadingGroupId, parentCaseId, loadingIdProductMap.get(loadingGroupId), Label.CalgaryLoadingGrpCategory);
                            caseToBeInserted.add(cas);
                        }
                    }    
                }
                
            }
            */
            if(!loadingIdToCaseMap.values().isEmpty()) {
                caseToBeDeleted.addAll(loadingIdToCaseMap.values());
            }
        }
		System.debug('Cases that will be deleted: '+caseToBeDeleted);
        if(caseToBeDeleted != null && !caseToBeDeleted.isEmpty()) {
            //delete caseToBeDeleted;
        }
		if(caseToBeInserted != null && !caseToBeInserted.isEmpty()) {
            //SFDC1-9020 Before insert validate the Implementation Case Records, 
            //Whether Case Account and Case Contact Account and Case Contact Related Accounts match.
            //SFDC1-10754: removing the related account validation.
            //CaseMethods.validateCaseContactAndAccount(caseToBeInserted,acctTypeMap);
            //set this to true,so that it will not re validate the implementation case records in CaseMethods while insertion.
            //GlobalConstants.hasImplementationCaseValidated = true;
            System.debug('Cases that will be created:'+caseToBeInserted);
            insert caseToBeInserted;
        }        
    }    
    //-----------------------------
	// @Author : Vishnu Vardhan Chowdary Andra
	// @Date : 13 Mar 2018
	// @Description : This method takes a Contract record, owner id, record type id and returns a case record
	// @param : Contract record, Owner Id, case record Type Id
    // @author: Vishnu Vardhan
    // @date: 29 Jun 2018
    // @description: SFDC-8902, 8948: Populating new fields in implementation case
	// @return : case
	// 
	// @LastModified By: Harshit Singhal
	// @LastModified Date: 02-May-2019
	// @LastModified Description: SFDC-1024: Update Type(For Renewals) and Description(For Renewals & New Business) for Implementation cases getting created on OM case validation
	// 
	// @LastModified By: Harshit Singhal
	// @LastModified Date: 04 Nov 2019
	// @LastModified Description: SFDC-1863: Modifications for Implementation cases created for IHS Trials
	// @Modified By : Paras Dhingra
    // @Modification Date: 1st May 2020
    // @Modification Description:SFDC-2873: Add Validated-POD Pending with Validated PO Pending conditions
	//-----------------------------
    private static Case createCase (Contract ctrct, Id ownerId, Id recordId, Id loadingGroupId,Id parentCaseId, List<String> productNames, String loadingGrpCategory, Set<Id> prodGrpIds) {
        Case cas = new Case();
        cas.RecordTypeId = recordId;
        cas.LoadingGroupOnboarding__c = loadingGroupId;
        cas.AccountId = ctrct.AccountId;
        cas.Contract__c = ctrct.id;	
        cas.OwnerId = ownerId;
        cas.Status = 'New';
        cas.Origin = 'Internal';        
        cas.ParentId = parentCaseId;
        cas.ContractStartDate__c = ctrct.StartDate;
        cas.ContractEndDate__c = ctrct.EndDate;
        if(!ctrct.ContractContactRoles.isEmpty()) {
            cas.ContactId = ctrct.ContractContactRoles.get(0).ContactId;
        }
        //SFDC-4279 If there is only 1 product group corresponding to its Loading grp
        //Then- update the loading group on Imp case
        //else- let product group as blank if multiple product groups found
		cas.ProductGroup__c = prodGrpIds.size() == 1 ? new list<Id>(prodGrpIds)[0] : null;
		
      	
        //Set subject of Implementation case
        cas.Subject = ctrct.ContractNumber+ ' for '+ctrct.Account.Name;
        if(ctrct.RecordTypeId == ContractMethods.continuationLetterRecordTypeId  || (ctrct.RecordTypeId == ContractMethods.trialContractRecordTypeId && (loadingGrpCategory == Label.IHSLoadingGrpCategory || loadingGrpCategory == Label.CalgaryLoadingGrpCategory))) {
            cas.Subject = 'Delivery Team POD - ' + cas.Subject;
        }
        if(!productNames.isEmpty()) {            
            //Update subject to add loading group
            cas.Subject = cas.Subject + ' - '+ productNames.remove(0);
            
            //Set Description field on Implementation Case
            String description ;
            if(ctrct.ContractStatus__c == 'Scheduled Termination') {
                description = 'Please terminate access for the following products as per Closed Lost Renewal - {'+ ctrct.ContractNumber +'}\r\n';    
            } else {
                if (ctrct.RecordTypeId == ContractMethods.trialContractRecordTypeId && loadingGrpCategory == 'Markit') {
                    description = 'A trial has been submitted for the following products: \r\n';    
                }
                else if(ctrct.RecordTypeId == ContractMethods.continuationLetterRecordTypeId || (ctrct.RecordTypeId == ContractMethods.trialContractRecordTypeId && (loadingGrpCategory == Label.IHSLoadingGrpCategory || loadingGrpCategory == Label.CalgaryLoadingGrpCategory))) {
                    description = 'Please attach POD for the following products: \r\n';    
                }
                else {
                    description = 'Proof of Delivery is required for subscription products only.  In order to close this case, you must attach the Proof of Delivery if there are any subscription products listed below: \r\n';
                }
            }
            for(String pName : productNames) {
        		description = description + '\r\n' + pName;
        	}
            cas.Description = description;
            
            //Set Type field on Implementation Case
            String caseType='';
            if (ctrct.RecordTypeId == ContractMethods.trialContractRecordTypeId) {
                caseType = 'Trial';
            } 
            else if (ctrct.RecordTypeId == ContractMethods.orderFormRecordTypeId) {
                if(ctrct.ContractStatus__c == 'Validated' || ctrct.ContractStatus__c == 'Validated PO Pending' || ctrct.ContractStatus__c == 'Validated-POD Pending') {
                    caseType = ctrct.Opportunity__r.RecordTypeId == ContractMethods.renewalOpportunityRecordTypeId ? 'New Renewal Product' : 'New Contract';
                }
                else if (ctrct.ContractStatus__c == 'Scheduled Termination') {
                    caseType = 'Scheduled Termination';
                }
            }
            else if(ctrct.RecordTypeId == ContractMethods.continuationLetterRecordTypeId) {
                caseType = 'Continuation';
            }
            cas.Type = caseType;
        }
        return cas;
    }

	//-----------------------------
	// @Author : Vishnu Vardhan Chowdary Andra
	// @Date : 13 Mar 2018
	// @Description : This method takes a Contract record, as input and returns a set of loading group categories.
	// 			1. From Contract, get Contract Line items.
	// 			2. From each contract line item, get an associated product and from it, a loading group record.
	// 			3. In each loading group record there is a loading group category (either IHS or Markit).
	// @param : Contract record
	// @return : Map<String,Set<Id>>
	// @Modified By : Harshit Singhal
    // @date: 26 Feb 2019
    // @description: SFDC-662: Added conditions to consider only 'New' contract line items for 'Order Form' contracts in 'Validated' or 'Validated PO Pending' status
	// @Modified By : Paras Dhingra
    // @Modification Date: 1st May 2020
    // @Modification Description:SFDC-2873: Add Validated-POD Pending with Validated PO Pending conditions
	//-----------------------------
    private static Map<String,Set<Id>> getLoadingGroupCategoriesForThisContract (Contract contractObj, Boolean isSourceContinuation) {
        Map<String,Set<Id>> loadingGroups = new Map<String,Set<Id>>();
        List<ContractLineItem__c> cliLst = contractObj.Contract_Line_Items__r;
        System.debug('All Contract Line items '+ cliLst);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
		if(cliLst!=null && !cliLst.isEmpty()) {
            for (ContractLineItem__c cli : cliLst) {
                System.debug('Line item '+ cli);
                Boolean skipCLI = false;
				//For order form contracts with Contract Status as 'Validated' or 'Validated PO Pending', collect loading groups of only NEW contract line items otherwise skip line item
				//SFDC-3401- Create Implemntn cases for NEW/Existing CLI Status
                if(!isSourceContinuation && contractObj.RecordTypeId == orderFormRecordTypeId && (contractObj.ContractStatus__c == 'Validated' || contractObj.ContractStatus__c == 'Validated PO Pending' || contractObj.ContractStatus__c == 'Validated-POD Pending') && !System.Label.CLIStatus.containsIgnoreCase(cli.Status__c)) {
					skipCLI = true;
				}
				if (cli.AssociatedProduct__c!=null && cli.AssociatedProduct__r.LoadingGroup__c!=null && !skipCLI) {
                    if(!loadingGroups.containsKey(cli.AssociatedProduct__r.LoadingGroup__r.LoadingGroupCategory__c)) {
                        loadingGroups.put(cli.AssociatedProduct__r.LoadingGroup__r.LoadingGroupCategory__c, new Set<Id>());
                    }
                    Set<Id> loadingGroupIds = loadingGroups.get(cli.AssociatedProduct__r.LoadingGroup__r.LoadingGroupCategory__c);
                    loadingGroupIds.add(cli.AssociatedProduct__r.LoadingGroup__c);
                    loadingGroups.put(cli.AssociatedProduct__r.LoadingGroup__r.LoadingGroupCategory__c, loadingGroupIds);
                } //else{//BSA's are pretty sure, we dont end here. Every CLI will have associated product, and loading group}
            }
        }
        return loadingGroups;
    }

    //-----------------------------
	// @Author : Vishnu Vardhan Chowdary Andra
	// @Date : 28 Jun 2018
	// @Description : This method takes a Contract record, as input and returns a Map with keys as loading group ids.
	// 			Keys as product names and loading group name from the contract line item. 
	// @param : Contract record
	// @return : Map<Id,Set<String>>
	// @Modified By : Harshit Singhal
    // @date: 26 Feb 2019
    // @description: SFDC-662: Added conditions to consider only 'New' contract line items for 'Order Form' contracts in 'Validated' or 'Validated PO Pending' status
    // @Modified By : Neelam Agrawal
    // @date: 04 Jan 2022
    // @description: SFDC-5508: Added conditions to generate implementation cases for continuation and trial contract
	//-----------------------------
    private static Map<Id,List<String>> getLoadingIdToProductMap (Contract contractObj, Boolean isSourceContinuation) {
        Map<Id,List<String>> loadingGroups = new Map<Id,List<String>>();
        List<ContractLineItem__c> cliLst = contractObj.Contract_Line_Items__r;
        System.debug('All Contract Line items '+ cliLst);
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        if(cliLst!=null && !cliLst.isEmpty()) {
            for (ContractLineItem__c cli : cliLst) {
                System.debug('Line item '+ cli);
                Boolean skipCLI = false;
				//For order form contracts with Contract Status as 'Validated' or 'Validated PO Pending', collect loading groups of only NEW contract line items otherwise skip line item
				//SFDC-3401- Create Implemntn cases for NEW/Existing CLI Status
                if(!isSourceContinuation && contractObj.RecordTypeId == orderFormRecordTypeId && (contractObj.ContractStatus__c == 'Validated' || contractObj.ContractStatus__c == 'Validated PO Pending' || contractObj.ContractStatus__c == 'Validated-POD Pending') && !System.Label.CLIStatus.containsIgnoreCase(cli.Status__c)) {
					skipCLI = true;
				}
                
                if (cli.AssociatedProduct__c!=null && cli.AssociatedProduct__r.LoadingGroup__c!=null && !skipCLI) {
                    List<String> productNames = loadingGroups.get(cli.AssociatedProduct__r.LoadingGroup__c);
                    if(productNames == null) {
                        productNames = new List<String>();
                        //Adding loading group name as 0 element as it is required in Subject
                        productNames.add(cli.AssociatedProduct__r.LoadingGroup__r.Name);
                    } 
                    if (!productNames.contains(cli.AssociatedProduct__r.Name)) {
                        productNames.add(cli.AssociatedProduct__r.Name);
                    }
                    loadingGroups.put(cli.AssociatedProduct__r.LoadingGroup__c, productNames);
                } //else{//BSA's are pretty sure, we dont end here. Every CLI will have associated product, and loading group}
				
                //SFDC-4279 - Creating a Map to hold LoadingGrp Id with Set Of ProductGrp Ids.
				if (cli.AssociatedProduct__c!=null && cli.AssociatedProduct__r.LoadingGroup__c!=null && cli.AssociatedProduct__r.ProductGroup__c != null) {
				  	if (loadingIdToProdGroupId.containsKey(cli.AssociatedProduct__r.LoadingGroup__c)) {
                       loadingIdToProdGroupId.get(cli.AssociatedProduct__r.LoadingGroup__c).add(cli.AssociatedProduct__r.ProductGroup__c);
					} else {
						loadingIdToProdGroupId.put(cli.AssociatedProduct__r.LoadingGroup__c, new Set<Id>{cli.AssociatedProduct__r.ProductGroup__c });
				    }
				}	
            }
        }
        return loadingGroups;
    }
	
	
    //-----------------------------
	// @Author : Vishnu Vardhan Chowdary Andra
	// @Date : 13 Mar 2018
	// @Description : This method takes a caseList List and creates a map with LoadingId, case.
	// 			This will help in verifying if a case has been already created for a specific criteria or not.
	// @param : caseList
	// @return : Map<String,Case>
    //-----------------------------
    private static Map<String,Case> createLoadingIdToCaseMap (List<Case> caseList) {
        Map<String,Case> caseMap = new Map<String,Case>();
        if(caseList != null && !caseList.isEmpty()) {
            for(Case c : caseList) {
                if(c.LoadingGroupOnboarding__c!=null) {
                    caseMap.put(c.LoadingGroupOnboarding__c, c);
                } else {
                    //We create only one case, for all the IHS loading group records in order form contract, 
                    //So, we dont have loading group in the case record. 
                    caseMap.put('OMRecord', c);
                }
            }
        }
        return caseMap;
    }
    
    //-----------------------------
	// @Author : Sharique Iqbal
	// @Date : 8th Nov 2021
	// @Description : This method fetches the Queue Name Based on TriageCriteria__c
	// @param : Id and Map
	// @Author : Neelam Agrawal
	// @Date : 4th Jan 2022
	// @Description : SFDC-5508: Optimized method
	// @return : String
    //-----------------------------
    private static String getQueueId (String QueueName, Map<string,id> caseQueue) {
        String queueId = '';
		if (caseQueue.containsKey(queueName)) {
		    queueId = caseQueue.get(QueueName);
		} 	
		System.debug('$$$queueId-'+queueId);
       return queueId;
    }
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 26 April 2018
    // @description: SFDC1-7488 Updating opportunity and case when ContractRejectionPastDue__c is set to true by Time trigger after 10 days
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @companyname: VERTIBA
    // @return: void
    // @companyname: VERTIBA
    // @LastModifiedby: Prachi Bhasin
    // @ModifiedDate: 14 Aug 2018
    // @description: SFDC1-8959: Rejection process for Consulting record type
    //-----------------------------
    public static void updateCaseAndOppoStatusContract(TriggerParameters tp) { 
        // Initializing variables
        List<Contract> listContracts = (List<Contract>) tp.newList;
        Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
		Set<Id> opportunityId = new Set<Id>();
		Set<Id> caseId = new Set<Id>();
		List<Opportunity> oppoList = new List<Opportunity>();
		List<Case> caseList = new List<Case>();
		List<sObject> recordsToUpdate = new List<sObject>();
        String oppRecordTypeRenewal = 'Renewal';
        String oppRecordTypeNewB = 'NewBusiness';
        String oppRecordTypeIY = 'InnerYear';
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        // fetching relevant ids to fetch case and opportunity associated with contract
        for(Contract c : listContracts) {
            Boolean ContRejecnPastDueOld = mapOldContract.get(c.id).ContractRejectionPastDue__c;          
            if(c.ContractRejectionPastDue__c == TRUE &&
               ContRejecnPastDueOld != c.ContractRejectionPastDue__c &&
              (c.RecordTypeId == orderFormRecordTypeId || c.RecordTypeId == consultingRecordTypeId)) {
                    opportunityId.add(c.Opportunity__c);
                    caseId.add(c.Id);
            }   
        }
        // Opportunity stage change for relevant record
        System.debug('$$$ SOQL COunt-1-'+ Limits.getQueries()); 
        if(opportunityId.size() > 0 && opportunityId != null) {
            oppoList = [Select Id , StageName , recordType.DeveloperName from Opportunity where Id In:opportunityId];
            if(oppoList.size()>0) {
                
                for(Opportunity o : oppoList) {
                    if(o.recordType.DeveloperName == oppRecordTypeRenewal || o.recordType.DeveloperName == oppRecordTypeIY) {
                        o.StageName = '5-Renewal Contracting';
                        recordsToUpdate.add(o);
                    } 
                    else if(o.recordType.DeveloperName == oppRecordTypeNewB) {
                        o.StageName = '5-Contracting';
                        recordsToUpdate.add(o);
                    }
                }
            }
        }
        // case status change for relevant record of record type Order Management
        // SFDC-1882 Order Management Case should not move to 'canceled' status
        /**if(caseId.size() > 0 && caseId != null) {
            caseList = [Select Id , Status from Case where Contract__c In:caseId AND recordType.name = 'Order Management' AND Status='Rejected' ];
            if(caseList.size()>0) {
               for(Case c : caseList) {
                       c.status = 'Canceled';  
                       recordsToUpdate.add(c); 
               }
                
            }
        }**/
        try {
            if(recordsToUpdate.size()>0) {
                update recordsToUpdate;
            }
        }
        catch(Exception e) {
            UtilityClass.createApexLogRecord(e,'ContractMethods','updateCaseAndOppoStatusContract');
        }
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 6 May 2019
    // @description: SFDC-1431: Method to get map of Contract Id and a String('Yes'/'No') which signifies if the contract is Variable/Volume based.
    // @param: TriggerParameters Contains the set of contract Ids
    // @return: Map<Id,String> where key is ContractId and value is 
    //-----------------------------
    public static Map<Id,String> checkVolumeVariableBillingContract(Set<Id> contractIdSet) {        
        Map<Id,String> contractIdIsVarVolContrctMap = new Map<Id,String>();
        if(contractIdSet!=null && contractIdSet.size()>0) {
            for(ContractLineItem__c cli: [SELECT Id, AssociatedProduct__r.AAG__c, Contract__c,
                                          (SELECT Id FROM BillingScheduleLineItems__r LIMIT 1)
                                          FROM ContractLineItem__c 
                                          WHERE Contract__c IN :contractIdSet ORDER BY Contract__c]) {
                if(!contractIdIsVarVolContrctMap.containsKey(cli.Contract__c) || (contractIdIsVarVolContrctMap.containsKey(cli.Contract__c) && contractIdIsVarVolContrctMap.get(cli.Contract__c)=='No')) {
                    String isVarVolBillingContract = 'No';
                    if(cli.AssociatedProduct__r.AAG__c=='SubscriptionVar' || (cli.BillingScheduleLineItems__r!=null && cli.BillingScheduleLineItems__r.size()>0)) {
                        isVarVolBillingContract='Yes';
                    }
                    contractIdIsVarVolContrctMap.put(cli.Contract__c,isVarVolBillingContract);
                }
            }
        }
        return contractIdIsVarVolContrctMap;
    }
    
    //-----------------------------
    // @Author : Vishnu Vardhan Chowdary Andra
    // @Date : 10 May 2018
    // @Description : SFDC1-7738: When order form contract is moved to Ready For Processing status.
    // 			then If OM case already exists, and have status as rejected then update status to 'Updated'. 
    // 			     If exists and status is different then update all fields from Contract and other related fields.
    // 			     Else create a new one and update all fields from Contract and other related fields.
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    // @Modified By : Ankita Singh
    // @Modification Date: 22nd May 2018
    // @Modification Discription: SFDC1-6735: Added Contract record type 'Consulting' to the existing functionality which creates OM CASES.
    // @Modified By : Vishnu Vardhan Chowdary Andra
    // @Modification Date: 23rd May 2018
    // @Modification Discription: SFDC1-8262: Removing Contract Owner, as the field has to be recreatd to change lookup type
    // @Modified By : Tran-Vu Tran
    // @Modification Date: 29 May 2018
    // @Modification Discription: Update logic to use the new Opportunity's ComplianceRestrictions__c formula field
    //                            instead of Account's ComplianceRestrictions__c picklist field
    // @Modified By : Prachi Bhasin
    // @Modification Date: 8 Jun 2018
    // @Modification Discription: SFDC1-8691: Adding subject to case record being created / updated
    // @Modified By : Vishnu Vardhan Chowdary Andra
    // @Modification Date: 14 Jun 2018
    // @Modification Discription: SFDC1-8775: Changing field from Text to Currency, Since Cant change the field used
    //				in text, creating a new field and using it here.
    // @Modified By : Vishnu Vardhan Chowdary Andra
    // @Modification Date: 18 Jun 2018
    // @Modification Discription: SFDC1-7738: Changing the owner to Order Management Queue.
    // @Modified By : Anjani Shukla
    // @Modification Date: 03 Jul 2018
    // @Modification Description: SFDC1-7992 -Generate OM Case for Closed Lost Renewal
    // @Modified By : Prachi Bhasin
    // @Modification Date: 27 Jul 2018
    // @Modification Discription: SFDC1-9505: Populating PO required field on OM case. 
    // @Modified By : Jagadesh Kumar
    // @Modification Date: 08 Oct 2018
    // @Modification Description: SFDC1-10090: Populating OM Case LostReasoncode, Lost Reason description,
    //                           Opportunity ,Auto Renwal fields when Renewal Opportunity 6L and Contract is 'Scheduled Termination'
    // @Modified By : Sruti Srivastava
    // @Modification Date: 30 Oct 2018
    // @Modification Description: SFDC1-10212: Populating currency from Contract
    // @Last Modified By : Mohit Modi
    // @Last Modified Date : 10 Dec 2018
    // @Last Modified Description - SFDC1-10379 - Added 'ContinuationEndDate__c' to Case from Renewal Opportunity associated to Case's Contract
    // @Last Modified By : Paras Dhingra
    // @Last Modified Date : 15 Jan 2018
    // @Last Modified Description - SFDC1-10913 - Added a temp fix so that correct oppy link is added to lost renewal OM case
    // 
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date : 6 May 2019
    // @Last Modified Description : SFDC-1431 Populate VolumeVariableBillingContract__c flag on new OM cases getting created on moving Contract to Stage-10 Ready For Processing
    // 
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date : 25 Jul 2019
    // @Last Modified Description : SFDC-1787 Changes to assign OM cases for consulting contracts(when Stage moves to 10-Ready For Processing) to OMConsultiing queue
    // 
    // @Last Modified By : Dev Aggarwal
    // @Last Modified Date : 20 January 2020.
    // @Last Modified Description : SFDC-1909 Auto Renewal flag on the OM case should be populated from Contract and not opportunity.
    // 
    // @Last Modified By : Akshay Dogra
    // @Last Modified Date : 11 Nov 2020.
    // @Last Modified Description : SFDC-1988 Populate Contract Start and Contract End Date from an Opportunity on an OM Case.
    // @Last Modified By : Paras Dhingra
    // @Last Modified Date : 13th Oct 2020
    // @Last Modified Description : SFDC-2723 Adding criteria to create OM Case when Auto Renewal flag is toggled 
    // @Last Modified By : Kanika Miglani
    // @Last Modified Date : 22nd Feb,2022
    // @Last Modified Description : SFDC-3646 Adding criteria to create OM Case when Auto Renewal flag is true on Add-on Contracts. 
    // @Last Modified By : Digvijay Singh
    // @Last Modified Date : 10 May 2022
    // @Last Modified Description : SFDC-5343 Added logic to bypass OM Case creation for given Lost reason codes.
    //-----------------------------
    public static void createOrModifyOMCasesForOrderFormContracts(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {   
            try { 
                List<Contract> listContracts = (List<Contract>) tp.newList;
                //SFDC-5343 : list of Lost reason code for by passing OM Case creation.
                 Set<String> lostReasonCodeforOMCaseBypass= new Set<String>{'Competition','Bankruptcy/Out of Business','Cutting Costs/Lost Budget','Decided to do it Themselves','Product/Solution Does Not Match',
                                                                              'Key Contact Left Company','Military Base Closure','Project Completed/Cancelled','Unfavorable Pricing','Non Payment','No/Low Usage',
                                                                               'Contact Non Responsive/Wrong Contact','Terms & Conditions Issues','Product Quality Issue','Customer Lost Bid','Company Too Small/Retail/Commerce'};
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;               
                Set<ID> listFilteredContractId = new  Set<Id>();
                List<Case> caseToBeInserted = new List<Case>();
                Map<string,id> caseQueue = new Map<string, id>();
                
                Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                Id orderManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management').getRecordTypeId();
                Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                //Id OrderMgmtQueueId = [SELECT QueueId,Queue.name FROM QueueSobject where Queue.name =: 'Order Management' limit 1].QueueId;
                Id OrderMgmtQueueId;
                Id OrderMgmtConsultingQueueId;
                Set<Id> setSchTeminationContractIds = new Set<Id>();
                Set<Id> setReadyForProcessingContractIds = new Set<Id>();
                Set<Id> setAutoRenewStoppedChanged = new Set<Id>();//set to contain contract ids for which auto-renew stopped flag is changed
                Set<Id> setAutoRenewStoppedChangedAddOn = new Set<Id>();
                Map<Id, Opportunity> contractRenewalOpptyMap = new Map<Id, Opportunity>();               
                String Ownerid = UserInfo.getUserId();//Just in case if queue is not there.
                Map<Id,set<Id>> mapContractIdVsAddOnContract = new Map<Id,set<Id>>();
                Map<Id,Id> mapReplacementContractIdVsContractId = new Map<Id,Id>();
                For(Contract contractMap : [Select Id,ReplacementContract__c,ReplacementContract__r.Status,(Select Id, Status,OrderReason__c,AutoRenewStopped__c  from OriginatingContractsforAddOn__r where OrderReason__c ='Add-On' AND Status = 'Complete' AND AutoRenewStopped__c = true) from Contract where id IN : listContracts]){
                    if(contractMap.OriginatingContractsforAddOn__r.size()>0)
                    {
                        Set<Id> ContIds= new Set<Id>();
                        for(Contract contId: contractMap.OriginatingContractsforAddOn__r){
                            ContIds.add(contId.id);
                        }
                        mapContractIdVsAddOnContract.put(contractMap.Id,ContIds);
                    }
                    if(contractMap.ReplacementContract__c != null && contractMap.ReplacementContract__r.Status == 'Complete')
                    {
                        mapReplacementContractIdVsContractId.put(contractMap.ReplacementContract__c,contractMap.Id);
                    }
                    
                }
                //Get Queue Ids - OrderManagement, OrderManagementConsulting
                /*for(Group grpObj: [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName in ('OrderManagement','OrderManagementConsulting')]) {
                    if(grpObj.DeveloperName=='OrderManagement') {
                        OrderMgmtQueueId = grpObj.Id;
                    }
                    if(grpObj.DeveloperName=='OrderManagementConsulting') {
                        OrderMgmtConsultingQueueId = grpObj.Id;
                    }
                }*/
                //replacing with custom labels
               OrderMgmtQueueId=System.Label.OrderManagementQueueId;
               OrderMgmtConsultingQueueId = System.Label.OrderManagementConsultingQueueId;//saved 2 unnecessarry soqls  
                for(Contract Contractobj : listContracts ) {
                    if(Contractobj.status != mapOldContract.get(Contractobj.id).status && (Contractobj.status == 'ReadyForProcessing') &&
                       (Contractobj.recordTypeId == orderFormRecordTypeId || Contractobj.recordTypeId == consultingRecordTypeId)) {
                           listFilteredContractId.add(Contractobj.id);
                           setReadyForProcessingContractIds.add(Contractobj.Id);
                       }
                    //SFDC1-7992 - Create OM Case
                    if(Contractobj.ContractStatus__c != mapOldContract.get(Contractobj.id).ContractStatus__c 
                       && Contractobj.ContractStatus__c == 'Scheduled Termination' && Contractobj.recordTypeId == orderFormRecordTypeId
                      ) {
                          listFilteredContractId.add(Contractobj.id);
                          setSchTeminationContractIds.add(Contractobj.id);
                      }
                       //adding check to see if auto renew flag is toggled
				     
                    if(Contractobj.AutoRenewStopped__c != mapOldContract.get(ContractObj.id).AutoRenewStopped__c && ContractObj.status=='Complete') {
                        setAutoRenewStoppedChanged.add(contractobj.id);
                        listFilteredContractId.add(Contractobj.id);
                         //SFDC-3646 : to fetch Add-on Contract Ids
                        if(Contractobj.AutoRenewStopped__c == true && mapContractIdVsAddOnContract.containskey(Contractobj.id)){
                            setAutoRenewStoppedChangedAddOn.addAll(mapContractIdVsAddOnContract.get(Contractobj.id));
                            listFilteredContractId.addAll(mapContractIdVsAddOnContract.get(Contractobj.id));
                        }
                        //SFDC-5552 : to fetch Replacement Contract Ids
                        if(Contractobj.AutoRenewStopped__c == true && mapReplacementContractIdVsContractId != null){
                           listFilteredContractId.addAll(mapReplacementContractIdVsContractId.keySet());
                        }
                    }
                }
                
                if(listFilteredContractId.isEmpty()) {
                    System.debug('No Contracts to process');
                    return;
                }
                //System.debug('Contracts to process'+listFilteredContractId);
                //System.debug('Scheduled Termination Contracts '+setSchTeminationContractIds);
                if(setSchTeminationContractIds.size() > 0) {
                    for(Opportunity oppty : [SELECT Id,ContractBeingRenewed__c,SourceSystem__c , ContractStartDate__c, ContractEndDate__c,StageName, AutoRenewal__c, DoesThisAutoRenewalHaveChanges__c, LostReasonCode__c, LostReasonDescription__c, 
                                             ContractBeingRenewed__r.ContractStatus__c,SAPContractNumber__c FROM Opportunity WHERE ContractBeingRenewed__c IN : listFilteredContractId AND isClosed=true AND isWon=false ORDER BY CloseDate ASC]) {     
                                                 contractRenewalOpptyMap.put(oppty.ContractBeingRenewed__c, oppty);              
                                             }
                    //SFDC-5343 : remove Contract Id from the list to bypass OM Case creation                      
                    for(Id contrId:setSchTeminationContractIds) {
                        Opportunity oppObj =contractRenewalOpptyMap.get(contrId);
                        if(oppObj !=Null && oppObj.SourceSystem__c == 'SAP' && (oppObj.StageName=='6L-Renewal Lost' || oppObj.StageName=='6L-Closed Lost') 
                            && lostReasonCodeforOMCaseBypass.contains(oppObj.LostReasonCode__c)) {
                              listFilteredContractId.remove(contrId);
                               
                           }
                           
                    }
                }
                
                //SFDC-1431: Update VolumeVariableBillingContract__c flag on OM case
                Map<Id,String> contractIdIsVolCarContractMap = checkVolumeVariableBillingContract(setReadyForProcessingContractIds);
				//System.debug('$$$ SOQL COunt-2-'+ Limits.getQueries());
                //SFDC1-10379 - Added 'ContinuationEndDate__c' to query
                for(Contract ctrct: [
                    select id,ContractStatus__c, Opportunity__r.ContractStartDate__c, Opportunity__r.ContractEndDate__c, recordType.Name,ContractNumber, TotalContractValue2__c, IHSMarkitLegalEntity__c, ChannelPartnerName__c, Status,
                    OrderReason__c, StartDate, EndDate, AutoRenewal__c, MultiyearOrderForm__c, ChannelPartnerBPNumber__c, BSI__c, ProcessedContracttext__c,CurrencyIsoCode,
                    Owner.UserRegion__c, Owner.HRBusinessLine__c, OwnerId, accountId, Opportunity__r.ComplianceRestrictions__c,Opportunity__r.PORequired__c, 
                    Opportunity__c, Opportunity__r.DoesThisAutoRenewalHaveChanges__c, Opportunity__r.LostReasonCode__c, Opportunity__r.LostReasonDescription__c,Opportunity__r.SAPContractNumber__c,Opportunity__r.AutoRenewal__c,Opportunity__r.ContinuationEndDate__c,
                    (select id, TotalContractValueNew__c, ContractOwnerRegion__c, IHSMarkitLegalEntityNew__c, ContractRecordType__c, OrderReason__c, 
                     ContractStartDate__c, ContractEndDate__c, AccountId, Opportunity__c, Contract__c, ContractStage__c, status, //ContractOwner__c, 
                     AutoRenewal__c, AutoRenewalWithChange__c, Multiyear__c, ChannelPartnerCompanyName__c, ChannelPartnerBP__c, ComplianceRestrictions__c, 
                     BSIMembership__c, LostReasonCode__c, LostReasonDescription__c, SAPContract__c,CurrencyIsoCode from Cases__r where recordTypeId =: orderManagementRecordTypeId
                     AND Type != 'Auto Renewal Stopped change')
                    FROM Contract where id IN: listFilteredContractId]) {
                        //ctrct.Cases__r
                        //1. Check if case is there and populate values. 
                        //2. Else create case.
                        
                        Case cas = new Case();
                        if(!ctrct.Cases__r.isEmpty() && ctrct.ContractStatus__c != 'Scheduled Termination' && !setAutoRenewStoppedChanged.contains(ctrct.Id) && !mapReplacementContractIdVsContractId.containskey(ctrct.Id) && !setAutoRenewStoppedChangedAddOn.contains(ctrct.Id) ) {
                            //As per BSA, User cant directly create a OM case, so can safely assume 
                            //There will be either one or zero OM case.
                            cas = ctrct.Cases__r.get(0);
                            if (cas.Status == 'Rejected') {
                                cas.Status = 'Updated';
                            }
                        } 
                        else {
                            cas.RecordTypeId = orderManagementRecordTypeId;
                            //SFDC1-7992 - Create OM Case
                            if(!setAutoRenewStoppedChangedAddOn.contains(ctrct.Id) && !mapReplacementContractIdVsContractId.containskey(ctrct.Id)){
                                //system.debug('ctrct.ContractStatus__c1---->'+ctrct.ContractStatus__c);
                            	//system.debug('mapOldContract.get(ctrct.id).ContractStatus__c1--->'+mapOldContract.get(ctrct.id).ContractStatus__c);
                            if(ctrct.ContractStatus__c != mapOldContract.get(ctrct.id).ContractStatus__c && ctrct.ContractStatus__c == 'Scheduled Termination') {
                                cas.OwnerId = OrderMgmtQueueId;
                            }
                            else {
                                //cas.OwnerId = OwnerId;
                                switch on ctrct.RecordType.Name {
                                    when 'Consulting' {
                                        cas.OwnerId = OrderMgmtConsultingQueueId!=null ? OrderMgmtConsultingQueueId : OwnerId;
                                    }
                                    when else {
                                        cas.OwnerId = OrderMgmtQueueId!=null ? OrderMgmtQueueId : OwnerId;
                                    }
                                }
                            } 
                                     
                            }
                        }
                        //cas.TotalContractValueNew__c = ctrct.TotalContractValue__c;
                        cas.TotalContractValueNew__c = ctrct.TotalContractValue2__c;
                        cas.CurrencyIsoCode  = ctrct.CurrencyIsoCode;
                        cas.ContractOwnerRegion__c = ctrct.Owner.UserRegion__c;
                        cas.HRBusinessUnit__c = ctrct.Owner.HRBusinessLine__c;
                        cas.IHSMarkitLegalEntityNew__c = ctrct.IHSMarkitLegalEntity__c;
                        cas.ContractRecordType__c = ctrct.RecordType.Name;
                        cas.OrderReason__c = ctrct.OrderReason__c;
                        cas.ContractStartDate__c = ctrct.Opportunity__r.ContractStartDate__c;
                        cas.ContractEndDate__c = ctrct.Opportunity__r.ContractEndDate__c;
                        cas.AccountId = ctrct.AccountId;
                        cas.Contract__c = ctrct.Id;
                        String cntrctNumber = ctrct.ContractNumber;
                        //SFDC1-7992 - Create OM Case
                        if(!setAutoRenewStoppedChangedAddOn.contains(ctrct.Id) && !mapReplacementContractIdVsContractId.containskey(ctrct.Id)){
                            //system.debug('ctrct.ContractStatus__c2---->'+ctrct.ContractStatus__c);
                        	//system.debug('mapOldContract.get(ctrct.id).ContractStatus__c2--->'+mapOldContract.get(ctrct.id).ContractStatus__c);
                        	if(ctrct.ContractStatus__c != mapOldContract.get(ctrct.id).ContractStatus__c &&  
                           		ctrct.ContractStatus__c == 'Scheduled Termination' &&
                           		contractRenewalOpptyMap.get(ctrct.Id) != NULL
                          	) {
                              		Opportunity renewalOppty = contractRenewalOpptyMap.get(ctrct.Id);
                              		cas.Subject = 'Closed Lost Renewal – {'+cntrctNumber +'}';
                              		cas.AutoRenewal__c = ctrct.AutoRenewal__c;
                              		cas.AutoRenewalWithChange__c = renewalOppty.DoesThisAutoRenewalHaveChanges__c;
                              		cas.LostReasonCode__c = renewalOppty.LostReasonCode__c;
                              		cas.LostReasonDescription__c = renewalOppty.LostReasonDescription__c;
                              		cas.Opportunity__c = renewalOppty.Id;
                              		cas.SAPContract__c = renewalOppty.SAPContractNumber__c; //SFDC1-10213 changes
                              		cas.ContractStartDate__c = renewalOppty.ContractStartDate__c;
                              		cas.ContractEndDate__c = renewalOppty.ContractEndDate__c;
                              		cas.Type = 'Closed Lost Renewal'; //SFDC-3598 change
                          		} 
                          	else if(setAutoRenewStoppedChanged.contains(ctrct.Id)) {                            		
                                	cas.Subject = 'Auto Renewal Stopped change - {'+cntrctNumber +'}';
                            		cas.AutoRenewal__c = ctrct.AutoRenewal__c;
                            		cas.AutoRenewalWithChange__c = ctrct.Opportunity__r.DoesThisAutoRenewalHaveChanges__c;
                            		cas.LostReasonCode__c = ctrct.Opportunity__r.LostReasonCode__c;
                            		cas.LostReasonDescription__c = ctrct.Opportunity__r.LostReasonDescription__c;
                            		cas.Opportunity__c = ctrct.Opportunity__c;
                            		cas.SAPContract__c = ctrct.Opportunity__r.SAPContractNumber__c;
                            		cas.Type = 'Auto Renewal Stopped change';
                        		}  
                        	else {
                              		cas.Subject = 'Processing Request – {'+cntrctNumber+'}';
                              		cas.AutoRenewal__c = ctrct.AutoRenewal__c;
                              		cas.AutoRenewalWithChange__c = ctrct.Opportunity__r.DoesThisAutoRenewalHaveChanges__c;
                              		cas.LostReasonCode__c = ctrct.Opportunity__r.LostReasonCode__c;
                              		cas.LostReasonDescription__c = ctrct.Opportunity__r.LostReasonDescription__c;
                              		cas.Opportunity__c = ctrct.Opportunity__c;
                              		cas.SAPContract__c = ctrct.Opportunity__r.SAPContractNumber__c; //SFDC1-10213 changes
                              		cas.Type = 'Processing Request'; //SFDC-3598 change
                          		}  
                        	}
                        	else if(setAutoRenewStoppedChangedAddOn.contains(ctrct.Id)) {
                                	cas.Subject = 'Auto Renewal Stopped change - {'+cntrctNumber +'}';
                            		cas.AutoRenewal__c = ctrct.AutoRenewal__c;
                            		cas.AutoRenewalWithChange__c = ctrct.Opportunity__r.DoesThisAutoRenewalHaveChanges__c;
                            		cas.LostReasonCode__c = ctrct.Opportunity__r.LostReasonCode__c;
                            		cas.LostReasonDescription__c = ctrct.Opportunity__r.LostReasonDescription__c;
                            		cas.Opportunity__c = ctrct.Opportunity__c;
                            		cas.SAPContract__c = ctrct.Opportunity__r.SAPContractNumber__c;
                            		cas.Type = 'Auto Renewal Stopped change';
                        	} 
                        	if(mapReplacementContractIdVsContractId.containskey(ctrct.Id)){
                            		cas.Subject = 'Auto Renewal Stopped change - {'+cntrctNumber +'}';
                            		cas.AutoRenewal__c = ctrct.AutoRenewal__c;
                            		cas.AutoRenewalWithChange__c = ctrct.Opportunity__r.DoesThisAutoRenewalHaveChanges__c;
                            		cas.LostReasonCode__c = ctrct.Opportunity__r.LostReasonCode__c;
                            		cas.LostReasonDescription__c = ctrct.Opportunity__r.LostReasonDescription__c;
                            		cas.Opportunity__c = ctrct.Opportunity__c;
                            		cas.SAPContract__c = ctrct.Opportunity__r.SAPContractNumber__c;
                            		cas.Type = 'Auto Renewal Stopped change';
                        	}
                        	
                        //cas.ContractOwner__c = ctrct.OwnerId;
                        cas.ContractStage__c = ctrct.Status;
                        cas.Multiyear__c = ctrct.MultiyearOrderForm__c;
                        cas.ChannelPartnerCompanyName__c = ctrct.ChannelPartnerName__c;
                        cas.ChannelPartnerBP__c = ctrct.ChannelPartnerBPNumber__c;
                        cas.ComplianceRestrictions__c = ctrct.Opportunity__r.ComplianceRestrictions__c;
                        cas.BSIMembership__c = ctrct.BSI__c;
                        cas.PORequired__c = ctrct.Opportunity__r.PORequired__c;
                        //SFDC1-10379 - Added 'ContinuationEndDate__c' to Case
                        cas.ContinuationEndDate__c = ctrct.Opportunity__r.ContinuationEndDate__c;
                        cas.VolumeVariableBillingContract__c = contractIdIsVolCarContractMap.containsKey(ctrct.Id)!=null && String.isNotBlank(contractIdIsVolCarContractMap.get(ctrct.Id)) ? contractIdIsVolCarContractMap.get(ctrct.Id) : 'No';
                        caseToBeInserted.add(cas);
                    }
                System.debug('Cases to upsert:'+caseToBeInserted);
                if(!caseToBeInserted.isEmpty()) {
                    upsert caseToBeInserted;
                    //system.debug('caseToBeInserted==>'+caseToBeInserted);
                }
            } catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'ContractMethods','createOrModifyOMCasesForOrderFormContracts'); 
            }
        }
    }
	
    // @author: Sruti Srivastava
	// @date: 11th May 2018
	// @description: SFDC1-7855-When an "Order Form" Contract record is updated "Completed" 
	// the Opportunity should be updated to 6WP, runs on After Update
	// @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
	// @companyname: VERTIBA
	// @return: void
    // @modifiedby: Paras Dhingra
    // @modifiedDate: 26th July 2019
    // @modified description : SFDC-1358 Adding consulting record type to set Opportunity as 6WP when case is set to validated 
    // @modifiedby: Paras Dhingra
    // @modifiedDate: 2nd April 2020
    // @modified description : SFDC-2396 This method is not required anymore. Commenting it out. 6WP will only be set using OM case
    /*
    public static void updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted(TriggerParameters tp) {
        //this method runs on after update currently, adding after insert for future purpose
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate || tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
        	
            set<id> setOpportunityIds = new set<id>();
            List<Contract> listContracts = (List<Contract>) tp.newList;
            Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
            map<id, Opportunity> mapOpportunity = new map<id, Opportunity>();
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            // Collect all the OpportunityIds with recordtype "Gratis", "New Business" and "Renewal" for the Contracts with status "Complete"
            for(Contract contractObj : listContracts ) {
                if( !String.isBlank(contractObj.Opportunity__c) && (contractObj.RecordTypeId == orderFormRecordTypeId || contractObj.RecordTypeId == consultingRecordTypeId)
                  && !String.isBlank(contractObj.Status) && contractObj.Status.equalsIgnoreCase('Complete')  && 
                   (mapOldContract == null ||
                    (mapOldContract != null && !mapOldContract.get(contractObj.Id).Status.equalsIgnoreCase('Complete')))
                  && (contractObj.OpportunityRecordType__c.containsIgnoreCase('Gratis') || contractObj.OpportunityRecordType__c.containsIgnoreCase('Business') 
                      || contractObj.OpportunityRecordType__c.containsIgnoreCase('Renewal'))) {
                    setOpportunityIds.add(contractObj.Opportunity__c);
                }            
            }
                
            if(!setOpportunityIds.isEmpty()) {
                // Updating Opportunity Records to stage '6WP-Closed Won/Order Processed' 
                for( Id oppId : setOpportunityIds) {
                    mapOpportunity.put(oppId , new Opportunity(Id= oppId, StageName ='6WP-Closed Won/Order Processed'));
                }
            }
                
            try {
                //Updating Opportunity
                if(!mapOpportunity.isEmpty()) {
                    update mapOpportunity.values();
                }
            }
            catch(Exception exp) {
                String errMessage = exp.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
                                    exp.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):exp.getMessage();
                UtilityClass.createApexLogRecord(exp,'ContractMethods','updateOppTo6WPClosedWonOPWhenOrderFormIsCompleted');
                tp.newList[0].addError('Error: '+errMessage);
            }
        }
    } */
    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 18 May 2018
    // @Description : SFDC1-8056: If SAP PGI’d is changed on order form contract, populate PGI Owner with LastModifiedBy field
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
	// Updated By: Anjani Shukla
	// LastModifiedDate: 20 Aug 2018
	// Description:SFDC1-9446: UAT feedback - Issue populating the Countersignature Owner or SAP PGI'd Owner.
	//                         CountersignatureOwner__c,PGIOwner__c should be updated when CountersignatureStatus__c and SAPPGId__c
	//                         "Countersignature Status" or "SAP PGI'd" is updated from blank to new, the corresponding owner fields 
	//                         "Countersignature Owner" and "PGI Owner" are being populated. The Counter Signature owner and the PGI Owner 
	//                         fields should still be blank when those fields are in "New" and owner field should be populated once the field 
	//                         is moved to anything except for new.
    //-----------------------------
    public static void updatePGIOwnerField(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate || tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {   
            try {
                Id orderFormRecordTypeId = Schema.Sobjecttype.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
                List<Contract> listContracts = (List<Contract>) tp.newList;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                for(Contract conObj: listContracts) {	
                    //SFDC1-9446 - Condition 2.   PGI'd field: When "SAP PGI'd" is updated 
					//			   from blank to new, the corresponding owner field "PGI Owner" 
					//			   is being populated. The PGI Owner field should still be blank 
					//			   when that field is in "New" Status. When the PGI'd field is 
					//			   moved to Pending, Completed or Rejected, then the PGI Owner 
					//			   field should be populated with that user.
                    if(conObj.RecordTypeId == orderFormRecordTypeId && 
                        conObj.SAPPGId__c != null && 
                        conObj.SAPPGId__c != 'New' &&                      
                        (mapOldContract == null || conObj.SAPPGId__c != mapOldContract.get(conObj.Id).SAPPGId__c)					   
					  ) {
                    	conObj.PGIOwner__c = UserInfo.getUserId();
                    }
                    
                    //SFDC1-9446 - Condition 2.   PGI'd field: When "SAP PGI'd" is updated 
					//			   from blank to new, the corresponding owner field "PGI Owner" 
					//			   is being populated. The PGI Owner field should still be blank 
					//			   when that field is in "New" Status. When the PGI'd field is 
					//			   moved to Pending, Completed or Rejected, then the PGI Owner 
					//			   field should be populated with that user.
                    if(conObj.RecordTypeId == orderFormRecordTypeId && 
                       (conObj.SAPPGId__c == null || conObj.SAPPGId__c == 'New') && ( mapOldContract!=null &&
                       conObj.SAPPGId__c != mapOldContract.get(conObj.Id).SAPPGId__c ) ){
                       conObj.PGIOwner__c = null;
                    }
               }
            }               
            catch (Exception e) {
               UtilityClass.createApexLogRecord(e,'ContractMethods','updatePGIOwnerField'); 
           }
        }
    }
    
    //-----------------------------
    // @Author : Tran-Vu Tran
    // @Date : 22 May 2018
    // @Description: this method implements the following requirements for 2 user stories
    // 
    // + SFDC1-7680:
    // 	3. Update Countersignature Status to "New" if Countersignature Status was Null, and:
    // 		a. Record Type = "Order Form" or "Consulting", and Contract Status = "Validated" or "Validated PO Pending",
    // 		b. Record Type = Trial, Continuation, Master, NDA, MST, DPA, and Stage = "Ready for Processing"
    // 	4. If Countersignature Status value changed, populate Countersignature Owner with LastModifiedBy field
    // 
    // + SFDC1-8252: If Contract Status = "Validated" and Record Type = "Order Form", update Stage to "Completed"
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @return : Void
	// Updated By: Sruti Srivastava
	// Description: SFDC1-8960 - Update Contract Stage to "Complete", when Contract Status is updated to "Validated" for
	// Consulting contracts
	// Updated By: Anjani Shukla
	// LastModifiedDate: 20 Aug 2018
	// Description:SFDC1-9446: UAT feedback - Issue populating the Countersignature Owner or SAP PGI'd Owner.
	//                         CountersignatureOwner__c,PGIOwner__c should be updated when CountersignatureStatus__c and SAPPGId__c
	//                         "Countersignature Status" or "SAP PGI'd" is updated from blank to new, the corresponding owner fields 
	//                         "Countersignature Owner" and "PGI Owner" are being populated. The Counter Signature owner and the PGI Owner 
	//                         fields should still be blank when those fields are in "New" and owner field should be populated once the field 
	//                         is moved to anything except for new.
	// Updated By: Sruti Srivastava
	// LastModifiedDate: 12 October 2018
    // Description: SFDC1-10185 - Update status to "11-Completed", when Contract Status is updated to "Validated PO Pending"
    // 
    // Updated By: Kolli Rohit Reddy
	// LastModifiedDate: 01 May 2019
    // Description: SFDC-1394 - Third Party Processor Agreement 'Countersignature Owner' should not be defaulted
	// @Modified By : Paras Dhingra
    // @Modification Date: 1st May 2020
    // @Modification Description:SFDC-2873: Add Validated-POD Pending with Validated PO Pending conditions
    //-----------------------------

    public static void updateCountersignatureFields(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate || tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {   
            try {
                List<Contract> listContracts = (List<Contract>) tp.newList;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;

                Id orderFormRecordTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                Id consultingRecordTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                Id tppaRecordTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Third Party Processor Agreement').getRecordTypeId();
                
                for (Contract c: listContracts) {
                    if (c.RecordTypeId == orderFormRecordTypeId || c.RecordTypeId == consultingRecordTypeId) {
                        
                        // SFDC1-7680: if Contract Status = "Validated" or "Validated PO Pending", and Countersignature Status was not set
                        if ((c.ContractStatus__c == 'Validated' || c.ContractStatus__c == 'Validated PO Pending' || c.ContractStatus__c == 'Validated-POD Pending')
                            && c.CountersignatureStatus__c == null) {
                                // update Countersignature Status to "New"
                                c.CountersignatureStatus__c = 'New';
                        }

                        // SFDC1-8252, SFDC1-8960, SFDC1-10185: if Contract Status = "Validated" and Record Type = "Order Form" or "Consulting"
                        if ((c.ContractStatus__c == 'Validated' ||  c.ContractStatus__c == 'Validated PO Pending' || c.ContractStatus__c == 'Validated-POD Pending') && c.Status != 'Complete') {
                                // update Stage to "Completed"
                                c.Status = 'Complete';
                        }
						
                    } else { // for different record types
                        if (c.Status == 'ReadyForProcessing'
                            && c.CountersignatureStatus__c == null) {
                                // update Countersignature Status to "New"
                                c.CountersignatureStatus__c = 'New';
                        }
                    }
                    
                    if (c.RecordTypeId != tppaRecordTypeId && ((mapOldContract == null && c.CountersignatureStatus__c != null) // when this one is a new inserted record
                        || (mapOldContract!=null && c.CountersignatureStatus__c != mapOldContract.get(c.Id).CountersignatureStatus__c)) // or during update
                       ) {
                           
                           c.CountersignatureOwner__c = UserInfo.getUserId(); // populate with current user Id, which would be the same as LastModifiedBy
                    }
                    
                    //SFDC1-9446 - Condition 1.  Countersignature Owner field 
					//			   When "Countersignature Status" " is updated from blank to new, 
					//			   the corresponding owner field "Countersignature Owner" is 
					//			   currently being populated. The Counter Signature owner field 
					//			   should still be blank when that field is in "New" Status. 
					//			   When the Countersignature status is moved to Pending, 
					//			   Completed or Rejected, then the Countersignature Owner 
					//			   field should be populated with that user.
                    if((c.RecordTypeId == orderFormRecordTypeId || c.RecordTypeId == tppaRecordTypeId) && 
                       c.CountersignatureStatus__c != null     && 
                       c.CountersignatureStatus__c != 'New'    &&
                       (mapOldContract == null ||
                       c.CountersignatureStatus__c != mapOldContract.get(c.Id).CountersignatureStatus__c)
                      ) {
                    	c.CountersignatureOwner__c = UserInfo.getUserId();                        
                    }
                    
                    //SFDC1-9446 - Condition 1.  Countersignature Owner field 
					//			   When "Countersignature Status" " is updated from blank to new, 
					//			   the corresponding owner field "Countersignature Owner" is 
					//			   currently being populated. The Counter Signature owner field 
					//			   should still be blank when that field is in "New" Status. 
					//			   When the Countersignature status is moved to Pending, 
					//			   Completed or Rejected, then the Countersignature Owner 
					//			   field should be populated with that user.
                    if((c.RecordTypeId == orderFormRecordTypeId || c.RecordTypeId == tppaRecordTypeId) && (c.CountersignatureStatus__c == null || c.CountersignatureStatus__c == 'New') && 
                        ( mapOldContract!=null && c.CountersignatureStatus__c != mapOldContract.get(c.Id).CountersignatureStatus__c)) {
                        c.CountersignatureOwner__c = null;                        
                    }
				}

            }               
            catch (Exception e) {
               UtilityClass.createApexLogRecord(e,'ContractMethods','updateCountersignatureFields'); 
           }
        }
    }

    /**
      * @author Tran-Vu Tran
      * @date 23 Oct 2018
      * @description SFDC1-9347 update Account Relationship field for accounts according to related opportunities and contracts
      * @param TriggerParameters
      * @return void
      * @companyname IHS Markit
      */

    public static void updateAccountRelationship(TriggerParameters tp) {
        
        if (GlobalVariables.preventRecursiveExecution) {
            GlobalVariables.preventRecursiveExecution = false;
            
            //generate accountId list
            Set<Id> setAccountId = new Set<Id>();
            Map<Id, Contract> oldContracts = (Map<Id, Contract>) tp.oldMap;
            for (Contract contr : (List<Contract>)tp.newList) {
                
                Contract oldContr;
                if (oldContracts != null && !oldContracts.isEmpty()) {
                    oldContr = oldContracts.get(contr.Id);
                }
                
                // checking if Contracts' Status or End Date changed
                if (oldContr == null || oldContr.Status != contr.Status || oldContr.EndDate != contr.EndDate) {
                    setAccountId.add(contr.accountID);
                }
            }
            // System.debug('setAccountID' + setAccountId);

            try {
                // calling the shared logic implemented in OpportunityMethods class
                if (setAccountId.size() > 0) {
                    OpportunityMethods.updateAccountRelationship(setAccountId);
                }
            } catch(Exception ex) {
                String description = '\n Cause: '+ ex.getCause() +'\n Message: '+ ex.getMessage();
                tp.newList[0].addError(System.Label.OpportunityGenericError+description);
                UtilityClass.createApexLogRecord(ex, 'ContractMethods', 'updateAccountRelationship'); 
            }
        }
    } 
          
    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 24 May 2018
    // @Description : SFDC1-8096: updating notice address fields  on contract from lega entity via code instead of process builder 'Populate IHS Markit Street Address on Contract'
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    // @lastmodified by : Mohit Modi
    // @lastmodified description : SFDC1-9280 : Commenting the field 'IHSMarkitStateOfIncorporationText__c' uses as It has to be Deleted.
    //-----------------------------
    public static void updateNoticeAddressFieldsOnContractFromLegalEntity(TriggerParameters tp) {
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
            tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
        { 
            try {
                Set<id> setLegalEntityId = new set<id>();
                List<Contract> listContracts = (List<Contract>) tp.newList;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                for(Contract Contractobj : listContracts ) {
                    if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert && NULL != Contractobj.IHSMarkitLegalEntity__c)
                    {
                        setLegalEntityId.add(Contractobj.IHSMarkitLegalEntity__c);
                    }
                    if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate && (NULL != Contractobj.IHSMarkitLegalEntity__c) &&
                        Contractobj.IHSMarkitLegalEntity__c != mapOldContract.get(Contractobj.id).IHSMarkitLegalEntity__c)
                    {
                        setLegalEntityId.add(Contractobj.IHSMarkitLegalEntity__c);
                    }
                    else if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate && (NULL == Contractobj.IHSMarkitLegalEntity__c) &&
                        Contractobj.IHSMarkitLegalEntity__c != mapOldContract.get(Contractobj.id).IHSMarkitLegalEntity__c)
                    {
                        Contractobj.IHSMarkitNoticeAddressCity__c = '';
                        Contractobj.IHSMarkitNoticeAddressCountry__c = '';
                        Contractobj.IHSMarkitNoticeZipCode__c = '';
                        Contractobj.IHSMarkitNoticeState__c = '';                   
                        Contractobj.IHSMarkitNoticeAddressStreet__c = '';
                        Contractobj.IHSMarkitLegalEntityStreet__c = '';
                        Contractobj.IHSMarkitLegalEntityStateProvinceNew__c = ''; 
                        //SFDC1-9280 : Commenting the field uses as It has to be Deleted.
                        //Contractobj.IHSMarkitStateOfIncorporationText__c = '';                            
                    }
                }
                if(setLegalEntityId != NULL && setLegalEntityId.size()>0) {
                Map<Id,LegalEntity__c> mapLegalEntity = new Map<Id,LegalEntity__c>([Select id, AddressLine1__c,AddressLine2__c,AddressLine3__c,City__c,Country__c,Country__r.Name,toLabel(StateOrProvinceNew__c),toLabel(IncorporatedinState__c),PostalCode__c from LegalEntity__c where Id IN : setLegalEntityId]);
                    for(Contract Contractobj : listContracts ) {
						if(mapLegalEntity != NULL && mapLegalEntity.containskey(Contractobj.IHSMarkitLegalEntity__c)){
                        LegalEntity__c legObj = mapLegalEntity.get(Contractobj.IHSMarkitLegalEntity__c);
                        Contractobj.IHSMarkitNoticeAddressCity__c = legObj.City__c;
                        Contractobj.IHSMarkitNoticeAddressCountry__c = legObj.Country__r.Name;
                        Contractobj.IHSMarkitNoticeZipCode__c = legObj.PostalCode__c;
                        Contractobj.IHSMarkitNoticeState__c = legObj.StateOrProvinceNew__c;
                        //SFDC1-9280 : Commenting the field uses as It has to be Deleted.
                        //Contractobj.IHSMarkitStateOfIncorporationText__c = legObj.IncorporatedinState__c;
                        String address = '';
                        if(!String.isBlank(legObj.AddressLine1__c)) {
                            address = address + legObj.AddressLine1__c;
                        }
                        if(!String.isBlank(legObj.AddressLine2__c)) {
                            address = address + ',' + legObj.AddressLine2__c;
                        }
                        if(!String.isBlank(legObj.AddressLine3__c)) {
                            address = address + ',' + legObj.AddressLine3__c;
                        }
                        
                        Contractobj.IHSMarkitNoticeAddressStreet__c = address;
                        Contractobj.IHSMarkitLegalEntityStreet__c = address;
                        Contractobj.IHSMarkitLegalEntityStateProvinceNew__c = legObj.StateOrProvinceNew__c;              
                    }
                }
				}
            }
        catch (Exception e) {
               UtilityClass.createApexLogRecord(e,'ContractMethods','updateNoticeAddressFieldsOnContractFromLegalEntity'); 
           }
        }
    }
    
    //-----------------------------
    // @Author: Tran-Vu Tran
    // @Date: 18 April 2019
    // @Description: SFDC-1362 populate Account Address details from the Processor Legal Entity for Third Party Contract record type
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @return : Void
    //-----------------------------
    public static voId updateThirdPartyContractAddressFromProcessorLegalEntity(TriggerParameters tp) {
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
            tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
        { 
            try {
                Set<Id> accountIDs = new Set<Id>();
                List<Contract> contracts= (List<Contract>) tp.newList;
                
                
                for (Contract contract : contracts) {
                    if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert && contract.ProcessorLegalEntityName__c != null) {
                        // adding ProcessorLegalEntity to the list of account that information needs to be retrieved from database
                        accountIDs.add(contract.ProcessorLegalEntityName__c);
                    }
                    else  
						if ( tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate ) {
							Map<Id, Contract> mapOldContract = (Map<Id, Contract>)tp.oldMap;
							Contract oldContract = mapOldContract.get(contract.Id);

							if ( contract.ProcessorLegalEntityName__c != null
								&& contract.ProcessorLegalEntityName__c != oldContract.ProcessorLegalEntityName__c) {
									// adding ProcessorLegalEntity to the list of account that information needs to be retrieved from database
									accountIDs.add(contract.ProcessorLegalEntityName__c);
							}
							else
								if ( contract.ProcessorLegalEntityName__c == null
									&& contract.ProcessorLegalEntityName__c != oldContract.ProcessorLegalEntityName__c) {
										// clearing the values when ProcessorLegalEntity was removed
										contract.ProcessorLegalEntityStreet__c = '';
										contract.ProcessorLegalEntityCity__c = '';
										contract.ProcessorLegalEntityStateProvince__c = '';
										contract.ProcessorLegalEntityPostalZipCode__c = '';
										contract.ProcessorLegalEntityCountry__c = null;
									}
                    }
                }
                
                if (accountIDs != null && accountIDs.size() > 0) {
                    Map<Id,Account> mapAccountValues = new Map<Id,Account>(
                        [Select Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, AccountCountry__c from Account where Id in : accountIDs]);
                    
                    for (Contract contract : contracts) {
                        Account account = mapAccountValues.get(contract.ProcessorLegalEntityName__c);
                        contract.ProcessorLegalEntityStreet__c = account.BillingStreet;                        
                        contract.ProcessorLegalEntityCity__c = account.BillingCity;
                        contract.ProcessorLegalEntityStateProvince__c = account.BillingState;
                        contract.ProcessorLegalEntityPostalZipCode__c = account.BillingPostalCode;
                        contract.ProcessorLegalEntityCountry__c = account.AccountCountry__c;
                    }
                }
            }
            catch (Exception e) {
                System.debug('Exception in ContractMethods.updateThirdPartyContractAddressFromProcessorLegalEntity(): ' + e.getMessage());
                UtilityClass.createApexLogRecord(e, 'ContractMethods', 'updateThirdPartyContractAddressFromProcessorLegalEntity'); 
            }
        }
    }

    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 5 June 2018
    // @Description : SFDC1-8096: updating Client State of Incorporation fields  on contract from client legal entity (instead of formula field)
    // @Description :SFDC1-905 Populate Client Notice Address Fields (SFDC1-7542: converted process builder 'PopulateClientNoticeAddressFieldsOnContract' to this method )
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    //-----------------------------
    public static void updateClientStateOfIncorporationFromClientLegalEntity(TriggerParameters tp) {
        
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
            tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
        { 
            try {
                Set<id> setAccountId = new set<id>();
                List<Contract> listContracts = (List<Contract>) tp.newList;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                for(Contract Contractobj : listContracts ) {
                    if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert && NULL != Contractobj.ClientLegalEntityLookUp__c)
                    {
                        setAccountId.add(Contractobj.ClientLegalEntityLookUp__c);
                    }
                    if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate && (NULL != Contractobj.ClientLegalEntityLookUp__c) &&
                        Contractobj.ClientLegalEntityLookUp__c != mapOldContract.get(Contractobj.id).ClientLegalEntityLookUp__c)
                    {
                        setAccountId.add(Contractobj.ClientLegalEntityLookUp__c);
                    }
                    else if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate && (NULL == Contractobj.ClientLegalEntityLookUp__c) &&
                        Contractobj.ClientLegalEntityLookUp__c != mapOldContract.get(Contractobj.id).ClientLegalEntityLookUp__c)
                    {
                        Contractobj.ClientStateofIncorporationNew__c = '';   
                        Contractobj.ClientNoticeAddressCity__c  = '';   
                        Contractobj.ClientNoticeAddressCountryLookup__c = NULL;   
                        Contractobj.ClientNoticeAddressStreet__c = '';   
                        Contractobj.ClientNoticeAddressStateProvince__c = '';   
                        Contractobj.ClientNoticeAddressZipPostalCode__c  = '';   
                        Contractobj.ClientLegalEntityCity__c = '';
                        Contractobj.ClientLegalEntityCountryLookup__c = NULL;
                        Contractobj.ClientLegalEntityZipPostalCode__c = '';
                        Contractobj.ClientLegalEntityStateProvince__c = '';
                        Contractobj.ClientLegalEntityStreet__c = '';                        
                    }
                }
                if(setAccountId != NULL && setAccountId.size()>0) {
                Map<Id,Account> mapAccountValues = new Map<Id,Account>([Select id,toLabel(StateOfIncorporation__c),AccountCountry__c,BillingCity,BillingStreet,BillingCountry,BillingPostalCode,BillingState from Account where Id IN : setAccountId]);
                    for(Contract Contractobj : listContracts ) {
                        Account clientLegObj = mapAccountValues.get(Contractobj.ClientLegalEntityLookUp__c);
                        Contractobj.ClientStateofIncorporationNew__c = clientLegObj.StateOfIncorporation__c;
                        Contractobj.ClientNoticeAddressCity__c  = clientLegObj.BillingCity;   
                        Contractobj.ClientNoticeAddressCountryLookup__c = clientLegObj.AccountCountry__c;   
                        Contractobj.ClientNoticeAddressStreet__c = clientLegObj.BillingStreet;   
                        Contractobj.ClientNoticeAddressStateProvince__c = clientLegObj.BillingState;   
                        Contractobj.ClientNoticeAddressZipPostalCode__c  = clientLegObj.BillingPostalCode;   
                        Contractobj.ClientLegalEntityCity__c = clientLegObj.BillingCity;
                        Contractobj.ClientLegalEntityCountryLookup__c = clientLegObj.AccountCountry__c;
                        Contractobj.ClientLegalEntityZipPostalCode__c = clientLegObj.BillingPostalCode;
                        Contractobj.ClientLegalEntityStateProvince__c = clientLegObj.BillingState;
                        Contractobj.ClientLegalEntityStreet__c = clientLegObj.BillingStreet;                        
                    }
                }
            }
        catch (Exception e) {
               UtilityClass.createApexLogRecord(e,'ContractMethods','updateClientStateOfIncorporationFromClientLegalEntity'); 
           }
        }
    }
    
    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 6 June 2018
    // @Description :SFDC1-4421 Populate Bill To Fields on Contract with Global Alliance Fields when Opportunity
    // associated to Contract as Global Alliance Sales Channel (SFDC1-7542: converting process builder
    // 'PopulateBillToFieldsonContractwithGlobalAllianceFields' first part)
    // @Description :SFDC1-6173 Copy Bill to and Ship to fields to the new Contract being created
    // @Description :SFDC1-4363 Populate Ship To and Bill To Address Information on Contract from Related Account 
    // @Description :SFDC1-7542: converting process builder 'PopulateBillToAndShipToInformationOnContractFromAccount', 'CopyBillToandShiptoFieldsfromRenewalOpptytoContract'  
    // and 'PopulateBillToFieldsonContractwithGlobalAllianceFields' before insert part (Copy Account details over to Bill To fields)
    // to this method
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    // @lastmodifiedby : Anjali
    // @lastmodifieddate : 18 Jan 2021
    // @lastmodifiedDescription :SFDC-2413 Populate Ship To and Bill To Address Information on Consulting Contract from Related Account
    //-----------------------------
    public static void populateBillToAndShipToInformationOnContractFromAccount(TriggerParameters tp) {
        
       if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert)
        {
            try {
                Set<id> setAccountId = new set<id>();
                Set<id> setOppId = new set<id>();
                List<Contract> listContracts = (List<Contract>) tp.newList;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
                Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
                for(Contract Contractobj : listContracts ) {
                    if((String.valueOf(Contractobj.RecordTypeId).substring(0,15) == String.valueOf(orderFormRecordTypeId).substring(0,15) || String.valueOf(Contractobj.RecordTypeId).substring(0,15) ==String.valueOf(trialRecordTypeId).substring(0,15)||String.valueOf(Contractobj.RecordTypeId).substring(0,15) ==String.valueOf(consultingRecordTypeId).substring(0,15) ) && NULL!= Contractobj.AccountId && NULL!= Contractobj.Opportunity__c && Contractobj.OpportunityRecordType__c == 'New Business') {
                        setAccountId.add(Contractobj.AccountId); 
                    } 
                    else if(NULL!= Contractobj.AccountId && NULL!= Contractobj.Opportunity__c && Contractobj.OpportunityRecordType__c == 'Renewal') {
                        setOppId.add(Contractobj.Opportunity__c);
                    }
                }
                if(setAccountId != NULL && setAccountId.size()>0) {
                Map<Id,Account> mapAccValues = new Map<Id,Account>([Select Name,AccountCountry__c,BillingCity,BillingStreet,BillingCountry,BillingPostalCode,BillingState from Account where Id IN : setAccountId]);
                // query here whether i should create 2 lookup fields on oppty to store lookup country record data OR do all logic here                
                    for(Contract Contractobj : listContracts ) {
                            Account clientLegObj = mapAccValues.get(Contractobj.AccountId);
                            Contractobj.ShipToCity__c = clientLegObj.BillingCity;
                            Contractobj.ShipToClientName__c  = clientLegObj.Name;   
                            Contractobj.ShipToCountryCodeLookup__c = clientLegObj.AccountCountry__c;   
                            Contractobj.ShipToPostalZipCode__c = clientLegObj.BillingPostalCode;   
                            Contractobj.ShipToStateProvince__c = clientLegObj.BillingState;   
                            Contractobj.ShipToStreet__c  = clientLegObj.BillingStreet;
                            Contractobj.BillToCity__c = clientLegObj.BillingCity;
                            Contractobj.BillToClientName__c  = clientLegObj.Name;   
                            Contractobj.BillToCountryCodeLookup__c = clientLegObj.AccountCountry__c;   
                            Contractobj.BillToPostalZipCode__c = clientLegObj.BillingPostalCode;   
                            Contractobj.BillToStateProvince__c = clientLegObj.BillingState;   
                            Contractobj.BillToStreet__c  = clientLegObj.BillingStreet;                          
                        }
                }
                if(setOppId != NULL && setOppId.size()>0) {
                system.debug('here---'+setOppId);
                Map<Id,Opportunity> mapOppValues = new Map<Id,Opportunity>([Select BillToCity__c,ShipToCountryNew__c,BillToCountryNew__c,BillToClientName__c,BillToCompanySAP__c,BillToContactEmailAddress__c,BillToContactFirstName__c,BillToContactLastName__c,BillToContactSAP__c,BillToContactTelephoneNumber__c,BillToPostalZipCode__c,BillToStateProvince__c,BillToStreet__c,ShipToCity__c,ShipToClientName__c,ShipToCompanySAP__c,ShipToContactEmailAddress__c,ShipToContactFirstName__c,ShipToContactLastName__c,ShipToContactSAP__c,ShipToContactTelephoneNumber__c,ShipToPostalZipCode__c,ShipToStateProvince__c,ShipToStreet__c from Opportunity where Id IN : setOppId]);
                // query here whether i should create 2 lookup fields on oppty to store lookup country record data OR do all logic here                
                    system.debug('mapOppValues---'+mapOppValues);
                    for(Contract Contractobj : listContracts ) {
                            Opportunity opp = mapOppValues.get(Contractobj.Opportunity__c);
                            system.debug('opp---'+opp);
                            Contractobj.BillToCity__c = opp.BillToCity__c;
                            Contractobj.BillToClientName__c  = opp.BillToClientName__c;   
                            Contractobj.BillToCompanySAP__c = opp.BillToCompanySAP__c;   
                            Contractobj.BillToContactEmailAddress__c = opp.BillToContactEmailAddress__c;   
                            Contractobj.BillToContactFirstName__c = opp.BillToContactFirstName__c;   
                            Contractobj.BillToContactLastName__c  = opp.BillToContactLastName__c;
                            
                            Contractobj.BillToContactSAP__c = opp.BillToContactSAP__c;
                            Contractobj.BillToContactTelephoneNumber__c  = opp.BillToContactTelephoneNumber__c;   
                            Contractobj.BillToCountryCodeLookup__c = UtilityClass.getCountry(opp.BillToCountryNew__c) == null ? (UtilityClass.getCountryByIsoCode(opp.BillToCountryNew__c) == null ? null : UtilityClass.getCountryByIsoCode(opp.BillToCountryNew__c).Id) : UtilityClass.getCountry(opp.BillToCountryNew__c).Id;       
                            Contractobj.BillToPostalZipCode__c = opp.BillToPostalZipCode__c;   
                            Contractobj.BillToStateProvince__c = opp.BillToStateProvince__c;   
                            Contractobj.BillToStreet__c  = opp.BillToStreet__c;
                            
                            Contractobj.ShipToCity__c = opp.ShipToCity__c;
                            Contractobj.ShipToClientName__c  = opp.ShipToClientName__c;   
                            Contractobj.ShipToCompanySAP__c = opp.ShipToCompanySAP__c;   
                            Contractobj.ShipToContactEmailAddress__c = opp.ShipToContactEmailAddress__c;   
                            Contractobj.ShipToContactFirstName__c = opp.ShipToContactFirstName__c;   
                            Contractobj.ShipToContactLastName__c  = opp.ShipToContactLastName__c;
                            
                            Contractobj.ShipToContactSAP__c = opp.ShipToContactSAP__c;
                            Contractobj.ShipToContactTelephoneNumber__c  = opp.ShipToContactTelephoneNumber__c;   
                            Contractobj.ShipToCountryCodeLookup__c = UtilityClass.getCountry(opp.ShipToCountryNew__c) == null ? (UtilityClass.getCountryByIsoCode(opp.ShipToCountryNew__c) == null ? null : UtilityClass.getCountryByIsoCode(opp.ShipToCountryNew__c).Id) : UtilityClass.getCountry(opp.ShipToCountryNew__c).Id;  
                            Contractobj.ShipToPostalZipCode__c = opp.ShipToPostalZipCode__c;   
                            Contractobj.ShipToStateProvince__c = opp.ShipToStateProvince__c;   
                            Contractobj.ShipToStreet__c  = opp.ShipToStreet__c;                         
                        }
                }
            }
        catch (Exception e) {
               UtilityClass.createApexLogRecord(e,'ContractMethods','updateClientStateOfIncorporationFromClientLegalEntity'); 
           }
        }
    }
    
    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 6 June 2018
    // @Description :SFDC1-4421 Populate Bill To Fields on Contract with Global Alliance Fields when Opportunity
    // associated to Contract as Global Alliance Sales Channel (SFDC1-7542: converting process builder
    // 'PopulateBillToFieldsonContractwithGlobalAllianceFields' first part)
    // to this method
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    // @lastmodifiedby : Mohit Modi
    // @lastmodifieddate : 15 June 2018
    // @lastmodifiedDescription : SFDC1-8366, Updating 'ChannelPartnerCompanyName__c' from 'GlobalAllianceCompanyName__c' for CopyTo functionality.
    //-----------------------------
    public static void populateBillToFieldsonContractwithGlobalAllianceFields(TriggerParameters tp) {
        
       if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
            tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
        {
            try {
                List<Contract> listContracts = (List<Contract>) tp.newList;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                    for(Contract Contractobj : listContracts ) {
                        Contract oldContract;
                        if(tp.oldMap != null && tp.oldMap.get(Contractobj.Id) != null) {
                            oldContract = (Contract)tp.oldMap.get(Contractobj.Id);
                        }
                        if ((oldContract.CopytoBillTo__c !=Contractobj.CopytoBillTo__c)  
                            && (Contractobj.CopytoBillTo__c == TRUE)) {
                            Contractobj.BillToCity__c = Contractobj.GlobalAllianceAddressCity__c;
                            Contractobj.BillToClientName__c  = Contractobj.ChannelPartnerName__c;    
                            Contractobj.BillToContactEmailAddress__c = Contractobj.GlobalAllianceContactEmailAddress__c;   
                            Contractobj.BillToContactFirstName__c = Contractobj.GlobalAllianceContactFirstName__c;   
                            Contractobj.BillToContactLastName__c  = Contractobj.GlobalAllianceContactLastName__c;
                            
                            Contractobj.BillToContactTelephoneNumber__c  = Contractobj.GlobalAllianceContactPhoneNumber__c;   
                            Contractobj.BillToCountryCodeLookup__c = UtilityClass.getCountry(Contractobj.GlobalAllianceAddressCountry__c)== null?null:UtilityClass.getCountry(Contractobj.GlobalAllianceAddressCountry__c).Id;      
                            Contractobj.BillToPostalZipCode__c = Contractobj.GlobalAllianceAddressPostalZipCode__c;   
                            Contractobj.BillToStateProvince__c = Contractobj.GlobalAllianceAddressStateProvince__c;   
                            Contractobj.BillToStreet__c  = Contractobj.GlobalAllianceAddressStreet__c;
                        }
                    }
                }
                if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
                    for(Contract Contractobj : listContracts ) {
                        if (Contractobj.CopytoBillTo__c == TRUE && ! String.IsBlank(Contractobj.ChannelPartnerName__c)) {
                            Contractobj.BillToCity__c = Contractobj.GlobalAllianceAddressCity__c;
                            Contractobj.BillToClientName__c  = Contractobj.ChannelPartnerName__c;    
                            Contractobj.BillToContactEmailAddress__c = Contractobj.GlobalAllianceContactEmailAddress__c;   
                            Contractobj.BillToContactFirstName__c = Contractobj.GlobalAllianceContactFirstName__c;   
                            Contractobj.BillToContactLastName__c  = Contractobj.GlobalAllianceContactLastName__c;
                            
                            Contractobj.BillToContactTelephoneNumber__c  = Contractobj.GlobalAllianceContactPhoneNumber__c;   
                            Contractobj.BillToCountryCodeLookup__c = UtilityClass.getCountry(Contractobj.GlobalAllianceAddressCountry__c)== null?null:UtilityClass.getCountry(Contractobj.GlobalAllianceAddressCountry__c).Id;   
                            Contractobj.BillToPostalZipCode__c = Contractobj.GlobalAllianceAddressPostalZipCode__c;   
                            Contractobj.BillToStateProvince__c = Contractobj.GlobalAllianceAddressStateProvince__c;   
                            Contractobj.BillToStreet__c  = Contractobj.GlobalAllianceAddressStreet__c;
                        }
                    }                       
                }               
            }
        catch (Exception e) {
               UtilityClass.createApexLogRecord(e,'ContractMethods','updateClientStateOfIncorporationFromClientLegalEntity'); 
           }
        }
    }
    
    //-----------------------------
    // @Author : Prachi Bhasin
    // @Date : 6 June 2018
    // @Description :SFDC1-6994  This updates Bill to/Ship to fields on Opportunity where the contract is 'Originating Contract' 
    //(if oppty is open) (SFDC1-7542: converting process builder 'UpdateAddressOnRenewalOppty' 
    // to this method)
    // @param : TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Company: Vertiba
    // @return : Void
    // 
    // @ModifiedBy: Tran-Vu Tran
    // @ModifiedDate: 1 April 2019
    // @ModifiedDescription: SFDC-492 Do not update Opportunity Bill To/Ship To fields from Originating Contract when External Source System = "SAP"
    //-----------------------------
    public static void updateAddressOnRenewalOppty(TriggerParameters tp) {
        
       if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate)
        {
            try {
                List<Contract> listContracts = new List<Contract>();
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                Id renewalRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
                for (Contract c :(List<Contract>) tp.newList) {
                    Contract oldContract = mapOldContract.get(c.id);
                    if ((String.valueOf(c.RecordTypeId).substring(0, 15) == String.valueOf(orderFormRecordTypeId).substring(0,15))
                        && (c.BillToClientName__c != oldContract.BillToClientName__c ||
                            c.BillToCompanySAP__c != oldContract.BillToCompanySAP__c ||
                            c.BillToContactSAP__c != oldContract.BillToContactSAP__c ||
                            c.BillToContactFirstName__c != oldContract.BillToContactFirstName__c ||
                            c.BillToContactLastName__c != oldContract.BillToContactLastName__c ||
                            c.BillToContactEmailAddress__c != oldContract.BillToContactEmailAddress__c ||
                            c.BillToContactTelephoneNumber__c != oldContract.BillToContactTelephoneNumber__c ||
                            c.BillToStreet__c != oldContract.BillToStreet__c ||
                            c.BillToCity__c != oldContract.BillToCity__c || 
                            c.BillToStateProvince__c != oldContract.BillToStateProvince__c ||
                            c.BillToPostalZipCode__c != oldContract.BillToPostalZipCode__c ||
                            c.BillToCountryCodeLookup__c != oldContract.BillToCountryCodeLookup__c ||
                            c.ShipToClientName__c != oldContract.ShipToClientName__c ||
                            c.ShipToCompanySAP__c != oldContract.ShipToCompanySAP__c ||
                            c.ShipToContactSAP__c != oldContract.ShipToContactSAP__c ||
                            c.ShipToContactFirstName__c != oldContract.ShipToContactFirstName__c ||
                            c.ShipToContactLastName__c != oldContract.ShipToContactLastName__c ||
                            c.ShipToContactEmailAddress__c != oldContract.ShipToContactEmailAddress__c ||
                            c.ShipToContactTelephoneNumber__c != oldContract.ShipToContactTelephoneNumber__c ||
                            c.ShipToStreet__c != oldContract.ShipToStreet__c ||
                            c.ShipToCity__c != oldContract.ShipToCity__c ||
                            c.ShipToStateProvince__c != oldContract.ShipToStateProvince__c ||
                            c.ShipToPostalZipCode__c != oldContract.ShipToPostalZipCode__c ||
                            c.ShipToCountryCodeLookup__c != oldContract.ShipToCountryCodeLookup__c
                           )
                    ) {
                        listContracts.add(c);
                    }   
                }
                
                System.debug('listContracts----'+listContracts);
                if (listContracts != NULL && listContracts.size()>0) {
                    List<Contract> lstContract = new List<Contract>();
                    List<Opportunity> lstOpp = new List<Opportunity>();
                    lstContract = [Select Id, Name, BillToClientName__c, BillToCompanySAP__c, BillToContactSAP__c,
                                   BillToContactFirstName__c, BillToContactLastName__c, BillToContactEmailAddress__c, BillToContactTelephoneNumber__c, 
                                   BillToStreet__c, BillToCity__c, BillToStateProvince__c, BillToPostalZipCode__c, BillToCountryCodeLookup__r.Name,
                                   ShipToClientName__c, ShipToCompanySAP__c, ShipToContactSAP__c,
                                   ShipToContactFirstName__c, ShipToContactLastName__c, ShipToContactEmailAddress__c, ShipToContactTelephoneNumber__c, 
                                   ShipToStreet__c, ShipToCity__c, ShipToStateProvince__c, ShipToPostalZipCode__c, ShipToCountryCodeLookup__r.Name,
                                   (select Id, Name, SourceSystem__c from Opportunities2__r
                                    where RecordTypeId =:renewalRecordTypeId and StageName != '6W-Renewal Won' and StageName != '6W-Renewal Lost')
                                   from Contract where Id in : listContracts];
                    for (Contract c:lstContract) {
						 if(c.Opportunities2__r!= NULL && c.Opportunities2__r.size()>0){
                        for (Opportunity opp : c.Opportunities2__r) {
                            if (opp.SourceSystem__c != 'SAP') {
                                // SFDC-492 only populate Opportunity Bill To/Ship To fields from Originating Contract when External Source System is not "SAP"
                                opp.BillToClientName__c = c.BillToClientName__c;
                                opp.BillToCompanySAP__c = c.BillToCompanySAP__c;
                                opp.BillToContactSAP__c = c.BillToContactSAP__c;
                                opp.BillToContactFirstName__c = c.BillToContactFirstName__c;
                                opp.BillToContactLastName__c = c.BillToContactLastName__c;
                                opp.BillToContactEmailAddress__c = c.BillToContactEmailAddress__c;
                                opp.BillToContactTelephoneNumber__c = c.BillToContactTelephoneNumber__c;
                                opp.BillToStreet__c = c.BillToStreet__c;
                                opp.BillToCity__c = c.BillToCity__c;
                                opp.BillToStateProvince__c = c.BillToStateProvince__c;
                                opp.BillToPostalZipCode__c = c.BillToPostalZipCode__c;
                                opp.BillToCountryNew__c = c.BillToCountryCodeLookup__r.Name;
                                opp.ShipToClientName__c = c.ShipToClientName__c;
                                opp.ShipToCompanySAP__c = c.ShipToCompanySAP__c;
                                opp.ShipToContactSAP__c = c.ShipToContactSAP__c;
                                opp.ShipToContactFirstName__c = c.ShipToContactFirstName__c;
                                opp.ShipToContactLastName__c = c.ShipToContactLastName__c; 
                                opp.ShipToContactEmailAddress__c =c.ShipToContactEmailAddress__c;
                                opp.ShipToContactTelephoneNumber__c = c.ShipToContactTelephoneNumber__c;
                                opp.ShipToStreet__c = c.ShipToStreet__c;
                                opp.ShipToCity__c = c.ShipToCity__c;
                                opp.ShipToStateProvince__c = c.ShipToStateProvince__c;
                                opp.ShipToPostalZipCode__c = c.ShipToPostalZipCode__c;
                                opp.ShipToCountryNew__c= c.ShipToCountryCodeLookup__r.Name;
                            }
                        }
                        lstOpp.addAll(c.Opportunities2__r);
						 }
                    }                   
                    update lstOpp;
                }
            }
            catch (Exception e) {
                UtilityClass.createApexLogRecord(e,'ContractMethods','updateAddressOnRenewalOppty'); 
            }
        }
    }
    
    //-----------------------------
    // @author: Ankita Singh
    // @date: 12 June 2018
    // @description: SFDC1-8051- Validating IHS Markit Legal Entity list of values(lookup on contract) by eligibility and Record Type of Contract.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @companyname: VERTIBA
    // @lastModifiedBy: Vishnu Vardhan Chowdary
    // @lastModifiedDate: 20 Nov 2018
    // @lastModifiedDescription: SFDC1-10049: On seeing the demo, Debbie has mentioned that Contract can have legal entity
    // 		for a particular record type, only when EligibleXXX has Yes as the value. So, if the field dont have any value
    // 		then dont allow the contract to be created. 
    // @lastModifiedBy: Vishnu Vardhan Chowdary
    // @lastModifiedDate: 05 Dec 2018
    // @lastModifiedDescription: SFDC1-10522: Adding the validation for NDA Record type.
    // @return: void
    // @last Modified by : Akshay Dogra
    // @last modified description :17 Sep 2020 , SFDC-3202 :This method is replaced by Validation Rule: <PreventNonEligibleContractCloning>.So commenting this method.
    //-----------------------------
    /*public static void validateLegalEntityOnContract(TriggerParameters tp) {
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {   
            
            List<Contract> listContracts = (List<Contract>) tp.newList;
            Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
            Map<Id,Contract> mapContract = new Map<Id,Contract>();
            Set<Id> legalEntity = new Set<Id>();
            // Fetching Contract RecordType Id
            Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
            Id continuationLetterRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Continuation Letter').getRecordTypeId();
            Id DPARecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('DPA').getRecordTypeId();
            Id MSTRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Managed Service Terms (MST)').getRecordTypeId();
            Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
            Id ndaRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('NDA').getRecordTypeId();
            Id ThirdpartyProcessorRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Third Party Processor Agreement').getRecordTypeId();
            
            for(Contract Contractobj : listContracts ) {
                Contract oldContract = mapOldContract.get(Contractobj.id);
                    // filtering relevant contract Ids and associated Legal Entity Ids selected from the lookup
                    mapContract.put(Contractobj.id,Contractobj);
                    legalEntity.add(Contractobj.IHSMarkitLegalEntity__c);
            }
            // Fectching Legal Entity Field values for the correspoding contract Ids
            Map<ID, LegalEntity__c> legalEntityMAP = new Map<ID, LegalEntity__c>([Select Id,EligibleforStatementofWork__c,EligibleforDPA__c,EligibleforMangedServiceTerms__c,EligibleforMasterAgreement__c,EligibleforContinuation__c,EligibleforTrial__c,EligibleforNDA__c,ThirdPartyProcessorAgreement__c from LegalEntity__c where Id IN:legalEntity]);
            // Validating the legal entity seleted from lookup wether it is valid for the particular contract Id else throw error
            for(Id contractId : mapContract.keySet()) {
                Contract c = mapContract.get(contractId);
                if(legalEntityMAP != NULL && legalEntityMAP.size() > 0 && legalEntityMAP.containskey(c.IHSMarkitLegalEntity__c)) {
                    if(mapContract.get(contractId).RecordTypeId==consultingRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforStatementofWork__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==trialRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforTrial__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==continuationLetterRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforContinuation__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==DPARecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforDPA__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==MSTRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforMangedServiceTerms__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==masterAgreementRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforMasterAgreement__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==ndaRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).EligibleforNDA__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } else if(mapContract.get(contractId).RecordTypeId==ThirdpartyProcessorRecordTypeId && legalEntityMAP.get(c.IHSMarkitLegalEntity__c).ThirdPartyProcessorAgreement__c != 'Yes') {
                        c.addError(Label.LegalEntityErrorOnContract);
                    } 
                }
            } 
        }
    }*/
	
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 20 Jun 2018
    // @description: SFDC1-8533 Convert Process Builder flow "Roll up Annual And Total Contract Value on Opportunity" on Contract object created in SFDC1-5906(this is to roll up contract values on Parent Opportunity whenever Value fields gets updated.) + SFDC1-7233(Removed the dependency of Opportunity's 'Total Contract Value' field.) to a trigger
    // 				 This methods updates Total Annual Contract Value field on parent Opportunity record during after update transactions.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.    
    // @return: None
    // @last Modified by : Mohit Modi
    // @last modified description :30 Oct 2018 , SFDC1-10188 : Field 'Total Annual Contract Value' [TotalAnnualContractValue__c] added to Deletion list, So Commenting this Method.
    //-----------------------------
    /*
    public static void updateTotalAnnualContractValueOnOpp(TriggerParameters tp) {
        Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id newBusinessOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id renewalOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        List<Opportunity> oppUpdateList = new List<Opportunity>();        
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id,Contract> newContractMap = new Map<Id,Contract>();
        
        for(Contract newContractObj : (List<Contract>)tp.newList) {
            Contract oldContract = (Contract) tp.oldMap.get(newContractObj.Id);
            if(newContractObj.Opportunity__c != null &&
              (newContractObj.FirstYearContractValue__c != oldContract.FirstYearContractValue__c || newContractObj.TotalContractValue__c != oldContract.TotalContractValue__c)) {
                contractIdSet.add(newContractObj.Id);                
            }
        }        
        
        if(contractIdSet.size() > 0) {
            newContractMap.putAll([Select Id, RecordTypeId, Opportunity__c, FirstYearContractValue__c, TotalContractValue__c,
                                   Opportunity__r.RecordTypeId, Opportunity__r.AutoRenewal__c, Opportunity__r.ContractBeingRenewed__c, Opportunity__r.ContractBeingRenewed__r.FirstYearContractValue__c 
                                   From Contract 
                                   Where Id IN :contractIdSet AND Opportunity__c != Null]);
        }
        contractIdSet.clear();
        
        if(newContractMap.size() > 0) {
            for(Contract newContract: newContractMap.values()) {                        
                if(newContract.RecordTypeId == orderFormContractRecTypeId && (newContract.Opportunity__r.RecordTypeId == newBusinessOppRecTypeId || newContract.Opportunity__r.RecordTypeId == renewalOppRecTypeId)) {                       
                    Opportunity oppUpdate = new Opportunity(Id=newContract.Opportunity__c);                       
                    if(newContract.Opportunity__r.RecordTypeId == renewalOppRecTypeId && newContract.Opportunity__r.AutoRenewal__c && 
                       newContract.Opportunity__r.ContractBeingRenewed__c != null && newContract.Opportunity__r.ContractBeingRenewed__r.FirstYearContractValue__c != null) {
                           oppUpdate.TotalAnnualContractValue__c = newContract.Opportunity__r.ContractBeingRenewed__r.FirstYearContractValue__c + newContract.FirstYearContractValue__c;
                       }
                    else {                           
                        oppUpdate.TotalAnnualContractValue__c = newContract.FirstYearContractValue__c;
                    }
                    oppUpdateList.add(oppUpdate);                   
                }
            }
        }
        
        try {
            if(oppUpdateList.size() > 0) {
                update oppUpdateList;
            }
        }        
        catch(Exception ex) {
            //UtilityClass.createApexLogRecord(ex, 'ContractMethods', 'updateTotalAnnualContractValueOnOpp');		//The custom exception below will rollback this DML hence commented.
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            System.debug('Exception in updateTotalAnnualContractValueOnOpp() method. Description:'+description);
            throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
        }        
    }
    */
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 21 Jun 2018
    // @description: SFDC1-8533 Convert Process Builder flow "SendNotificationtoOpportunityOwneronContractCancellation" on Contract object created in SFDC1-802(Send Notification to Opportunity Owner when Cancel Request Received Date on  Contract is filled) to a trigger
    // 				 This methods updates Oppty Owner Email field on Contract record during before update transactions.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @Modified By : Sruti Srivastava
    // @Modification Date: 3 Aug 2018
    // @Modification Description: SFDC1-8759-OpptyOwnerEmail__c should store Opportunity Owner Email Id, 
    // so email alert can be sent when Contract is rejected
    // @return: None
    //-----------------------------
    public static void setOpptyOwnerEmail(TriggerParameters tp) {        
        List<Contract> contractListToUpdate = new List<Contract>();
        Set<Id> oppIdSet = new Set<Id>();
        //Get Opportunity records
        for(Contract newContract: (List<Contract>)tp.newList) {
            Contract oldContract = (Contract)tp.oldMap.get(newContract.Id);
            //CHceking if ContractStatus is marked as "Rejected" or CancelRequestReceivedDate is changed
            if(newContract.Opportunity__c != null && 
               (newContract.CancelRequestReceivedDate__c != null && newContract.CancelRequestReceivedDate__c != oldContract.CancelRequestReceivedDate__c)
              || (!String.isblank(newContract.ContractStatus__c)  && newContract.ContractStatus__c.equalsIgnoreCase('Rejected')
                 && (String.isblank(oldContract.ContractStatus__c) || ( !String.isblank(oldContract.ContractStatus__c) &&
                                                                       !oldContract.ContractStatus__c.equalsIgnoreCase('Rejected'))))) {
                //newContract.OpptyOwnerEmail__c = newContract.Opportunity__r.Owner.Email;
                //Get Opportunity Ids
                oppIdSet.add(newContract.Opportunity__c);
                contractListToUpdate.add(newContract);
            }
        }
        
        //Get Opportunity Owners' Email
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        if(oppIdSet.size() > 0) {
            oppMap.putAll([SELECT Id,Opportunity.Owner.Email FROM Opportunity WHERE Id IN :oppIdSet]);
        }        
        
        //Set Email on Contract
        if(oppMap.size() > 0 && contractListToUpdate.size() > 0) {
            for(Contract updContract: contractListToUpdate) {                
                updContract.OpptyOwnerEmail__c = oppMap.get(updContract.Opportunity__c).Owner.Email;                
            }
        }        
    }

	//-----------------------------
    // @author: Harshit Singhal
    // @date: 22 Jun 2018
    // @description: SFDC1-8533 Convert Process Builder flow "Sync Contract Object Dates to Opportunity Contract Dates" on Contract object created in SFDC1-653(If contract dates are changed they should flow back to opportunity till opportunity reaches a read only stage i.e 6W stage) to a trigger
    // 				 This methods updates Contract Start Date and Contract End Date field on all child opportunities of a Contract based on a criteria during after insert and after update operations.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got inserted and updated.
    // @return: None
    //-----------------------------
    public static void updateOpptyContractStartEndDates(TriggerParameters tp) {
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        List<String> eligibleStageList = new List<String> {'6L-Renewal Lost','6L-Closed Lost','6W-Closed Won','6W-Renewal Won'};
        
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id,Contract> newContractMap = new Map<Id,Contract>();
        for(Contract newContractObj : (List<Contract>)tp.newList) {            
            if(newContractObj.Opportunity__c != null) {
                contractIdSet.add(newContractObj.Id);                
            }
        }        
        if(contractIdSet.size() > 0) {
            newContractMap.putAll([Select Id, (Select Id From Opportunities), StartDate, EndDate, Opportunity__c, Opportunity__r.StageName
                                   From Contract 
                                   Where Id IN :tp.newList AND Opportunity__c != Null]);
        }
        if(newContractMap.size() > 0) {
            for(Contract newContract: newContractMap.values()) {
                if(eligibleStageList.contains(newContract.Opportunity__r.StageName)) {
                    for(Opportunity oppUpdate: newContract.Opportunities) {                        
                        oppUpdate.ContractStartDate__c = newContract.StartDate;
                        oppUpdate.ContractEndDate__c = newContract.EndDate;
                        oppUpdateList.add(oppUpdate);
                    }
                }
            }  
        }
        
        try {                    
            if(oppUpdateList.size() > 0) {
                update oppUpdateList;                
            }            
        }
        catch(Exception ex) {            
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            System.debug('Exception in updateOpptyContractStartEndDates() method. Description:'+description);
            throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
        }        
    }
        
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Jun 2018
    // @description: SFDC1-8533 Convert Process Builder flow "UpdateGeneralAgreementEffectiveDateOnOrderForm" on Contract object created in SFDC1-5851(Agreement Effective Date automatically updated if the General Agreement has its Effective Date changed) to a trigger
    // 				 This methods updates Agreement Effective Date field on child Order Form contracts during after update operation on General Agreement contract.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // @return: None
    //-----------------------------
    public static void updateAgreementEffectiveDateOnOrderFormAgreements(TriggerParameters tp) {        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id masterAgreementRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Master Agreement').getRecordTypeId();
        Set<Id> masterAgreementIdSet = new Set<Id>();
        List<Contract> orderFormContractUpdateList = new List<Contract>();
        
        for(Contract newContract: (List<Contract>) tp.newList) {
            Contract oldContract = (Contract) tp.oldMap.get(newContract.Id);
            if(newContract.RecordTypeId == masterAgreementRecordTypeId && newContract.EffectiveDate__c != oldContract.EffectiveDate__c ) {
                masterAgreementIdSet.add(newContract.Id);                
            }
        }
        if(masterAgreementIdSet.size() > 0) {
            for(Contract contractUpdate:[SELECT Id,GeneralAgreement__c FROM Contract WHERE GeneralAgreement__c IN :masterAgreementIdSet AND RecordTypeId = :orderFormRecordTypeId]) {
                contractUpdate.GeneralAgreementDate__c = ((Contract)tp.newMap.get(contractUpdate.GeneralAgreement__c)).EffectiveDate__c;
                orderFormContractUpdateList.add(contractUpdate);
            }    
        }
        
        try {            
            if(orderFormContractUpdateList.size() > 0) {                
                update orderFormContractUpdateList;
            }    
        }
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            System.debug('Exception in updateAgreementEffectiveDateOnOrderFormAgreements() method. Description:'+description);
            throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Jun 2018
    // @description: SFDC1-8533 Convert Process Builder flow "ReadyforProcessingStageOpportunityUpdate" on Contract object created in SFDC1-5253(Move the Contract stage to 'Ready for Processing' updates the related opportunity to 6W) to a trigger
    // 				 This methods updates Stage field on parent Opportunity record during after update transactions.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    // 
    // @modified by: Harshit Singhal
    // @date: 29 Jun 2018
    // @description: SFDC1-8955 Changes to update Opportunity to 6W stages if related Consulting contract is moved to 'Ready For Processing'
    // Updated By: Sruti Srivastava
	// LastModifiedDate: 12 October 2018
    // Description: SFDC1-10185 - Update Opportunity to 6WP, when Contract Status is updated to "Validated PO Pending"
    // @return: None
    // @modified by: Paras Dhingra
    // @modified date: 02nd April 2020
    // @modified reason: SFDC-2396 commenting the code for SFDC1-10185 as 6WP can only be set via batch from SAP renewals and through OM case validation
    // @modified by: Priyanka Vyas
    // @modified date: 12th Oct 2020
    // @modified reason: SFDC-3258 Show error on UI if validation exception is encountered.
    // @modified by: Sharique Iqbal
    // @modified date: 1st Feb 2021
    // @modified reason: SFDC-2515- Do not update Opportunity to 6WP, when Contract Status is updated to 'Validated-BSI Pending' or 'Validated by ConsOps'
    //-----------------------------
    public static void updateStageOnOpp(TriggerParameters tp) {                
        Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        
        Id newBusinessOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Id renewalOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        Id placeholderOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Forecasting Placeholder').getRecordTypeId();
        Id gratisOppRecTypeId = Schema.SobjectType.Opportunity.getRecordTypeInfosByName().get('Gratis').getRecordTypeId();
        Set<Id> opptyIdSet = new Set<Id>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        Set<Id> opptyIdSetToUpdateTo6WP = new Set<Id>();
        for(Contract newContract : (List<Contract>)tp.newList) {
            if((newContract.RecordTypeId == orderFormContractRecTypeId || newContract.RecordTypeId == consultingContractRecTypeId) && newContract.Opportunity__c != null && (newContract.Status == 'ReadyForProcessing' || newContract.Status == 'Complete')
              && newContract.ContractStatus__c != 'Validated-BSI Pending' && newContract.ContractStatus__c != 'Validated by ConsOps') {            
                Contract oldContract = (Contract)tp.oldMap.get(newContract.Id);
                if(newContract.Status != oldContract.Status) {
                    opptyIdSet.add(newContract.Opportunity__c);
                }
                /*  
                else if(newContract.Opportunity__c != null && !String.isblank(newContract.Status) && 
				newContract.Status.equalsIgnoreCase('Complete')  && newContract.ContractStatus__c == 'Validated PO Pending') {
					opptyIdSetToUpdateTo6WP.add(newContract.Opportunity__c);
				}*/
            }
        }
        Set<Id> setAllOpportunityIdtoUpdate = new Set<Id> ();
        /*if(opptyIdSetToUpdateTo6WP.size() > 0) {
			setAllOpportunityIdtoUpdate.addAll(opptyIdSetToUpdateTo6WP);
		}*/
        if(opptyIdSet.size() > 0) {
			setAllOpportunityIdtoUpdate.addAll(opptyIdSet);
		}
        if(setAllOpportunityIdtoUpdate.size() > 0) {
            for(Opportunity oppToUpdate: [SELECT Id,StageName,RecordTypeId FROM Opportunity WHERE Id IN :setAllOpportunityIdtoUpdate]) {
                if(opptyIdSet.contains(oppToUpdate.Id)) {
                    //Set Stage for New Business Opportunity
                    if(oppToUpdate.RecordTypeId == newBusinessOppRecTypeId && oppToUpdate.StageName != '6W-Closed Won' && oppToUpdate.StageName != '6L-Closed Lost') {                    
                        oppToUpdate.ReadyForProcessingContractExist__c = true;                    
                        oppToUpdate.StageName = '6W-Closed Won';
                        oppUpdateList.add(oppToUpdate);
                    }
                    //Set Stage for Renewal Opportunity
                    else if(oppToUpdate.RecordTypeId == renewalOppRecTypeId && oppToUpdate.StageName != '6W-Renewal Won' && oppToUpdate.StageName != '6L-Renewal Lost') {
                        oppToUpdate.ReadyForProcessingContractExist__c = true;                    
                        oppToUpdate.StageName = '6W-Renewal Won';
                        oppUpdateList.add(oppToUpdate);
                    }
                    //Set Stage for Forecasting Placeholder Opportunity
                    else if(oppToUpdate.RecordTypeId == placeholderOppRecTypeId && oppToUpdate.StageName != '6W-Forecasting Placeholder' && oppToUpdate.StageName != '6L-Forecasting Placeholder') {
                        oppToUpdate.ReadyForProcessingContractExist__c = true;                    
                        oppToUpdate.StageName = '6W-Forecasting Placeholder';
                        oppUpdateList.add(oppToUpdate);
                    }
                    //Set Stage for Gratis Opportunity
                    else if(oppToUpdate.RecordTypeId == gratisOppRecTypeId) {
                        oppToUpdate.ReadyForProcessingContractExist__c = true;                    
                        oppToUpdate.StageName = '6W-Closed Won';
                        oppUpdateList.add(oppToUpdate);
                    }
                    //SFDC1-10185: updating Opprtunity stage to 6WP
                    /*if(opptyIdSetToUpdateTo6WP.contains(oppToUpdate.Id) && oppToUpdate.StageName != '6WP-Closed Won/Order Processed	' ) {
						oppToUpdate.StageName = '6WP-Closed Won/Order Processed	';
						oppUpdateList.add(oppToUpdate);
					}*/
                }
            }
        }
        
        try {
            if(oppUpdateList.size() > 0) {
                update oppUpdateList;                
            }            
        }
        catch(Exception ex) {
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                for(Contract newContract : (List<Contract>)tp.newList) {
                    String errorMessage=ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1].contains(Label.OppyAtRiskStatusMsgOnOpp) ? Label.OppyAtRiskStatusMsgOnContract : ex.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':');
                    newContract.addError(errorMessage);
                }
            }
            else{
                String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
                System.debug('Exception in updateStageOnOpp() method. Description:'+description);
                throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
            }
        }        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Jun 2018
    // @description: SFDC1-8533 Convert Process Builder flow "Update Contract Line Item Currency when Order Form Currency changes" on Contract object created in SFDC1-7467(When Contract Currency changes, change contract line currency as well.) to a trigger
    // 				 This methods copies Contract Currency from parent contract to Currency on child contract line items during after update transactions.
    // @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.    
    // @return: None
    //-----------------------------
    public static void updateCurrencyOnContractLineItems(TriggerParameters tp) {        
        Set<Id> parentContractIdSet = new Set<Id>();
        List<ContractLineItem__c> lineItemUpdateList = new List<ContractLineItem__c>();
        for(Contract newContract : (List<Contract>)tp.newList) {
            Contract oldContract = (Contract)tp.oldMap.get(newContract.Id);
            if(newContract.CurrencyIsoCode != oldContract.CurrencyIsoCode) {
                parentContractIdSet.add(newContract.Id);
            }
        }
        if(parentContractIdSet.size() > 0) {
            for(ContractLineItem__c lineItemUpdate : [SELECT Id,Contract__c FROM ContractLineItem__c WHERE Contract__c IN :parentContractIdSet]) {
                lineItemUpdate.CurrencyIsoCode = ((Contract)tp.newMap.get(lineItemUpdate.Contract__c)).CurrencyIsoCode;
                lineItemUpdateList.add(lineItemUpdate);
            }    
        }
        
        try {
            if(lineItemUpdateList.size() > 0) {
                update lineItemUpdateList;                
            }
        }
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            System.debug('Exception in updateCurrencyOnContractLineItems() method. Description:'+description);
            throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
        }
    }
		//-----------------------------
    // @author: Anjani Shukla	
    // @date: 23 July 2018
    // @description: SFDC1-5864 - This method will replace process builder which updates contract default value when status ='Creation' and autorenewal is //                            true. Due to rollupsummary field values are not available in before so written in After.
    // @return: None
    //-----------------------------
    public static void updateDefaultContractCumulative(TriggerParameters tp) {  
        try{
            if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
                Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                Map<Id,Contract> mapNewContract = (Map<Id,Contract>) tp.newMap;
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>) tp.oldMap;
                Set<Id> contractIds = new Set<Id>();
                //get opty ids
                if(mapNewContract != null) {
                    for(Contract newContract: mapNewContract.values()) {
                        if(newContract.Status == 'Creation' && 
						   newContract.Status != mapOldContract.get(newContract.Id).status &&
                           newContract.AutoRenewal__c && 
                           newContract.RecordTypeId == orderFormContractRecTypeId
                          ) {
                            contractIds.add(newContract.id);
                        	
                        }    
                    }
                }
                
                
                //get Opportunity
                Map<Id,Contract> contractRenewedMap = new  Map<Id,Contract>();
                //get Details for Contract being Renewed
                if(contractIds != null) {
                	contractRenewedMap = new Map<Id,Contract>([select Id,AllAssociatedTotalOpportunityValue__c,
                                                               AutoRenewal__c,ContractStatus__c,
                                                               FirstYearContractValue__c,
                                                               Name,Opportunity__c,Status,
                                                               Opportunity__r.ContractBeingRenewed__c,
                                                               TotalContractValue__c,RecordTypeId 
                                                               from Contract where ID IN: contractIds]);	    
                }  
                
                system.debug('contractRenewedMap==>'+contractRenewedMap.values());
                
                //List to update
                List<Contract> updateContractDefaultValue = new List<Contract>();
                
                //check whether annualcumulative value is NULL on Contract Creation.
                if(contractRenewedMap != null) {
                    for(Contract newContract: contractRenewedMap.values() ) {
                        
                        if(newContract.id == mapNewContract.get(newContract.id).id && 
                           newContract.Status != mapOldContract.get(newContract.Id).status &&
                           newContract.Status == 'Creation'
                          ) {                           
                               // Now Capture Contract Id where we have to set Contract default value.
							   // Assign default total contract value when status is Creation and autorenewal is true.
                               Contract updateContract = new Contract(id= newContract.Id);
                               updateContract.AllAssociatedTotalOpportunityValue__c = newContract.TotalContractValue__c;                           
                               updateContractDefaultValue.add(updateContract);
                               system.debug('updateContractDefaultValue==>'+updateContractDefaultValue);
                           }    
                    }   
                }
                
                if(updateContractDefaultValue != null) {
                    update updateContractDefaultValue;    
                }
                
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex,'ContractMethods','updateDefaultContractCumulative');  
        }
	}
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 09 Sep 2019
    // @param: TriggerParameters
    // @description: SFDC-1973 : Contract validation to make EarliestTerminationPeriod__c and ContractSpecialOptions__c fields required 
    // on consulting and OF contract if opp is New business, Non auto-renewal and auto-renewal with change and atleast one oppy product has ASC606RevRec__c=yes
    // @return: None
    //------------------------------
    public static void contractCheckASC606RevRecProductValidation(TriggerParameters tp) {        
        Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        
        Map<Id,Id> ctrctIdOppIdMap = new Map<Id,Id>();
        
        for(Contract ctrct: (List<Contract>)tp.newMap.values() ) {
            Contract oldCtrct = (Contract)tp.oldMap.get(ctrct.Id);
            if((ctrct.RecordTypeId==orderFormRecordTypeId || ctrct.RecordTypeId==consultingRecordTypeId) && ctrct.Status=='ReadyForProcessing' && ctrct.Status!=oldCtrct.Status 
               && (ctrct.OpportunityRecordType__c=='New Business' || ctrct.OpportunityRecordType__c=='Renewal')
               && (String.isBlank(ctrct.EarliestTerminationPeriod__c) || String.isBlank(ctrct.ContractSpecialOptions__c)) ) {                   
                   ctrctIdOppIdMap.put(ctrct.Id, ctrct.Opportunity__c);
            }
        }
        if(ctrctIdOppIdMap.size() > 0) {
            Set<Id> oppIdSet = new Set<Id>();
            oppIdSet.addAll(ctrctIdOppIdMap.values());
            Map<Id,Boolean> oppIdFlagMap = OpportunityMethods.checkIfOppyHasASC606RevRecProduct(oppIdSet, 'ContractTrigger');
            for(Id ctrctId: ctrctIdOppIdMap.keySet()) {
                if(oppIdFlagMap!=null && oppIdFlagMap.containsKey(ctrctIdOppIdMap.get(ctrctId)) && oppIdFlagMap.get(ctrctIdOppIdMap.get(ctrctId))) {
                    Contract ctrctToError = (Contract)tp.newMap.get(ctrctId);
                    String errorMsg = ctrctToError.EarliestTerminationPeriod__c==null && ctrctToError.ContractSpecialOptions__c==null ? 'Please populate Earliest Termination Period and Contract Special Options.': (ctrctToError.EarliestTerminationPeriod__c==null ? 'Please populate Earliest Termination Period.':'Please populate Contract Special Options.');
                    ctrctToError.addError(errorMsg);
                }
            }
        }
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 16 Jun 2020
    // @param: TriggerParameters
    // @description: SFDC-3071, SFDC-2713 blocking Sales general users from modifying contract on 11-Complete stage
    // on consulting and OF contract if opp is New business, Non auto-renewal and auto-renewal with change and atleast one oppy product has ASC606RevRec__c=yes
    // @return: None
    //------------------------------   
    public static void blockSalesGeneralOnCompletedContract(TriggerParameters tp) {
        //flag has been turned on by some other 
        if(GlobalVariables.shouldContractValidationBypass) {
            return;
        }
        Set<String> setAllowedFields = new Set<String>{'orderreason__c','name','replacementcontract__c','originatingcontractforaddon__c','description','specialterms','internalinstructions__c'};
        Set<String> setProfilesBlocked = new Set<String>{'IHSMarkit Sales: General'};
        //get logged in user profile name
        String profileName = UtilityClass.LoggedInUserProfileName;
        System.debug('@PD--Profilename--'+profileName);
        if(setProfilesBlocked.contains(profileName)) {//block only if user is part of blocked profiles
            //traverse contract fields and check if they are changed or not
            System.debug('found');
            Map <String, Schema.SobjectField > contractFields = Contract.sObjectType.getDescribe().fields.getMap();
            for(Contract cont : (List<Contract>) tp.newList) {
                Boolean hasError = false;
                Contract oldContract = (Contract) tp.OldMap.get(cont.Id);
                if(oldContract.ContractStatus__c != cont.ContractStatus__c && oldContract.ContractStatus__c.containsIgnoreCase('Validated') && !cont.ContractStatus__c.containsIgnoreCase('Replaced')) {
                    cont.addError('You are allowed to move validated contract status only to Replacement');
                    continue;//exit this iteration and move to next record
                }
                if(cont.ContractStatus__c.containsIgnoreCase('Validated') && !GlobalVariables.allowSalesGeneralToUpdateContractStatus) {
                    //validated change in fields
                    for(string fieldName : contractFields.keySet()) {
                        Schema.DescribeFieldResult dfr = contractFields.get(fieldName).getDescribe();
                        if(oldContract.get(fieldName)!=cont.get(fieldName) && !dfr.IsCalculated() && !setAllowedFields.contains(fieldName)) {
                            hasError = true;
                            break;//Error found
                        }
                    }
                    if(hasError) {
                        cont.addError('You are not allowed to modify the contract once it is validated');
                    }
                }
                
            }
        }

    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 22 July 2020
    // @param: TriggerParameters
    // @description: SFDC-2662, Master Agreement Exhibit validation (Code To be enabled for 11th August 2020 release)
    // @return: None
    //------------------------------  
    public static void masterAgreementExhibitCheck(TriggerParameters tp) {
        String currentUserProfileName = UtilityClass.LoggedInUserProfileName;
        if(UserInfo.getName()!=Label.BatchAdminUserName && Label.RunMasterAgreementExhibitCheck=='TRUE' && !Label.ExcludeProfilesmasterAgreementExhibitCheck.contains(currentUserProfileName)) {
            List<Contract> newContractList = (List<Contract>) tp.newList;
            Map<ID, Contract> contractMap = new Map<Id, Contract>();
            List<String> stageNames = new List<String>();
            List<String> masterAgrTypesForMAE = new List<String>();
            stageNames=Label.MasterAgreementExhibitContractStages.split(',');
            masterAgrTypesForMAE=Label.MasterAgrTypeForMAE.split(',');
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            /*for(Contract contractObj:listContracts) {
				if(contractObj.RecordTypeId==orderFormRecordTypeId && mapOldContract.get(contractObj.Id).GeneralAgreement__c!=null && contractObj.GeneralAgreement__c!=null && contractObj.Fastrack__c==false){
					if((contractObj.status!=mapOldContract.get(contractObj.id).status && stageNames.contains(contractObj.Status)) ||
						(contractObj.GeneralAgreementType__c!=mapOldContract.get(contractObj.id).GeneralAgreementType__c && masterAgrTypesForMAE.contains(contractObj.GeneralAgreementType__c)) ||
						(contractObj.Fastrack__c!=mapOldContract.get(contractObj.id).Fastrack__c)){
							contractMap.put(contractObj.id,contractObj);
					}
				}
			}*/
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
                for(Contract newContract:newContractList) {
                    Contract oldContract = mapOldContract.get(newContract.id);
                    if((newContract.status!=oldContract.status) ||
                       (newContract.GeneralAgreementType__c!=oldContract.GeneralAgreementType__c) ||
                       (newContract.Fastrack__c!=oldContract.Fastrack__c ) ||
                       (newContract.NoInternalApprovalNeeded__c!=oldContract.NoInternalApprovalNeeded__c )) {
                           if(newContract.RecordTypeId==orderFormRecordTypeId && stageNames.contains(newContract.Status) && masterAgrTypesForMAE.contains(newContract.GeneralAgreementType__c) && newContract.Fastrack__c==false && newContract.NoInternalApprovalNeeded__c) {
                               contractMap.put(newContract.id,newContract);
                           }
                       }
                }
            }
            if(!contractMap.isEmpty()) { 
            	masterAgreementExhibitCheckMethod(contractMap, stageNames, orderFormRecordTypeId, masterAgrTypesForMAE);
            }
        }
    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 22 July 2020
    // @param: TriggerParameters
    // @description: SFDC-2662, Method for logic of  Master Agreement Exhibit validation(Code To be enabled for 11th August 2020 release)
    // @return: None
    //------------------------------  
    public static void masterAgreementExhibitCheckMethod(Map<ID, Contract> contractMap, List<String> stageNames, Id orderFormRecordTypeId, List<String> masterAgrTypesForMAE){
        if(contractMap!=null && !contractMap.isEmpty() && stageNames!=null && !stageNames.isEmpty() && masterAgrTypesForMAE!=null && !masterAgrTypesForMAE.isEmpty()) {
            List<Contract> cList = new List<Contract>();
            List<ContractLineItem__c> cliList=new List<ContractLineItem__c>();
            List<MasterAgreementExhibit__c> maeList = new List<MasterAgreementExhibit__c>();
            Map<Contract,Set<String>> contractToCLIExhibitType = new Map<Contract,Set<String>>();
            Map<Contract,Set<String>> contractToMAEExhibitType = new Map<Contract,Set<String>>();
            
            //cList=[Select id, (Select Id, Contract__c, GoverningExhibit__c from Contract_Line_Items__r where (GoverningExhibit__c='Data' or GoverningExhibit__c='Software' or GoverningExhibit__c='Services')), (Select id, OrderFormOrConsulting__c,MasterAgreementExhibit__r.ExhibitType__c from MasterAgreementExhibits__r where (MasterAgreementExhibit__r.ExhibitType__c='Data' or MasterAgreementExhibit__r.ExhibitType__c='Software')) from Contract where id in:contractMap.keySet()];
            cList=[Select id, (Select Id, Contract__c, GoverningExhibit__c from Contract_Line_Items__r where (GoverningExhibit__c='Data' or GoverningExhibit__c='Software' or GoverningExhibit__c='Services') AND (AssociatedProduct__r.Division__c='Consolidated Markets & Solutions' or AssociatedProduct__r.Division__c='Resources' or AssociatedProduct__r.Division__c='Transportation')), (Select id, OrderFormOrConsulting__c,MasterAgreementExhibit__r.ExhibitType__c from MasterAgreementExhibits__r) from Contract where id in:contractMap.keySet()];
            for(Contract c:cList){
                cliList.addAll(c.Contract_Line_Items__r);
                maeList.addAll(c.MasterAgreementExhibits__r);
            }
            if(cliList!=null && !cliList.isEmpty()){    
                for(ContractLineItem__c cli:cliList) {
                    if(cli.GoverningExhibit__c!=null && cli.GoverningExhibit__c!='') {
                        if(!contractToCLIExhibitType.keySet().contains(contractMap.get(cli.Contract__c))) {
                            contractToCLIExhibitType.put(contractMap.get(cli.Contract__c), new Set<String>{cli.GoverningExhibit__c});
                        }
                        else {
                            contractToCLIExhibitType.get(contractMap.get(cli.Contract__c)).add(cli.GoverningExhibit__c);
                        }
                    }
                }
            }
            if(maeList!=null && !maeList.isEmpty()) {   
                for(MasterAgreementExhibit__c mae:maeList) {
                    if(mae.MasterAgreementExhibit__r.ExhibitType__c!=null && mae.MasterAgreementExhibit__r.ExhibitType__c!='') {
                        if(!contractToMAEExhibitType.keySet().contains(contractMap.get(mae.OrderFormOrConsulting__c))) {
                            contractToMAEExhibitType.put(contractMap.get(mae.OrderFormOrConsulting__c), new Set<String>{mae.MasterAgreementExhibit__r.ExhibitType__c});
                        }
                        else {
                            contractToMAEExhibitType.get(contractMap.get(mae.OrderFormOrConsulting__c)).add(mae.MasterAgreementExhibit__r.ExhibitType__c);
                        }
                    }
                }
            }
            if(contractToCLIExhibitType!=null && !contractToCLIExhibitType.isEmpty()) {
                for(Contract c:contractToCLIExhibitType.keySet()) {
                    if(contractToMAEExhibitType==null || contractToMAEExhibitType.isEmpty() || !contractToMAEExhibitType.keyset().contains(c) ||
                       (contractToMAEExhibitType!=null && !contractToMAEExhibitType.isEmpty() && contractToMAEExhibitType.keyset().contains(c) && (contractToMAEExhibitType.get(c)==null || contractToMAEExhibitType.get(c).isEmpty())) ||
                       (contractToMAEExhibitType!=null && !contractToMAEExhibitType.isEmpty() && contractToMAEExhibitType.keyset().contains(c) && contractToMAEExhibitType.get(c)!=null && !contractToMAEExhibitType.get(c).isEmpty() && 
                        contractToCLIExhibitType!=null && !contractToCLIExhibitType.isEmpty() && contractToCLIExhibitType.keyset().contains(c) && contractToMAEExhibitType.get(c)!=null && !contractToMAEExhibitType.get(c).isEmpty() &&
                        !contractToMAEExhibitType.get(c).containsAll(contractToCLIExhibitType.get(c)))) {    
                            c.addError(Label.AddMasterAgreementExhibitErrorMsg);
                        }
                    
                }
            }
        }
    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 22 July 2020
    // @param: TriggerParameters
    // @description: SFDC-2663, Remove Master Agreement Exhibit if Fastrack is true.
    // @return: None
    //------------------------------  
    public static void removeMasterAgreementExhibitOnFastrack(TriggerParameters tp) {  
        if(tp.tEvent == TriggerParameters.TriggerEvent.AfterUpdate) {
            List<Contract> listContracts = (List<Contract>) tp.newList;
            Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
            Set<ID> contractIDSet = new Set<ID>();
            List<Contract> cList = new List<Contract>();
            List<MasterAgreementExhibit__c> maeList = new List<MasterAgreementExhibit__c>();
            List<String> masterAgrTypesForMAE = new List<String>();
            masterAgrTypesForMAE=Label.MasterAgrTypeForMAE.split(',');
            for(Contract contractObj:listContracts) {
                if((contractObj.Fastrack__c!=mapOldContract.get(contractObj.id).Fastrack__c && contractObj.Fastrack__c==true) || 
                   contractObj.GeneralAgreementType__c!=mapOldContract.get(contractObj.id).GeneralAgreementType__c && masterAgrTypesForMAE.contains(mapOldContract.get(contractObj.id).GeneralAgreementType__c) && !masterAgrTypesForMAE.contains(contractObj.GeneralAgreementType__c)){
                       contractIDSet.add(contractObj.id);
                   }
            }
            if(!contractIDSet.isEmpty()) {
            	cList=[Select id, (Select id, OrderFormOrConsulting__c,MasterAgreementExhibit__r.ExhibitType__c from MasterAgreementExhibits__r) from Contract where id in:contractIDSet];
            }
            for(Contract c:cList) {
                maeList.addAll(c.MasterAgreementExhibits__r);
            }
            if(maeList!=null && !maeList.isEmpty()) {
                delete maeList;
            }
        }
        
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 7th Sep 2020
    // @param: TriggerParameters
    // @description: SFDC-3278: Validation rule created in SFDC-3292 causing updates on contract to fail. Adding the validation rule to code to bypass from other methods
    // @return: None
    //------------------------------   
    public static void validateContractDateChanges(TriggerParameters tp) {
        if(GlobalConstants.byPassContractValidationDates) {
            return;//rule bypassed
        }
        //query profile names
        String profileName = UtilityClass.LoggedInUserProfileName;
        Set<String> setAllowedProfiles = new Set<String>{'IHSMarkit System Admin','System Administrator','IHSMarkit Contract Management','IHSMarkit Sales: User Support','IHSMarkit Order Management','IHSMarkit System Admin: API'};
        System.debug('@PD==profileName=='+profileName);
        if(setAllowedProfiles.contains(profileName)) {
            return;//no need to validate
        }
        //check if contract is not trial and contract dates are changed
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            Id trialRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId();
            for(Contract cont: (List<Contract>)tp.newList) {
                Contract oldContract = (Contract)tp.oldMap.get(cont.Id);
                if(cont.RecordTypeId!=trialRecordTypeId && (oldContract.startDate!=cont.startDate || oldContract.endDate!=cont.endDate)) {
                    cont.addError('You are not authorized to edit Contract Start/End Date. Please contact Contract Management Team.');
                }
            }
        }
    }
    //-----------------------------
    // @author: Madhusudhan Karna
    // @date: 02 Dec 2020
    // @description: SFDC-2693 AutoRenewStopped Should be synced to opportunity auto-renewal stopped field from contract auto-renewal stopped field
    // @return: None
    // @Last Modified by: Kanika Miglani
    // @Last Modified date: 22nd Feb,2022
    // @description: SFDC-3646 AutoRenewStopped Should be synced to Open Inner Year Opportunity and latest Renewal Opportunity.
    //-----------------------------
     public static void updateOpptyAutoRenewStopped(TriggerParameters tp) {
        Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        Set<Id> contractIdSet = new Set<Id>();
        Map<Id,Contract> opptyContractMap = new Map<Id,Contract>();
        for(Contract newContractObj : (List<Contract>)tp.newList) {   
            if(newContractObj.Opportunity__c != null && (newContractObj.AutoRenewStopped__c != ((Contract)tp.oldMap.get(newContractObj.Id)).AutoRenewStopped__c)
                && (newContractObj.RecordTypeId == orderFormContractRecTypeId || newContractObj.RecordTypeId == consultingContractRecTypeId)) { 
                contractIdSet.add(newContractObj.id);
            }
        } 
        List<Contract> updateContractList = [Select Id,Opportunity__c, (Select Id,IsClosed,createdDate,RecordType.Name From Opportunities2__r order by createddate DESC), AutoRenewStopped__c From Contract Where Id IN : contractIdSet];
        DateTime d;
        ID renewalId;
         for(contract con : updateContractList) {
            if((con.Opportunities2__r).size()>0) {
                for(Opportunity opp : con.Opportunities2__r){
                    system.debug('debugging recordType'+opp.RecordTypeId);
                    // for inner year opportunity
                    if(opp.RecordType.Name == 'Inner Year' && opp.IsClosed ==false){
                        opptyContractMap.put(opp.id,con);
                    }
                    //for renewal opportunity
                    if(opp.RecordType.Name == 'Renewal'){
                        if(d == null || opp.CreatedDate > d){
                            d = opp.CreatedDate;
                            if(renewalId != null && opptyContractMap.containskey(renewalId)){
                                opptyContractMap.remove(renewalId);
                            }
                            opptyContractMap.put(opp.Id,con);
                            renewalId = opp.Id;
                        }
                     }    
            	}
            }else {
                opptyContractMap.put(con.Opportunity__c,con);
            }
            system.debug('debugging opptyContractMap'+opptyContractMap);
        }
        Opportunity oppty;
        if(opptyContractMap != null && opptyContractMap.size() > 0) {
            for(Id oppId : opptyContractMap.keySet()) {
                if(oppId != null) {
                    oppty=new Opportunity();
                    oppty.id=oppId;
                    oppty.AutoRenewStopped__c=opptyContractMap.get(oppId).AutoRenewStopped__c;
                    oppUpdateList.add(oppty);
                }
            }  
        }
        try {                   
            if(oppUpdateList != null && oppUpdateList.size() > 0) {
                update oppUpdateList;                
            }            
        }
        catch(Exception ex) {            
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            System.debug('Exception in updateOpptyAutoRenewStopped method. Description:'+description);
            throw new TriggerException('Something gone wrong! Please reach out to salesforce helpdesk.'+description);
        }        
    }
    
     //-----------------------------
    // @author: Vaishali Jain
    // @date: 21 May 2021
    // @description: SFDC-3473 Count of all contracts on Account.
    // @return: None
    // @Modified By : Digvijay Singh
    // @Modification Date: 11 June 2021
    // @Modification Description: SFDC-4166 - Moved DML to platform Event.
    //-----------------------------
     public static void updateAccountContractsCount(TriggerParameters tp) {
        
        List<SetContractCountonAccount__e> lstSetContractCountonAccountEvent = new List<SetContractCountonAccount__e>();
        Integer count = 0;
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
            for(Contract newContractObj : (List<Contract>)tp.newList) { 
                if(newContractObj.AccountId != null) {
                    lstSetContractCountonAccountEvent.add(new SetContractCountonAccount__e(AccountId__c = newContractObj.AccountId));
                }
            }
        }
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            for(Contract newContractObj : (List<Contract>)tp.newList) {
                if(newContractObj.AccountId != null) { 
                    if(newContractObj.AccountId != ((Contract)tp.oldMap.get(newContractObj.Id)).AccountId) {
                        lstSetContractCountonAccountEvent.add(new SetContractCountonAccount__e(AccountId__c = newContractObj.AccountId));
                        lstSetContractCountonAccountEvent.add(new SetContractCountonAccount__e(AccountId__c = ((Contract)tp.oldMap.get(newContractObj.Id)).AccountId));
                    }
                    else if(newContractObj.Active__c != ((Contract)tp.oldMap.get(newContractObj.Id)).Active__c) {
                        lstSetContractCountonAccountEvent.add(new SetContractCountonAccount__e(AccountId__c = newContractObj.AccountId));
                    }
                }
            }
        }
        
        if(!lstSetContractCountonAccountEvent.IsEmpty()) {
            EventBus.publish(lstSetContractCountonAccountEvent);
        }
     }
    
     /**
      * @author Sharique
      * @date 30 June 2021
      * @description SFDC-4017 
      * @param TriggerParameters
      */
      public static void updateRenewalOwner(TriggerParameters tp){

        Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id consultingContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
        Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
          
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            for(Contract newContractObj : (List<Contract>)tp.newList) { 
                if (newContractObj.RecordTypeId == orderFormContractRecTypeId || newContractObj.RecordTypeId == consultingContractRecTypeId) {
                    if(newContractObj.RenewalOwner__c == null) {
                       newContractObj.RenewalOwner__c = newContractObj.OwnerId;
                    } else {
                    if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                       Contract oldContract = mapOldContract.get(newContractObj.id);
                       if (newContractObj.OwnerId != oldContract.OwnerId && newContractObj.RenewalOwner__c == oldContract.OwnerId) {
                           newContractObj.RenewalOwner__c = newContractObj.OwnerId;
                       }
                    }
                   }
                }
            }        
        }
     }
    /**
     * @author Sharique
     * @date 20 July 2021
     * @description SFDC-4076 Price Increase Reviewed fields 
     * @param TriggerParameters
     */
     public static void autoPolupatePriceIncreaseReviewDate(TriggerParameters tp) {
        Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
           for(Contract contrt : (List<Contract>)tp.newList) {
              Contract oldContract = mapOldContract.get(contrt.id);
              if (contrt.RecordTypeId == orderFormContractRecTypeId) {
                  if (contrt.PriceIncreaseReviewedBy__c == null) {
                      contrt.PriceIncreaseReviewedDate__c = null;
                      continue;
                  } 
                  if (contrt.PriceIncreaseReviewedBy__c != null && contrt.PriceIncreaseReviewedBy__c != oldContract.PriceIncreaseReviewedBy__c) {
                      if (contrt.PriceIncreaseReviewedDate__c == null || contrt.PriceIncreaseReviewedDate__c == oldContract.PriceIncreaseReviewedDate__c) {
                          contrt.PriceIncreaseReviewedDate__c = System.today();
                      }    
                  }
                  if (contrt.PriceIncreaseReviewedDate__c == null && oldContract.PriceIncreaseReviewedDate__c!=null && contrt.PriceIncreaseReviewedBy__c == oldContract.PriceIncreaseReviewedBy__c) {
                      contrt.PriceIncreaseReviewedDate__c = oldContract.PriceIncreaseReviewedDate__c; 
                  }
                  if (contrt.PriceIncreaseReviewedDate__c > System.today()) {
                      contrt.PriceIncreaseReviewedDate__c.addError('This date can not be in future');
                  }
              }    
           }
        }    
     }
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 17th Nov 2021
    // @param: TriggerParameters
    // @description: SFDC-4987: Update ReadyForProcessingContractExist__c field on Opp when Contract stage move backword
    // @return: None
    //------------------------------   
    public static void updateFieldOnOppOnContractStageChange(TriggerParameters tp) {
        Id orderFormContractRecTypeId = orderFormRecordTypeId;
        Id consultingContractRecTypeId = consultingRecordTypeId;
        Set<Id> setAllOpportunityIdtoUpdate = new Set<Id>();
        List<Opportunity> oppUpdateList = new List<Opportunity>();
        for(Contract newContract : (List<Contract>)tp.newList) {
            Contract oldContract= (Contract)tp.oldMap.get(newContract.Id);
            if((newContract.RecordTypeId == orderFormContractRecTypeId || newContract.RecordTypeId == consultingContractRecTypeId) && newContract.Opportunity__c != null) {
                if(newContract.Status!=oldContract.Status && oldContract.Status=='ReadyForProcessing' && newContract.status!='completed') {          
                    setAllOpportunityIdtoUpdate.add(newContract.Opportunity__c);
                }
            }
        }
        if(setAllOpportunityIdtoUpdate!= Null && setAllOpportunityIdtoUpdate.size() > 0) {
            for(Id oppyId:setAllOpportunityIdtoUpdate){
               Opportunity opp=new Opportunity(Id=oppyId,ReadyForProcessingContractExist__c=false);
               oppUpdateList.add(opp);
            }
        }
        
        try {
            if(oppUpdateList.size() > 0) {
                update oppUpdateList;                
            }            
        }
        catch(Exception ex) {
            ApexLogger.logError(new LogMessage('ContractMethods','updateFieldOnOppOnContractStageChange',ex,tp.newList.get(0),null));
        }        
    }
    
    /** 
    * @author: Sharique Iqbal
    * @date: 8th Dec 2021
    * @description: SFDC-4917- Populate Rejected by & Rejected Date fields while rejecting Contract Status
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got edited.
    */
    public static void populateStatusRejectionInfo(TriggerParameters tp) {
      
        Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
        for(Contract ctrt : (List<Contract>)tp.newList) {
            if(ctrt.ContractStatus__c == 'Rejected' && ctrt.ContractStatus__c != mapOldContract.get(ctrt.id).ContractStatus__c ){
                ctrt.RejectedBy__c = UserInfo.getUserId();
                ctrt.RejectionDate__c = System.now();
            }
        }               
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 27th Jan 2022
    // @param: TriggerParameters
    // @description: SFDC-4891- Add a field to the contract to show when the Contract Status was last updated "Last Contract Status Change Date"
    // @return: None
    //------------------------------   
    public static void lastStatusChangeDateUpdate(TriggerParameters tp) {
      
        Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
        for(Contract ctrt : (List<Contract>)tp.newList) {
            if(ctrt.ContractStatus__c != mapOldContract.get(ctrt.id).ContractStatus__c ) {
                ctrt.LastContractStatusChangeDate__c = System.Today();
            }
        }               
    }

    /**
    * @author: Kanika Miglani
    * @date: 5th April, 2022
    * @description: SFDC-5533: Automating fields on Order Form Contracts
    * @param TriggerParameters
    */
    public static void automateRenewalFields(TriggerParameters tp){
      Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
      Id consultingContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
      
      Map<Id,Contract> mapOldContract = (Map<Id,Contract>)tp.oldMap;
      for(Contract ctrt : (List<Contract>)tp.newList) {
          if((ctrt.RecordTypeId == orderFormContractRecTypeId || ctrt.RecordTypeId == consultingContractRecTypeId) && ctrt.RenewalTerm__c != mapOldContract.get(ctrt.id).RenewalTerm__c){
              if(ctrt.RenewalTerm__c == 'One-time Expiring'){
                  ctrt.RenewalDate__c = null;
                  ctrt.AutoRenewal__c = false;
              }
              if(ctrt.RenewalTerm__c == 'Evergreen'){
                  ctrt.AutoRenewal__c = true;
                  if(ctrt.RenewalDate__c == null){
                      ctrt.RenewalDate__c = ctrt.EndDate + 1;
                  }
              }
          }
      } 
        
   }
   //-----------------------------
    // @author: Sharique
    // @date: 29th Mar 2022
    // @param: TriggerParameters
    // @description: SFDC-5451- Create a Contract Attachment placeholder record for OF/consulting contracts
    // @return: None
    //------------------------------   
    public static void createContractAttachmentPlaceHolder(TriggerParameters tp) {
        Id orderFormContractRecTypeId = orderFormRecordTypeId;
        Id consultingContractRecTypeId = consultingRecordTypeId;
        List<ContractAttachment__c> insertContractAtt = new List<ContractAttachment__c>();
        for(Contract ctrt : (List<Contract>)tp.newList) {
            if((ctrt.RecordTypeId == orderFormContractRecTypeId || ctrt.RecordTypeId == consultingContractRecTypeId)
                && ctrt.PORequired__c) {
                ContractAttachment__c ctrtAtt = new ContractAttachment__c();
                ctrtAtt.Name = 'PO / '+ctrt.ContractAccount__c+' '+System.today().format();
                ctrtAtt.Contract__c = ctrt.Id;
                ctrtAtt.AttachmentType__c = 'Purchase Order';
                ctrtAtt.CurrentPO__c = 'Yes';
                ctrtAtt.POAttached__c = 'No';
                insertContractAtt.add(ctrtAtt);
            }
        }
        
        if(!insertContractAtt.isEmpty()) {
            insert insertContractAtt;
        }
    }

    /**
    * @author: Kanika Miglani
    * @date: 19th April, 2022
    * @description: SFDC-5660 - Automation on Contract when RenewalTerm(SAP) is updated as Evergreen on Opportunity.
    * @param TriggerParameters
    */
    public static void renewalTermSAPUpdate(TriggerParameters tp){
      Id orderFormContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
      Id consultingContractRecTypeId = Schema.SobjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
      Id RenewalOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
  	  Set<Contract> setContractIdToBeUpdated = new Set<Contract>();
      List<Contract> listContractFieldToUpdate = new List<Contract>();
       
      List<Contract> listContractIdToBeUpdated = [Select id,EndDate,RenewalDate__c,RenewalTerm__c,AutoRenewal__c,RecordTypeId from Contract where Opportunity__c IN (Select id from Opportunity where SAP_RenewalTerm__c = 'Evergreen' AND RecordTypeId =: RenewalOppRecordTypeId ) ];
      if(listContractIdToBeUpdated.size()>0)
      {
          setContractIdToBeUpdated.addAll(listContractIdToBeUpdated);
      }
      for(Contract con : setContractIdToBeUpdated){
          if((con.RecordTypeId == orderFormContractRecTypeId || con.RecordTypeId == consultingContractRecTypeId) && con.RenewalTerm__c == 'Evergreen'){
             con.AutoRenewal__c = true;
             con.RenewalDate__c = con.EndDate + 1; 
             listContractFieldToUpdate.add(con);
          }
      }
      if(listContractFieldToUpdate.size()>0){
            update listContractFieldToUpdate;
      }
   }
}