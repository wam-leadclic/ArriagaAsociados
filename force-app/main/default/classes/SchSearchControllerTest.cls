@isTest
private class SchSearchControllerTest {
    @testSetup static void setup() {
        
        Account acc = new Account (Name = 'Test Cuenta', ShippingState = 'Madrid', Phone = '123456799');
        insert acc;
        
        String RecTypeId = [SELECT Id FROM RecordType WHERE (Name = 'Cuenta Personal') ].Id;
        Account pAcc = new Account(FirstName = 'Test Cuenta', LastName = 'Personal', ShippingState = 'Madrid', Phone = '023456769', RecordTypeID = RecTypeId, PersonEmail = 'testemailadress2@gmail.com');
        insert pAcc;

        // Create Calendar Holidays
        HolidayCalendar__c holidayCalendar = SchDataTest.createHolidayCalendar();

        // Create Calendar Setting
        List<CalendarSetting__c> lCSetToInsert = new List<CalendarSetting__c>();
        CalendarSetting__c cSetUser = SchDataTest.createCalendarSetting('User');
        cSetUser.HolidayCalendar__c = holidayCalendar.Id;
        lCSetToInsert.add(cSetUser);

        /*CalendarSetting__c cSetUser2 = SchDataTest.createCalendarSettingDiffSubtype('User');
        lCSetToInsert.add(cSetUser2);*/

        CalendarSetting__c cSetResource = SchDataTest.createCalendarSetting('Resource');
        cSetResource.HolidayCalendar__c = holidayCalendar.Id;
        lCSetToInsert.add(cSetResource);
        insert lCSetToInsert;

        // Create Time Table
        TimeTable__c tt = SchDataTest.createTimeTable();
        insert tt;

        // Create JO Calendar Time Table
        List<CalendarTimetable__c> lCTtToInsert = new List<CalendarTimetable__c>();
        CalendarTimetable__c calTtUser = SchDataTest.createCalendarTimetable(cSetUser.Id, tt.Id);
        lCTtToInsert.add(calTtUser);
        CalendarTimetable__c calTtResource = SchDataTest.createCalendarTimetable(cSetResource.Id, tt.Id);
        lCTtToInsert.add(calTtResource);      

        insert lCTtToInsert;

        

        // Create Lead
        Lead l = SchDataTest.createLead();
        insert l;

        // Create events
        List<Event> lEventToInsert = new List<Event>();
        Date todayDate = Date.today();
        Date todayEvent = Date.newInstance(todayDate.year(),todayDate.month(),todayDate.day());
        Event evt1 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent, Time.newInstance(9, 30, 0, 0)), 
                                                DateTime.newInstance(todayEvent, Time.newInstance(10, 00, 0, 0)));
        lEventToInsert.add(evt1);

        Event evt2 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent, Time.newInstance(14, 00, 0, 0)), 
                                                DateTime.newInstance(todayEvent, Time.newInstance(14, 30, 0, 0)));
        lEventToInsert.add(evt2);

        Event evt3 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent, Time.newInstance(11, 30, 0, 0)), 
                                                DateTime.newInstance(todayEvent, Time.newInstance(12, 00, 0, 0)));
        lEventToInsert.add(evt3);

        Event evt4 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent.addDays(1), Time.newInstance(18, 00, 0, 0)), 
                                                DateTime.newInstance(todayEvent.addDays(1), Time.newInstance(20, 00, 0, 0)));
        lEventToInsert.add(evt4);

         Event evt5 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent.addDays(1), Time.newInstance(07, 00, 0, 0)), 
                                                DateTime.newInstance(todayEvent.addDays(1), Time.newInstance(10, 00, 0, 0)));
        lEventToInsert.add(evt5);

        Event evt6 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent.addDays(2), Time.newInstance(9, 30, 0, 0)), 
                                                DateTime.newInstance(todayEvent.addDays(3), Time.newInstance(12, 00, 0, 0)));
        lEventToInsert.add(evt6);

        Event evt7 = SchDataTest.createEvent(   l.Id, 
                                                DateTime.newInstance(todayEvent.addDays(-1), Time.newInstance(9, 30, 0, 0)), 
                                                null);

        evt7.IsAllDayEvent = true;                                        
        lEventToInsert.add(evt7);

        insert lEventToInsert;

        // Create holidays
        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];
        SchDataTest.createHolidayAbsence(cal.Id);

    }

    @isTest static void testGetAvailability() {

        Lead attendee = [SELECT Id FROM Lead LIMIT 1];

        List<String> lSubtypeUser = SchDataTest.getSubtypesFromType('User');
        //List<String> lSubtypeUser2 = SchDataTest.getLastSubtypesFromType('User');
        List<String> lSubtypeResource = SchDataTest.getSubtypesFromType('Resource');

        String subtypeUser = lSubtypeUser.size() >= 1 ? lSubtypeUser[1] : '';
        //String subtypeUser2 = lSubtypeUser2.size() >= 1 ? lSubtypeUser2[1] : '';
        String subtypeResource = lSubtypeResource.size() >= 1 ? lSubtypeResource[1] : '';

        SchSearchController.GetAvailabilityRequest gar = new SchSearchController.GetAvailabilityRequest();
        gar.attendeeId = attendee.Id;
        gar.searchFromDate = System.today().addDays(-3);
        gar.searchToDate = System.today().addDays(4);
        gar.startHour = DateTime.newInstance(System.today().addDays(-3) ,Time.newInstance(8, 0, 0, 0));
        gar.endHour = DateTime.newInstance(System.today().addDays(3), Time.newInstance(20, 0, 0, 0));
        gar.duration = '00:30:00';
        gar.userSelected = new List<String>{subtypeUser/*,subtypeUser2*/};
        gar.resourceSelected = new List<String>{subtypeResource};
        gar.searchByEvents = false;     

        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];
        Map<String, Object> mFilterValues = new Map<String, Object>();
        mFilterValues.put('CalendarId__c', cal.Id);
        gar.filterValues = mFilterValues;

        SchSearchController.Interval intervUser = new SchSearchController.Interval(Time.newInstance(10, 0, 0, 0),Time.newInstance(14, 0, 0, 0),'User');
        List<SchSearchController.Interval> lIntervalUser = new List<SchSearchController.Interval>{intervUser};

        SchSearchController.Interval intervResource = new SchSearchController.Interval(Time.newInstance(8, 0, 0, 0),Time.newInstance(16, 0, 0, 0),'Resource');
        List<SchSearchController.Interval> lIntervalResource = new List<SchSearchController.Interval>{intervResource};

        Test.startTest();
        SchSearchController.getAvailability(gar);
        SchSearchController.intersectIntervals(lIntervalResource, lIntervalUser, new Map<String, Set<String>>(), gar);

        
        Test.stopTest();
    }

    @isTest static void testGetAvailabilityByEvents() {
        
        Lead attendee = [SELECT Id FROM Lead LIMIT 1];

        SchSearchController.GetAvailabilityRequest gar = new SchSearchController.GetAvailabilityRequest();
        gar.attendeeId = attendee.Id;
        gar.searchFromDate = System.today().addDays(-3);
        gar.searchToDate = System.today().addDays(4);
        gar.startHour = DateTime.newInstance(System.today().addDays(-3) ,Time.newInstance(8, 0, 0, 0));
        gar.endHour = DateTime.newInstance(System.today().addDays(3), Time.newInstance(20, 0, 0, 0));
        gar.searchByEvents = true;

        Map<String, Object> mFilterValues = new Map<String, Object>();
        mFilterValues.put('Subject', 'Test Subject');
        gar.filterValues = mFilterValues;

        Test.startTest();
        SchSearchController.getAvailability(gar);
        Test.stopTest();
    }

    @isTest static void testCreateEvent () {

        Lead attendee = [SELECT Id FROM Lead LIMIT 1];

        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];
        Map<Object, Object> mAssignedTo = new Map<Object, Object>();
        mAssignedTo.put(UserInfo.getUserId(), cal.Id);

        Map<Object, Object> mResource = new Map<Object, Object>();
        //Map<Object, Object> filterValues = new Map<Object, Object>();
        Map<Object, Object> extraParams = new Map<Object, Object>();

        Test.startTest();
        SchSearchController.CreateEventResponse cer = SchSearchController.createEvent(
            system.now(),
            system.now().addMinutes(30),
            attendee.Id,
            mAssignedTo,
            mResource,
            null,
            extraParams,
            'Test comments',
            'Informativa'
            );
        Test.stopTest();
    }

    @isTest static void testUpdateEvent() {

        Lead attendee = [SELECT Id FROM Lead LIMIT 1];
        
        Account acc = [SELECT Id FROM Account WHERE IsPersonAccount = true];

        Event evt = [SELECT Id FROM Event LIMIT 1];

        Map<Object, Object> extraParams = new Map<Object, Object>();

        Test.startTest();
        SchSearchController.CreateEventResponse cer0 = SchSearchController.updateEvent(evt.Id, attendee.Id, extraParams, 'new Comments');
        SchSearchController.CreateEventResponse cer1 = SchSearchController.updateEvent(evt.Id, acc.Id, extraParams, 'new Comments');
        Test.stopTest();
    }

    @isTest static void testGetParamsFromExtendedFeatures() {

        Lead attendee = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        SchSearchController.ResultGetParams rgp = SchSearchController.getParamsFromExtendedFeatures(attendee.Id);
        Test.stopTest();

    }
    
}