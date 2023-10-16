/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Clase que se encarga de la lógica del trigger de Candidato

<pre>
FECHA                 AUTOR           ACCION
30/04/2019			LCS - RDM		 Creación.
17/05/2019          LCS - RMG        Modificación. Si el origen del candidato es Web se ejecuta el trigger en el insert para crear el producto de interés
17/07/2019          LCS - RMG        Modificación. Si al crear un contacto de web2Lead el candidato ya existe como contacto en la oportunidad que se crea se asocia 
                                    la campaña indicada en el formulario
17/03/2020          LCS - RDM        Modificación. Al crear la oportunidad, esta hereda del candidato el origen.
29/06/2020          LCS - RAL        Modificación. Se pone como propietario de la tarea a "Online Asignación de Tareas"
 
*/
public class TriggerLeadHandler {    
    /**
     *  Método que se llama desde el trigger de Candidato
     *  
     * @param  mapa de los valores actuales
     * @param  lista con los contactos que se han modificado
     */
    public static void beforeUpdate(map<Id, Lead> mOldCandidato, list<Lead> lNewCandidato){
        Map<Id, String> mCandidatosConError = new map<Id, string>();
        list<Lead> CandidatoDNICumplimentado = new list<Lead>();
        
        //Recorremos las candidato
        for(Lead candidato : lNewCandidato){
            if(!String.isBlank(candidato.TipoDocumento__c) && candidato.TipoDocumento__c != system.Label.PasaporteVal){
                //Si el estado de la candidato es Cliente y el documento de identidad es vacío, mostramos error.
                if(!String.isBlank(candidato.DocumentoIdentidad__c) && candidato.DocumentoIdentidad__c != mOldCandidato.get(candidato.id).DocumentoIdentidad__c) CandidatoDNICumplimentado.add(candidato);
                else if(!String.isBlank(candidato.DocumentoIdentidad__c) && candidato.TipoDocumento__c != mOldCandidato.get(candidato.id).TipoDocumento__c) CandidatoDNICumplimentado.add(candidato);                
            }
        }        
        
        //Enviamos las nuevas candidato y un mapa vacío de errores para realizar las comprobaciones
        if(!CandidatoDNICumplimentado.isEmpty() && CandidatoDNICumplimentado != null) validacionDNI(CandidatoDNICumplimentado, mCandidatosConError);
        
        //Si el mapa viene relleno, recorremos el mapa con las candidato actualizadas y si en el mapa esta el ID, devolvemos el error
        if(!mCandidatosConError.isEmpty() && mCandidatosConError != null){
            for (Lead candidato : lNewCandidato){
                if(mCandidatosConError.containsKey(candidato.id)){
                    candidato.addError(mCandidatosConError.get(candidato.Id));
                }                
            }
        }
        
    }
    /**
     *  Método que se llama desde el trigger de Candidato
     *  
     * @param  lista con los contactos que se han modificado
     */
    public static void beforeInsert(list<Lead> lNewCandidato){  
        Map<Id, String> mCandidatosConError = new map<Id, string>();
        list<Lead> CandidatoDNICumplimentado = new list<Lead>();
        list<Lead> lCandidatosWeb = new list<Lead>();
        //Solo comprobaremos aquellos contactos que ya tengan cumplimentado el DNI y que aun no sean cliente
        for(Lead candidato : lNewCandidato){
            if(!String.isBlank(candidato.TipoDocumento__c)){
                //Si el estado de la cuenta es Cliente y el documento de identidad es vacío, mostramos error.
                if(!String.isBlank(candidato.DocumentoIdentidad__c)) CandidatoDNICumplimentado.add(candidato);
            }
            //Si es un candidato web lo guardamos para su posterior tratamiento
            if(candidato.LeadSource == system.label.CandidatoOrigenWeb) lCandidatosWeb.add(candidato);
        }
        //Enviamos las nuevas cuentas y un mapa vacío de errores para realizar las comprobaciones
        if(!CandidatoDNICumplimentado.isEmpty() && CandidatoDNICumplimentado != null) validacionDNI(CandidatoDNICumplimentado, mCandidatosConError);
        
        //Si el mapa viene relleno, recorremos el mapa con las cuentas actualizadas y si en el mapa esta el ID, devolvemos el error
        if(!mCandidatosConError.isEmpty() && mCandidatosConError != null){
            for (Lead candidato : lNewCandidato){                
                if(mCandidatosConError.containsKey(candidato.id)){
                    candidato.addError(mCandidatosConError.get(candidato.Id));
                }                
            }
        }

        //Si existen candidatos con el origen web se procede a su tratamiento
        if(!lCandidatosWeb.isEmpty()){
            set<Lead> sIdCandidatosNoInsertar = candidatosWebProcesados(lNewCandidato);
        } 

    }   

