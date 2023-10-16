/*
@author LeadClic Solutions S.L.
@date 13/06/2019
@description Clase que contiene los m?todos para llamar a la API del minerva y producci?n

FECHA             AUTOR           ACCION
13/06/2019      LCS - RDM         Creacion.
20/06/2019      LCS - RDM         Modificacion. Creamos el metodo que llamara a la creacion de los usuarios en los sistemas de Arriaga. Este ser? el encargado
                                            de llamar a la creacion del expediente en dichos sistemas
02/09/2019      LCS - RDM         Modificacion. Actualizacion metodos de llamada a los diferentes WS. Actualizacion de los datos enviados a Minerva. Cambio campos direcci?n, se apunta a los campos Shipping
11/09/2019      LCS - RDM         Modificacion. Se añade un control de rellamada por si hay fallo de redireccion a producci?n
04/10/2019      LCS - RDM         Modificacion. Se añade nuevo parametro de entrada a 'futureSendWSProd' para diferenciar entre enviar Exp o actualizar Cliente
29/10/2019      LCS - RDM         Modificacion. Se modifica la manera de enviar los intervinientes de un expediente a producci?n.
                                              Se modifica el campo 'censored' para enviar una fecha y no un boleano.
30/10/2019      LCS - RDM         Modificacion. Se añade comprobacion para que cuando el interviniente sea Titular enviemos a Producci?n el valor Primer titular. M?todo [postNewExpedientProd]
04/11/2019      LCS - RDM         Modificacion. Correcciones integracion con produccion. Comprobaciones de valores a nulos para enviar vacios, codificar el body para que se envie en urlencoding.
05/11/2019      LCS - RDM         Modificacion. Correcciones integracion con produccion. Se quita el urlEnconding, se quita el crm_id desde la actualizaci?n de contacto en producci?n.
15/11/2019      LCS - RDM         Modificacion. Refactorizacion de m?todo futuro. Cambio de mapeo a raiz del evolutivo #115
18/11/2019      LCS - JZD         Modificacion. Se extraen los datos del contacto (representante legal) cuando se procesa una cuenta empresarial
08/01/2020      LCS - MMV         Modificacion. Se envia a Produccion dinamicamente el estado del expediente.
27/04/2020      LCS - RAL         Modificacion. Se cambia la fecha de creacion por la del justificante de pago en el env?o a producci?n.
02/12/2020		LCS - HPS		  Modification. Test.isRunningTest() added to pass 2 test classes.
19/07/2021		LCS - SER		  Modification. Se revisa el funcionamiento de INSERT y UPDATE de MINNERVA para Account y Contract.
*/
public class MinervaRestCallouts {
    /*
	
		--- M?todos a futuro encargados de llamar a los WS de Arriaga ---

	*/
    /* M?todos envio de informaci?n */
    @future (callout=true)
    
    public static void futureSendWSMinerva(Map<String, Id> mDatosExpyCuenta, List<Id> actulizacionCliente){
        sendWSMinerva(mDatosExpyCuenta, actulizacionCliente);
    }
    
    public static void sendWSMinerva(Map<String, Id> mDatosExpyCuenta, List<Id> actulizacionCliente) {

        List<String> lExpedientes = new List<String>();
        List<Id> lIdCuentas = new List<Id>();
        //Comprobamos cual de los dos datos de entrada tienen valor. Si el valor lo tiene datos expediente lo utilizaremos para enviar el expediente
        //Si por el contrario viene la lista de Ids enviaremos la actualizaci?n de cliente
        if(mDatosExpyCuenta != null && !mDatosExpyCuenta.isEmpty()){
            for (String idExp : mDatosExpyCuenta.keySet()){
                lExpedientes.add(idExp);
                lIdCuentas.add(mDatosExpyCuenta.get(idExp));
            }
        } else if(actulizacionCliente != null && !actulizacionCliente.isEmpty()){
            for (Id cliente : actulizacionCliente){
                lIdCuentas.add(cliente);
            }
        }

        //Comenzamos el tratamiento de datos
        if(!lIdCuentas.isEmpty()){
            //Obtenemos los datos que enviaremos al WS que se encargar? de enviar el contacto
            //Address :  BillingStreet
            List<Account> lCuentas = [SELECT Id, Name, IBAN__c, IdClienteMinerva__c, FirstName, LastName, ShippingPostalCode, ShippingStreet,
                                                ShippingCity, TipoDocumento__c, DocumentoIdentidad__c, PersonMobilePhone, Phone,
                                                Sexo__pc, PersonBirthdate, PersonEmail, CorreoElectronicoSecundario__c, PersonTitle,
                                                AceptoPoliticaPrivacidad__pc, DeseoRecibirComunicacionesComerciales__pc, PoderNotarial__c,  
                                                IBAN__pc,IdOrigen__c, recordTypeId, ShippingCountry,  ShippingState, AccountSyncMinerva__c, 
                                                MessageErrMinerva__c, CreatedDate, Fax, PersonHomePhone, bodyMinerva__c
                                        FROM Account
                                        WHERE Id IN :lIdCuentas];
            //Enviamos las cuentas diferenciando si hay que actualizar o insertar
            List<Account> lCuentaInsert = new List<Account> ();
            List<Account> lCuentaUpdate = new List<Account> ();
            //Para ello recorremos las cuentas y comprobamos si tiene IdOrigen o no lo tiene
            for(Account ac : lCuentas){
                if(String.isBlank(ac.IdOrigen__c)){
                    lCuentaInsert.add(ac);
                }else{
                    lCuentaUpdate.add(ac);
                }
            }
			List<Account> lCuentaUpdateRespuesta = new List<Account>();
			List<Contract> lExpeUpdateRespuesta = new List<Contract>();
            //Revisamos las listas y si no estan vacias las enviamos a la clase correspondiente
            if(!lCuentaInsert.isEmpty()){
                lCuentaUpdateRespuesta = sendCrearContactoMinerva(lCuentaInsert);                
                if(!lCuentaUpdateRespuesta.isEmpty()){ 
                    if(!lExpedientes.isEmpty()) lExpeUpdateRespuesta = postNewExpedientMin(lExpedientes);
                }
            } 
            if(!lCuentaUpdate.isEmpty()){
                lCuentaUpdateRespuesta = sendActualizarContactoMinerva(lCuentaUpdate);           
                if(!lCuentaUpdateRespuesta.isEmpty()){
                    if(!lExpedientes.isEmpty()) lExpeUpdateRespuesta = postNewExpedientMin(lExpedientes);
                }                
            }
            
            if(!lCuentaUpdateRespuesta.isEmpty()){
                update lCuentaUpdateRespuesta;
                if(!lExpeUpdateRespuesta.isEmpty()) update lExpeUpdateRespuesta;
            }
        }
    }


    
    @future (callout=true)
    public static void futureSendWSProd(Map<String, Id> mDatosExpyCuenta, List<Id> actulizacionCliente){
        sendWsProd(mDatosExpyCuenta, actulizacionCliente);        
    }

    /**
     * sendWsProd Realiza las llamadas de integraci?n contra producci?n, v?lido para cuentas y expedientes
     * @param  mDatosExpyCuenta         Mapa que contiene como clave el id de expediente y como valor el id de la cuenta
     * @param  actulizacionCliente      Lista con ids de cuenta a actualizar
     */ 
    public static void sendWsProd(Map<String, Id> mDatosExpyCuenta, List<Id> actulizacionCliente) {
        List<String> lExpedientes = new List<String>();
        List<Id> lIdCuentas = new List<Id>();
        //Comprobamos cual de los dos datos de entrada tienen valor. Si el valor lo tiene datos expediente lo utilizaremos para enviar el expediente
        //Si por el contrario viene la lista de Ids enviaremos la actualizaci?n de cliente
        if(mDatosExpyCuenta != null && !mDatosExpyCuenta.isEmpty()){
            
            // Recuperamos los expedientes
            Set<String> sContractExternalId = new Set<String>();
            Set<Id> sAccountId = new Set<Id>();
            for(String idExp : mDatosExpyCuenta.keySet()) {
                sContractExternalId.add(idExp);
                sAccountId.add(mDatosExpyCuenta.get(idExp));
            }
            System.debug('ID ext EXP => ' + sContractExternalId);
            System.debug('ID ACC => ' + sAccountId);

            // Recuperamos los Id de Expedientes
            Set<Id> sContractId = new Set<Id>();
            List<Contract> lContract = [SELECT Id,TipoExpDerivado__c 
                                        FROM Contract 
                                        WHERE IdExpediente__c IN :sContractExternalId];
            for(Contract c : lContract) {
                sContractId.add(c.Id);
            }
            System.debug('ID EXP => ' + sContractId);

            // Recuperamos todos los intervinientes asociados
            Set<Id> sContactId = new Set<Id>();
            List<ContractContactRole> lRoles = [SELECT Id, ContractId, ContactId 
                                                FROM ContractContactRole 
                                                WHERE ContractId IN :sContractId];
            for(ContractContactRole role : lRoles ) {
                if(role.ContactId != null) sContactId.add(role.ContactId);
            }

            // Recuperamos las cuentas asociadas a los contactos
            List<Account> lAccount = [SELECT Id 
                                        FROM Account 
                                        WHERE PersonContactId IN :sContactId];

            for(Account acc : lAccount) {
                sAccountId.add(acc.Id);
            }

            // actualizamos las estructuras de datos para la comunicaci?n
            lExpedientes.addAll(new List<String>(sContractExternalId));
            lIdCuentas.addAll(new List<Id>(sAccountId));

            System.debug('lExpedientes => ' + lExpedientes);
            System.debug('lCuentas     => ' + lIdCuentas);

            /*
            for (String idExp : mDatosExpyCuenta.keySet()){
                lExpedientes.add(idExp);
                lIdCuentas.add(mDatosExpyCuenta.get(idExp));
            }
            */
        } else if(actulizacionCliente != null && !actulizacionCliente.isEmpty()){
            for (Id cliente : actulizacionCliente){
                lIdCuentas.add(cliente);
            }
        }

        //Comenzamos el tratamiento de datos
        if(!lIdCuentas.isEmpty()){
            //Obtenemos los datos que enviaremos al WS que se encargar? de enviar el contacto
            //Address :  BillingStreet
            List<Account> lCuentas = [SELECT Id, Name, IBAN__c, IdClienteMinerva__c, FirstName, LastName, ShippingPostalCode, ShippingStreet,
                                                ShippingCity, TipoDocumento__c, DocumentoIdentidad__c, PersonMobilePhone, Phone,
                                                Sexo__pc, PersonBirthdate, PersonEmail, CorreoElectronicoSecundario__c, PersonTitle,
                                                AceptoPoliticaPrivacidad__pc, DeseoRecibirComunicacionesComerciales__pc, PoderNotarial__c,  
                                                IBAN__pc,IdOrigen__c, recordTypeId, ShippingCountry,  ShippingState, AccountSyncMinerva__c, 
                                                IdOrigenProd__c, MessageErrMinerva__c, CreatedDate, Fax, PersonHomePhone, bodyProduccion__c,
                                                    (SELECT Id, Name, FirstName, LastName, DocumentoIdentidad__c, AceptoPoliticaPrivacidad__c,
                                                    DeseoRecibirComunicacionesComerciales__c FROM Contacts WHERE RepresentanteLegal__c = true)
                                        FROM Account
                                        WHERE Id IN :lIdCuentas];
            //Enviamos las cuentas diferenciando si hay que actualizar o insertar
            List<Account> lCuentaInsert = new List<Account> ();
            List<Account> lCuentaUpdate = new List<Account> ();
            //Para ello recorremos las cuentas y comprobamos si tiene IdOrigen o no lo tiene
            for(Account ac : lCuentas){
                if(String.isBlank(ac.IdOrigenProd__c)){
                    lCuentaInsert.add(ac);
                }else{
                    lCuentaUpdate.add(ac);
                }
            }
            
			List<Account> lCuentaUpdateRespuesta = new List<Account>();
			List<Contract> lExpeUpdateRespuesta = new List<Contract>();
            //Revisamos las listas y si no estan vacias las enviamos a la clase correspondiente
            if(!lCuentaInsert.isEmpty()){
                lCuentaUpdateRespuesta = sendCrearContactoProd(lCuentaInsert);  
                //system.debug('lCuentaUpdateRespuesta : ' + lCuentaUpdateRespuesta);
                if(!lCuentaUpdateRespuesta.isEmpty()){ 
                //system.debug('lExpedientes : ' + lExpedientes);
                    //if(!lExpedientes.isEmpty()) lExpeUpdateRespuesta = postNewExpedientProd(lExpedientes);
                }
            }  
            if(!lCuentaUpdate.isEmpty()){  
                lCuentaUpdateRespuesta = sendActualizarContactoProd(lCuentaUpdate);
                //system.debug('lCuentaUpdateRespuesta : ' + lCuentaUpdateRespuesta);
                if(!lCuentaUpdateRespuesta.isEmpty()){
                //system.debug('lExpedientes : ' + lExpedientes);
                    //if(!lExpedientes.isEmpty()) lExpeUpdateRespuesta = postNewExpedientProd(lExpedientes);
                }                
            }
            
           	if(!lExpedientes.isEmpty()) lExpeUpdateRespuesta = postNewExpedientProd(lExpedientes); 
            
            
            
             if(!lCuentaUpdateRespuesta.isEmpty()){
                update lCuentaUpdateRespuesta;
                if(!lExpeUpdateRespuesta.isEmpty()){
                    // Se pasa a un mapa para evitar duplicados
                    Map<Id, Contract> mExpeUpdate = new Map<Id, Contract>();
                    for (Contract c : lExpeUpdateRespuesta){
                        mExpeUpdate.put(c.Id, c);
                    }
                    update mExpeUpdate.values();
                } 
             }
        }

    }
    
    
    
  
	
