import { LightningElement, track, wire } from 'lwc';

import { showToast } from 'c/schHelper';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CALENDAR_SETTING_OBJECT from '@salesforce/schema/CalendarSetting__c';

import getUserList from '@salesforce/apex/SchUsersController.getUsersList';
import getUserEvents from '@salesforce/apex/SchUsersController.getUserEvents';

import showCalendarButton from '@salesforce/label/c.ShowCalendarButton';

import userError from '@salesforce/label/c.UserError'
import resourceError from '@salesforce/label/c.ResourceError'
import userName from '@salesforce/label/c.UserName'
import userPhone from '@salesforce/label/c.UserPhone'
import UserMail from '@salesforce/label/c.UserMail'
import userSchedule from '@salesforce/label/c.UserSchedule'

export default class SchUsers extends LightningElement {
   
    @track resourceCategories;
    @track mUsers = [];
    
    @track lEvent;

    @track startDate;
    @track endDate;
    @track openDate;  

    @track showSpinner;

    label = {
        showCalendarButton,
        userName,
        userPhone,
        UserMail,
        userSchedule
    }

    @track openmodel = false;

    error;

    onClickShowCalendar(event) {
        this.showSpinner = true;
        getUserEvents({ userId: event.target.value })
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
            showToast({variant : 'error', message : userError, title : 'Error'}, this);
            console.log(JSON.stringify(this.error));
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
        var mUser;

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
                getUserList({ userCategories: this.resourceCategories})
                    .then(result => {
                        if (result.status && result.mUser){
                            mUser = result.mUser;
                            for(let key in mUser){
                                // Preventing unexcepted data
                                if (mUser.hasOwnProperty(key)) { 
                                    this.mUsers.push({value:mUser[key], key:key}); 
                                }
                            }
                        }else{
                            this.error = result.errorMsg;
                        }
                        this.error = undefined;
                    })
                    .catch(errorGetUsers => {
                        this.error = errorGetUsers;
                    });
            }

        } else {
            this.isError = true;
            this.isDataLoaded = true;
        }
    }

}