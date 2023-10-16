/*
@author LeadClic Solutions S.L.
@date 13/05/2019
@description Trigger de Pagos

FECHA                 AUTOR           ACCION
13/05/2019			LCS - RDM		 Creación.
03/09/2019      	LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados 
*/
trigger TriggerPago on Pago__c (after insert, after update) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerPago' LIMIT 1];

    if(activoTrigger.Activo__c){
        //Seccion para los pasos de After
        if(trigger.isAfter){
            //Si es al actualizar
            if(trigger.isUpdate){
                TriggerPagoHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
            //Si es al insertar
            else if(trigger.isInsert){
                TriggerPagoHandler.afterInsert(trigger.new);
            }
        }
    }
}