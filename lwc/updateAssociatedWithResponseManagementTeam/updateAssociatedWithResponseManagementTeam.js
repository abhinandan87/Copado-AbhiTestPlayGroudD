import { LightningElement,wire,api} from 'lwc';
import ASSOCIATED_FIELD from '@salesforce/schema/Opportunity.AssociatedwithResponseManagementTeam__c';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOppy from '@salesforce/apex/AccessToResponseManagementTeamController.updateAssociatedWithResMmtTeam';


export default class UpdateAssociatedWithResponseManagementTeam extends LightningElement {
    
    @api recordId;
    fieldValue;

    @wire(getRecord, { recordId: '$recordId', fields: [ASSOCIATED_FIELD] })
    oppyRec({ error, data }) {
        if (data) {
            this.fieldValue = data.fields.AssociatedwithResponseManagementTeam__c.value;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }

    changeToggle(event){
        this.fieldValue = !this.fieldValue;
        var msgArr,variant,displayMsg;
        updateOppy({ oppyId: this.recordId, value: this.fieldValue })
        .then(result => {
            this.message = result;
            console.log('@@@ Msg-'+this.message);
            if (this.message.includes(':')){
                msgArr = this.message.split(':');
                variant = msgArr[0];
                displayMsg = msgArr[1];
            }
            // Refresh Oppy Detail Page
            getRecordNotifyChange([{recordId: this.recordId}]);
            //Show Toast Message 
            const evt = new ShowToastEvent({
                title: variant,
                message: displayMsg,
                variant: variant,
            });
            this.dispatchEvent(evt);
            
        })
        .catch(error => {
            this.message = error;
            console.log('@@ Error-'+JSON.stringify(this.message) );
        });
    }

}