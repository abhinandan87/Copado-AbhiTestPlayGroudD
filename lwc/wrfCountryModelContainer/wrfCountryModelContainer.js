import { LightningElement,api,track } from 'lwc';

export default class WrfCountryModelContainer extends LightningElement {
    @api recordId;
    @api requestType;
    @track openModal = false;
    showModal() {
        this.openModal = true;
    }
    closeModal() {
        this.openModal = false;
    }
}