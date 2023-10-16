/*
@author LeadClic Solutions S.L.
@date 21/05/2019
@description Trigger para el objeto usuario

<pre>
FECHA             AUTOR           ACCION
21/05/2019		LCS - RMG	   	  Creación.
03/09/2019      LCS - RMG        Modificación. se añade el poder desactivar el trigger a través de metadatos personalizados  
*/
trigger TriggerUsuario on User (after insert) {
	//Recuperamos los metadatos para saber si el trigger está activo
    ActivacionTrigger__mdt activoTrigger = [SELECT Activo__c
                                            FROM ActivacionTrigger__mdt
                                            WHERE Label = 'TriggerUsuario' LIMIT 1];

    if(activoTrigger.Activo__c){
        if (Trigger.isAfter) {
            if(Trigger.isInsert){
                TriggerUsuarioHandler.afterInsert(Trigger.new);
            } 
        }
    }
}