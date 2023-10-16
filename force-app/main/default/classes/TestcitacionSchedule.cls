/*
@author LeadClic Solutions S.L.
@date 21/05/2019
@description Clase Test para la clase programada citacionSchedule

<pre>
FECHA             AUTOR           ACCION
21/05/2019		LCS - RDM	   	  Creación. 
*/
@isTest
public with sharing class TestcitacionSchedule {
    @isTest static void TestReprogramacion() {

        Contact c = new Contact();
            c.FirstName = 'Test';
            c.LastName = 'TestApell';
            c.Phone = '658951256';
        insert c;

        Event e = new Event();
            e.Subject = 'Test';
            e.Description = 'Testing';
            e.StartDateTime = system.now().addDays(2);
            e.EndDateTime = system.now().addDays(4);
            e.WhoId = c.id;
            e.RecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Cita').getRecordTypeId();
        insert e;

        test.starttest();
            citacionSchedule myClass = new citacionSchedule ();   
            String chron = '0 0 23 * * ?';        
            system.schedule('Test Sched', chron, myClass);
        test.stopTest();
    }
}