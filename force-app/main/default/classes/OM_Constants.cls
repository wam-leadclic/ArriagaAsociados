/*
@author OMEGA CRM
@date 10/02/2023
@description Class that stores all the constants of the project.

<pre>
FECHA                 AUTOR           ACCION
10/02/2023			OMEGA CRM		 Creación 
*/
public class OM_Constants {
    // General constants.
    public static final String CONST_YES = 'Yes';
    public static final String CONST_NO = 'No';
    
    //Llamadas 
    public static final Map<String, String> CALL_TYPE = new Map<String, String>{'INBOUND' => 'Inbound', 'OUTBOUND' => 'Outbound'};
    public static final Map<String, String> CALL_STATUS = new Map<String, String>{'NEW' => 'Nueva', 'PENDING' => 'Pendiente', 'PROGRESS' =>'En curso'};
    public static final Map<String, String> CALL_STATUS_CLOSED = new Map<String, String>{'END' => 'Finalizada', 'NOTFOUND' => 'Cliente no localizado', 'CANCELLED' => 'Cancelada'};
    public static final Map<String, String> OUTBOUND_TYPE = new Map<String, String>{'OUTOFTIME' => 'Fuera de horario', 'ABANDONED' => 'Llamada abandonada'};

    //Autocita
    public static final Map<String, String> EMAIL_TEMPLATE = new Map<String, String>{'OM_NewAppointmentCall' => 'Call', 'OM_NewAppointmentPeople' => 'People', 'OM_NewAppointmentVideo' => 'Video'};
    public static final String FROM_EMAIL = OM_GeneralSettings__c.getInstance().OM_AutocitaEmail__c;
    public static final String FROM_NAME = 'Autocita - Arriaga Asociados';

    
}