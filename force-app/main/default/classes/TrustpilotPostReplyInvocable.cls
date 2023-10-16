public with sharing class TrustpilotPostReplyInvocable {
    @InvocableMethod(label='Post Reply to Trustpilot' category='Resenas' callout=true)
    public static List<String> postReplyInvocable(List<CustomerReview__c> review) {
        return new List<String>{IntegrationTrustPilot.postReply(review)};
    }
}