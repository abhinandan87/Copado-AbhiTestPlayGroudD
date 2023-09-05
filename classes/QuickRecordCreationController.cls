//-----------------------------------------------------------------------------
// @author: Priyanka Vyas
// @date: 9 Apr 2020
// @description:  SFDC-2560 Creation of Contact & Opportunity from utility bar
//-----------------------------------------------------------------------------
public with sharing class QuickRecordCreationController {
    @AuraEnabled
    public static Boolean checkCreationPermission(String objAPIName){
        Boolean thisUserMayCreate=true;
        Schema.DescribeSObjectResult utilityObject = Schema.getGlobalDescribe().get(objAPIName).getDescribe();
        if(!utilityObject.isCreateable()){
            thisUserMayCreate=false;
        }
        return thisUserMayCreate;
    }    
    @AuraEnabled
    public static Contact createContact (String firstname, String middlename, String lastname, String phone, String email, String accId, String title, String businessSegment, String jobTitle, String jobFunction, String groupDesk) {
        Contact newContact;
        newContact = new Contact(FirstName = firstname, LastName = lastname, Email = email, AccountId = accId, MiddleName=middlename, Phone=phone, Title=title,BusinessSegment__c=businessSegment,JobTitle__c=jobTitle,JobFunction__c=jobFunction,GroupDesk__c=groupDesk);
        try {
            if(Schema.sObjectType.Contact.fields.Email.isCreateable()){
                insert newContact;
            }
        }Catch(Exception ex) {
            System.debug('::: Error on quick create contact: '+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return newContact;
    }
    @AuraEnabled
    public static sobject fetchSObjectfields(String recordString) {
        SObject record;
        if(recordString!=null) {  
            UserRecordAccess u=[SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId = :recordString];
            if(u.HasReadAccess){    
                ID recordId = recordString;
                DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();	
                List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
                String query =
                    ' SELECT ' +
                    String.join( fieldNames, ',' ) +
                    ' FROM ' +
                    describeResult.getName() +
                    ' WHERE ' +
                    ' id = :recordId ' +
                    ' LIMIT 1 ';
                
                record = Database.query( query );
                System.debug( record );
            }
        }
        return record; 
    } 
    @AuraEnabled
    public static Opportunity createOpportunity (String oppyName, String accId, Date cDate, String budgetRange) {
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
            .get('NewBusiness').getRecordTypeId();
        Opportunity newOppy;
        //Replication of Account's Quick Action - Create New Business Opportunity
        newOppy = new Opportunity(Name = oppyName, AccountId = accId, CloseDate = cDate);
        newOppy.ForecastCategoryName='Pipeline';
        newOppy.Probability=1;
        newOppy.StageName='1-Sales Qualified';
        newOppy.RecordTypeId=recordTypeId;
        if(budgetRange!='--None--'){	
            newOppy.BudgetRange__c=budgetRange;
        }
        try {
            insert newOppy;
        }Catch(Exception ex) {
            System.debug('::: Error on quick create opportunity: '+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return newOppy;
    }
    @AuraEnabled
    public static List<String> fetchPickListValues(String objectAPIName, String fieldAPIName){
        List<String> options = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectAPIName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: ple) {
            System.debug(p.getLabel() +' '+p.getValue());
            options.add(p.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static Event createEvent(String eventJSONString) {
        System.debug(eventJSONString);
        Map<String, String> eventMap = (Map<String,String>) JSON.deserialize(eventJSONString, Map<String,String>.class);
        System.debug(eventMap);
        RecordType rt=new RecordType();
        rt=[select Id from RecordType where Name = 'Standard' and SobjectType = 'Event'];
        Event newEvent;
        newEvent=new Event();
        try {
            if(eventMap.get('eventType')=='Meeting'){
            	newEvent.Type='Meetings';
            }
            else{
            	newEvent.Type=eventMap.get('eventType');
            }
            newEvent.Subject=eventMap.get('eventSubject');
            newEvent.SubType__c = eventMap.get('eventSubType');
            if(eventMap.get('eventWhoId')!='' && eventMap.get('eventWhoId')!=null){
                newEvent.WhoId=eventMap.get('eventWhoId');
            }
            if(eventMap.get('eventWhatId')!='' && eventMap.get('eventWhatId')!=null){
                newEvent.WhatId=eventMap.get('eventWhatId');
            }
            Datetime startDT = Datetime.valueOf(eventMap.get('StartDateTime').replace('T', ' '));
			Integer offsetStart = UserInfo.getTimezone().getOffset(startDT);
            newEvent.StartDateTime= startDT.addSeconds(offsetStart/1000);
            
            Datetime endDT = Datetime.valueOf(eventMap.get('EndDateTime').replace('T', ' '));
			Integer offsetEnd = UserInfo.getTimezone().getOffset(endDT);
            newEvent.EndDateTime= endDT.addSeconds(offsetEnd/1000);
            newEvent.OwnerId=eventMap.get('OwnerId');
            newEvent.Location=eventMap.get('Location');
            if(rt!=null){
            	newEvent.RecordTypeId=rt.Id;
            }
            insert newEvent;
        }Catch(Exception ex) {
            System.debug('::: Error on quick create event: '+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return newEvent;
    } 
    @AuraEnabled
    public static Task createTask(String taskJSONString) {
        System.debug(taskJSONString);
        Map<String, String> taskMap = (Map<String,String>) JSON.deserialize(taskJSONString, Map<String,String>.class);
        System.debug(taskMap);
        Task newTask;
        newTask=new Task();
        try {
            newTask.Subject=taskMap.get('taskSubject');
            newTask.SubType__c = taskMap.get('taskSubType');
            if(taskMap.get('taskWhoId')!='' && taskMap.get('taskWhoId')!=null){
                newTask.WhoId=taskMap.get('taskWhoId');
            }
            if(taskMap.get('taskWhatId')!='' && taskMap.get('taskWhatId')!=null){
                newTask.WhatId=taskMap.get('taskWhatId');
            }
            newTask.OwnerId=taskMap.get('OwnerId');
            if(taskMap.get('ActivityDate')!=''){
                Date nativedate = Date.Valueof(taskMap.get('ActivityDate'));
				String localedate=nativedate.format();
                newTask.ActivityDate=Date.parse(localedate);
				//newTask.ActivityDate=Date.Valueof(taskMap.get('ActivityDate'));
            }
            newTask.Priority=taskMap.get('Priority');
            newTask.Status=taskMap.get('Status');
            
            insert newTask;
        }Catch(Exception ex) {
            System.debug('::: Error on quick create task: '+ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return newTask;
    } 
    @AuraEnabled
    public static String fetchEventWhatId(String eventId) {
        String eventWhatId='';
        Event evt = new Event();
        UserRecordAccess u=[SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId = :eventId];
        if(u.HasReadAccess){    
            evt = [Select id, WhatId from Event where id=:eventId ALL ROWS];
            if(evt!=null){   
            	if(evt.WhatId!=null){
                    eventWhatId=evt.WhatId;
                }
            }
        }
        return eventWhatId;
    }    
    @AuraEnabled
    public static String fetchTaskWhatId(String taskId) {
        String taskWhatId='';
        Task tsk = new Task(); 
        UserRecordAccess u=[SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId = :taskId];
        if(u.HasReadAccess){   
            tsk = [Select id, WhatId from Task where id=:taskId ALL ROWS];
            if(tsk!=null){
                if(tsk.WhatId!=null){
                    taskWhatId=tsk.WhatId;
                }
            }
        }
        return taskWhatId;
    }
    
    @AuraEnabled
    public static User fetchCurrentUser(String userId) {
        User userRecord;
        if(userId!=null){
            ID recordId=userId;
            DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();	
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            String query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +
                ' id = :recordId ' +
                ' LIMIT 1 ';
            
            userRecord = Database.query( query );
        }
        return userRecord;
    }    
}