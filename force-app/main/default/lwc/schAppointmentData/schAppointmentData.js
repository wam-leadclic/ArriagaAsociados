import { LightningElement, track, wire } from 'lwc';
import { fireEvent } from 'c/pubsub';
import { parseUrlParams } from 'c/schHelper';
import { CurrentPageReference } from 'lightning/navigation';

export default class SchAppointmentData extends LightningElement {



    @track attendeeId;
    @track showSpinner = false;
    
   
    currentPageRef;

    @track filterValues = {
        Clinic__c : 'Clinic', 
        Specialist__c : 'Medic'
    }

    @track consultant = 'Consultor';
 
    

    handleFieldChange ( event ) {
        // TODO : Detectar el cambio que se está cambiando para modificar los campos de filtervalues correctos
        // miFilterValue = event.target.value

        // search state update
        this.fireStateChangeEvent();
    }

    fireStateChangeEvent() {

        let message = {
            id : this.attendeeId, 
            state : {
                filterValues : this.filterValues, 
                extraParams : {
                    Consultant__c : this.consultant
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