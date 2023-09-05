/*******************************************************************************************
* @Name         HierarchyController 
* @Author       Vijay Sidgiddi
* @Date         02/09/2021
* @Description  This class contains all service methods related to  hierarchy.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Vijay     		 02/09/2021         Initial Creation                                                      
*******************************************************************************************/
public class HierarchyController {
    
    /**************************************************************************************
    * @Description  To get hierarchy settings
    * @Param		N/A
    * @Return       Returns hierarchy settings
    **************************************************************************************/ 
    public Static  List<Hierarchy_Settings__mdt> getHierarchySettings(){
        
     	 return [SELECT Column_Number__c, Field_Name__c, Field_Label__c 
                 FROM Hierarchy_Settings__mdt 
                 ORDER by Column_Number__c];
    }
    
     /**************************************************************************************
    * @Description  To get columns for hierarchy table 
    * @Param		N/A
    * @Return       Returns columns
    **************************************************************************************/ 
    @AuraEnabled
    public Static List<columnWrapper> getColumns(){
        
        list<columnWrapper> columnWrapperList = new List<columnWrapper>();
        List<Hierarchy_Settings__mdt> hierarchySettings = getHierarchySettings();
        
        for(Hierarchy_Settings__mdt hs : hierarchySettings){
            columnWrapper cw = new columnWrapper(hs.Field_Label__c,'String',hs.Field_Name__c);
            columnWrapperList.add(cw);
        }
        
        return columnWrapperList;
    }
    
      /**************************************************************************************
    * @Description  This method is to query to fetch the accounts
    * 				It fetches both parent and child up to level 5
    * @Param		string baseQuery
    * @Return       String 
    **************************************************************************************/    
    @AuraEnabled
    public Static String getAccountQuery(){
        Set<String> recordIdFieldNames = new Set<String>();
        List<Hierarchy_Settings__mdt> hierarchySettings = getHierarchySettings();
        String baseQuery = 'SELECT Id,Name,SP_CIQ_Company_ID__c,parentid,Total_ACV__c';

        for(Division_Settings__mdt division : [SELECT Salesforce_Record_ID_Field_Name__c FROM Division_Settings__mdt WHERE Active__c = true and Salesforce_Record_ID_Field_Name__c != null]){
            recordIdFieldNames.add(division.Salesforce_Record_ID_Field_Name__c);
        }

        for(String recordIdFieldName : recordIdFieldNames) {
            baseQuery += ', ' + recordIdFieldName;
        }
        for(Hierarchy_Settings__mdt md : hierarchySettings){
            
            if(md.Field_Name__c != null){
                
                if(!baseQuery.contains(md.Field_Name__c)){
               		baseQuery += ','+md.Field_Name__c;
                }
            }
        }
        
        baseQuery += ' FROM Account';
        return baseQuery;
    }
    
    /**************************************************************************************
    * @Description  This method is to get the hierarcy accounts of the account where the user is on. 
    * 				It fetches both parent and child up to level 5
    * @Param		string - Id of the account
    * @Return        List<Map<string,string>> - List of accounts from target org using
    Key,value pair. Example {Id:'234553454'} 
    **************************************************************************************/    
    @AuraEnabled
    public Static List<Map<string,string>> getHierarchyAccounts(String accountId, String windowUrl){
        
        String query = getAccountQuery();
        List<Map<String,String>>  accountsList = new  List<Map<String,String>>();
        String accountIds = '(\''+accountId+'\')';
        
        List<Map<String,String>> parentAccountsList = getParentAccounts(accountIds,query, windowUrl);
        List<Map<String,String>> childAccountsList = getChildAccounts(accountIds,query, windowUrl);

        if(parentAccountsList != null && !parentAccountsList.isEmpty()){
            accountsList.addAll(parentAccountsList);
        }
        
        if(childAccountsList != null && !childAccountsList.isEmpty()){
            accountsList.addAll(childAccountsList);
        }
        

        //Get
        Map<Id,Map<string,string>> mapDivisionIdToHubAccountId = new Map<Id,Map<string,string>>();

        List<Division_Settings__mdt> divisionsList = [SELECT Salesforce_Record_ID_Field_Name__c FROM Division_Settings__mdt WHERE Active__c = true AND Salesforce_Record_ID_Field_Name__c != null];
        for(Map<string,string> accMap:accountsList){
            if(accMap.get('Id').length()>=15){
                mapDivisionIdToHubAccountId.put(accMap.get('Id'), accMap);
            }
            for(Division_Settings__mdt division : divisionsList){
                if(accMap.containsKey(division.Salesforce_Record_ID_Field_Name__c) && accMap.get(division.Salesforce_Record_ID_Field_Name__c).length()>=15){
                    mapDivisionIdToHubAccountId.put(accMap.get(division.Salesforce_Record_ID_Field_Name__c), accMap);
                }
            }
        }
        if(!mapDivisionIdToHubAccountId.isEmpty()){
            //search accounts to find division id (if in division this will work)
            for(Account foundAccount : [SELECT ID FROM Account WHERE Id IN :mapDivisionIdToHubAccountId.keySet()]){
                //Now add the division id
                mapDivisionIdToHubAccountId.get(foundAccount.id).put('DivisionId',foundAccount.id);
            }
        }
        //for(Account acc:accountList){
            //check org id
        //    if(currentOrg = 'MI'){
        //        acc.id = acc.MI_Salesforce_Record_ID__c;
        //    }
        //    ...ratings
        //    ...indices
        //    ...platts
        
        return accountsList;
     }
    
