/*
@author LeadClic Solutions S.L.
@date 25/04/2019
@description Clase que relaciona los roles que tiene una cuenta en sus contratos

<pre>
FECHA                 AUTOR           ACCION
25/04/2019	           DRM	         Creación.
18/09/2019            LCS - RMG      Modificación. Se cambia la query para recuperar el id de expediente personalizado y no el estándar 
18/09/2019            LCS - RMG      Modificación. Se añaden más columnas que mostrar en el componente
*/

public with sharing class RolesFuncionesContrato {

 @AuraEnabled(cacheable=true)// Expone el método a los componentes Lightning y almacena en caché la lista 
    public static List<ContractWrapper> getContractContactRoleList(string idContacto) {
        
        List<ContractWrapper> lWrapper = new List<ContractWrapper>();
        List<ContractContactRole> lRole = new List<ContractContactRole>();
        
        lRole= [SELECT Id, ContractId , Role, Contract.IdExpediente__c, Contract.Producto__r.Name, Contract.Status, Contract.StartDate, 
                        Contract.Owner.Name, Contract.PagoConfirmado__c
                FROM ContractContactRole 
                WHERE Contact.AccountId = :idContacto];
    
        /* Iteramos los registros de contract role */
        for (ContractContactRole c : lRole) {
            ContractWrapper wrapper1 = new ContractWrapper();
            wrapper1.role = c.Role;
            wrapper1.ContractNumber = c.Contract.IdExpediente__c;
            wrapper1.ContractId=c.ContractId;
            wrapper1.name = c.Contract.Producto__r.Name;
            wrapper1.ContractEstado = c.Contract.Status; 
            if(c.Contract.StartDate != null)wrapper1.ContractFechaContratacion = c.Contract.StartDate.format();
            wrapper1.ContractPropietario = c.Contract.Owner.Name;
            wrapper1.ContractPagoConfirmado = c.Contract.PagoConfirmado__c;
       //     wrapper1.numRegistros=lRole.size();
            lWrapper.add(wrapper1);
        }

        /* Devuelvo la lista de Wrapper */
        return lWrapper;
    }

    public class ContractWrapper {
        @AuraEnabled public String role;
        @AuraEnabled public String name;
        @AuraEnabled public String ContractNumber;
        @AuraEnabled public String ContractId;     
        @AuraEnabled public String ContractEstado;     
        @AuraEnabled public String ContractFechaContratacion;     
        @AuraEnabled public Boolean ContractPagoConfirmado;     
        @AuraEnabled public String ContractPropietario;     
    }

}