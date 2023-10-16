/*
@author LeadClic Solutions S.L.
@date 10/05/2019
@description Clase manejadora del trigger de evento


FECHA             AUTOR           ACCION
10/05/2019		LCS - RMG	   	  Creación. 
17/05/2019		LCS - RDM	   	  Modificación. Se crea el método afterUpdate para que una vez se haya modificado el estado del evento a  "No asistido"(no definitivo), 
                                                creemos un caso de recaptura
27/05/2019		LCS - RDM	   	  Modificación. Se crea el método beforeUpdate para que antes de crear el evento modificar el propietario del Lead o Contact por el del Evento
05/06/2019		LCS - RDM	   	  Modificación. Se añade al caso de recaptura el tipo de registro de Call Center
17/07/2019		LCS - RDM	   	  Modificación. Se modifiaca el caso de recaptura para que el tipo de registro sea Call Center Recaptura y se le añade el campo Origin con Cita no atendida
23/07/2019		LCS - RDM	   	  Modificación. Se añade el cambio de estado de la cuenta relacionado para indicar que es de Recaptura
10/10/2019		LCS - RDM	   	  Modificación. Se añade método beforedelete
08/06/2020		LCS - RAL		  Modificación. Se elimina la relación del recurso y el evento cuando se pasa a estado "Cancelada" o "Reasignado"
*/
public without sharing class TriggerEventHandler {
    /**
     *  Método que se llama desde el trigger de Evento cuando se va a realizar un borrado de eventos
     *  
     * @param  lista con los eventos que se se quieren borrar
     */
    public class msgErrorEventoException extends Exception {}
    public static void beforeDelete(list<Event> lOldEvent){
        Map<Id, String> mEventErrors = new Map<Id,String>();
        //Comprobamos los IDs de los perfiles que pueden realizar el borrado de eventos. Si no devolvemos un error.
        Map<String, ProfileAllowedToDelEvent__c> mProfileAllowed = ProfileAllowedToDelEvent__c.getAll();
        //Si el usuario ejecutor no es un administrador del sistema no permitimos eliminar el evento
        Boolean scheduledEvent = false;
        for(Event oldEv: lOldEvent){
            scheduledEvent = (oldEv.ServiceAppointmentId  != null);
        }
        if(!scheduledEvent && !mProfileAllowed.containsKey(userinfo.getProfileId())){
            throw new msgErrorEventoException(system.Label.errorPermisosEvento);
        }
    }
    /**
     *  Método que se llama desde el trigger de Evento cuando se inserta un evento
     *  
     * @param  lista con los eventos que se han insertado
     */
    public static void afterInsert(list<Event> lNewEvent){
        //Recorremos los eventos insertados y si son del tipo de registro Cita y asociados a un candidato se convierte al candidato en cuenta y contacto
        list<Id> lCandidatosConvertir = new list<Id> ();
        Id idRecordTypeCita = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        for(Event evento :lNewEvent){
            Id idWho = evento.WhoId;
            if(evento.recordTypeId == idRecordTypeCita && evento.WhoId != null && string.valueOf(idWho.getsobjecttype()) == 'Lead'){
                lCandidatosConvertir.add(evento.WhoId);
            }
        }
        
        //Si hemos encontrado algún candidato asociado al evento del tipo de registro se convierte
        if(!lCandidatosConvertir.isEmpty()) LeadCustomConvert.convertLeads(lCandidatosConvertir);

    }
    /**
     *  Método que se llama desde el trigger de Evento cuando se inserta un evento
     *  
     * @param  lista con los eventos que se han insertado
     */
    public static void beforeInsert(list<Event> lNewEvent){
        list<Id> lLeadProp = new list<Id>();//Candidatos a modificar propietario
        list<Id> lContactProp = new list<Id>();//Contactos a modificar propietario
        Map<Id, String> mLeadProp = new Map<Id, String>();//Mapa de Candidatos a modificar propietario
        Map<Id, String> mContactProp = new Map<Id, String>();//Mapa de Contactos a modificar propietario
        String propietarioEvento;

        //Recorremos los eventos los cuales se van a insertar
        for(Event evento : lNewEvent){
            //Recuperamos el objeto relacionado al caso (si existe)
            if(!String.isBlank(evento.WhoId)){
                //Metemos el ID en un String para poder comprobar sus primeros valores y ver si es contacto o Lead
                String relacionado = evento.WhoId;
                if(relacionado.startsWith('00Q')){
                    //Si es un lead lo metemos en una lista y su propietario en un mapa
                    lLeadProp.add(evento.WhoId);
                    if(!String.isBlank(evento.OwnerId)){
                        mLeadProp.put(evento.WhoId, evento.OwnerId);
                    }
                    else{
                        mLeadProp.put(evento.WhoId, null);
                    }
                }else{
                    //Si es contacto lo metemos en una lista y su propietario en un mapa
                    lContactProp.add(evento.WhoId);
                    if(!String.isBlank(evento.OwnerId)){
                        mContactProp.put(evento.WhoId, evento.OwnerId);
                    }
                    else{
                        mContactProp.put(evento.WhoId, null);
                    }
                }
            }
        }

        //Enviamos las listas al método correspondiente si el propietario del evento es distinto a nulo y si el WhoId es Lead o Contact
        if(!lLeadProp.isEmpty() && mLeadProp.isEmpty() != null) propietarioCandidato(lLeadProp, mLeadProp);
        if(!lContactProp.isEmpty() && mContactProp.isEmpty() != null) propietarioContacto(lContactProp, mContactProp);
    }
    /**
     *  Método que se llama desde el trigger de Evento cuando se actualiza un evento
     *  
     * @param  lista con los eventos que se han actualizado
     * @param  mapa con los eventos que se han actualizado
     */
    public static void afterUpdate(list<Event> lNewEvent, map<Id,Event> mOldMap){
        list<Event> eventToRecaptura = new list<Event>();
        list<Id> contactToRecaptura = new list<Id>();
        Set<Id> eventToDeleteRelation = new Set<Id>();

        for(Event e :lNewEvent){
            //Al recorrer los eventos, comporbamos que el campo Estado__c del evento ha sido modificado y cuyo estado es no asiste, si es asi añadimos el evento a una
            //lista la cual enviaremos a un método donde crearemos el caso del tipo recaptura y añadimos los IDs del Contacto relacionado
            if(e.Estado__c != mOldMap.get(e.Id).Estado__c && e.Estado__c == system.label.NoAsiste) eventToRecaptura.add(e); contactToRecaptura.add(e.WhoId);
            if(e.Estado__c != mOldMap.get(e.Id).Estado__c && (e.Estado__c != system.label.Cancelada || e.Estado__c != system.label.Reagendada)) eventToDeleteRelation.add(e.Id);
        }

        if(!eventToRecaptura.isEmpty()) casoRecaptura(eventToRecaptura, contactToRecaptura);
        if(!eventToDeleteRelation.isEmpty()) deleteRelations(eventToDeleteRelation);

    }    
    /**
     *  Método que se llama desde el método afterUpdate que sirve para crear los casos del tipo recaptura correspondientes a los eventos
     *  
     * @param  lista con los eventos a los cuales hay que abrirles un caso del tipo recaptura
     * @param  lista con los id de contactos relacionados a los eventos
     * 
     */
    public static void casoRecaptura(list<Event> leventToCase, list<Id> lcontactToCase){
        list<Case> lCasoRecaptura = new list<Case>();
        list<Id> lCuentaRelacionada = new list<Id>();
        list<Account> lAccountUpdateStatus = new list<Account>();
        list<Id> lIdEvent = new List<Id>();
        for(Event e : leventToCase){
            lIdEvent.add(e.Id);
        }
        
        map<Id, Event> mEventOficinaAsesor = new map<Id, Event>([SELECT Id, Oficina__r.Name, Owner.Name FROM Event WHERE Id IN :lIdEvent]);
        map<Id,Contact> mContacto = new map<Id,Contact>([SELECT Id, Name, AccountId FROM Contact WHERE Id IN :lcontactToCase]);

        //Recorremos los eventos para asignar los campos al caso
        for(Event e :leventToCase){
            Contact contactoRel = mContacto.get(e.WhoId);
            lCuentaRelacionada.add(contactoRel.AccountId);//Metemos el id de cuenta para luego recorrer esas cuentas y actualizar su estado
            Case c = new Case();
                c.Status = 'Nuevo';
                c.Subject = system.Label.citaNoAtendidaSubject;
                c.Description = system.label.DescCasoRecaptura + ' ' + contactoRel.Name + ':\n' + e.Description;
                c.ContactId = e.WhoId;
            	c.OficinaCitaNoAsiste__c = mEventOficinaAsesor.get(e.Id).Oficina__r.Name;
            	c.AsesorCitaNoAsiste__c = mEventOficinaAsesor.get(e.Id).Owner.Name;
            	c.FechaCitaNoAsiste__c = e.StartDateTime;
                c.OwnerId = system.label.IdCasoCitaNoAtendida;//e.OwnerId;
                c.Type = system.label.TipoCasoRecaptura;//Recaptura       
            	c.Origin = System.label.caseOrigenCitaNAtendida; //Cita no atendida
            	c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center Recaptura').getRecordTypeId();
            lCasoRecaptura.add(c);
        }

        if(!lCuentaRelacionada.isEmpty()){
            //Recuperamos las cuentas relacionadas al contacto del evento
            list<Account> lRelatedAccount = [SELECT Id, EstadoCuenta__c FROM Account WHERE Id IN :lCuentaRelacionada];
            //Recorremos la lista y cambiamos el estado
            for(Account a : lRelatedAccount){
                if(a.EstadoCuenta__c != system.label.EstadoCuentaCliente){
                    a.EstadoCuenta__c = system.label.TipoCasoRecaptura;

                    lAccountUpdateStatus.add(a);
                }
            }
        }
        
        //Inserciones y actualizaciones
        if(!lAccountUpdateStatus.isEmpty()) update lAccountUpdateStatus;
        if(!lCasoRecaptura.isEmpty()) insert lCasoRecaptura;
    }    
    /**
     *  Método que se llama desde el método beforeInsert que sirve para modificar el propietario del candidato por el del Evento
     *  
     * @param  lista con los id de candidatos relacionados a los eventos
     * 
     */
    public static void propietarioCandidato(list<Id> lIdCandidato, Map<Id, String> mLeadProp){
        //Recuperamos los candidatos de los Ids los cuales vamos a modificar el propietario
        list<Lead> lLead = [SELECT Id, OwnerId FROM Lead WHERE Id IN :lIdCandidato];
        //Lista para actualizar
        list<Lead> lLeadUpdate = new list<Lead>();

        //Recorremos los candidatos y si el OwnerId es distinto al del evento, lo añadimos a la lista para actualizar
        for(Lead candidato :lLead){
            if(mLeadProp.containsKey(candidato.Id)){
                String propietarioEvento = mLeadProp.get(candidato.Id);
                if(candidato.OwnerId != propietarioEvento){
                    candidato.OwnerId = propietarioEvento;
                    lLeadUpdate.add(candidato);
                }
            }
        }

        //Actualizamos la lista de candidatos para actualizar
        if(!lLeadUpdate.isEmpty()) update lLeadUpdate;
    }    
    /**
     *  Método que se llama desde el método beforeInsert que sirve para modificar el propietario del contacto por el del Evento
     *  
     * @param  lista con los id de contacto relacionados a los eventos
     * 
     */
    public static void propietarioContacto(list<Id> lIdContacto, Map<Id, String> mContactProp){
        //Recuperamos los contacto de los Ids los cuales vamos a modificar el propietario
        list<Contact> lContact = [SELECT Id, OwnerId FROM Contact WHERE Id IN :lIdContacto];
        //Lista para actualizar
        list<Contact> lContactUpdate = new list<Contact>();

        //Recorremos los contactos y si el OwnerId es distinto al del evento, lo añadimos a la lista para actualizar
        for(Contact contacto :lContact){
            if(mContactProp.containsKey(contacto.Id)){
                String propietarioEvento = mContactProp.get(contacto.Id);
                if(contacto.OwnerId != propietarioEvento){
                    contacto.OwnerId = propietarioEvento;
                    lContactUpdate.add(contacto);
                }
            }
        }

        //Actualizamos la lista de contactos para actualizar
        if(!lContactUpdate.isEmpty()) update lContactUpdate;

    }
    
    /**
     *  Método que se llama desde el método afterUpdate que sirve para eliminar la relación del evento con la sala cuando pasa a "Cancelada" o "Reagendada"
     *  
     * @param  set con los ids de evento
     * 
     */
    public static void deleteRelations(Set<Id> idEvent){
        // List of relations to delete
        List<EventRelation> lEventToDelete = new List<EventRelation>();
        
        for(EventRelation rel : [SELECT Id, RelationId, EventId FROM EventRelation WHERE EventId IN :idEvent]) {
            if(String.valueOf(rel.RelationId).startsWith('023')) lEventToDelete.add(rel);
        }
        
        // Delete relations
        if (!lEventToDelete.isEmpty()) delete lEventToDelete;
    }
    
}