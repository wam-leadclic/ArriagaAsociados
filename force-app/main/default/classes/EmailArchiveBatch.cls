/*
@author LeadClic Solutions S.L.
@date 15/08/2023
@description Clase batch de archivado de emails antiguos.

<pre>
FECHA             AUTOR           ACCION
15/08/2023		LCS - DRU	   	  Creación. 
10/10/2023		LCS - DRU	   	  Modificación de la actualización del campo OriginEmailId__c en content documents.
*/

public class EmailArchiveBatch implements Database.Batchable<SObject> {

    /** 
     * Método para insertar los emails archivados. Implementado como queueable para evitar errores con los límites de operaciones.
     */
    public static void insertArchivedEmails(List<SObject> bigObjectRecords, List<SObject> oldEmailRecords) {

        EmailBigObjectQueueable dmlHandler = new EmailBigObjectQueueable(bigObjectRecords, oldEmailRecords);
        if(!Test.isRunningTest()){
            System.enqueueJob(dmlHandler);
        }
        
    }
    
    /**
     * Clase que implementa la interfaz del queueable. Se usa para insertar una lista de big objects.
     */
    @TestVisible
    private class EmailDeleteQueueable implements Queueable {

        private List<SObject> oldEmailRecords;

        public EmailDeleteQueueable(List<SObject> oldEmailRecords) {
            this.oldEmailRecords = oldEmailRecords;
        }

        public void execute (QueueableContext context){
            delete oldEmailRecords;
            Database.emptyRecycleBin(oldEmailRecords);
        }
    }

    
    /**
     * Clase que implementa la interfaz del queueable. Se usa para insertar una lista de big objects.
     */
    @TestVisible
    private class EmailBigObjectQueueable implements Queueable {
    
        private List<SObject> bigObjectRecords;
        private List<SObject> oldEmailRecords;
        
        public EmailBigObjectQueueable(List<SObject> bigObjectRecords, List<SObject> oldEmailRecords) {
            this.bigObjectRecords = bigObjectRecords;
            this.oldEmailRecords = oldEmailRecords;
        }
    
        public void execute (QueueableContext context) {
            Savepoint sp = Database.setSavepoint(); 
            try {
                List<Database.SaveResult> srList = Database.insertImmediate(bigObjectRecords); 
                //Realizamos un borrado completo de los emails antiguos mediante un hard delete (tiene como límite 1000 registros).
                EmailDeleteQueueable dmlHandler = new EmailDeleteQueueable(oldEmailRecords);
                System.enqueueJob(dmlHandler);
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('Exception: ' + e.getTypeName() + ', ' + e.getMessage());    
            }
        }
	}


    
    /**
     * Método start para obtener mediante query los emails antiguos para archivar.
     */
    public Database.QueryLocator start(Database.BatchableContext context) {
        Settings__mdt emailArchiveLapse = getCustomSettingValue();
        Integer numDays = (Integer)emailArchiveLapse.EmailArchiveLapse__c;
        if(Test.isRunningTest()){
            numDays = 30;
        } 

        Datetime myDT = Datetime.now().addDays(-numDays);
        String dateCondition = myDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String query;
        if(emailArchiveLapse.ArchivarHuerfanos__c){
            query = 'SELECT Id, ActivityId, ParentId, FromAddress, RelatedToId, ValidatedFromAddress, FromName, '+
                       'HasAttachment, ToAddress, CcAddress, BccAddress, Subject, TextBody, HTMLBody, MessageDate, RelatedTo.type, '+
                       'Status, IsOpened, ReplyToEmailMessageId, Parent.ContactId, Parent.AccountId '+
                       'FROM EmailMessage '+
                       'WHERE MessageDate < '+ dateCondition +
                       'ORDER BY CreatedDate asc';
        } else{
            query = 'SELECT Id, ActivityId, ParentId, FromAddress, RelatedToId, ValidatedFromAddress, FromName, '+
                       'HasAttachment, ToAddress, CcAddress, BccAddress, Subject, TextBody, HTMLBody, MessageDate, RelatedTo.type, '+
                       'Status, IsOpened, ReplyToEmailMessageId, Parent.ContactId, Parent.AccountId '+
                       'FROM EmailMessage '+
                       'WHERE MessageDate < '+ dateCondition + ' AND (ActivityId != null OR ParentId != null OR RelatedToId != null)' +
                       'ORDER BY CreatedDate asc';
        }
        

        return Database.getQueryLocator(query);
    }
    
