/** 
 * Test class of CalendarTimetable handler trigger
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-10-08
 */
@isTest
private class TriggerCalendarTimetableTest {

    @TestSetup
    static void setup(){
        SearchSetup__c cs = new SearchSetup__c();
        cs.EffectiveDatesOverlappingControl__c = true;
        insert cs;
    }

    @isTest
    private static void testTriggerCalendartimetable(){      

        CalendarSetting__c calSet = SchDataTest.createCalendarSetting('User');
        insert calSet;

        Timetable__c timetable = SchDataTest.createTimetable();
        insert timetable;    

        List<CalendarTimetable__c> lInsertCalTT = new List<CalendarTimetable__c>();

        CalendarTimetable__c calTT1 = SchDataTest.createCalendarTimetable(calSet.Id, timetable.Id, System.now().addDays(-30), System.now().addDays(30));
        lInsertCalTT.add(calTT1);

        CalendarTimetable__c calTT2 = SchDataTest.createCalendarTimetable(calSet.Id, timetable.Id, System.now().addDays(45), System.now().addDays(50));
        lInsertCalTT.add(calTT2);

        insert lInsertCalTT;

        Test.startTest();

        // Overlapping insert
        CalendarTimetable__c calTT3 = SchDataTest.createCalendarTimetable(calSet.Id, timetable.Id, System.now().addDays(-15), System.now().addDays(25));
        try{
            insert calTT3;
        }catch(Exception e){      
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.overlappingCalendarTimetableDates);
            System.AssertEquals(expectedExceptionThrown, true);
        }

        // Overlapping update
        calTT2.EffectiveFrom__c = System.now().addDays(-15);
        calTT2.EffectiveTo__c = System.now().addDays(25);
        try{
            update calTT2;
        }catch(Exception e){      
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.overlappingCalendarTimetableDates);
            System.AssertEquals(expectedExceptionThrown, true);
        }

        Test.stopTest();
    }
}