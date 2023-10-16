@isTest
private class LookupSearchResultTest {
    @isTest static void testSearchResult() {
        Account acc = new Account(Name = 'Test acc', Phone = '6000000000');
        insert acc;
        Test.startTest();
        LookupSearchResult lsr = new LookupSearchResult(acc.Id, 'Account', 'icon', 'title', 'subtitle');

        lsr.getId();
        lsr.getSObjectType();
        lsr.getIcon();
        lsr.getTitle();
        lsr.getSubtitle();
        Test.stopTest();
    }
}