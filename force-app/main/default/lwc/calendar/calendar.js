import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import MONDAY_SHORT_LABEL from '@salesforce/label/c.Monday_Short';
import TUESDAY_SHORT_LABEL from '@salesforce/label/c.Tuesday_Short';
import THURSDAY_SHORT_LABEL from '@salesforce/label/c.Thursday_Short';
import WEDNESDAY_SHORT_LABEL from '@salesforce/label/c.Wednesday_Short';
import FRIDAY_SHORT_LABEL from '@salesforce/label/c.Friday_Short';
import SUTURDAY_SHORT_LABEL from '@salesforce/label/c.Saturday_Short';
import SUNDAY_SHORT_LABEL from '@salesforce/label/c.Sunday_Short';

import MORE_LABEL from '@salesforce/label/c.More_Label';

export default class Calendar extends NavigationMixin(LightningElement) {
    today = new Date();
    @api _selectedDate;
    @api _userTimeZone;
    @api _timeZoneOffset;
    @api needToRedirect = false;

    @api moreLabel = "More";
    
    @track _viewStartDate;
    @track _viewEndDate;

    _startDate;
    _endDate;

    isMonth = true;
    isWeek = false;
    isDay = false;
    @api _viewType = "month";

    @track calendarWeeks;

    hoursTime;
    hours;

    @track events;
    @track eventsMap;
    @track currentEvent;
    @track dayWrapperEvents = {};

    mondayLabel = MONDAY_SHORT_LABEL;
    tuesdayLabel = TUESDAY_SHORT_LABEL;
    thursdayLabel = THURSDAY_SHORT_LABEL;
    wednesdayLabel = WEDNESDAY_SHORT_LABEL;
    fridayLabel = FRIDAY_SHORT_LABEL;
    suturdayLabel = SUTURDAY_SHORT_LABEL;
    sundayLabel = SUNDAY_SHORT_LABEL;
    
    weekDays = {"0" : 6, "1": 0, "2" : 1, "3" : 2, "4" : 3, "5" : 4, "6" : 5};
    
    @api expanded = false;

    connectedCallback() {
        this.hours = [];
        this.hoursTime = [];
        this.moreLabel = MORE_LABEL;
        for (let j = 0; j <= 23; j++) {
            this.hoursTime.push(new Date().setHours(j));
            this.hours.push(j);
        }
    }
    
    handleExpandExtra() {
        this.expanded = !this.expanded;
    }

    collectEvents() {
        let tzOffset = this._timeZoneOffset;
        var tempEventMap = {};
        var month = new Date(this._selectedDate).getUTCMonth();
        var year = new Date(this._selectedDate).getUTCFullYear();
        let viewStartDate = new Date(Date.UTC(year, month, 1));
        let viewEndDate = new Date(Date.UTC(year, month, 32 - new Date(Date.UTC(year, month, 32)).getDate()));
        viewEndDate.setUTCMilliseconds(viewEndDate.getUTCMilliseconds() + 86399999);
        this.events.forEach(function(element) {
            let startDate =  new Date(Date.parse(element.StartDateTime));
            let endDate =  new Date(Date.parse(element.EndDateTime));
            let startDay;
            let endDay;
            
            startDate.setUTCMilliseconds(startDate.getUTCMilliseconds() + parseInt(tzOffset, 10));
            endDate.setUTCMilliseconds(endDate.getUTCMilliseconds() + parseInt(tzOffset, 10));
            if (startDate < viewStartDate) {
                startDay = 1;
            } else if (startDate >= viewStartDate && startDate <= viewEndDate) {
                startDay =  startDate.getUTCDate();
            }
            if (endDate > viewEndDate) {
                endDay = 32 - new Date(Date.UTC(year, month, 32)).getUTCDate();
            } else if (endDate >= viewStartDate && endDate <= viewEndDate) {
                endDay =  endDate.getUTCDate();
            }
            
            for (let i = startDay; i <= endDay; i++) {
                let eventList;
                
                if (tempEventMap[i] === undefined) {
                    tempEventMap[i] = [];
                }
                eventList = tempEventMap[i];
                let newEvent = {
                    element: element
                }
                if (!element.IsAllDayEvent && i === startDay) {
                    newEvent.startTime = element.StartDateTime
                }
                if (element.IsAllDayEvent) {
                    eventList.unshift(newEvent);
                } else {
                    eventList.push(newEvent);
                }
                tempEventMap[i] = eventList;
            }
        });
        this.eventsMap = tempEventMap;
    }

