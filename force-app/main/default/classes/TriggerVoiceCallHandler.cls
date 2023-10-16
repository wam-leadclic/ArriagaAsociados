/*
@author OMEGA CRM
@date 01/02/2023
@description Clase que se encarga de la lógica del trigger de VoiceCall

<pre>
FECHA                 AUTOR           ACCION
01/02/2023			OMEGA CRM		 Creación.
*/
public without sharing class TriggerVoiceCallHandler {

    /**
     *  Método que ejecuta las acciones before update del objeto VoiceCall
     * @param  vcNewMap mapa de los valores actuales
     * @param  vcOldList lista de registros antiguos
     */
    public static void beforeUpdate(list<VoiceCall> vcOldList, map<Id, VoiceCall> vcNewMap){
        Map<Id,OM_Callback__c> vcCallbackMap = new Map<Id,OM_Callback__c>();
        List<VoiceCall> vcTocheck = new List<VoiceCall>();

        for(VoiceCall oldVC: vcOldList){
            VoiceCall newVC = vcNewMap.get(oldVC.Id);

            //Si cumple todas las condiciones, se actualiza Cola Origen CB 
            //Cambia el campo OM_OfficeQueue__c(condicion 2) (a cualquier valor relleno (condicion 1)) 
            //o cambia el campo OM_OriginQueue__c(condicion 2) y OM_OfficeQueue__c está relleno (condicion 1)
            
			//Condicion 1 - OM_OfficeQueue__c relleno
			if (newVC.OM_OfficeQueue__c != null)
            {
               //Condicion 2 - Cambia el campo OM_OfficeQueue__c o cambia el campo OM_OriginQueue__c
               if(oldVC.OM_OfficeQueue__c != newVC.OM_OfficeQueue__c || oldVC.OM_OriginQueue__c  != newVC.OM_OriginQueue__c ) 
            	{ 
                    OM_QueueSettingsSCV__mdt queueConfig = String.isNotBlank(newVC.OM_OfficeQueue__c) ? OM_QueueSettingsSCV__mdt.getInstance(newVC.OM_OfficeQueue__c) : OM_QueueSettingsSCV__mdt.getInstance('SCV_DEFAULT_CB');
					newVC.OM_OriginQueue__c = (queueConfig != null) ? newVC.OM_OfficeQueue__c : null;
                }
        	}
    	}
    }
    
    /**
     *  Método que ejecuta las acciones after update del objeto VoiceCall
     * @param  vcNewMap mapa de los valores actuales
     * @param  vcOldList lista de registros antiguos
     */
    public static void afterUpdate(list<VoiceCall> vcOldList, map<Id, VoiceCall> vcNewMap){
        Map<Id,OM_Callback__c> vcCallbackMap = new Map<Id,OM_Callback__c>();
        List<VoiceCall> vcTocheck = new List<VoiceCall>();

        for(VoiceCall oldVC: vcOldList){
            VoiceCall newVC = vcNewMap.get(oldVC.Id);
            //Si cumple todas las condiciones, se configura el callback
            //Cambia GDPR a Sí
            //No se ha aceptado la llamada
            //Es una llamada entrante
            //No ha habido desbordamiento
            //Se trata de una llamada de fuera de horario, de alguien que ha abandonado sin ser cliente o de un cliente que ha pedido que se le llame de nuevo
            if ((oldVC.OM_GDPR__c != OM_Constants.CONST_YES) && 
                (newVC.OM_GDPR__c == OM_Constants.CONST_YES) &&
                (newVC.CallAcceptDateTime == null) &&
                (newVC.CallType == OM_Constants.CALL_TYPE.get('INBOUND')) &&
                (newVC.OM_OutOfTime__c == OM_Constants.CONST_YES || String.isBlank(newVC.QueueName) ||  newVC.OM_GenerateCB__c == OM_Constants.CONST_YES)
                ){ 
                    vcCallbackMap.put(newVC.Id,generateCallBack(newVC, null));
                    vcTocheck.add(newVC);
                }
        }
        //Se comprueba si existe cola Callback para ser asignado.
        //Si no existe cola callback para asociar, no se crea el registro.
        assignCBToQueue(vcCallbackMap,vcTocheck);    
        
        //Operaciones DML
        if(!vcCallbackMap.isEmpty()){
            //Se controla error con try/catch para no impedir la actualización del VoiceCall
            try {
                insert vcCallbackMap.values();
            } catch(DmlException e) {
                System.debug('Error insertando Callback: ' + e.getMessage());
            }
            
        }
    }

    /**
     *  Método que completa la información del nuevo registro callback
     * @param  VoiceCall registro VoiceCall que origina el callback
     * @param  DateTime fecha programada del callback
     */
    public static OM_Callback__c generateCallBack (VoiceCall vcRecord, DateTime schedDate){
        OM_CallBack__c cbRecord = new OM_CallBack__c();
        cbRecord.OM_Status__c = (schedDate == null) ? OM_Constants.CALL_STATUS.get('PENDING') : OM_Constants.CALL_STATUS.get('NEW');
        cbRecord.OM_Case__c = vcRecord.OM_Case__c;
        cbRecord.OM_Account__c = vcRecord.OM_Account__c;
        cbRecord.OM_OriginQueue__c = String.isNotBlank(vcRecord.OM_OriginQueue__c) ? vcRecord.OM_OriginQueue__c: OM_QueueSettingsSCV__mdt.getInstance('SCV_DEFAULT_CB').OM_DefaultQueue__c;
        //Se comprueba si existe cola que debería ser el owner y si está almacenada en el custom metadata
        OM_QueueSettingsSCV__mdt queueConfig = String.isNotBlank(vcRecord.OM_OriginQueue__c) ? OM_QueueSettingsSCV__mdt.getInstance(vcRecord.OM_OriginQueue__c) : OM_QueueSettingsSCV__mdt.getInstance('SCV_DEFAULT_CB');
        cbRecord.OM_OwnerQueue__c = (queueConfig != null) ? queueConfig.OM_CallbackQueue__c : null;
        cbRecord.OM_ScheduledDate__c = (schedDate == null) ? null : schedDate;
        cbRecord.OM_VoiceCall__c = vcRecord.Id;
        cbRecord.OM_Opportunity__c = vcRecord.OM_Opportunity__c;
        cbRecord.OM_Phone__c = vcRecord.FromPhoneNumber;
        cbRecord.OM_Type__c = (vcRecord.OM_OutOfTime__c == OM_Constants.CONST_YES) ? OM_Constants.OUTBOUND_TYPE.get('OUTOFTIME') : OM_Constants.OUTBOUND_TYPE.get('ABANDONED'); 
        cbRecord.RecordtypeId = Schema.SObjectType.OM_Callback__c.getRecordTypeInfosByDeveloperName().get('OM_Callback').getRecordTypeId();
        return cbRecord;
    }

    /**
     *  Método que comprueba si existe una cola callback asociada a la cola origen y la asigna al nuevo registro
     * @param  vcCBMap mapa que relaciona el id del voicecall con el registro de callback que debe crearse
     * @param  vcList listado de voicecall que lanzan el trigger
     */
    public static void assignCBToQueue (Map<Id,OM_Callback__c> vcCBMap, List<VoiceCall> vcList){
        Map<Id, String> vcCallbackQueuesStr = new Map<Id, String>();
        Map<String, Id> queueMap = new Map<String, Id>();
		for(VoiceCall vcRecord: vcList){
            //Se comprueba si existe cola de origen y si está almacenada en el custom metadata
            OM_QueueSettingsSCV__mdt queueConfig = String.isNotBlank(vcRecord.OM_OriginQueue__c) ? OM_QueueSettingsSCV__mdt.getInstance(vcRecord.OM_OriginQueue__c): OM_QueueSettingsSCV__mdt.getInstance('SCV_DEFAULT_CB');
            //Se relaciona el registro del voicecall con la cola callback
            if(queueConfig != null && String.isNotBlank(queueConfig.OM_CallbackQueue__c)){
                vcCallbackQueuesStr.put(vcRecord.Id, queueConfig.OM_CallbackQueue__c );
            }else{ // Si no se encuentra cola callback no se crea el registro
                vcCBMap.remove(vcRecord.Id);
            }         
        }
        if(vcCallbackQueuesStr.isEmpty()){
            return;
        }
        //Se obtienen las colas callbacks que deben asociarse
        for(Group queueRecord: [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN: vcCallbackQueuesStr.values() ]){
            queueMap.put(queueRecord.DeveloperName, queueRecord.Id);
        }
        
        //Se asigna el owner del callback
        for(Id vcId: vcCBMap.keySet()){
            String cbQueueStr = (!vcCallbackQueuesStr.isEmpty() && vcCallbackQueuesStr.containsKey(vcId)) ? vcCallbackQueuesStr.get(vcId) : '';
            
            if( String.isNotBlank(cbQueueStr) && !queueMap.isEmpty() && queueMap.containsKey(cbQueueStr)){
                vcCBMap.get(vcId).OwnerId = queueMap.get(cbQueueStr);
            }else{
                vcCBMap.remove(vcId);
            }
        }
    }
}