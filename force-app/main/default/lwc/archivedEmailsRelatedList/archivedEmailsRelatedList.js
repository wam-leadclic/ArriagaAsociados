import { LightningElement, api, track, wire } from "lwc";
import getDataList from "@salesforce/apex/ArchivedEmailsRelatedListCtrl.getDataList";

const columns = [
    { label: "Fecha de envío", fieldName: "MessageDate", type: "date", sortable: "true",
    typeAttributes:{
        year: "numeric",
        month: "numeric",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    }},
    { label: "Fecha de archivado", fieldName: "CreatedDate", type: "date", sortable: "true",
    typeAttributes:{
        year: "numeric",
        month: "numeric",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit"
    }},
    { label: "Asunto", fieldName: "Subject", type: "button",
    typeAttributes: {
        label: { fieldName: "Subject" },
        name: "ActionName",
        variant: "base"
    } },
    { label: "Remitente", fieldName: "FromAddress" },
    { label: "Destinatario", fieldName: "ToAddress" },
];

export default class ArchivedEmailsRelatedList extends LightningElement {
    
    @api recordId;
    
    @track archivedEmailsData;
    @track archivedEmailRow;
    @track count;
    @track title;
    @track modalContainer = false;
    @track attachmentRecordId;
    
    //Fields values
    @track messageDate;
    @track fromAddress;
    @track toAddress;
    @track toAddressCC;
    @track toAddressBCC;
    @track isOpened;
    @track emailId;
    @track CreatedDate;
    
    columns = columns;
    @track sortBy;
    @track sortDirection;

    @track sections = [
        {
            id: 1,
            label: 'Información del email',
            subSections: [
                {
                    id: 1,
                    label: 'Fecha de envío',
                    value: '',
                    isDate: true
                },
                {
                    id: 2,
                    label: 'Fecha de archivado',
                    value: '',
                    isDate: true
                },
                {
                    id: 3,
                    label: 'Dirección De',
                    value: '',
                    isText: true
                },
                {
                    id: 4,
                    label: 'Dirección Para',
                    value: '',
                    isText: true
                },
                {
                    id: 5,
                    label: 'Dirección Cc',
                    value: '',
                    isText: true
                },
                {
                    id: 6,
                    label: 'Dirección Cco',
                    value: '',
                    isText: true
                },
                {
                    id: 7,
                    label: 'Leído',
                    value: '',
                    isBoolean: true
                },
            ]
        },
        {
            id: 2,
            label: 'Mensaje',
            subSections: [
                {
                    id: 1,
                    label: 'Asunto',
                    value: '',
                    isText: true
                },
                {
                    id: 2,
                    label: 'Cuerpo HTML del email',
                    value: '',
                    isHtml: true
                }
            ]
        }
    ];

    @wire(getDataList, { recordId: "$recordId" })
        archivedEmails({data, error}){
            if(data){
                this.archivedEmailsData = data;
                this.count = data.length;
                this.title = "Correos electrónicos archivados (" + this.count + ")";
                console.log("DATA ** ", JSON.stringify(this.archivedEmailsData));
            }
            else if(error){
                this.error = error;  
        }
    }

    handleRowAction(event){
        const dataRow = event.detail.row;
        this.archivedEmailRow = dataRow;
        this.attachmentRecordId = this.recordId;
        this.modalContainer = true;
        this.emailId = dataRow.OriginEmailId;  

        this.sections[0].subSections[0].value = dataRow.MessageDate;
        this.sections[0].subSections[1].value = dataRow.CreatedDate;
        this.sections[0].subSections[2].value = dataRow.FromAddress;
        this.sections[0].subSections[3].value = dataRow.ToAddress;
        this.sections[0].subSections[4].value = dataRow.ToAddressCC != null ? dataRow.ToAddressCC : '';
        this.sections[0].subSections[5].value = dataRow.ToAddressBCC != null ? dataRow.ToAddressBCC : '';
        this.sections[0].subSections[6].value = dataRow.IsOpened;

        this.sections[1].subSections[0].value = dataRow.Subject;
        this.sections[1].subSections[1].value = dataRow.HTMLBody;
    }

    closeModalAction(){
        this.modalContainer = false;
    }

    toggleSection(event){
        let buttonid = event.currentTarget.dataset.buttonid;
        let currentsection = this.template.querySelector('[data-id="' + buttonid + '"]');
        if (currentsection.className.search('slds-is-open') == -1) {
            currentsection.className = 'slds-section slds-is-open';
        } else {
            currentsection.className = 'slds-section slds-is-close';
        }
    }

    handleSortAccountData(event) {       
        this.sortBy = event.detail.fieldName;       
        this.sortDirection = event.detail.sortDirection;       
        this.sortAccountData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortAccountData(fieldname, direction) {
        
        let parseData = JSON.parse(JSON.stringify(this.archivedEmailsData));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; 
        y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.archivedEmailsData = parseData;
    }

}