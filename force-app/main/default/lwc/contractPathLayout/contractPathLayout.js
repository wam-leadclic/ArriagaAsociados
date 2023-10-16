import { LightningElement,track, api, wire} from 'lwc';
import getStatus from '@salesforce/apex/contractPathLayoutController.getStatus'
import estado1 from '@salesforce/label/c.funnelEstado1';
import estadoDescription1 from '@salesforce/label/c.funnelEstadoDescription1';
import estado2 from '@salesforce/label/c.funnelEstado2';
import estadoDescription2 from '@salesforce/label/c.funnelEstadoDescription2';
import estado3 from '@salesforce/label/c.funnelEstado3';
import estadoDescription3 from '@salesforce/label/c.funnelEstadoDescription3';
import estado4 from '@salesforce/label/c.funnelEstado4';
import estadoDescription4 from '@salesforce/label/c.funnelEstadoDescription4';
import estado5 from '@salesforce/label/c.funnelEstado5';
import estadoDescription5 from '@salesforce/label/c.funnelEstadoDescription5';
import estado6 from '@salesforce/label/c.funnelEstado6';
import estadoDescription6 from '@salesforce/label/c.funnelEstadoDescription6';
import estado7 from '@salesforce/label/c.funnelEstado7';
import estadoDescription7 from '@salesforce/label/c.funnelEstadoDescription7';
import estado8 from '@salesforce/label/c.funnelEstado8';
import estadoDescription8 from '@salesforce/label/c.funnelEstadoDescription8';

export default class ContractPathLayout extends LightningElement {
    @api recordId;
    @track showUploadModal=false;
    @track loadedModal=false;
    @track textoInformativo='';
    @track titleInformativo='';
    @wire(getStatus,{recordId:'$recordId'}) 
    estado({ error,data }){
        var number= parseInt(data);
        var allFunnels = this.template.querySelectorAll('[id*=status-]');
        for(let element of allFunnels){
            element.parentElement.classList.remove('estadoPendiente');
            element.parentElement.classList.add('estadoHecho');
            if(element.id.indexOf('status-'+number)>-1){
                element.parentElement.classList.remove('estadoHecho');
                element.parentElement.classList.add('estadoIntermedio');
                break;
            }
        }   
        // for(var i=0;i<allFunnels.length;i++){
        //     console.log(allFunnels[i]);
        // }
    }
    map = new Map()
    connectedCallback(){
        this.map.set(estado1,estadoDescription1);
        this.map.set(estado2,estadoDescription2);
        this.map.set(estado3,estadoDescription3);
        this.map.set(estado4,estadoDescription4);
        this.map.set(estado5,estadoDescription5);
        this.map.set(estado6,estadoDescription6);
        this.map.set(estado7,estadoDescription7);
        this.map.set(estado8,estadoDescription8);
    }

    changeModalTextInformative(event){
        this.textoInformativo=this.map.get(event.target.title);
        this.titleInformativo=event.target.title;
        this.showUploadModal=true;
    }

    closeModal() {
        this.showUploadModal=false;
    }

    label={
        estado1,
        estado2,
        estado3,
        estado4,
        estado5,
        estado6,
        estado7,
        estado8,
    }
}