    /**
     *  Método que se llama desde el trigger de Candidato
     *  
     * @param  lista con los contactos que se han insertado
     */
     public static void afterInsert(list<Lead> lNewCandidato){  
        //Lista con los productos de interés que se insertan
        list<LeadProduct__c> lProductoInteresNuevos = new list<LeadProduct__c>();
        //Lista con los candidatos que hay que eliminar
        list<Lead> lCandidatoEliminar = new list<Lead> ();
        for(Lead candidato :lNewCandidato){
            //Si el candidato insertado es de formulario Web se tiene que crear un producto de interés para el candidato
            if(candidato.LeadSource == system.label.CandidatoOrigenWeb && candidato.CandidatoWebEliminar__c == false){
                LeadProduct__c prodInteres = new LeadProduct__c();
                prodInteres.Candidato__c = candidato.id;
                prodInteres.Comentarios__c = candidato.description;
                prodInteres.Producto__c = candidato.ProductoFormularioWeb__c;
                lProductoInteresNuevos.add(prodInteres);
            }
            if(candidato.LeadSource == system.label.CandidatoOrigenWeb && candidato.CandidatoWebEliminar__c == true){
                Lead cand = new Lead();
                cand.id = candidato.id;
                lCandidatoEliminar.add(cand);
            }
        }

        //Insertamos los productos de interés de los candidatos de formulario web
        if(!lProductoInteresNuevos.isEmpty()) insert lProductoInteresNuevos;

        //Eliminamos los candidatos que están marcados para su eliminación
        if(!lCandidatoEliminar.isEmpty()) delete lCandidatoEliminar;
    }
    
    /**
     *  Método para realizar la comprobación del DNI y añadir a un mapa con errores
     *  
     * @param  lista con los candidatos que se han modificado
     * @param  mapa donde indicaremos los id de la cuenta error y su mensaje
     */
    public static void validacionDNI (list<Lead> lcandidatos, Map<Id, String> mCandidatosError){     
        //Recorremos las cuentas para comprobar el DNI
        for(Lead checkCandidatos: lcandidatos){  
            if(String.isBlank(checkCandidatos.DocumentoIdentidad__c)) mCandidatosError.put(checkCandidatos.id, Label.DNIVacio);
            else{
                //Enviamos el campo de DNI a la clase que realiza la comprobación  
                String validacion = ValidacionDNI.validarCif(checkCandidatos.DocumentoIdentidad__c);
                //Si la validación es errónea, añadimos el id y el error al mapa que utilizaremos mostrar el error
                if(validacion != 'OK') mCandidatosError.put(checkCandidatos.id, validacion);
            }
        }      
        
    }

