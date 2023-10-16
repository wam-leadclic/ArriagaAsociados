/*
@author LeadClic Solutions S.L.
@date 24/04/2019
@description Test de la clase InboundCustomerEmailHandler

<pre>
FECHA                 AUTOR           ACCION
24/04/2019		      LCS - RMG	      Creación. 
04/09/2019			  LCS - RDM		  Modificación. Subida de % de cobertura
 
*/
@isTest
public class TestInboundCustomerEmailHandler {

    static testmethod void envioEmail(){
        // Creamos el email y el envelope
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Creamos los datos del email
        email.subject = 'Test';
        email.fromAddress = 'test@email.com';
        email.plainTextBody = 'Mensaje de test';
        
        // Añadimos un adjunto binario
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('Test Adjunto');
        attachment.fileName = 'test.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        // Añadimos un adjunto de tipo texto
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'Ajunto Test Texto';
        attachmenttext.fileName = 'testTexto.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
        system.Test.StartTest();
            //LLamamos a la clase de email de servicio
            InboundCustomerEmailHandler testEnvioEmail = new InboundCustomerEmailHandler();
            testEnvioEmail.handleInboundEmail(email, env);
        system.Test.StopTest();
    }

    static testmethod void envioEmailContacto(){
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tdest';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;

        // Creamos el email y el envelope
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Creamos los datos del email
        email.subject = 'Test';
        email.fromAddress = 'test@email.com';
        email.plainTextBody = 'Mensaje de test';
        
        // Añadimos un adjunto binario
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('Test Adjunto');
        attachment.fileName = 'test.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        // Añadimos un adjunto de tipo texto
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'Ajunto Test Texto';
        attachmenttext.fileName = 'testTexto.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
        system.Test.StartTest();
            //LLamamos a la clase de email de servicio
            InboundCustomerEmailHandler testEnvioEmail = new InboundCustomerEmailHandler();
            testEnvioEmail.handleInboundEmail(email, env);
        system.Test.StopTest();
    }
}