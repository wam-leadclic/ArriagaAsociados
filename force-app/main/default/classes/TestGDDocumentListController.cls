/*
@author LeadClic Solutions S.L.
@date 
@description Clase Test para la clase que contiene el código controlador del LWC gdDocumentitems
<pre>
FECHA             AUTOR           ACCION
04/07/2019      LCS - RDM         Creación.
 
*/
@isTest
public class TestGDDocumentListController {
    
    @testSetup static void crearCustomSettings() {
    }
    
    @isTest static void testGetTipoDocumento(){
        List<TipoDocumento__c> lTipos = new List<TipoDocumento__c>();
        	TipoDocumento__c tipo1 = new TipoDocumento__c();
        		tipo1.TipoDocumento__c = '126';
        lTipos.add(tipo1);
        	TipoDocumento__c tipo2 = new TipoDocumento__c();
        		tipo2.TipoDocumento__c = '127';
        lTipos.add(tipo2);
        insert lTipos;
        
        list<CampoDocumento__c> lCamposDoc = new list<CampoDocumento__c>();
        	CampoDocumento__c campo1 = new CampoDocumento__c();
        		campo1.TipoDocumento__c = lTipos[0].Id;
        		campo1.TipoCampo__c = 'number';
        lCamposDoc.add(campo1);
        	CampoDocumento__c campo2 = new CampoDocumento__c();
        		campo2.TipoDocumento__c = lTipos[0].Id;
        		campo2.TipoCampo__c = 'Date';
        lCamposDoc.add(campo2);
        	CampoDocumento__c campo3 = new CampoDocumento__c();
        		campo3.TipoDocumento__c = lTipos[1].Id;
        		campo3.TipoCampo__c = 'Date';
        lCamposDoc.add(campo3);
        insert lCamposDoc;
        
        system.Test.startTest();
        	GDDocumentListController.getFieldDoc('126');
        	GDDocumentListController.getFieldDoc('216');
        	GDDocumentListController.getFieldDoc(null);
        system.Test.stopTest();
        
    }

}