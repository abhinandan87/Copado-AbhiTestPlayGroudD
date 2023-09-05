//-----------------------------
// @author: Anjani Shukla
// @date: 29 Sept 2017
// 
// @description: Class to hold trigger methods. This class is used in WRF POLK. 
// 
//-----------------------------
public class PLCJobMethods {
    public static Boolean isFirstTime = true;
        //-----------------------------
        // @author: Anjani Shukla
        // @date: 29 Sept 2017
        // @param: TriggerParameters tp
        // @description: Update Start Date or Negotiated Date if differs.
        // @return: None
        //------------------------------
        public static void updatePLCTaskStartNegotiatedDate(TriggerParameters tp) {
        List<JobTask__c> allChildrenToUpdate = new List<JobTask__c>();
        // for the updated parents
        //query all job tasks with parent fields (PLCJob__r.Field_Name__c)
        //Loop through job tasks individually for ALL plcs in the batch
        //  recreate the inner Job Task loop basically
        
        List<JobTask__c> children = [SELECT Id, PLCJob__r.Name, StartDate__c, DueDate__c, JobStatusOverride__c,
                                    Status__c, PLCJob__r.StartDate__c, PLCJob__r.NegotiatedDate__c,
                                    PLCJob__r.JobStatusOverride__c 
                                    from JobTask__c 
                                    where PLCJob__c IN :Trigger.new];
        //System.debug('children count = ' + children.size());
        
        //loop through all children and determine which need to be updated
        for(JobTask__c thischild: children )
        {
            //if the start date or negotiated date is different from a PLC, it will automatically
            //populate the child Job Task with the new start and due dates.  These can be edited on 
            //the job task later if need be
            if(  (thischild.StartDate__c !=  thischild.PLCJob__r.StartDate__c || 
            thischild.DueDate__c !=  thischild.PLCJob__r.NegotiatedDate__c ||
            thischild.JobStatusOverride__c != thischild.PLCJob__r.JobStatusOverride__c )
            && thischild.Status__c != 'Complete')
            {
                //assign the fields that are different to the parent field
                thischild.StartDate__c =  thischild.PLCJob__r.StartDate__c;
                thischild.DueDate__c =  thischild.PLCJob__r.NegotiatedDate__c;
                thischild.JobStatusOverride__c =  thischild.PLCJob__r.JobStatusOverride__c;
                
                //add to the list of children to update
                allChildrenToUpdate.add(thischild);
            }
        }
        
        update allChildrenToUpdate;
        }
        
        
        //-----------------------------
        // @author: Anjani Shukla
        // @date: 29 Sept 2017
        // @param: TriggerParameters tp
        // @description: Update Start Date or Negotiated Date if differs.
        // @return: None
        //------------------------------
        public static void createDeliveryTaskOnJobInsert(TriggerParameters tp) {
            
            List<JobTask__c> newTasks = new List<JobTask__c>();
            List<PLCJob__c > newPLCRecords = (List<PLCJob__c >)tp.newlist;

            //For each position processed by the trigger, add a new  
            //interviewer record for the specified hiring manager.  
            //Note that Trigger.New is a list of all the new positions  
            //that are being created.  
            
            for (PLCJob__c newJob: newPLCRecords){
                 newTasks.add(new JobTask__c(        
                        TaskName__c = 'Deliverable',
                        PLCJob__c = newJob.id,
                        EstimatedHours__c = newJob.TotalJobEstimate__c,
                        Status__c = 'Open',
                        Assignedto__c = newJob.OwnerId));
            }
            insert newTasks;
          }
    // @author: Madhusudhan karna
	// @date: 06 May 2021
	// @param: TriggerParameters tp
	// @description: Create the Task records, when CreateSetupMeetingTask, CreateDocumentationTask and CreatePeerReviewTask fields are checked
	// @return: None
	//------------------------------
	public static void CreateTasks(TriggerParameters tp) {
        Map<Id,PLCJob__c> mapNewPLCJob= (Map<Id,PLCJob__c>)tp.newMap;
        Map<Id,PLCJob__c> mapOldPLCJob= (Map<Id,PLCJob__c>)tp.oldMap;
        List<PLCJob__c> plcJobList = new List<PLCJob__c>();
        List<JobTask__c> insertJobTaskList = new List<JobTask__c>(); 
        JobTask__c newJobTask;
        Set<Id> plcJobIds = new Set<Id>();
        for(PLCJob__c plcJob: mapNewPLCJob.values()) { 
            if (plcJob.CreateSetupMeetingTask__c == true) {
                newJobTask=new JobTask__c();
                newJobTask=CreatePLCTask(plcJob, 'Setup Meeting');
                insertJobTaskList.add(newJobTask);
                plcJobIds.add(plcJob.Id);
            }
            if (plcJob.CreateDocumentationTask__c == true) {
                newJobTask=new JobTask__c();
                newJobTask=CreatePLCTask(plcJob, 'Documentation');
                insertJobTaskList.add(newJobTask);
                plcJobIds.add(plcJob.Id);
            }
            if (plcJob.CreatePeerReviewTask__c == true) {
                newJobTask=new JobTask__c();
                newJobTask=CreatePLCTask(plcJob, 'Peer Review');
                insertJobTaskList.add(newJobTask);
                plcJobIds.add(plcJob.Id);
            }
        }
        system.debug('plcJobList--------- '+insertJobTaskList);
        if(insertJobTaskList.size()>0){
            insert insertJobTaskList;
        }
        List<plcjob__c> updatePLCJobs=new List<plcjob__c>();
        plcjob__c plcJob;
        for(Id plcId : plcJobIds){
            plcJob=new plcjob__c();
            plcJob.Id=plcId;
            plcJob.CreateSetupMeetingTask__c=false;
            plcJob.CreateDocumentationTask__c=false;
            plcJob.CreatePeerReviewTask__c=false;
            updatePLCJobs.add(plcJob);
        }
        if(updatePLCJobs.size()>0){
            update updatePLCJobs;
        }
    }
    // @author: Madhusudhan karna
	// @date: 06 May 2021
	// @param: TriggerParameters tp
	// @description: Create the Task records, when CreateSetupMeetingTask, CreateDocumentationTask and CreatePeerReviewTask fields are checked
	// @return: None
	//------------------------------
    public static JobTask__c CreatePLCTask(PLCJob__c plc, string jobTitle) {
        JobTask__c newTask;
        newTask = new JobTask__c();
        newTask.TaskName__c = jobTitle;
        newTask.PLCJob__c = plc.id;
        newTask.Status__c = 'Open';
        newTask.AssignedTo__c = plc.OwnerId;
        return newTask;
    }

