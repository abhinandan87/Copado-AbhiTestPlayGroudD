// @Author : Ankush Agarwal
// @date: 24th Jan 2022
// @description : Manipulate New Added Product on Opportunity, Clone from productEditController class
public without sharing class OpportunityAddProductControllerLWC {
    public OpportunityAddProductControllerLWC() {

    }

    public static Map<String, Decimal> mapCurrencyType = UtilityClass.mapCurrencyIsoCodeConversionRate;
    /**
    * @Author : Paras Dhingra
    * @date: 17th Aug 2017
    * @description : SFDC1-2043 fetch product schedules and convert into wrapper
    * @company : IHS Markit
    * @param : List<ID>
    * @return : List<ProductEditController.ProductLineItemWrapper>
    */
    @AuraEnabled
    public static OppyWrapper getProductDetails(List<Id> productIds, String oppyId, String legalEntityName) {
        try {

            System.debug('====In getProductDetails===');
            System.debug('====productIds===' + productIds);
            System.debug('====oppyId===' + oppyId);
            System.debug('====legalEntityName===' + legalEntityName);

            List<Opportunity> oppy = [Select id, AccountId, CurrencyIsoCode, CloseDate,ContractStartDate__c,ContractEndDate__c,RecordType.Name, OpportunityCountry__r.Name, RecordType.DeveloperName, IsProRated__c, ShipToCountryNew__c from Opportunity where Id=:oppyId];
            //close date is a required field on oppy and cannot be null
            Date pricingDate = oppy[0].CloseDate;
            if(oppy[0].ContractStartDate__c!=null) {
                pricingDate = oppy[0].ContractStartDate__c;
            }
            String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <=:pricingDate AND EndDate >=:pricingDate]?.FiscalYearSettings?.Name;

            System.debug('===currentFiscalYear===' + currentFiscalYear);

            //Fix for missing records in Period object
            if(String.isBlank(currentFiscalYear)) {
                currentFiscalYear = String.valueOf(pricingDate.year());
            }

            List<Product2> lstProductsWithSchedules = [Select Id, Name ,MaterialCode__c, AAG__c,Division__c, InternalBusinessSegment__c, ProfitCenters__c,ProfitCenters__r.SaleType__c, Family__r.Name, ProductGroup__r.Name, BusinessLine2__r.Name,
                                                        (SELECT Id, Name,ListPrice__c, PricingYear__c, Product__c, ProductTerm__c, 
                                                                         InstallmentYear__c, Year__c,CurrencyIsoCode FROM ProductSchedules__r where isactive__c = true
                                                                         AND PricingYear__c=:currentFiscalYear order by InstallmentYear__c,ProductTerm__c asc ) 
                                                       from Product2 where id in :productIds];
            System.debug('Product List = ' + lstProductsWithSchedules);
            
	        //SFDC-4808 Defining Custom metadata for excluding Internal segments for Proration
            ProrationInternalBusinessSegToExclude__mdt[] ProrationSegmentToExclude = [SELECT id,label FROM ProrationInternalBusinessSegToExclude__mdt];
            Set<String> SetSegmentsToExclude = new set<String>();
            for (ProrationInternalBusinessSegToExclude__mdt ps : ProrationSegmentToExclude) {
                SetSegmentsToExclude.add(ps.label);
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
            if ((oppy[0].RecordType.Name == 'New Business' && (oppy[0].OpportunityCountry__r.Name == 'India' || oppy[0].OpportunityCountry__r.Name == 'IN')) || (oppy[0].RecordType.Name == 'Renewal' && (oppy[0].ShipToCountryNew__c == 'India' || oppy[0].ShipToCountryNew__c == 'IN'))) {
                isIndianOppy = true;
            }
    
            if (legalEntityName == 'IHS Global Pte Ltd' && isIndianOppy){
                for (Product2 prd : [Select Id from Product2 where LegalEntity__r.Name = 'IHS Global Pte Ltd' and Mediatype__c IN :mediaTypeSet and ID IN : productIds]){
                    indianLevyProds.add(prd.Id);
                }
                for (ProductExtensions__c pext : [Select Product__c from ProductExtensions__c where LegalEntity__r.Name = 'IHS Global Pte Ltd' and product__r.mediatype__c IN :mediaTypeSet and Product__c IN : productIds]){
                    indianLevyProds.add(pext.Product__c);
                }
            }
            System.debug('oppy'+ oppy);
            Map<Id, Product2> mapProductsWithSchedules = new Map<Id,Product2>(lstProductsWithSchedules);
            List<OPSWrapper> lstOPSWrapper = new List<OPSWrapper>();
            OppyWrapper opyWrap = new OppyWrapper();
            opyWrap.oppy = oppy[0];
            System.debug('opyWrap.oppy'+ opyWrap.oppy);
            opyWrap.canBeProRated = false;
            for(Id prodId : productIds) {
                OPSWrapper varOPSWrapper = new OPSWrapper();
                OpportunityLineItem varOLI = new OpportunityLineItem(); 
                Product2 prod = mapProductsWithSchedules.get(prodId);
                if(prod.Family__c == null) {
                    Family__c fmRcd = new Family__c(Name = '');
                    prod.Family__r = fmRcd;
                }
                if(prod.ProductGroup__c == null) {
                    ProductGroup__c prdGrpRcd = new ProductGroup__c(Name = '');
                    prod.ProductGroup__r = prdGrpRcd;
                }
                varOLI.Product2 = prod; 
                varOLI.Status__c = 'New';
                varOLI.Product2Id = prod.Id; 
                varOLI.OpportunityId = oppy[0].Id;
                varOPSWrapper.proRatedDays = 0;
                //SFDC-400 - Updated Contract Start Date and End Date
                varOLI.ContractStartDate__c = oppy[0].ContractStartDate__c;
                varOLI.ContractEndDate__c = oppy[0].ContractEndDate__c;
                varOLI.LicenseType__c = '';
                if (indianLevyProds.contains(prod.Id)) {//SFDC-3428
                    varOPSWrapper.isIndianLevyProd = true;
                }

                //SFDC-5496 Identify Alert Message for Products
                if(mapFSProductAlert.containsKey(prod.MaterialCode__c)) {
                    varOPSWrapper.fsAlertMessage = mapFSProductAlert.get(prod.MaterialCode__c);
                } else {
                    varOPSWrapper.fsAlertMessage = '';
                }
                

                //SFDC-400 Check if ProRation should be applied or not
                if(oppy[0].ContractStartDate__c == null || oppy[0].ContractEndDate__c == null || 
                   (oppy[0].RecordType.Name != 'Renewal' && oppy[0].RecordType.Name != 'New Business') 
                  ) {
                    opyWrap.canBeProRated = false;
                } else {
                    Integer proRatedDays = UtilityClass.calculateDays360ForProRation(oppy[0].ContractStartDate__c, oppy[0].ContractEndDate__c);
                    Integer dayDifference = oppy[0].ContractStartDate__c.daysBetween( oppy[0].ContractEndDate__c);
                    varOPSWrapper.proRatedDays = proRatedDays;
                    //System.debug('Days ' + dayDifference + ' Record Type ' + prodWrapper.recordTypeName + ' Type ' + prodWrapper.productType);
                    if(prod.AAG__c == 'Subscription' && (proRatedDays != 360 && proRatedDays != 361 && proRatedDays != 359 && proRatedDays < 719) 
                        && (!SetSegmentsToExclude.contains(prod.InternalBusinessSegment__c) 
                        || (prod.InternalBusinessSegment__c == 'Research Advisory Specialty Solutions' && prod.BusinessLine2__r.Name == 'Maritime and Trade'))
                      ) {  
                        //IHSMUS-5102796 - Added condition to allow 'Maritime and Trade' Business Line Products for ProRation        
                        opyWrap.canBeProRated = true;
                    }
                }
                System.debug('Product Schedule List ' + prod.ProductSchedules__r);
                varOPSWrapper.productQty = 1;
                varOPSWrapper.status = 'New';
                varOPSWrapper.discountType = 'No Discount';
                varOPSWrapper.lstOPS = new List<OpportunityLineItemSchedule__c>();
                varOPSWrapper.mapOPSAll = new Map<String, List<OpportunityLineItemSchedule__c>>();
                varOPSWrapper.oppyProduct = varOLI;
                //traverse the prodschedules and prepare opportunity line items schedules
                for(ProductSchedule__c ps :prod.ProductSchedules__r) {
                    Decimal psListPrice = ps.ListPrice__c>0?ps.ListPrice__c:0.0;
                    if(ps.ListPrice__c!=null && ps.ListPrice__c>0 && ps.CurrencyIsoCode!=oppy[0].CurrencyIsoCode) {
                        psListPrice = getConvertedCurrencyRate(ps.CurrencyIsoCode,oppy[0].CurrencyIsoCode,ps.ListPrice__c);
                    }
                    OpportunityLineItemSchedule__c varOPS = new OpportunityLineItemSchedule__c();
                    varOPS.InstallmentYears__c = ps.InstallmentYear__c;
                    varOPS.PriceBookListPrice__c = psListPrice>0?psListPrice:0;
                    varOPS.ExternalListPrice__c = oppy[0].RecordType.Name=='Gratis'?0:psListPrice;
                    varOPS.DiscountPercent__c = 0.00;
                    varOPS.DiscountAmount__c = 0.00;
                    varOPS.DiscountType__c = 'No Discount';
                    varOPS.Status__c = 'New';
                    varOPS.AnnualizedUnitPrice__c = psListPrice;
                    varOPS.AnnualizedDiscountAmount__c = 0.0;
                    varOPS.AnnualizedDiscountPercent__c = 0.00;
                    varOPS.SalesPrice__c = oppy[0].RecordType.Name=='Gratis'?0:psListPrice;
                    varOPS.TotalPrice__c= oppy[0].RecordType.Name=='Gratis'?0:psListPrice;
                    varOPS.ProductSchedule__c = ps.Id;
                    varOPS.Opportunity__c = oppy[0].Id;
                    varOPS.CurrencyISOCode = oppy[0].CurrencyIsoCode;
                    varOPS.Quantity__c = varOPSWrapper.productQty;

                    if (indianLevyProds.contains(prod.Id)) {//SFDC-3428
                 //     wrapperObj.isIndianLevyProd = true;  //Need to validate
                      varOPS.SalesPrice__c = ((Decimal.valueOf(System.Label.IndianLevyTax)/100) * psListPrice) + psListPrice; 
                      varOPS.TotalPrice__c =  ((Decimal.valueOf(System.Label.IndianLevyTax)/100) * psListPrice) + psListPrice;
                    }
                    //populate product term map
                    String productTerm = '';
                    productTerm= ps.ProductTerm__c!='Evergreen'?ps.ProductTerm__c.subString(0,1):ps.ProductTerm__c;
                    if(varOPSWrapper.mapOPSAll.containsKey(productTerm)) {
                        varOPSWrapper.mapOPSAll.get(productTerm).add(varOPS);
                    } else {
                        List<OpportunityLineItemSchedule__c> tempListOPSObj = new List<OpportunityLineItemSchedule__c>();
                        tempListOPSObj.add(varOPS);
                        varOPSWrapper.mapOPSAll.put(productTerm,tempListOPSObj);
                    }
                    
                }
                if(varOPSWrapper.mapOPSAll!=null && !varOPSWrapper.mapOPSAll.isEmpty()) {
                    varOPSWrapper.lstMapOPSIndex = new List<String>();
                    varOPSWrapper.lstMapOPSIndex.addAll(varOPSWrapper.mapOPSAll.keySet());
                    varOPSWrapper.lstMapOPSIndex.sort();
                    varOPSWrapper.productTermSelected = varOPSWrapper.lstMapOPSIndex[0];
                    varOPSWrapper.lstOPS = varOPSWrapper.mapOPSAll.get(varOPSWrapper.productTermSelected);
                }
                
                lstOPSWrapper.add(varOPSWrapper);
                opyWrap.lstOPSWrapper = lstOPSWrapper;
                System.debug('====opyWrap.lstOPSWrapper===' + opyWrap.lstOPSWrapper);
            }
            return opyWrap;
            
        } catch(exception e) {
		
            OppyWrapper varOppyWrapper = new OppyWrapper();
            return varOppyWrapper;
        }
        
    }
    

    /**
    * @Author : Paras Dhingra
    * @date: 17th Aug 2017
    * @description : SFDC1-2043 fetch updated productSchedules and save them
    * @company : IHS Markit
    * @param : String, String, String
    * @return : String
    * stringProductWrapper = wrapperJson
    * lstProductWrapper = lstOPSWrapper
    */
    @AuraEnabled
    public static String saveProductsOnOpportunity(String stringProductWrapper, String opportunityId, String legalEntity) {
        System.debug('--stringProductWrapper--'+ stringProductWrapper);
        //---List<ProductEditController.ProductLineItemWrapper> lstProductWrapper = //---(List<ProductEditController.ProductLineItemWrapper>)JSON.deserialize(stringProductWrapper, List<ProductEditController.ProductLineItemWrapper>.class);
        List<OPSWrapper> lstOPSWrapper = (List<OPSWrapper>)JSON.deserialize(stringProductWrapper, List<OPSWrapper>.class);
        String message = '';
        //--- System.debug('--lstProductWrapper--'+lstProductWrapper);
        System.debug('Oppy Id' + opportunityId);
        //query the Opportunity
        //SFDC-4969 Change Start
        Opportunity oppy = [Select id, CurrencyIsoCode, LegalEntity__c, Name,IsProRated__c,ContractStartDate__c,ContractEndDate__c, ExceptionStatus__c, RequestedLegalEntity__c from Opportunity where Id=:opportunityId limit 1 ];
        //SFDC-4969 Change End
        System.debug('--Opportunity--'+ oppy);
        //Initialise the records to be inserted
        List<OpportunityLineItemSchedule__c> lstOpportunityProductSchedules = new List<OpportunityLineItemSchedule__c>();
        Map<Id,OpportunityLineItem> mapOpportunityProducts = new Map<Id,OpportunityLineItem>();
        Map<Integer,OpportunityLineItem> mapOppyLineItem = new Map<Integer,OpportunityLineItem>();
        Map<Integer,List<OpportunityLineItemSchedule__c>> mapOppyLineItemSchedules = new Map<Integer,List<OpportunityLineItemSchedule__c>>();
        //traverse and fetch products to query pricebookentry.
        List<Id>lstProductIds = new List<Id>();
        System.debug('--Control reached here--');
        for( Integer i=0; i<lstOPSWrapper.size();i++) {
            lstProductIds.add(lstOPSWrapper[i].oppyProduct.product2Id);
        }
        System.debug('--lstProductIds--'+lstProductIds);
        //query pricebookentries and create a map
        List<PriceBookEntry> lstPriceBookEntries = [Select id, Product2Id from PriceBookEntry where product2Id IN:lstProductIds and isActive=true
                                                        and Pricebook2.Name = 'Standard Price Book' and CurrencyIsoCode =:oppy.CurrencyIsoCode ];

        System.debug('--lstPriceBookEntries--'+ lstPriceBookEntries);
        if(lstPriceBookEntries!=null && lstPriceBookEntries.size()>0) {

            Map<Id,Id> mapProductPBEId = new Map<Id,Id>();
            for(PriceBookEntry pbe : lstPriceBookEntries) {
                mapProductPBEId.put(pbe.Product2Id, pbe.Id);
            }
            Integer index = 1;
            //traverse the wrapper and create OpportunityLineItem Schedule for each product schedule displayed
            //--- for(ProductLineItemWrapper prodWrap : lstProductWrapper ) {
            for(OPSWrapper opsWrap : lstOPSWrapper) {
                OpportunityLineItem oli = new OpportunityLineItem();
                oli = opsWrap.oppyProduct;
                oli.PricebookEntryId = mapProductPBEId.get(opsWrap.oppyProduct.Product2Id);
                oli.Quantity = opsWrap.productQty;
                oli.UnitPrice = 0;
                oli.FirstYear__c = 0.0;
                oli.Status__c = 'New';//by default all products added will be set to 'New'
                lstOpportunityProductSchedules = new List<OpportunityLineItemSchedule__c>();
                for(Integer i=0; i<opsWrap.lstOPS.size(); i++) {
                    OpportunityLineItemSchedule__c olis = new OpportunityLineItemSchedule__c();
                    olis.Opportunity__c = opportunityId;
                    olis.CurrencyIsoCode = oppy.CurrencyIsoCode;
                    olis = opsWrap.lstOPS[i];
                    olis.Product__c = opsWrap.oppyProduct.Product2Id;
                // olis.ProductSchedule__c = opsWrap.lstOPS[i].ProductSchedule__c;
                    if(opsWrap.isIndianLevyProd) {
                    //SFDC-4527
                        olis.ExternalListPrice__c = setUnitPriceasperLevyCharges(opsWrap.lstOPS[i], opsWrap.productQty, false);
                    }else {
                        olis.ExternalListPrice__c = opsWrap.lstOPS[i].ExternalListPrice__c;
                    }
                    //SFDC-400 - Update Annualized Fields
                    if(oli.IsProRated__c == 'Yes') {
                        olis.AnnualizedDiscountAmount__c = opsWrap.lstOPS[i].AnnualizedDiscountAmount__c;
                        olis.AnnualizedDiscountPercent__c = opsWrap.lstOPS[i].AnnualizedDiscountPercent__c;
                        if(opsWrap.isIndianLevyProd) {
                            //SFDC-4527
                            olis.AnnualizedUnitPrice__c = setUnitPriceasperLevyCharges(opsWrap.lstOPS[i], opsWrap.productQty, true);
                        } else {
                            //SFDC-400 - Update Annualized Fields
                            olis.AnnualizedUnitPrice__c = opsWrap.lstOPS[i].AnnualizedUnitPrice__c;
                        }
                    }

                    olis.Quantity__c = opsWrap.productQty;
                    //olis.LicenseType__c = prodWrap.licenseType;
                    olis.Status__c = 'New';
                    lstOpportunityProductSchedules.add(olis);
                }
                mapOppyLineItem.put(index,oli);
                mapOppyLineItemSchedules.put(index,lstOpportunityProductSchedules);
                mapOpportunityProducts.put(oli.product2Id,oli); //Could be commented
                index++;
            }
            Savepoint sp = Database.setSavepoint();
            try {
                if(mapOppyLineItem!=null && mapOppyLineItem.size()>0) {
                    List<OpportunityLineItemSchedule__c> listOppySchedulesToInsert = new List<OpportunityLineItemSchedule__c>();
                    insert mapOppyLineItem.values();
                    //now traverse olis and add opportunity product ids
                    for(Integer i : mapOppyLineItemSchedules.keySet()) {
                        for(OpportunityLineItemSchedule__c olis : mapOppyLineItemSchedules.get(i)) {
                            olis.OpportunityProductID__c = mapOppyLineItem.get(i).Id;
                            listOppySchedulesToInsert.add(olis);
                        }
                    }
                    insert listOppySchedulesToInsert;
                    //update legal entity on opportunity
                    if(oppy.LegalEntity__c!=legalEntity) {
                        oppy.LegalEntity__c = legalEntity;
                        //SFDC-4969 Change Start
                        if(oppy.ExceptionStatus__c == 'Exception Request Denied' && oppy.RequestedLegalEntity__c != null){
                            oppy.ExceptionStatus__c = '';
                            oppy.RequestedLegalEntity__c = null;
                        }
                        //SFDC-4969 Change End
                        update oppy;
                    }
                    //Update message with list of OpportunityLineItem
                    //message = 'Records added successfully';
                    message = JSON.serialize(mapOppyLineItem.values());
                }
            }catch(Exception e) {
                message = 'Error occurred while creating records :'+e.getMessage();
                Database.rollback(sp);
            }

        } else {
            message = 'Error occurred no pricebookentries found';
        }

        return message;
    }

    /**
    * @Author : Ankush Agarwal
    * @date: 28th Apr 2022
    * @description : Delete OpportunityLineItem and Schedules
    * @company : IHS Markit
    * @param : String
    * @return : String
    */
    @AuraEnabled
    public static String deleteOppyProducts(String sOppyProdListWrapper) {
        List<OpportunityLineItem> lstOppyProd = (List<OpportunityLineItem>)JSON.deserialize(sOppyProdListWrapper, List<OpportunityLineItem>.class);
        set<Id> setOLIids = new set<Id>();
        String message = '';
        for(OpportunityLineItem oli : lstOppyProd) {
            setOLIids.add(oli.Id);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            List<OpportunityLineItemSchedule__c> lstOLIS = [Select Id, Opportunity__c, OpportunityProductId__c from OpportunityLineItemSchedule__c where OpportunityProductId__c IN: setOLIids];
            if(lstOLIS.size() > 0) {
                delete lstOLIS;
            }
            if(lstOppyProd.size() > 0) {
                delete lstOppyProd;
            }
            message = 'Products deleted successfully from Opportunity';
        } catch(Exception ex) {
            message = 'Error occurred while creating records :'+ex.getMessage();
            Database.rollback(sp);
        }

        return message;
    }
    
    /**
    * @Author : Paras Dhingra
    * @date: 25th Sep 2017
    * @description : SFDC1-2043 fetch custom picklist values for licenseType
    * @company : IHS Markit
    * @param : null
    * @return : List<String>
    */
    @AuraEnabled
    public static List<String> getLicenseTypes() {
        return UtilityClass.getselectOptions(new OpportunityLineItem(), 'LicenseType__c' );
    }
    
    /**
    * @Author : Paras Dhingra
    * @date: 27th Sep 2017
    * @description : SFDC1-4353 Get converted currency for a value
    * @company : IHS Markit
    * @param : null
    * @return : Decimal
    */
     public static Decimal getConvertedCurrencyRate(String currentCurrency, String convertedCurrency, Decimal value)
        {
            
            Decimal convertedValue = value;
            if(currentCurrency != convertedCurrency && mapCurrencyType != null && !mapCurrencyType.isEmpty()) {
                if(mapCurrencyType.containsKey(currentCurrency) && mapCurrencyType.containsKey(convertedCurrency)) {				
                    convertedValue *= ((1 / mapCurrencyType.get(currentCurrency)) * (mapCurrencyType.get(convertedCurrency)));
                }
            }
        Decimal convertedValueRounded = convertedValue.setScale(2);
        System.debug('--roundedValue--'+convertedValueRounded);
        return convertedValueRounded;
    }
	
     /**
    * @Author : Digvijay
    * @date: 3/09/2021
    * @description :Adjusted the Product Schdelue List Price as per indian Levy charges
    * @company : IHS Markit
    * @param : OpportunityLineItemSchedule__c
    * @return :Decimal
    */

    public static Decimal setUnitPriceasperLevyCharges(OpportunityLineItemSchedule__c olis, Decimal quantity, Boolean isAnnual) {
        Decimal dividingFactor=1+decimal.valueOf(Label.IndianLevyTax)/100;
        Decimal externalListPricewithlevycharges=0;
        System.debug('Annualized with Indian Levy ' + isAnnual);
        if(!isAnnual) {
            //if(prodschWrap != null && prodschWrap.salesPrice != null) {
			  if(olis != null && olis.SalesPrice__c != null) {
                Decimal listPricewithDiscountaftertaxremoval= (olis.SalesPrice__c / dividingFactor).setScale(2);
                Decimal taxamount=olis.SalesPrice__c - listPricewithDiscountaftertaxremoval;
                Decimal listPricewithoutDiscountaftertaxremoval = listPricewithDiscountaftertaxremoval+olis.DiscountAmount__c;
                externalListPricewithlevycharges = listPricewithoutDiscountaftertaxremoval+taxamount;    
            }
        } else {
            //if(prodschWrap!=null && prodschWrap.AnnualizedUnitPrice != null) {
			  if(olis!=null && olis.AnnualizedUnitPrice__c != null) {
                Decimal salesPrice = olis.AnnualizedTotalAmount__c / olis.Quantity__c;
                Decimal listPricewithDiscountaftertaxremoval= (salesPrice / dividingFactor).setScale(2);
                Decimal taxamount= salesPrice -listPricewithDiscountaftertaxremoval;
                Decimal listPricewithoutDiscountaftertaxremoval = listPricewithDiscountaftertaxremoval + olis.AnnualizedDiscountAmount__c;
                externalListPricewithlevycharges = listPricewithoutDiscountaftertaxremoval+taxamount; 
                System.debug('Annualized Unit Price with Indian Levy ' + externalListPricewithlevycharges);
            }
        }
        
        return externalListPricewithlevycharges;
    }

    public class OppyWrapper {
        @AuraEnabled public Opportunity oppy;
        @AuraEnabled public Boolean hasOpportunityEditAccess;
        @AuraEnabled public Boolean hasRemoveProductAccess;
        @AuraEnabled public Boolean canBeProRated;        
        @AuraEnabled public String isProRated;        
        @AuraEnabled public List<OPSWrapper> lstOPSWrapper;
        @AuraEnabled public List<Id> indianLevyProdList;
    }
}