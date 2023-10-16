import { LightningElement, track, api } from 'lwc';
import getNotifications from '@salesforce/apex/NotificationBellLayoutController.getNotifications';
import customChatterTitle from '@salesforce/label/c.customChatterTitle';
import customChatterCardTitle from '@salesforce/label/c.customChatterCardTitle';

export default class ContractChatterLayout extends LightningElement {

    @api recordId;
    @track lContractChatterFeeds = [];
    @track lContractChatterFeedBody = [];
    @track isShowSpinner = true;

    connectedCallback () {
        console.log(this.recordId)
        getNotifications({noTime: false,recordId:this.recordId})
        .then( result => {
            console.log(result);
            if (result!=null) {
                this.lContractChatterFeedBody=result;
                    
                this.isShowSpinner = false;
            }
            this.isShowSpinner = false;
        })
        .catch(error => {
            console.log(error);
            this.isShowSpinner = false;
        });
    }
    label={
        customChatterTitle,
        customChatterCardTitle
    }
}