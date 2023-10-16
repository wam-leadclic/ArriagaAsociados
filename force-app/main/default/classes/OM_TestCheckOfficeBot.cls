@isTest
private class OM_TestCheckOfficeBot {

    @isTest
    static void testGetAccountByIndex() {
        // Crear datos de prueba
        Account testAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Oficina').getRecordTypeId(),
            ShippingStreet = 'Test Street',
            ShippingState = 'Test State',
            Phone = '1234567890',
            Activa__c = true
        );
        insert testAccount;

        OM_CheckOfficeBot.InputWrapper inputRecord = new OM_CheckOfficeBot.InputWrapper();
        inputRecord.stateName = 'Test State';
        inputRecord.officeNamesInput = null;

        List<OM_CheckOfficeBot.InputWrapper> inputInfo = new List<OM_CheckOfficeBot.InputWrapper>();
        inputInfo.add(inputRecord);

        Test.startTest();
        List<OM_CheckOfficeBot.ReturnWrapper> returnInfo = OM_CheckOfficeBot.getAccountByIndex(inputInfo);
        Test.stopTest();

        System.assertEquals(1, returnInfo.size(), 'No se ha devuelto ninguna oficina');

        OM_CheckOfficeBot.ReturnWrapper returnRecord = returnInfo[0];
        System.assertEquals('Test Account (1234567890)', returnRecord.officeToReturn, 'El nombre de la oficina no es correcto');
        System.assertEquals(0, returnRecord.index, 'El valor del índice no es el correcto');
        System.assertEquals('', returnRecord.officeNamesReturn, 'El valor del listado de oficinas no es el correcto');
    }
}