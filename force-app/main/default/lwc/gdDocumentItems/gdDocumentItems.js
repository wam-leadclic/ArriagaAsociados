import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import FIELDPICKLIST from '@salesforce/schema/Opportunity.DocumentosCompletado__c';
import DOCUMENTTYPES from '@salesforce/schema/TipoDocumento__c.TipoDocumento__c';
import DOCUMENT from '@salesforce/schema/TipoDocumento__c';
import OBJECT from '@salesforce/schema/Opportunity';

import getProfile from '@salesforce/apex/GDRestCallouts.getProfile';
import getDocumentList from '@salesforce/apex/GDRestCallouts.getDocumentList';
import getDocumentFilteredList from '@salesforce/apex/GDRestCallouts.getDocumentFilteredList';
import getFieldDoc from '@salesforce/apex/GDDocumentListController.getFieldDoc';
import getIdOrigenMin from '@salesforce/apex/GDDocumentListController.getIdOrigenMin';
import deleteDocument from '@salesforce/apex/GDRestCallouts.deleteDocument';
import editDocument from '@salesforce/apex/GDRestCallouts.editDocument';
import getAuthToken from '@salesforce/apex/GDRestCallouts.getAuthToken';
import getDocumentData from '@salesforce/apex/GDRestCallouts.getDocumentData';
import fileMaxSize from '@salesforce/label/c.fileMaxSize';
import upload from '@salesforce/label/c.GDCargar';
import document from '@salesforce/label/c.GDDocumento';
import appName from '@salesforce/label/c.GDGestorDocumental';
import choose from '@salesforce/label/c.GDSeleccione';
import documentType from '@salesforce/label/c.GDTipoDocumento';
import cancel from '@salesforce/label/c.GDCancelar';
import GDURLAddDocument from '@salesforce/label/c.GDURLAddDocument';
import mensajeDescDoc from '@salesforce/label/c.MensajeDescargaDoc';
import sinDocumentosCargados from '@salesforce/label/c.sinDocumentosCargados';
import edit from '@salesforce/label/c.GDEdit';
import newTypeDoc from '@salesforce/label/c.GDNuevoTipo';
import newNameDoc from '@salesforce/label/c.GDNuevoNombre';
import newExpDoc from '@salesforce/label/c.GDNuevoExp';
import newExpCli from '@salesforce/label/c.GDNuevoCli';
import URL_DOWNLOAD from '@salesforce/label/c.GDURLDowloadDocument';

export default class GdDocumentItems extends LightningElement {
    label = {
            fileMaxSize,
         };

    // component record context
    @api recordId;
    @api objectApiName;

    // component attributes
    @track showUploadModal = false;
    documentType = '';
    @track documentId;
    documentNameFilter = '';
    @track token;
    @track idExpediente;
    @track idCliente;
    @track maxSize;
    @track sinDocs;
    @track editDocPop = false;

    // Inputs Edit doc
    nuevoNombre;
    nuevosExp;
    nuevodocumentType = '';
    nuevosCli;
    IdCuenta = '';
    IdOrigenProduccion = '';
    
    //fichero = {};

    @track loaded = false;
    @track loadedModal = false;
    @track lItem;
    @track lFields;
    @track error;
    
    @track option = [];
    @track documentTypeList = [];
    @track record;

    // Object record
    @track object;
    @track objectName;

    // get list document by offset and limit
    @track idExpDoc = [];
    @track idCustDoc = [];
    @track campoFiltro = null;
    @track ordenFiltro = null;
    @track pageNumb = 1;
    @track offset = 0;
    @track total = 0;
    @track totalPages;
    @track isClosedOpp;

    // nombre del documento a eliminar cuando se intenta borrar
    documentoAEliminar = '';

    // estilo botones paginación
    @track styleAnte =  true;
    @track styleSig =  true;

    //Upload Documents
    @track formUpload = this.template.querySelector('#formDoc');
    @track formDataUpload;

    //Mapa para guardar los valores de los campos dinámicos según el tipo de documento seleccionado
    mapDynamicField = new Map();
    
    @track userdata;
    ShowBtn = false;
    error;
    wiredActivities;


