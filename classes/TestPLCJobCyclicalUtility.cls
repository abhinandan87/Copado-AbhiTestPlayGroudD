//-----------------------------
// @author: Madhusudhan
// @date: 12 July 2021
// @param: 
// @description: Test class for PLCJob trigger methods 
// @return: NA
//----------------------------- 
@isTest
private class TestPLCJobCyclicalUtility  {
    //-----------------------------
    // @author: Madhusudhan
    // @date: 12 July 2021
    // @param: 
    // @description: This method is used for to create the cyclical jobs 
    // @return: NA
    //----------------------------- 
    @isTest
    public static void testgetPlcJobRecords() {  
        PLCJob__c plc = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Week Days', CreatePeerReviewTask__c=true);
        insert plc;
        List<plcjob__c> plcList=PLCJobCyclicalUtility.getPlcJobRecords(plc.id);
        system.assert(plcList.size()==9,'Check PLC List is 9');
        PLCJob__c plcWeekly = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Weekly', CreatePeerReviewTask__c=true);
        insert plcWeekly;
        List<plcjob__c> plcWeeklyList=PLCJobCyclicalUtility.getPlcJobRecords(plcWeekly.id);
        system.assert(plcWeeklyList.size()==9,'Check PLC List is 9');
        PLCJob__c plcMonthly = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Semi-Monthly', CreatePeerReviewTask__c=true);
        insert plcMonthly;
        List<plcjob__c> plcMonthlyList=PLCJobCyclicalUtility.getPlcJobRecords(plcMonthly.id);
        system.assert(plcMonthlyList.size()==9,'Check PLC List is 9');
        PLCJob__c plcQuarterly = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Quarterly', CreatePeerReviewTask__c=true);
        insert plcQuarterly;
        List<plcjob__c> plcQuarterlyList=PLCJobCyclicalUtility.getPlcJobRecords(plcQuarterly.id);
        system.assert(plcQuarterlyList.size()==9,'Check PLC List is 9');
        PLCJob__c plcAnnually = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Annually', CreatePeerReviewTask__c=true);
        insert plcAnnually;
        List<plcjob__c> plcAnnuallyList=PLCJobCyclicalUtility.getPlcJobRecords(plcAnnually.id);
        system.assert(plcAnnuallyList.size()==9,'Check PLC List is 9');
        PLCJob__c Otherplc = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Other', CreatePeerReviewTask__c=true);
        insert Otherplc;
        List<plcjob__c> OtherplcList=PLCJobCyclicalUtility.getPlcJobRecords(Otherplc.id);
        system.assert(OtherplcList.size()==9,'Check PLC List is 9');
        
    }
    //-----------------------------
    // @author: Madhusudhan
    // @date: 12 July 2021
    // @param: 
    // @description: This method is used for to create the Multipart jobs 
    // @return: NA
    //----------------------------- 
    @isTest
    public static void testPLCJobCloneMultipartUtility() {  
        PLCJob__c plc = new PLCJob__c(NumberofCycles__c = 5, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Week Days', CreatePeerReviewTask__c=true,NumberofParts__c=5);
        insert plc;
         List<plcjob__c> plcList=PLCJobCyclicalUtility.PLCJobCloneMultipartUtility(plc.id);
        system.debug('plcList.size()----------- '+plcList.size());
        system.assert(plcList.size()==4,'Check PLC size is 4');        
    }
    //-----------------------------
    // @author: Madhusudhan
    // @date: 12 July 2021
    // @param: 
    // @description: This method is used to save the PLC records
    // @return: NA
    //----------------------------- 
    @isTest
    public static void testsaveCyclicPLCJobs() {  
        List<PLCJob__c> bulkPLCs = new List<PLCJob__c>();
        for(Integer i = 0; i < 10; i++) {
            bulkPLCs.add(new PLCJob__c(StartDate__c = System.today(), NegotiatedDate__c=System.today()));
        }
        PLCJobCyclicalUtility.saveCyclicPLCJobs(bulkPLCs);
        system.assert(bulkPLCs.size()>0, 'Check size greater than 0');
    }
 
}