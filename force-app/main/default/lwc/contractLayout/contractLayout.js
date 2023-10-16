import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retrieveContractFields from '@salesforce/apex/ContractLayoutController.retrieveContractFields'

export default class ContractLayout extends LightningElement {

    @api recordId;
    @track lContractFieldSetLeft = [];
    @track lContractFieldSetRight =[];
    @track lContractField = [];
    @track isShowSpinner = true;

    connectedCallback () {

        retrieveContractFields()
            .then( result => {
                if (result.status) {                   
                    //this.lContractFieldSetLeft = result.lContractFields;
                    let index = 0;
                    this.lContractField = result.lContractFields;
                    for (let contractField of result.lContractFields){
                        if (index % 2 === 0){
                            this.lContractFieldSetLeft.push(contractField);
                        }else{
                            this.lContractFieldSetRight.push(contractField);
                        }
                        index++;
                    }
                } else {
                    this.showToast({variant : 'error', 
                                message : 'Error al obtener los datos del Expediente', title : 'Error'}, this);

                    console.log('Error: '+result.errorMsg);            
                }
                this.isShowSpinner = false;
            })
            .catch(error => {
                this.showToast({variant : 'error',
                            message : 'Error al obtener los datos del Expediente', title : 'Error'}, this);
                this.isShowSpinner = false;
                console.log('Error: '+JSON.stringify(error));
        });

    }


    showToast  = (payload, thisArgument) => {

        const showError = new ShowToastEvent({
            title: payload.title,
            message: payload.message,
            variant: payload.variant,
        });
        thisArgument.dispatchEvent(showError);       
    
    }

}