    /**
     * Método execute para realizar el proceso de archivado.
     */
    public void execute(Database.BatchableContext context, List<EmailMessage> lEmailMessages) {
        //Mapa para relacionar las tareas con su email.
        Map<String,String> mEmailTask = new Map<String,String>();
        //Set con los ids de los diferentes emails.
        Set<Id> sEmailIds = new Set<Id>(new Map<Id, EmailMessage>(lEmailMessages).keySet());
        //Set con los ids de las task relacionadas a los emails.
        Set<Id> sTaskIds = new Set<Id>();
        //Set con los ids de las cuentas relacionadas a los emails mediante los campos ParentId, RelatedToId o ActivityId.
        Set<Id> sRelatedAccountIds = new Set<Id>();
        //Set con los ids de los casos relacionados a los emails mediante el campo ParentId.
        Set<Id> sParentCaseIds = new Set<Id>();
        //Set con los ids de las cuentas relacionadas a las task de los emails mediante el campo ActivityId.
        Set<Id> sTaskWhoIds = new Set<Id>();
        //Todos los ids a linkear en los content document links.
        Set<Id> sAllLinkedIds = new Set<Id>();
        //Mapa para relacionar los content documents con el email al que estan vinculados. 
        Map<String, Set<String>> mContentDocumentEmailIds = new Map<String, Set<String>>();
        //Mapa que relaciona la lista de content documents vinculados a cada email.
        Map<String, List<ContentVersion>> mContentDocuments = new Map<String, List<ContentVersion>>();
        //Id del contacto genérico para los emails huerfanos (custom label).
        String genericContactId = System.Label.ContactoGenericoId;
        //Id de la cuenta genérica para los emails huerfanos.
		String genericAccountId;        
        //Cuenta genérica
        List<Account> lGenericAccount = [SELECT Id FROM Account WHERE PersonContactId = :genericContactId];
        //Se hace un guardado de la base de datos por si hubiese algún error en el proceso.
        Savepoint sp = Database.setSavepoint(); 
        try{
            //Añadimos el id de la cuenta y el contacto genéricos
            sAllLinkedIds.add(genericContactId);
            if(lGenericAccount!= null && !lGenericAccount.isEmpty()){
                genericAccountId = lGenericAccount[0].id;
                sAllLinkedIds.add(genericAccountId);
            }
            

            //Mapeamos el id de la task al email relacionado
            for(EmailMessage ems :lEmailMessages){
                if(ems.ActivityId!=null){
                    mEmailTask.put(ems.id, ems.ActivityId);
                    sTaskIds.add(ems.ActivityId);
                    sAllLinkedIds.add(ems.ActivityId);
                   
                }
                if(ems.RelatedToId!=null && ems.RelatedTo.Type!=null && ems.RelatedTo.Type == 'Account'){
                    sRelatedAccountIds.add(ems.RelatedToId);
                    sAllLinkedIds.add(ems.RelatedToId);
                }
                if(ems.ParentId!=null){
                    sParentCaseIds.add(ems.ParentId);
                    sAllLinkedIds.add(ems.ParentId);
                }
            }
            
            //Mapa que relaciona las diferentes task asociadas a los emails mediante su id como key.
            Map<Id,Task> mTasks = new Map<Id,Task>([SELECT Id, WhoId, Who.Type FROM Task WHERE ID IN :sTaskIds]);

            for(Id key : mTasks.keySet()){
                sTaskWhoIds.add(mTasks.get(key).WhoId);
                sAllLinkedIds.add(mTasks.get(key).WhoId);
            }


            //Mapa que relaciona las diferentes cuentas asociadas a los emails (ActivityId) mediante su id como key.
            Map<Id,Lead> mTasksLeads = new Map<Id,Lead>([SELECT Id, ConvertedContactId FROM Lead WHERE ID IN :sTaskWhoIds]);

            //Mapa de contactos asociados a las actividades relacionadas a los correos.
            Map<Id, Contact> mTaskContacts = new Map<Id, Contact>([SELECT Id, AccountId, IsPersonAccount  FROM Contact WHERE ID IN :sTaskWhoIds]);
            for(Id key : mTaskContacts.keySet()){
                sRelatedAccountIds.add(mTaskContacts.get(key).AccountId);
                sAllLinkedIds.add(mTaskContacts.get(key).AccountId);
            }
    
            //Mapa que relaciona los diferentes casos asociados a los emails (ParentId) mediante su id como key.
            Map<Id,Case> mCaseParentId = new Map<Id,Case>([SELECT Id, ContactId, AccountId FROM Case WHERE ID IN :sParentCaseIds]);

            for(Id key : mCaseParentId.keySet()){
                sRelatedAccountIds.add(mCaseParentId.get(key).AccountId);
                sAllLinkedIds.add(mCaseParentId.get(key).AccountId);
                sAllLinkedIds.add(mCaseParentId.get(key).ContactId);
            }

            //Mapa que relaciona las diferentes cuentas asociadas a los emails mediante su id como key.
            Map<Id,Account> mRelatedAccounts = new Map<Id,Account>([SELECT Id, PersonContactId, IsPersonAccount FROM Account WHERE ID IN :sRelatedAccountIds]);

            //Lista de contactos relacionados a las cuentas
            Map<Id,Contact> mRelatedContacts = new Map<Id,Contact>([SELECT Id, AccountId FROM Contact WHERE AccountId IN :sRelatedAccountIds]);

            //Mapa para obtener el contacto de una determinada cuenta
            Map<String, String> mAccountContact = new Map<String, String>();
            for(Id key : mRelatedContacts.keySet()){
                mAccountContact.put(mRelatedContacts.get(key).AccountId, mRelatedContacts.get(key).id);
                sAllLinkedIds.add(mRelatedContacts.get(key).AccountId);
                sAllLinkedIds.add(mRelatedContacts.get(key).id);
            }

            //Mapeamos los diferente content documents con el id de su email relacionado.
            Set<String> sIdsAux = new Set<String>();
            for (ContentDocumentLink documentLink : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:sEmailIds]) {
                sIdsAux = new Set<String>();
                if(mContentDocumentEmailIds.containsKey(documentLink.ContentDocumentId)){
                    sIdsAux = mContentDocumentEmailIds.get(documentLink.ContentDocumentId);
                }
                sIdsAux.add(documentLink.LinkedEntityId);
                mContentDocumentEmailIds.put(documentLink.ContentDocumentId, sIdsAux);
                
            }

            //Mapeamos el content document id con su linkedEntityId para evitar insertar document links ya vinculados en la base de datos.
            sIdsAux = new Set<String>();
            Map<String,Set<String>> mAllDocumentLinks = new Map<String,Set<String>>();

            if(sAllLinkedIds.size()!=0){
      			for (ContentDocumentLink documentLink : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:sAllLinkedIds AND ContentDocumentId IN :mContentDocumentEmailIds.keySet()]) {
                    sIdsAux = new Set<String>();
                    if(mAllDocumentLinks.containsKey(documentLink.ContentDocumentId)){
                        sIdsAux = mAllDocumentLinks.get(documentLink.ContentDocumentId);
                    }
                    sIdsAux.add(documentLink.LinkedEntityId);
                    mAllDocumentLinks.put(documentLink.ContentDocumentId, sIdsAux);
            	}
            }