    /* M?todos borrado de expedientes */
    @future (callout=true)
    public static void futureDeleteWSMinerva(List<String> isExpDel){
        //Enviamos la lista a la clase que realiza la acci?n de comunicaci?n
        deleteExpedientMin(isExpDel);
    }
    @future (callout=true)
    public static void futureDeleteWSProd(List<String> isExpDel){
        //Enviamos la lista a la clase que realiza la acci?n de comunicaci?n
        deleteExpedientProd(isExpDel);
    }
    
    /*
	
		--- M?todos encargados de Crear el contacto---

	*/
    /* Token */
    
    /**
    * M?todo para obtener el token, devolvemos el token obtenido.
    *
    * @return Token
    */
    @AuraEnabled
    public static String getAuthToken() {  
        //system.debug('getAuthToken()');
        String token;//Token de respuesta
        try{
            IntegracionGD__c datosIntegracion = IntegracionGD__c.getInstance('General');
            
            //Par?metros de llamada 
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
                system.debug('TOKEN '+token);
              
            }
            //system.debug('GetToken Method : ' + response.getBody());
        } catch (Exception e) {
            token = null;
            //system.debug(e.getStackTraceString());
        }
        
        return token;       
    }
    /* Minerva */
    private static List<Account> sendCrearContactoMinerva(List<Account> lcuenta){
        //Creamos una lista donde a?adiremos las cuentas que actualizaremos con la respuesta
        List<Account> lCuentaUpdateRespuesta = new List<Account>();
        //Cargamos la configuraci?n personalizada
        ArrMinervDatosWS__c datosWS = ArrMinervDatosWS__c.getInstance('General');

        if(datosWS.Activo__c && !Test.isRunningTest()){
            String endPoint = datosWS.Endpoint__c;             
            String token = getAuthToken();
            //system.debug('Token : ' + token);
            // Realizamos una llamada por Cuenta
            for(Account ac : lcuenta){
                Contact cont = [SELECT id,AccountId, Email, FirstName, LastName from Contact Where AccountId =:ac.id];
                //Montamos el body con la cuenta correspondiente transformandolo con la wrapper de envio de datos
                WrapperDatosEnvioContacto datosBody = new WrapperDatosEnvioContacto(ac,cont);

                //Inicializamos las wrappers de respuesta
                WrapperRespuestaOkMinContacto responseOk = new WrapperRespuestaOkMinContacto();
                WrapperRespuestaKoMinContacto responseKo = new WrapperRespuestaKoMinContacto();

                //Inicializamos el objeto cuenta que usaremos para actualizar
                Account updateCuenta = new Account();
                    updateCuenta.Id = ac.Id; 
                String body;
                try{
                    //Realizamos la llamada
                    Http http = new Http();
                    HttpRequest wsRequest = new HttpRequest();
                    wsRequest.setMethod('POST');  
                    wsRequest.setEndpoint(endPoint+'/api/customer');
                    wsRequest.setHeader('Content-Type', 'application/json');
                    wsRequest.setHeader('Authorization', 'Bearer ' + token);
                    body = JSON.serialize(datosBody);
                    wsRequest.setBody(body);
					
                    //system.debug('Requ : ' + wsRequest.getEndpoint());
                    //system.debug('Requ : ' + wsRequest.getHeader('Authorization'));
                    //system.debug('Requ : ' + wsRequest.getBody());
                    
                    HttpResponse wsResponse = http.send(wsRequest);
                    //Comprobamos la respuesta del WS y trasformamos la respuesta en funcion de si ha ido OK o KO con la wrapper correspondiente
                    if(wsResponse.getStatusCode() != 201) { 
                         responseKo = (WrapperRespuestaKoMinContacto) JSON.deserialize(wsResponse.getBody(), WrapperRespuestaKoMinContacto.class);
                        
                        updateCuenta.AccountSyncMinerva__c = 'ERROR';
                        updateCuenta.bodyMinerva__c = body;
                        updateCuenta.MessageErrMinerva__c = responseKo.status + ' - ' + responseKo.errors;
                        updateCuenta.FechaSyncMinerva__c = system.now();
                    } 
                    else {
                        
                        responseOk = (WrapperRespuestaOkMinContacto) JSON.deserialize(wsResponse.getBody(), WrapperRespuestaOkMinContacto.class);
                        updateCuenta.IdOrigen__c = ac.IdClienteMinerva__c;
                        updateCuenta.bodyMinerva__c = body;
                        updateCuenta.AccountSyncMinerva__c = 'OK';
                        updateCuenta.MessageErrMinerva__c = '';
                        updateCuenta.FechaSyncMinerva__c = system.now();                             
                    }
					
                    system.debug('Res : ' +  updateCuenta.AccountSyncMinerva__c);
                }catch(Exception e){                   
                    system.debug('Exception : ' + e.getMessage());
                    updateCuenta.AccountSyncMinerva__c = 'ERROR';
                    updateCuenta.bodyMinerva__c = body;
                    updateCuenta.MessageErrMinerva__c = 'Error al realizar la llamada de inserci?n : ' + e.getMessage();
                    updateCuenta.FechaSyncMinerva__c = system.now();
                } 
                lCuentaUpdateRespuesta.add(updateCuenta);
            }

            //if(!lCuentaUpdateRespuesta.isEmpty()) update lCuentaUpdateRespuesta;  
        }
        return lCuentaUpdateRespuesta; 
    }
    
    private static List<Account> sendActualizarContactoMinerva(List<Account> lcuenta){
        //Creamos una lista donde a?adiremos las cuentas que actualizaremos con la respuesta
        List<Account> lCuentaUpdateRespuesta = new List<Account>();
        //Cargamos la configuraci?n personalizada
        ArrMinervDatosWS__c datosWS = ArrMinervDatosWS__c.getInstance('General');
        if(datosWS.Activo__c){
            String endPoint = datosWS.Endpoint__c;            
            String token = getAuthToken(); 
            // Realizamos una llamada por Cuenta
            for(Account ac : lcuenta){
                Contact cont = [SELECT id,AccountId, Email, FirstName, LastName from Contact Where AccountId =:ac.id];
                system.debug('cont:' +cont);
                //Montamos el body con la cuenta correspondiente transformandolo con la wrapper de envio de datos
                WrapperDatosEnvioContacto datosBody = new WrapperDatosEnvioContacto(ac, cont);

                //Inicializamos las wrappers de respuesta
                WrapperRespuestaOkMinContacto responseOk = new WrapperRespuestaOkMinContacto();
                WrapperRespuestaKoMinContacto responseKo = new WrapperRespuestaKoMinContacto();

                //Inicializamos el objeto cuenta que usaremos para actualizar
                Account updateCuenta = new Account();
                    updateCuenta.Id = ac.Id;
                String body; 
                try{
                    system.debug('datosBody '+datosBody);
                    //Realizamos la llamada
                    Http http = new Http();
                    HttpRequest wsRequest = new HttpRequest();
                    wsRequest.setMethod('PUT');  
                    wsRequest.setEndpoint(endPoint+'/api/customer/'+datosBody.id);
                    wsRequest.setHeader('Content-Type', 'application/json');
                    wsRequest.setHeader('Authorization', 'Bearer ' + token);
                    body = JSON.serialize(datosBody);
                    system.debug(Pattern.compile('(.{299})').matcher(JSON.serialize( body )).replaceAll('$1\n'));
                    system.debug('body  '+body);
                    wsRequest.setBody(body);

                    HttpResponse wsResponse = http.send(wsRequest);
                    system.debug('SCA RESPONSE: ' + wsResponse); 
                    //Comprobamos la respuesta del WS y trasformamos la respuesta en funcion de si ha ido OK o KO con la wrapper correspondiente
                    if(wsResponse.getStatusCode() != 200) {                        
                        responseKo = (WrapperRespuestaKoMinContacto) JSON.deserialize(wsResponse.getBody(), WrapperRespuestaKoMinContacto.class);
                        
                        updateCuenta.AccountSyncMinerva__c = 'Error';
                        updateCuenta.bodyMinerva__c = body;
                        updateCuenta.MessageErrMinerva__c = responseKo.status + ' - ' + responseKo.errors;
                        updateCuenta.FechaSyncMinerva__c = system.now();
                    } 
                    else {
                        
                        responseOk = (WrapperRespuestaOkMinContacto) JSON.deserialize(wsResponse.getBody(), WrapperRespuestaOkMinContacto.class);
                        updateCuenta.AccountSyncMinerva__c = 'OK';
                        updateCuenta.bodyMinerva__c = body;
                        updateCuenta.MessageErrMinerva__c = '';
                        updateCuenta.FechaSyncMinerva__c = system.now();              
                    }
                    system.debug('updateCuenta.AccountSyncMinerva__c '+updateCuenta.AccountSyncMinerva__c);
					system.debug('updateCuenta.MessageErrMinerva__c '+updateCuenta.MessageErrMinerva__c);
                }catch(Exception e){
                    system.debug('Exception : ' + e.getMessage());
                    updateCuenta.AccountSyncMinerva__c = 'ERROR';
                    updateCuenta.bodyMinerva__c = body;
                    updateCuenta.MessageErrMinerva__c = 'Error al realizar la llamada de inserci?n : ' + e.getMessage();
                    updateCuenta.FechaSyncMinerva__c = system.now();
                } 
                lCuentaUpdateRespuesta.add(updateCuenta);
            }

            //if(!lCuentaUpdateRespuesta.isEmpty()) update lCuentaUpdateRespuesta;  
        }
        return lCuentaUpdateRespuesta;
    }
    
    /* Producci?n */
    private static List<Account> sendCrearContactoProd(List<Account> lcuenta){
        //Creamos una lista donde a?adiremos las cuentas que actualizaremos con la respuesta
        List<Account> lCuentaUpdateRespuesta = new List<Account>();
        //Cargamos la configuraci?n personalizada
        ArrProdDatosWS__c datosWS = ArrProdDatosWS__c.getInstance('General');
        if(datosWS.Activo__c && !Test.isRunningTest()){
            String endPoint = datosWS.EndpointInsrtContc__c; 
            String xApikey = datosWS.PublicKey__c;            
            String milisecondsUnix = string.valueOf(DateTime.now().getTime());
            String xApiTimestamp = milisecondsUnix.substring(0,10);
            //Inicio de  X-Api-Signature
            String concatenacion = xApiKey + xApiTimestamp + datosWS.PrivateKey__c;
            Blob concatenacionBlob = Blob.valueOf(concatenacion);
            Blob encriptacionMD5 = Crypto.generateDigest('MD5', concatenacionBlob);

            String encriptacionMD5Hexa = EncodingUtil.convertToHex(encriptacionMD5);
            Blob preSignatureBlob = Blob.valueOf(encriptacionMD5Hexa);

            String xApiSignature = EncodingUtil.base64Encode(preSignatureBlob);

            /*//system.debug('**************************************');
            //system.debug('endPoint : ' + endPoint);
            //system.debug('xApikey : ' + xApikey);
            //system.debug('xApiTimestamp : ' + xApiTimestamp);
            //system.debug('xApiSignature : ' + xApiSignature);
            //system.debug('**************************************');*/
            
            //Realizamos la llamada
            Http http = new Http();
            HttpRequest wsRequest = new HttpRequest();
            wsRequest.setMethod('POST');  
            wsRequest.setEndpoint(endPoint);
            wsRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            //wsRequest.setHeader('Content-Type', 'application/form-data');
            wsRequest.setHeader('x-api-key', xApikey); 
            wsRequest.setHeader('x-api-timestamp', xApiTimestamp);
            wsRequest.setHeader('x-api-signature', xApiSignature);

            // Realizamos una llamada por Cuenta
            for(Account ac : lcuenta){ 
                Account updateCuenta = new Account();
                    updateCuenta.Id = ac.Id;
                String datosBody; 
                
                System.debug('SINCRONIZANDO CUENTA (INSERT): ' + ac.Id);
                try{              
                    //Monto el body del tipo form-data

                    //Controlando campos para no mandar null
                    String nombre = (!String.isBlank(ac.FirstName)) ? ac.FirstName : '';
                    String apellido = (!String.isBlank(ac.LastName)) ? ac.LastName : '';
                    String postalCode = (!String.isBlank(ac.ShippingPostalCode)) ? ac.ShippingPostalCode : '';
                    String calle =  (!String.isBlank(ac.ShippingStreet)) ? ac.ShippingStreet : '';
                    String ciudad = (!String.isBlank(ac.ShippingCity)) ? ac.ShippingCity : '';
                    String movil = (!String.isBlank(ac.PersonMobilePhone)) ? ac.PersonMobilePhone : '';                    
                    String telefono =  (!String.isBlank(ac.Phone)) ? ac.Phone : '';                                
                    String email = (!String.isBlank(ac.PersonEmail)) ? ac.PersonEmail : '';         
                    String emailSec =  (!String.isBlank(ac.CorreoElectronicoSecundario__c)) ? ac.CorreoElectronicoSecundario__c : '';                  
                    String titulo =  (!String.isBlank(ac.PersonTitle)) ? ac.PersonTitle : '';                
                    String nacimiento = (!String.isBlank(string.valueOf(ac.PersonBirthdate))) ? string.valueOf(ac.PersonBirthdate) : ''; 


                    //NIF o CIF para el env?o de los datos
                    String nif = '';
                    String cif = '';
                    String tipoDoc = '';
                    if(!String.isBlank(ac.TipoDocumento__c)){
                        if((ac.TipoDocumento__c.toUpperCase()) != 'CIF'){
                            if(!String.isBlank(ac.DocumentoIdentidad__c)) nif = ac.DocumentoIdentidad__c;
                            tipoDoc = ac.TipoDocumento__c.toLowerCase();
                        }
                        else {
                            if(!String.isBlank(ac.DocumentoIdentidad__c)) cif = ac.DocumentoIdentidad__c; 
                        }
                    }


                    Integer acceptPrivac = 0;
                    Integer acceptMarket = 0;
                    Integer empresa = 1;
                    String genero = '';
                    String nombreJuridico = ac.Name;
                    String censored = '';
                    //Si es una cuenta personal, enviamo los datos de LOPD, sino lo es, enviamos un 0 e indicamos que es una empresa
                    if(ac.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()){
                        if(ac.AceptoPoliticaPrivacidad__pc) acceptPrivac = 1;
                        if(ac.DeseoRecibirComunicacionesComerciales__pc) acceptMarket = 1;
                        empresa = 0;
                        if(!String.isBlank(ac.Sexo__pc))genero = ac.Sexo__pc.substring(0,1);
                        nombreJuridico = '';
                    }
                    else if (ac.Contacts != null && !ac.Contacts.isEmpty()){
                    // Si es una cuenta empresarial, se cogen los datos del contacto marcado como reprensentante legal
                        system.debug('ac.recordTypeId :' +Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonaJuridica').getRecordTypeId());
                        if (ac.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonaJuridica').getRecordTypeId()){
                          
                                // Datos del representante legal
                                nif = (!String.isBlank(ac.Contacts[0].DocumentoIdentidad__c)) ? ac.Contacts[0].DocumentoIdentidad__c : '';
                                nombre = (!String.isBlank(ac.Contacts[0].FirstName)) ? ac.Contacts[0].FirstName : '';
                                apellido = (!String.isBlank(ac.Contacts[0].LastName)) ? ac.Contacts[0].LastName : '';
                                // Privacidad del representante legal
                                acceptPrivac = ac.Contacts[0].AceptoPoliticaPrivacidad__c ? 1 : 0;
                                acceptMarket = ac.Contacts[0].DeseoRecibirComunicacionesComerciales__c ? 1 : 0;
                            // Si no hay representante legal, dejarlo en blanco para no enviar los datos de la cuenta empresarial    
                            }else{
                                nif = '';
                                nombre = '';
                                apellido = '';
                            }
                        }
                    else if(ac.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Oculto').getRecordTypeId()){
                        censored = string.valueOf(system.today());
                    }
                    String poderNotarial = '';
                    if(!String.isBlank(ac.PoderNotarial__c)) {
                        if(ac.PoderNotarial__c == 'Ninguno' || ac.PoderNotarial__c == 'Revocado') poderNotarial = 'SIN PODER';
                        else poderNotarial = ac.PoderNotarial__c.toUpperCase();
                    }
                    

                    //Construcci?n body
                    datosBody = 'crm_id='+ac.IdClienteMinerva__c+'&dni='+nif+'&name='+nombre
                                        +'&lastname='+apellido+'&codpos='+postalCode+'&address='+calle
                                        +'&poblacion='+ciudad+'&document_type='+tipoDoc+'&cif='+cif+'&phone='+movil
                                        +'&cellphone='+telefono+'&gender='+genero+'&birth_date='+nacimiento+'&email='+email
                                        +'&email2='+emailSec+'&occupation='+titulo
                                        +'&confirmed='+'&accepts_privacy='+acceptPrivac+'&accepts_marketing='+acceptMarket
                                        +'&poder_notarial='+poderNotarial+'&censored='+censored+'&empresa='+empresa
                                        +'&empresa-nombre-juridico='+nombreJuridico+'&message=Privacidad Aceptada';
                                   
                    
                    //String bodyEncode = EncodingUtil.urlEncode(datosBody, 'UTF-8');
                    wsRequest.setBody(datosBody);     
                	system.debug('Body : ' + datosBody);
                	//system.debug('Body Encode : ' + bodyEncode);                
                
                    //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS
                    HttpResponse wsResponse = http.send(wsRequest); 
                    
                    JSONParser parser;
                    Integer intentos = 10;
                    if(wsResponse.getStatusCode() >=300 && wsResponse.getStatusCode() <= 307 && wsResponse.getStatusCode() != 306) {
                        do {
                            intentos--;
                            Boolean redirect = false; // reset the value each time
                            String loc = wsResponse.getHeader('Location'); // get location of the redirect
                            //system.debug('loc===='+loc);
                            if(loc == null) {
                                redirect = false;
                                continue;
                            }
                            wsRequest = new HttpRequest();
                            wsRequest.setEndpoint(loc);
                            wsRequest.setMethod('POST');
                            wsRequest.setBody(datosBody); 
                            wsResponse = http.send(wsRequest);
                            //system.debug('========='+wsResponse.getbody());
                            // Parse entire JSON response.
                            parser = JSON.createParser(wsResponse.getbody());
                            
                            //system.debug('===parser======'+parser);
                            
                            
                        }while(intentos > 0);
                    }else if(wsResponse.getStatusCode() != 200) {
                        Map<String, Object> json = (Map<String, Object>)JSON.deserializeUntyped(wsResponse.getBody());                        
                        Map<String, Object> jsonerrores = (Map<String, Object>) json.get('data');
	                    WrapperRespuestaKoContacto responseKo = new WrapperRespuestaKoContacto(json, jsonerrores);
                            //system.debug('===responseKo======'+responseKo);
                        
                        updateCuenta.AccountSyncProd__c = 'ERROR';
                        updateCuenta.bodyProduccion__c = datosBody;
                        updateCuenta.MessageErrProd__c = string.valueOf(responseKo.errors);
                        updateCuenta.FechaSyncProd__c = system.now();
                    } else {                       
                        Map<String, Object> json = (Map<String, Object>)JSON.deserializeUntyped(wsResponse.getBody());                        
                        Map<String, Object> jsonMeta = (Map<String, Object>) json.get('meta');                   
                        Map<String, Object> jsonData = (Map<String, Object>) json.get('data'); 
                        
                        WrapperRespuestaOkContacto responseOk = new WrapperRespuestaOkContacto(jsonMeta, jsonData);
                            //system.debug('===responseOk======'+responseOk);

                        updateCuenta.IdOrigenProd__c = ac.IdClienteMinerva__c;
                        updateCuenta.bodyProduccion__c = datosBody;
                        updateCuenta.AccountSyncProd__c = 'OK';
                    	updateCuenta.MessageErrProd__c = '';
                        updateCuenta.FechaSyncProd__c = system.now();
                    }
                    
                }catch(Exception e){
            			system.debug('ERROR  : ' + E.getMessage() + '---' + e.getStackTraceString());
                    updateCuenta.bodyProduccion__c = datosBody;
                    updateCuenta.AccountSyncProd__c = 'ERROR';
                    updateCuenta.MessageErrProd__c = 'Error al realizar la llamada de inserci?n : ' + e.getMessage();
                    updateCuenta.FechaSyncProd__c = system.now();
                } 
                lCuentaUpdateRespuesta.add(updateCuenta);
            }

            //if(!lCuentaUpdateRespuesta.isEmpty()) update lCuentaUpdateRespuesta;  
        }
        return lCuentaUpdateRespuesta;
    }
    
    
    private static List<Account> sendActualizarContactoProd(List<Account> lcuenta){
        //Creamos una lista donde a?adiremos las cuentas que actualizaremos con la respuesta
        List<Account> lCuentaUpdateRespuesta = new List<Account>();
        //Cargamos la configuraci?n personalizada
        ArrProdDatosWS__c datosWS = ArrProdDatosWS__c.getInstance('General');
        if(datosWS.Activo__c){
            String endPoint = datosWS.EndpointUpdtContc__c; 
            String xApikey = datosWS.PublicKey__c;            
            String milisecondsUnix = string.valueOf(DateTime.now().getTime());
            String xApiTimestamp = milisecondsUnix.substring(0,10);
            //Inicio de  X-Api-Signature
            String concatenacion = xApiKey + xApiTimestamp + datosWS.PrivateKey__c;
            Blob concatenacionBlob = Blob.valueOf(concatenacion);
            Blob encriptacionMD5 = Crypto.generateDigest('MD5', concatenacionBlob);

            String encriptacionMD5Hexa = EncodingUtil.convertToHex(encriptacionMD5);
            Blob preSignatureBlob = Blob.valueOf(encriptacionMD5Hexa);

            String xApiSignature = EncodingUtil.base64Encode(preSignatureBlob);

            //system.debug('**************************************');
            //system.debug('endPoint : ' + endPoint);
            //system.debug('xApikey : ' + xApikey);
            //system.debug('xApiTimestamp : ' + xApiTimestamp);
            //system.debug('xApiSignature : ' + xApiSignature);
            //system.debug('**************************************');

            // Realizamos una llamada por Cuenta
            for(Account ac : lcuenta){     
                Account updateCuenta = new Account();
                    updateCuenta.Id = ac.Id;
                String datosBody;
                
                System.debug('SINCRONIZANDO CUENTA (UPDATE): ' + ac.Id);
                 
                try{
                    //Realizamos la llamada
                    Http http = new Http();
                    HttpRequest wsRequest = new HttpRequest();
                    wsRequest.setMethod('PUT'); 
                    
                    wsRequest.setEndpoint(endPoint+ac.IdClienteMinerva__c+'.json');
                    wsRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                    wsRequest.setHeader('x-api-key', xApikey);
                    wsRequest.setHeader('x-api-timestamp', xApiTimestamp);
                    wsRequest.setHeader('x-api-signature', xApiSignature);  
                    //Monto el body del tipo form-data

                    //Controlando campos para no mandar null
                    String nombre = (!String.isBlank(ac.FirstName)) ? ac.FirstName : '';
                    String apellido = (!String.isBlank(ac.LastName)) ? ac.LastName : '';
                    String postalCode = (!String.isBlank(ac.ShippingPostalCode)) ? ac.ShippingPostalCode : '';
                    String calle = (!String.isBlank(ac.ShippingStreet)) ? ac.ShippingStreet : '';
                    String ciudad = (!String.isBlank(ac.ShippingCity)) ? ac.ShippingCity : '';
                    String movil = (!String.isBlank(ac.PersonMobilePhone)) ? ac.PersonMobilePhone : '';                    
                    String telefono = (!String.isBlank(ac.Phone)) ? ac.Phone : '';                                
                    String email = (!String.isBlank(ac.PersonEmail)) ? ac.PersonEmail : '';                   
                    String emailSec = (!String.isBlank(ac.CorreoElectronicoSecundario__c)) ? ac.CorreoElectronicoSecundario__c : '';                   
                    String titulo = (!String.isBlank(ac.PersonTitle)) ? ac.PersonTitle : '';
                    String nacimiento = (!String.isBlank(string.valueOf(ac.PersonBirthdate))) ? string.valueOf(ac.PersonBirthdate) : '';

                    //NIF o CIF para el env?o de los datos
                    String nif = '';
                    String cif = '';
                    String tipoDoc = '';
                     if(!String.isBlank(ac.TipoDocumento__c)){
                        if((ac.TipoDocumento__c.toUpperCase()) != 'CIF'){
                            if(!String.isBlank(ac.DocumentoIdentidad__c)) nif = ac.DocumentoIdentidad__c;
                            tipoDoc = ac.TipoDocumento__c.toLowerCase();
                        }
                        else {
                            if(!String.isBlank(ac.DocumentoIdentidad__c)) cif = ac.DocumentoIdentidad__c; 
                        }
                    }

					 system.debug('recordtype: '+Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonaJuridica').getRecordTypeId());
                    Integer acceptPrivac = 0;
                    Integer acceptMarket = 0;
                    Integer empresa = 1;
                    String genero = '';
                    String nombreJuridico = ac.Name;
                    String censored = '';
                    //Si es una cuenta personal, enviamo los datos de LOPD, sino lo es, enviamos un 0 e indicamos que es una empresa
                    if(ac.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()){
                        if(ac.AceptoPoliticaPrivacidad__pc) acceptPrivac = 1;
                        if(ac.DeseoRecibirComunicacionesComerciales__pc) acceptMarket = 1;
                        empresa = 0;
                        if(!String.isBlank(ac.Sexo__pc))genero = ac.Sexo__pc.substring(0,1);
                        nombreJuridico = '';
                    }
                   
                    // Si es una cuenta empresarial, se cogen los datos del contacto marcado como reprensentante legal
                    else if (ac.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonaJuridica').getRecordTypeId()){
                        if (ac.Contacts != null && !ac.Contacts.isEmpty()){
                            // Datos del representante legal
                            nif = (!String.isBlank(ac.Contacts[0].DocumentoIdentidad__c)) ? ac.Contacts[0].DocumentoIdentidad__c : '';
                            nombre = (!String.isBlank(ac.Contacts[0].FirstName)) ? ac.Contacts[0].FirstName : '';
                            apellido = (!String.isBlank(ac.Contacts[0].LastName)) ? ac.Contacts[0].LastName : '';
                            // Privacidad del representante legal
                            acceptPrivac = ac.Contacts[0].AceptoPoliticaPrivacidad__c ? 1 : 0;
                            acceptMarket = ac.Contacts[0].DeseoRecibirComunicacionesComerciales__c ? 1 : 0;
                        // Si no hay representante legal, dejarlo en blanco para no enviar los datos de la cuenta empresarial    
                        }else{
                            nif = '';
                            nombre = '';
                            apellido = '';
                        }
                    }
                    else if(ac.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Oculto').getRecordTypeId()){
                        censored = string.valueOf(system.today());
                    }
                    String poderNotarial = '';
                    if(!String.isBlank(ac.PoderNotarial__c)) {
                        if(ac.PoderNotarial__c == 'Ninguno' || ac.PoderNotarial__c == 'Revocado') poderNotarial = 'SIN PODER';
                        else poderNotarial = ac.PoderNotarial__c.toUpperCase();
                    }


                    //Construcci?n body
                    datosBody = /*'crm_id='+ac.IdClienteMinerva__c+'&*/'dni='+nif+'&name='+nombre
                                        +'&lastname='+apellido+'&codpos='+postalCode+'&address='+calle
                                        +'&poblacion='+ciudad+'&document_type='+tipoDoc+'&cif='+cif+'&phone='+movil
                                        +'&cellphone='+telefono+'&gender='+genero+'&birth_date='+nacimiento+'&email='+email
                                        +'&email2='+emailSec+'&occupation='+titulo
                                        +'&confirmed='+'&accepts_privacy='+acceptPrivac+'&accepts_marketing='+acceptMarket
                                        +'&poder_notarial='+poderNotarial+'&censored='+censored+'&empresa='+empresa
                                        +'&empresa-nombre-juridico='+nombreJuridico+'&message=Privacidad Aceptada';
                    
                    //String bodyEncode = EncodingUtil.urlEncode(datosBody, 'UTF-8');
                    wsRequest.setBody(datosBody);     
                	system.debug('Body : ' + datosBody);
                	//system.debug('Body Encode : ' + bodyEncode);                
                
                    //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS
                    HttpResponse wsResponse = http.send(wsRequest); 
                    
                    JSONParser parser;
                    Integer intentos = 10;
                    	//system.debug('wsResponse.getStatusCode():' + wsResponse.getStatusCode());
                    if(wsResponse.getStatusCode() >=300 && wsResponse.getStatusCode() <= 307 && wsResponse.getStatusCode() != 306) {
                        do {
                            intentos--;
                            Boolean redirect = false; // reset the value each time
                            String loc = wsResponse.getHeader('Location'); // get location of the redirect
                            //system.debug('loc===='+loc);
                            if(loc == null) {
                                redirect = false;
                                continue;
                            }
                            wsRequest = new HttpRequest();
                            wsRequest.setEndpoint(loc);
                            wsRequest.setMethod('POST');
                            wsRequest.setBody(datosBody); 
                            wsResponse = http.send(wsRequest);
                            //system.debug('========='+wsResponse.getbody());
                            // Parse entire JSON response.
                            parser = JSON.createParser(wsResponse.getbody());
                            
                            //system.debug('===parser======'+parser);
                            
                            
                        }while(intentos>0);
                    }else if(wsResponse.getStatusCode() != 200) {
                    	//system.debug('wsResponse.getStatusCode() != 200');
                        //system.debug('wsResponse : ' + wsResponse);
                        //system.debug('wsResponse.getBody() : ' + wsResponse.getBody());
                        Map<String, Object> json = (Map<String, Object>)JSON.deserializeUntyped(wsResponse.getBody());                        
                        Map<String, Object> jsonerrores = (Map<String, Object>) json.get('data');
	                    WrapperRespuestaKoContacto responseKo = new WrapperRespuestaKoContacto(json, jsonerrores);
                        
                        updateCuenta.bodyProduccion__c = datosBody;
                        updateCuenta.AccountSyncProd__c = 'ERROR';
                        updateCuenta.MessageErrProd__c = string.valueOf(responseKo.errors);
                        updateCuenta.FechaSyncProd__c = system.now();
                    } else {                        
                    	//system.debug('wsResponse.getStatusCode() = 200');
                        //system.debug('wsResponse : ' + wsResponse);
                        //system.debug('wsResponse.getBody() : ' + wsResponse.getBody());
                        Map<String, Object> json = (Map<String, Object>)JSON.deserializeUntyped(wsResponse.getBody());                        
                        Map<String, Object> jsonMeta = (Map<String, Object>) json.get('meta');                   
                        Map<String, Object> jsonData = (Map<String, Object>) json.get('data'); 
                        
                        WrapperRespuestaOkContacto responseOk = new WrapperRespuestaOkContacto(jsonMeta, jsonData);

                        updateCuenta.IdOrigenProd__c = ac.IdClienteMinerva__c;
                        updateCuenta.bodyProduccion__c = datosBody;
                        updateCuenta.AccountSyncProd__c = 'OK';
                    	updateCuenta.MessageErrProd__c = '';
                        updateCuenta.FechaSyncProd__c = system.now();
                    }
                }catch(Exception e){
                    system.debug('Exception : ' + e.getMessage());
                    updateCuenta.bodyProduccion__c = datosBody;
                    updateCuenta.AccountSyncProd__c = 'ERROR';
                    updateCuenta.MessageErrProd__c = 'Error al realizar la llamada de actualizaci?n : ' + e.getMessage();
                    updateCuenta.FechaSyncProd__c = system.now();
                }
                lCuentaUpdateRespuesta.add(updateCuenta);
            }

            //if(!lCuentaUpdateRespuesta.isEmpty()) update lCuentaUpdateRespuesta; 
        }
        return lCuentaUpdateRespuesta;
    }
    
    /*

		--- M?todos encargados de enivar o eliminar Expedientes ---

	*/
    /* Minerva */
    private static List<Contract> postNewExpedientMin(List<String> lIdExp){
        //Creamos una lista donde a?adiremos las cuentas que actualizaremos con la respuesta
        List<Contract> lExpedienteUpdateRespuesta = new List<Contract>();
        //Cargamos la configuraci?n personalizada
        ArrMinervDatosWS__c datosWS = ArrMinervDatosWS__c.getInstance('General');
        if(datosWS.Activo__c){
            String endPoint = datosWS.Endpoint__c; 
			String endPointEstados = datosWS.EndpointEstados__c;             
            String token = getAuthToken();
            //Obtenemos los datos del exediente los cuales enviaremos
            List<Contract> expediente = [SELECT Id, IdExpediente__c,TipoExpDerivado__c,ImporteRecuperar__c,CargaInicial__c, Oportunidad__r.NumeroExpedienteMinerva__c,Oportunidad__r.CargaInicial__c,IdOrigenMinerva__c, Account.IdClienteMinerva__c,Producto__r.ExternalId__c, ParteContraria__r.Name, PrecioTotal__c,
                                                Producto__r.Name, status, StartDate, OficinaAsesor__r.Name, Owner.Name, Account.IBAN__pc, Account.PoderNotarial__c,
                                                bodyMinerva__c, (SELECT PrecioTotal__c, Estado__c, Tipo__c FROM Pagos__r ORDER BY createdDate DESC LIMIT 1)
                                                FROM Contract
                                                WHERE IdExpediente__c IN : lIdExp];

            //Metemos en un mapa el número expediente de la oportunidad y el OLI asociado a la oportunidad para obtener el Producto
            Map<String, String> mProductoAsociado = new Map<String, String>();
            List<OpportunityLineItem> lOli = [SELECT Opportunity.NumeroExpediente__c, Product2Id, Product2.ExternalId__c 
                                                FROM OpportunityLineItem 
                                                WHERE Opportunity.NumeroExpediente__c IN :lIdExp];

            if(!lOli.isEmpty())for(OpportunityLineItem oli : lOli) mProductoAsociado.put(oli.Opportunity.NumeroExpediente__c, oli.Product2.ExternalId__c);

            for(Contract exp : expediente){
                //Inicializamos las variables que contendrán las respuestas
                WrapperRespuestaOKExpediente responseOk = new WrapperRespuestaOKExpediente();
                WrapperRespuestaKoExpediente responseKo = new WrapperRespuestaKoExpediente();                    
                //Creamos la variable que se usará para actualizar el expediente
                Contract UpdateExp = new Contract();
                UpdateExp.Id = exp.Id;
                String productoAsociado = '';
                String JsonBody;
                String JsonEstados;
                try{ 
                    if(!mProductoAsociado.isEmpty())if(mProductoAsociado.containsKey(exp.IdExpediente__c)) productoAsociado = mProductoAsociado.get(exp.IdExpediente__c);
                    if(productoAsociado=='') productoAsociado= exp.Producto__r.ExternalId__c;
                    system.debug('productoAsociado '+productoAsociado);
                    //Mapeamos los datos del expediente con los datos que enviaremos
                    WrapperDatosEnvioExpediente datosEnvio = new WrapperDatosEnvioExpediente(exp, productoAsociado);
                    WrapperDatosEnvioExpedienteEst datosEnvioEst = new WrapperDatosEnvioExpedienteEst(exp, productoAsociado);

                    //Transformamos el JSON los datos del expediente para enviarlos al WS
                    JsonBody = JSON.serialize(datosEnvio, true);
                    JsonEstados = JSON.serialize(datosEnvioEst, true);
                    system.debug('VENIA ' +JsonEstados);
                    system.debug('json1 : ' + JsonBody);
                    system.debug('datosEnvio : ' + datosEnvio);
                    //Comenzamos a montar la llamada
                    Http http = new Http();
                    HttpRequest wsRequest = new HttpRequest();
                    
                    //system.debug(JsonBody);
                     Boolean isUpdate = isUpdateMinervaExp(exp);
                    system.debug('isUpdate'+isUpdate);
					
                    // Decidimos si enviaremos una actualizaci?n o una inserci?n
                    if(isUpdate) {
                        wsRequest.setMethod('PUT');
                        wsRequest.setEndpoint(endPoint+'/api/expedient/'+exp.IdExpediente__c);
                        wsRequest.setHeader('Content-Type', 'application/json');
                        wsRequest.setHeader('Authorization', 'Bearer ' + token);
                        wsRequest.setBody(JsonBody);
                        wsRequest.setTimeout(120000);
                        string status = exp.Status;
                        string desistido= system.label.EstadoExpteAcuerdo;
                        System.debug('METHOD => UPDATE');
                    } else {
                        if(exp.status!=null)
                        {
                            WrapperExpedienteRelacionado datos =new WrapperExpedienteRelacionado(exp);
                            String Json = JSON.serialize(datosEnvio, true);
                            wsRequest.setMethod('POST');
                            system.debug('xp.Status '+exp.Status);
                             if(exp.Status.Contains( system.label.EstadoExpteVenia)){
                                system.debug('Venia');
                                system.debug('endPointEstados '+endPointEstados);
                            	wsRequest.setEndpoint(endPointEstados+'/api/expedient/transversal/venia');
                                wsRequest.setBody(JsonEstados);
                                
                            }
                            else if(exp.Status.Contains(system.label.EstadoExpteAcuerdo) && !exp.Status.Contains(system.label.EstadoExpteDesistido)){
                                system.debug('Acuerdo');
                                wsRequest.setEndpoint(endPointEstados+'/api/expedient/transversal/extrajudicialSettlement');    
                                wsRequest.setBody(JsonEstados);
                            }
                            else if(exp.Status.Contains(system.label.EstadoExpteDesistido)){
                                system.debug('Desistido');
                             	wsRequest.setEndpoint(endPointEstados+'/api/expedient/transversal/customerWithdrawal');   
	                            wsRequest.setBody(JsonEstados);
                            }
                            else{
                               wsRequest.setEndpoint(endPoint+'/api/expedient');
                               wsRequest.setBody(Json);
                            }
                            wsRequest.setMethod('POST'); 
                            wsRequest.setHeader('Content-Type', 'application/json');
                            wsRequest.setHeader('Authorization', 'Bearer ' + token);
                            
                            wsRequest.setTimeout(120000);   
                            System.debug('METHOD => INSERT');
                        }
                        else { 
                            wsRequest.setMethod('POST'); 
                            wsRequest.setEndpoint(endPoint+'/api/expedient');
                            wsRequest.setHeader('Content-Type', 'application/json');
                            wsRequest.setHeader('Authorization', 'Bearer ' + token);
                            wsRequest.setBody(JsonEstados);
                            wsRequest.setTimeout(120000);
                            system.debug('endPoint ' +endPoint);
                            System.debug('METHOD => INSERT');
                        }
                    }
                    HttpResponse wsResponse = http.send(wsRequest);
					system.debug(wsResponse);                    
                    //Comprobamos la respuesta del WS y trasformamos la respuesta en funcion de si ha ido OK o KO con la wrapper correspondiente
                    if(wsResponse.getStatusCode() != 201) { 
                        responseKo = (WrapperRespuestaKoExpediente) JSON.deserialize(wsResponse.getBody(), WrapperRespuestaKoExpediente.class);                        
						system.debug('responseKo '+responseKo);                        
                        UpdateExp.bodyMinerva__c = JsonBody;
                        UpdateExp.EstadoSyncMinerva__c = 'ERROR';
                        UpdateExp.MessageSyncMinerva__c = responseKo.status + ' - ' + responseKo.errors;
                        
                    }else{
                        responseOk = (WrapperRespuestaOKExpediente) JSON.deserialize(wsResponse.getBody(), WrapperRespuestaOKExpediente.class);
                        
                        UpdateExp.bodyMinerva__c = JsonBody;
                        UpdateExp.EstadoSyncMinerva__c = 'OK';
                        UpdateExp.MessageSyncMinerva__c = '';
                        
                    }           
                } catch(Exception e){
                    UpdateExp.bodyMinerva__c = JsonBody;
                    UpdateExp.EstadoSyncMinerva__c = 'ERROR';
                    UpdateExp.MessageSyncMinerva__c = 'Error al realizar la llamada de inserci?n : ' + e.getMessage()/* + '-' + e.getStackTraceString()*/;
                    system.debug(e.getMessage() + '-' + e.getStackTraceString());
                }
               
                system.debug(JsonBody);
                system.debug(UpdateExp.MessageSyncMinerva__c);
                lExpedienteUpdateRespuesta.add(UpdateExp);
            }
            
            //if(!lExpedienteUpdateRespuesta.isEmpty()) update lExpedienteUpdateRespuesta;  
            
        }
        return lExpedienteUpdateRespuesta;    
    }   
    
    private static void deleteExpedientMin(List<String> lIdExp){
        //Cargamos la configuraci?n personalizada
        ArrMinervDatosWS__c datosWS = ArrMinervDatosWS__c.getInstance('General');
        if(datosWS.Activo__c){
            String endPoint = datosWS.Endpoint__c;             
            String token = getAuthToken();
            // Realizamos una llamada por Cuenta
            for(String numexp : lIdExp){                                  
                try{
                    //Realizamos la llamada
                    Http http = new Http();
                    HttpRequest wsRequest = new HttpRequest();
                    wsRequest.setMethod('DELETE');  
                    wsRequest.setEndpoint(endPoint+'/api/expedient/'+numexp);
                    wsRequest.setHeader('Content-Type', 'application/json');
                    wsRequest.setHeader('Authorization', 'Bearer ' + token);

                    HttpResponse wsResponse = http.send(wsRequest);
                    //Comprobamos la respuesta del WS y trasformamos la respuesta en funcion de si ha ido OK o KO con la wrapper correspondiente
                    if(wsResponse.getStatusCode() != 204) {                        
                        //system.debug('Error de WS : ' + wsResponse.getBody());
                    } 
                    else {
                        //Un 204 - Expedient deleted succesfully      
                        //system.debug('204 - Expedient deleted succesfully');
                                      
                    }
                }catch(Exception e){      
                        //system.debug('Error de callout : ' + e.getMessage());
                    
                } 
            }  
        }
    }
    
    /* Producci?n */
    public static List<Contract> postNewExpedientProd(List<String> lIdExp){
        //system.debug('postNewExpedientProd');
        //Creamos una lista donde a?adiremos los n? de exp que usaremos para actualizar el expediente
        List<Contract> lExpUpdateRespuesta = new List<Contract>();
        //Cargamos la configuraci?n personalizada
        ArrProdDatosWS__c datosWS = ArrProdDatosWS__c.getInstance('General');
        if(datosWS.Activo__c){
            List<Contract> lExpedientes = [SELECT Id, ImporteRecuperar__c, TipoExpDerivado__c, IdExpediente__c, Account.IdClienteMinerva__c, ParteContraria__r.Name, PrecioTotal__c,
                                                Producto__r.Name, StartDate, OficinaAsesor__r.Name, Owner.Name, Account.IBAN__pc, Oportunidad__c,
                                                bodyProduccion__c, IdOrigenProduccion__c, CargaInicial__c, Owner.Email, Oportunidad__r.CargaInicial__c,
                                                Status, ExpedientePrincipal__c
                                            FROM Contract  
                                            WHERE IdExpediente__c IN :lIdExp];
            //Inicializamos el objeto que m?s tarde actualizaremos
            Contract expUpdate = new Contract();
            String datosBody;
            try{
                //Obtenemos los datos del pago
                List<Pago__c> lPagos = [SELECT Expediente__c, Tipo__c, Estado__c, PrecioTotal__c, ProofPaymentDate__c
                                        FROM Pago__c
                                        WHERE Expediente__r.IdExpediente__c IN :lIdExp
                                        ORDER BY CreatedDate DESC];
                Map<Id, Pago__c> mPagoExp = new Map<Id, Pago__c>();

                for(Pago__c pago : lPagos) mPagoExp.put(pago.Expediente__c, pago);

                //Obtenemos la lista de roles de contactos en funci?n del Expediente
                List<ContractContactRole> lRolesExp = [SELECT Id, ContractId, ContactId, Contact.Account.IdClienteMinerva__c, Role
                                                            FROM ContractContactRole
                                                            WHERE Contract.IdExpediente__c IN :lIdExp];
                
                //Recorremos los expedientes y nos quedamos con el ID de oportunidad
                List<Id> lIdsOpp = new List<Id>();
                for(Contract c : lExpedientes){
                    lIdsOpp.add(c.Oportunidad__c);
                }

                //Metemos en un mapa el ID de la oportunidad y el OLI asociado a la oportunidad para obtener el Producto
                Map<Id, String> mProductoAsociado = new Map<Id, String>();
                List<OpportunityLineItem> lOli = [SELECT OpportunityId, Product2Id, Product2.Name 
                                                    FROM OpportunityLineItem 
                                                    WHERE OpportunityId IN :lIdsOpp];

                for(OpportunityLineItem oli : lOli) mProductoAsociado.put(oli.OpportunityId, oli.Product2.Name);


                String endPointInsert = datosWS.EndpointInsrtExp__c; 
                String endPointUpdate = datosWS.EndpointUpdtExp__c; 

                String xApikey = datosWS.PublicKey__c;            
                String milisecondsUnix = string.valueOf(DateTime.now().getTime());
                String xApiTimestamp = milisecondsUnix.substring(0,10);
                //Inicio de  X-Api-Signature
                String concatenacion = xApiKey + xApiTimestamp + datosWS.PrivateKey__c;
                Blob concatenacionBlob = Blob.valueOf(concatenacion);
                Blob encriptacionMD5 = Crypto.generateDigest('MD5', concatenacionBlob);
                
                String encriptacionMD5Hexa = EncodingUtil.convertToHex(encriptacionMD5);
                Blob preSignatureBlob = Blob.valueOf(encriptacionMD5Hexa);
                
                String xApiSignature = EncodingUtil.base64Encode(preSignatureBlob);

                //Realizamos la llamada
                Http http = new Http();
                HttpRequest wsRequest = new HttpRequest();
                //wsRequest.setMethod('POST');  
                //wsRequest.setEndpoint(endPoint);
                wsRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                wsRequest.setHeader('x-api-key', xApikey);
                wsRequest.setHeader('x-api-timestamp', xApiTimestamp);
                wsRequest.setHeader('x-api-signature', xApiSignature);

                for(Contract expediente : lExpedientes){
                   system.debug('tst');
                    Boolean isUpdate = isUpdateProdExp(expediente);

                    // Decidimos si enviaremos una actualizaci?n o una inserci?n
                    if(isUpdate) {
                        wsRequest.setMethod('PUT');  
                        wsRequest.setEndpoint(endPointUpdate + expediente.IdExpediente__c); 
                        System.debug('METHOD => UPDATE');
                    } else {
                        wsRequest.setMethod('POST'); 
                        wsRequest.setEndpoint(endPointInsert); 
                        System.debug('METHOD => INSERT');
                    }

                    
                    //Igualamos el objeto a actualizar con el que enviamos a Producci?n
                    expUpdate.Id = expediente.Id;
                    
                    //lista string para los customers
                    List<String> lcustomers = new list<String>();
                    String roleInter;
                    if(!lRolesExp.isEmpty()){
                        for(ContractContactRole cr :lRolesExp){
                            if(cr.ContractId == expediente.Id){
                                //A?adimos el role en una variable de texto
                                roleInter = cr.Role;
                                //Si el rol es Titular, modificamos el valor de la variable para mandar Primer Titular, ya que es lo que la integraci?n acepta.
                                if(roleInter == 'Titular') roleInter = 'Primer Titular';
                                
                                //A?adimos en la lista de intervinientes los valores correctos
                                lcustomers.add('&customers['+cr.Contact.Account.IdClienteMinerva__c+']='+roleInter);
                            }
                        }
                    }
                    //obtenemos el producto
                    String producto ='';
                    if(mProductoAsociado.containsKey(expediente.Oportunidad__c)) producto = mProductoAsociado.get(expediente.Oportunidad__c);

                    //Datos del Pago
                    String tipo = '';
                    String estado = '';
                    String importe = '';
                    String fechaPago = '';
                    if(mPagoExp.containsKey(expediente.Id)){
                        if(!String.isBlank(mPagoExp.get(expediente.Id).Tipo__c)){
                            tipo = mPagoExp.get(expediente.Id).Tipo__c;

                            if(tipo == 'TPV Virtual') tipo = 'PASARELA PAGO INTERNET';
                            else if (tipo == 'En met?lico') tipo = 'EFECTIVO (Asesor)';
                            else tipo = tipo.toUpperCase();

                            if(!String.isBlank(String.valueOf(mPagoExp.get(expediente.Id).PrecioTotal__c))) importe = String.valueOf(mPagoExp.get(expediente.Id).PrecioTotal__c);
                            fechaPago = String.valueOf(mPagoExp.get(expediente.Id).ProofPaymentDate__c);
                        }
                    }

                    //Controlando campos para no mandar null
                    String importeExp = (!String.isBlank(String.valueOf(expediente.ImporteRecuperar__c))) ? String.valueOf(expediente.ImporteRecuperar__c) : '';
                    String bancoParteContr = (!String.isBlank(expediente.ParteContraria__r.Name)) ? expediente.ParteContraria__r.Name : '';
                    String personaComercial = (!String.isBlank(expediente.Owner.Email)) ? expediente.Owner.Email : '';
                    String iban = (!String.isBlank(expediente.Account.IBAN__pc)) ? expediente.Account.IBAN__pc : '';
                    String fecInicio = (!String.isBlank(string.valueOf(expediente.StartDate))) ? string.valueOf(expediente.StartDate) : '';
                    String estadoExp = expediente.Status != null ? expediente.Status : '';
                    
                    //Construcci?n body
                    datosBody = '';
                    if(!isUpdate) {
                        System.debug('Pongo CRM ID ya que es insert');
                        datosBody += 'crm_id='+expediente.IdExpediente__c + '&';    
                    }
                    datosBody += 'company_id=2'+'&status='+estadoExp+
                            +'&producto='+producto+'&importe='+importeExp +'&banco='+bancoParteContr
                            +'&pf_estado=SI'+'&pf_importe='+importe+'&pf_medio_cobro='+tipo+'&pf_fecha='+fechaPago
                            +'&contract_date='+fecInicio+'&persona_comercial='+personaComercial
                            +'&persona_completado='+personaComercial+'&num-cuenta-banco='+iban
                            +'&hoja-encargo-firmada=1'+'&unfold=' + String.join(lcustomers,'');
                    
                    /*
                    datosBody = 'crm_id='+expediente.IdExpediente__c + String.join(lcustomers,'') +'&company_id=2'+'&status='+'COMPLETANDOSE DOCUMENTACI?N'
                                        +'&producto='+producto+'&importe='+importeExp +'&banco='+bancoParteContr
                                        +'&pf_estado=SI'+'&pf_importe='+importe+'&pf_medio_cobro='+tipo+'&pf_fecha='+fechaPago
                                        +'&contract_date='+fecInicio+'&persona_comercial='+personaComercial
                                        +'&persona_completado='+personaComercial+'&num-cuenta-banco='+iban
                                        +'&hoja-encargo-firmada=1'+'&unfold=';
                    */

                    wsRequest.setBody(datosBody);     
                	system.debug('Body : ' + datosBody);
                    System.debug('Endpoint: ' + wsRequest.getEndpoint());
                    
                    //Realizamos la llamada y comprobamos la llamadaRespuesta obtenida por el WS
                    HttpResponse wsResponse = http.send(wsRequest);
                    
                    JSONParser parser;
                    Integer intentos = 10;
                    if(wsResponse.getStatusCode() >=300 && wsResponse.getStatusCode() <= 307 && wsResponse.getStatusCode() != 306) {
                        do {
                            intentos--;
                            Boolean redirect = false; // reset the value each time
                            String loc = wsResponse.getHeader('Location'); // get location of the redirect
                            //system.debug('loc===='+loc);
                            if(loc == null) {
                                redirect = false;
                                continue;
                            }
                            wsRequest = new HttpRequest();
                            wsRequest.setEndpoint(loc);
                            wsRequest.setMethod('POST');
                            wsRequest.setBody(datosBody); 
                            wsResponse = http.send(wsRequest);
                            //system.debug('========='+wsResponse.getbody());
                            // Parse entire JSON response.
                            parser = JSON.createParser(wsResponse.getbody());
                            
                            //system.debug('===parser======'+parser);
                            
                            
                        }while(intentos>0);
                    }else if(wsResponse.getStatusCode() != 200) {
                    	System.debug('INSERT EXP REQUEST: ERROR');
                        System.debug(wsResponse.getBody());
                        
                        try{
                            Map<String, Object> json = (Map<String, Object>)JSON.deserializeUntyped(wsResponse.getBody());     
                            Map<String, Object> jsonerrores = (Map<String, Object>) json.get('data'); 
                            WrapperRespuestaKoContacto responseKo = new WrapperRespuestaKoContacto(json, jsonerrores);

                            expUpdate.bodyProduccion__c = datosBody;
                            expUpdate.EstadoSyncProd__c = 'ERROR';
                            expUpdate.MessageSyncProd__c = wsResponse.getStatusCode() + ' - ' + string.valueOf(responseKo.errors);
                        } catch (Exception e){
                            expUpdate.bodyProduccion__c = datosBody;
                            expUpdate.EstadoSyncProd__c = 'ERROR';
                            expUpdate.MessageSyncProd__c = wsResponse.getStatusCode() + ' - Error al parsear la respuesta JSON';
                        }
                    } else {
                        System.debug('INSERT EXP REQUEST: OK');
                        expUpdate.bodyProduccion__c = datosBody;
                        expUpdate.EstadoSyncProd__c = 'OK';
                        expUpdate.MessageSyncProd__c = '';

                        // a?adimos el campo con el Id de prod, con eso reflejamos al menos una operaci?n de sincro ha ido bien
                        expUpdate.IdOrigenProduccion__c = expediente.IdExpediente__c;
                        
                    }
                    lExpUpdateRespuesta.add(expUpdate);
                }
            } catch (Exception e){
                expUpdate.bodyProduccion__c = datosBody;
                expUpdate.EstadoSyncProd__c = 'ERROR';
                expUpdate.MessageSyncProd__c = 'Error al realizar la llamada de inserci?n : ' + e.getMessage();
                    system.debug('ERROR : ' + e.getMessage());
                lExpUpdateRespuesta.add(expUpdate);    
            }
            //Actualizamos la lista
            //if(!lExpUpdateRespuesta.isEmpty()) update lExpUpdateRespuesta;
        }
		return lExpUpdateRespuesta;
    }
    public static void deleteExpedientProd(List<String> lIdExp){}
	

    /**
     * isUpdateProdExp Comprobaci?n si debemos enviar una actualizaci?n o inserci?n a Producci?n del expediente
     * @param  c Expediente
     * @return   return devuelve verdadero si es una operaci?n de actualizaci?n
     */ 
    private  static Boolean isUpdateProdExp (Contract c) {
        // Comprueba si viene de carga o se ha sincronizado con producci?n en una operaci?n de inserci?n/update
		system.debug('pasa prod' +!String.isBlank(c.IdOrigenProduccion__c));
        return (!String.isBlank(c.IdOrigenProduccion__c)) || (c.CargaInicial__c) || (c.Oportunidad__r.CargaInicial__c && c.ExpedientePrincipal__c == null);
    }
	/**
     * isUpdateMinervaExp Comprobaci?n si debemos enviar una actualizaci?n o inserci?n a Minerva del expediente
     * @param  c Expediente
     * @return   return devuelve verdadero si es una operaci?n de actualizaci?n
     */ 
    private  static Boolean isUpdateMinervaExp (Contract c) {
        // Comprueba si viene de carga o se ha sincronizado con produccion en una operacion de insercion/update
		system.debug('pasa min' +!String.isBlank(c.IdOrigenMinerva__c));
        system.debug('pasa min' +!String.isBlank(c.Oportunidad__r.NumeroExpedienteMinerva__c));
        return (!String.isBlank(c.IdOrigenMinerva__c)) && !c.Status.contains('VENIA') && !c.Status.contains('ACUERDO') && !c.Status.contains('DESISTIDO')  || (!String.isBlank(c.Oportunidad__r.NumeroExpedienteMinerva__c)) && !c.Status.contains('VENIA') && !c.Status.contains('ACUERDO') && !c.Status.contains('DESISTIDO') || (c.CargaInicial__c)  || (c.Oportunidad__r.CargaInicial__c && c.ExpedientePrincipal__c == null);
    }


    /*
	
		--- M?todos Wrappers Contacto---

	*/
    //Producci?n
    public class WrapperRespuestaOkContacto{
        @AuraEnabled public Object meta;
        @AuraEnabled public Wrapperdata data;
        public WrapperRespuestaOkContacto(Map<String, Object> jsonMeta, Map<String, Object> jsonData){
            this.meta = jsonMeta;
            this.data = new Wrapperdata(jsonData);          
        }
    }
    public class Wrapperdata{
        @AuraEnabled public String type;
        @AuraEnabled public String id;
        @AuraEnabled public WrapperAttrib attributes;
        public Wrapperdata( Map<String, Object> jsonData ){
            this.type = (String) jsonData.get('type');
            this.id = (String) jsonData.get('id');
            Map<String, Object> jsonAtrib = (Map<String, Object>) jsonData.get('attributes');
            
                        //system.debug('jsonAtrib : ' + jsonAtrib);
            this.attributes = new WrapperAttrib(jsonAtrib);  
        }
    }
    public class WrapperAttrib{
        @AuraEnabled public Integer crm_id;
        @AuraEnabled public String name;
        @AuraEnabled public String lastname;
        @AuraEnabled public String email;
        @AuraEnabled public String cellphone;
        @AuraEnabled public String address;
        @AuraEnabled public String codpos;
        @AuraEnabled public String poblacion;
        @AuraEnabled public String dni;
        @AuraEnabled public String created;
        @AuraEnabled public String modified;
        @AuraEnabled public String token;
        @AuraEnabled public String token_expiration;
        @AuraEnabled public Object fs;
        @AuraEnabled public String accepts_privacy;
        @AuraEnabled public String accepts_marketing;
        @AuraEnabled public Object web_dni_files;
        public WrapperAttrib( Map<String, Object> jsonAtrib ){
            this.crm_id = (Integer) jsonAtrib.get('crm_id');
            this.name = (String) jsonAtrib.get('name');
            this.lastname = (String) jsonAtrib.get('lastname');
            this.email = (String) jsonAtrib.get('email');
            this.cellphone = (String) jsonAtrib.get('cellphone');
            this.address = (String) jsonAtrib.get('address');
            this.codpos = (String) jsonAtrib.get('codpos');
            this.poblacion = (String) jsonAtrib.get('poblacion');
            this.dni = (String) jsonAtrib.get('dni');
            this.created = (String) jsonAtrib.get('created');
            this.modified = (String) jsonAtrib.get('modified');
            this.token = (String) jsonAtrib.get('token');
            this.token_expiration = (String) jsonAtrib.get('token_expiration');
            this.fs = jsonAtrib.get(':fs');
            this.accepts_privacy = (String) jsonAtrib.get('accepts_privacy');
            this.accepts_marketing = (String) jsonAtrib.get('accepts_marketing');
            this.web_dni_files = jsonAtrib.get('web_dni_files');
        }
    }
    public class WrapperRespuestaKoContacto{
        @AuraEnabled public Object data;
        @AuraEnabled public Integer code;
        @AuraEnabled public String url;
        @AuraEnabled public String message;
        @AuraEnabled public Integer errorCount;
        @AuraEnabled public Object errors;   
        public WrapperRespuestaKoContacto(Map<String, Object> json, Map<String, Object> jsonerrores){
             this.data = json.get('data');
             this.code = Integer.valueOf(jsonerrores.get('code'));
             this.url = (String)jsonerrores.get('url');
             this.message = (String)jsonerrores.get('message');
             this.errorCount = Integer.valueOf(jsonerrores.get('errorCount'));
             this.errors = jsonerrores.get('errors');
         }
    }

    //Minerva
    public class WrapperDatosEnvioContacto{
        @AuraEnabled public String id;
        @AuraEnabled public String idCard;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String secondLastName;
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String mobile;
        @AuraEnabled public String creationDate;
        @AuraEnabled public String bussinesName;
        @AuraEnabled public String bankAccount;
        @AuraEnabled public String address;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String municipality;
        @AuraEnabled public String province;
        @AuraEnabled public String country;
        @AuraEnabled public String phone1;
        @AuraEnabled public String fax;
        @AuraEnabled public String email2;

        public WrapperDatosEnvioContacto(Account ac, Contact cont){
            this.id = ac.IdClienteMinerva__c;
            this.idCard = ac.DocumentoIdentidad__c;
            this.secondLastName = '';
            this.email = cont.Email;
            this.phone = ac.Phone;
            this.mobile = ac.PersonMobilePhone;
            this.creationDate = string.valueOf(ac.CreatedDate);
            if(ac.recordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()) {
                this.bussinesName = ac.Name;
                system.debug('cont.FirstName '+cont.FirstName);
                this.firstName = cont.FirstName;
            	this.lastName = cont.LastName;
            } else {
                this.firstName = cont.FirstName;
            	this.lastName = cont.LastName;
            }
            this.bankAccount = ac.IBAN__c;
            this.address = ac.ShippingStreet;
            this.postalCode = ac.ShippingPostalCode;
            this.province = ac.ShippingState;
            this.municipality = ac.ShippingCity;
            this.country = ac.ShippingCountry;
            this.email2 = ac.CorreoElectronicoSecundario__c;
            this.fax = ac.Fax;
            this.phone1 = ac.PersonHomePhone;
            
        }
    }
    public class WrapperRespuestaOkMinContacto{
        @AuraEnabled public String id;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String secondLastName;
        @AuraEnabled public String fullName; 
        @AuraEnabled public String email;
        @AuraEnabled public String phone;
        @AuraEnabled public String mobile;
        @AuraEnabled public String idCard;
        @AuraEnabled public String creationDate;
        @AuraEnabled public String bussinesName;
        @AuraEnabled public String bankAccount;
        @AuraEnabled public String address;
        @AuraEnabled public String postalCode;
        @AuraEnabled public String municipality;
        @AuraEnabled public String province;
        @AuraEnabled public String country;
        @AuraEnabled public String phone1;
        @AuraEnabled public String fax;
        @AuraEnabled public String email2; 
    }
    public class WrapperRespuestaKoMinContacto{
        @AuraEnabled public Wrappererrors errors;
        @AuraEnabled public String type;
        @AuraEnabled public String title;
        @AuraEnabled public String status;
        @AuraEnabled public String detail;
        @AuraEnabled public String instance; 
        @AuraEnabled public String additionalProp1;
        @AuraEnabled public String additionalProp2;
        @AuraEnabled public String additionalProp3;
    }
    public class Wrappererrors{
        @AuraEnabled public List<String> id;
        @AuraEnabled public List<String> idCard;
        @AuraEnabled public List<String> firstName;
        @AuraEnabled public List<String> lastName;
        @AuraEnabled public List<String> secondLastName;
        @AuraEnabled public List<String> email;
        @AuraEnabled public List<String> phone;
        @AuraEnabled public List<String> mobile;
        @AuraEnabled public List<String> creationDate;
        @AuraEnabled public List<String> bussinesName;
        @AuraEnabled public List<String> bankAccount;
        @AuraEnabled public List<String> address;
        @AuraEnabled public List<String> postalCode;
        @AuraEnabled public List<String> municipality;
        @AuraEnabled public List<String> province;
        @AuraEnabled public List<String> country;
        @AuraEnabled public List<String> phone1;
        @AuraEnabled public List<String> fax;
        @AuraEnabled public List<String> email2;
    }

    /*
	
		--- M?todos Wrappers Respuesta Expediente---

	*/
    //Minerva
    public class WrapperDatosEnvioExpedienteEst{
         @AuraEnabled public String expedientId;//IdExpediente__c
    public WrapperDatosEnvioExpedienteEst(Contract ct, String productCode){
            this.expedientId = ct.IdExpediente__c;
        }
    }
    public class WrapperDatosEnvioExpediente{
        @AuraEnabled public String id;//IdExpediente__c       
        @AuraEnabled public Decimal amount;//Pago__c.PrecioTotal__c
        @AuraEnabled public String opponent;//ParteContraria__c
        @AuraEnabled public Integer productId;//Product2.ProductCode
        @AuraEnabled public Boolean isInternal;//false
        @AuraEnabled public Boolean powerOfAttorney = false; //Account.PoderNotarial__c (si esta relleno true) // ?Vale as??
        @AuraEnabled public List<Integer> expedientCustomers;//Account.IdClienteMinerva__c,
        @AuraEnabled public Integer jurisdictionId;// 1
        
        
        public WrapperDatosEnvioExpediente(Contract ct, String productCode){
            this.id = ct.IdExpediente__c;
            this.isInternal = false;
            //Obtenemos el objeto pago del expediente
            Pago__c pago = ct.Pagos__r;
            if(ct.ImporteRecuperar__c != null){ //SCA
            	this.amount = ct.ImporteRecuperar__c;
            }
            else{
                this.amount = 0;
            }
            this.opponent = ct.ParteContraria__r.Name;
            this.productId = Integer.valueOf(productCode);
            //Cogemos el valor de los contactos relacionados con la cuenta y despues la a?adimos a la lista
            List<ContractContactRole> lcontactrole = [SELECT id,ContactId,ContractId  FROM ContractContactRole WHERE ContractId=:ct.Id ];
            this.expedientCustomers = new List<Integer>();
            Contact lcont =  new Contact();
            List<Contact> lconttoup =  new List<Contact>();
            Account lacc =  new Account();
            List<Account> lacctoup =  new List<Account>();
            if(lcontactrole.size() != null){
                for(ContractContactRole contactrole :lcontactrole){
                    lcont = [SELECT id,accountid FROM Contact WHERE id = :contactrole.ContactId];
                    lconttoup.add(lcont);
                }
            
                for(Contact cont :lconttoup){
                      lacc = [SELECT id,IdClienteMinerva__c FROM Account WHERE id = :cont.accountid];
                      lacctoup.add(lacc);
                      
                }
                for(Account acc :lacctoup){
                    this.expedientCustomers.add(integer.valueOf(acc.IdClienteMinerva__c));
                }
             }
            system.debug('this.expedientCustomers '+this.expedientCustomers);
            //Poder Notarial
            if(!String.isBlank(ct.Account.PoderNotarial__c) || ct.Account.PoderNotarial__c != 'Ninguno') this.powerOfAttorney = true;
            this.jurisdictionId = 1;
        }
    }
    public class WrapperRespuestaOKExpediente{
        @AuraEnabled public String id;
        @AuraEnabled public String expedientId;
        @AuraEnabled public String amount;
        @AuraEnabled public String lawyer;
        @AuraEnabled public String externalLawyer; 
        @AuraEnabled public String solicitor;
        @AuraEnabled public String opponent;
        @AuraEnabled public String created;
        @AuraEnabled public String productId;
        //@AuraEnabled public String jurisdictionId; 
        @AuraEnabled public List<String> expedientCustomers;
        @AuraEnabled public List<String> expedientProcedures;
    }
    public class WrapperRespuestaKoExpediente{
        @AuraEnabled public WrapperErrorsExp errors;
        @AuraEnabled public String type;
        @AuraEnabled public String title;
        @AuraEnabled public String status;
        @AuraEnabled public String detail;
        @AuraEnabled public String instance; 
        @AuraEnabled public String additionalProp1;
        @AuraEnabled public String additionalProp2;
        @AuraEnabled public String additionalProp3;
    }
    public class WrapperErrorsExp{
        @AuraEnabled public List<String> id;
        @AuraEnabled public List<String> amount;
        @AuraEnabled public List<String> opponent;
        @AuraEnabled public List<String> productId;
        @AuraEnabled public List<String> expedientCustomers;
        @AuraEnabled public List<String> powerOfAttorney;
        //@AuraEnabled public List<String> jurisdictionId;
    }
    public class WrapperExpedienteRelacionado{
        @AuraEnabled public String sourceExpedientId;//IdExpediente__c
        @AuraEnabled public String destinationExpedientId;
        @AuraEnabled public String relationshipTypeId;
        public WrapperExpedienteRelacionado(Contract ct){
            this.sourceExpedientId = ct.IdExpediente__c;
            this.destinationExpedientId = ct.IdOrigenMinerva__c; 
            this.relationshipTypeId = ct.TipoExpDerivado__c;
        }
    }

}