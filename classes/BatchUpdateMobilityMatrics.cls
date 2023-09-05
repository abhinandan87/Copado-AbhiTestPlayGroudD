//@author: Arshad Qureshi
// @date: 5th May 2023
// @description: Batch apex to update the Mobility Matrices on opportunity reporting since FY 2021.
global class BatchUpdateMobilityMatrics implements Database.Batchable<sobject>, Database.Stateful{
    
    //Failed List
 //   List<Database.Error> err = new List<Database.Error>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {   
        
        String query = 'SELECT id,StageName,BusinessLine__c,CurrencyIsoCode,AverageDiscountPercentage__c,AccountId,CreatedDate,CloseDate,ContractStartDate__c,FirstYearValue__c, DiscountOverThreshold__c, MultiYear__c,ContractBeingRenewed__c,ContractBeingRenewed__r.Opportunity__c,PreviousFiscalYearOpportunityLink__c,Account.DataGovernanceStatus__c,(select Id,Name,Product2Id,OpportunityId,Product2.AAG__c,product2.BusinessLine2__r.name, Status__c, ProductType__c, FirstYear__c, DiscountPercentage__c, DiscountOverThreshold__c,IsProRated__c from OpportunityLineItems where product2.BusinessLine2__r.name=\'Automotive Insights\') FROM Opportunity where PreviousFiscalYearOpportunityLink__c!=null AND (ContractStartDate__c = LAST_N_YEARS:2 OR ContractStartDate__c = THIS_YEAR)';
        return Database.getQueryLocator(query);   
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope)  {  
        try{
            system.debug('scope->'+scope);  
            Map<Id,List<OpportunityLineItem>> previousFiscalOppyWithOLI= new Map<Id,List<OpportunityLineItem>>();
          //  List<Database.Error> err = new List<Database.Error>();
            
            Set<Id> setOppyID = new Set<Id>();
            list<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
            Map<String,List<DatedConversionRate>> mapOfDatedConversionrate = UtilityClass.isoCurrencyDatedConversionRate;
            Decimal conversionRateYearly;
            Decimal conversionRateYearlyForPriorYearPricingCalculation;
            set<Id> setPreviousOppyId= new set<ID>();
            Map<String, List<Id>> previousOppyProduct = new Map<String, List<Id>>();
          //  Decimal PriorYearTotalFirstYearValue = 0.0;
          //  Decimal PriorYearTotalFirstYearValueSub = 0.0;
            Map<Id,Decimal> oppIdPriorYearValueSum = new Map<Id, Decimal>();
            Map<Id,Decimal> oppIdPriorYearValueSumSub = new Map<Id, Decimal>();
            Map<Id, Map<Id, String>> prvOppyProductsStatusMap = new Map<Id, Map<Id, String>>();
            Map<Id, Map<Id,Decimal>> prvOppyProductsFirstYearValueMap = new Map<Id, Map<Id, Decimal>>();
            Map<Id, String> previousOppyProductStatus = new Map<Id, String>();
            Map<Id,Decimal> previousOppyProductFirstYearValue = new Map<Id, Decimal>();
            List<String> lstExcludedProductNames = New List<String>();
            Map<Id, String> previousOppyProductType = new Map<Id, String>();
            Map<Id, Map<Id,String>> prvOppyProductsTypeMap = new Map<Id, Map<Id, String>>();
            
            for(Mobility_Metrics_Excluded_Product_Name__mdt excludedProductName : Mobility_Metrics_Excluded_Product_Name__mdt.getAll().values()){
                lstExcludedProductNames.add('%' + excludedProductName.MasterLabel + '%');
            }
            
            for(Opportunity oppy : Scope){
                if(oppy.BusinessLine__c!=null){
                if((oppy.BusinessLine__c).contains('Automotive Insights')){
                setPreviousOppyId.add(oppy.PreviousFiscalYearOpportunityLink__c);
                setOppyID.add(oppy.Id);
                }
                }
            }
          //  system.debug('setPreviousOppyId-->'+setPreviousOppyId);
            
            List<Opportunity> lstOppyToUpdate = [Select id,PreviousFiscalYearOpportunityLink__c,AverageDiscountPercentage__c,FirstYearValue__c, DiscountOverThreshold__c, MultiYear__c,SalesNewSubscription__c, SalesLostSubOnly__c,MobilitySalesRenewal__c,MobilitySalesNew__c, CurrencyIsoCode,ContractStartDate__c,SalesLosttransonly__c,
                                                 StageName, (select Id,Name,Product2Id,OpportunityId,Product2.AAG__c,product2.BusinessLine2__r.name, Status__c, ProductType__c, FirstYear__c, DiscountPercentage__c, DiscountOverThreshold__c,IsProRated__c
                                                             from OpportunityLineItems)
                                                 from Opportunity where ID IN:setOppyID OR PreviousFiscalYearOpportunityLink__c IN : setOppyID];
            
      //      System.debug('--lstOppyToUpdate--'+lstOppyToUpdate[0].Id);
       //     System.debug('--lstOppyToUpdate--'+lstOppyToUpdate[0].OpportunityLineItems);
            
            //Create previous fiscal year Map
            
            List<Opportunity> lstPreviousFiscalOppy = [Select id,StageName,CurrencyIsoCode,PreviousFiscalYearOpportunityLink__c,AverageDiscountPercentage__c,FirstYearValue__c, DiscountOverThreshold__c, MultiYear__c,ContractBeingRenewed__c,ContractBeingRenewed__r.Opportunity__c,
                                                               (select Id,Name,OpportunityId,FirstYear__c,product2.BusinessLine2__r.name,Product2Id,Product2.AAG__c,DiscountPercentage__c, DiscountOverThreshold__c,IsProRated__c,Status__c, ProductType__c
                                                                from OpportunityLineItems)
                                                               from Opportunity where ID IN:setPreviousOppyId];
                    
            
           // system.debug('lstPreviousFiscalOppy-->'+lstPreviousFiscalOppy);
            if(lstPreviousFiscalOppy!=null && !lstPreviousFiscalOppy.isEmpty()){
                for(Opportunity oppy : lstPreviousFiscalOppy){
                    
                    Decimal PriorYearTotalFirstYearValue = 0.0;
                    Decimal PriorYearTotalFirstYearValueSub = 0.0;
                    previousOppyProductStatus = new Map<Id, String>();
                    previousOppyProductType = new Map<Id, String>();
                    previousOppyProductFirstYearValue = new Map<Id, Decimal>();
                    
                    for(OpportunityLineItem oli: oppy.opportunityLineItems){
                        if(previousFiscalOppyWithOLI.containsKey(oppy.Id)){
                            previousFiscalOppyWithOLI.get(oppy.Id).add(oli);
                            system.debug('previousFiscalOppyWithOLI'+previousFiscalOppyWithOLI);
                            
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
                system.debug('previousFiscalOppyWithOLI'+previousFiscalOppyWithOLI);
            }				
            
            //----
            
            //Rolling up Line items
            
            for(Opportunity oppy : lstOppyToUpdate) {
                Opportunity oppyToUpdate = new Opportunity(Id=oppy.Id);
               
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
                
                // Fetch Conversion Rate Yearly  
                if(mapOfDatedConversionrate!= null){
                    if(mapOfDatedConversionrate.keySet().contains(oppy.CurrencyIsoCode)){
                        List<DatedConversionRate> listOfMatchedOppyCurrency = mapOfDatedConversionrate.get(oppy.CurrencyIsoCode);
                        //  system.debug('listOfMatchedOppyCurrency'+listOfMatchedOppyCurrency);
                        for(DatedConversionRate checkMultiYear : listOfMatchedOppyCurrency){
                            if(checkMultiYear != null && oppy.ContractStartDate__c != null && checkMultiYear.StartDate <= oppy.ContractStartDate__c){
                                conversionRateYearly = checkMultiYear.ConversionRate;
                                break;
                            }
                            else{
                                conversionRateYearly = listOfMatchedOppyCurrency[0].ConversionRate;
                            }
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
                        system.debug('previousOppyProductStatus'+previousOppyProductStatus);
                        system.debug('previousOppyProductFirstYearValue'+previousOppyProductFirstYearValue);
                        system.debug('PriorYearTotalFirstYearValue__c'+oppyToUpdate.PriorYearTotalFirstYearValue__c);                        
                    }
                
                for(OpportunityLineItem oli: oppy.OpportunityLineItems) {
                   
                    if( oli.Status__c == 'Lost' && (!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights')){
                        if(previousOppyProductStatus != null && previousOppyProductFirstYearValue!= null && previousOppyProductFirstYearValue.containsKey(oli.Product2Id) && previousOppyProductStatus.containsKey(oli.Product2Id) && previousOppyProductStatus.get(oli.Product2Id) != 'Lost') {
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
                                    if(previousOppyProductStatus != null && previousOppyProductFirstYearValue!= null && previousOppyProductFirstYearValue.containsKey(oli.Product2Id) && previousOppyProductStatus.containsKey(oli.Product2Id) && (previousOppyProductStatus.get(oli.Product2Id) == 'New' || previousOppyProductStatus.get(oli.Product2Id) == 'Existing')){
                                        oppyToUpdate.SalesPriceIncreaseDecrease__c-=(previousOppyProductFirstYearValue.get(oli.Product2Id))/conversionRateYearly;
                                    }
                                    system.debug('oppyToUpdate.SalesPriceIncreaseDecrease__c '+oppyToUpdate.SalesPriceIncreaseDecrease__c);
                                }
                            }
                            // US: 5856692 - SalesNew and SalesRenewal fields
                        if(oli.Status__c=='New' && (!lstExcludedProductNames.contains(oli.Name) && oli.product2.BusinessLine2__r.name== 'Automotive Insights')) {
                            oppyToUpdate.MobilitySalesNew__c += oli.FirstYear__c/conversionRateYearly;
                            if(oli.ProductType__c == 'Subscription') {
                                oppyToUpdate.SalesNewSubscription__c += oli.FirstYear__c/conversionRateYearly;
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
                
                listOpportunityToUpdate.add(oppyToUpdate);
                System.debug('oppyToUpdate-->'+oppyToUpdate);
            }
         
            
            if(listOpportunityToUpdate != null && !listOpportunityToUpdate.isEmpty()){
                Database.SaveResult[] srList = Database.update(listOpportunityToUpdate,false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted' );
                    }
                    else {
                        // Operation failed, so get all errors  
                  //  err.addAll(sr.getErrors());    
                    System.debug('Error Caught'+sr.getErrors());    
                    }
                }
            }
            
        }
        catch(Exception ex) {
            System.debug('Exception caught in batch' + ex.getMessage());
           // System.debug('Error List-->'+err);
            UtilityClass.createApexLogRecord(ex, 'BatchUpdateMobilityMatrics', 'Execute');       
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
     //   System.debug('Error List-->'+err);
        System.debug(LoggingLevel.INFO, 'BatchUpdateMobilityMatrics batch completed');
    }
    
    
}