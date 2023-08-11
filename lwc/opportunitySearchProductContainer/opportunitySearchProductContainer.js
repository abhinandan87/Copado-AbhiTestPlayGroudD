import { LightningElement, api, wire, track  } from 'lwc';

import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
// Lightning Message Service and a message channel
import {publish, MessageContext} from 'lightning/messageService';
import SELECTED_PRODUCTS_LIST from '@salesforce/messageChannel/SelectedProductsList__c';

export default class OpportunitySearchProductContainer extends NavigationMixin(LightningElement){
    @api recordId;
    @track prodList;
    @track emptyProductList = true;
    selectedProductsList;
    @api filterProductsList;
    hideFilter = false;
    pageLoad = false;
    @wire(MessageContext) messageContext;

    //Called after all components are loaded
    renderedCallback() {
        if(!this.pageLoad){
            this.pageLoad = true;        
            this.setDynamicWidth();   
        } 
    }

    // Set default width of Collapse/Uncollapse Filter and Product List sections
    setDynamicWidth(){
        this.hideFilter = false;
        let colFilter = this.template.querySelector(`[data-id="CollapsedFilter"]`);
        let expFilter = this.template.querySelector(`[data-id="ExpandFilter"]`);
        let prodList = this.template.querySelector(`[data-id="prodlist"]`);
        colFilter.classList.toggle('slds-hide');
        expFilter.style.width = '15%';
        prodList.style.width = '85%';
    }
    
    // Handle Collapse/Uncollapse on icon
    handleFilterDisplay(event){
        let colFilter = this.template.querySelector(`[data-id="CollapsedFilter"]`);
        let expFilter = this.template.querySelector(`[data-id="ExpandFilter"]`);
        let prodList = this.template.querySelector(`[data-id="prodlist"]`);

        this.hideFilter = this.hideFilter?false:true ;
       
        if(this.hideFilter){            
           // prodList.classList.toggle('slds-size_10-of-12');
           colFilter.style.width = '1.5%';
           expFilter.style.width = '0%';
           prodList.style.width = '98.5%';
        }
        else{
           colFilter.style.width = '0%';
           expFilter.style.width = '15%';
           prodList.style.width = '85%';
        }
        colFilter.classList.toggle('slds-hide');
        expFilter.classList.toggle('slds-hide'); 
       

    }

    // Get all the Selected products on custom event from SelectedProductList component 
    // To show/hide Proceed button
    handleSelectedProdList(event){
        let selProductsList = event.detail.prodList;
        this.selectedProductsList = selProductsList;
        this.selectedProductsList.length === 0? this.emptyProductList = true : this.emptyProductList = false;
    }

    // Get Filter JSON on custom event from SearchProductsFilter component
    handleFilterSearchList(event){
        let filterProdList = event.detail.filterList;
        this.filterProductsList = filterProdList;
    }

    // Open Legal Entity Screen and publish selected products
    handleProceed(event){
     this.publishSelectedProductsList();
    }

    // Publish message
    publishSelectedProductsList(){
        publish(this.messageContext, SELECTED_PRODUCTS_LIST, {
                selProductsList : this.selectedProductsList,
                filProductsList : this.filterProductsList,
                mode : 'addScreen'
            });
    }

     // Navigate to Opportunity Record Page
     handleCancel(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }

}