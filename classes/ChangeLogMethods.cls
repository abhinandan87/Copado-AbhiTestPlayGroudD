//-----------------------------
// @author: Anjani Shukla
// @date: 29 Sept 2017
// @param: NA
// @description: Class to hold trigger methods 
// @return: NA
//-----------------------------
public class ChangeLogMethods {

    public static list<Group> groupList = new list<Group>();
    public static Map<Id,WorkRequestForm__c> workRequestForm = new Map<Id,WorkRequestForm__c>();
    public static Map<Id,User> mapofUsers = new Map<Id,User>();
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 29 Sept 2017
    // @param: TriggerParameters tp
    // @description: Update Start Date or Negotiated Date if differs.
    // @return: None
    //------------------------------
    /*public static void notificationEmail(TriggerParameters tp) {
        list<changelog__c> c = (list<changelog__c>)tp.newList;    
        for(changelog__c cl : c) {
            if (cl.wrstatus__c == 'Approved') {
                c.add(cl);
        
            }
        }    

    //SendEmail.sendMail(c);
    }*/
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Update Changedocument By field with the current user.
    // @return: None
    //------------------------------
    public static void updateChangeDocument(TriggerParameters tp) {
        for(changelog__c changelog : (list<changelog__c>)tp.newList) {
            changelog.ChangeDocumentedBy__c = userinfo.getuserid();
            }
        
        }   
        //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Update owner and submitted date when the request is submitted.
    // @return: None
    //------------------------------
    public static void updateonSubmit(TriggerParameters tp) {
        Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment = new Map<String,WRFOwnerAssignments__mdt>(); 
        Set<Id> wrfId =new Set<Id>();
        Set<Id> wrfOwnerId =new Set<Id>();
        Map<String, ID> queueMAP = new Map<String, ID>();
        if(groupList.size()==0) {
            groupList = [select id,name from Group where Type='Queue'];  
         }
        for(group g : groupList) {
            queueMAP.put(g.name,g.id);
        }
        for(WRFOwnerAssignments__mdt assignment : [SELECT MasterLabel, QueueName__c FROM WRFOwnerAssignments__mdt]) {
            mapOfOwnerAssignment.put(assignment.MasterLabel,assignment);
        }
        for(changelog__c logRec : (list<changelog__c>)tp.newList) {
            wrfId.add(logRec.WorkRequestForm__c);
        }
        if(workRequestForm.size()==0) { 
            workRequestForm = new Map<Id,WorkRequestForm__c>([Select Id,OwnerId,FormType__c,Loyalty__c,TableauVisualization__c,PolkInsightChinaSystem__c,DataExtractNewReg__c,
                                                          AdHocReport__c,ChinaDataRequests__c,ChinaCV__c,DataExtractGlobalVIOPARC__c,Mapping__c,MarketInsightSystem__c,
                                                          WorldviewVIO__c,PARCDataFiles__c,Analytics__c,PolkConnectSystem__c,AdhocCustom__c,AutoTrackerReport__c,AutoNews__c,PolkInsightProductionMessage__c,
                                                          CARB__c,CVINA__c,ReportDataFile__c,DMS__c,DrivewayCalculator__c,
                                                          FileCleanse__c,ListRequest__c,
                                                          modelSegmentation__c,NewRegSystem__c,NewRegNewFor__c,PS__c,PARCGlobal__c,PCVINA__c, 
                                                          PlanningSolutions__c,
                                                          Profile__c, Recall__c,SalesMatch__c, 
                                                          SmartLink__c, TIPNetNewTrailer__c, 
                                                          TIPNetNewTruck__c, TIPNetSystem__c, TIPNetVehiclesInOperation__c, 
                                                          TLAS__c, ScrappageMedianAge__c, Vfacts__c,
                                                          VINTrace__c, 
                                                          VINA__c, Vindicator__c,                                                        
                                                          CommercialAccountFile__c,Dashboard__c,ModelDecommission__c,MarketResearch__c,OwnershipSignals__c,SoftwareServices__c,CFIRequest__c,EmailAudienceProspecting__c FROM WorkRequestForm__c WHERE Id=:wrfId]);//SFDC-5577 Removed WRF Decomission Fields
        }
        
        if(workRequestForm.size()>0) {
            for(WorkRequestForm__c wrfowner :workRequestForm.values() ) {
                wrfOwnerId.add(wrfowner.OwnerId);
            }
        }
        
        if(mapofUsers.size()==0) {
            mapofUsers = new Map<Id,User>([SELECT Id,userroleid,userrole.name,UserRegion__c FROM user WHERE Id=:wrfOwnerId OR Id=:Userinfo.getUserid()]);
        }
        for(changelog__c changelog : (list<changelog__c>)tp.newList) {
            changeLog__c oldchangelog;
            if((tp.oldMap == null|| ((oldchangelog = (changeLog__c) tp.oldMap.get(changelog.Id))!=null && oldchangelog.RequestStatus__c!=changelog.RequestStatus__c ))&& changelog.RequestStatus__c=='Submitted') {
                if(changelog.WorkRequestForm__c!=null && mapofUsers.size()>0 && queueMAP.size()>0) {
                ID queueID = WRFUtility.returnWRFOwnerId(workRequestForm.get(changelog.WorkRequestForm__c), mapofUsers, queueMAP, mapOfOwnerAssignment);               
                changelog.OwnerId = queueID;
                }
                changelog.SubmittedDateTime__c=datetime.now();
            }
        }
        
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Updates when the request is approved.
    // @return: None
    //------------------------------
    public static void updateonApproval(TriggerParameters tp) {
        Map<Id,changelog__c> mapoldchangelog =  (Map<Id,changelog__c>)tp.oldMap;
        for(changelog__c changelog : (list<changelog__c>)tp.newList) {
            if(mapoldchangelog.get(changelog.Id).requeststatus__c!='Approved without Job'&& changelog.RequestStatus__c=='Approved without Job') {
                if(changelog.Programmer__c == NULL) {
                    changelog.OwnerId = UserInfo.getuserid();
                }
                else{
                    changelog.OwnerId = changelog.Programmer__c;
                }
            }
            
        }  
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Updates when the request is Approve & Create Jobs.
    // @return: None
    //------------------------------
    public static void updateonApprovalAndCreateJobs(TriggerParameters tp) {
        Map<Id,changelog__c> mapoldchangelog =  (Map<Id,changelog__c>)tp.oldMap;
        Map<Id,changelog__c> mapnewchangelog =  (Map<Id,changelog__c>)tp.newMap;
        set<Id> wrfIds= new set<Id>();
        PLCJob__c newJob;
        List<PLCJob__c> lstofjobs = new List<PLCJob__c>();
        for(changelog__c changelog : mapnewchangelog.values()) {
            wrfIds.add(changelog.WorkRequestForm__c);
        }
        Map<Id,workrequestform__c> mapofWRF = new Map<Id,workrequestform__c>([Select Id, changelogsplc__c, opportunityname__c, name, jobnumber__c, cycle__c, 
                                                                              cyclestart__c, jobtype__c, requeststatus__c, programmerassigned__c, ownerID 
                                                                              from workrequestform__c where id =: wrfIds]);
        if(mapofWRF.size()>0) {           
            for(changelog__c changelog : mapnewchangelog.values()) {               
                if(mapoldchangelog.get(changelog.Id).requeststatus__c!='Approved without Job'&& changelog.RequestStatus__c=='Approved' && changelog.PLCJob__c==NULL) {                    
                    if(changelog.Programmer__c == NULL) {
                        changelog.OwnerId = UserInfo.getuserid();
                    }
                    else{
                        changelog.OwnerId = changelog.Programmer__c;
                    }
                    newJob =  createPLCJobs(mapofWRF.get(changelog.WorkRequestForm__c),changelog);
                    lstofjobs.add(newJob);
                    
                    if(mapofWRF.get(changelog.WorkRequestForm__c).ChangeLogsPLC__c == null||mapofWRF.get(changelog.WorkRequestForm__c).ChangeLogsPLC__c == 0) {
                        
                        mapofWRF.get(changelog.WorkRequestForm__c).ChangeLogsPLC__c =1;
                    }
                    else{
                        mapofWRF.get(changelog.WorkRequestForm__c).ChangeLogsPLC__c++;
                    }
                }
                
            } 
            
            if(lstofjobs.size()>0) {
                Database.SaveResult[] result = Database.insert(lstofjobs);
                update mapofWRF.values(); 
                updatePLConChangeLog(result,mapnewchangelog,lstofjobs.size());
            } 
        }
    }
    
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: workrequestform__c wrfRec ,changelog__c changelog
    // @description: Method to create jobs.
    // @return: PLC Job
    //------------------------------
    public static PLCJob__c createPLCJobs(workrequestform__c wrfRec ,changelog__c changelog) {
        PLCJob__c newJob = new PLCJob__c();
        newJob.RequestedDate__c = changelog.RevisedRequestDate__c;
        newJob.Opportunity__c = wrfRec.OpportunityName__c;
        newJob.JobName__c = wrfRec.Name;
        // Number of PLC jobs created from changes assigned
        newJob.ChangeCounter__c = wrfRec.ChangeLogsPLC__c;
        newJob.JobType__c = wrfRec.JobType__c;
        newJob.WorkRequestForm__c = wrfRec.ID;
        newJob.OwnerID = changelog.OwnerID;
        newJob.Cycle__c = wrfRec.Cycle__c;
        newJob.CycleStart__c = wrfRec.CycleStart__c;
        // # cycles is not copied from WRF into PLC from change logs
        newJob.JobNumber__c = wrfRec.JobNumber__c;
        //Added Change Log reference to PLC
        newJob.ChangeLog__c = changelog.Id;
        newJob.SubmittedDate__c = changelog.SubmittedDateTime__c;
        newJob.Team1__c = changelog.Team1__c;
        newJob.NegotiatedDate__c = changelog.NegotiatedDate__c;
        newJob.StartDate__c = changelog.PLCStartDate__c;
        return newJob;
        
    } 
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Method to create jobs.
    // @return: None
    //------------------------------
    public static void updatePLConChangeLog(Database.SaveResult[] result ,Map<Id,changelog__c> mapnewchangelog, integer jobSize) {
        set<Id> insertPLCrec = new set<Id>();
        for(integer i=0;i<jobSize;i++) {
            insertPLCrec.add(result[i].getId());            
        }
        for(PLCJob__c job : [Select Id,changeLog__c FROM PLCJob__c WHERE ID IN:insertPLCrec]) {
            mapnewchangelog.get(job.changeLog__c).PLCJob__c = job.Id;
        }
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Updates whenthe request is Approval Pending.
    // @return: None
    //------------------------------    
    public static void updateonApprovalPending(TriggerParameters tp) {
        Map<Id,changelog__c> mapoldchangelog =  (Map<Id,changelog__c>)tp.oldMap;
        List<changeLog__c> changeLogLst = new List<changeLog__c>();
        for(changelog__c changelog : [Select Id,Programmer__c,OwnerId,requeststatus__c FROM changelog__c WHERE Id=:mapoldchangelog.keyset() ]) {
            if( changelog.RequestStatus__c=='Approval Pending') {
                if(changelog.Programmer__c == NULL) {
                    changelog.OwnerId = UserInfo.getuserid();
                }
                else{
                    changelog.OwnerId = changelog.Programmer__c;
                }
                 changeLogLst.add(changelog);
            }
        }
        if(changeLogLst.size()>0) {
            update changeLogLst;
        }
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: Update when the request is rejected.
    // @return: None
    //------------------------------  
    public static void updateonRejected(TriggerParameters tp) {
        Map<Id,changelog__c> mapoldchangelog =  (Map<Id,changelog__c>)tp.oldMap;
        for(changelog__c changelog : (list<changelog__c>)tp.newList) {
            if(mapoldchangelog.get(changelog.Id).requeststatus__c!='Rejected'&& changelog.RequestStatus__c=='Rejected') {
                changelog.OwnerId = changelog.ChangeDocumentedBy__c;
            }
        }
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 18th May 2021
    // @param: TriggerParameters tp
    // @description: To update no. of changelogs in WRF.
    // @return: None
    //------------------------------  
    public static void updateNoofChangeLogs(TriggerParameters tp) {
        set<Id> wrfId = new set<Id>();
        Map<Id,String> failedRec = new Map<Id,String>();
        List<WorkRequestForm__c> updateWRFLst = new List<WorkRequestForm__c>();
        if(Trigger.isInsert) {
            for(changelog__c changelog : (list<changelog__c>)tp.newList) {
                wrfId.add(changelog.WorkRequestForm__c);
            }
        }
        if(Trigger.isDelete) {
            for(changelog__c changelog : (list<changelog__c>)tp.oldList) {
                wrfId.add(changelog.WorkRequestForm__c);
            }  
        }
        for(WorkRequestForm__c wrf : [Select Id,ChangeLogs__c,(Select Id FROM ChangeLogs__r) FROM WorkRequestForm__c WHERE Id=:wrfId]) {
            wrf.ChangeLogs__c = wrf.ChangeLogs__r.size();
            updateWRFLst.add(wrf);
        }
        if(updateWRFLst.size()>0) {
           Database.SaveResult[] srList=Database.Update(updateWRFLst,false); 
            integer i=0;
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) { 
                        System.debug(err.getMessage());
                            failedRec.put(updateWRFLst[i].Id,err.getMessage());

                    }
                }
                i++;
            } 
        }
        if(failedRec.size()>0) {
            for(changelog__c cL: (list<changelog__c>)tp.newList) {
                if(failedRec.containsKey(cL.WorkRequestForm__c)) {
                    cL.addError('Work Request Form : '+failedRec.get(cL.WorkRequestForm__c));
                }
            }
        }
    }
}