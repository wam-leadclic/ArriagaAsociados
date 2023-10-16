/** 
 * Clic2Meet main controller class. Used for availability time slots retrieval
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-06-01
 */
public with sharing class SchSearchController {
   
    /**
     * getAvailability Implements availability search using several filters passed in the request object
     * @param  request filters used to search availability
     * @return         Time Slot list that will be paint in calendar as availability
     */
    
    @AuraEnabled
    public static GetAvailabilityResponse getAvailability ( GetAvailabilityRequest request ) {

        GetAvailabilityResponse response = new GetAvailabilityResponse();
        response.status = true;
       
        try {
            // Search by Calendar Setting intervals
            if (!request.searchByEvents){
                List<TimeSlot> lTimeSlot = new List<TimeSlot>();

                //Key: Day in string format, Value: Map containing the list of events or days off related to each Calendar
                Map<String, Map<Id, List<Interval>>> mDayCalendarIntervals = new Map<String, Map<Id, List<Interval>>>();

                // calendar settings retrieval and filter by main requirements (min resources and calendar)
                GetResourceInfoResult resultWrapper = getResourcesInfo(request, mDayCalendarIntervals);
                Map<String, ResourceInfo> mDateResources = resultWrapper.mDateResource;

                // Get current evets
                getResourceCurrentEvents(resultWrapper.mCalendarIdInfo.keySet(), request, mDayCalendarIntervals);

                // Interval creation
                
                ResponseResourceTimeSlot respResourceTimeSlot = getTimeSlots(mDateResources.values(), mDayCalendarIntervals, resultWrapper.mCalendarIdInfo, request);
                response.lTimeSlot = respResourceTimeSlot.lTimeSlot;            
                response.lResultResource = respResourceTimeSlot.lResourceSlot;

                response.lResult = getResultItems(response.lTimeSlot);

            // Search by events instead of Calendar Setting    
            } else {
                response.lTimeSlot = searchByEvents(request);
                response.lResult = getResultItems(response.lTimeSlot);
            }

        } catch (Exception e) {

            response.status = false;
            response.errorMsg = e.getMessage() + e.getStackTraceString();
            System.debug(response.errorMsg);
        }
        
        return response;
    }

    /**
     * Search availability by events yet created
     * @param request  Search start date
     * @return         List of events that match the request
     */ 
    private static List<TimeSlot> searchByEvents(GetAvailabilityRequest request){

        String finalQuery = '';

        try{
            // we use date or full datetime if hour constraint is filled
            Datetime fromDate = (request.startHour != null) ? request.startHour : request.searchFromDate;
            Datetime toDate = (request.endHour != null) ? request.endHour : request.searchToDate;

            String selectQuery = 'SELECT Id, StartDateTime, EndDateTime, Subject, IsAllDayEvent';  
            String fromQuery = ' FROM Event';
            String whDates = ' WHERE StartDateTime >= :fromDate AND EndDateTime <= :toDate';
            String orderBy = ' ORDER BY StartDateTime ASC';
            String whFilter = '';

            if(request.filterValues != null) {
                
                List<String> lFilter = new List<String>();

                for (String key : request.filterValues.keySet()) {

                    String filterValue = (String) request.filterValues.get(key); 
                    if(!String.isBlank(filterValue)) {
                        String chunk = key + '= \'' + request.filterValues.get(key) + '\''; 
                        lFilter.add(chunk);         
                    }  
                }
                whFilter = String.join(lFilter, ' AND ');
            }

            // query concat
            finalQuery = selectQuery + fromQuery + whDates;
            if(!String.isBlank(whFilter)) {
                finalQuery += ' AND ' + whFilter;
            }
            finalQuery += orderBy;
            System.debug(finalQuery);
        } catch (Exception e) {
            System.debug('EXCEPTION: Events retrieval' + e.getStackTraceString() + e.getCause() + e.getMessage());
            return null;
        }

        List<TimeSlot> lTimeSlot = new List<TimeSlot>();
        Integer uniqueId = 0;
        for (Event evt : Database.query(finalQuery)){
            TimeSlot slot = new TimeSlot();
            slot.Id = evt.Id;
            slot.Idx = String.valueOf(uniqueId);
            slot.startDateTime = evt.StartDateTime;
            slot.endDateTime = evt.EndDateTime;
            slot.subject = evt.Subject;
            lTimeSlot.add(slot); 
            uniqueId++;   
        }

        return lTimeSlot;

    }

    /**
     * getHolidays used for calendar settings holidays retrieval
     * @param fromDate  Search start date
     * @param toDate    Search end date
     * @return          returns free days stored in map using calendarsetting as Id and set of dates (dd-MM-yyyy) as value
     */ 
    private static void createIntervalsHolidays (Datetime fromDate, Datetime toDate, Map<String, Map<Id, List<Interval>>> mDayCalendarIntervals) {

        List<HolidayAbsence__c> lAbsences = [SELECT Id, CalendarId__c, StartDate__c, EndDate__c 
                                                FROM HolidayAbsence__c 
                                                WHERE ( ( StartDate__c <= :fromDate AND EndDate__c >= :fromDate)  OR  (StartDate__c >= :fromDate AND StartDate__c <= :toDate) )];

        // Get calendar type from Calendar
        Set<Id> sCalendarId = new Set<Id>();
        for (HolidayAbsence__c absence : lAbsences){
            sCalendarId.add(absence.CalendarId__c);
        }

        List<Calendar> lCalendar = [SELECT Id, Type FROM Calendar WHERE Id IN :sCalendarId];
        Map<Id, String> mCalendarType = new Map<Id, String>();
        for (Calendar cal : lCalendar){
            mCalendarType.put(cal.Id, cal.Type);
        }

        for (HolidayAbsence__c absenceRange : lAbsences){
            createIntervals(absenceRange.StartDate__c, absenceRange.EndDate__c, false, mCalendarType.get(absenceRange.CalendarId__c), absenceRange.CalendarId__c, mDayCalendarIntervals);
        }                                                 
    }


    private static GetResourceInfoResult getResourcesInfo ( GetAvailabilityRequest request, Map<String, Map<Id, List<Interval>>> mDayCalendarIntervals ) {
		

        GetResourceInfoResult resultWrapper = new GetResourceInfoResult();

        // result map 
        Map<String, ResourceInfo> mDateResources = new Map<String, ResourceInfo>();

        // CalendarId set
        Set<Id> sCalendarId = new Set<Id>();

        // Holidays map (CalendarSetting Id - Set<dd-MM-YYY>)
        Map<String, Set<String>> mHolidays = new Map<String, Set<String>>();

        try {
            
            // query params
            Set<String> sSubtype = new Set<String>();
            sSubtype.addAll(request.resourceSelected);
            sSubtype.addAll(request.userSelected);

            // we use date or full datetime if hour constraint is filled
            Datetime fromDate = (request.startHour != null) ? request.startHour : request.searchFromDate;
            // Check fromDate to avoid create past appointments
            fromDate = (fromDate < System.now()) ? System.now() : fromDate; 
            Datetime toDate = (request.endHour != null) ? request.endHour : request.searchToDate;
            
            
            String selectQuery = 'SELECT Id, CalendarSetting__r.CalendarId__c, CalendarSetting__r.Type__c, CalendarSetting__r.Subtype__c, CalendarSetting__r.Timezone__c,  Timetable__c, EffectiveFrom__c, EffectiveTo__c, CalendarSetting__r.HolidayCalendar__c, CalendarSetting__r.Videollamada__c ';
            String selectQueryTimetable =   ',Timetable__r.MondayMorningTo__c, Timetable__r.MondayMorningFrom__c, Timetable__r.MondayAfterTo__c, Timetable__r.MondayAfterFrom__c,' +
                                            'Timetable__r.TuesdayMorningTo__c,Timetable__r.TuesdayMorningFrom__c,Timetable__r.TuesdayAfterTo__c,Timetable__r.TuesdayAfterFrom__c,' +
                                            'Timetable__r.WednesdayMorningTo__c,Timetable__r.WednesdayMorningFrom__c,Timetable__r.WednesdayAfterTo__c,Timetable__r.WednesdayAfterFrom__c,' +
                                            'Timetable__r.ThursdayMorningTo__c,Timetable__r.ThursdayMorningFrom__c,Timetable__r.ThursdayAfterTo__c,Timetable__r.ThursdayAfterFrom__c,' +
                                            'Timetable__r.FridayMorningTo__c,Timetable__r.FridayMorningFrom__c,Timetable__r.FridayAfterTo__c,Timetable__r.FridayAfterFrom__c,' +
                                            'Timetable__r.SaturdayMorningTo__c,Timetable__r.SaturdayMorningFrom__c,Timetable__r.SaturdayAfterTo__c,Timetable__r.SaturdayAfterFrom__c,' +
                                            'Timetable__r.SundayMorningTo__c,Timetable__r.SundayMorningFrom__c,Timetable__r.SundayAfterTo__c, Timetable__r.SundayAfterFrom__c'; 
            
            String fromQuery = ' FROM CalendarTimetable__c ';
            String whSubTypeQuery = ' CalendarSetting__r.Subtype__c IN :sSubtype';
            //String whEffectiveDates = ' ( ( (EffectiveFrom__c <= :fromDate ) AND (EffectiveTo__c >= :fromDate))  OR  ((EffectiveFrom__c <= :toDate ) AND ( EffectiveTo__c >=:toDate))  OR  ((EffectiveFrom__c <= :fromDate) AND (EffectiveTo__c >= :toDate)) )';
            String whEffectiveDates = ' ( ( EffectiveFrom__c <= :fromDate AND EffectiveTo__c >= :fromDate)  OR  (EffectiveFrom__c >= :fromDate AND EffectiveFrom__c <= :toDate) )';
            String whFilter = '';

        
    
            if(request.filterValues != null) {
                
                List<String> lFilter = new List<String>();

                for (String key : request.filterValues.keySet()) {
                    
                    // TODO: cambiar el cast a string por el tipo adecuado recorriendo el schema de calendar setting
					String filterValue = (String) request.filterValues.get(key); 
                    if(!String.isBlank(filterValue)) {
                        String chunk = 'CalendarSetting__r.' + key + '= \'' + request.filterValues.get(key) + '\''; 
                        lFilter.add(chunk);
                    }  
                }
                
                whFilter = String.join(lFilter, ' AND ');
                
            }	

            // query concat
            String finalQuery = selectQuery + selectQueryTimetable + fromQuery + ' WHERE' + whEffectiveDates + ' AND ' + whSubTypeQuery;
            if(!String.isBlank(whFilter)) {
                finalQuery += ' AND ' + whFilter;
            }
            
            //Añadimos como filtro Videollamada si el check está marcado
                if(request.extraParams != null){
                    system.debug('EXTRAPARAMS>> :'+request.extraParams);
                    List<Object> videoMeeting = (List<Object>) request.extraParams.get('typeSelected');
                
            
                    if(!Test.isRunningTest() && videoMeeting != null && videoMeeting.size() != 0 && videoMeeting[0] =='Videollamada'){
                       String videomeetingFilter = ' CalendarSetting__r.Videollamada__c = true '; 
                       finalQuery += ' AND ' + videomeetingFilter;
                       
                    }
        		}
            System.debug(finalQuery);    

            // query for calendar holidays

            Map<Id, Day__c> mHoliday = new Map<Id, Day__c> ( [SELECT Id, Holiday__c, HolidayZone__c 
                                                                FROM Day__c 
                                                                WHERE Holiday__c >= :fromDate.date() AND Holiday__c <= :toDate.date()] );
            
            Map<Id, Set<Id>> mHolidayZoneDays = new Map<Id, Set<Id>>();
            for (Day__c day : mHoliday.values()){
                Set<Id> sDays = mHolidayZoneDays.containsKey(day.HolidayZone__c) ? mHolidayZoneDays.get(day.HolidayZone__c) : new Set<Id>();
                sDays.add(day.Id);
                mHolidayZoneDays.put(day.HolidayZone__c, sDays);
            }

            List<HolidayCalendarZone__c> lHolidayCz = [SELECT Id, HolidayCalendar__c, HolidayZone__c 
                                                        FROM HolidayCalendarZone__c 
                                                        WHERE HolidayZone__c IN :mHolidayZoneDays.keySet()];

            Map<Id, Set<Date>> mIdHcDays = new Map<Id, Set<Date>>();
            for (HolidayCalendarZone__c cZone : lHolidayCz){               
                if (mHolidayZoneDays.containsKey(cZone.HolidayZone__c)){
                    Set<Id> sDayId = mHolidayZoneDays.get(cZone.HolidayZone__c);
                    for (Id dayId : sDayId){
                        Date holiday = mHoliday.get(dayId).Holiday__c;
                        Set<Date> sDay = mIdHcDays.containsKey(cZone.HolidayCalendar__c) ? mIdHcDays.get(cZone.HolidayCalendar__c) : new Set<Date>();
                        sDay.add(holiday);
                        mIdHcDays.put(cZone.HolidayCalendar__c, sDay);
                    }
                }
            }
			
            
            // init result map with each searched day
            for(Datetime d = request.searchFromDate ; d <= request.searchToDate; d=d.addDays(1)) {
                if (d >= System.today())
                    mDateResources.put(d.formatGmt('dd-MM-yyyy'), new ResourceInfo(d));
            }

            // Holidays retrieval
            createIntervalsHolidays(fromDate, toDate, mDayCalendarIntervals);

            // retrieve calendarIds and user due inactive user disposal
            for(CalendarTimetable__c nm : Database.query(finalQuery)) {
                sCalendarId.add(nm.CalendarSetting__r.CalendarId__c);
            }

            // Search the resource name for each calendar Id
            Map<Id, UserResourceWrapper> mCalendarIdInfo = new Map<Id, UserResourceWrapper>();
            
            List<Calendar> lCalendar = [SELECT Id, Name, UserId, Type FROM Calendar WHERE Id IN :sCalendarId];
            Map<Id, Id> mUserIdCalendarId = new Map<Id, Id>();
            for (Calendar cal : lCalendar){
                if (cal.Type == 'User'){
                    mUserIdCalendarId.put(cal.UserId, cal.Id);
                }else if (cal.Type == 'Resource'){
                    UserResourceWrapper ur = new UserResourceWrapper();
                    ur.resourceName = cal.Name;
                    ur.resourceType = 'Resource';
                    mCalendarIdInfo.put(cal.Id, ur);
                }
            }
            List<User> lUser = [SELECT Id, Name, isActive FROM User WHERE Id IN : mUserIdCalendarId.keySet()];
            for (User u : lUser){
                if (mUserIdCalendarId.containsKey(u.Id)){               
                    UserResourceWrapper ur = new UserResourceWrapper();
                    ur.resourceName = u.Name;
                    ur.resourceType = 'User';
                    ur.isActive = u.isActive;
                    mCalendarIdInfo.put(mUserIdCalendarId.get(u.Id), ur);
                }
            }

            // ------------------------------- calendar timetables N-M iteration ------------------------------------------
            ResourceInfo info;
            for(CalendarTimetable__c nm : Database.query(finalQuery)) {
               
                // get related calendar Id
                // sCalendarId.add(nm.CalendarSetting__r.CalendarId__c);

                if(nm.CalendarSetting__r.Timezone__c != null) {

                    // List of holidays for this calendar setting
                    Set<Date> sHoliday = new Set<Date>();
                    if (mIdHcDays.containsKey(nm.CalendarSetting__r.HolidayCalendar__c)){
                        sHoliday = mIdHcDays.get(nm.CalendarSetting__r.HolidayCalendar__c);
                    }

                    // get current resource timezone 
                    TimeZone tz = TimeZone.getTimeZone(nm.CalendarSetting__r.Timezone__c);
                    
                    // searched days iteration. fill each day with available resources
                    for(Datetime d = request.searchFromDate ; d <= request.searchToDate; d=d.addDays(1)) {
                
                        // check is calendar setting is linked with an active user or resource
                        Boolean isUserActive = (nm.CalendarSetting__r.Type__c == 'User') && 
                                               (mCalendarIdInfo.containsKey(nm.CalendarSetting__r.CalendarId__c)) && 
                                                (mCalendarIdInfo.get(nm.CalendarSetting__r.CalendarId__c).isActive);
                        
                        if(nm.CalendarSetting__r.Type__c == 'Resource' || isUserActive) {

                            // get current resource offset
                            Integer offSet = tz.getOffset(DateTime.newInstanceGmt( d.year() , d.monthGmt(), d.dayGmt() , 0, 0, 0));
                            
                            //  check if searched date is contained in nm range date
                            if(d >= nm.EffectiveFrom__c && d <= nm.EffectiveTo__c) {
                                
                                Boolean dayHoliday = sHoliday.contains(d.dateGMT());
                                Boolean isFreeDay = false;
                                Boolean isSupRangeOK = true;
                                Boolean isInfRangeOK = true;
                                Boolean isPastDay = !mDateResources.containsKey(d.formatGmt('dd-MM-yyyy'));

                                if(!dayHoliday && !isPastDay) {

                                    info = mDateResources.get(d.formatGmt('dd-MM-yyyy'));
                            
                                    // check if calendar suits hour requirements
                                    String dayOfWeek = info.day.formatGmt('EEEE');
                                    Time morningFrom = (Time) nm.getSobject('Timetable__r').get(dayOfWeek + 'MorningFrom__c'); 
                                    Time morningTo = (Time) nm.getSobject('Timetable__r').get(dayOfWeek + 'MorningTo__c'); 
                                    Time afterFrom = (Time) nm.getSobject('Timetable__r').get(dayOfWeek + 'AfterFrom__c'); 
                                    Time afterTo = (Time) nm.getSobject('Timetable__r').get(dayOfWeek + 'AfterTo__c'); 

                                    // apply timezone offset
                                    morningFrom = (morningFrom != null) ? morningFrom.addSeconds(-offSet/1000) : null;
                                    morningTo = (morningTo != null) ? morningTo.addSeconds(-offSet/1000) : null;
                                    afterFrom = (afterFrom != null) ? afterFrom.addSeconds(-offSet/1000) : null;
                                    afterTo = (afterTo != null) ? afterTo.addSeconds(-offSet/1000) : null;

                                    // add time interval to wrapper class
                                    isFreeDay = ((morningFrom == null) && (morningTo == null) && (afterFrom == null) && (afterTo == null));
                                    
                                    if (!isFreeDay) {

                                        if(request.endHour != null) {
                                            Time endTo = Time.newInstance(request.endHour.hourGMT(), request.endHour.minuteGMT(), 0, 0);
                                            isSupRangeOK = ( endTo != null && ( (morningFrom != null && morningFrom < endTo) || (afterFrom != null && afterFrom < endTo) ) );
                                        }

                                        if(request.startHour != null) {
                                            Time startTo = Time.newInstance(request.startHour.hourGmt(), request.startHour.minuteGmt(), 0, 0);
                                            isInfRangeOK = ( startTo != null && ( (morningTo != null && morningTo >= startTo) || (afterTo != null && afterTo >= startTo) ) );
                                        }
                                    }
                                }

                                // Drop day if any condition is KO
                                if((!dayHoliday) && (!isFreeDay) && isSupRangeOK && isInfRangeOK && (!isPastDay)) {
                                    if(!info.mResource.containsKey(nm.CalendarSetting__r.Subtype__c)) {
                                        info.mResource.put(nm.CalendarSetting__r.Subtype__c, new List<CalendarTimeTableInterval>());
                                    }
                                    info.mResource.get(nm.CalendarSetting__r.Subtype__c).add(new CalendarTimeTableInterval (nm, d, nm.CalendarSetting__r.Type__c, request));
                                    info.lCalendarTTInterval.add(new CalendarTimeTableInterval (nm, d, nm.CalendarSetting__r.Type__c, request));
                                } else {
                                    //System.debug('dropped day: ');
                                }
                                                                                            
                            }

                        }
                        

                    }
                }
            }

            // check if days have all required resources 
            for(String dateKey : mDateResources.keySet()) {
                info = mDateResources.get(dateKey);
                if(!info.mResource.keySet().containsAll(sSubtype)){
                    mDateResources.remove(dateKey);
                }            
            }

            resultWrapper.mDateResource = mDateResources;
            resultWrapper.mCalendarIdInfo = mCalendarIdInfo;

        } catch (Exception e) {
            System.debug('EXCEPTION: Calendar settings retrieval' + e.getStackTraceString() + e.getCause() + e.getMessage());
        }


        return resultWrapper;

    }


    private static void createIntervals (Datetime startDate, Datetime endDate, Boolean isAllDayEvent, String resourceType, Id calendarId, Map<String, Map<Id, List<Interval>>> mDayCalendarIntervals){

        Map<String, List<Interval>> mDayInterval = new Map<String, List<Interval>>();
        // Check if the event lasts more than 1 day   
        if (startDate.dateGMT().daysBetween(endDate.dateGMT()) >= 1){
            // The first day is StartDateTime, add days until reach the last day, EndDateTime
            for (Datetime dayTime = startDate.dateGMT(); dayTime <= endDate.dateGMT(); dayTime = dayTime.addDays(1)){
                Date day = dayTime.dateGMT();

                Interval interv = null;
                // All days between first and last day, are allDayEvent
                if ( isAllDayEvent || (day > startDate.dateGMT() && day < endDate.dateGMT()) ){
                    interv = new Interval(null, null, resourceType);
                    interv.isAllDay = true;
                // First day    
                }else if (day == startDate.dateGMT()){
                    interv = new Interval(startDate.timeGmt(), null, resourceType);
                // Last day
                }else if (day == endDate.dateGMT()){
                    interv = new Interval(null, endDate.timeGmt(), resourceType);
                }

                if (interv != null){
                    String dayString = dayTime.formatGMT('dd-MM-yyyy');

                    List<Interval> lInterval = new List<Interval>();
                    if (mDayInterval.containsKey(dayString)){
                        lInterval = mDayInterval.get(dayString);
                    }
                    lInterval.add(interv);
                    mDayInterval.put(dayString, lInterval);
                }

            }
        }else{     
            List<Interval> lInterval = new List<Interval>();        
            // Check if the event is allDayEvent 
            if (isAllDayEvent){
                Interval intervalAllDay = new Interval(null, null, resourceType);
                intervalAllDay.isAllDay = true;
                lInterval.add(intervalAllDay);
            }else{
                Interval intervalRegular = new Interval(startDate.timeGmt(), endDate.timeGmt(), resourceType);
                lInterval.add(intervalRegular);
            }
        
            String dayString = startDate.formatGMT('dd-MM-yyyy');
            mDayInterval.put(dayString, lInterval);
        }

        for (String dayString : mDayInterval.keySet()){

            Map<Id, List<Interval>> mCalendarIntervals = new Map<Id, List<Interval>>();

            if (mDayCalendarIntervals.containsKey(dayString)){
                mCalendarIntervals = mDayCalendarIntervals.get(dayString);
            }

            // Create response map
            List<Interval> lIntervalMap = new List<Interval>();
            if (mCalendarIntervals.containsKey(calendarId)){
                lIntervalMap = mCalendarIntervals.get(calendarId);
            }
            lIntervalMap.addAll(mDayInterval.get(dayString));
            mCalendarIntervals.put(calendarId, lIntervalMap);
            
            if (dayString != null){
                if (mDayCalendarIntervals.containsKey(dayString)){
                    mDayCalendarIntervals.get(dayString).putAll(mCalendarIntervals);
                }else{
                    mDayCalendarIntervals.put(dayString, mCalendarIntervals);
                }
            }

        }

    }


    /**
     * Get the events related with each user and resource
     * @param sCalendarId   List of calendar IDs to search        
     * @param request       Contains the dates information  
     * @return Map containing the list of events related to each Calendar, grouped by day
     */      
    private static void getResourceCurrentEvents ( Set<Id> sCalendarId, GetAvailabilityRequest request, Map<String, Map<Id, List<Interval>>> mDayCalendarIntervals ) {

        // Query users for their Calendar Id
        List<Calendar> lCalendar = [SELECT Id, UserId, Type FROM Calendar WHERE Id IN :sCalendarId];
        Map<Id, Id> mUserCalendar = new Map<Id, Id>(); //Key: UserId, Value: CalendarId
        Set<Id> sCalendarIdResources = new Set<Id>();
        for (Calendar cal : lCalendar){
            if (cal.Type == 'User'){
                mUserCalendar.put(cal.UserId, cal.Id);
            }else if (cal.Type == 'Resource'){
                sCalendarIdResources.add(cal.Id);
            }    
        }

        // To search the Resource events, we need to access to EventRelation table
        List<EventRelation> lEventRelation = [SELECT RelationId, EventId FROM EventRelation WHERE RelationId IN: sCalendarIdResources]; 
        Map<Id, Id> mEventCalendar = new Map<Id, Id>(); //Key: EnventId, Value: Calendar Id
        for (EventRelation eventRel : lEventRelation){
            mEventCalendar.put(eventRel.EventId, eventRel.RelationId);
        }

        // we use date or full datetime if hour constraint is filled
        Datetime fromDate = (request.startHour != null) ? request.startHour : request.searchFromDate;
        
        // Check fromDate to avoid create past appointments
        fromDate = (fromDate < System.now()) ? System.now() : fromDate;
		Datetime toDate = (request.endHour != null) ? request.endHour : request.searchToDate;
        if (request.endHour == null){
            toDate = toDate.addDays(1);
        }

        // Events related to Users and Resources
        List<Event> lEvent = [ SELECT Id, OwnerId, StartDateTime, EndDateTime, IsAllDayEvent 
                                FROM Event 
                                WHERE OmitInSearch__c = false      
                                    AND ( (StartDateTime <= :fromDate AND EndDateTime >= :fromDate) 
                                    OR (StartDateTime >= :fromDate AND StartDateTime <= :toDate) )                            
                                    AND (OwnerId IN :mUserCalendar.keySet() OR Id IN :mEventCalendar.keySet())
                                    ORDER BY StartDateTime ASC];

        Map<Id, List<Event>> mCalendarSettingEvents = new Map<Id, List<Event>>(); //Map containing the list of events related to each Calendar Setting

        // Create result map relating each list of events with their Calendar
        for (Event eventResource: lEvent){
            if (mUserCalendar.containsKey(eventResource.OwnerId)){
                createIntervals(eventResource.StartDateTime, eventResource.EndDateTime, eventResource.IsAllDayEvent, 'User', mUserCalendar.get(eventResource.OwnerId), mDayCalendarIntervals);
            }
            if (mEventCalendar.containsKey(eventResource.Id)){
                createIntervals(eventResource.StartDateTime, eventResource.EndDateTime, eventResource.IsAllDayEvent, 'Resource', mEventCalendar.get(eventResource.Id), mDayCalendarIntervals);
            }   
        }                        

    }


    private static ResponseResourceTimeSlot getTimeSlots (List<ResourceInfo> lResourceInfo,  Map<String, Map<Id, List<Interval>>> mDayCalendarIntervals, Map<Id, UserResourceWrapper> mCalendarIdInfo, GetAvailabilityRequest request){
        List<TimeSlot> lTimeSlot = new List<TimeSlot>();
        List<ResourceSlot> lResourceSlot = new List<ResourceSlot>();
        Integer uniqueId = 0;

        List<String> lSPlit = (request.duration != null) ? request.duration.split(':') : new List<String>();
        Integer durationInMinutes = 0;
        if (lSPlit.size() >= 2){
            durationInMinutes = Integer.valueOf( lSplit[0]) * 60 + Integer.valueOf(lSplit[1]);
        }

        for (ResourceInfo resInfo : lResourceInfo){
            Datetime dayDatetime = resInfo.day;
            String dayString = dayDatetime.formatGmt('dd-MM-yyyy');
            Boolean userHasEvents = false;
            Boolean resourceHasEvents = false;

            Map<Id, List<Interval>> mCalendarIntervalsEvents = new Map<Id, List<Interval>>();                     
            if (mDayCalendarIntervals.containsKey(dayString)){        
                mCalendarIntervalsEvents = mDayCalendarIntervals.get(dayString);         
            }

            ResultCrossedIntervals resultIntervals = getCrossedIntervals(resInfo.lCalendarTTInterval, mCalendarIntervalsEvents);         

            Map<String, Set<String>> mIntervalResources = resultIntervals.mIntervalResources;
            Map<String, String> mCalendarIdSubtype = resultIntervals.mCalendarIdSubtype;
            Map<String, Interval> mKeyIntervalResource = resultIntervals.mKeyIntervalResource;
            Map<String, Interval> mKeyIntervalUser = resultIntervals.mKeyIntervalUser;
            
            // If we are searching resources and users, secure at least one resource and user
            if (!request.resourceSelected.isEmpty() && !request.userSelected.isEmpty()){

                if (mKeyIntervalResource.isEmpty()){
                    // Delete values of users map, and common map
                    for (String keyInterval : mKeyIntervalUser.keySet()){
                        mIntervalResources.remove(keyInterval);
                    }
                    mKeyIntervalUser.clear();
                }

                else if (mKeyIntervalUser.isEmpty()){
                    // Delete values of users map, and common map
                    for (String keyInterval : mKeyIntervalResource.keySet()){
                        mIntervalResources.remove(keyInterval);
                    }
                    mKeyIntervalResource.clear();
                }

            }

            // Create response structure
            List<IntervalResource> lIntervResource = new List<IntervalResource>();
            lIntervResource = createResponseStructure(mKeyIntervalResource.values(), mIntervalResources, mCalendarIdInfo, mCalendarIdSubtype, dayDatetime, 'Resource');
            lIntervResource.addAll(createResponseStructure(mKeyIntervalUser.values(), mIntervalResources, mCalendarIdInfo, mCalendarIdSubtype, dayDatetime, 'User'));


            // Split list of Resource and User by subtype
            Map<String, List<Interval>> mSubtypeIntervals = new Map<String, List<Interval>>();
            for (String intervKey : mIntervalResources.keySet()){
                for (String calendarId : mIntervalResources.get(intervKey)){
                    if (mCalendarIdSubtype.containsKey(calendarId)){
                        String subtype = mCalendarIdSubtype.get(calendarId);
                        
                        List<Interval> lInterval = new List<Interval>();
                        if (mSubtypeIntervals.containsKey(subtype)){
                            lInterval = mSubtypeIntervals.get(subtype);
                        }

                        if (mKeyIntervalResource.containsKey(intervKey)){
                            lInterval.add(mKeyIntervalResource.get(intervKey));
                        }
                        if (mKeyIntervalUser.containsKey(intervKey)){
                            lInterval.add(mKeyIntervalUser.get(intervKey));
                        }

                        mSubtypeIntervals.put(subtype, lInterval);
                    }
                }
            }

            // Solve overlaping for each user/resource subtype
            List<List<Interval>> llInterval = new List<List<Interval>>();
            for (String subtype : mSubtypeIntervals.keySet()){
                List<Interval> lResource = mSubtypeIntervals.get(subtype);
                lResource.sort();
                List<Interval> lResourceUnique = solveOverlap(lResource, mIntervalResources);
                llInterval.add(lResourceUnique);
            }

            // Intersect all the subtype with each other
            List<Interval> lIntervalIntersected = llInterval.isEmpty() ? new List<Interval>() : llInterval[0];
            for (Integer i=1; i < llInterval.size(); i++){
                List<Interval> lIntervalIntersectedResult = new List<Interval>();
                lIntervalIntersectedResult = intersectIntervals(lIntervalIntersected, llInterval[i], mIntervalResources, request); 
                lIntervalIntersected = lIntervalIntersectedResult;
            }
          
            for (Interval interv : lIntervalIntersected){   

                Datetime startDateTime = DateTime.newInstanceGmt(dayDatetime.date(), interv.startInterval);
                Datetime endDateTime = DateTime.newInstanceGmt(dayDatetime.date(), interv.endInterval);

                // Check duration 
                if (startDateTime.addMinutes(durationInMinutes) <= endDateTime){
                    TimeSlot slot = new TimeSlot();
                    slot.Id = String.valueOf(uniqueId);
                    slot.Idx = String.valueOf(uniqueId);
                    slot.startDateTime = startDateTime;
                    slot.endDateTime = endDateTime;
                    //slot.subject = 'Slot: '+String.valueOf(uniqueId);
                    lTimeSlot.add(slot);

                    List<IntervalResource> lIntervalResourceSlot = new List<IntervalResource>();
                    for (IntervalResource intervResource : lIntervResource){
                        if ((intervResource.interval.min <= startDateTime && intervResource.interval.max >= startDateTime) ||
                            (intervResource.interval.min >= startDateTime && intervResource.interval.min <= endDateTime)) {

                            lIntervalResourceSlot.add(intervResource);
                        }
                    }

                    ResourceSlot resSlot = new ResourceSlot();
                    resSlot.Id = String.valueOf(uniqueId);
                    resSlot.lIntervalResource = lIntervalResourceSlot;
                    lResourceSlot.add(resSlot);

                    uniqueId++;
                }
            }

        } // for resourceInfo
        ResponseResourceTimeSlot respResourceTimeSlot = new ResponseResourceTimeSlot();
        respResourceTimeSlot.lTimeSlot = lTimeSlot;
        respResourceTimeSlot.lResourceSlot = lResourceSlot;
        
        return respResourceTimeSlot;
    }


    /**
     * Cross interval resources with events, and get the interval resources and users
     * @param lCalendarTTInterval       List of intervals of NM object CalendarTimeTable        
     * @param mCalendarIntervalsEvents  Map containing the list of events related with each calendarId  
     * @return ResultCrossedIntervals   Response structure with the intervals info 
     */
    private static ResultCrossedIntervals getCrossedIntervals (List<CalendarTimeTableInterval> lCalendarTTInterval, Map<Id, List<Interval>> mCalendarIntervalsEvents) {

        Map<String, Set<String>> mIntervalResources = new Map<String, Set<String>>();
        Map<String, String> mCalendarIdSubtype = new Map<String, String>();

        // Use map to avoid duplicates
        Map<String, Interval> mKeyIntervalResource = new Map<String, Interval>();
        Map<String, Interval> mKeyIntervalUser = new Map<String, Interval>();

        // To check which calendarId has an allDayEvent
        Set<Id> sCalendarIdNotAvailable = new Set<Id>();       
        
        for (CalendarTimeTableInterval calendarTTInterval : lCalendarTTInterval){  

            Id calendarId = calendarTTInterval.calendarTimeTable.CalendarSetting__r.CalendarId__c;
            String subtype = calendarTTInterval.calendarTimeTable.CalendarSetting__r.Subtype__c;

            mCalendarIdSubtype.put(calendarId, subtype);

            // If this resource is not available in this day, break           
            if (sCalendarIdNotAvailable.contains(calendarId)){
                break;
            }    

            // Create initial list of resource intervals
            List<Interval> lIntervResource = calendarTTInterval.lInterval;
            Boolean resourceAvailable = true;

            if (mCalendarIntervalsEvents.containsKey(calendarId)){                   
                for (Interval intervEvent : mCalendarIntervalsEvents.get(calendarId)){
                    // If the resource has an isAllDayEvent, this resource won't be available this day
                    if (intervEvent.isAllDay){
                        sCalendarIdNotAvailable.add(calendarId);
                        resourceAvailable = false;
                        break;
                    }

                    Time startEvent = intervEvent.startInterval;
                    Time endEvent = intervEvent.endInterval;     

                    for (Integer i=0; i < lIntervResource.size(); i++){

                        Time startResource = lIntervResource[i].startInterval;
                        Time endResource = lIntervResource[i].endInterval;

                        // Open start interval: resource is busy this day until end interval
                        if (startEvent == null){
                            if (endEvent >= endResource){
                                // Interval not available
                                lIntervResource.remove(i);
                                // Decrement i to dont stop loop when removing
                                i--;
                            }else if (endEvent > startResource){
                                // Readjust start interval
                                lIntervResource[i].startInterval = endEvent;
                                lIntervResource[i].uniqueKey = String.valueOf(lIntervResource[i].startInterval) + '-' + String.valueOf(lIntervResource[i].endInterval);
                            }
                        }
                        // Open end interval: resource is busy this day since start interval
                        else if (endEvent == null){
                            if (startEvent <= startResource){
                                // Interval not available
                                lIntervResource.remove(i);
                                // Decrement i to dont stop loop when removing
                                i--;
                            }else if (startEvent < endResource){
                                // Readjust end interval
                                lIntervResource[i].endInterval = startEvent;
                                lIntervResource[i].uniqueKey = String.valueOf(lIntervResource[i].startInterval) + '-' + String.valueOf(lIntervResource[i].endInterval);
                            }
                        }

                        // Normal cases, closed intervals
                        else if (startEvent <= startResource && endEvent >= endResource){
                            // Interval not available
                            lIntervResource.remove(i);
                            // Decrement i to dont stop loop when removing
                            i--;
                        }else if (startEvent <= startResource && endEvent > startResource && endEvent < endResource){
                            // Readjust start interval 
                            lIntervResource[i].startInterval = endEvent;
                            lIntervResource[i].uniqueKey = String.valueOf(lIntervResource[i].startInterval) + '-' + String.valueOf(lIntervResource[i].endInterval);
                        }else if (startEvent > startResource && endEvent >= endResource && startEvent < endResource){
                            // Readjust end interval
                            lIntervResource[i].endInterval = startEvent;
                            lIntervResource[i].uniqueKey = String.valueOf(lIntervResource[i].startInterval) + '-' + String.valueOf(lIntervResource[i].endInterval);
                        }else if (startEvent > startResource && endEvent < endResource){
                            // Create two new interval

                            // First interval replace the current position
                            Interval newInterv1 = new Interval(startResource, startEvent, lIntervResource[i].resourceType);
                            lIntervResource.set(i, newInterv1);

                            // Insert second interval next to first, and move the rest of elements 1 place
                            Interval newInterv2 = new Interval(endEvent, endResource, lIntervResource[i].resourceType);
                            i++; // skip the first new interval     

                            if (lIntervResource.size() == i){
                                // Final position, does not need to move elements
                                lIntervResource.add(newInterv2);
                            }else{
                                List<Interval> lIntervToMove = new List<Interval>();
                                lIntervToMove.add(newInterv2);
                                for (Integer j = i; j < lIntervResource.size(); j++){   
                                    lIntervToMove.add(lIntervResource[j]);    
                                }    
                                for (Integer j = i; j < lIntervResource.size(); j++){
                                    if (!lIntervToMove.isEmpty()){
                                        lIntervResource.set(j, lIntervToMove[0]);
                                        lIntervToMove.remove(0);
                                    }
                                }   
                                if (!lIntervToMove.isEmpty()){
                                    lIntervResource.add(lIntervToMove[0]);
                                    lIntervToMove.remove(0);
                                }    
                            }
                            
                        }
                    } // for Resource intervals
                } // for Event intervals
            }

            // Update map with new intervals
            if (resourceAvailable){
                for (Interval interv : lIntervResource){ 
                    Set<String> sCalendarId = new Set<String>();
                    if (mIntervalResources.containsKey(interv.uniqueKey)){
                        sCalendarId = mIntervalResources.get(interv.uniqueKey);
                    }
                    sCalendarId.add(calendarId);
                    mIntervalResources.put(interv.uniqueKey, sCalendarId);
                    if (interv.resourceType == 'User'){
                        mKeyIntervalUser.put(interv.uniqueKey, interv);
                    }else if (interv.resourceType == 'Resource'){   
                        mKeyIntervalResource.put(interv.uniqueKey, interv);
                    }/*else if (interv.resourceType == 'User/Resource'){
                        mKeyIntervalUser.put(interv.uniqueKey, interv);
                        mKeyIntervalResource.put(interv.uniqueKey, interv);
                    }*/
                }
            }

        } // for calendarTimeTableInterval

        ResultCrossedIntervals resultIntervals = new ResultCrossedIntervals();

        resultIntervals.mIntervalResources = mIntervalResources;
        resultIntervals.mCalendarIdSubtype = mCalendarIdSubtype;
        resultIntervals.mKeyIntervalResource = mKeyIntervalResource;
        resultIntervals.mKeyIntervalUser = mKeyIntervalUser;

        return resultIntervals;
    }

    /**
     * Create a response structure to front component
     * @param lIntervalResource     List of intervals of User or Resource       
     * @param mIntervalResources    Map containing the list of calendarIds related with each Interval
     * @param mCalendarIdInfo       Contains the resource type for each CalendarId
     * @param mCalendarIdSubtype    Map relating each CalendarId with its subtype    
     * @param dayDatetime           Current day in loop
     * @param resourceType          User or Resource         
     * @return Response structure with the intervals of each resource and user subtype 
     */
    private static List<IntervalResource> createResponseStructure (List<Interval> lIntervalResource, Map<String, Set<String>> mIntervalResources, 
                                                                    Map<Id, UserResourceWrapper> mCalendarIdInfo, Map<String, String> mCalendarIdSubtype,
                                                                    Datetime dayDatetime, String resourceType) {
        
        List<IntervalResource> lIntervResource = new List<IntervalResource>();

        for (Interval interv : lIntervalResource){ 

            List<ResourceDetail> lResourceDetail = new List<ResourceDetail>();

            if (mIntervalResources.containsKey(interv.uniqueKey)){
                for (Id calendarId : mIntervalResources.get(interv.uniqueKey)){
                    if (mCalendarIdInfo.containsKey(calendarId) && mCalendarIdInfo.get(calendarId).resourceType == resourceType){
                        ResourceDetail resDetail = new ResourceDetail();
                        resDetail.calendarId = calendarId;
                        resDetail.resourceName = mCalendarIdInfo.get(calendarId).resourceName;
                        lResourceDetail.add(resDetail);
                    }
                }
                Map <String, List<ResourceDetail>> mSubtypeResourceDetail = new Map <String, List<ResourceDetail>>();
                for (ResourceDetail resDetail : lResourceDetail){
                    if (mCalendarIdSubtype.containsKey(resDetail.calendarId)){
                        String subtype = mCalendarIdSubtype.get(resDetail.calendarId);
                        List<ResourceDetail> lResourceDetailM = new List<ResourceDetail>();
                        if (mSubtypeResourceDetail.containsKey(subtype)){
                            lResourceDetailM = mSubtypeResourceDetail.get(subtype);
                        }
                        lResourceDetailM.add(resDetail);
                        mSubtypeResourceDetail.put(subtype, lResourceDetailM);
                    }
                }

                Map<String, Map<String, List<ResourceDetail>>> mTypeSubtypeResourceDetail = new Map<String, Map<String, List<ResourceDetail>>>();
                mTypeSubtypeResourceDetail.put(resourceType, mSubtypeResourceDetail);

                IntervalDate intervDate = new IntervalDate();
                intervDate.min = DateTime.newInstanceGmt(dayDatetime.date(),interv.startInterval);
                intervDate.max = DateTime.newInstanceGmt(dayDatetime.date(),interv.endInterval);


                IntervalResource intervResource = new IntervalResource();
                intervResource.interval = intervDate;
                intervResource.mTypeSubtypeResourceDetail = mTypeSubtypeResourceDetail;

                lIntervResource.add(intervResource);    
            }
        }

        return lIntervResource;
    }

    /**
     * Check if a list of Intervals is overlaping
     * @param lIntervalResource     List of intervals to check
     * @param mIntervalResources    Map with the list of CalendarId for each interval
     * @return New list with unique intervals 
     */
    private static List<Interval> solveOverlap (List<Interval> lIntervalResource, Map<String, Set<String>> mIntervalResources){

        if(lIntervalResource.size() == 0 || lIntervalResource.size() == 1)
            return lIntervalResource;

        Interval first = lIntervalResource.get(0);
        Time startInterval = first.startInterval;
        Time endInterval = first.endInterval;
        String resourceType = first.resourceType;
        List<Interval> result = new List<Interval>();

        for (Integer i = 1; i < lIntervalResource.size(); i++) {
            Interval current = lIntervalResource.get(i);
            if (current.startInterval <= endInterval) {
                //end = Math.max(current.endInterval, end);
                endInterval = (current.endInterval > endInterval) ? current.endInterval : endInterval;

                // Update map key with new interval ranges
                Set<String> sCalendarId = new Set<String>(); 
                if (mIntervalResources.containsKey(current.uniqueKey))
                    sCalendarId = mIntervalResources.remove(current.uniqueKey);           
                String newUniqueKey = String.valueOf(startInterval) + '-' + String.valueOf(endInterval);
                if (mIntervalResources.containsKey(newUniqueKey)){
                    sCalendarId.addAll(mIntervalResources.get(newUniqueKey));
                }
                mIntervalResources.put(newUniqueKey, sCalendarId);    
            } else {
                result.add(new Interval(startInterval, endInterval, resourceType));
                startInterval = current.startInterval;
                endInterval = current.endInterval;
            }
        }

        result.add(new Interval(startInterval, endInterval, resourceType));
        return result;            
    }

    /**
     * Intersect 2 list of intervals, returning only the joint values
     * @param lIntervalResource     First list of intervals to compare
     * @param lIntervalUser         Second list of intervals to compare
     * @param mIntervalResources    Map with the list of CalendarId for each interval
     * @param request               Contains filter information about the user or resource types selected
     * @return New list with intersected intervals 
     */
    @Testvisible 
    private static List<Interval> intersectIntervals(List<Interval> lIntervalResource, List<Interval> lIntervalUser, Map<String, Set<String>> mIntervalResources, GetAvailabilityRequest request) {
        Integer i = 0, j = 0;
        Map<String, Interval> mIntersection = new Map<String, Interval>(); // Use a Map to avoid duplicates intervals

        while (i < lIntervalResource.size() && j < lIntervalUser.size()) {      
            // Max start interval
            Time startInterval = lIntervalResource.get(i).startInterval >= lIntervalUser.get(j).startInterval ?
                                    lIntervalResource.get(i).startInterval : lIntervalUser.get(j).startInterval;

            // Min end interval
            Time endInterval =  lIntervalResource.get(i).endInterval <= lIntervalUser.get(j).endInterval ?
                                    lIntervalResource.get(i).endInterval : lIntervalUser.get(j).endInterval;                         

            if (endInterval > startInterval) {
                Interval newInterval = new Interval(startInterval, endInterval, null);
                mIntersection.put(newInterval.uniqueKey, newInterval);

                // Update map key with new interval ranges
                Set<String> sCalendarId = new Set<String>(); 
                if (mIntervalResources.containsKey(lIntervalResource.get(i).uniqueKey))
                    sCalendarId.addAll(mIntervalResources.remove(lIntervalResource.get(i).uniqueKey));
                if (mIntervalResources.containsKey(lIntervalUser.get(j).uniqueKey))    
                    sCalendarId.addAll(mIntervalResources.remove(lIntervalUser.get(j).uniqueKey));
                if (mIntervalResources.containsKey(newInterval.uniqueKey))
                    sCalendarId.addAll(mIntervalResources.get(newInterval.uniqueKey));
                
                mIntervalResources.put(newInterval.uniqueKey, sCalendarId);
            }

            if (lIntervalResource.get(i).endInterval < lIntervalUser.get(j).endInterval) {
                i++;
            } else {
                j++;
            }
        }

        return mIntersection.values();
    }
 

    private static List<ResultItem> getResultItems ( List<TimeSlot> lTimes )  {

        List<ResultItem> lResult = new List<ResultItem>();

        String dayKey = '';

        ResultItem ri = new ResultItem();

        for(TimeSlot ti : lTimes) {

            // if day changes
            if(dayKey != ti.StartDateTime.format('dd-MM-yyyy')) {
                ri = new ResultItem();
                ri.Id = ti.Idx;
                ri.label = ti.StartDateTime.format('dd-MM-yyyy');
                ri.name = ti.StartDateTime.format('dd-MM-yyyy');
                ri.expanded = false;
                lResult.add(ri);
            } 
                
            ResultItem innerRi = new ResultItem();        
            innerRi.label = ti.StartDateTime.format('HH-mm') + ' - ' +  ti.EndDateTime.format('HH-mm');
            //innerRi.name = ti.StartDateTime.format('HH-mm');
            innerRi.name = ti.Idx;
            innerRi.expanded = false;
            ri.items.add(innerRi);
            
            dayKey = ti.StartDateTime.format('dd-MM-yyyy');

        }
        return lResult;
    } 

    /**
     * creates and event with all the input data. No dml is executed
     * @param  startDate  event start date (GMT)
     * @param  endDate    event end date (GMT)
     * @param  attendeeId lead/contact/person account Id, main attendee
     * @param  assignedTo SF user related to the event (owner)
     * @param  lResource  resource list (stored as event relations)
     * @return            event ready to be inserted
     */ 
    @auraEnabled
    public static CreateEventResponse createEvent (Datetime startDate, Datetime endDate, Id attendeeId, 
                                    Map<Object, Object> assignedTo, Map<Object, Object> lResource, Map<Object, Object> filterValues,
                                    Map<Object, Object> extraParams, String comments, String appointmentType ) {
        system.debug('EXTRAPARAMS222>> :'+extraParams);
        CreateEventResponse response = new CreateEventResponse();

        try {
            
            Event appointment = new Event();

            // query to users with calendar Id info
            Set<Id> sCalendarId = new Set<Id>();
            for(Object calendarId : assignedTo.values()) {
                sCalendarId.add((Id)calendarId);
            }
            for(Object resourceId : lResource.values()) {
                sCalendarId.add((Id)resourceId);
            }
            List<Calendar> lCalendar = [SELECT Id, UserId FROM Calendar WHERE Id IN : sCalendarId ];
            Map<Id, Id> mCalendarUser = new Map<Id, Id>();
            for(Calendar cal : lCalendar) {
                mCalendarUser.put(cal.Id, cal.UserId);
            }

            // get contact id if person account is passed
            if(attendeeId.getSObjectType().getDescribe().getName() == 'Account' && Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount')) {
                String queryAcc = 'SELECT Id, PersonContactId FROM Account WHERE Id = :attendeeId LIMIT 1';
                List<Account> lAcc = Database.query(queryAcc);
                attendeeId = (Id)lAcc[0].get('PersonContactId');
            } 

            // ------------------------- custom event creation ------------------------------
            Type t = Type.forName('SchExtendedFeaturesImplementation');
            if (t != null && !Test.isRunningTest()){
                SchExtendedFeatures extendedFeatures = (SchExtendedFeatures)t.newInstance();
                
                Map<Object, Object> mParams = new Map<Object, Object>();
                mParams.put('assignedTo', assignedTo);
                mParams.put('lResource', lResource);
                mParams.put('filterValues', filterValues);
                mParams.put('startDate', startDate);
                mParams.put('endDate', endDate);
                mParams.put('attendeeId', attendeeId);
                mParams.put('comments', comments);
                mParams.put('extraParams', extraParams);
                mParams.put('appointmentType', appointmentType);
                

                appointment = extendedFeatures.setEventParams(appointment, mParams, mCalendarUser);
            
            // ------------------------- standard event creation -----------------------------
            } else {

                 List<EventRelation> lRelation = new List<EventRelation>();

                appointment.StartDatetime = startDate;
                appointment.EndDateTime = endDate;
                appointment.Subject = 'Cita';
                appointment.WhoId = attendeeId;
                appointment.Description = comments;
                appointment.Estado__c = 'Pendiente';
                appointment.TipoCita__c = appointmentType;

                // users
				List<Object> lAttendeeId = new List<Object>();
                lAttendeeId = assignedTo.values();
                Id mainAttendeeId = (Id) lAttendeeId.remove(0);

                appointment.OwnerId = mCalendarUser.get(mainAttendeeId);

                // if more users are present create relations
                for(Object calendarId : lAttendeeId) {

                    EventRelation rel = new EventRelation();   
                    rel.RelationId = mCalendarUser.get((Id)calendarId);
                    lRelation.add(rel);
                }

                // resources
                for(Object resourceId : lResource.values()) {
                    EventRelation rel = new EventRelation();
                    rel.RelationId = (Id)resourceId;
                    rel.Status = 'Accepted';
                    lRelation.add(rel);
                }

                insert appointment;
                
                for(EventRelation rel : lRelation) {
                    rel.EventId = appointment.Id;
                }
                
                insert lRelation;

            }


            response.appointment = appointment;


        } catch (Exception e) {
            response.status = false;
            response.errorMsg = e.getMessage() + e.getStackTraceString();
            System.debug('ERROR: ' + response.errorMsg);
            System.debug(e.getStackTraceString());
        }

       

        return response;
    }


    /**
     * Updates an event created
     * @param  eventId  The Event Id to update
     * @return event updated
     */ 
    @auraEnabled
    public static CreateEventResponse updateEvent (Id eventId, Id attendeeId, Map<Object, Object> extraParams, String comments) {
        system.debug('EXTRAPARAMS>>'+extraParams);
        CreateEventResponse response = new CreateEventResponse();

        Event appointment = new Event(Id = eventId);

        try {

            // get contact id if person account is passed
            if(attendeeId.getSObjectType().getDescribe().getName() == 'Account' && Schema.sObjectType.Account.fields.getMap().containsKey('isPersonAccount')) {
                String queryAcc = 'SELECT Id, PersonContactId FROM Account WHERE Id = :attendeeId LIMIT 1';
                List<Account> lAcc = Database.query(queryAcc);
                attendeeId = (Id)lAcc[0].get('PersonContactId');
            } 

            // ------------------------- custom event update ------------------------------
            Type t = Type.forName('SchExtendedFeaturesImplementation');
            if (t != null && !Test.isRunningTest()){
                SchExtendedFeatures extendedFeatures = (SchExtendedFeatures)t.newInstance();
                
                Map<Object, Object> mParams = new Map<Object, Object>();
                mParams.put('comments', comments);
                mParams.put('attendeeId', attendeeId);
                mParams.put('extraParams', extraParams);

                appointment = extendedFeatures.setEventParams(appointment, mParams, null);
            
            // ------------------------- standard event update -----------------------------
            }else{
                // TODO: what fields are required to update?
                appointment.OwnerId = UserInfo.getUserId();
                update appointment;
            }


            response.appointment = appointment;

        }catch (Exception e){
            response.status = false;
            response.errorMsg = e.getMessage() + e.getStackTraceString();
            System.debug(response.errorMsg);
            System.debug(e.getStackTraceString());
        }   
		
        return response;

    } 

    /**
     * Returns the converted Account given an specific Lead Id
     * @param  attendeeId The if of the converted lead
     * @return ResultGetParams returns an object containing useful data including the Converted Account Id
     */ 
    @AuraEnabled
    public static ResultGetParams getConvertedLead(Id attendeeId){
        ResultGetParams getParamsResult = new ResultGetParams();
        Lead convertedLead =[select ConvertedAccountId from Lead where Id = :attendeeId limit 1 ];
        
        try{
            Type t = Type.forName('SchExtendedFeaturesImplementation');
            if (t != null){
                SchExtendedFeatures extendedFeatures = (SchExtendedFeatures)t.newInstance();
                Map<String, Object> mParams = extendedFeatures.setInitParams(convertedLead.ConvertedAccountId);
                // We set the Account id param as a entry of the map
                mParams.put('ConvertedAccount', convertedLead.ConvertedAccountId);
                
                getParamsResult.mParams = mParams;
                getParamsResult.status = true;
            }
        }catch(Exception e){
            getParamsResult.status = false;
            getParamsResult.errorMsg = e.getMessage();
        }

        return getParamsResult;
    }

    /**
     * getParamsFromExtendedFeatures description
     * @param  attendeeId attendeeId description
     * @return            return description
     */ 
    @AuraEnabled
    public static ResultGetParams getParamsFromExtendedFeatures(Id attendeeId){

        ResultGetParams getParamsResult = new ResultGetParams();

        try{
            Type t = Type.forName('SchExtendedFeaturesImplementation');
            if (t != null){
                SchExtendedFeatures extendedFeatures = (SchExtendedFeatures)t.newInstance();
                Map<String, Object> mParams = extendedFeatures.setInitParams(attendeeId);

                getParamsResult.mParams = mParams;
            }
        }catch(Exception e){
            getParamsResult.status = false;
            getParamsResult.errorMsg = e.getMessage();
        }

        return getParamsResult;
    }

    public class ResultGetParams {
        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String errorMsg = '';

        @AuraEnabled public Map<String, Object> mParams = new Map<String, Object>();
    }

    public class CreateEventResponse {

        @auraEnabled public Boolean status = true;
        @auraEnabled public String errorMsg = '';

        @auraEnabled public Event appointment;
    }

    public class GetAvailabilityRequest {

        // customer id 
        @auraEnabled public String attendeeId   { get; set; }
        
        
        // event dates and duration
        @auraEnabled public Datetime searchFromDate  { get; set; }
        @auraEnabled public Datetime searchToDate  { get; set; }
        @auraEnabled public Datetime  startHour  { get; set; }
        @auraEnabled public Datetime  endHour  { get; set; }
        @auraEnabled public String duration { get; set; }

        // required resources
        @auraEnabled public List<String> userSelected  { get; set; }
        @auraEnabled public List<String> resourceSelected  { get; set; }

        // filters in resources
        @auraEnabled public Map<String, Object> filterValues { get; set; }

        @auraEnabled public Map<String, Object> extraParams { get; set; }

        // search by events instead of calendar setting
        @auraEnabled public Boolean searchByEvents { get; set; }
    }   

    public class GetAvailabilityResponse {

        @auraEnabled public Boolean status = true;
        @auraEnabled public String errorMsg = '';

        @auraEnabled public List<TimeSlot> lTimeSlot;
        @auraEnabled public List<ResultItem> lResult;
        @auraEnabled public List<ResourceSlot> lResultResource;

        public GetAvailabilityResponse() {
            this.lTimeSlot = new List<TimeSlot>();
            this.lResult = new List<ResultItem>();
            this.lResultResource = new List<ResourceSlot>();
        }

    }


    public class GetResourceInfoResult {

        public Map<String, ResourceInfo> mDateResource;
        //public Set<Id> sCalendarId;
        public Map<Id, UserResourceWrapper> mCalendarIdInfo;
    }

    public class UserResourceWrapper {
        @auraEnabled public String resourceName;
        @auraEnabled public String resourceType;
        @auraEnabled public Boolean isActive;
    }

    public class ResourceInfo {

        @auraEnabled public Datetime day;
        @auraEnabled public Map<String, List<CalendarTimeTableInterval>> mResource;
        @auraEnabled public List<CalendarTimeTableInterval> lCalendarTTInterval;

        public ResourceInfo(Datetime day) {
            this.mResource = new Map<String, List<CalendarTimeTableInterval>>();
            this.lCalendarTTInterval = new List<CalendarTimeTableInterval>();
            this.day = day;
        }
    }

    public class CalendarTimeTableInterval {
        public CalendarTimeTable__c calendarTimeTable;
        public List<Interval> lInterval;
        public String dayOfWeek;

        public CalendarTimeTableInterval(CalendarTimeTable__c calendarTimeTable, Datetime day, String resourceType, GetAvailabilityRequest request) {
            this.calendarTimeTable = calendarTimeTable;
            this.lInterval = new List<Interval>();
            this.dayOfWeek = day.formatGmt('EEEE');

            TimeZone tz = TimeZone.getTimeZone(calendarTimeTable.CalendarSetting__r.Timezone__c);
            // get current resource offset
            Integer offSet = tz.getOffset(DateTime.newInstanceGmt( day.year() , day.monthGmt(), day.dayGmt() , 0, 0, 0));

            // Morning TimeTable
            Time morningFrom = (Time) calendarTimeTable.getSobject('TimeTable__r').get(this.dayOfWeek + 'MorningFrom__c');
            Time morningTo = (Time) calendarTimeTable.getSobject('TimeTable__r').get(this.dayOfWeek + 'MorningTo__c');
             // Afternoon TimeTable
            Time afterFrom = (Time) calendarTimeTable.getSobject('TimeTable__r').get(this.dayOfWeek + 'AfterFrom__c');
            Time afterTo = (Time) calendarTimeTable.getSobject('TimeTable__r').get(this.dayOfWeek + 'AfterTo__c');
            // apply timezone offset
            morningFrom = (morningFrom != null) ? morningFrom.addSeconds(-offSet/1000) : null;
            morningTo = (morningTo != null) ? morningTo.addSeconds(-offSet/1000) : null;
            afterFrom = (afterFrom != null) ? afterFrom.addSeconds(-offSet/1000) : null;
            afterTo = (afterTo != null) ? afterTo.addSeconds(-offSet/1000) : null;
     
            if(request.startHour != null) {
                
                Datetime fromDate = request.startHour;
                if (day.date() == Date.today()){
                    fromDate = (fromDate.timeGmt() < System.now().timeGmt()) ? System.now() : fromDate;
                }
                
                Time startHour = Time.newInstance(fromDate.hourGmt(), fromDate.minuteGmt(), 0, 0);
                if (morningFrom != null && startHour > morningFrom)
                    morningFrom = startHour;
                if (afterFrom != null && startHour > afterFrom)    
                    afterFrom = startHour;
            }
            if(request.endHour != null) {
                Time endHour = Time.newInstance(request.endHour.hourGMT(), request.endHour.minuteGMT(), 0, 0);
                if (morningTo != null && endHour < morningTo)
                    morningTo = endHour;
                if (afterTo != null && endHour < afterTo)    
                    afterTo = endHour;
            }


            if (morningFrom != null && morningTo != null){   
                if (day.Date() == Date.today()){
                    Time timeNow = getRoundedCurrentTime();
                    morningFrom = (morningFrom < timeNow) ? timeNow : morningFrom;
                }
                if (morningTo > morningFrom){
                    Interval morningInterval = new Interval(morningFrom, morningTo, resourceType);
                    lInterval.add(morningInterval);
                }
            }
            
            if (afterFrom != null && afterTo != null){
                if (day.Date() == Date.today()){
                    Time timeNow = getRoundedCurrentTime();
                    afterFrom = (afterFrom < timeNow) ? timeNow : afterFrom;
                }
                if (afterTo > afterFrom){
                    Interval afterInterval = new Interval(afterFrom, afterTo, resourceType);
                    lInterval.add(afterInterval);
                }
            }
        }
        // A partir de la hora actual, redondea hacia arriba en intervalos de 15 minutos
        private Time getRoundedCurrentTime(){
            Time timeNow = Time.newInstance(System.now().hourGmt(), System.now().minuteGmt(), 0, 0);
            Time timeRounded = timeNow;
            if (timeNow.minute() > 1 && timeNow.minute() < 15){
                timeRounded = Time.newInstance(timeNow.hour(), 15, 0, 0);
            }else if (timeNow.minute() > 15 && timeNow.minute() < 30){
                timeRounded = Time.newInstance(timeNow.hour(), 30, 0, 0);
            }else if(timeNow.minute() > 30 && timeNow.minute() < 45){
                timeRounded = Time.newInstance(timeNow.hour(), 45, 0, 0);
            }else if(timeNow.minute() > 45 && timeNow.minute() < 59){
                timeRounded = Time.newInstance(timeNow.hour()+1, 0, 0, 0);
            }
            return timeRounded;
        }
    }


    /**
     * Wrapper class wicht contains an availability time slot. Represent a displayed calendar entry.
     */
    public class TimeSlot{

        @auraEnabled public String Id;
        @auraEnabled public String Idx;
        @auraEnabled public Datetime EndDateTime;
        @auraEnabled public Datetime StartDateTime;
        @auraEnabled public String Subject;
        @auraEnabled public Boolean IsAllDayEvent;
    }

    public class ResourceSlot {
        @auraEnabled public String Id;
        //@auraEnabled public List<String> lCalendarId;

        @auraEnabled public List<IntervalResource> lIntervalResource;
    }

    public class ResponseResourceTimeSlot {
        @auraEnabled public List<TimeSlot> lTimeSlot;
        @auraEnabled public List<ResourceSlot> lResourceSlot;
    }

    public class IntervalResource {
        @auraEnabled public IntervalDate interval;
        @auraEnabled public Map<String, Map<String, List<ResourceDetail>>> mTypeSubtypeResourceDetail;
    }

    public class IntervalDate {
        @auraEnabled public DateTime min;
        @auraEnabled public DateTime max;
    }

    public class ResourceDetail{
        @auraEnabled public String calendarId;
        @auraEnabled public String resourceName;
    }

    public class ResultItem {

        @auraEnabled public String Id;
        @auraEnabled public String label;
        @auraEnabled public String name;
        @auraEnabled public Boolean expanded;
        @auraEnabled public List<ResultItem> items;

        public ResultItem() {
            this.items = new List<ResultItem>();
        }
    }

    public class ResultCrossedIntervals {
        Map<String, Set<String>> mIntervalResources;
        Map<String, String> mCalendarIdSubtype;
        Map<String, Interval> mKeyIntervalResource;
        Map<String, Interval> mKeyIntervalUser;

        public ResultCrossedIntervals(){
            mIntervalResources = new Map<String, Set<String>>();
            mCalendarIdSubtype = new Map<String, String>();
            mKeyIntervalResource = new Map<String, Interval>();
            mKeyIntervalUser = new Map<String, Interval>();
        }

    }

    public class Interval implements Comparable{
        public String uniqueKey;
        public Time startInterval;
        public Time endInterval;
        public String resourceType; // User or Resource
        public Boolean isAllDay; // For the interval Events
        public Boolean available;

        public Interval (Time startInterval, Time endInterval, String resourceType){
            this.startInterval = startInterval;
            this.endInterval = endInterval;
            this.resourceType = resourceType;
            this.isAllDay = false;
            this.available = true;
            uniqueKey = String.valueOf(this.startInterval) + '-' + String.valueOf(this.endInterval);
        }

        public Integer compareTo(Object compareTo) {
            Interval compareToInterval = (Interval)compareTo;
            if (startInterval == compareToInterval.startInterval){
                if (endInterval == compareToInterval.endInterval){
                    return 0;
                }else if (endInterval > compareToInterval.endInterval){
                    return 1;
                }
            } else if (startInterval > compareToInterval.startInterval){
                return 1;
            }
            return -1;
        }
    }


}