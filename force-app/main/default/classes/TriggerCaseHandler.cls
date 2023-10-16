/*
@author LeadClic Solutions S.L.
@date 11/07/2019
@description Trigger para el objeto Caso

<pre>
FECHA             AUTOR           ACCION
11/07/2019        LCS - RMG       Creación. Se crea para la asignación automática de los SLAs en los casos
16/07/2019		  LCS - RMG		  Modificación. Cuando el usuario que inserta el caso es de la comunidad se provoca la ejecución de las reglas de asignación de casos, 
									necesario hacerlo desde este trigger porque sino no saltan las reglas de asignación y el caso queda en propiedad del usuario de la comunidad
29/07/2019		  LCS - RDM		  Modificación. Se modifica la asignación de SLAs al tener ahora 2 Asignaciones diferentes
*/
public class TriggerCaseHandler {
	
    /**
     *  Método que se llama desde el trigger de Caso
     *       
     * @param  lista con los casos creados
     */
    public static void beforeInsert( list<Case> lNewCase){
        list<Entitlement> lsla = [Select Id, Name from Entitlement limit 2];
        Id slaIncidencias; //Id de la asignación al SLA de Incidencias
        Id sla; //Id de la asignación al SLA genérico
        //Al crear el caso se asigna el entitlement (SLA) 
        if(!lsla.isEmpty()){
            for(Entitlement e : lsla){
                if(e.Name == 'SLAs Incidencias') slaIncidencias = e.Id;
                else sla = e.Id;
            } 
        }
        for(Case caso :lNewCase){
            if(!lsla.isEmpty()){
                Map<String, SLAsIncidenciaAsignacion__c> lConfigTipos = SLAsIncidenciaAsignacion__c.getAll();
                if(lConfigTipos.containsKey(caso.RecordTypeId)) caso.EntitlementId = slaIncidencias;
                else caso.EntitlementId = sla;
            }
        }
    }
    
    /**
     *  Método que se llama desde el trigger de Caso
     *       
     * @param  lista con los casos creados
     */
    public static void afterInsert( list<Case> lNewCase){
        //Si es usuario de la comunidad se asocia el caso a las reglas de asignación para que se ejecuten
        if(System.UserInfo.getProfileId() == system.label.IdPerfilUsuariocomunidad){
            Database.DMLOptions dmo = new Database.DMLOptions();
    		dmo.AssignmentRuleHeader.useDefaultRule = true;
            //Recuperamos los id de los casos insertados
            Set<Id> caseIdSet = new Set<Id>();
            for(Case c : lNewCase) {
                caseIdSet.add(c.Id);
            }
            
            list<Case> lCasosComunidad = new list<Case>();
            //Asignamos a los casos asignados el proceso de asignación de casos que está activo
            for(Case caso :[SELECT Id FROM Case WHERE Id IN: caseIdSet]){
                caso.setOptions(dmo);
                lCasosComunidad.add(caso);
            }
            
            update lCasosComunidad;
        }
    }
    
}