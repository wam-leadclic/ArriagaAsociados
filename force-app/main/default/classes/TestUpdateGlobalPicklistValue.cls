/*
@author LeadClic Solutions S.L.
@date 
@description Clase Test para la clase que contiene los métodos para llamar a la API de SF y de esta manera actualizar las lista de valores globales 
<pre>
FECHA             AUTOR           ACCION
04/07/2019      LCS - RDM         Creación.
 
*/
@isTest
public class TestUpdateGlobalPicklistValue {
    
    public static Integer prueba;
    
    @testSetup static void crearCustomSettings() {
        TestAux.crearIntegracionSF();
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
    // ---- GlobalPicklist ---- //
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
    	// ---- Get ---- //
            public class MockHttpResponseResult implements HttpCalloutMock {
                // Implement this interface method
                public HTTPResponse respond(HTTPRequest req) {         
                    // Create a fake response          
                    HttpResponse res = new HttpResponse();
                        res.setHeader('Content-Type', 'application/json');
                    if(TestUpdateGlobalPicklistValue.prueba == 1){ 
                        res.setBody('{"access_token":"eyKLÑJALKDJALKlkjdkjadi5687hdajhKJDLK"}');
                        res.setStatusCode(200);                        
                    }else if(TestUpdateGlobalPicklistValue.prueba == 2){  
                        res.setBody('{'
                                    +    '"attributes":{'
                                    +        '"type":"GlobalValueSet",'
                                    +        '"url":"/services/data/v41.0/tooling/sobjects/GlobalValueSet/0Nt5E0000009KngSAE"'
                                    +    '}'
                                    +    ',"Metadata":{'
                                    +        '"customValue":[{'
                                    +            '"color":null,'
                                    +            '"default":false,'
                                    +            '"description":null,'
                                    +            '"isActive":null,'
                                    +            '"label":"CERTIFICADO DE DEFUNCIÓN",'
                                    +            '"urls":null,'
                                    +            '"valueName":"CERTIFICADO DE DEFUNCIÓN"'
                                    +        '}]'
                                    +    '}'
                                    +'}');
                        res.setStatusCode(200);
                    }else if(TestUpdateGlobalPicklistValue.prueba == 3){   
                        res.setStatusCode(200);
                    }
                    return res;
                }
            }
    // ----------- Clases Test ----------- //
    // ---- Token ---- //
        @isTest static void testGetTokenOK(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseToken()); 
                UpdateGlobalPicklistValue.getAuthToken();
            System.Test.stopTest();
        }
        @isTest static void testGetTokenKO(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseTokenKO()); 
                UpdateGlobalPicklistValue.getAuthToken();
            System.Test.stopTest();
        }
    // ---- Post ---- //
        @isTest static void testPostPicklistValue(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseResult()); 
                UpdateGlobalPicklistValue.postNewGlobal ('nuevoDoc', 'nuevoApiDoc');
            System.Test.stopTest();
        }
    // ---- Update ---- //
        @isTest static void testUpdPicklistValue(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseResult()); 
                UpdateGlobalPicklistValue.updateGlobal ('CERTIFICADO DE DEFUNCIÓN', 'NameDoc', true);
            System.Test.stopTest();
        }
}