/*
@author LeadClic Solutions S.L.
@date 
@description Clase Test para la clase que contiene los métodos para llamar a la API del gestor documental
<pre>
FECHA             AUTOR           ACCION
03/07/2019      LCS - RDM         Creación.
 
*/
@isTest
public class TestGDRestCallouts {
    
    @testSetup static void crearCustomSettings() {
        TestAux.crearIntegracionGD();
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
    // ---- Tipo documento ---- //
            // ---- Error 400 ---- //
            public class MockHttpResponseTypeDocKO implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setStatusCode(400);
                    return res;
                }
            } 
    	// ---- Lista ---- //
            public class MockHttpResponseTypeDocList implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('[{'
                                +   '"id": 4,'
                                +   '"name": "Diligencia Preliminar",'
                                +   '"parentId": 3,'
                                +   '"parent": {'
                                +       '"id": 3,'
                                +       '"name": "Documento AA"'
                                +   '}'
                                +'}]');
                    res.setStatusCode(200);
                    return res;
                }
            }
    	// ---- Delete ---- //
            public class MockHttpResponseTypeDocDelete implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setStatusCode(204);
                    return res;
                }
            }
    	// ---- Insert ---- //
            public class MockHttpResponseTypeDocInsert implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                +   '"id": 116,'
                                +   '"name": "Notificación vista preliminar"'
                                +'}');
                    res.setStatusCode(201);
                    return res;
                }
            }
    	// ---- Update ---- //
            public class MockHttpResponseTypeDocUpdate implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                +   '"id": 116,'
                                +   '"name": "Notificación vista preliminar"'
                                +'}');
                    res.setStatusCode(200);
                    return res;
                }
            }
    // ---- Documento ---- //
    	// ---- Error 400 ---- //
            public class MockHttpResponseDocKO implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setStatusCode(400);
                    return res;
                }
            } 
    	// ---- Lista ---- //
            public class MockHttpResponseDocList implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setHeader('Content-Type', 'application/json');
                    res.setBody('{'
                                +   '"total": 24,'
                                +   '"items": ['
                                +       '{'
                                +           '"id": 211,'
                                +           '"documentType": "Plantilla",'
                                +           '"expedients": ['
                                +               '2'
                                +           '],'
                                +           '"fileName": "hola.txt",'
                                +           '"size": 15,'
                                +           '"contentType": "text/plain",'
                                +           '"created": "2019-05-28T15:01:38.0594032+00:00",'
                                +           '"createdUser": "3e8ea5fe-aa21-4f79-af82-8f4ae132603c"'
                                +       '}],'
                                +   '"totalPages": 1'
                                +'}');
                    res.setStatusCode(200);
                    return res;
                }
            }
    	// ---- Downl ---- //
            public class MockHttpResponseDocDownl implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setStatusCode(200);
                    return res;
                }
            }
    	// ---- Delete ---- //
            public class MockHttpResponseDocDelete implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setStatusCode(204);
                    return res;
                }
            }
    	// ---- Edit ---- //
            public class MockHttpResponseDocEdit implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {            
                    // Create a fake response
                    HttpResponse res = new HttpResponse();
                    res.setStatusCode(200);
                    return res;
                }
            }
    
    
    // ----------- Clases Test ----------- //
    // ---- Token ---- //
        @isTest static void testGetTokenOK(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseToken()); 
                GDRestCallouts.getAuthToken();
            System.Test.stopTest();
        }
        @isTest static void testGetTokenKO(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseTokenKO()); 
                GDRestCallouts.getAuthToken();
            System.Test.stopTest();
        }
    // ---- Tipo documento ---- //
    	// ---- Listado ---- //
            @isTest static void testTypeDocListOK(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocList()); 
                    GDRestCallouts.getTypeDocumentList();
                System.Test.stopTest();
            }
            @isTest static void testTypeDocListKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocKO()); 
                    GDRestCallouts.getTypeDocumentList();
                System.Test.stopTest();
            }
    	// ---- Delete ---- //
            @isTest static void testTypeDocDelOKRefresh(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocDelete()); 
                    GDRestCallouts.deleteTypeDocument('4', true);
                System.Test.stopTest();
            }
            @isTest static void testTypeDocDelOKstatus(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocDelete()); 
                    GDRestCallouts.deleteTypeDocument('4', false);
                System.Test.stopTest();
            }
            @isTest static void testTypeDocDelKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocKO()); 
                    GDRestCallouts.deleteTypeDocument('4', true);
                System.Test.stopTest();
            }
    	// ---- Insert ---- //
            @isTest static void testTypeDocInsRefresh(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocInsert()); 
                    GDRestCallouts.setTypeDocument('', 'Test', true);
                System.Test.stopTest();
            }
            @isTest static void testTypeDocInsStatus(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocInsert()); 
                    GDRestCallouts.setTypeDocument('', 'Test', false);
                System.Test.stopTest();
            }
            @isTest static void testTypeDocInsKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocKO()); 
                    GDRestCallouts.setTypeDocument('', 'Test', false);
                System.Test.stopTest();
            }
    	// ---- Update ---- //
            @isTest static void testTypeDocUpdRefresh(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocUpdate()); 
                    GDRestCallouts.renameTypeDocument('4', 'Test', true);
                System.Test.stopTest();
            }
            @isTest static void testTypeDocUpdStatus(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocUpdate()); 
                    GDRestCallouts.renameTypeDocument('4', 'Test', false);
                System.Test.stopTest();
            }
            @isTest static void testTypeDocUpdKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseTypeDocKO()); 
                    GDRestCallouts.renameTypeDocument('4', 'Test', false);
                System.Test.stopTest();
            }
    // ---- Documento ---- //
    	// ---- Lista ---- //    	
            @isTest static void testDocList(){
                List<String> lCustomer = new List<String>();
                	lCustomer.add('5');
                	lCustomer.add('4');
                List<String> lExpedients = new List<String>();
                	lExpedients.add('53');
                	lExpedients.add('43');
                
                IntegracionGD__c intGD = IntegracionGD__c.getInstance('General');
                	intGD.DebugMode__c = true;
                update intGD;
                
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocList()); 
                    GDRestCallouts.getDocumentList(lCustomer, lExpedients, 5, null, null,false);
                System.Test.stopTest();
            }
            @isTest static void testDocListKO(){
                List<String> lCustomer = new List<String>();
                	lCustomer.add('5');
                	lCustomer.add('4');
                List<String> lExpedients = new List<String>();
                	lExpedients.add('53');
                	lExpedients.add('43');
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocKO()); 
                    GDRestCallouts.getDocumentList(lCustomer, lExpedients, 5, null, null,false);
                System.Test.stopTest();
            }
    	// ---- Downl ---- //  	
            @isTest static void testDocDownl(){                                
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocDownl()); 
                    GDRestCallouts.downloadDocument('4');
                System.Test.stopTest();
            }
            @isTest static void testDocDownlKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocKO()); 
                    GDRestCallouts.downloadDocument('4');
                System.Test.stopTest();
            }
    	// ---- Delete ---- //
            @isTest static void testDocDel(){                                
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocDelete()); 
                    GDRestCallouts.deleteDocument('4');
                System.Test.stopTest();
            }
            @isTest static void testDocDelKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocKO()); 
                    GDRestCallouts.deleteDocument('4');
                System.Test.stopTest();
            }
    	// ---- Edit ---- //
            @isTest static void testDocEdit(){                                
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocEdit()); 
                    GDRestCallouts.editDocument('4', '146', 'nombreDoc', '530000164', '19090000806'); 
                System.Test.stopTest();
            }
            @isTest static void testDocEditKO(){
                System.Test.startTest();        
                    // Set mock callout class 
                    Test.setMock(HttpCalloutMock.class, new MockHttpResponseDocKO()); 
                    GDRestCallouts.editDocument('4', '146', 'nombreDoc', '530000164', '19090000806');
                System.Test.stopTest();
            }
    	
}