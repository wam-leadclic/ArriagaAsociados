/*
@author Leadclic Solutions S.L.
@date 29/04/2019 
@description  Clase controladora para el componenete que se encarga de seleccionar una hoja de encargo (hojaEncargocmp)

<pre>
FECHA                   AUTOR                   ACCION
07/05/2019              LCS - RDM               Creación
04/09/2019				LCS - RDM		 		Modificación. Subida de % de cobertura
11/09/2019				LCS - RMG				Modificación. Se valida el método validacionGeneracionPDF
10/01/2020				LCS - JCL				Modificación. Se amplia la cobertura y se comprueban las nuevas condiciones de validacionGeneracionPDF
*/
@isTest
public with sharing class TesthojaEncargoControllerlwc {

    private static final Id BUSINESS_ACCOUNT_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business_Account').getRecordTypeId();
    private static final Id PERSONAL_ACCOUNT_RT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    
    @isTest static void confirmarHojaEncargo(){
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = BUSINESS_ACCOUNT_RT;
        	ac.EstadoCuenta__c='Cliente';
            ac.Phone = '123456789';
            ac.DocumentoIdentidad__c = '82835698W';
            ac.ShippingStreet = 'Calle test';
            ac.ShippingPostalCode = '28224';
            ac.ShippingCity = 'Ciudad test';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
            c.AceptoPoliticaPrivacidad__c = true;
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
        insert prod;
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = 'Prospecting';      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        HojaEncargo__c h = new HojaEncargo__c();
        	h.Name = 'Test';
        	h.ExternalId__c = '456985';
        insert h;
        
        Opportunity opp2 = new Opportunity();
            opp2.AccountId = ac.id;
            opp2.StageName = 'Prospecting';      
            opp2.Name = 'Test';
            opp2.Pricebook2Id = standardPricebook.id;
            opp2.CloseDate = date.valueOf(system.now());
        	opp2.HojaEncargo__c = h.id;
        insert opp2;

        OpportunityContactRole opr = new OpportunityContactRole();
            opr.ContactId = c.Id;
            opr.OpportunityId = opp2.Id;
            opr.Role = 'Titular';
        insert opr;

        system.Test.startTest();
            hojaEncargoControllerlwc.getConfirmarHojaCargada(opp.id);
            hojaEncargoControllerlwc.getConfirmarHojaCargada(opp2.id);
        system.Test.stopTest();
    }
    
    @isTest static void hojaEncargo(){
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = BUSINESS_ACCOUNT_RT;
        	ac.EstadoCuenta__c='Cliente';
            ac.Phone = '123456789';
            ac.DocumentoIdentidad__c = '82835698W';
            ac.ShippingStreet = 'Calle test';
            ac.ShippingPostalCode = '28224';
            ac.ShippingCity = 'Ciudad test';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
            c.AceptoPoliticaPrivacidad__c = true;
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
        insert prod;
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = 'Prospecting';      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        HojaEncargo__c h = new HojaEncargo__c();
        	h.Name = 'Test';
        	h.Producto__c = prod.Id;
        	h.ExternalId__c = '456985';
        insert h;
        
        Opportunity opp2 = new Opportunity();
            opp2.AccountId = ac.id;
            opp2.StageName = 'Prospecting';      
            opp2.Name = 'Test';
            opp2.Pricebook2Id = standardPricebook.id;
            opp2.CloseDate = date.valueOf(system.now());
        	opp2.HojaEncargo__c = h.id;
        insert opp2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        	oli.Product2Id = prod.Id;
        	oli.OpportunityId = opp2.id;
        	oli.Quantity = 1;
        	oli.TotalPrice = 100;
        insert oli;

        system.Test.startTest();
        	hojaEncargoControllerlwc.rellenarCampos(opp.id, null, true);
        	hojaEncargoControllerlwc.getConfirmarHojaCargada(opp.id);
            hojaEncargoControllerlwc.getHojasEncargo(opp2.id);
            hojaEncargoControllerlwc.rellenarCampos(opp2.id, h.Id, false);
            hojaEncargoControllerlwc.vaciarCampos(opp2.id);
        system.Test.stopTest();
    }

    @isTest static void validarHojaEncargo() {
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = BUSINESS_ACCOUNT_RT;
        	ac.EstadoCuenta__c='Cliente';
            ac.Phone = '123456789';
            ac.DocumentoIdentidad__c = '82835698W';
            ac.ShippingStreet = 'Calle test';
            ac.ShippingPostalCode = '28224';
            ac.ShippingCity = 'Ciudad test';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
            c.AceptoPoliticaPrivacidad__c = true;
        insert c;

        Account pc = new Account();
        	pc.FirstName = 'Person Account';
            pc.LastName = 'Person Account';
        	pc.RecordTypeId = PERSONAL_ACCOUNT_RT;
        	pc.EstadoCuenta__c='Cliente';
            pc.Phone = '987654321';
            pc.DocumentoIdentidad__c = '32322944D';
            pc.ShippingStreet = 'Calle test2';
            pc.ShippingPostalCode = '28903';
            pc.ShippingCity = 'Ciudad test 2';
            pc.AceptoPoliticaPrivacidad__pc = true;
        	pc.IdClienteMinerva__c = '1';
        insert pc;
        
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
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];

        HojaEncargo__c h = new HojaEncargo__c();
        	h.Name = 'Test';
        	h.ExternalId__c = '456985';
        insert h;
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = 'Prospecting';      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            opp.CloseDate = date.valueOf(system.now());
        	opp.HojaEncargo__c = h.id;
        insert opp;

        OpportunityContactRole opr = new OpportunityContactRole();
            opr.ContactId = c.Id;
            opr.OpportunityId = opp.Id;
            opr.Role = 'Titular';
        insert opr;

        Opportunity opp2 = new Opportunity();
            opp2.AccountId = pc.id;
            opp2.StageName = 'Prospecting';      
            opp2.Name = 'Test';
            opp2.Pricebook2Id = standardPricebook.id;
            opp2.CloseDate = date.valueOf(system.now());
            opp2.HojaEncargo__c = h.id;
        insert opp2;

        pc = [ SELECT Id, FirstName, LastName, RecordTypeId, EstadoCuenta__c, Phone, DocumentoIdentidad__c, ShippingStreet, ShippingPostalCode, 
                      ShippingCity, AceptoPoliticaPrivacidad__pc, PersonContactId 
                      FROM Account
                      WHERE Id = :pc.Id ];

        OpportunityContactRole opr2 = new OpportunityContactRole();
            opr2.ContactId = pc.PersonContactId;
            opr2.OpportunityId = opp2.Id;
            opr2.Role = 'Titular';
        insert opr2;

        system.Test.startTest();
        
        	boolean resultado1 = hojaEncargoControllerlwc.validacionGeneracionPDF(opp.id);
        	boolean resultado2 = hojaEncargoControllerlwc.validacionGeneracionPDF(opp2.id);
        
        system.Test.stopTest();
        
        System.assertEquals(false, resultado1);
        System.assertEquals(true, resultado2);
        
    }

}