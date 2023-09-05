/**
 * @Author: Paras Dhingra
 * @Date: 25th Oct 2017
 * @Description: SFDC1-629 Generic controller custom lightning controller
 * @company: IHS Markit
 * @Modified : SFDC-5821 ENR- Contact visibility on Opportunity Activities
 */
public with sharing class customLookUpController {
     /**
      * @author: Paras Dhingra
      * @date: 25th Oct 2017
      * @description: SFDC1-629 method to get records for custom lookup for any object
      * @param: String,String
      * @return: List <sObject>
      * @companyname: IHS Markit
      */
  @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String optionalFilter, String secondaryFieldName) {
        System.debug('Secondary Field Name---> '+secondaryFieldName);
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+ searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        if(optionalFilter == null) {
            optionalFilter = '';
        }
        if(ObjectName=='Account' || ObjectName=='Contact' || ObjectName=='Opportunity'){
            optionalFilter = '';
        }
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        String sQuery;
        if(secondaryFieldName==''|| secondaryFieldName==null){	
        	sQuery =  'select id, Name from ';
        }
        else if(secondaryFieldName!='' && secondaryFieldName!=null){
            sQuery =  'select id, Name, '+secondaryFieldName+' from ';
        }
        String filter = ' where Name LIKE:searchKey ' + optionalFilter;
        String orderby ='';
        if(String.isBlank(searchKeyWord) ){
            orderby = '  order by Name ASC limit 5';
        }
        else{
            orderby = '  order by Name ASC limit 100';
        }
        sQuery = sQuery + ObjectName + filter + orderby;
        System.debug('--sQuery--'+sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}