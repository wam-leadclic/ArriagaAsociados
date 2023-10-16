global with sharing class IntegrationTrustPilot_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(new Map<String,String> {
            'access_token' => 'token',
            'referralEmail' => 'referral@email.com',
            'url' => 'url'
        }));
        response.setStatusCode(201);

        return response; 
    }
}