/**
 * @author LeadClic Solutions S.L.
 * @date 17/08/2023
 * @description Clase Test de la controladora del componente que muestra la lista relacionada de los correos archivados
 * <pre>
 * FECHA                 AUTOR           ACCION
 * 28/08/2023            LCS - NA        Creación.
 * 19/09/2023            LCS - NA        Modificación. Se han comentado los inserts del big object y los asserts por problemas en insertar los big objects en las clases test.
 * 04/10/2023            LCS - NA        Modificación. Add Wrapper class test method.
 */

@isTest
private class ArchivedEmailsRelatedListCtrlTest {
    
    @isTest
    static void testGetDataList_Contact() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account', Phone = '600000000');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;
        
        //ArchivedEmail__b testEmail = new ArchivedEmail__b(AccountOrLeadId__c = testAccount.Id, ContactId__c = testContact.Id);
        //insert testEmail;
        
        // Test method invocation
        Test.startTest();
        ArchivedEmailsRelatedListCtrl.getDataList(testContact.Id);
        Test.stopTest();
        
        // Assertion
        //System.assertEquals(1, result.size());
        //System.assertEquals(testEmail.Id, result[0].Id);
    }
    
    @isTest
    static void testGetDataList_Account() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account', Phone = '600000000');
        insert testAccount;
        
        //ArchivedEmail__b testEmail = new ArchivedEmail__b(AccountOrLeadId__c = testAccount.Id);
        //insert testEmail;
        
        // Test method invocation
        Test.startTest();
        ArchivedEmailsRelatedListCtrl.getDataList(testAccount.Id);
        Test.stopTest();
        
        // Assertion
        //System.assertEquals(1, result.size());
        //System.assertEquals(testEmail.Id, result[0].Id);
    }
    
    @isTest
    static void testGetDataList_Case() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account', Phone = '600000000');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;
        
        Case testCase = new Case(AccountId = testAccount.Id, ContactId = testContact.Id);
        insert testCase;
        
        //ArchivedEmail__b testEmail = new ArchivedEmail__b(AccountOrLeadId__c = testAccount.Id, ContactId__c = testContact.Id, CaseId__c = testCase.Id);
        //insert testEmail;
        
        // Test method invocation
        Test.startTest();
        ArchivedEmailsRelatedListCtrl.getDataList(testCase.Id);
        Test.stopTest();
        
        // Assertion
        //System.assertEquals(1, result.size());
        //System.assertEquals(testEmail.Id, result[0].Id);
    }

    @isTest
    static void testGetDataList_OtherObject() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account', Phone = '600000000');
        insert testAccount;
        
        //ArchivedEmail__b testEmail = new ArchivedEmail__b(AccountOrLeadId__c = testAccount.Id);
        //database.insertImmediate(testEmail);
        
        // Test method invocation
        Test.startTest();
        ArchivedEmailsRelatedListCtrl.getDataList(testAccount.Id);
        Test.stopTest();
        
        // Assertion
        //System.assertEquals(1, result.size());
        //System.assertEquals(testEmail.Id, result[0].Id);
    }

    @isTest
    static void getContentDocumentListTest(){
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Test';
        insert con;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Document Test';
        cv.OriginEmailId__c = '123';
        cv.PathOnClient ='test';
        Blob b=Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        Id conDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;

        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocumentId;
        cDocLink.LinkedEntityId = con.Id;
        cDocLink.ShareType = 'I';
        cDocLink.Visibility = 'InternalUsers';
        Insert cDocLink;

        Test.startTest();
        List<ContentDocumentLink> dataList = ArchivedEmailsRelatedListCtrl.getContentDocumentList(cDocLink.LinkedEntityId, cv.OriginEmailId__c); 
        Test.stopTest();

        System.assertEquals('Document Test', dataList[0].ContentDocument.Title, 'Records are not retrieved correctly'); 
        
    }

    @isTest 
    static void archivedEmailWrapperTest(){

        ArchivedEmail ae = new ArchivedEmail();
        ae.MessageDate = Datetime.newInstance(2023, 05, 01);

        ArchivedEmail ae2 = new ArchivedEmail();
        ae2.MessageDate = Datetime.newInstance(2022, 05, 01);

        ArchivedEmail ae3 = new ArchivedEmail();
        ae3.MessageDate = Datetime.newInstance(2023, 09, 09);
        
        ArchivedEmail ae4 = new ArchivedEmail();
        ae4.MessageDate = null;

        ArchivedEmail ae5 = new ArchivedEmail();
        ae4.MessageDate = null;
        
        Test.startTest();
        ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper wrapper = new ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper(ae);
        ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper wrapper2 = new ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper(ae2);
        ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper wrapper3 = new ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper(ae3);
        ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper wrapper4 = new ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper(ae4);
        ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper wrapper5 = new ArchivedEmailsRelatedListCtrl.ArchivedEmailWrapper(ae5);
            
        wrapper.archivedEmail = ae;
        wrapper2.archivedEmail = ae2;
        wrapper3.archivedEmail = ae3;
        wrapper4.archivedEmail = ae4;
        wrapper5.archivedEmail = ae5;
        wrapper.compareTo(wrapper);
        wrapper.compareTo(wrapper2);
        wrapper.compareTo(wrapper3);
        wrapper.compareTo(wrapper4);
        wrapper4.compareTo(wrapper5);
        wrapper5.compareTo(wrapper);
        Test.stopTest();
    }

}