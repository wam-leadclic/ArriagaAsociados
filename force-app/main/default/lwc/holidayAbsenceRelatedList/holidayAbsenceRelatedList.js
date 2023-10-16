import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHolidayAbsenceByCalendarId from '@salesforce/apex/HolidayAbsenceRelatedListController.getHolidayAbsenceByCalendarId';
import cardTitle from '@salesforce/label/c.holidayAbsenceRelatedListTitle'
import startAbsence from '@salesforce/label/c.startAbsence'
import endAbsence from '@salesforce/label/c.endAbsence'
import reasonAbsence from '@salesforce/label/c.reasonAbsence'
import nameAbsence from '@salesforce/label/c.nameAbsence'
import newAbsence from '@salesforce/label/c.newAbsence'
import accept from '@salesforce/label/c.Accept'
import cancel from '@salesforce/label/c.Cancel';
import titleNewAbsence from '@salesforce/label/c.titleNewAbsence';
import successNewAbsence from '@salesforce/label/c.successNewAbsence';
import successMessageNewAbsence from '@salesforce/label/c.successMessageNewAbsence';

export default class HolidayAbsenceRelatedList extends NavigationMixin(LightningElement) {

    @track lHolidayAbsence = [];
    @track calendarId;
    @track calendarSettingType;
    @track canCreateRecords;

    @track showSpinner;
    @track showModal = false;

    @api recordId;

    error;


    @wire(CurrentPageReference)
    getHolidayAbsence(){
        this.showSpinner = true;
        getHolidayAbsenceByCalendarId ({ calendarSettingId: this.recordId })
        .then(result => {
            if (result.status && result.lHolidayAbsence){
                this.lHolidayAbsence = result.lHolidayAbsence;
                this.calendarId = result.calendarId;
                this.calendarSettingType = result.calendarSettingType;
                this.canCreateRecords = result.canCreateRecords;
            }else{
                this.error = result.errorMsg;
            }
            this.error = undefined;
            this.showSpinner = false;
        })
        .catch(errorGetHolidayAbsence => {
            this.error = errorGetHolidayAbsence;     
            this.showSpinner = false;    
            console.log(JSON.stringify(error));
        });    
    }

    handleHolidayAbsenceView(event){
        // Navigate to contact record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'HolidayAbsence__c',
                actionName: 'view',
            },
        });
    }

     // Navigation to aura component HolidaAbsenceNew
     /*navigateToHolidayAbsenceNew() {
        this[NavigationMixin.Navigate]({
            "type": "standard__component",
            attributes: {
                "componentName": "c__HolidayAbsenceNew"

            },
            state: {
                "c__calendarSettingId": this.recordId,
                "c__calendarId": this.calendarId,
                "c__calendarSettingType": this.calendarSettingType
            }
        });
    }*/

    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        this.template.querySelector('lightning-record-edit-form').submit();
        this.handleSuccess();
     }

     handleSuccess(event) {
        const evt = new ShowToastEvent({
           title: successNewAbsence, 
           message: successMessageNewAbsence,
           variant: 'success'
        });
        this.closeModal();
        this.dispatchEvent(evt);   
  }

    onClickNewAbsence() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }

    labels = {
        cardTitle,
        nameAbsence,
        startAbsence,
        endAbsence,
        reasonAbsence,
        newAbsence,
        titleNewAbsence,
        accept,
        cancel
    }
}