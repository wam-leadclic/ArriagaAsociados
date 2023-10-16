public with sharing class TrustpilotGetInvitationLinkInvocable {
    @InvocableMethod(label='Get Invitation Link' category='Resenas' callout=true)
    public static List<String> getInvitationLink(List<Account> account) {
        return IntegrationTrustPilot.getInvitationLink(account);
    }
}