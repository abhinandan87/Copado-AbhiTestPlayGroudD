/*  @author: Pankhuri Jain
 *  @date: 21 Dec 2022
 *  @description: Test Class for RfaPullRecords
*/

@isTest
public class RfaPullRecordsTest {
	 @testSetup static void setup() {
        //Create s1 request
        s1_request__c objReq = new s1_request__c();
        objReq.Description__c = 'test for screen flow';
        objReq.Not_applicable__c = true;
        objReq.External_Id__c = '1';
        objReq.Division__c = 'Mobility';
        objReq.Category__c = 'Education (Internal)';
        insert objReq;

        //create s1 response
        s1_response__c objRes = new s1_response__c();
        objRes.Description__c = 'Test Response-01';
        objRes.s1_request__c = objReq.id;
        objRes.External_Id__c = '2';
        insert objRes;     
    }
    
    @isTest
    static void testPullRecordsFromHub() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RfaPullRecordsMockTest());       
        RfaPullRecords records = new RfaPullRecords();
        records.pullRecordsFromHub();
        System.assertEquals('In Progress',[SELECT id, status__c FROM s1_Request__c limit 1].status__c, 'Status updated to In Progress');
        Test.stopTest();
    }
    
     @isTest
    static void testSendNotification() {
        Test.startTest();         
        system.enqueueJob(new RfaPullRecords());
        List<s1_response__c> s1reslist  = [SELECT Id,type__c FROM s1_response__c where type__c = 'Incoming'];
        System.assert(s1reslist.size() == 0);
        Test.stopTest();
    }

}