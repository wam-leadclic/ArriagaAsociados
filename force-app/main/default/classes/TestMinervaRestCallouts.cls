/*
@author LeadClic Solutions S.L.
@date 11/09/2019
@description Clase test que recorre la clase de minerva

FECHA             AUTOR           ACCION
11/09/2019      LCS - RDM         Creación.
 
*/
@isTest
public class TestMinervaRestCallouts {  
    @testSetup static void crearCustomSettings() {
        TestAux.crearIntegracionGD();
        TestAux.crearDatosProd();
        TestAux.crearDatosMinerva();
        
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
             
    }

    // ----------- Clases Mock ----------- //
    // ---- Token ---- //
        public class MockHttpResponseToken implements HttpCalloutMock {
            // Implement this interface method
            public HTTPResponse respond(HTTPRequest req) {            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token":"eyKLÑJALKDJALKlkjdkjadi5687hdajhKJDLK"}');
                res.setStatusCode(200);
                return res;
            }
        }
        public class MockHttpResponseTokenKO implements HttpCalloutMock {
            // Implement this interface method
            public HTTPResponse respond(HTTPRequest req) {            
                // Create a fake response
                HttpResponse res = new HttpResponse();
                res.setStatusCode(400);
                return res;
            }
        }
    
    // ---- Minerva ---- //
    	// ---- Contacto ---- //
            public class MockHttpResponseMinCrearContacto implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                    +'"id": 590000173,'
                                    +'"firstName": "RosaII",'
                                    +'"lastName": "CabrejaIIs",'
                                    +'"secondLastName": "",'
                                    +'"fullName": "RosaII CabrejaIIs ",'
                                    +'"email": "rosaaacabrejas99@leadexample.com",'
                                    +'"phone": "123456789",'
                                    +'"mobile": "123466789",'
                                    +'"idCard": "31052768D"'
                                +'}');
                    res.setStatusCode(201);
                    return res;
                }
            }
            public class MockHttpResponseMinCrearContactoUpdate implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                    +'"id": 590000173,'
                                    +'"firstName": "Dorolice",'
                                    +'"lastName": "Hadenton",'
                                    +'"secondLastName": "Dyter",'
                                    +'"fullName": "Dorolice Hadenton Dyter",'
                                    +'"email": "ddyter0@ox.ac.uk",'
                                    +'"phone": "9096303429",'
                                    +'"mobile": "1876348788",'
                                    +'"idCard": "31052768D"'
                                +'}');
                    res.setStatusCode(200);
                    return res;
                }
            }
            public class MockHttpResponseMinCrearContactoKo implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                    +'"type": "https://httpstatuses.com/500",'
                                    +'"title": "Internal Server Error",'
                                    +'"status": 500'
                                +'}');
                    res.setStatusCode(500);
                    return res;
                }
            }
    	// ---- Expediente ---- // 
            public class MockHttpResponseMinCrearExp implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                    +'"id": 11000,'
                                    +'"amount": "150,00 €",'
                                    +'"lawyer": "string",'
                                    +'"externalLawyer": "string",'
                                    +'"solicitor": "string",'
                                    +'"opponent": "string",'
                                    +'"created": "2019-09-12T06:37:29.7566667+00:00",'
                                    +'"productId": 1,'
                                    +'"jurisdictionId": 1,'
                                    +'"expedientCustomers": ['
                                        +'1'
                                    +'],'
                                    +'"isInternal": false,'
                                    +'"powerOfAttorney": false,'
                                    +'"isClosed": false'
                                +'}');
                    res.setStatusCode(201);
                    return res;
                }
            }  
            public class MockHttpResponseMinCrearExpKo implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                    +'"type": "https://httpstatuses.com/500",'
                                    +'"title": "Internal Server Error",'
                                    +'"status": 500'
                                +'}');
                    res.setStatusCode(500);
                    return res;
                }
            } 
    	// ---- Delete ---- // 	
            public class MockHttpResponseMinDelExp implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setStatusCode(204);
                    return res;
                }
            }
            public class MockHttpResponseMinDelExpKo implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setStatusCode(404);
                    return res;
                }
            }
    // ---- Producción ---- //
    	// ---- Contacto ---- //
            public class MockHttpResponseProdCrearContacto implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                    +'"data": {' 
                                        +'"type": "clients",' 
                                        +'"id": "45",' 
                                        +'"attributes": {' 
                                            +'"crm_id": "9333555",' 
                                            +'"name": "JULIÁN",' 
                                            +'"lastname": "DE LA VIEJA",' 
                                            +'"email": "julian4@delavieja.es",' 
                                            +'"cellphone": "666555444",' 
                                            +'"address": "C/ Varsovia, 28 - 3º (Sobreático)",'
                                            +'"codpos": "08065",' 
                                            +'"poblacion": "Barcelona",' 
                                            +'"dni": "53426178F",' 
                                            +'"created": "2019-06-21T06:40:44+00:00",' 
                                            +'"modified": "2019-06-21T06:40:44+00:00",' 
                                            +'"token": "f202524fcb4c46979d98ec9b55ae9f82",' 
                                            +'"token_expiration": "2019-06-22T06:40:44+00:00",' 
                                            +'":fs": {},'
                                            +'"accepts_privacy": "0",' 
                                            +'"accepts_marketing": "0",' 
                                            +'"web_dni_files": []' 
                                        +'},' 
                                        +'"links": {' 
                                            +'"self": "https://sandbox-api.arriaga.io/api/clients/clients/45.json"' 
                                        +'}' 
                                    +'}'
                                +'}');
                    res.setStatusCode(200);
                    return res;
                }
            }
            public class MockHttpResponseProdCrearContactoUpdate implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{' 
                                    +'"data": {' 
                                        +'"type": "clients",' 
                                        +'"id": "45",' 
                                        +'"attributes": {' 
                                            +'"crm_id": "9333555",' 
                                            +'"name": "JULIÁN",' 
                                            +'"lastname": "DE LA VIEJA",' 
                                            +'"email": "julian4@delavieja.es",' 
                                            +'"cellphone": "666555444",' 
                                            +'"address": "C/ Varsovia, 28 - 3º (Sobreático)",' 
                                            +'"codpos": "08065",'
                                            +'"poblacion": "Barcelona",' 
                                            +'"dni": "53426178F",' 
                                            +'"created": "2019-06-21T06:40:44+00:00",' 
                                            +'"modified": "2019-06-21T06:40:44+00:00",' 
                                            +'"token": "f202524fcb4c46979d98ec9b55ae9f82",' 
                                            +'"token_expiration": "2019-06-22T06:40:44+00:00",' 
                                            +'":fs": {},'
                                            +'"accepts_privacy": "0",'
                                            +'"accepts_marketing": "0",'
                                            +'"web_dni_files": []'
                                        +'},' 
                                        +'"links": {' 
                                            +'"self": "https://sandbox-api.arriaga.io/api/clients/clients/45.json"' 
                                        +'}'
                                    +'}' 
                                +'}');
                    res.setStatusCode(200);
                    return res;
                }
            }
            public class MockHttpResponseProdCrearContactoKo implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{' 
                                    +'"url": "/api/clients/clients/12.json",' 
                                    +'"code": 422,' 
                                    +'"message": "Validation errors",' 
                                    +'"errors": {' 
                                        +'"name": "Name cannot be empty",' 
                                        +'"email": "Email already used"' 
                                    +'}'
                                +'}');
                    res.setStatusCode(422);
                    return res;
                }
            }
            public class MockHttpResponseProdCrearContacto300 implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{' 
                                    +'"url": "/api/clients/clients/12.json",' 
                                    +'"code": 422,' 
                                    +'"message": "Validation errors",' 
                                    +'"errors": {' 
                                        +'"name": "Name cannot be empty",' 
                                        +'"email": "Email already used"' 
                                    +'}'
                                +'}');
                    res.setStatusCode(300);
                    return res;
                }
            }
    	// ---- Expediente ---- //
            public class MockHttpResponseProdCrearExp implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('');
                    res.setStatusCode(200);
                    return res;
                }
            }
            public class MockHttpResponseProdCrearExpKo implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('');
                    res.setStatusCode(422);
                    return res;
                }
            }
            public class MockHttpResponseProdCrearExp300 implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('');
                    res.setStatusCode(300);
                    return res;
                }
            }
    // ----------- Clases Test ----------- //
        // ---- Token ---- //
            @isTest static void testGetTokenOK(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseToken()); 
                    MinervaRestCallouts.getAuthToken();
                System.Test.stopTest();
            }
            @isTest static void testGetTokenKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTokenKO()); 
                    MinervaRestCallouts.getAuthToken();
                System.Test.stopTest();
            }
        // ---- Futuro Minerva ---- //
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearContacto());
                	MinervaRestCallouts.futureSendWSMinerva(mDatosExpyCuenta, null);
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
                insert Exp;
                
                Pago__c pago = new Pago__c();
                    pago.Expediente__c = Exp.Id;
                    pago.PrecioTotal__c = 100;
                    pago.Estado__c = Label.EstadoPagoConfirmado;
                insert pago;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearExp());
                	MinervaRestCallouts.futureSendWSMinerva(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoMinervaContactoKo(){
                
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
                	prod.ExternalId__c = '53';
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
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearContactoKo());
                	MinervaRestCallouts.futureSendWSMinerva(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoMinervaExpedienteKo(){
                
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
                insert Exp;
                
                Pago__c pago = new Pago__c();
                    pago.Expediente__c = Exp.Id;
                    pago.PrecioTotal__c = 100;
                    pago.Estado__c = Label.EstadoPagoConfirmado;
                insert pago;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearExpKo());
                	MinervaRestCallouts.futureSendWSMinerva(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoMinervaContactoCatch(){        
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();                
                    try{
                        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearContacto());
                        MinervaRestCallouts.futureSendWSMinerva(mDatosExpyCuenta, null);
                    }catch(Exception e){}
                system.Test.stopTest();  
            }
            @isTest static void testFuturoMinervaContactoUpdateCatch(){        
                
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
                	ac.IdOrigen__c = '1958625';
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearContacto());
                	MinervaRestCallouts.futureSendWSMinerva(mDatosExpyCuenta, null);
                system.Test.stopTest();  
            }    
            @isTest static void testFuturoMinervaContactoUpd(){
                
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
                
                List<Id> lAc = new List<Id>();
                	lAc.add(ac.Id);
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearContactoUpdate());                	
                	MinervaRestCallouts.futureSendWSMinerva(null, lAc);
                system.Test.stopTest();                
            }
        // ---- Futuro Producción ---- //  
            @isTest static void testFuturoProdContactoUpd(){
                
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
                
                List<Id> lAc = new List<Id>();
                	lAc.add(ac.Id);
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinCrearContacto());
                	
                	MinervaRestCallouts.futureSendWSProd(null, lAc);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoProdContacto(){
                
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearContacto());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoProdExpediente(){
                
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
                insert Exp;
                
                Pago__c pago = new Pago__c();
                    pago.Expediente__c = Exp.Id;
                    pago.PrecioTotal__c = 100;
                    pago.Estado__c = Label.EstadoPagoConfirmado;
                insert pago;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearExp());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoProdContactoKo(){
                
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
                	prod.ExternalId__c = '53';
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
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearContactoKo());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoProdContactoUpdateKo(){        
                
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
                	ac.IdOrigen__c = '1958625';
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearContactoKo());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();  
            }
            @isTest static void testFuturoProdExpedienteKo(){
                
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
                insert Exp;
                
                Pago__c pago = new Pago__c();
                    pago.Expediente__c = Exp.Id;
                    pago.PrecioTotal__c = 100;
                    pago.Estado__c = Label.EstadoPagoConfirmado;
                insert pago;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearExpKo());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoProdContactoCatch(){        
                
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();  
            }
            @isTest static void testFuturoProdContactoUpdateCatch(){        
                
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
                	ac.IdOrigenProd__c = '1958625';
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();  
            }
            @isTest static void testFuturoProdContacto300(){
                
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
                	prod.ExternalId__c = '53';
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
                insert Exp;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearContacto300());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
            @isTest static void testFuturoProdExpediente300(){
                
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
                insert Exp;
                
                Pago__c pago = new Pago__c();
                    pago.Expediente__c = Exp.Id;
                    pago.PrecioTotal__c = 100;
                    pago.Estado__c = Label.EstadoPagoConfirmado;
                insert pago;
                
                
                Map<String, Id> mDatosExpyCuenta = new Map<String, Id>();
                	mDatosExpyCuenta.put(Exp.IdExpediente__c, Exp.AccountId);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseProdCrearExp300());
                	MinervaRestCallouts.futureSendWSProd(mDatosExpyCuenta, null);
                system.Test.stopTest();                
            }
        // ---- Delete Minerva---- //
            @isTest static void testDeleteMinerva(){
                
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                List<String> lIdExp = new List<String> ();
                	lIdExp.add(Exp.IdExpediente__c);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinDelExp());
                	MinervaRestCallouts.futureDeleteWSMinerva(lIdExp);
                system.Test.stopTest();                
            }
            @isTest static void testDeleteMinervaKo(){
                
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
                	prod.ExternalId__c = '53';
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
                                
                Contract Exp = new Contract();
                    Exp.AccountId = ac.Id;
                    Exp.Pricebook2Id = standardPricebook.id;
                    Exp.IdExpediente__c = opp.NumeroExpediente__c;
                    Exp.Oportunidad__c = opp.id;
                insert Exp;
                
                
                List<String> lIdExp = new List<String> ();
                	lIdExp.add(Exp.IdExpediente__c);
                
                
                system.Test.startTest();
                	Test.setMock(HttpCalloutMock.class, new MockHttpResponseMinDelExpKo());
                	MinervaRestCallouts.futureDeleteWSMinerva(lIdExp);
                system.Test.stopTest();                
            }
        // ---- Delete Prod---- //
    		@isTest static void testDeletProda(){  
                List<String> lIdExp = new List<String> ();      
                system.Test.startTest();
                	MinervaRestCallouts.futureDeleteWSProd(lIdExp);
                system.Test.stopTest();  
    		}

}