    collectEventsWithBounds(viewStart, viewEnd) {
        let tzOffset = this._timeZoneOffset;
        var tempEventMap = {};
        let viewStartDateBase = new Date(viewStart);
        let viewEndDateBase = new Date(viewEnd);
        viewEndDateBase.setUTCMilliseconds(viewEndDateBase.getUTCMilliseconds() + 86399999);
        while (viewStartDateBase <= viewEndDateBase) {
            let viewStartDate = new Date(viewStartDateBase.getTime());
            let viewEndDate = new Date(viewStartDateBase.getTime());
            viewEndDate.setUTCMilliseconds(viewEndDate.getUTCMilliseconds() + 86399999);

            this.events.forEach(function(element) {
                let startDate =  new Date(Date.parse(element.StartDateTime));
                let endDate =  new Date(Date.parse(element.EndDateTime));
                let tempStartDate;
                let tempEndDate;

                if (!element.IsAllDayEvent) {
                    startDate.setUTCMilliseconds(startDate.getUTCMilliseconds() + parseInt(tzOffset, 10));
                    endDate.setUTCMilliseconds(endDate.getUTCMilliseconds() + parseInt(tzOffset, 10));
                }
                if (startDate < viewStartDate) {
                    tempStartDate = new Date(viewStartDate.getTime());
                } else if (startDate >= viewStartDate && startDate <= viewEndDate) {
                    tempStartDate =  new Date(startDate.getTime());
                }
                if (endDate > viewEndDate) {
                    tempEndDate = new Date(viewEndDate.getTime());
                } else if ((element.IsAllDayEvent && endDate >= viewStartDate && endDate <= viewEndDate) || (!element.IsAllDayEvent && endDate > viewStartDate && endDate <= viewEndDate)) {
                    tempEndDate =  new Date(endDate.getTime());
                }
                while (tempStartDate <= tempEndDate) {
                    let dateUtcWOTime = new Date(Date.UTC(tempStartDate.getUTCFullYear(), tempStartDate.getUTCMonth(), tempStartDate.getUTCDate()));
                    let eventList;
                    if (tempEventMap[dateUtcWOTime.getTime()] === undefined) {
                        tempEventMap[dateUtcWOTime.getTime()] = [];
                    }
                    eventList = tempEventMap[dateUtcWOTime.getTime()];

                    eventList.push(element);
                    tempEventMap[dateUtcWOTime.getTime()] = eventList;

                    tempStartDate.setUTCDate(tempStartDate.getUTCDate() + 1);
                }

            });
            viewStartDateBase.setUTCMilliseconds(viewStartDateBase.getUTCMilliseconds() + 86400000);
        }
        this.eventsMap = tempEventMap;
    }

    collectEventByHour(events, currentDay) {
        let allDayEvents = [];
        let tempEventMap = {};
        let tzOffset = this._timeZoneOffset;

        let month = new Date(currentDay).getUTCMonth();
        let year = new Date(currentDay).getUTCFullYear();
        let day = new Date(currentDay).getUTCDate();
        let viewStartDate = new Date(Date.UTC(year, month, day, 0, 0, 0, 0));
        let viewEndDate = new Date(Date.UTC(year, month, day, 23, 59, 59, 999));
        
        events.forEach(function(element) {
            let startDateTime =  new Date(Date.parse(element.StartDateTime));
            let endDateTime =  new Date(Date.parse(element.EndDateTime));
            if (element.IsAllDayEvent || endDateTime - startDateTime >= 86400000) {
                allDayEvents.push({
                    element: element
                });
            } else {
                startDateTime.setUTCMilliseconds(startDateTime.getUTCMilliseconds() + parseInt(tzOffset, 10));
                endDateTime.setUTCMilliseconds(endDateTime.getUTCMilliseconds() + parseInt(tzOffset, 10));
                
                let startHour;
                let startDate;
                let endDate;
                if (startDateTime < viewStartDate) {
                    startHour = 0;
                    startDate = new Date(viewStartDate.getTime());
                } else if (startDateTime >= viewStartDate && startDateTime <= viewEndDate) {
                    startHour = startDateTime.getUTCHours();
                    startDate = new Date(Date.UTC(startDateTime.getUTCFullYear(), startDateTime.getUTCMonth(), startDateTime.getUTCDate(), startDateTime.getUTCHours(), 0, 0, 0));
                }
                
                if (endDateTime > viewEndDate) {
                    endDate = new Date(viewEndDate.getTime());
                } else if (endDateTime >= viewStartDate && endDateTime <= viewEndDate) {
                    endDate = new Date(Date.UTC(endDateTime.getUTCFullYear(), endDateTime.getUTCMonth(), endDateTime.getUTCDate(), endDateTime.getUTCHours(), 0, 0, 0));
                    
                }
                
                let i = startHour;
                if (endDate !== undefined) {
                    endDate.setUTCMilliseconds(endDate.getUTCMilliseconds() - 1);
                }
                
                
                while (startDate <= endDate) {
                    let eventList;
                    
                    if (tempEventMap[i] === undefined) {
                        tempEventMap[i] = [];
                    }
                    eventList = tempEventMap[i];
                    let newEvent = {
                        element : element,
                        startHour : false,
                        startTime : element.StartDateTime,
                        endTime : element.EndDateTime
                    }
                    if (i === startHour) {
                        newEvent.startHour = true;
                    }
                    eventList.push(newEvent);
                    tempEventMap[i] = eventList;
                    startDate.setUTCHours(startDate.getUTCHours() + 1);
                    i++
                }
            }
            
        });
        let dayEventsRecord = {
            date : viewStartDate,
            eventsByHour : tempEventMap,
            allDayEvents : allDayEvents
        };
        return dayEventsRecord;
    }
    
