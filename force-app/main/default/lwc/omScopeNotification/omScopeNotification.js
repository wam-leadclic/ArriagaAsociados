import { LightningElement, api } from 'lwc';

export default class OmScopeNotification extends LightningElement {
    @api titleNotification;
    @api messageNotification;
    @api iconCategory;
    @api iconName;
    @api notificationType;
    
    /**
     * Make value to attribute: icon-name
     */
    get iconFullName() {
        return this.iconCategory + ':' + this.iconName;
    }

    /**
     * Make value to attribute: icon-name
     */
    get className() {
        var returnClass = 'slds-scoped-notification slds-media slds-media_center';
        switch (this.notificationType) {
            case 'base':
                returnClass += ' slds-scoped-notification_light';
                break;
            case 'info':
                returnClass += ' slds-theme_info';
                break;
            case 'warning':
                returnClass += ' slds-theme_warning';
                break;
            case 'error':
                returnClass += ' slds-theme_error';
                break;
            case 'success':
                returnClass += ' slds-theme_success';
                break;            
          }
        console.log('returnClass:: ' + returnClass);
        return returnClass;
    }
}