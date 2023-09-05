import { LightningElement, api, track, wire } from 'lwc';
import getPlcJobRecords from '@salesforce/apex/PLCJobCyclicalUtility.getPlcJobRecords';
import getMultiPlcJobRecords from '@salesforce/apex/PLCJobCyclicalUtility.PLCJobCloneMultipartUtility';
import saveCyclicPLCJobs from '@salesforce/apex/PLCJobCyclicalUtility.saveCyclicPLCJobs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/PLCJob__c.Team1__c';
import INDUSTRY_FIELD from '@salesforce/schema/PLCJob__c.JobName__c';

export default class WorkRequestCyclicJobs extends NavigationMixin(LightningElement) {
    @api recordId;
    error;
    @track plcJobs;
    displayFields;
    @track isLoading = false;
    totalRecords;
    totalFailedRecords;
    listCyclicFields = ['JobName__c', 'OwnerId', 'Cycle__c', 'CycleStart__c', 'NumberOfCycles__c', 'SubmittedDate__c'];
    listMultipartFields = ['JobName__c', 'OwnerId', 'SubmittedDate__c'];
    @api actionName;
    get styleClass() {
        let columns = '8';
        return 'slds-size_1-of-' + columns;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, INDUSTRY_FIELD] })
    rec({ error, data }) {
        if (data) {
            console.log(data);
        }
        else {
            console.log(error);
        }
    };

    get isCyclic() {
        if (this.actionName === 'Cyclic') {
            return true;
        }
        return false;
    }


    listLabels = ['Job Name', 'Programmer', 'Programmers Team', 'Start Date', 'Negotiated Date', 'Requested Date', 'Hours Estimate', 'Peer Review Task'];
    listFields = ['JobName__c', 'ThirdResource__c', 'Team1__c', 'StartDate__c', 'DateOnHold1__c', 'RequestedDate__c', 'TotalJobEstimate__c', 'CreatePeerReviewTask__c'];

    connectedCallback() {
        this.getPlcJobRecords_();
    }

    closeModal() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
        this.tempRecordId = '';
    }

    handleSave(event) {
        this.isLoading = true;
        //this.callSaveOnChildCompoents();

        let plcJobs = this.getRecordsFromChildComponents();
        this.savePLCRecords(plcJobs);
        // this.getRecordsStatus();
        if (this.actionName === 'Multipart') {
            this.updateParentPLCJob();
        }
    }


    savePLCRecords(plcRecords) {
        this.isLoading = true;
        saveCyclicPLCJobs({ plcJobs: plcRecords })
        
            .then(data => {
                this.notifyUser('Success', 'Records Saved Successfully', 'success');
                this.navigateToRecordViewPage(this.recordId);
                this.isLoading = false;
            })
            .catch(error => {
                this.notifyUser('Error', error.body.message, 'error');
                this.isLoading = false;
            });
            
    }



    getPlcJobRecords_() {
        this.error = '';
        if (this.actionName === 'Cyclic') {
            getPlcJobRecords({ masterPLCId: this.recordId })
                .then(data => {
                    this.processPlcJobs(data);
                })
                .catch(error => {
                    this.error = JSON.stringify(error);
                });
        }
        if (this.actionName === 'Multipart') {
            getMultiPlcJobRecords({ masterPLCId: this.recordId })
                .then(data => {
                    this.processPlcJobs(data);
                })
                .catch(error => {
                    this.error = JSON.stringify(error);
                });
        }


    }

    callSaveOnChildCompoents() {
        let childCmps = this.template.querySelectorAll('c-plc-job-edit-row');
        childCmps.forEach(cmp => {
            console.log(cmp.handleJobSubmit());
        });
    }

    getRecordsFromChildComponents() {
        var plcJobs = [];
        let childCmps = this.template.querySelectorAll('c-plc-job-edit-row');
        childCmps.forEach(cmp => {
            let job = cmp.getRecordDetails();
            plcJobs.push(job);
        });
        return plcJobs;        
    }

    updateParentPLCJob() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields['IsMultipart__c'] = true;
        const plcJobInput = { fields };
        updateRecord(plcJobInput);
    }
    getRecordsStatus() {
        var hasErrors = false;
        let childCmps = this.template.querySelectorAll('c-plc-job-edit-row');
        childCmps.forEach(cmp => {
            if (cmp.getRecordStatus() === 'Failed') {
                hasErrors = true;
            }
        });

        if (!hasErrors) {
            this.navigateToRecordViewPage(this.recordId);
        }

    }

    navigateToRecordViewPage(navRecordId) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: navRecordId,
                objectApiName: 'PLCJob__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    handleSuccess(event) {
        if (event.target) {
            this.totalFailedRecords = this.totalFailedRecords - 1;
        }
        this.handleNavigation();
    }

    handleNavigation() {
        if (this.totalFailedRecords === 0) {
            this.navigateToRecordViewPage(this.recordId);
        }
    }

    processPlcJobs(data) {
        this.plcJobs = [];
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };
            if (!obj.hasOwnProperty('Team1__c')) {
                obj.Team1__c = '';
            };
            if (!obj.hasOwnProperty('TotalJobEstimate__c')) {
                obj.TotalJobEstimate__c = '';
            };
            obj.ThirdResource__c = data[i].OwnerId;
            obj.DateOnHold1__c = data[i].NegotiatedDate__c;
            obj.CycleOccurance__c = i + 1;
            this.plcJobs.push(obj);
        }
        this.totalRecords = this.plcJobs.length;
        this.totalFailedRecords = this.plcJobs.length;
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
}