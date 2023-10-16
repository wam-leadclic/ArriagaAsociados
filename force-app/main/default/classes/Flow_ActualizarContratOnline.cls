/*
@author LeadClic Solutions S.L.
@date 18/06/2019
@description Clase que actualiza la contratación Online al crear 2ºTitular o encontrar ya otro contacto

<pre>
FECHA                 AUTOR           ACCION
18/06/2019			LCS - RDM		 Creación
*/
global without sharing class Flow_ActualizarContratOnline {
    /**
     *  Método invocable desde los flujos. Utilizamos una lista de una wrapper class de datos enviados desde el flujo. 
     *  
     * 
     * @param  consentimientoSegTit	valor del consentimiento del segundo titular
     * @param  emailSegTit email del segundo titular
     * @param  segTit id del segundo titular
     * @param  tieneVariosTit valor del segundo titular
     * 
     */
    @InvocableMethod(label='Llamada flujo' description='Llamada desde el flujo')
    public static void metodoInvocable (list<GetParameters> WrapperParams){
        //Actualizamos la contratación online con los datos obtenidos del flujo
        CommunityOpp__c contrOnline = new CommunityOpp__c();
            contrOnline.Id = WrapperParams[0].idContratOnline;
            contrOnline.ConsentimientoDatosSegundoTitular__c = WrapperParams[0].consentimientoSegTit;
            contrOnline.Email2Titular__c = WrapperParams[0].emailSegTit;
            contrOnline.SegundoTitular__c = WrapperParams[0].segTit;
            contrOnline.TieneVariosTitulares__c = WrapperParams[0].tieneVariosTit;
        update contrOnline;
    }
    /*
     * @descripción Wrapper class que recibe los datos de entrada del flujo
     */ 
    global class GetParameters {
        
        @InvocableVariable( label = 'IdContratOnline' description = 'Id contratación online' required=true )
        global String idContratOnline; 
        
        @InvocableVariable( label = 'Consentimiento2ºTit' description = 'Consentimiento 2º Titular' required=true )
        global String consentimientoSegTit; 
        
        @InvocableVariable( label = 'Email2ºTitular' description = 'Email 2º Titular' required=true )
        global String emailSegTit;
        
        @InvocableVariable( label = '2ºTit' description = '2º Titular' required=true )
        global Id segTit;
        
        @InvocableVariable( label = 'TieneVariosTit' description = 'Tiene Varios Titulares' required=true )
        global String tieneVariosTit;
    }
}