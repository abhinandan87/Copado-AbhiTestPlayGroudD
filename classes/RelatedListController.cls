//----------------------------------
// @author Priyanka Vyas
// @date 16th March 2020
// @description To get the data of the related objects
// ---------------------------------
public with sharing class RelatedListController {

    @AuraEnabled
    public static ObjectWrapper fetchData(String infoJSON) {
        ComponentInfo info = (ComponentInfo)JSON.deserialize(infoJSON, ComponentInfo.class);
        if (String.isNotEmpty(info.objectType)) {
            String countQuery = getCountQueryString(info);
            String queryObjects = getObjectQueryString(info);

            system.debug('queryObjects:' +queryObjects);
            system.debug('countQuery:' +countQuery);

            return new ObjectWrapper(
                    info.recordToDisplay,
                    info.pageNumber,
                    Database.countQuery(countQuery),
                    Database.query(queryObjects)
            );
        } else {
            return new ObjectWrapper();
        }
    }

    private static String getCountQueryString(ComponentInfo info) {
        String objectType = String.escapeSingleQuotes(info.objectType);
        String parentField = info.parentField;
        String queryColumns = info.queryColumns;
        String filter = info.filter;
        Id parentRecordId = info.parentRecordId;

        String countQuery = 'SELECT count() FROM ';
        countQuery += objectType;

       if (String.isNotEmpty(parentField) && parentRecordId != null) {
            parentField = String.escapeSingleQuotes(parentField);
            countQuery += ' WHERE ' + parentField +' = \''+ parentRecordId+'\'';
        }

       if (String.isNotEmpty(filter)) {
            if(countQuery.contains('WHERE')){
                countQuery += ' AND (' + filter +')';
            }else{
                countQuery += ' WHERE (' + filter +')';
            }
            
        } 

        return countQuery;
    }

    private static String getObjectQueryString(ComponentInfo info) {
        String objectType = String.escapeSingleQuotes(info.objectType);
        String parentField = info.parentField;
        String queryColumns = info.queryColumns;
        String filter = info.filter;
        String orderBy = info.orderBy;
        Id parentRecordId = info.parentRecordId;

        String queryObjects = 'SELECT Id ';
        if(String.isNotEmpty(queryColumns)){
            queryColumns=', '+queryColumns;
            queryObjects += queryColumns;
        }
          queryObjects +='  FROM ';
        queryObjects += objectType;

        if (String.isNotEmpty(parentField) && parentRecordId != null) {
            parentField = String.escapeSingleQuotes(parentField);
            queryObjects += ' WHERE ' + parentField +' = \''+ parentRecordId+'\'';
        } 
        
         if (String.isNotEmpty(filter)) {
            if(queryObjects.contains('WHERE')){
                queryObjects += ' AND (' + filter +')';
            }else{
                queryObjects += ' WHERE (' + filter +')';
            }
            
        } 
		
        System.debug('info.recordToDisplay--->'+info.recordToDisplay);
        System.debug('info.pageNumber-->'+info.pageNumber);
        if(info.recordToDisplay!=null && info.pageNumber!=null){
        	queryObjects += ' ORDER BY ' + orderBy + ' LIMIT ' + info.recordToDisplay
                + ' OFFSET ' + (info.pageNumber - 1) * info.recordToDisplay;
		}

        return queryObjects;
    }
    
    @AuraEnabled
    public static String fetchReportId(String reportName) {
        String reportId;
        List<Report> r=new List<Report>();
        if(reportName!=null || reportName!=''){
        	r= [Select id from Report where developerName=:reportName];
        }
        if(r.size()>0) {
        	System.Debug(r[0].id);
            reportId=r[0].id;
        }
        return reportId;
    }

    @AuraEnabled
    public static ObjectWrapper deleteRecord(String infoJSON) {
        ComponentInfo info = (ComponentInfo)JSON.deserialize(infoJSON, ComponentInfo.class);
        UserRecordAccess recAccess = [
                SELECT
                        HasEditAccess,
                        HasDeleteAccess,
                        RecordId
                FROM UserRecordAccess
                WHERE UserId =: UserInfo.getUserId()
                AND RecordId =: info.recordId
        ];

        if (recAccess != null && recAccess.HasDeleteAccess) {
            try {
                sObject sObj = Schema.getGlobalDescribe().get(info.objectType).newSObject();
                sObj.Id = info.recordId;
                delete sObj;
            } catch (DmlException e) {
                throw new AuraHandledException('Error while deleting data.');
            }
        }

        return fetchData(infoJSON);
    }

    public class ObjectWrapper {
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public List<sObject> data {get;set;}

        ObjectWrapper(Integer pageSize, Integer page, Integer total, List<sObject> data) {
            this.pageSize = pageSize;
            this.page = page;
            this.total = total;
            this.data = data;
        }

        ObjectWrapper() {}
    }

    public class ComponentInfo {
        Integer pageNumber;
        Integer recordToDisplay;
        String objectType;
        String parentField;
        Id parentRecordId;
        String queryColumns;
        String filter;
        String orderBy;
        Id recordId;
    }
    
}