/*
@author LeadClic Solutions S.L.
@date 15/08/2023
@description Clase test para el batch de archivado de emails antiguos.

<pre>
FECHA             AUTOR           ACCION
15/08/2023		LCS - DRU	   	  Creación. 
15/08/2023		LCS - DRU	   	  Aumento de cobertura para gestión de ficheros duplicados.
*/

@isTest
public class EmailArchiveBatchTest {

    @testSetup static void setup() {
        //Test data setup
        Account testAccount = new Account();
		testAccount.Name='Test Account' ;
        testAccount.Phone = '455565464';
		insert testAccount;
		
		Contact cont = new Contact();
		cont.FirstName='Test';
		cont.LastName='Test';
		cont.Accountid= testAccount.id;
		insert cont;

        Case caseObj = new Case(
        ContactId = cont.id,
        AccountId = testAccount.id,
        Status = 'Working',
        Origin = 'Phone');

        insert caseObj;
    }

    //Método que se encarga de probar la correcta recogida de emails en la query del comienzo del batch.
    @isTest
    static void testStart() {

        //Data setup.
        Case cas = [SELECT Id,ContactId,AccountId FROM Case LIMIT 1];
    
        //Lista de emails a insertar
        List<EmailMessage> lEmails = new List<EmailMessage>();

        EmailMessage emailMessage = new EmailMessage(
            Subject = 'Test Email',
            TextBody = 'This is a test email',
            MessageDate = Date.today().addDays(-10),
            ParentId = cas.id
        );

        lEmails.add(emailMessage);

        EmailMessage emailMessage2 = new EmailMessage(
            Subject = 'Test Email (created today)',
            TextBody = 'This is a test email',
            MessageDate = Date.today()
        );

        lEmails.add(emailMessage2);
        
        EmailMessage emailMessage3 = new EmailMessage(
            Subject = 'Test Email (without related id)',
            TextBody = 'This is a test email',
            MessageDate = Date.today().addDays(-40),
            ParentId = cas.id
        );

        lEmails.add(emailMessage3);

        insert lEmails;

        // Test
        Test.startTest();
        EmailArchiveBatch batch = new EmailArchiveBatch();
        Database.QueryLocator queryLocator = batch.start(null);
        Test.stopTest();

        // Se comprueba que la query recoja unicamente los emails que cumplan los filtros establecidos.
        List<SObject> lResults = Database.query(queryLocator.getQuery());
        System.assertEquals(1, lResults.size());
        System.assertEquals(emailMessage3.Id, lResults[0].get('Id'));
    }

    //Método encargado de probar el correcto funcionamiento del execute para diferentes emails con attachments asociados.
    @isTest
    static void testExecute() {

        //Data setup.
        Case cas = [SELECT Id,ContactId,AccountId FROM Case LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        //Email messages.
        List<EmailMessage> lEmails = new List<EmailMessage>();

        EmailMessage emailMessage = new EmailMessage(
            Subject = 'Test Email Case',
            TextBody = 'This is a test email',
            MessageDate = Date.today().addDays(-40),
            ParentId = cas.id
        );
        lEmails.add(emailMessage);
        
        EmailMessage emailMessage2 = new EmailMessage(
            Subject = 'Test Email Account',
            TextBody = 'This is a test email',
            MessageDate = Date.today().addDays(-40),
            RelatedToId = acc.id
        );
		lEmails.add(emailMessage2);
        
        insert lEmails;
        
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');

        //Content documents.
        List<ContentVersion> lContents = new List<ContentVersion>();
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
		content.PathOnClient='/' + content.Title + '.jpg'; 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        lContents.add(content);
        
        ContentVersion content2=new ContentVersion(); 
        content2.Title='Header_Picture2'; 
        content2.PathOnClient='/' + content.Title + '.jpg'; 
        content2.VersionData=bodyBlob; 
        content2.origin = 'H';
        lContents.add(content2);        

        insert lContents;

        List<ContentDocument> document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 2];
        List<ContentDocumentLink> lDocumentLinks = new List<ContentDocumentLink>();
        List<Attachment> lAttach = new List<Attachment>();
        
        for(EmailMessage em : lEmails){
            //Content document links.
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=em.id;
            contentlink.contentdocumentid=document[0].id;
            contentlink.Visibility = 'AllUsers'; 
            lDocumentLinks.add(contentlink);
            
            ContentDocumentLink contentlink2=new ContentDocumentLink();
            contentlink2.LinkedEntityId=em.id;
            contentlink2.contentdocumentid=document[1].id;
            contentlink2.Visibility = 'AllUsers'; 
            lDocumentLinks.add(contentlink2);
    
            
    
            //Attachments.
            Attachment attach=new Attachment();       
            attach.Name='Unit Test Attachment';
            attach.body=bodyBlob;
            attach.parentId=em.id;
            lAttach.add(attach);
        }
        
        ContentDocumentLink contentlinkCas=new ContentDocumentLink();
            contentlinkCas.LinkedEntityId=acc.id;
            contentlinkCas.contentdocumentid=document[1].id;
            contentlinkCas.Visibility = 'AllUsers'; 
            lDocumentLinks.add(contentlinkCas);
        
        ContentDocumentLink contentlinkAcc=new ContentDocumentLink();
            contentlinkAcc.LinkedEntityId=cas.id;
            contentlinkAcc.contentdocumentid=document[1].id;
            contentlinkAcc.Visibility = 'AllUsers'; 
            lDocumentLinks.add(contentlinkAcc);
        
        insert lDocumentLinks;
        insert lAttach;

        // Test 
        Test.startTest();
        EmailArchiveBatch batch = new EmailArchiveBatch();
        batch.execute(null, lEmails);
        Test.stopTest();

        //Ids que se van a vincular a los diferentes content document links.
        Set<Id> lDocumentLinkedIds = new Set<Id>();
        //Id del caso y de la cuenta y contacto vinculados a este.
        lDocumentLinkedIds.add(cas.id);
        lDocumentLinkedIds.add(cas.contactId);
        lDocumentLinkedIds.add(cas.AccountId);
        lDocumentLinkedIds.add(acc.id);
        
        
        //Verificamos que se hayan creado los diferentes content document y document links correctamente.
        List<ContentDocumentLink> lContentDocumentLinks = [SELECT Id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :lDocumentLinkedIds];
        System.assertEquals(6, lContentDocumentLinks.size());

        Set<Id> sContentDocumentIds = new Set<Id>();
        for(ContentDocumentLink documentLink : lContentDocumentLinks){
            sContentDocumentIds.add(documentLink.ContentDocumentId);
        }

        List<ContentVersion> lContentDocument= [SELECT Id, ContentDocumentId, OriginEmailId__c FROM ContentVersion WHERE ContentDocumentId IN :sContentDocumentIds];
        System.assertEquals(2, lContentDocument.size());
    }
    
    @isTest
    static void testFinish() {
        // Test finish 
        Test.startTest();
        EmailArchiveBatch batch = new EmailArchiveBatch();
        batch.finish(null);
        Test.stopTest();
    }
}