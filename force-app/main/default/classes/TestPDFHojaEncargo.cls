/*
Test de la clase de PDFHojaEncargo

FECHA		AUTOR		DESCRIPCION
14/06/2019	LCS -RMG	Creación
04/09/2019	LCS - RDM	Modificación. Subida de % de cobertura
31/03/2020  LCS - RAL   Modificación. Se añade el número de teléfono a la cuenta

*/
@isTest
public class TestPDFHojaEncargo {
    
    static testmethod void hojaEncargo(){
        //Crear Cuenta Personal
        Account ac = new Account();
        	ac.FirstName = 'Test';
        ac.LastName= 'CuentaTest';
        ac.EstadoCuenta__c='Cliente';	
        ac.IdClienteMinerva__c = '1234';
        ac.Phone = '600000000';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        insert ac;
        
        Account PersonContactId= [SELECT PersonContactId
                                	FROM Account 
                                	WHERE Id =: ac.Id];
        
        //Crear Cuenta Personal
        Account tutor = new Account();
        tutor.FirstName= 'CuentasTest';
        tutor.LastName= 'CuentaTest';
        tutor.EstadoCuenta__c='Cliente';	
        tutor.IdClienteMinerva__c = '4321';
        tutor.Phone = '600000000';
        tutor.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        insert tutor;
        
        Account tutorCuentaPersonal = [SELECT PersonContactId
                                	FROM Account 
                                	WHERE Id =: tutor.Id];
        
        //Crear Hoja de encargo
        HojaEncargo__c hoja = new HojaEncargo__c();
        hoja.PDFDatosArriaga__c = 'TEST {!Name}';
        hoja.PDFDesistimiento__c = 'TEST {!Account.Name}';
        hoja.PDFHonorarios__c = 'TEST {!TEST}';
        hoja.ExternalId__c = '0003';
        insert hoja;
        
        //Crear Oportunidad
        Opportunity opp = new Opportunity();
        opp.AccountId = ac.Id;
        opp.StageName = 'Prospecting';      
        opp.Name = 'OppTest';
        Opp.CloseDate = date.valueOf(system.now());
        Opp.HojaEncargo__c = hoja.id;
        insert opp;
        
        //Crear Funcion de contacto
        OpportunityContactRole opprole = new OpportunityContactRole();
        opprole.ContactId = PersonContactId.PersonContactId;
        opprole.Role = 'Titular';
        opprole.OpportunityId = opp.Id;
        insert opprole;
        
        opprole = new OpportunityContactRole();
        opprole.ContactId = tutorCuentaPersonal.PersonContactId;
        opprole.Role = 'Tutor';
        opprole.OpportunityId = opp.Id;
        insert opprole;
               
        //Asignamos a la página el id de la oportunidad como parametro de la URL
        Test.setCurrentPageReference(new PageReference('PDFHojaEncargo'));
        System.currentPageReference().getParameters().put('id', opp.id);
        system.Test.startTest();
        	PDFHojaEncargo pdf = new PDFHojaEncargo();
        	pdf.getWOportunidad();
        	pdf.gethojaEnc();
        system.Test.stopTest();
    }
}