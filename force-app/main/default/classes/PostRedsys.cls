/*
@author Leadclic Solutions S.L.
@date 15/03/2019
@description Clase de peticion y tratamiento de las llamdas a Redsys

<pre>
FECHA               AUTOR   
15/03/2019			LCS - RMG		Creación.
18/03/2019			LCS - RDM		Modificación. Se completa clase de llamada y respuesta a Redsys
06/05/2019			LCS - RDM		Modificación. Se le añade substring(4) al numExpediente para quitar los 4 primeros dígitos ya que el formato del campos es: {YY}{MM}{99999}
26/07/2019			LCS - RDM		Modificación. Se le añade el cierre de la oportunidad al crear expediente
26/08/2019			LCS - RDM		Modificación. Se elimina la creación de expediente y pagos asociados para unificar el proceso y realizar estas creaciones desde el código del Trigger de Oportunidades 

</pre>
*/

public without sharing class PostRedsys {
    
    public Map<String, Object> m_datosPost = new Map<String, Object>();
    public Map<String, Object> m_datosRespuesta = new Map<String, Object>();

    //configuracion con los datos de codigos y mensaje de la respuesta en diferentes idiomas
	Redsys_CodigosRespuesta__c Codes;        
    
	/*****URL PARAMS*****/
    private String URL = System.label.REDSYSURL;
    //TEST REDSY: https://sis-t.redsys.es:25443/sis/realizarPago
    ////Producción REDSY: https://sis.redsys.es/sis/realizarPago
    
	/*****DS_SIGNATUREVERSION PARAMS*****/
	private String Version = 'HMAC_SHA256_V1';	
	
	/*****DS_MERCHANTPARAMETERS PARAMS*****/
	private String ParametersNOCodc;
	private String ParametersCodec;	
    private String merchantOrderId;
	private String merchantCode; 
	private String merchantTerminal = '1';
	private String merchantTransaction = '0';//0 --> Autorizado
	private String merchantCurrency = '978';//Euros
	private String merchantUrl;
	private String merchantUrlok;
	private String merchantUrlko;
	private String merchantName;
	private String merchantData; 
	private String merchantDescription;
    
    /*****CRYPTO 3DES URL PARAMS*****/
    private String URL3DES = system.Label.URLEncriptacion;
    
	/*****DS_SIGNATURE PARAMS*****/
	private String PassKey; //TODO: Falta indicar la clave para el pago;
	private String Signature;
	
	/*****CHECK RESPONSE PARAMS*****/
	private String SignatureCheck;
    private String SignatureChecked; 
    private String Userlanguage;    
        
	/*****CREATION PARAM FOR POST*****/ 
    /*
    @description    Método que se encarga de generar la llamada a Redsys
    @param          idOpp --> Oportunidad de la que partimos
    @param          Amount --> Cantidad que se tiene que pagar
    @param          FullName --> Nombre de la persona que realiza el pago   
    @param          description --> Información del pago que se va a realizar
    @return         Devuelve un mapa con la información necesaria para realizar la llamada a Redsys desde el componente
    */
    @AuraEnabled
    public static Map<String, Object> creationParams(String idOpp, String Amount, String FullName, String description){           
        PostRedsys post = new PostRedsys();
        RedsysDatosLlamada__c datosRedsys = RedsysDatosLlamada__c.getInstance('General');
            map<String, ProductosContrt__c> mProducto = ProductosContrt__c.getAll();
        
        
        //Clave secreta de cifrado
            post.PassKey = datosRedsys.ClaveCifrado__c;            
        //Asignar el código de comercio            
            post.merchantCode = datosRedsys.FUC__c;
        
        	post.merchantName = datosRedsys.NombreComercio__c;
        	post.merchantData = datosRedsys.Datocomercio__c;
        
       // //system.debug('Datos llamada : ' + post.PassKey + '--'+datosRedsys.ClaveCifrado__c);
        
        /*Recuperamos la url del buscador*/
        String url = URL.getSalesforceBaseUrl().toExternalForm();
        /*Indicamos las urls de envio para respuesta para que nos lo envien a la solicitud obtenida anteriormente:*/
        post.merchantUrl = url + datosRedsys.InotificacionSIS__c;
        post.merchantUrlko = url+'/s/casopagoko';
        
        //Obtenemos el Id del producto dentre de la contratación online
        CommunityOpp__c contr = [SELECT id, IDProducto__c, Oportunidad__r.NumeroExpediente__c FROM CommunityOpp__c WHERE Oportunidad__c = :idOpp];
 
        //Obtenemos el nombre del producto
        Product2 p = [SELECT Name FROM Product2 WHERE Id =:contr.IDProducto__c];

		//Comprobamos el producto a contratar y vemos el campo siempre pago que es donde vemos si puede llegar a ser pago    
        string nombreProd = p.Name;                    
        if(mProducto.containsKey(p.Name)){
            if(mProducto.get(nombreProd).SiemprePago__c){
                //Si es un producto de siempre pago, le enviamos a una página estática
                post.merchantUrlok = url+'/s/redsys-pago';  
            }else{
                //si puede ser gratis, le enviamos a la página donde comprobará el resto de prod que le pueden salir gratis
                post.merchantUrlok = url+'/s/pago-redsys';
            }
        }    
        try{	            
            /*convertimos a string la variable Amount que nos llega desde el flujo.*/
            Amount = string.valueOf(Amount);

            /*Tratamos la cantidad para poder enviar el dato tal como se pide (sin . ni , y los dos ultimos Nº decimales)*/
            Amount = Amount.replace('.', ',');
                        
            if(Amount.contains(',')){           
                /*Comprobamos cuantos decimales contiene*/
                String[] entry = Amount.split(',');
                integer decimales = entry[1].trim().length();
                /*Si contiene un unico decimal, le añadimos otro*/
                if(decimales < 2){
                    Amount += '0';
                }  
                Amount = Amount.replace(',', '');
            }else{
                //Si no contiene decimales, le añadimos 2 ceros
                Amount += '00';
            }
            
            /*Montamos el Merchant order id (numero de operacion) - 4 primers digitos numeros y hasta un max de 12 caracteres*/
            string numExpediente = contr.Oportunidad__r.NumeroExpediente__c;
            DateTime Dnow = DateTime.now();
            String miliseconds = string.valueOf(Dnow.millisecond());
            
            //Se le añade substring(4) al numExpediente para quitar los 4 primeros dígitos ya que el formato del campos es: {YY}{MM}{99999}
        	post.merchantOrderId = numExpediente;                      
            
            /*Montamos el JSON de envío sin espacios ni saltos de linea*/
            post.ParametersNOCodc = '{"DS_MERCHANT_ORDER":"'+ post.merchantOrderId +'","DS_MERCHANT_TERMINAL":"'+ post.merchantTerminal +'","DS_MERCHANT_URLOK":"'+ post.merchantUrlok +'","DS_MERCHANT_URLKO":"'+ post.merchantUrlko +'","DS_MERCHANT_PRODUCTDESCRIPTION":"'+ description +'","DS_MERCHANT_TITULAR":"'+ FullName +'","DS_MERCHANT_CURRENCY":"'+ post.merchantCurrency +'","DS_MERCHANT_TRANSACTIONTYPE":"'+ post.merchantTransaction +'","DS_MERCHANT_MERCHANTURL":"'+ post.merchantUrl +'","DS_MERCHANT_PRODUCTDESCRIPTION":"'+ description +'","DS_MERCHANT_MERCHANTNAME":"'+ post.merchantName +'","DS_MERCHANT_AMOUNT":"'+ Amount +'","DS_MERCHANT_MERCHANTDATA":"'+ post.merchantData +'","DS_MERCHANT_MERCHANTCODE":"'+ post.merchantCode +'"}';
            ////system.debug('JSON FORMAT AND WITHOUT SPACES : ' + post.ParametersNOCodc);
            
            /*Codificamos el JSON en base 64*/
            Blob Codificando = Blob.valueOf(post.ParametersNOCodc);		
            post.ParametersCodec = EncodingUtil.base64Encode(Codificando);
            ////system.debug('Parametros codificados :  ' + post.ParametersCodec);
            
            /*Llamamos a la funcion para generar la firma en 3DES, correspondiente a los parametros codificados */          
        	post.Signature = generateSignature(post.ParametersCodec, post.PassKey);		
            ////system.debug('Firma final : ' + post.Signature);
            
            /*Creamos un mapa con todos los valores necesarios para realizar la llamada*/
            //post.m_datosPost.put('URLTEST', post.URLTest);        
            post.m_datosPost.put('URL', post.URL);
            post.m_datosPost.put('DS_SIGNATUREVERSION', post.Version);
            post.m_datosPost.put('DS_MERCHANTPARAMETERS', post.ParametersCodec);
            post.m_datosPost.put('DS_SIGNATURE', post.Signature);            
            
            ////system.debug('Datos finales : ' + post.m_datosPost);
        }catch(Exception e){     
            if(!system.Test.isRunningTest()) throw new myException('Error al llamar a la pasarela de pago '+e.getMessage() + e.getStackTraceString());                    
            else system.debug('Error al realizar comprobacion : ' + e.getMessage());
        }
        
        return post.m_datosPost;
    }    

    /*
    @description    Método que se encarga de tratar el resultado de la llamada de Redsys
    @param          Ds_SignatureVersion --> datos de Redsys para validar el resultado obtenido
    @param          Ds_MerchantParameters --> datos de Redsys para validar el resultado obtenido
    @param          Ds_Signature --> datos de Redsys para validar el resultado obtenido
    @return         Devuelve un mapa con la información necesaria para indicar si la llamada a Redsys ha sido correcto y mostrarlo en el componente
    */
    @AuraEnabled
    public static Map<String, Object> transformarResponse(String Ds_SignatureVersion, String Ds_MerchantParameters, String Ds_Signature){         
        PostRedsys post = new PostRedsys();
        try{            
            string texto;
            RedsysDatosLlamada__c datosRedsys = RedsysDatosLlamada__c.getInstance('General');
            map<String, ProductosContrt__c> mProducto = ProductosContrt__c.getAll();
        
            //Clave secreta de cifrado
            	post.PassKey = datosRedsys.ClaveCifrado__c;            
            //Asignar el código de comercio            
                post.merchantCode = datosRedsys.FUC__c;
                
                post.merchantName = datosRedsys.NombreComercio__c;
                post.merchantData = datosRedsys.Datocomercio__c;
            /*Recogemos la respuesta en este metodo. Lo primero que hacemos es recoger Ds_Signature (firma) y comprobamos que corresponde
			  con la firma que nosotros obtenemos. Para ello cogemos los parametros de respuesta encriptados y los pasamos al metodo para 
			  obtener una firma que luego comprobaremos si coincide con la respuesta.*/
            post.SignatureCheck = generateSignature(Ds_MerchantParameters, post.PassKey);
            //system.debug('Ds_MerchantParameters: ' + Ds_MerchantParameters); 
            Ds_Signature = Ds_Signature.replace('_','/').replace('-','+');/*Remplazamos esos caracteres, ya que son causados por la encriptacion Base64Url*/
            //system.debug('Signature : ' + Ds_Signature);  
            //system.debug('SignatureCheck : ' + post.SignatureCheck); 
            
            /*Decodificamos los parametros obtenidos para guardar los valores para poder obtener el numero de expediente*/               
            Blob Decodificando = EncodingUtil.base64Decode(Ds_MerchantParameters);
            String Parametros = Decodificando.toString();
            Parametros = Parametros.substring(1, Parametros.length()-1);
            
            //system.debug('Parametros Decodificados :  ' + Parametros );
            
            String[] keyValuePairs = Parametros.split(',');    
            
            //system.debug('keyValuePairs :  ' + keyValuePairs );
            
            Map<String,String> mapaParametros = new Map<String,String>();
            for(String pair : keyValuePairs){
                pair = pair.replace('"','');
                
                //system.debug('pair :  ' + pair);
                
                String[] entry = pair.split(':');      
                mapaParametros.put(entry[0].trim(), entry[1].trim());          
            }
            
            post.m_datosRespuesta.put('Ds_Order', mapaParametros.get('Ds_Order'));                     
                
            String idPedido = string.valueOf(post.m_datosRespuesta.get('Ds_Order')); /*recogemos el id de operacion*/
            if(idPedido.startsWith('000')) idPedido = idPedido.substring(4);
            //String numExpediente = '%'+idPedido.substring(4);/*al estar compuesto por el número de expediente y los milisegundos, nos quedamos con el número de expediente*/                                                
            system.debug('Ds_Order : ' + mapaParametros.get('Ds_Order'));
            system.debug('idPedido : ' + idPedido);
            if((post.SignatureCheck.equals(Ds_Signature)) && (Ds_Signature != '')){                
                /*Si las firmas coinciden continuamos con el codigo:*/
                //system.debug('SignatureCheck == Ds_Signature'); 
                
                /*mapaParametros tiene todos los valores que Redsys nos envian en la respuesta, ya sea OK o sea KO.
				  Lo siguiente que haremos sera crear un nuevo mapa con estos parametros para comprobar el codigo
				  de respuesta y añadir nuevos campos como el significado o si es un OK o KO ese codigo*/
                
                post.m_datosRespuesta.put('Ds_Date', mapaParametros.get('Ds_Date')); 
                post.m_datosRespuesta.put('Ds_Hour', mapaParametros.get('Ds_Hour')); 
                post.m_datosRespuesta.put('Ds_SecurePayment', mapaParametros.get('Ds_SecurePayment')); 
                post.m_datosRespuesta.put('Ds_Amount', mapaParametros.get('Ds_Amount')); 
                post.m_datosRespuesta.put('Ds_Currency', mapaParametros.get('Ds_Currency')); 
                post.m_datosRespuesta.put('Ds_MerchantCode', mapaParametros.get('Ds_MerchantCode')); 
                post.m_datosRespuesta.put('Ds_Terminal', mapaParametros.get('Ds_Terminal')); 
                post.m_datosRespuesta.put('Ds_Response_Code', mapaParametros.get('Ds_Response'));
                               
                /*Recogemos el valor del codigo de respuesta*/
                String codigores = string.valueof(mapaParametros.get('Ds_Response'));
            
            	post.Codes = Redsys_CodigosRespuesta__c.getInstance(codigores);/*de la configuracion personalizamos, cogemos el valor segun el codigo resultado*/
                
                /*Si existe ese codigo: */
                if(post.Codes != null){
                    //Recuperamos la descripción del código de Redsys                    
                    post.m_datosRespuesta.put('Ds_Response_Meaning', post.Codes.Descripcion__c);        
                    if((mapaParametros.get('Ds_Response') == '900') || (mapaParametros.get('Ds_Response') == '400')){post.m_datosRespuesta.put('Ds_Response', 'KO');}
                    else{post.m_datosRespuesta.put('Ds_Response', 'KO');}                     
                }
                /*Si no existe comprobamos que la respuesta esta entre 0000 y el 0099*/
                else if(post.m_datosRespuesta.get('Ds_Response') != 'OK'){         
                    //los codigos del 0000 al 0099 significan una autorización. Comprobamos que esta en ese rango:
                    for(integer i=0000; i<0100; i++){
                        if(i == integer.valueof(mapaParametros.get('Ds_Response'))){
                            post.Codes = Redsys_CodigosRespuesta__c.getInstance('0to99');/*Valores de la configuracion personalizada segun el codigo*/
                            
                            post.m_datosRespuesta.put('Ds_Response_Meaning', post.Codes.Descripcion__c);
                            post.m_datosRespuesta.put('Ds_Response', 'OK'); 
                            i = 1000;
                        }
                        else{post.m_datosRespuesta.put('Ds_Response', 'KO'); }
                    }
                }
                /*Si no existe el valor en la lista personalizada, le añadimos un valor generico*/
                if((post.m_datosRespuesta.get('Ds_Response') != 'OK') && (post.Codes == null)){
                    post.Codes = Redsys_CodigosRespuesta__c.getInstance('NonExistCode');/*Valores de la configuracion personalizada segun el codigo*/
                    post.m_datosRespuesta.put('Ds_Response_Meaning', post.Codes.Descripcion__c);
                    post.m_datosRespuesta.put('Ds_Response', 'KO');                     
                }
                
                post.m_datosRespuesta.put('Ds_TransactionType', mapaParametros.get('Ds_TransactionType')); 
                post.m_datosRespuesta.put('Ds_MerchantData', mapaParametros.get('Ds_MerchantData')); 
                post.m_datosRespuesta.put('Ds_AuthorisationCode', mapaParametros.get('Ds_AuthorisationCode')); 
                post.m_datosRespuesta.put('Ds_ConsumerLanguage', mapaParametros.get('Ds_ConsumerLanguage'));
                
                
                /*Una vez creado el mapa que enviaremos por el metodo, Realizamos los inserts necesarios para guardar todo como lineas de pedido*/
                try{
                    //system.debug('Realizamos un INSERT');
                    /*Transformamos todos los valores que necesitamos en los insert en String*/
                    String fucComercio = string.valueOf(post.m_datosRespuesta.get('Ds_MerchantCode'));  
                    String insertAmount = string.valueOf(post.m_datosRespuesta.get('Ds_Amount')); 
						insertAmount = insertAmount.substring(0, insertAmount.length()-2) + '.' + insertAmount.substring(insertAmount.length()-2);                	
                
                	String fecha = string.valueof(post.m_datosRespuesta.get('Ds_Date')).replace('%2F','-');
                	String hora = string.valueof(post.m_datosRespuesta.get('Ds_Hour')).replace('%3A',':');
               	 	String fechaHora = fecha + ' ' + hora +':00';
                
                    String res = string.valueOf(post.m_datosRespuesta.get('Ds_Response'));
                    String rescod = string.valueOf(post.m_datosRespuesta.get('Ds_Response_Code'));
                    String resdes = string.valueOf(post.m_datosRespuesta.get('Ds_Response_Meaning'));
                
                    String secure = string.valueOf(post.m_datosRespuesta.get('Ds_SecurePayment')); 
                    String curr = string.valueOf(post.m_datosRespuesta.get('Ds_Currency'));  
                    String terminal = string.valueOf(post.m_datosRespuesta.get('Ds_Terminal')); 
                    String transtype = string.valueOf(post.m_datosRespuesta.get('Ds_TransactionType')); 
                    String merchdata = string.valueOf(post.m_datosRespuesta.get('Ds_MerchantData')); 
                    String authcod = string.valueOf(post.m_datosRespuesta.get('Ds_AuthorisationCode')); 
                    String conslangua = string.valueOf(post.m_datosRespuesta.get('Ds_ConsumerLanguage'));                                                                           
                    
                    //system.debug('******/RES2 : ' + res);
                    if(res == 'OK'){
                        /*Al ser OK el resultado final, cargamos el mensaje de Pago realizado*/
                        post.Codes = Redsys_CodigosRespuesta__c.getInstance('OK');/*Valores de la configuracion personalizada segun el codigo*/
                        post.m_datosRespuesta.put('BeginMessage', post.Codes.Descripcion__c); 
                        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults(); //cargamos configuración para obtener el estado de la oportunidad que se utiliza al cerrarla
                        //Obtenemos los datos necesarios de la oportunidad con el número de expediente
                         //Opportunity opp = [SELECT Amount, AccountId, Pricebook2Id FROM Opportunity Where NumeroExpediente__c =:idPedido];
                        //Obtenemos el Id del producto dentre de la contratación online
                         CommunityOpp__c contr = [SELECT id, IDProducto__c, Oportunidad__c, Oportunidad__r.Amount, Oportunidad__r.AccountId, Oportunidad__r.Pricebook2Id, Oportunidad__r.NumeroExpediente__c,
                                                  	Oportunidad__r.DocumentosCompletado__c, Oportunidad__r.DocumentosContratacion__c, Oportunidad__r.DocumentosCompletadoAportado__c, 
                                                  	Oportunidad__r.DocumentosContratacionAportado__c, Oportunidad__r.Tipo__c, Oportunidad__r.PrecioTotal__c, Oportunidad__r.OwnerId
                                                  	FROM CommunityOpp__c WHERE Oportunidad__r.NumeroExpediente__c =:idPedido];
                        //Obtenemos el nombre del producto
                         Product2 p = [SELECT Id, Name FROM Product2 WHERE Id =:contr.IDProducto__c];
						
                        //Comprobamos que el Expediente no ha sido ya insertado:
                        List<Contract> existeExp = [SELECT Id FROM Contract WHERE IdExpediente__c = :idPedido];
                        if(existeExp.isEmpty()){
                            CommunityOpp__c c = new CommunityOpp__c();
                                c.id = contr.Id;
                                c.Gratis__c = false;
                                c.ContrFinalizado__c = true;
                            update c;
                            
                            List<Opportunity> lOppComunidadCerrada = new List<Opportunity>();
                                Opportunity updateOpp = new Opportunity();
                                    updateOpp.Id = contr.Oportunidad__c;
                                    updateOpp.Tipo__c = 'TPV';
                                    updateOpp.StageName = configDatosflujo.EtapaFinalOportunidadContrOnline__c;
                                update updateOpp;
                             	Opportunity opp = [SELECT id, Amount, AccountId, Pricebook2Id, NumeroExpediente__c, DocumentosCompletado__c, DocumentosContratacion__c, DocumentosCompletadoAportado__c, 
                                                  	DocumentosContratacionAportado__c, Tipo__c, PrecioTotal__c, OwnerId
                                                  	FROM Opportunity WHERE Id =: contr.Oportunidad__c];
                            lOppComunidadCerrada.add(opp);
                            
            				//Llamamos al método que crea los expedientes para las oportunidades cerradas/ganadas
                            list<Contract> lExpedientes = TriggerOpportunityHandler.crearExpedientes(lOppComunidadCerrada);
                            insert lExpedientes;
                            Contract expediente = new Contract();
                             expediente.Id = lExpedientes[0].Id;

                            
                            //Movemos la documentación que se tenga en la oportunidad al contrato
                            TriggerOpportunityHandler.moverDocumentosDeOportunidadAExpediente (lExpedientes); 
                            //Creamos los pagos relacionados
                            List<Pago__c> lPagos = TriggerOpportunityHandler.crearPago (lExpedientes); 
                            //Actualizamos las cuentas relacionadas para pasar al estado "Cliente"
                            TriggerOpportunityHandler.cambioEstadoCliente (lExpedientes); 
                            
                            //Insertamos los pagos creados
                            if(!lPagos.isEmpty()) insert lPagos;
                                                        
                            list<ContentDocumentLink> ldocins = new list<ContentDocumentLink>();
                            list<ContentDocumentLink> ldocdel = new list<ContentDocumentLink>();
                            list<ContentDocumentLink> lcd = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId =:contr.id];
                            for(ContentDocumentLink cd : lcd){
                                ContentDocumentLink insertCd = cd.clone();
                                insertCd.LinkedEntityId = expediente.id;
                                insertCd.ShareType = cd.ShareType;
                                ldocins.add(insertCd);
                                ldocdel.add(cd);
                            }
                            if(!ldocins.isEmpty() && ldocins != null) insert ldocins;
                            if(!ldocdel.isEmpty() && ldocdel != null) delete ldocdel;
                        }
                            
                        //Enviamos el valor del producto que se está contratando
                        string nombreProd = p.Name;
                        list<string> prods = new list<string>();                        
                        for (String key : mProducto.keySet()){
                            if(key == nombreProd){
                                texto = mProducto.get(nombreProd).NameProduct__c;
                            }
                            else{
                                if(!mProducto.get(key).SiemprePago__c) prods.add(Key);
                            }
                        }
                         post.m_datosRespuesta.put('ListaProds', prods);
                        /*if(mProducto.containsKey(nombreProd)){
                            texto = mProducto.get(nombreProd).NameProduct__c;
                        }*/
                    }else{
                        /*Al ser ko el resultado final, cargamos el mensaje de Error que ira antes de mostrar el codigo y el significado*/
                        post.Codes = Redsys_CodigosRespuesta__c.getInstance('KO');/*Valores de la configuracion personalizada segun el codigo*/
                        post.m_datosRespuesta.put('BeginMessage', post.Codes.Descripcion__c);                                                   
                    }                    
                }
                catch(Exception e){
                    if(!system.Test.isRunningTest()) throw new myException('Error al guardar el pago '+e.getMessage());                                                      
                    else system.debug('Error insert : ' + e.getMessage());
                }
                
                post.SignatureChecked = 'OK';
            }else{
                /*Si las firmas no coinciden, terminamos el codigo y devolvemos un mensaje de fallo.*/
                //system.debug('SignatureCheck != Ds_Signature'); 
                post.SignatureChecked = 'KO'; 
                
                /*Al ser KO FIRMA el resultado final, cargamos el mensaje de firma erronea*/
                post.Codes = Redsys_CodigosRespuesta__c.getInstance('KOFirma');/*Valores de la configuracion personalizada segun el codigo*/
                post.m_datosRespuesta.put('BeginMessage', post.Codes.Descripcion__c);                    
            }            
        
        	post.m_datosRespuesta.put('Firma', post.SignatureChecked);
            post.m_datosRespuesta.put('TextoPago', texto);
			//system.debug('Datos : ' + post.m_datosRespuesta);
        }
        catch(Exception e){
            if(!system.Test.isRunningTest()) throw new myException('Error en la comprobación de la firma de respuesta '+e.getMessage());                           
            else system.debug('Error al realizar comprobacion : ' + e.getMessage());
        }
        
        return post.m_datosRespuesta;
    }

    /*
    @description    Método que se encarga de crear el caso al recibir un pago KO
    @param          Asunto --> texto indicado en el asunto del caso
    @param          Descripcion --> texto indicado en la descripción del caso
    @param          ds_order --> dsorder de la respuesta de redsys
    @return         Devuelve la URL del nuevo caso abierto con los datos indicados y relacionado con la cuenta 
    */
    @AuraEnabled
    public static String CrearCaso(string Asunto, String Descripcion, String ds_order){
        if(ds_order.startsWith('000')) ds_order = ds_order.substring(4);
		system.debug('TESTCLASE ++++++ ds_order ++++++ ' + ds_order);
        //Utilizamos el id del pago para obtener los datos necesarios del Expediente para unir el caso        
        List<Contract> lExpediente = [SELECT AccountId, Pricebook2Id FROM Contract WHERE IdExpediente__c =:ds_order];
        
        if(!lExpediente.isEmpty()){
            Case c = new Case();
                c.Subject = Asunto;
                c.Description = Descripcion;
                c.AccountId = lExpediente[0].AccountId;
                c.Type = Label.CasoTipoErrorPago;
                c.Reason = Label.CasoMotivoErrorPago;
            insert c;
            
            String url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+c.id;
            return url;
        }else return null;       
    }

    /*
    @description    Método que se encarga de obtener la url de la configuración personalizado donde posteriormente redireccionaremos para la nueva contratación
    @param          nProducto --> Nombre del producto a buscar en la configuración personalizada
    @param          botonPulsado --> Botón pulsado. Info o contratación
    @return         Devuelve un mapa de string con la URL a redireccionar y el target (si es en la misma ventana o diferente)
    */
    @AuraEnabled
    public static map<String, String> obtenerURLdeContratcion(string nProducto, string botonPulsado){
        map<String, ProductosContrt__c> mProducto = ProductosContrt__c.getAll();
        map<String, String> resultado = new map<String, String>();
        String url = URL.getSalesforceBaseUrl().toExternalForm();
        String target;
        
        if(botonPulsado.contains('Info')){
            if(mProducto.containsKey(nProducto)){  
                url = mProducto.get(nProducto).URLArriaga__c;
                target = '_blank';
            }
            else {
                url = 'Error - Producto no encontrado. Póngase en contacto con su administrador.';
                target = '';
            }     
        }else{
            if(mProducto.containsKey(nProducto)){  
                url += mProducto.get(nProducto).URLContratacion__c;
                target = '_self';
            }
            else {
                url = 'Error - Producto no encontrado. Póngase en contacto con su administrador.';
                target = '';
            }            
        }
            resultado.put('url', url);
            resultado.put('target', target);
        return resultado;        
    }
    	    
    /****METODOS AUXILIARES*****/ 
     /*
    @description    Método que llama a Google Cloud para hacer el cifrado 3DES
    @param          MERCHANTPARAMETERS --> Parametros a cifrar
    @param          PassKeyComercio --> clave de comercio a cifrar    
    @return         Devuelve la firma en 3DES que se ha generado
    */
	public static String generateSignature(String MERCHANTPARAMETERS, String PassKeyComercio){			        
        PostRedsys post = new PostRedsys();
        String Firma;
        /* LLamada a servicio google donde se alojara los metodos de encriptacion en 3DES */		  
        /*****CALLING TO A WEB SERVICE*****/
        	//system.debug('Inicio Request');
            try{
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod('GET');
                req.setEndpoint(post.URL3DES + '?param='+MERCHANTPARAMETERS+'&key='+PassKeyComercio);
                //system.debug('request : ' + req);
                HTTPResponse resp = http.send(req);
                Firma=resp.getBody();
                //system.debug('Firma : ' + Firma);
            }catch(Exception e){         
                if(!system.Test.isRunningTest()) throw new myException('Error al generar la firma 3DES '+e.getMessage());                      
                else system.debug('Error request localhost: '+e.getMessage());
            }
        /********FIN********/
        return Firma;
	}
    
//Método para generar una excepción personalizada    
public class myException extends Exception {}    
        
}