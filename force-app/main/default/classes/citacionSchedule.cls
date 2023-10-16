/*
@author LeadClic Solutions S.L.
@date 20/05/2019
@description Clase que realiza la lógica para la citación de citas

<pre>
FECHA             AUTOR           ACCION
20/05/2019		LCS - RDM	   	  Creación. 
10/10/2019		LCS - RDM	   	  Modificación. Se añaden los campos de Oficina del evento para añadirlos al caso 
*/
global with sharing class citacionSchedule  implements Schedulable {
    /**
     *  Método que realiza las comprobaciones de fecha para crear un caso de confirmación de cita
     *  
     * @param  lista con los eventos que se han insertado
     */
    global void execute(SchedulableContext ctx) {
        list<Case> lcasos = new list<Case>();

        //Creamos las variables que utilizaremos para el filtro de la query
        //Fecha inicial del evento que sirve para el inicio de la query
        Date inicioEventoQuery = Date.Today().addDays(2);
        //Fecha inicial del evento que sirve para el final de la query
        DateTime finEventoQuery = DateTime.newinstance(inicioEventoQuery.year(), inicioEventoQuery.month(), inicioEventoQuery.day(), 23, 59, 59);
        //Obtenemos el tipo de registro Cita del evento
        Id idRecordTypeCita = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        //Recuperamos los eventos que esten a una fecha de inicio de 48h y que sean del tipo Cita
        list<Event> lEventosConfirmacion = [SELECT Id, Subject, Description, WhoId, Oficina__r.Name, Owner.Name, StartDateTime FROM Event 
                                            WHERE StartDateTime >= :inicioEventoQuery
                                            AND StartDateTime <= :finEventoQuery  
                                            AND recordTypeId = :idRecordTypeCita];

        //Si existen eventos en la lista, creamos un caso de confirmación de citas
        if(!lEventosConfirmacion.isEmpty()){
            for(Event e :lEventosConfirmacion){
                Case c = new Case();
                    c.Status = 'Nuevo';
                    c.Subject = system.label.AsuntoCasoConfirmacion;
                    c.Description = e.Subject + ':\n' + e.Description;
                    c.ContactId = e.WhoId;
                    c.OficinaCitaNoAsiste__c = e.Oficina__r.Name;
            		c.AsesorCitaNoAsiste__c = e.Owner.Name;
                	c.FechaCitaNoAsiste__c = e.StartDateTime;
                    c.OwnerId = system.label.idColaCasoConfirmacion;
                    c.Type = system.label.TipoConfirmacionCita;                    
                	c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Call Center Confirmación de cita').getRecordTypeId();
                lcasos.add(c);
            }
        }

        if(!lcasos.isEmpty()) insert lcasos;

    }
}