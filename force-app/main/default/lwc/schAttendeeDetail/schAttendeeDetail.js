import { LightningElement, api, wire, track } from 'lwc';
import { getRecordUi } from 'lightning/uiRecordApi';
import attendeeName from '@salesforce/label/c.AttendeeName';
import change from '@salesforce/label/c.Change';

import { parseUrlParams, showToast } from 'c/schHelper';
import { CurrentPageReference } from 'lightning/navigation';

import { fireEvent } from 'c/pubsub';

export default class SchAttendeeDetail extends LightningElement {

    @api attendeeId;
    @track iconName = 'standard:lead';
    @track attendeeName = attendeeName;
    @track recordInfo 

    @track isDataLoaded = false;
    
    label = {
        attendeeName, 
        change
    }

    pageRef;

    // extract URL params
    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
        
        if(currentPageRef.state) {
            this.pageRef = currentPageRef;
            parseUrlParams(currentPageRef.state, this);
        }
    }

    @wire(getRecordUi, { recordIds: '$attendeeId', layoutTypes: ['Compact'], modes : ['View'] })
    updateRecordInfo({error, data}) {
        
        if (error) {
            showToast({
                title: '$Error', message: '$Ha ocurrido un error al recuperar los datos del cliente', variant: 'error',
            })
        }
        
        if (data) {
            this.recordInfo = this.getRecordInfo(data);
            this.iconName = this.getIconName(this.recordInfo.apiName);
            this.attendeeName = this.recordInfo.recordName; 

            // if attendeeId changes force a public refresh event.
            fireEvent(this.pageRef, 'refresh', {});
            console.log('fired refresh');
        } 
        this.isDataLoaded = true;   
    }

    getRecordInfo (record) {

        var recordInfo =  {
            apiName : '', 
            fields : [], 
            recordName : ''
        }

       
        var recordId = Object.keys(record.records)[0];
        var objectName = record.records[recordId].apiName; 

        recordInfo.apiName = objectName;
        
        var layoutId = Object.keys(record.layouts[objectName]);
        var rows = record.layouts[objectName][layoutId].Compact.View.sections[0].layoutRows;
        var firstName = record.records[recordId].fields.FirstName.value;
        var lastName = record.records[recordId].fields.LastName.value;

        if(record.records[recordId].fields.FirstName.value) {
            recordInfo.recordName = record.records[recordId].fields.FirstName.value;    
        }

        if(record.records[recordId].fields.LastName.value) {
            recordInfo.recordName += ' ' + record.records[recordId].fields.LastName.value;
        }

        if(!recordInfo.recordName) {
            recordInfo.recordName = '$Información del Contacto'
        }

        for(var i = 0; i < rows.length ; i++) {
            
            for(var j = 0; j < rows[i].layoutItems.length; j++) {
                for(var k = 0; k < rows[i].layoutItems[j].layoutComponents.length; k++) {
                    recordInfo.fields.push(rows[i].layoutItems[j].layoutComponents[k].apiName);
                }
            }
        }

        return recordInfo;
    }

    disconnectedCallback() {

        console.log('DISCONECTED CALLBACK!!!! DETAIL !!');

    }

   getIconName(apiName) {
        var name;
        switch (apiName) {
            case 'Lead':
            name = 'standard:lead';
                break;
            case 'Contact':
            name = 'standard:contact';
                break;
            default:
            name = 'standard:account';
                break;
        }
        return name;
   }

}