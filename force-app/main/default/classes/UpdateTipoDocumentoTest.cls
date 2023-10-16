@isTest
public class UpdateTipoDocumentoTest {
    
    public static Integer prueba;
    
    @testSetup static void crearCustomSettings() {
        TestAux.crearIntegracionSF();
    }
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
    // ---- Token ---- //
    @isTest static void testGetTokenOK(){
        System.Test.startTest();        
            // Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseToken()); 
            UpdateTipoDocumento.getAuthToken();
        System.Test.stopTest();
    }
    // ---- Post ---- //
        @isTest static void testPostTipoDocumentoValue(){
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseResult()); 
                UpdateTipoDocumento.postNewTipoDocumento ('nuevoDoc2', 'nuevoApiDoc');
            System.Test.stopTest();
        }
    // ---- Update ---- //
        @isTest static void testUpdTipoDocumentoValue(){
            TipoDocumento__c tipo=new TipoDocumento__c();
            tipo.TipoDocumento__c='187';
            tipo.ExternalID__c='187';
            tipo.ValorEtiqueta__c='nuevoDoc';
            tipo.VisibleComunidad__c=false;
            tipo.SubidaComunidad__c=false;
            insert tipo;
            System.Test.startTest();        
                // Set mock callout class 
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseResult()); 
                UpdateTipoDocumento.updateGlobal ('187', 'NameDoc', true);
            System.Test.stopTest();
        }
}