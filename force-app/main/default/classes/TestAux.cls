/*
@author Leadclic Solutions S.L.
@date 23/08/2017
@description Clase auxiliar para crear los datos necesarios de las clases de test

<pre>
FECHA               AUTOR  
15/04/2019			LCS - RDM            Creación 
03/07/2019			LCS - RDM            Modificación. Se añade las configuraciones necesarias para la clase GDRestCallouts
04/07/2019			LCS - RDM            Modificación. Se añade las configuraciones necesarias para la clase UpdateGlobalPicklistValue  
11/09/2019			LCS - RDM            Modificación. Se añade las configuraciones necesarias para la clase Minerva 
*/
@isTest
public with sharing class TestAux {
    
    public static void crearDatosRedsys(){
        RedsysDatosLlamada__c DatosRedsys = new RedsysDatosLlamada__c();
            DatosRedsys.Name = 'General';
        	DatosRedsys.ClaveCifrado__c ='sq7HjrUOBfKmC576ILgskD5srU870gJ7';
            DatosRedsys.Datocomercio__c = 'Arriaga payment - Data';
            DatosRedsys.NombreComercio__c = 'ARRIAGA ASOCIADOS ASESORAMIENTO JURIDICO Y ECONOMICO S.L.';
            DatosRedsys.FUC__c = '349436543';
        insert DatosRedsys;
    }
    
    public static void crearDatosFlujo(){
        DatosFlujo__c configDatosflujo = new DatosFlujo__c();
        	configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c = 'Calificación';
        	configDatosflujo.EtapaFinalOportunidadContrOnline__c = 'Cerrada ganada';
         insert configDatosflujo;
    }
    
    public static void crearProducto(){
        ProductosContrt__c configPro = new ProductosContrt__c();
        	configPro.Name = 'IRPH';
        	configPro.Activo__c = true;
        	configPro.IdProduct__c = '4513165468751354HHHJK';
        	configPro.NameProduct__c = 'IRPH';
        	configPro.URLArriaga__c = '/s/irph-contratacion';
        	configPro.URLContratacion__c = 'www.arriagaasociado.com';
         insert configPro;
    }
    
    public static void crearExpeDerivados(){
        Datosexpedientederivado__c configExpDer = new Datosexpedientederivado__c();
        	configExpDer.Name = 'General';
        	configExpDer.TiposDeriv__c = 'Reclamación por cantidad, Demanda independiente de cláusula suelo';
         insert configExpDer;
    }    

    public static void crearIntegracionGD(){
        IntegracionGD__c intGD = new IntegracionGD__c();
        	intGD.Name = 'General';
            intGD.claveAddDelete__c = '73bc3ed9-35a9-44ab-8642-dc43ebe64878';
            intGD.clientid__c = '998c0f65-cdc6-49e0-8a7e-ea1122d0ead0';
            intGD.clientsecret__c = '8KttlQ70CrgjLbt7EqWJx9mi7I5P/AAMfk7I2w2YGF0=';
            intGD.DebugMode__c = false;
            intGD.Endpoint__c = 'https://login.microsoftonline.com/73bc3ed9-35a9-44ab-8642-dc43ebe64878/oauth2/token';
            intGD.EndpointDoc__c = 'https://aa-pre-backend-api.azurewebsites.net/api/document';
            intGD.EndpointDocType__c = 'https://aa-pre-backend-api.azurewebsites.net/api/catalogs/documentType';
            intGD.granttype__c = 'client_credentials';
            intGD.LimiteDocs__c = 5;
            intGD.resource__c = '3e8ea5fe-aa21-4f79-af82-8f4ae132603c';
            intGD.usuarioAddDelete__c = 'user@arriaga.com';
        insert intGD;

    } 

    public static void crearIntegracionSF(){
        IntegracionSF__c intSF = new IntegracionSF__c();
        	intSF.Name = 'General';      
            intSF.clientid__c = '3MVG96mGXeuuwTZidMQsqDxgpszJMV8IjpVhWe1VxmKSN.ZXEC6zqJ0BsQcZfmUuGAvRr3cUFfUh3R1_DCzIn';
            intSF.clientsecret__c = '2519AAC4A5261BB7A72FB447559C2B51FD1040305D15397F032CF80683474F1A';
            intSF.password__c = 'crm4ever1';
            intSF.UrlEndPoint__c = 'https://test.salesforce.com/services/oauth2/token';
            intSF.username__c = 'rmoreira@arriaga.dev1'; 
        insert intSF;
    }
    
    public static void crearRedsysCodigoRespuesta(){
        list<Redsys_CodigosRespuesta__c> lcodesResp = new list<Redsys_CodigosRespuesta__c>();
        
    	Redsys_CodigosRespuesta__c codesResp = new Redsys_CodigosRespuesta__c();
        codesResp.Name = '0to99';
        codesResp.Descripcion__c = 'Transacción autorizada para pagos y preautorizaciones';
        
        lcodesResp.add(codesResp);
        
        
        codesResp = new Redsys_CodigosRespuesta__c();
        codesResp.Name = '0180';
        codesResp.Descripcion__c = 'Tarjeta ajena al servicio';
        lcodesResp.add(codesResp);
        
        
        codesResp = new Redsys_CodigosRespuesta__c();
        codesResp.Name = 'NonExistCode';
        codesResp.Descripcion__c = 'Error al realizar el pago. Realice de nuevo el pago al cabo de un instante';
        lcodesResp.add(codesResp);
        
        codesResp = new Redsys_CodigosRespuesta__c();
        codesResp.Name = 'OK';
        codesResp.Descripcion__c = 'Pago realizado con exito';
        lcodesResp.add(codesResp);
        
        codesResp = new Redsys_CodigosRespuesta__c();
        codesResp.Name = 'KO';
        codesResp.Descripcion__c = 'Hubo un problema con su pago. El error que produjo fue';
        lcodesResp.add(codesResp);
        
        codesResp = new Redsys_CodigosRespuesta__c();
        codesResp.Name = 'KOFirma';
        codesResp.Descripcion__c = 'Error de firma enviada por el servidor de REDSYS. Comuníquese con su administración.';
        lcodesResp.add(codesResp);
        
        
        insert lcodesResp;
    }    
    
    
    public static void crearDatosMinerva(){
        ArrMinervDatosWS__c configDatosflujo = new ArrMinervDatosWS__c();
        	configDatosflujo.Name = 'General';
        	configDatosflujo.Activo__c = true;
        	configDatosflujo.Endpoint__c = 'https://aa-pre-backend-api.azurewebsites.net';        	
        insert configDatosflujo;
    } 
    
    
    public static void crearDatosProd(){
        ArrProdDatosWS__c configDatosflujo = new ArrProdDatosWS__c();
        	configDatosflujo.Name = 'General';
        	configDatosflujo.Activo__c = true;
        	configDatosflujo.EndpointUpdtContc__c = 'https://sandbox-api.arriagaasociados.com/api/clients/clients/'; 
        	configDatosflujo.EndpointUpdtExp__c = 'https://sandbox-api.arriagaasociados.com/api/records/records/'; 
        	configDatosflujo.EndpointInsrtContc__c = 'https://sandbox-api.arriagaasociados.com/api/clients/clients.json'; 
        	configDatosflujo.EndpointInsrtExp__c = 'https://sandbox-api.arriagaasociados.com/api/records/records.json'; 
        	configDatosflujo.PrivateKey__c = 't2xO1SSQT9wkYLcoNQEWGFsZ41GATIDLxLhRvx2lFIJ1FHQJ'; 
        	configDatosflujo.PublicKey__c = 'kwadB10EqyFxZw3hFqkFFOzvm8BmEl56qCbHYxYx7nmjCKit'; 
         insert configDatosflujo;
    }

    /**
     *  Método que crea un nuevo registro de usuario
     */
    
    public static User createNewUser() {
        // Define los datos del nuevo usuario
        String firstName = 'Prueba';
        String lastName = 'Usuario';
        String email = 'puser@test.com';
        String username = 'puser' + UserInfo.getUserId() + '@test.com';
        
        // Crea el nuevo usuario
        User newUser = new User();
        newUser.FirstName = firstName;
        newUser.LastName = lastName;
        newUser.Email = email;
        newUser.Username = username;
        newUser.Alias = 'pUser';
        newUser.TimeZoneSidKey = 'America/Los_Angeles';
        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey ='UTF-8';
        newUser.ProfileId = UserInfo.getProfileId();
        insert newUser;   
        
        return newUser;        
    }  
    

}