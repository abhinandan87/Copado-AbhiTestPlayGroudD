/*******************************************************************************************
* @Name         AccountLandingPageController 
* @Author       Vijay Sidgiddi
* @Date         02/09/2021
* @Description  This class contains all service methods related to Account details, hierarchy, pipeline,activity and contact.  
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Vijay            02/09/2021         Initial Creation                                                      
*******************************************************************************************/
public class AccountLandingPageController {
    public static String baseEndpoint = 'callout:Hub_Org/services/data/v50.0/query?q=';

    /**************************************************************************************
    * @Description  This method gets the logged in environment account details based on the user opened account
    * @Param        String - Id of the account
    * @Return       Account - Details of the account
    **************************************************************************************/
    @AuraEnabled
    public static String getLocalAccount(string accountId){
        String selectQueryClause = 'SELECT parentId, Id, name,';
        if(Customer_Insight_Settings__c.getInstance() != NULL
           && Customer_Insight_Settings__c.getInstance().Mapping_Key__c != NULL){
              selectQueryClause = selectQueryClause + Customer_Insight_Settings__c.getInstance().Mapping_Key__c;
              
              String combinedQuery  = selectQueryClause+' FROM Account WHERE Id=\''+accountId+'\' Limit 1';
              List<Account> accList = database.query(combinedQuery);
               
               if(accList != NULL && !accList.isEmpty()){
                   return String.valueOf(accList[0].get(Customer_Insight_Settings__c.getInstance().Mapping_Key__c));
               }
           }
        
          return null;
    }
    
    
    /**************************************************************************************
    * @Description  This method is to get the division details of the target org. These details
         are maintained in custom metadatatype Division_Settings__mdt with division and field details
    * @Param        N/A
    * @Return       List<Division_Settings__mdt> - Returns the list of divisions from the custom metadata type 
    **************************************************************************************/ 
    @AuraEnabled
    public static List<Division_Settings__mdt> getDivisions(){
        return [SELECT  Label, Org_ID__c, Stack_Color__c, Order__c, NPS_Field_Name__c,
                    Manager_Field_Name__c, Display_Name__c, ACV_Field_Name__c, 
                    NPS_Color_Field__c, ACV_Color_Field__c, Opportunity_Amount_Field__c, DeveloperName, Disable_Chart__c,
                    ESG_Amount_Field__c
                FROM Division_Settings__mdt 
                 WHERE Active__c = true
                ORDER by Order__c];
    }
    
    
    /**************************************************************************************
    * @Description  This method is to get the product family details of the target org. These details
            are maintained in custom metadatatype  with division and field details
    * @Param        N/A
    * @Return       List<Product_Family_Filter__mdt> - Returns the list of divisions from the custom metadata type 
    **************************************************************************************/ 
    @AuraEnabled
    public static List<Product_Family_Filter__mdt> getProductFamily(){
        return [SELECT Label, Filter_Value__c, Filter_Name__c, Order__c, Opportunity_Amount_Field__c, Filter_Display_Name__c
                FROM Product_Family_Filter__mdt 
                ORDER by order__c asc];
    }

