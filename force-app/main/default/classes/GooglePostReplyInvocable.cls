public with sharing class GooglePostReplyInvocable {
    @InvocableMethod(label='Post Reply to Google Review' category='Resenas' callout=true)
    public static List<String> postReplyInvocable(List<CustomerReview__c> reviews) {
        return IntegrationGoogle.postReply(reviews);
    }
}