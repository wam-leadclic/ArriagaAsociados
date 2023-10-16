@RestResource(urlMapping='/eventListener')
global without sharing class IntegrationTrustPilot {
    @HttpPost
    global static void eventListener() {
        RestRequest req = RestContext.request;

        Payload payload = (Payload) JSON.deserialize(req.requestBody.toString(), Payload.class);
        List<CustomerReview__c> reviews = new List<CustomerReview__c>();
        CustomerReview__c review;
        for(Event event : payload.events) {
            if(event.eventName != 'service-review-deleted') {
                review = new CustomerReview__c(
                    ToProcess__c = true,
                    Platform__c = 'TrustPilot',
                    Stars__c = event.eventData.stars,
                    ExternalIDReview__c = event.eventData.id,
                    ReviewTitle__c = event.eventData.title,
                    ReviewText__c = event.eventData.text,
                    UserNickname__c = event.eventData.consumer.name,
                    UserEmail__c = getPrivateInfo(event.eventData.id)
                );
            }

            reviews.add(review);
        }

        upsert reviews ExternalIDReview__c;
        // upsert reviews;
    }
    
    public static String getToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Trustpilot_Get_Oauth_Token');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=password&username=victor.sainzgimeno@mail-bip.com&password=Bipconsulting01');

        HttpResponse res = new Http().send(req);
        system.debug(res.getBody());
        Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

        return (String) responseBody.get('access_token');
    }

    public static String getPrivateInfo(String reviewId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Trustpilot_Get_Private_Info/' + reviewId);
        setAuthHeader(req);
        req.setMethod('GET');
        req.setTimeout( 120000 );

        HttpResponse res = new Http().send(req);
        system.debug(res.getBody());
        Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());

        return (String) responseBody.get('referralEmail');
    }

    public static String postReply(List<CustomerReview__c> review) {
        HttpRequest req = new HttpRequest();
        setAuthHeader(req);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout( 120000 );

        String errorString = '';
        for(CustomerReview__c singleReview : review) {
            req.setEndpoint('callout:Trustpilot_Get_Private_Info/' + singleReview.ExternalIDReview__c + '/reply');
            req.setBody(JSON.serialize(new Map<String,String> {
                'message' => singleReview.ReplyText__c
            }));
            
            HttpResponse res = new Http().send(req);
            
            if(res.getStatusCode() != 201) {
                errorString += res.toString();
            }
        }

        return errorString == '' ? null : errorString;
    }

    public static List<String> getInvitationLink(List<Account> accounts) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Trustpilot_Get_Invitation_Link');
        setAuthHeader(req);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout( 120000 );

        List<String> links = new List<String>();
        for(Account account : accounts) {
            if(String.isNotBlank(account.PersonEmail)) {
                req.setBody(JSON.serialize(new Map<String,String> {
                    'locationId' => 'Arriaga Associados',
                    'referenceId' => account.Id,
                    'email' => account.PersonEmail,
                    'name' => account.Name,
                    // 'tags' => null,
                    // 'redirectUri' => null,
                    'locale' => 'es-ES'
                }));
            
                HttpResponse res = new Http().send(req);

                links.add((String) ((Map<String,Object>) JSON.deserializeUntyped(res.getBody())).get('url'));
            } else {
                // TO AVOID "System.JSONException: no content to map to Object due to end of input" IN FLOW
                links.add('');
            }
        }

        return links;
    }

    private static void setAuthHeader(HttpRequest req) {
        req.setHeader('Authorization', 'Bearer ' + getToken());
    }

    private class Payload {
        List<Event> events;
    }
    
    private class Event {
        String eventName;
        String version;
        EventData eventData;
    }
    
    private class EventData {
        String id;
        String language;
        Integer stars;
        String title;
        String text;
        String locationId;
        String referenceId;
        String createdAt;
        String link;
        Boolean isVerified;
        Consumer consumer;
        List<Map<String,String>> tags;
    }
    
    private class Consumer {
        String id;
        String name;
        String link;
    }
}