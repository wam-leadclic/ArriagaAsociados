import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const CSS_CLASS = 'modal-hidden';

export default class ExtraEventsModal extends NavigationMixin(LightningElement) {
    @track events;
    @track today;
    @api userTimeZone;

    @api show(extraEvents, mills) {
        this.today = mills;
        this.events = extraEvents;
        const divs = this.template.querySelectorAll('div');

        const outerDivEl = divs[0];
        outerDivEl.classList.remove(CSS_CLASS);
    }

    @api hide() {
        const outerDivEl = this.template.querySelector('div');
        outerDivEl.classList.add(CSS_CLASS);
    }

    handleEventClick(event) {
        let eventId = event.target.dataset.elementId;
        let eventIdx = event.target.dataset.elementIdx;
        const openEvent = new CustomEvent('handleeventclick', {
            detail: {
                elementId: eventId,
                elementIdx: eventIdx
            }
        });

       this.dispatchEvent(openEvent);
    }
}