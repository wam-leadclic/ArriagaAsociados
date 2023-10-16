/*
@author LeadClic Solutions S.L.
@date 14/03/2019
@description Clase Test para la clase Auxiliar que crea los objetos correspondientes al expediente

<pre>
FECHA                 AUTOR           ACCION
15/03/2019			LCS - RDM		 Creación.
04/09/2019			LCS - RMG		 Modificación. Se modifica el test para que no falle.
10/09/2019			LCS - RMG		 Modificación. Cambiamos el test para que no falle por una regla de validación nueva.
31/03/2020			LCS - RAL		 Modificación. Cambiamos el test para que no falle por una regla de validación nueva.
02/12/2020			LCS - HPS		 Modification. Custom settings are added.
18/09/2023			LCS - MHG		 Se añade a la Oportunidad la Oficina porque es necesaria para opps cerradas ganadas por regla de validación
*/
@isTest
public class TestClaseAuxiliarCreacionObjetos {
    
    @testSetup static void crearCustomSettings(){
        TestAux.crearDatosFlujo();
        ArrMinervDatosWS__c datosWS0 = new ArrMinervDatosWS__c();
        datosWS0.Name = 'General';
        datosWS0.Activo__c = true;
        
        insert datosWS0;
        
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
        
        ArrProdDatosWS__c datosWS1 = new ArrProdDatosWS__c();
        datosWS1.Name = 'General';
        datosWS1.Activo__c = true;
        
        insert datosWS1;
        //datosWS.Endpoint__c = ;
    }

    @isTest
    static void TestContratacionOnline(){
        
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Tesst';
        	ac.LastName = 'Test';
        	ac.ShippingPostalCode = '28931';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '600000000';
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

        ClaseAuxiliarCreacionObjetos.GetParameters request = new ClaseAuxiliarCreacionObjetos.GetParameters();
        List<ClaseAuxiliarCreacionObjetos.GetParameters> listRequest = new List<ClaseAuxiliarCreacionObjetos.GetParameters>();
                
        request.IdCuenta = ac.id;
        request.IdPriceBook = standardPricebook.id;
        request.IdPriceBookEntry = pb.id;
        request.IdProduct = prod.id;
        request.Opcion = 'Contratación Online';
        request.Flujo = 'Gastos Hipotecarios';
        listRequest.add(request);
        
        system.Test.startTest();
        	ClaseAuxiliarCreacionObjetos.MetodoInvocable(listRequest);
        system.Test.stopTest();
        
    }
    
    @isTest
    static void TestExpediente(){
        
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        User owner = [SELECT Id FROM User WHERE UserRoleId != null AND isActive = true LIMIT 1];
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '600000000';
        	ac.OwnerId = owner.Id;
        insert ac;
        
        Account acOficina = new Account();
        	acOficina.name = 'Test Oficina';
        	acOficina.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Oficina').getRecordTypeId();
        	acOficina.Activa__c = true;
            acOficina.CorreoElectronicoSecundario__c = 'oficina@emailfake.com';
        	acOficina.Phone = '600000001';
        	acOficina.OwnerId = owner.Id;
        insert acOficina;

        Contact cont = new Contact();
        	cont.accountId = ac.Id;
            cont.FirstName = 'NombreT';
            cont.lastName = 'Test';
            cont.MailingCountry = 'ESPAÑA';
            cont.MobilePhone =  '0034123456789';
            cont.Phone = '0034123456789';
            cont.Email = 'test.sz@example.com';
        insert cont;
              
        
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
        
        //Crear Hoja de encargo
        HojaEncargo__c hoja = new HojaEncargo__c();
        hoja.PDFDatosArriaga__c = 'TEST {!Name}';
        hoja.PDFDesistimiento__c = 'TEST {!Account.Name}';
        hoja.PDFHonorarios__c = 'TEST {!TEST}';
        hoja.ExternalId__c = '0001';
        insert hoja;
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Office__c = acOficina.Id;
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        	opp.CreadoComunidad__c = true;
        	opp.HojaEncargo__c = hoja.Id;
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.Quantity = 1;
        oli.TotalPrice = 1;
        insert oli;
        
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

        ClaseAuxiliarCreacionObjetos.GetParameters request = new ClaseAuxiliarCreacionObjetos.GetParameters();
        List<ClaseAuxiliarCreacionObjetos.GetParameters> listRequest = new List<ClaseAuxiliarCreacionObjetos.GetParameters>();
        
        request.IdCuenta = ac.id;
        request.IdPriceBook = standardPricebook.id;
        request.IdPriceBookEntry = pb.id;
        request.IdProduct = prod.id;
        request.IdOportunidad = opp.id;
        request.Opcion = 'Expediente';
        request.Flujo = 'Gastos Hipotecarios';
        listRequest.add(request);
        
        system.Test.startTest();        
        Profile p = [SELECT Id From Profile Where Name = 'Comunidad Arriaga'];
        
    	//Crear usuario
	     	User u = new User(
	     		ContactId = cont.Id,
				FirstName = cont.FirstName,
				LastName = cont.LastName,
				IsActive = true,
				EmailEncodingKey = 'ISO-8859-1',
				Email = cont.Email,
				Username = cont.Email,
				CommunityNickname = cont.Email,
				Phone = cont.Phone,
				Alias = cont.FirstName,
				ProfileId = p.id,
				TimeZoneSidKey = 'Europe/Paris',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es_ES'
	     	);
	     	insert u; 
            system.runAs(u){
                ClaseAuxiliarCreacionObjetos.MetodoInvocable(listRequest);
            }
        system.Test.stopTest();
        
    }
    
    @isTest
    static void TestBuscarOpp(){
        
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '600000000';
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
        insert opp;        
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        insert ContratOnline;

        ClaseAuxiliarCreacionObjetos.GetParameters request = new ClaseAuxiliarCreacionObjetos.GetParameters();
        List<ClaseAuxiliarCreacionObjetos.GetParameters> listRequest = new List<ClaseAuxiliarCreacionObjetos.GetParameters>();
        
        request.IdCuenta = ac.id;
        request.IdPriceBook = standardPricebook.id;
        request.IdPriceBookEntry = pb.id;
        request.IdProduct = prod.id;
        request.IdOportunidad = opp.id;
        request.IdContratOnline = ContratOnline.id;
        request.Opcion = 'Buscar Oportunidad';
        request.Flujo = 'Gastos Hipotecarios';
        listRequest.add(request);        
        
        system.Test.startTest();
        	ClaseAuxiliarCreacionObjetos.MetodoInvocable(listRequest);
        system.Test.stopTest();
        
    }
}