    fillDayByEvents(events, eventsByHour) {
        
        let dayEvents = [];
        events.forEach(function(element) {
            let hourMap = {};

            for (let i = 0; i < 24; i++) {
                let hourRecord;
                let currentHourEvents = eventsByHour[i];
                
                if (currentHourEvents !== undefined) {
                    for (let j = 0; j < currentHourEvents.length; j++) {
                        if (currentHourEvents[j].element.Id === element.Id) {
                            hourRecord = {
                                element : element,
                                isEmpty : false,
                                hour : i
                            };
                            if (currentHourEvents[j].startHour) {
                                hourRecord.startHour = true;
                            } else {
                                hourRecord.startHour = false;
                            }
                            break;
                        } 
                    }
                }

                if (hourRecord === undefined) {
                    hourRecord = {
                        element : element,
                        isEmpty : true,
                        hour : i
                    };
                }
                hourMap[i] = hourRecord;
            }
            dayEvents.push({
                element : element,
                hourMap : hourMap
            });
        });
        return dayEvents;
    }

    getOnlyHourlyEvents(events) {
        let hourlyEvents = [];
        events.forEach(function(element) {
            let startDateTime =  new Date(Date.parse(element.StartDateTime));
            let endDateTime =  new Date(Date.parse(element.EndDateTime));
            if (!element.IsAllDayEvent && endDateTime - startDateTime < 86400000) {
                hourlyEvents.push(element);
            }
        });
        return hourlyEvents;
    }
    
    getEventsFromMapByHour(dayEvents, hour) {
        let events = [];
        if (dayEvents !== undefined) {
            dayEvents.forEach(function(element) {
                let hourEvent = element.hourMap[hour];
                if (hourEvent !== undefined) {
                    events.push(hourEvent);
                }
            });
        }

        return events;
    }
    
    collectHourEventsMatrix(dayEvents) {
        let hourEventsMatrix = [];
        let maxEvents = 0;
        for (let i = 0; i <= 23; i++) {
            let eventsList = this.getEventsFromMapByHour(dayEvents, i);
            if (eventsList !== undefined) {
                if (eventsList.length > maxEvents) {
                    maxEvents = eventsList.length;
                }
                hourEventsMatrix[i] = eventsList;
            }
            
        }
        for (let j = 1; j < maxEvents; j++) {
            let startHour;
            let indexTosplice;
            for (let i = 0; i <= 23; i++) {
                if (hourEventsMatrix[i] !== undefined && !hourEventsMatrix[i][j].isEmpty) {
                    if (startHour === undefined) {
                        startHour = i;
                        break;
                    }
                }
            }
            for (let k = j; k > 0; k--) {
                if (hourEventsMatrix[startHour] !== undefined && hourEventsMatrix[startHour][j - k] !== undefined && hourEventsMatrix[startHour][j - k].isEmpty) {
                    for (let i = startHour; i <= 23; i++) {
                        if (hourEventsMatrix[i] !== undefined && hourEventsMatrix[i][j] !== undefined && !hourEventsMatrix[i][j].isEmpty) {
                            hourEventsMatrix[i][j - k] = hourEventsMatrix[i][j];
                            indexTosplice = j;
                        }
                    }
                    for (let i = 0; i <= 23; i++) {
                        if (hourEventsMatrix[i] !== undefined) {
                            hourEventsMatrix[i].splice(indexTosplice, 1);
                        }
                    }
                    maxEvents--;
                    j--;
                    break;
                }
            }
        }
        return hourEventsMatrix;

    }

