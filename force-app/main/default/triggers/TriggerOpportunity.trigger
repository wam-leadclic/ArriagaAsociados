/*
@author LeadClic Solutions S.L.
@date 08/05/2019
@description Trigger para el objeto Oportunidad

<pre>
FECHA             AUTOR           ACCION
08/05/2019		LCS - RMG	   	  Creación. 
03/09/2019      LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados
30/03/2020      LCS - RAL        Modificación. Creación del BeforeInsert 
*/
trigger TriggerOpportunity on Opportunity (after update, before update, before insert) {
	//Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerOpportunity' LIMIT 1];

    if(activoTrigger.Activo__c){
        if(trigger.isAfter && trigger.isUpdate){
            TriggerOpportunityHandler.afterUpdate(trigger.oldMap, trigger.new);
        }
        if(trigger.isBefore && trigger.isUpdate){
            TriggerOpportunityHandler.beforeUpdate(trigger.oldMap, trigger.new);
        }
        if(trigger.isBefore && trigger.isInsert){
            TriggerOpportunityHandler.beforeInsert(trigger.new);
        }
    }
}