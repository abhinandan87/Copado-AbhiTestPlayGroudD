// @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: This is used to create the cloned Cyclical jobs/ Multipart Jobs from parent PLC job record
    // @return: None
public class PLCJobCyclicalUtility {
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: This is used to create the cloned Cyclical jobs from Parent PLC Job record
    // @return: List<plcjob__c>
    @AuraEnabled(cacheable=false)
    public static List<plcjob__c> getPlcJobRecords(String masterPLCId) {
        plcjob__c clonedPLC = [select 
                CreatePeerReviewTask__c, id, OwnerId,Owner.Name,jobname__c, 
                JobType__c, NumberOfCycles__c, cyclestart__c, cycle__c, opportunity__c, OpportunityValue__c, 
                processtouse__c, totaljobestimate__c, othercostestimate__c, currencyisocode, 
                peerreviewer__c, encryptionrequired__c, encryptionkey__c, ftprequired__c, 
                ftpinformationinwrf__c, ftppath__c, ftpuserid__c, ftppassword__c, jobnumber__c, 
                JobEstimatedHours__c, workrequestform__c, DeliverableEstimate__c, 
                OrderRequest__c, SubmittedDate__c, StartDate__c, NegotiatedDate__c,RequestedDate__c,ChangeLog__c,
                Team1__c
                from plcjob__c where id =: masterPLCId];
        id cloneID = clonedPLC.ID;
        date nextDate = clonedPLC.StartDate__c;
        date negDate =  clonedPLC.NegotiatedDate__c ;
        date reqDate =  clonedPLC.RequestedDate__c ;
    
        //use cyclestart__c date if StartDate__c is not populated
        if (clonedPLC.StartDate__c == null ){
            nextDate = clonedPLC.cyclestart__c;
        }
        //use cyclestart__c date if NegotiatedDate__c is not populated
        if (clonedPLC.NegotiatedDate__c == null ){
            negDate = clonedPLC.cyclestart__c;
        }
        //use cyclestart__c date if RequestedDate__c is not populated
        if (clonedPLC.RequestedDate__c == null ){
            reqDate = clonedPLC.cyclestart__c;
        }
        double estimatedHours = clonedPLC.DeliverableEstimate__c;
        string nextDateDOW;
        string negDateDOW;
        string reqDateDOW;
        list<plcjob__c> newJobs = new list<plcjob__c>();
        
        //Here we iterate through the number of cycles based on the # put in the PLC Job
        //First thing that happens to set the date of the cycle based on the cycle type.
        
        for (integer i = 1; i <= clonedPLC.NumberOfCycles__c - 1; i++) {
            plcjob__c tempPLC = clonedPLC.clone(false);
            if (tempPLC.Cycle__c == 'Week Days' ){ //&& i <> 1) {
                    nextDate = nextDate.addDays(1);
                    negDate = negDate.addDays(1);
                    reqDate = reqDate.addDays(1);
            }
            else if (tempPLC.Cycle__c == 'Weekly'  ){ //&& i <> 1) {
                    nextDate = nextDate.addDays(7);
                    negDate =  negDate.addDays(7);
                    reqDate =  reqDate.addDays(7);
            }
            else if (tempPLC.Cycle__c == 'Semi-Monthly'  ){ //&& i <> 1) {
                    nextDate = nextDate.addDays(15);
                    negDate =  negDate.addDays(15);
                    reqDate =  reqDate.addDays(15);
            }
            else if (tempPLC.Cycle__c == 'Monthly'  ){ //&& i <> 1) {
                    nextDate = nextDate.addMonths(1);
                    negDate =  negDate.addMonths(1);
                    reqDate =  reqDate.addMonths(1);
            }
            else if (tempPLC.Cycle__c == 'Six Week Cycle'  ){ //&& i <> 1) {
                    nextDate = nextDate.addDays(42);
                    negDate =  negDate.addDays(42);
                    reqDate =  reqDate.addDays(42);
            }
            else if (tempPLC.Cycle__c == 'Quarterly'  ){ //&& i <> 1) {
                    nextDate = nextDate.addMonths(3);
                    negDate =  negDate.addMonths(3);
                    reqDate =  reqDate.addMonths(3);
            }
            else if (tempPLC.Cycle__c == 'Semi-Annually'  ){ //&& i <> 1) {
                    nextDate = nextDate.addMonths(6);
                    negDate =  negDate.addMonths(6);
                    reqDate =  reqDate.addMonths(6);
            }
            else if (tempPLC.Cycle__c == 'Annually'  ){ //&& i <> 1) {
                    nextDate = nextDate.addYears(1);
                    negDate =  negDate.addYears(1);
                    reqDate =  reqDate.addYears(1);
            }
            else if (tempPLC.Cycle__c == 'Other' ){ //&& i <> 1 ) {
                    nextDate = nextDate.addDays(0);
                    negDate =  negDate.addDays(0);
                    reqDate =  reqDate.addDays(0);
            }
            datetime nextDateTime = datetime.newInstance(nextDate.year(), nextDate.month(),nextDate.day());
            datetime negDateTime = datetime.newInstance(negDate.year(), negDate.month(),negDate.day());
            datetime reqDateTime = datetime.newInstance(reqDate.year(), reqDate.month(),reqDate.day());
            
            nextDateDOW = nextDateTime.format('EEEE');
            negDateDOW  = negDateTime.format('EEEE');
            reqDateDOW = reqDateTime.format('EEEE');
            
            //Backdate if Saturday or Sunday                       
            if (nextDateDOW == 'Saturday') {
                    nextDate = nextDate.addDays(-1);
            }
            if (nextDateDOW == 'Sunday') {
                    nextDate = nextDate.addDays(-2);
            }
            // Same backdate for negotiated date
            if (negDateDOW == 'Saturday') {
                    negDate = negDate.addDays(-1);
            }
            
            if (negDateDOW == 'Sunday') {
                    negDate = negDate.addDays(-2);
            }
            // Same backdate for RequestedDate__c 
            if (reqDateDOW == 'Saturday') {
                    reqDate = reqDate.addDays(-1);
            }
            if (reqDateDOW == 'Sunday') {
                    reqDate = reqDate.addDays(-2);
            }
            tempPLC.cycleoccurance__c = i;
            tempPLC.StartDate__c = nextDate;
            tempPLC.NegotiatedDate__c = negDate;
            tempPLC.RequestedDate__c = reqDate;
            //tempPLC.OwnerID = tempPLC.OwnerID;
            tempPLC.WRFQuality__c = 'No Set-up Required';
            tempPLC.ParentJob__c = cloneID;
            tempPLC.totaljobestimate__c = estimatedHours;

            newJobs.add (tempPLC);
            //Since we want the next date to be based on the standard, not backdated next date, we'll reverse what we did
            //For the next loop
            
            if (nextDateDOW == 'Saturday') {
                    nextDate = nextDate.addDays(1);
            }
            
            if (nextDateDOW == 'Sunday') {
                    nextDate = nextDate.addDays(2);
            }
        }
        return newJobs;
    }
    // @author: Madhusudhan karna
    // @date: 06 May 2021
    // @param:
    // @description: This is used to create the cloned Multipart jobs from Parent PLC Job record
    // @return: List<plcjob__c>
    @AuraEnabled
    public static List<plcjob__c> PLCJobCloneMultipartUtility(String masterPLCId) {

        plcjob__c clonedPLC = [select id, ownerid, jobname__c, JobType__c, NumberofCycles__c, 
                cyclestart__c, cycle__c, opportunity__c, opportunityvalue__c, processtouse__c,
                currencyisocode, peerreviewer__c, encryptionrequired__c,
                encryptionkey__c, ftprequired__c, ftpinformationinwrf__c, ftppath__c, 
                ftpuserid__c, ftppassword__c, workrequestform__c, jobnumber__c, NumberOfParts__c,
                //ELS added 7/17/12
                StartDate__c, NegotiatedDate__c,RequestedDate__c,ChangeLog__c, submitteddate__c
                from plcjob__c where id = :masterPLCId]; 
                
        id cloneID = clonedPLC.ID;
        
        date nextDate = clonedPLC.StartDate__c;
        date negDate =  clonedPLC.NegotiatedDate__c ;
        date reqDate =  clonedPLC.RequestedDate__c ;        
        
        
        string nextDateDOW;
        list<plcjob__c> newJobs = new list<plcjob__c>();
        integer totalJobs; 
        totalJobs = integer.valueOf(clonedPLC.NumberofParts__c);
                        
        for (integer i = 2; i <= totalJobs; i++) {
            plcjob__c tempPLC = clonedPLC.clone(false);
            tempPLC.multipartnum__c = i;
            tempPLC.StartDate__c = nextDate;
            tempPLC.NegotiatedDate__c = negDate;
            tempPLC.RequestedDate__c = reqDate;
            tempPLC.OwnerID = tempPLC.OwnerID;
            tempPLC.WRFQuality__c = 'No Set-up Required';
            tempPLC.ParentJob__c = cloneID;        
            tempPLC.isMultipart__c = True;                  
            newJobs.add (tempPLC);              
        }
        return newJobs;
    }

    //--------------------------------------------------------------------
    // @author: Uday Bikkumalla
    // @date: 30 June 2021
    // @param:
    // @description: Save PLC Jobs
    // @return:  List<PLCJob__C>
    //--------------------------------------------------------------------
    @AuraEnabled
    public static String saveCyclicPLCJobs(List<PLCJob__C> plcJobs) {
        String status = 'Failed';
        System.debug('List of PLC Jobs to be inserted: '+plcJobs);
        try {
            insert plcJobs;
            status = 'Success';
        }
        catch(AuraHandledException ex) {

            throw new AuraHandledException('Error: Unable to create cyclic jobs. '+ex.getMessage());
        }
        return status;
    }
}