@isTest
public class ContractChatterLayoutControllerTest {
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
        confEstadosComunidad2.Name = '08';
        confEstadosComunidad2.Estado__c = 'ESTADO DEFINIDO';
        insert confEstadosComunidad2;
    }
    
    @isTest public static void testGetChatter(){
        Account ac = new Account();
        ac.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        ac.PersonEmail = 'test@email.com';
        ac.EstadoCuenta__c='Cliente';
        ac.FirstName = 'Tesst';
        ac.LastName = 'Test';
        insert ac;
        Contact c = new Contact();
        	c.FirstName = 'Tesst';
        	c.LastName = 'TestII';
        insert c;
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
        insert Expediente;

        Expediente.Status='ACUERDO AC';
        update Expediente;

        Task tareaNueva = new Task();
        tareaNueva.Description = 'Pruebas';
        tareaNueva.Subject = 'Pruebas';
        tareaNueva.Status =  'Pruebas';
        tareaNueva.ActivityDate = system.today();
        tareaNueva.IsVisibleInSelfService=true;
        tareaNueva.WhatId = Expediente.Id;
        insert tareaNueva;

        System.Test.startTest(); 
        ContractChatterLayoutController.retrieveContractChatterFeeds(null);
        ContractChatterLayoutController.retrieveContractChatterFeeds(Expediente.Id);
        System.Test.stopTest(); 
    }
}