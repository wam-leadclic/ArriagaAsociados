import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RecibiLWC extends NavigationMixin(LightningElement) {

    @api parentRecord;
    @track urlPage;

    clickGetPDF(){
        this.urlPage = window.location.origin + '/apex/Recibi?Id=' + this.parentRecord;
        console.log(this.urlPage);
        // Navigate to a URL
        /*this[NavigationMixin.Navigate]({
            "type": 'standard__webPage',
            "attributes": {
                "url": this.urlPage
            }
        },false);*/

        window.open(this.urlPage);
    }
}