    /**************************************************************************************
    * @Description  This method is to get parent accounts
    * @Param		string - Id of the account and query
    * @Return        List<Map<string,string>> - List of accounts from target org using
    Key,value pair. Example {Id:'234553454'} 
    **************************************************************************************/  
        public Static List<Map<String,String>> getParentAccounts(String accountIds, String baseQuery, String windowUrl){
        List<Map<String,String>>  accountsList = new  List<Map<String,String>>();
        Map<string,string> ResultMap = new Map<string,string>();
        Map<String,object>  ParentMap = new Map<String,object>();
        Integer loopLimit = 1;
        String key = '';
        List<object>  finalList = new List<object>();
        String baseEndpoint = AccountLandingPageController.baseEndpoint;
        String whereQuery = ' WHERE Id in ';
        String combinedQuery = baseQuery + whereQuery;
        combinedQuery = EncodingUtil.urlEncode(combinedQuery,'UTF-8');
        String parentQuery = '';
            
        while(accountIds != '' && loopLimit <= 10){
       
            parentQuery = combinedQuery + accountIds; 
            String endpoint =  baseEndpoint+parentQuery;
            finalList =  AccountLandingPageController.performAccountCallout(endpoint, windowUrl);
            
            if(finalList != null && finalList.size() > 0){
                
                ResultMap = new Map<string,string>();
                ParentMap = (Map<string,object>)FinalList[0];
                accountIds = '';
                
                if(ParentMap != null && !ParentMap.isEmpty()){
                    
                    ResultMap = AccountLandingPageController.parseResponse(ParentMap);
                    if(ParentMap!=null && ParentMap.containsKey('ParentId')){
                        
                        ResultMap.put('ParentId',string.valueof(ParentMap.get('ParentId')));
                        if(ParentMap.get('ParentId') != null){
                             accountIds = '(\''+ParentMap.get('ParentId')+'\')';
                        }
                        
                    }
                }
                
                if(ResultMap.size()>0){
                    accountsList.add(ResultMap);
                }
            } 
            loopLimit += 1;
        }
        return accountsList;
    }
    
    /**************************************************************************************
    * @Description  This method is to get the child accounts. 
    * @Param		string - Id of the account and query
    * @Return        List<Map<string,string>> - List of accounts from target org using
    Key,value pair. Example {Id:'234553454'} 
    **************************************************************************************/  
    public Static List<Map<string,string>> getChildAccounts(String accountIds, String baseQuery, String windowUrl){
        
        List<Map<String,String>>  accountsList = new  List<Map<String,String>>();
        Map<String,object> FinalMap = new Map<String,object>();
        Map<String,String> ResultMap = new Map<String,String>();
        List<object> finalList = new List<object>();
        String key = '';
        Integer loopLimit = 0;
        String baseEndpoint = AccountLandingPageController.baseEndpoint;
        String whereQuery = ' WHERE parentId in ';
        String combinedQuery = baseQuery + whereQuery;
        combinedQuery = EncodingUtil.urlEncode(combinedQuery,'UTF-8');
        String childQuery = '';

        while(accountIds != '' && loopLimit <= 10){
       
            childQuery = combinedQuery + accountIds; 
            String endpoint =  baseEndpoint+childQuery;
            finalList =  AccountLandingPageController.performAccountCallout(endpoint, windowUrl);
            accountIds = '';
            finalList =  AccountLandingPageController.performAccountCallout(endpoint, windowUrl);
            
            for(object o : finalList){
                
                FinalMap = (Map<string,object>)o;
                if(FinalMap != null){
                    
                    ResultMap = AccountLandingPageController.parseResponse(FinalMap);
                    if(FinalMap!=null && FinalMap.get('Id')!=null){
                        
                        if(FinalMap.get('ParentId') != null){
                          ResultMap.put('ParentId',string.valueof(FinalMap.get('ParentId')));
                        }

                        accountIds = accountIds+'\''+FinalMap.get('Id')+'\',';
                    }
                    accountsList.add(ResultMap);
                }
            }
            
            if(accountIds != ''){
                accountIds = '('+accountIds.removeEnd(',')+')';
            }
            loopLimit++;
        }
        return accountsList;
    }

    
      public class columnWrapper{
          
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string type;
        @AuraEnabled
        public string fieldName;
        
        public columnWrapper(string label, string type, string fieldName){
            
            this.label = label;
            this.type = type;
            this.fieldName = fieldName.replace('__r.','__r_');
            
        }
          
    }

}