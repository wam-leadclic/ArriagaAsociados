public class OM_ReminderEmailBatch implements Database.Batchable<sObject> {

	private DateTime startDate;
	private DateTime endDate;	


	//offSetHours: indica las horas de antelación con las que debe de lanzarse el recordatorio
	//offsetScheduled: indica el intervalo con el que se ejecutará el proceso (ej: cada 1 hora)
	public OM_ReminderEmailBatch(Integer offsetHours, Integer offsetScheduled) {

		//Cogemos la hora desde "en punto" hasta la siguiente vez que se ejecutará el proceso.
		DateTime nowDateTime = DateTime.now().addHours(offsetHours);
		Time currentHour = Time.newInstance(nowDateTime.hourGMT(),0,0,0);
		startDate = DateTime.newInstanceGMT(nowDateTime.date(),currentHour);
		endDate = DateTime.newInstanceGMT(nowDateTime.date(),currentHour.addHours(offsetScheduled));
    }
    
	public Database.QueryLocator start(Database.BatchableContext context) {
		String query = 'SELECT Id, ContactId, AppointmentType FROM ServiceAppointment WHERE Status = \'Dispatched\' AND SchedStartTime >=: startDate AND SchedStartTime < : endDate';
		system.debug('OM_ReminderEmailBatch:: startDate:: ' + startDate);
		system.debug('OM_ReminderEmailBatch:: endDate:: ' + endDate);
		system.debug('OM_ReminderEmailBatch:: query:: ' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext context, List<ServiceAppointment> scope) {

		Map<String,Id> templateMap = new Map<String,Id>();
		for(EmailTemplate et: [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :OM_Constants.EMAIL_TEMPLATE.keySet()]){
			templateMap.put(OM_Constants.EMAIL_TEMPLATE.get(et.DeveloperName), et.Id);
		}

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        for (ServiceAppointment appointment : scope) {

			Messaging.SingleEmailMessage emailCall = new Messaging.SingleEmailMessage();
			emailCall.setTemplateId(templateMap.get(appointment.AppointmentType));
			emailCall.setTargetObjectId(appointment.ContactId);
			emailCall.setWhatId(appointment.Id);
			emailCall.setReplyTo(OM_Constants.FROM_EMAIL);
			emailCall.setSenderDisplayName(OM_Constants.FROM_NAME); 
			emailCall.setSaveAsActivity(false);
			emailCall.setUseSignature(false);
			emails.add(emailCall);
        }
        
		try {
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);

			if (results[0].isSuccess()) {
                System.debug('Correo electrónico enviado con éxito.');
			} else {
				System.debug('Error al enviar el correo electrónico: ' + results[0].getErrors()[0].getMessage());
			}
		}
		catch (Exception e) {
			System.debug('OM_ReminderEmailBatch Exception: ' + e.getMessage());
		}
    }
    
    public void finish(Database.BatchableContext context) {}
}