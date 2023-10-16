/*
@author LeadClic Solutions S.L.
@date 25/06/2019
@description Clase test para la clase manejadora del Trigger de Pagos

FECHA                 AUTOR           ACCION
25/06/2019			LCS - RDM		 Creación.
31/03/2020          LCS - RAL        Modificación. Se añade el teléfono en la creación de cuenta
02/12/2020			LCS - HPS		 Modification. Custom settings are added.
 
*/
@isTest
public class TestTriggerPago {
	
    @testSetup static void crearCustomSettings(){
        TestAux.crearDatosFlujo();
        
		
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
        
        ArrMinervDatosWS__c datosWS0 = new ArrMinervDatosWS__c();
        datosWS0.Name = 'General';
        datosWS0.Activo__c = true;
        
        insert datosWS0;
        
        ArrProdDatosWS__c datosWS1 = new ArrProdDatosWS__c();
        datosWS1.Name = 'General';
        datosWS1.Activo__c = true;
        
        insert datosWS1;
    }
    
    @isTest static void insertPagoConfirm(){
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            ac.EstadoCuenta__c='Cliente';
            ac.Phone = '60000000';
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
        
        PriceBookEntry pb = new PriceBookEntry();
        	pb.Product2Id = prod.id;
        	pb.Pricebook2Id = standardPricebook.id;
        	pb.IsActive = true;
        	pb.UnitPrice = 1000;
       // insert pb;
        
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
        insert Exp;
        
        
        Pago__c pago = new Pago__c();
            pago.Expediente__c = Exp.Id;
            pago.PrecioTotal__c = 100;
            pago.Estado__c = 'Pagada';
        
        system.Test.startTest();
        	insert pago;
        system.Test.stopTest();
    }
	
    @isTest static void updatePagoConfirm(){
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            ac.EstadoCuenta__c='Cliente';
            ac.Phone = '60000000';
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
        
        PriceBookEntry pb = new PriceBookEntry();
        	pb.Product2Id = prod.id;
        	pb.Pricebook2Id = standardPricebook.id;
        	pb.IsActive = true;
        	pb.UnitPrice = 1000;
       // insert pb;
        
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
        insert Exp;
        
        
        Pago__c pago = new Pago__c();
            pago.Expediente__c = Exp.Id;
            pago.PrecioTotal__c = 100;
            pago.Estado__c = 'Pendiente';
        insert pago;
        
        system.Test.startTest();
        		pago.Estado__c = 'Pagada';
        	update pago;
        system.Test.stopTest();
    }
    
}