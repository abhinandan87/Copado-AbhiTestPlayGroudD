import { LightningElement, track, api, wire } from 'lwc';
import getCloneRecordId from '@salesforce/apex/WorkRequestFormController.getCloneRecordId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';


export default class WorkRequestFormClone extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api isLoaded = false;
    @api actionName = 'Clone';
    isCloneInProgress = false;

    clonedRecordId;

    closeModal() {
        // to close modal, Navigate the page to the current record.
        //this.navigateToRecordViewPage(this.recordId);
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

    get cloneMsgs() {
       var msgs = [];
        if (this.actionName === 'Clone') {
            //msgs list to make messages appear in different lines
            msgs[0] = '-Please review and transfer all relevant change log details into the new WRF if any.';
            msgs[1] = '-Please note Special Instructions will not be carried over to the cloned record. Please review' +
            'and transfer all relevant instructions to the new WRF.'
            return msgs;
        }
        if (this.actionName === 'ConvertEstimate') {
            msgs[0] = 'You are about to create another Estimate Job type with current record details'
            return msgs;
        } else {
            return msgs;
        }
    }

    submitDetails() {
        //Add your code to call apex method or do some processing
        this.isLoaded = false;
        // To handle multiple Clicks from browser, validate if there an active clone process is inprogress
        if (this.isCloneInProgress === false) {
            this.isCloneInProgress = true;
            this.handleLoad();
            this.isCloneInProgress = false;
        }
        this.isLoaded = true;
    }

    handleLoad() {
        getCloneRecordId({ recId: this.recordId, actionName: this.actionName })
            .then(result => {
                this.clonedRecordId = result;
                this.navigateToRecordViewPage(this.clonedRecordId);
            })
            .catch(error => {
                this.error = error;
                this.notifyUser('Clone Error', this.error.body.message, 'error')
                this.isLoaded = false;
            });
    }

    navigateToRecordViewPage(navRecordId) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: navRecordId,
                objectApiName: 'WorkRequestForm__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
}