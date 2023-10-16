/*
@author LeadClic Solutions S.L.
@date 10/04/2019
@description Trigger para el objeto Expediente(Contract)

<pre>
FECHA             AUTOR           ACCION
17/04/2019		LCS - RDM	   	  Creación.
06/05/2019      LCS - RMG         Modificación. Se añade que el trigger sea before update
19/06/2019      LCS - RDM         Modificación. Se añade que el trigger sea after update
27/06/2019      LCS - RDM         Modificación. Se añade que el trigger sea before insert
03/09/2019      LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados 
*/
trigger TriggerContract on Contract (before insert, after insert, before update, after update) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerContract' LIMIT 1];

    if(activoTrigger.Activo__c){
        if (Trigger.isAfter) {
            if(Trigger.isInsert){
                TriggerContractHandler.afterInsert(Trigger.new);
            } else if(Trigger.isUpdate){
                TriggerContractHandler.afterUpdate(Trigger.new, Trigger.oldMap);
            }
        }

        if(Trigger.isBefore){
            TriggerContractHandler.updateStatusCommunity(Trigger.new);

            if(Trigger.isInsert){
                TriggerContractHandler.beforeInsert(Trigger.new);
            } else if(Trigger.isUpdate){
                TriggerContractHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }
    }
}