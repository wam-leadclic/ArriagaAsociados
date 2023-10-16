import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getTypeDocumentList from '@salesforce/apex/GDRestCallouts.getTypeDocumentList';
import deleteTypeDocument from '@salesforce/apex/GDRestCallouts.deleteTypeDocument';
import setTypeDocument from '@salesforce/apex/GDRestCallouts.setTypeDocument';
import renameTypeDocument from '@salesforce/apex/GDRestCallouts.renameTypeDocument';
//Recuperamos las etiquetas personalizadas
import GDTipologiaDocumentos from '@salesforce/label/c.GDTipologiaDocumentos';
import GDNuevo from '@salesforce/label/c.GDNuevo';
import GDCategoria from '@salesforce/label/c.GDCategoria';
import GDTipo from '@salesforce/label/c.GDTipo';
import GDNuevaTipologiaDocumentos from '@salesforce/label/c.GDNuevaTipologiaDocumentos';
import GDCrear from '@salesforce/label/c.GDCrear';
import GDNumCategoria from '@salesforce/label/c.GDNumCategoria';
import GDNombretipoDocumento from '@salesforce/label/c.GDNombretipoDocumento';
import GDErrorRecuperarTipologia from '@salesforce/label/c.GDErrorRecuperarTipologia';
import GDErrorEliminarDocumento from '@salesforce/label/c.GDErrorEliminarDocumento';
import GDErrorCrearTipologiaDocumento from '@salesforce/label/c.GDErrorCrearTipologiaDocumento';
import GDTituloError from '@salesforce/label/c.GDTituloError';
import GDModificarNombreTipologia from '@salesforce/label/c.GDModificarNombreTipologia';
import GDNuevoNombreTipologia from '@salesforce/label/c.GDNuevoNombreTipologia';
import GDGuardar from '@salesforce/label/c.GDGuardar';
import GDErrorModificarNombreTipologia from '@salesforce/label/c.GDErrorModificarNombreTipologia';

export default class GDDocumentTypeSetup extends LightningElement {
    @track lItem = [];
    @track error;
    @track loaded = false;
    @track mostrarModal = false;
    @track categoriaPadre;
    @track nombreTipoDocumento;
    @track spinner = false;
    @track mostrarModalModificacion = false;
    @track nuevoNombreTipologia;
    @track idTipologiaModificada;
    @track nombreActualTipologiaDocumento;

    constructor() {
        super();
        this.handleLoad();     
    }

    // component load event
    handleLoad() {
        this.spinner = true;
        getTypeDocumentList()
            .then(result => {
                if (!result.status) {
                    const event = new ShowToastEvent({
                        title: GDTituloError,
                        message: GDErrorRecuperarTipologia,
                    });
                    this.dispatchEvent(event);
                } else {
                    this.lItem = result.lItems;
                }
                this.loaded = true;
                this.spinner = false;
            })
            .catch(error => {
                this.error = error;
                this.loaded = true;
                this.spinner = false;
            });
    }

    //Eliminación de la tipología de documentos
    eliminarTipologia(event){     
        this.spinner = true;   
        deleteTypeDocument({ id : event.target.value, refresco: true})
            .then(result => {                
                if (!result.status) {
                    const event = new ShowToastEvent({
                        title: GDTituloError,
                        message: GDErrorEliminarDocumento,
                    });
                    this.dispatchEvent(event);
                } else {
                    this.lItem = result.lItems;
                }
                this.loaded = true;
                this.spinner = false;
            })
            .catch(error => {
                this.error = error;
                this.loaded = true;
                this.spinner = false;
        });
        
    }

    //Crear una tipología
    nuevaTipologia(){
        this.mostrarModal = true;        
    }
    
    asignarCategoriaPadre(event){
        this.categoriaPadre = event.target.value;
    }

    asignaNombreTipoDocumento(event){
        this.nombreTipoDocumento = event.target.value;
    }

    //Llamamos al WS para la creación del nuevo tipo de tipología
    crearTipoDocumento(){          
        this.spinner = true;                          
        setTypeDocument({ parentId : this.categoriaPadre, nombreType:this.nombreTipoDocumento , refresco: true})
            .then(result => {                
                if (!result.status) {
                    const event = new ShowToastEvent({
                        title: GDTituloError,
                        message: GDErrorCrearTipologiaDocumento,
                    });
                    this.dispatchEvent(event);
                } else {
                    this.lItem = result.lItems;
                    this.mostrarModal = false;
                }
                this.loaded = true;
                this.spinner = false;
            })
            .catch(error => {
                this.error = error;
                this.loaded = true;
                this.spinner = false;
        });
        
    }

    //Método para cerrar el modal
    cerrarModal(){
        this.mostrarModal = false;
        this.mostrarModalModificacion = false; 
    }

    //Mostrar popup para indicar el nuevo nombre de tipologia
    modificarTipologiaPopUp(event){
        this.idTipologiaModificada = event.target.value;        
        //Recorremos los documentos actuales para recuperar el nombre actual de la tipología de la documentación
        for(var i = 0; i < this.lItem.length; i++){
            if(this.lItem[i].id == this.idTipologiaModificada){
                this.nombreActualTipologiaDocumento = this.lItem[i].name;
            }            
        }

        this.mostrarModalModificacion = true;        
    }

    asignaNuevoNombreTipoDocumento(event){
        this.nuevoNombreTipologia = event.target.value;
    }

    //Método que se encarga de modifcar el nombre del tipo de documento
    modificarTipologia(){       
        this.spinner = true;   
        renameTypeDocument({ id : this.idTipologiaModificada, newName : this.nuevoNombreTipologia, refresco: true})
            .then(result => {                
                if (!result.status) {
                    const event = new ShowToastEvent({
                        title: GDTituloError,
                        message: GDErrorModificarNombreTipologia,
                    });
                    this.dispatchEvent(event);
                } else {
                    this.lItem = result.lItems;
                }
                this.loaded = true;
                this.spinner = false;
                this.mostrarModalModificacion = false; 
            })
            .catch(error => {
                this.error = error;
                this.loaded = true;
                this.spinner = false;
        });
    }


    //Etiquetas personalizadas
    label = {
        GDTipologiaDocumentos, 
        GDNuevo,
        GDCategoria,
        GDTipo,
        GDNuevaTipologiaDocumentos,
        GDCrear, 
        GDNumCategoria,
        GDNombretipoDocumento, 
        GDModificarNombreTipologia,
        GDNuevoNombreTipologia,
        GDGuardar
    };

}