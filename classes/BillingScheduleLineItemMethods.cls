//-----------------------------
// @author: Mohit Modi
// @date: 16 April 2018
// @description: This Class will hold all the methods related to Billing Schedule Line Items.
// @Last Modified By: Sruti Srivastava
// @Modification: SFDC1-9599- Added method rollupValuesToContractLineItem which rolls up unit price to Contract line item 
// @Last Modified Date: 4 Sept 2018
// @return: None
// @Last Modified By: Mohit Modi
// @Modification: SFDC1-9908- Added Logic for Auto-populate billing start dates on Billing Schedule Line Item
// @Last Modified Date: 17 Sept 2018
// @return: None
//@lastmodified by: Paras Dhingra
//@lastmodified date: 01 July 2019
//@lastmodified description : SFDC-1661 fixing the issue to allow order management team to modify variable/volume billing in 11-completed contract
//------------------------------
public class BillingScheduleLineItemMethods {

    //-----------------------------
    // @author: Mohit Modi
    // @date: 16 April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7472 : This Method is used to create the Billing Schedule Line Item records based on the Contract line Item's Biiling Period Value. Called from After Insert and before Insert trigger.
    // @return: None
    //------------------------------
    public static void CreateCloneBillingScheduleLIFromCLIandPreventBSLICreation(TriggerParameters tp) {

        // List of new values
        list<BillingScheduleLineItem__c> listNewBillingScheduleLI = (List<BillingScheduleLineItem__c>)tp.newlist;
        // Map of Old values
        Map<Id,BillingScheduleLineItem__c> mapOldBillingScheduleLI = (Map<Id,BillingScheduleLineItem__c>)tp.oldMap;
        // Map of CLI Id and BillingScheduleLineItem
        Map<id,BillingScheduleLineItem__c> mapContractLIIdBillingScheduleLI = new Map<id,BillingScheduleLineItem__c>();
        // Map of CLI Id and Count of Billing Period on CLI, based on whcih BillingScheduleLineItem records will be created
        Map<id,Decimal> mapCLIIBillingPeriod = new Map<id,Decimal>();
        // Map of CLI Id and Count of Existing BillingScheduleLineItem records
        Map<id,Decimal> mapCLIIBillingScheduleLICount = new Map<id,Decimal>();
        // Map of CLI Id and Billing Schedule Type on CLI, based on whcih BillingScheduleLineItem records will be created
        Map<id,String> mapCLIIBillingScheduleType = new Map<id,String>();
        // Map of CLI Id and Max StartDate of Existing BillingScheduleLineItem records
        Map<id,Date> mapCLIIMaxBillingStartDate = new Map<id,Date>();
        Date FirstBSLIRecDate = NULL;
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
            for(BillingScheduleLineItem__c bslObj : listNewBillingScheduleLI) {
                // This will be run only for the BillingScheduleLineItem created from quick action
                if(bslObj.IsCreatedfromQuickAction__c == true && bslObj.ContractLineItem__c != NULL) {
                    mapContractLIIdBillingScheduleLI.put(bslObj.ContractLineItem__c,bslObj);
                }   
            }
        }
        
        if(!mapContractLIIdBillingScheduleLI.isEmpty()) {
            //Query for the Count of BillingPeriods__c on CLI and to check the existing count of BillingScheduleLineItem records
            for(BillingScheduleLineItem__c bslObj : [select id,BillingStartDate__c,ContractLineItem__r.BillingPeriods__c,ContractLineItem__r.BillingScheduleType__c, ContractLineItem__c,IsCreatedfromQuickAction__c from BillingScheduleLineItem__c where ContractLineItem__c in : mapContractLIIdBillingScheduleLI.keyset() ]) {
                // This map will hold the values of CLI and its BillingPeriods value
                mapCLIIBillingPeriod.put(bslObj.ContractLineItem__c,bslObj.ContractLineItem__r.BillingPeriods__c);
                mapCLIIBillingScheduleType.put(bslObj.ContractLineItem__c,bslObj.ContractLineItem__r.BillingScheduleType__c);
                
                //This map will hold the count of existing BillingScheduleLineItem records on CLI including the existing which is created from quick action.
                Decimal bslCount = 0;
                if(mapCLIIBillingScheduleLICount.containskey(bslObj.ContractLineItem__c)) {
                    bslCount = mapCLIIBillingScheduleLICount.get(bslObj.ContractLineItem__c);
                }
                mapCLIIBillingScheduleLICount.put(bslObj.ContractLineItem__c,bslCount+1);
                
                //This map will hold the max of Start date of Existing BillingScheduleLineItem, based on this new Billing Schedule Line Item will have the Start Dates
                if(bslObj.BillingStartDate__c != NULL && FirstBSLIRecDate == NULL) {
                    FirstBSLIRecDate = bslObj.BillingStartDate__c;
                }
                if(bslObj.BillingStartDate__c != NULL) {
                    if(FirstBSLIRecDate < bslObj.BillingStartDate__c) {
                        FirstBSLIRecDate = bslObj.BillingStartDate__c ;
                    }
                    mapCLIIMaxBillingStartDate.put(bslObj.ContractLineItem__c,FirstBSLIRecDate);
                }
                
            }
        }
        
