import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import { updateRecord } from 'lightning/uiRecordApi';
import  getDocTypes  from '@salesforce/apex/GDDocumentListController.getDocTypes';


import getDocumentList from '@salesforce/apex/GDRestCallouts.getDocumentList';
import getFieldDoc from '@salesforce/apex/GDDocumentListController.getFieldDoc';
import editDocument from '@salesforce/apex/GDRestCallouts.editDocument';
import getAuthToken from '@salesforce/apex/GDRestCallouts.getAuthToken';
import sendNotificationEmail from '@salesforce/apex/GDRestCallouts.sendNotificationEmail';
import getDocumentData from '@salesforce/apex/GDRestCallouts.getDocumentData';
import fileMaxSize from '@salesforce/label/c.fileMaxSizeCommunity';
import upload from '@salesforce/label/c.GDCargarCommunity';
import document from '@salesforce/label/c.GDDocumentoCommunity';
import appName from '@salesforce/label/c.GDGestorDocumentalCommunity';
import choose from '@salesforce/label/c.GDSeleccioneCommunity';
import documentType from '@salesforce/label/c.GDTipoDocumentoCommunity';
import cancel from '@salesforce/label/c.GDCancelarCommunity';
import mensajeDescDoc from '@salesforce/label/c.MensajeDescargaDocCommunity';
import sinDocumentosCargados from '@salesforce/label/c.sinDocumentosCargadosCommunity';
import edit from '@salesforce/label/c.GDEditCommunity';
import newTypeDoc from '@salesforce/label/c.GDNuevoTipoCommunity';
import newNameDoc from '@salesforce/label/c.GDNuevoNombreCommunity';
import newExpDoc from '@salesforce/label/c.GDNuevoExpCommunity';
import newExpCli from '@salesforce/label/c.GDNuevoCliCommunity';
import getRecordCommunity from '@salesforce/apex/GDRestCallouts.getRecordCommunity';
import textoInformativo from '@salesforce/label/c.GDTextoInformativoCommunity';
import errorMessageFileTypeMinervaCommunity from '@salesforce/label/c.errorMessageFileTypeMinervaCommunity';

export default class gdDocumentItemsCommunity extends LightningElement {
    label = {
            fileMaxSize,
         };

    // component record context
    @api recordId='';
    @api objectApiName;

    // component attributes
    @track showUploadModal = false;
    documentType = '';
    @track documentId;
    documentName;
    @track token;
    @track idExpediente;
    @track idCliente;
    @track maxSize;
    @track sinDocs;
    @track editDocPop = false;
    oportunityActive=false;
    // Inputs Edit doc
    nuevoNombre;
    nuevosExp;
    nuevodocumentType = '';
    nuevosCli;
    //fichero = {};

    @track loaded = false;
    @track loadedModal = false;
    @track lItem=[];
    @track lFields;
    @track error;
    @track myDocuments=true;

    @track option = [];

    // Object record
    @track object;

    // get list document by offset and limit
    @track idExpDoc = [];
    @track idCustDoc = [];
    @track id;
    @track campoFiltro = null;
    @track ordenFiltro = null;
    @track pageNumb = 1;
    @track offset = 0;
    @track total = 0;
    @track totalPages;
    @track isClosedOpp;
    @track GDURLAddDocument='';
    @track URL_DOWNLOAD='';


    // estilo botones paginación
    @track styleAnte =  true;
    @track styleSig =  true;

    //Upload Documents
    //@track formUpload = this.template.querySelector('#formDoc');
    @track formDataUpload;

    //Mapa para guardar los valores de los campos dinámicos según el tipo de documento seleccionado
    mapDynamicField = new Map();

