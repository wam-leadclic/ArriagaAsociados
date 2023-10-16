/*
@author LeadClic Solutions S.L.
@date 22/05/2019
@description Test del trigger para el objeto linea de oportunidad

<pre>
FECHA             AUTOR           ACCION
22/05/2019		LCS - RDM	   	  Creación. 
*/
@isTest
public with sharing class TestTriggerOpportunityLineItem {    
    @isTest static void viajeDocumentacion(){
		
        PriceBook2 pb = New PriceBook2(Id = test.getStandardPricebookId(), isActive = true);
		update pb;
        
        Product2 prod = new Product2();
        	prod.IsActive = true;
        	prod.Name = 'TestPrd';
        	prod.DocumentosCompletado__c =  '126;127';
            prod.DocumentosContratacion__c = '126;127';
        insert prod;
        
        //Pricebook2 price = [select id, name from Pricebook2 where isStandard = true limit 1];
        Id price = Test.getStandardPricebookId();
        
     /*
        PricebookEntry priceEnt = new PricebookEntry();
        	priceEnt.Pricebook2Id = price;
        	priceEnt.Product2Id = prod.Id;
        	priceEnt.UnitPrice = 150;
        	priceEnt.IsActive = true;
        insert priceEnt;
*/
        
        Opportunity o = new Opportunity();
        	o.Pricebook2Id = price;
        	o.Name = 'Test';
        	o.StageName = system.label.OportunidadCalificacion;
            o.CloseDate = Date.today();
        insert o;
        
        OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = o.Id;
            oli.Product2Id = prod.Id;
            oli.Quantity = 1;
            oli.UnitPrice = 100;
        
        system.Test.startTest();
        	insert oli;
        system.Test.stopTest();
    }
}