        if(!mapCLIIBillingPeriod.isEmpty()) {
            
            // After Insert is to create the Addition BillingScheduleLineItem record from Billing Period on CLI using Clone
            if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert ) {
            
                try {
                List<BillingScheduleLineItem__c> listBillingScheduleLineItemtobeCreated = new List<BillingScheduleLineItem__c> ();
            
                for(Id cliId : mapCLIIBillingPeriod.keyset()) {
                    // Checking if Exiting record count of BillingScheduleLineItem is less then the BillingPeriods on CLI, if Yes, then create the remaining BillingScheduleLineItem records.
                    if(mapCLIIBillingPeriod.get(cliId) > mapCLIIBillingScheduleLICount.get(cliId)) {
                        Decimal remainingBSLI = mapCLIIBillingPeriod.get(cliId) - mapCLIIBillingScheduleLICount.get(cliId) ;
                        
                        for( integer i = 0 ; i < remainingBSLI ; i++) {
                            
                            BillingScheduleLineItem__c objBsliNew = new BillingScheduleLineItem__c();
                            // Object clone Parameters (preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber)
                            objBsliNew = mapContractLIIdBillingScheduleLI.get(cliId).clone(false,false,false,false);
                            
                            objBsliNew.IsCreatedfromQuickAction__c = false;
                            
                            // Adding Start Dates to new cloned Billing Schedule Line Item 
                            //*** ONLY IF Start Date is fillied on First Record and the Schedule Type is in (Monthly,Quarterly,Semi-annual)
                            if( mapCLIIMaxBillingStartDate.containskey(cliId) && mapCLIIBillingScheduleType.containskey(cliId) &&
                               (mapCLIIBillingScheduleType.get(cliId) == 'Monthly' || 
                                mapCLIIBillingScheduleType.get(cliId) == 'Quarterly' ||
                                mapCLIIBillingScheduleType.get(cliId) == 'Semi-annual')) {
                                
                                if(mapCLIIBillingScheduleType.get(cliId) == 'Monthly') {
                                    objBsliNew.BillingStartDate__c = (mapCLIIMaxBillingStartDate.get(cliId)).addMonths(1);
                                    mapCLIIMaxBillingStartDate.put(cliId,objBsliNew.BillingStartDate__c);
                                } else if(mapCLIIBillingScheduleType.get(cliId) == 'Quarterly') {
                                    objBsliNew.BillingStartDate__c = (mapCLIIMaxBillingStartDate.get(cliId)).addMonths(3);
                                    mapCLIIMaxBillingStartDate.put(cliId,objBsliNew.BillingStartDate__c);
                                } else if(mapCLIIBillingScheduleType.get(cliId) == 'Semi-annual') {
                                    objBsliNew.BillingStartDate__c = (mapCLIIMaxBillingStartDate.get(cliId)).addMonths(6);
                                    mapCLIIMaxBillingStartDate.put(cliId,objBsliNew.BillingStartDate__c);
                                }
                            }
                            
                            // Clearing the Id to NULL for Cloning
                            objBsliNew.id = null;
                            listBillingScheduleLineItemtobeCreated.add(objBsliNew);
                        }   
                    }
                }
                if(!listBillingScheduleLineItemtobeCreated.isEmpty())
                {
                    // Insert the newly Cloned records.
                    insert listBillingScheduleLineItemtobeCreated;
                }
                } catch (exception ex) {
                    ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BillingScheduleLineItemMethods',ErrorDescription__c=ex.getmessage(),FunctionName__c='CreateCloneBillingScheduleLIFromCLIandPreventBSLICreation');
                    insert apexLogRecord;     
                }
            }
            
