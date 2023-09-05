//
//@Author : Paras Dhingra
//@date: 17th Aug 2017
//@description : SFDC1-2043 product selector controller for multi-year oppys
//@modified date: 09th Mar 2017
//@modified reason: SFDC1-7092 fixing inconsistent search behavior by adding recursion and soql limit check
//@modified by: Paras Dhingra
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 21 Aug 2018
// @Last Modified Description : SFDC1-8620 Resolving Apex security Risk - CRUD delete, adding isDeleteable() before delete operation
// @Last Modified Company : VERTIBA
// @Last Modified By : Jagadesh Kumar
// @Last Modified Date : 30 Aug 2018
// @Last Modified Description : SFDC1-9462 Add Product Group to Add Products Display/Search
// @Last Modified Company : VERTIBA
// @Last Modified By : Prachi Bhasin
// @Last Modified Date : 20 Sep 2018
// @Last Modified Description : SFDC1-9252 Adding Legal Entity filter for POLK China Users, updated getAllLegalEntities method
// @Last Modified Company : VERTIBA
//
//@LastModified: Tran-Vu Tran
//@LastModifiedDate: 4th April 2019
//@LastModifiedDecription: SFDC-1278 allow "Renewal Only" products to be added to Renewal opportunity
//
public without sharing class productSearchController {
    
    //
    //@Author : Paras Dhingra
    //@date: 17th Aug 2017
    //@description : SFDC1-2043 fetch search products based on user filters
    //@company : IHS Markit
    //@param : String , List<String>, String,String, String, String,String, String, String, String
    //@return : List<ProductEditController.ProductLineItemWrapper>
    //
    //@modified: Tran-Vu Tran
    //@modifiedDate: 4th April 2019
    //@modifiedDecription: SFDC-1278 allow "Renewal Only" products to be added to Renewal opportunity
    //
    //@modified: Manish Kumar
    //@modifiedDate: 18th Oct 2021
    //@modifiedDecription: SFDC-4730 Changes for Search products screen to include new fields in the filter criteria

    @auraEnabled
    public static List<productSelectorWrapperClass> getProducts (String familyName, String productName,
                                                                 String materialNumber, String businessLine, String subBusinessLine, 
                                                                 //SFDC-4730 Change start
                                                                 //String profitCenter, String mediaType, String internalProductName, String legalEntity, String productGroup, String lastMaterialCode, List<productSelectorWrapperClass> lstSearchedSoFar) {
                                                                 String profitCenter, String mediaType, String internalProductName, String legalEntity, String productGroup, String lastMaterialCode, List<productSelectorWrapperClass> lstSearchedSoFar, String internalBusinessSegment, String aag) {
                                                                 //SFDC-4730 Change end
                                                                     List<productSelectorWrapperClass> lstProductsToReturn = new List<productSelectorWrapperClass>();
                                                                     System.debug('--familyName--'+ familyName);
                                                                     List<Product2> lstProductsLegal = new List<Product2>();
                                                                     Map<Id,Product2> mapProductsLegalEntity = new Map<Id,Product2>();
                                                                     Set<Id> setLegaLEntityProductIds = new Set<Id>();
                                                                     //SFDC-4730 Change start
                                                                     Set<id> setProductsLegalEntity = new Set<id>();
                                                                     //SFDC-4730 Change end
                                                                     
                                                                     String availableForSale = '04';
                                                                     String renewalOnly = '09'; // SFDC-1278 allow "Renewal Only" products to be added to Renewal opportunity
                                                                     //SFDC-4730 Change start
                                                                     //String queryBase = 'Select id, name, family__c, family__r.Name, MaterialCode__c, BusinessLine2__r.name, SubBusinessLine__r.name, ProfitCenters__r.Name, InternalProductName__c, MediaType__c, LegalEntity__c,ProductGroup__r.Name from Product2 where';
                                                                     String queryBase = 'Select id, name, family__c, family__r.Name, MaterialCode__c, BusinessLine2__r.name, SubBusinessLine__r.name, ProfitCenters__r.Name, InternalProductName__c, MediaType__c, LegalEntity__c,ProductGroup__r.Name, AAG__c, InternalBusinessSegment__c, IPJurisdiction__r.Name from Product2 where';
                                                                     //SFDC-4730 Change end
                                                                     //String queryLegalFilter = ' (LegalEntity__c=:legalEntity OR ID IN: setLegaLEntityProductIds) ';
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
                                                                     //SFDC-4730 Change start
                                                                     //if(businessLine!=null && !String.IsBlank(businessLine)) {
                                                                         //queryCommonFilter += ' AND BusinessLine2__r.name like \'%'+businessLine+'%\'';
                                                                     if(businessLine!= '--None--' && !String.IsBlank(businessLine)) {
                                                                         queryCommonFilter += ' AND BusinessLine2__r.name = \''+businessLine+'\'';
                                                                     }
                                                                     //if(subBusinessLine!=null && !String.IsBlank(subBusinessLine)) {
                                                                         //queryCommonFilter += ' AND SubBusinessLine__r.name like \'%'+subBusinessLine+'%\'';
                                                                     if(subBusinessLine!= '--None--' && !String.IsBlank(subBusinessLine)) {
                                                                         queryCommonFilter += ' AND SubBusinessLine__r.name = \''+subBusinessLine+'\'';
                                                                     }
                                                                     //SFDC-4730 Change end
                                                                     if(profitCenter!=null && !String.IsBlank(profitCenter)) {
                                                                         queryCommonFilter += ' AND ProfitCenters__r.name like \'%'+profitCenter+'%\'';
                                                                     }
                                                                     if(mediaType!=null && !String.IsBlank(mediaType)) {
                                                                         queryCommonFilter += ' AND MediaType__c like \'%'+mediaType+'%\'';
                                                                     }
                                                                     if(internalProductName!=null && !String.IsBlank(internalProductName)) {
                                                                         queryCommonFilter += ' AND internalProductName__c like \'%'+internalProductName+'%\'';
                                                                     }
                                                                     if(lastMaterialCode!=null && !String.IsBlank(lastMaterialCode)) {
                                                                         queryCommonFilter += ' AND MaterialCode__c > \''+lastMaterialCode+'\'';
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
                                                                     //SFDC-4730 Change end
                                                                    
                                                                     String queryFinalLegal = queryBase + queryCommonFilter + ' ORDER BY MaterialCode__c ASC LIMIT 100' ;
                                                                     System.debug('--queryFinalLegal--'+ queryFinalLegal);
                                                                     //lstProductsLegal = Database.query(queryFinalLegal);
                                                                     mapProductsLegalEntity = new Map<Id,Product2>((List<Product2>)Database.query(queryFinalLegal)); 
                                                                     
                                                                     //for recursive call carry forward the already searched products
                                                                     if(lstSearchedSoFar!=null) {
                                                                         lstProductsToReturn = lstSearchedSoFar;
                                                                     }
                                                                     //check if products are extended in product extensions
                                                                     //query the product extenstions and fetch related extensions only
                                                                     if(mapProductsLegalEntity!=null && !mapProductsLegalEntity.isEmpty()) {
                                                                         //SFDC-4730 Change start
                                                                         //for(ProductExtensions__c pe : [Select Product__c from ProductExtensions__c where LegalEntity__c =:legalEntity AND Product__r.isActive=true
                                                                                                    //AND Status__c='Active' AND Product__c IN: mapProductsLegalEntity.keySet() ] ) {
                                                                         for(ProductExtensions__c pe : [Select Product__c from ProductExtensions__c where Product__r.isActive=true
                                                                                                    AND Status__c='Active' AND Product__c IN: mapProductsLegalEntity.keySet() ] ) {
                                                                         //SFDC-4730 Change end
                                                                         setLegaLEntityProductIds.add(pe.Product__c);
                                                                        }
                                                                         //SFDC-4730 Change start
                                                                         for(Product2 prd : mapProductsLegalEntity.values()){
                                                                             setProductsLegalEntity.add(prd.id);
                                                                         }
                                                                         //SFDC-4730 Change end
                                                                         for(Product2 prod : mapProductsLegalEntity.values()) {
                                                                             productSelectorWrapperClass pswc = new productSelectorWrapperClass();
                                                                             //SFDC-4730 Change start
                                                                             //if(prod.LegalEntity__c ==legalEntity|| setLegaLEntityProductIds.contains(prod.Id)) {                                                                              
                                                                             if(setProductsLegalEntity.contains(prod.id) || setLegaLEntityProductIds.contains(prod.Id)) {
                                                                             //SFDC-4730 Change end
                                                                                 pswc.isSelected = false;
                                                                                 pswc.ProductName = prod.Name;
                                                                                 pswc.productId = prod.Id;
                                                                                 pswc.product = prod;
                                                                                 lstProductsToReturn.add(pswc);
                                                                                 
                                                                                    
                                                                             }
                                                                             // the last material code added in the loop will be the marker for offset    
                                                                             if( prod.MaterialCode__c!=null) {
                                                                                 lastMaterialCode = prod.MaterialCode__c;
                                                                             }
                                                                         }
                                                                     }
                                                                     System.debug('--getQueries--'+Limits.getQueries());
                                                                     //check if queried results have been filtered out and reduced the size of return payload
                                                                     System.debug('--lstProductsToReturn.size before recursion--'+lstProductsToReturn.size());
                                                                     if(lstProductsToReturn.size()<50 && mapProductsLegalEntity!=null && mapProductsLegalEntity.size()==100 ) {
                                                                         //make a recursive call to the method only if soql limit allowance is within range
                                                                         if(Limits.getQueries()<=94) {
                                                                            //SFDC-4730 Change start
                                                                            //lstProductsToReturn = getProducts(familyName, productName,materialNumber, businessLine, subBusinessLine,profitCenter, mediaType, internalProductName, legalEntity, productGroup, lastMaterialCode,lstProductsToReturn); 
                                                                            lstProductsToReturn = getProducts(familyName, productName,materialNumber, businessLine, subBusinessLine,profitCenter, mediaType, internalProductName, legalEntity, productGroup, lastMaterialCode,lstProductsToReturn, internalBusinessSegment, aag);
                                                                            //SFDC-4730 Change end
                                                                         }
                                                                         
                                                                        
                                                                     }
                                                                     System.debug('--lstProductsToReturn.size--'+lstProductsToReturn.size());
                                                                     return lstProductsToReturn;
                                                                 }
    //
    //@Author : Paras Dhingra
    //@date: 17th Aug 2017
    //@description : SFDC1-2043 fetch productIds already on opportunity
    //@company : IHS Markit
    //@param : String 
    //@return : List<String>
    //
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
    //
    //@Author : Paras Dhingra
    //@date: 20 Sep 2017
    //@description : SFDC1-4353 fetch list of all legal entities in the system
    //@company : IHS Markit
    //@param : String 
    //@return : List<LegalEntity__c>
    //
    @auraEnabled 
    public static OpportunityLegalEntityWrapper getAllLegalEntities(String oppyId) {
        //Code change starts for SFDC1-9252: finding country of logged in user      
        User loggedInUser = [Select id, country, Division, name from user where id=:UserInfo.getUserId()];        
        //Code change ends
        System.debug('--OppyId--'+ oppyId);
        OpportunityLegalEntityWrapper  oleWrapObj= new OpportunityLegalEntityWrapper();
        List<LegalEntity__c> lstLegalEntity;
        //Code change starts for SFDC1-9252: if a China user is logged in, find valid legal entities name from custom setting and built query accordingly,
        //else the previous query is used for all other users
        if (loggedInUser.Country == 'China' && loggedInUser.Division == 'Automotive') {
            List<POLKChinaLegalEntities__c> lstChinaLegalEntities= POLKChinaLegalEntities__c.getAll().Values();
            List<String> lstChinaLegalEntityNames = new List<String>();
            for(POLKChinaLegalEntities__c legEntObj :lstChinaLegalEntities) {
                lstChinaLegalEntityNames.add(legEntObj.LegalEntityName__c); 
            }
            lstLegalEntity = [Select Id, Name from LegalEntity__c where Name IN :lstChinaLegalEntityNames AND Status__c='Active' order by Name asc];
        }
        else {
            lstLegalEntity = [Select Id, Name from LegalEntity__c where Status__c='Active' order by Name asc];
        }
        //Code change ends
        Map<String,Id> mapLegalEntityNameId = new Map<String,Id>();
        if(lstLegalEntity!=null && !lstLegalEntity.isEmpty()) {
            for(LegalEntity__c legEnt : lstLegalEntity) {
                mapLegalEntityNameId.put(legEnt.Name,legEnt.Id);
            }
        }
        List<Opportunity> lstOppy = new List<Opportunity> ();
        oleWrapObj.oppyLegalEntity = '--None--';
        if(oppyId!=null && oppyId!='') {
            lstOppy = [Select id, LegalEntity__c,Owner.LegalEntity__c, (Select id from opportunityLineItems) from Opportunity where id=:oppyId];
            if(lstOppy!=null && !lstOppy.isEmpty() ) {
                if(lstOppy[0].LegalEntity__c!=null) {
                    
                    oleWrapObj.oppyLegalEntity = lstOppy[0].LegalEntity__c;    
                }
                else if(lstOppy[0].Owner.LegalEntity__c!=null && lstOppy[0].Owner.LegalEntity__c!='' && mapLegalEntityNameId.containsKey(lstOppy[0].Owner.LegalEntity__c)) {
                    
                    oleWrapObj.oppyLegalEntity = mapLegalEntityNameId.get(lstOppy[0].Owner.LegalEntity__c);
                    System.debug('--oleWrapObj.oppyLegalEntity--'+oleWrapObj.oppyLegalEntity);
                }
                
            }
        }
       
        
        oleWrapObj.lstLegalEntity = lstLegalEntity;
        return oleWrapObj;
    }
    //
    //@Author : Paras Dhingra
    //@date: 21 Sep 2017
    //@description : SFDC1-4353 delete related oppy products and oppy product schedules
    //@company : IHS Markit
    //@param : String
    //@return : String
    //
    @auraEnabled public static  String deleteProductsOnOppy (String oppyId, String newLegalEntity) {
        
        String message = '';
        Savepoint sp = Database.setSavepoint();
        try {
            GlobalConstants.hasAllowedOpportunityProductDeletion = true;
            List<Opportunity> lstOppy = [Select Id, LegalEntity__c,LegalEntity__r.name, (Select Id, Product2.LegalEntity__c, Product2Id,Quantity from OpportunityLineItems where Status__c='New') ,(Select Id,OpportunityProductID__c,Product__c,ExternalListPrice__c,SalesPrice__c,DiscountAmount__c,Quantity__c from OpportunityProductSchedules__r) 
                                            from Opportunity where Id=:oppyId];
            
            if(lstOppy!=null && !lstOppy.isEmpty()) {
                String prevLegalEntity=lstOppy[0].LegalEntity__r.name;
                Opportunity oppy = new Opportunity(id=lstOppy[0].Id);
                oppy.LegalEntity__c = newLegalEntity!=null?newLegalEntity:null;
                update oppy;
                
                //fetch latest legal entity details
                List<Opportunity> newOpp = [Select Id, LegalEntity__c,LegalEntity__r.name, RecordType.Name, OpportunityCountry__r.Name, ShipToCountryNew__c from Opportunity where Id=:oppyId];
                Set<Id> IndianLevyProds = new Set<Id>();
                //SFDC-3428
                Set<String> mediaTypeSet = new Set<String>{'PDF-Unlim Subs','Online Access','Online Download','S/W As A Service','Hosting','S/W Maintenance','Processing Svc','Training','FTP','Publication Electronic','PDF','Mobile App','Data Update/Maintenance','eBooks','EDT/EDI'};
                
                
                if(lstOppy[0].OpportunityLineItems!=null && !lstOppy[0].OpportunityLineItems.isEmpty()) {
                    //collate product ids
                    Set<Id> setOppyProductIdsToDel = new Set<Id>();
                    Set<Id> setValidProducts = new Set<Id>();
                    for(OpportunityLineItem oli : lstOppy[0].OpportunityLineItems) {
                        setOppyProductIdsToDel.add(oli.Product2Id);
                        if(oli.Product2.LegalEntity__c == newLegalEntity) {
                            setValidProducts.add(oli.Product2Id);
                        }
                    }
                    //query product extensions which are related to new legal entity
                    List<ProductExtensions__c> lstProductExtension = [Select Product__c , LegalEntity__r.Name ,  product__r.mediatype__c from ProductExtensions__c where LegalEntity__c=:newLegalEntity
                                                                        and Product__c IN:setOppyProductIdsToDel ];
                    if(lstProductExtension!=null && !lstProductExtension.isEmpty()) {
                        for(ProductExtensions__c prodEx : lstProductExtension) {
                            setValidProducts.add(prodEx.Product__c);
                        }
                    }
                    
                    for (Product2 prd : [Select Id from Product2 where LegalEntity__r.Name = 'IHS Global Pte Ltd' and Mediatype__c IN :mediaTypeSet and ID IN : setValidProducts]){
                      IndianLevyProds.add(prd.Id);
                    }
                    //SFDC-4805 :- moved where  clause conditions with IF condition to optimize Query output
                    for (ProductExtensions__c pext : lstProductExtension ) { //[Select Product__c from ProductExtensions__c where LegalEntity__r.Name = 'IHS Global Pte Ltd' and product__r.mediatype__c IN :mediaTypeSet and Product__c  IN : setValidProducts]){
                       //IndianLevyProds.add(pext.Product__c);
                       if(pext.LegalEntity__r.Name==  'IHS Global Pte Ltd' && mediaTypeSet.Contains(pext.product__r.mediatype__c)) {
                           IndianLevyProds.add(pext.Product__c);
                       }
                    }
                    if(setValidProducts!=null && !setValidProducts.isEmpty()) {
                        //remove valid products from the list
                        setOppyProductIdsToDel.removeAll(setValidProducts);
                    }
                    
                    //SFDC-3428- Indian Levy - Legal Entity change from Edit Prod page.
                    List <OpportunityLineItemSchedule__c> opsList = new List <OpportunityLineItemSchedule__c>();
                    // Check for Indian Opportunity
                    Boolean isIndianOppy = false;
                    if ((newOpp[0].RecordType.Name == 'New Business' && (newOpp[0].OpportunityCountry__r.Name == 'India' || newOpp[0].OpportunityCountry__r.Name == 'IN')) || (newOpp[0].RecordType.Name == 'Renewal' && (newOpp[0].ShipToCountryNew__c == 'India' || newOpp[0].ShipToCountryNew__c == 'IN'))) {
                        isIndianOppy = true;    
                    } 
                    for(OpportunityLineItemSchedule__c ops : lstOppy[0].OpportunityProductSchedules__r) {
                        if (newOpp[0].LegalEntity__r.name == 'IHS Global Pte Ltd' && isIndianOppy && IndianLevyProds.contains(ops.Product__c)) {
                            Decimal salesPrice = ops.ExternalListPrice__c - ops.DiscountAmount__c;
                            Decimal taxamount=((Decimal.valueOf(System.Label.IndianLevyTax)/100) * salesPrice);
                            ops.SalesPrice__c = taxamount + salesPrice;
                            ops.ExternalListPrice__c=ops.ExternalListPrice__c + taxamount;
                       } else {
                             if(prevLegalEntity=='IHS Global Pte Ltd' &&   isIndianOppy && IndianLevyProds.contains(ops.Product__c)) {
                                Decimal dividingFactor=1+decimal.valueOf(Label.IndianLevyTax)/100;
                                Decimal listPricewithDiscountaftertaxremoval= (ops.SalesPrice__c / dividingFactor).setScale(2);
                                Decimal taxamount=(ops.SalesPrice__c -listPricewithDiscountaftertaxremoval);
                                ops.ExternalListPrice__c=ops.ExternalListPrice__c-taxamount;
                             } 
                          ops.SalesPrice__c = ops.ExternalListPrice__c - ops.DiscountAmount__c;
                       }
                       ops.TotalPrice__c = ops.SalesPrice__c * ops.Quantity__c;
                       opsList.add(ops); 
                    }
                     if(!opsList.isEmpty()){
                       Update opsList;
                     }  
                    
                    //check if deletion list still has products 
                    if(setOppyProductIdsToDel!=null && !setOppyProductIdsToDel.isEmpty()) {
                        //create a list of opportunity line items to delete
                        List<OpportunityLineItem> lstOppyLineItemToDelete = new List<OpportunityLineItem>();
                        for(OpportunityLineItem oli : lstOppy[0].OpportunityLineItems) {
                            if(setOppyProductIdsToDel.contains(oli.Product2Id)) {
                                lstOppyLineItemToDelete.add(oli);
                            } 
                        }
                        
                        if(lstOppyLineItemToDelete!=null && !lstOppyLineItemToDelete.isEmpty() && OpportunityLineItem.sObjectType.getDescribe().isDeletable()) {
                            delete lstOppyLineItemToDelete;
                        }
                    }
                }
            }
            message = 'Related products updated!!';
            GlobalConstants.hasAllowedOpportunityProductDeletion = false;
        }
        catch(Exception ex) {
            System.debug('Exception caught in deleteProductsOnOppy');
            message = 'Error Occurred ' +ex; 
            Database.rollback(sp);
        }
        return message;
    }
    
    //
    //@Author : Paras Dhingra
    //@date: 21 Sep 2017
    //@description : SFDC1-4353 Wrapper class for Opportunity legal entity
    //@company : IHS Markit
    //
    public class OpportunityLegalEntityWrapper {
        @auraEnabled public string oppyLegalEntity;
        @auraEnabled public List<LegalEntity__c> lstLegalEntity;
    }
    //SFDC-4730 Change start
    //@Author : Manish Kumar
    //@date: 14th Sep 2021
    //@description : SFDC-4730 fetch list of all Internal Business Segments in the system
    //@company : IHS Markit
    //@param : Void 
    //@return : List<List<string>>
    //
    @auraEnabled 
    public static List<List<string>> getAllInternalBusinessSegmentAAG() {      
        
        List<Product2> lstProduct = [Select InternalBusinessSegment__c from product2 where NOT (InternalBusinessSegment__c LIKE 'zzz%' OR isActive = false) ];        
		List<String> lstInternalBusinessSegment = new List<String>();
        Set<String> setInternalBusinessSegment = new Set<String>();
        List<List<String>> result = new List<List<String>>();
        if(lstProduct!=null && !lstProduct.isEmpty()) {
            for(Product2 prdct : lstProduct) {
                setInternalBusinessSegment.add(prdct.InternalBusinessSegment__c);
            }
        }
        
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Product2.AAG__c.getDescribe();
		List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : picklistValues){
			pickListValuesList.add(pickListVal.getLabel());
		}
        
        lstInternalBusinessSegment.addAll(setInternalBusinessSegment);
        lstInternalBusinessSegment.sort();
        pickListValuesList.sort();
        
        result.add(lstInternalBusinessSegment);
        result.add(pickListValuesList);
        return result;
    }
    //@Author : Manish Kumar
    //@date: 14th Sep 2021
    //@description : SFDC-4730 fetch list of all Business Lines on IBS selection
    //@company : IHS Markit
    //@param : String 
    //@return : List<string>
    //
    @auraEnabled 
    public static List<string> getAllBusLineOnIBSSelection(string intBusSegment) {      
        List<Product2> lstProduct = [Select id, BusinessLine2__r.Name from product2 where internalBusinessSegment__c = :intBusSegment and isActive = true];        
		List<String> lstBusinessLine = new List<String>();
        Set<String> setBusinessLine = new Set<String>();
        if(lstProduct!=null && !lstProduct.isEmpty()) {
            for(Product2 prdct : lstProduct) {
                setBusinessLine.add(prdct.BusinessLine2__r.Name);
            }
        }
		lstBusinessLine.addAll(setBusinessLine);
        lstBusinessLine.sort();
        return lstBusinessLine;
    }
    
    //@Author : Manish Kumar
    //@date: 15th Sep 2021
    //@description : SFDC-4730 fetch list of all Sub Business Lines
    //@company : IHS Markit
    //@param : String, String 
    //@return : List<string>
    //
    @auraEnabled 
    public static List<string> getAllSubBusLineOnBLSelection(string intBusSegment, string busLine) {
        BusinessLine__c businessLine = [Select id from BusinessLine__c where name = :busLine];
        List<Product2> lstProduct = [Select id, SubBusinessLine__r.Name from product2 where internalBusinessSegment__c = :intBusSegment and BusinessLine2__c = :businessLine.id and isActive = true];        
		List<String> lstSubBusinessLine = new List<String>();
        Set<String> setSubBusinessLine = new Set<String>();
        if(lstProduct!=null && !lstProduct.isEmpty()) {
            for(Product2 prdct : lstProduct) {
                setSubBusinessLine.add(prdct.SubBusinessLine__r.Name);
            }
        }
		lstSubBusinessLine.addAll(setSubBusinessLine);
        lstSubBusinessLine.sort();
        return lstSubBusinessLine;
    }
    //SFDC-4730 Change end
}