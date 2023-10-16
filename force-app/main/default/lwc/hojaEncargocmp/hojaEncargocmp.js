import { LightningElement, wire, api, track } from 'lwc';
// import apex class. 
import getConfirmarHojaCargada from '@salesforce/apex/hojaEncargoControllerlwc.getConfirmarHojaCargada'
import getHojasEncargo from '@salesforce/apex/hojaEncargoControllerlwc.getHojasEncargo'
import validacionProducto from '@salesforce/apex/hojaEncargoControllerlwc.validacionProducto'
import rellenarCampos from '@salesforce/apex/hojaEncargoControllerlwc.rellenarCampos'
import vaciarCampos from '@salesforce/apex/hojaEncargoControllerlwc.vaciarCampos'
import validacionGeneracionPDF from '@salesforce/apex/hojaEncargoControllerlwc.validacionGeneracionPDF'
//Mostrar toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//Acceder a las etiquetas
import ErrorNoGestionado from '@salesforce/label/c.ErrorNoGestionado';
import ExitoHojaEncago from '@salesforce/label/c.ExitoHojaEncago';
import HojaEncargoCard from '@salesforce/label/c.HojaEncargoCard';
import BotonSeleccionar from '@salesforce/label/c.BotonSeleccionar';
import OportunidadConProducto from '@salesforce/label/c.OportunidadConProducto';
import HojaEncargoNoSeleccionado from '@salesforce/label/c.HojaEncargoNoSeleccionado';
import ModalSeleccionarHoja from '@salesforce/label/c.ModalSeleccionarHoja';
import ModalTablaCol1 from '@salesforce/label/c.ModalTablaCol1';
import ModalTablaCol2 from '@salesforce/label/c.ModalTablaCol2';
import ModalTablaCol3 from '@salesforce/label/c.ModalTablaCol3';
import ModalTablaCol4 from '@salesforce/label/c.ModalTablaCol4';
import ModalTablaBtnCancelar from '@salesforce/label/c.ModalTablaBtnCancelar';
import BotonCambiar from '@salesforce/label/c.BotonCambiar';
import BotonGenPDF from '@salesforce/label/c.BotonGenPDF';
import NoGenerarPDF from '@salesforce/label/c.NoGenerarPDF';

import { NavigationMixin } from 'lightning/navigation';
import {updateRecord} from 'lightning/uiRecordApi';

import ID_FIELD from '@salesforce/schema/Opportunity.Id';
import CUSTOMHDE_FIELD from '@salesforce/schema/Opportunity.HojaEncargoPersonalizada__c';


export default class HojaEncargocmp extends NavigationMixin(LightningElement) {
    @track noHdE = true;
    @track HdE = false;
    @track openModal = false;
    //Datos guardados de la tabla seleccionando las hojas de encargo
    @track idHdE;
    @track TipoDoc;
    @track CodigoDoc;
    @track Producto;
    NameHdE;
    @track urlLinkPDF;

    @track isCustomHdE;

    //obtener el Id de la oportunidad
    @api recordId;
    // return data from apex class.
    @track camposHojaEncargo; 
    @track error; // to show error message from apex controller.
    @track success; // to show succes message in ui.
    //Cargar etiquetas para usarlas en el formulario
    // Expose the labels to use in the template.
    label = {
        HojaEncargoCard,
        BotonSeleccionar,
        HojaEncargoNoSeleccionado,
        ModalSeleccionarHoja,
        ModalTablaCol1,
        ModalTablaCol2,
        ModalTablaCol3,
        ModalTablaCol4,
        ModalTablaBtnCancelar,
        BotonCambiar,
        BotonGenPDF,
        NoGenerarPDF
    };