            // Before Insert is to prevent the Addition BillingScheduleLineItem record creation from Billing Period on CLI 
            // IF Count of Billing Period is less than the Existing Count of Billing Schedule Line Item
            // IF Start Date of Billing Schedule Line Item is Less than the Existing Max Billing Schedule Line Item
            if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
                for(Id cliId : mapCLIIBillingPeriod.keyset()) {
                    // Checking if Exiting record count of BillingScheduleLineItem is greater than the BillingPeriods on CLI, if Yes, then show error.
                    if(mapCLIIBillingPeriod.get(cliId) <= mapCLIIBillingScheduleLICount.get(cliId)) {
                        mapContractLIIdBillingScheduleLI.get(cliId).addError(label.BSLIErrorOnQuickActionOnCLI);
                    }
                    // Checking if Exiting record Start Date of BillingScheduleLineItem is greater than the BillingPeriods on CLI, if Yes, then show error.
                    if(mapContractLIIdBillingScheduleLI.containskey(cliId) && mapContractLIIdBillingScheduleLI.get(cliId).BillingStartDate__c != NULL && 
                        mapCLIIMaxBillingStartDate.containskey(cliId) && mapContractLIIdBillingScheduleLI.get(cliId).BillingStartDate__c <= mapCLIIMaxBillingStartDate.get(cliId)) {
                        mapContractLIIdBillingScheduleLI.get(cliId).addError(label.BSLIErrorOnQuickActionOnCLIForStartDate);
                    }
                }
            }
        }
    }
  //---------------------------------------
  //@author : Sruti Srivastava
  //@date : 4th Sep 2017
  //@description : SFDC1-9599,SFDC1-9975 Method to rollup values from Billing Schedule Line Item to ContractLineItem__c
  //               Called from After Insert, After Update and After Delete triggers
  //@param : TriggerParameters
  //@return : void
  //@companyname : Vertiba
  //@lastmodified by: Paras Dhingra
  //@lastmodified date: 01 July 2019
  //@lastmodified description : SFDC-1661 fixing the issue to allow order management team to modify variable/volume billing in 11-completed contract
  //---------------------------------------
  public static void rollupValuesToContractLineItem(TriggerParameters tp) {
    try {
      Set<Id> setCLIIds = new Set<Id>();
      List<BillingScheduleLineItem__c> listCLIUpdated = new List<BillingScheduleLineItem__c>();
      
      if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
        listCLIUpdated = tp.newList;
      }
      if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
          //check if the values are actually changes on the billinhscheduleitem
          for(BillingScheduleLineItem__c objBillingScheduleLineItem : (List<BillingScheduleLineItem__c>)tp.newList) {
              BillingScheduleLineItem__c oldBillingScheduleItem = (BillingScheduleLineItem__c)tp.oldMap.get(objBillingScheduleLineItem.Id);
              if(oldBillingScheduleItem.TotalUpdated__c!=objBillingScheduleLineItem.TotalUpdated__c) {
                  listCLIUpdated.add(objBillingScheduleLineItem);
              }
          }
      }
      if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) { 
        listCLIUpdated = tp.oldList;
      }
      for(BillingScheduleLineItem__c objBillingScheduleLineItem : listCLIUpdated) {
        if(objBillingScheduleLineItem.ContractLineItem__c != null) {
          setCLIIds.add(objBillingScheduleLineItem.ContractLineItem__c);
        }
      }
      //Querying ContractLineItem from Billing Line Item records  
      if(setCLIIds !=null && !setCLIIds.isEmpty()) {
        Map<Id, ContractLineItem__c> mapCLIToBeUpdated = new Map<Id, ContractLineItem__c>();
        
                for(BillingScheduleLineItem__c objBillingScheduleLineItem : [select Id, TotalUpdated__c, ContractLineItem__c, 
                                                  ContractLineItem__r.Id, ContractLineItem__r.BillingScheduleTotal__c from BillingScheduleLineItem__c
                                                  where ContractLineItem__c IN: setCLIIds]) {
                    objBillingScheduleLineItem.TotalUpdated__c = objBillingScheduleLineItem.TotalUpdated__c == null? 0: objBillingScheduleLineItem.TotalUpdated__c;
                    ContractLineItem__c objCLI = new ContractLineItem__c(Id = objBillingScheduleLineItem.ContractLineItem__c,
                                      BillingScheduleTotal__c = 0);
                    //Calculating Billing Schedule Total value by adding up unit price
                    if(mapCLIToBeUpdated != null && !mapCLIToBeUpdated.containsKey(objCLI.Id)) {
                        mapCLIToBeUpdated.put(objCLI.Id, objCLI);                               
                    }
                    
                    objCLI = mapCLIToBeUpdated.get(objCLI.Id);
                    objCLI.BillingScheduleTotal__c = objCLI.BillingScheduleTotal__c + objBillingScheduleLineItem.TotalUpdated__c;
                    mapCLIToBeUpdated.put(objCLI.Id, objCLI);
                }
                //In case all billing line items are deleted
                for(Id CLIId: setCLIIds)
                {
                    if(mapCLIToBeUpdated != null && !mapCLIToBeUpdated.containsKey(CLIId)) {
                      mapCLIToBeUpdated.put(CLIId, new ContractLineItem__c(Id = CLIId,  BillingScheduleTotal__c = 0));
                    }
                }
                //Updating Contract line item
        if(mapCLIToBeUpdated !=null && !mapCLIToBeUpdated.isEmpty()) {
          update mapCLIToBeUpdated.values();
        }
      }
    }
    catch(Exception ex) {
      System.debug('Exception caught' + ex);
      UtilityClass.createApexLogRecord(ex, 'ContractLineItemMethods', 'rollupValuesToContractLineItem');
      String errMessage = ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
                  ex.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):ex.getMessage();
      tp.newList[0].addError('Error: '+errMessage); 
    }
  }
}