    fillWeekByAllDayEvents(eventsMap, viewStartJSON, viewEndJSON) {
        let eventsByDay = this.getAllDayEventsByDay(eventsMap, viewStartJSON, viewEndJSON);
        let events = this.getAllDayEvents(eventsByDay, viewStartJSON, viewEndJSON);
        let weekEvents = [];
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let viewEnd = new Date(JSON.parse(viewEndJSON));
        events.forEach(function(element) {
            let dayMap = {};

            while (viewStart <= viewEnd) {
                let dayRecord;
                let currentDayEvents = eventsByDay[viewStart.getTime()];
                if (currentDayEvents !== undefined) {
                    for (let j = 0; j < currentDayEvents.length; j++) {
                        if (currentDayEvents[j].element.Id === element.element.Id) {
                            dayRecord = {
                                element : element.element,
                                isEmpty : false,
                                day : viewStart
                            };
                            if (currentDayEvents[j].startDay) {
                                dayRecord.startDay = true;
                            } else {
                                dayRecord.startDay = false;
                            }
                            break;
                        } 
                    }
                }

                if (dayRecord === undefined) {
                    dayRecord = {
                        element : element.element,
                        isEmpty : true,
                        day : viewStart
                    };
                }
                dayMap[viewStart.getTime()] = dayRecord;
                viewStart.setUTCDate(viewStart.getUTCDate() + 1);
            }
            viewStart = new Date(JSON.parse(viewStartJSON));
            weekEvents.push({
                element : element.element,
                dayMap : dayMap
            });
        });
        
        return weekEvents;
    }

    getAllDayEventsByDay(eventsMap, viewStartJSON, viewEndJSON) {
        let tzOffset = this._timeZoneOffset;
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let viewEnd = new Date(JSON.parse(viewEndJSON));
        
        let weekEventsMap = {};
        while (viewStart <= viewEnd) {
            let dayEvents = eventsMap[viewStart.getTime()];
            let allDayEvents = [];
            if (dayEvents !== undefined) {
                dayEvents.forEach(function(element) {
                    let startDateTime =  new Date(Date.parse(element.StartDateTime));
                    let endDateTime =  new Date(Date.parse(element.EndDateTime));
                    if (element.IsAllDayEvent || endDateTime - startDateTime >= 86400000) {
                        let allDayEvent = {
                            element: element
                        };
                        if (!element.IsAllDayEvent) {
                            startDateTime.setUTCMilliseconds(startDateTime.getUTCMilliseconds() + parseInt(tzOffset, 10));
                        }
                        if (startDateTime.getTime() >= viewStart.getTime() && startDateTime.getTime() <= viewStart.getTime() + 86399999) {
                            allDayEvent.startDay = true;
                        } else {
                            allDayEvent.startDay = false;

                        }

                        allDayEvents.push(allDayEvent);
                    }
                });
            }
            weekEventsMap[viewStart.getTime()] = allDayEvents;
            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
        }
        return weekEventsMap;
    }

    getAllDayEvents(eventsMap, viewStartJSON, viewEndJSON) {
        
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let viewEnd = new Date(JSON.parse(viewEndJSON));
        let weekEvents = [];
        let eventsIds = [];
        while (viewStart <= viewEnd) {
            let dayEvents = eventsMap[viewStart.getTime()];
            dayEvents.forEach(function(element) {
                if (!eventsIds.includes(element.element.Id)) {
                    weekEvents.push(element);
                    eventsIds.push(element.element.Id);
                }
            });
            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
        }
        return weekEvents;
    }

    getEventsFromMapByDay(events, day) {
        let allEvents = [];
        if (events !== undefined) {
            events.forEach(function(element) {
                let dayEvent = element.dayMap[day];
                if (dayEvent !== undefined) {
                    allEvents.push(dayEvent);
                }
            });
        }
        
        return allEvents;
    }

    collectAllDayEventsMatrix(weekEvents, viewStartJSON) {
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let dayEventsMatrix = [];
        let maxEvents = 0;
        for (let i = 0; i < 7; i++) {
            let eventsList = this.getEventsFromMapByDay(weekEvents, viewStart.getTime());
            if (eventsList !== undefined) {
                if (eventsList.length > maxEvents) {
                    maxEvents = eventsList.length;
                }
                dayEventsMatrix[i] = eventsList;
            }

            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
            
        }
        viewStart = new Date(JSON.parse(viewStartJSON));

        for (let j = 1; j < maxEvents; j++) {
            let startDay;
            let indexToSplice;
            for (let i = 0; i < 7; i++) {
                if (dayEventsMatrix[i] !== undefined && !dayEventsMatrix[i][j].isEmpty) {
                    if (startDay === undefined) {
                        startDay = i;
                        break;
                    }
                }
            }
            
            for (let k = j; k > 0; k--) {
                if (dayEventsMatrix[startDay] !== undefined && dayEventsMatrix[startDay][j - k] && dayEventsMatrix[startDay][j - k].isEmpty) {
                    for (let i = startDay; i < 7; i++) {
                        if (dayEventsMatrix[i] !== undefined && dayEventsMatrix[i][j] && !dayEventsMatrix[i][j].isEmpty) {
                            dayEventsMatrix[i][j - k] = dayEventsMatrix[i][j];
                            indexToSplice = j;
                        }
                    }
                    for (let i = 0; i < 7; i++) {
                        if (dayEventsMatrix[i] !== undefined) {
                            dayEventsMatrix[i].splice(indexToSplice, 1);
                        }
                    }
                    maxEvents--;
                    j--;
                    break;
                }
            }
        }
        return dayEventsMatrix;
    }

