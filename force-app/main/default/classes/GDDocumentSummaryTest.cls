/*
@author LeadClic Solutions S.L.
@date 13/10/2023
@description Clase test para cobertura y pruebas unitarias de GDDocumentSummary 
<pre>
FECHA             AUTOR           ACCION
13/10/2023		LCS - SDF	   	  Creación.
*/
@isTest
private class GDDocumentSummaryTest {

    static Contract expedient;
    static Product2 prod;

    static {
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;

        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.IdClienteMinerva__c = '12345';
            ac.Phone = '654987321';
        insert ac;
        
        Contact c = new Contact();
        	c.FirstName = 'Test';
        	c.LastName = 'TestII';
        insert c;
        
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        
        prod = new Product2();
            prod.Name = 'test Prod'; 
            prod.IsActive = true;
        insert prod;
        
        PriceBookEntry pb = [SELECT Id FROM PriceBookEntry WHERE Product2Id =: prod.id];
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = 'Prospecting';      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        OpportunityContactRole opprole = new OpportunityContactRole();
            opprole.ContactId = c.Id;
            opprole.Role = 'Titular';
            opprole.IsPrimary = true;
            opprole.OpportunityId = opp.id;
        insert opprole;
        
        //declaramos un expediente base
        expedient = new Contract();
        expedient.AccountId = ac.Id;
        expedient.Pricebook2Id = standardPricebook.id;
        expedient.IdExpediente__c = opp.NumeroExpediente__c;
        expedient.Oportunidad__c = opp.id;
        expedient.IdExpediente__c = '11111';    
    }
    
    @isTest
    private static void shouldShowAllRedactionLines() {
        expedient.DocumentosRedaccion__c = '178;195;24;50';
        expedient.DocumentosRedaccionAportados__c = '24;50';
        insert expedient;
        GDDocumentSummary gdSummary;

        Test.startTest();
        gdSummary = new GDDocumentSummary(expedient.Id);
        Test.stopTest();

        Assert.istrue(
            gdSummary.redactionLines.containsAll(new Set<String>(expedient.DocumentosRedaccion__c.split(Utils.SEMICOLON))), 
            'Should be populated with DocumentosRedaccion__c field'
        );
        Assert.istrue(
            gdSummary.uploadedRedactionLines.containsAll(new Set<String>(expedient.DocumentosRedaccionAportados__c.split(Utils.SEMICOLON))),
            'Should be populated with DocumentosRedaccionAportados__c field'
        );
    } 

    @isTest
    private static void shouldShowAllAditionalLines() {
        expedient.DocumentosAdicionales__c = '167;32;55;180';
        expedient.DocumentosAdicionalesAportados__c = '32;167';
        insert expedient;
        GDDocumentSummary gdSummary;

        Test.startTest();
        gdSummary = new GDDocumentSummary(expedient.Id);
        Test.stopTest();

        Assert.istrue(
            gdSummary.aditionalLines.containsAll(new Set<String>(expedient.DocumentosAdicionales__c.split(Utils.SEMICOLON))), 
            'Should be populated with DocumentosAdicionales__c field'
        );
        Assert.istrue(
            gdSummary.uploadedAditionalLines.containsAll(new Set<String>(expedient.DocumentosAdicionalesAportados__c.split(Utils.SEMICOLON))),
            'Should be populated with DocumentosAdicionalesAportados__c field'
        );
    }

    @isTest
    private static void whenDocumentLineIsUploadedItShouldBeVisibleAndUploaded() {
        final String documentLineValue = '167';
        Ayuda_portal__c help = new Ayuda_portal__c(
            Producto__c = prod.Id,
            Documento__c = documentLineValue,
            Descripcion__c = 'test description'
        );
        insert help;

        expedient.DocumentosRedaccion__c = documentLineValue;
        expedient.DocumentosRedaccionAportados__c = documentLineValue;
        expedient.Producto__c = prod.Id;
        insert expedient;
        GDDocumentSummary gdSummary;
        GDDocumentSummary.GDDocumentLine line;
        
        Test.startTest();
        gdSummary = new GDDocumentSummary(expedient.Id);
        Test.stopTest();

        Assert.isNotNull(gdSummary.documentLines, 'Should not be null');
        Assert.areEqual(1,gdSummary.documentLines.size(), 'Should contain one value');

        line = gdSummary.documentLines.remove(0);
        
        Assert.areEqual(documentLineValue, line.value, 'must match value with documentLineValue');
        Assert.areEqual(false, line.visible, 'should\'nt be visible because it was already uploaded');
        Assert.areEqual(GDDocumentSummary.UPLOADED, line.status, 'status does not match with UPLOADED value');
        Assert.areEqual(help.Descripcion__c, line.helpText, 'shoulb be populated with Ayuda_Portal__c.Descripcion__c value');
        Assert.areEqual(Contract.DocumentosRedaccion__c.getDescribe().getName(), line.relatedField, 'value should be Contract.DocumentosRedaccion__c');
        Assert.areEqual(gdSummary.documentLabels.get(line.value), line.title, 'shoulb be populated with Ayuda_Portal__c.Descripcion__c value');
    }

