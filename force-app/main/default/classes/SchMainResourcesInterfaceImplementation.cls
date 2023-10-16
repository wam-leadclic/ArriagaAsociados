/** 
 * Custom implementation for custom user/resource list retrieval.
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-10-01
 */
public with sharing class SchMainResourcesInterfaceImplementation implements SchMainResourcesInterface {
   
    // ----------------------- control variables ----------------------
    public static Boolean GET_RESOURCE_LIST_CUSTOM_ACTIVE = true;


    public static List<CalendarSetting__c> getResourceListWithCustomCriteria (Set<String> sSubtype){

        List<CalendarSetting__c> lCS = new List<CalendarSetting__c>();

        // Query current user
        List<Calendar> lCurrentCalendar = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() LIMIT 1];

            if(!lCurrentCalendar.isEmpty()) {
                Set<Id> sOfficeId = new Set<Id>();
                
                // query current Calendar Setting
                for(CalendarSetting__C currentCalendar : [SELECT Id, Oficina__c, Subtype__c FROM CalendarSetting__c WHERE CalendarId__c = :lCurrentCalendar[0].Id]) {
                    if(currentCalendar.Oficina__c != null) {
                        sOfficeId.add(currentCalendar.Oficina__c);
                    }
                }

                if(!sOfficeId.isEmpty()) {
                    lCS = [SELECT Id, Subtype__c, CalendarId__c 
                            FROM CalendarSetting__c  
                            WHERE (Subtype__c IN :sSubtype) AND (Oficina__c IN :sOfficeId)];
                }
            }

        return lCS;
    }
}