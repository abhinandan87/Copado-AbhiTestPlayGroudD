////--------------------------------------
// @Author : Vishnu Vardhan Chowdary 
// @date: 08th Oct 2018
// @description : SFDC1-9003 Controller to create Order Management Delivery Helpdesk cases 
// 					from lightning quick action on Contract. 
// @company : Vertiba
//--------------------------------------
public without sharing class CreateOMDHCaseController {

    private static Id omdhRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId();
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 8 Oct 2018
    // @param: NA
    // @description: SFDC1- 9003 : The earlier requirement of creating Order Management delivery helpdesk 
    // 		case has been moved to lightning component. Accordingly moving all predefined values in existing
    // 		lightning quick action into Code.
    // @return: Case
    // @company: VERTIBA
    //------------------------------
    @AuraEnabled
    public static Case getOMDHRecord() {
        Case cas = new Case();
        cas.RecordTypeId = omdhRecordTypeId;
        //Values are not displayed in UI, but are stored in case. Moving values 
        //exactly as in existing quick actions. 
        cas.Origin = 'Contract';
        cas.Status = 'In Progress';
        cas.OMDStatus__c = 'New';
        cas.AccountName__c = System.Label.NewUserContactAccount;
        cas.ByPassValidation__c = true;
        return cas;
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 8 Oct 2018
    // @param: Id - ContractId for which OMDH case is about to be created
    // @description: SFDC1-9003: Create and return contract details to UI. Few details of 
    // 				contract are required to be shown on UI, add to case for persisting. 
    // @return: Contract - Few details of contract record
    // @company: VERTIBA
    //------------------------------
    @AuraEnabled
    public static Contract getContractDetails(Id contractId){
        Contract ctrct = [select Id, AccountId, ContractNumber from contract where id = :contractId];
        return ctrct;
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 8 Oct 2018
    // @param: Case - OMDH Case that will be created with teamselect as 'Order Management' or 'Retail'.  
    // @description: SFDC1-9003: OMDH Case will be created with teamselect as 'Order Management'
    // 				    or 'Retail' as selected in the lightning component.
    // @return: String - Success or error Message to be displayed in UI.
    // @company: VERTIBA
    //------------------------------
    @AuraEnabled
    public static String saveOMDHCase (Case cas) {
        String msg = 'Case record created';
        try {
            insert cas;
            //reverting by pass validation, so that next time when it is edited, validation should trigger
            //Internally when case is inserted Account is set to IHS Markit account, If cas is updated directly,  
            //then account the earlier set IHS Markit is reset with account from Contract and validation error 
            //is thrown. To avoid that creating a new case variable and updating here.
            Case c = new Case(id=cas.Id, ByPassValidation__c = false);
            update c;
        } catch (Exception e) {
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                msg = e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':');  
            } else {
                msg = e.getMessage();
            }
        }
        return msg;
    } 

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 8 Oct 2018
    // @param: Id - ContractId for which cases are to be created.  
    // @description: SFDC1-9003: Once user selects the Delivery as team select and continue, following steps occur:
    // 		1. Get products from the contract line items.
    // 		2. Get all the OM cases for contract with team select as delivery, and collect the related products.
    // 		3. Remove all the products in step 1, that are already part of OMDH cases in step 2.
    // 		4. Create a wrapper class for each product and return the list.
    // @return: List<ProductSelectorWrapperClass> - List to be displayed in the second screen for user to select.
    // @company: VERTIBA
    //------------------------------
    @AuraEnabled
    public static List<ProductSelectorWrapperClass> getAvailableProductsForContract(Id ContractId) {
        List<ProductSelectorWrapperClass> lstProductsToReturn = new List<ProductSelectorWrapperClass>();
        List<ContractLineItem__c> cliList = [Select id, associatedProduct__r.Name, associatedProduct__r.loadingGroup__r.name, 
                                     		associatedProduct__r.loadingGroup__r.DeliveryTeam__c, associatedProduct__r.Id 
                                             From ContractLineItem__c where Contract__c = :ContractId and 
                                            AssociatedProduct__r.LoadingGroup__r.LoadingGroupCategory__c = 'IHS'];
        Map<Id, ContractLineItem__c> cliMap = new Map<Id, ContractLineItem__c>();
        for(ContractLineItem__c clitem : cliList) {
            cliMap.put(clitem.AssociatedProduct__c, clitem);
        }
        if(cliMap.isEmpty()) {
            //No contract line items, we are displaing blank screen by returning empty list
            return lstProductsToReturn;
        }
        //Get all the OMDH cases for contract with team select as delivery, and collect the related products
        /**List<CaseProducts__c> cpList = [select id, Product__c from CaseProducts__c where Case__r.Contract__c = :ContractId
                                       and Case__r.recordTypeId = :omdhRecordTypeId and Case__r.TeamSelect__c = 'Delivery' 
                                       and Case__r.isClosed=false];
        //remove the products for which cases are already created. 
        for(CaseProducts__c caseProduct : cpList ) {
            cliMap.remove(caseProduct.product__c);
        }
        if(cliMap.isEmpty()) {
            //No new products to select we are displaing blank screen by returning empty list
            return lstProductsToReturn;
        }*/
        //create a wrapper and send to UI. Need Id, Product Name and Loading Group ID (to group)
        for(ContractLineItem__c clitem : cliMap.values()) {
            productSelectorWrapperClass wrapper = new productSelectorWrapperClass();
            wrapper.isSelected = false;
            wrapper.productName = clitem.associatedProduct__r.Name;
            wrapper.loadingGroupId = clitem.associatedProduct__r.loadingGroup__c;
            wrapper.productid = clitem.associatedProduct__r.Id;
            wrapper.deliveryTeam = clitem.associatedProduct__r.loadingGroup__r.DeliveryTeam__c;
            lstProductsToReturn.add(wrapper);
        }
        return lstProductsToReturn;
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 8 Oct 2018
    // @param: cas - Case record, according to which delivery cases will be created. 
    // 			WrapperJson- List of productSelectorWrapperClass that are selected in the UI to create products.  
    // @description: SFDC1-9003: Once user selects the products and submits following steps occur:
    // 		1. Group products based on loading group. For each loading group clone cas and create a case.
    // 		2. Insert cases. If SSO is selected, then set Delivery technical as Delivery team, else set
    // 				from loading group. If value is not there in case picklist, then set default value
    // 		3. Get inserted case Ids and based on loading groups, create Case products and insert it.
    // @return: String - Success or error Message to be displayed in UI.
    // @company: VERTIBA
    //------------------------------
    @AuraEnabled
    public static String createDeliveryCases(Case cas, String wrapperJson) {
        List<productSelectorWrapperClass> products = 
            (List<productSelectorWrapperClass>)JSON.deserialize(wrapperJson, List<productSelectorWrapperClass>.class);
        Map<Id, List<productSelectorWrapperClass>> loadingMap = new Map<Id, List<productSelectorWrapperClass>>();
        for(productSelectorWrapperClass product : products) {
            List<productSelectorWrapperClass> lst = new List<productSelectorWrapperClass>();
            //Once case is inserted, this map will be used to insert case product junction record.
            if(loadingMap.containsKey(product.loadingGroupId)) {
                lst = loadingMap.get(product.loadingGroupId);
            }
            lst.add(product);
            loadingMap.put(product.loadingGroupId, lst);
        }
        if(loadingMap.isEmpty()) {
            //Ideally we should never be here.
            return 'Selected Products dont have loading groups. Didnt create cases';
        }
        Set<String> delTeams = DependentPicklistUtil.getDependentOptionsImpl(Case.DeliveryTeam__c, case.TeamSelect__c).get('Delivery');
        Savepoint sp = Database.setSavepoint();
        try {
            List<Case> casesToInsert = new List<Case>();
            //Group selected products based on their loading group id. and create case for each group
            for(Id loadingGroupId : loadingMap.keySet()) {
                Case c = cas.clone();
                c.LoadingGroupOnboarding__c = loadingGroupId;
                productSelectorWrapperClass wclass = loadingMap.get(loadingGroupId).get(0);
                if(cas.SingleSignOnSAM__c) {
                    c.DeliveryTeam__c = 'Delivery Technical';
                } else if (delTeams.contains(wclass.deliveryTeam)) {
                    c.DeliveryTeam__c = wclass.deliveryTeam;
                } else {
                    c.DeliveryTeam__c = 'Global Delivery Help Desk'; //Set default value
                }
                casesToInsert.add(c);
            }
            //Insert list of cases.
            insert casesToInsert;
            //After inserting case, insert case products.
            List<CaseProducts__c> caseProductList = new List<CaseProducts__c>();
            for(Case c: casesToInsert) {
                List<productSelectorWrapperClass> prodList = loadingMap.get(c.LoadingGroupOnboarding__c);
                for(productSelectorWrapperClass wrapper : prodList) {
                    CaseProducts__c cp = new CaseProducts__c(Case__c = c.id, Product__c = wrapper.productid);
                    caseProductList.add(cp);
                }
            }
            insert caseProductList;
            //reverting by pass validation, so that next time when it is edited, validation should trigger
            //Internally when case is inserted Account is set to IHS Markit account, If cas is updated directly,  
            //then account the earlier set IHS Markit is reset with account from Contract and validation error 
            //is thrown. To avoid that creating a new case variable and updating here.
            List<Case> casesToUpdate = new List<Case>();
            for(Case ca: casesToInsert) {
                casesToUpdate.add(new Case(id=ca.Id, ByPassValidation__c = false));
            }
            update casesToUpdate;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('Error, method createDeliveryCases, class CreateOMDHCaseController ');
            ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='CreateOMDHCaseController ',ErrorDescription__c='Error: '+e.getMessage(),FunctionName__c='createDeliveryCases');
            insert apexLogRecord;
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                return e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION,',':');  
            } else {
                return e.getMessage();
            }
        } 
        return 'Cases are Created!';
    }
}