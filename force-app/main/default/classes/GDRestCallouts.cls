/*
@author LeadClic Solutions S.L.
@date 
@description Clase que contiene los métodos para llamar a la API del gestor documental
<pre>
FECHA             AUTOR           ACCION
07/05/2019      LCS - RMG         Modificación. Se añade el método que devuelve los tipos de documentos
28/05/2019      LCS - RDM         Modificación. Se añade llamadas a WS de preproducción y métodos de añadir y eliminar tipos de documento
02/07/2019      LCS - RDM         Modificación. Se añade llamadas a la clase encargad de actualizar el picklist global
26/03/2020      LCS - RAL         Modificación. Se modifica el envío de fecha de creación para mostrar solo la fecha en el componenete 
02/06/2022      LCS - DRU         Modificación. Añadido del método getDocumentFilteredList para filtrar documentos por tipo y nombre
*/

public without sharing class GDRestCallouts {

    /**
    * Método para obtener el token, devolvemos el token obtenido.
    *
    * @return Token
    */
    @AuraEnabled
    public static String getAuthToken() {        
        String token;//Token de respuesta
        try{
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            
            //Parámetros de llamada 
            String endPoint = datosIntegracion.Endpoint__c;
            String grant_type = datosIntegracion.granttype__c;
            String client_id = datosIntegracion.clientid__c;
            String client_secret = datosIntegracion.clientsecret__c;
            String resource = datosIntegracion.resource__c;
            
            
            //Componer la llamada al WS de Encamina
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');  
            request.setEndpoint(endPoint); 
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody('grant_type='+ grant_type + 
                            '&client_id='+ client_id + 
                            '&client_secret='+ client_secret +  
                            '&resource='+EncodingUtil.urlEncode(resource,'UTF-8') );
            
            
            //Respuesta obtenida por el WS de Encamina
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() != 200){
                token = null;
            }else{
                map<String,Object> mRespuesta = (map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                token = (String)mRespuesta.get('access_token');
            }
        } catch (Exception e) {
            token = null;
            //System.debug(e.getStackTraceString());
        }
        
        return token;       
    }

    
    /*
	
		--- Métodos relacionados con los tipos de documentos del gestor documental ---

	*/
    /**
    * Método encargado de llamar a la API del gestor documental para que nos devuelva los tipos de documentos existentes
    */
    @AuraEnabled
    public static getTypeDocumentListResponse getTypeDocumentList() {                
        getTypeDocumentListResponse response = new getTypeDocumentListResponse();    
        
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDocType__c;
            String token = getAuthToken();
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('GET');  
            wsRequest.setEndpoint(endPoint);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (200)
            if(wsResponse.getStatusCode() != 200) {
                response.status = false;
            } 
            else {
                //Si es correcto, guardamos el texto obtenido en las variables
                list<TypeDocument> wrapper = (list<TypeDocument>) JSON.deserialize(wsResponse.getBody(), list<TypeDocument>.class);    
                response.lItems = wrapper;    
                //System.debug('***wrapper*'+wrapper);       
            }
        } catch (Exception e) {
            response.status = false;
            //System.debug('***ERROR*'+e.getStackTraceString());
        }
        
        return response;
    }

    /**
    * Método encargado de llamar a la API del gestor documental para eliminar un tipo de documento
    */
    @AuraEnabled
    public static getTypeDocumentListResponse deleteTypeDocument(String id, Boolean refresco) {                
        getTypeDocumentListResponse response = new getTypeDocumentListResponse();    
        
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDocType__c;
            String x_user_id = datosIntegracion.usuarioAddDelete__c;
            String x_tenant_id = datosIntegracion.claveAddDelete__c;
            String token = getAuthToken();
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('DELETE');  
            wsRequest.setEndpoint(endPoint+'/'+id);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            wsRequest.setHeader('x-user-id', x_user_id);
            wsRequest.setHeader('x-tenant-id', x_tenant_id);
            
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (204 - No content)
                //System.debug(wsResponse.getBody());
            if(wsResponse.getStatusCode() != 204) {
                response.status = false;
            } 
            else {
                //Una vez eliminado correctamente y pedido un refresco desde el componente, obtenemos los datos
                if(refresco) response = getTypeDocumentList();       
                else response.status = true;
                
                //con la respuesta OK, actualizamos el picklistGlobal
                UpdateGlobalPicklistValue.updateGlobal(id, null, false);
                UpdateTipoDocumento.updateGlobal(id, null, false);
            }
        } catch (Exception e) {
            response.status = false;
           // System.debug('***ERROR*'+e.getStackTraceString());
        }
        
        return response;
    }

    /**
    * Método encargado de llamar a la API del gestor documental para crear un tipo de documento
    */
    @AuraEnabled
    public static getTypeDocumentListResponse setTypeDocument(String parentId, String nombreType, Boolean refresco) {                
        getTypeDocumentListResponse response = new getTypeDocumentListResponse();   
        GetDocumentListRequest reqBody = new GetDocumentListRequest();    
        
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDocType__c;
            String x_user_id = datosIntegracion.usuarioAddDelete__c;
            String x_tenant_id = datosIntegracion.claveAddDelete__c;
            String token = getAuthToken();
            
            if(parentId == null) parentId = '';
            
            //Monatmos el body utilizando la wrapper class y serializando los parametros
            reqBody.name = nombreType;
            reqBody.parentId = parentId;
            
            String body = JSON.serialize(reqBody);
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('POST');  
            wsRequest.setEndpoint(endPoint);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            wsRequest.setHeader('x-user-id', x_user_id);
            wsRequest.setHeader('x-tenant-id', x_tenant_id);
            wsRequest.setBody(body);
            
            //system.debug('Body : ' + body);
            //system.debug('REwyet : ' + wsRequest.getBody());
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (200)
            if((wsResponse.getStatusCode() != 200) && (wsResponse.getStatusCode() != 201)){
                response.status = false;
            } 
            else {
                //Una vez eliminado correctamente y pedido un refresco desde el componente, obtenemos los datos
                if(refresco) response = getTypeDocumentList();       
                else response.status = true;
                
                //Deserializamos la respuesta 
                TypeDocument respuesta = new TypeDocument();
                respuesta = (TypeDocument)JSON.deserialize(wsResponse.getBody(), TypeDocument.class);
                
                //con la respuesta OK, actualizamos el picklistGlobal
                UpdateGlobalPicklistValue.postNewGlobal(nombreType, respuesta.id);
                UpdateTipoDocumento.postNewTipoDocumento(nombreType,respuesta.id);
            }
        } catch (Exception e) {
            response.status = false;
            //System.debug('***ERROR*'+e.getStackTraceString());
        }
        
        return response;
    }

    /**
    * Método encargado de llamar a la API del gestor documental para actualizar el nombre de un tipo de documento
    */
    @AuraEnabled
    public static getTypeDocumentListResponse renameTypeDocument(String id, String newName, Boolean refresco) {                
        getTypeDocumentListResponse response = new getTypeDocumentListResponse();  
        GetDocumentListRequest reqBody = new GetDocumentListRequest();  
        
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDocType__c;
            String x_user_id = datosIntegracion.usuarioAddDelete__c;
            String x_tenant_id = datosIntegracion.claveAddDelete__c;
            String token = getAuthToken();

            //Monatmos el body utilizando la wrapper class y serializando los parametros
            reqBody.name = newName;
            
            String body = JSON.serialize(reqBody);
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('PUT'); 
            wsRequest.setEndpoint(endPoint+'/'+id);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            wsRequest.setHeader('x-user-id', x_user_id);
            wsRequest.setHeader('x-tenant-id', x_tenant_id);
            wsRequest.setBody(body);
            
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (200)
            if(wsResponse.getStatusCode() != 200) {
                response.status = false;
            } 
            else {
                //Una vez eliminado correctamente y pedido un refresco desde el componente, obtenemos los datos
                if(refresco) response = getTypeDocumentList();       
                else response.status = true;
                
                //con la respuesta OK, actualizamos el picklistGlobal
                UpdateGlobalPicklistValue.updateGlobal(id, newName, true);
                UpdateTipoDocumento.updateGlobal(id, newName, true);
            }
        } catch (Exception e) {
            response.status = false;
            //System.debug('***ERROR*'+e.getStackTraceString());
        }
        
        return response;
    }

    
    /*
	
		--- Métodos relacionados con los documentos del gestor documental ---

	*/
    /**
    * Método encargado de llamar a la API del gestor documental para obtener los documentos en funcion de los Ids de expediente
    */
    
    @AuraEnabled
    public static GetDocumentListResponse getDocumentList(List<String> lCustomer, List<String> lExpedients, Integer pageNumb, String filter, String filterMode, Boolean community) {

        getDocumentListResponse response = new getDocumentListResponse();
        GetDocumentListRequest reqBody = new GetDocumentListRequest();
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDoc__c;
            String token = getAuthToken();

            //Formar Url
            Integer limite = (Integer)datosIntegracion.LimiteDocs__c;
            Integer offSet = (pageNumb - 1) * limite;
            
                //String body = '{ "expedients":[' + idExp + '] }';

            // TO DO: Eliminar modo debug tras la realización de las UATs
            if(datosIntegracion.DebugMode__c){
                lExpedients = new List<String>();
                lExpedients.add('2');
                reqBody.expedients = new List<String>();
                reqBody.expedients = lExpedients;
            }else{
                //Monatmos el body utilizando la wrapper class y serializando los parametros
                if (!lCustomer.isEmpty()) {
                    reqBody.customers = new List<String>();
                    reqBody.customers = lCustomer;
                }
                if(!lExpedients.isEmpty()) {
                    reqBody.expedients = new List<String>();
                    reqBody.expedients = lExpedients;
                }
            }
            
            if(community!=null && community){
                reqBody.documentTypes= new List<GetDocumentListRequestDocument>();
                List<TipoDocumento__c> tipoDocumento= [SELECT ExternalID__c FROM TipoDocumento__c WHERE VisibleComunidad__c= true];
                for (TipoDocumento__c t : tipoDocumento){
                    GetDocumentListRequestDocument documentprueba =new GetDocumentListRequestDocument();
                    documentprueba.id= Integer.valueOf(t.ExternalID__c);                    
                    reqBody.documentTypes.add(documentprueba);
                }
            }
            //comprobamos que los parametros de filtro no vengan nulo para que la llamada al servicio no falle, si es asi, los inicializamos a vacío.
            if(String.isBlank(filter)) filter = '';
            if(String.isBlank(filterMode)) filterMode = '';

            // Serializamos como JSON la petición
            String reqBodyString = JSON.serialize(reqBody);
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('POST'); 
            wsRequest.setEndpoint(endPoint+'/search?offset='+offSet+'&limit='+limite+'&sortField='+filter+'&sortDirection='+filterMode);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            wsRequest.setBody(reqBodyString);
            
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (200)
            if(wsResponse.getStatusCode() != 200) {
                response.status = false;
                if(wsResponse.getStatusCode() == 404) response.statusCode = wsResponse.getStatusCode();
            } 
            else {
                //GetDocumentResponse wrapper = (GetDocumentResponse) JSON.deserialize(test, GetDocumentResponse.class);
                GetDocumentResponse wrapper = (GetDocumentResponse) JSON.deserialize(wsResponse.getBody(), GetDocumentResponse.class);
                for(DocumentItem item : wrapper.items){
                    if(item.created != null) item.created = item.created.left(10);
                }
                response.lItems = wrapper.items;
                //System.debug(wsResponse.getBody());
                response.offset = wrapper.offset;
                response.total = wrapper.total;
                response.totalPages = wrapper.totalPages;
                //System.debug('okay');
            }
        } catch (Exception e) {
            response.status = false;
            //System.debug(e.getStackTraceString());
        }

        return response;
    }


    
    /**
    * Método encargado de llamar a la API del gestor documental aplicandole los filtros por nombre y tipo de documento
    */
    
    @AuraEnabled
    public static GetDocumentListResponse getDocumentFilteredList(List<String> lCustomer, List<String> lExpedients, Integer pageNumb, String filter, String filterMode, Boolean community, String filterByType, String filterByName) {

        getDocumentListResponse response = new getDocumentListResponse();
        GetDocumentListRequest reqBody = new GetDocumentListRequest();
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDoc__c;
            String token = getAuthToken();

            //Formar Url
            Integer limite = 1000;
            Integer offSet = (pageNumb - 1) * limite;
            
                //String body = '{ "expedients":[' + idExp + '] }';

            // TO DO: Eliminar modo debug tras la realización de las UATs
            if(datosIntegracion.DebugMode__c){
                lExpedients = new List<String>();
                lExpedients.add('2');
                reqBody.expedients = new List<String>();
                reqBody.expedients = lExpedients;
            }else{
                //Monatmos el body utilizando la wrapper class y serializando los parametros
                if (!lCustomer.isEmpty()) {
                    reqBody.customers = new List<String>();
                    reqBody.customers = lCustomer;
                }
                if(!lExpedients.isEmpty()) {
                    reqBody.expedients = new List<String>();
                    reqBody.expedients = lExpedients;
                }
            }
            
            if(community!=null && community){
                reqBody.documentTypes= new List<GetDocumentListRequestDocument>();
                List<TipoDocumento__c> tipoDocumento= [SELECT ExternalID__c FROM TipoDocumento__c WHERE VisibleComunidad__c= true];
                for (TipoDocumento__c t : tipoDocumento){
                    GetDocumentListRequestDocument documentprueba =new GetDocumentListRequestDocument();
                    documentprueba.id= Integer.valueOf(t.ExternalID__c);                    
                    reqBody.documentTypes.add(documentprueba);
                }
            }
            //comprobamos que los parametros de filtro no vengan nulo para que la llamada al servicio no falle, si es asi, los inicializamos a vacío.
            if(String.isBlank(filter)) filter = '';
            if(String.isBlank(filterMode)) filterMode = '';

            // Serializamos como JSON la petición
            String reqBodyString = JSON.serialize(reqBody);
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('POST'); 
            wsRequest.setEndpoint(endPoint+'/search?offset='+offSet+'&limit='+limite+'&sortField='+filter+'&sortDirection='+filterMode);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            wsRequest.setBody(reqBodyString);

            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);

            //Comprobamos que la respuesta es correcta (200)
            if(wsResponse.getStatusCode() != 200) {

                response.status = false;
                if(wsResponse.getStatusCode() == 404) response.statusCode = wsResponse.getStatusCode();
            } 
            else {
                //GetDocumentResponse wrapper = (GetDocumentResponse) JSON.deserialize(test, GetDocumentResponse.class);
                GetDocumentResponse wrapper = (GetDocumentResponse) JSON.deserialize(wsResponse.getBody(), GetDocumentResponse.class);
                List<DocumentItem> filteredDocuments = new List<DocumentItem>();

                for(DocumentItem item : wrapper.items){
                    //if(item.created != null) item.created = item.created.left(10);


                    if(filterByName == '' && filterByType == ''){

                        filteredDocuments.add(item);
                        if(item.created != null) item.created = item.created.left(10);
                    }
                    else{

                        if ((filterByType != '' && filterByName != '' && filterByType == item.documentTypeId && item.fileName.containsIgnoreCase(filterByName)) ||
                            (filterByType != '' && filterByName == '' && filterByType == item.documentTypeId) ||
                            (filterByType == '' && filterByName != '' && item.fileName.containsIgnoreCase(filterByName))){

                            filteredDocuments.add(item);
                            if(item.created != null) item.created = item.created.left(10);
                        }
                        
                    }
                }
                response.lItems = filteredDocuments;
                //System.debug(wsResponse.getBody());
                response.offset = wrapper.offset;
                response.total = wrapper.total;
                response.totalPages = wrapper.totalPages;
                //System.debug('okay');
            }
        } catch (Exception e) {
            response.status = false;
            //System.debug(e.getStackTraceString());
        }

        return response;
    }

    
    /**
    * Método encargado de llamar a la API del gestor documental para descargar el documento indicado
    */
    @AuraEnabled
    public static GetDocumentListResponse downloadDocument(String idDoc) {

        getDocumentListResponse response = new getDocumentListResponse();
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDoc__c;
            String token = getAuthToken();
            
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('GET'); 
            wsRequest.setEndpoint(endPoint+ '/' + idDoc +'/content');
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            
            //System.debug('wsRequest' + wsRequest);
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (200)
            if(wsResponse.getStatusCode() != 200) {
                response.status = false;
            } 
            else {
                 response.status = true;      
            }
        } catch (Exception e) {
            response.status = false;
           // System.debug(e.getStackTraceString());
        }

        return response;
    }

    
    /**
    * Método encargado de llamar a la API del gestor documental para borrar el documento indicado
    */
    @AuraEnabled
    public static GetDocumentListResponse deleteDocument(String idDoc) {
        getDocumentListResponse response = new getDocumentListResponse();
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDoc__c;
            String token = getAuthToken();
            
            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('DELETE'); 
            wsRequest.setEndpoint(endPoint+ '/' + idDoc);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);

            
            //System.debug('wsRequest' + wsRequest);
            system.debug('WSRequest: '+wsRequest);
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            //Comprobamos que la respuesta es correcta (204 - No content)
            if(wsResponse.getStatusCode() != 204) {
                system.debug('Llamada web service KO');
                response.status = false;
            } 
            else {
                system.debug('Llamada web service OK');
                 response.status = true;      
            }
        } catch (Exception e) {
            system.debug('Entramos a catch');
            response.status = false;
            //System.debug(e.getStackTraceString());
        }
        system.debug('Response: '+response);
        return response;
    }

    
    /**
    * Método encargado de llamar a la API del gestor documental para editar el documento indicado
    */
    @AuraEnabled
    public static GetDocumentListResponse editDocument(String idDoc, String docType, String nombreDoc, String customers, String expedientes) {

        getDocumentListResponse response = new getDocumentListResponse();
        WrapperEditDocWithDocType reqBodydocType = new WrapperEditDocWithDocType();
        customers=null;
        //Documentos docId = new Documentos();
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDoc__c;
            String token = getAuthToken();
            String reqBodyString;
            List<String> lExpedientes = new List<String>();
            system.debug('expedientes '+expedientes);
            if(expedientes.contains(',')){
               system.debug('expedientes2 '+expedientes);
               lExpedientes.addAll( expedientes.split(','));
            }
            else{
                lExpedientes.add(expedientes);
            }
            List<String> lCustomers =  new List<String>();
            if(customers !=null){
              lCustomers = customers.split(',');
            }   
                        
            reqBodydocType.documentTypeId = docType;
            reqBodydocType.fileName = nombreDoc;
            reqBodydocType.expedients = lExpedientes;
            reqBodydocType.customers = lCustomers;
            // Serializamos como JSON la petición
            reqBodyString = JSON.serialize(reqBodydocType);
            

            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('PUT'); 
            wsRequest.setEndpoint(endPoint+ '/' + idDoc);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            wsRequest.setBody(reqBodyString);
            
            //System.debug('wsRequest' + wsRequest);
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            System.debug('wsResponse:' + wsResponse.getBody());
            System.debug('wsResponse:' + wsResponse.getStatusCode());
            System.debug('errors:' + wsResponse);
            if(wsResponse.getStatusCode() != 200) {
                response.status = false;
            } 
            else {
                response.status = true;      
            }
        } catch (Exception e) {
            response.status = false;
            System.debug(e.getStackTraceString());
        }

        return response;
    }
     /**
    * Método encargado de devolver el perfil del usuario actual
    */
    @AuraEnabled(cacheable = true)
    public static string getProfile(){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        system.debug('Profile Name'+profileName);
        return profileName;
    }
    @AuraEnabled
    public static void sendNotificationEmail(string archivo){
        try {
            
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            if(datosIntegracion.NotificationEmailAvailable__c){
                User user=[SELECT Contact.Account.Owner.Email, Contact.AccountId, Contact.Account.Name  FROM User WHERE Id = :UserInfo.getUserId() limit 1];
                //EmailTemplate template= [SELECT Id  FROM EmailTemplate WHERE DeveloperName='Subida_de_archivo_1640083934071' limit 1];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { user.Contact.Account.Owner.Email};
                system.debug(user.Contact.Account.Owner.Email);
                //message.setWhatId(user.Contact.AccountId);
                //message.setTemplateId(template.Id);
                TipoDocumento__C tipoDocumento= [SELECT ValorEtiqueta__c, ExternalID__c FROM TipoDocumento__c WHERE ExternalID__c =: archivo];
            
                String body =label.communityEmailMessageBody.replace('%Account%',user.Contact.Account.Name);
                body =body.replace('%file%',tipoDocumento.ValorEtiqueta__c);
                message.setSubject(label.communityEmailMessageSubject);
                message.setHtmlBody(body);
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                if (results[0].success) 
                {
                    System.debug('The email was sent successfully.');
                } else 
                {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * Método encargado de llamar a la API del gestor documental para obtener los datos de un documento
    */
    @AuraEnabled
    public static WrappergetDataDocument getDocumentData(String idDoc) {
        WrappergetDataDocument response = new WrappergetDataDocument();
        //Documentos docId = new Documentos();
        try {
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            //Endpoint
            String endPoint = datosIntegracion.EndpointDoc__c;
            String token = getAuthToken();
            

            //Componemos la variable que realiza la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('GET'); 
            wsRequest.setEndpoint(endPoint+ '/' + idDoc);
            wsRequest.setHeader('Content-Type', 'application/json');
            wsRequest.setHeader('Authorization', 'Bearer ' + token);
            
            //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS de Encamina
            HttpResponse wsResponse = http.send(wsRequest);
            system.debug(wsResponse.getStatusCode());
            if(wsResponse.getStatusCode() != 200) {
                response.status = false;
            } 
            else {
                WrappergetDataDocument wrapper = (WrappergetDataDocument) JSON.deserialize(wsResponse.getBody(), WrappergetDataDocument.class);
                    
                response.documentTypeId = wrapper.documentTypeId;
                response.fileName = wrapper.fileName;
                response.customers = wrapper.customers;
                response.expedients = wrapper.expedients;
                response.status = true;     
            }
        } catch (Exception e) {
            response.status = false;
            //System.debug(e.getStackTraceString());
        }

        return response;
    }
    @AuraEnabled(cacheable=true)
    public static RecordInformation getRecordCommunity(String recordId){
            RecordInformation recordInformation= new RecordInformation();
            List<String> expedientes =new List<String>(); 
            Account account;
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            recordInformation.gdURLDocument = datosIntegracion.EndpointDoc__c;

            if(String.isEmpty(recordId)){
                //Obtener todos los documentos subidos.
                User user=[SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() limit 1];
                Contact Contact= [SELECT Id, AccountId FROM Contact WHERE Id = :user.ContactId limit 1];
                account=[SELECT IdClienteMinerva__c FROM  Account WHERE Id = :Contact.AccountId];
                List<Opportunity> oportunidades=[SELECT NumeroExpediente__c,StageName FROM Opportunity WHERE AccountId=:Contact.AccountId];
                recordInformation.oportunityActive=true;
                for(Opportunity oportunidad : oportunidades){
                    if(!oportunidad.StageName.toUppercase().contains('CERRAD')){
                        recordInformation.oportunityActive=false;
                        break;
                    }
                }                
                recordInformation.idClienteMinerva= account.IdClienteMinerva__c;
                recordInformation.idExpedienteMinerva= null;
                return recordInformation;
            }        
            // Cuando se accede en un expediente
            Contract contract =[SELECT AccountId,IdExpediente__c,Oportunidad__c FROM Contract WHERE Id=:recordId];
            account=[SELECT IdClienteMinerva__c FROM  Account WHERE Id = :contract.AccountId];
            system.debug(contract.Oportunidad__c);
            Opportunity oportunidades=[SELECT NumeroExpediente__c,StageName FROM Opportunity WHERE id= :contract.Oportunidad__c];
            //expedientes.add('20010481859');//prueba
            expedientes.add(contract.IdExpediente__c);
            recordInformation.idClienteMinerva= account.IdClienteMinerva__c;
            recordInformation.idExpedienteMinerva=expedientes;
            recordInformation.oportunityActive=false;           

            return recordInformation;       
    }

    public class RecordInformation{
        @AuraEnabled public String idClienteMinerva='';
        @AuraEnabled public List<String> idExpedienteMinerva;
        @AuraEnabled public String gdURLDocument;
        @AuraEnabled public Boolean oportunityActive;
        }

    public class GetDocumentListRequest {
        private List<String> customers;
        private List<String> expedients;
        private List<GetDocumentListRequestDocument> documentTypes;
        private String name;
        private String parentId;
    }

    public class GetDocumentListRequestDocument{
        public Integer id;
        public String name;
    }
    public class GetDocumentResponse {
        @AuraEnabled public Integer offset;
        @AuraEnabled public Integer limite;
        @AuraEnabled public Integer total;
        @AuraEnabled public Integer totalPages;
        @AuraEnabled public List<DocumentItem> items;
    }


    public class getDocumentListResponse {

        @AuraEnabled public Boolean status = true;
        @AuraEnabled public Integer statusCode;
        @AuraEnabled public String errorMsg = '';
        @AuraEnabled public Integer offset;
        @AuraEnabled public Integer total;
        @AuraEnabled public Integer totalPages;
        @AuraEnabled public List<DocumentItem> lItems;

    }

    public class DocumentItem {

        @AuraEnabled public String documentId;
        @AuraEnabled public String id;
        @AuraEnabled public String documentType;
        @AuraEnabled public String documentTypeId;
        @AuraEnabled public String fileName;
        @AuraEnabled public Integer size;
        @AuraEnabled public String createdUser;
        @AuraEnabled public String created;
    }

    //Wrapper class que se devuelve al componente con los tipos de documentos
    public class getTypeDocumentListResponse {
        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String errorMsg = '';
        @AuraEnabled public List<TypeDocument> lItems;

    }
    
    //Wrapper class para guardar la información de los tipos de documentos del gestor documental
    public class TypeDocument{
        @AuraEnabled public String name;
        @AuraEnabled public String parentId;
        @AuraEnabled public String id;
        @AuraEnabled public TypeDocumentParent parent;
    }
    
    //Wrapper class para guardar la información de los tipos de documentos padres del gestor documental
    public class TypeDocumentParent{
        @AuraEnabled public String name;
        @AuraEnabled public String id;
    }

    //Wrapper del body para la edición de documentos
    public class WrapperEditDocWithDocType{
        @AuraEnabled public String documentTypeId;
        @AuraEnabled public String fileName;
        @AuraEnabled public List<String> customers;   
        @AuraEnabled public List<String> expedients;      
    }

    //Wrapper del body para la edición de documentos
    public class WrapperEditDocWithoutDocType{
        @AuraEnabled public String fileName;
        @AuraEnabled public List<String> customers;        
    }
    
    //Wrapper para la recuperación de datos de un documento
    public class WrappergetDataDocument{
        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String documentTypeId;
        @AuraEnabled public String fileName;
        @AuraEnabled public List<String> customers;   
        @AuraEnabled public List<String> expedients;      
    }

}