        // @author: Uday Bikkumalla
	// @date: 28 May 2021
	// @param: TriggerParameters tp
	// @description: Close Related Job Task when PLC Job is Completed.
	// @return: None
	//------------------------------    

    public static void closeChildPLCJobTasks(TriggerParameters tp) {
        List<Id> listJobIdsClosed = new List<Id>();
        List<JobTask__c> jobTasksToBeClosed = new List<JobTask__c>();
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            Map<Id, PLCJob__C> newMapJobs = (Map<Id,PLCJob__C>)tp.newMap;
            Map<Id, PLCJob__C> oldMapJobs = (Map<Id,PLCJob__C>)tp.oldMap;

            for(Id id : newMapJobs.keySet()) {
                if(oldMapJobs.get(id) != null && newMapJobs.get(id) != null 
                    && oldMapJobs.get(id).JobCompletedDelivered__c != newMapJobs.get(id).JobCompletedDelivered__c && newMapJobs.get(id).JobCompletedDelivered__c) {
                        listJobIdsClosed.add(id);
                    }
            }

           jobTasksToBeClosed = getOpenJobTasksFromPLCJobs(listJobIdsClosed);
           closeJobTasks(jobTasksToBeClosed);
        }
    }
  
    // @author: Uday Bikkumalla
	// @date: 28 May 2021
	// @param: List of PLC Job Ids
	// @description: Get List of JobTasks from PLC Job Ids
	// @return: List<JobTask__c>
	//------------------------------    
    private static List<JobTask__c> getOpenJobTasksFromPLCJobs(List<Id> listIds) {
        List<JobTask__c> listJobTasks = new List<JobTask__c> ();
        if(listIds.size() == 0) {
            return listJobTasks;
        }

        listJobTasks =  [SELECT Id, Status__c FROM JobTask__c WHERE Status__c <> 'Complete' AND PLCJob__c IN: listIds];
        return listJobTasks;
    }

        // @author: Uday Bikkumalla
	// @date: 28 May 2021
	// @param: List of PLC Job Ids
	// @description: Get List of JobTasks from PLC Job Ids
	// @return: List<JobTask__c>
	//------------------------------    
    private static List<JobTask__c> closeJobTasks(List<JobTask__c> listJobTasks) {
        if(listJobTasks.size() == 0) {
            return listJobTasks;
        }

        try {
                for(JobTask__c task : listJobTasks) {
                    task.Status__c='Complete';
                }    
                update listJobTasks;
        } catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'PLCJobMethods', 'closeJobTasks');
                    String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
                    System.debug('Exception in closeJobTasks() method. Description:'+description);
                    throw new TriggerException('Something gone wrong during closing of Job Task. Please reach out to salesforce helpdesk.'+description);
        }
        return listJobTasks;
    }

}