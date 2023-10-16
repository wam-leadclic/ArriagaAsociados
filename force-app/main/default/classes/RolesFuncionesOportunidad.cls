/*
@author LeadClic Solutions S.L.
@date 23/04/2019
@description Clase para el Lightning web component que muestra las oportunidades asociadas a una cuenta

<pre>
FECHA               AUTOR           ACCION
23/04/2019          LCS-LB         Creación.
18/09/2019          LCS - RMG      Modificación. Se añaden nuevas columnas que mostrar en el componente
</pre>
*/

public with sharing class RolesFuncionesOportunidad {

 @AuraEnabled(cacheable=true)// Expone el método a los componentes Lightning y almacena en caché la lista 
    public static List<Wrapper> getOpportunityContactRoleList(string idAccount) {
        
        /* Obtenemos el PersonContactId del Id de la cuenta */
        List<Account> miCuenta= [SELECT PersonContactId 
                                FROM Account
                                WHERE Id = :idAccount
                                LIMIT 1];
        
        /* Obtenemos la información de la oportunidad asociada al Id del contacto obtenido en la Query anterior */
        List<OpportunityContactRole> lRole = [SELECT Id, OpportunityId, Opportunity.Name, Role, Opportunity.StageName, Opportunity.NumeroExpediente__c, 
                                                    Opportunity.HojaEncargo__r.Name, Opportunity.Owner.Name, Opportunity.CloseDate, Opportunity.AccountId, Contact.AccountId
                                              FROM OpportunityContactRole
                                              WHERE ContactId = :miCuenta[0].PersonContactId];

        List <Wrapper> lWrapper= new List<Wrapper>();
        

        for(OpportunityContactRole c: lRole){
            //Solo se añade a la lista si el contacto no es el mismo que el de la oportunidad
            if(c.Contact.AccountId != c.Opportunity.AccountId){
                Wrapper wrap = new Wrapper();
                wrap.oppId= c.OpportunityId;
                wrap.oppName = c.Opportunity.Name;
                wrap.role = c.Role;
                wrap.etapa = c.Opportunity.StageName;
                wrap.numExpediente = c.Opportunity.NumeroExpediente__c;
                wrap.hojaEncargo = c.Opportunity.HojaEncargo__r.Name;
                wrap.propietario = c.Opportunity.Owner.Name;
                if(c.Opportunity.CloseDate != null) wrap.fechaCierre = c.Opportunity.CloseDate.format();
                lWrapper.add(wrap);
            }
        }

        return lWrapper;
    }


    public class Wrapper{

        @AuraEnabled public string oppId;
        @AuraEnabled public string oppName;
        @AuraEnabled public string role;        
        @AuraEnabled public string etapa;
        @AuraEnabled public string numExpediente;
        @AuraEnabled public string hojaEncargo;
        @AuraEnabled public string propietario;
        @AuraEnabled public String fechaCierre;
        
    }
}