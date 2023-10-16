import { LightningElement, track, wire } from 'lwc';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import { parseUrlParams, showToast } from 'c/schHelper';

import getAvailability from '@salesforce/apex/SchSearchController.getAvailability'
import getParamsFromExtendedFeatures from '@salesforce/apex/SchSearchController.getParamsFromExtendedFeatures'

import cardTitle from '@salesforce/label/c.Search';
import search from '@salesforce/label/c.SearchTab';
import result from '@salesforce/label/c.ResultTab';
import fromDate from '@salesforce/label/c.FromDate';
import toDate from '@salesforce/label/c.ToDate';
import fromHour from '@salesforce/label/c.FromHour';
import toHour from '@salesforce/label/c.ToHour';
import duration from '@salesforce/label/c.Duration';
import searchButton from '@salesforce/label/c.SearchButton';
import validationMessage from '@salesforce/label/c.validationMessage';
import searchError from '@salesforce/label/c.SearchError';
import noResultMessage from '@salesforce/label/c.NoResultMessage';


export default class SchSearch extends LightningElement {

    // search params
    @track attendeeId;
    @track searchFromDate;
    @track searchToDate;
    @track startHour;
    @track endHour;
    @track duration;
    @track userSelected;
    @track resourceSelected;
    @track typeSelected;
	@track sendMail;
    @track filterValues = {};
    @track extraParams = {};
    @track customValidation = [];
    @track isVideomeeting;



    // side bar result list
    @track lResult = [];
    @track lTimeSlot = [];

    // result list with resources info
    @track lResultResource = [];

    @track pageRef;
    @track activeTab = 'search';
    @track showSpinner = false;
    @track showResultModal = false;
    
    // info for result modal
    @track isSummaryResult = false;
    @track resultSelected = {};

    @track searchByEvents = false;

    constructor(){
        super();
        this.initParams();
    }

    get debugExtraParams () {

        return JSON.stringify(this.extraParams);

    }

    get debugFilters () {
        return JSON.stringify(this.filterValues);

    }

    initParams () {
        this.userSelected = [];
        this.resourceSelected = [];
        let today = new Date();
        this.searchFromDate = today.getFullYear() + '-' + (today.getMonth()+1) + '-' + today.getDate();

    }

    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
        
