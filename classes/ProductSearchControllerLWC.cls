//@Createdby : Pankhuri Jain
//@date: 28 Feb 2022
/*@description : SFDC-2964 Clone from productSearchController,Changes modified for new LWC components.Removed unused code/methods previous in use.
               : New class referenced in Add/Edit LWC components (SearchProductList and LegalEntitySelection)*/

public without sharing class ProductSearchControllerLWC {
   
    //@last modified: Pankhuri Jain
    //@modifiedDate: 28 Feb 2022  
    //@modifiedDecription : SFDC-2964  Updates done for New Add/Edit Screens. Removed unused code previous in use in Aura components
    
    //@modified: Manish Kumar
    //@modifiedDate: 18th Oct 2021
    //@modifiedDecription: SFDC-4730 Changes for Search products screen to include new fields in the filter criteria
    
    //@modified: Tran-Vu Tran
    //@modifiedDate: 4th April 2019
    //@modifiedDecription: SFDC-1278 allow "Renewal Only" products to be added to Renewal opportunity
    
    //@Author : Paras Dhingra
    //@date: 17th Aug 2017
    //@description : SFDC1-2043 fetch search products based on user filters
    
    @auraEnabled 
    public static List<productSelectorWrapperClass> getProducts(String familyName, String productName,String materialNumber, String businessLine, String subBusinessLine, String profitCenter, String mediaType, String internalProductName,String productGroup,String internalBusinessSegment, String aag) {
                                 
        List<productSelectorWrapperClass> lstProductsToReturn = new List<productSelectorWrapperClass>();
        System.debug('--familyName--'+ familyName);
        List<Product2> lstProductsLegal = new List<Product2>();
        Map<Id,Product2> mapProductIds = new Map<Id,Product2>();
        Set<Id> setExtensionProductIds = new Set<Id>();
        Set<id> setProductIds = new Set<id>();
      
        String availableForSale = '04';
        String renewalOnly = '09'; //SFDC-1278
        String queryBase = 'Select id, name, family__c, family__r.Name, MaterialCode__c, BusinessLine2__r.name, SubBusinessLine__r.name, ProfitCenters__r.Name, InternalProductName__c, MediaType__c, LegalEntity__c,ProductGroup__r.Name, AAG__c, InternalBusinessSegment__c, IPJurisdiction__r.Name from Product2 where';
    
        String queryCommonFilter = ' isActive=true AND (ProductStatus__r.SAPCode__c=:availableForSale OR ProductStatus__r.SAPCode__c=:renewalOnly)';
        if(familyName!=null && !String.IsBlank(familyName)) {
            queryCommonFilter += ' AND family__r.Name like \'%'+familyName+'%\'';
        }
        if(productName!=null && !String.IsBlank(productName)) {                                                                         
            queryCommonFilter+= ' AND Name like \'%'+productName+'%\'';
        }
        if(materialNumber!=null && !String.IsBlank(materialNumber)) {
            queryCommonFilter+= ' AND  MaterialCode__c like \'%'+materialNumber+'%\'';
        }
        if(businessLine!= '--None--' && !String.IsBlank(businessLine)) {
            queryCommonFilter += ' AND BusinessLine2__r.name = \''+businessLine+'\'';
        }
        if(subBusinessLine!= '--None--' && !String.IsBlank(subBusinessLine)) {
            queryCommonFilter += ' AND SubBusinessLine__r.name = \''+subBusinessLine+'\'';
        }
        if(profitCenter!=null && !String.IsBlank(profitCenter)) {
            queryCommonFilter += ' AND ProfitCenters__r.name like \'%'+profitCenter+'%\'';
        }
        if(mediaType!=null && !String.IsBlank(mediaType)) {
            queryCommonFilter += ' AND MediaType__c like \'%'+mediaType+'%\'';
        }
        if(internalProductName!=null && !String.IsBlank(internalProductName)) {
            queryCommonFilter += ' AND internalProductName__c like \'%'+internalProductName+'%\'';
        }
        if(productGroup!=null && !String.IsBlank(productGroup)) {
            queryCommonFilter += ' AND ProductGroup__r.Name like \'%'+productGroup+'%\'';
        }
        //SFDC-4730 Change start
        if(internalBusinessSegment!= '--None--' && !String.IsBlank(internalBusinessSegment)) {
            queryCommonFilter += ' AND internalBusinessSegment__c = \''+internalBusinessSegment+'\'';
        }
        if(aag!= '--None--' && !String.IsBlank(aag)) {
            queryCommonFilter += ' AND AAG__c = \''+aag+'\'';
        }
        String queryFinalLegal = queryBase + queryCommonFilter + ' ORDER BY MaterialCode__c ASC LIMIT 100' ;
        System.debug('--queryFinalLegal--'+ queryFinalLegal);

        mapProductIds = new Map<Id,Product2>((List<Product2>)Database.query(queryFinalLegal)); 
        
        
        //check if products are extended in product extensions
        //query the product extenstions and fetch related extensions only
        if(mapProductIds!=null && !mapProductIds.isEmpty()) {
            
            for(ProductExtensions__c pe : [Select Product__c from ProductExtensions__c where Product__r.isActive=true
                                    AND Status__c='Active' AND Product__c IN: mapProductIds.keySet() ] ) {
            //SFDC-4730 Change end
            setExtensionProductIds.add(pe.Product__c);
        }
            //SFDC-4730 Change start
            for(Product2 prd : mapProductIds.values()){
                setProductIds.add(prd.id);
            }
            //SFDC-4730 Change end
            for(Product2 prod : mapProductIds.values()) {
                productSelectorWrapperClass pswc = new productSelectorWrapperClass();
                                                                                            
                if(setProductIds.contains(prod.id) || setExtensionProductIds.contains(prod.Id)) {
                //SFDC-4730 Change end
                    pswc.isSelected = false;
                    pswc.product = prod;
                    pswc.ProductName = prod.Name;
                    pswc.productId = prod.Id;                  
                    lstProductsToReturn.add(pswc);                   
                }            
            }
        }
        System.debug('--getQueries--'+Limits.getQueries());

        System.debug('--lstProductsToReturn.size before recursion--'+lstProductsToReturn.size());
        
        return lstProductsToReturn;
    }


    //@Author : Paras Dhingra
    //@date: 17th Aug 2017
    //@description : SFDC1-2043 fetch productIds already on opportunity
    @auraEnabled
    public static List<String> getProductsAlreadyInOppy(String oppyId) {
        List<String> lstProductId = new List<String>();
        List<OpportunityLineItem> lstOppyProduct = [Select Product2Id from OpportunityLineItem where OpportunityId=:oppyId];
        if(lstOppyProduct!=null && !lstOppyProduct.isEmpty()) {
            for(OpportunityLineItem oli : lstOppyProduct) {
                lstProductId.add(oli.Product2Id);
            }
        }
        return lstProductId;
    }

    //@Author : Pankhuri Jain
    //@date : 28 Feb 2022
    //@description : Fetch map of all InternalBusiness, related Business and related SubBusiness Lines in sorted order
    @auraEnabled 
    public static Map<String, Map<String, List<String>>> getIbsBsSubBsLines() {
        
        Map<String, Map<String, List<String>>> mapIbsBs = new Map<String, Map<String, List<String>>>();
        
        List<AggregateResult> lstProduct = [Select count(id),InternalBusinessSegment__c ibsName,BusinessLine2__r.Name blName,SubBusinessLine__r.Name sblName from product2 where NOT (InternalBusinessSegment__c LIKE 'zzz%' OR isActive = false OR InternalBusinessSegment__c = '') group by InternalBusinessSegment__c,BusinessLine2__r.Name,SubBusinessLine__r.Name order by InternalBusinessSegment__c,BusinessLine2__r.Name,SubBusinessLine__r.Name];
        
        Map<String, List<String>> mapBsSbs = new Map<String, List<String>>(); 
        List<String> sbsList = new List<String>();
        
        for(AggregateResult prd : lstProduct) {
            mapBsSbs = new Map<String, List<String>>();
            sbsList = new List<String>();
            if(mapIbsBs.containsKey((String)prd.get('ibsName'))) {
                mapBsSbs = mapIbsBs.get((String)prd.get('ibsName'));                
                if(mapBsSbs.containsKey((String)prd.get('blName'))) {
                    sbsList = mapBsSbs.get((String)prd.get('blName'));                      
                }
            }
            sbsList.add((String)prd.get('sblName'));
            mapBsSbs.put((String)prd.get('blName'), sbsList);
            mapIbsBs.put((String)prd.get('ibsName'), mapBsSbs);
        }
        
        return mapIbsBs;

    }
   
}