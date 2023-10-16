/*
@author LeadClic Solutions S.L.
@date 21/05/2019
@description Clase Test para el trigger de usuario y su handler

<pre>
FECHA                 AUTOR           ACCION
21/05/2019			LCS - RMG		 Creación.
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura
 
*/
@isTest
public class TestTriggerUsuario {
	static testmethod void usuarioComunidad(){
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@test.com';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        cuentaPersonal.EstadoCuenta__c = 'Cliente Potencial';
        insert cuentaPersonal;

        Account cuenta = [SELECT PersonContactId
                            FROM Account
                            WHERE Id = :cuentaPersonal.id LIMIT 1].get(0);
        
        //Creamos el usuario de la comunidad
        Profile p = [SELECT Id FROM Profile WHERE Name='Comunidad Arriaga'];        
        
        User u1 = new User( email='testArriaga160419@arriaga.com',
                profileid = p.id, 
                UserName='testArriaga160419@arriaga.com', 
                Alias = 'test',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = cuenta.PersonContactId,
                FirstName = 'Test',
                LastName = 'Test');
        
        system.Test.startTest();
        	insert u1;
		system.Test.stopTest();
    }
}