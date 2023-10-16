/*
@author LeadClic Solutions S.L.
@date 18/06/2019
@description Clase Test para la clase que actualiza la contratación Online al crear 2ºTitular o encontrar ya otro contacto

<pre>
FECHA                 AUTOR           ACCION
18/06/2019			LCS - RDM		 Creación
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura
*/
@isTest
public with sharing class TestFlow_ActualizarContratOnline {
    
    @testSetup static void crearCustomSettings(){
        DatosFlujo__c flujo = new DatosFlujo__c();
            flujo.IDTipoRegistroCuentaPersonal__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            flujo.EstadoCuenta__c = 'Cliente Potencial';
            flujo.IdPropietarioSegundoTitular__c = system.UserInfo.getUserId();
            flujo.EtapaOEtapaOportuniportunidadContrOnline__c = 'Prospecting';
        insert flujo;  
    }

    @isTest
    static void TestCrearSegundoTitular(){
                 
        
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.PersonEmail = 'test111@test.com';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.IdClienteMinerva__c = '12345';
        insert ac;

        Account segTit = new Account();
        	segTit.FirstName = 'Test2';
        	segTit.LastName = 'Test2';
        	segTit.PersonEmail = 'test112@test.com';
        	segTit.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	segTit.EstadoCuenta__c='Cliente';
        	segTit.IdClienteMinerva__c = '12346'; 
        insert segTit;
        
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
        
        Product2 prod2 = new Product2();
            prod2.Name = 'test Prod2'; 
            prod2.IsActive = true;
        insert prod2;
        
        PricebookEntry pb = [SELECT Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :prod.id LIMIT 1];
        
        /*
        PriceBookEntry pb = new PriceBookEntry();
        	pb.Product2Id = prod.id;
        	pb.Pricebook2Id = standardPricebook.id;
        	pb.IsActive = true;
        	pb.UnitPrice = 1000;
        insert pb; 
*/
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;    
            opp.Name = 'Test';
            opp.StageName = 'Prospecting';
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline.IDProducto__c = prod.id;
        	ContratOnline.ContrFinalizado__c = true;
        insert ContratOnline;
        

        Flow_ActualizarContratOnline.GetParameters request = new Flow_ActualizarContratOnline.GetParameters();
        List<Flow_ActualizarContratOnline.GetParameters> listRequest = new List<Flow_ActualizarContratOnline.GetParameters>();
                
        request.idContratOnline = ContratOnline.id;
        request.consentimientoSegTit = 'SI';
        request.emailSegTit = 'test1252@test.com';
        request.segTit = segTit.Id;
        request.tieneVariosTit = 'Sí, hay otro titular y está informado';
        listRequest.add(request);
        
        system.Test.startTest();
        	Flow_ActualizarContratOnline.metodoInvocable(listRequest);
        system.Test.stopTest();
    }
    
}