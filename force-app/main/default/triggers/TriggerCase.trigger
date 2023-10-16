/*
@author LeadClic Solutions S.L.
@date 11/07/2019
@description Trigger para el objeto Caso

<pre>
FECHA             AUTOR           ACCION
11/07/2019        LCS - RMG       Creación.
16/07/2019		  LCS - RMG		  Modificación. Cuando se inserta un caso y el usuario es de la comunidad se hace que se ejecuten las reglas de asignación.
03/09/2019        LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados 
*/
trigger TriggerCase on Case (before insert, after insert) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerCase' LIMIT 1];

    if(activoTrigger.Activo__c){
        if(system.Trigger.isBefore && system.Trigger.isInsert){
            TriggerCaseHandler.beforeInsert(trigger.new);
        }
        if(system.Trigger.isAfter && system.Trigger.isInsert){
            TriggerCaseHandler.afterInsert(trigger.new);
        }
    }
}