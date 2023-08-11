//-----------------------------
// @author: Harshit Singhal
// @date: 18 Oct 2019
// @param: NA
// @description: Apex Data class to fetch important data params needed to run Order Form Docgen Templates. 
// 				 SFDC-2007: Fetches Product Specific Terms and Condition Ids based on contract line items.
// @company: IHS Markit
// @return: None
//------------------------------
global class OrderFormData implements Loop.IApexDataSource {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Oct 2019
    // @param: void
    // @description: Method to declare objects for Drawloop
    // @company: IHS Markit
    // @return: Set<String> Set of objects setup for Drawloop
    //------------------------------
    public Set<string> getGlobalDescribe() {
        return new Set<String>{'TermsAndConditions'};
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Oct 2019
    // @param: List <string >objNames list of objects to be defined
    // @description: Method to create definition of 'TermsAndConditions' object for Drawloop declared above
    // @company: IHS Markit
    // @return: List <Loop.ExternalData.DataObject > a list of objects defined using loop api
    //------------------------------
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
        List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();
        for (string objName : objNames) {
            List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();
            if(objName == 'TermsAndConditions') {
                outputFields.add(new Loop.ExternalData.FieldInfo('TnCIDs', Schema.DisplayType.String));
            }
            output.add(new Loop.ExternalData.DataObject(objName, outputFields));
        }        
        return output;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Oct 2019
    // @param: String Objectname object name for which children object are to be fetched
    // @description: Method to establish parent-child relationship
    // @company: IHS Markit
    // @return: Set<String> return a list of children objects related to an object defined via Loop API
    //------------------------------
    public Set<string> getChildRelationships(string objectName) {
        return null;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Oct 2019
    // @param: Loop.ExternalData.QueryRequestInfo requestInfo loop request param
    // @description: Method to query data from Salesforce and add it to custom drawloop objects TermsAndConditions
    // @company: IHS Markit
    // @return: Loop.ExternalData.QueryResultSet resultset contains all the data required to establish relationship
    //------------------------------
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();
        Loop.ExternalData.QueryResult qrTnCs = new Loop.ExternalData.QueryResult('TermsAndConditions', new List<string> { 'TnCIDs' });
        String idStringEmpty = '(\'\')';
        String allTnCIDsStr = '';
        
        if(string.valueOf(requestInfo.RecordId).startswith(Schema.sObjectType.Contract.keyprefix)) {
            Set<Id> prodIdSet = new Set<Id>();
            for(ContractLineItem__c cliObj: [SELECT AssociatedProduct__c FROM ContractLineItem__c WHERE Contract__c=:requestInfo.RecordId]) {
                prodIdSet.add(cliObj.AssociatedProduct__c);
            }
            System.debug('prodIdSet size='+prodIdSet.size());
            System.debug('prodIdSet='+prodIdSet);            
            if(prodIdSet.size() > 0) {
                Set<Id> tncIdSet = new Set<Id>();
                for(ProductswithTermsConditions__c objPTC: [SELECT TermsConditions__c FROM ProductswithTermsConditions__c WHERE Product__c IN :prodIdSet AND TermsConditions__c!=null]) {
                    tncIdSet.add(objPTC.TermsConditions__c);
                    //qrTnCs.rows.add(new List<String> { String.valueOf() });
                }
                System.debug('tncIdSet size='+tncIdSet.size());
                System.debug('tncIdSet='+tncIdSet);
                if(tncIdSet.size() > 0) {
                    List<String> tncIdList = new List<String>();                    
                    for(Id thisId : tncIdSet) {
                        tncIdList.add('\''+thisId+'\'');
                    }
                    if(tncIdList.size()>0) {
                        allTnCIDsStr = '(' + String.join(tncIdList,',') + ')';
                    }
                    System.debug('allTnCIDsStr='+allTnCIDsStr);                    
                }
                else {
                    allTnCIDsStr = idStringEmpty;
                }                
            }
        }
        qrTnCs.rows.add(new List<String> { String.valueOf(allTnCIDsStr) });
        System.debug('qrTnCs rows size='+qrTnCs.rows.size());
        System.debug('qrTnCs='+qrTnCs);
        //Setup Apex Results
        for (string objectName : requestInfo.GetObjectNames()) {
            System.debug('objectName='+objectName);
            if (objectName == 'TermsAndConditions') {
                results.add(qrTnCs);
            }
        }
        return results;
    }
}