// @Author : Pankhuri Jain
// @date: 11 Feb 2022
// @description : Clone from OpportunityProductEditController class, Manipulate and Remove unwanted methods from cloned class
//                Controller Class for opportunityEditProductLWC
//@company : IHS Markit

public without sharing class OpportunityEditProductControllerLWC  {
    //
    //@author : Paras Dhingra
    //@date: 8th Sep 2017
    //@description : SFDC1-1837 apex method to fetch Opportunity product and schedules 
    //@company : IHS Markit
    //@param : String
    //@return : OpportunityEditProductControllerLWC.OppyWrapper
    @AuraEnabled
    public static OppyWrapper getOpportunityOPS(String OppyId, string sortOLIDirection, string sortOLIByFieldName) {
        Id userId = UserInfo.getUserId();

        //query Opportunity with Opportunity Products and Opportunity Product Schedules
        String soqlQuery = 'Select Id,AccountId,GlobalSegments__c,InternalBusinessSegment__c,Name, RecordType.Name, OpportunityCountry__r.Name, ShipToCountryNew__c, LegalEntity__c, LegalEntity__r.name, CurrencyISOCode, CloseDate, ContractStartDate__c, ContractEndDate__c, RecordType.DeveloperName, StageName, IsProRated__c, AutoRenewal__c, DoesThisAutoRenewalHaveChanges__c, PriceChangeOnly__c, (Select id, DiscountPercent__c, DiscountAmount__c, DiscountType__c, ExternalListPrice__c, InstallmentYears__c, Opportunity__c, Opportunity__r.name, OpportunityProductID__c, OpportunityProductScheduleKey__c, PriceBookListPrice__c, Product__c, ProductSchedule__c, SalesPrice__c, TotalPrice__c, Quantity__c, Status__c, CurrencyIsoCode, AnnualizedDiscountAmount__c, AnnualizedUnitPrice__c, AnnualizedTotalAmount__c,AnnualizedDiscountPercent__c from OpportunityProductSchedules__r order by InstallmentYears__c ASC), (Select id, isProrated__c, Product2Id, Status__c, MaterialCode__c, Description, NumberofConcurrentUsersSeats__c, NumberofLocationsSites__c, NumberofPotentialUsers__c, PriorYearTotalSalesPrice__c, LicenseType__c, Product2.Name, Product2.MaterialCode__c,Product2.AAG__c,Product2.Division__c,Product2.InternalBusinessSegment__c,Product2.BusinessLine2__r.Name, Product2.IsActive, RecommendedUnitPrice__c, UnitPrice, Discount_Amount__c, ProductType__c, ContractStartDate__c, ContractEndDate__c, Probability__c, AuthorizedUsers__c, IsProductatRisk__c,RiskStatus__c, EstimatedValueatRisk__c from OpportunityLineItems order by '+sortOLIByFieldName+' '+sortOLIDirection+') from Opportunity where id=:oppyId';   

        //System.debug(database.query(soqlQuery));
        Opportunity oppy = database.query(soqlQuery);
        List<OPSWrapper> opsWrap = new List<OPSWrapper>();

        if(oppy.OpportunityLineItems==null || oppy.OpportunityLineItems.isEmpty()) {
            //no products associated with Opportunity return empty wrapper
            OppyWrapper blankOpyWrap = new OppyWrapper();
            blankOpyWrap.hasOpportunityEditAccess = userHasEditAccess(userId,oppyId);
            return  blankOpyWrap;
        }
                
        //SFDC-4808 Defining Custom metadata for excluding Internal segments for Proration
        ProrationInternalBusinessSegToExclude__mdt[] prorationSegmentToExclude = [SELECT id,label FROM ProrationInternalBusinessSegToExclude__mdt];
        Set<String> setSegmentsToExclude = new set<String>();
        for (ProrationInternalBusinessSegToExclude__mdt ps : prorationSegmentToExclude) {
            setSegmentsToExclude.add(ps.label);
        }

        //SFDC-5496 - Fetch FS Product Alert Message List
        Map<String, String> mapFSProductAlert = new Map<String, String>();
        List<FSProductAlertSetting__mdt> fsProd = FSProductAlertSetting__mdt.getall().values();
        for(FSProductAlertSetting__mdt fsProdDtl : fsProd) {
            mapFSProductAlert.put(fsProdDtl.MaterialCode__c, fsProdDtl.AlertMessage__c);
        }
        
        //SFDC-3428 - Create a set of Products which are eligible for 2% tax
        Set<Id> indianLevyProds = new Set<Id>();
        Boolean isIndianOppy = false;
        Set<String> mediaTypeSet = new Set<String>{'PDF-Unlim Subs','Online Access','Online Download','S/W As A Service','Hosting','S/W Maintenance','Processing Svc','Training','FTP','Publication Electronic','PDF','Mobile App','Data Update/Maintenance','eBooks','EDT/EDI'};
        // Check for Indian Opportunity
        if ((oppy.RecordType.Name == 'New Business' && (oppy.OpportunityCountry__r.Name == 'India' || oppy.OpportunityCountry__r.Name == 'IN')) || (oppy.RecordType.Name == 'Renewal' && (oppy.ShipToCountryNew__c == 'India' || oppy.ShipToCountryNew__c == 'IN'))) {
            isIndianOppy = true;    
        } 
        //SFDC-4805
        Map<Id,OpportunityLineItem> mapOLI = new Map<Id,OpportunityLineItem>(oppy.OpportunityLineItems);
        List<Id> listproductId= new List<Id>();
        
        for(OpportunityLineItem oli: mapOLI.values()) {
            listproductId.add(oli.Product2Id );
        }
        //SFDC-4805 added product Check
        if (oppy.LegalEntity__r.name == 'IHS Global Pte Ltd' && isIndianOppy){
           for (Product2 prd : [Select Id from Product2 where LegalEntity__r.Name = 'IHS Global Pte Ltd' and Mediatype__c IN :mediaTypeSet and Id IN : listproductId]){
                 indianLevyProds.add(prd.Id);
           }
           for (ProductExtensions__c pext : [Select Product__c from ProductExtensions__c where LegalEntity__r.Name = 'IHS Global Pte Ltd' and product__r.mediatype__c IN :mediaTypeSet and Product__c IN : listproductId]){
                indianLevyProds.add(pext.Product__c);
           }
        }
        //create a map for Oppy product and its oppyproductSchedules 
        Map<String,List<OpportunityLineItemSchedule__c>> mapOppyProductandSchedules = new Map<String,List<OpportunityLineItemSchedule__c>>();
        for(OpportunityLineItemSchedule__c ops : oppy.OpportunityProductSchedules__r) {        
            //SFDC-400           
            ops.AnnualizedUnitPrice__c = ops.AnnualizedUnitPrice__c == null ? ops.PriceBookListPrice__c : ops.AnnualizedUnitPrice__c; 
            ops.AnnualizedDiscountPercent__c = ops.AnnualizedDiscountPercent__c == null ? 0 : ops.AnnualizedDiscountPercent__c ;
            ops.AnnualizedDiscountAmount__c = ops.AnnualizedDiscountAmount__c == null ? 0 : ops.AnnualizedDiscountAmount__c ;
            // end
            if(mapOppyProductandSchedules.containsKey(ops.opportunityProductID__c)) {
                mapOppyProductandSchedules.get(ops.opportunityProductID__c).add(ops);
            }
            else {
                mapOppyProductandSchedules.put(ops.opportunityProductID__c,new List<OpportunityLineItemSchedule__c>{ops});
            }
            
        }
        //As closeDate is never null assigning it as the pricingDate
        Date pricingDate = oppy.CloseDate;
        //assign the pricing date to ContractStartDate__c if it is not null
        if(oppy.ContractStartDate__c!=null) {
            pricingDate = oppy.ContractStartDate__c;
        } 
        String oppyFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <=:pricingDate AND EndDate >=:pricingDate]?.FiscalYearSettings?.Name;
        
        //Fix for missing records in Period object
        if(String.isBlank(oppyFiscalYear)) {
            oppyFiscalYear = String.valueOf(pricingDate.year());
        }
        
        //create map for opportunitylineitem
        
        //query Opportunity product schedules
        List<Product2> lstRelatedOPS = [Select id, name, 
                                        (Select id, Name, ListPrice__c, PricingYear__c, Product__c, ProductTerm__c,CurrencyIsoCode, 
                                         InstallmentYear__c, Year__c from ProductSchedules__r  where isactive__c = true AND PricingYear__c=:oppyFiscalYear  order by InstallmentYear__c,ProductTerm__c ASC)
                                        from Product2
                                        where Id IN (Select Product2Id from OpportunityLineItem where OpportunityId=:oppyId)];
        Map<Id,Product2> mapProducts = new Map<Id,Product2>(lstRelatedOPS);                                
        //create a map for Products and ProductSchedules with product term as key
        Map<Id,Map<String,List<ProductSchedule__c>>> mapProductWithSchedules = new Map<Id,Map<String,List<ProductSchedule__c>>>();
        for(Product2 prod: lstRelatedOPS) {
            Map<String,List<ProductSchedule__c>> tempMapProdTermSchedule = new Map<String,List<ProductSchedule__c>>();
            for(ProductSchedule__c prodSchd : prod.ProductSchedules__r) {
                String productTerm = prodSchd.ProductTerm__c.substring(0,1);
                if(tempMapProdTermSchedule.containsKey(productTerm)) {
                    tempMapProdTermSchedule.get(productTerm).add(prodSchd);
                } 
                else {
                    tempMapProdTermSchedule.put(productTerm,new List<ProductSchedule__c>{prodSchd});
                }
            }
            mapProductWithSchedules.put(prod.Id,tempMapProdTermSchedule);
        }
        
        OppyWrapper opyWrap = new OppyWrapper();
        opyWrap.canBeProRated= false;
        opyWrap.isProRated = oppy.IsProRated__c;
         
        for(OpportunityLineItem oli: mapOLI.values()) {
            Product2 prod = mapProducts.get(oli.Product2Id);
            OPSWrapper opsWrapObj = new OPSWrapper();
            //Bug fix - Handle products with blank status
            if(String.isBlank(oli.Status__c)) {
                if(oppy.RecordType.Name == 'New Business') {
                    oli.Status__c = 'New';
                } else {
                    oli.Status__c = 'Existing';
                }
            }
            opsWrapObj.Status = oli.Status__c;
            opsWrapObj.oppyProduct = new OpportunityLineItem();
            opsWrapObj.oppyProduct = oli;
            String existingTerm = '';
            if(mapOppyProductandSchedules.containsKey(oli.Id)) {
                opsWrapObj.lstOPS = mapOppyProductandSchedules.get(oli.Id);
                existingTerm = String.valueOf(opsWrapObj.lstOPS.size());
            } 
            if (indianLevyProds.contains(oli.Product2Id)) {//SFDC-3428
                opsWrapObj.isIndianLevyProd = true;
                //SFDC-4527
                opsWrapObj.lstOPS=getUnitPriceasperLevyCharges( mapOppyProductandSchedules.get(oli.Id),opsWrapObj.oppyProduct);
            } else {
                opsWrapObj.lstOPS = mapOppyProductandSchedules.get(oli.Id);
            }  
            
            //SFDC-5496 Identify Alert Message for Products
            if(mapFSProductAlert.containsKey(oli.Product2.MaterialCode__c)) {
                opsWrapObj.fsAlertMessage = mapFSProductAlert.get(oli.Product2.MaterialCode__c);
            } else {
                opsWrapObj.fsAlertMessage = '';
            }
            
            opsWrapObj.oppyProduct.RecommendedUnitPrice__c = opsWrapObj.oppyProduct.RecommendedUnitPrice__c == null ? 0.0 : opsWrapObj.oppyProduct.RecommendedUnitPrice__c; 
            opsWrapObj.oppyProduct.PriorYearTotalSalesPrice__c = opsWrapObj.oppyProduct.PriorYearTotalSalesPrice__c == null ? 0.0 : opsWrapObj.oppyProduct.PriorYearTotalSalesPrice__c; 

            //SFDC-400 - ProRation Identification & Days calculation
            if(oli.ContractStartDate__c != null && oli.ContractEndDate__c != null){  
                Date startDat = oli.ContractStartDate__c;               
                Date endDat = oli.ContractEndDate__c;                   
                Integer diff = startDat.daysBetween(endDat);
                Integer proRatedDays = UtilityClass.calculateDays360ForProRation(oli.ContractStartDate__c, oli.ContractEndDate__c);
                opsWrapObj.proRatedDays = proRatedDays;

                if((proRatedDays != 360 && proRatedDays !=361 && proRatedDays != 359 && proRatedDays < 719) 
                    && oli.Product2.AAG__c == 'Subscription'                   
                    && (!setSegmentsToExclude.contains(oli.Product2.InternalBusinessSegment__c)  
                    || (oli.Product2.InternalBusinessSegment__c == 'Research Advisory Specialty Solutions' && oli.Product2.BusinessLine2__r.Name == 'Maritime and Trade'))
                ) { 
                    //IHSMUS-5102796 - Added condition to allow 'Maritime and Trade' Business Line Products for ProRation        
                    opyWrap.canBeProRated= true;
                }                                         
            }
            opsWrapObj.mapOPSAll = new Map<String,List<OpportunityLineItemSchedule__c>>();
            opsWrapObj.productTermSelected = existingTerm;
            String currencyIsoCode = oppy.CurrencyIsoCode;
            opsWrapObj.lstOPS = mapOppyProductandSchedules.get(oli.Id);
            opsWrapObj.mapOPSAll.put(existingTerm,opsWrapObj.lstOPS);
            //fetch related product schedules and convert them to oppyschedules and add them to the map
            if(mapProductWithSchedules.containsKey(oli.Product2Id)) {
                Map<String,List<ProductSchedule__c>> tempMapProductWithSchedule = new Map<String,List<ProductSchedule__c>>();
                tempMapProductWithSchedule = mapProductWithSchedules.get(oli.Product2Id);
                //now process for each product term and add to mapOPSAll
                for(String term : tempMapProductWithSchedule.keySet()) {
                    if(term!=existingTerm) {
                        List<OpportunityLineItemSchedule__c> tempOppyScheduleList= convertProdSchdsToOppySchds(currencyIsoCode, tempMapProductWithSchedule.get(term),opsWrapObj.lstOPS[0], oppy.RecordType.DeveloperName, opyWrap.canBeProRated);
                        if(tempOppyScheduleList!=null && !tempOppyScheduleList.isEmpty()) {
                            opsWrapObj.mapOPSAll.put(term,tempOppyScheduleList);
                        }
                    }
                }
                
            }
            opsWrapObj.productQty = 0.0;
            opsWrapObj.isDeleted = false;
            opsWrapObj.productQty = opsWrapObj.lstOPS != null? opsWrapObj.lstOPS[0].Quantity__c : 1;
            opsWrapObj.discountType = opsWrapObj.lstOPS != null? opsWrapObj.lstOPS[0].discountType__c : '';
            opsWrapObj.productTermSelected = String.valueOf(opsWrapObj.lstOPS.size());
            opsWrapObj.lstMapOPSIndex = new List<String>();
            opsWrapObj.lstMapOPSIndex.addAll(opsWrapObj.mapOPSAll.keySet());
            opsWrapObj.lstMapOPSIndex.sort();
            opsWrap.add(opsWrapObj);
        }
        
        opyWrap.oppy = oppy;       
        
        //SFDC-400 - Apply ProRation only for New Business & Renewal
        if(oppy.RecordType.Name != 'New Business' && oppy.RecordType.Name != 'Renewal'){       
            opyWrap.canBeProRated= false; 
        }       
        
        //Auto - Renewal is having short term contract without DoesThisAutoRenewalHaveChanges__c
        if(opyWrap.canBeProRated && oppy.RecordType.Name == 'Renewal' && oppy.AutoRenewal__c && !oppy.DoesThisAutoRenewalHaveChanges__c) {
            opyWrap.canBeProRated = false;
        }        
        opyWrap.lstOPSWrapper = opsWrap;
        opyWrap.indianLevyProdList = new List<Id>(indianLevyProds);
        opyWrap.hasOpportunityEditAccess = userHasEditAccess(userId,oppyId);
        opyWrap.hasRemoveProductAccess = getHasRemoveProductAccess(oppy.RecordType.DeveloperName);
        opyWrap.isAdmin = false;
        String profileName = UtilityClass.LoggedInUserProfileName;
        if (profileName.containsIgnoreCase('System Admin')) {
            //no validation checks are required for system admins
            opyWrap.isAdmin = true;
        }
        opyWrap.isSalesOps = false;
        if (profileName.containsIgnoreCase('Sales Ops') || profileName.containsIgnoreCase('User Support') || GlobalConstants.hasEnhancedSalesPermission) {
            //allow user to by-pass some validation checks
            opyWrap.isSalesOps = true;
        }
        return opyWrap;
    }

    //
    //@author : Paras Dhingra
    //@date: 01st Feb 2018
    //@description : SFDC1-4634 Product to be removed only by System admins for renewals
    //@company : IHS Markit
    //@param : String 
    //@return : Boolean
    //
    @TestVisible
    private static Boolean getHasRemoveProductAccess(String oppyRecordType) {
        Boolean hasAccess = true;
        if(oppyRecordType.containsIgnoreCase('Renewal')) {
            //check profile name
            Id profileId = UserInfo.getProfileId();
            String profileName = [Select Name from Profile where Id=:profileId].Name;
            if(!profileName.containsIgnoreCase('Admin')) {
                hasAccess = false;
            }
        }
        return hasAccess;
    }
    
    //
    //@author : Paras Dhingra
    //@date: 29th Jan 2018
    //@description : SFDC1-4789 code optimization for duplicate products in opportunity
    //@company : IHS Markit
    //@param : String, List<ProductSchedule__c>,OpportunityLineItemSchedule__c
    //@return : List<OpportunityLineItemSchedule__c>
    //
    @TestVisible
    private static List<OpportunityLineItemSchedule__c> convertProdSchdsToOppySchds(String oppyCurrencyISOCode, List<ProductSchedule__c> lstProdSchedules,OpportunityLineItemSchedule__c existingSchedule, String oppyRecordType, Boolean isProRatedApplied) {
        List<OpportunityLineItemSchedule__c> lstOPSToReturn = new List<OpportunityLineItemSchedule__c>();
        for(ProductSchedule__c ps : lstProdSchedules) {
            Decimal psListPrice = ps.ListPrice__c>0?ps.ListPrice__c:0.0;
            if(psListPrice!=null && psListPrice>0 && oppyCurrencyISOCode!=ps.CurrencyIsoCode) {
                psListPrice = ProductEditController.getConvertedCurrencyRate(ps.CurrencyIsoCode,oppyCurrencyISOCode,psListPrice);
            }
            OpportunityLineItemSchedule__c ops = new OpportunityLineItemSchedule__c();
            ops.PriceBookListPrice__c = psListPrice>0?psListPrice:0;
            ops.InstallmentYears__c = ps.InstallmentYear__c;
            ops.ExternalListPrice__c = oppyRecordType=='Gratis'?0:ops.PriceBookListPrice__c;
            ops.DiscountPercent__c = 0.00;
            ops.DiscountAmount__c = 0.00;
            //SFDC-400 - Update Annualized Values for ProRation
            if(isProRatedApplied) {
                ops.AnnualizedUnitPrice__c = ops.AnnualizedUnitPrice__c>0?ops.AnnualizedUnitPrice__c:ops.PriceBookListPrice__c;
                ops.AnnualizedDiscountPercent__c = ops.AnnualizedDiscountPercent__c>0?ops.AnnualizedDiscountPercent__c: 0;
                ops.AnnualizedDiscountAmount__c = ops.AnnualizedDiscountAmount__c>0?ops.AnnualizedDiscountAmount__c: 0;
            }
            ops.DiscountType__c  = existingSchedule.discountType__c;
            ops.Quantity__c = existingSchedule.Quantity__c;
            ops.ProductSchedule__c = ps.Id;
            ops.SalesPrice__c = oppyRecordType=='Gratis'?0:ops.PriceBookListPrice__c;
            ops.TotalPrice__c = oppyRecordType=='Gratis'?0:ops.PriceBookListPrice__c;
            ops.OpportunityProductID__c = existingSchedule.OpportunityProductID__c;
            ops.Opportunity__c = existingSchedule.Opportunity__c;
            ops.Product__c = existingSchedule.Product__c;
            ops.CurrencyIsoCode = oppyCurrencyISOCode;
            lstOPSToReturn.add(ops);
        }
        return lstOPSToReturn;
    }
    
    //@author : Paras Dhingra
    //@date: 8th Sep 2017
    //@description : SFDC1-1837 apex method to save oppy products and schedules post edit
    //@company : IHS Markit
    //@param : String, String
    //@return : String
    //@Update Author : Mohit Modi
    //@date : 23 March 2018
    //@Description : SFDC1-5722 : Added Global Constant check for bypassing the opportunitylineItem before deletion trigger
    
    @AuraEnabled
    public static String saveProducts(String oppyId, String wrapperJson) {
        String message = '';
        List<OPSWrapper> lstOPSWrapper = (List<OPSWrapper>)JSON.deserialize(wrapperJson, List<OPSWrapper>.class);
        if(lstOPSWrapper!=null && !lstOPSWrapper.isEmpty()) {
            //traverse to collect records for deletion
            Map<Id,OpportunityLineItemSchedule__c> mapOPSToDelete = new Map<Id,OpportunityLineItemSchedule__c>();
            List<OpportunityLineItemSchedule__c> lstOPSToUpsert = new List<OpportunityLineItemSchedule__c>();
            List<OpportunityLineItem> listOppyProductToDel = new List<OpportunityLineItem>();
            List<OpportunityLineItem> listOppyProductToUpdate = new List<OpportunityLineItem>();
            Map<Id, String> mapProdIdProRation = new Map<Id, String>();
            
            //traverse the wrapper to collect items in different lists
            for(OPSWrapper OPSObj : lstOPSWrapper) {
                // if user has opted to delete the product
                if(OPSObj.isDeleted) {
                    //select Oppy product to delete
                    listOppyProductToDel.add(OPSObj.oppyProduct);
                    for(String term : OPSObj.mapOPSAll.keySet()) {
                        for(OpportunityLineItemSchedule__c ops : OPSObj.mapOPSAll.get(term)) {
                            if(ops.Id!=null) {
                                //add to the map to delete all items that have id related to that product
                                mapOPSToDelete.put(ops.Id,ops);
                            }
                        }
                    }
                }
                else {//process records for upsert
                    Set<Id> setOPSToUpsert = new Set<Id>();
                    lstOPSToUpsert.addAll(OPSObj.lstOPS);
                    for(OpportunityLineItemSchedule__c ops: lstOPSToUpsert) {
                        if(ops.Id!=null) {
                            setOPSToUpsert.add(ops.Id);
                        }
                    }
                    //collect items not in mapOPSToUpsert for deletion
                    for(String term : OPSObj.mapOPSAll.keySet()) {
                        for(OpportunityLineItemSchedule__c ops : OPSObj.mapOPSAll.get(term)) {
                            if(ops.Id!=null && !setOPSToUpsert.contains(ops.Id)) {
                                //add to the map to delete all items that have id related to that product
                                mapOPSToDelete.put(ops.Id,ops);
                            }
                        }
                    }
                    if(OPSObj.isIndianLevyProd==true) {
                        listOppyProductToUpdate.add(OPSObj.oppyProduct);
                        //SFDC-4527
                        updateListPriceinOPS(lstOPSToUpsert,OPSObj.oppyProduct);
                    } else {
                        listOppyProductToUpdate.add(OPSObj.oppyProduct);
                    }
                }
            }
            Savepoint sp = Database.setSavepoint();
            try {
                // Adding the changes for GlobalConstant to bypass the Opportunity lineItem before delete trigger. Setting to True
                GlobalConstants.hasAllowedOpportunityProductDeletion = true;     
                //prevent opportunity validations from firing
                GlobalConstants.hasTriggeredFromOpportunityProduct = true;
                GlobalConstants.disableOppyProductValidations = true;
                //query Opportunity and enable byPassValidation on it : Commented as byPassing has been moved to Global Variable use
                
                if(mapOPSToDelete!=null && !mapOPSToDelete.isEmpty()) {
                    delete mapOPSToDelete.values();
                }
                 if(listOppyProductToUpdate!=null && !listOppyProductToUpdate.isEmpty()) {                    
                    update listOppyProductToUpdate;                    
                }               
               // System.debug('lstOPStoUpsert Unit ' + lstOPSToUpsert[0].AnnualizedUnitPrice__c); 
               // System.debug('lstOPStoUpsert Total ' + lstOPSToUpsert[0].AnnualizedTotalAmount__c); 
                //save OpportunityProductSchedules
                if(lstOPSToUpsert!=null && !lstOPSToUpsert.isEmpty()) {
                    upsert lstOPSToUpsert;
                }            
                
                //Query opportunity products and delete
                if(listOppyProductToDel!=null && !listOppyProductToDel.isEmpty() && OpportunityLineItem.sObjectType.getDescribe().isDeletable()) {                
                    
                    delete listOppyProductToDel;              
                    
                    // Adding the changes for GlobalConstant to bypass the Opportunity lineItem before delete trigger. Setting to false back.
                    GlobalConstants.hasAllowedOpportunityProductDeletion = false; 
                    GlobalConstants.hasTriggeredFromOpportunityProduct = false;
                    GlobalConstants.disableOppyProductValidations = false;
                }                
                
                message = 'Records updated successfully';
            }
            catch(Exception e) {
                message = 'Error occurred while creating records :'+e.getMessage();
                Database.rollback(sp);
            }
            
        }
        return message;
    }
    
    //
    //@author : Paras Dhingra
    //@date: 26th Sep 2017
    //@description : SFDC1-5958 check if logged in user has edit access to opportunity
    //@company : IHS Markit
    //@param : null
    //@return : List<String>
    //
    private static Boolean userHasEditAccess(Id usrId, Id recordId) {
        return UtilityClass.checkRecordAccessforUser(usrId, recordId);
    }

    public class OppyWrapper {
        @AuraEnabled public Opportunity oppy;
        @AuraEnabled public Boolean hasOpportunityEditAccess;
        @AuraEnabled public Boolean hasRemoveProductAccess;
        @AuraEnabled public Boolean canBeProRated;        
        @AuraEnabled public String isProRated;        
        @AuraEnabled public Boolean isAdmin;
        @AuraEnabled public Boolean isSalesOps;
        @AuraEnabled public List<OPSWrapper> lstOPSWrapper;
        @AuraEnabled public List<Id> indianLevyProdList;
    }
    /**
    * @Author : Digvijay
    * @date: 3/09/2021
    * @description :Adjusted the Product Schdelue List Price as per indian Levy charges fo component Load.
    * @company : IHS Markit
    * @param : OpportunityLineItemSchedule__c
    * @return :List<OpportunityLineItemSchedule__c>  
    */
    public static List<OpportunityLineItemSchedule__c> getUnitPriceasperLevyCharges(List<OpportunityLineItemSchedule__c> lstOPS,OpportunityLineItem opptyLineItem) {
        //Double discountAmount; Discount_Amount__c , UnitListPrice__c , UnitPrice
        Decimal dividingFactor=1+decimal.valueOf(Label.IndianLevyTax)/100;
        for(OpportunityLineItemSchedule__c ops : lstOPS) {
            if(ops!=null && ops.SalesPrice__c!=null) {
                ops.ExternalListPrice__c=(ops.SalesPrice__c/dividingFactor).setScale(2)+ops.DiscountAmount__c;
            }
            //SFDC-400 Annualized Unit Price without Indian Levy
            if(opptyLineItem.Product2.AAG__c == 'Subscription' && opptyLineItem.IsProRated__c == 'Yes') {
                
                Decimal annSalesPrice = ops.AnnualizedTotalAmount__c != null && ops.Quantity__c != null?(ops.AnnualizedTotalAmount__c / ops.Quantity__c):0;
                ops.AnnualizedUnitPrice__c = (annSalesPrice/dividingFactor).setScale(2)+ops.AnnualizedDiscountAmount__c;
            }
    }

        return lstOPS;
    }
    /**
    * @Author : Digvijay
    * @date: 3/09/2021
    * @description :Adjusted the Product Schdelue List Price as per indian Levy charges
    * @company : IHS Markit
    * @param : OpportunityLineItemSchedule__c
    * @return :void 
    */
    public static void setUnitPriceasperLevyCharges(OpportunityLineItemSchedule__c opptyLineItemSchedule, OpportunityLineItem opptyLineItem) {
        Decimal dividingFactor = 1+decimal.valueOf(Label.IndianLevyTax)/100;
        System.debug('ProRated Indian Levy ' + opptyLineItem.IsProRated__c + opptyLineItemSchedule.AnnualizedTotalAmount__c);
        if(opptyLineItemSchedule != null && opptyLineItemSchedule.SalesPrice__c !=null) {
            Decimal listPricewithDiscountAfterTaxRemoval= (opptyLineItemSchedule.SalesPrice__c / dividingFactor).setScale(2);
            Decimal taxAmount=(opptyLineItemSchedule.SalesPrice__c -listPriceWithDiscountAfterTaxRemoval);
            Decimal listPriceWithoutDiscountAfterTaxRemoval = listPricewithDiscountAfterTaxRemoval + opptyLineItemSchedule.DiscountAmount__c;
            Decimal externalListPrice = listPriceWithoutDiscountAfterTaxRemoval + taxAmount;
            opptyLineItemSchedule.ExternalListPrice__c = externalListPrice;
        }
        
        if(opptyLineItem.IsProRated__c == 'Yes') {
            Decimal salesPrice = opptyLineItemSchedule.AnnualizedTotalAmount__c != null && opptyLineItemSchedule.Quantity__c != null? (opptyLineItemSchedule.AnnualizedTotalAmount__c / opptyLineItemSchedule.Quantity__c):0;
            if(opptyLineItemSchedule != null && salesPrice !=null) {
                Decimal listPricewithDiscountAfterTaxRemoval= (salesPrice / dividingFactor).setScale(2);
                Decimal taxAmount = (salesPrice - listPricewithDiscountAfterTaxRemoval);
                Decimal listPriceWithoutDiscountAfterTaxRemoval = listPricewithDiscountAfterTaxRemoval + opptyLineItemSchedule.AnnualizedDiscountAmount__c;
                Decimal annualizedPrice = listPriceWithoutDiscountAfterTaxRemoval + taxamount;
                opptyLineItemSchedule.AnnualizedUnitPrice__c = annualizedPrice;
            }
        }

    }
    /**
    * @Author : Digvijay
    * @date: 3/09/2021
    * @description :Adjusted the Product Schdelue List Price as per indian Levy charges
    * @company : IHS Markit
    * @param : List<OpportunityLineItemSchedule__c> , OpportunityLineItem
    * @return :void 
    */
    public static Void updateListPriceinOPS(List<OpportunityLineItemSchedule__c> lstOPSToUpsert, OpportunityLineItem opptyLineItem) {
    if(lstOPSToUpsert!=null && !lstOPSToUpsert.IsEmpty() && opptyLineItem!=null) {
            for(OpportunityLineItemSchedule__c ops : lstOPSToUpsert) {
                System.debug('lstOPSToUpsert Annualized value ' + ops.Product__c);
                System.debug('lstOPSToUpsert Oppy Product ' + opptyLineItem.Product2Id);                        
                if(ops.Product__c==opptyLineItem.Product2Id ) {
                    setUnitPriceasperLevyCharges(ops, opptyLineItem);
                }
            }
        }
    }
    /*
    * @Author : Manish Kumar
    * @date: 5/11/2021
    * @description : Update legal entity to blank when all products are removed
    * @company : IHS Markit
    * @param : string
    * @return : string 
    */
    @AuraEnabled
    public static string updateLegalEntityNull(string oppyId) {
        String message = '';
        Opportunity oppy = [Select id, legalEntity__c from Opportunity where id = :oppyId limit 1];
        try{
            if(oppy!=null) {
                oppy.legalEntity__c = null;
                update oppy;
            }
            message = 'Records updated successfully';
        }
        catch(Exception e) {
            message = 'Error occurred while updating records :'+e.getMessage();
        }
        return message;
    }
}