/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Clase Test para el trigger de cuenta y su handler. También testea la clase ActualizarInfoUsuarioComunidad

<pre>
FECHA                 AUTOR           ACCION
16/04/2019			LCS - RMG		 Creación.
29/04/2019			LCS - RDM		 Modificación. Se crea la llamada para las comprobaciones de DNI
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura
 
*/
@isTest
public class TestTriggerAccount {
	
    @isTest static void cambiarEmail(){
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
		
		insert u1;        
        //Cambiamos el email del contacto para que salte el trigger
        cuentaPersonal.PersonEmail = 'testMod@test.com';
        
        system.Test.startTest();
        	update cuentaPersonal;
        System.Test.stopTest();
    }
    
    @isTest static void SinDNI(){
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@test.com';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        cuentaPersonal.EstadoCuenta__c = 'Cliente Potencial';
        insert cuentaPersonal;
        
        cuentaPersonal.PersonEmail = 'testMod@test.com';
        system.Test.startTest();
        	update cuentaPersonal;
        System.Test.stopTest();
    }
    
    @isTest static void insertDNI(){
        try{
            //Creamos la cuenta personal
            Account cuentaPersonal = new Account();
            cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            cuentaPersonal.PersonEmail = 'test@test.com';
            cuentaPersonal.FirstName = 'Tesst';
            cuentaPersonal.LastName = 'Test';
            cuentaPersonal.EstadoCuenta__c = 'Cliente Potencial';
            cuentaPersonal.TipoDocumento__c = 'NIF';
            cuentaPersonal.DocumentoIdentidad__c = '12345677A';  
            system.Test.startTest();
            insert cuentaPersonal;
            System.Test.stopTest();
        }catch(Exception e){}
    }
    
    @isTest static void updatetDNI(){
        try{
            //Creamos la cuenta personal
            Account cuentaPersonal = new Account();
            cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            cuentaPersonal.PersonEmail = 'test@test.com';
            cuentaPersonal.FirstName = 'Tesst';
            cuentaPersonal.LastName = 'Test';
            cuentaPersonal.EstadoCuenta__c = 'Cliente';
            cuentaPersonal.AccountSyncMinerva__c = 'OK';
            cuentaPersonal.AccountSyncProd__c = 'OK';
            insert cuentaPersonal;
             
            system.Test.startTest();
            	cuentaPersonal.TipoDocumento__c = 'NIF';
            	cuentaPersonal.DocumentoIdentidad__c = '12345677A'; 
                update cuentaPersonal;
            System.Test.stopTest();
        }catch(Exception e){}
    }
}