import { LightningElement,api,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getOpportunityOPS from '@salesforce/apex/OpportunityEditProductControllerLWC.getOpportunityOPS';
import refreshApex from '@salesforce/apex';

// Lightning Message Service and a message channel
import {publish, MessageContext} from 'lightning/messageService';
import LEGAL_PRODUCTS_LIST from '@salesforce/messageChannel/LegalProductsList__c';

export default class OpportunityEditProductContainer extends NavigationMixin(LightningElement) {  
    @api recordId; 
    
    sortOLIByFieldName = 'Product2.Name';
    sortOLIDirection = 'asc';
    actionName = 'view';
    objApiName = 'Opportunity';
    noProductsMessage = "No Products found";
    hideFilter = false;
    showSpinner = true;
    pageLoad = false;
    closeTab = false;
    hasOppyEditAccess = false;
    autoRenewNoChanges = false;
    is6W = false;
    hasNoProducts = false;
    disableAdd = false;
    disableSave = false;
    disableSaveClose = false;
    disableLegalEntity = false;
    error;
    startTime = 0;
    @track oppyWrapper;
    @track lstOpsWrapper = [];
    @track oppy;

    @wire(MessageContext) messageContext;

    connectedCallback() {        
        this.fetchOppyDetails();
    }

    //Fetch Details from Apex Controller on page load
    fetchOppyDetails() {
        this.showSpinner = true;
        getOpportunityOPS( { OppyId: this.recordId, sortOLIDirection: this.sortOLIDirection, sortOLIByFieldName: this.sortOLIByFieldName })
        .then(( data ) => {
            if (data) {
                this.oppyWrapper = data;
                this.oppy = this.oppyWrapper.oppy;
                this.lstOpsWrapper = this.oppyWrapper.lstOPSWrapper;
                this.hasOppyEditAccess = this.oppyWrapper.hasOpportunityEditAccess;
                this.hasNoProducts = (this.lstOpsWrapper && this.lstOpsWrapper.length > 0 ) ? false : true;
                this.error = undefined;
                this.showSpinner = false;

                if (this.oppy != null && this.oppy.AutoRenewal__c && !this.oppyWrapper.isAdmin && !this.oppyWrapper.isSalesOps) { // Allow Sales Ops to edit Opportunity Products on any Sales Stage including 6WP                                       
                    if(!this.oppy.DoesThisAutoRenewalHaveChanges__c) {
                        this.autoRenewNoChanges = true;
                        this.disableLegalEntity = true;
                        this.disableAdd = true;
                    }
                    if(this.oppy.StageName.toLowerCase().indexOf("6w")!==-1) {
                    this.is6W = true;
                    }                           
                }
            }
        })
        .catch((error) => {
            if (error) {
                console.log('Error Occured' + JSON.stringify(error));
                this.error = error;
                this.oppyWrapper = undefined;
                this.oppy = undefined;
                this.lstOpsWrapper = [];
                this.showSpinner = false;
            }
        })
    }

    //Called after all components are loaded
    renderedCallback() {
        if(!this.pageLoad){
            this.pageLoad = true;        
            this.setDynamicWidth(); 
        } 
    }

    //Set Width of different components on screen load
    setDynamicWidth(){
        this.hideFilter = false;
        let colFilter = this.template.querySelector(`[data-id="collapsedFilter"]`);
        let expFilter = this.template.querySelector(`[data-id="expandFilter"]`);
        let prodList = this.template.querySelector(`[data-id="prodList"]`);
        colFilter.classList.toggle('slds-hide');
        //colFilter.style.width = '0%';
        expFilter.style.width = '15%';
        prodList.style.width = '85%';
    }

    //expand or collapse Filter section on click 
    handleFilterDisplay(event){
        let colFilter = this.template.querySelector(`[data-id="collapsedFilter"]`);
        let expFilter = this.template.querySelector(`[data-id="expandFilter"]`);
        let prodList = this.template.querySelector(`[data-id="prodList"]`);

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

    //Reset Global Values, filters and Product List
    resetPage(event) {
        eval("$A.get('e.force:refreshView').fire();");
    }

    //Add new Products to Opportunity
    addProducts(event) {
        publish(this.messageContext, LEGAL_PRODUCTS_LIST, {
            legalProdList : []
        });
    }

    //Save Product Details
    saveProducts(event) {
        this.showSpinner = true;
        this.startTime = performance.now();
        this.template.querySelector('c-opportunity-Edit-Product-List').saveOppyProductList();
    }

    //Save Product Details and go back to the Opportunity Record Page
    saveClose(event) {
        this.showSpinner = true;
        this.startTime = performance.now();
        this.template.querySelector('c-opportunity-Edit-Product-List').saveOppyProductList();
        this.closeTab = true;
    }

    //Stop Spinner after save,close if required or update Legal Entity 
    stopSpinner(event) {
        let saveTime = performance.now() - this.startTime;
        this.showSpinner = false;
        if(event.detail.status === 'Success') {
            if(this.closeTab) {
                this.cancelChanges('cancel');
            } else {
                eval("$A.get('e.force:refreshView').fire();");
            }
        } else if(event.detail.status && event.detail.status !== 'Error') {
            this.oppy.LegalEntity__r.Name = event.detail.status;
        }
    }

    //Open Legal Entity Page to change it based on Product List 
    changeLegalEntity(event) {
        this.template.querySelector('c-opportunity-Edit-Product-List').publishChangeLegalEntity();
    }

    //go to back to the Opportunity Page
    cancelChanges(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.objApiName,
                actionName: this.actionName
            }
        });
    }

    //Handle error message from EditProductList Component
    handleErrorMsg(event) {
        if(event.detail && event.detail.value == 'Success') {
            this.disableAdd = false;
            this.disableSave = false;
            this.disableSaveClose = false;
            this.disableLegalEntity = false;
        } else {
            this.disableAdd = true;
            this.disableSave = true;
            this.disableSaveClose = true;
            this.disableLegalEntity = true;
        }
    }
}