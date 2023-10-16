import { LightningElement, track, wire } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { parseUrlParams } from 'c/schHelper';
import { CurrentPageReference } from 'lightning/navigation';

export default class SchAppointmentFilters extends LightningElement {



    @track attendeeId;
    @track showSpinner = false;
    
    // form values selecteds
    @track bussinessCountry = 'Country';
    @track eventType = 'Type';
   
    currentPageRef;

 
    handleFieldChange ( event ) {
    
        this.fireStateChangeEvent();
    }

    fireStateChangeEvent() {

        let message = {
            id : this.attendeeId, 
            state : {
                extraParams : {
                    AppointmentType__c : this.eventType
                }
            }
        }
        fireEvent(this.pageRef, 'stateChange', message);
   }

   @wire(CurrentPageReference)
   getUrlParams(currentPageRef) {
       this.pageRef = currentPageRef;
       if(currentPageRef.state) {
           parseUrlParams(this.pageRef.state, this);
       }
   }



}