global class CreateAndUpdateCustomMetadataTypes  Implements Schedulable
    {
    public static  Metadata.DeployContainer dmContainer;
    public static boolean performDeployment = false;
    
       global void execute(SchedulableContext sc)
        {
            performUpdates();
        }
        
        @future(callout=true)
        public static void performUpdates(){
             updateDivisionCustomDataTypes();
             updateHierarchyCustomDataTypes();
             updateproductFilterCustomTypes();
             updateActivityStatus();
              if(performDeployment == true && !Test.isRunningTest())
             Id jobId = Metadata.Operations.enqueueDeployment(dmContainer, null);
        }
   
    public static void updateDivisionCustomDataTypes(){
          dmContainer = new Metadata.DeployContainer();
        String query = 'select Active__c,masterLabel,Id,developerName,ACV_Color_Field__c,'
            			+ 'ACV_Field_Name__c,Display_Name__c,Manager_Field_Name__c,'
                        +'NPS_Color_Field__c,NPS_Field_Name__c,Order__c,'
                        +'Org_ID__c,Stack_Color__c,Disable_Chart__c,' +
                'ESG_Amount_Field__c, Label from Division_Settings__mdt';
        List<object> objectResponse = CreateAndUpdateCustomMetadataTypes.performCallout(query);
        if(objectResponse != NULL){
           List<string> fieldsList = new List<String>{'Active__c', 'ACV_Color_Field__c',
                						'ACV_Field_Name__c', 'Display_Name__c',
                                        'Manager_Field_Name__c', 'NPS_Color_Field__c',
                                        'NPS_Field_Name__c', 'Order__c',
                                        'Org_ID__c','Stack_Color__c', 'Disable_Chart__c',
                                        'ESG_Amount_Field__c', 'Label'};
            parseResponse(objectResponse,fieldsList ,'Division_Settings__mdt', query);
            system.debug('--dm--'+dmContainer);
           
             
           
        }
    }
    
     public static void updateHierarchyCustomDataTypes(){
      
        String query = 'select masterLabel,Id,developerName,Column_Number__c,Field_Label__c,'
                        +'Field_Name__c from Hierarchy_Settings__mdt';
        List<object> objectResponse = CreateAndUpdateCustomMetadataTypes.performCallout(query);
        if(objectResponse != NULL){
           List<string> fieldsList = new List<String>{'Field_Label__c', 'Field_Name__c',
                						'Column_Number__c'};
            parseResponse(objectResponse,fieldsList ,'Hierarchy_Settings__mdt', query);
          
        
        }
    }
    
       public static void updateproductFilterCustomTypes(){

           String query = 'select masterLabel,Id,developerName,Order__c,Filter_Value__c, Opportunity_Amount_Field__c, Filter_Display_Name__c, '
                        +'Filter_Name__c, Label, ESG_Amount_Field__c from Product_Family_Filter__mdt';
        List<object> objectResponse = CreateAndUpdateCustomMetadataTypes.performCallout(query);
        if(objectResponse != NULL){
           List<string> fieldsList = new List<String>{'Filter_Value__c', 'Filter_Name__c',
                						'Order__c', 'Opportunity_Amount_Field__c', 'Filter_Display_Name__c', 'ESG_Amount_Field__c', 'Label'};
            parseResponse(objectResponse,fieldsList ,'Product_Family_Filter__mdt', query);
          
        }
    }
        
        
       public static void updateActivityStatus(){

        String query = 'select masterLabel,Id,developerName,Filter_Value__c,'
                        +'Filter_Name__c from Activity_Status__mdt';
        List<object> objectResponse = CreateAndUpdateCustomMetadataTypes.performCallout(query);
        if(objectResponse != NULL){
           List<string> fieldsList = new List<String>{'Filter_Value__c', 'Filter_Name__c'
                				};
            parseResponse(objectResponse,fieldsList ,'Activity_Status__mdt', query);
          
        }
    }
        
        
    
    
    public static List<object> performCallout(string query){
        HttpRequest req = new HttpRequest();
        query = EncodingUtil.urlEncode(query, 'UTF-8');
        req.setEndpoint('callout:Hub_Org/services/data/v51.0/query?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug(res.getBody());
        if(res.getStatusCode() == 200){
            Map<string,object> metadataMap = (Map<string,object>)JSON.deserializeUntyped(res.getBody());
            List<object> metadataRecords = (list<object>)metadataMap.get('records');
            return metadataRecords;
        }
        else{
            return null;
        }
    }
    
    public static void parseResponse(List<object> metadataRecords, List<String> fieldsList, String metadataName, String query ){
        Map<String,sObject> localRecordMap =  new Map<String,sObject>();
        List<sObject> localOrgRecords = (List<sObject>)database.query(query);
        for(sObject o : localOrgRecords)    {
            localRecordMap.put(String.valueOf(o.get('DeveloperName')),o);
        }  
        Boolean isUpdate = false;
        SObjectType objType = ((sobject)(Type.forName('Schema.'+metadataName).newInstance())).getSObjectType();
        DescribeSobjectResult rd = objType.getDescribe();
        for(object externalObj : metadataRecords){
            Map<String,object> externalRecordMap = (Map<String,object>)externalObj;
            if(externalRecordMap != NULL){
                
                Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
                sObject localRecord = null;
                if(localRecordMap.containsKey(String.valueof(externalRecordMap.get('DeveloperName')))){
                    localRecord = localRecordMap.get(String.valueof(externalRecordMap.get('DeveloperName')));
                    customMetadata.fullName = metadataName+'.'+localRecord.get('DeveloperName');
                    customMetadata.label = String.valueOf(externalRecordMap.get('MasterLabel'));
                }
                else{
                    customMetadata.fullName = metadataName+'.'+String.valueOf(externalRecordMap.get('DeveloperName'));
                    customMetadata.label = String.valueOf(externalRecordMap.get('MasterLabel'));
                }
                
                for(String fieldName : fieldsList){
                    Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
                    if(localRecord == null || (localRecord != null
                        && String.valueOf(localRecord.get(fieldName)) !=  String.valueOf(externalRecordMap.get(fieldName))) ){
                            String fieldType = String.valueOf(rd.fields.getMap().get(fieldName).getDescribe().getType());
                            customField.field = fieldName;
                            if(!externalRecordMap.containsKey(fieldName)){
                                continue;
                            }
                            If(fieldType == 'Boolean'){
                                  customField.value = Boolean.valueOf(externalRecordMap.get(fieldName));
                            }
                            else{
                                  customField.value = String.valueOf(externalRecordMap.get(fieldName));
                            }
                   		  
                            customMetadata.values.add(customField);
                            isUpdate = true;
                     }
                }  
                if(isUpdate == true){
                 	dmContainer.addMetadata(customMetadata);
                    performDeployment = true;
                }
            }
        }        
    }
}