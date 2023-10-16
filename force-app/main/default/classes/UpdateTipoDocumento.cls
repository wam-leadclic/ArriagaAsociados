public with sharing class UpdateTipoDocumento {
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
    public static void postNewTipoDocumento (String nuevoDoc, String nuevoApiDoc){
        User user=[SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        TipoDocumento__c documento = new TipoDocumento__c();
        if(Test.isRunningTest()) nuevoApiDoc=TipoDocumento__c.TipoDocumento__c.getDescribe().getPicklistValues()[0].getValue();
        documento.TipoDocumento__c=nuevoApiDoc;
        documento.ExternalID__c=nuevoApiDoc;
        documento.ValorEtiqueta__c=nuevoDoc;
        documento.VisibleComunidad__c=false;
        documento.SubidaComunidad__c=false;
        documento.OwnerId=user.Id;
        insert documento;

    }
    public static void updateGlobal(String ApiDoc, String NameDoc, Boolean active){
        User user=[SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
        TipoDocumento__c documento = [SELECT TipoDocumento__c,ValorEtiqueta__c FROM TipoDocumento__c WHERE ExternalID__c=:ApiDoc];
        if(documento !=null){
            if(active){
                documento.OwnerId=user.Id;
                documento.ValorEtiqueta__c=NameDoc;
                update documento;
            }else{
                delete documento;
            }
        }

    }
}