            //Lista de todos los content documents relacionados a los emails para actualizar.
            Map<Id,ContentVersion> mContentDocumentsToUpdate = new Map<Id,ContentVersion>();
            //Lista auxiliar para el mapeado de los content documents.
            List<ContentVersion> lContentDocumentsAux = new List<ContentVersion>();

            //Mapeamos todos los content documents asociados a un correo, usando el id del email como key.
            for (ContentVersion contentDocument : [SELECT Id, OriginEmailId__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :mContentDocumentEmailIds.keySet()]) {
                for(String emailId : mContentDocumentEmailIds.get(contentDocument.ContentDocumentId)){
                    lContentDocumentsAux = new List<ContentVersion>();
                    if(mContentDocuments.containsKey(emailId)){
                        lContentDocumentsAux = mContentDocuments.get(emailId);
                    }

                    lContentDocumentsAux.add(contentDocument);
                    mContentDocuments.put(emailId, lContentDocumentsAux);
                 }
            }
    
            //Set de los nuevos content document links a insertar (utilizamos set para evitar duplicados).
            Set<ContentDocumentLink> sDocumentLinksToInsert = new Set<ContentDocumentLink>();
            //Lista de los emails archivados a insertar.
            List<ArchivedEmail__b> lArchivedEmails = new List<ArchivedEmail__b>();
            //Valor del id de la cuenta/lead asociada al email.
            String accountOrLeadId;
            //Valor del id del contacto asociado al email.
            String contactId;
            //Valor del id del caso asociado al email.
            String parentId;
            //Mapa que relaciona el correo con los valores contact id y account/lead id para relacionar los content document links. 
            Map<String, Map<String, String>> mEmailLinkIds = new Map<String, Map<String, String>> ();
            //Mapa auxiliar para almacenar el id del contacto y el id de la cuenta/lead.
            Map<String, String> mLinkIdsAux = new Map<String, String>();

