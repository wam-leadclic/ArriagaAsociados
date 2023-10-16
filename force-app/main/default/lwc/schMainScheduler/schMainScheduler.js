import { LightningElement, api, track } from 'lwc';

export default class SchMainScheduler extends LightningElement {

    @api attendeeId;

    // calendar setup params
    @api openDate;
    @api endDate;
    @api startDate;

    // appointment search ranges
    @api searchFromDate;
    @api searchToDate;
    @api duration;

    // resources selected
    @api userSelected;
    @api resourceSelected;
    @track typeSelected = [];
	@track sendMail;

    @api startHour;
    @api endHour;
  
    @api resourceCategories;
    @api events;

    handleProgressValueChange(event) {
        this.typeSelected = event.detail;
    }
}