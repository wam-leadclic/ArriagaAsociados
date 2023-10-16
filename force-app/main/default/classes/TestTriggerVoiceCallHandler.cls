/*
@author OMEGA CRM
@date 07/02/2023
@description Clase Test para el trigger de VoiceCall y su handler.

<pre>
FECHA                 AUTOR           ACCION
07/02/2023			OMEGA CRM		 Creación 
*/
@isTest
public class TestTriggerVoiceCallHandler {
    private static final String TEST_NAME = 'QueueNameTest';
    //private static final String TEST_COLA_OFI = 'SCV_ASESOR_OFI_PLENI';

    @TestSetup
    static void makeData(){

        Account cuentaPersonal = new Account();

        User uTest = TestAux.createNewUser();
        System.runAs(uTest) {
            cuentaPersonal.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId();
            cuentaPersonal.PersonEmail = 'test@test.com';
            cuentaPersonal.FirstName = 'Tesst';
            cuentaPersonal.LastName = 'Test';
            cuentaPersonal.EstadoCuenta__c = 'Cliente';
            insert cuentaPersonal;
        }
        String queueName = 'SCV_TestQueue';
        
        List<Group> queueList = new List<Group>();
        Group testQueue = new Group(Name='SCV_TestQueue',DeveloperName = 'SCV_TestQueue', Type='Queue');
        Group testQueueCB = new Group(Name='SCV_TestQueue_CB',DeveloperName = 'SCV_TestQueue_CB', Type='Queue');
        Group testQueueOffice = new Group(Name='SCV_ASESOR_OFI_PLENI', DeveloperName = 'SCV_ASESOR_OFI_PLENI', Type='Queue');
        
        insert testQueue;
        insert testQueueCB;
        //insert testQueueOffice;

        QueuesObject testQueueSO = new QueueSObject(QueueID = testQueue.id, SobjectType = 'OM_Callback__c');
        QueuesObject testQueueSOCB = new QueueSObject(QueueID = testQueueCB.id, SobjectType = 'OM_Callback__c');
        //QueuesObject testQueueOfficeCB = new QueueSObject(QueueID = testQueueOffice.id, SobjectType = 'OM_Callback__c');
        List<QueuesObject> qsoList = new List<QueuesObject>();
        qsoList.add(testQueueSO);
        qsoList.add(testQueueSOCB);
        //qsoList.add(testQueueOfficeCB);
        insert qsoList;

        CallCenter ccRecord = [Select Id FROM CallCenter LIMIT 1];

        List<VoiceCall> vcList = new List<VoiceCall>();
        VoiceCall vcRecord = new VoiceCall();
        vcRecord.CallStartDateTime = DateTime.now();
        vcRecord.CallEndDateTime = DateTime.now();
        vcRecord.FromPhoneNumber = '+34656565656';
        vcRecord.ToPhoneNumber = '+34909658563';
        vcRecord.CallType = OM_Constants.CALL_TYPE.get('INBOUND');
        vcRecord.RelatedRecordId = cuentaPersonal.Id;
        vcRecord.CallAcceptDateTime = null;
        vcRecord.QueueName = String.isNotBlank(queueName) ? queueName : '';
        vcRecord.OM_OriginQueue__c = vcRecord.QueueName;
        vcRecord.OM_Account__c = cuentaPersonal.Id;
        vcRecord.VendorType = 'ContactCenter';
        vcRecord.CallCenterId = ccRecord.Id;
        vcList.add(vcRecord);
        
        VoiceCall vcRecord2 = new VoiceCall();
        vcRecord2.CallStartDateTime = DateTime.now();
        vcRecord2.CallEndDateTime = DateTime.now();
        vcRecord2.FromPhoneNumber = '+34666666666';
        vcRecord2.ToPhoneNumber = '+34999999999';
        vcRecord2.CallType = OM_Constants.CALL_TYPE.get('INBOUND');
        vcRecord2.RelatedRecordId = cuentaPersonal.Id;
        vcRecord2.CallAcceptDateTime = null;
        vcRecord2.QueueName =  TEST_NAME;
        vcRecord2.OM_OriginQueue__c = vcRecord2.QueueName;
        vcRecord2.OM_Account__c = cuentaPersonal.Id;
        vcRecord2.VendorType = 'ContactCenter';
        vcRecord2.CallCenterId = ccRecord.Id;
        
        vcList.add(vcRecord2);

        VoiceCall vcRecord3 = new VoiceCall();
        vcRecord3.CallStartDateTime = DateTime.now();
        vcRecord3.CallEndDateTime = DateTime.now();
        vcRecord3.FromPhoneNumber = '+34666666777';
        vcRecord3.ToPhoneNumber = '+34999999777';
        vcRecord3.CallType = OM_Constants.CALL_TYPE.get('INBOUND');
        vcRecord3.RelatedRecordId = cuentaPersonal.Id;
        vcRecord3.CallAcceptDateTime = null;
        vcRecord3.OM_Account__c = cuentaPersonal.Id;
        vcRecord3.VendorType = 'ContactCenter';
        vcRecord3.CallCenterId = ccRecord.Id;
        
        vcList.add(vcRecord3);

        VoiceCall vcRecord4 = new VoiceCall();
        vcRecord4.CallStartDateTime = DateTime.now();
        vcRecord4.CallEndDateTime = DateTime.now();
        vcRecord4.FromPhoneNumber = '+34666666888';
        vcRecord4.ToPhoneNumber = '+34999999888';
        vcRecord4.CallType = OM_Constants.CALL_TYPE.get('INBOUND');
        vcRecord4.RelatedRecordId = cuentaPersonal.Id;
        vcRecord4.CallAcceptDateTime = null;
        vcRecord4.QueueName =  'Queue4';
        vcRecord4.OM_OriginQueue__c = String.isNotBlank(queueName) ? queueName : '';
        vcRecord4.OM_Account__c = cuentaPersonal.Id;
        vcRecord4.VendorType = 'ContactCenter';
        vcRecord4.CallCenterId = ccRecord.Id;
        
        vcList.add(vcRecord4);

        VoiceCall vcRecord5 = new VoiceCall();
        vcRecord5.CallStartDateTime = DateTime.now();
        vcRecord5.CallEndDateTime = DateTime.now();
        vcRecord5.FromPhoneNumber = '+34666666888';
        vcRecord5.ToPhoneNumber = '+34999999888';
        vcRecord5.CallType = OM_Constants.CALL_TYPE.get('INBOUND');
        vcRecord5.RelatedRecordId = cuentaPersonal.Id;
        vcRecord5.CallAcceptDateTime = null;
        vcRecord5.QueueName =  'QueueOffice';
        vcRecord5.OM_Account__c = cuentaPersonal.Id;
        vcRecord5.VendorType = 'ContactCenter';
        vcRecord5.CallCenterId = ccRecord.Id;
        
        vcList.add(vcRecord5);

        System.runAs(uTest) {
            insert vcList;
        }
        
    }

