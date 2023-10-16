/*
@author LeadClic Solutions S.L.
@date 08/05/2019
@description Clase manejadora del trigger de oportunidades

<pre>
FECHA             AUTOR           ACCION
08/05/2019		LCS - RMG	   	  Creación. 
13/06/2019		LCS - RDM	   	  Modificación. Se añade comprobación de los documentos básicos para llamar a minerva o producción. Si estan aportados y en cerrada-ganada, se enviará la información a Minerva. 
19/06/2019		LCS - RDM	   	  Modificación. Se elimina comprobaciones para Minerva, ya que se hará en Expediente. Se añade la actualización del expediente sobre la documentación aportada
27/06/2019      LCS - RDM         Modificación. Se elimina la comprobación de la aportacion de documentación básica para pasarla al expediente y se comprueba antes de actualizar el estado a cerrada/ganada
                                                si la documentacion de contratación ha sido aportada
30/07/2019      LCS - RDM         Modificación. Se añade comprobación de los campos de la oportunidad correspondientes al pago y se crea un pago relacionado al expediente que se crea con los datos del pago de la opp que
												asignamos también al expediente.
22/08/2019      LCS - RMG         Modificación. Si la oportunidad pasa a cerrada ganada se comprueba que si hay una función de contacto que sea menor de edad o incapacitado se tenga 
                                                otra función de contacto que sea representante legal
26/08/2019      LCS - RMG         Modificación. Se modifica la comprobación del menor de edad y el incapacitado. Si es menor de edad tiene que existir un representante legal o tutor. 
                                                Si es incapacitado tiene que existir el tutor.   
27/08/2019		LCS - RDM	   	  Modificación. Se cambia la comprobación del campo de creado por comunidad para comenzar a realizar esta comprobación por el perfil que ejecuta el trigger. Se saltará las comprobaciones los perfiles de
												alumno comunidad y el perfil de usuario guest. Se añade comprobación cuando se pasa al estado de Pago
28/08/2019		LCS - RDM	   	  Modificación. Se añade el método que obtiene el usuario ejecutor y devuelve la oficina correspondiente de ese usuario
03/09/2019 		LCS - RDM		  Modificación. Asignamos al expediente un tipo de registro concreto en funcion del campo fórmula del producto RecordTypeExpediente__c
01/10/2019 		LCS - GQG		  Modificación. Validación de hoja de encargo, con el caso de uso de la hoha de encargo personalizada
30/03/2020      LCS - RAL         Modificación. Se cambia el propietario de la cuenta al creador de la última oportunidad cuando no es un cliente de comunidad.
17/04/2020      LCS - GQG         Modificación. Se traslada el copiado de los campos de la Hoja de Encargo.
27/04/2020      LCS - RAL         Modificación. Se añade la fecha justificante de pago al cerrar una oportunidad como cerrada ganada.
30/09/2020      LCS - RAL         Modificación. Se añade la condición en el método getOficinas que se tenga en cuanta la vigencia de la relación entre horario y calendario.
28/10/2020 		LCS - GMC		  Modificación. Modificado el método "cambioEstadoCliente" para que cambie el estado a todos los intervinientes
*/
public without sharing class TriggerOpportunityHandler {
    

    /**
     *  Before Insert
     *  
     * @param  list with the new opportunities
     */
    public static void beforeInsert(list<Opportunity> lNewOpp){
      
        changeAccountOwner(lNewOpp);

        // copia los valores de la hoja de encargo en la creación (para el caso de la comunidad)		
	    copyValuesFromHdE(null, lNewOpp);
    }

    /**
     *  Método que se llama desde el trigger de Oportunidad
     *  
     * @param  mapa de los valores actuales
     * @param  lista con los contactos que se han modificado
     */
    public static void beforeUpdate(map<Id, Opportunity> mOldOpp, list<Opportunity> lNewOpp){
        
        List<Opportunity> lOppComprobar = new List<Opportunity>();
        Map<Id, String> mErroresOpp = new Map<Id, String>();
        for(Opportunity opp :lNewOpp){
            //Si no se envia a aprobación, seguimos el flujo normal. Si este cambia, comprobamos que no este bloqueado por aprobación
            if(opp.EnvioAprobacion__c == mOldOpp.get(opp.id).EnvioAprobacion__c && !opp.EnvioAprobacion__c){
                //Si la oportunidad cambia a cerrada/ganada, comprobamos los docsc e importes
                if(opp.StageName != mOldOpp.get(opp.id).StageName && opp.IsClosed && opp.IsWon
                   && userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad
                   && userinfo.getProfileId() != Label.IdPerfilGuest){  
                       lOppComprobar.add(opp);
                   }
                //Si la oportunidad cambia al estado Pago, comprobamos los doc e importes
                else if(opp.StageName != mOldOpp.get(opp.id).StageName &&  opp.StageName == Label.EstadoPago 
                        && userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad
                        && userinfo.getProfileId() != Label.IdPerfilGuest){
                            lOppComprobar.add(opp);              
                        }
            } else if(opp.BloqueoAprobacion__c == mOldOpp.get(opp.id).BloqueoAprobacion__c && opp.BloqueoAprobacion__c){
                mErroresOpp.put(opp.id, system.Label.mensajeErrorUpdOppApr);  
            } else {
                ////Solo cerraremos la oportunidad si esta aprobado, si es asi y la oportunidad cambia a cerrada/ganada, comprobamos los docs e importes, sino devolvemos un error
                if(opp.StageName != mOldOpp.get(opp.id).StageName && opp.IsClosed && opp.IsWon
                   && userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad
                   && userinfo.getProfileId() != Label.IdPerfilGuest){
                       if(!opp.Aprobado__c){
                           mErroresOpp.put(opp.id, system.Label.mensajeErrorNoAprob);
                       } else {
                           lOppComprobar.add(opp);
                       }
                   }
                //Si la oportunidad cambia al estado Pago, comprobamos los doc e importes
                else if(opp.StageName != mOldOpp.get(opp.id).StageName &&  opp.StageName == Label.EstadoPago 
                        && userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad
                        && userinfo.getProfileId() != Label.IdPerfilGuest){
                            lOppComprobar.add(opp);              
                        }
            }
        }
        //Enviamos la lista con las oportunidades nuevas que cumplan los requisitos previos para las diferentes comprobaciones
        if(!lOppComprobar.isEmpty()){
            //Antes de permitir la actualización comprobamos que los documentos de contratación han sido aportados, si no es así, devolvemos un error
            comprobacionCerradaGanada(lOppComprobar, mErroresOpp);
            //Se comprueba las funciones de contacto de la oportunidad y si hay un menor o un incapacitado tiene que existir también una de representante legal
            comprobacionFuncionesContactoOportunidad (lOppComprobar, mErroresOpp);
        }

        //Si existen errores, recorremos las oportunidades y aquellas que hayan dado error, lanzamos el error.
        if(!mErroresOpp.isEmpty()){
            for(Opportunity opp :lNewOpp){
                if(mErroresOpp.containsKey(opp.id)){
                    opp.addError(mErroresOpp.get(opp.id));
                }
            }
        }

        // Traslado de copiado de campos
        copyValuesFromHdE(mOldOpp, lNewOpp);


    }
    /**
     *  Método que se llama desde el trigger de Oportunidad
     *  
     * @param  mapa de los valores actuales
     * @param  lista con los contactos que se han modificado
     */
    public static void afterUpdate(map<Id, Opportunity> mOldOpp, list<Opportunity> lNewOpp){
        //Oportunidades Cerradas-Ganadas
        list<Id> lIdOppCerradasGanadas = new list<Id> ();
        list<Opportunity> lOppCerradasGanadas = new list<Opportunity>();
        //Oportunidades Cerradas-Perdidas
        list<Id> lIdOppCerradasPerdidas = new list<Id> ();
        list<Opportunity> lOppCerradasPerdidas = new list<Opportunity>();
        //Lista de ids de oportunidades las cuales tendremos que actualizar su expediente asociado 
        List<Id> lUpdateContract = new List<Id>();
        //Recorremos las oportunidades que se han modificado
        for(Opportunity opp :lNewOpp){
            //Si la oportunidad ha cambiado a cerrada/ganada se guarda el id
            if(opp.StageName != mOldOpp.get(opp.id).StageName && opp.IsClosed && opp.IsWon 
               && userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad
               && userinfo.getProfileId() != Label.IdPerfilGuest){
                lIdOppCerradasGanadas.add(opp.id);
                lOppCerradasGanadas.add(opp);
            }
            //Si la oportunidad ha cambiado a cerrada/perdida se guarda el id            
            else if(opp.StageName != mOldOpp.get(opp.id).StageName && opp.IsClosed && !opp.IsWon 
               && userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad
               && userinfo.getProfileId() != Label.IdPerfilGuest){
                lIdOppCerradasPerdidas.add(opp.id);
                lOppCerradasPerdidas.add(opp);                
            }
        }
		
        if(!lOppCerradasGanadas.isEmpty()){
            //Llamamos al método que crea los expedientes para las oportunidades cerradas/ganadas
            list<Contract> lNuevosExpedientes = crearExpedientes(lOppCerradasGanadas);
            if(!lNuevosExpedientes.isEmpty()){
                insert lNuevosExpedientes;     
    
                //Si se han creado nuevos expedientes movemos la documentación que se tenga en la oportunidad al contrato
                moverDocumentosDeOportunidadAExpediente (lNuevosExpedientes); 
                //Creamos los pagos relacionados
                List<Pago__c> lPagos = crearPago (lNuevosExpedientes); 
                //Actualizamos las cuentas relacionadas para pasar al estado "Cliente"
                cambioEstadoCliente (lNuevosExpedientes); 
                
                //Insertamos los pagos creados
                if(!lPagos.isEmpty()) insert lPagos;
            }    
        }
      
        //Enviamos las oportunidades Cerradas-Perdidas para llamar a Minerva y eliminar el exp
        if(!lOppCerradasPerdidas.isEmpty()){
            deleteExp(lOppCerradasPerdidas);
        }           
    }
    /**
     *  Método que crea un expediente a las oportunidades que están cerradas/ganadas
     *  
     * @param  lista con las oportunidad que están cerradas/ganadas
     */
    public static list<Contract> crearExpedientes (list<Opportunity> lOppCerradasGanadas){ 
        list<Contract> lExpedientes = new list<Contract> ();
        list<Id> lIdOppWin = new list<Id> ();

        //Recorremos la lista de Oportunidades y metemos el ID en una lista que usaremos para buscar expedientes
        for(Opportunity opp : lOppCerradasGanadas){
            lIdOppWin.add(opp.Id);
        }
        //Buscamos si las oportunidades que están cerradas/ganadas tienen un expediente
        if(!lIdOppWin.isEmpty()){
            
			//Vamos a comprobar la oficina correspondiente del creador del expediente			
            list<Id> lIdOficina = new list<Id>();
			 if(userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad && userinfo.getProfileId() != Label.IdPerfilGuest){
                 Id userId = UserInfo.getUserId();
                 lIdOficina = getOficina(userId);
             }

            list<Contract> lExpediente = [SELECT Id, Oportunidad__c
                                            FROM Contract
                                            WHERE Oportunidad__c IN :lIdOppWin];

            //Guardamos en un mapa para cada oportunidad su correspondiente expediente
            map<Id, Contract> mIdOppExpediente = new map<Id, Contract> ();
            for(Contract expediente :lExpediente){
                mIdOppExpediente.put(expediente.Oportunidad__c, expediente);
            }
            
            //Buscamos la Oli correspondiente para obtener el Producto y mandarlo al expediente
            list<OpportunityLineItem> lOli = [SELECT Id, OpportunityId, Product2Id, Product2.RecordTypeExpediente__c
                                             	FROM OpportunityLineItem
                                             	WHERE OpportunityId IN :lIdOppWin];
            Map<Id, Id> mIdOppProduct = new Map<Id, Id>();
            Map<Id, String> mProductRecordExp = new Map<Id, String>();
            for(OpportunityLineItem oli : lOli){
                mIdOppProduct.put(oli.OpportunityId, oli.Product2Id);
                mProductRecordExp.put(oli.Product2Id, oli.Product2.RecordTypeExpediente__c);
            }

            //Creamos un expediente para cada oportunidad cerrada/ganada que no tiene expediente ya creado
            for(Opportunity opp : lOppCerradasGanadas){
                if(!mIdOppExpediente.containsKey(opp.id)){
                    Contract Expediente = new Contract();
                    Expediente.AccountId = opp.AccountId;
                    Expediente.Pricebook2Id = opp.Pricebook2Id;
                    Expediente.IdExpediente__c = opp.NumeroExpediente__c;
                    Expediente.Oportunidad__c = opp.id;
                    Expediente.Status = system.label.Contratado;
                    Expediente.StartDate = system.today();     
                    Expediente.DocumentosCompletado__c = opp.DocumentosCompletado__c;
                    Expediente.DocumentosContratacion__c = opp.DocumentosContratacion__c;      
                    Expediente.DocumentosCompletadoAportado__c = opp.DocumentosCompletadoAportado__c;
                    Expediente.DocumentosContratacionAportado__c = opp.DocumentosContratacionAportado__c;    
                    Expediente.Tipo__c = opp.Tipo__c;
                    Expediente.PrecioTotal__c = opp.PrecioTotal__c;    
                    Expediente.ProofPaymentDate__c = opp.ProofPaymentDate__c;
		    Expediente.FechaPago__c = opp.ProofPaymentDate__c;
                    //Comprobamos si quien ejecuta el trigger viene de la comunidad, si es así le asignamos el mismo owner
                    if(userinfo.getProfileId() == Label.IdPerfilUsuariocomunidad && userinfo.getProfileId() == Label.IdPerfilGuest) Expediente.OwnerId = opp.OwnerId;
                    if(userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad && userinfo.getProfileId() != Label.IdPerfilGuest){
                        Expediente.OficinaAsesor__c = opp.OficinaCita__c;
                        if(!lIdOficina.isEmpty()) Expediente.OficinaContratacion__c = lIdOficina.get(0);
                    }
                    String tipoRegProducto = '';
                    if(mIdOppProduct.containsKey(opp.Id)){
                    	Id productoId = mIdOppProduct.get(opp.Id);
                        Expediente.Producto__c = productoId;
                        tipoRegProducto = mProductRecordExp.get(productoId);                        
                    }
                    if(!String.isBlank(tipoRegProducto)) Expediente.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(tipoRegProducto).getRecordTypeId(); 
                    else Expediente.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('General').getRecordTypeId(); 
                    
                    
                    lExpedientes.add(Expediente);
                }
            }
        }

        return lExpedientes;
    }

    /**
     *  Método que obtiene la oficina del usuario ejecutor
     *  
     * @return lista con los Ids de las oficinas
     */
    public static List<Id> getOficina(Id userId){ 
        List<Id> lIdOficina = new List<Id>();
        
        List<Id> lIdCalendario = new List<Id>();
        Date fechaEjecucion = system.today();
        DateTime fechaActual = system.now();
        //Obtenemos en una lista todos los calendarios correspondientes con el usuario ejecutor del trigger
        list<Calendar> lCalendario = [SELECT Id FROM Calendar WHERE UserId =: userid];
        //guardamos el id de los calendarios en una lista
        for(Calendar calendario : lCalendario) lIdCalendario.add(calendario.Id);
        
        //Obtenemos en una lista todos las configuraciones correspondientes con los calendarios obtenidos comprobando que las relaciones siguen vigentes
        List<CalendarSetting__c> lCalSett = [SELECT Id, Oficina__c FROM CalendarSetting__c WHERE CalendarId__c IN: lIdCalendario AND EffectiveFrom__c <=: fechaEjecucion AND EffectiveTo__c >=: fechaEjecucion AND Id IN (SELECT CalendarSetting__c FROM CalendarTimeTable__c WHERE EffectiveFrom__c <= :fechaActual AND EffectiveTo__c >= :fechaActual)];
        //guardamos el id de las oficinas en la lista que retornamos
        for(CalendarSetting__c calSett : lCalSett) lIdOficina.add(calSett.Oficina__c);       
        

        return lIdOficina;
    }

    /**
     *  Método que mueve los documentos que se tienen en la oportunidad a el expediente que se ha creado anteriormente
     *  
     * @param  lista con los expediente que se acaban de crear
     */
    public static void moverDocumentosDeOportunidadAExpediente (list<Contract> lExpedientes){ 
        list<Id> lIdOpp = new list<Id>();
        map<Id,Id> mIdOppIdExp = new map<Id,Id>();
        for(Contract expediente :lExpedientes){
            lIdOpp.add(expediente.Oportunidad__c);
            mIdOppIdExp.put(expediente.Oportunidad__c, expediente.id);
        }

        //Movemos los documentos de las oportunidades a los expedientes creados en el paso anterior    
        list<ContentDocumentLink> lDocNuevos = new list<ContentDocumentLink>();
        list<ContentDocumentLink> lDocEliminar = new list<ContentDocumentLink>();
        list<ContentDocumentLink> lDocumentos = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId IN :lIdOpp];
        for(ContentDocumentLink documento : lDocumentos){
            ContentDocumentLink documentoNuevo = documento.clone();
            documentoNuevo.LinkedEntityId = mIdOppIdExp.get(documento.LinkedEntityId);
            documentoNuevo.ShareType = documento.ShareType;
            lDocNuevos.add(documentoNuevo);
            lDocEliminar.add(documento);
        }
        //Insertamos los nuevos documentos que han sido clonados y eliminamos los que se han clonado
        if(!lDocNuevos.isEmpty()) insert lDocNuevos;
        if(!lDocEliminar.isEmpty()) delete lDocEliminar;
    }
    
    /**
    *  Método que cambia el estado de la cuenta a "Cliente" de todos los intervinientes cuando se crea un Expediente
    *  
    * @param  lista con los expedientes creados
    */
    public static void cambioEstadoCliente (list<Contract> lNewExpedients){ 
        list<Account> lChangeStatus = new List<Account>();
        //obtenemos todos los intervinientes
        list<ContractContactRole> lContactoExpeRol = [SELECT id, contactid, contractId FROM ContractContactRole WHERE contractid IN : lNewExpedients];
        //lista con los contactos que queremos updatear la cuenta
		system.debug('num Contratos'+ lContactoExpeRol.size());
        List<id> lAccId = new List<id>();
        List<Contact> listaContactosUpdate = new List<Contact>();
        for(Contract exp :lNewExpedients){
            lAccId.add(exp.Accountid);
        }
		List<Account> lExpCuenta= [SELECT id, name, EstadoCuenta__c FROM Account WHERE id IN :lAccId];
        //obtenemos todos los contactos que están relacionados con el expediente
		for (ContractContactRole conR :lContactoExpeRol){
    		Contact con = new Contact();
			con.id = conR.contactid;
        	listaContactosUpdate.add(con);
		}
        system.debug('num contactos'+ listaContactosUpdate.size());
        //obtenemos las cuentas de los contactos que queremos updatear el estado
		List<Account> cuentasUpdate = [SELECT id, name,EstadoCuenta__c FROM Account WHERE PersonContactId IN :listaContactosUpdate ];
    	cuentasUpdate.addAll(lExpCuenta);
        Set<Account> sAccounts = new Set<Account>();
        sAccounts.addAll(cuentasUpdate);
        for (Account acc : sAccounts){
        	if (!String.isBlank(acc.id) && acc.EstadoCuenta__c != system.Label.EstadoCuentaCliente){
        		Account cuenta = new Account();
        		cuenta.id =  acc.id;
        		cuenta.EstadoCuenta__c = system.Label.EstadoCuentaCliente;
        		lChangeStatus.add(cuenta);
        	}
    	}
        //Si exiten cuentas con cambio de estado, actualizamos la lista
        if(!lChangeStatus.isEmpty()) update lChangeStatus;
    }
    /**
     *  Método que crea un Pago por cada expediente que se ha creado para los registros que no son de comunidad y que las opp han sido cerradas ganadas
     *  
     * @param  lista con los expedientes recien creados
     */
    public static list<Pago__c> crearPago (list<Contract> lExpedientes){ 
        list<Pago__c> lPagos = new list<Pago__c> ();

        //Recorremos la lista de expedientes y creamos un pago
        for(Contract ct : lExpedientes){
            Pago__c pago = new Pago__c();
        		pago.Expediente__c = ct.Id;
                pago.PrecioTotal__c = ct.PrecioTotal__c;
                pago.Tipo__c = ct.Tipo__c;
                pago.ProofPaymentDate__c = ct.ProofPaymentDate__c;
                if(ct.Tipo__c != Label.tipoPagoSinProvision){
                    pago.Estado__c = Label.EstadoPagoNoCero;
                } else {
                    pago.Estado__c = Label.EstadoPagoCero;
                }
            lPagos.add(pago);
        }        
        return lPagos;
    }
        
    /**
     *  Método que llama a los WS de Minerva para eliminar un expediente cuando estas son cerradas perdidas
     *  
     * @param  lista con las oportunidad que están cerradas/perdidas
     */
    public static void deleteExp(List<Opportunity> lOppCerradasPerdidas){ 
        //Recorremos la lista de oportunidades CerradasPerdidas
        List<String> lNumExpToDel = new List<String>();
        for(Opportunity opp : lOppCerradasPerdidas){
            lNumExpToDel.add(opp.NumeroExpediente__c);
        }

        if(!lNumExpToDel.isEmpty()){
            //LLAMADA A CLASE CALLOUT
            //MinervaRestCallouts.deleteExpedientMin(lNumExpToDel); 
            //MinervaRestCallouts.deleteExpedientProd(lNumExpToDel);
        }
    }

    /**
     *  Método que comprueba si se ha cumplimentado lo necesario para cerrar la oportunidad como ganada
     *  
     * @param  lista de oportunidades los cuales pasan de estado
     * @param  mapa de errores
     */
    public static void comprobacionCerradaGanada (List<Opportunity> lOppWon, Map<Id, String> mErroresOpp){ 
        for(Opportunity opp : lOppWon){
            String error = '';
            if(userinfo.getProfileId() != Label.IdPerfilUsuariocomunidad && userinfo.getProfileId() != Label.IdPerfilGuest){
                //Comprobamos que tiene los documentos necesarios
                if(!String.isBlank(opp.DocumentosContratacionAportado__c) && !String.isBlank(opp.DocumentosContratacion__c)){
                    //separamos los valores por el ; y lo metemos en un Set el cual compararemos
                    String docContratacion = opp.DocumentosContratacion__c;
                    String docContratacionAportado = opp.DocumentosContratacionAportado__c;
                    String[] arrDocContratacion = docContratacion.split(';');
                    String[] arrDocContratacionAportado = docContratacionAportado.split(';');
                    Set<String> sDocContratacion = new Set<String>();
                    for(String documento : arrDocContratacion){
                        sDocContratacion.add(documento);
                    }
                    Set<String> sDocContratacionAportado = new Set<String>();
                    for(String documento : arrDocContratacionAportado){
                        sDocContratacionAportado.add(documento);
                    }                    
                    //Comprobamos que los datos de la oportunidad correspondientes a la documentación tengan los mismos valores
                    if(!sDocContratacionAportado.containsAll(sDocContratacion)){
                        error += ' '+system.label.ErrorDocumentos;
                    }
                }else{
                    error += ' '+system.label.ErrorDocumentos;
                }
                //Comprobamos que se ha realizado el pago y tiene cumplimentado el importe
                if(String.isBlank(string.valueOf(opp.PrecioTotal__c)) && opp.IsClosed && opp.IsWon) error += ' '+system.label.ErrorImporte;
                //Comprobamos que se ha realizado el pago y tiene cumplimentado la forma de pago
                if(String.isBlank(opp.Tipo__c) && opp.IsClosed && opp.IsWon) error += ' '+system.label.ErrorTipo;
                //Comprobamos que la oportunidad tiene una hoja de encargo asociada
                if( String.isBlank(opp.HojaEncargo__c) && (!opp.HojaEncargoPersonalizada__c) ) error += ' '+system.label.ErrorHojaEncargo;
                //Comprobamos que la oportunidad tiene la Fecha de justificante de pago completa
                if( String.isBlank(String.valueOf(opp.ProofPaymentDate__c)) && opp.IsClosed && opp.IsWon ) error += ' '+system.label.ErrorFechaJustificante;
                //Si existen errores añadimos al mapa del errores el id de la oportunidad y los errores generados
                if(!String.isBlank(error))  mErroresOpp.put(opp.id, error);
            }
        }
    }

    /**
     *  Método que comprueba si la oportunidad tiene algún menor o incapacitado y si tiene su correspondiente representante legal, en caso de no tener representante legal 
     *  se devuelve un error
     *  
     * @param  lista de oportunidades los cuales pasan de estado
     * @param  mapa de errores
     */
    public static void comprobacionFuncionesContactoOportunidad (List<Opportunity> lOppWon, Map<Id, String> mErroresOpp){ 
        //Recorremos las oportunidades para recuperar los id de las oportunidades
        list<Id> lIdOpp = new list<Id>();
        for(Opportunity opp :lOppWon){
            if(opp.IsClosed && opp.IsWon) lIdOpp.add(opp.id);
        }
        //Buscamos las funciones de contacto de las oportunidades
        list<OpportunityContactRole> lFuncionesContacto = [SELECT Id, OpportunityId, Role
                                                            FROM OpportunityContactRole
                                                            WHERE OpportunityId IN :lIdOpp];

        //Recorremos las funciones de contacto obtenidas y guardamos en un mapa el id de la oportunidad y si tiene un menor o incapacitado,
        //en otro mapa se guarda el id de la oportunidad y si tiene un representante legal
        map<Id, OpportunityContactRole> mMenoresEdad = new map<Id,OpportunityContactRole>();
        map<Id, OpportunityContactRole> mIncapacitados = new map<Id,OpportunityContactRole>();
        map<Id, OpportunityContactRole> mRepresentantesLegal = new map<Id,OpportunityContactRole>();
        map<Id, OpportunityContactRole> mTutor = new map<Id,OpportunityContactRole>();
        for(OpportunityContactRole funcionContacto :lFuncionesContacto){
            if(funcionContacto.Role == system.label.MenorDeEdad) mMenoresEdad.put(funcionContacto.OpportunityId, funcionContacto);
            else if(funcionContacto.Role == system.label.Incapacitado) mIncapacitados.put(funcionContacto.OpportunityId, funcionContacto);
            else if(funcionContacto.Role == system.label.Tutor) mTutor.put(funcionContacto.OpportunityId, funcionContacto);
            else if(funcionContacto.Role == system.label.RepresentanteLegal) mRepresentantesLegal.put(funcionContacto.OpportunityId, funcionContacto); 
        }

        //Recorremos las  oportunidades que han pasado a cerradas ganadas 
        for(Opportunity opp: lOppWon){
            //Comprobamos en el mapa si tiene algún menor 
            if(mMenoresEdad.containsKey(opp.Id)){
                //Si tiene menor comprobamos que tiene un representante legal o tutor, si no tiene se devuelve un error
                if(!mRepresentantesLegal.containsKey(opp.Id) && !mTutor.containsKey(opp.Id)) mErroresOpp.put(opp.Id, system.label.ErrorMenorSinRepresentanteLegal);
            }
            //Comprobamos en el mapa si tiene algún incapacitado
            if(mIncapacitados.containsKey(opp.Id)){
                //Si tiene incapacitado comprobamos que tiene un tutor, si no tiene se devuelve un error
                if(!mTutor.containsKey(opp.Id)) mErroresOpp.put(opp.Id, system.label.ErrorIncapacitadoSinTutor);
            }
        }
    }

    /**
     * Cuando se rellena el campo de la hoja de encargo, se copian los valores de los campos con el mismo nombre
     * @param  mOldOpp mOldOpp description
     * @param  lNewOpp lNewOpp description
     */ 
    private static void copyValuesFromHdE (map<Id, Opportunity> mOldOpp, list<Opportunity> lNewOpp) {


        List<Opportunity> lOppNewHdE = new List<Opportunity>();
        Set<Id> sHdE = new Set<Id>();

        // Detectamos las opp a las que se le está asignando una HdE
        for(Opportunity opp : lNewOpp) {
            
            Boolean isHdeFromInsert = (opp.HojaEncargo__c != null);
            Boolean isHdeFromUpdate = (mOldOpp != null) && (mOldOpp.get(opp.Id).HojaEncargo__c != opp.HojaEncargo__c) && (opp.HojaEncargo__c != null);
            
            if ( isHdeFromInsert || isHdeFromUpdate  ) {
                lOppNewHdE.add(opp);
                sHdE.add(opp.HojaEncargo__c);
            }
        }

        // Recuperamos las HdE asociadas
        Map<Id, HojaEncargo__c> mHdE = new Map<Id, HojaEncargo__c>( [SELECT Id,HAbogadoDivorcio__c, HAbogadoLiqRegimen__c, HAbogadoMedProvisional__c, HAbogadoUnico__c, HCondenaCostas__c,
                                            PHAcuerdoJudOExtra__c, PHAcuerdoExtra__c, PHAcuerdoJud__c, PSinCondenaCostas__c, ImporteEstudioAnalisis__c,
                                            ImporteDesistimientoMaximo__c, ImporteDesistimientoMinimo__c, ImporteDesistimientoUnico__c, ImporteGestionesPrevias__c,
                                            PInteresCondenaCostas__c, PInteresSinCondenaCostas__c, HAcuerdoJudOExtra__c, HProcurador__c, HSinCondenaCostas__c, 
                                            ImportePresentacionDemanda__c, PHRecuperacionDineroOC__c, PHResEstConCondenaCostas__c, PHResEstConOSinConCostas__c, 
                                            PHRespectoHonorarios__c, PHResEstSinCondenaCostas__c
                                    FROM HojaEncargo__c 
                                    WHERE Id IN :sHdE]);


        // Actualizamos los valores de la oportunidad, no hace falta update
        for(Opportunity opp : lNewOpp) {

            HojaEncargo__c hde = mHdE.get(opp.HojaEncargo__c);

            if(hde != null) {
                if(opp.HAbogadoDivorcio__c == null) opp.HAbogadoDivorcio__c = hde.HAbogadoDivorcio__c; 
                if(opp.HAbogadoLiqRegimen__c == null) opp.HAbogadoLiqRegimen__c = hde.HAbogadoLiqRegimen__c; 
                if(opp.HAbogadoMedProvisional__c == null) opp.HAbogadoMedProvisional__c = hde.HAbogadoMedProvisional__c;
                if(opp.HAbogadoUnico__c == null) opp.HAbogadoUnico__c =  hde.HAbogadoUnico__c;
                if(opp.Hcondenacostas__c == null) opp.Hcondenacostas__c = hde.Hcondenacostas__c; 
                if(opp.PHAcuerdoJudOExtra__c == null) opp.PHAcuerdoJudOExtra__c = hde.PHAcuerdoJudOExtra__c; 
                if(opp.PHAcuerdoExtra__c == null) opp.PHAcuerdoExtra__c = hde.PHAcuerdoExtra__c; 
                if(opp.PHAcuerdoJud__c == null) opp.PHAcuerdoJud__c = hde.PHAcuerdoJud__c; 
                if(opp.PSincondenacostas__c == null) opp.PSincondenacostas__c =  hde.PSincondenacostas__c; 
                if(opp.ImporteEstudioAnalisis__c == null) opp.ImporteEstudioAnalisis__c = hde.ImporteEstudioAnalisis__c;
                if(opp.ImporteDesistimientoMaximo__c == null) opp.ImporteDesistimientoMaximo__c = hde.ImporteDesistimientoMaximo__c; 
                if(opp.ImporteDesistimientoMinimo__c == null) opp.ImporteDesistimientoMinimo__c = hde.ImporteDesistimientoMinimo__c; 
                if(opp.ImporteDesistimientoUnico__c == null) opp.ImporteDesistimientoUnico__c =  hde.ImporteDesistimientoUnico__c;
                if(opp.ImporteGestionesPrevias__c == null) opp.ImporteGestionesPrevias__c =  hde.ImporteGestionesPrevias__c;
                if(opp.PInterescondenacostas__c == null) opp.PInterescondenacostas__c =  hde.PInterescondenacostas__c;
                if(opp.PInteresSincondenacostas__c == null) opp.PInteresSincondenacostas__c = hde.PInteresSincondenacostas__c;

                // Nuevos campos detectados antes de la carga de HdE
                if(opp.HAcuerdoJudOExtra__c == null) opp.HAcuerdoJudOExtra__c = hde.HAcuerdoJudOExtra__c;
                if(opp.HProcurador__c == null) opp.HProcurador__c = hde.HProcurador__c;
                if(opp.HSinCondenaCostas__c == null) opp.HSinCondenaCostas__c = hde.HSinCondenaCostas__c;
                if(opp.ImportePresentacionDemanda__c == null) opp.ImportePresentacionDemanda__c = hde.ImportePresentacionDemanda__c;
                if(opp.PHRecuperacionDineroOC__c == null) opp.PHRecuperacionDineroOC__c = hde.PHRecuperacionDineroOC__c;
                if(opp.PHResEstConCondenaCostas__c == null) opp.PHResEstConCondenaCostas__c = hde.PHResEstConCondenaCostas__c;
                if(opp.PHResEstConOSinConCostas__c == null) opp.PHResEstConOSinConCostas__c = hde.PHResEstConOSinConCostas__c;
                if(opp.PHResEstSinCondenaCostas__c == null) opp.PHResEstSinCondenaCostas__c = hde.PHResEstSinCondenaCostas__c;
                if(opp.PHRespectoHonorarios__c == null) opp.PHRespectoHonorarios__c = hde.PHRespectoHonorarios__c;
            }
        }
    }

    /**
     *  Method to change the account owner to the last opportunity creator
     *  
     * @param  lista con las nuevas oportunidades
     */
    private static void changeAccountOwner(List<Opportunity> lNewOpp){
        
        Set<Id> sIdsAcc = new Set<Id>();
        List<Account> lAccUpdate = new List<Account>();
        String idPerfilAutocita = OM_GeneralSettings__c.getOrgDefaults().OM_AutocitaProfile__c;
        for(Opportunity opp : lNewOpp){
            if(UserInfo.getProfileId() != Label.IdPerfilUsuariocomunidad && UserInfo.getProfileId() != Label.IdPerfilGuest && UserInfo.getProfileId() != idPerfilAutocita && opp.AccountId != null){
                sIdsAcc.add(opp.AccountId);
            }
        }
        // Cambiamos el propietario de la cuenta al usuario creador de la oportunidad
        for(Account acc : [SELECT Id, OwnerId FROM Account WHERE Id IN :sIdsAcc]){
            acc.OwnerId = UserInfo.getUserId();
            lAccUpdate.add(acc);
        }
        if(lAccUpdate.size() > 0) update lAccUpdate;


    }
    
}