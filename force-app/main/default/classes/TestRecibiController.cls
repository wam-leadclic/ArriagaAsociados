/*
@author Leadclic Solutions S.L.
@date 02/08/2019
@description Clase test para la clase controladora para el PDF recibí

FECHA               AUTOR   
02/08/2019			LCS - RDM		Creación.
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura

*/
@isTest
public class TestRecibiController {

    @isTest static void getParam(){
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        	cuentaPersonal.FirstName = 'Testss';
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.PrecioTotal__c = 150.00;
        oportunidad.Tipo__c = 'TPV';
        oportunidad.CloseDate = system.today();
        insert oportunidad;
        
        system.Test.startTest();
        
        	RecibiController recibi = new RecibiController();
        		recibi.idOpp = oportunidad.id;
        		recibi.getDatosOpp();
        
        system.Test.stopTest();        
    }
    
     @isTest static void catchParams(){        
        system.Test.startTest();
        
        	RecibiController recibi = new RecibiController();
        		recibi.idOpp = null;
        		recibi.getDatosOpp();
        
        system.Test.stopTest();        
    }
    
}