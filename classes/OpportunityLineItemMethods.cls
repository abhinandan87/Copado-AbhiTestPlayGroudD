//
//@Author : Paras Dhingra
//@Date : 15th Sep 2017
//@Description : SFDC1-4275 Trigger helper method class for OpportunityLineItem object 
//@company : IHS Markit
// @Last Modified By: Sruti Srivastava
// @Last Modified Date: 10th April 2018
// @Last Modified Description: SFDC1-7027- Added method populateContractStartDateAndEndDate which 
// populate Contract Start Date and End Date on Opportunity Line Items form Opportunity
// @Modification : SFDC1-8161: Modified exception handling by showing customized error message
// @Modified by : Sruti Srivastava
// @Last Modified Date: 8th May 2018
//@modified : Paras Dhingra
//@modified date : 20-Jun-2018
//@modified description: SFDC1-8222 Product schedule update on change of contract start date and end date
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 21 Aug 2018
// @Last Modified Description : SFDC1-8620 Resolving Apex security Risk - CRUD delete, adding isDeleteable() before delete operation
// @Last Modified Company : VERTIBA
// @Last Modified By: Tran-Vu Tran
// @Last Modified Date: 18 Dec 2018
// @Last Modified Description: SFDC1-10336 Removing isDeletable() check when deleting OpportunityLineItemSchedule.
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 12 February 2019
// @modifiedDescription: SFDC-660 populate "Opportunity Stage" value from Opportunity, this is used in Sales Classification formulas
// 
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 20 Feb 2019
// @modifiedDescription: SFDC-696 refactor rollupProductInfoToOpportunity method to handle the roll-up update
//                      and resolve "invalid query locator" error when adding/updating more than 30 products in an opportunity
// 
// @modifiedBy: Tran-Vu Tran
// @modifiedDate: 8th Mar 2019
// @modifiedDescription: SFDC-949 Contract Management profile needs rights to update Auto Renewal Oppty Line Item field
//
// @modifiedby: Paras Dhingra
// @modifiedDate: 26th July 2019
// @modified description : SFDC-1646 defaulting product owner to opportunity owner on insert
// //
// @modifiedby: Dev Aggarwal
// @modifiedDate: 19 February 2020
// @modified description : SFDC-1777 Add Product Owner and SME to Opportunity Team.