    @isTest
    private static void whenDocumentLineIsMptUploadedItShouldNotBeVisibleAndPending() {
        final String documentLineValue = '167';

        expedient.DocumentosRedaccion__c = documentLineValue;
        insert expedient;
        GDDocumentSummary gdSummary;
        GDDocumentSummary.GDDocumentLine line;
        
        Test.startTest();
        gdSummary = new GDDocumentSummary(expedient.Id);
        Test.stopTest();

        Assert.isNotNull(gdSummary.documentLines, 'Should not be null');
        Assert.areEqual(1,gdSummary.documentLines.size(), 'Should contain one value');

        line = gdSummary.documentLines.remove(0);
        Assert.areEqual(true, line.visible, 'should be visible because it is not uploaded yet');
        Assert.areEqual(documentLineValue, line.value, 'must match value with documentLineValue');
        Assert.areEqual(GDDocumentSummary.PENDING, line.status, 'status does not match with PENDING value');
        Assert.areEqual(null, line.helpText, 'must be null because there are not values in Ayuda_Portal__c sObject');
        Assert.areEqual(Contract.DocumentosRedaccion__c.getDescribe().getName(), line.relatedField, 'value should be Contract.DocumentosRedaccion__c');
        Assert.areEqual(gdSummary.documentLabels.get(line.value), line.title, 'shoulb be populated with Ayuda_Portal__c.Descripcion__c value');
    }
    
    @isTest
    private static void shouldGetAllRedactionLinesAsDocumentLine() {
        expedient.DocumentosRedaccion__c = '167;32;55;180';
        expedient.DocumentosRedaccionAportados__c = '32;167';
        insert expedient;
        GDDocumentSummary gdSummary;

        Test.startTest();
        gdSummary = new GDDocumentSummary(expedient.Id);
        Test.stopTest();

        Assert.areEqual(
            gdSummary.documentLines.size(),
            gdSummary.redactionLines.size(),
            'Should be populated with all lines as document line'
        );

        Integer actualUploadedLines = 0;
        Integer actualPendingLines = 0;

        for (GDDocumentSummary.GDDocumentLine line : gdSummary.documentLines) {
            if (gdSummary.uploadedRedactionLines.contains(line.value)) {
                actualUploadedLines++;
                
            } else {
                actualPendingLines++;
            }
        }

        Assert.areEqual(
            gdSummary.uploadedRedactionLines.size(),
            actualUploadedLines,
            'Should be populated with all lines as document line'
        );

        Integer pendingLines = gdSummary.redactionLines.size() - gdSummary.uploadedRedactionLines.size();
        Assert.areEqual(
            pendingLines,
            actualPendingLines,
            'Should be populated with all lines as document line'
        );
    }

    @isTest
    private static void shouldGetAllAditionalLinesAsDocumentLine() {
        expedient.DocumentosAdicionales__c = '167;32;';
        expedient.DocumentosAdicionalesAportados__c = '32;';
        insert expedient;
        GDDocumentSummary gdSummary;

        Test.startTest();
        gdSummary = new GDDocumentSummary(expedient.Id);
        Test.stopTest();

        Assert.areEqual(
            gdSummary.documentLines.size(),
            gdSummary.aditionalLines.size(),
            'Should be populated with all lines as document line'
        );

        Integer actualUploadedLines = 0;
        Integer actualPendingLines = 0;

        for (GDDocumentSummary.GDDocumentLine line : gdSummary.documentLines) {
            if (gdSummary.uploadedAditionalLines.contains(line.value)) {
                actualUploadedLines++;
                
            } else {
                actualPendingLines++;
            }
        }

        Assert.areEqual(
            gdSummary.uploadedAditionalLines.size(),
            actualUploadedLines,
            'Should be populated with all lines as document line'
        );

        Integer pendingLines = gdSummary.aditionalLines.size() - gdSummary.uploadedAditionalLines.size();
        Assert.areEqual(
            pendingLines,
            actualPendingLines,
            'Should be populated with all lines as document line'
        );
    }
    
}