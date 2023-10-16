@isTest
public with sharing class IntegrationGoogle_Test {
    // @TestSetup
    // static void makeData(){
    //     insert new Account(
    //         Name = 'Oficina',
    //         Phone = '1231231231',
    //         IdExternoOficina__c = 'id_externo'
    //     );
    // }

    @isTest
    public static void eventListener_test() {
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>{
            'message' => new Map<String,String>{
                'data' => EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(new Map<String,Object> {
                    // 'location' => 'id_externo'
                })))
            }
        }));
        RestContext.request = request;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationGoogle_Mock());

        IntegrationGoogle.eventListener();

        Test.stopTest();
    }

    @isTest
    public static void getToken_test() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IntegrationGoogle_Mock());
        String token = IntegrationGoogle.getToken();

        System.assertEquals('access_token_value', token, 'ERROR - wrong token received');
        Test.stopTest();
    }

    @isTest
    public static void postReply_test() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new IntegrationGoogle_Mock());
        List<String> responses = GooglePostReplyInvocable.postReplyInvocable((new List<CustomerReview__c>{new CustomerReview__c()}));

        Test.stopTest();
    }
}