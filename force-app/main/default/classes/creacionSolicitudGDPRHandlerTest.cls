/*
@author LeadClic Solutions S.L.
@date 24/04/2019
@description Test de la clase creacionSolicitudGDPRHandler

<pre>
FECHA                 AUTOR           ACCION
02/02/2021		      LCS - SER	      Creación. 
 
*/
@isTest

public class creacionSolicitudGDPRHandlerTest {

    static testmethod void envioEmail(){
        // Creamos el email y el envelope
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // Creamos los datos del email
        email.subject = 'Test';
        email.fromAddress = 'test@email.com';
        email.plainTextBody = 'ref:_00D5E4bK9._a0k9E7TzQfQAK:ref ]';
        email.htmlBody = 'ref:_00D5E4bK9._a0k9E7TzQfQAK:ref ]';
        
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
            creacionSolicitudGDPRHandler testEnvioEmail = new creacionSolicitudGDPRHandler();
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
        email.plainTextBody = 'ref:_00D5E4bK9._a0k9E7TzQfQAK:ref ]';
        email.htmlBody = 'ref:_00D5E4bK9._a0k9E7TzQfQAK:ref ]';
        
        // Añadimos un adjunto binario
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('Test Adjunto');
        attachment.fileName = 'test.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
        
        // Añadimos un adjunto de tipo texto
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'Adjunto Test Texto';
        attachmenttext.fileName = 'testTexto.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
        system.Test.StartTest();
            //LLamamos a la clase de email de servicio
            creacionSolicitudGDPRHandler testEnvioEmail = new creacionSolicitudGDPRHandler();
            testEnvioEmail.handleInboundEmail(email, env);
        system.Test.StopTest();
    }
}