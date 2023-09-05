public with sharing class OrderRequestMethods {
    
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: Update Requestor By field with the current user.
    // @return: None
    //------------------------------
    public static void updateRequestor(TriggerParameters tp) {
        for(OrderRequest__c order : (list<OrderRequest__c>)tp.newList) {
            order.Requestor__c  = userinfo.getuserid();
            }
        
        }
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: Updation of owner when order request is approved without job.
    // @return: None
    //------------------------------    
    public static void updateonApprovalwithoutJob(TriggerParameters tp) {
        Map<Id,OrderRequest__c> mapoldOrderReq =  (Map<Id,OrderRequest__c>)tp.oldMap;
        for(OrderRequest__c order : (list<OrderRequest__c>)tp.newList) {
            if(mapoldOrderReq.get(order.Id).orderrequeststatus__c!='Approved without Job'&& order.orderrequeststatus__c=='Approved without Job') {
                if(order.Programmer__c == NULL) {
                    order.OwnerId = UserInfo.getuserid();
                }
                else{
                    order.OwnerId = order.Programmer__c;
                }
            }
            
        }  
    }
      
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: Updation of owner when order request is rejected.
    // @return: None
    //------------------------------
    public static void updateonRejected(TriggerParameters tp) {
        Map<Id,OrderRequest__c> mapoldOrderReq =  (Map<Id,OrderRequest__c>)tp.oldMap;       
        for(OrderRequest__c order : (list<OrderRequest__c>)tp.newList) {
            if(mapoldOrderReq.get(order.Id).orderrequeststatus__c!='Rejected'&& order.orderrequeststatus__c=='Rejected') {
                order.OwnerId = order.CreatedById;
            }
        }
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: Updation of owner and creation of PLC Job when order request is approved.
    // @return: None
    //------------------------------
    public static void updateonApproval(TriggerParameters tp) {
        Map<Id,OrderRequest__c> mapoldOrderReq =  (Map<Id,OrderRequest__c>)tp.oldMap;
        Map<Id,OrderRequest__c> mapnewOrderReq =  (Map<Id,OrderRequest__c>)tp.newMap;   
        set<Id> wrfIds= new set<Id>();
        PLCJob__c newJob;
        List<PLCJob__c> lstofjobs = new List<PLCJob__c>();
        for(OrderRequest__c order : mapnewOrderReq.values()) {
            wrfIds.add(order.WorkRequestForm__c);
        }
        Map<Id,workrequestform__c> mapofWRF = new Map<Id,workrequestform__c>([Select Id,opportunityname__c, name, jobnumber__c, cycle__c, 
                                                                              cyclestart__c, jobtype__c, requeststatus__c, programmerassigned__c, ownerID 
                                                                              from workrequestform__c where id =: wrfIds]);
        if(mapofWRF.size()>0) {  
            for(OrderRequest__c orderReq : mapnewOrderReq.values()) {               
                if(mapoldOrderReq.get(orderReq.Id).orderrequeststatus__c!='Approved without Job'&& orderReq.orderrequeststatus__c=='Approved' && orderReq.PLCJob__c==NULL) {                    
                    if(orderReq.Programmer__c == NULL) {
                        orderReq.OwnerId = UserInfo.getuserid();
                    }
                    else{
                        orderReq.OwnerId = orderReq.Programmer__c;
                    }
                    newJob =  createPLCJobs(mapofWRF.get(orderReq.WorkRequestForm__c),orderReq);
                    lstofjobs.add(newJob);
                    
                }
            }
        }
        if(lstofjobs.size()>0) {
            Database.SaveResult[] result = Database.insert(lstofjobs);
            updatePLConOrderReq(result,mapnewOrderReq,lstofjobs.size());
        }
    }
    
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: PLC creation method.
    // @return: None
    //------------------------------
    public static PLCJob__c createPLCJobs(workrequestform__c wrfRec ,OrderRequest__c orderReq) {
        PLCJob__c newJob = new PLCJob__c();
        newJob.Opportunity__c = wrfRec.OpportunityName__c;
        newJob.JobName__c = wrfRec.Name;
        newJob.JobType__c = wrfRec.JobType__c;
        newJob.WorkRequestForm__c = wrfRec.ID;
        newJob.OwnerID = orderReq.OwnerID;
        newJob.Cycle__c = wrfRec.Cycle__c;
        newJob.CycleStart__c = wrfRec.CycleStart__c;
        newJob.JobNumber__c = wrfRec.JobNumber__c;
        //Added Order Request reference to PLC
        newJob.OrderRequest__c = orderReq.Id;
        newJob.SubmittedDate__c = orderReq.SubmittedDateTime__c;
        newJob.Team1__c = orderReq.Team1__c;
        newJob.NegotiatedDate__c = orderReq.NegotiatedDate__c;
        newJob.StartDate__c = orderReq.PLCStartDate__c;
        return newJob;
        
    }
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: updation of PLC count.
    // @return: None
    //------------------------------
    public static void updatePLConOrderReq(Database.SaveResult[] result ,Map<Id,orderrequest__c> mapnewOrderReq, integer jobSize) {
        set<Id> insertPLCrec = new set<Id>();
        for(integer i=0;i<jobSize;i++) {
            insertPLCrec.add(result[i].getId());            
        }
        for(PLCJob__c job : [Select Id,OrderRequest__c FROM PLCJob__c WHERE ID IN:insertPLCrec]) {
            mapnewOrderReq.get(job.OrderRequest__c).PLCJob__c = job.Id;
        }
    }
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: Updation of owner and creation of PLC Job when order request is approval pending.
    // @return: None
    //------------------------------
    public static void updateonApprovalPending(TriggerParameters tp) {
        Map<Id,OrderRequest__c> mapoldOrderReq =  (Map<Id,OrderRequest__c>)tp.oldMap;
        List<OrderRequest__c> orderReqLst = new List<OrderRequest__c>();
        for(OrderRequest__c orderReq : [Select Id,Programmer__c,OwnerId,orderrequeststatus__c FROM OrderRequest__c WHERE Id=:mapoldOrderReq.keyset()]) {
            if( orderReq.OrderRequestStatus__c=='Approval Pending') {
                if(orderReq.Programmer__c == NULL) {
                    orderReq.OwnerId = UserInfo.getuserid();
                }
                else{
                    orderReq.OwnerId = orderReq.Programmer__c;
                }
            }
            orderReqLst.add(orderReq);
            
        }
        if(orderReqLst.size()>0) {
            update orderReqLst;
        }
    }
    //-----------------------------
    // @author: Anjali
    // @date: 17th June 2021
    // @param: TriggerParameters tp
    // @description: Updation of owner and creation of PLC Job when order request is submitted.
    // @return: None
    //------------------------------
    public static void updateonSubmit(TriggerParameters tp) {
         Map<String,WRFOwnerAssignments__mdt> mapOfOwnerAssignment = new Map<String,WRFOwnerAssignments__mdt>(); 
        Map<Id,User> mapofUsers;
        Map<Id,WorkRequestForm__c> workRequestForm ;new Map<Id,WorkRequestForm__c>();
        Set<Id> wrfId =new Set<Id>();
        Set<Id> wrfOwnerId =new Set<Id>();
        Map<String, ID> queueMAP = new Map<String, ID>();
        for(group g : [select id,name from Group where Type='Queue']) {
            queueMAP.put(g.name,g.id);
        }
        for(WRFOwnerAssignments__mdt assignment : [SELECT MasterLabel, QueueName__c FROM WRFOwnerAssignments__mdt]) {
            mapOfOwnerAssignment.put(assignment.MasterLabel,assignment);
        }
        for(OrderRequest__c logRec : (list<OrderRequest__c>)tp.newList) {
            wrfId.add(logRec.WorkRequestForm__c);
        }
        workRequestForm = new Map<Id,WorkRequestForm__c>([Select Id,OwnerId,FormType__c,Loyalty__c,TableauVisualization__c,PolkInsightChinaSystem__c,DataExtractNewReg__c,
                                                          AdHocReport__c,ChinaDataRequests__c,ChinaCV__c,DataExtractGlobalVIOPARC__c,Mapping__c,MarketInsightSystem__c,
                                                          WorldviewVIO__c,PARCDataFiles__c,Analytics__c,PolkConnectSystem__c,AdhocCustom__c,AutoTrackerReport__c,AutoNews__c,PolkInsightProductionMessage__c,
                                                          CARB__c,CVINA__c,ReportDataFile__c,DMS__c,DrivewayCalculator__c,
                                                          FileCleanse__c,ListRequest__c,
                                                          modelSegmentation__c,NewRegSystem__c,NewRegNewFor__c,PS__c,PARCGlobal__c,PCVINA__c, 
                                                           PlanningSolutions__c,
                                                          Profile__c, Recall__c, SalesMatch__c, 
                                                          SmartLink__c, TIPNetNewTrailer__c, 
                                                          TIPNetNewTruck__c, TIPNetSystem__c, TIPNetVehiclesInOperation__c, 
                                                          TLAS__c, ScrappageMedianAge__c, Vfacts__c, 
                                                           VINTrace__c, 
                                                          VINA__c, Vindicator__c,                                                       
                                                          CommercialAccountFile__c,Dashboard__c,ModelDecommission__c,MarketResearch__c,OwnershipSignals__c,SoftwareServices__c,CFIRequest__c,EmailAudienceProspecting__c  FROM WorkRequestForm__c WHERE Id=:wrfId]);//SFDC-5577 Removed WRF Decomission Fields
        
        if(workRequestForm.size()>0) {
            for(WorkRequestForm__c wrfowner :workRequestForm.values() ) {
                wrfOwnerId.add(wrfowner.OwnerId);
            }
        }
        mapofUsers = new Map<Id,User>([SELECT Id,userroleid,userrole.name,UserRegion__c FROM user WHERE Id=:wrfOwnerId OR Id=:Userinfo.getUserid()]);
        for(OrderRequest__c orderReq : (list<OrderRequest__c>)tp.newList) {
            OrderRequest__c oldorderReq;
            if((tp.oldMap == null|| ((oldorderReq = (OrderRequest__c) tp.oldMap.get(orderReq.Id))!=null && oldorderReq.OrderRequestStatus__c!=orderReq.OrderRequestStatus__c ))&& orderReq.OrderRequestStatus__c=='Submitted') {
                if(orderReq.WorkRequestForm__c!=null && mapofUsers.size()>0 && queueMAP.size()>0) {
                ID queueID = WRFUtility.returnWRFOwnerId(workRequestForm.get(orderReq.WorkRequestForm__c), mapofUsers, queueMAP, mapOfOwnerAssignment);               
                orderReq.OwnerId = queueID;
                }
                orderReq.SubmittedDateTime__c=datetime.now();
            }
        }
        
    }
    

}