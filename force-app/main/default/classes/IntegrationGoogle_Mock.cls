@isTest
global with sharing class IntegrationGoogle_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(JSON.serialize(new Map<String,Object> {
            'access_token' => 'access_token_value',
            'reviewer' => new Map<String,String>(),
            'starRating' => 'FIVE',
            'name' => 'name',
            'comment' => 'comment'
        }));
        response.setStatusCode(200);

        return response; 
    }
}