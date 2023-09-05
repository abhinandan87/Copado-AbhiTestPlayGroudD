public class Innovation_callOut {

    @InvocableMethod( label='leadWriteBack' description='Update Lead records in EA sandbox' category='Callout' )
    public static void leadWriteBack(List < String > leadId) {
        sendWriteBackRequest(leadId[0]);
        //postToSlack(leadId[0]);
    }
    
    @future( callout=true )
    public static void sendWriteBackRequest( String leadId ) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Dev_Slack/services/apexrest/LeadWriteBack/updateLead');
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"leadId" : "'+leadId+'"}');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }
    @future( callout=true )
    public static void postToSlack(Id leadId) {
        system.debug('lead'+leadId);
        Lead objLead = [SELECT id, name, owner.name, createddate, external_lead_id__c, convertedopportunity.name FROM lead WHERE  external_lead_id__c=:leadId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/chat.postMessage');
        request.setHeader('Content-Type', 'application/json');
       // request.setHeader('Authorization', 'Bearer xoxb-3917199550261-4007949978871-Rv4NBYRVsUzkJg6J6w0GKhWo');
       request.setHeader('Authorization', 'Bearer xoxb-4097889578001-4093345057316-lYb6R8gzIvPiRMO48H0mK6ct');
        request.setBody('{  "channel": "C042VS5JA9X",  "text": "Hi, \n\nThe lead *<https://spglobalc360--devslack.sandbox.lightning.force.com/'+objLead.external_lead_id__c+'|'+objLead.name+'>* is converted :tada: \n\n*Lead Owner:* '+objLead.owner.name+'\n*Created Date:* '+objLead.CreatedDate+'\n*Opportunity:* '+objLead.convertedopportunity.name+'\n\nThanks,\n'+UserInfo.getName()+'"}');
        request.setMethod('POST');
        HttpResponse response = http.send(request);
    }
}