@isTest
private class SchExtendedFeaturesImplementationTest {
    @testSetup static void setup() {

        Lead l = new Lead(LastName = 'testLNLead', FirstName = 'test', Company='Test company', PostalCode='12345', Email = 'test@test.com');
        insert l;

        Product2 prod = new Product2(Name = 'TestProduct', DuracionEntrevista__c = 15, IsActive = true);
        insert prod;

        LeadProduct__c lp = new LeadProduct__c(Candidato__c = l.Id, Producto__c = prod.Id);
        insert lp;


        Id oficinaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Oficina').getRecordTypeId();
        Account oficina = new Account(Name = 'Test Oficina', ShippingState = 'Madrid', RecordTypeId = oficinaRecordTypeId, Phone = '6000000000');
        insert oficina;   

        // Calendar Setting
        // DML operation Insert not allowed on Calendar, so we have to query it
        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];

        Schema.DescribeFieldResult fieldSubtype = CalendarSetting__c.Subtype__c.getDescribe();
		List<Schema.PicklistEntry> lFieldSubtype = fieldSubtype.getPicklistValues();
        String subtype = (lFieldSubtype != null && !lFieldSubtype.isEmpty()) ? lFieldSubtype[0].getValue() : ''; 
        
        CalendarSetting__c cSet = new CalendarSetting__c(CalendarId__c = cal.Id, Subtype__c = subtype, Type__c = 'User', Provincia__c = 'Madrid', Oficina__c = oficina.Id);
        insert cSet;


        // Custom settings
        PerfilesCallCenter__c pcc = new PerfilesCallCenter__c(Name='ProfileUserId',Id__c = UserInfo.getProfileId());
        insert pcC;
    }

    @isTest static void testSetInitParams() {

        Id lId = [SELECT Id FROM Lead LIMIT 1].Id;

        test.startTest();
        SchExtendedFeaturesImplementation.setInitParams(lId);
        test.stopTest();
    }

    @isTest static void testSetInitFilterParams() {
        
        Account oficina = [SELECT Id FROM Account LIMIT 1];

        test.startTest();
        SchExtendedFeaturesImplementation scsEfi = new SchExtendedFeaturesImplementation();

        // Itinerantes use case
        Map<Object, Object> mParams;
        scsEfi.setInitFilterParams(mParams);

        // standard init searching current calendar setting 
        mParams = new Map<Object, Object>();
        mParams.put('Oficina__c', oficina.Id);
        scsEfi.setInitFilterParams(mParams);
        test.stopTest();
    }

    @isTest static void testSetEventParams() {

        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];

        Map<Object, Object> mAssignedTo = new Map<Object, Object>();
        mAssignedTo.put('Asesor', cal.Id);

        Account oficina = [SELECT Id FROM Account LIMIT 1];
        Map<Object, Object> mFilterValues = new Map<Object, Object>();
        mFilterValues.put('Oficina__c', oficina.Id);

        Map<Object, Object> mResource = new Map<Object, Object>();

        Map<Object, Object> mExtraParams = new Map<Object, Object>();
        mExtraParams.put('products', new List<Object>());

        Map<Object, Object> mParams = new Map<Object, Object>();
        mParams.put('assignedTo', mAssignedTo);
        mParams.put('filterValues', mFilterValues);
        mParams.put('lResource', mResource);
        mParams.put('extraParams', mExtraParams);

        Map<Id, Id> mCalendarUser = new Map<Id, Id>();   
        mCalendarUser.put(cal.Id, UserInfo.getUserId());
        

        test.startTest();
        // Asesor
        SchExtendedFeaturesImplementation scsEfi = new SchExtendedFeaturesImplementation();
        scsEfi.setEventParams(new Event(durationInMinutes=15, ActivityDateTime=system.now()), mParams, mCalendarUser);

        // Administrativo
        mAssignedTo.remove('Asesor');
        mAssignedTo.put('Administrativo', cal.Id);
        mParams.put('assignedTo', mAssignedTo);
        scsEfi.setEventParams(new Event(durationInMinutes=15, ActivityDateTime=system.now()), mParams, mCalendarUser);
        test.stopTest();
    }
}