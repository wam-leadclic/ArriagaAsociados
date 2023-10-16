import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import scheduler from '@salesforce/label/c.Scheduler';
import resources from '@salesforce/label/c.Resources';
import users from '@salesforce/label/c.Users';

import  getAvailability  from '@salesforce/apex/SchSearchController.getAvailability';

export default class SchContainer extends LightningElement {

    @api attendeeId;
    
    // calendar setup params
    @api openDate;
    @api endDate;
    @api startDate;

    // appointment search ranges
    @api searchFromDate;
    @api searchToDate;
    @api duration;

    //@track events;

    // extract URL params
    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
    
        this.initAttributes();

    }

    initAttributes () {
        //this.events = [];
        this.openDate = new Date().getTime();
        this.startDate = new Date(new Date().getFullYear(), 0, 1).getTime();
        this.endDate = new Date(new Date().getFullYear()+1, 11, 31).getTime();
    }



    label = {
        scheduler, 
        resources, 
        users
    }

}