@isTest
private class SchFiltersControllerTest {
    @isTest static void testGetMetadataFilter() {

        Account oficina = new Account(Name = 'Test Oficina', ShippingState = 'Madrid', Phone = '6000000000');
        insert oficina;   

        Map<Object, Object> mParams = new Map<Object, Object>();
        mParams.put('Oficina__c', oficina.Id);

        Map<Object, Object> params = new Map<Object, Object>();
        params.put('filterValues',mParams);
        Test.startTest();
        SchFiltersController.getMetadataFilter(params);
        Test.stopTest();
    }
}