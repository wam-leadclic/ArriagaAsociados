public with sharing class HolidayAbsenceRelatedListController {
    
    @AuraEnabled
    public static GetHolidayAbsenceResponse getHolidayAbsenceByCalendarId(Id calendarSettingId){
        system.debug('calendarSettingId: '+calendarSettingId);
        GetHolidayAbsenceResponse resp = new GetHolidayAbsenceResponse();

        List<HolidayAbsence__c> lHolidayAbsence = new List<HolidayAbsence__c>();
        Id calendarId = null;
        String calendarSettingType = '';
        Boolean canCreateRecords = false;
        try{

            CalendarSetting__c calendarSetting = [SELECT Id, CalendarId__c, Type__c FROM CalendarSetting__c WHERE Id = :calendarSettingId limit 1];
            calendarId = calendarSetting.CalendarId__c;
            calendarSettingType = calendarSetting.Type__c;

            lHolidayAbsence = [SELECT Id, Name, CalendarId__c, StartDate__c, EndDate__c, Comments__c, Reason__c FROM HolidayAbsence__c WHERE CalendarId__c = :calendarSetting.CalendarId__c];

            canCreateRecords = Schema.SObjectType.HolidayAbsence__c.isCreateable();
            
        }catch(Exception e){
            resp.status = false;
            resp.errorMsg = e.getMessage();
        }

        resp.lHolidayAbsence = lHolidayAbsence;
        resp.calendarId = calendarId;
        resp.calendarSettingType = calendarSettingType;
        resp.canCreateRecords = canCreateRecords;
        return resp;
    }

    public class GetHolidayAbsenceResponse {
        @auraEnabled public Boolean status;
        @auraEnabled public String errorMsg;
        @auraEnabled public List<HolidayAbsence__c> lHolidayAbsence;
        @auraEnabled public Id calendarId;
        @auraEnabled public String calendarSettingType;
        @auraEnabled public Boolean canCreateRecords;

        public GetHolidayAbsenceResponse() {
            status = true;
            errorMsg = '';
            lHolidayAbsence = new List<HolidayAbsence__c>();
            canCreateRecords = false;
        }
    }
}