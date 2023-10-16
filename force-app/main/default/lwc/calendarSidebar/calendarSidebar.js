import { LightningElement, track, api } from 'lwc';

import MONDAY_SHORT_LABEL from '@salesforce/label/c.Monday_Short';
import TUESDAY_SHORT_LABEL from '@salesforce/label/c.Tuesday_Short';
import THURSDAY_SHORT_LABEL from '@salesforce/label/c.Thursday_Short';
import WEDNESDAY_SHORT_LABEL from '@salesforce/label/c.Wednesday_Short';
import FRIDAY_SHORT_LABEL from '@salesforce/label/c.Friday_Short';
import SUTURDAY_SHORT_LABEL from '@salesforce/label/c.Saturday_Short';
import SUNDAY_SHORT_LABEL from '@salesforce/label/c.Sunday_Short';

import PREVIOUS_LABEL from '@salesforce/label/c.Previous_Label';
import NEXT_LABEL from '@salesforce/label/c.Next_Label';

export default class CalendarSidebar extends LightningElement {

    @track selectedDate
    eventDate;
    
    @api userTimeZone;

    _startDate;
    _endDate;

    @track calendarWeeks;

    @track maxYear;
    @track minYear;
    @track selectedYear;

    @api nextLabel = "Next";
    @api previousLabel = "Previous";
    
    mondayLabel = MONDAY_SHORT_LABEL;
    tuesdayLabel = TUESDAY_SHORT_LABEL;
    thursdayLabel = THURSDAY_SHORT_LABEL;
    wednesdayLabel = WEDNESDAY_SHORT_LABEL;
    fridayLabel = FRIDAY_SHORT_LABEL;
    suturdayLabel = SUTURDAY_SHORT_LABEL;
    sundayLabel = SUNDAY_SHORT_LABEL;
    
    weekDays = {"0" : 6, "1": 0, "2" : 1, "3" : 2, "4" : 3, "5" : 4, "6" : 5};
    
    @track yearOptions;

    connectedCallback() {
        let yearList = [];
        let startDate = new Date(this._startDate);
        let endDate = new Date(this._endDate);
        let today = new Date();
        
        this.previousLabel = PREVIOUS_LABEL;
        this.nextLabel = NEXT_LABEL;
        
        this.selectedDate = new Date(Date.UTC(today.getUTCFullYear(), today.getUTCMonth(), today.getUTCDate())).getTime();
        this.selectedYear = new Date(this.selectedDate).getUTCFullYear();
        for (let i = startDate.getUTCFullYear(); i <= endDate.getUTCFullYear(); i++) {
            yearList.push({ label: i, value: i });
        }

        this.maxYear = endDate.getUTCFullYear();
        this.minYear = startDate.getUTCFullYear();

        this.yearOptions = yearList;
        this.showCalendar();
    }

    showCalendar() {
        this.calendarWeeks = [];

        let year = new Date(this.selectedDate).getUTCFullYear();
        let month = new Date(this.selectedDate).getUTCMonth();
        let firstDay = this.weekDays[(new Date(Date.UTC(year, month))).getUTCDay()] + 1;
        let daysInMonth = 32 - new Date(Date.UTC(year, month, 32)).getUTCDate();
        let date = 1;
        let dayRecord;
        
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
                    dayRecord = {
                        label: date, 
                        type: "day", 
                        numb: j,
                        selected: false
                    };
                    let strToCompare = new Date(Date.UTC(year, month, date)).getTime();
                    if (this.eventDate === strToCompare) {
                        dayRecord.selected = true;
                    }

                    date++;

                }
                let checkingDate = new Date(Date.UTC(year, month, date - 1));
                if (checkingDate.getTime() > this._endDate || checkingDate.getTime() < this._startDate) {
                    dayRecord.disabled = true;
                }

                row.push(dayRecord);
            }

            this.calendarWeeks.push({days: row, numb: i});
        }
    }

    next() {
        let selectedDate = new Date(this.selectedDate);
        let selectedYear = selectedDate.getUTCFullYear();
        let selectedMonth = selectedDate.getUTCMonth();

        let checkingDate = new Date(Date.UTC(selectedYear, selectedMonth + 1, 1));

        if (checkingDate <= this._endDate) {
            selectedYear = (selectedMonth === 11) ? selectedYear + 1 : selectedYear;
            selectedDate.setUTCFullYear(selectedYear);

            selectedMonth = (selectedMonth + 1) % 12;
            selectedDate.setUTCMonth(selectedMonth);

            this.selectedDate = selectedDate.getTime();
            this.selectedYear = new Date(this.selectedDate).getUTCFullYear();

            this.showCalendar();
        }
    }

    previous() {
        let selectedDate = new Date(this.selectedDate);
        let selectedYear = selectedDate.getUTCFullYear();
        let selectedMonth = selectedDate.getUTCMonth();

        let checkingDate = new Date(Date.UTC(selectedYear, selectedMonth - 1, 32 - new Date(Date.UTC(selectedYear, selectedMonth, 32)).getUTCDate()));

        if (checkingDate >= this._startDate) {
            selectedYear = (selectedMonth === 0) ? selectedYear - 1 : selectedYear;
            selectedDate.setUTCFullYear(selectedYear);

            selectedMonth = (selectedMonth === 0) ? 11 : selectedMonth - 1;
            selectedDate.setUTCMonth(selectedMonth);

            this.selectedDate = selectedDate.getTime();
            this.selectedYear = new Date(this.selectedDate).getUTCFullYear();
            
            this.showCalendar();
        }

    }

    jump(event) {
        let selectedDate = new Date(this.selectedDate);
        selectedDate.setUTCFullYear(parseInt(event.target.value, 10));
        if (selectedDate > this._endDate) {
            selectedDate = new Date(this._endDate);
        } else if (selectedDate < this._startDate) {
            selectedDate = new Date(this._startDate);
        }
        this.selectedDate = selectedDate.getTime();
        this.selectedYear = new Date(this.selectedDate).getUTCFullYear();

        this.showCalendar();
    }

    navigateToDate(event) {
        let selectedDate = new Date(this.selectedDate);
        selectedDate.setUTCDate(event.target.dataset.day);
        this.selectedDate = selectedDate.getTime();
        this.eventDate = this.selectedDate;
        const navToDate = new CustomEvent('navigatetodate', {
            detail: {
                selectedDate: this.selectedDate
            }
        });

       this.dispatchEvent(navToDate);
       this.showCalendar();
    }

    @api
    resetSidebarDate(selectedDate, resetEventDate) {
        if (resetEventDate) {
            this.eventDate = null;
        }
        this.selectedDate = selectedDate;
        this.selectedYear = new Date(this.selectedDate).getUTCFullYear();
        this.showCalendar();
    }

    @api
    get startDate() {
        return this._startDate;
    }
    set startDate(value) {
        this._startDate = value;
    }
    
    @api
    get endDate() {
        return this._endDate;
    }
    set endDate(value) {
        this._endDate = value;
    }
}