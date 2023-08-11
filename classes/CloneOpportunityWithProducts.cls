//-----------------------------
// @author: Prachi Bhasin
// @date: 23 Jan 2018
// @param: NA
// @description: Class to clone opportunity along with products and schedule. This is being used by 'Clone (with products)' action on opportunity. 
// @return: NA
// @company: VERTIBA
// @Last Modified By : Prachi Bhasin
// @Last Modified Date: 21 Feb 2018
// @Last Modified Description: SFDC1-6909, Adding method to check if logged in user has edit access on opportunity.
// @Last Modified By : Prachi Bhasin
// @Last Modified Date: 6 March 2018
// @Last Modified Description: SFDC1-7234, If 'Auto Renewal' field is "yes" and the "Does this Auto Renew have changes" field is set to No — do not allow the user to change the currency on that opportunity.
// @Last Modified By : Prachi Bhasin
// @Last Modified Date: 13 March 2018
// @Last Modified Description: SFDC1-6971, Currency change can only happen on Sales Stages 1 or 2.
// @Last Modified By : Sruti Srivastava
// @Last Modified Date: 7th May 2018
// @Last Modified Description: SFDC1-7896, Displaying exact error when some error occurs on Currency change
// @Modified By: Paras Dhingra
// @Modified Date: 13th Jun 2018
// @Modifief description: Fixing bug SFDC1-8261 to include two currency fields PricingOpsListUnitPrice__c and RecommendedUnitPrice__c
// @Modified By: Prachi Bhasin
// @Modified Date: 17th Aug 2018
// @Modifief description: Fixing bug SFDC1-9597 to disable oppty and product level validations when oppty is being cloned/ currency change
// @Modified By: Prachi Bhasin
// @Modified Date: 7 Sept 2018
// @Modifief description: SFDC1-9397 when cloning inner year oppty, it should be cloned as new business
// @Modified By: Paras Dhingra
// @Modified Date: 27 MAy 2019
// @Modifief description: SFDC1-1520 modifiying code to individually select fields for currency 
//-----------------------------
public without sharing class CloneOpportunityWithProducts {
    public STATIC Boolean IsOppyBeingCloned = TRUE;
    public STATIC Boolean IsCurrencyBeingChanged = FALSE;
    public STATIC Boolean IsOppyProdBeingCloned = FALSE;
    public static Map<String, Decimal> mapCurrencyType = UtilityClass.mapCurrencyIsoCodeConversionRate;
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 21 Feb 2018 
    // @param:opp Id - Id of opportunity 
    // @description:This method checks if user has permission to edit the record 
    // @return:string- specifying error condition if any  
    //------------------------------
    @AuraEnabled
    public static string getOpptyAccess(String oppId) {
        Boolean access = UtilityClass.checkRecordAccessforUser(UserInfo.getUserID(),oppId);
        String errorMessage = '' ;
        if(access) {
            errorMessage = 'userHasAccess';
            Opportunity opp = [Select id, AutoRenewal__c,StageName, DoesThisAutoRenewalHaveChanges__c, OpportunityRecordType__c from Opportunity where id =: oppId]; 
            if(opp.OpportunityRecordType__c == 'Renewal' && opp.AutoRenewal__c==TRUE && opp.DoesThisAutoRenewalHaveChanges__c ==FALSE) {
                errorMessage = 'autoRenewWithoutChange';
            }
            if(opp.OpportunityRecordType__c == 'Renewal' && (opp.StageName!='3-Renewal Pending')) {
                errorMessage = 'renewalCanBeUpdatedAtStage3';
            }
            if(opp.OpportunityRecordType__c == 'New Business' && (opp.StageName!='1-Sales Qualified' && opp.StageName!='2-Need Confirmed')) {
                errorMessage = 'newBusinessCanBeUpdatedAtStage1Or2';
            }
        }
        else {
            errorMessage = 'userHasNoAccess';
        }
        return errorMessage;
    }
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 23 Jan 2018 
    // @param:NA 
    // @description:This method clones the opportunity record. 
    // @return:Id of newly created opportunity  
    //------------------------------
    @AuraEnabled
    public static string getActiveCurrencies() {
        string returnString='';
        Schema.DescribeFieldResult fieldResult = Opportunity.CurrencyIsoCode.getDescribe();
        List<RecordTypeWrapper> wrapperList=new List<RecordTypeWrapper>();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            RecordTypeWrapper rw=new RecordTypeWrapper();
            rw.recordTypeLabel=f.getLabel();
            rw.recordTypeId=f.getValue();
            wrapperList.add(rw);
        }       
        returnString= JSON.serialize(wrapperList);
        system.debug('*****'+returnString);
        return returnString;
    }
    
    public class RecordTypeWrapper {
        public string recordTypeLabel {get;set;}
        public string recordTypeId {get;set;}
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 23 Jan 2018
    // @param:expectedCurrencyIsoCode - new CurrencyIsoCode for opportunity
    // @param:opp Id - Id of opportunity to be cloned 
    // @description:This method clones the opportunity record. 
    // @return:Id of newly created opportunity  
	// @Update Author : Sruti Srivastvaa
    // @date : 7th May 2018
    // @Description : SFDC1-7158 : Displaying exact error when some error occurs on Currency change
    //------------------------------
    @AuraEnabled
    public static String changeOpportunityCurrency(String expectedCurrencyIsoCode, String oppId) {
        Savepoint spForCurrencychangeOpportunityCurrency = Database.setSavepoint();
        try {
            CloneOpportunityWithProducts.IsOppyBeingCloned = FALSE;
            CloneOpportunityWithProducts.IsCurrencyBeingChanged = TRUE;
            Opportunity opp = [Select id, Pricebook2Id,currencyisocode from opportunity where id =: oppId];
            
            //queuable change
            changeOpportunityCurrencyQueuable changeOpportunityCurrencyQueuableJob = new changeOpportunityCurrencyQueuable(opp,opp.Pricebook2Id,'',opp.currencyisocode,expectedCurrencyIsoCode,false);            
            System.enqueueJob(changeOpportunityCurrencyQueuableJob);
            return 'currency Loading';
        }
        catch(Exception e) {
            String errMessage = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
                                e.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'): 
                                (e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION')? 
                                e.getMessage().substringAfterLast('FIELD_INTEGRITY_EXCEPTION,')
                                :e.getMessage());
            
            if(errMessage.containsIgnoreCase('pricebook entry is inactive'))
                errMessage = 'One of Opportunity price book entry is inactive.';                 
            Database.rollback(spForCurrencychangeOpportunityCurrency);
            System.debug('Error, method changeOpportunityCurrency, class CloneOpportunityWithProducts '+ e.getMessage());
            //ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='CloneOpportunityWithProducts ',ErrorDescription__c='Error '+e.getMessage(),FunctionName__c='changeOpportunityCurrency');
            //insert apexLogRecord; 
            ApexLogger.logError(new LogMessage('CloneOpportunityWithProducts','changeOpportunityCurrency',e)); 
            return errMessage;
        }
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 23 Jan 2018 
    // @param:opp Id - Id of opportunity to be cloned 
    // @description:This method clones the opportunity record. 
    // @return:Id of newly created opportunity  
    // @modification date : 4 July 2018
    // @modified by : Ankita Singh
    // @description : SFDC1-8878 : probablilty and Forecast Category should adjust as per stage while cloning for all opportunity record types  
    // @modification date: 28 Nov 2018
    // @modified by : Mohit Modi
    // @modification description :SFDC1-10521: Sending the error message to UI, so that correct message is displayed to User.
    //------------------------------
    @AuraEnabled
    public static string cloneOpportunityRecord(string oppId) {
        Savepoint sp = Database.setSavepoint();
        try 
        {
            GlobalConstants.disableOppyProductValidations = TRUE;
            Map<String,CloneOpportunityMapping__c> mapOppCloneMapping = CloneOpportunityWithProducts.getFilteredOpportunityMapping();
            String querySelect = 'SELECT ';
            for(CloneOpportunityMapping__c objIns : mapOppCloneMapping.values()) {
                querySelect = querySelect + objIns.Name + ',';                
            }
            //SFDC1-7782 : Removing the LEADLINK__C
            querySelect = querySelect +'Opportunity.RecordType.Name,Opportunitynum__c,ASSOCIATEDWITHRESPONSEMANAGEMENTTEAM__C,AUTORENEWAL__C,DOESTHISAUTORENEWALHAVECHANGES__C,LEADORIGIN__C,LEADSOURCE,MARKETINGCAMPAIGN__C,PROBABILITY,TYPE ';
            String queryFrom = 'FROM Opportunity ';
            String queryWhere = 'WHERE Id = \''+oppId+'\' LIMIT 1';
        
            String query = querySelect + queryFrom + queryWhere;
            Opportunity oppRec = Database.query(query);
            
            List<OpportunityContactRole> lstOppContacts = new List<OpportunityContactRole>([Select ContactId,OpportunityId,IsPrimary,Role from OpportunityContactRole where OpportunityId =:oppId]);
            
            Opportunity newOppRec;
            if(oppRec != NULL) {
                    newOppRec = new Opportunity();
                    for(CloneOpportunityMapping__c objIns : mapOppCloneMapping.values()) {
                        newOppRec.put(objIns.Name , oppRec.get(objIns.Name));  
                    } 
                    if(oppRec.RecordType.Name == 'New Business') {
                        newOppRec.ASSOCIATEDWITHRESPONSEMANAGEMENTTEAM__C = oppRec.ASSOCIATEDWITHRESPONSEMANAGEMENTTEAM__C;
                        newOppRec.AUTORENEWAL__C = oppRec.AUTORENEWAL__C ;
                        newOppRec.DOESTHISAUTORENEWALHAVECHANGES__C = oppRec.DOESTHISAUTORENEWALHAVECHANGES__C ;
                        //SFDC1-7782 : Removing the LEADLINK__C
                        //newOppRec.LEADLINK__C = oppRec.LEADLINK__C ;
                        newOppRec.LEADORIGIN__C = oppRec.LEADORIGIN__C ;
                        newOppRec.LEADSOURCE = oppRec.LEADSOURCE ;
                        newOppRec.MARKETINGCAMPAIGN__C = oppRec.MARKETINGCAMPAIGN__C ;
                       // newOppRec.PROBABILITY = oppRec.PROBABILITY ; Probablity should reflect as per stage
                        newOppRec.TYPE = oppRec.TYPE ;
                        newOppRec.ForecastCategoryName = 'Pipeline';
                        newOppRec.StageName = '1-Sales Qualified';
                    } 
                    if(oppRec.RecordType.Name == 'Renewal' || oppRec.RecordType.Name == 'Inner year') {
                        Id nbRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
                        newOppRec.RecordTypeId = nbRecordTypeId ;
                        newOppRec.ForecastCategoryName = 'Pipeline';
                        newOppRec.StageName = '1-Sales Qualified';
                    } 
                    if(oppRec.RecordType.Name == 'Gratis' || oppRec.RecordType.Name == 'Forecasting Placeholder') {
                      newOppRec.ForecastCategoryName = 'Pipeline';
                      newOppRec.StageName = '1-Open';      
                    }
                    newOppRec.SourceSystem__c = 'Clone';
                    newOppRec.Name = newOppRec.Name.left(112) + ' - Clone';
                    if(newOppRec.Description == null) {
                        newOppRec.Description  = 'Cloned from Oppy # ' +oppRec.Opportunitynum__c +' -';
                    }
                    else {
                        newOppRec.Description  = 'Cloned from Oppy # ' +oppRec.Opportunitynum__c +' -'+newOppRec.Description;
                    }
                    insert newOppRec;
                if(lstOppContacts.size()>0 && newOppRec != NULL) {
                    List<OpportunityContactRole> lstOppContactsToBeCloned = new List<OpportunityContactRole>();
                    for(OpportunityContactRole oppRecContact: lstOppContacts) {
                        OpportunityContactRole ocrObj = new OpportunityContactRole();
                        ocrObj.ContactId = oppRecContact.ContactId;
                        ocrObj.OpportunityId = newOppRec.Id;
                        ocrObj.IsPrimary = oppRecContact.IsPrimary;
                        ocrObj.Role = oppRecContact.Role;
                        lstOppContactsToBeCloned.add(ocrObj);
                    }
                    insert lstOppContactsToBeCloned;
                }
            }
            // Rashmeet : US - 6216236 :  Clone Functionality Asynchronous process
            //CloneOpportunityWithProducts.cloneOpportunityProducts(oppRec,oppRec.Pricebook2Id,newOppRec.id,oppRec.CurrencyIsoCode, oppRec.CurrencyIsoCode, true);
             //queuable change
            cloneOpportunityRecordQueuable cloneOpportunityRecordQueuableJob = new cloneOpportunityRecordQueuable(oppRec,oppRec.Pricebook2Id,newOppRec.id,oppRec.CurrencyIsoCode, oppRec.CurrencyIsoCode, true);            
            System.enqueueJob(cloneOpportunityRecordQueuableJob);
            
            return newOppRec.id;
        }
        catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error, method cloneOpportunityRecord, class CloneOpportunityWithProducts '+ e.getMessage());
            //ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='CloneOpportunityWithProducts ',ErrorDescription__c='Error '+e.getMessage(),FunctionName__c='cloneOpportunityRecord');
            //insert apexLogRecord;  
            ApexLogger.logError(new LogMessage('CloneOpportunityWithProducts','cloneOpportunityRecord',e));
            
            if(e.getMessage().contains('VALIDATION_EXCEPTION')) {//FIELD_FILTER_VALIDATION_EXCEPTION and FIELD_CUSTOM_VALIDATION_EXCEPTION
                throw new AuraHandledException (e.getMessage().substringBetween('VALIDATION_EXCEPTION,',':')); 
            } else {
                throw new AuraHandledException (e.getMessage());
            }
        }
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 23 Jan 2018 
    // @param:oppRecord - opportunity which is being cloned (original opportunity record)
    // @param:pricebookId - Id of pricebook related ot opportunity
    // @param:newOppId - Id of opportunity which is newly created 
    // @param:originalCurrency - CurrencyISOCode of original oppty
    // @param:expectedCurrency - CurrencyISOCode of after change
    // @param:isBeingCloned - Boolean set to tru when oppty is being cloned and set to false when currency os being changed
    // @description:This method clones the opportunity products related to opportunity record. 
    // @return:NA
    // @Update Author : Mohit Modi
    // @date : 14 March 2018
    // @Description : SFDC1-7158 : Added the where clause in Opportunity Product only for New and Existing Status
	// @Update Author : Sruti Srivastvaa
    // @date : 7th May 2018
    // @Description : SFDC1-7158 : fixing error when no Opprtunity product exist
    // @ModifiedBy : Paras Dhingra
    // @ModifiedDate: 09th July 2020
    // @ModifiedDescription: SFDC-2952 fix to enable change currency for lost products
    //------------------------------
    @AuraEnabled
    public static void cloneOpportunityProducts(Opportunity oppRecord, string pricebookId, string newOppId,string originalCurrency, string expectedCurrency, boolean isBeingCloned) {
        GlobalConstants.disableOppyProductValidations = TRUE;
        String oppId = oppRecord.Id;
        Map<String,CloneOpportunityProductMapping__c> mapOppCloneMapping = CloneOpportunityWithProducts.getFilteredOpportunityProductMapping();
        String querySelect = 'SELECT ';
        for(CloneOpportunityProductMapping__c objIns : mapOppCloneMapping.values()) {
            String name = objIns.Name;
            if(objIns.Name == 'PriorYearNumberOfConcurrentUsersSeats') {
                name = 'PriorYearNumberOfConcurrentUsersSeats__c';
            }
            querySelect = querySelect + name + ',';                
        }

        querySelect = querySelect +'Product2Id,Product2.Id,Product2.name,Status__c ';
        String queryFrom = 'FROM OpportunityLineItem ';
        String queryWhere = 'WHERE OpportunityId = \''+oppId+'\'';
        //if it is being cloned then check status because lost products should be cloned
        If(isBeingCloned) {
            queryWhere += ' and Status__c IN (\'New\',\'Existing\') ';
        }//else no check on status as currency should be changed on them
        
        String query = querySelect + queryFrom + queryWhere;
        List<OpportunityLineItem> lstOppLineItem = new List<OpportunityLineItem>();
		List<OpportunityLineItem> lstOppLineItemCloned = new List<OpportunityLineItem>();
        lstOppLineItem = Database.query(query);
        
		if(!lstOppLineItem.isEmpty()) {
			
			set<id> setProdId = new set<id>();
			set<id> setOppProdId = new set<id>();
			for(OpportunityLineItem opp :lstOppLineItem ) {
				setProdId.add(opp.Product2Id);
				setOppProdId.add(opp.id);
			}
			
			Map<String,PricebookEntry> pbs = new Map<String,PricebookEntry>();
			for(PricebookEntry record:[select id,unitprice,product2id,product2.name from pricebookentry where product2.Id in :setProdId and currencyisocode = :oppRecord.currencyisocode and pricebook2id = :pricebookId]) {
				pbs.put(record.product2.name, record);
			}
			Map<Id,OpportunityLineItem> mapOpportunityProductMapping = new Map<Id,OpportunityLineItem>();
			//fetching all the currency fields of the object
			//Set<String> currencyFieldsForMapping = new Set<String> {'ListPrice__c','PriorYearTotalDiscountAmt__c','PriorYearTotalSalesPrice__c','PriorYearUnit__c','ProjectedUnitPrice__c','ProRatedPrice__c','RecommendedUnitPrice__c', 'TotalPrice','FirstYear__c', 'UnitListPrice__c', 'AnnualizedPrice__c','ActiveInactiveNetUnitPrice__c', 'Discount_Amount__c','RecommendedUnitPrice__c','PricingOpsListUnitPrice__c'};
			Set<String> currencyFieldsForMapping = UtilityClass.getCurrencyFieldNames('OpportunityLineItem');
			// Fetching pricebook entries
			List<PriceBookEntry> lstPriceBookEntries = [Select id, Product2Id from PriceBookEntry where product2.Id IN:setProdId 
														and CurrencyIsoCode =:expectedCurrency];
			Map<Id,Id> mapProductPBEId = new Map<Id,Id>();

			if(lstPriceBookEntries!=null && lstPriceBookEntries.size()>0) {                        
				for(PriceBookEntry pbe : lstPriceBookEntries) {
					mapProductPBEId.put(pbe.Product2Id, pbe.Id);
				}
			}
			
			for(OpportunityLineItem oppRec: lstOppLineItem) {
                OpportunityLineItem newOppRec = new OpportunityLineItem();
                for(CloneOpportunityProductMapping__c objIns : mapOppCloneMapping.values()) {
                    String fieldAPIName = objIns.Name;
                    if(objIns.Name == 'PriorYearNumberOfConcurrentUsersSeats') {
                        fieldAPIName = 'PriorYearNumberOfConcurrentUsersSeats__c';
                    }
                    if((originalCurrency.equals(expectedCurrency)) || (!originalCurrency.Equals(expectedCurrency) && !(currencyFieldsForMapping.contains(objIns.Name)))) {
                        newOppRec.put(fieldAPIName , oppRec.get(fieldAPIName));
                    } 
                    else if(!originalCurrency.Equals(expectedCurrency) && (currencyFieldsForMapping.contains(fieldAPIName))) {
                        String value = String.valueOf(oppRec.get(fieldAPIName));
                        
                        if(value!=null) {
                            Decimal convertedValue = ProductEditController.getConvertedCurrencyRate(originalCurrency,expectedCurrency,Decimal.valueOf(value));
                            newOppRec.put(fieldAPIName , convertedValue);
                        }
                    } 
                }                                                                           
                if(originalCurrency.equals(expectedCurrency)) {
                    newOppRec.pricebookentryid = pbs.get(oppRec.product2.name).id;
                }
                else {
                    newOppRec.PricebookEntryId = mapProductPBEId.get(oppRec.product2.Id);
                }
                mapOpportunityProductMapping.put(oppRec.Id,newOppRec);
                if(isBeingCloned) {
                    newOppRec.OpportunityId = newOppId;
                    newOppRec.Status__c = 'New';
                }
                else {
                    newOppRec.OpportunityId = oppId;
                    newOppRec.Status__c = oppRec.Status__c;                                                         
                }
                lstOppLineItemCloned.add(newOppRec);                
            }
            if(isBeingCloned) {
                database.insert(lstOppLineItemCloned,false);
            }
            system.debug('lstOppLineItemCloned===='+lstOppLineItemCloned);
            CloneOpportunityWithProducts.cloneOpportunityProductSchedules(oppRecord,lstOppLineItemCloned,lstOppLineItem,mapOpportunityProductMapping,newOppId,originalCurrency,expectedCurrency, isBeingCloned, new list<id>(setOppProdId));
        }
		else {
			if(!isBeingCloned) {
				//Updating opportunity record
				oppRecord.CurrencyIsoCode = expectedCurrency;
				update oppRecord;
			}
		}
    }
    
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 23 Jan 2018 
    // @param:oppRecord - opportunity which is being cloned (original opportunity record)
    // @param:lstOppLineItemCloned - List of newly create opportunity line items
    // @param:lstOppLineItemProd - List of original opportunity line items
    // @param:mapOpportunityProductMapping - map with opportunity line item id as key and the record as value
    // @param:newOppId - Id of opportunity which is newly created 
    // @param:originalCurrency - CurrencyISOCode of original oppty
    // @param:expectedCurrency - CurrencyISOCode of after change
    // @param:isBeingCloned - Boolean set to tru when oppty is being cloned and set to false when currency os being changed
    // @description:This method clones the opportunity product schedules related to opportunity product record. 
    // @return:NA
    // @Update Author : Mohit Modi
    // @date : 14 March 2018
    // @Description : SFDC1-7158 : Added the where clause in Opportunity Product schedule only for New and Existing Status Opportunity line Item
    // @Update Author : Mohit Modi
    // @date : 23 March 2018
    // @Description : SFDC1-5722 : Added Global Constant check for bypassing the opportunitylineItem before deletion trigger
    // @Last Modified By: Harshit Singhal
    // @Last Modified Date: 25th June 2019
    // @Last Modified Description: SFDC-1680 In a cloning transaction, the opportunity product schedule should be cloned with Status='New'
    //------------------------------
    @AuraEnabled
    public static void cloneOpportunityProductSchedules(Opportunity oppRecord ,List<OpportunityLineItem>lstOppLineItemCloned,List<OpportunityLineItem>lstOppLineItemProd, Map<Id,OpportunityLineItem> mapOpportunityProductMapping, string newOppId, string originalCurrency, string expectedCurrency, boolean isBeingCloned, list<id> setOppProdId) {
        String oppId = oppRecord.Id;
        Map<String,CloneOpportunityProductScheduleMapping__c> mapCloneMapping = CloneOpportunityWithProducts.getFilteredOpportunityProdScheduleMapping();
        
        String querySelect = 'SELECT ';
        for(CloneOpportunityProductScheduleMapping__c objIns : mapCloneMapping.values()) {
            querySelect = querySelect + objIns.Name + ',';                
        }

        querySelect = querySelect +'Product__c,ProductSchedule__c,Opportunity__c,Status__c ';
        String queryFrom = 'FROM OpportunityLineItemSchedule__c ';
        String queryWhere = 'WHERE Opportunity__c = \''+oppId+'\'';
        queryWhere += ' and OpportunityProductID__c IN : setOppProdId ';
        
        String query = querySelect + queryFrom + queryWhere;
        system.debug('query -----'+query );
        List<OpportunityLineItemSchedule__c> lstOppLineItem = new List<OpportunityLineItemSchedule__c>();
        lstOppLineItem = Database.query(query);
        
        //Set<String> currencyFieldsForMapping = new Set<String> {'DiscountAmount__c','ExternalListPrice__c', 'PriceBookListPrice__c', 'TotalPrice__c', 'SalesPrice__c'};
        Set<String> currencyFieldsForMapping = UtilityClass.getCurrencyFieldNames('OpportunityLineItemSchedule__c');
        
        List<OpportunityLineItemSchedule__c> lstOppLineItemSchedulesCloned = new List<OpportunityLineItemSchedule__c>();
        
        if(!isBeingCloned) {
            // Adding the changes for GlobalConstant to bypass the Opportunity lineItem before delete trigger. Setting to True
            GlobalConstants.hasAllowedOpportunityProductDeletion = true;         
            delete lstOppLineItemProd;
            // Adding the changes for GlobalConstant to bypass the Opportunity lineItem before delete trigger. Setting to false back.
            GlobalConstants.hasAllowedOpportunityProductDeletion = false;
            oppRecord.CurrencyIsoCode = expectedCurrency;
            // Bypass OLI Risk Status update logic in trigger while cloning OLI during Currency Change on Oppy. 
            CloneOpportunityWithProducts.IsOppyProdBeingCloned = TRUE;
            update oppRecord;
            insert lstOppLineItemCloned;    
        }
        
        if(lstOppLineItem.size()>0) {
            for(OpportunityLineItemSchedule__c scheduleRec: lstOppLineItem) {
                OpportunityLineItemSchedule__c newScheduleRec = new OpportunityLineItemSchedule__c();
                for(CloneOpportunityProductScheduleMapping__c objIns : mapCloneMapping.values()) { 
                    String fieldAPIName = objIns.Name;
                    if((originalCurrency.equals(expectedCurrency)) || (!originalCurrency.Equals(expectedCurrency) && !(currencyFieldsForMapping.contains(fieldAPIName)))) {
                        newScheduleRec.put(fieldAPIName , scheduleRec.get(fieldAPIName));
                    }
                    else if(!originalCurrency.Equals(expectedCurrency) && (currencyFieldsForMapping.contains(fieldAPIName))) {
                        String value = String.valueOf(scheduleRec.get(fieldAPIName));
                        if(value!=null) {
                        Decimal convertedValue = ProductEditController.getConvertedCurrencyRate(originalCurrency,expectedCurrency,Decimal.valueOf(value));                     
                        newScheduleRec.put(fieldAPIName , convertedValue);
                        }
                    }
                } 
                newScheduleRec.Product__c = scheduleRec.Product__c;
                newScheduleRec.ProductSchedule__c = scheduleRec.ProductSchedule__c;
                newScheduleRec.OpportunityProductID__c = mapOpportunityProductMapping.get(scheduleRec.OpportunityProductID__c).Id;
                newScheduleRec.CurrencyIsoCode = expectedCurrency;
                
                if(isBeingCloned) {
                    newScheduleRec.Opportunity__c = newOppId;
                    newScheduleRec.Status__c = 'New';
                }
                else {
                    newScheduleRec.Opportunity__c = oppId;
                    newScheduleRec.Status__c = scheduleRec.Status__c;
                }
                lstOppLineItemSchedulesCloned.add(newScheduleRec);                         
            }            
            insert lstOppLineItemSchedulesCloned;
            system.debug('lstOppLineItemSchedulesCloned===='+lstOppLineItemSchedulesCloned);
        }       
    }
    public static Map<String,CloneOpportunityMapping__c> getFilteredOpportunityMapping() {
        Map<String,CloneOpportunityMapping__c> mapOppyMapping = new Map<String,CloneOpportunityMapping__c>();
        for(CloneOpportunityMapping__c mapping : CloneOpportunityMapping__c.getAll().values()) {
            if(IsOppyBeingCloned) {
                if(mapping.CopyDuringClone__c) {
                   mapOppyMapping.put(mapping.Name,mapping); 
                }
            }
            else if(IsCurrencyBeingChanged) {
                 if(mapping.CopyDuringCurrencyChange__c) {
                   mapOppyMapping.put(mapping.Name,mapping); 
                }
            }
        }
        return mapOppyMapping;
    }
    public static Map<String,CloneOpportunityProductMapping__c> getFilteredOpportunityProductMapping() {
        Map<String,CloneOpportunityProductMapping__c> mapOppyMapping = new Map<String,CloneOpportunityProductMapping__c>();
        for(CloneOpportunityProductMapping__c mapping : CloneOpportunityProductMapping__c.getAll().values()) {
            if(IsOppyBeingCloned) {
                if(mapping.CopyDuringClone__c) {
                   mapOppyMapping.put(mapping.Name,mapping); 
                }
            }
            else if(IsCurrencyBeingChanged) {
                 if(mapping.CopyDuringCurrencyChange__c) {
                   mapOppyMapping.put(mapping.Name,mapping); 
                }
            }
        }
        return mapOppyMapping;
    }
    public static Map<String,CloneOpportunityProductScheduleMapping__c> getFilteredOpportunityProdScheduleMapping() {
        Map<String,CloneOpportunityProductScheduleMapping__c> mapOppyMapping = new Map<String,CloneOpportunityProductScheduleMapping__c>();
        for(CloneOpportunityProductScheduleMapping__c mapping : CloneOpportunityProductScheduleMapping__c.getAll().values()) {
            if(IsOppyBeingCloned) {
                if(mapping.CopyDuringClone__c) {
                   mapOppyMapping.put(mapping.Name,mapping); 
                }
            }
            else if(IsCurrencyBeingChanged) {
                 if(mapping.CopyDuringCurrencyChange__c) {
                   mapOppyMapping.put(mapping.Name,mapping); 
                }
            }
        }
        return mapOppyMapping;
    }
}