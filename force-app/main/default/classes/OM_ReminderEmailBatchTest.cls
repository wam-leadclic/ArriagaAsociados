@IsTest
private class OM_ReminderEmailBatchTest {
    
    @IsTest
    static void testBatchExecution() {

        Contact contact = new Contact();
        contact.FirstName = 'John';
        contact.LastName = 'Doe';
        contact.Email = 'test@example.com';
        insert contact;

		Lead newLead = new Lead();
		newLead.LastName = 'Test Lead';
        newLead.FirstName = 'FirstName';
		newLead.Phone = '661616161';
        newLead.PostalCode = '50013';
        newLead.Email = 'test@example.com';
		insert newLead;

		OperatingHours oh = new OperatingHours();
		oh.Name = 'Horario de Trabajo';
		oh.TimeZone = 'America/Los_Angeles';
		oh.Description = 'Horario de trabajo estándar';
		insert oh;
        
        ServiceTerritory territory = new ServiceTerritory();
		territory.OperatingHoursId = oh.Id;
        territory.Name = 'Territory';
		territory.IsActive = true;
        insert territory;
        
        ServiceAppointment appointment = new ServiceAppointment();
        appointment.ContactId = contact.Id;
        appointment.ServiceTerritoryId = territory.Id;
        appointment.Email = 'test@example.com';
        appointment.SchedStartTime = DateTime.now().addHours(24);
        appointment.AppointmentType = 'Call';
		appointment.ParentRecordId = newLead.Id;
        insert appointment;

        Integer timeOffset = 24;
        Integer shchedOffset = 1;
        
        // Crea una instancia de la clase OM_ReminderEmailSchedule utilizando los valores de prueba
        OM_ReminderEmailSchedule scheduleInstance = new OM_ReminderEmailSchedule(timeOffset, shchedOffset);
        
        Test.startTest();
        scheduleInstance.execute(null);
        Test.stopTest();
    }

}