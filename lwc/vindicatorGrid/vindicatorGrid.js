import { LightningElement, wire, track, api } from 'lwc';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import DRDTTYPE_FIELD from '@salesforce/schema/WorkRequestForm__c.DRDTTYPE__c';
export default class VindicatorGrid extends LightningElement {
    @api recordId;
    @track listDrdt;
    @wire(getRecord, { recordId: '$recordId', fields: [DRDTTYPE_FIELD] })
    rec({ error, data }) {
        this.listDrdt = [];
        if (data) {
            if (data.fields.DRDTTYPE__c.value) {
                data.fields.DRDTTYPE__c.value.split(";").forEach(type => {
                    this.listDrdt.push(type);
                });
            }

        }
        else {
        }
    };

}