import { LightningElement, api, track } from 'lwc';
//Llamar a clase Apex
import getTipoDerivado from '@salesforce/apex/ExpedienteDerivadoController.getTipoDerivado'
import creacionExpediente from '@salesforce/apex/ExpedienteDerivadoController.creacionExpediente'
import checkExpedienteDerivado from '@salesforce/apex/ExpedienteDerivadoController.checkExpedienteDerivado'
//Importar etiquetas
import expDerivadoTituloInformacion from '@salesforce/label/c.expDerivadoTituloInformacion';
import expDerivadoCliente from '@salesforce/label/c.expDerivadoCliente';
import expDerivadoOportunidad from '@salesforce/label/c.expDerivadoOportunidad';
import expDerivadoIdentificador from '@salesforce/label/c.expDerivadoIdentificador';
import expDerivadoLabelComp from '@salesforce/label/c.expDerivadoLabelComp';
import expDerivadoTituloComponente from '@salesforce/label/c.expDerivadoTituloComponente';
import expDerivadoErrorNoGestionado from '@salesforce/label/c.expDerivadoErrorNoGestionado';
import expDerivadoErrorNoDerivarExp from '@salesforce/label/c.expDerivadoErrorNoDerivarExp';
import errorSinTipoDerivado from '@salesforce/label/c.errorSinTipoDerivado';
//Mostrar toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExpedienteDerivado extends LightningElement {
    @track openModal = false;
    @track option = [];
    @track value;
    @track numExp;
    @track oppName;
    @track accountName;
    //obtener el Id del Expediente
    @api recordId;
    //Etiquetas personalizadas
    label = {
        expDerivadoTituloInformacion,
        expDerivadoCliente,
        expDerivadoOportunidad,
        expDerivadoIdentificador,
        expDerivadoLabelComp,
        expDerivadoTituloComponente,
        errorSinTipoDerivado
    };

    connectedCallback() {        
        getTipoDerivado()
            .then(result => {  
                //console.log('Result1 : ' + result);
                for( var opp in result){
                    this.option.push({ label: result[opp], value: result[opp] });
                }
            })
            .catch(error => {                    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: expDerivadoErrorNoGestionado,
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    onclickabrirModal(){
        this.openModal = true;
    }
    onclickApex(){
        if(this.value !== undefined){
            checkExpedienteDerivado({contractId : this.recordId})
                .then(result => { 
                    if(result == true){
                        creacionExpediente({contractId : this.recordId, tipoDerivado: this.value})
                            .then(result => {  
                                this.openModal= false; 
                                window.open(result, "_self");  
                            })
                            .catch(error => {                    
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: expDerivadoErrorNoGestionado,
                                        message: error.body.message,
                                        variant: 'error',
                                    }),
                                );
                            });
                    }
                    else{
                        this.dispatchEvent(
                            new ShowToastEvent({
                                message: expDerivadoErrorNoDerivarExp,
                                variant: 'warning',
                            }),
                        );
                    }
                })
                .catch(error => {                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: expDerivadoErrorNoGestionado,
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: errorSinTipoDerivado,
                    variant: 'error',
                }),
            );
        }
    }
    onclickcloseModal(){
        this.openModal= false;
    }
    handleChangePickList(event) {
        //console.log('Valor : ' + event.detail.value);
        this.value = event.detail.value;
    }
}