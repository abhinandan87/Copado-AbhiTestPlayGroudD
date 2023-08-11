//-----------------------------
// @author: Priyanka Vyas
// @date: 22 June 2020
// @param: Trigger events
// @description: SFDC-3115 Class to hold Related Opportunity trigger methods
// @return: NA
//-----------------------------
public class RelatedOpportunityMethods {
    public static void updateActivityCreatedOnOppy(TriggerParameters tp) {
        Map<Id,RelatedOpportunity__c> mapNewRelatedOpportunity = (Map<Id,RelatedOpportunity__c>)tp.newMap;
        Set<ID> OpportunityIDSet=new Set<ID>();
        List<Opportunity> opportunityList=new List<Opportunity>();
        List<Opportunity> opportunityListToUpdate=new List<Opportunity>();
        try{
            for(RelatedOpportunity__c newRelatedOppy: mapNewRelatedOpportunity.values()) {
                if(newRelatedOppy.Opportunity__c!=null){
                    OpportunityIDSet.add(newRelatedOppy.Opportunity__c);
                }
            }
            if(OpportunityIDSet.size()>0){
                opportunityList=[Select id, ActivityCreated__c from Opportunity where id in:OpportunityIDSet];
            }
            if(opportunityList.size()>0){
                for(Opportunity opp:opportunityList){
                    if(opp.ActivityCreated__c==false){
                        opp.ActivityCreated__c=true;
                        opportunityListToUpdate.add(opp);
                    }
                }
            }
            if(opportunityListToUpdate!=null && !opportunityListToUpdate.isEmpty()) {
                update opportunityListToUpdate;
            }
        }
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            tp.newList[0].addError(System.Label.OpportunityGenericError+description);
            
        }
    }
    public static void changeActivityCreatedOnOppyOnUpdate(TriggerParameters tp) {
        Map<Id,RelatedOpportunity__c> mapNewRelatedOpportunity = (Map<Id,RelatedOpportunity__c>)tp.newMap;
        Map<Id,RelatedOpportunity__c> mapOldRelatedOpportunity = (Map<Id,RelatedOpportunity__c>)tp.oldMap;
        Set<ID> OpportunityIDSetOld=new Set<ID>();
        Set<ID> OpportunityIDSetNew=new Set<ID>();
        List<Opportunity> opportunityListToUpdate=new List<Opportunity>();
        try{
            for(RelatedOpportunity__c newRelatedOppy: mapNewRelatedOpportunity.values()) {
                RelatedOpportunity__c oldRelatedOppy = new RelatedOpportunity__c();
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                    oldRelatedOppy = mapOldRelatedOpportunity.get(newRelatedOppy.Id);
                    if(oldRelatedOppy.Opportunity__c!=null && oldRelatedOppy.Opportunity__c!=newRelatedOppy.Opportunity__c){
                        OpportunityIDSetOld.add(oldRelatedOppy.Opportunity__c);
                    }
                    if(newRelatedOppy.Opportunity__c!=null && oldRelatedOppy.Opportunity__c!=newRelatedOppy.Opportunity__c){
                        OpportunityIDSetNew.add(newRelatedOppy.Opportunity__c);
                    }
                }
            }
            opportunityListToUpdate = UtilityClass.setCreateActivityAsFalse(OpportunityIDSetOld);
            if(OpportunityIDSetNew.size()>0){
                for(Opportunity opp:[Select id,ActivityCreated__c from Opportunity where id in: OpportunityIDSetNew]){
                    if(opp.ActivityCreated__c==false){
                        opp.ActivityCreated__c=true;
                        opportunityListToUpdate.add(opp);
                    }
                }
            }
            if(opportunityListToUpdate.size()>0){
                update opportunityListToUpdate;
            }
        }
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            tp.newList[0].addError(System.Label.OpportunityGenericError+description);
        }
    }
    public static void changeActivityCreatedOnOppyOnDelete(TriggerParameters tp) {
        Map<Id,RelatedOpportunity__c> mapOldRelatedOpportunity = (Map<Id,RelatedOpportunity__c>)tp.oldMap;
        Set<ID> OpportunityIDSetOld=new Set<ID>();
        List<Opportunity> opportunityListToUpdate=new List<Opportunity>();
        try{    
            for(RelatedOpportunity__c oldRelatedOppy: mapOldRelatedOpportunity.values()){
                if(oldRelatedOppy.Opportunity__c!=null){
                    OpportunityIDSetOld.add(oldRelatedOppy.Opportunity__c);
                }
            }
            opportunityListToUpdate=UtilityClass.setCreateActivityAsFalse(OpportunityIDSetOld);
            if(opportunityListToUpdate.size()>0){
                update opportunityListToUpdate;
            }
        }
        catch(Exception ex) {
            String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
            tp.newList[0].addError(System.Label.OpportunityGenericError+description);
        }
    }
    //-----------------------------
    // @author: Anjali
    // @date: 17 Feb 2021
    // @param: Trigger events
    // @description: SFDC-3135 : Event Junction linking should not allow same Oppy to be linked again & again to same event
    // @return: NA
    //------------------------------
    public static void checkDuplicateRelatedOpportunityRec(TriggerParameters tp) {       
       	Set<Id> meetingNoteId = new Set<Id>();   
        Map<Id,List<Id>> oppyMeetingNote = new Map<Id,List<Id>>();
            for(RelatedOpportunity__c relatedOppy : (List<RelatedOpportunity__c>) tp.newList) {
                meetingNoteId.add(relatedOppy.MeetingNote__c);
            }
            if(meetingNoteId!=null) {
                for(RelatedOpportunity__c existingRec :[Select Opportunity__c,MeetingNote__c FROM RelatedOpportunity__c WHERE  MeetingNote__c IN:meetingNoteId]) {
                    if(oppyMeetingNote.containsKey(existingRec.MeetingNote__c)) {
                        List<Id> oppyId = oppyMeetingNote.get(existingRec.MeetingNote__c);
						oppyId.add(existingRec.Opportunity__c);
                    	oppyMeetingNote.put(existingRec.MeetingNote__c,oppyId) ;
                    }
                    else{
                        oppyMeetingNote.put(existingRec.MeetingNote__c, new List<Id> {existingRec.Opportunity__c});
                    }
                }             
            }
            if(oppyMeetingNote!=null) {
                for(RelatedOpportunity__c newRec : (List<RelatedOpportunity__c>) tp.newList) {
                    if(oppyMeetingNote.containsKey(newRec.MeetingNote__c)) {
                        List<Id> oppyId = oppyMeetingNote.get(newRec.MeetingNote__c);   
                        for(Id existingOppy : oppyId) {
                            if(newRec.Opportunity__c==existingOppy) {
                                newRec.addError(System.Label.DuplicateRelatedOpportunity );
                            }
                        }
                    }
                }  
            }            	                        
    }
}