    @wire(getRecordCommunity,{recordId:'$recordId'})
    objectRecord({ error,data }){
        this.loaded = true;
        this.myDocuments= this.recordId==null||this.recordId=="";
        console.log("data "+data);
        console.log("error "+error);
        if(data){
            console.log(data);
            this.GDURLAddDocument=data.gdURLDocument;
            this.URL_DOWNLOAD =data.gdURLDocument;
            this.idExpDoc=data.idExpedienteMinerva;
            this.idExpediente = data.idExpedienteMinerva;
            this.idCliente = data.idClienteMinerva;
            this.oportunityActive=data.oportunityActive;
            this.idCustDoc.push( this.idCliente);
            
            console.log(this.idCustDoc[0]);
            this.handleLoad();
        }
        else{
            this.loaded = false;
            const toast = new ShowToastEvent({
                title: 'Ops!',
                message: 'Ha ocurrido un error al recuperar los documentos',
                variant: 'error'
            });
            this.dispatchEvent(toast);
        }
    }

    @wire(getDocTypes)
    globalValues({ error, data }) {
        if(data){
            for(var op in data) {
                this.option.push({ label: data[op].ValorEtiqueta__c, value: data[op].ExternalID__c });
            }
        }

    }
    // component load event
    handleLoad() {
        this.loaded = true;
        let customerCustom=(this.myDocuments)?this.idCustDoc:[];
        getDocumentList({ lCustomer :customerCustom , lExpedients : this.idExpDoc, pageNumb : this.pageNumb,community:true})
            .then(result => {
                this.lItem = [];
                if (!result.status) {
                    if(result.statusCode === 404){
                        this.sinDocs = true;
                    }else{
                        const toast = new ShowToastEvent({
                            title: 'Ops!',
                            message: 'Ha ocurrido un error al recuperar los documentos',
                            variant: 'error'
                        });
                        this.dispatchEvent(toast);
                    }
                    this.totalPages = 1;
                    this.loaded = false;
                } else {
                    this.sinDocs = false;
                    this.loaded = false;
                    this.offset = result.offset;
                    this.limite = result.limite;
                    this.total = result.total;
                    this.totalPages =result.totalPages;
                    for(var i =0;i< result.lItems.length;i++){
                        var splitType= result.lItems[i].fileName.split('.');
                        var icon='';
                        switch(splitType[splitType.length-1]){
                            case 'doc':
                            case 'odt':
                            case 'docx':
                                icon = 'doctype:gdoc';
                                break;
                            case 'xls':
                            case 'ods':
                            case 'xlsx':
                                icon = 'doctype:excel';
                                break;                            
                            case 'zip':                            
                                icon = 'doctype:zip';                            
                                break;
                            case 'pdf':
                                icon = 'doctype:pdf';
                                break;
                            default:
                                icon = 'doctype:unknown';
                                break;
                        }
                        result.lItems[i].type=icon;
                    }
                    this.lItem = result.lItems;

                    //botón anterior mostrar o no
                    if(this.pageNumb === 1) this.styleAnte = true;
                    else this.styleAnte =  false;
                    //botón siguiente mostrar o no
                    if(this.pageNumb === this.totalPages) this.styleSig = true;
                    else this.styleSig =  false;
                }
            })
            .catch(error => {
                this.error = error;
                this.loaded = false;
            });
    }

