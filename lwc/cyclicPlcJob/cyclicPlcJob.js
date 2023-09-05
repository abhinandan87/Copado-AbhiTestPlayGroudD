import { LightningElement, api } from 'lwc';

export default class CyclicPlcJob extends LightningElement {
    @api recordId;
    @api listFields;
    //listFields = ['JobName__c', 'OwnerId', 'Cycle__c', 'CycleStart__c', 'NumberOfCycles__c', 'SubmittedDate__c'];

    get styleClass() {
        return 'slds-size_1-of-' + 3;
    }
}