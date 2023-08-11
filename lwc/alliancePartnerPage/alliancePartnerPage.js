import { LightningElement, api, wire } from 'lwc';
import getProductGroup from '@salesforce/apex/multiSelectPicklist.getProductGroup';

export default class AlliancePartnerPage extends LightningElement {
    @api recordId;

    defaultOptions = [];
    selectOptions = [];
    selectedOptionsList = [];
    showMultipicklist = false;
    @wire(getProductGroup, {
        contractId: '$recordId'
    })

    availableProductGroups({
        error,
        data
    }) {

        if (data) {
            for (const list of data) {
                console.log('$$$ListValue', list);
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
    handleChange(event) {
        // Get the list of the "value" attribute on all the selected options
        this.selectedOptionsList = event.detail.value;
        if (Array.isArray(this.selectedOptionsList)) {
            this.selectedOptionsList = this.selectedOptionsList.join(',');
        }
        //alert(`Options selected: ${selectedOptionsList}`);
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        console.log('@@selected', this.selectedOptionsList);
        //console.log('###AD' ,JSON.stringify(this.inputOptions));
        fields.ProductGroupText__c = this.selectedOptionsList;
        console.log('@@Fields', JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }
    handleSuccess() {
        const closeQA = new CustomEvent('close'); // Dispatches the event. 
        this.dispatchEvent(closeQA);
    }
    handleCancel() {
        const cancelQA = new CustomEvent('cancel'); // Dispatches the event. 
        this.dispatchEvent(cancelQA);
    }
    handleCreateLoad() {
        this.showMultipicklist = true;
    }
}