    // component events handler
    handleChangeDocumentType (event) {
        this.loaded = true;
        this.documentType = event.detail.value;
        //Inicializamos el mapa que contiene los campos que son dinámicos para eliminar los datos anteriores
        this.mapDynamicField = new Map();
        getFieldDoc({ nameDocType : this.documentType })
            .then(result => {
                if (!result.status) {
                    const toast = new ShowToastEvent({
                        title: 'Ops!',
                        message: 'Ha ocurrido un error al recuperar los documentos',
                        variant: 'error'
                    });
                    this.dispatchEvent(toast);
                    this.loaded = false;
                } else {
                    this.lFields = result.lFieldsItem;
                    this.loaded = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.loaded = false;
            });
    }

    onClickUploadDocument () {
        this.showUploadModal = true;
        this.loaded = true;
        this.loaded = false;
    }

    onClickDownloadDocument (event) {
        this.documentName = event.target.value.fileName;
        this.documentId = event.target.value.id;
        this.loaded = true;
        getAuthToken()
            .then(result => {
                if (result != null) {
                    this.token = result;
                    this.handleCalloutDownloadDoc();
                } else {
                    const toast = new ShowToastEvent({
                        title: 'Ops!',
                        message: 'Ha ocurrido un error al recuperar los documentos',
                        variant: 'error'
                    });
                    this.dispatchEvent(toast);
                    this.loaded = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.loaded = false;
            });
    }

    onClickViewDocument (event) {
        this.documentName = event.target.value.fileName;
        this.documentId = event.target.value.id;
        this.loaded = true;
        getAuthToken()
            .then(result => {
                if (result != null) {
                    this.token = result;
                    this.handleCalloutViewDoc();
                } else {
                    const toast = new ShowToastEvent({
                        title: 'Ops!',
                        message: 'Ha ocurrido un error al recuperar los documentos',
                        variant: 'error'
                    });
                    this.dispatchEvent(toast);
                    this.loaded = false;
                }
            })
            .catch(error => {
                this.error = error;
                this.loaded = false;
            });
    }
    handleCalloutDownloadDoc(){
        //Recuperamos la etiqueta que realizará la descarga
        var field = this.template.querySelector('a');
        var ficherodesc = this.documentName;

        let endpointUrl = this.URL_DOWNLOAD +"/"+ this.documentId + '/content';
        
        fetch(endpointUrl,
        {
            method : "GET",
            headers : {
                "Authorization": "Bearer " + this.token,
                "Content-Type": "application/json"
            }
        }).then(function(response) {
            
             return response.blob();
        })
        .then((response) =>{
            let reader = new FileReader();

            reader.onload = function (evt) {

                // creating blob from arrayBuffer
                var binaryData = [];
            	binaryData.push(evt.target.result);
            	let data = window.URL.createObjectURL(new Blob(binaryData, {type: 'application/octet-stream'}))

                //convertir a data el blob
                
                // pass urlobject to anchor link
                field.setAttribute("href", data);
                field.setAttribute("download", ficherodesc);
                field.click();

                window.URL.revokeObjectURL(data);

            }
            reader.onerror = function (evt) {
                this.loaded = false;
            }

            reader.readAsArrayBuffer(response);
        })
        .catch( e => {
            this.loaded = false;
        });        
    }
    handleCalloutViewDoc(){
        //Recuperamos la etiqueta que realizará la descarga
        var field = this.template.querySelector('a');
        var ficherodesc = this.documentName;
        console.log('***Comunidades: '+this.URL_DOWNLOAD);
        let endpointUrl = this.URL_DOWNLOAD +"/"+ this.documentId + '/content';
        console.log('***Enpoint comunidad: '+endpointUrl);

        fetch(endpointUrl,
        {
            method : "GET",
            headers : {
                "Authorization": "Bearer " + this.token,
                "Content-Type": "application/json"
            }
        }).then(function(response) {
            
             return response.blob();
        })
        .then((response) =>{
            let reader = new FileReader();
            reader.fileName = response.type;
            reader.onload = function (evt) {

                // creating blob from arrayBuffer               
                var type='';
                switch(evt.currentTarget.fileName){
                    case 'application/pdf':
                        type=evt.currentTarget.fileName;
                        break;
                    case 'image/jpg':
                    case 'image/png':
                        type='image/jpg';
                        break;
                    default: 
                        type='application/octet-stream'
                        break;

                }
            	let data = window.URL.createObjectURL(new Blob([evt.target.result],{type:type}))
                
                // pass urlobject to anchor link
                field.href= data;
                field.target= '_blank';
                
                if(type=='application/octet-stream'){
                    field.setAttribute('download',ficherodesc);                    
                }else{
                    field.removeAttribute('download');
                }
                field.click();

            }
            reader.onerror = function (evt) {
                this.loaded = false;
            }

            reader.readAsArrayBuffer(response);
        })
        .catch( e => {
            this.loaded = false;
        });        
    }

    onClickDownloadmessage(){
        var field = this.template.querySelector('a');
        console.log(field.getAttribute('download'))
        if(field.getAttribute('download')){
            const toast = new ShowToastEvent({
                message: this.label.mensajeDescDoc,
                variant: 'success',
                mode: 'sticky'
            });
            this.dispatchEvent(toast);
        }
        this.loaded = false;
    }

    onClickEditDocument (event){
        this.loaded = true;
        this.documentId = event.target.value.id;
        getDocumentData({ idDoc : this.documentId })
            .then(result => {
                if (!result.status) {
                    const toast = new ShowToastEvent({
                        title: 'Ops!',
                        message: 'Ha ocurrido un error al recuperar los documentos',
                        variant: 'error'
                    });
                    this.dispatchEvent(toast);
                    this.loaded = false;
                } else {

                    this.loaded = false;
                    this.editDocPop = true;
                    this.id=result.id;
                    this.nuevodocumentType = result.documentTypeId;
                    this.nuevosExp = result.expedients!=null?result.expedients.join():'';
                    this.nuevosCli = result.customers!=null?result.customers.join():'';
                    this.nuevoNombre = result.fileName;
                }
            })
            .catch(error => {
                const toast = new ShowToastEvent({
                    title: 'Ops!',
                    message: 'Ha ocurrido un error al recuperar los datos del documentos',
                    variant: 'error'
                });
                this.dispatchEvent(toast);
                this.error = error;
                this.loaded = false;
            });
    }

    onClickCloseEditDocument (){
        this.editDocPop = false;
    }

    onChangeInputNombreDoc(event){
        this.nuevoNombre = event.detail.value;
    }

    onChangeInputExpDoc(event){
        this.nuevosExp = event.detail.value;
    }

    onChangeInputCliDoc(event){
        this.nuevosCli = event.detail.value;
    }

    handleChangeDocumentTypeEditDoc(event){
        this.nuevodocumentType = event.detail.value;
    }

    onClickSendEditDocument (){
            this.loadedModal = true;
            editDocument({ idDoc : this.documentId, docType : this.nuevodocumentType, nombreDoc : this.nuevoNombre, customers : this.nuevosCli, expedientes : this.nuevosExp})
            .then(result => {
                if (!result.status) {
                    const toast = new ShowToastEvent({
                        title: 'Ops!',
                        message: 'Ha ocurrido un error al editar el documento',
                        variant: 'error'
                    });
                    this.dispatchEvent(toast);
                    this.loadedModal = false;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Edición completada',
                            variant: 'sucess',
                        }),
                    );
                    this.loadedModal = false;
                    this.editDocPop = false;
                    this.handleLoad();//Reiniciar componente
                }
            })
            .catch(error => {
                this.error = error;
                this.loadedModal = false;
            });
        
    }

    onClickBack () {
        this.showUploadModal = false;
    }

    onClickUpload (event){

        this.loaded = true;
        this.loadedModal = true;
        let maxSize = Number.parseInt(fileMaxSize);
        let maxSizeB = maxSize*1048576;
        //Recuperamos del html el fichero
        let myInput = this.template.querySelector('input[type=file]');
        let fichero = myInput.files[0];

        //Comprobamos que el documento se ha indicado
        if(this.documentType == null || this.documentType === '' || this.documentType === undefined){
            const event = new ShowToastEvent({
                title: 'Ops!',
                message: 'Se debe seleccionar el tipo de documento',
            });
            this.dispatchEvent(event);
            this.loaded = false;
            this.loadedModal = false;
        }else if(fichero == undefined){
            const event = new ShowToastEvent({
            title: 'Ops!',
            message: 'Debe seleccionar el documento',
            });
            this.dispatchEvent(event);
            this.loaded = false;
            this.loadedModal = false;

            }else if(myInput.files[0].size > maxSizeB){
            const event = new ShowToastEvent({
                title: 'Ops!',
                message: 'Debe seleccionar un documento de menos de '+maxSize+ 'MB',
            });
            this.dispatchEvent(event);
            this.loaded = false;
            this.loadedModal = false;
        }else{
            //Generamos el token para la llamada del gestor documental
            getAuthToken()
            .then(result => {
               if (result != null) {
                   this.token = result;

                   //Generamos los datos del body
                    var formData = new FormData();
                    formData.append("FileContent", fichero);
                    formData.append("DocumentTypeId", this.documentType);
                    if( this.idExpediente !== undefined && this.idExpediente.length ==1) formData.append("Expedients", this.idExpediente[0]);
                    formData.append("Customers", this.idCliente);
                    //Añadimos los datos dinámicos para cada tipo de documento
                    if(this.lFields !== undefined){
                        var jsonMetadata = {};
                        //Recorremos los campos que son dinámicos para el tipo de documento y en caso de haber indicado un valor se añade al cuerpo de la llamada que se
                        //envía al gestor documental
                        for(var i = 0; i < this.lFields.length; i++){
                            if(this.mapDynamicField.has(this.lFields[i].nameField)){
                                if(this.lFields[i].nameAPIField != undefined) jsonMetadata[this.lFields[i].nameAPIField] = this.mapDynamicField.get(this.lFields[i].nameField);
                                else jsonMetadata[this.lFields[i].nameField] = this.mapDynamicField.get(this.lFields[i].nameField);
                            }
                        }
                        //formData.append(this.lFields[i].nameField, this.mapDynamicField.get(this.lFields[i].nameField));
                        formData.append("Metadata", JSON.stringify(jsonMetadata));
                    }

                   //Realizamos la llamada al gestor documental
                   fetch(this.GDURLAddDocument,
                   {
                       method : "POST",
                       headers : {
                           "Access-Control-Allow-Origin":'https://pre-procesal-api.azurewebsites.net',
                           "Accept": "application/json",
                           "Authorization": "Bearer " + this.token
                       },
                       body : formData
                   }).then(function(response) {
                       //return response.json();
                       return response;
                    })
                    .then((myJson) =>{
                        console.log(myJson);
                        if(myJson.status === 201){
                            const toast = new ShowToastEvent({
                                title: 'Genial!',
                                message: 'Fichero cargado correctamente',
                                variant: 'success',
                            });
                            this.showUploadModal = false;
                            this.handleLoad();
                            this.dispatchEvent(toast);
                            sendNotificationEmail({archivo: this.documentType});
                        }else{
                            const toast = new ShowToastEvent({
                                title: 'Ops!',
                                message: this.label.errorMessageFileTypeMinervaCommunity,
                            });
                            this.dispatchEvent(toast);
                        }
                        this.loaded = false;
                        this.loadedModal = false;
                   })
                   .catch(e=>{  console.log("hola:"+e);
                        const event = new ShowToastEvent({
                            title: 'Ops!',
                            message: 'Ha ocurrido un error al cargar el fichero',
                        });
                        this.dispatchEvent(event);
                       this.loaded = false;
                       this.loadedModal = false;
                   });
               } else {
                   const event = new ShowToastEvent({
                       title: 'Ops!',
                       message: 'Ha ocurrido un error al recuperar el token',
                   });
                   this.dispatchEvent(event);
                   this.loaded = false;
                   this.loadedModal = false;
               }
           })
           .catch(error => {
               this.error = error;
               this.loaded = false;
               this.loadedModal = false;
           });
        }

    }

    // change page buttons
    onClickPrevious () {
        this.pageNumb = this.pageNumb - 1;
        this.handleLoad();
    }

    onClickNext () {
        this.pageNumb = this.pageNumb + 1;
        this.handleLoad();
    }

    // //Se llama cuando se modifica el valor de uno de los campos dinámicos que se tiene según el tipo de documento seleccionado para guardar el dato introducido por el usuario
    onChangeFieldDynamic(event){
        this.mapDynamicField.set(event.target.label, event.target.value);
    }

    // //Necesario para cuando se selecciona un fichero, no hace nada pero si se elimina da error al cargar el documento
    onChangeFile(){}

    // // label export
    label = {
        upload,
        fileMaxSize,
        document,
        appName,
        choose,
        documentType,
        cancel,
        mensajeDescDoc,
        sinDocumentosCargados,
        edit,
        newTypeDoc,
        newNameDoc,
        newExpDoc,
        newExpCli,
        textoInformativo,
        errorMessageFileTypeMinervaCommunity
    }
}