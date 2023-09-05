//
//@Author Paras Dhingra
//@Date 15th Sep 2017
//@Description SFDC1-4275 Trigger helper method class for OpportunityLineItemSchedule object 
//@company IHS Markit
//@ModifiedBy: Paras Dhingra
//@ModifiedDate: 11/11/2020
//@Description: SFDC-3354 adding price change exception reporting logic
//@ModifiedBy: Ankush Agarwal
//@ModifiedDate: 25th Aug 2021
//@Description: SFDC-400 Pro Ration logic
//
public class OpportunityLineItemScheduleMethods {
    
    //
    //@author Paras Dhingra
    //@date 15th Sep 2017
    //@description SFDC1-4275 Method to rollup values from 
    //            Oppy product schedules to Oppy products
    //@param TriggerParameters
    //@return void
    //@companyname IHS Markit
    // @Modification : SFDC-2669: Control the working of code thorugh a flag.
	// @Modified by : Dev Aggarwal
	// @Last Modified Date: 14 February 2020
    public static void rollUpValuesToOppyProduct(TriggerParameters tp) {
        if(!GlobalConstants.runRollupOpportunityLineItemSchedule) {
        try {
            System.debug('Control Reached rollUpValuesToOppyProduct');
            Map<Id,OpportunityLineItemSchedule__c> mapOPSModified = new  Map<Id,OpportunityLineItemSchedule__c>();
        
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ||
                tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    mapOPSModified = (Map<Id,OpportunityLineItemSchedule__c>)tp.newMap;
            }
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                
                mapOPSModified = (Map<Id,OpportunityLineItemSchedule__c>)tp.oldMap;
            }
            if(mapOPSModified!=null && !mapOPSModified.isEmpty()) {
                //traverse the map and extract opportunity product id
                Set<Id> setOppyProductId = new Set<Id>();
                for(OpportunityLineItemSchedule__c ops: mapOPSModified.values()) {
                    if(!String.isBlank(ops.OpportunityProductId__c)) {
                        setOppyProductId.add(ops.OpportunityProductId__c);
                    }
                    
                }
                if(setOppyProductId!=null && !setOppyProductId.isEmpty()) {
                    //query Opportunity prodcut which was to be updated
                    Map<Id, OpportunityLineItem> mapOppyProductId = new Map<Id, OpportunityLineItem>([Select id, DiscountPercentage__c, Discount_Amount__c, DiscountType__c,OpportunityId,FirstYear__c,
                                                                    ListPrice__c,Quantity,UnitListPrice__c,UnitPrice, PricebookEntry.Product2.DiscountThreshold__c,LicenseType__c,
                                                                    DiscountOverThreshold__c,Status__c, ActiveInactiveNetUnitPrice__c,AnnualizedUnitPrice__c, AnnualizedDiscountAmount__c,
                                                                    //ProRatedUnitPrice__c, ProRatedDiscountAmount__c, ProRatedDiscountPercentage__c, ProRatedTotalPrice__c, 
                                                                    ProductType__c From OpportunityLineItem  where Id IN: setOppyProductId]);
                    //query all OpportunityLinetITemSchedule related to Opportunity Products
                    //Cannot use inner query as there is no direct relation exists between the two Oppy product and Oppy product schedules
                    List<OpportunityLineItemSchedule__c> lstOPS = [Select id, DiscountPercent__c, DiscountAmount__c, DiscountType__c, ExternalListPrice__c,
                                                                    InstallmentYears__c, OpportunityProductId__c, PriceBookListPrice__c, Quantity__c, SalesPrice__c,
                                                                    TotalPrice__c,Status__c, AnnualizedUnitPrice__c, AnnualizedDiscountAmount__c
                                                                    //ProRatedUnitPrice__c, ProRatedDiscountAmount__c, ProRatedDiscountPercentage__c, ProRatedTotalPrice__c 
                                                                    from OpportunityLineItemSchedule__c where OpportunityProductID__c IN:setOppyProductId
                                                                    order by InstallmentYears__c ASC];
                     System.debug('--lstOPS--' + lstOPS);
                     System.debug('--mapOppyProductId--' + mapOppyProductId);
                     if(lstOPS!=null && !lstOps.isEmpty() && mapOppyProductId!=null && !mapOppyProductId.isEmpty()) {
                         System.debug('--inside if--');
                         //create a map of Opportunity ID it's OppyProducts
                         Map<Id, List<OpportunityLineItemSchedule__c>> mapOppyProdAndScheds = new Map<Id, List<OpportunityLineItemSchedule__c>>();
                         List<OpportunityLineItem> lstOLIToUpdate = new List<OpportunityLineItem>();
                         for(OpportunityLineItemSchedule__c ops : lstOPS) {
                             if(mapOppyProdAndScheds.containskey(ops.OpportunityProductId__c)) {
                                 mapOppyProdAndScheds.get(ops.OpportunityProductId__c).add(ops);
                             }
                             else {
                                 List<OpportunityLineItemSchedule__c> tempLstOps = new List<OpportunityLineItemSchedule__c>();
                                 tempLstOps.add(ops);
                                 mapOppyProdAndScheds.put(ops.OpportunityProductId__c, tempLstOps);
                             }
                         }
                         System.debug('--mapOppyProdAndScheds--' + mapOppyProdAndScheds);
                         //process the map and update OpportunityProducts
                         
                         for( OpportunityLineItem oli : mapOppyProductId.values()) {
                             
                             List<OpportunityLineItemSchedule__c> lstCurrentOliScheds = new List<OpportunityLineItemSchedule__c>();
                             lstCurrentOliScheds = mapOppyProdAndScheds.get(oli.Id);
                             //reset all values
                             oli.DiscountPercentage__c = 0.0;
                             oli.Discount_Amount__c = 0.0;
                             oli.DiscountType__c = 'No Discount';
                             oli.FirstYear__c = 0.0; // First Year Total Price
                             if(lstCurrentOliScheds!=null && lstCurrentOliScheds.size()>0) {
                                 oli.FirstYear__c = lstCurrentOliScheds[0].TotalPrice__c;
                                 oli.Status__c = lstCurrentOliScheds[0].Status__c;
                                 oli.Quantity = lstCurrentOliScheds[0].Quantity__c;// Always fetch Quantity from Opportunity Line Item Schedule
                                 oli.DiscountType__c = lstCurrentOliScheds[0].DiscountType__c;
                                 oli.ListPrice__c = lstCurrentOliScheds[0].PriceBookListPrice__c; //Price book List Price first year
                                 //oli.LicenseType__c = lstCurrentOliScheds[0].LicenseType__c;// LicenseType__c copied from Opportunity Line item schedule
                                 
                             }
                             oli.UnitListPrice__c = 0.0; //Total external list price
                             oli.UnitPrice = 0.0;//Total Sales Price
                             //traverse the opportunity line item children
                             oli.AnnualizedUnitPrice__c = 0.0;
                             oli.AnnualizedDiscountAmount__c = 0.0;
                             for( OpportunityLineItemSchedule__c ops : lstCurrentOliScheds) {
                                 oli.Discount_Amount__c += ops.DiscountAmount__c==null?0:ops.DiscountAmount__c;
                                 oli.DiscountPercentage__c+=ops.DiscountPercent__c==null?0:ops.DiscountPercent__c;
                                 oli.UnitListPrice__c+=ops.ExternalListPrice__c==null?0:ops.ExternalListPrice__c;
                                 oli.UnitPrice +=ops.SalesPrice__c==null?0:ops.SalesPrice__c;
                                 oli.ActiveInactiveNetUnitPrice__c = oli.UnitPrice==null?0:oli.UnitPrice;
                                 oli.AnnualizedUnitPrice__c += ops.AnnualizedUnitPrice__c==null?0:ops.AnnualizedUnitPrice__c;
                                 oli.AnnualizedDiscountAmount__c += ops.AnnualizedDiscountAmount__c==null?0:ops.AnnualizedDiscountAmount__c;
                             }
                             if(oli.Status__c=='Lost') {
                                 oli.UnitPrice=0;
                             }
                             oli.DiscountPercentage__c = oli.DiscountPercentage__c/(lstCurrentOliScheds.size());
                             oli.DiscountOverThreshold__c = oli.DiscountPercentage__c>oli.PricebookEntry.Product2.DiscountThreshold__c?true:false;
                             lstOLIToUpdate.add(oli);
                         }
                         //update Opportunity Line Items
                         if(lstOLIToUpdate!=null && !lstOLIToUpdate.isEmpty()) {
                             update lstOLIToUpdate;
                         }
                     }
                    
                }
            }
            
        } catch(Exception ex) {
            System.debug('Exception caught' + ex);
            UtilityClass.createApexLogRecord(ex, 'OpportunityLineItemScheduleMethods', 'rollUpValuesToOppyProduct');
            String errorMessage = ex.getMessage();
            String validationEx = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
            if (ex.getMessage().contains(validationEx)) {
                Integer pos = errorMessage.indexOf(validationEx) + validationEx.length() + 2;
                errorMessage = errorMessage.mid(pos, errorMessage.length()).substringBefore(':');
            }
            else {
                errorMessage = ex.getMessage();
            }
           // throw new GenericCustomException('Error occurred'+errorMessage);
           tp.newList[0].addError('Error occurred - ' + errorMessage);

        }

       }  
    }
    //
    //@author Paras Dhingra
    //@date 11th Jul 2018
    //@description SFDC1-9058 Method to populate annualized values
    //@param TriggerParameters tp
    //@return void
    //@companyname IHS Markit
    //
    public static void populateAnnualizedValues(TriggerParameters tp) {
        try {
            //SFDC-400 Check if ProRation Applied
            System.debug('Populate Annual Value');                
            Set<String> OLI_Ids = new Set<String>();
            for(OpportunityLineItemSchedule__c olis : (List<OpportunityLineItemSchedule__c>)tp.newList) {
                OLI_Ids.add(olis.OpportunityProductID__c);
				System.debug('Product Id ' + olis.OpportunityProductID__c);                
            }
            
            Map<Id, OpportunityLineItem> OLI_Map = new Map<Id, OpportunityLineItem>([select Id, IsProRated__c from OpportunityLineItem where Id IN:OLI_Ids]);
            System.debug('OLI Map ' + OLI_Map);                
            //traverse oppy schedules and copy values to annualized fields
            for(OpportunityLineItemSchedule__c olis : (List<OpportunityLineItemSchedule__c>)tp.newList) {
                //SFDC-400 Skip Annualized value updation if prodeuct is ProRated 
                
                if(!OLI_Map.containsKey(olis.OpportunityProductID__c) || OLI_Map.get(olis.OpportunityProductID__c).IsProRated__c == null || OLI_Map.get(olis.OpportunityProductID__c).IsProRated__c != 'Yes'){
                    olis.AnnualizedUnitPrice__c = olis.ExternalListPrice__c;
                    olis.AnnualizedDiscountAmount__c = olis.DiscountAmount__c;
                }
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'OpportunityLineItemScheduleMethods', 'populateAnnualizedValues');
        }
    }

    /**
     * @author: Paras Dhingra
     * @date: 10th Aug 2020
     * @description: SFDC-3187 this method will be triggered for Lineitems which are related auto renewal price change only opportunities
     * @author: Paras Dhingra
     * @date: 20th Jan 2021
     * @description: SFDC-3686 adding by pass for contract validations in opportunity contract sync
     */
    public static void syncAutoRenewalPriceChangeOnlyLineItems(TriggerParameters tp) {
        //check if opportunity is auto renewal and price change only and total price is changed
        Map<String,OpportunityLineItemSchedule__c> mapOppyLineItemScheduleValid = new Map<String,OpportunityLineItemSchedule__c>();
        Set<Id> setContractsToQuery = new Set<Id>();
        //<Opportunity> lstOpportunitySyncNotPossible  = new List<Opportunity>();
        Map<Id,Opportunity> mapOpportunitySyncNotPossible=new Map<Id,Opportunity>();
        Map<String,String> mapContractToOppyForDuplicateProducts = new Map<String,String>();
        Set<String> oliIds = new Set<String>();
        Map<Id,Id> oliProductMap = new Map<Id,Id>();
        Map<Id,Id> oppSchProductMap = new Map<Id,Id>();
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            
            for(OpportunityLineItemSchedule__c oppSch : (List<OpportunityLineItemSchedule__c>) tp.newList) {
               oliIds.add(oppSch.OpportunityProductID__c);
            }
            if(!oliIds.isEmpty()) {
              for(OpportunityLineItem oli : [Select id,Product2Id from OpportunityLineItem where Id IN :oliIds]) {
               oliProductMap.put(oli.id,oli.Product2Id);
              }
            }    
            for(OpportunityLineItemSchedule__c oppySch : (List<OpportunityLineItemSchedule__c>) tp.newList) {
               if (oliProductMap.containsKey(oppySch.OpportunityProductID__c)) {
                   oppSchProductMap.put(oppySch.id,oliProductMap.get(oppySch.OpportunityProductID__c)); 
               }     
            }
            for(OpportunityLineItemSchedule__c oppySchedule : (List<OpportunityLineItemSchedule__c>) tp.newList) {
                OpportunityLineItemSchedule__c oldSchedule = (OpportunityLineItemSchedule__c) tp.oldMap.get(oppySchedule.Id);
                if(oppySchedule.AutoRenewal__c && oppySchedule.PriceChangeOnly__c &&  oppySchedule.TotalPrice__c!=oldSchedule.TotalPrice__c && oppySchedule.OriginatingContract__c!=null) {
                    String prodId = oliProductMap.containsKey(oppySchedule.OpportunityProductID__c) ? oliProductMap.get(oppySchedule.OpportunityProductID__c) : '';
                    mapOppyLineItemScheduleValid.put(''+oppySchedule.OriginatingContract__c + prodId + oppySchedule.InstallmentYears__c,oppySchedule);
                    setContractsToQuery.add(oppySchedule.OriginatingContract__c);
                    mapContractToOppyForDuplicateProducts.put(oppySchedule.Opportunity__c,oppySchedule.OriginatingContract__c);
                }
                System.debug('@PD==map  mapOppyLineItemScheduleValid to be updated=='+mapOppyLineItemScheduleValid);
            }
            if(mapContractToOppyForDuplicateProducts!=null && !mapContractToOppyForDuplicateProducts.isEmpty()) {
                //check if opportunity has 
                AggregateResult[] oppyWithDuplicateProducts = [Select count(Id) prodCount, Product2Id, OpportunityId from OpportunityLineItem where OpportunityId IN: mapContractToOppyForDuplicateProducts.keyset()
                                                                    Group by Product2Id, OpportunityId having count(Id)>1 ];
                if(oppyWithDuplicateProducts!=null && !oppyWithDuplicateProducts.isEmpty()) {
                    for(AggregateResult ar: oppyWithDuplicateProducts) {
                        String oppyId = (String)ar.get('OpportunityId');
                        //add oppy to oppy sync failure list
                        Opportunity tempOppyToUpdate = new Opportunity(id=oppyId, priceChangeSyncFailed__c=true);
                        //lstOpportunitySyncNotPossible.add(tempOppyToUpdate);
                        if(!mapOpportunitySyncNotPossible.containsKey(oppyId)) {
                            mapOpportunitySyncNotPossible.put(oppyId,tempOppyToUpdate);
                        }
                        //remove the contract from set to query
                        if(mapContractToOppyForDuplicateProducts.containsKey(oppyId)) {
                            setContractsToQuery.remove(mapContractToOppyForDuplicateProducts.get(oppyId));
                            mapContractToOppyForDuplicateProducts.remove(oppyId);
                        }                        
                    }
                }
                AggregateResult[] contractsWithDuplicateProducts = [Select count(Id) prodCount, AssociatedProduct__c, Contract__c from ContractLineItem__c 
                                                                    where Contract__c IN: mapContractToOppyForDuplicateProducts.values()
                                                                    Group by AssociatedProduct__c,Contract__c having count(Id)>1];
                if(contractsWithDuplicateProducts!=null && !contractsWithDuplicateProducts.isEmpty()) {
                    Set<String> contractIdToOppy = new Set<String>();
                    for(AggregateResult ar : contractsWithDuplicateProducts) {
                        String contractId = (String)ar.get('Contract__c');
                        //remove from set
                        setContractsToQuery.remove(contractId);
                        //add to set to traverse map
                        contractIdToOppy.add(contractId);
                    }
                    if(contractIdToOppy!=null && !contractIdToOppy.isEmpty()) {
                        for(String oppyId : mapContractToOppyForDuplicateProducts.keySet()) {
                            String contractId = mapContractToOppyForDuplicateProducts.get(oppyId);
                            if(contractIdToOppy.contains(contractId)){
                                Opportunity tempOppyToUpdate = new Opportunity(id=oppyId, priceChangeSyncFailed__c=true);
                                //lstOpportunitySyncNotPossible.add(tempOppyToUpdate);
                                if(!mapOpportunitySyncNotPossible.containsKey(oppyId)) {
                                    mapOpportunitySyncNotPossible.put(oppyId,tempOppyToUpdate);
                                }
                            }
                        }
                    }
                }
                
               // if(lstOpportunitySyncNotPossible!=null && !lstOpportunitySyncNotPossible.isEmpty()) {
                   // update lstOpportunitySyncNotPossible;
               // }
                if(mapOpportunitySyncNotPossible!=null && !mapOpportunitySyncNotPossible.isEmpty()) {
                    update mapOpportunitySyncNotPossible.values();
                }
            }
            if(setContractsToQuery!=null) {
                //query related originating contract's fixed fee line items in case they already exist
                List<ContractLineItemSchedule__c> lstFixedFeeScheduleToUpsert = new List<ContractLineItemSchedule__c>();
                List<ContractLineItemSchedule__c> lstFixedFeeScheduleToQuery = new List<ContractLineItemSchedule__c>();
                Map<String,ContractLineItemSchedule__c> mapCLISchedules = new Map<String,ContractLineItemSchedule__c>();
                Map<String,ContractLineItem__c> mapProductContractLineItem= new Map<String,ContractLineItem__c>();
                lstFixedFeeScheduleToQuery = [SELECT Id, Installmentyear__c, SalesPrice__c,Contract__c,ContractLineItem__c,
                                                DiscountAmount__c,DiscountType__c,DiscountPercent__c,ExternalListPrice__c,
                                                ContractLineItem__r.AssociatedProduct__c
                                                FROM ContractLineItemSchedule__c
                                                WHERE Contract__c IN : setContractsToQuery];
                //create a map out based on key ContractID + ProductId + InstallmentYear
                if(lstFixedFeeScheduleToQuery!=null && !lstFixedFeeScheduleToQuery.isEmpty()) {
                    for(ContractLineItemSchedule__c fixedFeeItemSchd : lstFixedFeeScheduleToQuery) {
                        mapCLISchedules.put(''+fixedFeeItemSchd.Contract__c + fixedFeeItemSchd.ContractLineItem__r.AssociatedProduct__c + fixedFeeItemSchd.InstallmentYear__c,fixedFeeItemSchd);
                        ContractLineItem__c tempCLI = new ContractLineItem__c(Id = fixedFeeItemSchd.ContractLineItem__c, Contract__c = fixedFeeItemSchd.Contract__c);
                        mapProductContractLineItem.put(fixedFeeItemSchd.ContractLineItem__r.AssociatedProduct__c,tempCLI);
                    }
                }
                System.debug('@PD==map  mapCLISchedules queried=='+mapOppyLineItemScheduleValid);
                //traverse the oppyschedule map and upsert fixed fee line items
                for(String oppyScheduleKey : mapOppyLineItemScheduleValid.keySet()) {
                    OpportunityLineItemSchedule__c oppySchedule = mapOppyLineItemScheduleValid.get(oppyScheduleKey);
                    ContractLineItemSchedule__c scheduleToUpsert = new ContractLineItemSchedule__c();
                    System.debug('@PD==oppyScheduleKey=='+oppyScheduleKey);
                    System.debug('@PD==map  mapOppyLineItemScheduleValid queried keyset=='+mapOppyLineItemScheduleValid.keySet());
                    System.debug('@PD==map  mapCLISchedules queried keyset=='+mapCLISchedules.keySet());
                    if(mapCLISchedules.containsKey(oppyScheduleKey)) {
                        scheduleToUpsert = mapCLISchedules.get(oppyScheduleKey);
                        System.debug('@Pd==schedule assigned=='+ scheduleToUpsert);
                    } 
                    else {
                        String prodId = oliProductMap.containsKey(oppySchedule.OpportunityProductID__c) ? oliProductMap.get(oppySchedule.OpportunityProductID__c) : '';
                        System.debug('@PD--'+prodId);
                        System.debug('@PD--'+mapProductContractLineItem.get(prodId));
                        if(mapProductContractLineItem.get(prodId)!=null) {
                            scheduleToUpsert.Contract__c = mapProductContractLineItem.get(prodId).Contract__c;
                            scheduleToUpsert.ContractLineItem__c = mapProductContractLineItem.get(prodId).Id;
                        }
                    }
                    if(scheduleToUpsert.Contract__c!=null && scheduleToUpsert.ContractLineItem__c!=null) {
                        scheduleToUpsert.InstallmentYear__c = oppySchedule.InstallmentYears__c;
                        scheduleToUpsert.SalesPrice__c = oppySchedule.TotalPrice__c;
                        scheduleToUpsert.CurrencyIsoCode = oppySchedule.CurrencyIsoCode;
                        scheduleToUpsert.DiscountAmount__c = oppySchedule.DiscountAmount__c;
                        scheduleToUpsert.DiscountType__c = oppySchedule.DiscountType__c;
                        scheduleToUpsert.DiscountPercent__c = oppySchedule.DiscountPercent__c;
                        scheduleToUpsert.ExternalListPrice__c = oppySchedule.ExternalListPrice__c;
                        scheduleToUpsert.PriceIncreaseId__c  = oppySchedule.Opportunity__c;
                        scheduleToUpsert.AutoRenewal__c = true;
                        lstFixedFeeScheduleToUpsert.add(scheduleToUpsert);
                    }
                        
                }
                if(lstFixedFeeScheduleToUpsert!=null && !lstFixedFeeScheduleToUpsert.isEmpty()) {
                    GlobalVariables.shouldCLIValidationBypass = true;
                    GlobalVariables.shouldContractValidationBypass = true;
                    upsert lstFixedFeeScheduleToUpsert;
                    GlobalVariables.shouldCLIValidationBypass = false;
                    GlobalVariables.shouldContractValidationBypass = false;
                }
            }

        }
        
    }

}