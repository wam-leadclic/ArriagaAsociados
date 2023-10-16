/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Trigger de Candidato

<pre>
FECHA                 AUTOR           ACCION
30/04/2019			LCS - RDM		 Creación.
20/05/2019          LCS - RMG        Modificación. Se añade el after insert
03/09/2019      	LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados 
*/
trigger TriggerLead on Lead (before update, before insert, after insert) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerLead' LIMIT 1];

    if(activoTrigger.Activo__c){
        if(trigger.isBefore && trigger.isUpdate){
            TriggerLeadHandler.beforeUpdate(trigger.oldMap, trigger.new);
        }
        if(trigger.isBefore && trigger.isInsert){
            TriggerLeadHandler.beforeInsert(trigger.new);
        }
        if(trigger.isAfter && trigger.isInsert){
            TriggerLeadHandler.afterInsert(trigger.new);
        }
    }
}