            //Recorremos los diferentes emails para realizar el proceso de archivado.
            for (EmailMessage emailMessage : lEmailMessages) {            
                accountOrLeadId = null;
                contactId = null;
                parentId = null;
                mLinkIdsAux = new Map<String, String>();

                //Obtenemos los ids del contacto y cuenta/lead asociados al email para vincularlo a los content documents links.
                if(emailMessage.ParentId != null){
                    accountOrLeadId = mCaseParentId.get(emailMessage.ParentId).AccountId;
                    //Comprobamos si se trata de un person account para evitar duplicados en la creación de document links
                    contactId = (mCaseParentId.get(emailMessage.ParentId).AccountId == null && mCaseParentId.get(emailMessage.ParentId).ContactId != null) || 
                                (mRelatedAccounts.containsKey(mCaseParentId.get(emailMessage.ParentId).AccountId) && !mRelatedAccounts.get(mCaseParentId.get(emailMessage.ParentId).AccountId).IsPersonAccount) ? 
                        		mCaseParentId.get(emailMessage.ParentId).ContactId : null;
                    parentId = emailMessage.ParentId;
                }
                //En caso de no estar asignado a un caso obtenemos los datos de la cuenta mediante el campo RelatedToId. 
                else if (emailMessage.RelatedToId != null && emailMessage.RelatedTo.Type != null && emailMessage.RelatedTo.Type.equals('Account')){
                    accountOrLeadId = emailMessage.RelatedToId;
                    //Comprobamos si se trata de un person account para evitar duplicados en la creación de document links
                    contactId = mRelatedAccounts.containsKey(emailMessage.RelatedToId) && !mRelatedAccounts.get(emailMessage.RelatedToId).IsPersonAccount ? 
                        		mAccountContact.get(emailMessage.RelatedToId) : null;
                }
                //La actividad puede estar asociada a un Lead o un Contacto, cubrimos ambos casos. 
                else if(emailMessage.ActivityId != null && mTasks.get(mEmailTask.get(emailMessage.id)).WhoId!= null && 
                          mTasks.get(mEmailTask.get(emailMessage.id)).Who.Type.equals('Lead')){

                    accountOrLeadId = mTasksLeads.containsKey(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId) ? 
                        			  mTasksLeads.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).id : null;

                    contactId = mTasksLeads.containsKey(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId) ? 
                        		mTasksLeads.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).ConvertedContactId : null; 
                }
                else if(emailMessage.ActivityId != null && mTasks.get(mEmailTask.get(emailMessage.id)).WhoId!= null && 
                         mTasks.get(mEmailTask.get(emailMessage.id)).Who.Type.equals('Contact')){

                    //Comprobamos si se trata de un person account para evitar duplicados en la creación de document links
                    accountOrLeadId = mTaskContacts.containsKey(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId) && !mTaskContacts.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).IsPersonAccount ? 
                        			  mTaskContacts.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).AccountId : mTaskContacts.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).Id;
                    contactId = mTaskContacts.containsKey(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId) && !mTaskContacts.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).IsPersonAccount ? 
                        		mTaskContacts.get(mTasks.get(mEmailTask.get(emailMessage.id)).WhoId).Id : null;  
                } 
                //Si el correo es huérfano se le asigna a un contacto genérico almacenado en una custom label.
                else{
                    accountOrLeadId = genericAccountId;
                }
                
                //Vinculamos los ids del contacto y cuenta al mapa de emails.
                mLinkIdsAux.put('contactId', contactId != null ? contactId : 'null');
                mLinkIdsAux.put('accountOrLeadId', accountOrLeadId != null ? accountOrLeadId : 'null');
                mLinkIdsAux.put('parentId', parentId != null ? parentId : 'null');
                mEmailLinkIds.put(emailMessage.id, mLinkIdsAux);

                //Actualizamos el nuevo campo de los content documents existentes y creamos los nuevos content document links.
                if(mContentDocuments.containsKey(emailMessage.Id)){
                    for (ContentVersion contentDocument : mContentDocuments.get(emailMessage.Id)) {
                        //Actualizamos el content document rellenando el campo OriginEmailId__c.
                        if(contentDocument.OriginEmailId__c!= null){
                            contentDocument.OriginEmailId__c = emailMessage.Id + ',' + contentDocument.OriginEmailId__c;
                        } else{
                            contentDocument.OriginEmailId__c = emailMessage.Id;
                        }
                        mContentDocumentsToUpdate.put(contentDocument.id,contentDocument);
                        //Creamos un content document link, comprobando que no exista el mismo document link ya vinculado al contacto.
                        if((contactId!=null && !mAllDocumentLinks.containsKey(contentDocument.ContentDocumentId)) || 
                           (contactId!=null && mAllDocumentLinks.containsKey(contentDocument.ContentDocumentId) && 
                           !mAllDocumentLinks.get(contentDocument.ContentDocumentId).contains(contactId))){

                            sDocumentLinksToInsert.add(new ContentDocumentLink(
                                ContentDocumentId = contentDocument.ContentDocumentId,
                                LinkedEntityId = contactId
                            ));    
                        }
                        //Creamos un content document link, comprobando que no exista el mismo document link ya vinculado al account/lead.
                        if((accountOrLeadId!=null && !mAllDocumentLinks.containsKey(contentDocument.ContentDocumentId)) || 
                           (accountOrLeadId!=null && mAllDocumentLinks.containsKey(contentDocument.ContentDocumentId) && 
                           !mAllDocumentLinks.get(contentDocument.ContentDocumentId).contains(accountOrLeadId))){

                            sDocumentLinksToInsert.add(new ContentDocumentLink(
                                ContentDocumentId = contentDocument.ContentDocumentId,
                                LinkedEntityId = accountOrLeadId
                            ));
                        }
                        //Creamos un content document link, comprobando que no exista el mismo document link ya vinculado al caso.
                        if((parentId!=null && !mAllDocumentLinks.containsKey(contentDocument.ContentDocumentId)) || 
                           (parentId!=null && mAllDocumentLinks.containsKey(contentDocument.ContentDocumentId) && 
                           !mAllDocumentLinks.get(contentDocument.ContentDocumentId).contains(parentId))){
                            
                            sDocumentLinksToInsert.add(new ContentDocumentLink(
                                ContentDocumentId = contentDocument.ContentDocumentId,
                                LinkedEntityId = parentId
                            ));
                            
                        }
                    }
                }
            
                //Creamos el nuevo email archivado.
                lArchivedEmails.add(new ArchivedEmail__b(
                    OriginEmailId__c = emailMessage.Id,
                    AccountOrLeadId__c = accountOrLeadId != null ? accountOrLeadId : '001000000000000AAA',
                    ContactId__c = contactId != null ? contactId : '003000000000000AAA',
                    CaseId__c = parentId != null ? parentId : '500000000000000AAA',
                    FromAddress__c = emailMessage.FromAddress,
                    ValidatedFromAddress__c = emailMessage.ValidatedFromAddress,
                    FromName__c = emailMessage.FromName,
                    HasAttachment__c = emailMessage.HasAttachment ? 1 : 0,
                    ToAddress__c = emailMessage.ToAddress,
                    ToAddressCC__c = emailMessage.CcAddress,
                    ToAddressBCC__c = emailMessage.BccAddress,
                    Subject__c = emailMessage.Subject,
                    TextBody__c = emailMessage.TextBody,
                    HTMLBody__c = emailMessage.HtmlBody,
                    MessageDate__c = emailMessage.MessageDate,
                    PreviousEmailId__c = emailMessage.ReplyToEmailMessageId,
                    Status__c = emailMessage.Status,
                    IsOpened__c = emailMessage.IsOpened ? 1 : 0
                ));
            }

            //Insertamos los nuevos content document links.
            List<ContentDocumentLink> lDocumentLinksToInsert = new List<ContentDocumentLink>();
            if (!sDocumentLinksToInsert.isEmpty()) {
                //Con el set evitamos insertar duplicados
                lDocumentLinksToInsert.addAll(sDocumentLinksToInsert);
                insert lDocumentLinksToInsert;
            }
            //Actualizamos los content documents existentes.
            if(!mContentDocuments.isEmpty()){
                update mContentDocumentsToUpdate.values();
            }

            //Insertamos los emails archivados y borramos los antiguos.
            if (!lArchivedEmails.isEmpty()) {
                insertArchivedEmails(lArchivedEmails, lEmailMessages);
            }

        }catch(Exception ex){
            //Si sucede algún error en el proceso revertimos la base de datos a su estado previo al archivado.
            Database.rollback(sp);
            throw ex;
        }
    }
    
    /**
     * Método finish del batch.
     */
    public void finish(Database.BatchableContext context) {
    }
    
    /**
     * Método helper para obtener la custom metadata "Settings__mdt".
     */
    private Settings__mdt getCustomSettingValue() {
        Settings__mdt settings = Settings__mdt.getInstance('EmailArchiveLapse');
        return settings != null ? settings : null;
    }

}