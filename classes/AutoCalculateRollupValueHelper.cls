//-----------------------------
// @author: Neelam Agrawal
// @date: 10 Feb 2022
// @description:  SFDC-5361 Helper class for BatchUpdateRollUpFieldOnParent, can be called from trigger as well 
// @lastmodifiedby: Neelam Agrawal
// @description: Added check specific to fields, now this class can be called for specific fields
// ------------------------------
global class AutoCalculateRollupValueHelper {
    
    public Static Boolean parentUpdated=false;
    public Static Map<String,String> fieldMapping= new Map<String,String>();
    
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 10 Feb 2022
    // @param: 
    // 			1) List<sObject>- Parent Object list for which rollupvalue will be calculated
    // 			2) List<sObject>- Child Object list contains data to be used for calculation
    // 			3) String relationshipField- Relationship field that bind child Object to parent Object
    // 			4) set<String> - Rollupfield which will contain value if calling for specific fields
    // @description:  SFDC-5361 This method is main method of BatchUpdateRollUpFieldOnParent
    // 			It will calculate the rollup field value for parent object
    // @return: List<sObject> - It will contain the updated parentlist if value differs from old list
    // @lastmodifiedby: Digvijay
    // @date: 23 May 2022
    // @description: SFDC-5802 Added Logic to populate default CI divison on Opportunity.
    
    global static List<sObject> rollupProductInfoToParent(List<sObject> parentObjList,List<sObject> childItemList,String relationshipField,set<String> rollupfields) {
        
        String parentObjName=String.valueOf(parentObjList.getSObjectType());
        String childobjName=String.valueOf(childItemList.getSObjectType());
        List<sObject> updatedParentList= new List<sObject>();
		
        //SFDC-5802-Exception for Opportunity CI Division Field
          Map<String,sObject> mapopptyIdwithnoLineItems=new Map<String,sObject>();
        // Storing value in fieldmapping which will be used by other methods
        getfieldMapping(parentObjName,childobjName,rollupfields);
        
        // Creating Map of ListOfChildObject as per the relationshipField provided
        Map<Id, List<sObject>> mapParentIdChildList = new Map<Id, List<sObject>>();
        for (sObject childItem :childItemList)
        {                
            List<sObject> childItems = mapParentIdChildList.get((String)childItem.get(relationshipField));
            if (childItems == null) {
                childItems = new List<sObject>();
            }
            childItems.add(childItem);
            mapParentIdChildList.put(((String)childItem.get(relationshipField)), childItems);
        }
        
        //Iterating through each parent record
        for (sObject oppy: parentObjList) {
            List<sObject> childItems=mapParentIdChildList.get(oppy.Id);
            parentUpdated=false;
            if(childItems!=Null){
                map<String, set<String>> mapFieldValues = new map<String, set<String>>();
                for(sObject childObj:childItems) {
                    //concatinating String value of child object and storing in Map
                    mapFieldValues= updateRollupfield(childObj,mapFieldValues);
                }
                System.debug('mapFieldValues' + mapFieldValues);
                //Updating parent object value with new rollup field
                oppy= updateParentObj(oppy,mapFieldValues);
            }
            else{
               
                //SFDC-5802-Exception for Opportunity CI Division Field
                if(oppy.getSObjectType()==Schema.Opportunity.getSObjectType() && oppy.get('Referral_ID__c')!=Null) {
                    mapopptyIdwithnoLineItems.put(String.valueOf(oppy.get('Id')),oppy);
                }else {
                      //Updating parent object value with blank rollup value
                      oppy= blankUpdateParentObj(oppy);
                }
            }
            if(parentUpdated) {
                updatedParentList.add(oppy);
            }
        }
        
        //SFDC-5802-Exception for Opportunity CI Division Field
        if(!mapopptyIdwithnoLineItems.isEmpty()) {
            updateCIDivisionValueFromLead(mapopptyIdwithnoLineItems,updatedParentList);
        }
        
        return updatedParentList;
    }  
    
     //-----------------------------
    // @author: Digvijay Singh
    // @date: 20/05/2022
    // @description: SFDC-5802 Logic to fetch the default Division Value from Lead associated to converted opportunity.
    // @param: 
    //          1) List<String>- listofLineItemsId
       public static void updateCIDivisionValueFromLead(Map<String,sObject> mapopptyIdwithnoLineItems,List<sObject> updatedParentList) {  
           Map<String ,sObject>  mapOppToBeUpdated=new Map<String ,sObject>();
           if(mapopptyIdwithnoLineItems!=null && !mapopptyIdwithnoLineItems.IsEmpty()) {
               List<Lead> listLead=[Select Id ,ConvertedOpportunityId ,Referral_ID__c  , Division_Sent_To__c from Lead where ConvertedOpportunityId IN: mapopptyIdwithnoLineItems.keySet()];
                for(Lead lobj:listLead ) {
                    if(mapopptyIdwithnoLineItems.ContainsKey(lobj.ConvertedOpportunityId )) {
                        Opportunity opp=(Opportunity)mapopptyIdwithnoLineItems.get(lobj.ConvertedOpportunityId);    
                        if(opp.Referral_ID__c==lobj.Referral_ID__c) {
                            opp.CIDivision__c=lobj.Division_Sent_To__c ;
                            mapOppToBeUpdated.put(lobj.ConvertedOpportunityId,opp);
                        }
                       
                    }
              }  
           }  
           
           if(!mapOppToBeUpdated.IsEmpty() && updatedParentList!=Null) {
               updatedParentList.addAll(mapOppToBeUpdated.values());
           }         
        }
    
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 10 Feb 2022
    // @description:  SFDC-5361 Property to hold all active criteria based mappings and fetch them from CustomRollUpConfiguration__c custom setting
    // @lastmodifiedby: Neelam Agrawal
    // @date: 28-Feb-2022
    // @param: 
    // 			1) String- ParentObjectName and childObjectName
    // 			2) set<String> - set of Rollupfield
    // @description: SFDC 5361 This method will hold active criteria based mappings based on rollupfields value and fetch them from CustomRollUpConfiguration__c custom setting 
    // @lastmodified date: 10 Mar 2022
    // @lastmodifiedby: Neelam Agrawal
    // @description: SFDC-5587- Added check for fieldmapping
    // @return: None
    
    public static void getfieldMapping( String parentObjectName,String childObjectName,set<String> rollupfields) {               
        List<CustomRollUpConfiguration__c> CustomRollUpConfigurationCSList = new  List<CustomRollUpConfiguration__c> ();
        if(!fieldMapping.isEmpty()) {
            fieldMapping.clear();
        }
        if(rollupfields!= NULL && !rollupfields.isEmpty()) {
            CustomRollUpConfigurationCSList = [Select id,Active__c, ParentField__c, ParentObject__c, ChildField__c, ChildObject__c from CustomRollUpConfiguration__c 
                                               where ParentObject__c=:parentObjectName AND ChildObject__c=:childObjectName AND ParentField__c IN:rollupfields AND Active__c=true ];
        }
        else {
            CustomRollUpConfigurationCSList = [Select id,Active__c, ParentField__c, ParentObject__c, ChildField__c, ChildObject__c from CustomRollUpConfiguration__c 
                                               where ParentObject__c=:parentObjectName AND ChildObject__c=:childObjectName  AND Active__c=true ];
        }
        for(CustomRollUpConfiguration__c fieldMapObj:CustomRollUpConfigurationCSList) {
            if(  fieldMapObj.ChildField__c!= null && fieldMapObj.ParentField__c!=null ) {
                fieldMapping.put(fieldMapObj.ChildField__c,fieldMapObj.ParentField__c);
            }
        }       
    }

    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: 
    // 			1) sObject- childObject record
    // 			2) map<String, set<String>> - Map of mappingfield and their values stored in set of string
    // @description: SFDC 5361 This method will process each child record and concatinate field values into mapFieldValues 
    // @return: map<String, set<String>> - Updated map after each iteration
    
    public static map<String, set<String>> updateRollupfield(sObject Obj,map<String, set<String>> mapFieldValues ){
        for(String field:fieldMapping.keySet()){
            String fieldvalue=getFieldValue(Obj,field);
            if(!mapFieldValues.containsKey(field)){
                mapFieldValues.put(field,new set<String>());
            }
            if(!String.isBlank(fieldvalue)) {
                mapFieldValues.get(field).add(fieldvalue);
            }
            
        }
        return  mapFieldValues;   
    }
    
    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: 
    // 			1) sObject- childObject record
    // 			2) String - child field name
    // @description: SFDC 5361 This method will retrieve field value for related child record
    // @return: String - child record field value
    //
    public static string getFieldValue(sObject obj, String field) {
        if(field.contains('.')){
            string[] fieldParts = field.split('\\.');
            for(Integer i=0;i<fieldParts.size()-1;i++){
                if(obj!=null){
                    obj=obj.getSObject(fieldParts[i]);
                }
                else
                    break;
            }
            if(obj==null)
                return '';
            else{
                String fieldname=fieldParts[fieldParts.size()-1];
                return string.valueOf(obj.get(fieldname));
            }
        }
        else{
            return string.valueOf(obj.get(field));
        }        
    } 
    
    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: 
    // 			1) sObject- Parent Object record
    // 			2) map<String, set<String>> - Map of mappingfield and their values stored in set of string
    // @description: SFDC 5361 This method will update parent record with calculated rollup value
    // @return: Sobject - updated parentObject record
    
    public static Sobject updateParentObj(Sobject parentObj,map<String, set<String>> mapFieldValues){
        parentUpdated=false;
        for(String field:fieldMapping.keySet()){
            set<String> values= mapFieldValues.get(field);
            if(values.size()>0){
                List<String> val1= new List<String>(values);
                val1.sort();
                String fieldvalue=String.join(val1,',').trim();
                if(parentObj.get(fieldMapping.get(field))!=fieldvalue){
                    parentUpdated=true;                    
                    String fieldName=fieldMapping.get(field);
                    parentObj.put(fieldName.trim(),fieldvalue);
                }
                
            }
            
        } 
        return parentObj;
    }
    
    // @author: Neelam Agrawal
    // @date: 10-Feb-2022
    // @param: 
    // 			1) sObject- Parent Object record
    // @description: SFDC 5361 This method will update parent with blank value if there are no child record
    // @return: Sobject - updated parentObject record
    public static Sobject blankUpdateParentObj(Sobject parentObj){
        parentUpdated=false;      
        for(String field:fieldMapping.keySet()){
            if(parentObj.get(fieldMapping.get(field))!=NULL){
                String fieldName=fieldMapping.get(field);
                parentObj.put(fieldName.trim(),'');
                parentUpdated=true;
            }                                       
        }
        return parentObj;
    } 
    
}