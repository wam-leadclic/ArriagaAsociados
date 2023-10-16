/** 
 * CalendarTimetable handle trigger
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-10-08
 */
public class TriggerCalendarTimeTableHandler {
   
    public static void beforeInsert (List<CalendarTimetable__c> lNewCalendarTimetable) {
        checkEffectiveDatesOverlapping(lNewCalendarTimetable, null);                                  
    }

    public static void beforeUpdate (List<CalendarTimetable__c> lNewCalendartimetable, Map<Id, CalendarTimetable__c> mOldCalendarTimetable) {
        checkEffectiveDatesOverlapping(lNewCalendarTimetable, mOldCalendarTimetable);
    }


    private static void checkEffectiveDatesOverlapping (List<CalendarTimetable__c> lNewCalendartimetable, Map<Id, CalendarTimetable__c> mOldCalendarTimetable) {

        Map<Id, List<CalendarTimeTable__c>> mCalendarSetting_lCalendarTT = new Map<Id, List<CalendarTimeTable__c>>(); // Key: CalendarSetting Id, Value: List of CalendarTimetable 
        for (CalendarTimetable__c calendarTT : lNewCalendarTimetable){        
            // If it's an update and Effective Dates changes, or it's an insert
            if ( (mOldCalendarTimetable != null 
                && (mOldCalendarTimetable.get(calendarTT.Id).EffectiveFrom__c != calendarTT.EffectiveFrom__c || mOldCalendarTimetable.get(calendarTT.Id).EffectiveTo__c != calendarTT.EffectiveTo__c) )
                || mOldCalendarTimetable == null){

                List<CalendarTimetable__c> lCalendarTTMap = new List<CalendarTimetable__c>();
                if (mCalendarSetting_lCalendarTT.containsKey(calendarTT.CalendarSetting__c)){
                    lCalendarTTMap = mCalendarSetting_lCalendarTT.get(calendarTT.CalendarSetting__c);
                }
                lCalendarTTMap.add(calendarTT);

                mCalendarSetting_lCalendarTT.put(calendarTT.CalendarSetting__c, lCalendarTTMap);
            }
        }

        Set<Id> sCurrentId = mOldCalendarTimetable != null ? mOldCalendarTimetable.keySet() : new Set<Id>();
        
        List<CalendarTimeTable__c> lCalendarTT = [SELECT Id, CalendarSetting__c, EffectiveFrom__c, EffectiveTo__c 
                                                    FROM CalendarTimeTable__c 
                                                    WHERE CalendarSetting__c IN :mCalendarSetting_lCalendarTT.keySet() AND Id NOT IN :sCurrentId];

        for (CalendarTimetable__c calendarTT : lCalendarTT){
            if (mCalendarSetting_lCalendarTT.containsKey(calendarTT.CalendarSetting__c)){
                for (CalendarTimetable__c calendarTTFromTrigger: mCalendarSetting_lCalendarTT.get(calendarTT.CalendarSetting__c)){
                    if ((calendarTTFromTrigger.EffectiveFrom__c <= calendarTT.EffectiveFrom__c && calendarTTFromTrigger.EffectiveTo__c >= calendarTT.EffectiveFrom__c)  
                        || (calendarTTFromTrigger.EffectiveFrom__c >= calendarTT.EffectiveFrom__c && calendarTTFromTrigger.EffectiveFrom__c <= calendarTT.EffectiveTo__c)){
                        
                        calendarTTFromTrigger.addError(Label.overlappingCalendarTimetableDates);
                    }
                }
            }
        }       

    }


}