/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Clase Test para trigger de Candidato

<pre>
FECHA                 AUTOR           ACCION
30/04/2019			LCS - RDM		 Creación.
20/04/2019			LCS - RMG		 Modificación. Se añade la parte de candidatos procedentes de formulario web 
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura
*/
@isTest
public class TestTriggerLead {

    @isTest static void InsertSinDNI(){
        try{
            Lead l = new Lead(
                FirstName = 'test',
                LastName = 'test2',
                Phone = '652589652',
                Email = 'test@gmail.com'
            );
            
            system.Test.startTest();
            	insert l;
            
            	l.TipoDocumento__c = 'NIE';
            	l.DocumentoIdentidad__c = 'NIE';
            	update l;
            System.Test.stopTest();
            
        }
        Catch(Exception e){}
    }

    @isTest static void InsertConDNI(){
        try{
            Lead l = new Lead(
                FirstName = 'test',
                LastName = 'test2',
                Phone = '652589652',
                Email = 'test@gmail.com',
                TipoDocumento__c = 'NIE',
                DocumentoIdentidad__c = '45256859F'
            );
            
            system.Test.startTest();
            	insert l;
            System.Test.stopTest();
            
        }
        Catch(Exception e){}
    }

    @isTest static void CambiarTipoDNI(){
        try{
            Lead l = new Lead(
                FirstName = 'test',
                LastName = 'test2',
                Phone = '652589652',
                Email = 'test@gmail.com',
                DocumentoIdentidad__c = '45256859F'
            );
            insert l;
            
            system.Test.startTest();            
            	l.TipoDocumento__c = 'NIE';
            
            	update l;
            System.Test.stopTest();
            
        }
        Catch(Exception e){}
    }
    
    static testMethod void formularioWeb(){
        Lead cand =  new Lead ();
        cand.LastName = 'Test';
        cand.FirstName = 'Test';
        cand.Email = 'test1524@test.com';
        cand.LeadSource = system.label.CandidatoOrigenWeb;
        
        Lead cand2 =  new Lead ();
        cand2.FirstName = 'Test2';
        cand2.LastName = 'Test2';
        cand2.Email = 'test114@test.com';
        cand2.LeadSource = system.label.CandidatoOrigenWeb;
        
        system.Test.startTest();
        	insert cand;
        	insert cand2;
        system.Test.stopTest();
    }
    
    static testMethod void formularioWebContactoExistente(){        
        Contact cont = new Contact ();
        cont.FirstName = 'Tesst';
        cont.LastName = 'Test';
        cont.Email = 'test@test.com';
        insert cont;
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        
        Product2 prod = new Product2();
        prod.Name = 'test Prod'; 
        prod.IsActive = true;
        insert prod;
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Lead cand =  new Lead ();
        cand.FirstName = 'Test';
        cand.LastName = 'Test';
        cand.Email = 'test@test.com';
        cand.LeadSource = system.label.CandidatoOrigenWeb;
        cand.ProductoFormularioWeb__c = prod.id;
        
        system.Test.startTest();
        	insert cand;
        system.Test.stopTest();
    }
    
        static testMethod void formularioWebCandidatoExistente(){        
        Lead cand =  new Lead ();
        cand.FirstName = 'Test';
        cand.LastName = 'Test';
        cand.Email = 'test@test.com';
        cand.PostalCode = '11111';
        insert cand;
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        
        Product2 prod = new Product2();
        prod.Name = 'test Prod'; 
        prod.IsActive = true;
        insert prod;
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Lead cand2 =  new Lead ();
        cand2.FirstName = 'Test';
        cand2.LastName = 'Test';
        cand2.Email = 'test@test.com';
        cand2.LeadSource = system.label.CandidatoOrigenWeb;
        cand2.ProductoFormularioWeb__c = prod.id;
        
        system.Test.startTest();
        try{
        	insert cand2;
        }catch(DmlException e){
        	System.assert(e.getMessage().contains('DUPLICATES_DETECTED'));        
        }
        system.Test.stopTest();
    }
}