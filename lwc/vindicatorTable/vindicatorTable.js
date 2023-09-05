import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVindicators from '@salesforce/apex/WorkRequestFormController.getVindicators';

export default class VindicatorTable extends LightningElement {
    @track vindicatorsData;
    @track inputDrdtData;
    @track outputDrdtData;
    @api drdtType;
    @track
     columns = [
        { label: 'Property', fieldName: 'Property__c' ,type: 'text' },
        { label: 'Value', fieldName: 'Value__c',type: 'text' }
    ];

    @wire(getVindicators, { drdtType: '$drdtType' })
    wiredVindicators({ error, data }) {
        //Check if data exists 
        if (data) {
            this.vindicatorsData = data;
            this.processVindicators(data);
        } else if (error) {
            console.log(error);
            this.notifyUser('Error', error.body.message, 'error');
        } else {
            console.log('unknown error')
        }
    }
    //Filter based on Type__c on Vindicators data.
    processVindicators(data) {
        if (data) {
            this.inputDrdtData=[];
            this.inputDrdtData = data.filter(function (opt) {
                return opt.Type__c === 'Input';
            });
            this.outputDrdtData=[];
            this.outputDrdtData = data.filter(function (opt) {
                return opt.Type__c === 'Output';
            });
        }
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
}