import { LightningElement, api, track, wire } from 'lwc';
import getContentDocumentList from "@salesforce/apex/ArchivedEmailsRelatedListCtrl.getContentDocumentList";
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: "File name", fieldName: "ContentDocument.Title", type: "button",
    typeAttributes: {
        label: { fieldName: "ContentDocument.Title" },
        name: "view_file",
        variant: "base"
    } }
];

export default class ArchivedEmailDetail extends NavigationMixin(LightningElement) {

    @api archivedEmailRow;
    @api modalContainer = false;
    @api attachmentRecordId;
    @api toggleSection;
    @api sections;
    @api emailId;
    
    @track docs;
    @track title;
    @track count;
    
    columns = columns;

    closeModalAction() {
        const changeEvent = new CustomEvent('closemodal', {});
        this.dispatchEvent(changeEvent);
    }

    @wire(getContentDocumentList, {attachmentRecordId : '$attachmentRecordId', emailId : '$emailId'})
        docsList({data, error}){
            if(data){
                this.docs = data;
                this.count = data.length;
                this.title = 'Archivos adjuntos ('+this.count+')';
                this.docs =  data.map(
                    record => Object.assign(
                { "ContentDocument.Title": record.ContentDocument.Title },
                record
                    )
                );
            }
            else if(error){
                this.error = error;  
        }
    }

    previewHandler(event){
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.detail.row.ContentDocumentId
            }
        })
    }

}