/*
@author LeadClic Solutions S.L.
@date 29/04/2019
@description Clase controladora del lwc de email huerfanos

<pre>
FECHA                 AUTOR           ACCION
29/04/2019		      LCS - RMG	      Creación. 
14/01/2020		      LCS - MMV	      Modificación. 
 
*/
public without sharing class EmailHuerfanosController {
    /**
    *  Método que devuelve los emails que están huerfanos (no tienen asigando un relacionado con)
    *      
    * @return	Devolvemos el listado de los emails
    */
    @AuraEnabled(cacheable=true)
    public static list<EmailMessage> getEmailHuerfanosBusqueda() {

        // Buscamos los datos del contacto genérico
        list<Contact> lContactos = [SELECT Id, OwnerId, AccountId
                                    FROM Contact
                                    WHERE Id =: system.label.ContactoGenericoId];

        Id cuentaGenerica = lContactos.isEmpty() ? null : lContactos[0].AccountId;


        list<EmailMessage> lEmail = [SELECT Id, FromAddress, Subject, MessageDate, FromName, CcAddress
                                    FROM EmailMessage
                                    WHERE RelatedToId = null OR RelatedToId =: cuentaGenerica
                                    ORDER BY MessageDate DESC];
        
        return lEmail;
    }


    /**
    *  Método que elimina el registro de email
    *      
    * @param	Id del registro que se va a eliminar
    * @return   Listado de los emails huerfanos con la información actualizada
    */
    @AuraEnabled
    public static list<EmailMessage> eliminarEmail(string idRegistro) {
        EmailMessage emailEliminar = new EmailMessage();
        emailEliminar.id = idRegistro;
        delete emailEliminar;   

        //Llamamos a la búsqueda de emails para refrescar el listado  
        return getEmailHuerfanosBusqueda();   
    }

    /**
    *  Método que crea el remitente del correo
    *      
    * @param	Id del registro de email al que se va a relacionar el cliente
    * @param    Id del cliente al que se va a asociar
    * @return   Listado de los emails huerfanos con la información actualizada
    */
    @AuraEnabled
    public static list<EmailMessage> actualizarRemitenteEmail(string idEmail, string idRemitente) {
        //Buscamos el email, los datos del contacto que se ha indicado como remitente y los adjuntos al email
        list<EmailMessage> lEmail = [SELECT Id, ParentId, ActivityId, CreatedById, CreatedDate, TextBody, HtmlBody, Headers, FromName, Subject, FromAddress, 
                                    ToAddress, CcAddress, BccAddress, Incoming, HasAttachment, Status, MessageDate, ReplyToEmailMessageId, 
                                    IsExternallyVisible, MessageIdentifier, ThreadIdentifier, IsClientManaged, IsTracked, IsOpened, FirstOpenedDate, 
                                    LastOpenedDate, IsBounced, EmailTemplateId 
                                    FROM EmailMessage
                                    WHERE id = :idEmail];

        
        list<Contact> lContactos = [SELECT Id, OwnerId, AccountId
                                FROM Contact
                                WHERE id = :idRemitente];

        //Listado con los adjuntos al email
        list<Attachment> lAdjuntos = [SELECT Id, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, CreatedDate, CreatedById, Description, SystemModstamp
                                      FROM Attachment
                                      WHERE ParentId = :idEmail];                                

        if(!lEmail.isEmpty() && !lContactos.isEmpty()){
            EmailMessage email = lEmail.get(0);
            //Como no se pueden realizar modificaciones sobre el campo RelatedToId clonamos el registro de email                      
            EmailMessage emailClonado = email.clone(false, true, true, true);        
            emailClonado.RelatedToId = lContactos.get(0).AccountId;
            insert emailClonado;   
            
            //Buscamos si el email tiene adjuntos y en caso de tener se asocian al nuevo email
            list<Attachment> lAdjuntosUpdate = adjuntosEmail(idEmail, emailClonado.id, lAdjuntos);
            insert lAdjuntosUpdate;

            //Eliminamos los adjuntos que se han clonado
            delete lAdjuntos;
            
            //Creamos la relación con el cliente que se ha identificado como que ha hecho el envío
            //Creamos al email el EmailMessageRelation y añadimos el TO y el FROM 
            insert crearRelationEmail(emailClonado, lContactos.get(0));

            //Eliminamos el email que acabamos de clonar
            delete email;
        }
        //Llamamos a la búsqueda de emails para refrescar el listado  
        return getEmailHuerfanosBusqueda();   
    }


    /**
    *  Se crea los registros relacionados con el email creado
    *  
    * @param  email datos del correo electrónico recibido
    * @return lista con los contactos que están relacionados al email
    */
    private static list<EmailMessageRelation> crearRelationEmail(EmailMessage email, Contact contacto){
        //lista con las relaciones que se tienen que insertar
        list<EmailMessageRelation> lRelaciones = new list<EmailMessageRelation>();
        //Relación con el cliente que se ha identificado que ha hecho el envío
        EmailMessageRelation relationFrom = new EmailMessageRelation();
        relationFrom.EmailMessageId = email.Id;
        relationFrom.RelationAddress = email.FromAddress;
        relationFrom.RelationType = 'FromAddress';
        relationFrom.RelationId = contacto.id;
        lRelaciones.add(relationFrom);

        //Relación con el usuario propietario del contacto o candidato
        EmailMessageRelation relationTo = new EmailMessageRelation();
        relationTo.EmailMessageId = email.Id;
        relationTo.RelationAddress = email.ToAddress;
        relationTo.RelationType = 'ToAddress';
        relationTo.RelationId = contacto.OwnerId;                
        lRelaciones.add(relationTo);

        return lRelaciones;
    }

    /**
    *  Se buscan los adjuntos del email y se copian en el nuevo email
    *  
    * @param  id del email enviado por el cliente
    * @param id del email que se ha clonado
    * @param listado con los archivos adjuntos al email
    * @return lista con los adjuntos que hay que modificar
    */
    private static list<Attachment> adjuntosEmail(id idEmail, id idEmailClonado, list<Attachment> lAdjuntos){        
        //Clonación de los adjuntos porque no se puede modificar el parent id
        list<Attachment> lAdjuntosClonados = new list<Attachment>();
        for(Attachment adjunto :lAdjuntos){
            Attachment adjuntoClonado = adjunto.clone();
            adjuntoClonado.ParentId = idEmailClonado;
            lAdjuntosClonados.add(adjuntoClonado);
        }

        return lAdjuntosClonados;
    }
}