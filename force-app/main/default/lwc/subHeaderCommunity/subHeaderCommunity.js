import { LightningElement } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';
import subHeader1 from '@salesforce/label/c.subHeader1';
import subHeader2 from '@salesforce/label/c.subHeader2';
import subHeader3 from '@salesforce/label/c.subHeader3';
import subHeader4 from '@salesforce/label/c.subHeader4';
import subHeader5 from '@salesforce/label/c.subHeader5';
import subHeader6 from '@salesforce/label/c.subHeader6';
import subHeader7 from '@salesforce/label/c.subHeader7';
import arriagalogo from '@salesforce/label/c.arriagalogo';

export default class SubHeaderCommunity extends LightningElement {

    get isDesktop() {
        return formFactorPropertyName === 'Large';
    }

    get isMobile() {
        return formFactorPropertyName === 'Small';
    }
    label={
        subHeader1,
        subHeader2,
        subHeader3,
        subHeader4,
        subHeader5,
        subHeader6,
        subHeader7,
        arriagalogo
    }

}