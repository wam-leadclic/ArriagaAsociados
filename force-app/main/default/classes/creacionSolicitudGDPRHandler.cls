/*
@author LeadClic Solutions S.L.
@date 24/04/2019
@description Clase manejadora de correos electrónicos para gestionar las solicitudes de GDPR.

<pre>
FECHA                 AUTOR           ACCION
02/02/2021            LCS - SER         Creación. Solo se tienen que buscar clientes, los candidatos no usuaran este buzón de email
01/03/2022            LCS - SER         Actualización. Se trunca el body a un maximo de 3200 caracteres  
*/

global class creacionSolicitudGDPRHandler implements Messaging.InboundEmailHandler{
    public Contact contacto;
    /**
  *  Método encargado de manejar los email recibidos por los clientes
  *  
  * @param  email que es el email enviado por el cliente
  * @param  env dirección del from y to del email recibido
  * @return Devolvemos si el email recibido ha podido ser gestionado correctamente
  */
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
            Messaging.InboundEmailResult resultado = new Messaging.InboundEmailResult();
            //Comprobamos si existe un Contacto ya existente con este correo
            buscarClienteCandidato(email.fromAddress);
            User ownerId = [Select id, name,email, title from user where userName like '%sistemas@arriagaasociados%'  LIMIT 1 ];
            //Creamos la nueva solicitud de GDPR
            lcs_gdpr__GDPRRequest__c solicitudGDPR = new lcs_gdpr__GDPRRequest__c();
            String solicitudName= extractRef(email.subject);
            //If solicitudNumber is not in the subject extract from email body
            if(solicitudName == null){
            solicitudName = extractRef(JSON.serialize(email.plainTextBody));
                if(solicitudName == null){
                    solicitudName = extractRef(string.valueOf(JSON.serialize(email.htmlBody)));
                }
            }
            if (solicitudName!= null){
                solicitudGDPR =[Select id from lcs_gdpr__GDPRRequest__c where Name = :solicitudName limit 1];
            }
            else{
                solicitudGDPR.lcs_gdpr__Status__c='Pending';
                solicitudGDPR.lcs_gdpr__Subject__c= email.subject;
                solicitudGDPR.lcs_gdpr__RequestText__c= email.plainTextBody;
                solicitudGDPR.OwnerId = ownerId.id;
                //Si existe ya el contacto, lo asociamos a la solicitud
                if (contacto != null){
                    solicitudGDPR.lcs_gdpr__Contact__c= contacto.id;
                }
                
                insert solicitudGDPR;
            }
            List<String> lCcAddress = new List<String>();
            
            //Creamos el EmailMessage
            EmailMessage newEmail = new EmailMessage();
            newEmail.FromAddress = email.fromAddress;
            newEmail.CcAddress= String.valueOf(email.ccAddresses);
            newEmail.FromName = email.fromName;
            newEmail.Headers = String.valueOf(email.headers);
            newEmail.RelatedToId = solicitudGDPR.id;
        	Integer maxSize = 10000;
			if(String.valueOf(email.plainTextBody).length() > maxSize ){
   			 	email.plainTextBody = email.plainTextBody.substring(0, maxSize);
			}
        	if(email.htmlBody.length() > maxSize ){
   			 	email.htmlBody = email.htmlBody.substring(0, maxSize);
			}
            newEmail.HtmlBody = email.htmlBody;        
            newEmail.Subject = email.Subject;
        	if (!string.isBlank(email.plainTextBody) && email.plainTextBody.length() >= 32000) {
            	email.plainTextBody = email.plainTextBody.substring(0, 32000);
        	}
            newEmail.TextBody = String.valueOf(email.plainTextBody);
            newEmail.ToAddress = System.label.emailComercial;
            newEmail.Status = '0';
            insert newEmail;
            list<Attachment> lAdjuntosInsert = crearAdjuntos(email, newEmail.id);
            insert lAdjuntosInsert;  
            return resultado;
    }
    /**
  *  Se busca el cliente que ha enviado el email
  *  
  * @param  dirección de email desde el que se ha enviado el correo electrónico
  * @param  contacto registro que ha enviado el email
  * @param  candidato registro que ha enviado el email
  */
    private void buscarClienteCandidato(string direccionEmailFrom){
    //Buscamos las cuentas personales que tienen como correo electronico secundario el email que ha enviado el correo y nos quedamos con el registro cuyo contacto ha sido modificado por última vez
      list<Account> lCuentas = [SELECT Id, PersonContactId, PersonContact.OwnerId , PersonContact.AccountId 
                              FROM Account 
                              WHERE PersonContactId != null AND (CorreoElectronicoSecundario__c = :direccionEmailFrom OR PersonEmail  = :direccionEmailFrom)
                              ORDER BY PersonContact.LastModifiedDate DESC limit 1];
     system.debug('lCuentas'+lCuentas.size());
      if(!lCuentas.isEmpty()) {
          system.debug('lCuentas.get(0).PersonContactId; '+lCuentas.get(0).PersonContactId);
          contacto = new contact(
          Id = lCuentas.get(0).PersonContactId,
          OwnerId = lCuentas.get(0).PersonContact.OwnerId,
          AccountId = lCuentas.get(0).PersonContact.AccountId);
      }
      else{
          //Buscamos a los contactos que tienen el email por el que han mandado el correo electrónico y nos quedamos con el registro que ha sido modificado por última vez
          list<Contact> lContactos = [SELECT Id, OwnerId, AccountId
                                                    FROM Contact
                                                    WHERE email = :direccionEmailFrom
                                                    ORDER BY LastModifiedDate DESC];

          if(!lContactos.isEmpty()) {
              contacto = lContactos.get(0);
          }
         /* else {
            EmailTemplate plantilla = [Select id,subject,HtmlValue  from EmailTemplate where name = 'Dirección email no registrado Cliente' limit 1];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { direccionEmailFrom };
            message.optOutPolicy = 'FILTER';
            message.subject = plantilla.subject;
            message.htmlbody = plantilla.HtmlValue;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else 
            {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
                      }*/
      }
    }
     /**
  *  Se añaden los adjuntos al email
  *  
  * @param  email datos del correo electrónico recibido
  * @param  idEmail id del email que se ha creado para guardar la información 
  * @return lista con los adjuntos que hay que insertar
  */
  private list<Attachment> crearAdjuntos(Messaging.inboundEmail email, Id idEmail){
    //lista con los adjuntos que se insertan con el email
    list<Attachment> lAdjuntos = new list<Attachment>();

    //Recorremos los adjuntos del tipo texto del correo electrónico recibido 
    if(email.textAttachments != null){
      for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
        Attachment attachment = new Attachment();
        attachment.Name = tAttachment.fileName;
        attachment.Body = Blob.valueOf(tAttachment.body);
        attachment.ParentId = idEmail;
        lAdjuntos.add(attachment);
      }
    }

    //Recorremos los adjuntos del tipo binario del correo electrónico recibido 
    if(email.binaryAttachments != null){
      for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
        Attachment attachment = new Attachment();
        attachment.Name = bAttachment.fileName;
        attachment.Body = bAttachment.body;
        attachment.ParentId = idEmail;
        lAdjuntos.add(attachment);
      }
    }
    
    return lAdjuntos;
  }
    /**
    @description    Extract the reference number
    @param          caseRef         String where can be the reference of the case
    @return         Case number
    */
    public String extractRef(String caseRef) {
        
        String itemRef = null;
        String target = caseRef.toLowerCase();
        String patternString;
        Pattern thePattern;
        Matcher matcher;
         
        /*  Take the text between the period and ":ref"  For example in the ref [ ref:_00D5E4bK9._5005E2QwY4:ref ] extract 5005E000002QwY4
         Append 5005E000002QwY4 to https://na5.salesforce.com/  to produce https://na5.salesforce.com/5005E000002QwY4.   This is your link to get to the case
        */  
        patternString = '.*ref:_(.{9})._(.{5})(.+):ref.*';
        thePattern = Pattern.compile(patternString);
        system.debug('thePattern '+thePattern);
        matcher = thePattern.matcher(caseRef); // do not change to lower case for this test because Id's are case sensitive
        system.debug('matcher '+matcher);
        //the ref id in the email is the ref id send by salesforce
        if (matcher.matches()) {
            String solicitudId = '';
             if( (matcher.group(2).length() + matcher.group(3).length() ) < 18){
                integer ToAdd = 18 - matcher.group(2).length() + matcher.group(3).length();
                 system.debug('id'+matcher.group(2) + matcher.group(3));
                 system.debug('ToAdd'+ToAdd);
                solicitudId = matcher.group(2) + '00000' + matcher.group(3);
                   
            }
            /*
            Boolean SandBox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            if(!SandBox){
                caseId = matcher.group(2) + '0000' + matcher.group(3);   
            }
            else{
                caseId = matcher.group(2) + '00000' + matcher.group(3);
            }*/
             system.debug('solicitudId '+solicitudId);
             
            lcs_gdpr__GDPRRequest__c[] matchingSolicitudes = [Select Name from lcs_gdpr__GDPRRequest__c where Id = :solicitudId];
            if(matchingSolicitudes.size() == 1) {
                lcs_gdpr__GDPRRequest__c tSolicitud = matchingSolicitudes[0];
                itemRef = tSolicitud.Name;
            }    
        }  
        //the ref id in the email is a complete ref id
        else{
            patternString = '.*ref:_(.{15})._(.{4})(.+):ref.*';
            thePattern = Pattern.compile(patternString);
            matcher = thePattern.matcher(caseRef); // do not change to lower case for this test because Id's are case sensitive
            if (matcher.matches()) {
                String solicitudId = matcher.group(2) + matcher.group(3);
                lcs_gdpr__GDPRRequest__c[] matchingSolicitudes = [Select Name from lcs_gdpr__GDPRRequest__c where Id = :solicitudId];
                if(matchingSolicitudes.size() == 1) {
                    lcs_gdpr__GDPRRequest__c tSolicitud = matchingSolicitudes[0];
                    itemRef = tSolicitud.Name;
                }    
            }  
        }
        
        //the ref id does not exist in the email, but contains the case number
        if(itemRef == null) {
            // extract the Case Number from the String
            // Re: Test two numbers Case: 30088 and Case: 30089'
            // returns 30089, the last pattern matched
            patternString = '.*case[;:=]?\\s*([0-9]+).*';
            thePattern = Pattern.compile(patternString);
            matcher = thePattern.matcher(target);
            
            if (matcher.matches()) {
                itemRef = matcher.group(1);
            }
        }
    
        return itemRef; 
    }
}