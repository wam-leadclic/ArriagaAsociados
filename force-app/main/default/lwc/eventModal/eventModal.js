import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import LOCATION_LABEL from '@salesforce/label/c.Location_Label';
import START_LABEL from '@salesforce/label/c.Start_Label';
import END_LABEL from '@salesforce/label/c.End_Label';
import MORE_DETAILS_LABEL from '@salesforce/label/c.More_Details_Label';
import NAMEEVENT from '@salesforce/label/c.NameEvent';

const CSS_CLASS = 'modal-hidden';

export default class EventModal extends NavigationMixin(LightningElement) {
    @track currentEvent = {};
    @track whoName;
    @api userTimeZone;

    @api locationLabel = "Location";
    @api startLabel = "Start";
    @api endLabel = "End";
    @api moreDetailsLabel = "More Details";
    @api nameEventLabel = 'Name';

    connectedCallback() {
        this.locationLabel = LOCATION_LABEL;
        this.startLabel = START_LABEL;
        this.endLabel = END_LABEL;
        this.moreDetailsLabel = MORE_DETAILS_LABEL;
        this.nameEventLabel = NAMEEVENT;
    }

    @api show(currentEvent) {
        this.currentEvent = currentEvent;
        this.whoName = currentEvent.Who.Name;
        const outerDivEl = this.template.querySelector('div');
        outerDivEl.classList.remove(CSS_CLASS);
    }

    @api hide() {
        const outerDivEl = this.template.querySelector('div');
        outerDivEl.classList.add(CSS_CLASS);
    }
    
    navigateToEvent(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.elementId,
                actionName: 'view',
            },
        });
    }
}