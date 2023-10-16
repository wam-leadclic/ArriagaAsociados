/*
@author LeadClic Solutions S.L.
@date 03/04/2019
@description Clase Test para la clase Flow_CrearSegundoTitular

<pre>
FECHA                 AUTOR           ACCION
03/04/2019			LCS - RMG		 Creación.
22/04/2019			LCS - RDM		 Modificación. Se añade la creación de la opp para poder pasar por las lineas de la creación del rol de la oportunidad para la nueva cuenta creada.
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura
31/03/2020			LCS - RAL		 Modificación. Se añade el teléfono en la creación de cuenta

*/
@isTest
public class TestFlow_CrearSegundoTitular {
    
    @testSetup static void crearCustomSettings(){
        DatosFlujo__c flujo = new DatosFlujo__c();
            flujo.IDTipoRegistroCuentaPersonal__c = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            flujo.EstadoCuenta__c = 'Cliente Potencial';
            flujo.IdPropietarioSegundoTitular__c = system.UserInfo.getUserId();
            flujo.EtapaOEtapaOportuniportunidadContrOnline__c = 'Prospecting';
        insert flujo;  
    }

    @isTest
    static void TestCrearSegundoTitular(){         
        
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.IdClienteMinerva__c = '0000001';
        	ac.Phone = '60000000';
        insert ac;
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        

        Flow_CrearSegundoTitular.GetParameters request = new Flow_CrearSegundoTitular.GetParameters();
        List<Flow_CrearSegundoTitular.GetParameters> listRequest = new List<Flow_CrearSegundoTitular.GetParameters>();
                
        request.dni = '83676973Y';
        request.nombre = 'Test';
        request.email = 'test@test.com';
        request.telefono = '666666666';
        request.IdOportunidad = opp.id;
        listRequest.add(request);
        
        system.Test.startTest();
        	Flow_CrearSegundoTitular.MetodoInvocable(listRequest);
        system.Test.stopTest();
    }

    @isTest
    static void TestExisteSegundoTitular(){         
        
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Account ac = new Account();
        	ac.FirstName = 'Test';
        	ac.LastName = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.IdClienteMinerva__c = '0000123';
        	ac.Phone = '60000000';
        insert ac;
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        

        Flow_CrearSegundoTitular.GetParameters request = new Flow_CrearSegundoTitular.GetParameters();
        List<Flow_CrearSegundoTitular.GetParameters> listRequest = new List<Flow_CrearSegundoTitular.GetParameters>();
                
        request.dni = '83676973Y';
        request.nombre = 'Test';
        request.email = 'test@test.com';
        request.telefono = '666666666';
        request.IdOportunidad = opp.id;
        request.IdCuentaSegundoTitular = ac.id;
        listRequest.add(request);
        
        system.Test.startTest();
        	Flow_CrearSegundoTitular.MetodoInvocable(listRequest);
        system.Test.stopTest();
    }
}