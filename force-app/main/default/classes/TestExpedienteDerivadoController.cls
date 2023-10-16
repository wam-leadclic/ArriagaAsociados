/*
@author Leadclic Solutions S.L.
@date 14/05/2019 
@description    Controlador del componente ExpedienteDerivado

<pre>
FECHA                   AUTOR                   ACCION
14/05/2019              LCS - RDM               Creación
04/07/2019				LCS - RDM	   	  		Modificación. Se añaden el método para pasar por la comprobación del expediente derivado
04/12/2019				LCS - GQG				Modificación. Se añade el campo teléfono por regla de validación.
31/03/2020              LCS - RAL               Modificación. Se modifica el tipo de expediente derivado.
*/
@isTest
public with sharing class TestExpedienteDerivadoController {
    
    @testSetup static void crearCustomSettings(){
        TestAux.crearExpeDerivados();   
        
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
             
    }

    @isTest static void obtenerPick(){
        system.Test.startTest();
            ExpedienteDerivadoController.getTipoDerivado();
        system.Test.stopTest();
    }

    @isTest static void obtenerDatosExp(){
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '499292929';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
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
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        OpportunityContactRole opprole = new OpportunityContactRole();
            opprole.ContactId = c.Id;
            opprole.Role = 'Titular';
            opprole.IsPrimary = true;
            opprole.OpportunityId = opp.id;
        insert opprole;
        
        Contract Exp = new Contract();
            Exp.AccountId = ac.Id;
            Exp.Pricebook2Id = standardPricebook.id;
            Exp.IdExpediente__c = opp.NumeroExpediente__c;
            Exp.Oportunidad__c = opp.id;
            Exp.IdExpediente__c = '19050012345';
        insert Exp;

        system.Test.startTest();
            ExpedienteDerivadoController.getExpediente(Exp.Id);
            ExpedienteDerivadoController.creacionExpediente(Exp.Id, 'Demanda independiente de cláusula suelo');
        system.Test.stopTest();
    }  

    @isTest static void crearExp(){
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '499292929';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
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
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        OpportunityContactRole opprole = new OpportunityContactRole();
            opprole.ContactId = c.Id;
            opprole.Role = 'Titular';
            opprole.IsPrimary = true;
            opprole.OpportunityId = opp.id;
        insert opprole;
        
        Contract Exp = new Contract();
            Exp.AccountId = ac.Id;
            Exp.Pricebook2Id = standardPricebook.id;
            Exp.IdExpediente__c = opp.NumeroExpediente__c;
            Exp.Oportunidad__c = opp.id;
            Exp.IdExpediente__c = '19050012345';
        insert Exp;
        Contract Exp2 = new Contract();
            Exp2.AccountId = ac.Id;
            Exp2.Pricebook2Id = standardPricebook.id;
            Exp2.IdExpediente__c = opp.NumeroExpediente__c;
            Exp2.Oportunidad__c = opp.id;
            Exp2.IdExpediente__c = '19050912345';
        insert Exp2;

        system.Test.startTest();
            ExpedienteDerivadoController.creacionExpediente(Exp.Id, 'Demanda independiente de cláusula suelo');
            ExpedienteDerivadoController.creacionExpediente(Exp2.Id, 'Demanda independiente de cláusula suelo');
        system.Test.stopTest();
    }

    @isTest static void comprobarExpDerivado(){
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.Phone = '499292929';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
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
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        OpportunityContactRole opprole = new OpportunityContactRole();
            opprole.ContactId = c.Id;
            opprole.Role = 'Titular';
            opprole.IsPrimary = true;
            opprole.OpportunityId = opp.id;
        insert opprole;
        
        Contract Exp = new Contract();
            Exp.AccountId = ac.Id;
            Exp.Pricebook2Id = standardPricebook.id;
            Exp.IdExpediente__c = opp.NumeroExpediente__c;
            Exp.Oportunidad__c = opp.id;
            Exp.IdExpediente__c = '19050012345';
        insert Exp;
        
        Contract Exp2 = new Contract();
            Exp2.AccountId = ac.Id;
            Exp2.Pricebook2Id = standardPricebook.id;
            Exp2.IdExpediente__c = opp.NumeroExpediente__c;
            Exp2.Oportunidad__c = opp.id;
            Exp2.IdExpediente__c = '19050912345';
        insert Exp2;

        system.Test.startTest();
            ExpedienteDerivadoController.checkExpedienteDerivado(Exp.Id);
        
            Contract expDer = new Contract();
                expDer.AccountId = ac.Id;
                expDer.Pricebook2Id = standardPricebook.id;
                expDer.IdExpediente__c = opp.NumeroExpediente__c;
                expDer.Oportunidad__c = opp.id;
                expDer.IdExpediente__c = '19050112345';
        		expDer.ExpedientePrincipal__c = Exp.Id;
            insert expDer;
        
            ExpedienteDerivadoController.checkExpedienteDerivado(expDer.Id);        
        system.Test.stopTest();
    }
}