        var keyParamName;
        this.pageRef = currentPageRef;      
        if(currentPageRef.state) {
            parseUrlParams(currentPageRef.state, this);
           
            // Get duration and searchToDate from SchExtendedFeaturesImplementation if exists
            getParamsFromExtendedFeatures( { attendeeId: this.attendeeId })
                .then ( result => {
                    if (result.status) {
                        if (result.mParams){
                            
                            for (keyParamName in result.mParams){
                                if(keyParamName != null) {
                                    this[keyParamName] = result.mParams[keyParamName];
                                }
                            }
                        }
                    }else {
                        showToast({variant : 'error', 
                            message : searchError, 
                            title : 'Error'}, this);
                    }
                })
                .catch ( error => {
                    showToast({variant : 'error', 
                            message : searchError, 
                            title : 'Error'}, this);
            });
             
        }
    }

    onChangeInput(event) {
        this[event.target.name] = event.target.value;
    }

    onClickSearch(event) {
       
        if((this.isValidSearchParams() && this.extraParams.isVideomeeting) || (this.isValidSearchParams() && (JSON.parse(JSON.stringify(this.filterValues)).Oficina__c!='' && typeof JSON.parse(JSON.stringify(this.filterValues)).Oficina__c != 'undefined'))) {
            this.getAvailabilityCall();
            //fireEvent(this.pageRef, 'search', null);   

        } else {
            showToast({variant : 'warning', 
                        message : validationMessage, 
                        title : ''}, this);      
        }  
    }


    handleSearch(payload) {
       // this.getAvailabilityCall();    
    }

    getAvailabilityCall() {

        this.showSpinner = true;
        this.activeTab = 'search';    

        let fromTime = this.searchFromDate + ' ' + this.startHour;
        let toTime = this.searchToDate + ' ' + this.endHour;

        let startDate = new Date(this.searchFromDate);
        let endDate = new Date(this.searchToDate);
        console.log('this.attendeeId: ',this.attendeeId);
        console.log('this.filterValues: ',JSON.parse(JSON.stringify(this.filterValues)));
        console.log('Oficina: ',JSON.parse(JSON.stringify(this.filterValues)).Oficina__c);

        let request = {
            attendeeId : this.attendeeId, 
            searchFromDate : new Date(startDate.getTime() - startDate.getTimezoneOffset() * 60000), // todo: adjust with set hour
            searchToDate : new Date(endDate.getTime() - endDate.getTimezoneOffset() * 60000),
            startHour : (this.startHour) ? new Date(fromTime) : null,
            endHour : (this.endHour) ? new Date(toTime) : null,
            duration : this.duration,
            userSelected : this.userSelected, 
            resourceSelected : this.resourceSelected, 
            filterValues : this.filterValues,
            searchByEvents : this.searchByEvents,
            extraParams : this.extraParams      
        }
		console.log('<<<<<<EXTRAPARAMSXX>>>>>>',JSON.stringify(this.extraParams));

        getAvailability({request : request})
        .then(result => {
            if (result.status){
                this.handleAvailabilitySearchResult(result);
            }else{
                showToast({variant : 'error', message : searchError, title : 'Error'}, this);
            }   
            this.showSpinner = false;        
        })
        .catch(error => {
            showToast({variant : 'error', message : searchError, title : 'Error'}, this);
            this.showSpinner = false;   
        });
    }

    
    handleAvailabilitySearchResult (searchResult) {     
        
        if(searchResult && searchResult.lTimeSlot.length && searchResult.lTimeSlot.length > 0) {
            //let eventPayload = {events : searchResult.lTimeSlot}

            //fireEvent(this.pageRef, 'refreshCalendar', eventPayload);   
            this.fireRefreshCalendarEvent(searchResult.lTimeSlot); 
            
            
            this.lResult = searchResult.lResult;
            this.lTimeSlot = searchResult.lTimeSlot;
            this.lResultResource = searchResult.lResultResource;
            this.activeTab = 'results';
        } else {
            //let eventPayload = {events : searchResult.lTimeSlot}
            //fireEvent(this.pageRef, 'refreshCalendar', eventPayload);  
            this.fireRefreshCalendarEvent(searchResult.lTimeSlot); 

            showToast({variant : 'warning', 
                        message : noResultMessage, 
                        title : ''}, this);    
        }
    }

   

    fireRefreshCalendarEvent(items) {
       
        let message = {
            id : this.attendeeId, 
            state : {
                events :  items
            }
        }
       
        fireEvent(this.pageRef, 'refreshCalendar', message);
   }


    isValidSearchParams() {
        console.log('this.resourceSelected: ',JSON.parse(JSON.stringify(this.resourceSelected)));
        console.log('this.userSelected: ',JSON.parse(JSON.stringify(this.userSelected)));
        
        let requirementsOk = (this.userSelected.length > 0) || (this.resourceSelected.length > 0);
        let datesOK = this.searchByEvents ? (this.searchFromDate && this.searchToDate) : (this.searchFromDate && this.searchToDate && this.duration);

 
        // Check custom validations
        let customValidationOK = true;
		
        console.log('this.customValidation: ',JSON.parse(JSON.stringify(this.customValidation)));
       
        if(this.customValidation) {

            // iterate conditions
            let j = 0;
            while (customValidationOK && (j < this.customValidation.length)) {
                          
                let splitted = this.customValidation[j].split('.');
                let aux;
				let controlOficina = false;
				
				
                // check single condition
				//if(splitted.includes(substring)){
					for(let i = 0; i < splitted.length; i++) {
						
						
						if(i === 0) {
							aux = this[splitted[i]];
							
							
						} else {
							controlOficina = splitted[i] == 'Oficina__c';
							aux = aux[splitted[i]];
							
						}
					}
				//}
				
                customValidationOK = controlOficina || (Array.isArray(aux) ? (aux.length > 0) : (aux !== undefined && aux !== ''));

				console.log('<<<<<<customValidationOKKKKK>>>>>>',customValidationOK);
				console.log('<<<<<<EXTRAPARAMS>>>>>>',JSON.stringify(this.extraParams));
				
                j++;
            }
        }

        return (requirementsOk || this.searchByEvents === true) && datesOK && customValidationOK;
    }

    connectedCallback() {
        registerListener('stateChange', this.handleStateChange, this);
        registerListener('openResultModal', this.handleOpenModal, this);
        registerListener('search', this.handleSearch, this);
        registerListener('refresh', this.handleRefresh, this);
    }

    handleRefresh() {
        
        let today = new Date();
        this.searchFromDate = today.getFullYear() + '-' + (today.getMonth()+1) + '-' + today.getDate();

        this.startHour = '';
        this.endHour = '';
        this.activeTab = 'search';

        let eventPayload = [];
       
        this.fireRefreshCalendarEvent(eventPayload);

    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleStateChange ( payload ) {
        
        if(payload && (payload.id === this.attendeeId)) {

            let state = payload.state;

            for(let att of Object.keys(state)) {
                
               if(typeof(this[att]) === 'object' && (!Array.isArray(this[att])) ) {
                this[att] = Object.assign( this[att],state[att] );
              
                } else {
                    this[att] = state[att]; 
                } 
                
            }
            
        }

    }

    handleOpenModal ( payload ) {
        
        if(payload && (payload.id === this.attendeeId)) {
            
            let timeSlot = this.lTimeSlot[payload.state.idx];

            if (this.searchByEvents){

                this.resultSelected = {
                    eventId : timeSlot.Id, 
                    startDate :  new Date(Date.parse(timeSlot.StartDateTime)),  
                    endDate : new Date(Date.parse(timeSlot.EndDateTime)),
                    attendeeId : this.attendeeId,
                    extraParams : this.extraParams
                };

                this.showResultModal = true;
            }else{         

                let resourceInfo = this.lResultResource[payload.state.idx];
                let lSplit = this.duration.split(':');
                let durationInMinutes = parseInt( lSplit[0], 10 ) * 60 + parseInt(lSplit[1], 10);
            
                this.resultSelected = {
                    startDate :  new Date(Date.parse(timeSlot.StartDateTime)),  
                    endDate : new Date(Date.parse(timeSlot.EndDateTime)), 
                    duration : durationInMinutes, 
                    attendeeId : this.attendeeId,
                    filterValues : this.filterValues, 
                    intervals : resourceInfo.lIntervalResource
                    
                };

                this.showResultModal = true;

            }
        }
        
    }

    handleCloseModal ( event ) {
        this.showResultModal = false;
    }

    handleAppointmentCreated ( event ) {
     
        this.resultSelected = {};
        this.lResult = [];
        this.lTimeSlot = [];
        
        let eventPayload = [];
        //fireEvent(this.pageRef, 'refreshCalendar', eventPayload); 

        this.fireRefreshCalendarEvent(eventPayload);
        
        this.lResultResource = [];
        this.activeTab = 'search';
    }

    handleOnSelectResult ( event ) {
     
        const item = this.findNested(this.lResult, 'name', event.detail.name);
        
        // if child node is clicked (parent only contains date)
        if(item.items.length === 0) {
            
            let message = {
                id : this.attendeeId, 
                state : {
                    idx :  item.name
                }
            }
        
            this.handleOpenModal(message);  
        }  
    }

    // Searches the object for the item containing a key of the provided name that contains the value provided
    findNested(obj, key, value) {
        // Base case
        if (obj[key] === value) {
            return obj;
        }
        // otherwise
        const objKeys = Object.keys(obj);
        for (const k of objKeys) {
            if (typeof obj[k] === 'object' || Array.isArray(obj[k])) {
                const found = this.findNested(obj[k], key, value);

                if (found) {
                    // If the object was found in the recursive call, bubble it up.
                    return found;
                }
            }
        }

        return null;
    }

    labels = {
   
        cardTitle,
        search,
        result,
        fromDate,
        toDate,
        fromHour,
        toHour,
        duration,
        searchButton
    }
    
}