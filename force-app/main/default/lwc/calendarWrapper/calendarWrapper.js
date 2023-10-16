import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import getTZ from '@salesforce/apex/CalendarWrapperController.getUserTimezone';

import NEW_EVENT_BUTTON_LABEL from '@salesforce/label/c.newEventButton';
import TODAY_BUTTON_LABEL from '@salesforce/label/c.todayButton';
import DAY_LABEL from '@salesforce/label/c.Day_View_Type_Label';
import WEEK_LABEL from '@salesforce/label/c.Week_View_Type_Label';
import MONTH_LABEL from '@salesforce/label/c.Month_View_Type_Label';
import PREVIOUS_LABEL from '@salesforce/label/c.Previous_Label';
import NEXT_LABEL from '@salesforce/label/c.Next_Label';

import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { parseUrlParams } from 'c/schHelper';

export default class CalendarWrapper extends NavigationMixin(LightningElement) {
    @api events;
    @api _userTimeZone;
    @api timeZoneOffset

    @api newEventLabel = "New Event";
    @api todayLabel = "Today";

    @api dayLabel = "Day";
    @api weekLabel = "Week";
    @api monthLabel = "Month";
    
    @api nextLabel = "Next";
    @api previousLabel = "Previous";

    @api _startDate;
    @api _endDate;
    
    isMonth = true;
    isWeek = false;
    isDay = false;
    @track _viewType = "month";

    @api calendarLabel = "Calendar";
    @api showSidebar = false;
    @api showNewEvent = false;
    @api redirectToEvent = false;

    defaultDate;

    today;
    weekDays = {"0" : 6, "1": 0, "2" : 1, "3" : 2, "4" : 3, "5" : 4, "6" : 5};
    @track selectedDate;
    
    
    @api viewStartDate;
    @api viewEndDate;

    @track maxYear;
    @track minYear;   

    attendeeId;

