/*
@author Leadclic Solutions S.L.
@date 17/06/2019 
@description  Clase Test para la clase controladora para la VisualForce GDPRPersonalData

FECHA                   AUTOR                   ACCION
17/06/2019              LCS - RDM               Creación
31/03/2020              LCS - RAL               Modificación. Se añade el número de teléfono a la cuenta
*/
@isTest
public with sharing class TestGDPRPersonalDataController {
    @isTest static void pdfOk()
    {        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            ac.EstadoCuenta__c='Cliente';
            ac.Phone = '600000000';
        insert ac;

        GDPRPersonalDataController datos = new GDPRPersonalDataController();
        
        PageReference TestPage = Page.gdprpersonaldata;
        TestPage.getParameters().put('Id', ac.Id);
        test.setCurrentPage(TestPage);
        
        datos.idAccount = TestPage.getParameters().get('Id');
        
        system.Test.startTest();
            try{
                datos.getDataFromAccount();
            }
        	catch(Exception e){}
        
        system.Test.stopTest();
    }
}