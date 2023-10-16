/*
@author LeadClic Solutions S.L.
@date 24/04/2019
@description Clase manejadora de correos electrónicos para gestionar la entrada de las comunicaciones entrates por parte de los clientes.

<pre>
FECHA                 AUTOR           ACCION
24/04/2019		      LCS - RMG	        Creación. Solo se tienen que buscar clientes, los candidatos no usuaran este buzón de email
14/01/2020            LCS - MMV         Modificación. Si no se encuentra cuenta ni contacto se asigna a un contacto genérico.
17/05/2021		      LCS - SER	        Se envia un correo de bienvenida si el contacto no existe en SF
01/03/2022            LCS - SER         Actualización. Se trunca el body a un maximo de 3200 caracteres 
*/
global class InboundCustomerEmailHandler implements Messaging.InboundEmailHandler {
  //Variables para guardar la información del contacto y el candidato que se usa en diferentes métodos
  public Contact contacto;
  //public Lead candidato;

  /**
  *  Método encargado de manejar los email recibidos por los clientes
  *  
  * @param  email que es el email enviado por el cliente
  * @param  env dirección del from y to del email recibido
  * @return	Devolvemos si el email recibido ha podido ser gestionado correctamente
  */
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
    //Variable que se devuelve con el resultado de la gestión
    Messaging.InboundEmailResult resultado = new Messaging.InboundEmailResult();

    //Recuperamos la dirección desde la que se ha enviado el email para buscar si existe el cliente o el candidato
    contacto = new Contact();
    //candidato = new Lead();
    buscarClienteCandidato (email.fromAddress); 

    //Creamos el EmailMessage con el email que se ha recibido
    EmailMessage emailInsert = crearEmail(email, env);
    insert emailInsert;

    //Creamos el EmailMessageRelation del remitente y el destinatario
    list<EmailMessageRelation> lEmailRelationInsert = crearRelationEmail(emailInsert);
    insert lEmailRelationInsert;

    //Asociamos los archivos adjuntos al email
    list<Attachment> lAdjuntosInsert = crearAdjuntos(email, emailInsert.id);
    insert lAdjuntosInsert;

    return resultado;                                                       
	}

  /**
  *  Se busca el cliente o el candidato que ha enviado el email
  *  
  * @param  dirección de email desde el que se ha enviado el correo electrónico
  * @param	contacto registro que ha enviado el email
  * @param  candidato registro que ha enviado el email
  */
  private void buscarClienteCandidato(string direccionEmailFrom){
    //Buscamos las cuentas personales que tienen como correo electronico secundario el email que ha enviado el correo y nos quedamos con el registro cuyo contacto ha sido modificado por última vez
	  list<Account> lCuentas = [SELECT Id, PersonContactId, PersonContact.OwnerId , PersonContact.AccountId 
							  FROM Account 
						      WHERE PersonContactId != null AND CorreoElectronicoSecundario__c = :direccionEmailFrom 
							  ORDER BY PersonContact.LastModifiedDate DESC];
	
	  if(!lCuentas.isEmpty()) {
      contacto.Id = lCuentas.get(0).PersonContactId;
	    contacto.OwnerId = lCuentas.get(0).PersonContact.OwnerId;
	    contacto.AccountId = lCuentas.get(0).PersonContact.AccountId;
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
	      else {
                // Si no se encuentra Cuenta ni Contacto se asocia al contacto genérico
               lContactos = [SELECT Id, OwnerId, AccountId
									                FROM Contact
									                WHERE Id =: system.label.ContactoGenericoId];
               if(!lContactos.isEmpty()) {
                   contacto = lContactos.get(0);
               }
              
              EmailTemplate plantilla = [Select id,subject,HtmlValue  from EmailTemplate where name = 'Dirección email no registrado Cliente' limit 1];
              if (plantilla != null){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                  	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'lopd@arriagaasociados.com'];
					if ( owea.size() > 0 ) {
   						 message.setOrgWideEmailAddressId(owea.get(0).Id);
					}                    
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
             }
         }  
      }
  }

  /**
  *  Se crea el registro de email con los datos del email que se ha recibido
  *  
  * @param  email datos del correo electrónico recibido
  * @return registro de email con los datos que se van a insertar
  */
  private EmailMessage crearEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
    EmailMessage emailInsert = new EmailMessage();
    //emailInsert.CcAddress = email.ccAddresses.get(0);
    emailInsert.FromAddress = email.fromAddress;
    emailInsert.FromName = email.fromName;
    if (!string.isBlank(email.htmlBody) && email.htmlBody.length() >= 32000) {
        email.htmlBody = email.htmlBody.substring(0, 32000);
    }
    emailInsert.HtmlBody = email.htmlBody;
    //emailInsert.Headers = email.headers.get(1).value;
    emailInsert.Incoming = true;
    emailInsert.MessageDate = system.now();
    if(contacto != null) emailInsert.RelatedToId = contacto.AccountId;
    //else if(candidato != null) emailInsert.RelatedToId = candidato.id;
    /*
    Posibles valores del estado
    0 (New)
    1 (Read)
    2 (Replied)
    3 (Sent)
    4 (Forwarded)
    5 (Draft)
    */
    emailInsert.Status = '0';
    emailInsert.Subject = email.subject;
    if (!string.isBlank(email.plainTextBody) && email.plainTextBody.length() >= 32000) {
       email.plainTextBody = email.plainTextBody.substring(0, 32000);
    }
    emailInsert.TextBody = email.plainTextBody;
    emailInsert.ToAddress = env.toAddress;

    return emailInsert;
  }

  /**
  *  Se crea los registros relacionados con el email creado
  *  
  * @param  email datos del correo electrónico recibido
  * @return lista con los contactos que están relacionados al email
  */
  private list<EmailMessageRelation> crearRelationEmail(EmailMessage email){
    //lista con las relaciones que se tienen que insertar
    list<EmailMessageRelation> lRelaciones = new list<EmailMessageRelation>();

    //Si tenemos un contacto o un candidato con quien asociarlo procedemos a su creación
    if(contacto != null && contacto.id != null /*|| candidato != null*/){
      //Relación con el contacto o candidato que ha hecho el envío    
      EmailMessageRelation relationFrom = new EmailMessageRelation();
      relationFrom.EmailMessageId = email.Id;
      relationFrom.RelationAddress = email.FromAddress;
      relationFrom.RelationType = 'FromAddress';
      if(contacto != null) relationFrom.RelationId = contacto.id;
      //else if(candidato != null) relationFrom.RelationId = candidato.id;
      lRelaciones.add(relationFrom);

      //Relación con el usuario propietario del contacto o candidato
      EmailMessageRelation relationTo = new EmailMessageRelation();
      relationTo.EmailMessageId = email.Id;
      relationTo.RelationAddress = email.ToAddress;
      relationTo.RelationType = 'ToAddress';
      if(contacto != null) relationTo.RelationId = contacto.OwnerId;
      //else if(candidato != null) relationTo.RelationId = candidato.OwnerId;
      lRelaciones.add(relationTo);
    }

    return lRelaciones;
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
}