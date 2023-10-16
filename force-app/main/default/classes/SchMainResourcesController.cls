public without sharing class SchMainResourcesController {
    


    /**
        @description            Search resources of an specific type
        @param resCategories    List of Resource's types to search
        @result                 Map relating Resource's List for each subtype 
    */
    @AuraEnabled(cacheable=true)
    public static ResultWrapperGetResource getResourcesList (GetResourcesRequest resCategories) {
        
        ResultWrapperGetResource ret = new ResultWrapperGetResource();

        // return structure
        Map<String, List<ResourceWrapper>> mLabel_Resource = new Map<String, List<ResourceWrapper>>();

    
        // To return the map using the picklist label instead value
        Map<String, String> mSubtype = new Map<String, String>();
        if (resCategories != null){

            for (Subtype st : resCategories.Resource.lSubType){
                mLabel_Resource.put(st.label, new List<ResourceWrapper>());
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
           
            List<Calendar> lCalendar = [SELECT Id, Name FROM Calendar WHERE Id IN :mCalendarId_Subtype.keySet() AND Type = 'Resource'];

            for (Calendar cal : lCalendar){
                if(mCalendarId_Subtype.containsKey(cal.Id)){
                    String subtype = mCalendarId_Subtype.get(cal.Id);
                    if (mSubtype.containsKey(subtype)){
                        String subtypeLabel = mSubtype.get(subtype);     
                        if (mLabel_Resource.containsKey(subtypeLabel)){
                            List<ResourceWrapper> lResourceWrapper = mLabel_Resource.get(subtypeLabel);
                            ResourceWrapper rw = new ResourceWrapper();
                            rw.id = cal.Id;
                            rw.name = cal.Name;
                            lResourceWrapper.add(rw);
                            mLabel_Resource.put(subtypeLabel, lResourceWrapper);
                        }
                    }
                }      
            }

        }else{
            ret.status = false;
            ret.errorMsg = 'Error getting resource subtypes from Calendar Setting';
        }
        
        ret.mResource = mLabel_Resource;

        return ret;
    }    

    /**
        @description            Search events from resource
        @param userId           Resource Id to search events
        @result                 Event list
    */
    @AuraEnabled(cacheable=true)
    public static ResultWrapperGetEvent getResourceEvents (Id resourceId) {

        ResultWrapperGetEvent resultGetEvent = new ResultWrapperGetEvent();
        List<Event> lEvent = new List<Event>();
        try{
            List<EventRelation> lRelation = [SELECT Id, EventId FROM EventRelation WHERE RelationId = :resourceId AND EventId != null ];

            if (lRelation != null){
                Set<Id> sEventIds = new Set<Id>();
                for (EventRelation rel : lRelation){
                    sEventIds.add(rel.EventId);
                }

                lEvent = [SELECT Id, StartDateTime, EndDateTime, Subject, WhoId, WhatId, IsAllDayEvent, Who.Name FROM Event WHERE Id IN :sEventIds AND StartDateTime >= THIS_MONTH];
            }

            resultGetEvent.lEvent = lEvent;
        }catch(Exception e){
            resultGetEvent.status = false;
            resultGetEvent.errorMsg = e.getMessage();
        }

        return resultGetEvent;
    } 

    /**
        @description Wrapper class to return resource information
    */
    public class ResourceWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
    }

    /**
        @description Structure to manage the Subtypes of the picklist values of Calendar Setting
    */
    public class GetResourcesRequest {

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
    
    public class ResultWrapperGetResource {
        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String errorMsg = '';

        @AuraEnabled public Map<String, List<ResourceWrapper>> mResource;
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