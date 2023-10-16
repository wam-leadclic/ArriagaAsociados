@RestResource(urlMapping='/googleEventListener')
global without sharing class IntegrationGoogle {
    private static final String JWT_HEADER = '{"alg":"RS256","typ":"JWT"}';
    private static final string secretkey = 'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDI7aepAEdGmekg3dLd0xgpKx/B0nrVHr2XWfzkODCFVrE+owSr+6DLErN2mv95W5RVkEi6g7woVMDtXvdeqBRAPwmWNWgJnSLQMDIihMDfpxpMoO92awCM3a0o2Rf/RZkp1w0gHBOEwauVw+Ndu6zZ48Zb+DkDdOi8bBC76cUY9y/ADGP7VMFSAeUPg5cCw+YTv42uJrcmixCkd0Kd9N7ElngQDu4soc2NGIbKCkXbmIvMiOokfa34fefhS44PD7MZ+Xn8uf+FuCQoFHZ7VnoJM9HnEr6yMsknch0BRZ4RfPTGJsslci0egzlhO/EgTCUGPT/Rb8LAfxEHDQE7CCiHAgMBAAECggEANyYj0psk9RfhiQfZjNEX3JTdjpF67WwWlag5ZVqW1sJIu+x6p8nVBGgJohBA9spQGHwVujvWNSuuGHjsZKq1hDzJINVfzOO4XnQcDqVpWvm+mjHCCDquV/uwP3n2wDYWKAnCrIGISfPuaJjvmxacBuIh27Rx0aURDEaNAUbUtlkF1smkgGbvoH6ZYofwk5UpR6yGVtLY/8B6kw/E6yoISJ/8WokyZuN+d/30MfxogS644L0HszIrk9H8ohwMzhZu9Qp6krnrUQEqfEcTCxU6o1f0M2UYdyLfOuwMmnJvqlnFWc5KoXxCzRBGpFisF8Iq89loIOvZWIr2SUcfYltvoQKBgQDnoTxgVvNt80ioKs/1LId5LCJDKfnhjN8reFjsMIitzhhjFfRA+URa1tgcql55IRMqw6+sscFu+GwUcUJswqOLb5wfmK2Le/G+q5D9yeQ+0+oiFL5GBd0MrDlg8dNK2VMvEJW8CuLNS6TUazPBekb/LAY6cDvgqkBYJYGOLt2ThQKBgQDeEX/B62A+X0LcNyt50vdq9RSUwhg6uOc8nlZamShJD+DHdrHq9w1yUhx9tRhwB3CvbjVI1JDiovjUHpBKMtD1HzcL/EOWGIMdvO67Nb2FYCx9ZMjGYAFk2GvOA4FwA18d863NA84ahl9H62V7o8SN4s5GpENHLvJmZABA/N6rmwKBgBpBr7tn/9411sWhXMN5Eb5Nn3CnoHjN5DpkQQg9FDFHjIIm6fI3j2UQt5zAP0dR1X9igVZ9K+UtaesDT7lOcwWKWFNIlluaaDPp9Nyf9yycDw1f9pWvcnhOSY7QutfgPMq4AZE4Vq9Y5M1jfZFwD/46+lXDhTYZdoPHdKEudNWVAoGBAKCaHUB83xUcxfkHuVyYs7FZ3/GZ0fYeJbYUeTV6kMUOQ61d7VyWIdZtBgfwAeV7rAZj+QtcGBCgdr7J/+Z5i9/LHH+BiMuznJfUPP+N5SvhmytwyTeW1Us+rfDHXkRJW/AIfMjJmLRcO+qCltltXkiTIEW8pJ+Fl29voTNe7hdDAoGBAL0dwAOTTdbhhas64TaQF2BmClcqHSDsYZ17sQiZl1xIEZPIbngE5i07mYhveqRDaMHRS6aQ/N6ucGcbbjb5g52kkopoSg9aFJOvElmMfCVVS2Y5HvDcPPoeGrO5Zln5S1+B+qYxduwTTIZ6Up3WFlg9mq4eHSgqT+abyJ1v6YgY';
    private static final string accountId = '111375206075600660460'; //id for new project service acc

    @HttpPost
    global static void eventListener() {
        try {
            RestRequest req = RestContext.request;

            Map<String,Object> requestBody = (Map<String,Object>) JSON.deserializeUntyped(req.requestBody.toString());
            Map<String,Object> message = (Map<String,Object>) requestBody.get('message');

            String decodedData = EncodingUtil.base64Decode((String) message.get('data')).toString();
            system.debug('NOTIFICATION: ' + decodedData);

            Map<String,String> dataMap = (Map<String,String>) JSON.deserialize(decodedData, Map<String,String>.class);
            handleNewReview(getReviewData((dataMap.get('review'))), dataMap.get('location'));
        } catch (Exception e) {
            System.debug(e.getCause());
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }

    public static Map<String,Object> getReviewData(String reviewId) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('authorization', 'Bearer ' + getToken());
        req.setEndpoint('https://mybusiness.googleapis.com/v4/' + reviewId);
        req.setTimeout( 120000 );

        HttpResponse res = new Http().send(req);

        system.debug(res);
        system.debug(res.getBody());

        return (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
    }

    public static void handleNewReview(Map<String,Object> reviewData, String location) {
        Map<String,Object> reviewer = (Map<String,Object>) reviewData.get('reviewer');

        Integer stars;
        switch on (String) reviewData.get('starRating') {
            when 'ONE' {
                 stars = 1;
            }
            when 'TWO' {
                 stars = 2;
            }
            when 'THREE' {
                 stars = 3;
            }
            when 'FOUR' {
                 stars = 4;
            }
            when 'FIVE' {
                 stars = 5;
            }
        }
        System.debug(location);
        System.debug(location.replaceAll('accounts/.*/',''));

        Id oficinaId;
        List<Account> oficina = [SELECT Id FROM Account WHERE IdExternoOficina__c =: location.replaceAll('accounts/[0-9]*/','')];
        if(oficina.size() > 0) {
            oficinaId = oficina.get(0).Id;
        }

        upsert new CustomerReview__c(
            ExternalIDReview__c = (String) reviewData.get('name'),
            ReviewText__c = (String) reviewData.get('comment'),
            Stars__c = stars,
            UserNickname__c = (String) reviewer.get('displayName'),
            Platform__c = 'Google',
            Location__c = oficinaId
        ) ExternalIDReview__c;
    }

    public static List<String> postReply(List<CustomerReview__c> reviews) {
        List<String> responses = new List<String>();
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('authorization', 'Bearer ' + getToken());
        req.setTimeout( 120000 );
        for(CustomerReview__c review : reviews) {
            req.setEndpoint('https://mybusiness.googleapis.com/v4/' + review.ExternalIDReview__c + '/reply');
            req.setBody(JSON.serialize(new Map<String,String> {'comment' => review.ReplyText__c}));
            
            HttpResponse res = new Http().send(req);
            if(res.getStatus() != 'OK') {
                responses.add(res.toString() + ' ' + res.getBody());
            }
        }

        return responses;
    }

    public static String generateJWT() {
        String claimSet = JSON.serialize(new Map<String,Object>{
            'iss' => 'my-business-delegated-integrat@arriaga-mybusiness.iam.gserviceaccount.com',
            // 'sub' => 'marketing@arriagaasociados.com',
            'sub' => 'pavilla@arriagaasociados.com',
            'scope' => 'https://www.googleapis.com/auth/business.manage',
            'aud' => 'https://oauth2.googleapis.com/token',
            'exp' => Datetime.now().addMinutes(5).getTime() / 1000,
            'iat' => Datetime.now().getTime() / 1000
        });

        String text = EncodingUtil.base64Encode(Blob.valueOf(JWT_HEADER)) + '.' + EncodingUtil.base64Encode(Blob.valueOf(claimSet));

        String textUrlEncoded = base64url(text);

        Blob signature = Crypto.sign('RSA-SHA256', Blob.valueOf(textUrlEncoded), EncodingUtil.base64Decode(secretkey));

        string result = textUrlEncoded + '.' + base64Url(EncodingUtil.base64Encode(signature));

        return result;
    }
    
    private static String base64url(String s) {
        s = s.replaceAll('\\+', '-');
        s = s.replaceAll('/', '_');
        s = s.replaceAll('=', '');
        return s;
    }
    
    public static String getToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://oauth2.googleapis.com/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        String jwt = generateJWT();

        req.setBody('grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + EncodingUtil.urlEncode(jwt, 'UTF-8'));
        
        HttpResponse res = new Http().send(req);

        return (String) ((Map<String,Object>) JSON.deserializeUntyped(res.getBody())).get('access_token');
    }
}