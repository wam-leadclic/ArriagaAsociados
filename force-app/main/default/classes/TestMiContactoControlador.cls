/*
@author LeadClic Solutions S.L.
@date 14/03/2019
@description Clase de test para la clase MiContactoControlador

 FECHA		AUTOR		Descripción
14/03/2019	LCS-RMG		Creación.
04/09/2019	LCS - RDM	Modificación. Subida de % de cobertura
31/03/2020	LCS - RAL	Modificación. Se añade el teléfono en la creación de cuenta

*/
@isTest
public class TestMiContactoControlador {
    
    @isTest static void InformacionUsuario()
    {   
        Account a = new Account(
        	FirstName = 'Test',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId(),
            Description = 'TestApx',
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

        //Cargar perfil
    		Profile p = [select id From Profile where Name ='Comunidad Arriaga'];    	
    	//Crear usuario
	     	User u = new User(
	     		ContactId = c.Id,				
				LastName = 'TestApx',
				IsActive = true,
				Email = 'test@test.com',
				Username = 'test@testArriaga.com',
				CommunityNickname = 'test@testArriaga.com',
				Alias = 'test',
				ProfileId = p.id,
				LanguageLocaleKey = 'es',
				TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1'
	     	);
	     	insert u; 
        system.runAs(u)
        {
            system.Test.startTest();
            	MiContactoControlador.getInformacionUsuario();
            system.Test.stopTest();
        }
    }
}