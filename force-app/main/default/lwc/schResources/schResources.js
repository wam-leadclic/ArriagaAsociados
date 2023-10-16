import { LightningElement, wire, track, api } from 'lwc';

import { CurrentPageReference } from 'lightning/navigation';


import { parseUrlParams, showToast } from 'c/schHelper';
import { fireEvent } from 'c/pubsub';

import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CALENDAR_SETTING_OBJECT from '@salesforce/schema/CalendarSetting__c';


import cardTitle from '@salesforce/label/c.AppointmentTitle'
import needConfig  from '@salesforce/label/c.needMetadataConfig'
import resourceError from '@salesforce/label/c.ResourceError'
import videomeeting from '@salesforce/label/c.Videomeeting'
import notSendMail from '@salesforce/label/c.notSendMail'

export default class SchResources extends LightningElement {


    attendeeId;

    @track resourceCategories;

    @track userSelected = [];
    @track resourceSelected = [];
    @track optionsUser = [];
    @track optionsResource = [];
    @track optionsType = [];
    @track typeSelected = [];
	@track optionsMail = [];
	@track sendMail = [];

    @track pageRef;
    @track isError = false;
    @track isDataLoaded = false;

    @track isVideomeeting = false;

    @api userMode = 'check';      // check => displays chekbox group | radio => displays radio button group
   
   
    get isRadio () {
        return this.userMode === 'radio';
    }

    get userSelectedForComponent () {
        let returnValue = (this.userMode === 'radio' && Array.isArray(this.userSelected)) ? this.userSelected[0] : this.userSelected;
        return returnValue
    }

    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
        this.pageRef = currentPageRef;
        if(currentPageRef.state) {
            parseUrlParams(this.pageRef.state, this);
        }
    }

    // Resources type and subtype
    @wire(getPicklistValuesByRecordType, { objectApiName: CALENDAR_SETTING_OBJECT, recordTypeId : '012000000000000AAA'})
    getPicklistValues ({error, data}) {
        
        if (error) {
            showToast({variant : 'error', message : resourceError, title : 'Error'}, this)
        }
        
        if (data) {
            this.resourceCategories = {};
            this.optionsResource = [];
            this.optionsUser = [];
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
                // populate resource checkbox group
                for(let item of this.resourceCategories.Resource.lSubtype) {
                    this.optionsResource.push({label : item.label, value : item.value});
                }
                // populate user checkbox group
                for(let item of this.resourceCategories.User.lSubtype) {
                    this.optionsUser.push({label : item.label, value : item.value});
                }
                this.optionsType.push({label : "Videollamada", value: "Videollamada"});
                this.isDataLoaded = true;
                this.isError = false;

				this.optionsMail.push({label : "No enviar correo al cliente", value: "No enviar correo al cliente"});
                this.isDataLoaded = true;
                this.isError = false;

            } catch (exception) {
                this.isError = true;
                this.isDataLoaded = true;
            }
        } else {
            this.isError = true;
            this.isDataLoaded = true;
        }
    }

    handleChangeUser(e) {
        this.userSelected = e.detail.value;
        let userSelected = this.userSelected;

        if(!Array.isArray(userSelected)) {
            userSelected = [];
            userSelected.push(e.detail.value);
        }
        
        let message = {
            id : this.attendeeId, 
            state : {
                userSelected : userSelected
            }
        }
        
        
        fireEvent(this.pageRef, 'stateChange', message);
    }

    handleChangeResource(e) {
        this.resourceSelected = e.detail.value;
        
        let message = {
            id : this.attendeeId, 
            state : {
                resourceSelected : this.resourceSelected
            }
        }

        fireEvent(this.pageRef, 'stateChange', message);    
    }

    handleChangeType(event) {
		console.log('typeSelected<<',event.target.value)
        this.typeSelected = event.target.value;
        this.isVideomeeting = !this.isVideomeeting;
        console.log('isVideomeeting<< '+this.isVideomeeting);
        let message = {
            id : this.attendeeId, 
            state : {
                extraParams : {
                    typeSelected : this.typeSelected,
                    isVideomeeting: this.isVideomeeting
                }
            }
        }

        fireEvent(this.pageRef, 'stateChange', message);  
    }

    handleSendMail(event) {
		console.log('SENDMAIL<<',event.target.value)
        this.sendMail = event.target.value;

		let message = {
            id : this.attendeeId, 
            state : {
                extraParams : {
                    sendMail : this.sendMail
                }
            }
        }
        
        fireEvent(this.pageRef, 'stateChange', message);  
    }

    labels = {
        cardTitle, 
        needConfig,
        videomeeting,
		notSendMail
    }

}