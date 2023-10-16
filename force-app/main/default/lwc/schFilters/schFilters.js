import { LightningElement, track, wire } from 'lwc';

import CALENDAR_SETTING_OBJECT from '@salesforce/schema/CalendarSetting__c';

import { parseUrlParams, showToast } from 'c/schHelper';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

import getFilters from '@salesforce/apex/SchFiltersController.getMetadataFilter'
import customSearch from '@salesforce/apex/LookupController.getCustomLookupResults';

import cardTitle from '@salesforce/label/c.SearchFilters'
import filtersError from '@salesforce/label/c.FiltersError'



export default class SchFilters extends LightningElement {


    attendeeId;

    @track lFilter;
    @track filterValues = {};

    @track isShowSpinner = true;
    @track isReadOnly;

    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
        this.pageRef = currentPageRef;
        if(currentPageRef.state) {
            parseUrlParams(this.pageRef.state, this);
        }
    }
    /*
    constructor() {
        super();  
    }
    */

    connectedCallback () {
        let params = {
            filterValues : this.filterValues
        }

        getFilters({params : params})
            .then( result => {
                if (result.status) {
                    
                    this.lFilter = result.lFieldConstraint;
                    
                    // init attribute object
                    for(let filter of this.lFilter) {
                        this.filterValues[filter.fieldName] = filter.value;
                    }
                    //fireEvent(this.pageRef, 'stateChange', {filterValues : this.filterValues});
                    
                    this.fireStateChangeEvent();

                } else {
                    showToast({variant : 'error', 
                                message : filtersError, title : 'Error'}, this);
                }
                this.isShowSpinner = false;
            })
            .catch(error => {
                showToast({variant : 'error',
                            message : filtersError, title : 'Error'}, this);
                this.isShowSpinner = false;
                console.log(JSON.stringify(error));
        });
    }

    
    // custom lookup search function
    handleSearch(event) {
        
        // field merge with filter values
        let constraint = event.target.fieldConstraint;
        for(let objectKey of Object.keys(this.filterValues)) {
            if (constraint.search(objectKey)) {
                constraint = constraint.replace(objectKey, '\'' + this.filterValues[objectKey] + '\'');
            }
        }

        // remove empty filters
        let splitByAND = constraint.split('AND');
       
        let index = splitByAND.length - 1;

        while (index >= 0) {
            if (splitByAND[index].includes('\'\'')) {
            splitByAND.splice(index, 1);
          }
        
          index -= 1;
        }
        
        // join filters and pass to back-end
        constraint = splitByAND.join('AND');
        event.detail.fieldConstraint = (constraint) ? constraint : ''; 
        
        customSearch(event.detail)
            .then(results => {
                this.template.querySelector('c-lookup').setSearchResults(results);
            })
            .catch(error => {
                console.log('Error in custom search ' + JSON.stringify(error));
            });
    }

    // custom lookup handle change function
    handleSelectionChange(event) {

        const selection = this.template.querySelector('c-lookup').getSelection();
        
        if(!event.target.isMultiEntry) {
            let value = (selection[0]) ? selection[0].id : '';
            this.filterValues[event.target.fieldName] = value;
        }
        
        this.fireStateChangeEvent();
    }

    handleFieldChange(event) {
        this.filterValues[event.target.fieldName] = event.target.value;
        this.fireStateChangeEvent();
    }
    
    fireStateChangeEvent() {
       
        let message = {
            id : this.attendeeId, 
            state : {
                filterValues :  this.filterValues
            }
        }
        
        fireEvent(this.pageRef, 'stateChange', message);
   }


    objectInfo = {
        objectName : CALENDAR_SETTING_OBJECT,
        fields : this.fields
    }

    labels = {
        cardTitle
    }


}