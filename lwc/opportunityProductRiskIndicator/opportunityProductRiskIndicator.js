import { LightningElement,api, wire } from 'lwc';
import  getProductName from '@salesforce/apex/OpportunityProductRiskController.getRiskProductName';

export default class OpportunityProductRiskIndicator extends LightningElement {
    record;
    error;
    @api recordId;
    @wire(getProductName, {oppyId : '$recordId'}) 
    riskyProducts ({error,data}){
        if (data) {
            this.record = data;
            this.error = undefined;
            console.log('@@@@@ success--'+this.record);
        } else if (error) {
            this.error = error;
            this.record = undefined;
            console.log('@@@@@ Error--'+JSON.stringify(this.error));
        }
    }
}