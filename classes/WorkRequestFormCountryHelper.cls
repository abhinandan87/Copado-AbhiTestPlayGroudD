public with sharing class WorkRequestFormCountryHelper {

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Country Options 
    // @return: List<CountryOption__c>
    //--------------------------------------------------------------------

    @AuraEnabled(cacheable=true)
    public static List<CountryOption__c> getCountryOptions(String requestType, String dataType, List<CountrySelection__c> loadParam) {
        if(String.isBlank(dataType)) {
            return [SELECT Id, OwnerId, Name, CurrencyIsoCode, Country__c, DataType__c, Geography__c, Region__c, RequestType__c, VehicleType__c, ISOCode__c FROM CountryOption__c WHERE RequestType__c includes (:requestType)] ;
        }  else {
            return [SELECT Id, OwnerId, Name, CurrencyIsoCode, Country__c, DataType__c, Geography__c, Region__c, RequestType__c, VehicleType__c, ISOCode__c FROM CountryOption__c WHERE RequestType__c includes (:requestType) AND DataType__c includes (:dataType)] ;
        }
        
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Country Selection Options 
    // @return: List<CountrySelection__c>
    //--------------------------------------------------------------------    

    @AuraEnabled(cacheable=true)
    public static List<CountrySelection__c> getCountrySelections(String wrfId, string requestType) {
    return [SELECT Id, RequestType__c, DataType__c, Region__c,
                                        Country__c, Geography__c, VehicleType__c,
                                        Comments__c, ISOCode__c
                                 FROM CountrySelection__c
                                 WHERE WorkRequestForm__c =: wrfId and RequestType__c =: requestType];
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Country Selection Options 
    // @return: List<CountrySelection__c>
    //--------------------------------------------------------------------        

    @AuraEnabled(cacheable=true)
    public static List<CountrySelection__c> getCountrySelectionsByDataType(String wrfId, String dataType, String requestType) {
    return [SELECT Id, RequestType__c, DataType__c, Region__c,
                                        Country__c, Geography__c, VehicleType__c,
                                        Comments__c, ISOCode__c
                                 FROM CountrySelection__c
                                 WHERE WorkRequestForm__c=:wrfId AND RequestType__c includes (:requestType) AND DataType__c includes (:dataType)];
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Country Selection Options 
    // @return: List<CountrySelection__c>
    //--------------------------------------------------------------------    

    @AuraEnabled(cacheable=false)
    public static List<CountrySelection__c>  upsertCountrySelections(List<CountrySelection__c> listSelections, String wrfId, String dataType, String requestType) {
        List<CountrySelection__c> existingSelections = getCountrySelectionsByDataType(wrfId, dataType, requestType);
        Map<String, List<CountrySelection__c>> mapProcessedSelectionsTemp = getMapCountrySelections(listSelections, existingSelections);
        if(mapProcessedSelectionsTemp == null && mapProcessedSelectionsTemp.values().size() == 0) {
            return new List<CountrySelection__c>();
        }
        List<CountrySelection__c> listSelectionsUpsert = mapProcessedSelectionsTemp.get('Upsert');
        List<CountrySelection__c> listSelectionsRemove = mapProcessedSelectionsTemp.get('Delete');
        try{
            delete listSelectionsRemove;
            upsert listSelectionsUpsert;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return listSelectionsUpsert;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Work request from with request types
    // @return: WorkRequestForm__c
    //--------------------------------------------------------------------        

    public static WorkRequestForm__c getWRFRecordWithRequestTypes(String wrfId) {
        if(String.ISBLANK(wrfId)) {
            return null;
        }        
        return [SELECT Id, PARCDataFiles__c, DataExtractGlobalVIOPARC__c, WorldviewVIO__c, WorldViewSystemDataSet__c, MarketInsightSystem__c, DataExtractNewReg__c FROM WorkRequestForm__c 
                    WHERE Id =: wrfId ];
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Request type for Work Request Form
    // @return: String
    //--------------------------------------------------------------------            

    @AuraEnabled(cacheable=true)
    public static String  getRequestType(String wrfId) {
        Map<String,String> mapRequestTypes = new Map<String, String>();
        
        // After Market Attributes and keys must be added to the query handler 
        mapRequestTypes.put('PARCDataFiles__c', 'MarketInsight VIO System');
        mapRequestTypes.put('DataExtractGlobalVIOPARC__c', 'Data Extract Global VIO (PARC)');
        mapRequestTypes.put('WorldviewVIO__c', 'WorldView Global VIO');

        // APAC Attributes and keys must be added to the query handler 
        mapRequestTypes.put('MarketInsightSystem__c', 'MarketInsight System');
        mapRequestTypes.put('DataExtractNewReg__c', 'Data Extract');
        try {
            WorkRequestForm__c wrf = getWRFRecordWithRequestTypes(wrfId);
            for(String key: mapRequestTypes.keySet()) {
                if(key.equals('WorldviewVIO__c') && wrf.get(key)==true) {
                    String dataset = (String)wrf.get('WorldViewSystemDataSet__c');
                    if(dataset.contains('WorldView Global VIO')) {
                        return 'WorldView Global VIO';
                    }
                    if(dataset.contains('WorldView OE Parts Research')){
                        return 'WorldView OE Parts Research';
                    }
                }
                if(wrf.get(key) == true) {
                    return mapRequestTypes.get(key);
                }
                
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Country Map Selection
    // @return: Map<String, List<CountrySelection__c>>
    //--------------------------------------------------------------------            

    public static Map<String, List<CountrySelection__c>> getMapCountrySelections(List<CountrySelection__c> listSelections, List<CountrySelection__c> existingSelections) {
        Map<String, List<CountrySelection__c>> mapProcessedSelections = new Map<String, List<CountrySelection__c>>();
        List<CountrySelection__c> listSelectionsUpsert = new List<CountrySelection__c>();
        if(existingSelections.size() == 0) {
            mapProcessedSelections.put('Upsert', listSelections);
            mapProcessedSelections.put('Delete', new List<CountrySelection__c>());
            return mapProcessedSelections;
        }
        Map<String, CountrySelection__c> mapSelections = new Map<String, CountrySelection__c>();

        List<CountrySelection__c> listSelectionsRemove = new List<CountrySelection__c>();
        for(CountrySelection__c cs: listSelections) {
            mapSelections.put(getCountryKey(cs), cs);
        }
        for(CountrySelection__c cs: existingSelections) {
            String existingKey = getCountryKey(cs);
            if(mapSelections.containsKey(existingKey)) {
                // Check change in existing selection, remove from the map as it does not require any update
                if(cs.VehicleType__c == mapSelections.get(existingKey).VehicleType__c && cs.Comments__c == mapSelections.get(existingKey).Comments__c) {
                    mapSelections.remove(existingKey);
                } else {
                    //Update the VechicleType if there is a change in existing selection.
                    cs.VehicleType__c = mapSelections.get(existingKey).VehicleType__c;
                    cs.Comments__c = mapSelections.get(existingKey).Comments__c;
                    listSelectionsUpsert.add(cs);
                    mapSelections.remove(existingKey);
                }
            } else {
                //Prepare list of selections to remove.
                listSelectionsRemove.add(cs);
                mapSelections.remove(existingKey);
            }
        }
        // Left over values in map are to be added as the selections.
        listSelectionsUpsert.addAll(mapSelections.values());
        System.debug(listSelectionsUpsert);
        System.debug(listSelectionsRemove);
        mapProcessedSelections.put('Upsert', listSelectionsUpsert);
        mapProcessedSelections.put('Delete', listSelectionsRemove);
        System.debug(mapProcessedSelections);
        return mapProcessedSelections;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Helper method to get country key.
    // @return: String
    //--------------------------------------------------------------------      

    public static String getCountryKey(CountrySelection__c selection) {
        String selectionKey = '';
        if(selection == null) {
            return selectionKey;
        }
        if(!String.isBlank(selection.RequestType__c)) {
            selectionKey = selectionKey + selection.RequestType__c;
        }
        if(!String.isBlank(selection.DataType__c)) {
            selectionKey = selectionKey + selection.DataType__c;
        }
        if(!String.isBlank(selection.Country__c)) {
            selectionKey = selectionKey + selection.Country__c;
        }
        if(!String.isBlank(selection.Geography__c)) {
            selectionKey = selectionKey + selection.Geography__c;
        }
        return selectionKey;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 06 May 2021
    // @param:
    // @description: Get Country Options by Request Type.
    // @return: List<CountryOption__c>
    //--------------------------------------------------------------------      

    @AuraEnabled(cacheable=true)
    public static List<CountryOption__c> getDataTypes(String requestType) {
    return [SELECT Id, RequestType__c, DataType__c, Region__c,
                                        Country__c, Geography__c, VehicleType__c                                        
                                        FROM CountryOption__c WHERE RequestType__c includes (:requestType)] ;
    }


}