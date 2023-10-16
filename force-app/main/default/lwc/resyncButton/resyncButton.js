import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import sendData from '@salesforce/apex/ResyncButtonController.sendData';

export default class resyncButton extends LightningElement {


    @api recordId;    



    handleClick(event) {

        sendData( {recordId : this.recordId} )
        .then(result => {
            this.showToast('', 'Llamada realizada a los sistemas externos', 'success');
        })
        .catch(error => {
            this.showToast('', 'Ha ocurrido un error en la llamada a los sistemas externos', 'error');    
        });    



    }

    showToast( title, message, variant ) {
        const event = new ShowToastEvent({
            title: title,
            message: message, 
            variant : variant,
            mode : 'pester'
        });
        this.dispatchEvent(event);
    }



}