import { LightningElement, api, wire, track } from 'lwc';
import getContractContactRoleList from '@salesforce/apex/RolesFuncionesContrato.getContractContactRoleList';
import { NavigationMixin } from 'lightning/navigation';

import EXPEDIENTE from '@salesforce/label/c.ArrLrcEXPEDIENTE';
import PRODUCTO from '@salesforce/label/c.ArrLrcPRODUCTO';
import ROL from '@salesforce/label/c.ArrLrcROL';
import TITLE from '@salesforce/label/c.ArrLrcTitle';
import ESTADO from '@salesforce/label/c.Estado';
import FECHACONTRATACION from '@salesforce/label/c.FechaContratacion';
import PAGOCONFIRMADO from '@salesforce/label/c.PagoConfirmado';
import PROPIETARIO from '@salesforce/label/c.Propietario';


export default class ListadoRolesContratos extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track data = [];

    get cardTitle() {
        return this.label.TITLE +' (' + this.data.length + ')'; 
    }

     @wire(getContractContactRoleList, {idContacto: '$recordId' })
     ContractContactRole({
        error,
        data
    }) {
        if (data) {
            this.data = data;
            this.numRegistros+="("+data[0].numRegistros+")";
        } else if (error) {
            this.error = error;
        }
    }
    navigateToContract(event) {

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Contract',
                actionName: 'view'
            }
        });
    }
    label = {
        EXPEDIENTE,
        PRODUCTO,
        ROL,
        TITLE,
        ESTADO,
        FECHACONTRATACION,
        PAGOCONFIRMADO,
        PROPIETARIO
    };

}