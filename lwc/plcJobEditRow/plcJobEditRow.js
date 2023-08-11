import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PLCJOb_OBJECT from '@salesforce/schema/PLCJob__c';

export default class PlcJobEditRow extends LightningElement {
    @api plcJob
    @api recordId
    @api listFields;
    isLoading;
    @track displayFields = [];
    plcJobObj;
    recordStatus = 'In Progress';
    newRecordId;

    connectedCallback() {
        this.isLoading = true;
        this.getDisplayFields();
        this.plcJobObj = { ...this.plcJob };
    }

    renderedCallback() {
        this.isLoading = false;
    }

    @api getRecordStatus() {
        return this.recordStatus;
    }

    @api getDisplayFields() {
        this.listFields.forEach(field => {
            var mode = false
            if (field === 'CycleOccurance__c') {
                mode = true
            }
            let displayField = { 'apiName': field, 'value': this.plcJob[field], 'readOnly': mode };
            this.displayFields.push(displayField);
        });
    }

    handleChange(event) {
        if (this.plcJob.hasOwnProperty(event.target.fieldName)) {
            this.plcJobObj[event.target.fieldName] = event.target.value;
        }
    }

    @api handleJobSubmit() {

        //Delete Compound Field Owner from Create call. Not supported in Create call.
        delete this.plcJobObj.Owner;

        //Delete Formula fields from the Create call. Not supported in Create call.
        delete this.plcJobObj.DeliverableEstimate__c;
        delete this.plcJobObj.JobEstimatedHours__c;
        delete this.plcJobObj.OpportunityValue__c;

        //Update Owner as Programmer
        if (this.plcJob.hasOwnProperty('OwnerId')) {
            this.plcJobObj['OwnerId'] = this.plcJobObj['ThirdResource__c'];
        }

        //Update Owner as Programmer
        if (this.plcJob.hasOwnProperty('DateOnHold1__c')) {
            this.plcJobObj['NegotiatedDate__c'] = this.plcJobObj['DateOnHold1__c'];
        }

        delete this.plcJobObj.ThirdResource__c;
        delete this.plcJobObj.DateOnHold1__c;

        var fields = this.plcJobObj;

        const recordInput = {
            apiName: PLCJOb_OBJECT.objectApiName,
            fields
        };

        createRecord(recordInput)
            .then(mapping => {
                this.newRecordId = mapping.id;
                this.recordStatus = 'Success'
                // this.dispatchEvent(new CustomEvent('success', {detail:'success'}));
            })
            .catch(error => {
                this.recordStatus = 'Failed';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while creating PLC Jobs.',
                        message: error.body.message,
                        variant: 'error'
                    }),
                );
            });
        return this.recordStatus;
    }

    @api getRecordDetails() {
        //Delete Compound Field Owner from Create call. Not supported in Create call.
        delete this.plcJobObj.Owner;

        //Delete Formula fields from the Create call. Not supported in Create call.
        delete this.plcJobObj.DeliverableEstimate__c;
        delete this.plcJobObj.JobEstimatedHours__c;
        delete this.plcJobObj.OpportunityValue__c;

        //Update Owner as Programmer
        if (this.plcJob.hasOwnProperty('OwnerId')) {
            this.plcJobObj['OwnerId'] = this.plcJobObj['ThirdResource__c'];
        }

        //Update Owner as Programmer
        if (this.plcJob.hasOwnProperty('DateOnHold1__c')) {
            this.plcJobObj['NegotiatedDate__c'] = this.plcJobObj['DateOnHold1__c'];
        }

        delete this.plcJobObj.ThirdResource__c;
        delete this.plcJobObj.DateOnHold1__c;

        return this.plcJobObj;

    }

    get styleClass() {
        return 'slds-size_1-of-' + 8;
    }

}