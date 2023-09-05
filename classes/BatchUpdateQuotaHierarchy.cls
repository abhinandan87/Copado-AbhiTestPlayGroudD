/*  @author: Akash Punera
*   @date: 04 Jul 2021
*   @description: Batch class to update All Managers field on Quota records with latest user info
*/
global class BatchUpdateQuotaHierarchy implements Database.Batchable<sObject>,Database.Stateful {
    public String query;
    public Map<String,String> mapEmployeeIdToName;
    public Map<String,List<String>> mapQuotaToShare;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        mapEmployeeIdToName = new Map<String,String>();
        mapQuotaToShare = new Map<String, List<String>>();
        
        //Get all users and create employeeNumber to Name map
        for(User uObj : [SELECT employeeNumber__c, Name 
                         FROM User
                         WHERE employeeNumber__c != '' ]) {
                             mapEmployeeIdToName.put(uObj.employeeNumber__c,uObj.Name);
                         }
        //SFDC-4930 create shared quota map
        createSharedQuotaMap();
        //Query all Quota Records
        query = 'SELECT Id, Name, AllManagers__c, hierarchy__c, SharedHierarchy__c FROM Quota__c where source__c = \'Quota Database\' ';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quota__c> scope) {
        try {
            List<Quota__c> lstQuotaToUpdate = new List<Quota__c>();
            
            //Update manager names based on hierarchy
            for(Quota__c qObj : scope) {
                //SFDC-4930 check and update custom hierarchy
                qObj = updateCustomHierarchy(qObj);
                
                String managerNames = '';
                if(qObj.hierarchy__c != null){
                    for(String mId : qObj.hierarchy__c.split(';')) {
                        if(String.isNotBlank(mId)){
                            managerNames += mapEmployeeIdToName.get(mId)+';';
                        }
                    }
                    qObj.AllManagers__c = managerNames;
                    lstQuotaToUpdate.add(qObj);
                } 
            }
            if(lstQuotaToUpdate!=null && !lstQuotaToUpdate.isEmpty()) {
                Database.SaveResult[] srList = Database.update(lstQuotaToUpdate, false);
                List<ApexLogger__c> logRecList = new List<ApexLogger__c>();                
                Integer counter = 0;
                for (Database.SaveResult sr : srList) {                    
                    if (!sr.isSuccess()) {                        
                        for(Database.Error err : sr.getErrors()) {
                            logRecList.add(new ApexLogger__c(ClassName__c='BatchUpdateQuotaHierarchy', FunctionName__c='Execute', LogRecordId__c=lstQuotaToUpdate[counter].Id, LogRecordName__c=lstQuotaToUpdate[counter].Name, ErrorDescription__c=err.getMessage()));
                        }
                    }
                    counter++;
                }
                //Insert Error Log records
                if(logRecList.size() > 0) {
                    insert logRecList;
                }
            }

            
        } catch(Exception ex) {
            System.debug('Exception caught in batch'+ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchUpdateQuotaHierarchy', 'Execute');       
        }
        
    }
    global void finish(Database.BatchableContext BC) { 
        System.debug(LoggingLevel.INFO, 'BatchUpdateQuotaHierarchy batch completed');
    }
    
    /*  @author: Akash Punera
    *   @date: 05 Apr 2022
    *   @description: SFDC-4930 Method to create map of users to share quota records with
    */
    public void createSharedQuotaMap() {
        //Get all Shared Quota records
        for(SharedQuota__c sQuota : [SELECT user__r.employeeNumber__c, shareWithUser__r.employeeNumber__c 
                                     FROM 	SharedQuota__c
                                     WHERE 	active__c = true]) {
            if(mapQuotaToShare.containsKey(sQuota.user__r.employeeNumber__c)) {
                mapQuotaToShare.get(sQuota.user__r.employeeNumber__c).add(sQuota.shareWithUser__r.employeeNumber__c);
            }else {
                mapQuotaToShare.put(sQuota.user__r.employeeNumber__c, new list<STring>{sQuota.shareWithUser__r.employeeNumber__c});
            }            
        }
        system.debug('mapQuotaToShare '+mapQuotaToShare);
    }
    
     
    /*  @author: Akash Punera
    *   @date: 05 Apr 2022
    *   @description: SFDC-4930 Method to update custom hierarchy on quota
    */
    public quota__c updateCustomHierarchy(quota__c qObj) {
        //clear existing sharings if any
        if(String.isnotblank(qObj.SharedHierarchy__c)) {
            for(string employeeToRemove : qObj.sharedHierarchy__c.split(';')) {
                qObj.Hierarchy__c = qObj.Hierarchy__c.replace(employeeToRemove,'').replace(';;',';');
            }
            qObj.SharedHierarchy__c = '';
        }
        
        //iterate on all shared quota records
        for(String mId : mapQuotaToShare.keySet()) {
            if(qObj.hierarchy__c.contains(mId) && (String.isblank(qObj.SharedHierarchy__c) || !qObj.SharedHierarchy__c.contains(mId))) {
                for(String userId : mapQuotaToShare.get(mId)) {
                    if(String.isblank(qObj.SharedHierarchy__c)) {
                    	qObj.SharedHierarchy__c = userId+';';    
                    }else {
                        qObj.SharedHierarchy__c += userId+';';
                    }
                	qObj.Hierarchy__c += userId+';';   
                }
            }
        }
        return qObj;
    }
}