    @isTest 
    static void callbackOutOfTime(){
        VoiceCall vc = [SELECT Id, OM_Account__c FROM VoiceCall WHERE QueueName !=: TEST_NAME AND QueueName !=: NULL LIMIT 1];

        Test.startTest();
        vc.OM_GDPR__c = OM_Constants.CONST_YES;
        vc.OM_OutOfTime__c = OM_Constants.CONST_YES;
        update vc;
        Test.stopTest();

        OM_Callback__c cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.areEqual(OM_Constants.CALL_STATUS.get('PENDING'), cbRecord.OM_Status__c, 'Expected Pending Status');
        Assert.areEqual(vc.OM_Account__c, cbRecord.OM_Account__c, 'Expected Client Id');
        Assert.areEqual(OM_Constants.OUTBOUND_TYPE.get('OUTOFTIME'), cbRecord.OM_Type__c, 'Expected Out Of Time Type');
        
    }

    @isTest 
    static void callbackAbandonedCall(){
        VoiceCall vc = [SELECT Id, OM_Account__c FROM VoiceCall WHERE QueueName = NULL LIMIT 1];

        Test.startTest();
        vc.OM_GDPR__c = OM_Constants.CONST_YES;
        update vc;
        Test.stopTest();
        OM_Callback__c cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.areEqual(OM_Constants.CALL_STATUS.get('PENDING'), cbRecord.OM_Status__c, 'Expected Pending Status');
        Assert.areEqual(vc.OM_Account__c, cbRecord.OM_Account__c, 'Expected Client Id');
        Assert.areEqual(OM_Constants.OUTBOUND_TYPE.get('ABANDONED'), cbRecord.OM_Type__c, 'Expected Out Of Time Type');
    }