    fillMonthByEvents(eventsMap, viewStartJSON, viewEndJSON) {
        let eventsByDay = this.getEventsByDay(eventsMap, viewStartJSON, viewEndJSON);
        let events = this.getEvents(eventsByDay, viewStartJSON, viewEndJSON);
        let monthEvents = [];
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let viewEnd = new Date(JSON.parse(viewEndJSON));
        events.forEach(function(element) {
            let dayMap = {};

            while (viewStart <= viewEnd) {
                let dayRecord;
                let currentDayEvents = eventsByDay[viewStart.getTime()];
                if (currentDayEvents !== undefined) {
                    for (let j = 0; j < currentDayEvents.length; j++) {
                        if (currentDayEvents[j].element.Id === element.element.Id) {
                            dayRecord = {
                                element : element.element,
                                isEmpty : false,
                                day : viewStart
                            };
                            if (currentDayEvents[j].startDay) {
                                dayRecord.startDay = true;
                            } else {
                                dayRecord.startDay = false;
                            }
                            break;
                        } 
                    }
                }

                if (dayRecord === undefined) {
                    dayRecord = {
                        element : element.element,
                        isEmpty : true,
                        day : viewStart
                    };
                }
                dayMap[viewStart.getTime()] = dayRecord;
                viewStart.setUTCDate(viewStart.getUTCDate() + 1);
            }
            viewStart = new Date(JSON.parse(viewStartJSON));
            monthEvents.push({
                element : element.element,
                dayMap : dayMap
            });
        });
        
        return monthEvents;
    }

    
    getEventsByDay(eventsMap, viewStartJSON, viewEndJSON) {
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let viewEnd = new Date(JSON.parse(viewEndJSON));
        let tzOffset = this._timeZoneOffset;

        let monthEventsMap = {};
        while (viewStart <= viewEnd) {
            let dayEvents = eventsMap[viewStart.getTime()];
            let events = [];
            if (dayEvents !== undefined) {
                dayEvents.forEach(function(element) {
                    let startDateTime =  new Date(Date.parse(element.StartDateTime));
                    let allDayEvent = {
                        element: element
                    };
                    
                    if (!element.IsAllDayEvent) {
                        startDateTime.setUTCMilliseconds(startDateTime.getUTCMilliseconds() + parseInt(tzOffset, 10));
                    }
                    if (startDateTime.getTime() >= viewStart.getTime() && startDateTime.getTime() <= viewStart.getTime() + 86399999) {
                        allDayEvent.startDay = true;
                    } else {
                        allDayEvent.startDay = false;

                    }

                    events.push(allDayEvent);
                });
            }
            monthEventsMap[viewStart.getTime()] = events;
            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
        }
        return monthEventsMap;
    }

    getEvents(eventsMap, viewStartJSON, viewEndJSON) {
        
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let viewEnd = new Date(JSON.parse(viewEndJSON));
        let monthEvents = [];
        let eventsIds = [];
        while (viewStart <= viewEnd) {
            let dayEvents = eventsMap[viewStart.getTime()];
            dayEvents.forEach(function(element) {
                if (!eventsIds.includes(element.element.Id)) {
                    monthEvents.push(element);
                    eventsIds.push(element.element.Id);
                }
            });
            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
        }
        return monthEvents;
    }

    collectMonthEventsMatrix(monthEvents, viewStartJSON) {
        let viewStart = new Date(JSON.parse(viewStartJSON));
        let dayEventsMatrix = [];
        let maxEvents = 0;
        let daysInMonth = 32 - new Date(Date.UTC(viewStart.getUTCFullYear(), viewStart.getUTCMonth(), 32)).getUTCDate();
        for (let i = 0; i < daysInMonth; i++) {
            let eventsList = this.getEventsFromMapByDay(monthEvents, viewStart.getTime());
            if (eventsList !== undefined) {
                if (eventsList.length > maxEvents) {
                    maxEvents = eventsList.length;
                }
                dayEventsMatrix[i] = eventsList;
            }

            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
            
        }
        viewStart = new Date(JSON.parse(viewStartJSON));
        for (let j = 1; j < maxEvents; j++) {
            let startDay;
            let indexToSplice;
            for (let i = 0; i < daysInMonth; i++) {
                if (dayEventsMatrix[i] !== undefined) {
                    if (!dayEventsMatrix[i][j].isEmpty) {
                        if (startDay === undefined) {
                            startDay = i;
                            break;
                        }
                    }
                }
            }
            
            for (let k = j; k > 0; k--) {
                if (dayEventsMatrix[startDay] !== undefined && dayEventsMatrix[startDay][j - k] !== undefined && dayEventsMatrix[startDay][j - k].isEmpty) {
                    for (let i = startDay; i < daysInMonth; i++) {
                        if (dayEventsMatrix[i] !== undefined && dayEventsMatrix[i][j] !== undefined && !dayEventsMatrix[i][j].isEmpty) {
                            dayEventsMatrix[i][j - k] = dayEventsMatrix[i][j];
                            indexToSplice = j;
                        }
                    }
                    for (let i = 0; i < daysInMonth; i++) {
                        if (dayEventsMatrix[startDay] !== undefined) {
                            dayEventsMatrix[i].splice(indexToSplice, 1);
                        }
                    }
                    maxEvents--;
                    j--;
                    break;
                }
            }
        }
        return dayEventsMatrix;
    }
    // ================================================= Show Calendar Functions =================================================


