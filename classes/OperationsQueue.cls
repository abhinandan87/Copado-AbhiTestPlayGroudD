//-----------------------------
// @author: Anjali
// @date: 27th May 2021
// @description: Class for passing data in operation queue related lwc components.
// @return: None
//------------------------------
public with sharing class OperationsQueue {
    
    @AuraEnabled(cacheable=true)
    public static List<Queues__mdt> queueValues(){
        return [SELECT Id, MasterLabel FROM Queues__mdt ORDER BY MasterLabel ASC];
    }
    
    @AuraEnabled(cacheable=true)
    public static list<WorkRequestForm__c> getWRFRecords(String selectedQueue) {
        list<WorkRequestForm__c> lstofWRF = new list<WorkRequestForm__c>();
        String searchID = returnQueue(selectedQueue);
        if(selectedQueue != 'All') {
        lstofWRF =[select id, name, ownerId,owner.Name, SubmittedDateTime__c, PrimarySalesContact__c,PrimarySalesContact__r.Name, RequestedDueDate__c, RequestStatus__c,
                            JobNumber__c, FormType__c from WorkRequestForm__c where ownerid =: searchID order by SubmittedDateTime__c ASC LIMIT :(Limits.getLimitQueryRows())];
        }
         else {
                lstofWRF=[select id, name, ownerId,owner.Name, SubmittedDateTime__c, PrimarySalesContact__c,PrimarySalesContact__r.Name, RequestedDueDate__c, RequestStatus__c,
                            JobNumber__c, FormType__c from WorkRequestForm__C where RequestStatus__c = 'Submitted' order by SubmittedDateTime__c asc LIMIT :(Limits.getLimitQueryRows())];
        }
        return lstofWRF;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static list<changelog__c> getchangeLogRecords(String selectedQueue) {
        list<changelog__c> clResults = new list<changelog__c>();
        String searchID = returnQueue(selectedQueue);       
        if(selectedQueue != 'All') {
            clResults = [select Id, Name, OwnerId,Owner.Name,Owner__c, changedescription__c, ChangeDocumentedBy__c,ChangeDocumentedBy__r.Name, SubmittedDateTime__c,
                         WorkRequestForm__c,WorkRequestForm__r.Name, RequestStatus__c, wrstatus__c from changelog__c where ownerid =: searchID order by SubmittedDateTime__c LIMIT :(Limits.getLimitQueryRows())];
        }
        else {
            clResults = [select Id, Name, OwnerId,Owner.Name,Owner__c, changedescription__c, ChangeDocumentedBy__c,ChangeDocumentedBy__r.Name, SubmittedDateTime__c,
                         WorkRequestForm__c,WorkRequestForm__r.Name, RequestStatus__c, wrstatus__c from changelog__c where RequestStatus__c = 'Submitted' order by SubmittedDateTime__c LIMIT :(Limits.getLimitQueryRows())];
        }
        return clResults;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static list<OrderRequest__c> getOrderReqRecords(String selectedQueue) {
        list<OrderRequest__c> orResults = new list<OrderRequest__c>();
        String searchID = returnQueue(selectedQueue);       
        if(selectedQueue != 'All') {
            orResults = [select id, name, ownerid,owner.Name, SubmittedDateTime__c,
                         workrequestform__c,workrequestform__r.Name, OrderRequestStatus__c,OrderRequestedDate__c from OrderRequest__c where ownerid =:searchID order by SubmittedDateTime__c LIMIT :(Limits.getLimitQueryRows()) ];//Added OrderRequestedDate__c for SFDC-4664 
        }        
        else {
            orResults = [select id, name, ownerid,owner.Name, SubmittedDateTime__c,
                         workrequestform__c,workrequestform__r.Name, OrderRequestStatus__c,OrderRequestedDate__c from OrderRequest__c where OrderRequestStatus__c = 'Submitted' order by SubmittedDateTime__c LIMIT :(Limits.getLimitQueryRows())];//Added OrderRequestedDate__c for SFDC-4664
        }
        return orResults;
        
    }
    
    public static String returnQueue(String selectedQueue) {
        String searchID;
        if (selectedQueue != 'All') {
            List<Group> queues = [Select id From Group where Type='Queue' and name =: selectedQueue LIMIT 1 ];
            if(queues.size() > 0) {
                searchID = queues[0].id;
            } else {
                searchID = null;
            }
        }
        return searchID;
    }

}