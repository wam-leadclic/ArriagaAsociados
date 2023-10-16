/*
@author LeadClic Solutions S.L.
@date 10/05/2019
@description Clase Test para el trigger de evento y su handler

<pre>
FECHA                 AUTOR           ACCION
10/05/2019			LCS - RMG		 Creación.
20/05/2019 			LCS - RDM		 Modificación. Se añade cobertura para creación del caso recaptura
27/05/2019 			LCS - RDM		 Modificación. Se añade cobertura para la reasignación del usuario
 
*/
@isTest
public class TestTriggerEvent {
    @testSetup static void crearCustomSettings(){
        //Configuración personalizada  
        ConversionCandidato__c confPerConvCand = new ConversionCandidato__c();
        confPerConvCand.name = 'General';
        confPerConvCand.EtapaOportunidad__c = 'Calificación';
        confPerConvCand.IdListaDePrecio__c = Test.getStandardPricebookId();
        confPerConvCand.RolFuncionContacto__c = 'Economic Buyer';
        insert confPerConvCand;
    }
    
    static testmethod void eventoCita(){
		Lead candidato = new Lead();
        candidato.FirstName = 'test';
        candidato.LastName = 'test2';
        candidato.Phone = '652589652';
        candidato.Email = 'test@gmail.com';
        candidato.PostalCode = '28224';
        insert candidato;
        
        Event evento = new Event();
        evento.whoId = candidato.id;
        evento.StartDateTime = system.now();
        evento.DurationInMinutes = 2;
        evento.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        
        System.Test.startTest();
        	insert evento;
        System.Test.stopTest();
            
    }
    
    @isTest static void eventoRecaptura(){        
        Contact candidato = new Contact();
        candidato.FirstName = 'test';
        candidato.LastName = 'test2';
        candidato.Phone = '652589652';
        candidato.Email = 'test@gmail.com';        
        insert candidato;
        
        Event evento = new Event();
        evento.whoId = candidato.id;
        evento.StartDateTime = system.now();
        evento.DurationInMinutes = 2;
        evento.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        insert evento;
        
        System.Test.startTest();
        	evento.Estado__c = system.label.NoAsiste;
        	update evento;
        System.Test.stopTest();
            
    }
    
    @isTest static void reasignarContactPropietario(){        
        User usuario = new User();
        usuario.LastName = 'tEST';
        usuario.Alias = 'Test';
        usuario.Email = 'testcont@mail.com';
        usuario.ProfileId = system.Label.IdPerfilAdmin;
        usuario.Username = 'testcont@mail.com'; 
        usuario.TimeZoneSidKey = 'Europe/Paris'; 
        usuario.LocaleSidKey = 'es_ES'; 
        usuario.EmailEncodingKey = 'ISO-8859-1'; 
        usuario.LanguageLocaleKey = 'es';
        insert usuario;
        
		Contact candidato = new Contact();
        candidato.FirstName = 'test';
        candidato.LastName = 'test2';
        candidato.Phone = '652589652';
        candidato.Email = 'test@gmail.com';
        candidato.OwnerId = usuario.id;        
        insert candidato;
        
        Event evento = new Event();
        evento.whoId = candidato.id;
        evento.StartDateTime = system.now();
        evento.DurationInMinutes = 2;
        evento.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        
        System.Test.startTest();
        	insert evento;
        System.Test.stopTest();
            
    }
    
    @isTest static void reasignarLeadPropietario(){
        User usuario = new User();
        usuario.LastName = 'tEST';
        usuario.Alias = 'Test';
        usuario.Email = 'testLead@mail.com';
        usuario.CommunityNickname = 'test@mail.com';
        usuario.ProfileId = system.Label.IdPerfilAdmin;
        usuario.Username = 'testLead@mail.com'; 
        usuario.TimeZoneSidKey = 'Europe/Paris'; 
        usuario.LocaleSidKey = 'es_ES'; 
        usuario.EmailEncodingKey = 'ISO-8859-1'; 
        usuario.LanguageLocaleKey = 'es';
        insert usuario;
        
		Lead candidato = new Lead();
        candidato.FirstName = 'test';
        candidato.LastName = 'test2';
        candidato.Phone = '652589652';
        candidato.Email = 'test@gmail.com';
        candidato.OwnerId = usuario.id;
        candidato.PostalCode = '28224';
        insert candidato;
        
        Event evento = new Event();
        evento.whoId = candidato.id;
        evento.StartDateTime = system.now();
        evento.DurationInMinutes = 2;
        evento.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        
        System.Test.startTest();
        	insert evento;
        System.Test.stopTest();
            
    }
}