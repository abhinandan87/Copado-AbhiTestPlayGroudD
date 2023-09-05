/*  @author: Akash Punera
 *   @date: 15 Dec 2022
 *   @description: Test Class for RfaPushUpdates
 */
@isTest(SeeAllData = false)
public class RfaPushUpdatesTest {

    @testSetup static void setup() {
        //Create s1 request
        s1_request__c objReq = new s1_request__c();
        //Do not rename used in mock callout
        objReq.Description__c = 'Test Record-001';
        objReq.Not_applicable__c = true;
        insert objReq;

        //create s1 response
        s1_response__c objRes = new s1_response__c();
        //Do not rename used in mock callout
        objRes.Description__c = 'Test Response-001';
        objRes.s1_request__c = objReq.id;
        insert objRes;
     
    }

    @isTest
    static void testPushUpdatesToHub() {

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RfaPushUpdatesMockTest());
        // Create a new instance of the RfaPushUpdates class.
        RfaPushUpdates updates = new RfaPushUpdates();

        // Call the pushUpdatesToHub() method and assert that the flag is updated.
        updates.pushUpdatesToHub();
        System.assertEquals(false,[SELECT id, push_updates__c FROM s1_Request__c limit 1].push_Updates__c, 'Push updates flag not reset to false');

        Test.stopTest();
    }

    @isTest
    static void testSendNotification() {

        Test.startTest();
        // Call the pushUpdatesToHub() method and assert that flag is updated
        system.enqueueJob(new RfaPushUpdates());        
        
        System.assertEquals(true,[SELECT id, push_updates__c FROM s1_Request__c limit 1].push_Updates__c, 'Push updates flag not reset to true');

        Test.stopTest();
    }

    @isTest
    static void testScheduler() {

        Test.startTest();
        RfaUpdateScheduler us = new RfaUpdateScheduler();
        String sch = '0 0 * ? * * *';
        String jobID = System.schedule('RFA Update Job', sch, us);
        List<AsyncApexJob> listScheduledJob  = [SELECT Id, CreatedDate, CreatedBy.name, ApexClass.name, JobType, Status, CompletedDate, MethodName FROM AsyncApexJob];
        System.assert(listScheduledJob.size() > 0);
        Test.stopTest();
    }

    
    @isTest
    static void testRfaWrapper() {

        Test.startTest();
        RfaWrapper.RfaRestResponse objResponse = new RfaWrapper.RfaRestResponse([SELECT id, push_updates__c FROM s1_Request__c limit 1].id, 'Success','Upsert Success','S1_request__c');
        System.assert(objResponse.status == 'Success');
        Test.stopTest();
    }
}