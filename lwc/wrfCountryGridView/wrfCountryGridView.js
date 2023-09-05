import { LightningElement, track, api, wire } from 'lwc';
import getCountrySelections from '@salesforce/apex/WorkRequestFormCountryHelper.getCountrySelections';
import { refreshApex } from '@salesforce/apex';

import messageChannel from '@salesforce/messageChannel/SaveCountrySelections__c';
import {subscribe, MessageContext} from 'lightning/messageService'

export default class WrfCountryGridView extends LightningElement {
    @api recordId;
    @api requestType;
    reqType;
    @track listDataTypes = [];
    @track dataTypesList;
    refreshView = true;
    @wire(getCountrySelections, { wrfId: '$recordId', requestType: '$requestType' })
    dataTypes(response) {
        this.dataTypesList = response;
        if (response.data) {
            this.processDataTypes(response.data);
        }
    }

    subscription = null;

    connectedCallback() {
        this.handleSubscribe();
    }

    @wire(MessageContext)
    messageContext;

    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, messageChannel, (message) => {
            this.refreshViewGrid();
        });
    }


    @wire(MessageContext)
    messageContext;

    handlePrint() {
        var url = '/apex/wrfCountrySelectionsPage?Id=' + this.recordId + '&requestType='+this.requestType;
        window.open(url, '_blank');
    }

    
    processDataTypes(data) {
        var setDataTypes = new Set();
        this.listDataTypes = [];
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };
            obj.DataType__c.split(';').forEach(dataType => {
                setDataTypes.add(dataType);
            });
        }
        this.listDataTypes = Array.from(setDataTypes).sort();
        this.refreshChildCmps();
    }
    refreshViewGrid() {
        this.refreshView = false;
        this.dataTypesList.data = undefined;
        refreshApex(this.dataTypesList);
        if (this.dataTypesList.data) {
            this.processDataTypes(this.dataTypesList.data);
        }
        this.refreshChildCmps();

        this.refreshView = true;
    }

    refreshChildCmps() {
        let message = {messageText: 'This is a test'};
        //publish(this.messageContext, messageChannel, message);
        let childCmps = this.template.querySelectorAll('c-wrf-request-type-country-grid-view');
        childCmps.forEach(cmp => {
            cmp.refreshCountryViewGrid();
        });
    }
}