/*
@author LeadClic Solutions S.L.
@date 10/04/2019
@description Trigger para el objeto Expediente(Contract)

<pre>
FECHA             AUTOR           ACCION
17/04/2019		LCS - RDM	   	  Creación.
06/05/2019      LCS - RMG         Modificación. Se añade la comprobación de si existe conflicto de interés.
19/06/2019      LCS - RDM         Modificación. Se añade las llamadas a Minerva o producción dependiendo de los diferentes factores
27/06/2019      LCS - RDM         Modificación. Se añade la comprobación antes de la insercion de se se realizo la aportacion de documentación básica
02/09/2019      LCS - RDM         Modificación. Se añade variable para evitar que el WS de Minerva llame otra vez al trigger
18/11/2019      LCS - GQG         Modificación. Integración con PROD. Se elimina la condición del estado de sincro == OK para permitir updates de expedientes.
08/01/2020      LCS - MMV         Modificación. Antes de enviar el expediente, si cumple los requisitos, cambiar el valor del Estado a COMPLETANDOSE DOCUMENTACIÓN
27/01/2020      LCS - MMV         Modificación. Control para que no se lance siempre al cambiar el status, solo si es uno de los valores y no es el usuario de integración
27/02/2020      LCS - MMV         Modificación. Cambio de llamadaWS = false para que solo lo marque en el caso de llamada a WS.
06/08/2021      LCS - DRA         Modificación. Se añade el método updateStatusCommunity para la gestión del estado de la comunidad

*/
public without sharing class TriggerContractHandler {
    
    //Evitamos dobles llamadas desde el WS
    public static Boolean llamadaWS;

    public static void beforeInsert (list <Contract> newExpedientes) {
        /*27/06/2019  LCS - RDM  */
        //antes de insertar comprobamos si en la oportunidad ya se realizo la aportacion de documentación básica
        
        System.debug('hola: '+newExpedientes);
        docAportadosExpedientes (newExpedientes);        
    }

    public static void afterInsert (list <Contract> newExpedientes) {
    	/*17/04/2019  LCS - RDM  */
        //enviamos los expedientes creadas para realizar la creación y asociacion de las funciones de contrato
        CrearRoleExpediente(newExpedientes);
        /*19/06/2019  LCS - RDM  */
        //enviamos los expedientes creadas para realizar las comprobaciones y enviar a Minerva y Producción
        sendExp(newExpedientes);
    }

    public static void beforeUpdate(list<Contract> newExpedientes, map<Id,Contract> oldMapExpedientes){
        //Recorremos los expedientes que han sido modificados y nos quedamos con los que han cambiado el campo de parte contraria
        set<Id> sIdContratosParteContraria = new set<Id>();
        set<Id> sIdCuentaParteContraria = new set<Id>();
        List<Contract> lExpedientesDoc = new List<Contract>();
        for(Contract expediente :newExpedientes){
            if(expediente.ParteContraria__c != oldMapExpedientes.get(expediente.id).ParteContraria__c){
                sIdContratosParteContraria.add(expediente.id);
                //Si el expediente tiene parte contraria y no está ya en el conjunto se inserta para luego buscarle en las funciones de contacto de los contratos
                if(expediente.ParteContraria__c != null && !sIdCuentaParteContraria.contains(expediente.ParteContraria__c)){
                    sIdCuentaParteContraria.add(expediente.ParteContraria__c);
                }
            }            
            //Si se aportan documentos de contratación, revisamos que ambos campos coinciden.
            if(!String.isBlank(expediente.DocumentosCompletadoAportado__c) && expediente.DocumentosCompletadoAportado__c != oldMapExpedientes.get(expediente.id).DocumentosCompletadoAportado__c){
                lExpedientesDoc.add(expediente);
            }
        }
        //Comprobamos si la parte contraria indicada genera conflicto de interés
        if(!sIdContratosParteContraria.isEmpty()) newExpedientes = comprobarConflictoInteres (sIdContratosParteContraria, newExpedientes, sIdCuentaParteContraria);
        if(!lExpedientesDoc.isEmpty()) docAportadosExpedientes(lExpedientesDoc) ;

        // MMV: Modificar el estado del Expediente si cumple los requisitos para enviarlo
        updateStatus(newExpedientes, oldMapExpedientes);
        
    }
    
    /*19/06/2019  LCS - RDM  */
    public static void afterUpdate(list<Contract> newExpedientes, map<Id,Contract> oldMapExpedientes){
        //lista de Expedientes a enviar a Minerva
        if(llamadaWS != false){
            
            // Obtenemos los estados que provocan el envío a Producción y Minerva
            Set<String> sStatus = new Set<String>();
            for(StatusExp2Send__mdt status : [SELECT MasterLabel FROM StatusExp2Send__mdt]){
                sStatus.add(status.MasterLabel);                
            }
            // Obtenemos el Id del usuario de integración en la custom setting
            IntegracionSF__c confIntegracionSF = IntegracionSF__c.getInstance('General');


            List<Contract> lSendExp = new List<Contract>();
            for(Contract expediente :newExpedientes){
                
                if(expediente.DocumentacinBasicaAportada__c == true && expediente.PagoConfirmado__c == true && 
                    ( expediente.DocumentacinBasicaAportada__c != oldMapExpedientes.get(expediente.id).DocumentacinBasicaAportada__c ||
                    expediente.PagoConfirmado__c != oldMapExpedientes.get(expediente.id).PagoConfirmado__c || 
                    (expediente.Status != oldMapExpedientes.get(expediente.id).Status && sStatus.contains(expediente.Status) && UserInfo.getUserId() != confIntegracionSF.UsuarioIntegracionId__c) )
                  ){
                      lSendExp.add(expediente);
                }
                /*if((expediente.DocumentacinBasicaAportada__c != oldMapExpedientes.get(expediente.id).DocumentacinBasicaAportada__c) && expediente.DocumentacinBasicaAportada__c == true){
                    if(expediente.PagoConfirmado__c == true) lSendExp.add(expediente);
                }   
                if((expediente.PagoConfirmado__c != oldMapExpedientes.get(expediente.id).PagoConfirmado__c) && expediente.PagoConfirmado__c == true){
                    if(expediente.DocumentacinBasicaAportada__c == true) lSendExp.add(expediente);
                }*/
                

            }
            //enviamos los expedientes que cumplen las comprobaciones a Minerva y Producción
            if(!lSendExp.isEmpty()) sendExp(lSendExp);
        }
    }
    
    
    /**
     *  Método encargado de traspasar el rol del contacto asociado a la oportunidad dentro del objeto Expediente
     *  
     * @param  lista con los IDs de los expedientes que se han creado
     */
    public static void CrearRoleExpediente(list<Contract> newExpedientes){
        //Creamos lista de función de expediente donde añadiremos las funciones a insertar
        list<ContractContactRole> lFuncionesExp = new list<ContractContactRole>();
        //Creamos un mapa donde indicaremos el id de la opp y el id del expediente, que usaremos para relacionar el rol con el expediente
        map<id, list<id>> mapOppExp = new map<id, list<id>>();//Creamos este mapa para después recorrerlo y poder asignar al rol de expediente el ContractId
        list<Id> lIdOpp = new list<Id>();
        //recorremos los expedientes insertados
        for(Contract exp : newExpedientes){
            lIdOpp.add(exp.Oportunidad__c);//añadimos el id de la oportunidad para después buscar los roles relacionados
            list<id> lidexp = new list<id>();
            //comprobamos que el valor de opp esta en el mapa para añadir el expediente asociado en el, sino, creamos el registro en el mapa
            if(mapOppExp.containsKey(exp.Oportunidad__c)){
                lidexp = mapOppExp.get(exp.Oportunidad__c);
                lidexp.add(exp.Id);
                mapOppExp.put(exp.Oportunidad__c, lidexp);
            }else{
                lidexp.add(exp.Id);
                mapOppExp.put(exp.Oportunidad__c, lidexp);                
            }
        }
        //Si la lista de oportunidades no esta vacía, buscamos todos los roles de contacto asociados y los añadimos a una lista que posteriormente recorreremos
        if(!lIdOpp.isEmpty()){
            list<OpportunityContactRole> lOppRole = [SELECT ContactId, Role, IsPrimary, OpportunityId
                                                        FROM OpportunityContactRole
                                                        WHERE OpportunityId IN :lIdOpp];
            
            /*ADVERTENCIA - Se utiliza un for dentro de otro for debido a la asociacion del id de expediente, el cual no lo podemos obtener en ninguna query (o añadirla a un mapa como clave IDOpp) de oportunidad por ser 1-N
				se ha creado un mapa con <idopp, list<idExp>> para poder tener un mayor control del segundo for*/
            
            //Recorremos la lista de roles de las oportunidades asignadas a los expedientes
            for(OpportunityContactRole rol :lOppRole){
                //Comprobamos que el Id de oportunidad del rol existe en el mapa
                if(mapOppExp.containsKey(rol.OpportunityId)){
                    //Si existe, recorremos la lista que existe como valor en el mapa asociada a la oportunidad
                    for(Id expId : mapOppExp.get(rol.OpportunityId)){
                        //Creamos el valor de ContractContactRole con los valores y los añadimos a la lista que se utilizará para la creación.
                        ContractContactRole exprol = new ContractContactRole();
                            exprol.ContactId = rol.ContactId;
                            exprol.ContractId = expId;
                            exprol.Role = rol.Role;
                            exprol.IsPrimary = rol.IsPrimary;
                        lFuncionesExp.add(exprol);
                    }
                }
            }
        }
        //Insertamos las funciones de contacto asociadas al expediente
        if(!lFuncionesExp.isEmpty() && lFuncionesExp != null) insert lFuncionesExp;
    }
    

    /**
    *   Método que comprueba si la parte contraria indicada en el expediente genera un conflicto de interés porque ya sea cliente de Arriaga
    *
    *   @param  sIdContratosParteContraria: conjunto con los expedientes que han cambiado su parte contraria
    *   @param  newExpedientes: expedientes que han ejecutado el trigger
    *   @param  sIdCuentaParteContraria: conjunto con los id de las cuentas seleccionadas como parte contraria en los expedientes
    */
    public static list<Contract> comprobarConflictoInteres (set<Id> sIdContratosParteContraria, list<Contract> newExpedientes, set<Id> sIdCuentaParteContraria){
        //Recuperamos las funciones de contacto asociadas a los contactos seleccionados como parte contraria en los expedientes
        list<ContractContactRole> lFuncionesContactos = [SELECT Id, ContractId, Contact.AccountId
                                                        FROM ContractContactRole
                                                        WHERE Contact.AccountId IN :sIdCuentaParteContraria]; 

        //Recorremos las funciones de contacto encontradas y metemos en un mapa a cada cliente que ya es cliente
        set<Id> sIdCuentaFuncionesContacto = new set<Id> ();
        for(ContractContactRole funcionContacto :lFuncionesContactos){
            if(!sIdCuentaFuncionesContacto.contains(funcionContacto.Contact.AccountId)) sIdCuentaFuncionesContacto.add(funcionContacto.Contact.AccountId);
        }

        //Recorremos los expedientes
        for(Contract contrato :newExpedientes){
            //Si han cambiado de parte contraria se continua
            if(sIdContratosParteContraria.contains(contrato.id)){
                //Si la parte contraria está vacia se pone el campo de posible conflicto de interés a false
                if(contrato.ParteContraria__c == null && contrato.PosibleConflictoInteres__c) contrato.PosibleConflictoInteres__c = false;
                //Si está informado el campo de parte contraria se mira si ya existe como cliente de arriaga 
                // y en caso de ser ya cliente se marca a true el campo de posible conflicto de interés
                if(contrato.ParteContraria__c != null && sIdCuentaFuncionesContacto.contains(contrato.ParteContraria__c)) contrato.PosibleConflictoInteres__c = true;
                //Si está informado el campo de parte contraria y no existe como cliente de arriaga se pone el campo de 
                //posible conflicto de interés a false
                if(contrato.ParteContraria__c != null && !sIdCuentaFuncionesContacto.contains(contrato.ParteContraria__c)) contrato.PosibleConflictoInteres__c = false;
            }
        }
		
        return newExpedientes;
    }
    
    /**
     *  Método que comprueba si la documentación basica necesaria ha sido aportada y el pago es confirmado se envia la información a Minerva
     *  
     * @param  lista con los expedientes a enviar a MInerva/producción
     */
     /*19/06/2019  LCS - RDM  */
    public static void sendExp(List<Contract> lExpAenviar){ 
        //Recorremos la lista de oportunidades CerradasPerdidas
        Map<String, Id> mNumExpToSendMinerva = new Map<String, Id>();
        Map<String, Id> mNumExpToSendProd = new Map<String, Id>();
        //Recorremos la lista de oportunidades CerradasGanadas
        for(Contract expediente : lExpAenviar){
            //Si tiene documentación basica seleccionada y la documentación basica aportada esta completamente igual y el pago ha sido confirmado, mandamos el expediente a minerva
            if(expediente.DocumentacinBasicaAportada__c == true && expediente.PagoConfirmado__c == true){
                llamadaWS = false;
                if(expediente.EstadoSyncMinerva__c != 'OK') mNumExpToSendMinerva.put(expediente.IdExpediente__c, expediente.AccountId);
                mNumExpToSendProd.put(expediente.IdExpediente__c, expediente.AccountId);
            }
        }
        //Si el mapa de Numero de expediente y cuenta es diferente a vacíos mandamos la información a Minerva
        if(!mNumExpToSendMinerva.isEmpty()){   
            //LLAMADA A CLASE CALLOUT
            MinervaRestCallouts.futureSendWSMinerva(mNumExpToSendMinerva, null);  
        }
        //Si el mapa de Numero de expediente y cuenta es diferente a vacíos mandamos la información a Producción
        if(!mNumExpToSendProd.isEmpty()){  
            //LLAMADA A CLASE CALLOUT
            MinervaRestCallouts.futureSendWSProd(mNumExpToSendProd, null); 
        }
    }

    /**
     *  Método que actualiza el campo DocumentacinBasicaAportada__c si la documentación esta aportada
     *  
     * @param  lista de expedientes a insertar
     */
    public static void docAportadosExpedientes (List<Contract> lnewExpedientes){ 
        for(Contract exp : lnewExpedientes){
            if(!String.isBlank(exp.DocumentosCompletadoAportado__c) && !String.isBlank(exp.DocumentosCompletado__c)){
                //separamos los valores por el ; y lo metemos en un Set el cual compararemos
                String docCompletado = exp.DocumentosCompletado__c;
                String docCompletadoAportado = exp.DocumentosCompletadoAportado__c;
                String[] arrDocCompletado = docCompletado.split(';');
                String[] arrDocCompletadoAportado = docCompletadoAportado.split(';');
                Set<String> sDocbasico = new Set<String>();
                for(String documento : arrDocCompletado){
                    sDocbasico.add(documento);
                }
                Set<String> sDocbasicoAportado = new Set<String>();
                for(String documento : arrDocCompletadoAportado){
                    sDocbasicoAportado.add(documento);
                }                    
                //Comprobamos que los datos de la oportunidad correspondientes a la documentación tengan los mismos valores
                if(sDocbasicoAportado.containsAll(sDocbasico)){
                    exp.DocumentacinBasicaAportada__c = true; 
                }
            } else if(String.isBlank(exp.DocumentosCompletado__c)){
                exp.DocumentacinBasicaAportada__c = true; 
            }
        }
    }

    /**
     *  Método que actualiza el estado del Expediente si cumple las condiciones para ser mandado
     *  
     * @param  lista de expedientes a insertar
     */
    public static void updateStatus (List<Contract> lnewExpedientes, map<Id,Contract> oldMapExpedientes){ 
        for(Contract expediente :lnewExpedientes){
            if((expediente.DocumentacinBasicaAportada__c != oldMapExpedientes.get(expediente.id).DocumentacinBasicaAportada__c) && expediente.DocumentacinBasicaAportada__c == true){
                if(expediente.PagoConfirmado__c == true){
                    expediente.Status = system.label.CompletandoseDocumentacion;
                }
            }   
            if((expediente.PagoConfirmado__c != oldMapExpedientes.get(expediente.id).PagoConfirmado__c) && expediente.PagoConfirmado__c == true){
                if(expediente.DocumentacinBasicaAportada__c == true){
                    expediente.Status = system.label.CompletandoseDocumentacion;
                }
            }            
        }
    }

    public static void updateStatusCommunity(List<Contract> lnewExpedientes){
        //Recuperamos las configuraciones personalizadas necesarias
        Map<String, EstadosComunidad__c> mEstadosCom = EstadosComunidad__c.getAll();
        
        //Recuperamos el schema del objeto Contract (Expediente) para obtener el valor de la etiqueta de los estados
        list<Schema.PicklistEntry> PicklistEntries = Contract.Status.getDescribe().getPicklistValues();
        Map<String,String> mApiToLabel = new Map<String,String>();
        for (Schema.PicklistEntry pe : PicklistEntries){
            mApiToLabel.put(pe.getValue(),pe.getLabel());
        }

        //Recorremos los expedientes
        for(Contract expediente : lnewExpedientes){
            //Recuperamos los dos primeros caracteres que serán el prefijo del estado y actualizamos el estado de la comunidad
            String prefix = (expediente.Status != null && expediente.Status.length() > 2) ? mApiToLabel.get(expediente.Status).left(2) : '00';
            expediente.EstadoExpedienteComunidad__c= (mEstadosCom.containsKey(prefix)) ? mEstadosCom.get(prefix).Estado__c : mEstadosCom.get('00').Estado__c;
        }
    }
}