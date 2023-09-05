import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class VocFlowLWC extends LightningElement {

    @api recordId;
    get inputVariables() {
        return [
            {
                name: "InputrecordId",
                type: "String",
                value: this.recordId
            }
        ];
    }
    
    handleStatusChange(event) {
        if (event.detail.status === "FINISHED") {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }
}