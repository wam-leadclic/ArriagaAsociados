/*
@author LeadClic Solutions S.L.
@date 10/04/2019
@description Trigger para el objeto Expediente(Contract)

<pre>
FECHA             AUTOR           ACCION
17/04/2019		LCS - RDM	   	  Creación.
06/05/2019		LCS - RMG		  Modificación. Se añade la parte de conflicto de interés
04/09/2019		LCS - RDM		  Modificación. Subida de % de cobertura
09/01/2020      LCS - MMV         Modificación. Arreglar errores
27/01/2020      LCS - MMV         Modificación. Añadir Custom setting
13/08/2021      LCS - DRA         Modificación. Añadir Custom setting EstadosComunidad__c en el testsetup
 
*/
@isTest
public class TestTriggerContract {
    
    @testSetup static void crearCustomSettings(){
        //Configuración personalizada  
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
    }

    static testMethod  void CrearExpediente(){
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.IdClienteMinerva__c = '12345';
            ac.Phone = '654987321';
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
        
        list<Contract> lExp = new list<Contract>();
            Contract Exp = new Contract();
                Exp.AccountId = ac.Id;
                Exp.Pricebook2Id = standardPricebook.id;
                Exp.IdExpediente__c = opp.NumeroExpediente__c;
                Exp.Oportunidad__c = opp.id;
        		Exp.IdExpediente__c = '11111';
        		
        lExp.add(Exp);
            Contract Expediente = new Contract();
                Expediente.AccountId = ac.Id;
                Expediente.Pricebook2Id = standardPricebook.id;
                Expediente.IdExpediente__c = opp.NumeroExpediente__c;
                Expediente.Oportunidad__c = opp.id;
        		Expediente.IdExpediente__c = '22222';
        lExp.add(Expediente);
                 
        system.Test.startTest();
        	insert lExp;
        system.Test.stopTest();
        
        
    }
    
    static testMethod  void ConflictoInteres(){
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@test.com';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        cuentaPersonal.EstadoCuenta__c = 'Cliente Potencial';
        cuentaPersonal.IdClienteMinerva__c = '00002';
        insert cuentaPersonal;
        
        Account Personal =[SELECT PersonContactId 
                          FROM Account
                          WHERE Id =: cuentaPersonal.Id
                          LIMIT 1 ];	
        
        //Creación del expediente
        Contract Exp = new Contract();
        Exp.AccountId = cuentaPersonal.Id;
        Exp.DocumentosCompletadoAportado__c = '126;42';
        Exp.DocumentosCompletado__c = '126';
        Exp.DocumentacinBasicaAportada__c = true;
        Exp.PagoConfirmado__c = true;
        Exp.IdExpediente__c = '333333';
        insert exp;
        
        //Modificación del expediente para asignar la cuenta que es parte contraria
        exp.ParteContraria__c = cuentaPersonal.id;
        
        //Creamos la función de contacto del contrato
        ContractContactRole ccr = new ContractContactRole();
        ccr.ContractId = exp.Id;
        ccr.ContactId = Personal.PersonContactId;
        insert ccr;
        
        system.test.startTest();
        	//Actualizamos el expediente que tiene ya informado el campo de parte contraria
        	update exp;
        system.Test.stopTest();
    }
    
     static testMethod  void ConflictoInteres200(){
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@test.com';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        cuentaPersonal.EstadoCuenta__c = 'Cliente Potencial';
         cuentaPersonal.IdClienteMinerva__c = '00001';
        insert cuentaPersonal;
        
        Account Personal =[SELECT PersonContactId 
                          FROM Account
                          WHERE Id =: cuentaPersonal.Id
                          LIMIT 1 ];	
        
        //Creación del expediente
        list<Contract> lContratos = new list<Contract>();
         for(integer i=0; i<200;i++){
        	Contract Exp = new Contract();
        	Exp.AccountId = cuentaPersonal.Id;
        	lContratos.add(exp);
         }
         
         insert lContratos;
        
        //Modificación del expediente para asignar la cuenta que es parte contraria
        //Creamos la función de contacto del contrato
        list<ContractContactRole> lFuncionContacto = new list<ContractContactRole>();
         for(Contract exp :lContratos){
        	exp.ParteContraria__c = cuentaPersonal.id;
             
            ContractContactRole ccr = new ContractContactRole();
        	ccr.ContractId = exp.Id;
        	ccr.ContactId = Personal.PersonContactId;
             lFuncionContacto.add(ccr);
        }       
        
        insert lFuncionContacto;
        
        system.test.startTest();
        	//Actualizamos el expediente que tiene ya informado el campo de parte contraria
        	update lContratos;
        system.Test.stopTest();
    }
}