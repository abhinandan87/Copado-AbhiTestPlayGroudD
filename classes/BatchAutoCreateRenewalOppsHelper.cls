//-----------------------------
// @author: Harshit Singhal
// @date: 24 Aug 2020
// @description: SFDC-3186 Helper class for BatchAutoCreateRenewalOpps batch class.
//-----------------------------
public class BatchAutoCreateRenewalOppsHelper {
    //public static final String ORDERFORMCONTRACTRECORDTYPENAME = 'Order Form';
    public static List<String> contractRecordTypes = new List<String> {'Order Form','Consulting'};
    public static final String LOSTOPPPRODSTATUS = 'Lost';    
    public static List<String> validOppRecordTypes = new List<String> {'New Business','Renewal'};
    public static List<String> finalAAGProds = new List<String>(); 
    public static Set<Id> IndianLevyProds = new Set<Id>(); 
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020    
    // @description: SFDC-3186 Property to hold all active criteria based mappings and fetch them from AutomatedRenewalsMappings__c custom setting.
    //------------------------------
    public static List<AutomatedRenewalsMappings__c> renewalsCriteriaMappingCSList {
        get {
            if(renewalsCriteriaMappingCSList==null) {
                renewalsCriteriaMappingCSList = new List<AutomatedRenewalsMappings__c>();
                for(AutomatedRenewalsMappings__c fieldMapObj: AutomatedRenewalsMappings__c.getAll().values()) {
                    if(fieldMapObj.Active__c && fieldMapObj.CriteriaMapping__c && fieldMapObj.SourceObject__c!=null && fieldMapObj.SourceField__c!=null && fieldMapObj.SourceValue__c!=null) {
                        renewalsCriteriaMappingCSList.add(fieldMapObj);
                    }
                }
            }
            return renewalsCriteriaMappingCSList;
        }
        set;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020    
    // @description: SFDC-3186 Property to hold valid Product Global Segments that are considered as Financial Services products.
    //------------------------------
    public static List<String> validProdGlobalSegments {
        get {
            if(validProdGlobalSegments==null) {
                validProdGlobalSegments = new List<String>();
                for(AutomatedRenewalsMappings__c criteriaMapObj: renewalsCriteriaMappingCSList) {
                    if(criteriaMapObj.SourceObject__c=='Product' && criteriaMapObj.SourceField__c=='Global Segment' && String.isNotBlank(criteriaMapObj.SourceValue__c)) {
                        validProdGlobalSegments.add(criteriaMapObj.SourceValue__c);
                    }
                }
            }
            return validProdGlobalSegments;
        }
        set;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020    
    // @description: SFDC-3186 Property to hold valid Product AAG values that should be renewed.
    //------------------------------
    public static List<String> validSubsProdAAGs {
        get {
            if(validSubsProdAAGs==null) {
                validSubsProdAAGs = new List<String>();
                for(AutomatedRenewalsMappings__c criteriaMapObj: renewalsCriteriaMappingCSList) {
                    if(criteriaMapObj.SourceObject__c=='Product' && criteriaMapObj.SourceField__c=='AAG' && String.isNotBlank(criteriaMapObj.SourceValue__c) && criteriaMapObj.RuleName__c=='Subscription') {
                        validSubsProdAAGs.add(criteriaMapObj.SourceValue__c);
                    }
                }
            }
            return validSubsProdAAGs;
        }
        set;
    }
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 17 June 2021    
    // @description: SFDC-3925 Property to hold valid Non Subscription(Transaction/Consulting) Product AAG values that should be renewed.
    //------------------------------
    public static List<String> validNonSubsProdAAGs {
        get {
            if(validNonSubsProdAAGs==null) {
                validNonSubsProdAAGs = new List<String>();
                for(AutomatedRenewalsMappings__c criteriaMapObj: renewalsCriteriaMappingCSList) {
                    if(criteriaMapObj.SourceObject__c=='Product' && criteriaMapObj.SourceField__c=='AAG' && String.isNotBlank(criteriaMapObj.SourceValue__c) && criteriaMapObj.RuleName__c=='Non-Subscription') {
                        validNonSubsProdAAGs.add(criteriaMapObj.SourceValue__c);
                    }
                }
            }
            return validNonSubsProdAAGs;
        }
        set;
    }
    //-----------------------------
    // @author: Sharique Iqbal
    // @date: 17 June 2021    
    // @description: SFDC-3925 Property to hold Products(Subs/SubVar/Transaction/Consulting) AAG values that should be renewed.
    //------------------------------
    public static List<String> allProdAAGs {
        get {
            if(allProdAAGs==null) {
                allProdAAGs = new List<String>();
                for(AutomatedRenewalsMappings__c criteriaMapObj: renewalsCriteriaMappingCSList) {
                    if(criteriaMapObj.SourceObject__c=='Product' && criteriaMapObj.SourceField__c=='AAG' && String.isNotBlank(criteriaMapObj.SourceValue__c)) {
                        allProdAAGs.add(criteriaMapObj.SourceValue__c);
                    }
                }
            }
            return allProdAAGs;
        }
        set;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020    
    // @description: SFDC-3186 Property to hold all active field mappings for objects - Opportunity, Opportunity Product, Opportunity Product Schedule, Opportunity Team, Opportunity Contact Role, Opportunity Splits. Fetch these from AutomatedRenewalsMappings__c custom setting.
    //------------------------------
    public static List<AutomatedRenewalsMappings__c> renewalsFieldMappingCSList {
        get {
            if(renewalsFieldMappingCSList==null) {
                renewalsFieldMappingCSList = new List<AutomatedRenewalsMappings__c>();
                for(AutomatedRenewalsMappings__c fieldMapObj: AutomatedRenewalsMappings__c.getAll().values()) {
                    if(fieldMapObj.Active__c && fieldMapObj.FieldMapping__c && fieldMapObj.TargetObject__c!=null && fieldMapObj.TargetField__c!=null && fieldMapObj.SourceObject__c!=null && fieldMapObj.SourceField__c!=null) {
                        renewalsFieldMappingCSList.add(fieldMapObj);
                    }
                }
            }
            return renewalsFieldMappingCSList;
        }
        set;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020    
    // @description: SFDC-3186 Property to hold all active value based mappings. Fetch them from AutomatedRenewalsMappings__c custom setting.
    //------------------------------
    public static List<AutomatedRenewalsMappings__c> renewalsValueMappingCSList {
        get {
            if(renewalsValueMappingCSList==null) {
                renewalsValueMappingCSList = new List<AutomatedRenewalsMappings__c>();
                for(AutomatedRenewalsMappings__c fieldMapObj: AutomatedRenewalsMappings__c.getAll().values()) {
                    if(fieldMapObj.Active__c && fieldMapObj.ValueMapping__c && fieldMapObj.TargetField__c!=null && fieldMapObj.TargetValue__c!=null && fieldMapObj.SourceField__c!=null && fieldMapObj.SourceValue__c!=null) {
                        renewalsValueMappingCSList.add(fieldMapObj);
                    }
                }
            }
            return renewalsValueMappingCSList;
        }
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) List<Opportunity> - Opps that are supposed to be processed by Renewals batch for validations and creations process.
    // 			2) Map<Id,RenewalsLogWrapper> - Map of opp Id and log Wrapper class instance. This is used to collect log info at each step in Renewals validation and creation process.
    // @description: SFDC-3186 This method is the master/main method of Renewal opps validation and creation process. 
    // 					- It first validates all the input opps to check if renewal opp should be created. All invalid opps are skipped for creation and logged in as exceptions in their respective RenewalsLogWrapper instances.
    // 					- Then, for all valid opps, renewal opp and their related records are created. All success and error opps are logged in their respective RenewalsLogWrapper instances.
    // @return: 
    // 			Map<Id,RenewalsLogWrapper> - Map of opp Id and their RenewalsLogWrapper instance; Each wrapper instance has all the relevant log variables populated from master opp's renewal creation process context.
    //------------------------------
    public static Map<Id,RenewalsLogWrapper> validateAndCreateRenewalOpps(List<Opportunity> oppList, Map<Id,RenewalsLogWrapper> wrapperMap) {
        
        //Collect all data relevant for opp validation
        Map<Id,Opportunity> toProcessOppMap = BatchAutoCreateRenewalOppsHelper.collectDataForOppValidation(oppList);
        //SFDC-4805
        List<Id> listProdIds = new List<Id>();
        for(Opportunity op:toProcessOppMap.values()) {
            for(OpportunityLineItem oli: op.OpportunityLineItems) { 
                listProdIds.add(oli.Product2Id);
            }
        }
        
        //SFDC-3428
        //SFDC-4805 :- added check for Product Id
        Set<String> mediaTypeSet = new Set<String>{'PDF-Unlim Subs','Online Access','Online Download','S/W As A Service','Hosting','S/W Maintenance','Processing Svc','Training','FTP','Publication Electronic','PDF','Mobile App','Data Update/Maintenance','eBooks','EDT/EDI'};
        for (Product2 prd : [Select Id from Product2 where LegalEntity__r.Name = 'IHS Global Pte Ltd' and Mediatype__c IN :mediaTypeSet and Id IN: listProdIds]){
           IndianLevyProds.add(prd.Id);
        }
        for (ProductExtensions__c pext : [Select Product__c from ProductExtensions__c where LegalEntity__r.Name = 'IHS Global Pte Ltd' and product__r.mediatype__c IN :mediaTypeSet and Product__c IN : listProdIds]){
           IndianLevyProds.add(pext.Product__c);
        }
        
        //Validate each opp
        Map<Id,Opportunity> validOppsMap = new Map<Id,Opportunity>();        
        for(Opportunity opp: toProcessOppMap.values()) {
            RenewalsLogWrapper oppWrpObj = wrapperMap!=null && wrapperMap.containsKey(opp.Id) ? wrapperMap.get(opp.Id) : null;
            if(!BatchAutoCreateRenewalOppsHelper.isOppInvalidForRenewal(opp,oppWrpObj)) {
                //Send these opps for auto-renewal creation
                validOppsMap.put(opp.Id,opp);
            }
        }
        //Check if renewals pre-exist for valid opps. If yes, then remove those opps from valid dataset.        
        Set<Id> setOppIdWithRenewals = BatchAutoCreateRenewalOppsHelper.getOppsWithExistingRenewals(validOppsMap);
        System.debug('setOppIdWithRenewals='+setOppIdWithRenewals);
        for(Id oppWithRenewalId: setOppIdWithRenewals) {
            validOppsMap.remove(oppWithRenewalId);
            
            //Set wrapper variables
            RenewalsLogWrapper oppWrpObj = wrapperMap!=null && wrapperMap.containsKey(oppWithRenewalId) ? wrapperMap.get(oppWithRenewalId) : null;
            if(oppWrpObj!=null) {
                oppWrpObj.renewalPreExists = true;
                oppWrpObj.isException = true;
                oppWrpObj.exceptionReason += 'Pre-existing Renewal check failed, rule is - For an opp, renewal opp should not pre-exist \n';
                oppWrpObj.isProcessed = true;
            }
        }
        if(validOppsMap!=null && validOppsMap.size()>0) {
            //Collect master data for valid opps
            List<Opportunity> masterOppsList = BatchAutoCreateRenewalOppsHelper.queryMasterOpps(validOppsMap);
            
            //Create Renewal opp and child data
            BatchAutoCreateRenewalOppsHelper.createRenewalOpportunities2(masterOppsList, wrapperMap);            
        }
        
        return wrapperMap;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) List<Opportunity> - Input Opps that are supposed to be processed by Renewals batch for validations/business checks.
    // @description: SFDC-3186 Method to gather required data from opp, opp line items, contracts in order to perform opp business criteria checks.
    // @return: 
    // 			Map<Id,Opportunity> - Map of opp id and opp record
    //------------------------------
    public static Map<Id,Opportunity> collectDataForOppValidation(List<Opportunity> oppList) {
        Map<Id,Opportunity> outputMap = new Map<Id,Opportunity>([SELECT Id,RecordTypeId,RecordType.Name,StageName,SourceSystem__c,GlobalSegments__c,OwnerId,Owner.IsActive,
                                                                 DoesThisAutoRenewalHaveChanges__c, AutoRenewStopped__c, AutoRenewal__c,
                                                                 ContractBeingRenewed__c, ContractBeingRenewed__r.RecordTypeId, ContractBeingRenewed__r.RecordType.Name, ContractBeingRenewed__r.RenewalTerm__c, ContractBeingRenewed__r.BillingFrequency__c,ContractBeingRenewed__r.AutoRenewal__c,
                                                                 (SELECT Id,Product2Id,Product2.AAG__c,Product2.Division__c FROM OpportunityLineItems WHERE Product2Id!=null),
                                                                 (SELECT Id,RenewalTerm__c,BillingFrequency__c,AutoRenewal__c,RecordType.Name FROM Contracts__r WHERE RecordType.Name IN :contractRecordTypes AND Active__c=true LIMIT 1)
                                                                 FROM Opportunity 
                                                                 WHERE Id IN :oppList]);
        
        return outputMap;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Opportunity - Opp record that should be validated
    // 			2) RenewalsLogWrapper - Wrapper instance for the input opp. This wrapper stores the exceptions if any found in the validation check.
    // @description: SFDC-3186 Method to check if opp is inavlid for renewal creation as per given business rules. This method validates the opp, its products and the related OF contract(if needed).
    //     
    // LastModifiedDate: 22 Oct 2020
    // LastModifiedBy: Harshit Singhal
    // LastModifiedDesciption: SFDC-3372 Updated contract level validations logic to add non-billable evergreen contract exception
    // 
    // @return: 
    // 			Boolean - Returns true if opp is invalid
    //------------------------------
    public static  Boolean isOppInvalidForRenewal(Opportunity opp, RenewalsLogWrapper oppWrpObj) {
        Boolean isException = false;
        Boolean isInvalidOpp = false;
        Boolean isInvalidOppPoduct = false;
        Boolean isInvalidContract = false;
        
        //Check validations at opp level
        isInvalidOpp = !(BatchAutoCreateRenewalOppsHelper.isOppValid(opp, oppWrpObj));
        if(!isInvalidOpp) {
            //Check validations at opp product level            
            if(!BatchAutoCreateRenewalOppsHelper.hasValidOppProducts(opp.OpportunityLineItems,oppWrpObj)) {
                isInvalidOppPoduct = true;
                oppWrpObj.isInValidOppProducts = true;
                oppWrpObj.isException = true;                
                oppWrpObj.exceptionReason += 'Opp Product Level Validations failed, rule is - All non-lost products must belong to Financial Services Global Segment';
                oppWrpObj.isProcessed = true;
                if (oppWrpObj.isOrderFormContract && oppWrpObj.hasNoSubscriptionProd) {
                    oppWrpObj.exceptionReason += ', There should atleast be one subscription non-lost product for Order Form Contract \n';
                } else if (oppWrpObj.isConsultingContract && oppWrpObj.hasNoValidConsultingProducts) {
                    oppWrpObj.exceptionReason += ', There should atleast be one transaction/Consulting/Subscription/SubscriptionVar non-lost product for Consulting Contract \n';   
                }
            }
        }
        
        //Check contract level validations
        if(!isInvalidOpp && !isInvalidOppPoduct) {            
            if(!BatchAutoCreateRenewalOppsHelper.hasValidContract(opp,oppWrpObj)) {
                isInvalidContract = true;
                oppWrpObj.isInValidContract = true;
                oppWrpObj.isException = true;
                
                oppWrpObj.exceptionReason += 'Contract Level Validations failed, rules are - \n';
                oppWrpObj.exceptionReason += '1) An auto-renewal without change opportunity should not have Evergreen and Non-Billable orginating contract.\n';
                oppWrpObj.exceptionReason += '2) For any other renewal or new business opportunity:	\n'; 
                oppWrpObj.exceptionReason += 'a) Opportunity should have an active order form/Consulting contract, \n'; 
                oppWrpObj.exceptionReason += 'b) Renewal Term on this contract should not be One-Time Expiring, \n';
                oppWrpObj.exceptionReason += 'c) This contract should not have Renewal Term as Evergreen and Billing Frequency as Non-Billable.';
                    
                oppWrpObj.exceptionReason += 'd) Auto-renewal should be checked for Consulting Contract ';
                oppWrpObj.isProcessed = true;                
            }
        }      
        
        isException = isInvalidOpp || isInvalidOppPoduct || isInvalidContract;
        return isException;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Opportunity - Opp record that should be validated
    // 			2) RenewalsLogWrapper - Wrapper instance for the input opp. This wrapper stores the exceptions if any found in the validation check.
    // @description: SFDC-3186 Method to check opportunity object level filter criteria to find if opp is valid for renewal.
    // @return: 
    // 			Boolean - Returns true if opp is valid
    //------------------------------
    public static Boolean isOppValid(Opportunity opp, RenewalsLogWrapper oppWrpObj) {
        Boolean isOppValidForRenewal = (opp.StageName.contains('6WP') && BatchAutoCreateRenewalOppsHelper.validOppRecordTypes.contains(opp.RecordType.Name) && opp.SourceSystem__c!='SAP');
        // SFDC-4799
		/*Boolean isOppOwnerActive = opp.Owner.IsActive;
        if(!isOppOwnerActive) {
            oppWrpObj.isInValidOpp = true;
            oppWrpObj.isException = true;
            oppWrpObj.isOwnerInactive = true;
            oppWrpObj.exceptionReason += 'Opp Level Validation failed, rule is- Opportunity Owner should be active \n';
            oppWrpObj.isProcessed = true;
        }*/
        if(!isOppValidForRenewal) {
            oppWrpObj.isInValidOpp = true;
            oppWrpObj.isException = true;
            oppWrpObj.exceptionReason += 'Opp Level Validation failed, rule is - Stage=6WP, RecordType=New Business or Renewal, External Source System!=SAP \n';
            oppWrpObj.isProcessed = true;
        }
        if(opp.Contracts__r != null && !opp.Contracts__r.isEmpty()) {
            if (opp.Contracts__r[0].RecordType.Name == 'Order Form'){
                oppWrpObj.isOrderFormContract = true;
            } else {
                oppWrpObj.isConsultingContract = true; 
            }
        } else if (opp.ContractBeingRenewed__c != null) {
            if (opp.ContractBeingRenewed__r.RecordType.Name == 'Order Form'){
                oppWrpObj.isOrderFormContract = true;
            } else {
                oppWrpObj.isConsultingContract = true; 
            }
        } 
        Boolean isOppValidResult = isOppValidForRenewal;// && isOppOwnerActive;
        return isOppValidResult;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) List<OpportunityLineItem> - List of opp products that should be validated
    // 			2) RenewalsLogWrapper - Wrapper instance for the input opp. This wrapper stores the exceptions if any found in the validation check.
    // @description: SFDC-3186 Method to check rules at opportunity product object level filter criteria to find if opp is valid for renewal
    // @return: 
    // 			Boolean - Returns true if opp has atleast one valid products for renewal
    //------------------------------
    public static Boolean hasValidOppProducts(List<OpportunityLineItem> oppLineItemList, RenewalsLogWrapper oppWrpObj) {
        Boolean hasValidOppProductsResult = false;
        Boolean hasNonFinancialProducts = false;
        Boolean hasSubscriptionProducts = false;
        Boolean hasFinancialProducts = false;
        Boolean hasValidConsultingProducts = false; 
        for(OpportunityLineItem oliObj: oppLineItemList) {
            //Check if atleast one product is with AAG=Sub/Subvar
            if(BatchAutoCreateRenewalOppsHelper.validSubsProdAAGs.contains(oliObj.Product2.AAG__c)) {
                hasSubscriptionProducts = true;
            }
            //Check if atleast one product is with AAG=Transaction/Consulting SFDC-3925
			// Sub/Subvar also included in Consulting Contract - SFDC-5490
			if(BatchAutoCreateRenewalOppsHelper.allProdAAGs.contains(oliObj.Product2.AAG__c)) {
                hasValidConsultingProducts = true;
            }
            //Check if all products have Global Segment='Financial*'
            if(!BatchAutoCreateRenewalOppsHelper.validProdGlobalSegments.contains(oliObj.Product2.Division__c)) {
                hasNonFinancialProducts = true;                        
            }
            else {
                hasFinancialProducts = true;
            }
        }
        /* Consider an OppProd as valid if:
		   1.Contract is Order form with atleast 1 Sub/Subvar Prods (OR)
		   2.Contract is Cons form with atleast 1 trans/Cons Prods 
		*/
            
        if(!hasNonFinancialProducts && ((oppWrpObj.isOrderFormContract && hasSubscriptionProducts) || (oppWrpObj.isConsultingContract && hasValidConsultingProducts))) {
            hasValidOppProductsResult = true;
        }
        //Set Wrapper variables
        if(oppWrpObj!=null) {
            oppWrpObj.hasAnyNonFinProd = hasNonFinancialProducts;
            oppWrpObj.hasNoSubscriptionProd = !hasSubscriptionProducts;
            oppWrpObj.hasNoValidConsultingProducts = !hasValidConsultingProducts;
            oppWrpObj.hasMixedProducts = hasNonFinancialProducts && hasFinancialProducts;
        }
        return hasValidOppProductsResult;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Opportunity - Opp record
    // 			2) RenewalsLogWrapper - Wrapper instance for the opp. This wrapper stores the exceptions if any found in the validation check.
    // @description: SFDC-3186 Method to check if contract should be checked while validating an opp for renewal creation
    // @return: 
    // 			Boolean - Returns true if the contract should be validated for the given input opp
    //------------------------------
    public static Boolean shouldCheckNewContract(Opportunity opp) {
        Boolean shdChckContract = (opp.RecordType.Name=='New Business' || (opp.RecordType.Name=='Renewal' && (opp.DoesThisAutoRenewalHaveChanges__c || opp.AutoRenewStopped__c || !opp.AutoRenewal__c)));
        return shdChckContract;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Opportunity - Opp record(with related Contract record)
    // 			2) RenewalsLogWrapper - Wrapper instance for the opp. This wrapper stores the exceptions if any found in the validation check.
    // @description: SFDC-3186 Method to check rules at contract level to find if opp is valid for renewal
    // 
    // LastModifiedDate: 22 Oct 2020
    // LastModifiedBy: Harshit Singhal
    // LastModifiedDesciption: SFDC-3372 Added a new contract level exception when new contract/originating contract is Non-Billable and Evergreen
    // 
    // @return: 
    // 			Boolean - Returns true if the contract is valid
    //------------------------------
    public static Boolean hasValidContract(Opportunity opp, RenewalsLogWrapper oppWrpObj) {
        Boolean shdCheckNewContract = shouldCheckNewContract(opp);       
        Boolean hasValidContract = true;        
        Boolean hasActiveOFContract = false;
        Boolean hasOneTimeExpContract = false;
        Boolean hasNonBillableEvergreenContract = false;
        Boolean validateConsultingContract = false;
                 
        //Check originating contract
        if(opp.RecordType.Name=='Renewal' && opp.AutoRenewal__c && !opp.DoesThisAutoRenewalHaveChanges__c) {
            hasNonBillableEvergreenContract = opp.ContractBeingRenewed__c != null && (opp.ContractBeingRenewed__r.RecordType.Name == 'Order Form' || opp.ContractBeingRenewed__r.RecordType.Name == 'Consulting') && opp.ContractBeingRenewed__r.RenewalTerm__c == 'Non-Billable' && opp.ContractBeingRenewed__r.BillingFrequency__c == 'Evergreen';
            oppWrpObj.hasNonBillableEvergreenContract = hasNonBillableEvergreenContract;
            // Check for valid Cons Contract if it is parent
            validateConsultingContract = oppWrpObj.isConsultingContract && opp.ContractBeingRenewed__c != null && opp.ContractBeingRenewed__r.RenewalTerm__c != 'One-time Expiring' && opp.ContractBeingRenewed__r.AutoRenewal__c;
        }
                
        if(shdCheckNewContract) {            
            if(opp.Contracts__r!=null && opp.Contracts__r.size() > 0) {
                hasActiveOFContract = true;
                for(Contract ctrct: opp.Contracts__r) {
                    if(ctrct.RenewalTerm__c=='One-time Expiring') {
                        hasOneTimeExpContract = true;
                        oppWrpObj.hasOneTimeContract = true;
                    }
                    if(ctrct.RenewalTerm__c == 'Evergreen' && ctrct.BillingFrequency__c == 'Non-Billable') {
                        hasNonBillableEvergreenContract = true;
                        oppWrpObj.hasNonBillableEvergreenContract = true;
                    }
                    // Check for valid Cons Contract if it is child
                    if(oppWrpObj.isConsultingContract && ctrct.AutoRenewal__c) {
                        validateConsultingContract = true;
                    }
                }
            }            
        }    
        if((shdCheckNewContract && !hasActiveOFContract) || hasOneTimeExpContract || hasNonBillableEvergreenContract) {
            hasValidContract = false;
        }
        // Consulting Contract not matching bussiness criteria
        if(oppWrpObj.isConsultingContract && !validateConsultingContract) {
            hasValidContract = false;
        }
        
        return hasValidContract;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Opportunity> - Map of opp Id and opp
    // @description: SFDC-3186 Method to find opps that have pre-existing renewals
    // @return: 
    // 			Set<Id> - Returns set of opp Ids for  which renewal pre-exists
    //------------------------------
    public static Set<Id> getOppsWithExistingRenewals(Map<Id,Opportunity> validOppsMapInput) {
        Set<Id> oppIdsWithExistingRenewals = new Set<Id>();
        if(validOppsMapInput!=null && validOppsMapInput.size() > 0) {
            for(Opportunity existingRenewalOpp: [SELECT Id,PreviousYearOpportunitylink__c FROM Opportunity WHERE PreviousYearOpportunitylink__c IN :validOppsMapInput.keySet() AND RecordType.Name='Renewal']) {
                oppIdsWithExistingRenewals.add(existingRenewalOpp.PreviousYearOpportunitylink__c);                    
            }
        }
        return oppIdsWithExistingRenewals;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) String - Name of object for which fields are to be queried
    // @description: SFDC-3186 Method to fetch field names to query for an object
    // @return: 
    // 			String - Returns string of comma-separated field names
    //------------------------------
    public static String getQueryFieldsPerObject(String objName) {
        String outputStr = '';
        Set<String> mandatoryFields = new Set<String>();
        Set<String> finalSet = new Set<String>();
        switch on objName {
            when 'Opportunity' {
                mandatoryFields = new Set<String>{'Id', 'RecordTypeId', 'RecordType.Name', 'DoesThisAutoRenewalHaveChanges__c', 'AutoRenewStopped__c', 'AutoRenewal__c', 'ProcessedContractNum__c', 'SAPContractNumber__c', 'ContractBeingRenewed__c', 'ContractBeingRenewed__r.ContractNumber', 'ContractBeingRenewed__r.RenewalTerm__c', 'ContractBeingRenewed__r.TerminationNotice__c', 'ContractEndDate__c', 'AccountId', 'Account.Name', 'CurrencyIsoCode','LegalEntity__r.Name', 'Owner.isactive'};
            }
            when 'Contract' {
                mandatoryFields = new Set<String>{'Id', 'ContractNumber', 'ProcessedContracttext__c', 'RenewalTerm__c', 'TerminationNotice__c'};
            }
            when 'OpportunityLineItem' {
                mandatoryFields = new Set<String>{'Id', 'Product2Id', 'PricebookEntryId', 'Quantity', 'TotalPrice', 'NumberofLocationsSites__c', 'NumberofConcurrentUsersSeats__c','ContractEndDate__c','Product2.AAG__c'};
            }
            when 'OpportunityLineItemSchedule__c' {
                mandatoryFields = new Set<String>{'Id','Opportunity__c','OpportunityProductID__c','Product__c','CurrencyIsoCode','InstallmentYears__c'};
            }
            when 'OpportunityContactRole' {
                mandatoryFields = new Set<String>{'Id','ContactId','IsPrimary'};
            }
            when 'OpportunitySplit' {
                mandatoryFields = new Set<String>{'Id','SplitTypeId','SplitPercentage'};
            }
            when 'OpportunityTeamMember' {
                mandatoryFields = new Set<String>{'Id', 'UserId', 'TeamMemberRole', 'OpportunityAccessLevel'};
            }
        }
        //Get fields from Renewals custom mapping
        Set<String> mappingSourceObjFields = BatchAutoCreateRenewalOppsHelper.fetchSourceMappingFields(objName,BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);                
        //Get unique fields in a set
        finalSet.addAll(mandatoryFields);
        finalSet.addAll(mappingSourceObjFields);
        //Prepare comma separated field names in a string
        List<String> finalList = new List<String>();
        finalList.addAll(finalSet);
        System.debug('finalList='+finalList);
        outputStr = String.join(finalList, ',');        
        System.debug('outputStr='+outputStr);
        
        return outputStr;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) String - Name of object for which mapping fields are needed
    // 			2) List<AutomatedRenewalsMappings__c> - List of custom setting records which are field mappings and are active
    // @description: SFDC-3186 Method to fetch set of source mapping fields for an object. This output is used for preparing object queries.
    // @return: 
    // 			Set<String> - Returns set of field names
    //------------------------------
    public static Set<String> fetchSourceMappingFields(String objName, List<AutomatedRenewalsMappings__c> customSettingList) {
        Set<String> mappingSourceObjFields = new Set<String>();
        for(AutomatedRenewalsMappings__c csObj: customSettingList) {
            if(csObj.SourceObject__c==objName && String.isNotBlank(csObj.SourceField__c)) {
                mappingSourceObjFields.add(csObj.SourceField__c);
            }
        }
        return mappingSourceObjFields;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Opportunity> - Map of opp id and opp valid for renewals
    // @description: SFDC-3186 Method to query master data for opps that are valid for renewals. This method prepares dynamic queries.
    // @return: 
    // 			List<Opportunity> - Returns list of master opps
    //------------------------------
    public static List<Opportunity> queryMasterOpps(Map<Id,Opportunity> validOppsMap) {
        
        if(validOppsMap!=null && validOppsMap.size() > 0) {
            List<String> argumentsList = new List<String>();
            List<Id> oppIdList = new List<Id>();
            oppIdList.addAll(validOppsMap.keySet());
            List<String> prodAAGList = BatchAutoCreateRenewalOppsHelper.allProdAAGs;
            List<String> contractRTypes = BatchAutoCreateRenewalOppsHelper.contractRecordTypes;
            
            String masterQry = '';
            masterQry += 'SELECT {0}, ';
            argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('Opportunity'));
            
            masterQry += '(SELECT {1} FROM Contracts__r WHERE RecordType.Name IN :contractRTypes AND Active__c=true LIMIT 1), ';
            argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('Contract'));
            
            masterQry += '(SELECT {2} FROM OpportunityLineItems WHERE Status__c!=:LOSTOPPPRODSTATUS AND Product2.AAG__c IN :prodAAGList), ';
            argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('OpportunityLineItem'));
            
            masterQry += '(SELECT {3} FROM OpportunityContactRoles), ';
            argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('OpportunityContactRole'));
            
            masterQry += '(SELECT {4} FROM OpportunitySplits), ';
            argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('OpportunitySplit'));
            
            masterQry += '(SELECT {5} FROM OpportunityTeamMembers) ';
            argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('OpportunityTeamMember'));
            
            masterQry += 'FROM Opportunity WHERE Id IN :oppIdList';
            
            String finalQry = String.format(masterQry,argumentsList);
            System.debug('finalQry='+finalQry);
            List<Opportunity> masterOppsList = Database.query(finalQry);
            
            /*
            //Query the original opp data
            List<Opportunity> masterOppsList = [SELECT Id, RecordTypeId, RecordType.Name, DoesThisAutoRenewalHaveChanges__c, AutoRenewStopped__c, AutoRenewal__c,
                                                ChannelPartner__c, SubType__c, BudgetRange__c, OpportunityCountry__c, PrimaryContact__c, BSI__c, OwnerId, AccountId, Account.Name,
                                                Account.GlobalAccountManager__c,ContractBeingRenewed__c, ContractBeingRenewed__r.ContractNumber, ContractEndDate__c, 
                                                ContractBeingRenewed__r.RenewalTerm__c, ContractBeingRenewed__r.BillingFrequency__c, ContractBeingRenewed__r.PaymentTerms__c, ContractBeingRenewed__r.PriceIncreaseClause__c, ContractBeingRenewed__r.RenewalNoticePeriod__c, ContractBeingRenewed__r.TerminationNotice__c,
                                                //SAP_RenewalTerm__c, SAP_BillingFrequency__c, SAP_PaymentTerms__c, SAP_PriceIncreaseClause__c, SAP_RenewalNoticePeriod__c, SAP_TerminationNotice__c, 
                                                PORequired__c, LegalEntity__c,ProcessedContractNum__c, SAPContractNumber__c,
                                                BillToClientName__c, BillToCompanySAP__c, BillToContactFirstName__c, BillToContactLastName__c, BillToContactSAP__c, BillToCountryNew__c, BillToCity__c, BillToContactEmailAddress__c, BillToContactTelephoneNumber__c, BillToPostalZipCode__c, BillToStateProvince__c, BillToStreet__c,
                                                ShipToClientName__c, ShipToCompanySAP__c, ShipToContactFirstName__c, ShipToContactLastName__c, ShipToContactSAP__c, ShipToCountryNew__c, ShipToCity__c, ShipToContactEmailAddress__c, ShipToContactTelephoneNumber__c, ShipToPostalZipCode__c, ShipToStateProvince__c, ShipToStreet__c,
                                                
                                                (SELECT Id, ContractNumber, RenewalTerm__c, BillingFrequency__c, PaymentTerms__c, PriceIncreaseClause__c, RenewalNoticePeriod__c, TerminationNotice__c, AutoRenewal__c, PORequired__c, IHSMarkitLegalEntity__c, ProcessedContracttext__c,
                                                 BillToClientName__c, BillToCompanySAP__c, BillToContactFirstName__c, BillToContactLastName__c, BillToContactSAP__c, BillToCountryCodeLookup__r.Name, BillToCity__c, BillToContactEmailAddress__c, BillToContactTelephoneNumber__c, BillToPostalZipCode__c, BillToStateProvince__c, BillToStreet__c,
                                                 ShipToClientName__c, ShipToCompanySAP__c, ShipToContactFirstName__c, ShipToContactLastName__c, ShipToContactSAP__c, ShipToCountryCodeLookup__r.Name, ShipToCity__c, ShipToContactEmailAddress__c, ShipToContactTelephoneNumber__c, ShipToPostalZipCode__c, ShipToStateProvince__c, ShipToStreet__c
                                                 FROM Contracts__r WHERE RecordType.Name='Order Form' AND Active__c=true LIMIT 1),
                                                
                                                (SELECT Id,Product2Id,PricebookEntryId,Product2.AAG__c,Product2.Division__c,
                                                 ListPrice__c,LicenseType__c,Quantity,NumberofLocationsSites__c,NumberofConcurrentUsersSeats__c,UnitPrice,Discount_Amount__c,TotalDiscountValue__c,TotalPrice
                                                 FROM OpportunityLineItems 
                                                 WHERE Status__c!='Lost' AND Product2.AAG__c IN :BatchAutoCreateRenewalOppsHelper.validSubsProdAAGs),
                                                    
                                                (SELECT Id, OpportunityId, ContactId, Role, IsPrimary, CurrencyIsoCode FROM OpportunityContactRoles),
                                                
                                                (SELECT Id, Split, CurrencyIsoCode, OpportunityId, SplitOwnerId, SplitPercentage, SplitNote, SplitTypeId, SplitAmount, SalesRegion__c, MySplitOppy__c, 
                                                 SplitCountry__c, SplitGeography__c, SplitRegion__c, MyTeamSplitOppy__c, SalesManager__c 
                                                 FROM OpportunitySplits),
                                                
                                                (SELECT Id, OpportunityId, UserId, Name, PhotoUrl, Title, TeamMemberRole, OpportunityAccessLevel, CurrencyIsoCode, OpportunityGAMValue__c, 
                                                 BusinessLine__c, SalesBusinessLine__c 
                                                 FROM OpportunityTeamMembers)
                                                
                                                FROM Opportunity 
                                                WHERE Id IN :validOppsMap.keySet()];
            */
            //Create opp
            System.debug('masterOppsList size='+masterOppsList.size());            
            return masterOppsList;
            
        }
        return null;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) List<Opportunity> - List of input opps
    // 			2) Map<Id,RenewalsLogWrapper> - Map of input opp id and its associated RenewalLogWrapper instance to capture success and error results.
    // @description: SFDC-3186 Method to create new renewal opps and its products and related schedules.
    // @return: none
    //------------------------------
    public static void createRenewalOpportunities2(List<Opportunity> oldOppList, Map<Id,RenewalsLogWrapper> wrapperMap) {
        //System.debug('createRenewalOpportunities2() METHOD BEGINS');
        Id renewalOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
        List<Opportunity> newRenewalOppList = new List<Opportunity>();
        
        //Field Mappings
        Map<String,String> renewalOppOFContractFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('Opportunity','ConditionalContractToOppMapping',BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);                
        Map<String,String> renewalOppMasterOppFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('Opportunity','ConditionalOppToOppMapping',BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);                
        Map<String,String> renewalOppOldOppDirectFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('Opportunity','DirectOppToOppMapping',BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
        
        Id adminUsrId = [Select Id from User where Name = :System.Label.AdminUser].Id;
        
        for(Opportunity oldOpp:oldOppList) {
            Boolean fetchDetailsFromActiveContract = BatchAutoCreateRenewalOppsHelper.shouldFetchDetailsFromActiveOrderFormContract(oldOpp);
            Boolean fetchDetailsFromLastOppy = BatchAutoCreateRenewalOppsHelper.shouldFetchDetailsFromLastOppy(oldOpp);
            Id origContractId;
            String origContractNumber = '';
            Opportunity newRenewalOpp = new Opportunity();
                        
            //1-to-1 direct field mappings
            //Dynamic Mapping - from old Opp to new Renewal Opp
            BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newRenewalOpp,oldOpp,renewalOppOldOppDirectFieldMappings);
            
            //Conditional field mappings - FROM Active OF contract OR existing parent oppy
            if(fetchDetailsFromActiveContract) {
                Contract activeOFContract = oldOpp.Contracts__r.size()>0 ? oldOpp.Contracts__r[0]:null;
                origContractId = activeOFContract!=null ? activeOFContract.Id : null;
                origContractNumber = activeOFContract!=null ? activeOFContract.ContractNumber : null;
                
                //Conditional fields initialisation
                newRenewalOpp.SAPContractNumber__c = oldOpp.ProcessedContractNum__c !=null ? oldOpp.ProcessedContractNum__c : (activeOFContract!=null ? activeOFContract.ProcessedContracttext__c : null);
                
                //Dynamic Mapping - from activeOFContract to new Renewal Opp
                BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newRenewalOpp,activeOFContract,renewalOppOFContractFieldMappings);
            }
            else if(fetchDetailsFromLastOppy) {
                origContractId = oldOpp.ContractBeingRenewed__c!=null ? oldOpp.ContractBeingRenewed__c : null;
                origContractNumber = oldOpp.ContractBeingRenewed__c!=null ? oldOpp.ContractBeingRenewed__r.ContractNumber : null;
                //Conditional fields initialisation
                newRenewalOpp.SAPContractNumber__c = oldOpp.ProcessedContractNum__c !=null ? oldOpp.ProcessedContractNum__c : oldOpp.SAPContractNumber__c;
                
                //Dynamic Mapping - from master opp to new Renewal Opp
                BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newRenewalOpp,oldOpp,renewalOppMasterOppFieldMappings);                
            }
            
            //NON-CONFIGURABLE Mappings
            //Fixed or Static field mappings
            newRenewalOpp.RecordTypeId=renewalOppRecTypeId;
            newRenewalOpp.PreviousYearOpportunitylink__c=oldOpp.Id;
            newRenewalOpp.CurrencyIsoCode=oldOpp.CurrencyIsoCode;
            newRenewalOpp.ContractBeingRenewed__c = origContractId;
            newRenewalOpp.StageName='3-Renewal Pending';
            newRenewalOpp.SourceSystem__c='IHSM Salesforce';
            newRenewalOpp.LeadSource='Renewal';
            newRenewalOpp.ProcessedContractNum__c = null;
            newRenewalOpp.DoesThisAutoRenewalHaveChanges__c = false;
            newRenewalOpp.AutoRenewStopped__c = false;
            
            //Calculated field mappings
            newRenewalOpp.ContractStartDate__c = oldOpp.ContractEndDate__c + 1;
            newRenewalOpp.ContractEndDate__c = BatchAutoCreateRenewalOppsHelper.calculateContractEndDate(newRenewalOpp.ContractStartDate__c, newRenewalOpp.SAP_RenewalTerm__c);
            newRenewalOpp.CloseDate = BatchAutoCreateRenewalOppsHelper.calculateCloseDate(newRenewalOpp.ContractStartDate__c, newRenewalOpp.SAP_TerminationNotice__c);
            newRenewalOpp.Name = BatchAutoCreateRenewalOppsHelper.calculateRenewalOppName(oldOpp.Account.Name, origContractNumber, newRenewalOpp.ContractStartDate__c);
            
            //SFDC-4799 Make SF Admin as Owner when Oppy owner is Inactive.
            if (!oldOpp.Owner.isActive) {
                newRenewalOpp.OwnerId = adminUsrId;
            } 
            
            newRenewalOppList.add(newRenewalOpp);
        }
        System.debug('newRenewalOppList.size()='+newRenewalOppList.size());
        if(newRenewalOppList.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            List<String> successVarList = new List<String>();
            try {
                
                //Create new renewal opportunities
                insert newRenewalOppList;
                successVarList.add('isSuccessOpp');
                
                //Prepare map for child records creation
                Map<Id,Opportunity> masterOppMap = new Map<Id,Opportunity>();
                masterOppMap.putAll(oldOppList);                
                
                Map<Id,Id> renewalOppMasterOppMap = new Map<Id,Id>();                
                for(Opportunity renewalOpp: newRenewalOppList) {
                    renewalOppMasterOppMap.put(renewalOpp.Id, renewalOpp.PreviousYearOpportunitylink__c);
                }
                
                //SFDC-5075 Change Start
                Map<Id,Id> masterOppRenewalOppMap = new Map<Id,Id>();                
                for(Opportunity renewalOpp: newRenewalOppList) {
                    masterOppRenewalOppMap.put(renewalOpp.PreviousYearOpportunitylink__c, renewalOpp.Id);
                }
                
                List<Opportunity> lstOldOppy = New List<Opportunity>();
                for(Opportunity optyRec : oldOppList){
                    Id renewalOppId = masterOppRenewalOppMap.get(optyRec.Id);
                    optyRec.NextYearOpportunityLink__c = renewalOppId;
                    optyRec.AutoGeneratedRenewal__c = True;
                    lstOldOppy.add(optyRec);
                }
                
                Update lstOldOppy;
                //SFDC-5075 Change End
                
                //Create Products and Schedules
                BatchAutoCreateRenewalOppsHelper.createRenewalOppProductsAndSchedules(renewalOppMasterOppMap, masterOppMap, wrapperMap);
                successVarList.add('isSuccessOLI');
                
                //Clone opportunity contact roles
                BatchAutoCreateRenewalOppsHelper.createRenewalOppContactRoles(renewalOppMasterOppMap, masterOppMap);
                successVarList.add('isSuccessOCR');
                
                //Clone opportunity splits
                BatchAutoCreateRenewalOppsHelper.createRenewalOppSplits(renewalOppMasterOppMap, masterOppMap);
                successVarList.add('isSuccessOppSplit');
                
                //Clone opportunity team
                BatchAutoCreateRenewalOppsHelper.createRenewalOppTeam(renewalOppMasterOppMap, masterOppMap);
                successVarList.add('isSuccessOppTeam');
                
                successVarList.add('isSuccess');
            }            
            catch(Exception ex) {                
                System.debug('Exception='+ex);
                System.debug('ex.getMessage()='+ex.getMessage());
                Database.rollback(sp);
                String errorDesc = '--------------Error Reason: ' + System.today() + '-----------\n' + ex.getMessage() + '\n------------------------\n';
                
                //Error logging mechanism
                for(Opportunity newOpp: newRenewalOppList) {
                    RenewalsLogWrapper oppWrpObj = wrapperMap!=null && wrapperMap.containsKey(newOpp.PreviousYearOpportunitylink__c) ? wrapperMap.get(newOpp.PreviousYearOpportunitylink__c) : null;
                    if(oppWrpObj!=null) {
                        oppWrpObj.isError = true;
                        oppWrpObj.errorReason += errorDesc;
                    }
                }
            }            
            finally {
                BatchAutoCreateRenewalOppsHelper.setSuccessVariablesInWrapper(newRenewalOppList, wrapperMap, successVarList);                
            }
            
        }
        System.debug('createRenewalOpportunities2() METHOD ENDS');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) String targetObjName - Name of object
    // 			2) String ruleName - Name of rule used to fetch conditional mappings. This is used only for opp level mappings as of today.
    // 			3) List<AutomatedRenewalsMappings__c> - List of custom setting records that have active field mappings.
    // @description: SFDC-3186 Method to fetch field mappings for automated renewal creations job
    // @return: Map<String,String> - Map of source field name and target field name
    //------------------------------
    public static Map<String,String> fetchFieldMappings(String targetObjName, String ruleName, List<AutomatedRenewalsMappings__c> customSettingList) {
        Map<String, String> tgtSrcFieldMapName = new Map<String,String>();
        for(AutomatedRenewalsMappings__c mappingRecord: customSettingList) {
            if(mappingRecord.TargetObject__c==targetObjName && (String.isBlank(ruleName) || mappingRecord.RuleName__c==ruleName)) {
                tgtSrcFieldMapName.put(mappingRecord.TargetField__c,mappingRecord.SourceField__c);
            }
        }
        return tgtSrcFieldMapName;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) SObject tgtRec - Target Record
    // 			2) SObject srcRec - Source Record
    // 			3) Map<String,String> tgtToSrcFieldsMap - Map of target field to source field
    // @description: SFDC-3186 Method to populate field values on a target record dynamically from source record using a string map of Target=> Source field mappings. 
    // 					- Method can also handle 1-level upwards related object fields as source fields.
    // @return: None
    //------------------------------
    public static void dynamicallyInitialiseRecordFields(SObject tgtRec, SObject srcRec, Map<String,String> tgtToSrcFieldsMap) {
        if(tgtRec!=null && srcRec!=null && tgtToSrcFieldsMap!=null && tgtToSrcFieldsMap.size()>0) {
            for(String tgtField: tgtToSrcFieldsMap.keySet()) {            
                SObject sourceObj = srcRec;
                String srcField = tgtToSrcFieldsMap.get(tgtField);
                if(srcField.containsIgnoreCase('__r.') || srcField.containsIgnoreCase('.')) {
                    String relationshipName = srcField.split('\\.').size()==2 ? srcField.split('\\.')[0] : '';
                    //System.debug('relationshipName='+relationshipName);
                    sourceObj = sourceObj.getSObject(relationshipName);
                    srcField = srcField.remove(relationshipName + '.');
                }
                if(sourceObj!=null && String.isNotBlank(srcField)) {
                    tgtRec.put(tgtField,sourceObj.get(srcField));                            
                }
            }
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) List<Opportunity> newRenewalOppList - List of new renewal opportunities created
    // 			2) Map<Id,RenewalsLogWrapper> wrapperMap - Map of old opp id and related RenewalsLogWrapper instance
    // 			3) List<String> successVarNameList - List of success variables
    // @description: SFDC-3186 Method to set success variables at each level in RenewalsLogWrapper instance
    // @return: None
    //------------------------------
    public static void setSuccessVariablesInWrapper(List<Opportunity> newRenewalOppList, Map<Id,RenewalsLogWrapper> wrapperMap, List<String> successVarNameList) {
        //Set Success in Wrapper
        for(Opportunity newOpp: newRenewalOppList) {
            RenewalsLogWrapper oppWrpObj = wrapperMap!=null && wrapperMap.containsKey(newOpp.PreviousYearOpportunitylink__c) ? wrapperMap.get(newOpp.PreviousYearOpportunitylink__c) : null;
            if(oppWrpObj!=null) {
                for(String successVarName: successVarNameList) {
                    switch on successVarName {
                        when 'isSuccess' {
                            oppWrpObj.isSuccess = true;
                        }
                        when 'isSuccessOpp' {
                            oppWrpObj.isSuccessOpp = true;
                        }
                        when 'isSuccessOLI' {
                            oppWrpObj.isSuccessOLI = true;
                        }
                        when 'isSuccessOppTeam' {
                            oppWrpObj.isSuccessOppTeam = true;
                        }
                        when 'isSuccessOCR' {
                            oppWrpObj.isSuccessOCR = true;
                        }
                        when 'isSuccessOppSplit' {
                            oppWrpObj.isSuccessOppSplit = true;
                        }                    
                    }
                }                
            }
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of new opp id and old opp id
    // 			2) Map<Id,Opportunity> masterOppMap - Map of old opp id and old opp
    // 			3) List<String> successVarNameList - List of success variables
    // @description: SFDC-3186 Method to create opportunity products and related schedules based on term of opp
    // @return: None
    //------------------------------
    public static void createRenewalOppProductsAndSchedules(Map<Id,Id> newOppOldOppMap, Map<Id,Opportunity> masterOppMap,Map<Id,RenewalsLogWrapper> wrapperMap) {
        //Create opp products which are Sub/Subvar
        Map<OpportunityLineItem,OpportunityLineItem> oldOLINewOLIMap = new Map<OpportunityLineItem,OpportunityLineItem>();
		Map<Id,OpportunityLineItem> oldOLIMap = new Map<Id,OpportunityLineItem>();
        
        //Field Mappingss
        Map<String,String> renewalProdMasterProdFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('OpportunityLineItem','OliToOliMapping',BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
        Map<String,String> renewalProdMasterProdFieldMappingsV2 = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('OpportunityLineItem','OlischdToOliMapping',BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
        Map<Id,List<OpportunityLineItemSchedule__c>> oliWithSchedulesMap = new Map<Id,List<OpportunityLineItemSchedule__c>>();
        
        for(OpportunityLineItemSchedule__c olis: [SELECT Id, OpportunityProductID__c,TotalPrice__c, ExternalListPrice__c,InstallmentYears__c,SalesPrice__c,DiscountAmount__c FROM OpportunityLineItemSchedule__c WHERE Opportunity__c IN : masterOppMap.keySet() AND InstallmentYears__c != null AND OpportunityProductID__c != null ORDER BY InstallmentYears__c DESC]) {
            List<OpportunityLineItemSchedule__c> olisList = oliWithSchedulesMap.containsKey(olis.OpportunityProductID__c) ? oliWithSchedulesMap.get(olis.OpportunityProductID__c) : new List<OpportunityLineItemSchedule__c>();
            olisList.add(olis);
            oliWithSchedulesMap.put(olis.OpportunityProductID__c,olisList);            
        }        
        
        for(Id renewalOppId: newOppOldOppMap.keySet()) {
            Opportunity masterOpp = masterOppMap.get(newOppOldOppMap.get(renewalOppId));
            //Fetch Sub/Subvar Product if Oppy Contract is Order Form else get Trans/Cons Prod
            BatchAutoCreateRenewalOppsHelper.finalAAGProds = wrapperMap.containsKey(masterOpp.Id)? (wrapperMap.get(masterOpp.Id).isOrderFormContract ? BatchAutoCreateRenewalOppsHelper.validSubsProdAAGs.clone() : BatchAutoCreateRenewalOppsHelper.allProdAAGs.clone()): new List<String>();
            for(OpportunityLineItem oldOLI: masterOpp.OpportunityLineItems) {
                //Create Subs/Subsvar prod if Contract is Order form else create trans/cons prod
                if (BatchAutoCreateRenewalOppsHelper.finalAAGProds.contains(oldOLI.Product2.AAG__c)){
                    OpportunityLineItem newOLI = new OpportunityLineItem(OpportunityId=renewalOppId);
                    //get latest Oppy schedules from old OLI
                    Integer renewalYear = oldOLI.ContractEndDate__c !=null ? UtilityClass.calculateFyFromDate(oldOLI.ContractEndDate__c+1 , UtilityClass.FiscalStartMonth): null;
                    OpportunityLineItemSchedule__c oppySch = BatchAutoCreateRenewalOppsHelper.getValidOldSchedule(oliWithSchedulesMap.get(oldOLI.Id), renewalYear);          
                    BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newOLI,oppySch,renewalProdMasterProdFieldMappingsV2);
    
                    //Dynamic Mapping - from old OLI to new OLI
                    BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newOLI,oldOLI,renewalProdMasterProdFieldMappings);
                                      
                    //Fixed Field Mappings - cannot change
                    newOLI.Status__c='Existing';
                    newOLI.PriorYearNumberOfLocationsSites__c = String.valueOf(oldOLI.NumberofLocationsSites__c);
                    newOLI.PriorYearNumberOfConcurrentUsersSeats__c = String.valueOf(oldOLI.NumberofConcurrentUsersSeats__c);
                    oldOLINewOLIMap.put(oldOLI,newOLI);
					oldOLIMap.put(oldOLI.id,oldOLI);
                }    
            }
        }
        if(oldOLINewOLIMap.values().size() > 0) {            
            insert oldOLINewOLIMap.values();
            //Create opp product schedules for above products as per oppy term
            Map<Id,Id> newOLIIdOldOLIIdMap = new Map<Id,Id>();
            //for(OpportunityLineItem newOLIObj: newOLIOldOLIMap.keySet()) {                
            for(OpportunityLineItem oldOLIObj: oldOLINewOLIMap.keySet()) {
                OpportunityLineItem newOLIObj = oldOLINewOLIMap.get(oldOLIObj);
                newOLIIdOldOLIIdMap.put(newOLIObj.Id,oldOLIObj.Id);
            }
            BatchAutoCreateRenewalOppsHelper.createOppProductSchedules(newOLIIdOldOLIIdMap, newOppOldOppMap, wrapperMap, oldOLIMap);
        }
        
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of new opp id and old opp id
    // @description: SFDC-3186 Method to create renewal opp product schedules
    // @return: None
    //------------------------------
    public static void createOppProductSchedules(Map<Id,Id> newOLIOldOLIIdMap, Map<Id,Id> newOppOldOppMap, Map<Id,RenewalsLogWrapper> wrapperMap, Map<Id,OpportunityLineItem> oldOLIMap) {
        List<Id> oldOLIIdList = newOLIOldOLIIdMap!=null ? newOLIOldOLIIdMap.values() : new List<Id>();
        
        String masterOLISQry = '';
        masterOLISQry += 'SELECT {0} ';
        List<String> argumentsList = new List<String>();
        argumentsList.add(BatchAutoCreateRenewalOppsHelper.getQueryFieldsPerObject('OpportunityLineItemSchedule__c'));
        //masterOLISQry += 'FROM OpportunityLineItemSchedule__c WHERE OpportunityProductID__c IN :oldOLIIdList AND InstallmentYears__c!=null AND Product__c!=null AND Opportunity__c!=null ORDER BY Opportunity__c,Product__c,InstallmentYears__c DESC';
        masterOLISQry += 'FROM OpportunityLineItemSchedule__c WHERE OpportunityProductID__c IN :oldOLIIdList AND InstallmentYears__c!=null AND Opportunity__c!=null ORDER BY Opportunity__c,OpportunityProductID__c,InstallmentYears__c DESC';
        String finalOLISQry = String.format(masterOLISQry,argumentsList);
        System.debug('finalOLISQry='+finalOLISQry);
        List<OpportunityLineItemSchedule__c> masterOLISList = Database.query(finalOLISQry);
        
        /*List<OpportunityLineItemSchedule__c> masterOLISList = [SELECT Id, Opportunity__c, OpportunityProductID__c, Product__c, 
                                                               CurrencyIsoCode, DiscountPercent__c, DiscountAmount__c, DiscountType__c, InstallmentYears__c, SalesPrice__c, OwnerId, PriceBookListPrice__c, Quantity__c, Status__c, TotalPrice__c, ExternalListPrice__c
                                                               FROM OpportunityLineItemSchedule__c 
                                                               WHERE OpportunityProductID__c IN :newOLIOldOLIIdMap.values() AND InstallmentYears__c!=null AND Product__c!=null AND Opportunity__c!=null
                                                               Order By Opportunity__c,Product__c,InstallmentYears__c DESC];
        */
        
        //Get all old opp product Schedules and group them by OLI
        Map<Id,List<OpportunityLineItemSchedule__c>> oliWithSchedulesMap = new Map<Id,List<OpportunityLineItemSchedule__c>>();
        for(OpportunityLineItemSchedule__c olis:masterOLISList) {
            List<OpportunityLineItemSchedule__c> olisList = oliWithSchedulesMap.containsKey(olis.OpportunityProductID__c) ? oliWithSchedulesMap.get(olis.OpportunityProductID__c) : new List<OpportunityLineItemSchedule__c>();
            olisList.add(olis);
            oliWithSchedulesMap.put(olis.OpportunityProductID__c,olisList);            
        }
        
        //Get new opp line items with needed opp info
        Map<Id,OpportunityLineItem> newOLIMap = new Map<Id,OpportunityLineItem>([SELECT Id,Product2Id,OpportunityId, Opportunity.ContractStartDate__c,Opportunity.ContractEndDate__c,Opportunity.SAP_RenewalTerm__c,Opportunity.LegalEntity__r.name, Quantity, Opportunity.RecordType.Name, Opportunity.OpportunityCountry__r.Name, Opportunity.ShipToCountryNew__c, Product2.AAG__c 
                                                                                 FROM OpportunityLineItem
                                                                                 WHERE Id IN :newOLIOldOLIIdMap.keySet()]);
        
        //Field Mappings - Old Schedule to New Schedule
        Map<String,String> renewalSchedMasterSchedFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('OpportunityLineItemSchedule__c',null,BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
                
        //Create new schedules based on no. of years in renewal oppy's term
        List<OpportunityLineItemSchedule__c> newOLISList = new List<OpportunityLineItemSchedule__c>();
        for(Id newOLIId: newOLIOldOLIIdMap.keySet()) {
            
            //Get info from new renewal opp - renewal year, renewal term year count
            OpportunityLineItem newOLIWithOppInfo = newOLIMap.get(newOLIId);
            Integer renewalYear = newOLIWithOppInfo.Opportunity.ContractStartDate__c!=null ? UtilityClass.calculateFyFromDate(newOLIWithOppInfo.Opportunity.ContractStartDate__c, UtilityClass.FiscalStartMonth): null;
            //Integer renewalYear = newOLIWithOppInfo.Opportunity.ContractStartDate__c!=null ? newOLIWithOppInfo.Opportunity.ContractStartDate__c.year() : null;
            Integer scheduleYearsCount = BatchAutoCreateRenewalOppsHelper.calculateScheduleYearsFromRenewalTerm(newOLIWithOppInfo.Opportunity.SAP_RenewalTerm__c);
            //Check for Indian Opportunity
            Boolean isIndianOppy = false;
            if ((newOLIWithOppInfo.Opportunity.RecordType.Name == 'New Business' && (newOLIWithOppInfo.Opportunity.OpportunityCountry__r.Name == 'India' || newOLIWithOppInfo.Opportunity.OpportunityCountry__r.Name == 'IN')) || (newOLIWithOppInfo.Opportunity.RecordType.Name == 'Renewal' && (newOLIWithOppInfo.Opportunity.ShipToCountryNew__c == 'India' || newOLIWithOppInfo.Opportunity.ShipToCountryNew__c == 'IN'))) {
                 isIndianOppy = true;    
            } 
            //Find relevant schedule from the old OLI schedules based on current year of renewal opp
            Id oldOLIId = newOLIOldOLIIdMap.get(newOLIId);
            OpportunityLineItem oldOLI = oldOLIMap.get(oldOLIId);
            OpportunityLineItemSchedule__c validOldOLIS = BatchAutoCreateRenewalOppsHelper.getValidOldSchedule(oliWithSchedulesMap.get(oldOLIId), renewalYear);
            
            //Copy over the relevant schedules as per no. of schedule years, insert them
            if(validOldOLIS != null) {
                for(Integer i=0; i<scheduleYearsCount; i++) {
                    OpportunityLineItemSchedule__c newOLIS = new OpportunityLineItemSchedule__c(Opportunity__c=newOLIWithOppInfo.OpportunityId);
                    
                    //Dynamic Mapping
                    BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newOLIS,validOldOLIS,renewalSchedMasterSchedFieldMappings);
                    //Fixed Field Mappings - cannot change                    
                    newOLIS.OpportunityProductID__c=newOLIWithOppInfo.Id;
                    //newOLIS.Product__c=validOldOLIS.Product__c;
                    newOLIS.Product__c=newOLIWithOppInfo.Product2Id;
                    newOLIS.InstallmentYears__c = String.valueOf(renewalYear);
                    newOLIS.Status__c = 'Existing';
                    if (newOLIWithOppInfo.Opportunity.LegalEntity__r.name == 'IHS Global Pte Ltd' && isIndianOppy && IndianLevyProds.contains(newOLIWithOppInfo.Product2Id)){
                        if(newOLIS.DiscountAmount__c== NULL) {
                            newOLIS.SalesPrice__c = newOLIS.ExternalListPrice__c;
                        }
                        else {
                        newOLIS.SalesPrice__c = newOLIS.ExternalListPrice__c - newOLIS.DiscountAmount__c;
                        }
                       //DCP-4527, As Indian Levy charges are already part of ListPrice for New Business Opps, Hence no Need to recalulate tax again.
                       //newOLIS.SalesPrice__c = ((Decimal.valueOf(System.Label.IndianLevyTax)/100) * salesPrice) + salesPrice;
                    } else {
                       if(newOLIS.DiscountAmount__c== NULL) {
                            newOLIS.SalesPrice__c = newOLIS.ExternalListPrice__c;
                        }
                        else {
                        newOLIS.SalesPrice__c = newOLIS.ExternalListPrice__c - newOLIS.DiscountAmount__c;
                        }                 
                    }
                    newOLIS.TotalPrice__c = newOLIS.SalesPrice__c * newOLIWithOppInfo.Quantity; 
                    //SFDC-3965 For Consulting Contract, OLI & OLISch prices should be 0
                    /*if (newOppOldOppMap.containsKey(newOLIWithOppInfo.OpportunityId) && wrapperMap.containsKey(newOppOldOppMap.get(newOLIWithOppInfo.OpportunityId)) && wrapperMap.get(newOppOldOppMap.get(newOLIWithOppInfo.OpportunityId)).isConsultingContract) {*/
					
					/*SFDC-5490 For Consulting Contract if: 
					AAG is Trans/Cons ---> OLI & OLISch prices should be 0
					AAG is Sub/Subvar ---> OLI & OLISch prices will be annual value */
					if (BatchAutoCreateRenewalOppsHelper.validNonSubsProdAAGs.contains(newOLIWithOppInfo.Product2.AAG__c)) {
                        newOLIS.ExternalListPrice__c = 0;
                        newOLIS.TotalPrice__c = 0;
                        newOLIS.PriceBookListPrice__c = 0;
                        newOLIS.SalesPrice__c = 0;
                        newOLIS.DiscountAmount__c = 0;
                        newOLIS.DiscountPercent__c = 0;	
                    }                    
                    renewalYear++;
                    newOLISList.add(newOLIS);
                }                
            }
            
        }
        if(newOLISList.size() > 0) {
            insert newOLISList;
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) List<OpportunityLineItemSchedule__c> olisList - List of old opp product schedules
    // 			2) Integer renewalYear - Renewal Year of new opp, calculated as per org fiscal year
    // @description: SFDC-3186 Method to fetch valid schedule from old opp product based on renewal year of new oppy and available schedules in old opp product
    // @return: OpportunityLineItemSchedule__c - Returns a valid opportunity line item schedule based on renewal year. This is used as a base schedule to create new product schedules in renewal opp.
    //------------------------------
    public static OpportunityLineItemSchedule__c getValidOldSchedule(List<OpportunityLineItemSchedule__c> olisList, Integer renewalYear) {
        OpportunityLineItemSchedule__c validOLIS;
        //Add code to find valid schedule based on renewal year
        if(olisList!=null && olisList.size()>0) {
            for(OpportunityLineItemSchedule__c olisObj: olisList) {
                Integer olisInstYear = Integer.valueOf(olisObj.InstallmentYears__c);
                if(olisInstYear > renewalYear) {
                    continue;
                }
                if(olisInstYear <= renewalYear) {
                    validOLIS = olisObj;
                    break;
                }
            }            
        }
        
        return validOLIS;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of new opp id and old opp id
    // 			2) Map<Id,Opportunity> masterOppMap - Map of old opp id and old opp
    // @description: SFDC-3186 Method to create opportunity contact roles
    // @return: None
    //------------------------------
    public static void createRenewalOppContactRoles(Map<Id,Id> newOppOldOppMap, Map<Id,Opportunity> masterOppMap) {
        List<OpportunityContactRole> newOCRList = new List<OpportunityContactRole>();
        
        //Field Mappings
        Map<String,String> newOCROldOCRFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('OpportunityContactRole',null,BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
        
        for(Id renewalOppId: newOppOldOppMap.keySet()) {
            Opportunity masterOpp = masterOppMap.get(newOppOldOppMap.get(renewalOppId));
            for(OpportunityContactRole oldOCR : masterOpp.OpportunityContactRoles) {
                //Create new OCR from old OCR
                OpportunityContactRole newOCR = new OpportunityContactRole(OpportunityId=renewalOppId, ContactId=oldOCR.ContactId, IsPrimary=oldOCR.IsPrimary);
                
                //Dynamic Mapping - from old OLI to new OLI
                BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newOCR,oldOCR,newOCROldOCRFieldMappings);
                
                newOCRList.add(newOCR);
            }
        }
        if(newOCRList.size() > 0) {
            insert newOCRList;
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of new opp id and old opp id
    // 			2) Map<Id,Opportunity> masterOppMap - Map of old opp id and old opp
    // @description: SFDC-3186 Method to create opportunity splits
    // @return: None
    //------------------------------
    public static void createRenewalOppSplits(Map<Id,Id> newOppOldOppMap, Map<Id,Opportunity> masterOppMap) {
        List<OpportunitySplit> newSplitsList = new List<OpportunitySplit>();
        
        Map<String,String> newsplitOldSplitFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('OpportunitySplit',null,BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
                
        //Fetch existing splits and delete them
        List<OpportunitySplit> existingOppOwnerSplitList = [SELECT Id,OpportunityId,SplitTypeId,SplitOwnerId FROM OpportunitySplit WHERE OpportunityId IN :newOppOldOppMap.keySet()];
        Map<Id,Map<String,OpportunitySplit>> oppIdExistingOppSplitMap = new Map<Id,Map<String,OpportunitySplit>>();
        for(OpportunitySplit defaultSplit: existingOppOwnerSplitList) {
            String uniqueKeyForSplit = String.valueOf(defaultSplit.SplitTypeId) + String.valueOf(defaultSplit.SplitOwnerId);
            Map<String,OpportunitySplit> existingSplitMap = oppIdExistingOppSplitMap.containsKey(defaultSplit.OpportunityId) ? oppIdExistingOppSplitMap.get(defaultSplit.OpportunityId) : new Map<String,OpportunitySplit>();
            existingSplitMap.put(uniqueKeyForSplit,defaultSplit);
            oppIdExistingOppSplitMap.put(defaultSplit.OpportunityId,existingSplitMap);
        }
        for(Id renewalOppId: newOppOldOppMap.keySet()) {
            Opportunity masterOpp = masterOppMap.get(newOppOldOppMap.get(renewalOppId));
            Map<String,OpportunitySplit> existingOppSplitMap = oppIdExistingOppSplitMap.get(renewalOppId);
            for(OpportunitySplit oldSplit : masterOpp.OpportunitySplits) {                
                //Create new split from old split.Added If Condition to prevent duplicate split creation for AM . Split for AM already getting created
				// from Opportunity Insert trigger, so no need to Copy from old Opportunity.
				if(oldSplit.SplitTypeId!=UtilityClass.OverlayId) {
					OpportunitySplit newOppSplit = new OpportunitySplit(OpportunityId=renewalOppId, SplitTypeId=oldSplit.SplitTypeId, SplitPercentage=oldSplit.SplitPercentage);
					String uniqueKeyForOldSplit = String.valueOf(oldSplit.SplitTypeId) + String.valueOf(oldSplit.SplitOwnerId);
					
					//Dynamic Mapping
					BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newOppSplit,oldSplit,newsplitOldSplitFieldMappings);
					
					//Update default owner split as it is automatically created and cannot be deleted, so use upsert for splits
					if(existingOppSplitMap!=null && existingOppSplitMap.size()>0 && existingOppSplitMap.containsKey(uniqueKeyForOldSplit)) {
						newOppSplit.Id = existingOppSplitMap.get(uniqueKeyForOldSplit).Id;                    
					}
					newSplitsList.add(newOppSplit);
				}
            }
        }
        if(newSplitsList.size() > 0) {
            upsert newSplitsList;
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of new opp id and old opp id
    // 			2) Map<Id,Opportunity> masterOppMap - Map of old opp id and old opp
    // @description: SFDC-3186 Method to create opportunity team
    // @return: None
    //------------------------------
    public static void createRenewalOppTeam(Map<Id,Id> newOppOldOppMap, Map<Id,Opportunity> masterOppMap) {
        List<OpportunityTeamMember> newOppTeamMemberList = new List<OpportunityTeamMember>();
        
        
        //Field Mappings - old team to new team
        Map<String,String> newTeamOldTeamFieldMappings = BatchAutoCreateRenewalOppsHelper.fetchFieldMappings('OpportunityTeamMember',null,BatchAutoCreateRenewalOppsHelper.renewalsFieldMappingCSList);
        Map<String,OpportunityTeamMember> mapOppIdAndTeamMember = new Map<String,OpportunityTeamMember>();
        List<OpportunityTeamMember> listExistingGAMOnOpportunity = new List<OpportunityTeamMember>();
        listExistingGAMOnOpportunity = [Select Id,TeamMemberRole,UserId,OpportunityId from OpportunityTeamMember where opportunityId IN: newOppOldOppMap.keyset() ];
        for(OpportunityTeamMember otm:listExistingGAMOnOpportunity) {
            mapOppIdAndTeamMember.put(otm.TeamMemberRole+'_'+otm.OpportunityId,otm);
        }
        for(Id renewalOppId: newOppOldOppMap.keySet()) {
            Opportunity masterOpp = masterOppMap.get(newOppOldOppMap.get(renewalOppId));
            for(OpportunityTeamMember oldOppTeamMember : masterOpp.OpportunityTeamMembers) {
                //Create new opp team member from old opp team member 
                //added check to prevent duplicate team roles in renewal oppty .
                if(!mapOppIdAndTeamMember.ContainsKey(oldOppTeamMember.TeamMemberRole+'_'+renewalOppId)) {
                    OpportunityTeamMember newOppTeamMember = new OpportunityTeamMember(OpportunityId=renewalOppId, UserId=oldOppTeamMember.UserId);
                    
                    //Dynamic Mapping
                    BatchAutoCreateRenewalOppsHelper.dynamicallyInitialiseRecordFields(newOppTeamMember,oldOppTeamMember,newTeamOldTeamFieldMappings);
                                    
                    newOppTeamMemberList.add(newOppTeamMember);
                }
            }
        }
        if(newOppTeamMemberList.size() > 0) {
            insert newOppTeamMemberList;
        }
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of old opp
    // @description: SFDC-3186 Method to decide if important field mappings should come from active Order Form contract on existing opp or not
    // @return: Boolean - Returns true if some fields on new renewal opp need to be mapped from related active OF contract
    //------------------------------
    public static Boolean shouldFetchDetailsFromActiveOrderFormContract(Opportunity opp) {        
        if(opp.RecordType.Name=='New Business' || (opp.RecordType.Name=='Renewal' && (opp.DoesThisAutoRenewalHaveChanges__c || opp.AutoRenewStopped__c || !opp.AutoRenewal__c))) {
            return true;
        }
        return false;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Map<Id,Id> newOppOldOppMap - Map of old opp
    // @description: SFDC-3186 Method to decide if important field mappings should come from directly existing opp or not
    // @return: Boolean - Returns true if some fields on new renewal opp need to be mapped from old renewal opp
    //------------------------------
    public static Boolean shouldFetchDetailsFromLastOppy(Opportunity opp) {        
        if(opp.RecordType.Name=='Renewal' && opp.AutoRenewal__c && !opp.DoesThisAutoRenewalHaveChanges__c && !opp.AutoRenewStopped__c) {
            return true;
        }
        return false;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) String accName - Account Name
    // 			2) String contractNum - Originating contract number
    // 			3) Date contractStartDate - Contract start date of new opp
    // @description: SFDC-3186 Method to format opp name for automated renewals created by SFDC
    // @return: Boolean - Returns calculated renewal opp name
    //------------------------------
    public static String calculateRenewalOppName(String accName, String contractNum, Date contractStartDate) {
        String oppName = accName.left(25);
        oppName += '- Renewal';
        oppName = String.isNotBlank(contractNum) ? (oppName + '- ' + contractNum) : oppName;
        Datetime contractStartDatetime = contractStartDate;
        String csdFormattedString = String.valueOf(contractStartDatetime.day()) + '-' + String.valueOf(contractStartDatetime.format('MMM')) + '-' + String.valueOf(contractStartDatetime.year());
        oppName = contractStartDate!=null ? (oppName + '- ' + csdFormattedString) : oppName;
        
        return oppName;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Date contractStartDate - Contract start date of new opp
    // 			2) String renewalTerm - Renewal Term(SAP) of new opp
    // @description: SFDC-3186 Method to calculate contract end date on renewal opp using Renewal Term (SAP)
    // @return: Date - Returns calculated contract end date
    //------------------------------
    public static Date calculateContractEndDate(Date conStartDate, String renewalTerm) {
        Integer defaultMonthsDuration = 12;
        Map<String,Integer> renewalTermToMonthsConversionMap = new Map<String,Integer>();
        for(AutomatedRenewalsMappings__c valMappingObj: BatchAutoCreateRenewalOppsHelper.renewalsValueMappingCSList) {
            if(valMappingObj.ValueMapping__c && valMappingObj.SourceField__c=='Renewal Term' && valMappingObj.TargetField__c=='Contract End Date' && valMappingObj.SourceValue__c!=null && valMappingObj.TargetValue__c!=null) {
                renewalTermToMonthsConversionMap.put(valMappingObj.SourceValue__c,Integer.valueOf(valMappingObj.TargetValue__c));
            }
        }
        Integer renewalTermMonthsDuration = String.isNotBlank(renewalTerm) && renewalTermToMonthsConversionMap.containsKey(renewalTerm) ? renewalTermToMonthsConversionMap.get(renewalTerm) : defaultMonthsDuration;
        
        Date contractEndDate = conStartDate.addMonths(renewalTermMonthsDuration)-1;
        
        return contractEndDate;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Date contractStartDate - Contract start date of new opp
    // 			2) String terminationNotice - Termination Notice(SAP) of new opp
    // @description: SFDC-3186 Method to calculate close date on renewal opp using Termination Notice (SAP)
    // @return: Date - Returns calculated close date
    //------------------------------
    public static Date calculateCloseDate(Date conStartDate, String terminationNotice) {
        Integer defaultDaysDuration = 0;
        Map<String,Integer> termNoticeToDaysConversionMap = new Map<String,Integer>();
        for(AutomatedRenewalsMappings__c valMappingObj: BatchAutoCreateRenewalOppsHelper.renewalsValueMappingCSList) {
            if(valMappingObj.ValueMapping__c && valMappingObj.SourceField__c=='Termination Notice' && valMappingObj.TargetField__c=='Close Date' && valMappingObj.SourceValue__c!=null && valMappingObj.TargetValue__c!=null) {
                termNoticeToDaysConversionMap.put(valMappingObj.SourceValue__c,Integer.valueOf(valMappingObj.TargetValue__c));
            }
        }
        Integer termNoticeDaysDuration = String.isNotBlank(terminationNotice) && termNoticeToDaysConversionMap.containsKey(terminationNotice) ? termNoticeToDaysConversionMap.get(terminationNotice) : defaultDaysDuration;
        Date closeDate = conStartDate-termNoticeDaysDuration;
        
        return closeDate;
    }    
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 25 Aug 2020
    // @param: 
    // 			1) Date contractStartDate - Contract start date of new opp
    // 			2) String terminationNotice - Termination Notice(SAP) of new opp
    // @description: SFDC-3186 Method to calculate no. of years for which schedules should be created based on renewal term
    // @return: Date - Returns count of schedules that should be created for new opp product based on renewal term
    //------------------------------
    public static Integer calculateScheduleYearsFromRenewalTerm(String renewalTerm) {
        Integer defaultRenewalTermYears = 1;
        Map<String,Integer> renewalTermToSchedYearsMap = new Map<String,Integer>();
        for(AutomatedRenewalsMappings__c valMappingObj: BatchAutoCreateRenewalOppsHelper.renewalsValueMappingCSList) {
            if(valMappingObj.ValueMapping__c && valMappingObj.SourceField__c=='Renewal Term' && valMappingObj.TargetField__c=='Schedules Count' && valMappingObj.SourceValue__c!=null && valMappingObj.TargetValue__c!=null) {
                renewalTermToSchedYearsMap.put(valMappingObj.SourceValue__c,Integer.valueOf(valMappingObj.TargetValue__c));
            }
        }
        Integer renewalTermYears = String.isNotBlank(renewalTerm) && renewalTermToSchedYearsMap.containsKey(renewalTerm) ? renewalTermToSchedYearsMap.get(renewalTerm) : defaultRenewalTermYears;
        
        return renewalTermYears;
    }
}