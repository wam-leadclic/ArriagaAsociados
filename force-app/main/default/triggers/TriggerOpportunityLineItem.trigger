/*
@author LeadClic Solutions S.L.
@date 22/05/2019
@description Trigger para el objeto linea de oportunidad

<pre>
FECHA             AUTOR           ACCION
22/05/2019		LCS - RDM	   	  Creación. 
03/09/2019      LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados 
*/
trigger TriggerOpportunityLineItem on OpportunityLineItem (after insert) {
    //Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerOpportunityLineItem' LIMIT 1];

    if(activoTrigger.Activo__c){
        if(trigger.isAfter && trigger.isInsert){
            TriggerOpportunityLineItemHandler.afterInsert(trigger.new);
        }
    }
}