public class Innovation_CheckIfSlackChannelExists {
    @invocablemethod(Label='Check Channel Name Exists')
    public static List<FlowOutputsWrapper> postIfCHannelExistsToFlow(List<String> channelName) {
        List<FlowOutputsWrapper> slackWrapperRetrun = new List<FlowOutputsWrapper>();
        FlowOutputsWrapper slackWrapperObj = new FlowOutputsWrapper();
        String channelValue = channelName[0];
        System.debug('channelValue##: '+channelValue);
        //Boolean isChannelExists = false;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://slack.com/api/conversations.list');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer xoxb-4158229548946-4290334634833-eWBiJRYwppQ5yHPsIlytolGI');
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        System.debug('response### '+response.getbody());
        List<String> lstChannelName = new List<String>();
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'name')) {
                    // Get the value.                    
                    parser.nextToken();
                    // Compute the grand total price for all invoices.
                    lstChannelName.add(parser.getText());
                }
        }
        System.debug('name### '+lstChannelName);
        for(String channel:lstChannelName){
            if(channelValue==channel){
               //isChannelExists = true;
               slackWrapperObj.isChannelExists = true; 
                break;
            }
        }
        //return isChannelExists;
       System.Debug('slackWrapperObj.isChannelExists##: '+slackWrapperObj.isChannelExists);
        slackWrapperRetrun.add(slackWrapperObj);
        return slackWrapperRetrun;
        
    }
    
    public class FlowOutputsWrapper{
        
        @InvocableVariable
        public Boolean isChannelExists =false; 
        
    }
    
}