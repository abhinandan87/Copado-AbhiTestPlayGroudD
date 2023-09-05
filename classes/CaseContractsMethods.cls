/**
* @author: Vishnu vardhan Chowdary Andra
* @date: 23 August 2017
* @description: SFDC1-593. After insert dispatcher event handler class that calls the functions in CaseContractsMethods.
* @companyname: VERTIBA
*/
public class CaseContractsMethods {
    /** 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 23 August 2017
    * @description: SFDC1-593.  When a CaseContracts object is created/updated/deleted then the parent case object will be
    *		updated (simillar to rollup summary). Contract product list and revenue are the fields in case object.
    *		Products and Annual Revenue are the fields in Contract object. 
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @return: void
    * 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 3 November 2017
    * @description: SFDC1-593. Updating try catch block and adding revenue part.
	* @author: Paras Dhingra
	* @date: 10th June 2020
	* @description: SFDC-99 Replacing Product__c with AssociatedProduct__c as it is a duplicate
    */
    public static void updateRollupSummariesInCase(TriggerParameters tp) {
        try {
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ||
               tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate ||
               tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                   //1. Collect all the caseId's(parent id) from the case Contracts and get required fields, also create a 
                   //		 map of key as caseId and list of case Contracts as values. 
                   Set<id> caseIds = new Set<id>();
                   Map<Id,CaseContracts__c> newMapCaseContracts = (Map<Id,CaseContracts__c>) tp.newMap;
                   Map<Id,CaseContracts__c> oldMapCaseContracts = (Map<Id,CaseContracts__c>) tp.oldMap;
                   Map<Id,CaseContracts__c> mapCaseContracts = newMapCaseContracts;
                   if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                       mapCaseContracts = oldMapCaseContracts;
                   }
                   for(CaseContracts__c caseContracts : mapCaseContracts.values()) {
                       CaseContracts__c oldCaseContract = new CaseContracts__c();
                       if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                           oldCaseContract = oldMapCaseContracts.get(caseContracts.id);
                       } 
                       if(caseContracts.Contract__c != oldCaseContract.Contract__c) {
                           caseIds.add(caseContracts.Case__c);
                       }
                   }
                   System.debug('Get Cases for updation:'+caseIds);
                   List<Case> caseList = [select id, ContractProductList__c, Revenue__c,
                                          (select id, Contract__c, Revenue__c from CaseContracts__r) 
                                          from case where id in :caseIds ];
                   //2. Collect all the contracts from the case object and get the product names. Create a map.
                   Set<id> ContractsIds = new Set<id>();
                   for(case cas : caseList) {
                       for(CaseContracts__c caseContracts : cas.CaseContracts__r) {
                           ContractsIds.add(caseContracts.Contract__c);
                       }
                   }
                   List<Contract> ContractsList = [SELECT Id, (Select AssociatedProduct__r.Name From Contract_Line_Items__r) 
                                                   FROM Contract WHERE Id in :ContractsIds];
                   System.debug('Got Contracts and product map'+ContractsList);
                   Map<id,List<String>> ContractsProductMap = new Map<Id,List<String>>();
                   System.debug('Before actual logic begins');
                   for(Contract contract:ContractsList) {
                       List<String> productNames = new List<String>();
                       for(ContractLineItem__c cli:contract.Contract_Line_Items__r) {
                           productNames.add(cli.AssociatedProduct__r.Name);
                       }
                       ContractsProductMap.put(contract.id, productNames);
                   }
                   //3. Loop through each case object and each case Contracts object, and calculate revenue, product text.
                   for(case cas : caseList) {
                       Decimal revenue = 0;
                       //If a product is available in more than one contract line item then set will remove the duplicate name.
                       Set<String> productNameSet = new Set<String>();
                       for(CaseContracts__c caseContracts : cas.CaseContracts__r) {
                           revenue+=caseContracts.Revenue__c;
                           if(ContractsProductMap.containsKey(caseContracts.Contract__c)) {
                               productNameSet.addAll(ContractsProductMap.get(caseContracts.Contract__c));
                           }
                       }
                       cas.Revenue__c = revenue;
                       cas.ContractProductList__c = String.join(new List<String>(productNameSet), ',');
                   }
                   System.debug('Before update of cases:'+caseList);
                   //4. Update case 
                   update caseList;
               }
        } catch (Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseContractsMethods','updateRollupSummariesInCase');
        }
    }

    /** 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 25 September 2017
    * @description: SFDC1-593. When a CaseContracts object is created/updated verify that same case and 
	* 		Contract record is not there in database. If exists then dont allow the insert.
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @return: void
    * 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 3 November 2017
    * @description: SFDC1-593. Updating try catch block
    */
    public static void validateIfCaseContractAlreadyExist(TriggerParameters tp) {
        try {
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
               tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                   //1. Collect all the caseId's(parent id) from the case Contract and get records from database
                   Set<id> caseIds = new Set<id>();
                   List<CaseContracts__c> listCaseContracts = (List<CaseContracts__c>) tp.newList;
                   
                   for(CaseContracts__c caseContract : listCaseContracts) {
                       caseIds.add(caseContract.Case__c);
                   }
                   System.debug('Get Cases for verification:'+caseIds);
                   Map<id,List<CaseContracts__c>> existingCaseContractMap = new Map<id, List<CaseContracts__c>>();
                   for(CaseContracts__c caseContract : [select Case__c, Contract__C, id from 
                                                        CaseContracts__c where case__c in :caseIds]) {
                       if(!existingCaseContractMap.containsKey(caseContract.Case__c)) {
                           existingCaseContractMap.put(caseContract.Case__c, new List<CaseContracts__c>());
                       }
                       existingCaseContractMap.get(caseContract.case__c).add(caseContract);
                   }
                   System.debug('Case and Contract map:'+existingCaseContractMap);
                   //2. verify from the records if the record is already present.
                   for(CaseContracts__c caseContract : listCaseContracts) {
                       if(existingCaseContractMap.containsKey(caseContract.Case__c)) {
                           //One or more than one Contracts are there for this case.
                           List<CaseContracts__c> caseConts = existingCaseContractMap.get(caseContract.Case__c);
                           for(CaseContracts__c caseCont : caseConts) {
                               //Case Contracts should be same but id should not be same for raising error
                               if(caseCont.Contract__C == caseContract.Contract__C && 
                                  caseContract.id != caseCont.id) {
                                      caseContract.addError(System.Label.CaseContractDuplicateCheck);
                                  }
                           }
                       }
                   }
               }
        } catch (Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseContractsMethods','validateIfCaseContractAlreadyExist');
        }
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 17th November 2021
    // @description: SFDC-4823 Updating Account on case for Response Management record type when a Contract is linked to it
    // @return: None
    //-----------------------------
    public static void updateAccount(TriggerParameters tp) { 
        
        //Getting response Management Case recordtypeId
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        // creating a Set of CaseContract Junction and adding new records to it
        Set<Id> caseCons = new Set<Id>();
        for(CaseContracts__c caseCon: (List<CaseContracts__c>)tp.newList) {
            caseCons.add(caseCon.Id);
        }
        
        //Query the information from CaseContractrecords using the records identified earlier
        List<CaseContracts__c> listOfNewCaseContracts = [SELECT Id, Case__c,Case__r.AccountId,Case__r.RequestRegion__c,Case__r.RecordTypeID,
                                                         Contract__c,Contract__r.AccountId, Contract__r.Account.AccountRegion__c
                                                         FROM CaseContracts__c WHERE Id IN: caseCons];
        
        List<Case> listOfCases = new List<Case>();
        for(CaseContracts__c caseCon: listOfNewCaseContracts) {
            if(caseCon.Case__r.RecordTypeId == resManagementRecordTypeId) {
                listOfCases.add(new Case(Id = caseCon.Case__c, AccountId = caseCon.Contract__r.AccountId, RequestRegion__c = caseCon.Contract__r.Account.AccountRegion__c));
            }
        }
        
        if(listOfCases.size()>0) {
            update listOfCases;
        }
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 28th November 2021
    // @description: SFDC-5051 Updating Account and Request region on case for Response Management record type when a caseContract is deleted from it
    // @return: None
    //-----------------------------
    public static void updateAccountOnDeletion(TriggerParameters tp) { 
        
        //Getting response Management Case recordtypeId
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        // creating a Set of CaseIds and adding cases to it for deleted casecontract record
        Set<Id> caseIds = new Set<Id>();
        for(CaseContracts__c caseCons: (List<CaseContracts__c	>)tp.oldlist) {
            caseIds.add(caseCons.Case__c);
        }
        
        //Query the information from Case Records using the records identified earlier        
        List<Case> listOfNewCases = [Select Id, RecordTypeId,
                                     (SELECT Id, CreatedDate, Opportunity__r.AccountId, Opportunity__r.Account.AccountRegion__c FROM CaseOpportunities__r ORDER BY CreatedDate DESC LIMIT 1),
                                     (SELECT Id, CreatedDate, Contract__r.AccountId, Contract__r.Account.AccountRegion__c FROM CaseContracts__r ORDER BY CreatedDate DESC LIMIT 1) 
                                     FROM Case WHERE Id IN: caseIds AND RecordTypeId =: resManagementRecordTypeId];
        System.debug('Case in question:' + listOfNewCases);
        
        List<Case> listOfCases = new List<Case>();
        
        for(Case cse: listOfNewCases) {
            // Scenario with case having both caseoppies and casecontracts linked to it after deletion
            if(cse.CaseOpportunities__r.size()>0 && cse.CaseContracts__r.size()>0) {
                if(cse.CaseOpportunities__r[0].CreatedDate > cse.CaseContracts__r[0].CreatedDate) {
                    listOfCases.add(new Case(Id = cse.Id, AccountId = cse.CaseOpportunities__r[0].Opportunity__r.AccountId, RequestRegion__c = cse.CaseOpportunities__r[0].Opportunity__r.Account.AccountRegion__c));
                } else if (cse.CaseOpportunities__r[0].CreatedDate < cse.CaseContracts__r[0].CreatedDate) {
                    listOfCases.add(new Case(Id = cse.Id, AccountId = cse.CaseContracts__r[0].Contract__r.AccountId, RequestRegion__c = cse.CaseContracts__r[0].Contract__r.Account.AccountRegion__c));
                }
            }
            // Scenario with case having oppies linked but no contracts
            else if(cse.CaseOpportunities__r.size()>0 && cse.CaseContracts__r.size() == 0) {
                listOfCases.add(new Case(Id = cse.Id, AccountId = cse.CaseOpportunities__r[0].Opportunity__r.AccountId, RequestRegion__c = cse.CaseOpportunities__r[0].Opportunity__r.Account.AccountRegion__c));
            }
            //Scenario with case having Contracts linked but no Oppies
            else if(cse.CaseOpportunities__r.size() == 0 && cse.CaseContracts__r.size()>0) {
                listOfCases.add(new Case(Id = cse.Id, AccountId = cse.CaseContracts__r[0].Contract__r.AccountId, RequestRegion__c = cse.CaseContracts__r[0].Contract__r.Account.AccountRegion__c));
            }
        }
        
        if(listOfCases.size()>0) {
            update listOfCases;
        }     
    }
    
}