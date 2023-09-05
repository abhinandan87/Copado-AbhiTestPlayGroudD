//-----------------------------
// @author : Vaishali Jain
// @date : 29th Sep 2021
// @description : common class for CampaignMember trigger
// @companyname : IHS Markit
//-----------------------------
public class CampaignMemberMethods {

      // @author: Vaishali Jain
      // @date: 29th Sep 2021
      // @description: SFDC1-8827 after a CampaignMember is created, check if the Type is Lead or Contact 
      //               then update the Campaign Name and Campaign Number on that CampaignMember record.
      // @param: TriggerParameters
      // @return: void
      //-----------------------------
      
    public static void updateCampaignNameCampaignNumber(TriggerParameters tp) {

            if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert || tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                System.debug('Inside===trigger');
                // retrieving all source cases for the new Leads
                Map<Id, Id> leadNewMap = new Map<Id, Id>();
                Map<Id, Id> contactNewMap = new Map<Id, Id>();
                Map<Id, CampaignMember> newMap = (Map<Id, CampaignMember>)tp.newMap;
                Map<Id, String> leadCampaignNameMap = new Map<Id, String>();
                Map<Id, String> leadCampaignNumberMap = new Map<Id, String>();
                Map<Id, String> contactCampaignNameMap = new Map<Id, String>();
                Map<Id, String> contactCampaignNumberMap = new Map<Id, String>();
                List<Lead> leadUpdateList = new List<Lead>();
                List<Contact> contactUpdateList = new List<Contact>();
                For (CampaignMember cm : [SELECT Id, CampaignId, LeadId, ContactId, Campaign.Name, Campaign.CampaignNumber__c FROM CampaignMember WHERE Id IN :newMap.keySet()]) {
                    If (cm.LeadId != null) {
                        if(cm.CampaignId != null) {
                            leadNewMap.put(cm.LeadId,cm.CampaignId);
                            leadCampaignNameMap.put(cm.LeadId, cm.Campaign.Name);
                            leadCampaignNumberMap.put(cm.LeadId, cm.Campaign.CampaignNumber__c);
                        }
                    }
                    if(cm.contactId != null) {
                        if(cm.CampaignId != null) {
                            contactNewMap.put(cm.contactId,cm.CampaignId);
                            contactCampaignNameMap.put(cm.contactId, cm.Campaign.Name);
                            contactCampaignNumberMap.put(cm.contactId, cm.Campaign.CampaignNumber__c);
                        }
                    }
                }
                //System.debug('---------- leadSourceCaseMap: ' + leadSourceCaseMap);
    
                if (leadNewMap.size() > 0) {
                
                    for(Id leadIdMapKey: leadNewMap.keySet()) {
                        Lead ld = new Lead(Id = leadIdMapKey);
                        if(leadCampaignNameMap.containsKey(leadIdMapKey)) {
                            ld.Name__c = leadCampaignNameMap.get(leadIdMapKey);
                        }
                        if(leadCampaignNumberMap.containsKey(leadIdMapKey)) {
                            ld.CampaignNumber__c = leadCampaignNumberMap.get(leadIdMapKey);
                        }
                        leadUpdateList.add(ld);
                    }                                 
                }
                
                if (contactNewMap.size() > 0) {
                
                    for(Id contactIdMapKey: contactNewMap.keySet()) {
                        Contact con = new Contact(Id = contactIdMapKey);
                        if(contactCampaignNameMap.containsKey(contactIdMapKey)) {
                            con.Name__c = contactCampaignNameMap.get(contactIdMapKey);
                        }
                        if(contactCampaignNumberMap.containsKey(contactIdMapKey)) {
                            con.CampaignNumber__c = contactCampaignNumberMap.get(contactIdMapKey);
                        }
                        contactUpdateList.add(con);
                    }                                 
                }
                if(leadUpdateList != null && leadUpdateList.size()>0) {
                    update leadUpdateList;
                }
            
                if(contactUpdateList != null && contactUpdateList.size()>0) {
                    update contactUpdateList;
                }
            }   
            

    }
}