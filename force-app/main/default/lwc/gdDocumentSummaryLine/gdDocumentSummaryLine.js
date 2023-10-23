import { LightningElement, api } from "lwc";
export default class GdDocumentSummaryLine extends LightningElement {
    
    @api
    line
    
    handleSelected(event) {
        this.dispatchEvent(new CustomEvent('selected', {detail : this.line}));
    }
}