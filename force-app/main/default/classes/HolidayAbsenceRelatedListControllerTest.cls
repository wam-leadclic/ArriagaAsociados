@isTest
private class HolidayAbsenceRelatedListControllerTest {

    @isTest static void testGetHolidayAbsenceByCalendarId() {
        CalendarSetting__c calSetting = SchDataTest.createCalendarSetting('User');
        insert calSetting;

        HolidayAbsence__c holidayAbsence = SchDataTest.createHolidayAbsence(calSetting.CalendarId__c);
        insert holidayAbsence;

        Test.startTest();
        HolidayAbsenceRelatedListController.getHolidayAbsenceByCalendarId(calSetting.Id);
        Test.stopTest();
    }

    @isTest static void testCatch () {
        Test.startTest();
        HolidayAbsenceRelatedListController.getHolidayAbsenceByCalendarId(null);
        Test.stopTest();
    }
}