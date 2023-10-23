import { LightningElement, api, track, wire } from "lwc";
import { refreshApex } from '@salesforce/apex';
import getDocumentSumary from "@salesforce/apex/GDDocumentSummaryController.getDocumentSumary";
import removeUploadedDocument from "@salesforce/apex/GDDocumentSummaryController.removeUploadedDocument";
import { 
	SUCCESS,
	ERROR, 
	GD_DOCUMENT_ITEMS_NAMESPACE,
	LMS_OPEN_CHANNEL,
	GD_DOCUMENT_SUMMARY_NAMESPACE 
} from "c/communityConstants";
import REDACTION_DOCUMENT_FIELD from "@salesforce/schema/Contract.DocumentosRedaccion__c";
import ADITIONAL_DOCUMENT_FIELD from "@salesforce/schema/Contract.DocumentosAdicionales__c";

import { Label } from "./labels";

const DOCUMENT_GROUP_VALUES = {
	CUSTOMER_SUPPORTING: {
		title  : Label.consumerSupportingDocuments,
		values : Label.consumerSupportingDocumentsValues.split(';')
	},
	DIVORCE: {
		title  : Label.specialDivorceDocuments,
		values : Label.specialDivorceDocumentsValues.split(';')
	},
	SPECIAL_CASE_INHERITANCE : {
		title  : Label.specialCaseInheritanceDocuments,
		values : Label.specialCaseInheritanceDocumentsValues.split(';')
	},
	SPECIAL_DISABILITY_CASE: {
		title  : Label.specialDisabilityCaseDocuments,
		values : Label.specialDisabilityCaseDocumentsValues.split(';')
	},
}
export default class GdDocumentSummary extends LightningElement {
	
	label = Label;

	_namespace = GD_DOCUMENT_SUMMARY_NAMESPACE

	_showSpinner = false;

	@api recordId;
	
	@wire(getDocumentSumary, {expedientId : '$recordId'})
	summaryWired

	// Respond to UI event by publishing message
    handleDocumentSelect(event) {
		const lmsService = this.template.querySelector(LMS_OPEN_CHANNEL);
		lmsService.doPublish(event.detail);
    }

	handleMessageService(event) {
		if (event.detail && event.detail.source === GD_DOCUMENT_ITEMS_NAMESPACE) {
			const document = event.detail.payload;
			this.updateExpedient(document);
		}
	}

	async updateExpedient(document) {
		this.showSpinner = true;
		try {
			let params = {
				recordId : this.recordId, 
				documentLine : JSON.stringify(document)
			};
			let response = await removeUploadedDocument(params);
			if (response.status == SUCCESS) {
				await refreshApex(this.summaryWired);
			}
		} catch (error) {
			console.error(JSON.stringify(error));
		}
		this.showSpinner = false; 
	}

	get aditionaLinesGrouping() {
		let grouping = [];
		Object.keys(DOCUMENT_GROUP_VALUES).forEach((key) => {
			let {title, values} = {...DOCUMENT_GROUP_VALUES[key]};
			let filteredValues = this.aditionalLines.filter(document => values.includes(document.value));
			if (filteredValues.length) {
				grouping.push({
					title : title,
					values : filteredValues
				});
			} 
		})
		return grouping;
	}

	get summary() {
		return this.summaryWired.data.data;
	}

	get redactionLines() {
		return this.summary.documentLines.filter(document => (
				document.visible && 
				document.relatedField === REDACTION_DOCUMENT_FIELD.fieldApiName && 
				this.summary.redactionLines.includes(document.value)
			) 
		)
	}

	get aditionalLines() {
		return this.summary.documentLines.filter(document => (
			document.relatedField === ADITIONAL_DOCUMENT_FIELD.fieldApiName && this.summary.aditionalLines.includes(document.value)) 
		)
	}

	get hasPendingAditionalLines() {
		return this.aditionalLines.length > 0;
	}

	get hasPendingRedactionLines() {
		return this.redactionLines.length > 0;
	}

	get hasError() {
		return this.summaryWired?.data.status == ERROR;
	}

	get loaded() {
		return (this.summaryWired?.data && this.summaryWired.data.status === SUCCESS);
	}

	get showSpinner() {
		return (!this.hasError && !this.loaded) || this._showSpinner;
	}

	set showSpinner(value) {
		this._showSpinner = value;
	}
}