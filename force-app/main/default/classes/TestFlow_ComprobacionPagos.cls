/*
@author LeadClic Solutions S.L.
@date 14/03/2019
@description Clase Test para la clase Aque comprueba si se debe realizar un pago

<pre>
FECHA                 AUTOR           ACCION
15/03/2019			LCS - RDM		 Creación.
31/03/2020			LCS - RAL		 Modificación. Se añade el teléfono en la creación de cuenta

*/
@isTest
public class TestFlow_ComprobacionPagos {
    
    @testSetup static void crearCustomSettings(){
        
    }

    @isTest static void TestContratacionOnline(){ 
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c = 'Cliente';
        	ac.Phone = '60000000';
        insert ac;
        
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
        
        
        ProductosContrt__c lConfigProd = new ProductosContrt__c();
            lConfigProd.Name = prod.Name;
            lConfigProd.Activo__c = true;
            lConfigProd.IdProduct__c = prod.id;
            lConfigProd.NameProduct__c = prod.Name;
            lConfigProd.URLArriaga__c = 'www.test.com';
            lConfigProd.URLContratacion__c = '';
        insert lConfigProd;

        Flow_ComprobacionPagos.GetParameters request = new Flow_ComprobacionPagos.GetParameters();
        List<Flow_ComprobacionPagos.GetParameters> listRequest = new List<Flow_ComprobacionPagos.GetParameters>();
                                
        request.productoGratis = true;
        request.IdCuenta = ac.id;
        request.IdProducto = prod.id;
        listRequest.add(request);
        
        system.Test.startTest();
        	Flow_ComprobacionPagos.MetodoInvocable(listRequest);
        system.Test.stopTest();
    }
    
    @isTest static void TestContratacionOnlineExistente(){        
        
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c = 'Cliente';
        	ac.Phone = '60000000';
        insert ac;
        
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
        
        Product2 prod2 = new Product2();
            prod2.Name = 'test Prod2'; 
            prod2.IsActive = true;
        insert prod2;
        
        PriceBookEntry pb = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;    
            opp.Name = 'Test';
            opp.StageName = 'Prospecting';
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        CommunityOpp__c ContratOnline = new CommunityOpp__c();
            ContratOnline.Cuenta__c = ac.id;
            ContratOnline.Oportunidad__c = opp.Id;  
            ContratOnline.IdOportunidad__c = opp.Id; 
        	ContratOnline.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline.IDProducto__c = prod.id;
        	ContratOnline.ContrFinalizado__c = true;
        insert ContratOnline;
        
        CommunityOpp__c ContratOnline2 = new CommunityOpp__c();
            ContratOnline2.Cuenta__c = ac.id;
            ContratOnline2.Oportunidad__c = opp.Id;  
            ContratOnline2.IdOportunidad__c = opp.Id; 
        	ContratOnline2.CantidadPagar__C = pb.UnitPrice;
        	ContratOnline2.IDProducto__c = prod2.id;
        	ContratOnline2.ContrFinalizado__c = true;
        	ContratOnline2.Gratis__c = true;
        insert ContratOnline2;
        
        list<ProductosContrt__c> lConfigProd = new list<ProductosContrt__c>();
            ProductosContrt__c ConfigProd = new ProductosContrt__c();
                ConfigProd.Name = prod.Name;
                ConfigProd.Activo__c = true;
                ConfigProd.IdProduct__c = prod.id;
                ConfigProd.NameProduct__c = prod.Name;
                ConfigProd.URLArriaga__c = 'www.test.com';
                ConfigProd.URLContratacion__c = '';
            lConfigProd.add(ConfigProd);
            ProductosContrt__c ConfigProd2 = new ProductosContrt__c();
                ConfigProd2.Name = prod2.Name;
                ConfigProd2.Activo__c = true;
                ConfigProd2.IdProduct__c = prod2.id;
                ConfigProd2.NameProduct__c = prod2.Name;
                ConfigProd2.URLArriaga__c = 'www.test.com';
                ConfigProd2.URLContratacion__c = '';
            lConfigProd.add(ConfigProd2);
        insert lConfigProd;

        Flow_ComprobacionPagos.GetParameters request = new Flow_ComprobacionPagos.GetParameters();
        List<Flow_ComprobacionPagos.GetParameters> listRequest = new List<Flow_ComprobacionPagos.GetParameters>();
               
        request.productoGratis = true; 
        request.IdCuenta = ac.id;
        request.IdProducto = prod.id;
        listRequest.add(request);
        
        system.Test.startTest();
        	Flow_ComprobacionPagos.MetodoInvocable(listRequest);
        system.Test.stopTest();
    }

}