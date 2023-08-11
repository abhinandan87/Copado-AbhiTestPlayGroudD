//-----------------------------
// @author: Anjali
// @company: Epam
// @date: 18 May 2021
// @param: 
// @description:  This class is used for Work Request Form.
// @return: NA
//----------------------------- 

public with sharing class WRFUtility {
    public static Map<String,Schema.DisplayType> mapOfFieldDataType;
    public static Id returnWRFOwnerId (WorkRequestForm__c wrf,Map<Id,User> mapofUsers,Map<String, ID> queueMAP,Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment){
        User wrfOwner;
        String wrfOwnerRegion='';
        if(mapofUsers.get(wrf.ownerid) != NULL) {
            wrfOwner = mapofUsers.get(wrf.ownerid);
            if(wrfOwner.UserRegion__c != NULL) {
                wrfOwnerRegion = wrfOwner.UserRegion__c;
            }
        } else {
            wrfOwner = mapofUsers.get(Userinfo.getUserid());
            if(wrfOwner.UserRegion__c != NULL) {
                wrfOwnerRegion = wrfOwner.UserRegion__c;
            }
        }
        if(wrf.TableauVisualization__c == true && visualizationOnly(wrf)) {
            wrf.ownerid = queueMAP.containsKey('Visualization')? queueMap.get('Visualization') : wrf.ownerid;
        }
        else if(wrf.FormType__c == 'Analytics' && wrf.Loyalty__c == false) { 
            wrf.ownerid = queueMAP.containsKey('Analytics')? queueMAP.get('Analytics') : wrf.ownerid;        
        }
        else if(wrf.FormType__c == 'Analytics' && wrf.Loyalty__c == true) {
            wrf.ownerid = queueMAP.containsKey('Market Reporting - Loyalty')? queueMAP.get('Market Reporting - Loyalty') : wrf.ownerid; 
        }
        else if(wrf.FormType__c == 'Aftermarket') {
            if((wrf.DataExtractGlobalVIOPARC__c && (wrfOwnerRegion.contains('EMEA') || wrfOwnerRegion.contains('EU'))) 
               || wrf.PARCDataFiles__c) {
                   wrf.ownerid = queueMAP.containsKey('European WRF')? queueMAP.get('European WRF') : wrf.ownerid;       
               } else if(wrf.Mapping__c) {
                   wrf.ownerid = queueMAP.containsKey('Jeff Allen')? queueMAP.get('Jeff Allen') : wrf.ownerid; 
               } else {
                   wrf.ownerid = queueMAP.containsKey('Market Reporting - CAP')? queueMAP.get('Market Reporting - CAP') : wrf.ownerid; 
               }
        }
        else if(wrf.FormType__c == 'UK') {
            if(wrf.Analytics__c) {
                wrf.ownerid = queueMAP.containsKey('PolkConnect Analytics')? queueMAP.get('PolkConnect Analytics') : wrf.ownerid; 
            } else if (wrf.PolkConnectSystem__c) {
                wrf.ownerid = queueMAP.containsKey('PolkConnect System')? queueMAP.get('PolkConnect System') : wrf.ownerid; 
            }
        }
        else if(wrf.FormType__c == 'APAC') {
            if(wrf.AdHocReport__c || wrf.ChinaDataRequests__c || wrf.ChinaCV__c) {
                wrf.ownerid = queueMAP.containsKey('APAC WRF')? queueMAP.get('APAC WRF') : wrf.ownerid; 
            } else if (wrf.MarketInsightSystem__c || wrf.DataExtractNewReg__c) {
                wrf.ownerid = queueMAP.containsKey('European WRF') ?queueMAP.get('European WRF') : wrf.ownerid; 
            } else if (wrf.DataExtractGlobalVIOPARC__c) {
                if(wrfOwnerRegion.contains('EMEA') || wrfOwnerRegion.contains('EU') || wrfOwnerRegion.contains('APAC')) {                               
                    wrf.ownerid = queueMAP.containsKey('European WRF')? queueMAP.get('European WRF') : wrf.ownerid; 
                } else { 
                    wrf.ownerid = queueMAP.containsKey('Market Reporting - CAP')? queueMAP.get('Market Reporting - CAP') : wrf.ownerid; 
                }
            } else if (wrf.Mapping__c) {
                //Do nothing, Workflow Rule is handling it.
            } else if (wrf.PolkInsightChinaSystem__c) {
                wrf.ownerid = queueMAP.containsKey('Market Reporting - OEM Stat')? queueMAP.get('Market Reporting - OEM Stat') : wrf.ownerid; 
            } else if (wrf.WorldviewVIO__c) {
                wrf.ownerid = queueMAP.containsKey('Market Reporting - CAP')? queueMAP.get('Market Reporting - CAP') : wrf.ownerid; 
            } else {
                wrf.ownerid = queueMAP.containsKey('Salesforce Support')? queueMAP.get('Salesforce Support') : wrf.ownerid; 
            }
        }
        else {
            WRFOwnerAssignments__mdt ownerAssignment = mapOfOwnerAssignment.get(wrf.FormType__c);
            if(ownerAssignment != NULL && queueMap.get(ownerAssignment.QueueName__c)!=null) {
                wrf.ownerid = queueMap.get(ownerAssignment.QueueName__c);
            }
            else{
                wrf.ownerid = UserInfo.getUserId();
            }
            
        }
        return wrf.ownerid;
    }
    
    private static final Set<String> allRequestTypes = new Set<String> { 'AdhocCustom__c', 
        'AutoTrackerReport__c', 'AutoNews__c', 'PolkInsightProductionMessage__c', 
        'CARB__c', 'ChinaCV__c', 'ChinaDataRequests__c', 
         'CVINA__c', 
        'DataExtractGlobalVIOPARC__c', 'ReportDataFile__c', 'DMS__c', 
        'DrivewayCalculator__c', 'FileCleanse__c',  'ListRequest__c', 
        'Loyalty__c', 'Mapping__c', 'DataExtractNewReg__c', 'MarketInsightSystem__c', 
        'PARCDataFiles__c',  'modelSegmentation__c', 'NewRegSystem__c', 
        'NewRegNewFor__c', 'PS__c', 'PARCGlobal__c', 'PCVINA__c', 
        'PlanningSolutions__c', 'PolkInsightChinaSystem__c', 'Analytics__c', 'PolkConnectSystem__c',
        'Profile__c', 'Recall__c', 'AdHocReport__c', 'SalesMatch__c', 
        'SmartLink__c', 'TIPNetNewTrailer__c', 
        'TIPNetNewTruck__c', 'TIPNetSystem__c', 'TIPNetVehiclesInOperation__c', 
        'TLAS__c', 'ScrappageMedianAge__c', 'Vfacts__c',  
         'VINTrace__c', 
        'VINA__c', 'Vindicator__c',  'WorldviewVIO__c',
        'TableauVisualization__c', 'Analytics__c', 'PolkConnectSystem__c',
        'CommercialAccountFile__c','Dashboard__c','ModelDecommission__c','MarketResearch__c','OwnershipSignals__c',
        'SoftwareServices__c', 'CFIRequest__c','EmailAudienceProspecting__c'};//SFDC-5577- Removed WRF Decomission Fields
            
            private static boolean hasOtherRequests(workrequestform__c wrf, Set<String> ignoreList) {
                Set<String> requestTypes = allRequestTypes.clone();
                if(ignoreList <> null)
                    requestTypes.removeall(ignoreList);
                
                for(String requestType : requestTypes) {
                    // system.debug('requestType-------'+(boolean)wrf.get(requestType));
                    if(wrf.get(requestType) <> null && (('SoftwareServices__c'.equals(requestType) && wrf.get(requestType)!=null)
                                                        || (boolean)wrf.get(requestType))) {
                                                            return true;
                                                        }
                }
                
                return false;
            }
    private static boolean visualizationOnly(workrequestform__c wrf) {
        if(wrf.TableauVisualization__c == true) {
            //check if it has anything besides Tableau Visualization
            return !hasOtherRequests(wrf, new Set<String>{'TableauVisualization__c'});
        }
        return false;
    }
    
    public static Set<String> getRequestTypes() {
        return allRequestTypes;
    }
    
    public static list<WRFPrintView__mdt> getWRFPrintView(List<String> wrfFormTypeList){
        return [Select RecordType__c, RequestType__c, RequestTypeFields__c,
                        (select MasterLabel, DeveloperName, ParentFieldValue__c, ChildRenderingFields__c, WRFPrintView__c from WRFPrintDependent__r)
                            FROM WRFPrintView__mdt where RecordType__c IN : wrfFormTypeList];
    }
    
    public static Map<String,Schema.DisplayType> getWRFFieldDataType(){
        String type='WorkRequestForm__c';
        if(mapOfFieldDataType==null){
        mapOfFieldDataType = new Map<String,Schema.DisplayType>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            for (String fieldName: fieldMap.keySet()) {
                String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
                Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                mapOfFieldDataType.put(fieldName.toLowercase(),fielddataType);
            }
        }
        return mapOfFieldDataType;
    }
    
}