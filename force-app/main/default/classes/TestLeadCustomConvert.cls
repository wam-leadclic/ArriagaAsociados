/*
@author LeadClic Solutions S.L.
@date 12/04/2019
@description Clase Test para la clase LeadCustomConvert

<pre>
FECHA                 AUTOR           ACCION
12/04/2019			LCS - RMG		 Creación.

*/
@isTest
public class TestLeadCustomConvert {

    @testSetup static void crearCustomSettings(){
        //Configuración personalizada  
        ConversionCandidato__c confPerConvCand = new ConversionCandidato__c();
        confPerConvCand.name = 'General';
        confPerConvCand.EtapaOportunidad__c = 'Calificación';
        confPerConvCand.IdListaDePrecio__c = Test.getStandardPricebookId();
        confPerConvCand.RolFuncionContacto__c = 'Economic Buyer';
        insert confPerConvCand;
    }

    @isTest
    static void TestConversionCandidato(){   
        //Lista con los candidatos que se van a convertir
        list<Id> lIdCand = new list<Id>();   
        
        //Candidato para su conversión
        Lead cand = new lead();
        cand.FirstName = 'Candidato';
        cand.LastName = 'Candidato Test';
        cand.PostalCode = '28914';
        cand.Phone = '965852365';
        insert cand;

        //Insertamos al candidato para su conversión
        lIdCand.add(cand.id);
        
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

        //Producto de interés
        LeadProduct__c prodInteres = new LeadProduct__c();
        prodInteres.Candidato__c = cand.id;
        prodInteres.Producto__c = prod.id;
        insert prodInteres;

        system.test.startTest();
            LeadCustomConvert.convertLeads(lIdCand);
        system.test.stopTest();
    }
}