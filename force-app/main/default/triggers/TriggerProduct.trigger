/*
@author LeadClic Solutions S.L.
@date 03/10/2019
@description Trigger de Producto

FECHA                 AUTOR           ACCION
03/10/2019			LCS - RDM		 Creación. 
*/
trigger TriggerProduct on Product2 (after insert) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            TriggerProductHandler.afterInsert(trigger.new);
        }
    }
}