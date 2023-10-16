/** 
 * Clic2Meet interface with methods for custom implementations 
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-07-01
 */
global interface SchExtendedFeatures {

    /**
     * setInitParams overrides main scheduler inicializaton params. Included url params.
     * @param  attendeeId attendee id (lead, contact or person account Id)
     * @return            return map with params values
     */ 
    Map<String, Object> setInitParams (Id attendeeId);
    

    /**
     * setInitFilterParams overrides filters init values.
     * @return   return map with filters values. If custom lookup applies
     */ 
    Map<String, Object> setInitFilterParams (Map<Object, Object> mParams);


    /*  setEventParams overrides standard event creation
        @return event to create with custom field fill
    */
    Event setEventParams (Event evt, Map<Object, Object> mParams, Map<Id, Id> mCalendarUser);

  

}