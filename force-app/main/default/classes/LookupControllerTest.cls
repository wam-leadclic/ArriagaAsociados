@isTest
private class LookupControllerTest {
    @isTest static void testGetCustomLookupResults() {
        
        List<Account> lAccToInsert = new List<Account>();
        Account accTest = new Account(Name = 'Test Acc', Phone = '1234');
        Account accTestSelectedId = new Account(Name = 'Test2 Acc', Phone = '1233');
        lAccToInsert.add(accTest); 
        lAccToInsert.add(accTestSelectedId); 
        insert lAccToInsert;
        List<Id> lId = new List<Id>{accTestSelectedId.Id};

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = accTest.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        Test.startTest();
        LookupController.getCustomLookupResults('Test*', lId, 'Phone = \'1234\'', 'Account', 'Phone');
        Test.stopTest();
    }
}