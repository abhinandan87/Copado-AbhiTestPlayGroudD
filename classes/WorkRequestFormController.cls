//--------------------------------------------------------------------
// @author: Madhusudhan karna
// @date: 06 May 2021
// @param:
// @description: This is used to fetch the WorkRequestForm RecordTypes based on slected
// FormType on related opportunity products records
// @return: None
//--------------------------------------------------------------------
public with sharing class WorkRequestFormController {
    public static Map<Id, String> recordtypemap;
    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: Get the current page opportunity record
    // @return: Opportunity
    //--------------------------------------------------------------------
    @AuraEnabled        
    public static Opportunity getOpportunity( String opportunityId) {
      Opportunity opp= [select OwnerId, Name, Amount, AccountId, CostCenter__c, AISUltimateClient__c,
                        CurrencyIsoCode,Opportunitynum__c from Opportunity where id =: opportunityId]; 
      return opp;
    }
    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: This is used to fetch the WorkRequestForm RecordTypes based on slected
    // FormType on related opportunity products records
    // @return: Map<Id, String>
    //--------------------------------------------------------------------
    @AuraEnabled        
    public static Map<Id, String> fetchRecordTypeValues(String objectName, String opportunityId) {
		List<WorkRequestFormProductMapping__mdt>  workRequestFormTypes= new List<WorkRequestFormProductMapping__mdt>();
		workRequestFormTypes=getFormTypes(opportunityId);
        List<Schema.RecordTypeInfo> recordtypes = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
		Id recordTypeId;
        for(WorkRequestFormProductMapping__mdt rt : workRequestFormTypes) {
			//recordTypeId=getRecordTypeIdbyName(objectName,rt.QualifiedApiName);
			recordTypeId=getRecordTypeIdbyName(objectName,rt.MasterLabel);
			if(recordTypeId!=null){
				recordtypemap.put(recordTypeId, rt.PicklistValueLabel__c);	
			} 
        }
        return recordtypemap;
    }
    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: Get the record Type Id based on Record Type Name
    // @return: Id
    //--------------------------------------------------------------------
	public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName) {
		Id recordTypeId;
		try{
			recordTypeId=Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(strRecordTypeName).getRecordTypeId();
		 }catch(Exception e) {
			system.debug('WRF record Type Error : '+e);
		 }
		 return recordTypeId;
    }
    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: Mapping product record selected WRF checkboxs with WRF recordTypes
    // @return:  List<WorkRequestFormProductMapping__mdt>
    //--------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<WorkRequestFormProductMapping__mdt> getFormTypes(String opportunityId) {
        List<WorkRequestFormProductMapping__mdt> listForms = new List<WorkRequestFormProductMapping__mdt>();
        Map<String, WorkRequestFormProductMapping__mdt> mapformTypes = getFormTypesMap();

        for(Product2 product : getStandardProductsFromOpp(opportunityId)) {
            for(String apiName : mapformTypes.keySet()) {
                if(product.get(apiName) == TRUE && !listForms.contains(mapformTypes.get(apiName))) {
                    listForms.add(mapformTypes.get(apiName));
                    mapformTypes.remove(apiName);
                }
            }
        }
        return listForms;
    }
    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: Get WRF recordType map using the Custom meta data type WorkRequestFormProductMapping__mdt
    // @return: Map<String, WorkRequestFormProductMapping__mdt>
    //--------------------------------------------------------------------
    public static Map<String, WorkRequestFormProductMapping__mdt> getFormTypesMap() {
        Map<String, WorkRequestFormProductMapping__mdt> mapFormTypes = new Map<String, WorkRequestFormProductMapping__mdt>();
        for(WorkRequestFormProductMapping__mdt wrfpm : [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, QualifiedApiName, Label, FieldApiName__c, PicklistValueApi__c, PicklistValueLabel__c from WorkRequestFormProductMapping__mdt ORDER BY FieldApiName__c ASC ]) {
            mapFormTypes.put(wrfpm.FieldApiName__c, wrfpm);
        }
        return mapFormTypes;
    }
    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: Get StandardProducts From Opportunity
    // @return: List<Product2>
    //--------------------------------------------------------------------
    public static List<Product2> getStandardProductsFromOpp(String opportunityId) {
        List<Product2> listProducts = new List<Product2>();
        List<Id> opportunityProduct2Ids = new List<Id>();
        for(OpportunityLineItem oli : [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId =: opportunityId]) {
            opportunityProduct2Ids.add(oli.Product2Id);
        }

        if(opportunityProduct2Ids.size() > 0) {
            listProducts  =  [SELECT Family, Name, WRFPlanningSolutions__c, WRFTIPNetSystem__c, WRFNewUsedRegistration__c,  WRFStat__c, WRFCanada__c,WRFSoftwareServices__c, WRFSalesMatch__c, WRFCommercial__c,
            WRFRecall__c, WRFNVPPOnline__c, WRFListAndTLAS__c, WRFJobTracker__c, WRFAPAC__c, WRFUK__c, WRFContinentalTireAftermarket__c, WRFCVGAndGlobal__c, WRFAnalytics__c,
            WRFAftermarket__c, WRFAustralia__c, WRFLoyalty__c,WRFEmailAudienceProspecting__c FROM Product2 WHERE Id IN : opportunityProduct2Ids];
        }
        return listProducts;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Helper method to get work request form with all fields.
    // @return:  WorkRequestForm__c
    //--------------------------------------------------------------------
    public static WorkRequestForm__c getWorkRequestFormRecord(String recordId) {
        String query = UtilityClass.queryBuilder('WorkRequestForm__c');
        query = query + ' WHERE Id =: recordId';
        System.debug(query);
        WorkRequestForm__c wrf = Database.query(query);
        return wrf;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Helper method to get cloned work request form with all fields.
    // @return:  WorkRequestForm__c
    //--------------------------------------------------------------------
    public static WorkRequestForm__c getClonedRecordFromWRF(String recordId) {
        WorkRequestForm__c wrf = getWorkRequestFormRecord(recordId);
        //.clone(false) -> do not preserve ID
        WorkRequestForm__c cwrf = wrf.clone(false);
        return cwrf;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Helper method to get cloned record Id.
    // @return:  Id
    //--------------------------------------------------------------------
    @AuraEnabled
    public static Id  getCloneRecordId(String recId, String actionName) { 
        
    	Set<String> retiredFormtypes = new Set<String> {'TIPNet','CVGGlobal', 'Sales Match', 'TLAS', 'Software Services'}; 
        WorkRequestForm__c cwrf = getClonedRecordFromWRF(recId);
        String formtype = cwrf.formType__c;
        if(retiredFormtypes.contains(formtype)) {
            throw new AuraHandledException('You are cloning a retired form. Clone is not allowed on retired form type. Please try different form.');
        }       
        
        //Perform processClonedRecord only when action name Clone is perform from UI
        if(actionName.equals('Clone')) {
            cwrf = processClonedRecordFields(cwrf, recId);
        }
        //Perform processClonedRecord only when action name ConvertEstimate is perform from UI
        if(actionName.equals('ConvertEstimate')) {
            cwrf = processConvertEstimateRecordFields(cwrf);
        }
        
        try {
            insertWrf(cwrf);
        }
        catch(AuraHandledException ex) {
            throw new AuraHandledException('Error Processing Cloing the record');
        }
        return cwrf.Id;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Helper method to insert Work Request Form.
    // @return:  WorkRequestForm__c
    //--------------------------------------------------------------------

    public static WorkRequestForm__c insertWRF(WorkRequestForm__c cwrf) {
        insert cwrf;
        return cwrf;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Helper method to update Cloned WRF Object.
    // @return:  WorkRequestForm__c
    //--------------------------------------------------------------------
    public static WorkRequestForm__c processClonedRecordFields(WorkRequestForm__c cwrf, String parentWrfId ) { 
        
        cwrf.isSubmitted__c=false;
        cwrf.RequestStatus__c='Draft';
        cwrf.OwnerId = UserInfo.getuserid();
        // do not copy dates or special instructions
        cwrf.SpecialInstructions__c = null;
        cwrf.SubmittedDate__c = null;
        cwrf.RequestedDueDate__c = null;
        cwrf.ApprovalDate__c = null;
        cwrf.CycleStart__c = null;
        cwrf.EndDate__c = null;
        cwrf.ExpirationDate__c = null;
        cwrf.StartDate__c = null;
        cwrf.SubmittedDateTime__c = null;
        // Append "Clone - " to WRF name if it isn't already there  
        cwrf.Name = cwrf.Name.startsWithIgnoreCase('Clone') ? cwrf.Name : ('Clone - ' + cwrf.Name).left(80);  
        // Assign the name of the parent WRF           
        cwrf.ClonedfromWRF__c = parentWrfId;
        cwrf.ChangeLogs__c = 0;
        // do not clone rejection comments
        cwrf.RejectionComments__c = null;
        // Symbols
        cwrf.SymbolsApprovedDate__c = null;
        cwrf.SymbolApproved__c = false;//SFDC-5577 Removed WRF Decomission Fields
        cwrf.SymbolMerge__c =null;
        cwrf.AIBVRG__c = null;
        cwrf.MASymbols__c = null;
        cwrf.PreservedRolledSymbols__c = null;
        cwrf.RVData__c = null;
        //DUC
        cwrf.DUCApproved__c=false;
        cwrf.DUCApprovalDate__c= null;
        cwrf.DUCApprovalRequired__c = null;
        cwrf.RoyaltyVendor__c = null;
        //field no longer available on forms, so it cannot be unchecked after clone
        cwrf.WorldviewParc__c = false;   
        cwrf.ProgrammerTeam__c = null;
        cwrf.NegotiatedDate__c =  null;
        cwrf.LegacyID__c = null;
        cwrf.LegacyIDUnique__c = null;
        cwrf.LegacySystem__c = null;
        cwrf.LegacyReference__c = null;
        return cwrf;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Process Convert Estimate Record Fields
    // @return:  WorkRequestForm__c
    //--------------------------------------------------------------------
    public static WorkRequestForm__c processConvertEstimateRecordFields(WorkRequestForm__c cwrf) {
        cwrf.isSubmitted__c=false;
        cwrf.RequestStatus__c='Draft';
        cwrf.ChangeLogs__c = 0;
        cwrf.RoyaltyVendor__c = null;
        cwrf.RequestedDueDate__c = null;
        cwrf.ApprovalDate__c = null;
        cwrf.LegacyID__c = null;
        cwrf.LegacyIDUnique__c = null;
        cwrf.LegacySystem__c = null;
        cwrf.LegacyReference__c = null;
        cwrf.ProgrammerTeam__c = null;
        cwrf.NegotiatedDate__c =  null;
        cwrf.SubmittedDate__c = null;
        Set<String> requestTypes = WRFUtility.getRequestTypes();
        for(String requestType : requestTypes) {
            if(requestType!='SoftwareServices__c'){
            cwrf.put(requestType, false);
            }
            if(requestType=='SoftwareServices__c'){
                cwrf.put(requestType,null);
            }
        }
        return cwrf;
    }

    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 16 June 2021
    // @param:
    // @description: get all vindicator types from Vindicator__mdt
    // @return:  List<Vindicator__mdt>
    //--------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<Vindicator__mdt> getVindicators(String drdtType) {
        List<Vindicator__mdt> listVindicators = new List<Vindicator__mdt>();
		listVindicators=[SELECT MasterLabel, DRDTTYPE__c, Order__c, Property__c, Type__c, Value__c FROM 
                        Vindicator__mdt where DRDTTYPE__c =: drdtType order by Order__c ASC];
		
        return listVindicators;
    }

    //--------------------------------------------------------------------
    // @author: Madhusudhan karna
    // @date: 21 June 2021
    // @param:
    // @description: get all SWS Delivery Timings from SWSDeliveryTimings__mdt
    // @return:  List<SWSDeliveryTimings__mdt>
    //--------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<SWSDeliveryTimings__mdt> getSWSDeliveryTimings() {
        List<SWSDeliveryTimings__mdt> listDeliveryTimings = new List<SWSDeliveryTimings__mdt>();
		listDeliveryTimings=[SELECT MasterLabel, CustomWork__c, Order__c ,Product__c, StandardPlusaddon__c, StandardRequest__c FROM 
                        SWSDeliveryTimings__mdt order by Order__c ASC ];
		
        return listDeliveryTimings;
    }
    
    //--------------------------------------------------------------------
    // @author: Anjali
    // @date: 06 July 2021
    // @param:
    // @description: get opportunity products details of an opportunity
    // @return:  List<opportunitylineitem>
    //--------------------------------------------------------------------
    @AuraEnabled(cacheable=true)
    public static List<opportunitylineitem> getProductDetails(Id recordId) {
      List<opportunitylineitem> lineItemsLst = new List<opportunitylineitem>([SELECT Opportunity.Name,Quantity,PricebookEntry.Product2.Family,PricebookEntry.product2.Family__r.Name,PricebookEntry.Product2.Name,PriceBookEntry.UnitPrice,ListPrice FROM Opportunitylineitem WHERE OpportunityId=:recordId]);
        return lineItemsLst;
    }
}