    showCalendar() {
        if (this._viewStartDate !== undefined && this._viewEndDate !== undefined && this._selectedDate !== undefined && this._startDate !== undefined && this._endDate !== undefined && this._timeZoneOffset !== undefined && this._userTimeZone !== undefined) {
            if (this.isDay) {
                this.showDayCalendar();
            } else if (this.isWeek) {
                this.showWeekCalendar();
            } else {
                this.showMonthCalendar();
            }
        }
    }

    showMonthCalendar() {
        //this.collectEvents();
        
        this.collectEventsWithBounds(this._viewStartDate, this._viewEndDate);
        
        this.calendarWeeks = [];
        let startDate = new Date(this._viewStartDate);
        let endDate = new Date(this._viewEndDate);
        let year = new Date(this._selectedDate).getUTCFullYear();
        let month = new Date(this._selectedDate).getUTCMonth();
        let firstDay = this.weekDays[(new Date(Date.UTC(year, month))).getUTCDay()] + 1;
        let daysInMonth = 32 - new Date(Date.UTC(year, month, 32)).getUTCDate();
        let date = 1;
        let dayRecord;

        let monthEvents = this.fillMonthByEvents(this.eventsMap, JSON.stringify(startDate), JSON.stringify(endDate));
        let alldayEventsMatrix = this.collectMonthEventsMatrix(monthEvents, JSON.stringify(startDate));
        for (let i = 1; i < 7; i++) {
            let row = [];

            for (let j = 1; j <= 7; j++) {
                if (i === 1 && j < firstDay) {
                    dayRecord = {
                        label: "", 
                        type: "empty", 
                        numb: j
                    };
                }
                else if (date > daysInMonth) {
                    break;
                }

                else {
                    let events = alldayEventsMatrix[date - 1];
                    dayRecord = {
                        label: date,
                        date: startDate.getTime(),
                        type: "day", 
                        numb: j,
                        events: events,
                        moreEvents: false,
                        today: false
                    };
                    let shortEventsList = [];
                    let count = 0;
                    let outputEvents = 0;
                    if (events !== undefined) {
                        for (let ind = 0 ; ind < events.length; ind++) {
                            let currentEvent = events[ind];
                            if (ind < 3) {
                                shortEventsList.push(currentEvent);
                                if (!currentEvent.isEmpty) {
                                    outputEvents++;
                                }
                            }
                            if (!currentEvent.isEmpty) {
                                count++;
                            }
                        
                            dayRecord.extraEvents = count - outputEvents;
                            
                            if (ind === dayRecord.events.length - 1 && dayRecord.extraEvents > 0) {
                                dayRecord.moreEvents = true;
                            }
                        }
                    }
                    if (date === this.today.getUTCDate() && month === this.today.getUTCMonth() && year === this.today.getUTCFullYear()) {
                        dayRecord.today = true;
                    }
                    dayRecord.eventsToShow = shortEventsList;
                    date++;
                    startDate.setUTCDate(startDate.getUTCDate() + 1);
                }
                let checkingDate = new Date(Date.UTC(year, month, date - 1)).getTime();
                if (checkingDate > this._endDate || checkingDate < this._startDate) {
                    dayRecord.disabled = true;
                }
                row.push(dayRecord);
            }

            this.calendarWeeks.push({days: row, numb: i});
        }

    }

