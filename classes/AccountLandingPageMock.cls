@isTest
global class AccountLandingPageMock implements HttpCalloutMock {
    public string body;
    public integer status;
    public AccountLandingPageMock(string body, integer status){
        this.body = body;
        this.status = status;
    }
    global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type','application/json');
        response.setStatusCode(status);
		response.setBody(body);
        return response;
    }

}