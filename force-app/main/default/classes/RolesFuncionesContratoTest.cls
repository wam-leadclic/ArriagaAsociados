/*
@author LeadClic Solutions S.L.
@date 25/04/2019
@description Clase de Test de RolesFuncionesContrato

<pre>
FECHA             AUTOR           ACCION
25/04/2019		   DRM	   	     Creación.
31/03/2020         RAL           Modificación. Se añade el teléfono en la creación de cuenta.
*/
@isTest
public class RolesFuncionesContratoTest {
    
    @isTest static void RolesFuncionesContratoTest() {
        
        EstadosComunidad__c confEstadosComunidad = new EstadosComunidad__c();
        confEstadosComunidad.Name = '00';
        confEstadosComunidad.Estado__c = 'ESTADO NO DEFINIDO';
        insert confEstadosComunidad;
        
        Account ac = new Account();
        ac.LastName = 'CuentaTest';
        ac.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
        ac.EstadoCuenta__c='Cliente';
        ac.Phone = '60000000';
        ac.FirstName = 'CuentaTest';
        insert ac;
        
        Account Personal =[SELECT PersonContactId 
                          FROM Account
                          WHERE Id =: ac.Id
                          LIMIT 1 ];		
        
        Contract contr = new Contract();
        contr.Name = 'ContratoTest';
        contr.AccountId = ac.Id;
        contr.Status = 'Contratado';
        insert contr;
        system.debug('creado contrato: ' + contr.Name);
        
        ContractContactRole ccr = new ContractContactRole();
        ccr.ContractId = contr.Id;
        ccr.ContactId = Personal.PersonContactId;
        ccr.Role = 'Business User';
        insert ccr;
        
        system.Test.startTest();
        RolesFuncionesContrato.getContractContactRoleList(ac.Id);
        system.Test.stopTest();
        
    }
}