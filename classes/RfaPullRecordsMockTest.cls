/*  @author: Pankhuri Jain
 *  @date: 21 Dec 2022
 *  @description: Mock Response Test Class for RfaPullRecords
*/

@isTest
public class RfaPullRecordsMockTest implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest request) {   
        s1_request__c s1Req = [SELECT id,External_Id__c FROM s1_Request__c limit 1];
        s1_response__c s1Res = [SELECT id,External_Id__c FROM s1_response__c limit 1];
        HttpResponse response = new HttpResponse();        
        response.setHeader('Content-Type', 'application/json');  
        response.setBody('[[{"Id":"'+s1Req?.id+'","External_Id__c":"'+s1Req?.id+'","Account_Name__c":"","Completed_Date__c":"2022-12-08","Opportunity_Name__c":"test2","Record_Type_Id__c":"","Description__c":"test for screen flow","Status__c":"In Progress","OwnerId":"0054x0000062aP1AAI","Division__c":"Mobility","Division_Sent_From__c":"MI","Category__c":"Education (Internal)","S1Response":{"records":[{"Id":"'+s1Res?.id+'","External_Id__c":"'+s1Res?.external_Id__c+'","S1_Request__c":"'+s1Req?.id+'","Description__c":"test for screen flow","Status__c":"New","Owner":"DonnaORourke","OwnerEmail":"donna.orourke@spglobal.com.invalid","Type":"Outgoing"}]}}]]');        
        response.setStatusCode(200);
        return response; 
    }
}