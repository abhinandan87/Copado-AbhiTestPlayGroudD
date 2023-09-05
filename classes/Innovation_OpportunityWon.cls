public class Innovation_OpportunityWon {
    
    @future( callout=true )
    public static void postToSlack(Id opportunityId) {
        system.debug('opportunityId: '+opportunityId);
        Opportunity objOpportunity = [SELECT id, name, owner.name,CreatedDate FROM Opportunity WHERE  id=:opportunityId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/chat.postMessage');
        request.setHeader('Content-Type', 'application/json');
       // request.setHeader('Authorization', 'Bearer xoxb-3917199550261-4007949978871-Rv4NBYRVsUzkJg6J6w0GKhWo');
       request.setHeader('Authorization', 'Bearer xoxb-4097889578001-4093345057316-lYb6R8gzIvPiRMO48H0mK6ct');
        request.setBody('{  "channel": "C042VS5JA9X",  "text": "Hi, \n\nThe lead *<https://spglobalc360--devslack.sandbox.lightning.force.com/'+'|'+objOpportunity.name+'>* is converted :tada: \n\n*Lead Owner:* '+objOpportunity.owner.name+'\n*Created Date:* '+objOpportunity.CreatedDate+'"}');
        request.setMethod('POST');
        HttpResponse response = http.send(request);
    }

}