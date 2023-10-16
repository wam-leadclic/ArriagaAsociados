@isTest
private class SchProductInfoControllerTest {
    
    @TestSetup
    static void setup(){
        Lead l = SchDataTest.createLead();
        insert l;

        Product2 prod = new Product2 (Name = 'Test Prod', IsActive = true, ExternalId__c = '123', DuracionEntrevista__c = 30);
        insert prod;

        LeadProduct__c leadProd = new LeadProduct__c(Candidato__c = l.Id, Producto__c = prod.Id);
        insert leadProd;
    }

    @isTest static void testRetrieveCurrentProducts() {
        
        Id leadId = [SELECT Id FROM Lead LIMIT 1].Id;

        Test.startTest();
        SchProductInfoController.retrieveCurrentProducts(leadId);
        Test.stopTest();
    }

    @isTest static void testGetAppointmentDuration() {

        Id prodId = [SELECT Id FROM Product2 LIMIT 1].Id;

        Test.startTest();
        SchProductInfoController.getAppointmentDuration(new List<String>{prodId});
        Test.stopTest();
    }
}