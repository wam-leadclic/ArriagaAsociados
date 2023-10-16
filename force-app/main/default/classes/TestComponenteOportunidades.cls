/*
@author LeadClic Solutions S.L.
@date 25/04/2019
@description Clase Test para la clase RolesFuncionesOportunidad

<pre>
FECHA                 AUTOR           ACCION
25/04/2019			LCS - LB		 Creación.
04/09/2019			LCS - RDM		 Modificación. Subida de % de cobertura
31/03/2020          LCS - RAL        Modificación. Se añade el teléfono en la creación de cuenta.

*/

@isTest
public class TestComponenteOportunidades {
    
    @isTest static void testComponente(){
        
        Account ac = new Account();
        ac.FirstName= 'CuentdaTest';
        ac.LastName= 'CuentaTest';
        ac.EstadoCuenta__c='Cliente';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        ac.IdClienteMinerva__c = '12345';
        ac.Phone = '60000000';
        insert ac;

        Account ac2 = new Account();
        ac2.FirstName= 'RolTest';
        ac2.LastName= 'RolTest';
        ac2.EstadoCuenta__c='Cliente';
        ac2.IdClienteMinerva__c = '12346';
        ac2.Phone = '60000000';
        ac2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        insert ac2;
    

        Account PersonContactId= [SELECT PersonContactId
                                FROM Account 
                                WHERE Id =: ac.Id
                                LIMIT 1];

        Opportunity opp = new Opportunity();
            opp.AccountId = ac.Id;
            opp.StageName = 'Prospecting';      
            opp.Name = 'OppTest';
            Opp.CloseDate = date.valueOf(system.now());
        insert opp;
        
         Opportunity opp2 = new Opportunity();
            opp2.AccountId = ac2.Id;
            opp2.StageName = 'Prospecting';      
            opp2.Name = 'OppTest';
            Opp2.CloseDate = date.valueOf(system.now());
        insert opp2;

        OpportunityContactRole opprole = new OpportunityContactRole();
            opprole.ContactId = PersonContactId.PersonContactId;
            opprole.Role = 'Titular';
            opprole.OpportunityId = opp.Id;
        insert opprole;

        OpportunityContactRole opprole2 = new OpportunityContactRole();
            opprole2.ContactId = personContactId.PersonContactId;
            opprole2.Role = 'Titular';
            opprole2.OpportunityId = opp2.Id;
        insert opprole2;

        system.Test.startTest();
        	RolesFuncionesOportunidad.getOpportunityContactRoleList(ac.Id);
        system.Test.stopTest();
    }
}