/*
@author LeadClic Solutions S.L.
@date 17/10/2023
@description Clase GDDocumentSummaryControllerTest: test unitarios para la clase GDDocumentSummaryController.
<pre>
FECHA             AUTOR           ACCION
17/10/2023		LCS - SDF	   	  Creación.
*/
@isTest
private class GDDocumentSummaryControllerTest {
    static User communityUser;
    static Contract expedient;

    static {
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
        Profile p = [SELECT Id From Profile Where Name = 'Comunidad Arriaga'];
        if (UserInfo.getUserRoleId() == null) {
            System.runAs(new User(Id = UserInfo.getUserId())) {
                User userWithRole = [SELECT Id,UserRoleId FROM User WHERE UserRoleId != null LIMIT 1];
                update new User(Id = UserInfo.getUserId(), UserRoleId = userWithRole.UserRoleId);
            }
        }
        Account ac = new Account();
        	ac.name = 'Test';
        	ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        	ac.EstadoCuenta__c='Cliente';
        	ac.IdClienteMinerva__c = '12345';
            ac.Phone = '654987321';
        insert ac;
        Contact cont = new Contact();
        	cont.accountId = ac.Id;
            cont.FirstName = 'NombreT';
            cont.lastName = 'Test';
            cont.MailingCountry = 'ESPAÑA';
            cont.MobilePhone =  '0034123456789';
            cont.Phone = '0034123456789';
            cont.Email = 'test.sz@example.com';
        insert cont;
    	//Crear usuario
        communityUser = new User(
            ContactId = cont.Id,
            FirstName = cont.FirstName,
            LastName = cont.LastName,
            IsActive = true,
            EmailEncodingKey = 'ISO-8859-1',
            Email = cont.Email,
            Username = cont.Email,
            CommunityNickname = cont.Email,
            Phone = cont.Phone,
            Alias = cont.FirstName,
            ProfileId = p.id,
            TimeZoneSidKey = 'Europe/Paris',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es_ES'
        );
        insert communityUser; 

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
        
        Opportunity opp = new Opportunity();
            opp.AccountId = ac.id;
            opp.StageName = 'Prospecting';      
            opp.Name = 'Test';
            opp.Pricebook2Id = standardPricebook.id;
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
        OpportunityContactRole opprole = new OpportunityContactRole();
            opprole.ContactId = cont.Id;
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
    private static void whenExpedientIdIsNullOrBlankItShouldThrowAnExceltion() {
        GDDocumentSummaryController.GDDocumentSummaryResponse response;
        String message;

        Test.startTest();
        System.runAs(communityUser) {
            response = GDDocumentSummaryController.getDocumentSumary(null);
        }
        Test.stopTest();

        Assert.areEqual(LightningDataResponse.ERROR, response.status, 'must be an error');
        Assert.areEqual(GDDocumentSummaryController.INVALID_ID, response.message, 'message should be populated with exception message');
    }

    @isTest
    private static void whenWeCallTheControllerWithInvalidSObjectItShouldThrowAnException() {
        GDDocumentSummaryController.GDDocumentSummaryResponse response;
        String message;

        Test.startTest();
        System.runAs(communityUser) {
            response = GDDocumentSummaryController.getDocumentSumary(UserInfo.getUserId());
        }
        Test.stopTest();

        Assert.areEqual(LightningDataResponse.ERROR, response.status, 'must be an error');
        Assert.areEqual(GDDocumentSummaryController.INVALID_SOBJECT_TYPE, response.message, 'message should be populated with exception message');
    }

    @isTest
    private static void whenCommunityUserCallTheControllerItShouldPopulateTheDataResponse() {
        GDDocumentSummaryController.GDDocumentSummaryResponse response;
        expedient.DocumentosRedaccion__c = '167;32;';
        expedient.DocumentosRedaccionAportados__c = '167';
        expedient.DocumentosAdicionales__c = '187';
        expedient.DocumentosAdicionalesAportados__c = '187';
        insert expedient;

        Test.startTest();
        System.runAs(communityUser) {
            response = GDDocumentSummaryController.getDocumentSumary(expedient.Id);
        }
        Test.stopTest();

        Assert.areEqual(LightningDataResponse.SUCCESS, response.status, 'must be success response');
        Assert.IsNotNull(response.data, 'data should be populated');
        Assert.areEqual(3, response.data.documentLines.size(),'there must be 3 document line');
    }
}

