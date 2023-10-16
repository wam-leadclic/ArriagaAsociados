/** 
 * Clic2Meet data factory to Test classes
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-09-17
 */
public class SchDataTest {

    public static List<String> getSubtypesFromType (String resourcetype) {
        // Get subtypes from Schema
		Schema.DescribeFieldResult fieldSubtype = CalendarSetting__c.Subtype__c.getDescribe();
		List<Schema.PicklistEntry> lFieldSubtype = fieldSubtype.getPicklistValues();


/*
        for (Integer i=0; i<lFieldSubtype.size() && subtypeLabel =='' && subtypeValue==''; i++){
            System.debug('<<getSubtypesFromType FOR VALUE>>  '+lFieldSubtype[i].getValue() );
            System.debug('<<getSubtypesFromType FOR LABEL>>  '+lFieldSubtype[i].getLabel() );
            if (lFieldSubtype[i].getValue().containsIgnoreCase(resourcetype)){
                subtypeLabel = lFieldSubtype[i].getLabel(); 
                subtypeValue = lFieldSubtype[i].getValue();
            }
        }
		*/
        List<String> lSubtype = new List<String>();
        
        if (resourcetype == 'Resource'){
            
            String subtypeLabel = 'Sala';
        	String subtypeValue = 'Sala';
            
            lSubtype.add(subtypeLabel);
        	lSubtype.add(subtypeValue);
        }
        
        if (resourcetype == 'User'){
            
            String subtypeLabel = 'Administrativo';
        	String subtypeValue = 'Administrativo';
            
            lSubtype.add(subtypeLabel);
        	lSubtype.add(subtypeValue);
        }
        
        
        
        //List<String> lSubtype = new List<String>();
        //lSubtype.add(subtypeLabel);
        //lSubtype.add(subtypeValue);

        return lSubtype;
    }

    /*public static List<String> getLastSubtypesFromType (String resourcetype) {
        // Get subtypes from Schema
		Schema.DescribeFieldResult fieldSubtype = CalendarSetting__c.Subtype__c.getDescribe();
		List<Schema.PicklistEntry> lFieldSubtype = fieldSubtype.getPicklistValues();

        String subtypeLabel = '';
        String subtypeValue = '';

        for (Integer i=0; i<lFieldSubtype.size(); i++){
            if (lFieldSubtype[i].getValue().containsIgnoreCase(resourcetype)){
                subtypeLabel = lFieldSubtype[i].getLabel(); 
                subtypeValue = lFieldSubtype[i].getValue();
            }
        }

        List<String> lSubtype = new List<String>();
        lSubtype.add(subtypeLabel);
        lSubtype.add(subtypeValue);

        return lSubtype;
    }*/

    public static CalendarSetting__c createCalendarSetting (String resourcetype) {

        List<String> lSubtype = getSubtypesFromType(resourcetype);
        String subtypeValue = lSubtype.size() >= 1 ? lSubtype[1] : '';

        // DML operation Insert not allowed on Calendar, so we have to query it
        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];
        CalendarSetting__c cSet = new CalendarSetting__c(CalendarId__c = cal.Id, Subtype__c = subtypeValue, Type__c = resourcetype);

        return cSet;
    }

    /*public static CalendarSetting__c createCalendarSettingDiffSubtype (String resourcetype) {

        List<String> lSubtype = getLastSubtypesFromType(resourcetype);
        String subtypeValue = lSubtype.size() >= 1 ? lSubtype[1] : '';

        // DML operation Insert not allowed on Calendar, so we have to query it
        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];
        CalendarSetting__c cSet = new CalendarSetting__c(CalendarId__c = cal.Id, Subtype__c = subtypeValue, Type__c = resourcetype);

        return cSet;
    }*/

    public static Lead createLead () {
        Lead l = new Lead(LastName = 'testLNLead', FirstName = 'test', Company='Test company', PostalCode='12345', Email = 'test@test.com', Phone= '666666666');
        return l;
    }

    public static Event createEvent (Id leadId, Datetime startEvent, Datetime endEvent) {
        Event evt = new Event();
        evt.WhoId = leadId;
        evt.Subject = 'Test Subject';
        evt.StartDateTime = startEvent;
        evt.EndDateTime = endEvent;

        return evt;
    }

    public static Timetable__c createTimetable () {

        Timetable__c tt = new Timetable__c();

        tt.MondayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.MondayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.MondayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.MondayAfterTo__c = Time.newInstance(19, 00, 0, 0);
        
        tt.TuesdayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.TuesdayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.TuesdayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.TuesdayAfterTo__c = Time.newInstance(19, 00, 0, 0);
        
        tt.WednesdayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.WednesdayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.WednesdayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.WednesdayAfterTo__c = Time.newInstance(19, 00, 0, 0);
        
        tt.ThursdayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.ThursdayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.ThursdayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.ThursdayAfterTo__c = Time.newInstance(19, 00, 0, 0);
        
        tt.FridayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.FridayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.FridayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.FridayAfterTo__c = Time.newInstance(19, 00, 0, 0);

        tt.SaturdayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.SaturdayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.SaturdayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.SaturdayAfterTo__c = Time.newInstance(19, 00, 0, 0);

        tt.SundayMorningFrom__c = Time.newInstance(9, 30, 0, 0);
        tt.SundayMorningTo__c = Time.newInstance(14, 30, 0, 0);
        tt.SundayAfterFrom__c = Time.newInstance(15, 30, 0, 0);
        tt.SundayAfterTo__c = Time.newInstance(19, 00, 0, 0);

        return tt;  
    }

    public static CalendarTimetable__c createCalendarTimetable (Id calendarSettingId, Id timetableId) {

        CalendarTimetable__c calTt = new CalendarTimetable__c();
        calTt.EffectiveFrom__c = System.now().addDays(-30);
        calTt.EffectiveTo__c = System.now().addDays(30);
        calTt.CalendarSetting__c = calendarSettingId;
        calTt.Timetable__c = timetableId;

        return calTt;
    }

    public static CalendarTimetable__c createCalendarTimetable (Id calendarSettingId, Id timetableId, Datetime effectiveFrom, Datetime effectiveTo) {

        CalendarTimetable__c calTt = new CalendarTimetable__c();
        calTt.EffectiveFrom__c = effectiveFrom;
        calTt.EffectiveTo__c = effectiveTo;
        calTt.CalendarSetting__c = calendarSettingId;
        calTt.Timetable__c = timetableId;

        return calTt;
    }

    public static HolidayCalendar__c createHolidayCalendar () {

        HolidayZone__c zone = new HolidayZone__c(Name = 'Test holiday');
        insert zone;

        Day__c holiday = new Day__c (Holiday__c = System.today().addDays(1), HolidayZone__c = zone.Id);
        insert holiday;

        HolidayCalendar__c holidayCalendar = new HolidayCalendar__c(Name = 'Test Holiday calendar');
        insert holidaycalendar;

        HolidayCalendarZone__c calendarZone = new HolidayCalendarZone__c(HolidayCalendar__c = holidayCalendar.Id, HolidayZone__c = zone.Id);
        insert calendarZone;

        return holidaycalendar;
    }

    public static HolidayAbsence__c createHolidayAbsence (Id calendarId) {
        HolidayAbsence__c holidayAbsence = new HolidayAbsence__c( CalendarId__c = calendarId,
                                                                StartDate__c = system.now().addDays(-2), 
                                                                EndDate__c = system.now().addDays(-1), 
                                                                Comments__c = 'Test comments');

        return holidayAbsence;                                                           
    }


}