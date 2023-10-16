import { LightningElement, track, wire, api } from 'lwc';
import { parseUrlParams, showToast } from 'c/schHelper';
import { CurrentPageReference } from 'lightning/navigation';

import { fireEvent, registerListener } from 'c/pubsub';

import retrieveCurrentProducts from '@salesforce/apex/SchProductInfoController.retrieveCurrentProducts';
import getAppointmentDuration from '@salesforce/apex/SchProductInfoController.getAppointmentDuration';

import accept from '@salesforce/label/c.Accept'
import cancel from '@salesforce/label/c.Cancel'
import cardTitle from '@salesforce/label/c.Products'
import add from '@salesforce/label/c.Add'
import errorMessage from '@salesforce/label/c.ErrorMsg'
import noProductMessage from '@salesforce/label/c.NoProduct'
import selectProduct from '@salesforce/label/c.selectProduct'


export default class SchProductInfo extends LightningElement {

    @track attendeeId;

  
    @track lProduct = [];
    @track lProductPicklist = [];
    duration;
    selectedProduct;
    principal=false;
    @track pageRef;

    // front-end control
    @track showSpinner = false;
    @track isShowModal = false;
    @track disableAction = true;

    // extract URL params
    @wire(CurrentPageReference)
    getUrlParams(currentPageRef) {
        if(currentPageRef.state) {
            this.pageRef = currentPageRef;
            parseUrlParams(currentPageRef.state, this);
        }
    }


    connectedCallback() {
        this.handleLoad();
        // if attendeeId changes an event of refresh is received
        registerListener('refresh', this.handleRefresh, this);
    }

    // reload product info if attendeeId changes
    handleRefresh( payload ) {
        
        if(payload && (payload.id === this.attendeeId)) {
            this.handleLoad(); 
        }
         
    }

    handleLoad() {
        
        this.lProduct = [];
        this.lProduct.lProductId = [];
        this.lProductPicklist = [];
        this.disableAction = true;
        this.showSpinner = true;
         retrieveCurrentProducts({attendeeId : this.attendeeId})
            .then(result => {
                if(result.status) {
                    this.lProduct = result.lProduct;
                    this.lProductPicklist = result.lPicklistEntry;
                    this.disableAction = result.isLead;
                    this.duration = result.duration;
                    this.fireStateChangeEvent();  
                    this.showSpinner= false;

                    
                } else {
                    showToast({variant : 'error', message : errorMessage, title : 'Error'}, this); 
                }

                
            })
            .catch(error => {
                showToast({variant : 'error', message : errorMessage, title : 'Error'}, this); 
                this.showSpinner = false;
            });
    }

    get isProductList () {
        return this.lProduct && this.lProduct.length > 0;
    }
    
    onClickNewProduct ( event ) {
        this.isShowModal = true;
    }

    handleCheckBoxChange(event){
        var check = event.target.checked;
        if(check){
            this.principal = true
        }
        else{
            this.principal = false
        }
    }

    handleItemRemove (event) {
        
        if(!this.disableAction) {
            const index = event.detail.index;
            let myArray = [];
    
            for(let e1 of this.lProduct) {
                myArray.push(e1);
            }
            myArray.splice(index, 1);
           
            this.lProduct = myArray;
        }

        this.recalculateAppointmentDuration(); 
    }

    addProduct(event) {
        
        if(this.selectedProduct) {
            let lsplit = this.selectedProduct.split('-');
            if(!this.principal){
                let item = {"label" : lsplit[1], "name" : lsplit[0] +'-false'};
                this.lProduct = [...this.lProduct, item];
            }
            else{
                let item = {"label" : lsplit[1] + " (Principal)", "name" : lsplit[0] +'-true'};
                this.lProduct = [...this.lProduct, item];
            }
           
            this.recalculateAppointmentDuration();       
        }
        this.principal = false;
        this.isShowModal = false;
    }

    recalculateAppointmentDuration() {

        let lProductId = [];
        for(let pill of this.lProduct) {
            let lsplit = pill.name.split('-');
            lProductId.push(lsplit[0]);
        }

        this.showSpinner = true;
        getAppointmentDuration({lProductId : lProductId})
        .then(result => {
           
            if(result.status) {
                this.duration = result.duration;
                this.showSpinner = false;
                this.fireStateChangeEvent();
            } else {
                showToast({variant : 'error', message : errorMessage, title : 'Error'}, this); 
            } 
        })
        .catch(error => {
            showToast({variant : 'error', message : errorMessage, title : 'Error'}, this); 
            this.showSpinner = false;
        });
    }

    closeModal() {
        this.isShowModal = false;
    }

    handleProductChange (event) {
        this.selectedProduct = event.detail.value;
    }

    fireStateChangeEvent() {
      
        let message = {
            id : this.attendeeId, 
            state : {
                extraParams : {
                    products : this.lProduct
                },
                duration : this.duration
            }
        }

        fireEvent(this.pageRef, 'stateChange', message);
    }

    labels = {
    
        cancel, 
        accept, 
        cardTitle, 
        add,
        errorMessage,
        noProductMessage,
        selectProduct
    }



}