    // Pop up borrado de documentos
    @track showModal = false;
    @track approveDelete = false;
    documentNameList = [];

    // Checkbox seleccionar todos
    @track checked = false;

    //Checkbox mostrar documentos borrados
    @track showDeletedDocuments = false;


    /*constructor() {
        super(); 
        this.handleLoad();    
    }*/

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View']})
    objectRecord({ error, data }){
        this.loaded = true;
        if(data){
            this.object = data;
            this.objectName = this.object.apiName;
            //console.log(this.object);
            //console.log(this.object);
            switch (this.objectName) {
                case 'Account':
                    this.idCustDoc.push(this.object.fields.IdClienteMinerva__c.value);
                    this.idCliente = this.object.fields.IdClienteMinerva__c.value;
                    
                   
                    break;
                case 'Opportunity':
                    this.idExpDoc.push(this.object.fields.NumeroExpediente__c.value);
                    this.idExpediente = this.object.fields.NumeroExpediente__c.value;
                    this.idCliente = this.object.fields.IdClienteMinerva__c.value;
                    if(this.object.fields.StageName.value.startsWith('Cerrada')){
                        this.isClosedOpp = true;
                    }
                    break;
                case 'Contract':
                    this.idExpDoc.push(this.object.fields.IdExpediente__c.value);
                    this.idExpediente = this.object.fields.IdExpediente__c.value;
                    this.idCliente = this.object.fields.IdClienteMinerva__c.value;
            }
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

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: FIELDPICKLIST })
    globalValues({ error, data }) {
       
        if(data){
            //console.log(JSON.stringify(data.values)); 
            for(var op in data.values) {
                this.option.push({ label: data.values[op].label, value: data.values[op].value });
            }
            //console.log(this.option);
        }
        
    }

    @wire(getPicklistValues, { recordTypeId: '$documentInfo.data.defaultRecordTypeId', fieldApiName: DOCUMENTTYPES })
    globalTypeValues({ error, data }) {
       
        if(data){
            this.documentTypeList.push({label: 'Todos los tipos', value: ''});
            for(var op in data.values) {
                this.documentTypeList.push({ label: data.values[op].label, value: data.values[op].value });
            }

        }
        
    }

    // Obtenemos el tipo de registro de un objeto concreto, definido arriba
    @wire(getObjectInfo, { objectApiName: OBJECT })
    objectInfo;

    //Obtenemos el tipo de registro del objeto tipo de documento
    @wire(getObjectInfo, { objectApiName: DOCUMENT })
    documentInfo;
    

    // component load event
    handleLoad() {
        //console.log('handleLoad');
        this.loaded = true;
        getDocumentList({ lCustomer : this.idCustDoc, lExpedients : this.idExpDoc, pageNumb : this.pageNumb})
            .then(result => {
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
                    this.loaded = false;
                } else {
                    //console.log('result : ' + result);
                    this.sinDocs = false;
                    this.loaded = false;
                    this.offset = result.offset;
                    this.limite = result.limite;
                    this.total = result.total;
                    this.totalPages = result.totalPages;
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
                //console.log('error : ' + error.body.message);
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
        this.documentNameFilter = event.target.value.fileName;
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
                //console.log('errorr 203 : ' + error.message);
                this.error = error;
                this.loaded = false;    
            });
    }

    handleCalloutDownloadDoc(){                
        //Recuperamos la etiqueta que realizará la descarga
        var field = this.template.querySelector('a');  
        var ficherodesc = this.documentNameFilter; 
        
        let endpointUrl = URL_DOWNLOAD + this.documentId + '/content';
        
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
                
                // pass urlobject to anchor link
                field.setAttribute("href", data);
                field.setAttribute("download", ficherodesc);
                field.click();

                window.URL.revokeObjectURL(data);
                
            }
            reader.onerror = function (evt) {
                //console.log('error');
                this.loaded = false;
            }       
            
