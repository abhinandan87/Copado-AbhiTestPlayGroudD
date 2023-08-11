import { LightningElement, api, wire } from 'lwc';
import getProductGroupAlliance from '@salesforce/apex/multiSelectPicklist.getProductGroupAlliance';
import getProductGroupAll from '@salesforce/apex/multiSelectPicklist.getProductGroupAll';
import { NavigationMixin } from 'lightning/navigation';
import {refreshApex} from '@salesforce/apex'

export default class Example extends NavigationMixin(LightningElement) {
    @api recordId;
    selectOptions = [];
    defaultOptions = [];
    selectedValues = [];
    selectedOptionsList = [];
    recordPageUrl;
    showMultipicklist = false;

    @wire(getProductGroupAll, {
        allianceId: '$recordId'
    })

    allProductGroups({
        error,
        data
    }) {

        if (data) {
            for (const list of data) {
                const option = {
                    label: list,
                    value: list
                };
                // this.selectOptions.push(option);
                this.selectOptions = [...this.selectOptions, option];
            }
            this.error = undefined;
        }
        if (error) {
            this.picklistValues = undefined;
            console.log(' ##error ', error);
            this.error = error;
        }
    }
    @wire(getProductGroupAlliance, {
        Id: '$recordId'
    })

    selectedProductGroups({
        error,
        data
    }) {
        this.productgroupvalue = data;

        if (data) {
            console.log('@@@@', JSON.stringify(data));
            for (const list of data) {
                console.log('$$$ListValue', list);
                const option = {
                    label: list,
                    value: list
                };
                // this.selectOptions.push(option);
                this.selectedValues = data;
                return refreshApex(this.productgroupvalue);
            }
            this.error = undefined;
        }
        if (error) {
            this.picklistValues = undefined;
            console.log(' ##error ', error);
            this.error = error;
        }
    }

    handleChange(event) {
        // Get the list of the "value" attribute on all the selected options
        this.selectedOptionsList = event.detail.value;
        if (Array.isArray(this.selectedOptionsList)) {
            this.selectedOptionsList = this.selectedOptionsList.join(',');
        }
    }
    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        fields.ProductGroupText__c = this.selectedOptionsList;
        this.template.querySelector('lightning-record-edit-form').submit(fields);

    }
    handleSuccess() {
        const closeQA = new CustomEvent('close'); // Dispatches the event. 
        this.dispatchEvent(closeQA);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ContractProductAlliancePartner__c',
                actionName: 'view'
            }
        });
    }
    handleCreateLoad() {
        this.showMultipicklist = true;
    }
    closepage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'ContractProductAlliancePartner__c',
                actionName: 'view'
            }
        });
    }
}