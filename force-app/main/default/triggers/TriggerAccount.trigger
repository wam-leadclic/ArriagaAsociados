/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Trigger de cuenta

<pre>
FECHA                 AUTOR           ACCION
16/04/2019			LCS - RMG		 Creación.
29/04/2019			LCS - RDM		 Modificación. Se crea la llamada para las comprobaciones antes de la actualización
03/09/2019          LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados 
*/

trigger TriggerAccount on Account (after update, before update, before insert, after insert ) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerAccount' LIMIT 1];
	
    if(activoTrigger.Activo__c){        
        //Se llama a la clase controladora encargada de realizar la lógica
        if(trigger.isAfter && trigger.isUpdate){
            TriggerAccountHandler.afterUpdate(trigger.old, trigger.newMap);
        }
        if(trigger.isBefore && trigger.isUpdate){
            TriggerAccountHandler.beforeUpdate(trigger.oldMap, trigger.new);
        }
        if(trigger.isBefore && trigger.isInsert){
            TriggerAccountHandler.beforeInsert(trigger.new);
        }
    }
        
}