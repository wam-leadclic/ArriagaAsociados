import { LightningElement,api,wire } from 'lwc';
// Import message service features required for subscribing and the message channel
import { subscribe, unsubscribe, publish, MessageContext } from 'lightning/messageService';
import OPEN_CHANNEL from '@salesforce/messageChannel/lmsOpenChannel__c';

export default class LmsMessageService extends LightningElement {
    subscription = null;

    @api
    source

    @wire(MessageContext)
    messageContext;

    // Standard lifecycle hooks used to sub/unsub to message channel
    connectedCallback() {
        if (this.subscription) {
            return;
        }
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Encapsulate logic for LMS subscribe.
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            OPEN_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }

    // Handler for message received by component
    handleMessage(message) {
        this.dispatchEvent(new CustomEvent('message', {detail : message}));
    }

    @api
    doPublish(payload, eventName) {
        const detailedPayload = {
            source  : this.source,
            payload : payload,
            eventName : eventName
        }
        publish(this.messageContext, OPEN_CHANNEL, detailedPayload);
    }
}