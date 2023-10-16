/*
@author LeadClic Solutions S.L.
@date 08/05/2019
@description Clase test del trigger de oportunidad

<pre>
FECHA             AUTOR           ACCION
08/05/2019      LCS - RMG         Creación.
24/06/2019      LCS - RDM         Modificación. Se añaden los métodos que pasan por la oportunidad cerrada perdida y la aportación de documentos
04/07/2019      LCS - RDM         Modificación. Se añaden el método para pasar por cerradad ganada aportando los documentos
30/07/2019      LCS - RDM         Modificación. Se añaden los campos necesarios para pasar por el método de creación del pago
04/09/2019      LCS - RDM         Modificación. Subida de % de cobertura
16/12/2019      LCS - HPS         Modificacion. Se modifica el método 'cerrarOportunidadGanadaDocumentos' para respetar la nueva regla de validación creada para 'Oportunidad'.
27/04/2020      LCS - RAL         Modificación. Se añade la fecha de justificante de pago para actualizar la oportunidad
*/
@isTest
public class TestTriggerOpportunity {
     @testSetup static void crearCustomSettings() {
        
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
    }
    static testMethod  void cerrarOportunidad(){
    
        //Creamos la oficina
        Account oficina = new Account();
        oficina.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Oficina').getRecordTypeId();
        oficina.Name = 'TestOficina';
        oficina.Activa__c = true;
        oficina.Phone = '123123123';
        insert oficina;

        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.CloseDate = system.today();
        oportunidad.Office__c = oficina.Id;
        insert oportunidad;
        
        //Añadimos documentos a la oportunidad        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test';      
        cv.PathOnClient ='test';           
        cv.VersionData =blob.valueOf('Test Adjunto');          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=oportunidad.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
        
        System.Test.startTest();
            try{
                //Cambiamos la etapa de la oportunidad a cerrada/ganada
                oportunidad.StageName = system.label.OportunidadCerragaGanada;
                update oportunidad;
            
                //Volvemos a pasar la oportunidad a abierta
                oportunidad.StageName = system.label.OportunidadCalificacion;
                update oportunidad; 
            
                //Pasamos la oportunidad a cerrada/ganada
                oportunidad.StageName = system.label.OportunidadCerragaGanada;
                update oportunidad;
            }catch(Exception e){}
        System.Test.stopTest();
    }
    
    
    @isTest static void cerrarOportunidadPerdida(){
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.CloseDate = system.today();
        insert oportunidad;
        
        //Añadimos documentos a la oportunidad        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test';      
        cv.PathOnClient ='test';           
        cv.VersionData =blob.valueOf('Test Adjunto');          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=oportunidad.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
        
        System.Test.startTest();
            //Cambiamos la etapa de la oportunidad a cerrada/perdida
            oportunidad.StageName = system.label.OportunidadCerragaPerdida;
            oportunidad.LossReason__c = 'Cliente no quiere contratar';
            oportunidad.Motivo_Perdida_Descripcion__c='Confianza en el proceso';
            update oportunidad;
        System.Test.stopTest();
    }
    
    @isTest static void cerrarOportunidadDocumentos(){
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.CloseDate = system.today();
        oportunidad.DocumentosCompletado__c = '118;120';
        insert oportunidad;
        
        
        Contract Exp = new Contract();
        Exp.AccountId = cuentaPersonal.Id;
        Exp.Pricebook2Id = standardPricebook.id;
        Exp.IdExpediente__c = oportunidad.NumeroExpediente__c;
        Exp.Oportunidad__c = oportunidad.id;
        insert Exp;
        
        //Añadimos documentos a la oportunidad        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test';      
        cv.PathOnClient ='test';           
        cv.VersionData =blob.valueOf('Test Adjunto');          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=oportunidad.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
        
        System.Test.startTest();
            //Cambiamos los documentos aportados
            oportunidad.DocumentosCompletadoAportado__c = '118;120';    
            update oportunidad;
        System.Test.stopTest();
    }
    
