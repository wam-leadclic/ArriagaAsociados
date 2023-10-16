import { LightningElement, track, api } from 'lwc';
import customChatterTitle from '@salesforce/label/c.customChatterTitle';
import getNotifications from '@salesforce/apex/NotificationBellLayoutController.getNotifications';
import customChatterCardTitle from '@salesforce/label/c.historyCustomChatterCardTitle';
export default class ChatterLayout extends LightningElement {
    
    @track lContractChatterFeedBody = [];
    @track isShowSpinner = true;

    connectedCallback () {
        getNotifications({noTime: false,recordId:''})
        .then( result => {
            console.log(result)
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