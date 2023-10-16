import { LightningElement, track, wire } from 'lwc';

import { showToast } from 'c/schHelper';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CALENDAR_SETTING_OBJECT from '@salesforce/schema/CalendarSetting__c';

import getResourcesList from '@salesforce/apex/SchMainResourcesController.getResourcesList';
import getResourceEvents from '@salesforce/apex/SchMainResourcesController.getResourceEvents';

import showCalendarButton from '@salesforce/label/c.ShowCalendarButton';

import calendarError from '@salesforce/label/c.CalendarError'
import resourceError from '@salesforce/label/c.ResourceError'
import resourceName from '@salesforce/label/c.ResourceName'
import resourceSchedule from '@salesforce/label/c.ResourceSchedule'


export default class SchMainResources extends LightningElement {

    @track resourceCategories;

    @track mResources = [];

    @track startDate;
    @track endDate;
    @track openDate;

    @track showSpinner;

    label = {
        showCalendarButton,
        resourceName,
        resourceSchedule
    }

    @track openmodel = false;

    error;

    onClickShowCalendar(event) {
        this.showSpinner = true;
        getResourceEvents({ resourceId: event.target.value })
            .then(result => {
                if (result.status && result.lEvent){
                    this.lEvent = result.lEvent;
                    this.startDate = result.startDate;
                    this.endDate = result.endDate;
                    this.openDate = result.openDate;
                }else{
                    this.error = result.errorMsg;
                }
                this.error = undefined;
                this.showSpinner = false;
            })
            .catch(errorGetEvents => {
                this.error = errorGetEvents;     
                this.showSpinner = false;    
            });

        if (this.error){    
            showToast({variant : 'error', message : calendarError, title : 'Error'}, this)
        } else {
            this.openmodel = true;
        }
    }
    onClickCloseModal() {
        this.openmodel = false
    }


    // Resources type and subtype
    @wire(getPicklistValuesByRecordType, { objectApiName: CALENDAR_SETTING_OBJECT, recordTypeId : '012000000000000AAA'})
    getPicklistValues ({error, data}) {
        var mResource;

        if (error) {
            showToast({variant : 'error', message : resourceError, title : 'Error'}, this)
        }
        
        if (data) {
            this.resourceCategories = {};
            try {
                // parent picklist process
                for(let i = 0; i < data.picklistFieldValues.Type__c.values.length ; i++) {
                    let picklistValueInfo = {
                        info : data.picklistFieldValues.Type__c.values[i], 
                        lSubtype : []
                    }
                    this.resourceCategories[data.picklistFieldValues.Type__c.values[i].value] = picklistValueInfo;
                }
                for(let subtype of data.picklistFieldValues.Subtype__c.values) {
                    for(let controlField of subtype.validFor) {
                        let parent = Object.keys(data.picklistFieldValues.Subtype__c.controllerValues)[controlField];
                        this.resourceCategories[parent].lSubtype.push(subtype);
                    }
                }

                this.isDataLoaded = true;
                this.isError = false;
            } catch (exception) {
                this.isError = true;
                this.isDataLoaded = true;
            }

            if (this.resourceCategories){
                // Returns a Map with the User's List for each subtype
                getResourcesList({ resCategories: this.resourceCategories})
                    .then(result => {
                        if (result.status && result.mResource){
                            mResource = result.mResource;
                            for(let key in mResource){
                                // Preventing unexcepted data
                                if (mResource.hasOwnProperty(key)) { 
                                    this.mResources.push({value:mResource[key], key:key}); 
                                }
                            }
                        }else{
                            this.error = mResource.errorMsg;
                        }
                        this.error = undefined;
                    })
                    .catch(errorGetResources => {
                        this.error = errorGetResources;
                    });
            }

        } else {
            this.isError = true;
            this.isDataLoaded = true;
        }
    }

}