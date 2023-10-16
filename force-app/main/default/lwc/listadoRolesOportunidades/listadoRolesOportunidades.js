import { LightningElement, api, wire, track  } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOpportunityContactRoleList from '@salesforce/apex/RolesFuncionesOportunidad.getOpportunityContactRoleList';
import Title from '@salesforce/label/c.ArrLroOportunidad';
import OppName from '@salesforce/label/c.ArrLroNombreOportunidad';
import Role from '@salesforce/label/c.ArrLroRoleOportunidad';
import Propietario from '@salesforce/label/c.Propietario';
import Etapa from '@salesforce/label/c.Etapa';
import HojaEncargo from '@salesforce/label/c.HojaEncargo';
import FechaCierre from '@salesforce/label/c.FechaCierre';
import EXPEDIENTE from '@salesforce/label/c.ArrLrcEXPEDIENTE';

export default class ListadoRolesOportunidad extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track data = [];

     @wire(getOpportunityContactRoleList, {idAccount: '$recordId' })
     OpprtunityContactRole({
        error,
        data
    }) {
        if (data) {
            this.data = data;
            
        } else if (error) {
            this.error = error;
        }
    }

    get cardTitle(){
           
        return this.label.Title + " ("+ this.data.length +")";
    }

    //recordPageUrl;
    handleClick(event) {
        // Navigate to contact record page
        
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Opportunity',
                actionName: 'view',
            },
        }).then(url => {
            this.recordPageUrl = url;
        });*/
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Opportunity',
                actionName: 'view',
            },
        });
        
    }

    label={
        
        Title,
        OppName,
        Role,
        Propietario,
        Etapa,
        HojaEncargo,
        FechaCierre,
        EXPEDIENTE
    };

    
}