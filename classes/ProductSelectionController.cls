/**
 * @CreatedBy: Paras Dhingra
 * @CreatedDate : 12-09-201
 * @Description: SFDC-4540 Controller class to implement Product Legal Entity Selection
 * @Modified By: Akash Punera
 * @Modified Date: 22 Feb 2022
 * @Modified Reason: SFDC-5373 Remove SOQL inside for loop
 */
public without sharing class ProductSelectionController {
    @AuraEnabled
    public static LegalEntityResultWrapper productSelectionRuleEngine(String oppyId, List<Id> lstProducts) {
        LegalEntityResultWrapper legalWrapObjToReturn = new LegalEntityResultWrapper();
        try {
            //instance variables

            Set<Id> setProductIds = new Set<Id>();
            List<Product2> lstQueriedProducts = new List<Product2>();
            Map<Integer,List<ProductSelectionCriteria__c>> mapProdSelectionCriteria = new Map<Integer,List<ProductSelectionCriteria__c>>();
            Set<String> setFormerIpOwner = new Set<String>();
            Set<String> setBusinessLine = new Set<String>();
            List<LegalEntity__c> lstLegalEntityToReturn = new List<LegalEntity__c>();
            Set<Id> setlegalEntityToReturn = new Set<Id> ();
            Opportunity oppy = new Opportunity();
            Set<Id> setStep4NonUSDefaults = new Set<Id>();
            setStep4NonUSDefaults.addAll((List<Id>)System.Label.Step4NonUSDefaults.split(','));
            String oppyCountry;
            setProductIds.addAll(lstProducts);
            if(setProductIds!=null && !setProductIds.isEmpty()) {
                //check for product compatibility
                LegalEntityResultWrapper checkCompatibility = getListLegalEntity(lstProducts);
                If(checkCompatibility.result == 'FAILURE') {
                    return checkCompatibility;
                }
                lstQueriedProducts = [SELECT Id, BusinessLine2__c,MediaType__c,LegalEntity__c,ProductGroup__c,ProductGroup__r.Name,LegalEntity__r.LegalEntityText__c,IPJurisdiction__c,FormerIPOwner__c
                                        FROM Product2 WHERE ID IN: setProductIds];
                Set<Id> setLegalEntitiesRelatedToProduct = new Set<Id>();
                Set<Id> setProductGroupsRelatedToProduct = new Set<Id>();
                Set<Id> setProductIPJurisdiction = new Set<Id>();
                Set<Id> setProductBusinessLine = new Set<Id>();
                Set<String> setMediaType = new Set<String>();
                for( Product2 prod: lstQueriedProducts) {
                    setLegalEntitiesRelatedToProduct.add(prod.LegalEntity__c);
                    setProductGroupsRelatedToProduct.add(prod.ProductGroup__c);
                    setProductBusinessLine.add(prod.BusinessLine2__c);
                    setProductIPJurisdiction.add(prod.IPJurisdiction__c);
                    setMediaType.add(prod.MediaType__c);
                }
                // extract and create map of all the steps
                List<ProductSelectionCriteria__c> lstProductSelectionCriteria = [SELECT Id,StepNumber__c,BillingCountry__c,BusinessLine__c,FormerIPOwner__c,IPJurisdiction__c,MediaType__c,
                                                                        Order__c,ProductGroup__c,ProductLegalEntity__c,Region__c,TargetLegalEntity__c,CompareCurrency__c,CurrencyISOCode,PreferredLegalEntity__c
                                                                         FROM ProductSelectionCriteria__c order by StepNumber__c,Order__c];
                //SFDC-5282 Change Start
                //oppy = [Select Id, Account.AccountRegion__c,Account.AccountCountry__c,OpportunityCountry__c,ShipToCountryNew__c, RecordType.Name, CurrencyISOCode from Opportunity where Id =:oppyId limit 1];
                oppy = [Select Id, OpportunityRegion__c,Account.AccountCountry__c,OpportunityCountry__c,ShipToCountryNew__c, RecordType.Name, CurrencyISOCode from Opportunity where Id =:oppyId limit 1];
                //SFDC-5282 Change End
                oppyCountry = oppy.OpportunityCountry__c;
                system.debug('oppyCountry' +oppy.OpportunityCountry__c);
                //SFDC-5595 Change Start
				Country__c usCountry = [Select id from Country__c where Name = 'United States' Limit 1];
				String usCountryId = usCountry.id;
				Country__c rowCountry = [Select id from Country__c where Name = 'Rest of the World' Limit 1];
				String rowCountryId = rowCountry.id;
				//SFDC-5595 Change End
                if(oppy.recordType.Name == 'Renewal' && oppy.ShipToCountryNew__c!=null) {
                    //SFDC-5270 Change Start
                    //oppyCountry = UtilityClass.getCountry(oppy.ShipToCountryNew__c).Id;
                   	Country__c shipToCountry = UtilityClass.getCountry(oppy.ShipToCountryNew__c) == Null ? UtilityClass.getCountryByIsoCode(oppy.ShipToCountryNew__c) : UtilityClass.getCountry(oppy.ShipToCountryNew__c);
                    if(shipToCountry!=Null){
                    	oppyCountry = shipToCountry.Id;
                    }
                    //SFDC-5270 Change End
                }   
                if(lstProductSelectionCriteria!=null && !lstProductSelectionCriteria.isEmpty()) {
                    for(ProductSelectionCriteria__c prodSelObj : lstProductSelectionCriteria) {
                        Integer key = Integer.valueOf(prodSelObj.StepNumber__c);
                        if(mapProdSelectionCriteria.containsKey(key)) {
                            mapProdSelectionCriteria.get(key).add(prodSelObj);
                        } else {
                            List<ProductSelectionCriteria__c> tempLstProdSel = new List<ProductSelectionCriteria__c>();
                            tempLstProdSel.add(prodSelObj);
                            mapProdSelectionCriteria.put(key,tempLstProdSel);
                        }
                        //create former Ip set to compare
                        if(prodSelObj.stepNumber__c ==0) {
                            setFormerIpOwner.add(prodSelObj.FormerIPOwner__c);
                        }
                        if(prodSelObj.BusinessLine__c!=null) {
                            setBusinessLine.add(prodSelObj.BusinessLine__c);
                        }
                    }
                    //step 0 check for excluded services
                    /*if(mapProdSelectionCriteria.containsKey(0)) {
                        Set<String> setFormerIpOwnerText = new Set<String>();
                        List<ProductSelectionCriteria__c> formerIpLst = new List<ProductSelectionCriteria__c>();
                        formerIpLst = mapProdSelectionCriteria.get(0);
                    }*/
                    List<Integer> lstOfKeys = new List<Integer>(mapProdSelectionCriteria.keySet());
                    lstOfKeys.sort();
                    for(Integer step: lstOfKeys) {
                        System.debug('@PD Control reached here line 70');
                        if(step == 0) {//process step 0

                            //if all product matches exlcuded services then show all related legal entities
                            //traverse all products 
                            Integer formerIpCount = 0;
                            for(Product2 prod: lstQueriedProducts) {
                                if(setFormerIpOwner.contains(prod.FormerIPOwner__c)) {
                                    formerIpCount++;
                                }  
                            }
                            if(formerIpCount == lstQueriedProducts.size()) {
                                //all products are related to excluded services
                                //SFDC-5373 Remove SOQL inside for loop, query on Legal Entity not required here as it is queried again after the for loop
                                //lstLegalEntityToReturn = [Select Id, Name from LegalEntity__c WHERE Status__c = 'Active' Order by Name];
                                break;// break the criteria loop and skip further checks
                            }
                        }

                        if(step == 1) { // process step 1
                            //process each criteria record
                            for(ProductSelectionCriteria__c prodSelCri : mapProdSelectionCriteria.get(step)) {
                                if((prodSelCri.BillingCountry__c==null || prodSelCri.BillingCountry__c==oppyCountry) &&
                                    (prodSelCri.BusinessLine__c==null || setProductBusinessLine.contains(prodSelCri.BusinessLine__c)) && 
                                    (prodSelCri.CompareCurrency__c==false || (prodSelCri.CompareCurrency__c && oppy.CurrencyISOCode == prodSelCri.CurrencyISOCode)) &&
                                    (prodSelCri.MediaType__c==null || setMediaType.contains(prodSelCri.MediaType__c))
                                    ) {
                                        if(prodSelCri.PreferredLegalEntity__c!=null && setlegalEntityToReturn.contains(prodSelCri.PreferredLegalEntity__c)) {
                                            setlegalEntityToReturn.add(prodSelCri.PreferredLegalEntity__c);
                                        } else {
                                            setlegalEntityToReturn.add(prodSelCri.TargetLegalEntity__c);
                                        }
                                }
                                //check if business line is not null
                                /*if(prodSelCri.BillingCountry__c!=null && oppyCountry==prodSelCri.BillingCountry__c && prodSelCri.BusinessLine__c==null) {
                                    setlegalEntityToReturn.add(prodSelCri.TargetLegalEntity__c);
                                }
                                if(prodSelCri.BusinessLine__c!=null  && oppyCountry==prodSelCri.BillingCountry__c) {
                                    for(Product2 prod: lstQueriedProducts) {
                                        if(setBusinessLine.contains(prod.BusinessLine2__c)) {
                                            setlegalEntityToReturn.add(prodSelCri.TargetLegalEntity__c);
                                        }
                                    }
                                }*/
                            }
                        }
                        System.debug('@PD set legal entity to return after step1 '+setlegalEntityToReturn);
                        if(step == 2) {
                            Set<Id> tempStep2LE = new Set<Id>();
                            //check for restricted products
                            for(ProductSelectionCriteria__c prodSelCri : mapProdSelectionCriteria.get(step)) { 
                                //check if the legal entity is related to the product
                                
                                if(setLegalEntitiesRelatedToProduct.contains(prodSelCri.ProductLegalEntity__c)) {
                                    if( (prodSelCri.BillingCountry__c==null ||  (oppyCountry!=null && oppyCountry==prodSelCri.BillingCountry__c )) &&
                                        (prodSelCri.ProductGroup__c==null || (prodSelCri.ProductGroup__c!=null && setProductGroupsRelatedToProduct.contains(prodSelCri.ProductGroup__c ))) 
                                    ) {
                                        if(prodSelCri.PreferredLegalEntity__c!=null && tempStep2LE.contains(prodSelCri.PreferredLegalEntity__c)) {
                                            tempStep2LE.add(prodSelCri.PreferredLegalEntity__c);
                                        } else {
                                            tempStep2LE.add(prodSelCri.TargetLegalEntity__c);
                                        }
                                        
                                    }
                                }
                                
                            }
                           if(tempStep2LE!=null && !tempStep2LE.isEmpty()) {
                               setlegalEntityToReturn = new Set<Id>();
                               setlegalEntityToReturn.addAll(tempStep2LE);
                           }
                        }
                        System.debug('@PD set legal entity to return after step2 '+setlegalEntityToReturn);
                        if(step == 3) {
                            //check if any legal entity is identified
                            if(setlegalEntityToReturn!=null && !setlegalEntityToReturn.isEmpty()) {
                                //all relevant legal entities found in step 2
                                break;
                            }
                            //add defaul legal entity based on the account country
                            for(ProductSelectionCriteria__c prodSelCri : mapProdSelectionCriteria.get(step)) { 
                                if((prodSelCri.BillingCountry__c!=null && oppyCountry==prodSelCri.BillingCountry__c && setlegalEntityToReturn.isEmpty()) || prodSelCri.BillingCountry__c==null) {
                                    setlegalEntityToReturn.add(prodSelCri.TargetLegalEntity__c);
                                    legalWrapObjToReturn.recommendedLegalEntity = prodSelCri.TargetLegalEntity__c;
                                    break;
                                }
                            }
                            
                        }
                        //add pre-approved exceptions based on certain criteria
                        if(step == 4) {
                            for(ProductSelectionCriteria__c prodSelCri : mapProdSelectionCriteria.get(step)) { 
                                //check all attributes for this step
                                if((prodSelCri.BillingCountry__c==null || prodSelCri.BillingCountry__c==oppyCountry || (oppyCountry!=usCountryId && prodSelCri.BillingCountry__c==rowCountryId ))  &&  //SFDC-5595 Change
                                   //SFDC-5282 Change Start
                                    //(prodSelCri.Region__c==null || prodSelCri.Region__c==oppy.Account.AccountRegion__c) &&
                                   	(prodSelCri.Region__c==null || prodSelCri.Region__c==oppy.OpportunityRegion__c) &&
                                   //SFDC-5282 Change End
                                    (prodSelCri.IPJurisdiction__c == null || setProductIPJurisdiction.contains(prodSelCri.IPJurisdiction__c)) &&
                                    (prodSelCri.BusinessLine__c == null || setProductBusinessLine.contains(prodSelCri.BusinessLine__c)) &&
                                    (prodSelCri.ProductLegalEntity__c == null || setLegalEntitiesRelatedToProduct.contains(prodSelCri.ProductLegalEntity__c))  //SFDC-5595 change
                                ) {
                                    setlegalEntityToReturn.add(prodSelCri.TargetLegalEntity__c);
                                }
                                
                            }
                            //check if country is non US
                            Id US = UtilityClass.getCountryByIsoCode('US').Id;
                            if(US!=null && oppyCountry!=US) {
                                setlegalEntityToReturn.addAll(setStep4NonUSDefaults);
                            }
                        }
                    }

                } 
            
            
            
            //implement step by step implementation of the policy

            }
            if(setlegalEntityToReturn!=null && !setlegalEntityToReturn.isEmpty()) {
                lstLegalEntityToReturn = [Select Id, Name from LegalEntity__c where Id IN: setlegalEntityToReturn and Status__c = 'Active' Order By Name];
            } else {
                /********************If all else fails send the list of all legal entities Start****************** */
                lstLegalEntityToReturn = [Select Id, Name from LegalEntity__c Where Status__c = 'Active' Order By Name];
            
                /********************END****************** */
            }
            //Uncomment the below code to enable to RLE compatibility check with products
			//LegalEntityResultWrapper checkLegalEntityCompatible = checkLegalEntityCompatibility(lstLegalEntityToReturn, lstProducts);
			//if(checkLegalEntityCompatible.result == 'FAILURE') {
            	//return checkLegalEntityCompatible;
            //}
            legalWrapObjToReturn.result = 'Success';
            legalWrapObjToReturn.lstRecommendedLegalEntity = lstLegalEntityToReturn;
            if(legalWrapObjToReturn.recommendedLegalEntity==null) {
                legalWrapObjToReturn.recommendedLegalEntity = lstLegalEntityToReturn[0].Id;
            }
            return legalWrapObjToReturn;
            
        } catch (Exception e) {
            legalWrapObjToReturn.result = 'FAILURE';
            legalWrapObjToReturn.errorMessage = e.getMessage();
            System.debug('error message' + e.getMessage());
            System.debug('error message' + e.getLineNumber());
            return legalWrapObjToReturn;
        }
    }
    
   /*
    * @Author : Manish Kumar
    * @date: 30th Sep 2021
    * @description : SFDC-4540 Update Legal Entity and add Products on Opportunity
    * @param : List<String>, String, String, Boolean, Boolean
    * @return : String
    */
    @AuraEnabled
    public static String saveProductsOnOpportunity(list<string> lstProductIds, String opportunityId, String legalEntity, Boolean changeLegalEntityCheck, Boolean productsRemovedCheck) {
        String message = '';
        Savepoint sp = Database.setSavepoint();
        Set<Id> setIds = New Set<id>();
        Map<Integer, OpportunityLineItem> mapOli = New Map<Integer, OpportunityLineItem>();
        Map<Integer, OpportunityLineItemSchedule__c> mapOlis = new Map<Integer, OpportunityLineItemSchedule__c>();
        List<OpportunityLineItemSchedule__c> lstOpportunityProductSchedules = new List<OpportunityLineItemSchedule__c>();
        Set<id> setProduct2Id = New set<id>();

        //query the Opportunity
        Opportunity oppy = [Select id, LegalEntity__c, OwnerId, StageName, CurrencyIsoCode, ContractStartDate__c, CloseDate, ExceptionStatus__c, RequestedLegalEntity__c from Opportunity where Id=:opportunityId limit 1 ];
        
        if(changeLegalEntityCheck == false && productsRemovedCheck == false){    
        	//close date is a required field on oppy and cannot be null
			Date pricingDate = oppy.CloseDate;
        	if(oppy.ContractStartDate__c!=null) {
				pricingDate = oppy.ContractStartDate__c;
			}
            
        	//Query Current Fiscal Year
        	String currentFiscalYear = [SELECT FiscalYearSettings.Name FROM Period WHERE Type = 'Year' AND StartDate <=:pricingDate AND EndDate >=:pricingDate].FiscalYearSettings.Name;

        	//Query Price Book Entries
        	List<PriceBookEntry> lstPriceBookEntries = [Select id, Product2Id from PriceBookEntry where product2Id IN:lstProductIds and isActive=true 
                                                    	and Pricebook2.Name = 'Standard Price Book' and CurrencyIsoCode =:oppy.CurrencyIsoCode ORDER BY product2Id ASC];
        
        	//Query Product Schedules
        	List<ProductSchedule__c> lstProductSchedule = [Select id, Product__c, InstallmentYear__c, ListPrice__c from ProductSchedule__c where Product__c in :lstProductIds and IsActive__c = true and PricingYear__c = :currentFiscalYear and ProductTerm__c = '1 Year' Order by Product__c ASC ];
            
        	Integer index = 1;
        	if(lstPriceBookEntries!=null && lstPriceBookEntries.size()>0) {
            	for(String prd : lstProductIds){
        			for(PriceBookEntry pbeId : lstPriceBookEntries){
                    	if(prd == pbeId.Product2Id){
        					OpportunityLineItem oli = New OpportunityLineItem();
        					oli.PricebookEntryId = pbeId.Id;
        					oli.Opportunity__c = opportunityId;
        					oli.OpportunityId = opportunityId;
        					oli.ProductOwner__c = oppy.OwnerId;
        					oli.Status__c = 'New';
        					oli.Quantity = 1;
        					oli.UnitPrice = 0;
        					oli.FirstYear__c = 0.0;
                
       						if(lstProductSchedule!=Null && lstProductSchedule.size()>0){
            					for(ProductSchedule__c ps: lstProductSchedule){
                        			if(ps.Product__c == pbeId.Product2Id){
                						OpportunityLineItemSchedule__c olis = New OpportunityLineItemSchedule__c();
                						olis.ProductSchedule__c = ps.id;
                						olis.Product__c = ps.Product__c;
                						olis.Opportunity__c = opportunityId;
                						olis.Status__c = 'New';
                						olis.Quantity__c = 1;
                                    	olis.CurrencyIsoCode = oppy.CurrencyIsoCode;
                                    	olis.ExternalListPrice__c = ps.ListPrice__c;
                    					olis.SalesPrice__c = ps.ListPrice__c;
                    					olis.TotalPrice__c = ps.ListPrice__c;
										olis.DiscountPercent__c = 0.0;
										olis.DiscountAmount__c = 0.00;
										olis.PriceBookListPrice__c = ps.ListPrice__c;                    
                    					olis.InstallmentYears__c = ps.InstallmentYear__c;
                						mapOlis.put(index, olis);
                            			Break;
            						}
                    			}
                			}
                
                			mapOli.put(Index, oli);
                			index++;
                        
                    	}
                	}
        		}
        	}
        
            try {
                if(mapOli!=null && mapOli.size()>0) {
                    insert mapOli.values();
                    List<OpportunityLineItemSchedule__c> listOppySchedulesToInsert = new List<OpportunityLineItemSchedule__c>();
                	for(Integer i : mapOlis.keySet()) {
                        OpportunityLineItemSchedule__c olis = mapOlis.get(i);
                        olis.OpportunityProductID__c = mapOli.get(i).Id;
                        listOppySchedulesToInsert.add(olis);
                        
                    }
                    
                    insert listOppySchedulesToInsert;
                	//update legal entity on opportunity
                	//if(oppy.LegalEntity__c != legalEntity) {                   //SFDC-5126 Change
                	//SFDC-5500 Change Start  
                    oppy.RequestedLegalEntity__c = legalEntity;
                    oppy.ExceptionStatus__c = 'Exception Requested';
                    update oppy;
                    if(oppy.LegalEntity__c != oppy.RequestedLegalEntity__c) {
                        List<OpportunityLineItem> olisToUpdate = New List<OpportunityLineItem>();
                    	List<OpportunityLineItem> olis = [Select PriorApproved__c from OpportunityLineItem where OpportunityId = :oppy.id and PriorApproved__c = true];
                    	for(OpportunityLineItem oli : olis) {
                        	oli.PriorApproved__c = false;
                        	olisToUpdate.add(oli);
                    	}
                        if(olisToUpdate.size() > 0) {
                    		update olisToUpdate;
                        }
                    }
                    //SFDC-5500 Change End
                	//}                                                          //SFDC-5126 Change
				
                	message = 'Records added successfully';
            	}
            }catch(Exception e) {
                	message = 'Error occurred while creating records :'+e.getMessage();
                	Database.rollback(sp);
             }
        }
                    
        else{
            try{
                if(oppy.LegalEntity__c != legalEntity) {
            		oppy.RequestedLegalEntity__c = legalEntity;
                    oppy.ExceptionStatus__c = 'Exception Requested';
                	update oppy;
                    //SFDC-5500 Change Start
                    message = 'Records updated successfully';
                    List<OpportunityLineItem> olisToUpdate = New List<OpportunityLineItem>();
                    List<OpportunityLineItem> olis = [Select PriorApproved__c from OpportunityLineItem where OpportunityId = :oppy.id and PriorApproved__c = true];
                    for(OpportunityLineItem oli : olis) {
                        oli.PriorApproved__c = false;
                        olisToUpdate.add(oli);
                    }
                    if(olisToUpdate.size() > 0) {
                    	update olisToUpdate;
                    }
            	}                                            
            	//message = 'Records updated successfully';
            	//SFDC-5500 Change End
        	}
            catch(Exception e) {
                	message = 'Error occurred while updating records :'+e.getMessage();
                	Database.rollback(sp);
             }
        }
        	 return message;
    }
    
    /*
    * @Author : Manish Kumar
    * @date: 4th Oct 2021
    * @description : SFDC-4731 Fetch Opportunity Country/Territory
    * @param : String
    * @return : String
    */
    @AuraEnabled
    public static String getOppCountry(String opportunityId) {
        String optyCountry = '';
        Opportunity oppy = [Select id, OpportunityCountry__r.Name, ShipToCountryNew__c, OpportunityRecordType__c from Opportunity where Id=:opportunityId limit 1 ];
        if(oppy!=null) {
            if(oppy.OpportunityRecordType__c == 'Renewal' && oppy.ShipToCountryNew__c!= null){
                optyCountry = oppy.ShipToCountryNew__c;
            }
            else{
        		optyCountry = oppy.OpportunityCountry__r.Name;
            }
        }
        return optyCountry;   
    } 
    
    /*
    * @Author : Manish Kumar
    * @date: 4th Oct 2021
    * @description : SFDC-4731 Send email to Legal Team for Offline Exception Approval
    * @param : String, String, String, String, String, String, String
    * @return : Boolean
    */
    @AuraEnabled
    public static Boolean exceptionApprovalEmail(String opportunityId, String requestReason, String requestedLegalEntity, String dollarValue, String countryTerritory, String materialCodes, String lstProductsAdded) {
        /*SFDC-5500 Change Start
        List<String> materialcodelist =new List<String>();
        for(String str:materialCodes.split(',')) {
            if(!String.isBlank(str)) {
                materialcodelist.add(str.trim());
            }
        }
        List<product2> productlist= [select Name, MaterialCode__c from product2 where MaterialCode__c IN:materialcodelist];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        EmailTemplate et = [Select Id, Subject, Name, HtmlValue from EmailTemplate where DeveloperName = 'ProductSelectionExceptionRequestEmail'];
        Opportunity opp = [Select id, Opportunitynum__c from Opportunity where id = :opportunityId limit 1];
        String EmailBodyLink1 = System.Label.EmailBodyLink1;
        String EmailBodyLink2 = System.Label.EmailBodyLink2;
        Integer currentYear = System.Today().year();
        String sCurrentYear = String.valueOf(currentYear);
        String EmailFooterLink1 = System.Label.EmailFooterLink1;
        String EmailFooterLink2 = System.Label.EmailFooterLink2;
        String EmailFooterLink3 = System.Label.EmailFooterLink3;
        String EmailFooterLink4 = System.Label.EmailFooterLink4;
        String EmailFooterAddress1 = System.Label.EmailFooterAddress1;
        String TaxTeamEmailAddress = System.Label.TaxTeamEmailAddress;
        String ContractManagementTeamEmailAddress = System.Label.ContractManagementTeamEmailAddress;
        String salesUserName = UserInfo.getName();
        String salesUserEmail = UserInfo.getUserEmail();
        if(!dollarValue.containsAny('.')){
            dollarValue = dollarValue + '.00';
        }
        String optyLink = System.Label.SalesforceBaseURL + opportunityId;
        
        //process merge fields for Subject
        String subject = et.Subject;
        subject = subject.replace('{!Opportunity.Opportunitynum__c}', opp.Opportunitynum__c);
        
        //process merge fields for Body
        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('{!requestReason}', requestReason);
        htmlBody = htmlBody.replace('{!requestedLegalEntity}', requestedLegalEntity);
        htmlBody = htmlBody.replace('{!countryTerritory}', countryTerritory);
        htmlBody = htmlBody.replace('{!dollarValue}', dollarValue);
        htmlBody = htmlBody.replace('{!materialCodes}', getTableBody(productlist));
        htmlBody = htmlBody.replace('{!salesUserName}', salesUserName);
        htmlBody = htmlBody.replace('{!$Label.EmailBodyLink1}', EmailBodyLink1);
        htmlBody = htmlBody.replace('{!$Label.EmailBodyLink2}', EmailBodyLink2);
        htmlBody = htmlBody.replace('{!Opportunity.Link}', optyLink);
        
        //process merge fields for Footer
        htmlBody = htmlBody.replace('{!YEAR(TODAY())}', sCurrentYear);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink1}', EmailFooterLink1);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink2}', EmailFooterLink2);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink3}', EmailFooterLink3);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink4}', EmailFooterLink4);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterAddress1}', EmailFooterAddress1);
        
        mail.setSubject(subject);
        mail.setSenderDisplayName(salesUserName);
        mail.toAddresses = new String[] {TaxTeamEmailAddress};
        mail.ccAddresses = new String[]{salesUserEmail, ContractManagementTeamEmailAddress};
        mail.setHtmlBody(htmlBody);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setWhatId(opportunityId);
        
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success){
            System.debug('The email was sent successfully');
        }
        else{
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
        */
        List<OPSWrapper> lstOPSWrapper = (List<OPSWrapper>)JSON.deserialize(lstProductsAdded, List<OPSWrapper>.class);
        List<Id> lstOliIds = New List<Id>();
		if(lstOPSWrapper!=null && !lstOPSWrapper.isEmpty()) {
        	for(OPSWrapper opsWrap : lstOPSWrapper) {
            	If(opsWrap.isDeleted == false) {
                	lstOliIds.add(opsWrap.oppyProduct.Id);
            	}
        	}
        }
        String salesUserEmail = UserInfo.getUserEmail();
        String taxTeamEmailAddress = System.Label.TaxTeamEmailAddress;
        String userETDevName = 'ProductSelectionExceptionRequestEmail';
        String taxTeamETDevName = 'ProductSelectionExceptionRequestEmailForTaxTeam';
        Boolean result1 = exceptionRequestEmail(salesUserEmail, opportunityId, userETDevName, requestReason, requestedLegalEntity, dollarValue, countryTerritory, materialCodes, lstOliIds);
        Boolean result2 = exceptionRequestEmail(taxTeamEmailAddress, opportunityId, taxTeamETDevName, requestReason, requestedLegalEntity, dollarValue, countryTerritory, materialCodes, lstOliIds);
        return result2;
        //SFDC-5500 Change End
    }
    
    /*
    * @Author : Manish Kumar
    * @date: 5th Oct 2021
    * @description : SFDC-4531 Fetch Legal Entity list based on Selected products and related product extensions
    * @param : List<Id>
    * @return : LegalEntityResultWrapper
    */
    @AuraEnabled
    public static LegalEntityResultWrapper getListLegalEntity(List<id> lstProducts) {
        LegalEntityResultWrapper legalWrapObjToReturn = new LegalEntityResultWrapper();
        set<id> setIds = New set<id>();
        Set<String> requiredLegalEntityIds = new Set<String>();
        set<id> setProdIds = New set<id>();
        for(id prodId : lstProducts){
            setProdIds.add(prodId);
        }
        If(setProdIds.size() > 1){
        	//Set to store Ids of common Legal Entities
			Set<String> prodExtMultiLegalEntityIds = new Set<String>();
            
            //Set to store Ids of non-common Legal Entities
        	Set<String> prodExtSingleLegalEntityIds = new Set<String>();
        	
            //Retrieve common Legal Entities
			List<ProductExtensions__c> lstProdExtLegalEntities = [Select LegalEntity__r.Name, LegalEntity__r.Id, product__c 
                                                                  from ProductExtensions__c where product__c in :setProdIds 
                                                                  and Status__c = 'Active' ORDER BY LegalEntity__r.Name, product__c ASC];
            List<Product2> lstProdLegalEntities = [Select LegalEntity__r.Name, LegalEntity__r.Id from Product2 
                                       				  where id in :setProdIds ORDER BY LegalEntity__r.Name ASC];
			id prdId = null;
			Map<String, String> mapOfLegalEntityIdAndProdId = New Map<String, String>();
        	Set<string> setLegalEntityIds = new Set<string>();
        	if(lstProdExtLegalEntities!=null && !lstProdExtLegalEntities.isEmpty()) {
            	for(ProductExtensions__c pe : lstProdExtLegalEntities) {
                	setLegalEntityIds.add(pe.LegalEntity__r.Id);
            	}
        	}

            if(lstProdLegalEntities!=null && !lstProdLegalEntities.isEmpty()) {
            	for(Product2 prodct : lstProdLegalEntities) {
                    if(!setLegalEntityIds.contains(prodct.LegalEntity__r.Id)){
                		setLegalEntityIds.add(prodct.LegalEntity__r.Id);
                    }
            	}
        	}

            Integer counter = 0;
			Set<String> setOfProducts = New set<String>();
            for(string legEnt : setLegalEntityIds){
            	for(ProductExtensions__c pele : lstProdExtLegalEntities){
                	if(pele.LegalEntity__r.Id == legEnt){
                    	for(id productId : setProdIds){
                        	if(pele.product__c == productId && pele.product__c !=prdId){
                            	counter = counter + 1;
                                prdId=pele.product__c;
                                setOfProducts.add(productId);
                            	Break;
                        	}
                    	}
                	}
            	}
                
                if(counter != setProdIds.size()){
                	for(Product2 prd : lstProdLegalEntities){
                        if(!setOfProducts.contains(prd.id)){
                    		if(prd.LegalEntity__r.Id == legEnt){
                       			counter = counter + 1;
                    		}
                        }
                	}
                }
				system.debug('counter: ' +counter);
                if(counter == setProdIds.size()){
                    prodExtMultiLegalEntityIds.add(legEnt);
                }
                else{
                    prodExtSingleLegalEntityIds.add(legEnt);
                }
            	counter=0;
                prdId=null;
                setOfProducts.clear();
        	}
			
            System.debug('prodExtMultiLegalEntityIds: ' +prodExtMultiLegalEntityIds);
            System.debug('prodExtSingleLegalEntityIds: ' +prodExtSingleLegalEntityIds);
            
        	if(prodExtMultiLegalEntityIds!=Null && prodExtMultiLegalEntityIds.size()>0){
            	requiredLegalEntityIds.addAll(prodExtMultiLegalEntityIds);
        	}
            
        	List<LegalEntity__c> lstLegalEntity = New list<LegalEntity__c>();
        	if(requiredLegalEntityIds!=Null && requiredLegalEntityIds.size()>0){
        		lstLegalEntity = [Select id, Name from LegalEntity__c where id in :requiredLegalEntityIds and Status__c ='Active' Order By Name];
        		legalWrapObjToReturn.result = 'SUCCESS';
            	legalWrapObjToReturn.lstRecommendedLegalEntity = lstLegalEntity;
            	return legalWrapObjToReturn;
        	}
        	else{
        		legalWrapObjToReturn.result = 'FAILURE';
            	legalWrapObjToReturn.errorMessage = 'No compatible Legal Entity found for selected products';
            	return legalWrapObjToReturn;     
        	}
        }
        else{
        	List<ProductExtensions__c> lstProductExt = [Select id, LegalEntity__c from ProductExtensions__c where product__c in :setProdIds and Status__c = 'Active' ];
        	if(lstProductExt!=Null && lstProductExt.size()>0){
            	for(ProductExtensions__c pe : lstProductExt){
                    setIds.add(pe.LegalEntity__c);
        		}
       	 	}
        
        	list<Product2> lstprod = [Select id, LegalEntity__c from Product2 where id in :setProdIds];
        	if(lstprod!=Null && lstprod.size()>0){
            	for(Product2 prd : lstprod){
            		setIds.add(prd.LegalEntity__c);
        		}
        	}
        
        	List<LegalEntity__c> lstLegalEntity = New list<LegalEntity__c>();
            if(setIds!=Null && setIds.size()>0){
        		lstLegalEntity = [Select id, Name from LegalEntity__c where id in :setIds and Status__c ='Active'];
                legalWrapObjToReturn.result = 'SUCCESS';
            	legalWrapObjToReturn.lstRecommendedLegalEntity = lstLegalEntity;
            	return legalWrapObjToReturn;
            }
            else{
        		legalWrapObjToReturn.result = 'FAILURE';
            	legalWrapObjToReturn.errorMessage = 'No Legal Entity found for selected products';
            	return legalWrapObjToReturn;     
        	} 
        }
    }
    /*
    * @Author : Manish Kumar
    * @date: 28th Oct 2021
    * @description : SFDC-4901 Update changed Legal Entity on Opportunity
    * @param : String, String
    * @return : String
    */
    @AuraEnabled
    public static string updateLegalEntityOnOppy(String opportunityId, String legalEntity) {
        String message = '';
        Opportunity oppy = [Select id,LegalEntity__c, ExceptionStatus__c, RequestedLegalEntity__c from Opportunity where Id=:opportunityId limit 1 ];
        try{
            if(oppy!=null) {
        		oppy.LegalEntity__c = legalEntity;
                if(oppy.ExceptionStatus__c == 'Exception Request Denied' && oppy.RequestedLegalEntity__c != null){
                    oppy.ExceptionStatus__c = '';
                    oppy.RequestedLegalEntity__c = null;
                }
            	update oppy;
        	}
            message = 'Records updated successfully';
        }
        catch(Exception e) {
        	message = 'Error occurred while updating records :'+e.getMessage();
        }
        return message;
    }
	
	/*
    * @Author : Manish Kumar
    * @date: 8th Dec 2021
    * @description : SFDC-5082 Match the RLE with Legal Entity list based on Selected products and related product extensions
    * @param : List<LegalEntity__c>, List<Id>
    * @return : LegalEntityResultWrapper
    */
    @AuraEnabled
    public static LegalEntityResultWrapper checkLegalEntityCompatibility(List<LegalEntity__c> lstLegalEntity, list<id> lstProducts) {
        LegalEntityResultWrapper legalWrapObjToReturn = new LegalEntityResultWrapper();
        String ProductNames = '';
		set<id> setRecLegalEntityIds = New set<id>();
        for(LegalEntity__c le : lstLegalEntity){
            setRecLegalEntityIds.add(le.Id);
        }
		set<id> setProdIds = New set<id>();
        for(id prodId : lstProducts){
            setProdIds.add(prodId);
        }
		Map<id, Set<id>> mapOfProductAndLegalEntities = New Map<id, Set<id>>();
        //Retrieve Product Extensions for selected products
		List<ProductExtensions__c> lstProdExtLegalEntities = [Select LegalEntity__r.Name, LegalEntity__r.Id, product__c 
                                                              from ProductExtensions__c where product__c in :setProdIds 
                                                              and Status__c = 'Active' ORDER BY product__c ASC];
        List<Product2> lstProdLegalEntities = [Select Name, LegalEntity__r.Name, LegalEntity__r.Id from Product2 
                                       				  where id in :setProdIds ORDER BY Id ASC];
        
        for(Product2 prod : lstProdLegalEntities){
            set<id> setLegalEntityIds = New set<id>();
            setLegalEntityIds.add(prod.LegalEntity__r.Id);
            for(ProductExtensions__c pe : lstProdExtLegalEntities){
                if(pe.Product__c == prod.Id){
                    setLegalEntityIds.add(pe.LegalEntity__r.Id);
                }
            }
            mapOfProductAndLegalEntities.put(prod.Id, setLegalEntityIds);
        }

        for(LegalEntity__c le : lstLegalEntity){
            for(Product2 prd : lstProdLegalEntities){
                set<id> setOfLegalEntityForProduct = mapOfProductAndLegalEntities.get(prd.Id);
                if(!setOfLegalEntityForProduct.contains(le.Id)){
                    ProductNames = ProductNames + 'Recommended Legal Entity \'' + le.Name + '\' is not compatible with the selected product \'' + prd.Name + '\'\n';
                }
            }
        }
        if(ProductNames!=Null && ProductNames.length() > 0){
        	legalWrapObjToReturn.result = 'FAILURE';
        	legalWrapObjToReturn.errorMessage = ProductNames;
            return legalWrapObjToReturn;
        }
        else{
            legalWrapObjToReturn.result = 'SUCCESS';
        	return legalWrapObjToReturn;
        }
    }
    
    public static string getTableBody(List<OpportunityLineItem> oliList) {
        String htmlBody = '';
        //create table.
        htmlBody = '<table border="1" cellpadding="10" style="border-color:#485865;"><tr><th style="text-align:left; color:#485865;">SAP Material Code</th><th style="text-align:left; color:#485865;">Product Name</th><th style="text-align:left; color:#485865;">Previously Approved</th></tr>';
        //iterate over list and output columns/data into table rows...
        for(OpportunityLineItem oli : oliList) {
            htmlBody += '<tr><td style="text-align:left; color:#485865;">' + oli.MaterialCode__c + '</td><td style="text-align:left; color:#485865;">' + oli.product2.Name + '</td><td style="text-align:left; color:#485865;">' + oli.PriorApproved__c + '</td></tr>';
        }
        //End table.
        htmlBody += '</table>';
        return htmlBody;
    }
    
    /*
    * @Author : Manish Kumar
    * @date: 23rd March 2022
    * @description : SFDC-5500 Send offline exception request email 
    * @param : String, String, String, String, String, String, String, String, List<id>
    * @return : Boolean
    */
    public static Boolean exceptionRequestEmail(String toEmailAddress, String opportunityId, String developerName, String requestReason, String requestedLegalEntity, String dollarValue, String countryTerritory, String materialCodes, List<id> lstOliIds) {
		String previousApprovedOli = '';
        String previousNonApprovedOli = '';
        List<OpportunityLineItem> olis = New List<OpportunityLineItem>();
		if(lstOliIds!=null && !lstOliIds.isEmpty()) {
            olis = [Select Product2.Name, MaterialCode__c, PriorApproved__c from OpportunityLineItem where id IN :lstOliIds order by product2.Name ASC];
        }
        else{
        	olis = [Select Product2.Name, MaterialCode__c, PriorApproved__c from OpportunityLineItem where opportunityId = :opportunityId order by product2.Name ASC];
        }
        List<OpportunityLineItem> approvedOli = New List<OpportunityLineItem>();
        List<OpportunityLineItem> nonApprovedOli = New List<OpportunityLineItem>();
        for(OpportunityLineItem oli : olis) {
            if(oli.PriorApproved__c == true && previousApprovedOli != oli.Product2.Name) {
            	approvedOli.add(oli);
                previousApprovedOli = oli.Product2.Name;
            }
            else if(oli.PriorApproved__c == false && previousNonApprovedOli != oli.Product2.Name) {
                nonApprovedOli.add(oli);
                previousNonApprovedOli = oli.Product2.Name;
            }
        }
        EmailTemplate et = [Select Id, Subject, Name, HtmlValue from EmailTemplate where DeveloperName = :developerName];
        Opportunity opp = [Select id, Opportunitynum__c from Opportunity where id = :opportunityId limit 1];
        String EmailBodyLink1 = System.Label.EmailBodyLink1;
        String EmailBodyLink2 = System.Label.EmailBodyLink2;
        Integer currentYear = System.Today().year();
        String sCurrentYear = String.valueOf(currentYear);
        String EmailFooterLink1 = System.Label.EmailFooterLink1;
        String EmailFooterLink2 = System.Label.EmailFooterLink2;
        String EmailFooterLink3 = System.Label.EmailFooterLink3;
        String EmailFooterLink4 = System.Label.EmailFooterLink4;
        String EmailFooterAddress1 = System.Label.EmailFooterAddress1;
        String InboundEmailAddress = System.Label.ProductSelectionInboundEmailAddress;
        String salesUserName = UserInfo.getName();
        if(!dollarValue.containsAny('.')) {
            dollarValue = dollarValue + '.00';
        }
        String optyLink = System.Label.SalesforceBaseURL + opportunityId;
        
        //process merge fields for Subject
        String subject = et.Subject;
        subject = subject.replace('{!Opportunity.Opportunitynum__c}', opp.Opportunitynum__c);
        
        //process merge fields for Body
        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('{!requestReason}', requestReason);
        htmlBody = htmlBody.replace('{!requestedLegalEntity}', requestedLegalEntity);
        htmlBody = htmlBody.replace('{!countryTerritory}', countryTerritory);
        htmlBody = htmlBody.replace('{!dollarValue}', dollarValue);
        htmlBody = htmlBody.replace('{!existingMaterialCodes}', getTableBody(approvedOli));
        htmlBody = htmlBody.replace('{!newMaterialCodes}', getTableBody(nonApprovedOli));
        htmlBody = htmlBody.replace('{!salesUserName}', salesUserName);
        htmlBody = htmlBody.replace('{!$Label.EmailBodyLink1}', EmailBodyLink1);
        htmlBody = htmlBody.replace('{!$Label.EmailBodyLink2}', EmailBodyLink2);
        htmlBody = htmlBody.replace('{!Opportunity.Link}', optyLink);
        htmlBody = htmlBody.replace('{!OpportunityId}', opportunityId);
        htmlBody = htmlBody.replace('{!InboundEmailAddress}', InboundEmailAddress);
        
        //process merge fields for Footer
        htmlBody = htmlBody.replace('{!YEAR(TODAY())}', sCurrentYear);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink1}', EmailFooterLink1);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink2}', EmailFooterLink2);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink3}', EmailFooterLink3);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterLink4}', EmailFooterLink4);
        htmlBody = htmlBody.replace('{!$Label.EmailFooterAddress1}', EmailFooterAddress1);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setSubject(subject);
        mail.setSenderDisplayName(salesUserName);
        mail.toAddresses = new String[] {toEmailAddress};
        mail.setHtmlBody(htmlBody);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setSaveAsActivity(true);
        mail.setWhatId(opportunityId);
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully');
        }
        else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
        return results[0].success;
    }
    
}