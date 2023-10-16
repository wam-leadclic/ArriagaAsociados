/*
@author LeadClic Solutions S.L.
@date 30/04/2019
@description Test de la clase EmailHuerfanosController

<pre>
FECHA                 AUTOR           ACCION
30/04/2019		      LCS - RMG	      Creación. 
04/09/2019			  LCS - RDM		  Modificación. Subida de % de cobertura
 
*/
@isTest
public class TestEmailHuerfanos {

    static testmethod void getEmailHuerfano(){
        
        system.Test.startTest();
            EmailHuerfanosController.getEmailHuerfanosBusqueda();
        system.Test.stopTest();
    }

    static testmethod void eliminarEmailHuerfano(){
        EmailMessage emailInsert = new EmailMessage();
        emailInsert.FromAddress = 'test@test.com';
        emailInsert.FromName = 'test';
        emailInsert.HtmlBody = 'email.htmlBody';
        emailInsert.Incoming = true;
        emailInsert.MessageDate = system.now();
        emailInsert.Status = '0';
        emailInsert.Subject = 'Email de prueba adjunto';
        emailInsert.TextBody = 'email.plainTextBody';
        emailInsert.ToAddress = 't@t.es';

        insert emailInsert;

        system.Test.startTest();
            EmailHuerfanosController.eliminarEmail(emailInsert.id);
        system.Test.stopTest();
    }

    static testmethod void actualizarEmailHuerfano(){
        //Creación del email
        EmailMessage emailInsert = new EmailMessage();
        emailInsert.FromAddress = 'test@test.com';
        emailInsert.FromName = 'test';
        emailInsert.HtmlBody = 'email.htmlBody';
        emailInsert.Incoming = true;
        emailInsert.MessageDate = system.now();
        emailInsert.Status = '0';
        emailInsert.Subject = 'Email de prueba adjunto';
        emailInsert.TextBody = 'email.plainTextBody';
        emailInsert.ToAddress = 't@t.es';

        insert emailInsert;

        //Creamos el email adjunto
        Attachment attachment = new Attachment();
        attachment.Name = 'test';
        attachment.Body = blob.valueOf('Test Adjunto');
        attachment.ParentId = emailInsert.id;
        insert attachment;

        //Creación de la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Test';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;

        Account cuenta = [SELECT Id, PersonContactId
                            FROM Account
                            WHERE Id = :cuentaPersonal.id].get(0);

        system.Test.startTest();
            EmailHuerfanosController.actualizarRemitenteEmail(emailInsert.id, cuenta.PersonContactId);
        system.Test.stopTest();
    }
}