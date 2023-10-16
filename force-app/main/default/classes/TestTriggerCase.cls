/*
@author LeadClic Solutions S.L.
@date 11/07/2019
@description Test del Trigger para el objeto Caso

<pre>
FECHA             AUTOR           ACCION
11/07/2019        LCS - RMG       Creación. 
16/07/2019		  LCS - RMG		  Modificación. Se añade el after update al trigger
04/09/2019		  LCS - RDM		  Modificación. Subida de % de cobertura
31/03/2020        LCS - RAL       Modificación. Se añade el teléfono en la creación de cuenta.
*/
@isTest
public class TestTriggerCase {
	
    static testmethod void crearCaso(){
    	Case caso = new Case();
        caso.Subject = 'Test';
        
        system.Test.startTest();
        	insert caso;
        System.Test.stopTest();
    }
    
    @isTest static void slaCaso(){
        SLAsIncidenciaAsignacion__c tipos = new SLAsIncidenciaAsignacion__c();
        	tipos.Name = 'IdRegistro';
        	tipos.NombreTipoRegistro__c = 'TestReg';
        insert tipos;
        
        Account ac = new Account();
            ac.Name = 'Arriaga';
            ac.Phone = '60000000';
        insert ac;
        
        List<SlaProcess> slaGen = [SELECT Id, Name FROM SlaProcess where isActive = true Limit 2];
        
        List<Entitlement> lsla = new List<Entitlement>();
        Entitlement sla = new Entitlement();
        	sla.AccountId = ac.Id;
        	sla.Name = 'SLAs';
        	sla.SlaProcessId = slaGen.get(0).Id;        	
        lsla.add(sla);
        
        Entitlement slaIncidencias = new Entitlement();
        	slaIncidencias.AccountId = ac.Id;
        	slaIncidencias.Name = 'SLAs Incidencias';
        	slaIncidencias.SlaProcessId = slaGen.get(1).Id;        	
        lsla.add(slaIncidencias);
        
        insert lsla;
        
    	Case caso = new Case();
        caso.Subject = 'Test';
        
        system.Test.startTest();
        	insert caso;
        System.Test.stopTest();        
    }
    
    static testmethod void crearCasoComunidad(){
    	Case caso = new Case();
        caso.Subject = 'Test';
        
        Account a = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId(),
            Description = 'TestApx',
            firstname = 'TestApsx',
            lastname = 'TestApx',
            ShippingCity = 'Madrid',
            ShippingCountry = 'España',
            ShippingPostalCode = '28028',
            ShippingState = 'Madrid',
            ShippingStreet = 'Calle de Alcalá 192',
            Phone = '60000000'
        );
        insert a;
        
        contact c = [SELECT Id FROM Contact WHERE AccountId = :a.id];
                  
        User u = new User(
	     		ContactId = c.Id,				
				LastName = 'TestApx',
				IsActive = true,
				Email = 'test@test.com',
				Username = 'test@testArriaga.com',
				CommunityNickname = 'test@testArriaga.com',
				Alias = 'test',
				ProfileId = system.label.IdPerfilUsuariocomunidad,
				LanguageLocaleKey = 'es',
				TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1'
	     	);
        
        system.Test.startTest();
        	system.runAs(u) {
            	insert caso;
            }
        System.Test.stopTest();
    }
}