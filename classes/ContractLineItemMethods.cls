//@Author : Jagadesh Kumar
//@Date : 20th Dec 2018
//@Description : SFDC1-10588 Trigger helper method class for ContractLineItem__c object 
//@company : Vertiba
// 
// @ModifiedBy: Tran-Vu Tran
// @ModifiedDate: 20 Feb 2019
// @Modification: SFDC-887 refactored rollupProductInfoToContract method to handle the roll-up update
// 				and resolve "invalid query locator" error when adding more than 30 products,
// 				also added logic to roll up Product Family from Contract Line Item to Contract record
// @ModifiedBy: Paras Dhingra
// @ModifiedDate: 15/07/2019
// @ModifiedDescription: SFDC-1346 Addinge new rollup fields on contract and opportunity
// @ModifiedBy: Sushma Yadav
// @ModifiedDate: 4th Jun 2020
// @ModifiedDescription: SFDC-2969 Adding new rollup field on contract and opportunity

public class ContractLineItemMethods {
    
    //@author : Jagadesh Kumar
    //@date : 20th Dec 2018
    //@description : SFDC1-10588 Rollup product group from ContractLineItem to contract level 
    //@modifiedBy: Tran-Vu Tran
    //@modifiedDate: 20 Feb 2019
    //@modifiedDescription: SFDC-887 refactored rollupProductInfoToContract method to handle the roll-up update
    // 						and resolve "invalid query locator" error when adding more than 30 products,
    // 						also added logic to roll up Product Family from Contract Line Item to Contract record
    //@param : TriggerParameters
    //@return : void
    //@companyname : Vertiba
	// @ModifiedBy: Paras Dhingra
	// @ModifiedDate: 15/07/2019
	// @ModifiedDescription: SFDC-1346 Addinge new rollup fields on contract and opportunity
    public static void rollupProductInfoToContract(TriggerParameters tp) {  
        try {
            Set<Id> contractIds = new Set<Id>();

            if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert 
                || tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate
                || tp.tEvent == TriggerParameters.TriggerEvent.afterUndelete) {
                for (ContractLineItem__c cli: (List<ContractLineItem__c>) tp.newList) {
                    contractIds.add(cli.Contract__c);
                }
            }
            
            if (tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                for (ContractLineItem__c cli: (List<ContractLineItem__c>) tp.oldList) {
                    contractIds.add(cli.Contract__c);
                }           
            }
            
            if (!contractIds.isEmpty()) {
                rollupProductInfoToContract(contractIds);
            }
            
        } catch(Exception ex) {
			String errMessage = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')?
                ex.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):ex.getMessage();
            System.debug('Exception occured while rollupProductInfoToContract :' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'ContractLineItemMethods', 'rollupProductInfoToContract');
			tp.newList[0].addError('Error: ' + errMessage);
        }
    }
    
    //@author: Tran-Vu Tran
    //@date: 25 Feb 2019
    //@description: SFDC-887 refactored rollupProductInfoToContract method above to handle the roll-up update
    // 						and resolve "invalid query locator" error when adding too many products,
    // 						also added logic to roll up Product Family from Contract Line Item to Contract record
	// @modifiedBy: Paras Dhingra
	// @modifiedDate: 10th June 2020
	// @modifiedDescription: SFDC-99 Replacing Product__c with AssociatedProduct__c as it is a duplicate field
	// @date: 28 Feb 2022
    // @description: SFDC-5557,updated logic to use AutoCalculateRollupValueHelper class  
    public static void rollupProductInfoToContract(Set<Id> contractIds) {
		System.Savepoint sp = Database.setSavepoint();
        try {
            List<Contract> contractList = [Select Id, BusinessLine__c,SubBusinessLine__c,GlobalSegments__c,InternalBusinessSegment__c,ProductGroup__c, ProductFamily__c,AAG__c from Contract where Id in : contractIds];
            
            List<Contract> contractToBeUpdatedList = new List<Contract>();
            
            //Map<Id, List<ContractLineItem__c>> mapContract_LineItems = new Map<Id, List<ContractLineItem__c>>();
            //SFDC-1346 adding new rollup fields at contract level
            List<ContractLineItem__c> lineItemList = [Select Id, AssociatedProduct__r.ProductGroup__r.Name, AssociatedProduct__r.Family__r.Name,AssociatedProduct__r.AAG__c,Contract__c,
                                                 AssociatedProduct__r.SubBusinessLine__r.name, AssociatedProduct__r.BusinessLine2__r.Name, AssociatedProduct__r.Division__c, AssociatedProduct__r.InternalBusinessSegment__c            
                                                 FROM ContractLineItem__c where Contract__c in: contractIds and Status__c != 'Lost'];
            contractToBeUpdatedList=AutoCalculateRollupValueHelper.rollupProductInfoToParent(contractList,lineItemList,'Contract__c',Null);
            /*SFDC- 5557 Commenting this logic , AutoCalculateRollupValueHelper class will be used to calculate logic
            {
                List<ContractLineItem__c> contractLineItems = mapContract_LineItems.get(lineItem.Contract__c);
                if (contractLineItems == null) {
                    contractLineItems = new List<ContractLineItem__c>();
                }
                contractLineItems.add(lineItem);
                mapContract_LineItems.put(lineItem.Contract__c, contractLineItems);
            } 
            
            for (Contract contract : contractList) {
                List<ContractLineItem__c> contractLineItems = mapContract_LineItems.get(contract.Id);
                if (contractLineItems != null) {
                    //initialize sets and add values from related child ContractLineItems
                    Set<String> productGroups = new Set<String>();
                    Set<String> productFamilies = new Set<String>();
                    //SFDC-1346 adding string sets for business line, sub business line and global segment(division__c) #start
                    Set<String> productBusinessLine = new Set<String>();
                    Set<String> productSubBusinessLine = new Set<String>();
                    Set<String> productGlobalSegment = new Set<String>();
                    //SFDC-1346 #end
                    //SFDC-2969 adding string set for internal business segment
                    Set<String> productInternalBusinessSegment = new Set<String>();
                    for (ContractLineItem__c lineItem : contractLineItems) {
                        // getting the Product Group Name from the Contract Line Item's Product
                        if (lineItem.AssociatedProduct__r.ProductGroup__r.Name != null) {
                            productGroups.add(lineItem.AssociatedProduct__r.ProductGroup__r.Name.trim());                                                                      
                        }
                        
                        // getting the Product Family Name from the Contract Line Item's Product
                        if (lineItem.AssociatedProduct__r.Family__r.Name != null) {
                            productFamilies.add(lineItem.AssociatedProduct__r.Family__r.Name.trim());                                                                      
                        }
                        //SFDC-1346 #start
                        // getting the Business line from the Contract line item's product
                        if (lineItem.AssociatedProduct__r.BusinessLine2__r.Name!=null) {
                            productBusinessLine.add(lineItem.AssociatedProduct__r.BusinessLine2__r.Name.trim());
                        }
                        if (lineItem.AssociatedProduct__r.SubBusinessLine__r.Name!=null) {
                            productSubBusinessLine.add(lineItem.AssociatedProduct__r.SubBusinessLine__r.Name.trim());
                        }
                        if (lineItem.AssociatedProduct__r.Division__c!=null) {
                            productGlobalSegment.add(lineItem.AssociatedProduct__r.Division__c);
                        }
                        //SFDC-1346 #end
                        //SFDC-2969
                        if (lineItem.AssociatedProduct__r.InternalBusinessSegment__c!=null) {
                            productInternalBusinessSegment.add(lineItem.AssociatedProduct__r.InternalBusinessSegment__c);
                        }
                    }
                    
                    contract.ProductGroup__c = '';
                    //process product groups and create comma separated values
                    if (productGroups.size() > 0) { 
                        List<String> productGroupList = new List<String>(productGroups);
                        productGroupList.sort();
                        contract.ProductGroup__c = String.join(productGroupList, ',');     
                    }
                    System.debug('rollupProductInfoToContract - productGroups: ' + productGroups);
                    
                    contract.ProductFamily__c = '';
                    //process product families and create comma separated values
                    if (productFamilies.size() > 0) { 
                        List<String> productFamilyList = new List<String>(productFamilies);
                        productFamilyList.sort();
                        contract.ProductFamily__c = String.join(productFamilyList, ',');     
                    }
                    System.debug('rollupProductInfoToContract - productFamilies: ' + productFamilies);
    				//SFDC-1346 #start
    				// adding business lines
                    if (productBusinessLine.size()>0) {
                        List<String> productBusinessList = new List<String>(productBusinessLine);
                        productBusinessList.sort();
                        contract.BusinessLine__c = String.join(productBusinessList, ',');     
                    }
                    // adding product sub business lines
                    if (productBusinessLine.size()>0) {
                        List<String> productBusinessList = new List<String>(productBusinessLine);
                        productBusinessList.sort();
                        contract.BusinessLine__c = String.join(productBusinessList, ',');     
                    }
                    if (productSubBusinessLine.size()>0) {
                        List<String> productSubBusinessList = new List<String>(productSubBusinessLine);
                        productSubBusinessList.sort();
                        contract.SubBusinessLine__c = String.join(productSubBusinessList, ',');     
                    }
                    // adding product global segment
                    if (productGlobalSegment.size()>0) {
                        List<String> productGlobalSegmenList = new List<String>(productGlobalSegment);
                        productGlobalSegmenList.sort();
                        contract.GlobalSegments__c = String.join(productGlobalSegmenList, ',');     
                    }
    				//SFDC-1346 #end
    				//SFDC-2969
    				if (productInternalBusinessSegment.size()>0) {
                        List<String> productInternalBusinessSegmenList = new List<String>(productInternalBusinessSegment);
                        productInternalBusinessSegmenList.sort();
                        contract.InternalBusinessSegment__c = String.join(productInternalBusinessSegmenList, ',');     
                    }
                    contractToBeUpdatedList.add(contract);
                }
            }
            */
            if (!contractToBeUpdatedList.isEmpty()) {
                update contractToBeUpdatedList;
            }
            
        }
        catch(Exception ex) {
			Database.rollback(sp);
            throw(ex);
        }
    }
        
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 05 Oct 2020
    // @description: SFDC-3403: Moved "LockContractLineItem" validation rule to code. This method stops users from updating contract line items if the parent Contract is marked as Complete.
    // @param: TriggerParameters
    // @return: None
    // @modified by: Paras Dhingra
    // @date: 10th May 2021
    // @description: SFDC-4066 Giving access to custom permission ContractLineItemEditAccessFinancialServicesteam to allow users to 
    //                  add billing info and create volume billing records
    //-----------------------------
    public static void lockCLIForCompletedContracts(TriggerParameters tp) {        
        if(GlobalVariables.shouldCLIValidationBypass) {
            return;
        }
        Set<String> setProfilesAllowed = new Set<String>{'System Administrator', 'IHSMarkit System Admin', 'IHSMarkit System Admin: API', 'IHSMarkit Contract Management', 'IHSMarkit Sales: User Support', 'IHSMarkit Sales: Sales Coordinator'};        
        String profileName = UtilityClass.LoggedInUserProfileName;        
        Boolean isPermAssigned = FeatureManagement.checkPermission('RevenueAssuranceForBSLI');
        if(!isPermAssigned) {//if user does not have elevated access. check for another permission set
            isPermAssigned = FeatureManagement.checkPermission('ContractLineItemEditAccessFinancialServicesteam');
            if(isPermAssigned) {
                GlobalVariables.shouldContractValidationBypass = true;
            }
        }
        if (!setProfilesAllowed.contains(profileName) && !isPermAssigned) {
            Map <String, Schema.SobjectField > cliFields = ContractLineItem__c.sObjectType.getDescribe().fields.getMap();
            Map<Id,ContractLineItem__c> newCLIMap = new Map<Id,ContractLineItem__c>([SELECT Id,Contract__c,Contract__r.Status FROM ContractLineItem__c WHERE Id IN :tp.newList]);
            for(ContractLineItem__c newCLI: (List<ContractLineItem__c>)tp.newList) {
                Boolean hasError = false;
                ContractLineItem__c oldCLI = (ContractLineItem__c)tp.oldMap.get(newCLI.Id);
                ContractLineItem__c newCLIWithContractInfo = newCLIMap.get(newCLI.Id);
                if(newCLIWithContractInfo.Contract__c!=null && newCLIWithContractInfo.Contract__r.Status=='Complete') {
                    for(string fieldName : cliFields.keySet()) {
                        Schema.DescribeFieldResult dfr = cliFields.get(fieldName).getDescribe();
                        if(oldCLI.get(fieldName)!=newCLI.get(fieldName) && !dfr.IsCalculated()) {
                            hasError = true;
                            break;
                        }
                    }
                    if(hasError) {
                        newCLI.addError('Contract Line Items are locked for editing after stage is completed');
                    }
                }                
            }
        }        
    }

    /** 
    * @author: Digvijay
    * @date: 3 May 2021
    * @description: SFDC-4069- Do not allow  users with "ContractLineItemEditAccessFinancialServicesteam" permission set  to delete contract Line Items.
    * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got deleted.
    * @return: void
    */
    public static void preventContractLineItemDeletion(TriggerParameters tp) {
        List<PermissionSetAssignment> lstpermset=[SELECT Id, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE 
                            PermissionSet.Name =: System.Label.ContractLineItemEditAccessPermissionSet and AssigneeId =: Userinfo.getUserId() limit 1];
        List<ContractLineItem__c> listContractlineItems = (List<ContractLineItem__c>) tp.oldList;
        for(ContractLineItem__c cliObj : listContractlineItems ) {
            if(!lstpermset.IsEmpty()){
                cliObj.addError('You are not authorized to Delete a Contract Line Item.');
            }
        }               
    }
}