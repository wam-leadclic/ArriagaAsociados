@isTest
public class ResyncButtonControllerTest {

    @testSetup static void crearCustomSettings() {
        TestAux.crearIntegracionGD();
        TestAux.crearDatosProd();
        TestAux.crearDatosMinerva();
        
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
    }
    
     @isTest static void testFuturoMinervaContacto(){
                
        Account ac = new Account();
            ac.FirstName = 'Test';
            ac.LastName = 'TestII';
            ac.PersonEmail = 'Test@gmail.com';
            ac.CorreoElectronicoSecundario__c = 'TestII@gmail.com';
            ac.Phone = '698523654';
            ac.PersonMobilePhone = '654789632';
            ac.ShippingCity = 'Madrid';
            ac.ShippingCountry = 'España';
            ac.ShippingPostalCode = '28924';
            ac.ShippingState = 'Madrid';
            ac.ShippingStreet = 'Calle del Retiro';
            ac.TipoDocumento__c = 'NIF';
            ac.DocumentoIdentidad__c = '75875743P';
            ac.DeseoRecibirComunicacionesComerciales__pc = true;
            ac.AceptoPoliticaPrivacidad__pc = true;
            ac.Sexo__pc = 'Hombre';
            ac.PoderNotarial__c = 'Sin facultad de cobro';
            ac.IBAN__pc = 'ES1220393718275012191913';
            ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            ac.EstadoCuenta__c='Cliente';
        insert ac;
        
        Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'TestII';
        insert c;
        
        system.Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TestMinervaRestCallouts.MockHttpResponseMinCrearContacto());
            ResyncButtonController.sendData(ac.Id);
        system.Test.stopTest();                
    }
    
   	
    @isTest static void testFuturoMinervaExpediente(){
                
                Account ac = new Account();
                    ac.FirstName = 'Test';
                    ac.LastName = 'TestII';
                    ac.PersonEmail = 'Test@gmail.com';
                    ac.CorreoElectronicoSecundario__c = 'TestII@gmail.com';
                    ac.Phone = '698523654';
                    ac.PersonMobilePhone = '654789632';
                    ac.ShippingCity = 'Madrid';
                    ac.ShippingCountry = 'España';
                    ac.ShippingPostalCode = '28924';
                    ac.ShippingState = 'Madrid';
                    ac.ShippingStreet = 'Calle del Retiro';
                    ac.TipoDocumento__c = 'NIF';
                    ac.DocumentoIdentidad__c = '75875743P';
                    ac.DeseoRecibirComunicacionesComerciales__pc = true;
                    ac.AceptoPoliticaPrivacidad__pc = true;
                    ac.Sexo__pc = 'Hombre';
                    ac.PoderNotarial__c = 'Sin facultad de cobro';
                    ac.IBAN__pc = 'ES1220393718275012191913';
                    ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
                    ac.EstadoCuenta__c='Cliente';
                	ac.IdOrigen__c = '53000026';
                insert ac;
                
                Contact c = new Contact();
                    c.FirstName = 'Test';
                    c.LastName = 'TestII';
                insert c;
                
                // Se crea Pricebook2, cogiendo el Id de la lista standard
                Pricebook2 standardPricebook = new Pricebook2(
                    Id = Test.getStandardPricebookId(),
                    IsActive = true
                );
                //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
                update standardPricebook;
                
                Product2 prod = new Product2();
                    prod.Name = 'test Prod'; 
                    prod.IsActive = true;
                	prod.ExternalId__c = '52';
                insert prod;
                
                Opportunity opp = new Opportunity();
                    opp.AccountId = ac.id;
                    opp.StageName = 'Prospecting';      
                    opp.Name = 'Test';
                    opp.Pricebook2Id = standardPricebook.id;
                    Opp.CloseDate = date.valueOf(system.now());
                insert opp;
                
                OpportunityContactRole opprole = new OpportunityContactRole();
                    opprole.ContactId = c.Id;
                    opprole.Role = 'Titular';
                    opprole.IsPrimary = true;
                    opprole.OpportunityId = opp.id;
                insert opprole;
                
                OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId = opp.Id;
                    oli.Product2Id = prod.Id;
                    oli.Quantity = 1;
                    oli.UnitPrice = 100;
                insert oli;
                
                Opportunity oppNum = [SELECT Id, NumeroExpediente__c FROM Opportunity WHERE Id =:opp.Id];
                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = oppNum.NumeroExpediente__c;
                    Exp.Oportunidad__c = oppNum.id;
                    Exp.Status='';
                    Exp.EstadoExpedienteComunidad__c='';                    
                insert Exp;
                
                Pago__c pago = new Pago__c();
                    pago.Expediente__c = Exp.Id;
                    pago.PrecioTotal__c = 100;
                    pago.Estado__c = Label.EstadoPagoConfirmado;
                insert pago;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new TestMinervaRestCallouts.MockHttpResponseMinCrearExp());
                	ResyncButtonController.sendData(Exp.Id);
                system.Test.stopTest();                
            }
    
    		@isTest static void tetsNull(){
                
           
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new TestMinervaRestCallouts.MockHttpResponseMinCrearExp());
                	ResyncButtonController.sendData(null);
                system.Test.stopTest();                
            }

    
}