            reader.readAsArrayBuffer(response);
        })
        .catch( e => {
            console.log(e); 
            this.loaded = false;     
        });
    }

    onClickDownloadmessage(){
        const toast = new ShowToastEvent({
            message: 'Se realizará la acción seleccionada en breves momentos!',
            variant: 'success',
            mode: 'sticky'
        });
        this.dispatchEvent(toast);       
        this.loaded = false;
    }

    onClickDeleteDocument (event) {
        this.loaded = true;
        this.documentId = event.target.value.id;
        deleteDocument({ idDoc : this.documentId })
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
                   // this.lFields = result.lFieldsItem;
                    const toast = new ShowToastEvent({
                        title: 'Eliminado correctamente!',
                        variant: 'success'

                    });
                    this.dispatchEvent(toast);
                    this.handleLoad();//Reiniciar componente
                }
            })
            .catch(error => {
                this.error = error;
                this.loaded = false;
            });
    }

    onClickEditDocument (event){
        this.loaded = true;
        this.documentId = event.target.value.id;
        console.log(this.documentId);
        getDocumentData({ idDoc : this.documentId })
            .then(result => {
                if (!result.status) {
                    console.log('result.status -> ' + result.status);
                   
                } else {
                    
                    this.loaded = false;
                    console.log('result.status2 -> ' + JSON.stringify(result));                 
                    this.editDocPop = true;
                    this.nuevodocumentType = result.documentTypeId;
                    if (result.expedients != null){
                        this.nuevosExp = result.expedients.join();
                        console.log('result exp2 -> ' + this.nuevosExp);
                    }
                    console.log('result.customers ' +result.customers );
                    if (result.customers != null){
                        this.nuevosCli = result.customers.join();
                    }
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
                console.log('error -> ' + this.error); 
            });
    }

    onClickCloseEditDocument (){
        this.editDocPop = false;
    }

    onChangeInputNombreDoc(event){
        this.nuevoNombre = event.detail.value;
    }

    onChangeInputExpDoc(event){
        console.log('onchange exp -> ' + this.nuevosExp);
        this.nuevosExp = event.detail.value;
    }
    
    onChangeInputCliDoc(event){
        this.nuevosCli = event.detail.value;
    }

    handleChangeDocumentTypeEditDoc(event){
        this.nuevodocumentType = event.detail.value;
    }

    onClickSendEditDocument (){ 

        if((this.nuevosCli!=null && this.nuevosCli.includes(' '))|| this.nuevosExp.includes(' ')){
            const toast = new ShowToastEvent({
                message: 'Los campos "Clientes" y "Expedientes" no deben contener espacios.',
                variant: 'error'
            });
            this.dispatchEvent(toast);
            this.loadedModal = false;
        }else{
            this.loadedModal = true; 
            console.log('send exp -> ' + this.nuevosExp);       

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
                //console.log('error : ' + error.body.message);
                this.error = error;
                this.loadedModal = false;
            });
        }
    }

    onClickBack () {
        this.showUploadModal = false;
    }

    actualizarDocumentacionAportados () {

        //Si el tipo de objeto es oportunidad se actualiza la información de la oportunidad
        if(this.objectName === 'Opportunity' || this.objectName === 'Contract'){
            //Creamos la variable con los documentos aportados
            var vDocCompletadoAportado;
            var vDocContratacionAportado;      
            //Si está indicado como requerido entonces se añade en el multipicklist de aportado
            if(this.object.fields.DocumentosCompletado__c.value != null && this.object.fields.DocumentosCompletado__c.value.includes(this.documentType) == true){
                //Si no hay valores se introduce el tipo de documento
                if(this.object.fields.DocumentosCompletadoAportado__c.value == null){
                    vDocCompletadoAportado = this.documentType;
                }else if(this.object.fields.DocumentosCompletadoAportado__c.value.includes(this.documentType) == false){
                //Si tiene valores se comprueba que no está ya seleccionado en el multipicklist            
                    vDocCompletadoAportado = this.object.fields.DocumentosCompletadoAportado__c.value +';'+this.documentType;
                }    
            }    
            //Si está indicado como requerido entonces se añade en el multipicklist de aportado
            if(this.object.fields.DocumentosContratacion__c.value != null && this.object.fields.DocumentosContratacion__c.value.includes(this.documentType) == true){
                //Si no hay valores se introduce el tipo de documento
                if(this.object.fields.DocumentosContratacionAportado__c.value == null){
                    vDocContratacionAportado = this.documentType;
                }else if(this.object.fields.DocumentosContratacionAportado__c.value.includes(this.documentType) == false) {
                //Si tiene valores se comprueba que no está ya seleccionado en el multipicklist            
                    vDocContratacionAportado = this.object.fields.DocumentosContratacionAportado__c.value +';'+this.documentType;
                }
            }

            //Indicamos los datos nuevos de los campos de la oportunidad
            let record = {
                fields: {
                    Id: this.recordId,                
                    DocumentosCompletadoAportado__c : vDocCompletadoAportado,
                    DocumentosContratacionAportado__c :vDocContratacionAportado,
                },
            };
            //Actualizamos la información de la oportunidad
            updateRecord(record)                
                .then(() => {


                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Record Is Updated',
                            variant: 'sucess',
                        }),
                    );*/
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error on data save',
                            message: error.message.body,
                            variant: 'error',
                        }),
                    );
            });
        }            
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
                    if( this.idExpediente !== undefined) formData.append("Expedients", this.idExpediente);                       
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
                        //console.log(JSON.stringify(jsonMetadata));
                        formData.append("Metadata", JSON.stringify(jsonMetadata));                 
                    }

                   //Realizamos la llamada al gestor documental               
                   fetch(this.label.GDURLAddDocument,
                   {
                       method : "POST",
                       headers : {
                           "Accept": "application/json",
                           "Authorization": "Bearer " + this.token
                       },
                       body : formData
                   }).then(function(response) {                         
                       //return response.json();                       
                       return response;
                    })
                    .then((myJson) =>{                                              
                        if(myJson.status === 201){                            
                            const toast = new ShowToastEvent({
                                title: 'Genial!',
                                message: 'Fichero cargado correctamente',
                                variant: 'success',
                            });        
                            this.actualizarDocumentacionAportados();                    
                            this.showUploadModal = false;
                            this.handleLoad();
                            this.dispatchEvent(toast); 
                            this.objectName = this.object.apiName;
               
                            console.log('cli '+this.idCliente);
                            console.log('exp '+this.idExpediente );
                            console.log('obj '+this.objectName);
                            getIdOrigenMin({ thisidCliente :this.idCliente, thisidExpediente :this.idExpediente })
                                .then((result) => {
                                    console.log('ok'+result);
                                    this.contacts = result;
                                    this.error = undefined;
                                })
                                .catch((error) => {
                                    this.error = error;
                                    this.contacts = undefined;
                                });
                            /*console.log(IdOrigenProd__c);
                            console.log(IdOrigenProduccion);
                            let record = {
                                fields: {
                                    Id: this.recordId,                
                                    IdOrigenProd__c : IdOrigenProduccion,
                                },
                            };
                                    updateRecord(record)                
                                .then(() => {


                                    /*this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'Record Is Updated',
                                            variant: 'sucess',
                                        }),
                                    );
                                })*                                .catch(error => {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error on data save',
                                            message: error.message.body,
                                            variant: 'error',
                                        }),
                                    );
                            }); */                          
                        }else{                            
                            const toast = new ShowToastEvent({
                                title: 'Ops!',
                                message: 'Ha ocurrido un error al cargar el fichero1',                                
                            });
                            this.dispatchEvent(toast);
                        }
                        this.loaded = false; 
                        this.loadedModal = false;
                   })
                   .catch(e=>{
                        const event = new ShowToastEvent({
                            title: 'Ops!',
                            message: 'Ha ocurrido un error al cargar el fichero1',
                        });
                        this.dispatchEvent(event);
                       //console.log(e);            
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
               //console.log('error : ' + error.message);
               this.error = error;
               this.loaded = false;  
               this.loadedModal = false;  
           });       
        }
       
    }

    // change page buttons
    onClickPrevious () {
        //console.log('this.pageNumb :' + this.pageNumb);
        this.pageNumb = this.pageNumb - 1;
        this.handleLoad();
    }

    onClickNext () {
        //console.log('this.pageNumb :' + this.pageNumb);
        this.pageNumb = this.pageNumb + 1;
        this.handleLoad();
    }

    //Se llama cuando se modifica el valor de uno de los campos dinámicos que se tiene según el tipo de documento seleccionado para guardar el dato introducido por el usuario    
    onChangeFieldDynamic(event){        
        this.mapDynamicField.set(event.target.label, event.target.value);                
    }

    //Necesario para cuando se selecciona un fichero, no hace nada pero si se elimina da error al cargar el documento
    onChangeFile(){}

    // label export
    label = {
        upload, 
        fileMaxSize,
        document, 
        appName, 
        choose, 
        documentType,
        cancel,
        GDURLAddDocument,
        mensajeDescDoc,
        sinDocumentosCargados,
        edit,
        newTypeDoc,
        newNameDoc,
        newExpDoc,
        newExpCli
    }

    //Para obtener los datos del picklist
    get options() { 
        return JSON.parse(JSON.stringify(this.documentTypeList));
    }

    documentTypeFilter = '';
    isSelectDocuments;
    IdSelected = '';

    handleChangeFilter(event) {
        this.documentTypeFilter = event.detail.value;
        this.handleClick();
        
    }

    handleClick(event) {
        this.loaded = true;
        if(!this.showDeletedDocuments){
            //Hacemos la búsqueda con los valores del filtro por tipo de documento
            getDocumentFilteredList({ lCustomer : this.idCustDoc, lExpedients : this.idExpDoc, pageNumb : this.pageNumb, filterByType: this.documentTypeFilter, filterByName: this.documentNameFilter})
            .then(result => {
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
                    this.loaded = false;
                } else {
                    //console.log('result : ' + result);
                    this.sinDocs = false;
                    this.loaded = false;
                    this.offset = result.offset;
                    this.limite = result.limite;
                    this.total = result.total;
                    this.totalPages = result.totalPages;
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
                //console.log('error : ' + error.body.message);
                this.error = error;
                this.loaded = false;
            });
        }
        else{
            //Se muestran los documentos borrados
            
        }
        

    }
    
    handleCalloutViewDoc(){
        //Recuperamos la etiqueta que realizará la descarga
        var field = this.template.querySelector('a');
        var ficherodesc = this.documentNameFilter;
        let endpointUrl = URL_DOWNLOAD + this.documentId + '/content';
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

    //Evento para previsualizar el fichero PDF
    onClickViewDocument (event) {
        this.documentNameFilter = event.target.value.fileName;
        
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

    //Borramos el documento seleccionado
    onClickDeleteDocuments(event) {
        this.IdSelected = event.target.value.id;
        this.documentoAEliminar = event.target.value.fileName;
        this.gestionPopUp();
    }

    // Desmarca las checkbox de borrado en todos los documentos
    uncheckDocuments(){
        this.checked = false;
        let allItems = this.template.querySelectorAll('.selected-input-delete');
        let change = new Event('change');

        allItems.forEach(element => {
            element.checked = false;
            element.dispatchEvent(change);
        });
    }

    // Gestiona la aparición del pop up de borrado de documentos
    gestionPopUp (){
        this.showModal = true;
    }


    // Se cancela el borrado del documento
    closeModalCancel() {
        this.showModal = false;
    }

    // Se acepta el borrado del documento
    closeModalDelete(){
        //Borrado de documento del bucle
        deleteDocument({
            idDoc: this.IdSelected
        })
        .then(result => {
            this.handleClick();
            const toast = new ShowToastEvent({
                message: 'El documento se ha eliminado correctamente',
                variant: 'success',
                mode: 'sticky'
            });
            this.dispatchEvent(toast);
            console.log('Borrado correcto');
        })
        .catch(error => {
            console.log('Fallo en el borrado');
            const toast = new ShowToastEvent({
                message: 'Fallo en el borrado del documento ',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(toast);
        });
        this.showModal = false;
        
    }

    renderedCallback() {
    }

    //Filtrar por nombre de documento
    filterByName(event) {
        this.documentNameFilter = event.detail.value;
        this.handleClick(event);

        
    }

    showDeleteDocuments(){
        this.showDeletedDocuments = !this.showDeletedDocuments;
        this.handleClick();
    }

}