    //Iniciamos el componente comprobando si ya hay una hoja de encargo cargada
    connectedCallback() {
        //this.urlLinkPDF = window.location.origin + '/apex/PDFHojaEncargo?id='+this.recordId;
        // initialize component
        getConfirmarHojaCargada({ idOportunidad: this.recordId })
            .then(result => {  
                //console.log('Result : ' + result[0].tipoHoja);
                if(result[0].hojaEncargoYaRelacionada == true){
                    
                    console.log(JSON.stringify(result));

                    //Cargamos los valores de la hoja de encargo
                    this.idHdE = result[0].idHoja;
                    this.TipoDoc = result[0].tipoHoja;
                    this.CodigoDoc = result[0].codigoPlantilla;
                    this.Producto = result[0].producto;
                    this.nameHdE = result[0].name;
                   
                    this.isCustomHdE = result[0].isCustomHdE;

                    this.urlLinkPDF = ( this.isCustomHdE ) ? '' : window.location.origin + '/' + result[0].idHoja;
                    
                    //Escondemos las secciones que no necesitamos y mostramos la del pdf
                    this.openModal = false;
                    this.noHdE = false;
                    this.HdE = true;  
                }                
            })
            .catch(error => {                    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ErrorNoGestionado,
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    onclickSeleccionarHdE(event) {
        console.log(this.recordId)
        validacionProducto({ idOportunidad: this.recordId })
            .then(result => {  
                if (result == false){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: OportunidadConProducto,
                            variant: 'error',
                        }),
                    );
                }else{    
                    this.openModal = true;
                }   
            })
            .catch(error => {                    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ErrorNoGestionado,
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
            getHojasEncargo({ idOportunidad: this.recordId })
                    .then(result => {  
                    this.camposHojaEncargo = result;   
                    })
                    .catch(error => {                    
                        this.dispatchEvent(
                        new ShowToastEvent({
                            title: ErrorNoGestionado,
                            message: error.body.message,
                            variant: 'error',
                    }),
                );
            });
        
    }
    onclickcargarHdE(event) {        
        
        
        this.isCustomHdE =  event.target.value.isCustomHdE;
        this.idHdE = event.target.value.idHoja;
       
        this.CodigoDoc = event.target.value.codigoPlantilla;
        this.nameHdE = event.target.value.name;
        this.urlLinkPDF = window.location.origin + '/' + event.target.value.idHoja;
        
        this.TipoDoc = (this.isCustomHdE) ? 'Hoja de Encargo' : event.target.value.tipoHoja;
    
    
        rellenarCampos({ idOportunidad: this.recordId, idHojaEncargo: this.idHdE, isCustomHdE : this.isCustomHdE })
        .then(result => {                
            this.dispatchEvent(
                new ShowToastEvent({
                    message: ExitoHojaEncago,
                    variant: 'Success',
                }),
            );
            
            this.openModal = false;
            this.noHdE = false;
            this.HdE = true;
            
        })
        .catch(error => {                    
            this.dispatchEvent(
                new ShowToastEvent({
                    title: ErrorNoGestionado,
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
  
        
    }
    
    onclickcloseModal(event) {
        this.openModal = false;
    }
    onclickcambiarHdE(event) {        
        vaciarCampos({ idOportunidad: this.recordId})
            .then(result => {     
                               
            })
            .catch(error => {                    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ErrorNoGestionado,
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        this.noHdE = true;
        this.HdE = false;
    }
    /*
    Método que se encarga de llamar a la VF que muestra el PDF de la Hoja de Encargo
    */
    onclickgnPDF(event) {   
        
        if(this.isCustomHdE) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'La hoja de Encargo es personalizada, debe estar cargada en el Gestor Documental',
                    variant: 'warning'
                }),
            );

        } else {
            validacionGeneracionPDF({ idOportunidad: this.recordId}) 
            .then(result => {     
                if(result){
                    window.open ('/apex/PDFHojaEncargo?id='+this.recordId ,"mywindow","width=750,height=750");
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: ErrorNoGestionado,
                            message: NoGenerarPDF,
                            variant: 'error'
                        }),
                    );
                }                       
            })

        }
        
        
    }

    
}