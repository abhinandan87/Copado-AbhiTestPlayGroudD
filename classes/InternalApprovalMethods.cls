//-----------------------------
// @author: Jagadesh Kumar
// @date: 06 June 2018
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
//-----------------------------
public class InternalApprovalMethods {
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 06 June 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8542,SFDC1-6282: Populate the Contract Owner field of the new Internal Approval record with 
    // the Owner of the Contract on which it is created and send notification.
    // @return: NA
    //------------------------------
    public static void populateContractOwner(TriggerParameters tp) {
        Set<Id> contractIds = new Set<Id>();
        if(tp.tEvent==TriggerParameters.TriggerEvent.beforeInsert) {
            for (InternalApproval__c inApproval : (List<InternalApproval__c>)tp.newList) {
                contractIds.add(inApproval.Contract__c);
            }
            if(contractIds.size() > 0) {
                Map<Id,Contract> contractUserIdMap = new Map<Id,Contract>([SELECT Id,OwnerId FROM Contract 
                                                                           WHERE Id IN : contractIds]);
                for (InternalApproval__c inApproval : (List<InternalApproval__c>)tp.newList) {
                    if(contractUserIdMap.get(inApproval.Contract__c) != null) {
                    	inApproval.ContractOwner__c = contractUserIdMap.get(inApproval.Contract__c).OwnerId;    
                    }
                }
            }
        }
    }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 02 July 2021
    // @param: TriggerParameters tp
    // @description: SFDC-3222: Notification of the contract movement when internal approval is provided
    // @return: NA
    //------------------------------
    public static void notifyContractOwner(TriggerParameters tp) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> contractIds = new Set<Id>();
        Map<Id,InternalApproval__c> mapOldInternalApproval = (Map<Id,InternalApproval__c>)tp.oldMap;
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        List<FeedItem> FeedItemList = New List<FeedItem>();
        if(tp.tEvent==TriggerParameters.TriggerEvent.afterUpdate) {
            for (InternalApproval__c inApproval : (List<InternalApproval__c>)tp.newList) {
                contractIds.add(inApproval.Contract__c);
                contactIds.add(inApproval.Contact__c);
            }
            
			Map<Id,Contract> contractIdMap = new Map<Id,Contract>([SELECT Id,OwnerId FROM Contract WHERE Id IN : contractIds]);
            Map<Id,Contact> contactUserIdMap = new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE Id IN : contactIds]); 
            
            for (InternalApproval__c inApproval : (List<InternalApproval__c>)tp.newList) {
                if(inApproval.status__c != mapOldInternalApproval.get(inApproval.id).Status__c && (inApproval.status__c == 'Approved')) {   
                    
                    String message = 'Internal Approval has been provided by user '+ contactUserIdMap.get(inApproval.Contact__c).Name + ' ';
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(UtilityClass.getChatterFeedItemInput(inApproval.contract__c,new List<String>{contractIdMap.get(inApproval.Contract__c).OwnerId},message));
                    batchInputs.add(batchInput);
                } 
            }
            if(!batchInputs.isEmpty()) {
                if(!Test.isRunningTest()) {
                    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                }
            }
        }
    } 

}