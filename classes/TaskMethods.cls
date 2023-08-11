//-----------------------------
// @author: Uttam Arya
// @date: 29 Aug 2017
// @param: NA
// @description: SFDC1-2243 Class to hold Task trigger methods 
// @return: NA
//-----------------------------
public class TaskMethods {

    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 Aug 2017
    // @param: TriggerParameters tp
    // @description: SFDC1-2243 Whenever an Task is added to an opportunity,  
    //                  MISActivityAdded field is auto populated with the current timestamp. 
    //                  This is used for MIS pipeline reporting.
    // @return: None
    // @Update by : Mohit Modi
    // @Updated date : 17 Jan 2018
    // @updated description : Updated list to Map for removing the Duplicate Error in TestClass
    // 
    // @Update by : Harshit Singhal
    // @Updated date : 15 Jun 2018
    // @Updated description : SFDC1-8540 Convert Process Builder flow "Activity Created On Opportunity" on Task object created in SFDC1-547(When the Activity gets created on Opportunity Checkbox will be Checked) to a trigger
    // 						  Added code to set Activity Created field=true on related Opportunity
    // @Update by : Vishnu Vardhan
    // @Updated date : 06 Dec 2018
    // @Updated description : SFDC1-10613 Catching and throwing correct error messages to the UI
    // @Update by : Paras Dhingra
    // @Updated date : 06 Dec 2020
    // @Updated description : SFDC-2594 adding exemption to prevent validations from firing
    //------------------------------
    public static void populateTaskAddedInOpportunityWhenTaskIsInserted(TriggerParameters tp) {
        try {
            //Set of Opportunity that needs to be updated    
            Map<id,Opportunity > OpportunityToUpdate = new Map<id,Opportunity>(); 
            
            for(Task Task: (List <Task>) tp.newList) {
                if(Task.WhatId != null && String.valueOf(Task.WhatId).startsWith('006')) {
                    OpportunityToUpdate.put(Task.WhatId,new Opportunity(Id = Task.WhatId, MISActivityAdded__c = Datetime.now(), ActivityCreated__c=true));                
                }
            }        
            //update if list has any records
            if(OpportunityToUpdate != null && OpportunityToUpdate.size() > 0) {
                GlobalConstants.hasBeenValidatedOnce = true;
                update OpportunityToUpdate.values();
                GlobalConstants.hasBeenValidatedOnce = false;
            } 
        } catch (Exception e) {
            if(e.getMessage().contains('VALIDATION_EXCEPTION')) {
                ((List<Task>) tp.newList).get(0).addError(e.getMessage().substringBetween('VALIDATION_EXCEPTION,',':'));  
            } else {
                ((List<Task>) tp.newList).get(0).addError(e.getMessage());
            }
        }
    }
    
