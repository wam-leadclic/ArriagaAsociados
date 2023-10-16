import { LightningElement, api, track, wire } from 'lwc';
import { showToast } from 'c/schHelper';
import { NavigationMixin } from 'lightning/navigation';

import createEvent from '@salesforce/apex/SchSearchController.createEvent'
import updateEvent from '@salesforce/apex/SchSearchController.updateEvent'
import getConvertedLead from '@salesforce/apex/SchSearchController.getConvertedLead'


import next from '@salesforce/label/c.Next';
import cancel from '@salesforce/label/c.Cancel';
import assign from '@salesforce/label/c.Assign';
import day from '@salesforce/label/c.Day';
import hour from '@salesforce/label/c.Hour';
import summaryHeader from '@salesforce/label/c.SummaryHeader';
import appOK from '@salesforce/label/c.AppointmentCreated';
import appError from '@salesforce/label/c.AppointmentCreatedError';
import resources from '@salesforce/label/c.Resources';
import users from '@salesforce/label/c.Users';
import timeAv from '@salesforce/label/c.TimeAvailability';
import commentsLabel from '@salesforce/label/c.CommentsEvent';
import appointmentType from '@salesforce/label/c.DateType';


export default class SchResultModal extends NavigationMixin(LightningElement) {

    // data passed from parent component with time slot and resources info
    @api resultSelected; 
    @api isSummaryResult;

    // min availability requested by user
    @api userSelected;
    @api resourceSelected;
    @api appointmentTypeSelected;
    @api typeSelected;
	@api sendMail;

    // extra params
    @api extraParams;

    @api searchByEvents;

    // Selected from picklist, or preselected from the search component
    @track userValueSelected = {};
    @track resourceValueSelected = {};
    @track usersPreSelected = {};
    @track resourcesPreSelected = {};

    // Maps containing the user/resource type and their values, to print the picklists dynamically
    @track mUserValues = {};
    @track lUserValues = [];
    @track mResourceValues = {};
    @track lResourceValues = [];
    @track appointmentTypeValues = [{label: 'Informativa', value: 'Informativa'}, {label: 'Contratación', value: 'Contratación'}, {label: 'Completado', value: 'Completado'}]


    // info for appointment creation
    @track appointmentTypeValueSelected = '';
    @track comments = '';
    @track eventData = {};

    @track showSpinner = false;
    @track showAppointmentData = false;

    @track showSelection;

    @track ConvertedAccount;

    @track recordPageUrl;

    get startDayFormatted () {
        let dd = this.eventData.startDate.getDate().toString().padStart(2, '0');
        let mm = (this.eventData.startDate.getMonth() + 1).toString().padStart(2, '0'); 
        let yyyy = this.eventData.startDate.getFullYear()
        return yyyy + '-' + mm + '-' + dd;
    }


    get startHourFormatted () {
        let hh = this.eventData.startDate.getHours().toString().padStart(2, '0');
        let mm = this.eventData.startDate.getMinutes().toString().padStart(2, '0');
        return hh + ':' + mm
    }

    get modalHeader () {
        
        let returnValue;

        if(!this.showSelection) {
            returnValue = this.labels.summaryHeader;
        } else {
            returnValue = this.resultSelected.startDate.getHours().toString().padStart(2, '0') + ' : ' + this.resultSelected.startDate.getMinutes().toString().padStart(2, '0') +
            ' - ' + this.resultSelected.endDate.getHours().toString().padStart(2, '0') + ' : ' + this.resultSelected.endDate.getMinutes().toString().padStart(2, '0') ;
        }
        
        return returnValue;
    }

