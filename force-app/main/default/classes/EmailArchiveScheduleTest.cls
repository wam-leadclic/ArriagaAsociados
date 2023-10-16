/*
@author LeadClic Solutions S.L.
@date 15/08/2023
@description Test de la clase schedule para el batch de archivado de emails antiguos.

<pre>
FECHA             AUTOR           ACCION
15/08/2023		LCS - DRU	   	  Creación. 
*/

@isTest
private class EmailArchiveScheduleTest {

    @testSetup static void setup() {
        //Test data setup
        Account testAccount = new Account();
		testAccount.Name='Test Account' ;
        testAccount.Phone = '455565464';
		insert testAccount;
		
		Contact cont = new Contact();
		cont.FirstName='Test';
		cont.LastName='Test';
		cont.Accountid= testAccount.id;
		insert cont;

        Case caseObj = new Case(
        ContactId = cont.id,
        AccountId = testAccount.id,
        Status = 'Working',
        Origin = 'Phone');

        insert caseObj;

        EmailMessage emailMessage = new EmailMessage(
            Subject = 'Test Email',
            TextBody = 'This is a test email',
            MessageDate = Date.today().addDays(-31),
            ParentId = caseObj.id
        );

        insert emailMessage;
    }

    
    /**
     * Método test para verificar el lanzamiento del batch.
     */
    @isTest
    static void testExecute() {
        
        //Programación de la ejecución de la clase batch.
        Test.startTest();
        String chron = '0 0 23 * * ?';       
        String jobId = System.schedule('Email Archive Batch Job', chron, new EmailArchiveSchedule());
        Test.stopTest();
        
        //Comprobamos que el batch se haya ejecutado
        Integer executedJobs = [
            SELECT count() FROM AsyncApexJob
            WHERE JobType = 'BatchApex'
            AND ApexClass.Name = 'EmailArchiveBatch'
        ];
        system.assertEquals(1, executedJobs, 'The job should be scheduled');
    }
}