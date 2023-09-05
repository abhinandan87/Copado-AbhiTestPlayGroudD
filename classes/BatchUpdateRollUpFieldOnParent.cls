//-----------------------------
// @author: Neelam Agrawal
// @date: 10 Feb 2022
// @description: SFDC-5361 This batch class will be used to create rollup values to parent object
//------------------------------
global class BatchUpdateRollUpFieldOnParent implements Database.Batchable<sObject>,Database.Stateful{
    public String parentObject;
    public String childObject;
    public String relationshipField;
    public String parentWhereClause;
    public String childWhereClause;
    public set<String> parentObjectFieldName = new set<String>();
    public set<String> childObjectFieldName = new set<String>();
    public Boolean batchHasErrors = false;
    public set<String> errorLog= new set<String>();
    public map<String, set<String>> mapErrorRecord= new map<String, set<String>>();
    
    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: batchParameter - wrapper class
    // @description: Constructor to collect field name for parentObject and ChildObject from Custom Setting CustomRollUpConfiguration__c
    // @return: None
    public BatchUpdateRollUpFieldOnParent(batchParameter parameter) {
        this.parentObject =parameter.getParentObjectName();
        this.childObject = parameter.getchildObject();
        this.relationshipField = parameter.getrelationshipField();
        this.parentWhereClause = parameter.getparentWhereClause();
        this.childWhereClause = parameter.getchildWhereClause();
        List<CustomRollUpConfiguration__c> rollUpConfigurationCSList=[Select id,Active__c, ParentField__c, ParentObject__c, ChildField__c, ChildObject__c from CustomRollUpConfiguration__c 
                                                                      where ParentObject__c=:parentObject AND ChildObject__c=:childObject AND Active__c=true];
        for(CustomRollUpConfiguration__c fieldMapObj:rollUpConfigurationCSList ) {
            if(fieldMapObj.Active__c) {
                  if(!String.isBlank(fieldMapObj.ParentField__c)){
                      this.parentObjectFieldName.add(fieldMapObj.ParentField__c);
                  }
                  if(!String.isBlank(fieldMapObj.childField__c)){
                      this.childObjectFieldName.add(fieldMapObj.childField__c); 
                  }
              }
        }
    }
    
    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: BatchableContext - Batch context variable
    // @description: Method to collect ParentObject records for which rollup field value will be calculated.
    // @return: List<sObject> - List of ParentObject records to be processed by execute() method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = '';
        String joinedString = String.join(new List<String>(parentObjectFieldName), ',');
        if (String.isEmpty(parentWhereClause)) {
            query= 'SELECT Id, '+joinedString+ ' FROM '+parentObject;        
        }
        else{
            query= 'SELECT Id, '+joinedString+ ' FROM '+parentObject+parentWhereClause;
        }
        return Database.getQueryLocator(query);
    }
    
    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: 
    //          BatchableContext - Batch context variable
    //          List<sObject> - List of ParentObject records  collected in start() method
    // @description: Method to:
    //              1) Extract ChildRecord based on Relationship Key
    //              2) Call main method 'AutoCalculateRollupValueHelper.rollupProductInfoToParent' which validates ParentRecord and calculate Rollup field Value
    //              3) Update the parentObject records              
    // @return: None
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Schema.SObjectType sObjectType = scope.getSObjectType();
        List<sObject> parentToUpdated= new List<sObject>();
        String joinedString = String.join(new List<String>(childObjectFieldName), ',');  
        String childQuery='';
        if (String.isEmpty(childWhereClause)) {
            childQuery= 'SELECT Id, '+relationshipField+','+joinedString+ ' FROM '+childObject+' WHERE '+relationshipField+ ' IN: scope';        
        }
        else{
            childQuery= 'SELECT Id, '+relationshipField+','+joinedString+ ' FROM '+childObject+' WHERE '+relationshipField+ ' IN: scope '+childWhereClause;
        }
        List<sObject> childObjectList = Database.query(childQuery);       
        parentToUpdated=AutoCalculateRollupValueHelper.rollupProductInfoToParent(scope, childObjectList,relationshipField,Null);
        Database.SaveResult[] srList = Database.update(parentToUpdated, false);
        Integer counter=0;
        for (Database.SaveResult sr : srList) {                    
        	if (!sr.isSuccess()) {                        
            	for(Database.Error err : sr.getErrors()) {
                    String error= err.getMessage();
                    batchHasErrors = true;
                    errorLog.add(err.getMessage());
                    if(!mapErrorRecord.containsKey(error)) {
                            mapErrorRecord.put(error, new set<String>());
                        }
                    	mapErrorRecord.get(error).add(parentToUpdated[counter].Id);
                    }
              }
            counter++;
          }
    }
    
    global void finish(Database.BatchableContext BC){
        if(batchHasErrors) {
            try {               
                List<ApexLogger__c> apexloggerList= new List<ApexLogger__c>();
                for(String err:mapErrorRecord.keySet()) {
                    List<String> errorvalues= new List<String>(mapErrorRecord.get(err));
                    String RecordId=String.join(errorvalues,',').trim();
                    Integer size= mapErrorRecord.get(err).size();
                    String errormessage= 'Total records failed: '+size;
                    ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchUpdateRollUpFieldOnParent',ErrorDescription__c=err,LogRecordJson__c=RecordId,ErrorMessage__c=errormessage);
                    apexloggerList.add(apexLogRecord);
                }
                insert apexloggerList;   
            }
            catch (DMLException ex) {
                List<String> errorvalues= new List<String>(errorLog);
                String Errordescription=String.join(errorvalues,',').trim();
                ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchUpdateRollUpFieldOnParent',ErrorDescription__c=Errordescription);
                insert apexLogRecord;   
            }
        }
    }
    
}