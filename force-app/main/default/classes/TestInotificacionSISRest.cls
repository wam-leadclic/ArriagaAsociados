/*
@author Leadclic Solutions S.L.
@date 15/07/2019
@description Clase test para el tratamiento de las llamdas a Redsys mediante el merchantURL

<pre>
FECHA               AUTOR   
15/07/2019			LCS - RDM		Creación 
04/09/2019			LCS - RDM		Modificación. Subida de % de cobertura
31/03/2020			LCS - RAL		Modificación. Se añade el teléfono en la creación de cuenta

</pre>
*/
@isTest
public class TestInotificacionSISRest {
    
    @testSetup static void crearCustomSettings() {
        TestAux.crearDatosRedsys();
        TestAux.crearDatosFlujo();
        TestAux.crearProducto();
        TestAux.crearRedsysCodigoRespuesta();
    }
    
    /*******CLASES MOCK*******/
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }    
    
    public class MockHttpResponseGeneratorFirmaok_ko implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('slAlBC9h2aL/dJBTunkuzHUWYf1JKzn33Ldd++4u5fM=');
            res.setStatusCode(200);
            return res;
        }
    }    
    
    public class MockHttpResponseGeneratorFirmaok_ok implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            //System.assertEquals('http://example.com/example/test', req.getEndpoint());
            //System.assertEquals('GET', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('V/KqVymKT/xW7tfuhhDz9OYKd2fuXn8+8QwL9jyTKxM=');
            res.setStatusCode(200);
            return res;
        }
    }    
    /*******FIN MOCK*******/
    @isTest static void generarFirma()
    {            
        
        String merchparams = 'eyJEU19NRVJDSEFOVF9PUkRFUiI6IjE4MDczMTEyIiwiRFNfTUVSQ0hBTlRfVEVSTUlOQUwiOiIxIiwiRFNfTUVSQ0hBTlRfVVJMT0siOiJodHRwczovL3VlbGlnaHRuaW5nLS1kZXZlbG9wMS5jczg5Lm15LnNhbGVzZm9yY2UuY29tLzgwMTBFMDAwMDAwWG5wdlFBQy9kZXRhaWw/UmVzcG9uc2U9dHJ1ZSIsIkRTX01FUkNIQU5UX1VSTEtPIjoiaHR0cHM6Ly91ZWxpZ2h0bmluZy0tZGV2ZWxvcDEuY3M4OS5teS5zYWxlc2ZvcmNlLmNvbS84MDEwRTAwMDAwMFhucHZRQUMvZGV0YWlsP1Jlc3BvbnNlPXRydWUiLCJEU19NRVJDSEFOVF9USVRVTEFSIjoiUm9zYSBMQ1MiLCJEU19NRVJDSEFOVF9DVVJSRU5DWSI6Ijk3OCIsIkRTX01FUkNIQU5UX1RSQU5TQUNUSU9OVFlQRSI6IjAiLCJEU19NRVJDSEFOVF9NRVJDSEFOVFVSTCI6Imh0dHBzOi8vdWVsaWdodG5pbmctLWRldmVsb3AxLmNzODkubXkuc2FsZXNmb3JjZS5jb20vODAxMEUwMDAwMDBYbnB2UUFDIiwiRFNfTUVSQ0hBTlRfUFJPRFVDVERFU0NSSVBUSU9OIjoiQXB0byIsIkRTX01FUkNIQU5UX01FUkNIQU5UTkFNRSI6IlVOSVZFUlNJREFEIEVVUk9QRUEgREUgTUFEUklEIFMuTC5VLiIsIkRTX01FUkNIQU5UX0FNT1VOVCI6IjUwMCIsIkRTX01FUkNIQU5UX01FUkNIQU5UREFUQSI6IjAxMjEwMTUzODAwRDcyMDE4IiwiRFNfTUVSQ0hBTlRfTUVSQ0hBTlRDT0RFIjoiMzM0ODQyOTM3In0=';
        String KeyComercio = 'sq7HjrUOBfKmC576ILgskD5srU870gJ7';
        RedsysDatosLlamada__c DatosRedsys = RedsysDatosLlamada__c.getInstance('General');
        
        system.test.startTest();
        
        // Set mock callout class 
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
		InotificacionSISRest.generateSignature(merchparams, KeyComercio);
        
        System.test.stopTest();
    }
    
    //*****TEST OK codigo 0000*****/
    @isTest static void okRespuesta()
    {          
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFirmaok_ok());
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '60000000';
        insert ac;   
        
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
        insert prod;
        
        PriceBookEntry pb = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        	opp.Amount = pb.UnitPrice;
        insert opp;        
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline.IDProducto__c = prod.id;
        	ContratOnline.ContrFinalizado__c = true;
        insert ContratOnline;
        
        
        //Añadimos documentos a la oportunidad        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test';      
        cv.PathOnClient ='test';           
        cv.VersionData =blob.valueOf('Test Adjunto');          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=ContratOnline.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
        
        String idOpp = opp.Id;
        String Name = ac.Name;
        
        Blob Decodificando = EncodingUtil.base64Decode('eyJEc19EYXRlIjoiMDYlMkYwOSUyRjIwMTgiLCJEc19Ib3VyIjoiMDglM0EyMSIsIkRzX1NlY3VyZVBheW1lbnQiOiIwIiwiRHNfQW1vdW50IjoiMTAwIiwiRHNfQ3VycmVuY3kiOiI5NzgiLCJEc19PcmRlciI6Ijg4OTAwMDAwMDE2OCIsIkRzX01lcmNoYW50Q29kZSI6IjMzNDg0MjkzNyIsIkRzX1Rlcm1pbmFsIjoiMDAxIiwiRHNfUmVzcG9uc2UiOiIwMDAwIiwiRHNfVHJhbnNhY3Rpb25UeXBlIjoiMCIsIkRzX01lcmNoYW50RGF0YSI6IjAxMjEwMTUzODAwRDcyMDE4IiwiRHNfQXV0aG9yaXNhdGlvbkNvZGUiOiIzMjY4MjQiLCJEc19Db25zdW1lckxhbmd1YWdlIjoiMSIsIkRzX0NhcmRfQ291bnRyeSI6IjcyNCIsIkRzX0NhcmRfQnJhbmQiOiIxIn0=');
        String Parametros = Decodificando.toString();
        Parametros = Parametros.substring(1, Parametros.length()-1);
        
                
        String[] keyValuePairs = Parametros.split(',');
        string pa = '';
        
        Opportunity o = [SELECT NumeroExpediente__c FROM Opportunity WHERE Id =:opp.Id];
        
        for(String pair : keyValuePairs)                        
        {
            pair = pair.replace('"','');
            String[] entry = pair.split(':');
            
            if(entry[0].trim() == 'Ds_Order') entry[1] = '0000'+o.NumeroExpediente__c;
            
            if(pa == '')pa = '{"'+entry[0].trim()+'":"'+ entry[1].trim();
            else pa += ','+entry[0].trim()+'":"'+ entry[1].trim();
        }
        pa+='"}"';
        
         Blob Codificando = Blob.valueOf(pa);		
        String ParametersCodec = EncodingUtil.base64Encode(Codificando);
        
        system.test.startTest();

           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
            req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/InotificacionSIS';  //Request URL
        
            req.addParameter('Ds_MerchantParameters', ParametersCodec);
            req.addParameter('Ds_Signature','V_KqVymKT_xW7tfuhhDz9OYKd2fuXn8-8QwL9jyTKxM=');
            req.addParameter('Ds_SignatureVersion', 'HMAC_SHA256_V1');

        	req.httpMethod = 'POST';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            InotificacionSISRest.notificar();
        System.Test.stopTest();
        
    }
    
    //*****TEST KO codigo 0180*****/
    @isTest static void koRespuesta()
    {        
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFirmaok_ko()); 
         
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFirmaok_ok());
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '60000000';
        insert ac;   
        
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
        insert prod;
        
        PriceBookEntry pb = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        	opp.Amount = pb.UnitPrice;
        insert opp;  
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline.IDProducto__c = prod.id;
        	ContratOnline.ContrFinalizado__c = true;
        insert ContratOnline;
        
        String idOpp = opp.Id;
        String Name = ac.Name;
        
        Blob Decodificando = EncodingUtil.base64Decode('eyJEc19EYXRlIjoiMDUlMkYwOSUyRjIwMTgiLCJEc19Ib3VyIjoiMTMlM0EyNSIsIkRzX1NlY3VyZVBheW1lbnQiOiIwIiwiRHNfQW1vdW50IjoiMTAwIiwiRHNfQ3VycmVuY3kiOiI5NzgiLCJEc19PcmRlciI6Ijg2OTAwMDAwMDE2NiIsIkRzX01lcmNoYW50Q29kZSI6IjMzNDg0MjkzNyIsIkRzX1Rlcm1pbmFsIjoiMDAxIiwiRHNfUmVzcG9uc2UiOiIwMTgwIiwiRHNfVHJhbnNhY3Rpb25UeXBlIjoiMCIsIkRzX01lcmNoYW50RGF0YSI6IjAxMjEwMTUzODAwRDcyMDE4IiwiRHNfQXV0aG9yaXNhdGlvbkNvZGUiOiIrKysrKysiLCJEc19Db25zdW1lckxhbmd1YWdlIjoiMSIsIkRzX0NhcmRfQ291bnRyeSI6IjAifQ==');
        String Parametros = Decodificando.toString();
        Parametros = Parametros.substring(1, Parametros.length()-1);
        
        Opportunity o = [SELECT NumeroExpediente__c FROM Opportunity WHERE Id =:opp.Id];
                
        String[] keyValuePairs = Parametros.split(',');
        string pa = '';
        Map<String,String> mapaParametros = new Map<String,String>();
        for(String pair : keyValuePairs)                        
        {
            pair = pair.replace('"','');            
            String[] entry = pair.split(':');  
            
            if(entry[0].trim() == 'Ds_Order') entry[1] = '0000'+o.NumeroExpediente__c;
            
            if(pa == '')pa = '{"'+entry[0].trim()+'":"'+ entry[1].trim();
            else pa += ','+entry[0].trim()+'":"'+ entry[1].trim();
        }
        pa+='"}"';
        
         Blob Codificando = Blob.valueOf(pa);		
        String ParametersCodec = EncodingUtil.base64Encode(Codificando);
        
        system.test.startTest();

           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
            req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/InotificacionSIS';  //Request URL
        
            req.addParameter('Ds_MerchantParameters', ParametersCodec);
            req.addParameter('Ds_Signature','slAlBC9h2aL/dJBTunkuzHUWYf1JKzn33Ldd++4u5fM=');
            req.addParameter('Ds_SignatureVersion', 'HMAC_SHA256_V1');

        	req.httpMethod = 'POST';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            InotificacionSISRest.notificar();
        System.Test.stopTest();
    } 
    
    //*****TEST KO codigo 9000*****/
    @isTest static void koNoMessageRespuesta()
    {          
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFirmaok_ko()); 
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '60000000';
        insert ac;   
        
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
        insert prod;
        
        PriceBookEntry pb = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        	opp.Amount = pb.UnitPrice;
        insert opp;        
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline.IDProducto__c = prod.id;
        	ContratOnline.ContrFinalizado__c = true;
        insert ContratOnline;
        
        String idOpp = opp.Id;
        String Name = ac.Name;
        
        Blob Decodificando = EncodingUtil.base64Decode('eyJEc19EYXRlIjoiMDYlMkYwOSUyRjIwMTgiLCJEc19Ib3VyIjoiMDglM0EyMSIsIkRzX1NlY3VyZVBheW1lbnQiOiIwIiwiRHNfQW1vdW50IjoiMTAwIiwiRHNfQ3VycmVuY3kiOiI5NzgiLCJEc19PcmRlciI6Ijg4OTAwMDAwMDE2OCIsIkRzX01lcmNoYW50Q29kZSI6IjMzNDg0MjkzNyIsIkRzX1Rlcm1pbmFsIjoiMDAxIiwiRHNfUmVzcG9uc2UiOiIwMDAwIiwiRHNfVHJhbnNhY3Rpb25UeXBlIjoiMCIsIkRzX01lcmNoYW50RGF0YSI6IjAxMjEwMTUzODAwRDcyMDE4IiwiRHNfQXV0aG9yaXNhdGlvbkNvZGUiOiIzMjY4MjQiLCJEc19Db25zdW1lckxhbmd1YWdlIjoiMSIsIkRzX0NhcmRfQ291bnRyeSI6IjcyNCIsIkRzX0NhcmRfQnJhbmQiOiIxIn0=');
        String Parametros = Decodificando.toString();
        Parametros = Parametros.substring(1, Parametros.length()-1);
        
                
        String[] keyValuePairs = Parametros.split(',');
        string pa = '';
        
        Opportunity o = [SELECT NumeroExpediente__c FROM Opportunity WHERE Id =:opp.Id];
        
        for(String pair : keyValuePairs)                        
        {
            pair = pair.replace('"','');
            String[] entry = pair.split(':');
            
            if(entry[0].trim() == 'Ds_Order') entry[1] = '0000'+o.NumeroExpediente__c;
            
            if(pa == '')pa = '{"'+entry[0].trim()+'":"'+ entry[1].trim();
            else pa += ','+entry[0].trim()+'":"'+ entry[1].trim();
        }
        pa+='"}"';
        
         Blob Codificando = Blob.valueOf(pa);		
        String ParametersCodec = EncodingUtil.base64Encode(Codificando);
        
        system.test.startTest();

           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
            req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/InotificacionSIS';  //Request URL
        
            req.addParameter('Ds_MerchantParameters', ParametersCodec);
            req.addParameter('Ds_Signature','V_KqVymKT_xW7tfuhhDz9OYKd2fuXn8-8QwL9jyTKxM=');
            req.addParameter('Ds_SignatureVersion', 'HMAC_SHA256_V1');

        	req.httpMethod = 'POST';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            InotificacionSISRest.notificar();
        System.Test.stopTest();
        
    }
    //*****TEST ERROR FIRMA*****/
    @isTest static void koRespuestaFirma()
    {  
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '60000000';
        insert ac;   
        
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
        insert prod;
        
        PriceBookEntry pb = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        	opp.Amount = pb.UnitPrice;
        insert opp;        
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline.IDProducto__c = prod.id;
        	ContratOnline.ContrFinalizado__c = true;
        insert ContratOnline;
        
        String idOpp = opp.Id;
        String Name = ac.Name;
        
        Blob Decodificando = EncodingUtil.base64Decode('eyJEc19EYXRlIjoiMDYlMkYwOSUyRjIwMTgiLCJEc19Ib3VyIjoiMDglM0EyMSIsIkRzX1NlY3VyZVBheW1lbnQiOiIwIiwiRHNfQW1vdW50IjoiMTAwIiwiRHNfQ3VycmVuY3kiOiI5NzgiLCJEc19PcmRlciI6Ijg4OTAwMDAwMDE2OCIsIkRzX01lcmNoYW50Q29kZSI6IjMzNDg0MjkzNyIsIkRzX1Rlcm1pbmFsIjoiMDAxIiwiRHNfUmVzcG9uc2UiOiIwMDAwIiwiRHNfVHJhbnNhY3Rpb25UeXBlIjoiMCIsIkRzX01lcmNoYW50RGF0YSI6IjAxMjEwMTUzODAwRDcyMDE4IiwiRHNfQXV0aG9yaXNhdGlvbkNvZGUiOiIzMjY4MjQiLCJEc19Db25zdW1lckxhbmd1YWdlIjoiMSIsIkRzX0NhcmRfQ291bnRyeSI6IjcyNCIsIkRzX0NhcmRfQnJhbmQiOiIxIn0=');
        String Parametros = Decodificando.toString();
        Parametros = Parametros.substring(1, Parametros.length()-1);
        
                
        String[] keyValuePairs = Parametros.split(',');
        string pa = '';
        
        Opportunity o = [SELECT NumeroExpediente__c FROM Opportunity WHERE Id =:opp.Id];
        
        for(String pair : keyValuePairs)                        
        {
            pair = pair.replace('"','');
            String[] entry = pair.split(':');
            
            if(entry[0].trim() == 'Ds_Order') entry[1] = '0000'+o.NumeroExpediente__c;
            
            if(pa == '')pa = '{"'+entry[0].trim()+'":"'+ entry[1].trim();
            else pa += ','+entry[0].trim()+'":"'+ entry[1].trim();
        }
        pa+='"}"';
        
         Blob Codificando = Blob.valueOf(pa);		
        String ParametersCodec = EncodingUtil.base64Encode(Codificando);
        
        system.test.startTest();

           RestRequest req = new RestRequest(); 
           RestResponse res = new RestResponse();
        
            req.requestURI = URL.getSalesforceBaseUrl() + '/services/apexrest/InotificacionSIS';  //Request URL
        
            req.addParameter('Ds_MerchantParameters', ParametersCodec);
            req.addParameter('Ds_Signature','V_KqVymKT_xW7tfuhhDz9OYKd2fuXn8-8QwL9jyTKxM=');
            req.addParameter('Ds_SignatureVersion', 'HMAC_SHA256_V1');

        	req.httpMethod = 'POST';//HTTP Request Type
            RestContext.request = req;
            RestContext.response= res;
            InotificacionSISRest.notificar();
        System.Test.stopTest();
    }
}