public with sharing class CalendarWrapperController {
    
    @AuraEnabled(cacheable=true)
    public static TimeZoneWrapper getUserTimezone() {
        TimeZone tz = UserInfo.getTimeZone();
        TimeZoneWrapper userTz = new TimeZoneWrapper();

        userTz.userTimeZone = tz.getID();
        userTz.timeZoneOffset = String.valueOf(tz.getOffset(Datetime.now()));

        return userTz;
    }

    public class TimeZoneWrapper {
        @AuraEnabled
        public String userTimeZone;

        @AuraEnabled
        public String timeZoneOffset;
    }
}