    //@wire(CurrentPageReference) pageRef;

    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
        this.pageRef = currentPageRef;
        if(currentPageRef.state) {
            parseUrlParams(this.pageRef.state, this);
        }
    }


    handleRefreshEvent (payload) {
        
        if(this.attendeeId === payload.id){
            this.events = [];
            this.events = payload.state.events;
        }

    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    // handle event click from calendar component, fires open result modal event
    handleEventClickEvent (event) {
        
        let message = {
            id : this.attendeeId, 
            state : {
                id :  event.detail.eventId,
                idx: event.detail.eventIdx
            }
        }
        fireEvent(this.pageRef, 'openResultModal', message)
    }

    connectedCallback() {
        
        // register listener
        registerListener('refreshCalendar', this.handleRefreshEvent, this);
        
        getTZ({
        userTimeZone: this._userTimeZone
        })
        .then(tz => {
            this._userTimeZone = tz.userTimeZone;
            this.timeZoneOffset = tz.timeZoneOffset;

            this.todayLabel = TODAY_BUTTON_LABEL;
            this.newEventLabel = NEW_EVENT_BUTTON_LABEL;

            this.dayLabel = DAY_LABEL;
            this.weekLabel = WEEK_LABEL;
            this.monthLabel = MONTH_LABEL;

            this.previousLabel = PREVIOUS_LABEL;
            this.nextLabel = NEXT_LABEL;

            let today = new Date();
            this.today = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate())).getTime();

            
            if (this.selectedDate === undefined) {
                this.selectedDate = this.today;
            }
            if (this.defaultDate === undefined) {
                this.defaultDate = this.today;
            }

            if (this._startDate === undefined) {
                let startDate = new Date(this.today);
                startDate.setUTCDate(1);
                this._startDate = startDate.getTime();
            }
            if (this._endDate === undefined) {
                let endDate = new Date(this.today);
                endDate.setUTCDate(32 - new Date(Date.UTC(endDate.getUTCFullYear(), endDate.getUTCMonth(), 32)).getUTCDate());
                this._endDate = endDate.getTime();
            }

            this.recalculateViewDates();
            
            let startDate = new Date(this._startDate);
            let endDate = new Date(this._endDate);
            this.maxYear = endDate.getUTCFullYear();
            this.minYear = startDate.getUTCFullYear();
        });
        
    }

    renderedCallback() {
        if (this.showSidebar === true || this.showSidebar === "true") {
            this.template.querySelector('c-calendar').style.width = "calc(100% - 250px)";
            this.template.querySelector('c-calendar-sidebar').resetSidebarDate(this.selectedDate, false);
        } else {
            this.template.querySelector('c-calendar').style.width = "100%";
        }

    }

    setToday() {
        if (this.today >= this._startDate && this.today <= this._endDate) {
            this.selectedDate = this.today;
            this.recalculateViewDates();
            if (this.showSidebar === true || this.showSidebar === "true") {
                this.template.querySelector('c-calendar-sidebar').resetSidebarDate(this.selectedDate, true);
            } 
        }
    }

    next() {
        let selectedDate = new Date(this.selectedDate);
        let checkingDate;
        if (this.isMonth) {
            checkingDate = new Date(Date.UTC(selectedDate.getUTCFullYear(), selectedDate.getUTCMonth() + 1, 1));
            if (checkingDate <= this._endDate) {
                selectedDate.setUTCFullYear((selectedDate.getUTCMonth() === 11) ? selectedDate.getUTCFullYear() + 1 : selectedDate.getUTCFullYear());
                selectedDate.setUTCMonth((selectedDate.getUTCMonth() + 1) % 12);
                
                this.selectedDate = selectedDate.getTime();
                this.recalculateViewDates();
            }
        } else if (this.isWeek) {
            checkingDate = new Date(this.viewEndDate);
            checkingDate.setUTCDate(checkingDate.getUTCDate() + 1);
            if (checkingDate <= this._endDate) {
                this.selectedDate = checkingDate.getTime();
                this.recalculateViewDates();
            }
        } else {
            checkingDate = selectedDate;
            checkingDate.setUTCDate(checkingDate.getUTCDate() + 1);
            if (checkingDate <= this._endDate) {
                this.selectedDate = checkingDate.getTime();
                this.recalculateViewDates();
            }
        }
        if (this.showSidebar === true || this.showSidebar === "true") {
            this.template.querySelector('c-calendar-sidebar').resetSidebarDate(this.selectedDate, true);
        } 
    }

    previous() {
        let selectedDate = new Date(this.selectedDate);
        let checkingDate

        if (this.isMonth) {
            checkingDate = new Date(Date.UTC(selectedDate.getUTCFullYear(), selectedDate.getUTCMonth() - 1, 32 - new Date(Date.UTC(selectedDate.getUTCFullYear(), selectedDate.getUTCMonth(), 32)).getDate()));
            if (checkingDate >= this._startDate) {
                selectedDate.setUTCFullYear((selectedDate.getUTCMonth() === 0) ? selectedDate.getUTCFullYear() - 1 : selectedDate.getUTCFullYear());
                selectedDate.setUTCMonth((selectedDate.getUTCMonth() === 0) ? 11 : selectedDate.getUTCMonth() - 1);

                this.selectedDate = selectedDate.getTime();
                this.recalculateViewDates();
            }
        } else if (this.isWeek) {
            checkingDate = new Date(this.viewStartDate);
            checkingDate.setUTCDate(checkingDate.getUTCDate() - 1);
            if (checkingDate >= this._startDate) {
                this.selectedDate = checkingDate.getTime();
                this.recalculateViewDates();
            }
        } else {
            checkingDate = selectedDate;
            checkingDate.setUTCDate(checkingDate.getUTCDate() - 1);
            if (checkingDate >= this._startDate) {
                this.selectedDate = checkingDate.getTime();
                this.recalculateViewDates();
            }
        }
        if (this.showSidebar === true || this.showSidebar === "true") {
            this.template.querySelector('c-calendar-sidebar').resetSidebarDate(this.selectedDate, true);
        } 
    }

    selectViewType(event) {
        this._viewType = event.detail.value;
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
        this.recalculateViewDates();
    }

    recalculateViewDates() {
        let openDate = new Date(this.selectedDate);

        if (this.isDay) {
            this.viewStartDate = this.selectedDate;
            this.viewEndDate = this.selectedDate;
        } else if (this.isWeek) {
            this.viewStartDate = new Date(openDate.setUTCDate(openDate.getUTCDate() - this.weekDays[openDate.getUTCDay()])).getTime();
            this.viewEndDate = new Date(openDate.setUTCDate(openDate.getUTCDate() - this.weekDays[openDate.getUTCDay()] + 6)).getTime();
        } else {
            this.viewStartDate = new Date(openDate.setUTCDate(1)).getTime();
            this.viewEndDate = new Date(openDate.setUTCDate(32 - new Date(Date.UTC(openDate.getUTCFullYear(), openDate.getUTCMonth(), 32)).getUTCDate())).getTime();
        }
    }

    setDate(event) {
        this.selectedDate = event.detail.selectedDate;
        this.recalculateViewDates();
    }

    @api
    get openDate() {
        return this.defaultDate;
    }
    set openDate(value) {
        let openDate = new Date(value);
        this.defaultDate = new Date(Date.UTC(openDate.getUTCFullYear(), openDate.getUTCMonth(), openDate.getUTCDate())).getTime();
        this.selectedDate = new Date(Date.UTC(openDate.getUTCFullYear(), openDate.getUTCMonth(), openDate.getUTCDate())).getTime();
        if (this.showSidebar === true || this.showSidebar === "true") {
            this.template.querySelector('c-calendar-sidebar').resetSidebarDate(this.selectedDate, true);
        } 
        this.recalculateViewDates();
    }

    @api
    get startDate() {
        return this._startDate;
    }
    set startDate(value) {
        let startDate = new Date(value);
        this._startDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), startDate.getUTCDate())).getTime();
    }

    @api
    get endDate() {
        return this._endDate;
    }
    set endDate(value) {
        let endDate = new Date(value);
        this._endDate = new Date(Date.UTC(endDate.getUTCFullYear(), endDate.getUTCMonth(), endDate.getUTCDate())).getTime();
    }
    
    @api
    get userTimeZone() {
        return this._userTimeZone;
    }
    set userTimeZone(value) {
        getTZ({
            userTimeZone: value
        })
        .then(tz => {
            this._userTimeZone = tz.userTimeZone;
            this.timeZoneOffset = tz.timeZoneOffset;
        });
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
        this.recalculateViewDates();
    }

    handleNewEvent() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'new',
            }
        });
    }
}