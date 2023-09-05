import { LightningElement, api, wire, track } from 'lwc';
import queueValues from '@salesforce/apex/OperationsQueue.queueValues';

export default class OpeartionQueue extends LightningElement {
   
    @track value = 'All'
    @track lstOptions = [];
    
    renderedCallback() {
        this.isLoaded = true;
    }
    @wire(queueValues)
    listValues({
        error,
        data
    }) {
        if (data) {
            
            let items = [];
            for(let i=0;i<=data.length;i++){
                if(data[i]){
                    const option = {
                        label : data[i].MasterLabel,
                        value : data[i].MasterLabel
                    };
                    items.push(option);
                }  
                }
                this.lstOptions = items;           
                
        } else if (error) {
            this.error = error;
            console.log(JSON.stringify(error));

        }
    }
   
    
    
    handleChange(event) {
        this.value = event.detail.value;
    }

    refreshComponent(event){
        this.template.querySelector("c-change-log-queue").refreshOR();
        this.template.querySelector("c-work-request-queue").refreshOR();
        this.template.querySelector("c-order-request-queue").refreshOR();
    }
    
}