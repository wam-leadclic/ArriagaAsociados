public without sharing class SchUsersController {

    /**
        @description            Search users of an specific type
        @param userCategories   List of User's types to search
        @result                 Map relating User's List for each subtype 
    */
    @AuraEnabled(cacheable=true)
    public static ResultWrapperGetUser getUsersList (GetUsersRequest userCategories) {
        
        ResultWrapperGetUser ret = new ResultWrapperGetUser();

        // To return the map using the picklist label instead value
        Map<String, List<UserWrapper>> mLabel_User = new Map<String, List<UserWrapper>>();
        Map<String, String> mSubtype = new Map<String, String>();
        if (userCategories != null){

            for (Subtype st : userCategories.User.lSubType){
               mLabel_User.put(st.label, new List<UserWrapper>());
               mSubtype.put(st.value, st.label);
            }

            // Custom implementation, calendar setting retrieval
            List<CalendarSetting__c> lCalendarSetting = new List<CalendarSetting__c>();
            Type t = Type.forName('SchMainResourcesInterfaceImplementation');
            if (t != null){
                SchMainResourcesInterface extendedFeatures = (SchMainResourcesInterface)t.newInstance();
                lCalendarSetting = extendedFeatures.getResourceListWithCustomCriteria(mSubtype.keySet());
            } else {
                lCalendarSetting = [SELECT Id, Subtype__c, CalendarId__c FROM CalendarSetting__c WHERE Subtype__c IN :mSubtype.keySet()];
            }

            Map<Id, String> mCalendarId_Subtype = new Map<Id, String>();
            for (CalendarSetting__c cs : lCalendarSetting){
                mCalendarId_Subtype.put(cs.CalendarId__c, cs.Subtype__c);
            }

            List<Calendar> lCalendar = [SELECT Id, UserId FROM Calendar WHERE Id IN :mCalendarId_Subtype.keySet() AND Type = 'User'];

            Map<Id, Id> mUser_Calendar = new Map<Id, Id>();
            for (Calendar cal : lCalendar){
                mUser_Calendar.put(cal.UserId, cal.Id);          
            }

            List<User> lUser = [SELECT Id, Name, Phone, Email FROM User WHERE Id IN: mUser_Calendar.keySet()];

            
            for (User u : lUser){
                if (mUser_Calendar.containsKey(u.Id)){
                    Id calendarId = mUser_Calendar.get(u.Id);
                    if (mCalendarId_Subtype.containsKey(calendarId)){
                        String subtype = mCalendarId_Subtype.get(calendarId);
                        if (mSubtype.containsKey(subtype)){
                            String subtypeLabel = mSubtype.get(subtype);          
                            if (mLabel_User.containsKey(subtypeLabel)){
                                List<UserWrapper> lUserWrapper = mLabel_User.get(subtypeLabel);
                                UserWrapper uw = new UserWrapper();
                                uw.id = u.Id;
                                uw.name = u.Name;
                                uw.phone = u.Phone;
                                uw.email = u.Email;
                                lUserWrapper.add(uw);                                    
                                mLabel_User.put(subtypeLabel, lUserWrapper);
                            }
                        }
                    }
                }
            }

        }else{
           ret.status = false;
           ret.errorMsg = 'Error getting user subtypes from Calendar Setting';
        }
        
        ret.mUser = mLabel_User;

        return ret;
         
    }

   /**
        @description            Search events from user
        @param userId           User Id to search events
        @result                 Event list
    */
    @AuraEnabled(cacheable=true)
    public static ResultWrapperGetEvent getUserEvents (Id userId) {

        ResultWrapperGetEvent resultGetEvent = new ResultWrapperGetEvent();
        
        try{
            List<Event> lEvent = [SELECT Id, StartDateTime, EndDateTime, Subject, WhoId, WhatId, IsAllDayEvent, Who.Name FROM Event WHERE OwnerId = :userId AND StartDateTime >= THIS_MONTH];
            resultGetEvent.lEvent = lEvent;
        }catch(Exception e){
            resultGetEvent.status = false;
            resultGetEvent.errorMsg = e.getMessage();
        }

        return resultGetEvent;
    } 

    /**
        @description Wrapper class to return user information
    */
    public class UserWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String phone;
        @AuraEnabled public String email;
    }

    /**
        @description Structure to manage the Subtypes of the picklist values of Calendar Setting
    */
    public class GetUsersRequest {

        @AuraEnabled public UserReq User {get; set; }
        @AuraEnabled public UserReq Resource {get; set; }
    }

    public class UserReq {
        @AuraEnabled public Info info {get; set; }
        @AuraEnabled public List<Subtype> lSubtype {get; set; }
    }

     public class Info {
        @AuraEnabled public Object attributes {get; set; }
        @AuraEnabled public String label {get; set; }
        @AuraEnabled public List<ValidFor> validFor {get; set; }
        @AuraEnabled public String value {get; set; }
    }

    public class ValidFor {
    }

    public class Subtype {
        @AuraEnabled public Object attributes {get; set; }
        @AuraEnabled public String label {get; set; }
        @AuraEnabled public List<Integer> validFor {get; set; }
        @AuraEnabled public String value {get; set; }
    }

    /**
        @description Wrapper class to return the results to the component
    */
    
    public class ResultWrapperGetUser {
        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String errorMsg = '';

        @AuraEnabled public Map<String, List<UserWrapper>> mUser;
    }

    public class ResultWrapperGetEvent {
        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String errorMsg = '';

        @AuraEnabled public List<Event> lEvent;
        @AuraEnabled public Date openDate = System.today();
        @AuraEnabled public Date endDate = System.today().addYears(1);    
        @AuraEnabled public Date startDate = System.today().toStartofMonth(); // First day of current month                                             
    }
}