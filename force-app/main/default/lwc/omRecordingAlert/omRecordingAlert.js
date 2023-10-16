import { LightningElement, api, wire } from 'lwc';
import LightningAlert from 'lightning/alert';
import { getRecord } from 'lightning/uiRecordApi';
import OM_IS_RECORDED_FIELD from '@salesforce/schema/VoiceCall.OM_RecordingAccepted__c';
import OM_CALLTYPE from '@salesforce/schema/VoiceCall.CallType';
import OM_CALLSTATUS from '@salesforce/schema/VoiceCall.CallDisposition';
import OM_REQUESTED from '@salesforce/schema/VoiceCall.OM_RequestedByAgent__c';
import recordingHeader from '@salesforce/label/c.OM_RecordingHeader';
import recordingMessage from '@salesforce/label/c.OM_RecordingMessage';
import reminderHeader from '@salesforce/label/c.OM_ReminderHeader';
import reminderMessage from '@salesforce/label/c.OM_ReminderMessage';
const FIELDS = [OM_IS_RECORDED_FIELD,OM_CALLTYPE,OM_CALLSTATUS,OM_REQUESTED];
const OPEN_STATUS = 'in-progress';
const INBOUND = 'Inbound';
const OUTBOUND = 'Outbound';

export default class alertPopup extends LightningElement {
    @api recordId;
    alertHeader;
    alertMessage;
    alertType;
    displayAlert = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wireRecord({data, error}){
        console.log('recordid:: ' + this.recordId + ' -- ' + '$recordId');
        console.log('  data --> ' + JSON.stringify(data) + ' error -->  ' + JSON.stringify(error) )
        if(data && data.fields.CallDisposition.value === OPEN_STATUS){
            this.displayAlert = false;
            if(data.fields.CallType.value === OUTBOUND && !data.fields.OM_RequestedByAgent__c.value && data.fields.OM_RecordingAccepted__c.value != 'Yes'){
                this.alertHeader = reminderHeader;
                this.alertMessage = reminderMessage;
                this.alertType = 'shade';
                this.displayAlert = true;
            } else if(data.fields.OM_RecordingAccepted__c.value === 'No' && !data.fields.OM_RequestedByAgent__c.value){
                this.alertHeader = recordingHeader;
                this.alertMessage = recordingMessage;
                this.alertType = 'warning';
                this.displayAlert = true;
            }
            if(this.displayAlert){
                LightningAlert.open({
                    message: this.alertMessage,
                    theme: this.alertType,
                    label: this.alertHeader,
                });
            }
        }
        else if(error){
            this.error = error;
        }
    }
}