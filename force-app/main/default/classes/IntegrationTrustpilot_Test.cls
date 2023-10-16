@isTest
public with sharing class IntegrationTrustpilot_Test {
    @TestSetup
    static void makeData(){
        insert new Account(
            FirstName = 'Mario',
            LastName = 'Rossi',
            PersonEmail = 'person@email.com'            
        );
    }
    
    @isTest
    public static void test() {
        Test.startTest();

        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object> {
            'events' => new List<Map<String,Object>> {
                new Map<String,Object> {
                    'eventName' => 'name',
                    'eventData' => new Map<String,Object>{
                        'stars' => '5',
                        'id' => 'id',
                        'title' => 'title',
                        'text' => 'text',
                        'consumer' => new Map<String,String>{
                            'name' => 'name'
                        },
                        'id' => 'id'
                    }
                }
            }
        }));
        RestContext.request = req;

        Test.setMock(HttpCalloutMock.class, new IntegrationTrustPilot_Mock()); 

        String token = IntegrationTrustpilot.getToken();
        System.assertEquals('token', token, 'getToken - error wrong result');

        List<CustomerReview__c> review = new List<CustomerReview__c>{new CustomerReview__c(
            ExternalIDReview__c = 'ExternalIDReview__c',
            ReplyText__c = 'ReplyText__c'
        )};
        List<String> error = TrustpilotPostReplyInvocable.postReplyInvocable(review);
        System.assertEquals(null, error[0], 'postReply - error wrong result');
        
        List<Account> account = [SELECT Id, PersonEmail, Name FROM Account LIMIT 1];
        List<String> link = TrustpilotGetInvitationLinkInvocable.getInvitationLink(account);
        System.assertEquals('url', link[0], 'getInvitationLink - error wrong result');
        
        IntegrationTrustpilot.eventListener();
        System.assertEquals(1, [SELECT Id FROM CustomerReview__c].size(), 'eventListener - error, review not created');

        Test.stopTest();
    }
}