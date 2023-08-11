//-----------------------------
// @author: Madhusudhan
// @date: 12 July 2021
// @param: 
// @description: Test class for PLCJob trigger methods 
// @return: NA
//----------------------------- 
@isTest
private class TestPLCJobMethods {
//-----------------------------
// @author: Madhusudhan
// @date: 12 July 2021
// @param: 
// @description: This method is used to test the CreateTasks method
// @return: NA
//----------------------------- 
    public static testMethod void testCreateTasks() {
        PLCJob__c plc = new PLCJob__c(NumberofCycles__c = 10, CycleStart__c = date.newInstance(2000,1,1), Cycle__c = 'Week Days');
        insert plc;
        plc.CreateSetupMeetingTask__c = true;
        plc.CreateDocumentationTask__c = true;
        plc.CreatePeerReviewTask__c = true;
        update plc;
        Integer count=[select count() from JobTask__c where PLCJob__c =:plc.Id];
        system.debug('count----------- '+count);
        system.assert(count==4);
    }
}