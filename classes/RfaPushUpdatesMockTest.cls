/*  @author: Akash Punera
 *   @date: 15 Dec 2022
 *   @description: Mock Class for RfaPushUpdates test callouts
 */
@isTest
public class RfaPushUpdatesMockTest implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        s1_request__c s1Req = [SELECT id FROM s1_Request__c limit 1];
        s1_response__c s1Res = [SELECT id FROM s1_response__c limit 1];
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('[[{"type":"S1_Request__c","status":"Success","recordId":"'+s1Req?.id+'","message":"Record Upserted"},{"type":"S1_Response__c","status":"Success","recordId":"'+s1Res?.id+'","message":"Record Upserted"}]]');
        response.setStatusCode(200);
        return response; 
    }
}