import { LightningElement, api } from "lwc";
export default class GdDocumentSummaryLine extends LightningElement {
    
    @api
    line
    
    handleSelected(event) {
        this.dispatchEvent(new CustomEvent('selected', {detail : this.line}));
    }
    
    handleHelp(event) {
        this.dispatchEvent(new CustomEvent('help', {detail : this.line}));
    }

    /**
     * Si tiene ayuda el documento, aseguramos el espacio
     * para el help-text, de lo contrario ocupamos la columna entera
     */
    get titleClass() {
        if (this.line.helpText) {
            return 'slds-size_11-of-12 slds-has-flexi-truncate';
        }
        return 'slds-has-flexi-truncate';
    }

    /**
     * Si está aportado el documento, aseguramos el espacio
     * para el estado, de lo contrario ocupamos la columna entera
     */
    get titleWrapperClass() {
        if (!this.line.visible) {
            return 'slds-size_10-of-12 slds-text-align_left';
        }
        return 'slds-text-align_left';
    }
}