    connectedCallback() {

        console.log(JSON.stringify(this.resultSelected));

         // picklist init
        if(this.userSelected) {
            for(let userKey of this.userSelected) {
                this.mUserValues[userKey] = [];
                this.lUserValues = [{key : userKey, value: [], valueSelected : ''}];
            }
        }

        // NavigationMixin generates URL at the load of the component
        // The Id used in this URL must be replaced or reformatted later to avoid malfunctioning
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.resultSelected.attendeeId,
                objectApiName: 'Account',
                actionName: "view"
            }
        }).then(url => {
            this.recordPageUrl = url;
        })
        
        if (this.resourceSelected) {
            for(let resourceKey of this.resourceSelected) {
                this.mResourceValues[resourceKey] = [];
                this.lResourceValues = [{key : resourceKey, value: [], valueSelected : ''}];
            }
        }

        if (this.resourcesPreSelected)
            this.resourcesPreSelected = {};
        if (this.usersPreSelected)
            this.usersPreSelected = {};    

        this.showSelection = !this.searchByEvents;   
        
        if (this.searchByEvents){
            this.eventData.startDate = this.resultSelected.startDate;
            this.eventData.endDate = this.resultSelected.endDate;
        }
    }

    onChangeHour ( event ) {

        console.log(JSON.stringify(this.resultSelected));
        
        if(this.userSelected) {
            for(let userKey of this.userSelected) {
                this.mUserValues[userKey] = [];
                this.lUserValues = [{key : userKey, value: [], valueSelected : ''}];
            }
        }
        
        if (this.resourceSelected) {
            for(let resourceKey of this.resourceSelected) {
                this.mResourceValues[resourceKey] = [];
                this.lResourceValues = [{key : resourceKey, value: [], valueSelected : ''}];
            }
        } 
        
        if (this.resourcesPreSelected)
            this.resourcesPreSelected = {};
        if (this.usersPreSelected)
            this.usersPreSelected = {}; 

        // current init date
        let lTime = event.target.value.split(':');
        let currentDate = new Date(this.resultSelected.startDate.getTime());
        currentDate.setHours(lTime[0]);
        currentDate.setMinutes(lTime[1]);
        
        // fill event start/end date
        this.eventData.startDate = currentDate;
        this.eventData.endDate = new Date (currentDate.getTime() + this.resultSelected.duration * 60000);

        if (!this.isSummaryResult)
            this.fillPicklistValues(currentDate, this.resultSelected.duration);
        else
            this.pickUserResourceValues(currentDate, this.resultSelected.duration);    

    }
    
    fillPicklistValues (currentDate, duration) {
        
        for(let interval of this.resultSelected.intervals) {
            
            let minInterval = new Date( Date.parse(interval.interval.min));/* - (currentDate.getTimezoneOffset() * 60000));*/
            let maxInterval = new Date( Date.parse(interval.interval.max));/* - (currentDate.getTimezoneOffset() * 60000)); */
            
            if ( currentDate >= minInterval && currentDate < maxInterval &&
                ( currentDate.getTime() + (duration*60000) ) >= minInterval.getTime() && 
                ( currentDate.getTime() + (duration*60000) ) <= maxInterval.getTime() ) {

                let resourcesInfo = interval.mTypeSubtypeResourceDetail;
                
                console.log('resourcesInfo: '+JSON.stringify(resourcesInfo));
                
                for(let key of Object.keys(resourcesInfo) ) {
                    console.log('key: '+key);   
                    if(key === 'User') {
                        for(let userKey of Object.keys(resourcesInfo[key])) {
                            console.log('userKey: '+userKey);
                            for(let userValue of resourcesInfo[key][userKey]) {
                                console.log('userValue: '+userValue);
                                
                                if (this.mUserValues.hasOwnProperty(userKey)){
                                    this.mUserValues[userKey].push({label : userValue.resourceName , value : userValue.calendarId});
                                }                                                          
                                
                            }
                        }                    
                    }
                    
                    if(key === 'Resource') {
                        for(let resourceKey of Object.keys(resourcesInfo[key])) {
                            console.log('resourceKey: '+resourceKey);
                            for(let resourceValue of resourcesInfo[key][resourceKey]) {
                                console.log('resourceValue: '+resourceValue);
                                
                                if(this.mResourceValues.hasOwnProperty(resourceKey)) {
                                    this.mResourceValues[resourceKey].push({label : resourceValue.resourceName , value : resourceValue.calendarId});

                                }
                            }
                        }
                    }
                }
            }
        }

        // picklist build
        this.lUserValues = [];
        for(let userType of Object.keys(this.mUserValues)) {
            this.lUserValues.push({key : userType, value : this.mUserValues[userType], valueSelected : '' });
        }
        for (let userValue of this.lUserValues){
            userValue.value.sort(function(a, b){
                return a.label.toLowerCase() < b.label.toLowerCase() ? -1 : (a.label.toLowerCase() > b.label.toLowerCase() ? 1 : 0);
            });
        }


        this.lResourceValues = [];
        for(let resourceType of Object.keys(this.mResourceValues)) {
            this.lResourceValues.push({key : resourceType, value : this.mResourceValues[resourceType], valueSelected : '' });          
        }
        for (let resourceValue of this.lResourceValues){
            resourceValue.value.sort(function(a, b){
                return a.label.toLowerCase() < b.label.toLowerCase() ? -1 : (a.label.toLowerCase() > b.label.toLowerCase() ? 1 : 0);
            });
        }

    }
    
    pickUserResourceValues (currentDate, duration) {

        for(let interval of this.resultSelected.intervals) {
            
            let minInterval = new Date( Date.parse(interval.interval.min));/* - (currentDate.getTimezoneOffset() * 60000));*/
            let maxInterval = new Date( Date.parse(interval.interval.max));/* - (currentDate.getTimezoneOffset() * 60000)); */

            // TODO: code condition
            if ( currentDate >= minInterval && currentDate < maxInterval &&
                ( currentDate.getTime() + (duration*60000) ) >= minInterval.getTime() && 
                ( currentDate.getTime() + (duration*60000) ) <= maxInterval.getTime() ) {

                let resourcesInfo = interval.mTypeSubtypeResourceDetail;
                
                for(let key of Object.keys(resourcesInfo) ) {  
                    if(key === 'User') {
                        // Pick one user for each different userKey
                        for(let userKey of Object.keys(resourcesInfo[key])) {
                            for(let userValue of resourcesInfo[key][userKey]) {                            
                                this.usersPreSelected[userKey] = userValue.calendarId;
                                break;                                                                                                    
                            }
                        }
                    }      
                    
                    else if(key === 'Resource') {
                        for(let resourceKey of Object.keys(resourcesInfo[key])) {
                            for(let resourceValue of resourcesInfo[key][resourceKey]) {
                                this.resourcesPreSelected[resourceKey] = resourceValue.calendarId;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    get availableDates () {
        
        let result = this.getTimeIntervals(this.resultSelected.startDate, this.resultSelected.endDate, this.resultSelected.duration);
        let picklistValues = [];
        
        for(let d of result) {
            picklistValues.push({
                label : d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0'), 
                value : d.getHours().toString().padStart(2, '0') + ':' + d.getMinutes().toString().padStart(2, '0')
            });
        }
        return picklistValues;
    }


    getTimeIntervals(startDate, endDate, duration) {
 
        let dates = [],
            currentDate = startDate,
            addMinutes = function(minutes) {
                let date = new Date(currentDate.getTime() + (minutes*60000));
                return date;
            };
        while ( (currentDate < endDate) && ( (currentDate.getTime() + (duration*60000)) <= endDate.getTime() ) ) {
            dates.push(currentDate);
            currentDate = addMinutes.call(currentDate, 15);
        }
        return dates;
    }


   

    closeModal () {      
        const closeEvent = new CustomEvent('closemodal', {});
        this.dispatchEvent(closeEvent);
    }

    assignDate () {
        console.log('TEST ONchange');
        // Update event created
        if (this.searchByEvents){
            let request = {
                eventId : this.resultSelected.eventId,
                attendeeId : this.resultSelected.attendeeId,
                extraParams : this.extraParams,
                comments : this.comments,
                appointmentType : this.appointmentTypeValueSelected
            }

            this.showSpinner = true;
            updateEvent(request)
                .then(result => {
                    if (result.status){
                        console.log('OK');
                    }else{
                        console.log('FAIL1');
                        showToast({variant : 'error', message : this.labels.appError, title : 'Error'}, this);
                    }   
                    this.showSpinner = false;   
                    
                    
                    const cleanEvent = new CustomEvent('appointmentcreated', {});
                    this.dispatchEvent(cleanEvent);

                    this.closeModal();  
                    this.resultSelected.attendeeId;
                    showToast({variant : 'success', message : this.labels.appOK, title : ''}, this);  

                })
                .catch(error => {
                    console.log('FAIL2');
                    showToast({variant : 'error', message : this.labels.appError, title : 'Error'}, this);
                    this.showSpinner = false;   
                });
        // Create a new event
        } else {
            let request = {
                startDate : this.eventData.startDate,
                endDate : this.eventData.endDate,
                attendeeId : this.resultSelected.attendeeId,
                assignedTo : (this.isSummaryResult ? this.usersPreSelected : this.userValueSelected),
                lResource : (this.isSummaryResult ? this.resourcesPreSelected : this.resourceValueSelected), 
                filterValues : this.resultSelected.filterValues,
                extraParams : this.extraParams,
                comments : this.comments,
                appointmentType : this.appointmentTypeValueSelected
            }
            console.log('TEST ' + JSON.stringify(request));

            this.showSpinner = true;
            createEvent(request)
                .then(result => {
                    console.log('STATUS : ' + result.status);
                    if (result.status){
                        console.log('OK');
                    }else{
                        showToast({variant : 'error', message : this.labels.appError, title : 'Error'}, this);
                    }   
                    this.showSpinner = false;   
                    
                    const cleanEvent = new CustomEvent('appointmentcreated', {});
                    this.dispatchEvent(cleanEvent);

                    this.closeModal();  
                    showToast({variant : 'success', message : this.labels.appOK, title : ''}, this);
                    console.log('Id : ' + this.resultSelected.attendeeId);

                    /*getConvertedLead({ attendeeId : this.resultSelected.attendeeId})
                        .then( result => {
                        this.ConvertedAccount = result.mParams['ConvertedAccount'];
                        let finalUrl = this.recordPageUrl.replace(this.resultSelected.attendeeId, this.ConvertedAccount.toString());
                        window.open(finalUrl, "_blank");
                    }).catch(error => {
                        console.log('Error : ' + error.message);

                    });*/
                });
        }
    }
    
    validateFields () {
        this.template.querySelectorAll('.appointmentTypeClass').forEach(element => {
            console.log(element.reportValidity());

            if( element.reportValidity() ) {
                this.acceptSelection();
            } else {
                element.reportValidity();
            }
        });
    }

    acceptSelection () {
        this.showSelection = false; 
        this.showAppointmentData = true;
    }

    onChangeAppointmentType ( event ) {
        this.appointmentTypeValueSelected = event.target.value;

    }


    onChangeUserPicklist ( event ) {
        let mapKey = event.target.label;
        let mapValue = event.target.value;
        this.userValueSelected[mapKey] = mapValue;

        console.log(JSON.stringify(this.userValueSelected));
    }

    onChangeResourcePicklist ( event ) {
        let mapKey = event.target.label;
        let mapValue = event.target.value;
        this.resourceValueSelected[mapKey] = mapValue;
        console.log(JSON.stringify(this.resourceValueSelected));

    }

    onChangeComments ( event ) {
        this.comments = event.target.value;
    }

    labels = {
   
        next,
        cancel,
        assign,
        day, 
        hour, 
        summaryHeader, 
        appOK, 
        appError, 
        resources, 
        users, 
        timeAv,
        commentsLabel,
        appointmentType
    }

  
}