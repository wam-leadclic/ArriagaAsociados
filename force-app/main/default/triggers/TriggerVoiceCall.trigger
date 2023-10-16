/*
@author Omega CRM 
@date 01/02/2023
@description Trigger de Voicecall

<pre>
FECHA                 AUTOR           ACCION
01/02/2023			OMEGA CRM		 Creación.
*/

trigger TriggerVoiceCall on VoiceCall (before insert, after insert, before update, after update ) {
    ActivacionTrigger__mdt activoTrigger = ActivacionTrigger__mdt.getInstance('TriggerVoiceCall');
    //Update
    if(activoTrigger != null && activoTrigger.Activo__c){    
        //Before
        if(trigger.isBefore && trigger.isUpdate){
            TriggerVoiceCallHandler.beforeUpdate(trigger.old, trigger.newMap);
        }
        
        //After
        if(trigger.isAfter && trigger.isUpdate){
            TriggerVoiceCallHandler.afterUpdate(trigger.old, trigger.newMap);
        }
    }        
}