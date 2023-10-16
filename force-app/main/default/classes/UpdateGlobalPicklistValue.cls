/*
@author LeadClic Solutions S.L.
@date 26/06/2019
@description Clase que contiene los métodos para llamar a la API de SF y de esta manera actualizar las lista de valores globales 
<pre>
FECHA             AUTOR           ACCION
26/06/2019      LCS - RDM         Creación.
03/07/2019      LCS - RDM         Modificación. Se añade método para obtener la autenticación.
 
*/
public without sharing class UpdateGlobalPicklistValue {
    /**
    * Método encargado obtener el sesion Id para poder acceder
    *
    * @return token
    *
    */
    public static String getAuthToken (){
        String token;
            //Cargamos el custom setting para obtener los datos necesarios del Endpoint
            IntegracionSF__c datosSF = IntegracionSF__c.getInstance('General');
            
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(datosSF.UrlEndPoint__c + '?grant_type=password&client_id='+ datosSF.clientid__c + '&client_secret=' + datosSF.clientsecret__c + '&username=' + datosSF.username__c + '&password='+ datosSF.password__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            HttpResponse response = h.send(request);
            
            
            if(response.getStatusCode() != 200){
                token = null;
            }else{
                map<String,Object> mRespuesta = (map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                token = (String)mRespuesta.get('access_token');
            }
        return token;
    }
    /**
    * Método encargado de crear nuevos valores
    *
    * @param nuevoDoc : nombre para el nuevo valor global
    * @param nuevoApiDoc :  nombre api de ese nuevo valor global
    *
    */
    public static void postNewGlobal (String nuevoDoc, String nuevoApiDoc){
        //system.debug('postNewGlobal');
        wrapper respuesta = new wrapper();
        datos newGlobal = new datos();
        String fieldDef = '';//respuesta
        
        if(Test.isRunningTest()) TestUpdateGlobalPicklistValue.prueba = 1;
        //String token =  UserInfo.getSessionId();
        String token = getAuthToken ();
        //system.debug('token : ' + token);
        
        
        if(Test.isRunningTest()) TestUpdateGlobalPicklistValue.prueba = 2;
        Http http = new Http();
        HttpRequest wsRequest = new HttpRequest();
        wsRequest.setMethod('GET');  
        wsRequest.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/tooling/sobjects/GlobalValueSet/' + System.Label.IdGlobalValuePicklist);
        //wsRequest.setHeader('Content-Type', 'application/json');
        wsRequest.setHeader('Authorization', 'Bearer ' + token);
        
        system.debug('wsRequest : ' + wsRequest);
        
        
        //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
        HttpResponse wsResponse = http.send(wsRequest);
        while (wsResponse.getStatusCode() == 302) {
            wsRequest.setEndpoint(wsResponse.getHeader('Location'));
            wsResponse = new Http().send(wsRequest);
        }
        //System.debug('respuesta : ' + wsResponse.getBody());
        respuesta = (wrapper)JSON.deserialize(wsResponse.getBody(), wrapper.class);
        //System.debug('respuesta : ' + respuesta);
        List<Object> lob = respuesta.Metadata.customValue;
            newGlobal.isActive = true;
            newGlobal.label = nuevoDoc;      
            newGlobal.valueName = nuevoApiDoc; 
        lob.add(newGlobal);        
        
        
        string lista = JSON.serialize(lob);
        fieldDef = '{"Metadata":{"customValue":'+ lista +',"description":null,"masterLabel":"DocumentosRequeridos","sorted":false,"urls":null},"FullName":"DocumentosRequeridos"}';
        
        //system.debug('Envio : ' + fieldDef);
        
        if(Test.isRunningTest()) TestUpdateGlobalPicklistValue.prueba = 3;
        
        HttpRequest req = new HttpRequest();
        req.setBody(fieldDef);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/tooling/sobjects/GlobalValueSet/' + System.Label.IdGlobalValuePicklist + '?_HttpMethod=PATCH');
        req.setMethod('POST');
        
        Http httpreq = new Http();
        HttpResponse res  = httpreq.send(req);
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
        
        system.debug(res.getBody());
    }
    
    /**
    * Método encargado de actualizar valores globales
    *
    * @param nuevoApiDoc : nombre api del valor a actulizar
    * @param active : valor boleano para activar o desactivar valor
    *
    */
    public static void updateGlobal (String ApiDoc, String NameDoc, Boolean active){
        wrapper respuesta = new wrapper();
        String fieldDef = '';//respuesta        
        
        if(Test.isRunningTest()) TestUpdateGlobalPicklistValue.prueba = 1;
        //String token =  UserInfo.getSessionId();
        String token = getAuthToken ();
        
        
        if(Test.isRunningTest()) TestUpdateGlobalPicklistValue.prueba = 2;
        
         Http http = new Http();
        HttpRequest wsRequest = new HttpRequest();
        wsRequest.setMethod('GET');  
        wsRequest.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/tooling/sobjects/GlobalValueSet/' + System.Label.IdGlobalValuePicklist);
        //wsRequest.setHeader('Content-Type', 'application/json');
        wsRequest.setHeader('Authorization', 'Bearer ' + token);
        
        
        //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
        HttpResponse wsResponse = http.send(wsRequest);
        while (wsResponse.getStatusCode() == 302) {
            wsRequest.setEndpoint(wsResponse.getHeader('Location'));
            wsResponse = new Http().send(wsRequest);
        }
        
        respuesta = (wrapper)JSON.deserialize(wsResponse.getBody(), wrapper.class);
        List<Object> lob = new List<Object> (); 
        
        for(integer i = 0; i<respuesta.Metadata.customValue.size(); i++){
            if(respuesta.Metadata.customValue.get(i).valueName == ApiDoc){
                respuesta.Metadata.customValue.get(i).isActive = active;
                if(!String.isBlank(NameDoc)) respuesta.Metadata.customValue.get(i).label = NameDoc;
            }
            lob.add(respuesta.Metadata.customValue.get(i));
        }
        
        string lista = JSON.serialize(lob);
        fieldDef = '{"Metadata":{"customValue":'+ lista +',"description":null,"masterLabel":"DocumentosRequeridos","sorted":false,"urls":null},"FullName":"DocumentosRequeridos"}';
        //system.debug('body : ' + fieldDef);
        
        if(Test.isRunningTest()) TestUpdateGlobalPicklistValue.prueba = 3;
        
        HttpRequest req = new HttpRequest();
        req.setBody(fieldDef);
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');      
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v41.0/tooling/sobjects/GlobalValueSet/' + System.Label.IdGlobalValuePicklist + '?_HttpMethod=PATCH');
        req.setMethod('POST');
        
        Http httpreq = new Http();
        HttpResponse res  = httpreq.send(req);
        while (res.getStatusCode() == 302) {
            req.setEndpoint(res.getHeader('Location'));
            res = new Http().send(req);
        }
        
        system.debug(res.getBody());
    }
    
    public class wrapper{
        @AuraEnabled public wrapperatt attributes;        
        @AuraEnabled public wrappermet Metadata;
    }
    
    public class wrapperatt{
        @AuraEnabled public String type;
        @AuraEnabled public string url;       
    }
    
    public class wrappermet{
        @AuraEnabled public List<datos> customValue;           
    }
    
    public class datos{
        @AuraEnabled public String color;
        @AuraEnabled public string description;
        @AuraEnabled public boolean isActive;
        @AuraEnabled public string label;    
        @AuraEnabled public string urls;      
        @AuraEnabled public string valueName;           
    }
}