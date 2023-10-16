/*
@author LeadClic Solutions S.L.
@date 10/05/2019
@description Trigger para el objeto Evento

<pre>
FECHA             AUTOR           ACCION
10/05/2019		LCS - RMG	   	  Creación. 
17/05/2019		LCS - RDM	   	  Modificación. se añade el after update 
27/05/2019		LCS - RDM	   	  Modificación. se añade el before update 
03/09/2019      LCS - RMG         Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados
10/10/2019      LCS - RDM         Modificación. se añade el before delete  
*/
trigger TriggerEvent on Event (after insert, before insert, after update, before delete) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerEvent' LIMIT 1];

    if(activoTrigger.Activo__c){
        if(trigger.isAfter && trigger.isInsert){
            TriggerEventHandler.afterInsert(trigger.new);
        }
        else if(trigger.isAfter && trigger.isUpdate){
            TriggerEventHandler.afterUpdate(trigger.new, trigger.oldMap);
        }
        else if(trigger.isBefore && trigger.isInsert){
            TriggerEventHandler.beforeInsert(trigger.new);
        }
        else if(trigger.isBefore && trigger.isDelete){
            TriggerEventHandler.beforeDelete(trigger.old);
        }
    }
}