    private static String getDataSyncQuery(){
        return 'SELECT Id, Last_INFA_Data_Update__c FROM Data_Sync_Summary__c WHERE Status__c = \'Success\' ORDER BY CreatedDate DESC LIMIT 1';
    }
    @AuraEnabled
    public static String getDataSyncSummaryDate(String windowUrl){
        String dataQuery = getDataSyncQuery();
        dataQuery = EncodingUtil.urlEncode(dataQuery, 'UTF-8');
        String endPoint = baseEndpoint + dataQuery;

        List<Object> dataObjectList = performAccountCallout(endPoint, windowUrl);

        if(dataObjectList != null && dataObjectList.size() > 0) {
            Map<String, Object> dataObject = (Map<String, Object>)dataObjectList[0];
            String dateField = (String)dataObject.get('Last_INFA_Data_Update__c');
            if(dateField == null || dateField.length() == 0){
                return null;
            }
            List<String> dateTimeList = dateField.split('T');
            String dateString = dateTimeList[0];
            String timeString = dateTimeList[1];
            List<String> dateRaw = dateString.split('-');
            List<String> timeRaw = timeString.split(':');
            DateTime lastSyncDate = Datetime.newInstanceGMT(
                    Integer.valueOf(dateRaw[0]),
                    Integer.valueOf(dateRaw[1]),
                    Integer.valueOf(dateRaw[2]),
                    Integer.valueOf(timeRaw[0]),
                    Integer.valueOf(timeRaw[1]),
                    0);

            User currentUser = [Select TimeZoneSidKey from User where id =: UserInfo.getUserId()];
            return ''+lastSyncDate.format('M/dd/yyyy h:mm a', currentUser.TimeZoneSidKey);
        }

        return null;
    }

    
    /**************************************************************************************
    * @Description  This method is to get the target org account based on SP_CIQ_Company_ID__c
    * @Param        String - SPCIQCompanyId
    * @Return       Map<string,string> - Provide details of the account from target org using
    Key,value pair. Example {Id:'234553454'} 
    **************************************************************************************/    
    @AuraEnabled
    public static Map<String,String> getAccount(String SPCIQCompanyId, String windowUrl){
        String selectQueryClause = getAccountQuery();
        String fromQueryClause = ' FROM Account ';
        String whereQueryClause = ' WHERE SP_CIQ_Company_ID__c=\''+SPCIQCompanyId+'\'';
       
        String combinedQuery = selectQueryClause + fromQueryClause + whereQueryClause + ' LIMIT 1';
        combinedQuery = EncodingUtil.urlEncode(combinedQuery,'UTF-8');
        String endPoint = baseEndpoint + combinedQuery;

        List<Object> finalList =  performInitialCallout(endpoint, windowUrl);
        if(finalList != null && finalList.size() > 0){
            Map<String, Object> finalMap = (Map<String, Object>)finalList[0];
            if(finalMap.containsKey('Error')){
                return (Map<String, String>)finalMap;
            }
            return parseResponse(finalMap);
        }

        return null;
    }
    
     /**************************************************************************************
    * @Description  This method is to get the query
    * @Param        N/A
    * @Return       Object - Returns query
    **************************************************************************************/     
    public static String getAccountQuery(){    
        List<Division_Settings__mdt> divisions  = getDivisions();
        string query = 'SELECT id,name,SP_CIQ_Company_ID__c,parentid,SP_CIQ_Ultimate_Parent_Name__c';
        
        for(Division_Settings__mdt dt : divisions){
            if(String.isNotBlank(dt.NPS_Field_Name__c)){
                 query =query+','+dt.NPS_Field_Name__c;
            }
            
            if(String.isNotBlank(dt.ACV_Field_Name__c)){
                 query =query+','+dt.ACV_Field_Name__c;
            }
            
            if(String.isNotBlank(dt.NPS_Color_Field__c)){
                 query =query+','+dt.NPS_Color_Field__c;
            }
            
            if(String.isNotBlank(dt.ACV_Color_Field__c)){
                 query =query+','+dt.ACV_Color_Field__c;
            }
            
            if(String.isNotBlank(dt.Manager_Field_Name__c)){
                  query =  query+','+dt.Manager_Field_Name__c.replace('__c','__r')+'.Name';
                  query =  query+','+dt.Manager_Field_Name__c.replace('__c','__r')+'.email__c';
                  query =  query+','+dt.Manager_Field_Name__c.replace('__c','__r')+'.phone__c';
            }
        }
       return query;
    }

    public static List<Object> performInitialCallout(String endpoint, String windowUrl){
        httpRequest request = new httpRequest();
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        http http = new http();
        httpResponse response;
        String errorMessage;
        try{
            response = http.send(request);
        } catch(Exception e){
            errorMessage = e.getMessage();
            List<Map<String, String>> errorMap = new List<Map<String, String>>{new Map<String, String>{
                    'Error' => errorMessage,
                    'StatusCode' => 'Callout not made.',
                    'Url' => windowUrl
            }};
            return errorMap;
        }
        if(response.getStatusCode()==200) {
            List<object> FinalList = new List<object>();
            Map<string, object> responseMap = (Map<string, object>) JSON.deserializeUntyped(response.getBody());
            if (responseMap.containsKey('records')) {
                FinalList = (List<object>) (responseMap.get('records'));
            }

            return FinalList;
        } else {
            String statusCode = String.valueOf(response.getStatusCode());
            errorMessage = response.getBody();
            List<Map<String, String>> errorMap = new List<Map<String, String>>{new Map<String, String>{
                    'Error' => errorMessage,
                    'StatusCode' => statusCode,
                    'Url' => windowUrl
            }};
            return errorMap;
        }
    }
      /**************************************************************************************
    * @Description  This method is to perform callout and get response
    * @Param        String - endpoint
    * @Return       Object - Returns response
    **************************************************************************************/     
    public static List<Object> performAccountCallout(String endpoint, String windowUrl){
        httpRequest request = new httpRequest();
        request.setEndPoint(endpoint);
        request.setMethod('GET');
        http http = new http();
        httpResponse response;
        String errorMessage;
        try{
            response = http.send(request);
        } catch(Exception e){
            errorMessage = e.getMessage();
            List<Map<String, String>> errorMap = new List<Map<String, String>>{new Map<String, String>{
                    'Error' => errorMessage,
                    'StatusCode' => 'Callout not made.',
                    'Url' => windowUrl
            }};
            sendErrorEmail(errorMap[0]);
            return null;
        }
        if(response.getStatusCode()==200) {
            List<object> FinalList = new List<object>();
            Map<string, object> responseMap = (Map<string, object>) JSON.deserializeUntyped(response.getBody());
            if (responseMap.containsKey('records')) {
                FinalList = (List<object>) (responseMap.get('records'));
            }

            return FinalList;
        } else {
            String statusCode = String.valueOf(response.getStatusCode());
            errorMessage = response.getBody();
            List<Map<String, String>> errorMap = new List<Map<String, String>>{new Map<String, String>{
                    'Error' => errorMessage,
                    'StatusCode' => statusCode,
                    'Url' => windowUrl
            }};
            sendErrorEmail(errorMap[0]);
            return null;
        }
    }


