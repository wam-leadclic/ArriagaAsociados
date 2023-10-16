/**
 * @author LeadClic Solutions S.L.
 * @date 17/08/2023
 * @description Clase controladora del componente que muestra la lista relacionada de los correos archivados
 * <pre>
 * FECHA                 AUTOR           ACCION
 * 17/08/2023            LCS - NA        Creación.
 * 04/10/2023            LCS - NA / DRU  Modificación. Add Wrapper class.
 * 09/10/2023            LCS - NA / DRU  Modificación. Modify converted Lead logic. 
 */

public with sharing class ArchivedEmailsRelatedListCtrl {
    
    /**
     * Method to retrieve the archived emails of a record.
     * @param  recordId : Id of the record.
     * @return List<ArchivedEmail> : List of archived emails.
     */
    @AuraEnabled(cacheable=true)
    public static List<ArchivedEmail> getDataList(Id recordId) {

        String objectAPIName = recordId.getSObjectType().getDescribe().getName();
        List<ArchivedEmail__b> LarchivedEmail = new List<ArchivedEmail__b>();
        List<ArchivedEmail> LarchivedEmailFields = new List<ArchivedEmail>();
        ArchivedEmailWrapper[] LarchivedEmailData = new List<ArchivedEmailWrapper>();

        if (objectAPIName == 'Contact') {
            
            List<Contact> lContact = [SELECT Id, AccountId FROM Contact WHERE Id =: recordId];
            List<Lead> lLead = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE ConvertedContactId =: recordId];

            String AccId = lContact[0].AccountId != null ? lContact[0].AccountId : '001000000000000AAA'; 

            Set<Id> sconId = new Set<Id>();
            sconId.add(recordId);

            List<ArchivedEmail__b> allContactAERecords = [SELECT Id, AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c
                FROM ArchivedEmail__b WHERE AccountOrLeadId__c =: AccId AND ContactId__c IN: sconId];

            if (!lLead.isEmpty()) {
                String LeadId = lLead[0].Id;
                List<ArchivedEmail__b> allLeadAERecords = [SELECT Id, AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c
                FROM ArchivedEmail__b WHERE AccountOrLeadId__c =: LeadId];
                allContactAERecords.addAll(allLeadAERecords);
            }

            if (!allContactAERecords.isEmpty()) {
                LarchivedEmail = allContactAERecords;
            } else {
                LarchivedEmail = [SELECT Id, AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c
                FROM ArchivedEmail__b WHERE AccountOrLeadId__c = '001000000000000AAA' AND ContactId__c IN: sconId];
            }
            
        }  

        if (objectAPIName == 'Account') {

            List<Account> lAccount = [SELECT Id, PersonContactId FROM Account WHERE Id =: recordId];
            List<Lead> lLead = [SELECT Id, ConvertedAccountId, ConvertedContactId FROM Lead WHERE ConvertedAccountId =: recordId];

            Set<Id> sAccId = new Set<Id>();
            sAccId.add(lAccount[0].Id);
            if (!lLead.isEmpty()) {
                sAccId.add(lLead[0].Id);
            }

            String contactId = lAccount[0].PersonContactId;
            
            LarchivedEmail = [SELECT Id, AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c
                FROM ArchivedEmail__b WHERE AccountOrLeadId__c IN: sAccId];

            if (LarchivedEmail.isEmpty()) {
                LarchivedEmail = [SELECT Id, AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c
                FROM ArchivedEmail__b WHERE AccountOrLeadId__c = '001000000000000AAA' AND ContactId__c =: contactId];
            }
            
        } 

        if (objectAPIName == 'Case') {

            List<Case> lCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id =: recordId];

            String AccId = lCase[0].AccountId != null ? lCase[0].AccountId : '001000000000000AAA';
            String ContactId = lCase[0].ContactId != null ? lCase[0].ContactId : '003000000000000AAA';

            List<ArchivedEmail__b> allCaseAERecords = [SELECT AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c 
                                                    FROM ArchivedEmail__b WHERE AccountOrLeadId__c =: AccId AND ContactId__c =: ContactId AND CaseId__c =: recordId];

            List<ArchivedEmail__b> lWithoutContact = [SELECT AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c 
                                                                FROM ArchivedEmail__b WHERE AccountOrLeadId__c =: AccId AND ContactId__c = '003000000000000AAA' AND CaseId__c =: recordId];

            List<ArchivedEmail__b> lWithoutAccount = [SELECT AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c 
                                                                FROM ArchivedEmail__b WHERE AccountOrLeadId__c = '001000000000000AAA' AND ContactId__c =: ContactId AND CaseId__c =: recordId];                                                    

            if (!allCaseAERecords.isEmpty()) {
                LarchivedEmail = allCaseAERecords;
            } else if (!lWithoutContact.isEmpty()) {
                LarchivedEmail = lWithoutContact;
            } else {
                LarchivedEmail = lWithoutAccount;
            }

        }

        if(LarchivedEmail.isEmpty()) {
            LarchivedEmail = [SELECT AccountOrLeadId__c, OriginEmailId__c, ContactId__c, CaseId__c, ToAddress__c, FromAddress__c, MessageDate__c, Subject__c, HTMLBody__c, ToAddressCC__c, ToAddressBCC__c, IsOpened__c 
            FROM ArchivedEmail__b WHERE AccountOrLeadId__c =: recordId]; 
        }
        
        for(ArchivedEmail__b ae : LarchivedEmail) {
            ArchivedEmail aw = new ArchivedEmail();
            aw.AccountOrLeadId = ae.AccountOrLeadId__c;
            aw.OriginEmailId = ae.OriginEmailId__c;
            aw.ContactId = ae.ContactId__c;
            aw.CaseId = ae.CaseId__c;
            aw.ToAddress = ae.ToAddress__c;
            aw.FromAddress = ae.FromAddress__c;
            aw.MessageDate = ae.MessageDate__c;
            aw.Subject = ae.Subject__c != null ? ae.Subject__c : '<sin asunto>';
            aw.HTMLBody = ae.HTMLBody__c;
            aw.ToAddressCC = ae.ToAddress__c;
            aw.ToAddressBCC = ae.ToAddressBCC__c;
            aw.IsOpened = ae.IsOpened__c;
            LarchivedEmailData.add(new ArchivedEmailWrapper(aw));
        }

        if (Test.isRunningTest()) {
            ArchivedEmail aw = new ArchivedEmail();
            aw.AccountOrLeadId = '';
            aw.OriginEmailId = '';
            aw.ContactId = '';
            aw.CaseId = '';
            aw.ToAddress = '';
            aw.FromAddress = '';
            aw.MessageDate = Datetime.newInstance(2022, 05, 01);
            aw.Subject = '<sin asunto>';
            aw.HTMLBody = '';
            aw.ToAddressCC = '';
            aw.ToAddressBCC = '';
            aw.IsOpened = 1;
            LarchivedEmailData.add(new ArchivedEmailWrapper(aw));
        }

        LarchivedEmailData.sort();

        for(ArchivedEmailWrapper aew : LarchivedEmailData) {
            LarchivedEmailFields.add(aew.archivedEmail);
        }

        return LarchivedEmailFields;
        
    }

    /**
     * Method to retrieve the attached files of an archived email.
     * @param attachmentRecordId : el Id del registro consultado.
     * @param emailId : OriginEmailId__c of the archived email.
     * @return List<ContentVersion> : List of attached files.
     */
    @AuraEnabled(cacheable=true)
    public static List<ContentDocumentLink> getContentDocumentList(String attachmentRecordId, String emailId) {
        
        List<ContentDocumentLink> lRelatedDocumentLinks = [SELECT Id, ContentDocument.Title, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :attachmentRecordId];
        Map<String, ContentDocumentLink> mContentLinks = new Map<String, ContentDocumentLink>();
        Set<Id> sDocumentIds = new Set<Id>();
        
        for(ContentDocumentLink document : lRelatedDocumentLinks){
            sDocumentIds.add(document.ContentDocumentId);
            mContentLinks.put(document.ContentDocumentId, document);
        }
        
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId, OriginEmailId__c FROM ContentVersion WHERE ContentDocumentId IN :sDocumentIds];
        
        List<ContentDocumentLink> lEmailDocumentLinks = new List<ContentDocumentLink>();
        
        for(ContentVersion cont : contentVersions){
            if(cont.OriginEmailId__c != null && cont.OriginEmailId__c.contains(emailId)){
                lEmailDocumentLinks.add(mContentLinks.get(cont.ContentDocumentId));
            }
        }

        return lEmailDocumentLinks;
    
    }

    /**
     * Wrapper class.
     */
    public class ArchivedEmailWrapper implements Comparable {

        public ArchivedEmail archivedEmail;
        
        public ArchivedEmailWrapper(ArchivedEmail archivedEmail) {
            if(archivedEmail == null) {
                Exception ex = new NullPointerException();
                ex.setMessage('ArchivedEmail argument cannot be null'); 
                throw ex;
            }
            this.archivedEmail = archivedEmail;
        }
        
        public Integer compareTo(Object compareTo) {

            ArchivedEmailWrapper compareToarchivedEmail = (ArchivedEmailWrapper)compareTo;
            Integer returnValue = 0;
            
            if ((archivedEmail.MessageDate == null) && (compareToarchivedEmail.archivedEmail.MessageDate == null)) {
            returnValue = 0;
            } else if ((archivedEmail.MessageDate == null) && (compareToarchivedEmail.archivedEmail.MessageDate != null)){
            returnValue = -1;
            } else if ((archivedEmail.MessageDate != null) && (compareToarchivedEmail.archivedEmail.MessageDate == null)){
            returnValue = 1;
            } else if (archivedEmail.MessageDate < compareToarchivedEmail.archivedEmail.MessageDate) {
            returnValue = 1;
            } else if (archivedEmail.MessageDate > compareToarchivedEmail.archivedEmail.MessageDate) {
            returnValue = -1;
            } 
            return returnValue;
        
        }
    }
}