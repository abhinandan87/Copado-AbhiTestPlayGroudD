//-----------------------------
// @author: Madhusudhan karna
// @date: 06 May 2021
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
//-----------------------------
public with sharing class WorkRequestFormMethods {
    public static Map<Id,User> mapofUsers = new Map<Id,User>();
    
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param: TriggerParameters tp
    // @description: Create the PLCJob record, when WorkRequestForm request status is approved.
    // @return: None
    //------------------------------
    public static void createPLCJobs(TriggerParameters tp) {
        Map<Id,WorkRequestForm__c> mapNewWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.newMap;
        Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
        List<WorkRequestForm__c> workRequestFormList = new List<WorkRequestForm__c>();
        for(WorkRequestForm__c wrf: mapNewWorkRequestForm.values()) {        
            if(mapOldWorkRequestForm != NULL && mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c 
               && ('Approved').equalsIgnoreCase(wrf.RequestStatus__c) ) {
                   if (wrf.ProgrammerAssigned__c == NULL) {
                       wrf.OwnerId = UserInfo.getuserid();
                   } else {
                       wrf.OwnerId = wrf.ProgrammerAssigned__c;
                   }
                   wrf.ProgrammerAssigned__c = null;
                   wrf.ApprovalDate__c = system.today();
                   workRequestFormList.add(wrf);
               }
        }
        List<PLCJob__c> pLCJobList=new list<PLCJob__c>();
        PLCJob__c newJob;
        
        for( WorkRequestForm__c wrf : workRequestFormList ) {
            newJob = new PLCJob__c();
            newJob.RequestedDate__c = wrf.RequestedDueDate__c;
            newJob.Opportunity__c = wrf.OpportunityName__c;
            newJob.JobName__c = wrf.Name;
            newJob.JobType__c = wrf.JobType__c;
            newJob.WorkRequestForm__c = wrf.ID;
            newJob.OwnerID = wrf.OwnerID;
            newJob.Cycle__c = wrf.Cycle__c;
            newJob.CycleStart__c = wrf.CycleStart__c;
            newJob.NumberofCycles__c = wrf.NumberofCycles__c;
            newJob.JobNumber__c = wrf.Internal__c ? wrf.JobNumber__c : null;
            newJob.Team1__c = wrf.ProgrammerTeam__c;
            newJob.NegotiatedDate__c = wrf.NegotiatedDate__c ;
            newJob.StartDate__c = wrf.PLCStartDate__c;
            //convert to datetime, then assign to submitted date
            Datetime dt;
            if(wrf.SubmittedDate__c!= null) {
                dt = datetime.newInstance(wrf.SubmittedDate__c.year(), wrf.SubmittedDate__c.month(),wrf.SubmittedDate__c.day());
            }
            
            newJob.SubmittedDate__c = dt;
            pLCJobList.add(newJob); 
        }
        
        if( pLCJobList.size()>0 ) {
            Insert pLCJobList;
        }
    }
    
    // @author: Akhila Kodipaka
    // @date: 19 May 2021
    // @param: TriggerParameters tp
    // @description: Assign owner to WRF record, when WorkRequestForm request status is submitted.
    // @return: None
    //------------------------------
    public static void updateOwnerAssignment(TriggerParameters tp) {
        system.debug('entered uoa');
        Map<Id,WorkRequestForm__c> mapNewWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.newMap;
        Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
        List<WorkRequestForm__c> workRequestFormList = new List<WorkRequestForm__c>();
        Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment = new Map<String,WRFOwnerAssignments__mdt>(); 
        Set<Id> wrfOwners = new Set<Id>();
        Map<String, ID> queueMAP = new Map<String, ID>();
        for(group g : [select id,name from Group where Type='Queue']) {
            queueMAP.put(g.name,g.id);
        }
        for(WRFOwnerAssignments__mdt assignment : [SELECT MasterLabel, QueueName__c FROM WRFOwnerAssignments__mdt]){
            mapOfOwnerAssignment.put(assignment.MasterLabel,assignment);
        }
        for(WorkRequestForm__c wrfownerId : (List<WorkRequestForm__c>)tp.newList){
            wrfOwners.add(wrfownerId.OwnerId);
        }
        if(mapofUsers.size()==0){
            mapofUsers = new Map<Id,User>([SELECT Id,userroleid,userrole.name,UserRegion__c FROM user WHERE (ID=:wrfOwners OR ID=:Userinfo.getUserid())]);  
        }
        
        for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {        
            if((mapOldWorkRequestForm == NULL || (mapOldWorkRequestForm != NULL && mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c ))
               && ('Submitted').equalsIgnoreCase(wrf.RequestStatus__c)) {
                   wrf.OwnerId = WRFUtility.returnWRFOwnerId(wrf, mapofUsers, queueMAP, mapOfOwnerAssignment);
               }
        }
    }    
    
    
    //-----------------------------
    // @author: Akhila
    // @date: 21st May 2021
    // @param: TriggerParameters tp
    // @description: Method to update Owner based on Programmer assigned.
    // @return: None
    //------------------------------    
    public static void updateonApprovalPending(TriggerParameters tp) {
        
        Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
        for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
            if((mapOldWorkRequestForm != NULL /*&& mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c*/ )){
                if(('Approval Pending').equalsIgnoreCase(wrf.RequestStatus__c)) {
                    if(wrf.ProgrammerAssigned__c == NULL) {
                        system.debug('if. updateonApprovalPending');
                        wrf.OwnerId = UserInfo.getuserid();
                        system.debug('wrf.OwnerId:'+wrf.OwnerId);
                    } else {
                        system.debug('else updateonApprovalPending');
                        wrf.OwnerId = wrf.ProgrammerAssigned__c;
                        system.debug('wrf.OwnerId::'+wrf.OwnerId);
                    }
                }
                if(('Rejected').equalsIgnoreCase(wrf.RequestStatus__c) && 
                   (mapOldWorkRequestForm!=null && mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c)) {
                       if(wrf.PrimarySalesContact__c != null) {
                           wrf.OwnerId=wrf.PrimarySalesContact__c;
                       } else {
                           wrf.OwnerId=UserInfo.getUserId();
                       }
                   }
            } 
        }    
    }
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param: TriggerParameters tp
    // @description: update SubmittedDate, when WorkRequestForm request status is submitted or rejected or Draft.
    // @return: None
    //------------------------------
    public static void updateSubmittedDate(TriggerParameters tp) {
        Map<Id,WorkRequestForm__c> mapNewWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.newMap;
        Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
        List<WorkRequestForm__c> workRequestFormList = new List<WorkRequestForm__c>();
        system.debug('Enter into createPLCJob method-----------');
        for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
            if((mapOldWorkRequestForm == NULL || (mapOldWorkRequestForm != NULL && mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c ))
               && ('Submitted').equalsIgnoreCase(wrf.RequestStatus__c)) {
                   wrf.SubmittedDate__c=system.today();
                   wrf.IsSubmitted__c=True;
               } else if((mapOldWorkRequestForm != NULL && mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c 
                          && (('Draft').equalsIgnoreCase(wrf.RequestStatus__c) ||('Rejected').equalsIgnoreCase(wrf.RequestStatus__c) 
                              || ('Symbol Approval Request').equalsIgnoreCase(wrf.RequestStatus__c) || ('Symbol Approved').equalsIgnoreCase(wrf.RequestStatus__c)))) {
                                  wrf.IsSubmitted__c=False;
                                  wrf.SubmittedDate__c=null;
                              }
        }        
    }
    
    // @author: Anjali
    // @date: 24 May 2021
    // @param: TriggerParameters tp
    // @description: Create opportunity Work request record for the users with edit permission or throw error if they don't have permission.
    // @return: None
    //------------------------------
    public static void createOppyWrkRequest(TriggerParameters tp) {
        OpportunityWorkRequestForm__c optyWrf;
        set<Id> failedRec = new set<Id>();
        List<OpportunityWorkRequestForm__c> oppyWrkRequestLst = new  List<OpportunityWorkRequestForm__c>();
        for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
            optyWrf = new OpportunityWorkRequestForm__c();
            optyWrf.Opportunity__c = wrf.OpportunityName__c;
            optyWrf.WorkRequestForm__c = wrf.Id; //this ensures an ID is always present
            oppyWrkRequestLst.add(optyWrf);
            
        }
        if(oppyWrkRequestLst.size()>0){
            Database.SaveResult[] srList = Database.Insert(oppyWrkRequestLst,false);
            integer i=0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug(oppyWrkRequestLst[i].WorkRequestForm__c + ': ' + err.getMessage());
                        system.debug('@@error');
                        if(err.getMessage()=='insufficient access rights on cross-reference id'){
                            failedRec.add(oppyWrkRequestLst[i].WorkRequestForm__c);
                        }
                    }
                }
                i++;
            } 
            
        }
        
        for(WorkRequestForm__c wrkReq: (List<WorkRequestForm__c>)tp.newList){
            if(failedRec.contains(wrkReq.Id)){
                wrkReq.addError('You do not have necessary permission to create this record');
            }
        }
        
    }
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param: TriggerParameters tp
    // @description: update WR Formtype if WRF record is created as internal
    // @return: None
    //------------------------------
    public static void updateWRFormType(TriggerParameters tp) {
        for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
            if (wrf.FormType__c == NULL && wrf.Internal__c) {
                wrf.FormType__c=getRecordTypeNameById('WorkRequestForm__c',wrf.RecordTypeId);
            }
        }        
    }
    public static String getRecordTypeNameById(String objectName, Id strRecordTypeId) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(strRecordTypeId).getName();
    }
    
    // @author: Mohit Parnami
    // @date: 25 Feb 2022
    // @param: TriggerParameters tp
    // @description: To throw error if country isn't selected. // Correcting old Code by removing SOQL in loop
    // @return: None
    //------------------------------
    public static void validationRulesOnWRF(TriggerParameters tp) {
        Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
        Set<String> applicableFormTypes = new Set<String>{ 'Aftermarket','Australia','APAC','Global New & Used Registration'};
        Set<Id> setWRFId = new Set<Id>(); 
        Map<Id, List<String>> mapWRFIdToListRequestType = new Map<Id, List<String>>();
		Map<Id, Map<String, Set<CountrySelection__c>>> mapWRFIdToMapReqTypeToSetCountrySelection = new Map<Id, Map<String, Set<CountrySelection__c>>>();        
        
        for(WorkRequestForm__c wrf : (List<WorkRequestForm__c>)tp.newList) {
            if((mapOldWorkRequestForm == NULL || (mapOldWorkRequestForm != NULL && mapOldWorkRequestForm.get(wrf.id).RequestStatus__c != wrf.RequestStatus__c ))
                   && ('Submitted').equalsIgnoreCase(wrf.RequestStatus__c)) {
						if (applicableFormTypes.contains(wrf.FormType__c) && wrf.Internal__c == false ) {
                           System.debug('===Inside Loop==' + wrf.DataExtractNewReg__c);
                           // check Country Selection count, should be at least 1 selection per CountrySelectorController
                           // if there are no CountrySelectorController instances, then this loop will not be entered
                           List<String> listRequestTypes = new List<String>();
                           if( wrf.WorldviewVIO__c == true ) {
                               if(wrf.WorldViewSystemDataSet__c <> null && wrf.WorldViewSystemDataSet__c.contains('WorldView OE Parts Research'))
                                   listRequestTypes.add('WorldView OE Parts Research');
                               if(wrf.WorldViewSystemDataSet__c <> null && wrf.WorldViewSystemDataSet__c.contains('WorldView Global VIO'))
                                   listRequestTypes.add('WorldView Global VIO');
                           }
                           if (wrf.PARCDataFiles__c == true){
                               listRequestTypes.add('MarketInsight VIO System');
                           }
                           if (wrf.DataExtractGlobalVIOPARC__c == true) {
                               listRequestTypes.add('Data Extract Global VIO (PARC)');
                           }
                           if (wrf.MarketInsightSystem__c == true ) {
                               listRequestTypes.add('MarketInsight System');
                           }
                           if (wrf.DataExtractNewReg__c == true ) {
                               listRequestTypes.add('Data Extract');
                           }
                           if (wrf.NewRegSystem__c == true ) {
                               listRequestTypes.add('New Reg System');
                           }
                           mapWRFIdToListRequestType.put(wrf.Id, listRequestTypes);
                       }
                   }
        }
        for(CountrySelection__c countrySelections : [SELECT VehicleType__c, RequestType__c, WorkRequestForm__c 
                                                               FROM CountrySelection__c
                                                               WHERE WorkRequestForm__c IN : mapWRFIdToListRequestType.keySet()]) { 
                                                                 
               	if(!mapWRFIdToMapReqTypeToSetCountrySelection.containsKey(countrySelections.WorkRequestForm__c)) {
               		mapWRFIdToMapReqTypeToSetCountrySelection.put(countrySelections.WorkRequestForm__c, new Map<String, Set<CountrySelection__c>>());                                                        
                }
                
                for(String reqType : countrySelections.RequestType__c.split(';')) {
                    if(mapWRFIdToMapReqTypeToSetCountrySelection.containsKey(countrySelections.WorkRequestForm__c)) {
                        Map<String, Set<CountrySelection__c>> mapReqTypeToSetCountrySelection = mapWRFIdToMapReqTypeToSetCountrySelection.get(countrySelections.WorkRequestForm__c);
                        if(!mapReqTypeToSetCountrySelection.containsKey(reqType)) {
                            mapReqTypeToSetCountrySelection.put(reqType, New Set<CountrySelection__c>());
                        }
                        mapReqTypeToSetCountrySelection.get(reqType).add(countrySelections);
                        mapWRFIdToMapReqTypeToSetCountrySelection.put(countrySelections.WorkRequestForm__c, mapReqTypeToSetCountrySelection);
                    }
                } 
		}                                      
        for(WorkRequestForm__c wrf : (List<WorkRequestForm__c>)tp.newList) {
           Map<String, Set<CountrySelection__c>>  mapReqTypeToSetCountrySelection = mapWRFIdToMapReqTypeToSetCountrySelection.containsKey(wrf.Id) ? mapWRFIdToMapReqTypeToSetCountrySelection.get(wrf.Id) : null;
            if(mapReqTypeToSetCountrySelection != null) {
                for(String reqType : mapReqTypeToSetCountrySelection.keySet()) {
                   boolean hasSelections = false;
                   for(CountrySelection__c countrySel : mapReqTypeToSetCountrySelection.get(reqType)) {
                       if(!String.isEmpty(countrySel.VehicleType__c)) {
                           hasSelections = true;
                           break;
                       }
                   }
                   if(!hasSelections) { 
                      wrf.addError('Requirements - You must have at least one Market selection for the ' + reqType + ' Request.');
                   }
               }
            }   
            
        }
    }
    
    // @author: Uday Bikkumalla
    // @date: 01 July 2021
    // @param: TriggerParameters tp
    // @description: update opp related fields on WRF when Opportunity link is changed.
    // @return: None
    //------------------------------
    public static void handleOnOppChangeOnWRF(TriggerParameters tp) {
        Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
        Set<Id> opportunityIds = new Set<Id>();
        List<WorkRequestForm__c> formsToUpdate = new List<WorkRequestForm__c>();
        for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
            if(mapOldWorkRequestForm.get(wrf.id).OpportunityName__c != wrf.OpportunityName__c && wrf.OpportunityName__c != null) {
                opportunityIds.add(wrf.OpportunityName__c);
                formsToUpdate.add(wrf);
            }
        }
        
        Map<Id, Opportunity> mapOpportunties = getOpportunityDetails(opportunityIds);    
        //Update Work Request Forms fields with latest selected Opportunity fields
        if(TriggerParameters.TriggerEvent.beforeUpdate == tp.tEvent) {
            updateOpportunityFieldsOnWRF(formsToUpdate, mapOpportunties);
        }
        if(TriggerParameters.TriggerEvent.afterUpdate == tp.tEvent) {
            updateChangestoOpportunityWorkRequestForms(formsToUpdate, mapOpportunties, tp);
        }
        /*
        if(TriggerParameters.TriggerEvent.afterUpdate == tp.tEvent) {
        insertOpportunityWorkRequestForms(oppyWrkRequestLst, tp);
        }
        */
        
    }   
    
    
    public static Map<Id, Opportunity> getOpportunityDetails(Set<Id> opportunityIds) {
        if(opportunityIds.isEmpty()) {
            return new Map<Id, Opportunity>();
        }
        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, Opportunitynum__c, AccountId, Amount, CostCenter__c, AISUltimateClient__c, CurrencyIsoCode FROM Opportunity WHERE Id in : (opportunityIds) ] );
        return mapOpportunities;
    }
    
    public static void updateOpportunityFieldsOnWRF(List<WorkRequestForm__c> formsToUpdate, Map<Id, Opportunity> mapOpportunties) {
        for(WorkRequestForm__c refWrf : formsToUpdate) {
            Opportunity oppty = mapOpportunties.get(refWrf.OpportunityName__c);
            refWrf.OpportunityNumber__c = oppty.Opportunitynum__c;
            refWrf.Revenue__c = oppty.Amount;
            refWrf.AccountName__c = oppty.AccountId;
            refWrf.CostCenter__c = oppty.CostCenter__c;
            refWrf.UltimateCustomeracct__c = oppty.AISUltimateClient__c;
            refWrf.CurrencyISOCode = oppty.CurrencyIsoCode;
        }
    }
    
    public static void updateChangestoOpportunityWorkRequestForms(List<WorkRequestForm__c> formsToUpdate, Map<Id, Opportunity> mapOpportunties, TriggerParameters tp) {
        List<OpportunityWorkRequestForm__c> oppyWrkRequestLst = new List<OpportunityWorkRequestForm__c>();
        Set<Id> workrequestFormIds = new Set<Id>();
        for(WorkRequestForm__c refWrf : formsToUpdate) {
            Opportunity oppty = mapOpportunties.get(refWrf.OpportunityName__c);
            OpportunityWorkRequestForm__c optyWrf = new OpportunityWorkRequestForm__c();
            optyWrf.Opportunity__c = oppty.Id;
            optyWrf.WorkRequestForm__c = refWrf.Id; //this ensures an ID is always present
            workrequestFormIds.add(refWrf.Id);
            oppyWrkRequestLst.add(optyWrf);
        }
        List<OpportunityWorkRequestForm__c> formsToDelete = [SELECT Id FROM OpportunityWorkRequestForm__c WHERE WorkRequestForm__c IN: workrequestFormIds];
        Delete formsToDelete;
        insertOpportunityWorkRequestForms(oppyWrkRequestLst, tp);
    }
    
    public static void insertOpportunityWorkRequestForms(List<OpportunityWorkRequestForm__c> oppyWrkRequestLst, TriggerParameters tp) {
        set<Id> failedRec = new set<Id>();
        if(oppyWrkRequestLst.size()>0){
            Database.SaveResult[] srList = Database.Insert(oppyWrkRequestLst,false);
            integer i=0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug(oppyWrkRequestLst[i].WorkRequestForm__c + ': ' + err.getMessage());
                        if(err.getMessage()=='insufficient access rights on cross-reference id'){
                            failedRec.add(oppyWrkRequestLst[i].WorkRequestForm__c);
                        }
                    }
                }
                i++;
            } 
        }
        
        for(WorkRequestForm__c wrkReq: (List<WorkRequestForm__c>)tp.newList){
            if(failedRec.contains(wrkReq.Id)){
                wrkReq.addError('You do not have necessary permission to create/update this record. Please ensure you have access to the related records before making change.');
            }
        }
    }
    // @author: Madhusudhan karna
    // @date: 19 July 2021
    // @param: TriggerParameters tp
    // @description: update SubmittedDate, when WorkRequestForm request status is submitted or rejected or Draft.
    // @return: None
    //------------------------------
    public static void wipeOffUnSelectedRequestTypesFields(TriggerParameters tp) {
        if((System.Label.WRFWipeOffFeature).equalsIgnoreCase('TRUE')){
            Map<Id,WorkRequestForm__c> mapNewWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.newMap;
            Map<Id,WorkRequestForm__c> mapOldWorkRequestForm = (Map<Id,WorkRequestForm__c>)tp.oldMap;
            List<WorkRequestForm__c> workRequestFormList = new List<WorkRequestForm__c>();
            list<WRFPrintView__mdt> wrfPrintViewList = new list<WRFPrintView__mdt>();
            Map<String,String> recordTypeIdNameMap= new Map<String,String>();
            String developerName;
            for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
                if( wrf.RecordTypeId != null ) {
                    developerName = Schema.SObjectType.WorkRequestForm__c.getRecordTypeInfosById().get(wrf.RecordTypeId).getDeveloperName();
                    recordTypeIdNameMap.put(wrf.RecordTypeId,developerName);
                }
            }

            wrfPrintViewList=[Select RecordType__c, RequestType__c, RequestTypeFields__c,
                            (select MasterLabel, DeveloperName, ParentField__c, ParentFieldValue__c, ChildRenderingFields__c, WRFPrintView__c from WRFPrintDependent__r)
                                FROM WRFPrintView__mdt where RecordType__c IN : recordTypeIdNameMap.values()];
            Map<String,set<String>> requestTypeFieldsMap= new Map<String,set<String>>();
            Map<String,set<String>> formTypeRequestTypeMap= new Map<String,set<String>>();
            Map<String,List<WRFPrintDependent__mdt>> requestTypeDependentFieldsMap= new Map<String,List<WRFPrintDependent__mdt>>();

            Set<string> fieldsSet;
            Set<string> requestTypeSet;
            for(WRFPrintView__mdt wrfPrint : wrfPrintViewList) {
                if(requestTypeFieldsMap.containsKey(wrfPrint.RequestType__c)){
                    fieldsSet = new Set<string>();
                    fieldsSet = requestTypeFieldsMap.get(wrfPrint.RequestType__c);
                    if(wrfPrint.RequestTypeFields__c!=null && wrfPrint.RequestTypeFields__c!=''){
                        fieldsSet.addAll(wrfPrint.RequestTypeFields__c.split(':'));
                    }
                    requestTypeFieldsMap.put(wrfPrint.RequestType__c,fieldsSet);
                    
                } else {
                    fieldsSet = new Set<string>();
                    if(wrfPrint.RequestTypeFields__c!=null && wrfPrint.RequestTypeFields__c!=''){
                        fieldsSet.addAll(wrfPrint.RequestTypeFields__c.split(':'));
                    }
                    
                    requestTypeFieldsMap.put(wrfPrint.RequestType__c,fieldsSet);
                }
                if(formTypeRequestTypeMap.containsKey(wrfPrint.RecordType__c)){
                    requestTypeSet = new Set<string>();
                    requestTypeSet = formTypeRequestTypeMap.get(wrfPrint.RecordType__c);
                    requestTypeSet.add(wrfPrint.RequestType__c);
                    formTypeRequestTypeMap.put(wrfPrint.RecordType__c,requestTypeSet);
                    
                } else {
                    requestTypeSet = new Set<string>();
                    requestTypeSet.add(wrfPrint.RequestType__c);
                    formTypeRequestTypeMap.put(wrfPrint.RecordType__c,requestTypeSet);
                }
                List<WRFPrintDependent__mdt> printDependentList;
                if(wrfPrint.WRFPrintDependent__r.size()>0){
                    for(WRFPrintDependent__mdt dependent : wrfPrint.WRFPrintDependent__r){
                        if(requestTypeDependentFieldsMap.containsKey(wrfPrint.RequestType__c)){
                            printDependentList = new List<WRFPrintDependent__mdt>();
                            printDependentList = requestTypeDependentFieldsMap.get(wrfPrint.RequestType__c);
                            printDependentList.add(dependent);
                            requestTypeDependentFieldsMap.put(wrfPrint.RequestType__c,printDependentList);
                            
                        } else {
                            printDependentList = new List<WRFPrintDependent__mdt>();
                            printDependentList.add(dependent);
                            requestTypeDependentFieldsMap.put(wrfPrint.RequestType__c,printDependentList);
                        }
                    }
                }
            }
            Set<WorkRequestForm__c> changedWRFList = new Set<WorkRequestForm__c>();
            for(WorkRequestForm__c wrf: (List<WorkRequestForm__c>)tp.newList) {
                if(formTypeRequestTypeMap.size()>0 && recordTypeIdNameMap.size()>0){
                    for(String requestType : formTypeRequestTypeMap.get(recordTypeIdNameMap.get(wrf.RecordTypeId))) {
                        Integer charIndex=requestType.indexOf(':');
                        String pickRequestType=requestType;
                        if(charIndex>=0){
                            requestType = requestType.substring(0,charIndex);
                        }
                        if(mapOldWorkRequestForm == NULL || (mapOldWorkRequestForm != NULL 
                            && (mapOldWorkRequestForm.get(wrf.id)).get(requestType) != wrf.get(requestType))) {
                            changedWRFList.add(wrf);
                            break; // If atleast request type is changed in wrf record then loop will be break
                        } else if(requestTypeDependentFieldsMap.get(pickRequestType)!=null  
                                && requestTypeDependentFieldsMap.get(pickRequestType).size()>0) {
                            for(WRFPrintDependent__mdt dependent : requestTypeDependentFieldsMap.get(pickRequestType)) {
                                if((mapOldWorkRequestForm.get(wrf.id)).get(dependent.ParentField__c) != wrf.get(dependent.ParentField__c)) {
                                    changedWRFList.add(wrf);
                                    break; // If atleast one dependent parent field is changed in wrf record then loop will be break
                                }
                            }
                        }
                    }
                }
            }
            workRequestFormList= new List<WorkRequestForm__c>(changedWRFList);
            removeDataOnSubmission(workRequestFormList, formTypeRequestTypeMap, requestTypeFieldsMap,recordTypeIdNameMap,requestTypeDependentFieldsMap);
        }
       
    }

    public static void removeDataOnSubmission(List<WorkRequestForm__c> workRequestFormList, Map<String,Set<String>> formTypeRequestTypeMap, Map<String,Set<String>> requestTypeFieldsMap, Map<String,String> recordTypeIdNameMap,
    Map<String,List<WRFPrintDependent__mdt>> requestTypeDependentFieldsMap) {
        
        Map<String, Schema.DisplayType> mapOfFieldDataType = WRFUtility.getWRFFieldDataType();
        for(WorkRequestForm__c wrf: workRequestFormList) {
            //Prepare Data for following two sets based on the request types (True/Flase);
            //True - Add the fields to fieldsDataToBeRetained.
            //False - Add the fields to fieldsDataToBeRemoved.
            Set<String> fieldsDataToBeRetained = new Set<String>();
            Set<String> fieldsDataToBeRemoved = new Set<String>();
            if(formTypeRequestTypeMap.containsKey(recordTypeIdNameMap.get(wrf.RecordTypeId))){
                Set<String> requestTypeSet = new Set<String>();
                requestTypeSet = formTypeRequestTypeMap.get(recordTypeIdNameMap.get(wrf.RecordTypeId));
                Set<String> fieldsSet = new Set<String>();
                for(String requestType :  new List<String>(requestTypeSet)) {

                    fieldsSet = requestTypeFieldsMap.get(requestType);
                    if(fieldsSet == null) {
                        fieldsSet = new Set<String>();
                    }
                    Integer charIndex=requestType.indexOf(':');
                    String requestTypeValue;
                    string pickListRequestType;
                    if(charIndex>=0){
                        requestTypeValue= requestType.substring(charIndex+1);
                        pickListRequestType = requestType.substring(0,charIndex);
                    }
                    if((charIndex == -1 && wrf.get(requestType) == false) || (charIndex >=0 && wrf.get(pickListRequestType) != requestTypeValue ) ) {
                        system.debug('@@requestTypeDependentFieldsMap'+requestTypeDependentFieldsMap);
                        if(requestTypeDependentFieldsMap.size()>0 && requestTypeDependentFieldsMap.get(requestType)!=null) {
                            for(WRFPrintDependent__mdt dependent : requestTypeDependentFieldsMap.get(requestType)) {
                                if( dependent.ParentField__c!=null && dependent.ParentFieldValue__c!=null){
                                    Set<String> dependentFieldsSet = new Set<String>();
                                    dependentFieldsSet.addAll(dependent.ChildRenderingFields__c.split(':'));
                                    fieldsDataToBeRemoved.addAll(dependentFieldsSet);
                                }
                            }
                        }
                        fieldsDataToBeRemoved.addAll(fieldsSet);
                    } else {
                        if(requestTypeDependentFieldsMap.size()>0 && requestTypeDependentFieldsMap.get(requestType)!=null) {
                            for(WRFPrintDependent__mdt dependent : requestTypeDependentFieldsMap.get(requestType)) {
                                if( dependent.ParentField__c!=null && dependent.ParentFieldValue__c!=null){
                                    Set<String> dependentFieldsSet = new Set<String>();
                                    dependentFieldsSet.addAll(dependent.ChildRenderingFields__c.split(':'));
                                    if(wrf.get(dependent.ParentField__c)!=null && (dependent.ParentFieldValue__c).equalsignorecase(String.ValueOf(wrf.get(dependent.ParentField__c)))) {
                                        fieldsDataToBeRetained.addAll(dependentFieldsSet);
                                    }else {
                                        fieldsDataToBeRemoved.addAll(dependentFieldsSet);
                                    }
                                }
                            }
                        }
                        fieldsDataToBeRetained.addAll(fieldsSet);
                       
                    }
                }
                //Remove If there are any common fields b/w two sets fieldsDataToBeRetained, fieldsDataToBeRemoved. fieldsDataToBeRetained will take precedence.
                fieldsDataToBeRemoved.removeAll(fieldsDataToBeRetained);
                system.debug('@@fieldsDataToBeRetained'+fieldsDataToBeRetained);
                 system.debug('@@fieldsDataToBeRemoved'+fieldsDataToBeRemoved);
                for(String fieldName : new List<String>(fieldsDataToBeRemoved)) {
                    String keyField = fieldName.toLowerCase().trim();
                    if(mapOfFieldDataType.get(keyField) == Schema.DisplayType.BOOLEAN) {
                        wrf.put(keyField, false);                        
                    } else {
                        wrf.put(keyField, null);
                    }
                }
            }
        }
    }
}