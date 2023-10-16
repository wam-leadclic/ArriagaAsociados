@isTest
public class NotificationBellLayoutControllerTest {
    public static String account;
    @testSetup static void crearCustomSettings() {
        TestAux.crearIntegracionGD();
        ArrMinervDatosWS__c confPer = new ArrMinervDatosWS__c();
        confPer.name = 'General';
        confPer.Activo__c = true;
        
        
        ArrProdDatosWS__c cs = new ArrProdDatosWS__c();
        cs.name = 'General';
        cs.Activo__c = true;
        cs.PrivateKey__c = 'XXXX';
        cs.PublicKey__c = 'XXXX';
        cs.EndpointInsrtContc__c = 'test';
        cs.EndpointInsrtExp__c = 'sad';
        cs.EndpointUpdtExp__c = 'ass';
        
        insert cs;
       	insert confPer;

        IntegracionSF__c confIntegracionSF = new IntegracionSF__c();
        confIntegracionSF.Name = 'General';
        confIntegracionSF.UsuarioIntegracionId__c = '0051t000003IpmE';
        insert confIntegracionSF;


        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
        EstadosComunidad__c confEstadosComunidad2 = new EstadosComunidad__c();
        confEstadosComunidad2.Name = '01';
        confEstadosComunidad2.Estado__c = 'ESTADO NO DEFINIDO2';
        insert confEstadosComunidad2;
        EstadosComunidad__c confEstadosComunidad3 = new EstadosComunidad__c();
        confEstadosComunidad3.Name = '08';
        confEstadosComunidad3.Estado__c = 'ESTADO NO DEFINIDO3';
        insert confEstadosComunidad3;
    }
    
    
    @isTest public static void testGetNotifications(){
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '600000000';
        insert ac;
        Contact cont = new Contact();
            cont.accountId = ac.Id;
            cont.FirstName = 'NombreT';
            cont.lastName = 'Test';
            cont.MailingCountry = 'ESPAÑA';
            cont.MobilePhone =  '0034123456789';
            cont.Phone = '0034123456789';
            cont.Email = 'test.sz@example.com';
        insert cont;
        account=ac.Id;
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
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
      
        Opportunity opp = new Opportunity();
        opp.AccountId = ac.id;
        opp.StageName = 'Prospecting';   
        opp.Pricebook2Id = standardPricebook.id;   
        opp.Name = 'Test';
        Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        Contract Expediente = new Contract();
            Expediente.AccountId = ac.Id;
            Expediente.Pricebook2Id = standardPricebook.id;
            Expediente.IdExpediente__c = opp.NumeroExpediente__c;
            Expediente.Oportunidad__c = opp.id;
            Expediente.Status='Contratado';
        insert Expediente;

        Task tareaNueva = new Task();
        tareaNueva.Description = 'Pruebas';
        tareaNueva.Subject = 'Pruebas';
        tareaNueva.Status =  'Pruebas';
        tareaNueva.ActivityDate = system.today();
        tareaNueva.IsVisibleInSelfService=true;
        tareaNueva.WhatId = Expediente.Id;
        insert tareaNueva;
        
        Account oficina = new Account(Name = 'Test Oficina Notificacion', 
        ShippingState = 'Madrid',
        IdClienteMinerva__c='111',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Oficina').getRecordTypeId(),
         Phone = '6000000000');
        insert oficina;

        Event evt = new Event();
        evt.WhatId =  ac.Id;
        evt.Subject = 'Cita';
        evt.Oficina__c=oficina.Id;
        evt.StartDateTime = DateTime.now();
        evt.EndDateTime =  DateTime.now();
        insert evt;

        FeedItem tpost= new FeedItem();
        tpost.ParentId=Expediente.Id;
        tpost.Body = 'Enter post text here';
        insert tpost;
        
    	Profile p = [select id From Profile where Name ='Comunidad Arriaga'];
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
        System.Test.startTest();        
                NotificationBellLayoutController.getNotifications(false,'');
                NotificationBellLayoutController.getNotifications(true,'');
            
        System.Test.stopTest();
    }
}