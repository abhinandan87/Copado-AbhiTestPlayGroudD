/**
* @author: Vishnu vardhan Chowdary Andra
* @date: 23 August 2017
* @description: SFDC1-593. After insert dispatcher event handler class that calls the functions in CaseOpportunitiesMethods.
* @companyname: VERTIBA
*/
public class CaseOpportunitiesMethods {
    /** 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 23 August 2017
    * @description: SFDC1-593. When a CaseOpportunities object is created/updated/deleted then the parent case object will be
    *		updated (simillar to rollup summary). Opportunity product list and Expected revenue are the fields in case object.
    *		Products and Annualised 1 year amount are the fields in CaseOpportunities object. 
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @return: void
    * 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 3 November 2017
    * @description: SFDC1-593. Updating try catch block
    */
    public static void updateRollupSummariesInCase(TriggerParameters tp) {
        try {
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ||
               tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate ||
               tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                   //1. Collect all the caseId's(parent id) from the case opportunities and get required fields, also create a 
                   //		 map of key as caseId and list of case opportunities as values. 
                   Set<id> caseIds = new Set<id>();
                   Map<Id,CaseOpportunities__c> newMapCaseOpportunities = (Map<Id,CaseOpportunities__c>) tp.newMap;
                   Map<Id,CaseOpportunities__c> oldMapCaseOpportunities = (Map<Id,CaseOpportunities__c>) tp.oldMap;
                   Map<Id,CaseOpportunities__c> mapCaseOpportunities = newMapCaseOpportunities;
                   
                   if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                       mapCaseOpportunities = oldMapCaseOpportunities;
                   }
                   for(CaseOpportunities__c caseOpportunity : mapCaseOpportunities.values()) {
                       CaseOpportunities__c oldCaseOpportunity = new CaseOpportunities__c();
                       if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                           oldCaseOpportunity = oldMapCaseOpportunities.get(caseOpportunity.id);
                       } 
                       if(caseOpportunity.Opportunity__c != oldCaseOpportunity.Opportunity__c) {
                           caseIds.add(caseOpportunity.Case__c);
                       }
                       caseIds.add(caseOpportunity.Case__c);
                   }
                   System.debug('Get Cases for updation:'+caseIds);
                   List<Case> caseList = [select id, OpportunityProductList__c, ExpectedRevenue__c, 
                                          (select id, ExpectedRevenue__c, Opportunity__c from CaseOpportunities__r)
                                          from case where id in :caseIds ];
                   //2. Collect all the opportunities from the case object and get the product names. Create a map.
                   Set<id> opportunityIds = new Set<id>();
                   for(case cas : caseList) {
                       for(CaseOpportunities__c caseOpportunity : cas.CaseOpportunities__r) {
                           opportunityIds.add(caseOpportunity.Opportunity__c);
                       }
                   }
                   List<Opportunity> OpportunityList = [SELECT Id, (SELECT PricebookEntry.Product2.Name FROM OpportunityLineItems) 
                                                        FROM Opportunity WHERE Id in :opportunityIds];
                   System.debug('Got Opportunity and product map'+OpportunityList);
                   Map<id,List<String>> opportunityProductMap = new Map<Id,List<String>>();
                   System.debug('Before actual logic begins');
                   for(Opportunity opp:opportunityList) {
                       List<String> productNames = new List<String>();
                       for(OpportunityLineItem oli:opp.OpportunityLineItems) {
                           productNames.add(oli.PricebookEntry.Product2.Name);
                       }
                       opportunityProductMap.put(opp.id, productNames);
                   }
                   //3. Loop through each case object and each case opportunity object, and calculate revenue, product text.
                   for(case cas : caseList) {
                       Decimal expectedrevenue = 0;
                       //If a product is available in more than one opp line item then set will remove the duplicate name.
                       Set<String> productNameSet = new Set<String>();
                       for(CaseOpportunities__c caseOpportunity : cas.CaseOpportunities__r) {
                           expectedrevenue+=caseOpportunity.ExpectedRevenue__c;
                           if(opportunityProductMap.containsKey(caseOpportunity.Opportunity__c)) {
                               productNameSet.addAll(opportunityProductMap.get(caseOpportunity.Opportunity__c));
                           }
                       }
                       cas.ExpectedRevenue__c = expectedrevenue;
                       cas.OpportunityProductList__c = String.join(new List<String>(productNameSet), ',');
                   }
                   System.debug('Before update of cases:'+caseList);
                   //4. Update case 
                   update caseList;
               }
        } catch (Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseOpportunitiesMethods','updateRollupSummariesInCase');
        }
    }
    
    /** 
    * @author: Vishnu vardhan Chowdary Andra
    * @date: 25 September 2017
    * @description: SFDC1-593. When a CaseOpportunities object is created/updated verify that same case and 
	* 		opportunity record is not there in database. If exists then dont allow the insert.
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
    * @companyname: VERTIBA
    * @return: void
    * 
	* @author: Vishnu vardhan Chowdary Andra
    * @date: 3 November 2017
    * @description: SFDC1-593. Updating try catch block
    */
    public static void validateIfCaseOpportunityAlreadyExist(TriggerParameters tp) {
        try {
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert ||
               tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                   //1. Collect all the caseId's(parent id) from the case opportunities and get records from database
                   Set<id> caseIds = new Set<id>();
                   List<CaseOpportunities__c> listCaseOpportunities = (List<CaseOpportunities__c>) tp.newList;
                   
                   for(CaseOpportunities__c caseOpportunity : listCaseOpportunities) {
                       caseIds.add(caseOpportunity.Case__c);
                   }
                   System.debug('Get Cases for verification:'+caseIds);
                   Map<id,List<CaseOpportunities__c>> existingCaseOpportunityMap = new Map<id, List<CaseOpportunities__c>>();
                   for(CaseOpportunities__c caseOpportunity : [select Case__c, Opportunity__c, id from 
                                                               CaseOpportunities__c where case__c in :caseIds]) {
                       if(!existingCaseOpportunityMap.containsKey(caseOpportunity.Case__c)) {
                           existingCaseOpportunityMap.put(caseOpportunity.Case__c, new List<CaseOpportunities__c>());
                       }
                       existingCaseOpportunityMap.get(caseOpportunity.case__c).add(caseOpportunity);
                   }
                   System.debug('Case and Opp map:'+existingCaseOpportunityMap);
                   //2. verify from the records if the record is already present.
                   for(CaseOpportunities__c caseOpportunity : listCaseOpportunities) {
                       if(existingCaseOpportunityMap.containsKey(caseOpportunity.Case__c)) {
                           //One or more than one opportunities are there for this case.
                           List<CaseOpportunities__c> caseOpps = existingCaseOpportunityMap.get(caseOpportunity.Case__c);
                           for(CaseOpportunities__c caseOpp : caseOpps) {
                               //Case opportunity should be same but id should not be same for raising error
                               if(caseOpp.Opportunity__c == caseOpportunity.Opportunity__c && 
                                  caseOpportunity.id != caseOpp.id) {
                                      caseOpportunity.addError(System.Label.CaseOpportunityDuplicateCheck);
                                  }
                           }
                       }
                   }
               }
        } catch (Exception e) {
            UtilityClass.createApexLogRecord(e,'CaseOpportunitiesMethods','validateIfCaseOpportunityAlreadyExist');
        }
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 17th November 2021
    // @description: SFDC-4823 Updating Account and Request region on case for Response Management record type when an opportunity is linked to it
    // @return: None
    //-----------------------------
    public static void updateAccount(TriggerParameters tp) { 
        
        //Getting response Management Case recordtypeId
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        // creating a Set of CaseOpportunity Junction and adding new records to it
        Set<Id> caseOppies = new Set<Id>();
        for(CaseOpportunities__c caseOppy: (List<CaseOpportunities__c>)tp.newList) {
            caseOppies.add(caseOppy.Id);
        }
        
        //Query the information from CaseOpportunityrecords using the records identified earlier
        List<CaseOpportunities__c> listOfNewCaseOpportunities = [SELECT Id, Case__c,Case__r.AccountId,Case__r.RequestRegion__c,Case__r.RecordTypeID,
                                                                 Opportunity__c,Opportunity__r.AccountId, Opportunity__r.Account.AccountRegion__c
                                                                 FROM CaseOpportunities__c WHERE Id IN: caseOppies];
        
        List<Case> listOfCases = new List<Case>();
        for(CaseOpportunities__c caseOppy: listOfNewCaseOpportunities) {
            if(caseOppy.Case__r.RecordTypeId == resManagementRecordTypeId) {
                listOfCases.add(new Case(Id = caseOppy.Case__c, AccountId = caseOppy.Opportunity__r.AccountId, RequestRegion__c = caseOppy.Opportunity__r.Account.AccountRegion__c));
            }
        }
        
        if(listOfCases.size()>0) {
            update listOfCases;
        }
    }
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 28th November 2021
    // @description: SFDC-5051 Updating Account and Request region on case for Response Management record type when a caseopportunity is deleted from it
    // @return: None
    //-----------------------------
    public static void updateAccountOnDeletion(TriggerParameters tp) { 
        
        //Getting response Management Case recordtypeId
        Id resManagementRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Response Management').getRecordTypeId();
        // creating a Set of CaseIds and adding cases to it for deleted caseoppy record
        Set<Id> caseIds = new Set<Id>();
        for(CaseOpportunities__c caseOppy: (List<CaseOpportunities__c>)tp.oldlist) {
            caseIds.add(caseOppy.Case__c);
        }
        
        //Query the information from Case Records using the records identified earlier        
        List<Case> listOfNewCases = [Select Id, RecordTypeId,
                                     (SELECT Id, CreatedDate, Opportunity__r.AccountId, Opportunity__r.Account.AccountRegion__c FROM CaseOpportunities__r ORDER BY CreatedDate DESC LIMIT 1),
                                     (SELECT Id, CreatedDate, Contract__r.AccountId, Contract__r.Account.AccountRegion__c FROM CaseContracts__r ORDER BY CreatedDate DESC LIMIT 1) 
                                     FROM Case WHERE Id IN: caseIds AND RecordTypeId =: resManagementRecordTypeId];
        
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