    /**************************************************************************************
    * @Description  This method is to parse the response
    * @Param        List<object> response
    * @Return       Map<string,string>
    **************************************************************************************/     
    public static Map<string,string> parseResponse(Map<string,object>  recordMap){        
          Map<string,string> accountResponseMap = new Map<string,string>();
          Map<string,object> parentRecordMap = new Map<string,object>();
          string value = '';
          string key = '';
        
          for(string record : recordMap.keyset()){
                if(record != 'attributes' && !record.contains('__r')){
                    value = string.valueOf(recordMap.get(record));
                   
                    if(value != 'ParentId' && String.isBlank(value)){
                        value = '--';
                    }
                    accountResponseMap.put(record,value);
                }
                else if(record.contains('__r')){
                    parentRecordMap = (Map<string,object>)recordMap.get(record);
                    if(parentRecordMap!=null){
                        
                        for(string parentRecord : parentRecordMap.keyset()){
                            if(parentRecord != 'attributes'){
                                key = record+'_'+parentRecord;
                                accountResponseMap.put(key,string.valueOf(parentRecordMap.get(parentRecord)));
                            }
                        }
                    }else
                        accountResponseMap.put(record+'_Name','--' );
                }
          } 
            return accountResponseMap;
    }

    @AuraEnabled
    public static void sendErrorEmail(Map<String, String> errorObject){
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String Url = '';
        String UserName = UserInfo.getUserName();
        String Error = '';
        String UserFirstLastName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        String UserId = UserInfo.getUserId();
        String StatusCode = '';

        if(errorObject.containsKey('Url')){
            Url = errorObject.get('Url');
        } else {
            Url = 'Url Unavailable';
        }
        if(String.isEmpty(UserName)) {
            UserName = 'UserName Unavailable';
        }

        if(errorObject.containsKey('Error')){
            Error = errorObject.get('Error');
        } else {
            Error = 'Error Unavailable';
        }
        if(String.isEmpty(UserFirstLastName)){
            UserFirstLastName = 'Name Unavailable';
        }
        if(String.isEmpty(UserId)){
            UserId = 'User Id Unavailable';
        }
        if(errorObject.containsKey('StatusCode')){
            StatusCode = errorObject.get('StatusCode');
        } else {
            StatusCode = 'Status Code Unavailable';
        }
        Customer_Insight_Settings__c emailSettings = Customer_Insight_Settings__c.getInstance();
        String[] toAddresses = new String[]{emailSettings.Error_Message_To_Address__c};
        mail.setToAddresses(toAddresses);

        List<OrgWideEmailAddress> orgWideEmail;
        if(emailSettings.Error_Message_From_Address__c!=null) {
            orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :emailSettings.Error_Message_From_Address__c LIMIT 1];
        }

        if(orgWideEmail != null && orgWideEmail.size() > 0) {
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
        }

        mail.setSubject('Customer Insight Divisional View Error');
        String messageBody = '<p>The following error has occurred while ' + UserName;
        messageBody += ' loaded the Divisional View on: <a href=' + Url +'>' + Url + '</a></p>';
        messageBody += '</p><br/> Status Code: ' + StatusCode;
        messageBody += '<br/>Username: ' + UserName;
        messageBody += '<br/>User Id: ' + UserId;
        messageBody += '<br/>Name: ' + UserFirstLastName;
        messageBody += '<br/>Error Message: ' + Error;
        mail.setHtmlBody(messageBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

}