public class OpportunityLineItemMethods {
    //
    //@author : Paras Dhingra
    //@date : 15th Sep 2017
    //@description : SFDC1-4275 Method to rollup values from Oppy products to Opportunity
    //@param : TriggerParameters
    //@return : void
    //@companyname : IHS Markit
    // @Modification : SFDC1-8161: Modified exception handling, showing customized error message
    // @Modified by : Sruti Srivastava
    // @Last Modified Date: 8th May 2018
    // @Modifiedby : Digvijay Singh
    // @date :22 April 2022
    // @description : SFDC-5721,Added static boolean "hasrollupProductInfoToOpportunityCompleted" to stop multiple iteration of method causing 
    // SOQL 101 Error.
    //
    public static void rollupValuesToOpportunity(TriggerParameters tp) {
        if(GlobalConstants.isOppLineItemUpdatedDueToParentOppCascade) {
            return;
        }
        try {
            Set<Id> setOppyID = new Set<Id>();
            List<OpportunityLineItem> lstOLIUpdated = new List<OpportunityLineItem>();
            
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ||
               tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                   lstOLIUpdated = tp.newList;
               }
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) { 
                lstOLIUpdated = tp.oldList;
            }
            for(OpportunityLineItem oli : lstOLIUpdated) {
                setOppyID.add(oli.OpportunityId);
            }
            performRollupCalculationsforOpportunity(setOppyID);
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'OpportunityLineItemMethods', 'rollupValuesToOpportunity');
            String errMessage = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
                ex.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):ex.getMessage();
            System.debug('Exception caught' + errMessage);
            //tp.newList[0].addError('Error: '+errMessage);
        }
        
    }
    
    //
    //@author : Ankush Agarwal
    //@date : 15th Jun 2023
    //@description : Externalized the rollup summary calculation and Mobility Metrcis fields implementation
    //@param : OpportunityIdList
    //@return : void
    public static void performRollupCalculationsforOpportunity(set<Id> setOppyID) {
        try {
            set<Id> setPreviousOppyId= new set<ID>();
            Map<Id,List<OpportunityLineItem>> previousFiscalOppyWithOLI= new Map<Id,List<OpportunityLineItem>>();
            Map<Id, String> previousOppyProductStatus = new Map<Id, String>();
            Map<Id, String> previousOppyProductType = new Map<Id, String>();
            Map<Id,Decimal> previousOppyProductFirstYearValue = new Map<Id, Decimal>();
            Map<Id, Map<Id, String>> prvOppyProductsStatusMap = new Map<Id, Map<Id, String>>();
            Map<Id, Map<Id,String>> prvOppyProductsTypeMap = new Map<Id, Map<Id, String>>();
            Map<Id, Map<Id,Decimal>> prvOppyProductsFirstYearValueMap = new Map<Id, Map<Id, Decimal>>();
            Map<Id,Decimal> oppIdPriorYearValueSum = new Map<Id, Decimal>();
            Map<Id,Decimal> oppIdPriorYearValueSumSub = new Map<Id, Decimal>();
            Map<String,List<DatedConversionRate>> mapOfDatedConversionrate = UtilityClass.isoCurrencyDatedConversionRate;
            Map<Id,List<OpportunityLineItemSchedule__c>> mapOppyProductWithSchedules = new Map<Id,List<OpportunityLineItemSchedule__c>>();
            List<Opportunity> lstOpportunityToBeUpdated = new List<Opportunity>();
            List<String> lstExcludedProductNames = New List<String>();
            List<OpportunityLineItem> lstOLIUpdated = new List<OpportunityLineItem>();
            Decimal conversionRateYearly;
            
            
            //quering products from metadata that needs to be excluded.
            for(Mobility_Metrics_Excluded_Product_Name__mdt excludedProductName : Mobility_Metrics_Excluded_Product_Name__mdt.getAll().values()){
                lstExcludedProductNames.add('%' + excludedProductName.MasterLabel + '%');
            }
            //Query Opportunity Ids for which OLI was updated.
            List<Opportunity> lstOppyToUpdate = [Select id,BusinessLine__c,PreviousFiscalYearOpportunityLink__c,AverageDiscountPercentage__c,FirstYearValue__c, DiscountOverThreshold__c, MultiYear__c,SalesNewSubscription__c, SalesLostSubOnly__c,MobilitySalesRenewal__c,MobilitySalesNew__c, CurrencyIsoCode,ContractStartDate__c,SalesLosttransonly__c,
                                                 StageName, (select Id,Name,Product2Id,OpportunityId,Product2.AAG__c,product2.BusinessLine2__r.name, Status__c, ProductType__c, FirstYear__c, DiscountPercentage__c, DiscountOverThreshold__c,IsProRated__c
                                                             from OpportunityLineItems),
                                                 (select id, OpportunityProductID__c from OpportunityProductSchedules__r where Status__c!='Lost' )
                                                 from Opportunity where ID IN:setOppyID OR PreviousFiscalYearOpportunityLink__c IN : setOppyID];
            
            System.debug('--lstOppyToUpdate--'+lstOppyToUpdate[0].Id);
            System.debug('--lstOppyToUpdate--'+lstOppyToUpdate[0].OpportunityLineItems);
            
            if(lstOppyToUpdate!=null && !lstOppyToUpdate.isEmpty()) {
                for(Opportunity oppy : lstOppyToUpdate){
                    if(oppy.BusinessLine__c!=null){
                        if((oppy.BusinessLine__c).contains('Automotive Insights')){
                            setPreviousOppyId.add(oppy.PreviousFiscalYearOpportunityLink__c);
                        }
                    }
                }
                
                if(setPreviousOppyId!=null){
                    //quering prior year opp and related opportunity line items.
                    List<Opportunity> lstPreviousFiscalOppy = [Select id,PreviousFiscalYearOpportunityLink__c,AverageDiscountPercentage__c,FirstYearValue__c, DiscountOverThreshold__c, MultiYear__c,ContractBeingRenewed__c,ContractBeingRenewed__r.Opportunity__c,
                                                               (select Id,Name,OpportunityId,FirstYear__c,product2.BusinessLine2__r.name,Product2Id,Product2.AAG__c,DiscountPercentage__c, DiscountOverThreshold__c,IsProRated__c,Status__c, ProductType__c
                                                                from OpportunityLineItems WHERE (NOT Name LIKE :lstExcludedProductNames) AND product2.BusinessLine2__r.name='Automotive Insights')
                                                               from Opportunity where ID IN:setPreviousOppyId];
                    
                    if(lstPreviousFiscalOppy!=null && !lstPreviousFiscalOppy.isEmpty()){
                        //Iterating over list of Previous Year Opp.
                        for(Opportunity oppy : lstPreviousFiscalOppy){
                            
                            Decimal PriorYearTotalFirstYearValue = 0.0;
                            Decimal PriorYearTotalFirstYearValueSub = 0.0;
                            previousOppyProductStatus = new Map<Id, String>();
                            previousOppyProductType = new Map<Id, String>();
                            previousOppyProductFirstYearValue = new Map<Id, Decimal>();
                            
                            for(OpportunityLineItem oli: oppy.opportunityLineItems){
                                if(previousFiscalOppyWithOLI.containsKey(oppy.Id)){
                                    previousFiscalOppyWithOLI.get(oppy.Id).add(oli);
                                }
                                else{                       
                                    List<OpportunityLineItem> lstOppyLineItem = new List<OpportunityLineItem>();
                                    lstOppyLineItem.add(oli);
                                    previousFiscalOppyWithOLI.put(oppy.id,lstOppyLineItem);
                                }
                                //US: 856599 - Prior Year Pricing Story
                                if(!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights'){
                                    if(oli.Status__c!= 'Lost'){
                                        PriorYearTotalFirstYearValue = PriorYearTotalFirstYearValue + oli.FirstYear__c;
                                        if(oli.ProductType__c == 'Subscription'){
                                            PriorYearTotalFirstYearValueSub = PriorYearTotalFirstYearValueSub + oli.FirstYear__c;
                                        }
                                    }
                                }
                                oppIdPriorYearValueSum.put(oli.OpportunityId, PriorYearTotalFirstYearValue);
                                oppIdPriorYearValueSumSub.put(oli.OpportunityId, PriorYearTotalFirstYearValueSub);
                                
                                previousOppyProductStatus.put(oli.Product2Id, oli.Status__c);
                                previousOppyProductType.put(oli.Product2Id, oli.ProductType__c);
                                previousOppyProductFirstYearValue.put(oli.Product2Id, oli.FirstYear__c);
                                
                                prvOppyProductsStatusMap.put(oppy.Id, previousOppyProductStatus);
                                prvOppyProductsTypeMap.put(oppy.Id, previousOppyProductType);
                                prvOppyProductsFirstYearValueMap.put(oppy.Id, previousOppyProductFirstYearValue);
                            }
                            
                        }
                    }               
                    
                }
                
                for(Opportunity oppy : lstOppyToUpdate) {
                    
                    Opportunity oppyToUpdate = new Opportunity(Id=oppy.Id);
                    oppyToUpdate.AverageDiscountPercentage__c = 0.0;
                    oppyToUpdate.FirstYearValue__c = 0.0;
                    oppyToUpdate.DiscountOverThreshold__c = false;
                    oppyToUpdate.MultiYear__c = false;
                    oppyToUpdate.IsProRated__c='No';
                    oppyToUpdate.MobilitySalesNew__c = 0.0;
                    oppyToUpdate.MobilitySalesRenewal__c= 0.0;
                    oppyToUpdate.SalesNewSubscription__c = 0.0;
                    oppyToUpdate.SalesPriceIncreaseDecrease__c=0.0;
                    oppyToUpdate.CurrentYearTotalFirstYearValue__c = 0.0;
                    oppyToUpdate.CurrentYearTotalFirstYearValueSub__c = 0.0;
                    oppyToUpdate.SalesLostSubOnly__c = 0.0;
                    oppyToUpdate.SalesLosttransonly__c = 0.0;
                    oppyToUpdate.PriorYearTotalFirstYearValue__c=0.00;
                    oppyToUpdate.PriorYearTotalFirstYearValueSub__c=0.00;
                    oppyToUpdate.StageName = oppy.StageName;
                    boolean hasExistingStatusProduct = FALSE;
                    
                    // Fetching Yearly Conversion Rate.                    
                    if(mapOfDatedConversionrate!= null){
                        if(mapOfDatedConversionrate.keySet().contains(oppy.CurrencyIsoCode)){
                            List<DatedConversionRate> listOfMatchedOppyCurrency = mapOfDatedConversionrate.get(oppy.CurrencyIsoCode);
                            for(DatedConversionRate checkMultiYear : listOfMatchedOppyCurrency){
                                if(checkMultiYear != null && oppy.ContractStartDate__c != null && (checkMultiYear.StartDate == oppy.ContractStartDate__c  || checkMultiYear.StartDate < oppy.ContractStartDate__c)){
                                    conversionRateYearly = checkMultiYear.ConversionRate;
                                    break;
                                }
                                else{
                                    conversionRateYearly = listOfMatchedOppyCurrency[0].ConversionRate;
                                }
                            }
                        }
                    }
                    
                    //create a map of schedules with opportunity productId
                    for(OpportunityLineItemSchedule__c oppySchedule : oppy.OpportunityProductSchedules__r) {
                        if(oppySchedule.OpportunityProductID__c!=null) {
                            if(mapOppyProductWithSchedules.containsKey(oppySchedule.OpportunityProductID__c)) {
                                mapOppyProductWithSchedules.get(oppySchedule.OpportunityProductID__c).add(oppySchedule);
                            } 
                            else {
                                mapOppyProductWithSchedules.put(oppySchedule.OpportunityProductID__c,new List<OpportunityLineItemSchedule__c>{oppySchedule});
                            }
                        }
                    }
                    //Update Previous Fiscal Year Values based on previous Year oppy link
                    if(oppy.PreviousFiscalYearOpportunityLink__c != null && oppIdPriorYearValueSum.containsKey(oppy.PreviousFiscalYearOpportunityLink__c) && prvOppyProductsFirstYearValueMap.containsKey(oppy.PreviousFiscalYearOpportunityLink__c) && prvOppyProductsStatusMap.containsKey(oppy.PreviousFiscalYearOpportunityLink__c)) {
                        previousOppyProductStatus = prvOppyProductsStatusMap.get(oppy.PreviousFiscalYearOpportunityLink__c);
                        previousOppyProductType = prvOppyProductsTypeMap.get(oppy.PreviousFiscalYearOpportunityLink__c);
                        previousOppyProductFirstYearValue = prvOppyProductsFirstYearValueMap.get(oppy.PreviousFiscalYearOpportunityLink__c);
                        //US: 856599 - Prior Year Pricing Story
                        oppyToUpdate.PriorYearTotalFirstYearValue__c = oppIdPriorYearValueSum.get(oppy.PreviousFiscalYearOpportunityLink__c)/conversionRateYearly;
                        oppyToUpdate.PriorYearTotalFirstYearValueSub__c = oppIdPriorYearValueSumSub.get(oppy.PreviousFiscalYearOpportunityLink__c)/conversionRateYearly;
                    }
                    
                    for(OpportunityLineItem oli: oppy.OpportunityLineItems) {
                        system.debug('exclude check ===> '+ lstExcludedProductNames.contains(oli.Name) + oli.product2.BusinessLine2__r.name + oli.Status__c);
                        //Logic to calculate SalesLostSubOnly and SalesLosttransonly Fields on the basis of prior year opp.
                        if( oli.Status__c == 'Lost' && (!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights')){
                            if(previousOppyProductStatus != null && previousOppyProductStatus.containsKey(oli.Product2Id) && previousOppyProductStatus.get(oli.Product2Id) != 'Lost') {
                                if(oli.ProductType__c == 'Subscription'){
                                    oppyToUpdate.SalesLostSubOnly__c += (previousOppyProductFirstYearValue.get(oli.Product2Id))/conversionRateYearly;
                                }
                                if(oli.ProductType__c == 'Transaction'){
                                    oppyToUpdate.SalesLosttransonly__c += (previousOppyProductFirstYearValue.get(oli.Product2Id))/conversionRateYearly;
                                }
                            }
                        }
                        else{
                            if(oli.FirstYear__c!=null ) {
                                if(oli.Status__c!='Lost'){
                                    oppyToUpdate.FirstYearValue__c += oli.FirstYear__c;
                                }
                                //Calculating values for CurrentYearTotalFirstYearValue and CurrentYearTotalFirstYearValueSub fields.
                                if(!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights'){
                                    oppyToUpdate.CurrentYearTotalFirstYearValue__c += oli.FirstYear__c/conversionRateYearly;
                                    if(oli.ProductType__c == 'Subscription'){
                                        oppyToUpdate.CurrentYearTotalFirstYearValueSub__c += oli.FirstYear__c/conversionRateYearly;
                                    }
                                }
                            }                          
                            //US: 5856776 - Sales price increase decrease
                            if(oli.Status__c=='Existing' && (!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights')){
                                hasExistingStatusProduct = TRUE;
                                oppyToUpdate.MobilitySalesRenewal__c += oli.FirstYear__c/conversionRateYearly;
                                if(previousFiscalOppyWithOLI!=null && previousFiscalOppyWithOLI.containsKey(oppy.PreviousFiscalYearOpportunityLink__c)){
                                    if(oli.FirstYear__c!=null){
                                        oppyToUpdate.SalesPriceIncreaseDecrease__c+=oli.FirstYear__c/conversionRateYearly;
                                    }
                                    if(previousOppyProductStatus != null && previousOppyProductStatus.containsKey(oli.Product2Id) && (previousOppyProductStatus.get(oli.Product2Id) == 'New' || previousOppyProductStatus.get(oli.Product2Id) == 'Existing')){
                                        oppyToUpdate.SalesPriceIncreaseDecrease__c-=(previousOppyProductFirstYearValue.get(oli.Product2Id))/conversionRateYearly;
                                    }
                                }
                            }
                            // US: 5856692 - SalesNew and SalesRenewal fields
                            if(oli.Status__c=='New' && (!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights')) {
                                oppyToUpdate.MobilitySalesNew__c += oli.FirstYear__c/conversionRateYearly;
                                if(oli.ProductType__c == 'Subscription') {
                                    oppyToUpdate.SalesNewSubscription__c += oli.FirstYear__c/conversionRateYearly;
                                }
                            }
                            if(oli.Status__c!='Lost'){
                                if(oli.DiscountPercentage__c!=null) {
                                    oppyToUpdate.AverageDiscountPercentage__c += oli.DiscountPercentage__c;
                                }
                                if(oli.DiscountOverThreshold__c) {
                                    oppyToUpdate.DiscountOverThreshold__c = true;
                                }
                                if(oli.IsProRated__c=='Yes') {
                                    oppyToUpdate.IsProRated__c = 'Yes';
                                }
                                if(mapOppyProductWithSchedules!=null && mapOppyProductWithSchedules.containsKey(oli.Id)) {
                                    if(mapOppyProductWithSchedules.get(oli.Id).size()>1) {
                                        oppyToUpdate.Multiyear__c = true;  
                                    }
                                }
                            }
                        }
                    }
                    if(oppyToUpdate.StageName.contains('6L')){
                        oppyToUpdate.SalesLostSubOnly__c = 0.0;
                        oppyToUpdate.SalesLosttransonly__c = 0.0;
                        for(OpportunityLineItem oli: oppy.OpportunityLineItems) {
                            if(!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights'){
                                if(oli.ProductType__c == 'Subscription' && previousOppyProductFirstYearValue.ContainsKey(oli.Product2Id)){
                                    oppyToUpdate.SalesLostSubOnly__c += (previousOppyProductFirstYearValue.get(oli.Product2Id))/conversionRateYearly;
                                }
                                if(oli.ProductType__c == 'Transaction' && previousOppyProductFirstYearValue.ContainsKey(oli.Product2Id)){
                                    oppyToUpdate.SalesLosttransonly__c += (previousOppyProductFirstYearValue.get(oli.Product2Id))/conversionRateYearly;
                                }
                            }
                        }
                    }
                    if(oppyToUpdate.AverageDiscountPercentage__c>0) {
                        oppyToUpdate.AverageDiscountPercentage__c = oppyToUpdate.AverageDiscountPercentage__c/(oppy.OpportunityLineItems.size());
                    }
                    //Updating fields to 0 when the opp is Lost.
                    if(oppyToUpdate.StageName.contains('6L')){
                        oppyToUpdate.CurrentYearTotalFirstYearValue__c = 0;
                        oppyToUpdate.CurrentYearTotalFirstYearValueSub__c = 0;
                        oppyToUpdate.MobilitySalesRenewal__c = 0;
                        oppyToUpdate.SalesPriceIncreaseDecrease__c = 0;
                        oppyToUpdate.MobilitySalesNew__c=0;
                        oppyToUpdate.SalesNewSubscription__c=0;
                    }
                    if(!hasExistingStatusProduct){
                        oppyToUpdate.SalesPriceIncreaseDecrease__c = 0;
                    } 
                    
                    lstOpportunityToBeUpdated.add(oppyToUpdate);
                }
                if(lstOpportunityToBeUpdated!=null && !lstOpportunityToBeUpdated.isEmpty()) {
                    //prevent validations from rollup
                    GlobalConstants.hasTriggeredFromOpportunityProduct = true;
                    update lstOpportunityToBeUpdated;
                }
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'OpportunityLineItemMethods', 'performRollupCalculationsforOpportunity');
            String errMessage = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
                ex.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):ex.getMessage();
            System.debug('Exception caught' + errMessage);
            //tp.newList[0].addError('Error: '+errMessage);
            //throw new GenericCustomException('Error occurred. Please contact salesforce helpdesk for assistance', ex);
        }
    }
    
    //
    //@author : Paras Dhingra
    //@date : 14th Dec 2017
    //@description : SFDC1-5432 Clear all related Opportunity Line Item schedule after delete 
    //@param : TriggerParameters
    //@return : void
    //@companyname : IHS Markit
    //
    public static void deleteChildOpportunityLineItemSchedules(TriggerParameters tp) {
        try {
            Set<Id> setOLIIds = new Set<Id>();
            List<OpportunityLineItem> lstOLIDeleted = new List<OpportunityLineItem>();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) { 
                lstOLIDeleted = tp.oldList;
                for(OpportunityLineItem oli : lstOLIDeleted) {
                    setOLIIds.add(oli.Id);
                }
                if(setOLIIds!=null && !setOLIIds.isEmpty()) {
                    //query Opportunity line item schedules
                    List<OpportunityLineItemSchedule__c> listOLIs = [Select id from OpportunityLineItemSchedule__c 
                                                                     where OpportunityProductID__c IN:setOLIIds];
                    if(listOLIs!=null && !listOLIs.isEmpty() 
                       // SFDC1-10336 Removing isDeletable() check when deleting OpportunityLineItemSchedule
                       // && OpportunityLineItemSchedule__c.sObjectType.getDescribe().isDeletable()
                      ) {
                          delete listOLIs;
                      }
                }
            }
            
        }
        catch(Exception ex) {
            System.debug('Exception caught' + ex);
            UtilityClass.createApexLogRecord(ex, 'OpportunityLineItemMethods', 'deleteChildOpportunityLineItemSchedules');
            throw new GenericCustomException('Error occurred. Please contact salesforce helpdesk for assistance');
        }
    }
    
    //-----------------------------
    // @author: Sruti Srivastava
    // @date: 9th April 2018
    // @param: TriggerParameters
    // @description: SFDC1-7027 - populate Contract Start Date and End Date on Opportunity Line Items form Opportunity
    // This method will be called in before insert trigger Events.
    // @return: None
    //------------------------------
    public static void populateContractStartDateAndEndDate(TriggerParameters tp) {
        
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        List<OpportunityLineItem> listNewOpportunityLineItem = (List<OpportunityLineItem>)tp.newList;
        Set<Id> setOpportunityIds = new Set<Id>();
        //Method should run on before insert
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
            try {
                // Add all related opportunity to a set
                for(OpportunityLineItem newOLI : listNewOpportunityLineItem) {
                    setOpportunityIds.add(newOLI.OpportunityId);
                }
                
                //If Contract Start Date or End Date on Opportunity have been populated, populate values on Opportunity Products too
                if(!setOpportunityIds.isEmpty()) {
                    // Querying related Opportunities
                    for(Opportunity opp : [Select Id, ContractStartDate__c, ContractEndDate__c
                                           from Opportunity
                                           where Id IN: setOpportunityIds ]) {
                                               if(opp.ContractEndDate__c !=  null ||
                                                  opp.ContractStartDate__c !=  null) {                                         
                                                      mapOpportunity.put(opp.Id, opp );
                                                  }
                                           }
                }
                if(!listNewOpportunityLineItem.isEmpty()) {
                    for(OpportunityLineItem newOLI : listNewOpportunityLineItem) {
                        if(mapOpportunity != null && mapOpportunity.containsKey(newOLI.OpportunityId)) {
                            Opportunity opp = mapOpportunity.get(newOLI.OpportunityId);
                            newOLI.ContractStartDate__c = opp.ContractStartDate__c;
                            newOLI.ContractEndDate__c = opp.ContractEndDate__c;
                        }
                        else {
                            newOLI.ContractStartDate__c = null;
                            newOLI.ContractEndDate__c = null;
                        }
                    }
                }
            }
            catch(Exception e) {
                UtilityClass.createApexLogRecord(e, 'OpportunityLineItemMethods', 'populateContractStartDateAndEndDate');
                System.debug('Exception in OpportunityLineItemMethods.PopulateContractStartDateAndEndDate: ' + e.getMessage());
            }
        }
    }
    
    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 11 February 2019
    // @description: SFDC-660 populate hidden field "Opportunity Stage" value from Opportunity, this is used in Sales Classification formulas
    // @return: None
    //------------------------------
    public static void populateOpportunityStage(TriggerParameters tp) {
        
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        List<OpportunityLineItem> listNewOpportunityLineItem = (List<OpportunityLineItem>)tp.newList;
        Set<Id> setOpportunityIds = new Set<Id>();
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert
            || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                try {
                    // Add all related opportunity to a set
                    for (OpportunityLineItem newOLI : listNewOpportunityLineItem) {
                        setOpportunityIds.add(newOLI.OpportunityId);
                    }
                    
                    //If Contract Start Date or End Date on Opportunity have been populated, populate values on Opportunity Products too
                    if (!setOpportunityIds.isEmpty()) {
                        // Querying related Opportunities
                        for (Opportunity opp : [Select Id, StageName from Opportunity where Id in: setOpportunityIds]) {
                            mapOpportunity.put(opp.Id, opp);
                        }
                    }
                    
                    for (OpportunityLineItem newOLI : listNewOpportunityLineItem) {
                        Opportunity opp = mapOpportunity.get(newOLI.OpportunityId);
                        if (opp != null) {
                            newOLI.OpportunityStage__c = opp.StageName;
                        }
                    }
                }
                
                catch(Exception e) {
                    System.debug('Exception in OpportunityLineItemMethods.populateOpportunityStage: ' + e.getMessage());
                    UtilityClass.createApexLogRecord(e, 'OpportunityLineItemMethods', 'populateOpportunityStage');
                }
            }
    }
    
    //
    //@author : Paras Dhingra
    //@date : 10th Apr 2018
    //@description : SFDC1-7525 Rollup profit center, product family, and former Ip to Opportunity level 
    //@param : TriggerParameters
    //@return : void
    //@companyname : IHS Markit
    // @Modification : SFDC1-8161: Modified exception handling, showing customized error message
    // @Modified by : Sruti Srivastava
    // @Last Modified Date: 8th May 2018
    // @Modification : SFDC1-9301: Modified to update Product Family Field on Contract
    // @Modified by : Ankita Singh
    // @Last Modified Date: 23rd July 2018
    // @Modification : SFDC1-5228: Account Overview Report
    // @Modified by : Jagadesh Kumar
    // @Last Modified Date: 01st Aug 2018
    // @Modification: SFDC1-9374 add Business Line to list of roll-up fields from Product to Opportunity
    // @Modified by: Tran-Vu Tran
    // @Last Modified Date: 01st Oct 2018
    // @Modified by : Jagadesh Kumar
    // @Last Modified Date: 06 Dec 2018
    // @Modification: SFDC1-10588 added sorting for productFamily, productGroup,profitCenter,businessLine,formerIP
    // 
    // @Modified by: Tran-Vu Tran
    // @Modified Date: 20 Feb 2019
    // @Modification: SFDC-696 refactored rollupProductInfoToOpportunity method to handle the roll-up update
    //                  and resolve "invalid query locator" error when adding more than 30 products
    // @Modifiedby : Digvijay Singh
    // @date :22 April 2022
    // @description : SFDC-5721,Added static boolean "hasrollupProductInfoToOpportunityCompleted" to stop multiple iteration of method causing 
    // SOQL 101 Error.
    public static void rollupProductInfoToOpportunity(TriggerParameters tp) {
        if(GlobalConstants.isOppLineItemUpdatedDueToParentOppCascade) {
            return;
        }
        //SFDC-5721
        if(!GlobalVariables.hasrollupProductInfoToOpportunityCompleted || tp.tEvent == TriggerParameters.TriggerEvent.afterInsert || tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
            try {
                //create a set of opportunityid from opportunity products being updated
                Set<Id> setOpportunityIds = new Set<Id>();
                
                if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert
                    || tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate
                    || tp.tEvent == TriggerParameters.TriggerEvent.afterUndelete) {
                        for (OpportunityLineItem oli: (List<OpportunityLineItem>) tp.newList) {
                            setOpportunityIds.add(oli.OpportunityId);
                        }
                    }
                
                if (tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                    for (OpportunityLineItem oli: (List<OpportunityLineItem>) tp.oldList) {
                        setOpportunityIds.add(oli.OpportunityId);
                    }           
                }
                
                if (!setOpportunityIds.isEmpty()) {
                    rollupProductInfoToOpportunity(setOpportunityIds);
                }
            }
            catch (Exception ex) {
                String errMessage = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')?
                    ex.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):ex.getMessage();
                System.debug('Exception in OpportunityLineItemMethods.rollupProductInfoToOpportunity: ' + errMessage);
                //tp.newList[0].addError('Error: ' + errMessage);
                //throw new GenericCustomException ('An Exception Has been caught+ex.getMessage()', ex);
            }
        }
        //SFDC-5721
        GlobalVariables.hasrollupProductInfoToOpportunityCompleted=true;
    }
    //----------------------------
    // @author: Tran-Vu Tran
    // @date: 20th Feb 201
    // @description: SFDC-696 refactored from the method above to handle the roll-up update
    //                  and resolve "invalid query locator" error when adding more than 30 products
    //              + SFDC-887 stop cascading Product Family "Roll-up" field to related Contract records
    // @modified by: Paras Dhingra
    // @date: 11th Jul 2019
    // @description: SFDC-1346 Adding more rollup fields Global Segments and at opportunity level for reporting purposes
    // @modified by: Sushma Yadav
    // @date: 4th Jun 2020
    // description: SFDC-2969 Adding more rollup fields Internal Business Segments and at opportunity level for reporting purposes
    // @modified : Digvijay Singh
    // @date: 11 Nov 2021
    // @param: TriggerParameters tp
    // @description: SFDC-4820,changes to Roll up Synergy Theme and Type to Opporunity 
    // @date: 28 Feb 2022
    // @description: SFDC-5557,updated logic to use AutoCalculateRollupValueHelper class  
    // @modified : Neelam agrawal
    // @date: 05 May 2022  
    // @description: SFDC-5699 CI Division - New field on Opportunity & Opportunity Line Item  
    //----------------------------
    public static void rollupProductInfoToOpportunity(Set<Id> setOpportunityIds) {
        System.Savepoint sp = Database.setSavepoint();
        try {
            List<Opportunity> lstOpportunityUpdate = new List<Opportunity>();
            //List<Contract> contractToBeUpdatedList = new List<Contract>();
            
            //query related opportunities with fields that needs to be rolled up
            List<Opportunity> lstOppy = [Select Id, SynergyType__c, SynergyTheme__c,CIDivision__c,Referral_ID__c, ProfitCenter__c,InternalBusinessSegment__c,GlobalSegments__c, BusinessLine__c, ProductFamily__c, ProductGroup__c, FormerIP__c,SubBusinessLine__c
                                         from opportunity where Id in: setOpportunityIds ]; //SFDC1-5228 JK- Change
            
            //Map<Id, List<OpportunityLineItem>> mapOpportunity_LineItems = new Map<Id, List<OpportunityLineItem>>();
            List<OpportunityLineItem> opptyLineItemList = [Select Id, OpportunityId,SynergyType__c, SynergyTheme__c,CIDivision__c,
                                                           PricebookEntry.Product2.FormerIPOwner__c, PricebookEntry.Product2.Family__r.name,
                                                           PricebookEntry.Product2.ProductGroup__r.name, PricebookEntry.Product2.ProfitCenters__r.name,
                                                           PricebookEntry.Product2.BusinessLine2__r.Name,
                                                           PricebookEntry.Product2.SubBusinessLine__r.Name,
                                                           PricebookEntry.Product2.Division__c,
                                                           PricebookEntry.Product2.InternalBusinessSegment__c
                                                           from OpportunityLineItem where OpportunityId in: setOpportunityIds and Status__c!='Lost'];
            
            lstOpportunityUpdate=AutoCalculateRollupValueHelper.rollupProductInfoToParent(lstOppy,opptyLineItemList,'OpportunityId',Null);
            /*SFDC- 5557 Commenting this logic , AutoCalculateRollupValueHelper class will be used to calculate logic
{
List<OpportunityLineItem> opptyLineItems = mapOpportunity_LineItems.get(opptyLineItem.OpportunityId);
if (opptyLineItems == null) {
opptyLineItems = new List<OpportunityLineItem>();
}
opptyLineItems.add(opptyLineItem);
mapOpportunity_LineItems.put(opptyLineItem.OpportunityId, opptyLineItems);
}
*/
            
            /* SFDC-887 stop cascading Product Family "Roll-up" field to related Contract records,
* instead the Contract's Product Family would be rolled up from Contract Line Items
Map<Id, List<Contract>> mapOpportunity_Contracts = new Map<Id, List<Contract>>();
for (Contract opptyContract : [Select Id, Opportunity__c, ProductFamily__c, ProductGroup__c from Contract
where Opportunity__c in: setOpportunityIds and
(RecordType.DeveloperName='OrderForm' or RecordType.DeveloperName='Consulting')])
{
List<Contract> opptyContracts = mapOpportunity_Contracts.get(opptyContract.Opportunity__c);
if (opptyContracts == null) {
opptyContracts = new List<Contract>();
}
opptyContracts.add(opptyContract);
mapOpportunity_Contracts.put(opptyContract.Opportunity__c, opptyContracts);
}
*/
            
            /* SFDC- 5557 Commenting this logic , AutoCalculateRollupValueHelper class will be used to calculate logic
for (Opportunity oppy: lstOppy) {

//initialize the opportunity 
Set<String> productFamily = new Set<String>();
Set<String> productGroup = new Set<String>();   //SFDC1-5228 JK- New                                         
Set<String> profitCenter = new Set<String>();
Set<String> businessLine = new Set<String>();
Set<String> formerIP = new Set<String>();

//SFDC-4820,Set declared to Roll up Synergy Theme and Type to Opporunity  
Set<String> setSynergyType = new Set<String>();
Set<String> setSynergyTheme = new Set<String>();
//Adding new fields to rollup SFDC-1346
Set<String> productSubBusinessLine = new Set<String>();
Set<String> productGlobalSegment = new Set<String>();
//Adding new fields to rollup SFDC-2969
Set<String> productInternalBusinessSegment = new Set<String>();                

//initialize sets and add values from related child opportunity line items
List<OpportunityLineItem> opptyLineItems = mapOpportunity_LineItems.get(oppy.Id);
if (opptyLineItems != null) {
for (OpportunityLineItem childOlI : opptyLineItems) {
//SFDC-4820,Collect to Roll up Synergy  Type from  Opporunity Line Items
if(childOlI.SynergyType__c!=null && !String.IsEmpty(childOlI.SynergyType__c)) {
setSynergyType.add(childOlI.SynergyType__c);
}
//SFDC-4820,Collect to Roll up Synergy  Theme from  Opporunity Line Items
if(childOlI.SynergyTheme__c!=null && !String.IsEmpty(childOlI.SynergyTheme__c)) {
setSynergyTheme.add(childOlI.SynergyTheme__c);
}
if (childOlI.PricebookEntry.Product2.Family__r.name != null) {
productFamily.add(childOlI.PricebookEntry.Product2.Family__r.name.trim());    
}
if (childOlI.PricebookEntry.Product2.ProductGroup__r.name != null) {
productGroup.add(childOlI.PricebookEntry.Product2.ProductGroup__r.name.trim()); //SFDC1-5228 JK- New                                                                        
}
if (childOlI.PricebookEntry.Product2.ProfitCenters__r.name != null) {
profitCenter.add(childOlI.PricebookEntry.Product2.ProfitCenters__r.name.trim());    
}
if (childOlI.PricebookEntry.Product2.BusinessLine2__r.name != null) {
businessLine.add(childOlI.PricebookEntry.Product2.BusinessLine2__r.name.trim()); // SFDC1-9374 TVT add Business Line    
}
if (childOlI.PricebookEntry.Product2.FormerIPOwner__c != null) {
formerIP.add(childOlI.PricebookEntry.Product2.FormerIPOwner__c.trim());    
}
//adding for SFDC-1346
if(childOlI.PriceBookEntry.Product2.SubBusinessLine__r.Name!= null) {
productSubBusinessLine.add(childOlI.PriceBookEntry.Product2.SubBusinessLine__r.Name);
}
if(childOlI.PriceBookEntry.Product2.Division__c !=null) {
productGlobalSegment.add(childOlI.PriceBookEntry.Product2.Division__c);
}
//adding for SFDC-2969
if(childOlI.PriceBookEntry.Product2.InternalBusinessSegment__c!= null) {
productInternalBusinessSegment.add(childOlI.PriceBookEntry.Product2.InternalBusinessSegment__c);
}
}

//initialize values from oppy
oppy.ProfitCenter__c = '';
oppy.BusinessLine__c = '';
oppy.ProductFamily__c = '';
oppy.ProductGroup__c = '';  //SFDC1-5228 JK- New                      
oppy.FormerIP__c = '';
//SFDC-4820,changes to Roll up Synergy Theme and Type to Opporunity
oppy.SynergyType__c='';
oppy.SynergyTheme__c='';
//adding new roll ups SFDC-1364
oppy.SubBusinessLine__c = '';
oppy.GlobalSegments__c = '';
//adding new roll up SFDC-2969
oppy.InternalBusinessSegment__c = '';
//process product family and create comma separated values
if (productFamily.size()>0) {
List<String> productFamilyList = new List<String>(productFamily);
productFamilyList.sort();
oppy.ProductFamily__c = String.join(productFamilyList,',');     
}
//SFDC-4820,Set  Synergy Theme and Type on  Opporunity
if (setSynergyType.size()>0) {  
List<String> listSynergyType = new List<String>(setSynergyType);
listSynergyType.sort();
oppy.SynergyType__c = String.join(listSynergyType,',');     
}

if (setSynergyTheme.size()>0) { 
List<String> listSynergyTheme = new List<String>(setSynergyTheme);
listSynergyTheme.sort();
oppy.SynergyTheme__c = String.join(listSynergyTheme,',');     
}

//process product group and create comma separated values
if (productGroup.size()>0) {    //SFDC1-5228 JK- New
List<String> productGroupList = new List<String>(productGroup);
productGroupList.sort();
oppy.ProductGroup__c = String.join(productGroupList,',');       
}                                                                                                    

//process profit center values
if (profitCenter.size()>0) {
List<String> profitCenterList = new List<String>(profitCenter);
profitCenterList.sort();
oppy.ProfitCenter__c = String.join(profitCenterList,',');
}

//process business line values
if (businessLine.size() > 0) {
List<String> businessLineList = new List<String>(businessLine);
businessLineList.sort();
oppy.BusinessLine__c = String.join(businessLineList, ',');
}

//process formerIP values
if (formerIP.size()>0) {
List<String> formerIPList = new List<String>(formerIP);
formerIPList.sort();
oppy.FormerIP__c = String.join(formerIPList,',');
}
//process sub business lines
if(productSubBusinessLine.size()>0) {
List<String> subBusinessLineList = new List<String>(productSubBusinessLine);
subBusinessLineList.sort();
oppy.SubBusinessLine__c = String.join(subBusinessLineList,',');
}
//process global segment
if(productGlobalSegment.size()>0) {
List<String> globalSegmentList = new List<String>(productGlobalSegment);
globalSegmentList.sort();
oppy.GlobalSegments__c = String.join(globalSegmentList,',');
}
//process Internal Business Segment
if(productInternalBusinessSegment.size()>0) {
List<String> InternalBusinessSegmentList = new List<String>(productInternalBusinessSegment);
InternalBusinessSegmentList.sort();
oppy.InternalBusinessSegment__c = String.join(InternalBusinessSegmentList,',');
}

lstOpportunityUpdate.add(oppy);                    
}

/* SFDC-887 stop cascading Product Family "Roll-up" field to related Contract records,
* instead the Contract's Product Family would be rolled up from Contract Line Items

// Updating Product Family Field on Contract
List<Contract> opptyContracts = mapOpportunity_Contracts.get(oppy.Id);
// SFDC1-10588: Product group rollup is moved to ContractLineItem trigger
if (opptyContracts != null) {
for (Contract childContract : opptyContracts) {
childContract.ProductFamily__c = '';
if (productFamily.size() > 0) {
List<String> productFamilyList = new List<String>(productFamily);
productFamilyList.sort();
childContract.ProductFamily__c = String.join(productFamilyList,',');    
contractToBeUpdatedList.add(childContract);
}
}
}

}
*/
            
            if (!lstOpportunityUpdate.isEmpty()) {
                update lstOpportunityUpdate;
            }
            
            /* SFDC- 5557: Analysed contracts are not updating in this method
if (!contractToBeUpdatedList.isEmpty()) {
update contractToBeUpdatedList;
}
*/
        }
        
        catch(Exception ex) {
            Database.rollback(sp);
            throw(ex);
        }
    }
    
    //@author : Mohit Modi
    //@date : 23 Apr 2018
    //@description : SFDC1-5722 : This method will be used to prevent the deletion of Opportunity line Items from UI, it wcan be bypassed using the global constant in any of the APEX.
    //@param : TriggerParameters
    //@return : void
    //@companyname : Vertiba
    public static void preventOpportunityLineItemDeletion(TriggerParameters tp) {
        // This is a globla constant which will be used to bypass this trigger Error if required.
        if(!GlobalConstants.hasAllowedOpportunityProductDeletion) {
            
            String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            system.debug('ProfileName'+profileName);
            List<OpportunityLineItem> listOppLineItem = (List<OpportunityLineItem>) tp.oldList;
            for(OpportunityLineItem OppLineItemObj : listOppLineItem) {
                if(!profileName.contains('System Admin')){
                    OppLineItemObj.addError('You are not authorized to delete Opportunity Products.');
                }
            }        
        }
    }
    //@author : Paras Dhingra
    //@date : 04 Jun 2018
    //@description : SFDC1-7082 : Rolling down children Oppy schedules on change of contract start date and end date
    //@param : TriggerParameters
    //@return : void
    //@companyname : IHS Markit
    //@modified : Paras Dhingra
    //@modified date : 20-Jun-2018
    //@modified description: SFDC1-8222 Product schedule update on change of contract start date and end date
    //@modified : Dev Aggarwal
    //@modified date : 14-February-2020
    //@modified description: SFDC-2629 
    public static void updateChildSchedulesOnContractDateChange(TriggerParameters tp) {
        System.Savepoint sp = Database.setSavepoint();
        try {
            List<OpportunityLineItemSchedule__c> lstOppySchedulesToUpdate = new List<OpportunityLineItemSchedule__c>();
            List<OpportunityLineItemSchedule__c> lstOLISToBeChanged = new List<OpportunityLineItemSchedule__c>();
            Map<Id,OpportunityLineItem> mapOLIContractDateChanged = new Map<Id,OpportunityLineItem>();
            Map<Id,OpportunityLineItem> mapOLIContractFiscalChanged = new Map<Id,OpportunityLineItem>();
            Map<Id,OpportunityLineItem> mapOLIAllChanged = new Map<Id,OpportunityLineItem>();
            Set<Id> setProductIDs = new Set<Id>();
            Set<String> setPricingYear = new Set<String>();
            Map<Id,String> mapOLIFiscalYear = new Map<Id,String>();
            Map<String,ProductSchedule__c> mapMultiKeyProductSchedule = new Map<String,ProductSchedule__c>();
            Set<Id>setOpportunityIdForBlankCSDOLIs = new Set<Id>();
            Set<Id>setOLIIdsBlankCSD = new Set<Id>();
            if(!GlobalConstants.preventOpportunityProductScheduleUpdate) {
                GlobalConstants.preventOpportunityProductScheduleUpdate=true;
                Integer fiscalStartMonth = UtilityClass.FiscalStartMonth;
                //collect all opportunity products for which contract start date or end date has been modified
                for(OpportunityLineItem oli : (List<OpportunityLineItem>) tp.newList) {
                    OpportunityLineItem oldOli =(OpportunityLineItem)tp.oldMap.get(oli.Id);
                    if(oldOli!=null  && (oli.ContractStartDate__c!=oldOli.ContractStartDate__c || oli.ContractEndDate__c!=oldOli.ContractEndDate__c)) {
                        //fiscal change
                        if(oli.ContractStartDate__c!=null) {
                            //Integer oldOLIFiscalYear = UtilityClass.calculateFYFromDate(oldOli.ContractStartDate__c,fiscalStartMonth);
                            Integer oliFiscalYear =  UtilityClass.calculateFYFromDate(oli.ContractStartDate__c,fiscalStartMonth);
                            //if(oldOLIFiscalYear!=oliFiscalYear) {
                            mapOLIContractFiscalChanged.put(oli.id,oli);
                            mapOLIAllChanged.put(oli.Id,oli);
                            setProductIDs.add(oli.Product2Id);
                            setPricingYear.add(String.valueOf(oliFiscalYear));
                            mapOLIFiscalYear.put(oli.Id,String.valueOf(oliFiscalYear));
                            //}
                        } 
                        else if(oli.ContractStartDate__c==null) {
                            //fetch contract start date or close date from opportunity
                            setOpportunityIdForBlankCSDOLIs.add(oli.OpportunityId);
                            setOLIIdsBlankCSD.add(oli.Id);
                        }
                        
                        //check if opportunity is already pro-rated and is eligible for pro-ration
                        //to be uncommented for phase 1.3
                        /*
if(oli.status__c!='Lost' && oli.isProRated__c=='Yes'&& oli.ProductType__c =='Subscription' ) {
mapOLIContractDateChanged.put(oli.id,oli);
mapOLIAllChanged.put(oli.Id,oli);
}*/
                    }
                    
                }
                System.debug('--setOpportunityIdForBlankCSDOLIs--'+ setOpportunityIdForBlankCSDOLIs);
                
                if(setOpportunityIdForBlankCSDOLIs!=null && !setOpportunityIdForBlankCSDOLIs.isEmpty()) {
                    //query opportunities for closeDate and opportunity start date
                    Map<Id,Opportunity> mapOppyForCSD = new Map<Id,Opportunity>([Select Id, CloseDate, ContractStartDate__c 
                                                                                 from Opportunity 
                                                                                 where Id IN: setOpportunityIdForBlankCSDOLIs ]);
                    System.debug('--mapOppyForCSD--'+mapOppyForCSD);
                    if(mapOppyForCSD!=null && !mapOppyForCSD.isEmpty()) {
                        for(Id OLIId : setOLIIdsBlankCSD) {
                            OpportunityLineItem oli = (opportunityLineItem)tp.newMap.get(OLIId);
                            OpportunityLineItem oldOLi = (OpportunityLineItem)tp.oldMap.get(OLIId);
                            Opportunity oppy = mapOppyForCSD.get(oli.OpportunityId);
                            Integer oppyFiscalYear;
                            //by defauly fiscal date is close date but if Contract Start date is present, it takes precedence
                            Date fiscalDate = oppy.CloseDate;
                            if(oppy.ContractStartDate__c!=null) {
                                fiscalDate = oppy.ContractStartDate__c;
                            }
                            oppyFiscalYear = UtilityClass.calculateFYFromDate(fiscalDate,fiscalStartMonth);
                            //update maps with opportunity fiscal year as oppy fiscal year is not present
                            if(oppyFiscalYear!=null) {
                                System.debug('@PD--inside oppyFiscalYear logic');
                                mapOLIContractFiscalChanged.put(oli.id,oli);
                                mapOLIAllChanged.put(oli.Id,oli);
                                setProductIDs.add(oli.Product2Id);
                                setPricingYear.add(String.valueOf(oppyFiscalYear));
                                mapOLIFiscalYear.put(oli.Id,String.valueOf(oppyFiscalYear));
                            }
                            
                        }
                    }
                }
                System.debug('@PD --mapOLIAllChanged--'+mapOLIAllChanged.size());
                System.debug('@PD --mapOLIContractDateChanged--'+mapOLIContractDateChanged.size());
                System.debug('@PD --mapOLIContractFiscalChanged--'+mapOLIContractFiscalChanged.size());
                System.debug('@PD --mapOLIFiscalYear--'+mapOLIFiscalYear);
                
                if(mapOLIAllChanged!=null && !mapOLIAllChanged.isEmpty()) {
                    lstOLISToBeChanged = [Select id, DiscountPercent__c,DiscountAmount__c,DiscountType__c,ExternalListPrice__c,
                                          InstallmentYears__c, OpportunityProductID__c,PriceBookListPrice__c, Product__c,ProductSchedule__c,
                                          ProductSchedule__r.ProductTerm__c, ProductSchedule__r.Year__c,
                                          SalesPrice__c, TotalPrice__c, Quantity__c,AnnualizedDiscountAmount__c, AnnualizedUnitPrice__c, 
                                          AnnualizedTotalAmount__c, ProRatedDiscountAmount__c, ProRatedUnitPrice__c
                                          from OpportunityLineItemSchedule__c
                                          where OpportunityProductID__c IN: mapOLIAllChanged.keySet()
                                          order by InstallmentYears__c ASC];
                    if(mapOLIContractFiscalChanged!=null && !mapOLIContractFiscalChanged.isEmpty()) {
                        //query the product schedules to be reassigned to olis
                        
                        List<ProductSchedule__c> lstProdSchedules = [Select id,Product__c,InstallmentYear__c,PricingYear__c,Year__c,ProductTerm__c,ListPrice__c 
                                                                     from ProductSchedule__c  
                                                                     where isactive__c = true AND PricingYear__c IN:setPricingYear AND Product__c IN:setProductIDs 
                                                                     order by InstallmentYear__c,ProductTerm__c ASC];
                        if(lstProdSchedules!=null && !lstProdSchedules.isEmpty()) {
                            for(ProductSchedule__c ps : lstProdSchedules) {
                                String PSKey = String.valueOf(ps.Product__c) + ps.PricingYear__c + ps.Year__c + ps.ProductTerm__c ;
                                mapMultiKeyProductSchedule.put(PSKey,ps);
                            }
                            
                        }
                        
                    }
                    System.debug('@PD--lstOLIS--'+lstOLISToBeChanged);
                    if(lstOLISToBeChanged!=null && !lstOLISToBeChanged.isEmpty()) {
                        //change pro-ration of opportunity schedule products and change of contract where financial year is changed
                        for(opportunityLineItemSchedule__c olis : lstOLISToBeChanged) {
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli=mapOLIAllChanged.get(olis.OpportunityProductID__c);
                            //make changes to olis oppy schedules if contract date is changed of parent oppy products
                            //to be uncommendted for phase 1.3
                            /*
if(mapOLIContractDateChanged.containsKey(olis.OpportunityProductID__c)) {
Double proRatedDays = UtilityClass.getDays360(oli.ContractStartDate__c, oli.ContractEndDate__c);
//copy existing unit price to annualized unit price and discount
olis.ProRatedUnitPrice__c = (olis.AnnualizedUnitPrice__c / 360) * proRatedDays;
olis.ProRatedDiscountAmount__c = (olis.AnnualizedDiscountAmount__c / 360) * proRatedDays;
//set precision to 2
olis.ProRatedUnitPrice__c = olis.ProRatedUnitPrice__c.setScale(2);
olis.ProRatedDiscountAmount__c = olis.ProRatedDiscountAmount__c.setScale(2);
//move values from proRated to unit price
olis.ExternalListPrice__c = olis.ProRatedUnitPrice__c;
olis.DiscountAmount__c = olis.ProRatedDiscountAmount__c;
olis.SalesPrice__c = (olis.ExternalListPrice__c - olis.DiscountAmount__c).setScale(2);
olis.TotalPrice__c = (olis.SalesPrice__c * oli.Quantity).setScale(2);
}*/
                            //make changes to oppy schedules if fiscal is changed of parent oppy products
                            if(mapOLIContractFiscalChanged!=null && mapOLIContractFiscalChanged.containsKey(olis.OpportunityProductID__c) && mapOLIFiscalYear!=null && mapOLIFiscalYear.containsKey(olis.OpportunityProductID__c)) {
                                String OlisPSKey = String.valueOf(olis.Product__c) + mapOLIFiscalYear.get(olis.OpportunityProductID__c) + olis.ProductSchedule__r.Year__c + olis.ProductSchedule__r.ProductTerm__c;
                                if(mapMultiKeyProductSchedule!=null && mapMultiKeyProductSchedule.containsKey(OlisPSKey)) {
                                    
                                    ProductSchedule__c ps = mapMultiKeyProductSchedule.get(OlisPSKey);
                                    olis.ProductSchedule__c = ps.Id;
                                    olis.InstallmentYears__c = ps.InstallmentYear__c;
                                    olis.PriceBookListPrice__c = ps.ListPrice__c; 
                                }
                                
                            }
                            lstOppySchedulesToUpdate.add(olis);    
                        }
                        
                        
                    }
                    
                }
                System.debug('@PD --lstOppySchedulesToUpdate--'+lstOppySchedulesToUpdate);
                if(lstOppySchedulesToUpdate!=null && !lstOppySchedulesToUpdate.isEmpty()) {
                    update lstOppySchedulesToUpdate;
                }
            }
        }
        catch(Exception ex) {
            Database.rollback(sp);
            throw new GenericCustomException ('An Exception Has been caught'+ex.getMessage()); 
        }
        
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 21st July 2018
    // @param: TriggerParameters
    // @description: SFDC1-7060 - Adding validations for auto renew and opening certain fields from editing
    // This method will be called in before update trigger Events.
    // @return: None
    // @modified by: Paras Dhingra
    // @modified date: 16th Aug 2018
    // @modified description: SFDC1-9648 quanity should not be editable on opportunity product layouts
    // 
    // @modified by: Tran-Vu Tran
    // @modified date: 8th Mar 2019
    // @modified description: SFDC-949 Contract Management profile needs rights to update Auto Renewal Oppty Line Item field
    // 
    // @modified by: Tran-Vu Tran
    // @modified date: 8th Mar 2019
    // @modified description: SFDC-701 Sales Ops needs to be able to edit Opportunity Product fields (with appropriate Field Level Security settings)
    //                      on any Sales Stage and for any Opportunity record type, regardless Auto-Renewal or not, and with Auto-Renewal with changes or not
    // @Last Modified By : Harshit Singhal
    // @Last Modified Date: 23 Jul 2020
    // @Last Modified Description: SFDC-3072 Add User Support profile to exclusions wherever Sales Ops or Contract Management checks are already present
    //------------------------------
    public static void oppyProductValidations(TriggerParameters tp) {
        //the trigger will not be called when records updated from add/edit products page
        if(GlobalConstants.disableOppyProductValidations) {
            return;
        }
        //get logged in user profile name
        String profileName = UtilityClass.LoggedInUserProfileName;
        //get all the valid fields on this object
        Map <String, Schema.SobjectField > oppyProductFields = OpportunityLineItem.sObjectType.getDescribe().fields.getMap();
        Set<Id> setOppportunityID = new Set<Id>();
        Map<Id,Opportunity> mapRelatedOpportunity = new Map<Id,Opportunity>();
        //check if user is admin then do not process further
        if (profileName.containsIgnoreCase('System Admin') || profileName.containsIgnoreCase('Sales Ops') || profileName.containsIgnoreCase('User Support') || GlobalConstants.hasEnhancedSalesPermission) { // SFDC-701 allow Sales Ops to edit Opportunity Product fields on any Sales Stage and any record type
            return; // no validation checks are required for system admins, and Sales Ops (with appropriate Field Level Security settings as required in SFDC-701)
        }
        //control reached here not admin
        //iterate through opportunity product and fetch opportunity ids
        for (OpportunityLineItem oli : (List<OpportunityLineItem>) tp.newList) {
            setOppportunityID.add(oli.OpportunityId);
        }
        //query Opportunity records
        mapRelatedOpportunity = new Map<Id,Opportunity>([Select Id, AutoRenewal__c, DoesThisAutoRenewalHaveChanges__c
                                                         from Opportunity where Id IN:setOppportunityID]);
        //fetch custom opportunity validation custom settings
        List<OpportunityValidationFields__c> oppyValidationFields = OpportunityValidationFields__c.getAll().values();
        //Set<String> setHasChangesAPIs = new Set<String>();
        Set<String> setDoesNotHaveChangesAPIs = new Set<String>();
        for(OpportunityValidationFields__c ovf : oppyValidationFields) {
            String apiname = ovf.APIName__c.toLowerCase();
            //commenting out code based on input from Christine. no validations on edit products page when does this auto renewal has changes is 'yes'
            /*
if(ovf.RuleName__c=='AutoRenewHasChangesOppyProduct') {
setHasChangesAPIs.add(apiname);
}
*/
            if (ovf.RuleName__c=='AutoRenewNoChangesOppyProduct') {
                setDoesNotHaveChangesAPIs.add(apiname);
            }
        }
        //iterate opportunity products and process which have auto-renewal opportunity attached
        for (OpportunityLineItem oli : (List<OpportunityLineItem>) tp.newList) {
            Boolean hasError = false;
            Boolean isAllowed = false;
            //not adding null check as opportunityId will always be populated
            Opportunity oppy = mapRelatedOpportunity.get(oli.OpportunityId);
            OpportunityLineItem oldOppyProduct = (OpportunityLineItem)tp.oldMap.get(oli.Id);
            //check if the oppy is valid for validations
            if (oppy.AutoRenewal__c == true) {
                //check profile level checks
                if (profileName.containsIgnoreCase('General') 
                    || profileName.containsIgnoreCase('Sales Coordinator')
                    || profileName.containsIgnoreCase('Contract Management') // SFDC-949 allow Contract Management profile to update Auto Renewal Oppty Line Item field
                    || profileName.containsIgnoreCase('User Support')
                   ) {
                       isAllowed=true;
                   }
                if (!isAllowed) {
                    //not allowed to edit the opportunity product
                    oli.addError(System.Label.AutoRenewOppyProductError);
                    //no further processing required on this oppy product record skip the iteration
                    continue;
                }
                for (string fieldName : oppyProductFields.keySet()) {
                    Schema.DescribeFieldResult dfr = oppyProductFields.get(fieldName).getDescribe();
                    if (oldOppyProduct.get(fieldName)!=oli.get(fieldName) && !dfr.IsCalculated()) {
                        //locked field edited
                        //commenting out code based on input from Christine. no validations on edit products page when does this auto renewal has changes is 'yes'
                        /*
if(oppy.DoesThisAutoRenewalHaveChanges__c && !setHasChangesAPIs.contains(fieldName)) {
//rule specific custom message can be added later 
System.debug('@PD--Error Field--'+fieldName);
hasError = true;
break;
}
*/
                        if(!oppy.DoesThisAutoRenewalHaveChanges__c && !setDoesNotHaveChangesAPIs.contains(fieldName)) {
                            //rule specific custom message can be added later on
                            System.debug('@PD--Error Field2--'+fieldName);
                            hasError = true;
                            break;
                        }
                    }
                }
                
            }
            if(hasError) {                
                oli.addError(System.Label.AutoRenewOppyProductError);
            }
            //adding code for quantity change check
            if(oli.Quantity!=oldOppyProduct.Quantity) {
                oli.addError(System.Label.OppyProductQuantityError);
            }
            
        }
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 25th July 2019
    // @param: TriggerParameters
    // @description: SFDC-1646 Default product owner field on update to opportunity owner
    // @return: None
    //----------------------------
    public static void setDefaultProductOwner(TriggerParameters tp) {
        //the trigger will run on insert and update is the product owner is blank on the opportunity product
        Set<Id> setOpportunityId = new Set<Id>();
        List<OpportunityLineItem> lstOLIToUpdate = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli : (List<OpportunityLineItem>) tp.newList) {
            if(oli.ProductOwner__c == null) {
                setOpportunityId.add(oli.OpportunityId);
                lstOLIToUpdate.add(oli);
            }
        }
        if(setOpportunityId!=null && !setOpportunityId.isEmpty()) {
            Map<Id,Opportunity> mapOpportunityOwner = new Map<Id,Opportunity>([SELECT 
                                                                               Id,OwnerId 
                                                                               FROM
                                                                               Opportunity
                                                                               WHERE 
                                                                               Id IN: setOpportunityId]);
            for(OpportunityLineItem oli: lstOLIToUpdate) {
                oli.ProductOwner__c = mapOpportunityOwner.get(oli.OpportunityId).OwnerId;
            }
        }
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Jan 2020
    // @param: TriggerParameters
    // @description: SFDC-2417 Moved inner year opp validations to code to skip them during oppy product cascade updates.
    // @return: None
    //----------------------------
    public static void innerYearOppyProductValidations(TriggerParameters tp) {
        if(GlobalConstants.disableOppyProductValidations) {
            return;
        }
        if(GlobalConstants.hasInnerYearOLIUpdatePermission || GlobalConstants.hasEnhancedSalesPermission) {
            return;
        }
        String profileName = UtilityClass.LoggedInUserProfileName;
        if (profileName.containsIgnoreCase('System Admin')) {
            return;
        }
        
        Set<Id> setOppportunityID = new Set<Id>();
        Map<Id,Opportunity> mapRelatedOpportunity = new Map<Id,Opportunity>();
        
        for (OpportunityLineItem oli : (List<OpportunityLineItem>) tp.newList) {
            setOppportunityID.add(oli.OpportunityId);
        }
        if(setOppportunityID.size() > 0) {
            mapRelatedOpportunity = new Map<Id,Opportunity>([SELECT Id, Opportunity.RecordTypeId FROM Opportunity WHERE Id IN :setOppportunityID]);
        }
        Id innerYearRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inner Year').getRecordTypeId();
        for (OpportunityLineItem oli : (List<OpportunityLineItem>) tp.newList) {
            if(mapRelatedOpportunity.containsKey(oli.OpportunityId) && mapRelatedOpportunity.get(oli.OpportunityId).RecordTypeId==innerYearRecTypeId) {
                oli.addError(System.Label.InnerYearOppProdValidationMsg);
            }
        }
        
    }
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 14 February 2020
    // @param: TriggerParameters
    // @description: SFDC-2669 Cascade status changes to Opportunity Product Schedules
    // @return: None
    //----------------------------
    public static void updateSchedulesOnStatusChange(TriggerParameters tp) {
        Set<Id> oppyProductChanges = new Set<Id>();
        List<OpportunityLineItemSchedule__c> olisForUpdation = new List<OpportunityLineItemSchedule__c>();
        for(OpportunityLineItem Oli : (List<OpportunityLineItem>) tp.newList) {
            if(Oli.Status__c != ((OpportunityLineItem) tp.oldMap.get(Oli.id)).status__c) {
                oppyProductChanges.add(oli.id);
            }
        }
        
        if(oppyProductChanges != null && oppyProductChanges.size() > 0) {
            List<OpportunityLineItemSchedule__c> olisList = [Select status__c, opportunityProductId__c from 
                                                             OpportunityLineItemSchedule__c where OpportunityProductId__c  in :oppyProductChanges];
            for(OpportunityLineItemSchedule__c olis : olisList) {
                OpportunityLineItem newOli = (OpportunityLineItem) tp.newMap.get(olis.OpportunityProductID__c);
                if(olis.Status__c != newOli.status__c ) {
                    olis.Status__c = newOli.Status__c;
                    olisForUpdation.add(olis);
                }
            }
            
            if(olisForUpdation!= null && olisForUpdation.size() > 0) {
                GlobalConstants.runRollupOpportunityLineItemSchedule = true;
                update olisForUpdation;
                GlobalConstants.runRollupOpportunityLineItemSchedule = false;
            }
            
        }
    }
    
    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 19 February 2020
    // @param: TriggerParameters
    // @description: SFDC-1777 Add Product Owner and SME to Opportunity team.
    // @return: None
    // 
    // @modified by: Dev Aggarwal
    // @modified date: 3 March 2020
    // @modified description: SFDC-2743- Added code to avoid deleletion of team member if user exists in Splits.
    //----------------------------
    public static void updateOpportunityTeamsforPOAndSME(TriggerParameters tp) {
        List<OpportunityTeamMember> teamsForInsertion = new List<OpportunityTeamMember>();
        List<OpportunityTeamMember> teamsForDeletion = new List<OpportunityTeamMember>();
        Map<Id, OpportunityLineItem> oldMap = (Map<Id,OpportunityLineItem>) tp.oldMap;
        Map<Id,OpportunityLineItem> newMap = (Map<ID,OpportunityLineItem>) tp.newMap;
        List<OpportunityLineItem> DeletionListPO = new List<OpportunityLineItem>();
        List<OpportunityLineItem> InsertionListPO = new List<OpportunityLineItem>();
        List<OpportunityLineItem> DeletionListSME = new List<OpportunityLineItem>();
        List<OpportunityLineItem> InsertionListSME = new List<OpportunityLineItem>();
        Map<String, OpportunityTeamMember> OppyIdAndUserId = new Map<String, OpportunityTeamMember>();
        Set<String> OppyProductUserPO = new Set<String>();
        Set<String> OppyProductUserSME = new Set<String>();
        Set<String> SplitSet = new Set<String>();
        
        Map<Id,Opportunity> mapOpptyAndTeam;
        Set<Id> OpptyIds = new Set<ID>();
        
        for(OpportunityLineItem newOli : newMap.values()) {
            OpportunityLineItem oldOli = new OpportunityLineItem();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                oldOli = oldMap.get(newOli.id);
            }
            // Product Owner Updates 
            if(!String.isBlank(newOli.ProductOwner__c) && !String.isBlank(oldOli.ProductOwner__c) && newOli.ProductOwner__c != oldOli.ProductOwner__c) {
                InsertionListPO.add(newOli);
                DeletionListPO.add(oldOli);
                OpptyIds.add(newOli.OpportunityId);         
            }
            if(!String.isBlank(newOli.ProductOwner__c) && String.isBlank(oldOli.ProductOwner__c)) {
                InsertionListPO.add(newOli);
                OpptyIds.add(newOli.OpportunityId);
            }
            if(String.isBlank(newOli.ProductOwner__c) && !String.isBlank(oldOli.ProductOwner__c)) {
                DeletionListPO.add(oldOli);
                OpptyIds.add(newOli.OpportunityId);
            }
            // SME Field
            if(!String.isBlank(newOli.SME__c) && !String.isBlank(oldOli.SME__c) && newOli.SME__c != oldOli.SME__c) {
                insertionListSME.add(newOli);
                deletionListSME.add(oldOli);
                OpptyIds.add(newOli.OpportunityId);                 
            }
            if(!String.isBlank(newOli.SME__c) && String.isBlank(oldOli.SME__c)) {
                
                insertionListSME.add(newOli);
                OpptyIds.add(newOli.OpportunityId);
            }
            if(String.isBlank(newOli.SME__c) && !String.isBlank(oldOli.SME__c)) {
                deletionListSME.add(oldOli);
                OpptyIds.add(newOli.OpportunityId);
            }    
        }
        if(OpptyIds.size() > 0) {
            mapOpptyAndTeam = new Map<Id,Opportunity>([Select Id, OwnerId,GAM__c, (Select Id,TeamMemberRole,UserId,OpportunityId from OpportunityTeamMembers),
                                                       (Select Product2ID, OpportunityId, ProductOwner__c, SME__c from OpportunityLineItems),
                                                       (Select opportunityId, SplitOwnerId from OpportunitySplits)
                                                       from Opportunity where id in :opptyIds]);
            // These maps will helping in ensuring that we dont insert duplicate team members 
            // will also help in deciding on which records should be deleted.
            for(Opportunity oppty : mapOpptyAndTeam.values()) {
                for(OpportunityTeamMember otm : oppty.opportunityTeamMembers) {
                    OppyIdAndUserId.put('' + otm.OpportunityId + otm.UserId, otm);
                }
                for(OpportunityLineItem oppyProd : oppty.OpportunityLineItems) {
                    if(!String.isBlank(oppyProd.ProductOwner__c)) {
                        OppyProductUserPO.add('' + oppyProd.OpportunityId + oppyProd.ProductOwner__c);    
                    }
                    if(!String.isBlank(oppyProd.SME__c)) {
                        OppyProductUserSME.add('' + oppyProd.OpportunityId + oppyProd.SME__c);    
                    }
                    for(OpportunitySplit osplt : oppty.OpportunitySplits) {
                        SplitSet.add('' + osplt.OpportunityId + osplt.SplitOwnerId);
                    }
                }
                
                // Insert PO records here
                for(OpportunityLineItem oli : insertionListPO) {
                    String key ='' + oli.OpportunityId + oli.ProductOwner__c;
                    if(!OppyIdAndUserId.containsKey(key)){
                        teamsForInsertion.add(OpportunityMethods.createOpportunityTeamMember(oli.OpportunityId,oli.ProductOwner__c,'Edit','Product Specialist'));
                        OppyIdAndUserId.put(key, new OpportunityTeamMember(TeamMemberRole = 'Product Specialist'));
                    }
                    else{
                        if(!OppyProductUserSME.contains(key) && OppyIdAndUserId.get(key).TeamMemberRole == 'Subject Matter Expert' ) {
                            teamsForInsertion.add(new OpportunityTeamMember(Id = OppyIdAndUserId.get(key).Id,TeamMemberRole='Product Specialist'));
                            OppyIdAndUserId.put(key, new OpportunityTeamMember(TeamMemberRole = 'Product Specialist'));
                        }
                    }
                }
            }
            // Insert SME records here.
            for(OpportunityLineItem oli : insertionListSME) {
                String key ='' + oli.OpportunityId + oli.SME__c;
                if(!OppyIdAndUserId.containsKey(key)){
                    teamsForInsertion.add(OpportunityMethods.createOpportunityTeamMember(oli.OpportunityId,oli.SME__c,'Edit','Subject Matter Expert'));
                    OppyIdAndUserId.put(key, new OpportunityTeamMember(TeamMemberRole = 'Subject Matter Expert'));
                }
                else{
                    if(!OppyProductUserPO.contains(key) && OppyIdAndUserId.get(key).TeamMemberRole == 'Product Specialist' ) {
                        teamsForInsertion.add(new OpportunityTeamMember(TeamMemberRole = 'Subject Matter Expert', Id = OppyIdAndUserId.get(key).Id));
                        OppyIdAndUserId.put(key, new OpportunityTeamMember(TeamMemberRole = 'Subject Matter Expert'));
                        
                    }
                }
            }
            //Delete PO records here
            for(OpportunityLineItem oli : deletionListPO) {
                String key = '' + oli.opportunityId +  oli.ProductOwner__c;
                if(!OppyProductUserPO.contains(key) && !OppyProductUserSME.contains(key) && mapOpptyAndTeam.get(oli.OpportunityId).ownerId != oli.ProductOwner__c && mapOpptyAndTeam.get(oli.OpportunityId).GAM__c != oli.ProductOwner__c && !SplitSet.contains(key)) {
                    if(OppyIdAndUserId.containsKey(key) && !String.isBlank(OppyIdAndUserId.get(key).Id) && OpportunityMethods.isOpportunityOwnerChanged==false) {
                        teamsForDeletion.add(new OpportunityTeamMember(Id=OppyIdAndUserId.get(key).Id));
                        OppyIdAndUserId.remove(key);
                    }
                }
                else if (!OppyProductUserPO.contains(key) && OppyProductUserSME.contains(key) && mapOpptyAndTeam.get(oli.OpportunityId).ownerId != oli.ProductOwner__c && mapOpptyAndTeam.get(oli.OpportunityId).GAM__c != oli.ProductOwner__c && !SplitSet.contains(key)) {
                    if(OppyIdAndUserId.containsKey(key) && !String.isBlank(OppyIdAndUserId.get(key).Id)) {
                        teamsForInsertion.add(new OpportunityTeamMember(Id=OppyIdAndUserId.get(key).Id, TeamMemberRole = 'Subject Matter Expert' ));    
                        OppyIdAndUserId.put(key, new OpportunityTeamMember(TeamMemberRole = 'Subject Matter Expert'));
                    }
                }
            }
            //Delete SME records here
            for(OpportunityLineItem oli : deletionListSME) {
                String key = '' + oli.opportunityId + oli.SME__c;
                if(!OppyProductUserSME.contains(key) && !OppyProductUserPO.contains(key) && mapOpptyAndTeam.get(oli.OpportunityId).ownerId != oli.SME__c && mapOpptyAndTeam.get(oli.OpportunityId).GAM__c != oli.SME__c && !SplitSet.contains(key)) {
                    if(OppyIdAndUserId.containsKey(key) && !String.isBlank(OppyIdAndUserId.get(key).Id) && OpportunityMethods.isOpportunityOwnerChanged==false) {
                        teamsForDeletion.add(new OpportunityTeamMember(Id=OppyIdAndUserId.get(key).Id));
                        OppyIdAndUserId.remove(key);
                    }
                }
                else if(!OppyProductUserSME.contains(key) && OppyProductUserPO.contains(key) && mapOpptyAndTeam.get(oli.OpportunityId).ownerId != oli.SME__c && mapOpptyAndTeam.get(oli.OpportunityId).GAM__c != oli.SME__c && !SplitSet.contains(key)) {
                    system.debug('Here');
                    if(OppyIdAndUserId.containsKey(key) && !String.isBlank(OppyIdAndUserId.get(key).Id)) {
                        teamsForInsertion.add(new OpportunityTeamMember(Id=OppyIdAndUserId.get(key).Id, TeamMemberRole = 'Product Specialist' ));    
                        OppyIdAndUserId.put(key, new OpportunityTeamMember(TeamMemberRole = 'Product Specialist'));
                    }
                }
            }
            
            if(teamsForInsertion.size() > 0) {
                insert teamsForInsertion;
            }
            if(teamsForDeletion.size() > 0) {
                delete teamsForDeletion;
            }
            
        }
    }
    
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 12 March 2020
    // @param: TriggerParameters
    // @description: SFDC-3918 Mark Risk Status to Open when 'Is Product At Risk' moved from No to YES.
    //               Clear all Risk fields when 'Is Product At Risk' is changed to No.               
    // @return: None
    //----------------------------
    public static void updateRiskStatus(TriggerParameters tp) {
        
        if ((tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate)
            && !CloneOpportunityWithProducts.IsOppyProdBeingCloned) {
                
                for(OpportunityLineItem Oli : (List<OpportunityLineItem>) tp.newList) {               
                    
                    if(Oli.IsProductatRisk__c == 'Yes' &&  (tp.oldMap == null || Oli.IsProductatRisk__c != ((OpportunityLineItem) tp.oldMap.get(Oli.id)).IsProductatRisk__c)) {
                        Oli.RiskStatus__c = 'Open - Pending Resolution';
                        if (Oli.EstimatedValueatRisk__c == null) { 
                            Oli.EstimatedValueatRisk__c = Oli.PriorYearTotalSalesPrice__c;//Oli.AnnualizedTotalAmount__c;
                        }
                    }
                    
                    if(Oli.IsProductatRisk__c == 'Yes' && Oli.Probability__c != null) {
                        Oli.RiskProbability__c = 100 - Oli.Probability__c;
                    }
                    
                    if(Oli.IsProductatRisk__c != 'Yes' &&  (tp.oldMap == null || Oli.IsProductatRisk__c != ((OpportunityLineItem) tp.oldMap.get(Oli.id)).IsProductatRisk__c)) {
                        Oli.RiskStatus__c = '';
                        Oli.EstimatedValueatRisk__c = null;
                        Oli.RiskProbability__c = 0;
                        Oli.RiskComments__c = '';
                    }                 
                }
            }
    }
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 12th April 2021
    // @param: TriggerParameters
    // @description: SFDC-4007 Default Value of 0.00 should show on reports and GUI
    // @return: None
    //----------------------------
    public static void setDefaultParameter(TriggerParameters tp) {
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate){
            for(OpportunityLineItem Oli : (List<OpportunityLineItem>) tp.newList){
                if(Oli.UnitListPrice__c==NULL){
                    Oli.UnitListPrice__c=0.00;
                }
                if(Oli.Discount_Amount__c==NULL){
                    Oli.Discount_Amount__c=0.00;
                } 
                if(Oli.AnnualizedUnitPrice__c==NULL){
                    Oli.AnnualizedUnitPrice__c=0.00;
                }
                if(Oli.AnnualizedDiscountAmount__c==NULL){
                    Oli.AnnualizedDiscountAmount__c=0.00;
                }
                if(Oli.FirstYear__c==NULL){
                    Oli.FirstYear__c=0.00;
                }
                if(Oli.ProRatedUnitPrice__c==NULL){
                    Oli.ProRatedUnitPrice__c=0.00;
                }
                if(Oli.ProRatedDiscountAmount__c==NULL){
                    Oli.ProRatedDiscountAmount__c=0.00;
                }
                if(Oli.PassThroughRoyaltyAnnualValue__c==NULL){
                    Oli.PassThroughRoyaltyAnnualValue__c=0.00;
                }
            }
        }
    }
    
    //-----------------------------
    // @author: Digvijay Singh
    // @date: 28 March 2022
    // @param: TriggerParameters tp
    // @description: SFDC-5600,Method to populate Synergy Theme and Type on Opporunity Line Item 
    //----------------------------
    public static void populateSynergyTypeandTheme(TriggerParameters tp) {
        List<OpportunityLineItem> listopportunityLineItem=new List<OpportunityLineItem>();
        for(OpportunityLineItem Oli : (List<OpportunityLineItem>) tp.newList) {  
            listopportunityLineItem.add(oli);                  
        }
        
        populateSynergyTypeandTheme(listopportunityLineItem,true);
        
    }
    
    
    //-----------------------------
    // @author: Digvijay Singh
    // @date: 11 Nov 2021
    // @param: TriggerParameters tp
    // @description: SFDC-4820,Method to populate Synergy Theme and Type on Opporunity Line Item 
    // @date: 02 Mar 2022
    // @description: SFDC-5474, Added criteria to populate only when synergy theme and type is blank            
    // @return: None
    // @Modifiedby : Digvijay Singh
    // @date :28 March 2022
    // @description : SFDC-5600,updated code to call snergy calculation logic conditionally on oppty update 
    //----------------------------
    public static List<Sobject> populateSynergyTypeandTheme(List<OpportunityLineItem> newList,Boolean IsInsert) {
        
        List<Sobject> lstlineItems=new List<Sobject>();
        List<Id> lstProductId=new List<id>(); 
        Set<Id> setOpportunityIds=new Set<Id>();
        List<OpportunityLineItem> oliList= new List<OpportunityLineItem>();
        Map<Id,Opportunity> mapIdtoOpportunity=new Map<Id,Opportunity>();
        Map<Id,Account> mapIdtoAccount=new Map<Id,Account>();
        Map<Id,SubBusinessLine__c> mapIdtoSubusinessLine=new Map<Id,SubBusinessLine__c>();
        Map<Id,BusinessLine__c> mapIdtoBusinessLine=new Map<Id,BusinessLine__c>();
        Map<Id,ProductGroup__c> mapIdtoProductGroup=new Map<Id,ProductGroup__c>();
        Map<Id,Family__c> mapIdtoProductFamily=new Map<Id,Family__c>();
        Map<Id,Product2> mapIdtoProduct=new Map<Id,Product2>();
        Map<String ,Map<Id,sobject>> mapofrelatedData=new Map<String, Map<Id,sobject>>();
        
        
        //filter out the synergy Opportunities
        if (newList!=null && !newList.IsEmpty()) {
            
            for(OpportunityLineItem Oli : newList) {  
                setOpportunityIds.add(oli.OpportunityId);                  
            }
            
            for(Opportunity opp : [Select Id,Synergy1__c, Synergy__c,RecordType.Name ,Account.AccountRegion__c, AccountId,toLabel(Account.ExternalOrgType__c)
                                   from Opportunity where Id IN: setOpportunityIds ]) {
                                       if(opp.Synergy1__c=='Yes') {
                                           mapIdtoOpportunity.put(opp.Id, opp);
                                       }
                                   }
            
            for(OpportunityLineItem Oli : newList) {  
                if(String.isBlank(Oli.SynergyType__c) && String.isBlank(Oli.SynergyTheme__c) 
                   && mapIdtoOpportunity.ContainsKey(oli.OpportunityId)) {
                       
                       Opportunity oppobj=mapIdtoOpportunity.get(oli.OpportunityId);
                       if(oppobj!=null && !(oli.Status__c=='Existing'&& oppobj.RecordType.Name=='Renewal')) {
                           oliList.add(oli); 
                       }                         
                   }                   
            }
        }
        
        //prepare the account map
        if(!mapIdtoOpportunity.IsEmpty()) {
            for(OpportunityLineItem Oli : oliList) {
                if(mapIdtoOpportunity.ContainsKey(oli.OpportunityId)) {
                    lstProductId.add(oli.Product2Id);
                    Opportunity oppty=mapIdtoOpportunity.get(oli.OpportunityId);
                    Account aobj=oppty.Account;//new Account(Id=oppty.AccountId,ExternalOrgType__c=oppty.Account.ExternalOrgType__c,AccountRegion__c=oppty.Account.AccountRegion__c);
                    if(IsInsert) {
                        mapIdtoAccount.put(oli.Product2Id , aobj);
                    }else {
                        mapIdtoAccount.put(oli.Id , aobj);
                    }
                }
            }
        }
        
        //prepare the Sub business Line ,Product group , product,product family map
        Map<ID, Product2> mapProductrecs = new Map<ID, Product2>([Select Id ,Name,Division__c ,MaterialCode__c , BusinessLine2__c,BusinessLine2__r.Name, SubBusinessLine__c,SubBusinessLine__r.Name,ProductGroup__c,ProductGroup__r.Name,Family__c,Family__r.Name from Product2 where Id IN :lstProductId]);
        for(OpportunityLineItem Oli : oliList) {
            if(mapProductrecs.ContainsKey(Oli.Product2ID)) {
                Product2 pobj=mapProductrecs.get(Oli.Product2ID);
                SubBusinessLine__c sbobj;
                BusinessLine__c bobj;
                ProductGroup__c pgobj;
                Family__c   familyobj;
                familyobj=pobj.Family__r;
                
                if(pobj.SubBusinessLine__c!=null) {
                    sbobj=new SubBusinessLine__c(Id=pobj.SubBusinessLine__c, Name=pobj.SubBusinessLine__r.Name);
                }
                if(pobj.BusinessLine2__c!=null) {
                    bobj=new BusinessLine__c(Id=pobj.BusinessLine2__c, Name=pobj.BusinessLine2__r.Name);
                }
                if(pobj.ProductGroup__c!=null) {
                    pgobj=new ProductGroup__c(Id=pobj.ProductGroup__c,Name=pobj.ProductGroup__r.Name);
                }
                
                if(IsInsert) {
                    mapIdtoSubusinessLine.put(oli.Product2Id , sbobj);
                    mapIdtoProductGroup.put(oli.Product2Id , pgobj);
                    mapIdtoProduct.put(oli.Product2Id,pobj);
                    mapIdtoProductFamily.put(oli.Product2Id,familyobj);
                    mapIdtoBusinessLine.put(oli.Product2Id , bobj);
                }else {  
                    mapIdtoSubusinessLine.put(oli.Id , sbobj);
                    mapIdtoProductGroup.put(oli.Id , pgobj);
                    mapIdtoProduct.put(oli.Id,pobj);
                    mapIdtoProductFamily.put(oli.Id,familyobj);
                    mapIdtoBusinessLine.put(oli.Id , bobj);
                }
            }
        }
        //create a map of map which contains all the related data required by the rule engine
        if(!mapIdtoOpportunity.isEmpty()) {
            mapofrelatedData.put('SubBusinessLine__c',mapIdtoSubusinessLine);
            mapofrelatedData.put('BusinessLine__c',mapIdtoBusinessLine);
            mapofrelatedData.put('ProductGroup__c',mapIdtoProductGroup);
            mapofrelatedData.put('Account',mapIdtoAccount);
            mapofrelatedData.put('Product2',mapIdtoProduct);
            mapofrelatedData.put('Family',mapIdtoProductFamily);
            String key='Id';
            if(IsInsert) {
                key='Product2Id';
            }
            lstlineItems=RuleEngineLogic.runtheBusinessLogic('OpportunityLineItem', 'OpportunityLineItemSynergyRules',oliList,mapofrelatedData,key );
        }
        return lstlineItems;
    }
    
    //----------------------------
    // @author: Rashmeet Gandhi
    // @date: 28th April,2023
    // @param: TriggerParameters
    // @description: US-5856761 : Opportunity - Mobility Metrics Section - Lost Sales 
    // @return: none
    //----------------------------
    /* public static void priorYearValueCalculation(TriggerParameters tp){
Set<Id> setOppyID = new Set<Id>();
List<OpportunityLineItem> lstOLIUpdated = new List<OpportunityLineItem>();
Map<Id,Decimal> oppIdPriorYearValueSum = new Map<Id, Decimal>();
Map<Id,Decimal> oppIdPriorYearValueSumSub = new Map<Id, Decimal>();
Map<String,List<DatedConversionRate>> mapOfDatedConversionrate = UtilityClass.isoCurrencyDatedConversionRate;
Decimal conversionRateYearly;
Decimal PriorYearTotalFirstYearValueInUS = 0.0;
Decimal PriorYearTotalFirstYearValueSub = 0.0;
List<Opportunity> lstOpportunityToBeUpdated = new List<Opportunity>();
if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ||
tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
lstOLIUpdated = tp.newList;
}
if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) { 
lstOLIUpdated = tp.oldList;
}
for(OpportunityLineItem oli : lstOLIUpdated) {
setOppyID.add(oli.OpportunityId);
}
//Query Opportunity Ids for which Query was updated.
List<Opportunity> lstOppyToUpdate = [Select id,PreviousFiscalYearOpportunityLink__c,FirstYearValue__c, CurrencyIsoCode,ContractStartDate__c,
(select Id,Product2Id,OpportunityId,Product2.AAG__c, Status__c, FirstYear__c
from OpportunityLineItems),
(select id, OpportunityProductID__c from OpportunityProductSchedules__r where Status__c!='Lost' )
from Opportunity where ID IN:setOppyID];




System.debug('--lstOppyToUpdate--'+lstOppyToUpdate);
if(lstOppyToUpdate!=null && !lstOppyToUpdate.isEmpty()) {
for(Opportunity oppy : lstOppyToUpdate) {
for(OpportunityLineItem oli: oppy.OpportunityLineItems) {
if(oli.FirstYear__c!=null && oli.Status__c != 'Lost') {

PriorYearTotalFirstYearValueInUS += oli.FirstYear__c;
oppIdPriorYearValueSum.put(oppy.id,PriorYearTotalFirstYearValueInUS);
system.debug('oppIdPriorYearValueSum ===> ' +oppIdPriorYearValueSum);
if(oli.Product2.AAG__c == 'Subscription'){
PriorYearTotalFirstYearValueSub += oli.FirstYear__c;
oppIdPriorYearValueSumSub.put(oppy.id,PriorYearTotalFirstYearValueSub);
System.debug('oppIdPriorYearValueSumSub ===> ' +oppIdPriorYearValueSumSub);
}
}
}
}

}
List<Opportunity> lstCurrentYearOpp = new List<Opportunity>([SELECT id,CurrencyIsoCode, ContractStartDate__c, PreviousFiscalYearOpportunityLink__c from Opportunity where PreviousFiscalYearOpportunityLink__c in : oppIdPriorYearValueSumSub.keySet()]);
system.debug('lstCurrentYearOpp ===> ' +lstCurrentYearOpp);
for(Opportunity opp : lstCurrentYearOpp){

//FX rates of current year opp 
if(mapOfDatedConversionrate!= null){
if(mapOfDatedConversionrate.keySet().contains(opp.CurrencyIsoCode)){
List<DatedConversionRate> listOfMatchedOppyCurrency = mapOfDatedConversionrate.get(opp.CurrencyIsoCode);
//  system.debug('listOfMatchedOppyCurrency'+listOfMatchedOppyCurrency);
for(DatedConversionRate checkMultiYear : listOfMatchedOppyCurrency){
if(checkMultiYear != null && opp.ContractStartDate__c != null && checkMultiYear.StartDate.year() == opp.ContractStartDate__c.year()){
conversionRateYearly = checkMultiYear.ConversionRate;
break;
}
else{
conversionRateYearly = listOfMatchedOppyCurrency[0].ConversionRate;
}
system.debug('conversionRateYearly ===> ' +conversionRateYearly);
}
}
}

//adding prior year values to current year opp
system.debug('oppIdPriorYearValueSum ===> ' +oppIdPriorYearValueSum);
system.debug('oppIdPriorYearValueSumSub ===> ' +oppIdPriorYearValueSumSub);
if(oppIdPriorYearValueSum.containsKey(opp.PreviousFiscalYearOpportunityLink__c)){
opp.PriorYearTotalFirstYearValue__c = oppIdPriorYearValueSum.get(opp.PreviousFiscalYearOpportunityLink__c)/conversionRateYearly;
system.debug('opp.PriorYearTotalFirstYearValue__c ===> ' +opp.PriorYearTotalFirstYearValue__c);

}
if(oppIdPriorYearValueSumSub.containsKey(opp.PreviousFiscalYearOpportunityLink__c)){
opp.PriorYearTotalFirstYearValueSub__c = oppIdPriorYearValueSumSub.get(opp.PreviousFiscalYearOpportunityLink__c)/conversionRateYearly;
system.debug('opp.PriorYearTotalFirstYearValueSub__c ===> ' +opp.PriorYearTotalFirstYearValueSub__c);
}
system.debug('opp ====> ' +opp);
lstOpportunityToBeUpdated.add(opp);
system.debug('lstOpportunityToBeUpdated ===> ' +lstOpportunityToBeUpdated);

if(lstOpportunityToBeUpdated!=null && !lstOpportunityToBeUpdated.isEmpty()) {
//prevent validations from rollup
GlobalConstants.hasTriggeredFromOpportunityProduct = true;
update lstOpportunityToBeUpdated;
}

}

} */
    
    //----------------------------
    // @author: Kanika Miglani
    // @date: 18th April,2023
    // @param: TriggerParameters
    // @description: US-5856761 : Opportunity - Mobility Metrics Section - Lost Sales 
    // @return: none
    //----------------------------
    /*public static void mobilityMetricsCalculation(TriggerParameters tp){
Set<Id> setOppyID = new Set<Id>();
List<OpportunityLineItem> lstOLIUpdated = new List<OpportunityLineItem>();
List<Opportunity> listofOppyToUpdate = new List<Opportunity>();
Map<String,List<DatedConversionRate>> mapOfDatedConversionrate = new Map<String,List<DatedConversionRate>>();
List<DatedConversionRate> listISODatedConversionRate = new List<DatedConversionRate>();
List<Opportunity> lstOpportunityToBeUpdated = new List<Opportunity>();

if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ||
tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
lstOLIUpdated = tp.newList;
}
if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) { 
lstOLIUpdated = tp.oldList;
}
for(OpportunityLineItem oli : lstOLIUpdated) {
setOppyID.add(oli.OpportunityId);
}
//Query Opportunity Ids for which Query was updated.
List<Opportunity> lstOppyToUpdate = [Select id, FirstYearValue__c, MultiYear__c,SalesLostSubOnly__c,SalesLosttransonly__c,CurrencyIsoCode,ContractStartDate__c,
(select Id,Product2.AAG__c, Status__c, FirstYear__c from OpportunityLineItems where Status__c = 'Lost') from Opportunity where ID IN:setOppyID];  
System.debug('--lstOppyToUpdate--'+lstOppyToUpdate);

if(lstOppyToUpdate!=null && !lstOppyToUpdate.isEmpty()){

Decimal conversionRateYearly; 
//Query all dated conversion rates
for(DatedConversionRate yearConversionFiscalRate : [Select Id, IsoCode, StartDate, NextStartDate, ConversionRate from DatedConversionRate order by IsoCode, StartDate desc]){
if(mapOfDatedConversionrate.containsKey(yearConversionFiscalRate.IsoCode)){ 
mapOfDatedConversionrate.get(yearConversionFiscalRate.IsoCode).add(yearConversionFiscalRate);
}
else{
listISODatedConversionRate = new List<DatedConversionRate>();
listISODatedConversionRate.add(yearConversionFiscalRate);
mapOfDatedConversionrate.put(yearConversionFiscalRate.IsoCode, listISODatedConversionRate);
}
} 

for(Opportunity oppy : lstOppyToUpdate) {
Opportunity oppyToUpdate = new Opportunity(Id= oppy.id);
oppyToUpdate.SalesLostSubOnly__c = 0.0;
oppyToUpdate.SalesLosttransonly__c = 0.0;
if(mapOfDatedConversionrate!= null){
if(mapOfDatedConversionrate.keySet().contains(oppy.CurrencyIsoCode)){
List<DatedConversionRate> listOfMatchedOppyCurrency = mapOfDatedConversionrate.get(oppy.CurrencyIsoCode);
system.debug('listOfMatchedOppyCurrency'+listOfMatchedOppyCurrency);
for(DatedConversionRate checkMultiYear : listOfMatchedOppyCurrency){
if(checkMultiYear != null && oppy.ContractStartDate__c != null && checkMultiYear.StartDate.year() == oppy.ContractStartDate__c.year()){
conversionRateYearly = checkMultiYear.ConversionRate;
break;
}
else{
conversionRateYearly = listOfMatchedOppyCurrency[0].ConversionRate;
}
}
}
}
for(OpportunityLineItem oli : oppy.OpportunityLineItems){
if(oli.Status__c == 'Lost' && oli.FirstYear__c != null && oli.Product2.AAG__c == 'Subscription'){
oppyToUpdate.SalesLostSubOnly__c += oli.FirstYear__c * conversionRateYearly;
}
if(oli.Status__c == 'Lost' && oli.FirstYear__c != null && oli.Product2.AAG__c == 'Transaction'){
oppyToUpdate.SalesLosttransonly__c += oli.FirstYear__c * conversionRateYearly;
}
}
lstOpportunityToBeUpdated.add(oppyToUpdate);
}
}
if(lstOpportunityToBeUpdated!=null && !lstOpportunityToBeUpdated.isEmpty()) {
update lstOpportunityToBeUpdated;
}
}*/
    
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 10 Apr 2022
    // @param: TriggerParameters
    // @description: SFDC-5699 : Update rollup information from Global Segment/Integnal Business Segment to CIDivision on Opportunity
    // @return: None
    // @Modifiedby : Digvijay Singh
    // @date :22 April 2022
    // @description : SFDC-5721,Added static boolean "hasrollupProductInfoToOpportunityCICompleted" to stop multiple iteration of method causing 
    // SOQL 101 Error.
    //------------------------------    
    /* public static void rollupProductInfoToOpportunityCI(TriggerParameters tp) {

//SFDC-5721
if(!GlobalVariables.hasrollupProductInfoToOpportunityCICompleted || tp.tEvent == TriggerParameters.TriggerEvent.afterInsert || tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
Set<Id> setOpportunityIds = new Set<Id>();
Map<Id,List<OpportunityLineItem>> mapOppyIdOppyLineItem= new Map<Id,List<OpportunityLineItem>>();
List<OpportunityLineItem> opptyLineItemList= new List<OpportunityLineItem>();
List<Opportunity> lstOppy = new List<Opportunity>();
List<Opportunity> UpdateOppyList=new List<Opportunity>();
if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert
|| tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate
|| tp.tEvent == TriggerParameters.TriggerEvent.afterUndelete) {
for (OpportunityLineItem oli: (List<OpportunityLineItem>) tp.newList) {
setOpportunityIds.add(oli.OpportunityId);
}
}
if (tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
for (OpportunityLineItem oli: (List<OpportunityLineItem>) tp.oldList) {
setOpportunityIds.add(oli.OpportunityId);
}           
}

if(!setOpportunityIds.isEmpty()) {
lstOppy = [Select Id, CIDivision__c from opportunity where Id in: setOpportunityIds ];
opptyLineItemList = [Select Id, OpportunityId,PricebookEntry.Product2.Division__c,
PricebookEntry.Product2.InternalBusinessSegment__c
from OpportunityLineItem where OpportunityId in: setOpportunityIds and Status__c!='Lost'];
}
for (OpportunityLineItem opptyLineItems :opptyLineItemList)
{                
List<OpportunityLineItem> opptyLineItemsList = mapOppyIdOppyLineItem.get(opptyLineItems.OpportunityId);
if (opptyLineItemsList == null) {
opptyLineItemsList = new List<OpportunityLineItem>();
}
opptyLineItemsList.add(opptyLineItems);
mapOppyIdOppyLineItem.put(opptyLineItems.OpportunityId,opptyLineItemsList);
}
For(Opportunity oppy:lstOppy) {
Set<String> CIDivision = new Set<String>(); 
List<OpportunityLineItem> opptyLineItems = mapOppyIdOppyLineItem.get(oppy.Id);
if (opptyLineItems != null) {
for (OpportunityLineItem childOlI : opptyLineItems) {
System.debug('InternalBusinessSegment__c' + childOlI.PriceBookEntry.Product2.InternalBusinessSegment__c);
System.debug('Division__c' + childOlI.PriceBookEntry.Product2.Division__c);
if(childOlI.PriceBookEntry.Product2.InternalBusinessSegment__c =='Issuer Solutions & Global Insights' || childOlI.PriceBookEntry.Product2.InternalBusinessSegment__c=='Maritime Trade') {
CIDivision.add('Financial Services'); 
} 
else if(childOlI.PriceBookEntry.Product2.Division__c =='Financial Services' ||childOlI.PriceBookEntry.Product2.Division__c=='Financial Svcs-Info' ) {
CIDivision.add('Financial Services'); 
}
else if(childOlI.PriceBookEntry.Product2.Division__c =='Consolidated Markets & Solutions') {
CIDivision.add('Engineering Solutions'); 
}
else if(childOlI.PriceBookEntry.Product2.Division__c =='Transportation') {
CIDivision.add('Mobility');
}
else if(childOlI.PriceBookEntry.Product2.Division__c =='Resources') {
CIDivision.add('ENR');
}
} 
}
else {
if(!String.isEmpty(Oppy.CIDivision__c)) {
Oppy.CIDivision__c='';
UpdateOppyList.add(oppy);
}
}
if(CIDivision.size()>0) {
List<String> CIDivisionList = new List<String>(CIDivision);
CIDivisionList.sort();
String CIDivisionValue = String.join(CIDivisionList,',');
if(oppy.CIDivision__c !=CIDivisionValue) {
oppy.CIDivision__c=CIDivisionValue; 
UpdateOppyList.add(oppy);
} 
}
}
try {
if (!UpdateOppyList.isEmpty()) {
update UpdateOppyList;
} 
}
catch(Exception ex) {
ApexLogger.logandAddError(new LogMessage('OpportunityLineItemMethods','rollupProductInfoToOpportunityCI',ex,tp.newList.get(0),null )); 
}   
}
//SFDC-5721
GlobalVariables.hasrollupProductInfoToOpportunityCICompleted=true;      
} */
    
}