    @isTest 
    static void callbackClientCall(){
        VoiceCall vc = [SELECT Id, OM_Account__c FROM VoiceCall WHERE QueueName !=: TEST_NAME AND QueueName !=: NULL LIMIT 1];

        Test.startTest();
        vc.OM_GDPR__c = OM_Constants.CONST_YES;
        vc.OM_GenerateCB__c = OM_Constants.CONST_YES;
        update vc;
        Test.stopTest();
        OM_Callback__c cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.areEqual(OM_Constants.CALL_STATUS.get('PENDING'), cbRecord.OM_Status__c, 'Expected Pending Status');
        Assert.areEqual(vc.OM_Account__c, cbRecord.OM_Account__c, 'Expected Client Id');
        Assert.areEqual(OM_Constants.OUTBOUND_TYPE.get('ABANDONED'), cbRecord.OM_Type__c, 'Expected Out Of Time Type');
    }

    @isTest 
    static void callbackNoGDPR(){
        VoiceCall vc = [SELECT Id, OM_Account__c FROM VoiceCall WHERE QueueName = NULL LIMIT 1];

        Test.startTest();
        vc.OM_GDPR__c = OM_Constants.CONST_NO;
        update vc;
        Test.stopTest();

        List<OM_Callback__c> cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.isTrue(cbRecord.isEmpty(), 'No callback generated');
    }

    @isTest 
    static void noCallbackQueue(){
        VoiceCall vc = [SELECT Id, OM_Account__c FROM VoiceCall WHERE QueueName =: TEST_NAME LIMIT 1];

        Test.startTest();
        //vc.OM_GDPR__c = OM_Constants.CONST_YES;
        //vc.OM_OutOfTime__c = OM_Constants.CONST_YES;
        update vc;
        Test.stopTest(); 

        List<OM_Callback__c> cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.isTrue(cbRecord.isEmpty(), 'No callback generated');
    }

    @isTest 
    static void callbackOverflow(){
        VoiceCall vc = [SELECT Id, OM_Account__c, OM_OriginQueue__c FROM VoiceCall WHERE QueueName = 'Queue4' LIMIT 1];

        Test.startTest();
        vc.OM_GDPR__c = OM_Constants.CONST_YES;
        vc.OM_GenerateCB__c = OM_Constants.CONST_YES;
        update vc;
        Test.stopTest();
        OM_Callback__c cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c, OM_OriginQueue__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.areEqual(OM_Constants.CALL_STATUS.get('PENDING'), cbRecord.OM_Status__c, 'Expected Pending Status');
        Assert.areEqual(vc.OM_Account__c, cbRecord.OM_Account__c, 'Expected Client Id');
        Assert.areEqual(OM_Constants.OUTBOUND_TYPE.get('ABANDONED'), cbRecord.OM_Type__c, 'Expected Out Of Time Type');
        Assert.areEqual(vc.OM_OriginQueue__c, cbRecord.OM_OriginQueue__c);
    }

    //OFFICE CALLBACK
    @isTest 
    static void callbackOffice(){
        VoiceCall vc = [SELECT Id, OM_Account__c, OM_OriginQueue__c FROM VoiceCall WHERE QueueName = 'QueueOffice' LIMIT 1];

        Test.startTest();
        vc.OM_GDPR__c = OM_Constants.CONST_YES;
        vc.OM_GenerateCB__c = OM_Constants.CONST_YES;
        vc.OM_OfficeQueue__c = 'SCV_ASESOR_OFI_PLENI';
        vc.OM_OriginQueue__c = 'SCV_ASESOR_OFI_PLENI';
        update vc;
        Test.stopTest();
        OM_Callback__c cbRecord = [SELECT Id, OM_Status__c, OM_Account__c, OM_Type__c, OM_OriginQueue__c FROM OM_Callback__c WHERE Recordtype.DeveloperName = 'OM_Callback' LIMIT 1];
        Assert.areEqual(OM_Constants.CALL_STATUS.get('PENDING'), cbRecord.OM_Status__c, 'Expected Pending Status');
        Assert.areEqual(vc.OM_Account__c, cbRecord.OM_Account__c, 'Expected Client Id');
        Assert.areEqual(OM_Constants.OUTBOUND_TYPE.get('ABANDONED'), cbRecord.OM_Type__c, 'Expected Out Of Time Type');
        Assert.areEqual(vc.OM_OriginQueue__c, cbRecord.OM_OriginQueue__c);
    }
}