    showWeekCalendar() {
        this.dayWrapperEvents = {};
        this.collectEventsWithBounds(this._viewStartDate, this._viewEndDate);
        let eventsMap = this.eventsMap;
        let viewStart = new Date(this._viewStartDate);
        let viewEnd = new Date(this._viewEndDate);

        let allDayWeekEvents = this.fillWeekByAllDayEvents(eventsMap, JSON.stringify(viewStart), JSON.stringify(viewEnd));
        
        let alldayEventsMatrix = this.collectAllDayEventsMatrix(allDayWeekEvents, JSON.stringify(viewStart));
        this.calendarWeeks = [];

        let dayOfWeek = 0;
        
        while (viewStart <= viewEnd) {
            let dayRecord;
            let hourRecord;
            let events = eventsMap[viewStart.getTime()];
            let dayEvents;
            if (events !== undefined) {
                this.dayWrapperEvents[viewStart.getTime()] = this.collectEventByHour(events, viewStart.getTime());
                if (this.dayWrapperEvents[viewStart.getTime()] !== undefined) {
                    dayEvents = this.fillDayByEvents(this.getOnlyHourlyEvents(events), this.dayWrapperEvents[viewStart.getTime()].eventsByHour);
                }
            }

            let hourEventsMatrix = this.collectHourEventsMatrix(dayEvents);
    
            dayRecord = {
                label: viewStart.getTime(),
                today: false,
                disabled: false
            };
            let currentAllDayEvents = alldayEventsMatrix[dayOfWeek];
            if (currentAllDayEvents !== undefined) {
                dayRecord.allDayEvents = currentAllDayEvents;
            } else {
                dayRecord.allDayEvents = [];
            }
            dayRecord.eventsByHour = [];
    
            for (let j = 0; j <= 23; j++) {
                let shortEventsList = [];
                hourRecord = {
                    hour: new Date().setUTCHours(j),
                    moreEvents: false
                };
                if (dayEvents !== undefined) {
                    hourRecord.events = hourEventsMatrix[j];
                } else {
                    hourRecord.events = [];
                }
                let count = 0;
                let outputEvents = 0;
                for (let ind = 0 ; ind < hourRecord.events.length; ind++) {
                    let currentEvent = hourRecord.events[ind];
                    if (ind < 1) {
                        shortEventsList.push(currentEvent);
                        if (!currentEvent.isEmpty) {
                            outputEvents++;
                        }
                    }
                    if (!currentEvent.isEmpty) {
                        count++;
                    }
                
                    hourRecord.extraEvents = count - outputEvents;
                    if (ind === hourRecord.events.length - 1 && hourRecord.extraEvents > 0) {
                        hourRecord.moreEvents = true;
                    }
                }
                hourRecord.eventsToShow = shortEventsList;
                dayRecord.eventsByHour.push(hourRecord);
            }

            if (viewStart.getUTCDate() === this.today.getUTCDate() && viewStart.getUTCMonth() === this.today.getUTCMonth() && viewStart.getUTCFullYear() === this.today.getUTCFullYear()) {
                dayRecord.today = true;
            }
                
            if (viewStart.getTime() > this._endDate || viewStart.getTime() < this._startDate) {
                dayRecord.disabled = true;
            }
            this.calendarWeeks.push(dayRecord);

            dayOfWeek++;
            viewStart.setUTCDate(viewStart.getUTCDate() + 1);
        }
    }

    showDayCalendar() {
        this.dayWrapperEvents = {};
        this.collectEventsWithBounds(this._viewStartDate, this._viewEndDate);
        let eventsMap = this.eventsMap;
        let events = eventsMap[this._selectedDate];

        let dayEvents;
        if (events !== undefined) {
            
            this.dayWrapperEvents[this._selectedDate] = this.collectEventByHour(events, this._selectedDate);
            if (this.dayWrapperEvents[this._selectedDate] !== undefined) {
                dayEvents = this.fillDayByEvents(this.getOnlyHourlyEvents(events), this.dayWrapperEvents[this._selectedDate].eventsByHour);
            }
        }
        
        let dayRecord;
        let hourRecord;
        let selectedDate = new Date(this._selectedDate);
        this.calendarWeeks = [];
        let hourEventsMatrix = this.collectHourEventsMatrix(dayEvents);

        let eventsObject = this.dayWrapperEvents[selectedDate.getTime()];
        dayRecord = {
            label: selectedDate.getTime(),
            today: false,
            disabled: false
        };
        if (eventsObject !== undefined && eventsObject.allDayEvents !== undefined) {
            dayRecord.allDayEvents = eventsObject.allDayEvents;
        } else {
            dayRecord.allDayEvents = [];
        }
        dayRecord.eventsByHour = [];

        for (let j = 0; j <= 23; j++) {
            let shortEventsList = [];
            hourRecord = {
                hour: new Date().setUTCHours(j),
                moreEvents: false
            };
            if (dayEvents !== undefined) {
                //hourRecord.events = this.getEventsFromMapByHour(dayEvents, j);
                hourRecord.events = hourEventsMatrix[j];
            } else {
                hourRecord.events = [];
            }
            let count = 0;
            let outputEvents = 0;
            for (let ind = 0 ; ind < hourRecord.events.length; ind++) {
                let currentEvent = hourRecord.events[ind];
                if (ind < 3) {
                    shortEventsList.push(currentEvent);
                    if (!currentEvent.isEmpty) {
                        outputEvents++;
                    }
                }
                if (!currentEvent.isEmpty) {
                    count++;
                }
            
                hourRecord.extraEvents = count - outputEvents;
                if (ind === hourRecord.events.length - 1 && hourRecord.extraEvents > 0) {
                    hourRecord.moreEvents = true;
                }
            }
            hourRecord.eventsToShow = shortEventsList;
            dayRecord.eventsByHour.push(hourRecord);
        }
        if (selectedDate.getUTCDate() === this.today.getUTCDate() && selectedDate.getUTCMonth() === this.today.getUTCMonth() && selectedDate.getUTCFullYear() === this.today.getUTCFullYear()) {
            dayRecord.today = true;
        }
            
        if (selectedDate.getTime() > this._endDate || selectedDate.getTime() < this._startDate) {
            dayRecord.disabled = true;
        }
        this.calendarWeeks.push(dayRecord);
    }


