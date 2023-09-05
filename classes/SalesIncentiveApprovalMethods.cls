//-----------------------------
// @author: Sushma Yadav
// @date: 10 Feb 2020
// @param: NA
// @description: Class to hold Sales Incentive Approval trigger methods 
// @date: 27 Feb 2020: SFDC-2680 Req update so achieving the result via custom button URL hacking
// @return: NA
//-----------------------------

public class SalesIncentiveApprovalMethods {
/*	public static void populateIncentiveOwnerLookupSalesIncentive(TriggerParameters tp) {
		if(tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
			for(SalesIncentiveApproval__c SIA: (List <SalesIncentiveApproval__c>) tp.newList) {
            SIA.IncentiveOwner__c = UserInfo.getUserId();
			}      
		}	
	}*/

    //-----------------------------
    // @author: Dev Aggarwal
    // @date: 9 March 2020
    // @param: TriggerParameters
    // @description: SFDC-2681 - Automatically Submit record for approval.
    // @US-5103087 : removed CommissionStatus__c check so that the approval is triggered in afterUpdate.
    public static void submitForApproval(TriggerParameters tp) {
        system.debug('Method called');
        Set<Id> checkedRecords = new Set<Id>();
        Set<Id> pendingRecords = new Set<Id>();
        List<Approval.ProcessSubmitRequest> approvalList = new list<Approval.ProcessSubmitRequest>();
        Map<Id, SalesIncentiveApproval__c> oldMapSIA = (Map<Id, SalesIncentiveApproval__c>) tp.oldMap;
        Map<Id, SalesIncentiveApproval__c> newMapSIA = (Map<Id, SalesIncentiveApproval__c>) tp.newMap;
        for(SalesIncentiveApproval__c sia : (List<SalesIncentiveApproval__c>) tp.newList) {
            SalesIncentiveApproval__c oldSIA = new SalesIncentiveApproval__c();
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                oldSIA = oldMapSIA.get(sia.id);
            }
                if(/*sia.CommissionStatus__c != oldSIA.CommissionStatus__c &&*/ sia.CommissionStatus__c == 'Open' && sia.Ready_for_Submission__c != oldSIA.Ready_for_Submission__c && sia.Ready_for_Submission__c == true) {
                    checkedRecords.add(sia.Id);
                }
        }
        if(checkedRecords!= null && checkedRecords.size() > 0) {
        //Check if the record is already in Approval Process
        	for(ProcessInstance existingApprovals : [SELECT Id, TargetObjectId
                                            FROM ProcessInstance 
                                            WHERE TargetObjectId IN :checkedRecords and Status='Pending']) {
                pendingRecords.add(existingApprovals.TargetObjectId);                                
         	}
        
            for(Id IdSia : checkedRecords) {
                if(!pendingRecords.contains(IdSia)) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setObjectId(IdSia);
                    req.setComments(System.label.SalesIncentiveApprovalComment);
                    req.setSubmitterId(newMapSIA.get(IdSIA).IncentiveOwner__c); 
                    approvalList.add(req);
                }
            }
            if(approvalList != null && approvalList.size() > 0) {
                Approval.process(approvalList);
            }
        }
    }
    
    
    
    
}