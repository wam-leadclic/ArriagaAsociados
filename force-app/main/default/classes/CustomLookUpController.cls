/**
@author Leadclic Solutions S.L.
@date 24/04/2019
@description Controller class from the CustomLookup Component.
FECHA                 AUTOR                    ACCION
24/04/2019            JZD                      Created
*/
public class CustomLookUpController { 

    /**
        @description    Find a calendar searching by the related user or resource
        @param          searchKeyWord String to find
        @result         Wrapper class wtiht the result and the calendar list
    */
    @AuraEnabled
    public static ResultWrapperFindCalendar findCalendar(String searchKeyWord) {
        String key = '%' + searchKeyWord + '%';

        try{
            // Buscar calendarios por el Id de usuario que coincida por nombre o email introducido en la barra de búsqueda, o con el nombre del recurso público 

            Map<Id,User> mUser = new Map<Id, User> ([SELECT Id, Name FROM User WHERE Name LIKE :key OR Email LIKE :key]);

            List<Calendar> lCalendar = [SELECT Id, Name, Type, UserId FROM Calendar WHERE (Type = 'User' AND UserId IN :mUser.keySet()) OR (Type = 'Resource' AND Name LIKE :key)];

            // Create calendar wrapper list
            List<CalendarWrapper> lCalendarW = new List<CalendarWrapper>();
            for (Calendar cal : lCalendar){
                String calendarName = cal.Type == 'User' ? mUser.get(cal.UserId).Name : cal.Name;
                CalendarWrapper calW = new CalendarWrapper (cal.Id, calendarName, cal.Type);
                lCalendarW.add(calW);
            }
            system.debug('calendarW List: '+lCalendarW);
            return new  ResultWrapperFindCalendar(true, '', lCalendarW);                           
        }catch(Exception e){
            return new  ResultWrapperFindCalendar(false, e.getMessage(), new list<CalendarWrapper>());
        }
    }

    /**
        @description Wrapper class to return the results to the component
    */
    
    public class ResultWrapperFindCalendar {
        @AuraEnabled public Boolean status;
        @AuraEnabled public String errorMsg;
        /*@AuraEnabled public List<Calendar> lCalendar;
        public ResultWrapperFindCalendar(Boolean status, String errorMsg, List<Calendar> lCalendar){
            this.status = status;
            this.errorMsg = errorMsg;
            this.lCalendar = lCalendar;
        } */
         @AuraEnabled public List<CalendarWrapper> lCalendar;
        public ResultWrapperFindCalendar(Boolean status, String errorMsg, List<CalendarWrapper> lCalendar){
            this.status = status;
            this.errorMsg = errorMsg;
            this.lCalendar = lCalendar;
        }    
    }

    /**
        @description Wrapper class to return calendar information
    */
    public class CalendarWrapper {
        @AuraEnabled public String calendarId;
        @AuraEnabled public String calendarName;
        @AuraEnabled public String calendarType;
        public CalendarWrapper (String calendarId, String calendarName, String calendarType){
            this.calendarId = calendarId;
            this.calendarName = calendarName;
            // To set an icon in HTML
            this.calendarType = calendarType == 'Resource' ? 'custom:custom24' : 'standard:user';
        }
    }
}