import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ArchivedEmailAttachments extends NavigationMixin(LightningElement) {

    @api docs;
    @api columns;
    @api title;
    @api count;
    @api previewHandler;

}