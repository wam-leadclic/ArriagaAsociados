/*
@author Leadclic Solutions S.L.
@date 15/07/2019
@description Clase de tratamiento de las llamdas a Redsys mediante el merchantURL

<pre>
FECHA               AUTOR   
15/07/2019			LCS - RDM		Creación    
26/08/2019			LCS - RDM		Modificación. Se elimina la creación de expediente y pagos asociados para unificar el proceso y realizar estas creaciones desde el código del Trigger de Oportunidades      

</pre>
*/
@RestResource(urlMapping='/InotificacionSIS')
global class InotificacionSISRest {
    @HttpPost
    global static void notificar () {
        // **** Parametros **** //
			String merchantTerminal;
        	String merchantTransaction;
        	String merchantCurrency;
        	String merchantName;
        	String merchantData;
        	String merchantCode;
        	String Version;
        	String URL;
        	String URL3DES;
        	String PassKey;
        
        // **** MapaRespuesta **** //
        	Map<String, Object> m_datosRespuesta = new Map<String, Object>();
        
        // **** CHECK RESPONSE PARAMS **** //
            String SignatureCheck;
            String SignatureChecked; 
        	String Userlanguage;
        
        // **** Custom settings de respuesta código **** //
        	Redsys_CodigosRespuesta__c Codes;
        
          // **** Datos petición de Redsys **** //
            //Recuperamos la petición de Redsys
            RestRequest req = RestContext.request; 
            //Metemos en el mapa los datos enviados
            Map<String, String> mParam = req.params;  
                String Ds_MerchantParameters = mParam.get('Ds_MerchantParameters');
                String Ds_Signature = mParam.get('Ds_Signature');
                String Ds_SignatureVersion = mParam.get('Ds_SignatureVersion');
        
        try{            
            string texto;
            RedsysDatosLlamada__c datosRedsys = RedsysDatosLlamada__c.getInstance('General');
            map<String, ProductosContrt__c> mProducto = ProductosContrt__c.getAll();
        
            //Clave secreta de cifrado
            	PassKey = datosRedsys.ClaveCifrado__c;            
            //Asignar el código de comercio            
                merchantCode = datosRedsys.FUC__c;
                
                merchantName = datosRedsys.NombreComercio__c;
                merchantData = datosRedsys.Datocomercio__c;
            /*Recogemos la respuesta en este metodo. Lo primero que hacemos es recoger Ds_Signature (firma) y comprobamos que corresponde
			  con la firma que nosotros obtenemos. Para ello cogemos los parametros de respuesta encriptados y los pasamos al metodo para 
			  obtener una firma que luego comprobaremos si coincide con la respuesta.*/
            SignatureCheck = generateSignature(Ds_MerchantParameters, PassKey);
            //system.debug('Ds_MerchantParameters: ' + Ds_MerchantParameters); 
            Ds_Signature = Ds_Signature.replace('_','/').replace('-','+');/*Remplazamos esos caracteres, ya que son causados por la encriptacion Base64Url*/
            //system.debug('Signature : ' + Ds_Signature);  
            //system.debug('SignatureCheck : ' + SignatureCheck); 
            
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
            
            m_datosRespuesta.put('Ds_Order', mapaParametros.get('Ds_Order'));                     
                
            String idPedido = string.valueOf(m_datosRespuesta.get('Ds_Order')); /*recogemos el id de operacion*/
            if(idPedido.startsWith('000')) idPedido = idPedido.substring(4);
            //String numExpediente = '%'+idPedido.substring(4);/*al estar compuesto por el número de expediente y los milisegundos, nos quedamos con el número de expediente*/                                                
            system.debug('Ds_Order : ' + mapaParametros.get('Ds_Order'));
            system.debug('idPedido : ' + idPedido);
            if((SignatureCheck.equals(Ds_Signature)) && (Ds_Signature != '')){                
                /*Si las firmas coinciden continuamos con el codigo:*/
                //system.debug('SignatureCheck == Ds_Signature'); 
                
                /*mapaParametros tiene todos los valores que Redsys nos envian en la respuesta, ya sea OK o sea KO.
				  Lo siguiente que haremos sera crear un nuevo mapa con estos parametros para comprobar el codigo
				  de respuesta y añadir nuevos campos como el significado o si es un OK o KO ese codigo*/
                
                m_datosRespuesta.put('Ds_Date', mapaParametros.get('Ds_Date')); 
                m_datosRespuesta.put('Ds_Hour', mapaParametros.get('Ds_Hour')); 
                m_datosRespuesta.put('Ds_SecurePayment', mapaParametros.get('Ds_SecurePayment')); 
                m_datosRespuesta.put('Ds_Amount', mapaParametros.get('Ds_Amount')); 
                m_datosRespuesta.put('Ds_Currency', mapaParametros.get('Ds_Currency')); 
                m_datosRespuesta.put('Ds_MerchantCode', mapaParametros.get('Ds_MerchantCode')); 
                m_datosRespuesta.put('Ds_Terminal', mapaParametros.get('Ds_Terminal')); 
                m_datosRespuesta.put('Ds_Response_Code', mapaParametros.get('Ds_Response'));
                               
                /*Recogemos el valor del codigo de respuesta*/
                String codigores = string.valueof(mapaParametros.get('Ds_Response'));
            
            	Codes = Redsys_CodigosRespuesta__c.getInstance(codigores);/*de la configuracion personalizamos, cogemos el valor segun el codigo resultado*/
                
                /*Si existe ese codigo: */
                if(Codes != null){
                    //Recuperamos la descripción del código de Redsys                    
                    m_datosRespuesta.put('Ds_Response_Meaning', Codes.Descripcion__c);        
                    if((mapaParametros.get('Ds_Response') == '900') || (mapaParametros.get('Ds_Response') == '400')){m_datosRespuesta.put('Ds_Response', 'KO');}
                    else{m_datosRespuesta.put('Ds_Response', 'KO');}                     
                }
                /*Si no existe comprobamos que la respuesta esta entre 0000 y el 0099*/
                else if(m_datosRespuesta.get('Ds_Response') != 'OK'){         
                    //los codigos del 0000 al 0099 significan una autorización. Comprobamos que esta en ese rango:
                    for(integer i=0000; i<0100; i++){
                        if(i == integer.valueof(mapaParametros.get('Ds_Response'))){
                            Codes = Redsys_CodigosRespuesta__c.getInstance('0to99');/*Valores de la configuracion personalizada segun el codigo*/
                            
                            m_datosRespuesta.put('Ds_Response_Meaning', Codes.Descripcion__c);
                            m_datosRespuesta.put('Ds_Response', 'OK'); 
                            i = 1000;
                        }
                        else{m_datosRespuesta.put('Ds_Response', 'KO'); }
                    }
                }
                /*Si no existe el valor en la lista personalizada, le añadimos un valor generico*/
                if((m_datosRespuesta.get('Ds_Response') != 'OK') && (Codes == null)){
                    Codes = Redsys_CodigosRespuesta__c.getInstance('NonExistCode');/*Valores de la configuracion personalizada segun el codigo*/
                    m_datosRespuesta.put('Ds_Response_Meaning', Codes.Descripcion__c);
                    m_datosRespuesta.put('Ds_Response', 'KO');                     
                }
                
                m_datosRespuesta.put('Ds_TransactionType', mapaParametros.get('Ds_TransactionType')); 
                m_datosRespuesta.put('Ds_MerchantData', mapaParametros.get('Ds_MerchantData')); 
                m_datosRespuesta.put('Ds_AuthorisationCode', mapaParametros.get('Ds_AuthorisationCode')); 
                m_datosRespuesta.put('Ds_ConsumerLanguage', mapaParametros.get('Ds_ConsumerLanguage'));
                
                
                /*Una vez creado el mapa que enviaremos por el metodo, Realizamos los inserts necesarios para guardar todo como lineas de pedido*/
                try{
                    //system.debug('Realizamos un INSERT');
                    /*Transformamos todos los valores que necesitamos en los insert en String*/
                    String fucComercio = string.valueOf(m_datosRespuesta.get('Ds_MerchantCode'));  
                    String insertAmount = string.valueOf(m_datosRespuesta.get('Ds_Amount')); 
						insertAmount = insertAmount.substring(0, insertAmount.length()-2) + '.' + insertAmount.substring(insertAmount.length()-2);                	
                
                	String fecha = string.valueof(m_datosRespuesta.get('Ds_Date')).replace('%2F','-');
                	String hora = string.valueof(m_datosRespuesta.get('Ds_Hour')).replace('%3A',':');
               	 	String fechaHora = fecha + ' ' + hora +':00';
                
                    String res = string.valueOf(m_datosRespuesta.get('Ds_Response'));
                    String rescod = string.valueOf(m_datosRespuesta.get('Ds_Response_Code'));
                    String resdes = string.valueOf(m_datosRespuesta.get('Ds_Response_Meaning'));
                
                    String secure = string.valueOf(m_datosRespuesta.get('Ds_SecurePayment')); 
                    String curr = string.valueOf(m_datosRespuesta.get('Ds_Currency'));  
                    String terminal = string.valueOf(m_datosRespuesta.get('Ds_Terminal')); 
                    String transtype = string.valueOf(m_datosRespuesta.get('Ds_TransactionType')); 
                    String merchdata = string.valueOf(m_datosRespuesta.get('Ds_MerchantData')); 
                    String authcod = string.valueOf(m_datosRespuesta.get('Ds_AuthorisationCode')); 
                    String conslangua = string.valueOf(m_datosRespuesta.get('Ds_ConsumerLanguage'));                                                                           
                    
                    //system.debug('******/RES2 : ' + res);
                    if(res == 'OK'){
                        /*Al ser OK el resultado final, cargamos el mensaje de Pago realizado*/
                        Codes = Redsys_CodigosRespuesta__c.getInstance('OK');/*Valores de la configuracion personalizada segun el codigo*/
                        m_datosRespuesta.put('BeginMessage', Codes.Descripcion__c); 
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
                        
                        //Enviamos el valor del producto que se está contratando
                        string nombreProd = p.Name;
                        list<string> prods = new list<string>();                        
                        for (String key : mProducto.keySet()){
                            if(key == nombreProd){
                                texto = mProducto.get(nombreProd).NameProduct__c;
                            }
                            else{
                                prods.add(Key);
                            }
                        }
                        
                         m_datosRespuesta.put('ListaProds', prods);
                        /*if(mProducto.containsKey(nombreProd)){
                            texto = mProducto.get(nombreProd).NameProduct__c;
                        }*/
                    }else{
                        /*Al ser ko el resultado final, cargamos el mensaje de Error que ira antes de mostrar el codigo y el significado*/
                        Codes = Redsys_CodigosRespuesta__c.getInstance('KO');/*Valores de la configuracion personalizada segun el codigo*/
                        m_datosRespuesta.put('BeginMessage', Codes.Descripcion__c);                                                   
                    }                    
                }
                catch(Exception e){
                    if(!system.Test.isRunningTest()) throw new myException('Error al guardar el pago '+e.getMessage());                                                      
                    else system.debug('Error insert : ' + e.getMessage());
                }
                
                SignatureChecked = 'OK';
            }else{
                /*Si las firmas no coinciden, terminamos el codigo y devolvemos un mensaje de fallo.*/
                //system.debug('SignatureCheck != Ds_Signature'); 
                SignatureChecked = 'KO'; 
                
                /*Al ser KO FIRMA el resultado final, cargamos el mensaje de firma erronea*/
                Codes = Redsys_CodigosRespuesta__c.getInstance('KOFirma');/*Valores de la configuracion personalizada segun el codigo*/
                m_datosRespuesta.put('BeginMessage', Codes.Descripcion__c);                    
            }            
        
        	m_datosRespuesta.put('Firma', SignatureChecked);
            m_datosRespuesta.put('TextoPago', texto);
			//system.debug('Datos : ' + m_datosRespuesta);
        }
        catch(Exception e){
            if(!system.Test.isRunningTest()) throw new myException('Error en la comprobación de la firma de respuesta '+e.getMessage());                           
            else system.debug('Error al realizar comprobacion : ' + e.getMessage());
        }
    }
    	    
    /****METODOS AUXILIARES*****/ 
     /*
    @description    Método que llama a Google Cloud para hacer el cifrado 3DES
    @param          MERCHANTPARAMETERS --> Parametros a cifrar
    @param          PassKeyComercio --> clave de comercio a cifrar    
    @return         Devuelve la firma en 3DES que se ha generado
    */
	public static String generateSignature( String MERCHANTPARAMETERS, String PassKeyComercio){			        
        String URL3DES = system.Label.URLEncriptacion;
        String Firma;
        /* LLamada a servicio google donde se alojara los metodos de encriptacion en 3DES */		  
        /*****CALLING TO A WEB SERVICE*****/
        	//system.debug('Inicio Request');
            try{
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                req.setMethod('GET');
                req.setEndpoint(URL3DES + '?param='+MERCHANTPARAMETERS+'&key='+PassKeyComercio);
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