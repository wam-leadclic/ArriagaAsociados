/*
@author LeadClic Solutions S.L.
@date 
@description Clase que contiene el código controlador del LWC contractPathLayoutController
<pre>
FECHA             AUTOR           ACCION
09/08/2021      LCS - SRG         Creación. Obtenemos el estado del expediente en base a la custom Setting
*/
public with sharing class contractPathLayoutController {
    
    @AuraEnabled(cacheable=true)
    public static string getStatus(String recordId){
        String estado ='';
        try {
            List<EstadosComunidad__c> ec= EstadosComunidad__c.getall().values();
            
            Contract expediente=[SELECT EstadoExpedienteComunidad__c FROM Contract WHERE Id=:recordId ];
            estado=expediente.EstadoExpedienteComunidad__c;
            for (EstadosComunidad__c variable : ec) {
                if(variable.Estado__c==expediente.EstadoExpedienteComunidad__c) estado=variable.Name;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return estado;
    }
}