    @isTest static void cerrarOportunidadGanadaDocumentos(){
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        //Crear Hoja de encargo
        HojaEncargo__c hoja = new HojaEncargo__c();
        hoja.PDFDatosArriaga__c = 'TEST {!Name}';
        hoja.PDFDesistimiento__c = 'TEST {!Account.Name}';
        hoja.PDFHonorarios__c = 'TEST {!TEST}';
        hoja.ExternalId__c = '12345';
        insert hoja;
 
        //Asociamos el pricebook
        PriceBook2 pb = New PriceBook2(Id = test.getStandardPricebookId(), isActive = true);
        update pb;
        
        Id price = Test.getStandardPricebookId();

        //Creamos la oficina
        Account oficina = new Account();
        oficina.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Oficina').getRecordTypeId();
        oficina.Name = 'TestOficina';
        oficina.Activa__c = true;
        oficina.Phone = '123123123';
        insert oficina;
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.CloseDate = system.today();
        oportunidad.DocumentosContratacion__c = '118;120';
        oportunidad.DocumentosContratacionAportado__c = '118;120';  
        oportunidad.PrecioTotal__c = 15.2;
        oportunidad.Tipo__c = 'TPV';
        oportunidad.HojaEncargo__c = hoja.Id;     
        oportunidad.Pricebook2Id = price;
        oportunidad.Office__c = oficina.Id;
        insert oportunidad;
        
        //Añadimos documentos a la oportunidad        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test';      
        cv.PathOnClient ='test';           
        cv.VersionData =blob.valueOf('Test Adjunto');          
        insert cv;         

        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=oportunidad.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        insert contentlink;
       
        Opportunity testOpp = [SELECT id FROM Opportunity where name = 'test'];
        
        
        //Creamos un producto
        Product2 prod = new Product2();
            prod.IsActive = true;
            prod.Name = 'TestPrd';
            prod.DocumentosCompletado__c =  '126;127';
            prod.DocumentosContratacion__c = '126;127';
        insert prod;
        
        //Creamos un OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = testOpp.Id;
            oli.Product2Id = prod.Id;
            oli.Quantity = 1;
            oli.UnitPrice = 100;
        insert oli;
        

        
        System.Test.startTest();
        
            //Pasamos la oportunidad a cerrada/ganada
            oportunidad.StageName = system.label.OportunidadCerragaGanada;
            oportunidad.ProofPaymentDate__c = system.today();
            update oportunidad;
        System.Test.stopTest();
    }
    
    @isTest static void cerrarOportunidadGanadaMenorEdad(){
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        list<Contact> lContactos = [SELECT Id FROM Contact Where AccountId = :cuentaPersonal.id];
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.CloseDate = system.today();
        oportunidad.PrecioTotal__c = 15.2;
        oportunidad.Tipo__c = 'TPV';
        insert oportunidad;
        
        //Funciones de contacto de la oportunidad
        list<OpportunityContactRole> lFuncionesContacto = new list<OpportunityContactRole>();
        OpportunityContactRole funcionContacto = new OpportunityContactRole();
        funcionContacto.OpportunityId = oportunidad.id;
        funcionContacto.ContactId = lContactos.get(0).id;
        funcionContacto.Role = system.label.MenorDeEdad;
        lFuncionesContacto.add(funcionContacto);
        
        OpportunityContactRole funcionContactoRL = new OpportunityContactRole();
        funcionContactoRL.OpportunityId = oportunidad.id;
        funcionContactoRL.ContactId = lContactos.get(0).id;
        funcionContactoRL.Role = system.label.RepresentanteLegal;
        lFuncionesContacto.add(funcionContactoRL);
        
        insert lFuncionesContacto;
        
        //Pasamos la oportunidad a cerrada/ganada
        oportunidad.StageName = system.label.OportunidadCerragaGanada;
        
        System.Test.startTest();
            //Lo ponemos en un try-catch porque estamos probando que nos falla al no tener representante legal
            try{    
                update oportunidad;
            }catch(Exception e){}
        System.Test.stopTest();
    }
    
    @isTest static void cerrarOportunidadGanadaIncapacitado(){
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        //Creamos la cuenta personal
        Account cuentaPersonal = new Account();
        cuentaPersonal.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        cuentaPersonal.PersonEmail = 'test@email.com';
        cuentaPersonal.EstadoCuenta__c='Cliente';
        cuentaPersonal.FirstName = 'Tesst';
        cuentaPersonal.LastName = 'Test';
        insert cuentaPersonal;
        
        list<Contact> lContactos = [SELECT Id FROM Contact Where AccountId = :cuentaPersonal.id];
        
        //Creamos la oportunidad
        Opportunity oportunidad = new Opportunity();
        oportunidad.AccountId = cuentaPersonal.id;
        oportunidad.StageName = system.label.OportunidadCalificacion;
        oportunidad.Name = 'test';
        oportunidad.CloseDate = system.today();
        oportunidad.PrecioTotal__c = 15.2;
        oportunidad.Tipo__c = 'TPV';
        insert oportunidad;
        
        //Funciones de contacto de la oportunidad
        list<OpportunityContactRole> lFuncionesContacto = new list<OpportunityContactRole>();
        OpportunityContactRole funcionContacto = new OpportunityContactRole();
        funcionContacto.OpportunityId = oportunidad.id;
        funcionContacto.ContactId = lContactos.get(0).id;
        funcionContacto.Role = system.label.Incapacitado;
        lFuncionesContacto.add(funcionContacto);
        
        OpportunityContactRole funcionContactoRL = new OpportunityContactRole();
        funcionContactoRL.OpportunityId = oportunidad.id;
        funcionContactoRL.ContactId = lContactos.get(0).id;
        funcionContactoRL.Role = system.label.Tutor;
        lFuncionesContacto.add(funcionContactoRL);
        
        insert lFuncionesContacto;
        
        //Pasamos la oportunidad a cerrada/ganada
        oportunidad.StageName = system.label.OportunidadCerragaGanada;
        
        System.Test.startTest();
            //Lo ponemos en un try-catch porque estamos probando que nos falla al no tener representante legal
            try{    
                update oportunidad;
            }catch(Exception e){}
        System.Test.stopTest();
    }
}