    //-----------------------------
    // @author: Mohit Modi
    // @date: 17 Jan 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-5027 Whenever an Task is deleted to an opportunity, ActivityCreated__c field should be set to FALSE
    //                   if this is the last task on the Opportunity, else don't update on Opportunity.
    //
    // @return: None
    // @Modified by: Priyanka Vyas
    // @date: 25 Aug 2020
    // @param: TriggerParameters tp
    // @description: SFDC-3133 Change ActivityCreated__c on Opportunity when task is deleted.
    //------------------------------
    public static void updateOpportunityActivityCheckOnTaskDeletion(TriggerParameters tp) {
        
        /*set<id> setDeletedTaskOppId = new set<id>();
        set<id> setRemainingTaskOppId = new set<id>();
        list<Opportunity> listopptoUpdate = new List<Opportunity>();
        
        for(Task Task: (List <Task>) tp.oldList) {
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete
             && Task.WhatId != null && String.valueOf(Task.WhatId).startsWith('006')) {
                 setDeletedTaskOppId.add(Task.WhatId);
            }
        }
        
        if(!setDeletedTaskOppId.isEmpty()) {
            // Query for remaining tasks on the Opportunity
            for(Task remainingTask : [select id,WhatId from Task where WhatId in :setDeletedTaskOppId]) {
                setRemainingTaskOppId.add(remainingTask.WhatId );
            }
            // Removing the Task's opportunity to get the list of opportunity where another tasks are remaining.
            if(!setRemainingTaskOppId.isEmpty()) {
                setDeletedTaskOppId.removeAll(setRemainingTaskOppId);
            }
            // Checking if any Opportunity available for whcih no tasks are left.If no task left, update the Opportunity.
            if(!setDeletedTaskOppId.isEmpty()) {
                for(ID oppId:setDeletedTaskOppId) {
                    Opportunity oppToUpdate = new Opportunity(id = oppId );
                    oppToUpdate.ActivityCreated__c = false;
                    listopptoUpdate.add(oppToUpdate);
                }
            }
            
            if(!listopptoUpdate.isEmpty()) {
                update listopptoUpdate;
            }
        }*/
    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 25 Aug 2020
    // @param: TriggerParameters tp
    // @description: SFDC-3133 Change ActivityCreated__c on Opportunity when Task is updated/deleted.
    // @return: None
    //------------------------------   
    public static void changeActivityCreatedCheckboxOnOpportunity(TriggerParameters tp) {
    	Set<ID> OpportunityIDSetOld=new Set<ID>();
        Set<ID> OpportunityIDSetNew=new Set<ID>();
        List<Opportunity> opportunityListToUpdate=new List<Opportunity>();
        Map<Id, Opportunity> opportunityNamesMap;
        try{
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                for(Task newTask: (List<Task>)tp.newMap.values()) {            
                    Task oldTask = new Task();         
                    oldTask = (Task)tp.oldMap.get(newTask.Id);
                    if(oldTask.WhatId!=null && String.valueOf(oldTask.WhatId).startsWith('006') && oldTask.WhatId!=newTask.WhatId) {
                            OpportunityIDSetOld.add(oldTask.WhatId);
                    }
                    if(newTask.WhatId!=null && String.valueOf(newTask.WhatId).startsWith('006') && oldTask.WhatId!=newTask.WhatId) {
                        OpportunityIDSetNew.add(newTask.WhatId);
                    }
                }
            }
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                for(Task oldTask: (List<Task>)tp.oldMap.values()) {
                    if(oldTask.WhatId!=null && String.valueOf(oldTask.WhatId).startsWith('006')) {
                        OpportunityIDSetOld.add(oldTask.WhatId);
                    }
                }
            }
            if(OpportunityIDSetOld!=null && !OpportunityIDSetOld.isEmpty() && OpportunityIDSetOld.size()>0) {
                opportunityListToUpdate = UtilityClass.setCreateActivityAsFalse(OpportunityIDSetOld);
            }
            if(OpportunityIDSetNew!=null && !OpportunityIDSetNew.isEmpty() && OpportunityIDSetNew.size()>0) {
                for(Opportunity opp:[Select id,ActivityCreated__c from Opportunity where id in: OpportunityIDSetNew]) {
                    if(opp.ActivityCreated__c==false) {
                        opp.ActivityCreated__c=true;
                        opportunityListToUpdate.add(opp);
                    }
                }
            }
            if(opportunityListToUpdate.size()>0) {
                update opportunityListToUpdate;
            }
        }
        catch(Exception ex){
            //Mohit : updated to remove SOQL from loop.
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,') && ex.getMessage().contains(Label.ActivityRequiredForStage5NewBusiness) && opportunityListToUpdate.size()>0) {
                    opportunityNamesMap = new Map<Id, Opportunity>([Select name from Opportunity where id in:opportunityListToUpdate]);
                }
                for(Task oldTask: (List<Task>)tp.oldList) {
                    if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                        //ActivityRequiredForStage5NewBusiness validation rule on Opportunity handling.
                        if(ex.getMessage().contains(Label.ActivityRequiredForStage5NewBusiness)) {
                            String errorMessage=ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1];
                            String opportunityIdInErrorMsg = ex.getMessage().split('; first error:')[0].split('with id ')[1];
                            if(opportunityNamesMap!=null && !opportunityNamesMap.isEmpty() && opportunityIdInErrorMsg.startsWith('006')) {
                            	oldTask.addError('"'+opportunityNamesMap.get(opportunityIdInErrorMsg).name+'": '+errorMessage);
                            }
                            else {
                                oldTask.addError(ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1]);
                            }
                    	}
                        else {
                            oldTask.addError(ex.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1]);
                        }
                    }
                    else {
                        oldTask.addError(ex.getMessage());
                    }
                }
            }
        }
    }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 07 Jun 2021
    // @param: TriggerParameters tp
    // @description: SFDC-3979 Notes / Comments Added Checkbox on Tasks.
    // @return: None
    //------------------------------
    public static void notesCheckbox(TriggerParameters tp) {
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate || tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
            
            for(Task newTask: (List<Task>)tp.newList) {
                newTask.CommentsPreview__c = newTask.Description==null?'': newTask.Description.left(255);
            }
        }
    }
}