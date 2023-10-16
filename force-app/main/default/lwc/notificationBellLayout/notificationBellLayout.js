import { LightningElement,wire,track } from 'lwc';
import getNotifications from '@salesforce/apex/NotificationBellLayoutController.getNotifications';
import customChatterCardTitle from '@salesforce/label/c.customChatterCardTitleBell';
import customNotElementBell from '@salesforce/label/c.customNotElementBell';
import { NavigationMixin } from 'lightning/navigation';


export default class NotificationBellLayout extends NavigationMixin(LightningElement) {
    notificaciones=[];
    @track isActive=false;
    notificationsNumbers=0;
    @track noNotifications=true;
    @wire(getNotifications,{noTime:true,recordId:''})
    objectRecord({ error,data }){
        
        if(data){
            this.notificaciones=data;
            console.log(data);
            this.notificationsNumbers=this.notificaciones.length;
            if(this.notificationsNumbers>0){
                this.noNotifications=false;
                this.isActive=true;
            }
        }
    };
    label={
        customChatterCardTitle,
        customNotElementBell
    }
    handleNotification(){
        this.isActive=false;
    }
    redictEvent(event){
        var ParentId = event.currentTarget.dataset.id;
        if(ParentId==''){
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'mis-notificaciones',
                }
            });
        }else{
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId:ParentId,
                    objectApiName: 'contract',
                    actionName: 'view'
                }
            });
        }
    }
}