    // ================================================= Modals and Click Event =================================================


    handleEventClick(event) {
        var elementId = event.target.dataset.elementId;
        var elementIdx = event.target.dataset.elementIdx;
        this.fireClickEvent(elementId, elementIdx);
    }

    handleExtraModalClick(event) {
        var elementId = event.detail.elementId;
        var elementIdx = event.detail.elementIdx;
        this.fireClickEvent(elementId, elementIdx);
    }

    fireClickEvent(eventId, eventIdx) {
        if (this.needToRedirect === true || this.needToRedirect === "true") {
            this.showEventModal(eventId);
        } else {
            const clickEvent = new CustomEvent('handleeventclick', {
                detail: {
                    eventId: eventId,
                    eventIdx: eventIdx
                }
            });

            this.dispatchEvent(clickEvent);
        }
    }

    showEventModal(elementId) {
        var eventToPass;
        this.events.forEach(function(element) {
            if (element.Id === elementId) {
                eventToPass = element;
            }
        });
        this.template.querySelector('c-event-modal').show(eventToPass);
    }

    showExtraEvents(event) {
        let dayNumb = event.target.dataset.currentDay;
        let eventToPass = [];
        
        let viewStart = new Date(this._viewStartDate);
        let viewEnd = new Date(this._viewEndDate);
        let eventsByDay = this.getEventsByDay(this.eventsMap, JSON.stringify(viewStart), JSON.stringify(viewEnd));
        let currentEvents = eventsByDay[dayNumb];
        currentEvents.forEach(function(element) {
            if (element !== undefined) {
                eventToPass.push(element);
            }
        });
        this.template.querySelector('c-extra-events-modal').show(eventToPass, dayNumb);
    }

    showExtraHourEvents(event) {
        let currentHour = new Date(parseInt(event.target.dataset.currentHour, 10)).getUTCHours();
        let currentMills = event.target.dataset.currentDate;
        let eventToPass = [];
        let currentEvents = this.dayWrapperEvents[currentMills].eventsByHour[currentHour];
        
        currentEvents.forEach(function(element) {
            if (element !== undefined) {
                eventToPass.push(element);
            }
        });
        this.template.querySelector('c-extra-events-modal').show(eventToPass, currentMills);
    }


    // ================================================= Getters and Setters =================================================


    @api
    get startDate() {
        return this._startDate;
    }
    set startDate(value) {
        let startDate = new Date(value);
        this._startDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), startDate.getUTCDate())).getTime();
        this.showCalendar();
    }
    
    @api
    get endDate() {
        return this._endDate;
    }
    set endDate(value) {
        let endDate = new Date(value);
        this._endDate = new Date(Date.UTC(endDate.getUTCFullYear(), endDate.getUTCMonth(), endDate.getUTCDate())).getTime();
        this.showCalendar();
    }

    @api
    get calendarEvents() {
        return this.events;
    }
    set calendarEvents(value) {
        if (value === undefined) {
            this.events = [];
        } else {
            this.events = value;
        }
        this.showCalendar();
    }

    @api
    get selectedDate() {
        return this._selectedDate;
    }
    set selectedDate(value) {
        this._selectedDate = value;
        this.showCalendar();
    }

    @api
    get viewStartDate() {
        return this._viewStartDate;
    }
    set viewStartDate(value) {
        this._viewStartDate = value;
    }

    @api
    get viewEndDate() {
        return this._viewEndDate;
    }
    set viewEndDate(value) {
        this._viewEndDate = value;
    }
    
    @api
    get userTimeZone() {
        return this._userTimeZone;
    }
    set userTimeZone(value) {
        this._userTimeZone = value;
    }
    
    @api
    get timeZoneOffset() {
        return this._timeZoneOffset;
    }
    set timeZoneOffset(value) {
        this._timeZoneOffset = value;
        this.showCalendar();
    }

    @api
    get viewType() {
        return this._viewType;
    }
    set viewType(value) {
        this._viewType = value;
        if (this._viewType === "day") {
            this.isMonth = false;
            this.isWeek = false;
            this.isDay = true;
        } else if (this._viewType === "week") {
            this.isMonth = false;
            this.isWeek = true;
            this.isDay = false;
        } else {
            this.isMonth = true;
            this.isWeek = false;
            this.isDay = false;
        }
        this.showCalendar();
    }
}