    /**
     *  Método que se encarga de tratar los candidatos que han venido por web
     *  
     * @param  lista con los candidatos que se han insertadps
     */
     public static set<Lead> candidatosWebProcesados (list<Lead> lCandidatos){
         Set<String> subjectsToMapToQueue = new Set<String>();
         // Cola Asignacion de Tarea Por Defecto
         Id DEFAULT_EMPTY_SUBJECT = [Select Id, name from Group Where Name = :System.Label.ColaAsignacionTareas limit 1].Id;
         // Cola Online Asignacion de Tarea
         for(Lead leadIndividual : lCandidatos) subjectsToMapToQueue.add(leadIndividual.Asunto_Formulario_Web__c);
         // Inicio Mapping Asunto - Cola
         /* Se hace un mapeo usando un metadata que asocia Asunto con Cola */
         List<Asignaci_n_Formularios_Web_Colas__mdt> listQueuesMdt = [Select Asunto_Formulario__c, Cola__c from Asignaci_n_Formularios_Web_Colas__mdt where Asunto_Formulario__c in :subjectsToMapToQueue];
         Map<String,String> subjectQueueMap = new Map<String,String>();
         Set<String> subjectsList = new Set<String>();
         for(Asignaci_n_Formularios_Web_Colas__mdt metadataQueue : listQueuesMdt){
             subjectsList.add(metadataQueue.Cola__c);
         }
         Map<String,Id> groupToMap = new Map<String,Id>();
         List<Group> idQueuesOnline = [Select Id, name from Group Where Name in :subjectsList];
         for(Group g : idQueuesOnline){
             for(Asignaci_n_Formularios_Web_Colas__mdt metadataQueue : listQueuesMdt){
                 if(metadataQueue.Cola__c == g.name) groupToMap.put(metadataQueue.Asunto_Formulario__c, g.Id);
             }
         }
        // Fin Mapping Asunto - Cola
        // Usando mapping Asunto - Cola se mapea directamente el Lead con la cola necesaria
         for(Lead leadToMap : lCandidatos){
             Id queueId = groupToMap.get(leadToMap.Asunto_Formulario_Web__c);
             if(queueId != null){
                 subjectQueueMap.put(leadToMap.NombreApellidoEmail__c, queueId);   
             }
             else{
                 subjectQueueMap.put(leadToMap.NombreApellidoEmail__c, DEFAULT_EMPTY_SUBJECT);
             }
         }
         /* Fin mapeo Colas - Leads */
                               
         set<Lead> sIdCandidatosExistentes = new set<Lead> ();
        //Recorremos los candidatos que son de web y añadimos en una lista el nombre+apellido+email y en otra lista los emails
        list<string> lEmailCandidatos = new list<string>();
        list<string> lNombreApellidoEmailCandidato = new list<string>();
        list<Id> lIdProductos = new list<Id> ();
        for(Lead candidato :lCandidatos){
            lEmailCandidatos.add(candidato.email);
            lNombreApellidoEmailCandidato.add(candidato.NombreApellidoEmail__c);
            lIdProductos.add(candidato.ProductoFormularioWeb__c);
        }

        //Buscamos los productos en los que están interesados los candidatos
        map<Id, Product2> mIdProductos = new map<Id, Product2> ([SELECT Id, Name 
                                                                FROM Product2
                                                                WHERE id IN : lIdProductos]);

        //Buscamos el precio unitario de cada producto
        list<PricebookEntry> lPriceBookEntry = [SELECT Id, UnitPrice, Product2Id
                                                FROM PriceBookEntry 
                                                WHERE Product2Id IN :lIdProductos
                                                AND IsActive = true
                                                AND PriceBook2.IsStandard = true]; 

        map<Id, PriceBookEntry> mIdProductoPriceBookEntry = new map<Id, PriceBookEntry>();
        for(PricebookEntry pbe :lPriceBookEntry){
            mIdProductoPriceBookEntry.put(pbe.Product2Id, pbe);
        }                                                                                                               

        //Mapa con los contactos y candidatos que se han encontrado
        map<string, Contact> mContactos = new map<string, Contact>();
        map<string, Lead> mCandidatos = new map<string, Lead>();
        
       
        //Buscamos si existen contacto con el email
        list<Contact> lContactosEmail = [SELECT Id, Email, OwnerId, AccountId, NombreApellidoEmail__c
                                            FROM Contact
                                            WHERE Email IN :lEmailCandidatos];

        for(Contact contacto :lContactosEmail){
            mContactos.put(contacto.Email, contacto);
            mContactos.put(contacto.NombreApellidoEmail__c, contacto);
             
        }                                             

        //Buscamos si existen candidatos por el email
        list<Lead> lCandidatosEmail = [SELECT Id, Email, NombreApellidoEmail__c, CreatedDate, Status
                                            FROM Lead
                                            WHERE Email IN :lEmailCandidatos];

        for(Lead candidato :lCandidatosEmail){
            mCandidatos.put(candidato.Email, candidato);
            mCandidatos.put(candidato.NombreApellidoEmail__c, candidato);
        }  

        //Lista con los contactos que hay que actualizar la información de GDPR
        list<Contact> lContactosUpdate = new list<Contact>();
        //Lista con los candidatos que hay que actualizar su información
        list<Lead> lCandidatosUpdate = new list<Lead>();
        //Lista con los productos de interés que se insertan
        list<LeadProduct__c> lProductoInteresNuevos = new list<LeadProduct__c>();
        //Lista con las oportunidades que se insertan
        list<Opportunity> lOportunidadesNuevas = new list<Opportunity>();
        //Lista de los productos de oportunidad
        list<OpportunityLineItem> lProductoOportunidadNuevas = new list<OpportunityLineItem>();
        //Lista con las tareas que se insertan asociadas al comercial del contacto
        list<Task> lTareasNuevas = new list<Task>();

        //Recorremos los candidatos con origen web
        List<Crear_Tarea_en_Candidato_Web_Duplicado__e> lEvents = new List<Crear_Tarea_en_Candidato_Web_Duplicado__e>();
        List<Id> candidatosConReentradaTratada = new List<Id>();
        String apiConvertedStatusName = [Select Id, MasterLabel, ApiName from LeadStatus  where IsConverted=true limit 1].ApiName;
        for(Lead candidato :lCandidatos){
            candidato.OwnerId = subjectQueueMap.get(candidato.NombreApellidoEmail__c);
            Contact contacto = new Contact();
            Lead candidatoExistente = new Lead();
            //Vemos si existe ya un contacto con nombre+apellido+email
            if(mContactos.containsKey(candidato.NombreApellidoEmail__c)) contacto = mContactos.get(candidato.NombreApellidoEmail__c);
            //Si no existe miramos si existe un contacto por email
            if(contacto.id == null && mContactos.containsKey(candidato.Email)) contacto = mContactos.get(candidato.Email);

            //Si hemos encontrado a un contacto se crea una oportunidad con el producto indicado en el formulario
            if(contacto.id != null){
                //Meter el mensaje del formulario en la oportunidad
                Opportunity oportunidadNueva = new Opportunity();
                oportunidadNueva.AccountId = contacto.AccountId;
                oportunidadNueva.CloseDate = system.today();
                oportunidadNueva.StageName = system.label.OportunidadCalificacion;
                oportunidadNueva.Pricebook2Id = system.label.ListaPreciosEstandar;
                if(mIdProductos.containsKey(candidato.ProductoFormularioWeb__c)) oportunidadNueva.Name = mIdProductos.get(candidato.ProductoFormularioWeb__c).Name;
                oportunidadNueva.Description = candidato.description;
                oportunidadNueva.IdProducto__c = candidato.ProductoFormularioWeb__c;
                oportunidadNueva.CampaignId = candidato.idCampanaWeb__c;
                oportunidadNueva.LeadSource = candidato.LeadSource;
                lOportunidadesNuevas.add(oportunidadNueva);                                
                
                //Se actualiza la información de GDPR del contacto
                Contact contactoUpdate = new Contact();
                contactoUpdate.id = contacto.id;
                contactoUpdate.AceptoPoliticaPrivacidad__c = candidato.AceptoPoliticaPrivacidad__c;
                contactoUpdate.DeseoRecibirComunicacionesComerciales__c = candidato.DeseoRecibirComunicacionesComerciales__c;
                lContactosUpdate.add(contactoUpdate);

                //Si hemos encontrado un contacto se crea una tarea al comercial (propietario del contacto) asociada a la oportunidad insertada
                Task tareaNueva = new Task();
                // tareaNueva.OwnerId = subjectQueueMap.get(candidato.subject) != null ? subjectQueueMap.get(candidato.subject) : subjectQueueMap.get("DEFAULT_EMPTY_SUBJECT");
                tareaNueva.OwnerId = subjectQueueMap.get(candidato.NombreApellidoEmail__c);
                tareaNueva.Description = candidato.Description;
                tareaNueva.Subject = system.label.AsuntoTareaFormularioWeb;
                tareaNueva.Status = system.label.EstadoTareasNoIniciada;
                tareaNueva.ActivityDate = system.today();
                tareaNueva.WhoId = contacto.id;
                //tareaNueva.WhatId = oportunidad.id;
                lTareasNuevas.add(tareaNueva);
            }            


            //Si no hemos encontrado el contacto buscamos si existe un candidato con el nombre+apellido+email
            if(contacto.id == null && mCandidatos.containsKey(candidato.NombreApellidoEmail__c)) candidatoExistente = mCandidatos.get(candidato.NombreApellidoEmail__c);
            //Si no existe miramos si existe un candidato con el email
            if(contacto.id == null && candidatoExistente.id == null && mCandidatos.containsKey(candidato.Email)) candidatoExistente = mCandidatos.get(candidato.Email);
            //Si existe se actualiza la información del candidato
            if(candidatoExistente.id != null){
                //Actualizamos la información del candidato
                candidatoExistente.FirstName = candidato.FirstName;
                candidatoExistente.LastName = candidato.LastName;
                candidatoExistente.email = candidato.email;
                candidatoExistente.phone = candidato.phone;

                //Se actualiza la información de GDPR                
                candidatoExistente.AceptoPoliticaPrivacidad__c = candidato.AceptoPoliticaPrivacidad__c;
                candidatoExistente.DeseoRecibirComunicacionesComerciales__c = candidato.DeseoRecibirComunicacionesComerciales__c;
                lCandidatosUpdate.add(candidatoExistente);
                //Se crea un producto de interés para ese candidato
                //Mensaje del formulario añadido en el producto de interés
                LeadProduct__c prodInteres = new LeadProduct__c();
                prodInteres.Candidato__c = candidatoExistente.id;
                prodInteres.Comentarios__c = candidato.description;
                prodInteres.Producto__c = candidato.ProductoFormularioWeb__c;
                lProductoInteresNuevos.add(prodInteres);
            }

            system.debug('TEST ' + contacto.id);
            //Si hemos encontrado un contacto o un candidato se guarda en el set para luego eliminarlo de la lista de registros que hay que insertar
            if(contacto.id != null || candidatoExistente.id != null){ 
                //Se marca el candidato para su eliminación ya que se crea la información del formulario Web en el contacto o candidato existente
                candidato.CandidatoWebEliminar__c = true;
                sIdCandidatosExistentes.add(candidato);
                if(!candidatosConReentradaTratada.contains(candidatoExistente.id)){
                    Datetime tomorrowsDate = Datetime.newInstance(
                        Date.today().addDays(1),
                        Time.newInstance(0, 0, 0, 0));
                    Datetime todaysDate = Datetime.newInstance(
                        Date.today(),
                        Time.newInstance(0, 0, 0, 0));
                    system.debug('Today : ' + todaysDate + ' | Tomorrow : ' + tomorrowsDate);
                    //Se comprueba si el candidato ya tenía tarea creada en el mismo día, en caso de tenerlo
                    
                    List<Task> lTareasCandidatosDuplicadoToday = new List<Task>([SELECT Id FROM Task where WhoId = :candidatoExistente.Id and CreatedDate > :todaysDate and CreatedDate < :tomorrowsDate]);
                    system.debug('TEST LIST : ' + lTareasCandidatosDuplicadoToday);
                    system.debug('TEST ' + contacto.id);
                    if(lTareasCandidatosDuplicadoToday.isEmpty()){
                        Crear_Tarea_en_Candidato_Web_Duplicado__e event = new Crear_Tarea_en_Candidato_Web_Duplicado__e();                            
                        event.OwnerId__c = subjectQueueMap.get(candidato.NombreApellidoEmail__c);
                        event.Description__c = system.label.DescripcionSolicitudInfoFormularioWeb;
                        event.Subject__c = system.label.AsuntoTareaFormularioWeb;
                        event.Status__c = system.label.EstadoTareasNoIniciada;
                        event.ActivityDate__c = system.today();
                        if(candidatoExistente.Status == apiConvertedStatusName || contacto.Id != null){
                            event.WhatId__c = contacto.AccountId;
                            event.WhoId__c = contacto.Id;                    
                        }
                        else
                            event.WhoId__c = candidatoExistente.id;                    
                        lEvents.add(event);
                        system.debug('TEST Event ' + event.WhatId__c + ' --- ' + event.WhoId__c);
                        Database.SaveResult eventLog = EventBus.publish(event);
                        if (eventLog.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted account. Account ID: ' + eventLog.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : eventLog.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Account fields that affected this error: ' + err.getFields());
                            }
                        }
                        candidatosConReentradaTratada.add(candidatoExistente.id);
                    }
                }
        	}
        }
         
        if(!lTareasNuevas.isEmpty()) insert lTareasNuevas;
        //Insertamos o modificamos los registros anteriormente tratados
        system.debug('***lContactosUpdate*'+lContactosUpdate);
        if(!lContactosUpdate.isEmpty()) update lContactosUpdate;
        if(!lCandidatosUpdate.isEmpty()) update lCandidatosUpdate;
        if(!lProductoInteresNuevos.isEmpty()) insert lProductoInteresNuevos;
        if(!lOportunidadesNuevas.isEmpty()) insert lOportunidadesNuevas;



        //Una vez insertadas las oportunidades se crea el producto asociado a cada oportunidad
        for(Opportunity oportunidad :lOportunidadesNuevas){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.Product2Id = oportunidad.IdProducto__c;
            oli.Quantity = 1;
            oli.OpportunityId = oportunidad.id;
            oli.TotalPrice = mIdProductoPriceBookEntry.get(oli.Product2Id).UnitPrice;
            lProductoOportunidadNuevas.add(oli);
        }

        if(!lProductoOportunidadNuevas.isEmpty()) insert lProductoOportunidadNuevas;

        return sIdCandidatosExistentes;
     }
}