global with sharing class OM_ReminderEmailSchedule implements Schedulable {
	Integer offsetHours;
	Integer offsetScheduled;

	public OM_ReminderEmailSchedule ( Integer timeOffset, Integer shchedOffset) {
		offsetHours = timeOffset;
		offsetScheduled = shchedOffset;
	}
    
	global void execute(SchedulableContext sc) {
		OM_ReminderEmailBatch  batchToExecute = new OM_ReminderEmailBatch (offsetHours, offsetScheduled ); 
		database.executebatch(batchToExecute);
	}
}