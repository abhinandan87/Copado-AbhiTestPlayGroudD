import { LightningElement,api,wire,track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getProductDetails from '@salesforce/apex/OpportunityAddProductControllerLWC.getProductDetails';
//Import Custom Labels
import NoOPSforContractStartDate from "@salesforce/label/c.NoOPSforContractStartDate";
// Lightning Message Service and a message channel
import {publish, MessageContext} from 'lightning/messageService';
import SELECTED_PRODUCTS_LIST from '@salesforce/messageChannel/SelectedProductsList__c';

export default class OpportunityAddProductContainer extends NavigationMixin(LightningElement) {
    @api selProductsList;
    @api legalEntityId;
    @api legalEntityName;
    @api recordId;
    sortOLIByFieldName = 'Product2.Name';
    sortOLIDirection = 'asc';
    actionName = 'view';
    objApiName = 'Opportunity';
    hideFilter = false;
    showSpinner = true;
    pageLoad = false;
    closeTab = false;
    noOPSforProduct = false;
    disableSave = false;
    label = {
        NoOPSforContractStartDate
    };
    error;
    @track lstOPSWrapper = [];
    @track listProdIds = [];
    @track oppyWrapper;
    @track oppy;

    @wire(MessageContext) messageContext;

    connectedCallback() {
        console.log('Oppyy Id ' + this.recordId); 
        this.fetchOppyDetails();
    }

    //Fetch Details from Apex Controller on page load
    fetchOppyDetails() {
        this.showSpinner = true;
        this.selProductsList.forEach((item)=>{
            this.listProdIds.push(item.productId);
        });
        getProductDetails( {productIds: this.listProdIds, oppyId: this.recordId, legalEntityName: this.legalEntityName})
        .then(( data ) => {
            if (data) {
                this.showSpinner = false;
                this.oppyWrapper = data;
                this.oppy = this.oppyWrapper.oppy;
                this.lstOPSWrapper = this.oppyWrapper.lstOPSWrapper;
                this.validateOPSList();
                this.error = undefined;
            }
        })
        .catch((error) => {
            if (error) {
                console.log('Error Occured' + JSON.stringify(error));
                this.error = error;
                this.opsWrapper = undefined;
                this.oppy = undefined;
                this.lstOPSWrapper = [];
                this.showSpinner = false;
            }
        })
    }

    //Validate if there is any product without Product schedules then show error
    validateOPSList() {
        for(let item in this.lstOPSWrapper){
            if(!this.lstOPSWrapper[item].lstOPS || this.lstOPSWrapper[item].lstOPS.length == 0) {
                this.noOPSforProduct = true;
                this.disableSave = true;
                break;
            }
        }
    }

    //Called after all components are loaded
    renderedCallback() {
        if(!this.pageLoad){
            this.pageLoad = true;
            this.setDynamicWidth(); 
        } 
    }

    //Setting width of div to show filter in expanded state
    setDynamicWidth(){
        this.hideFilter = false;
        let colFilter = this.template.querySelector(`[data-id="collapsedFilter"]`);
        let expFilter = this.template.querySelector(`[data-id="expandFilter"]`);
        let prodList = this.template.querySelector(`[data-id="prodList"]`);
        colFilter.classList.toggle('slds-hide');
        expFilter.style.width = '15%';
        prodList.style.width = '85%';
    }

    //show/hide Filter on collapse/expand button click
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

    //Stop Spinner once Save operation is completed
    stopSpinner(event) {
        this.showSpinner = false;
        if(event.detail.status === 'Success') {
            if(this.closeTab) {
                this.cancelChanges('cancel');
            }
        }
    }

    //Save Product Details
    saveProducts(event) {
        this.showSpinner = true;
        this.template.querySelector('c-opportunity-Add-Product-List').saveOppyProductList();
        this.closeTab = true;
    }

    //Open Legal Entity Page to change it based on Product List 
    changeLegalEntity(event) {
        publish(this.messageContext, SELECTED_PRODUCTS_LIST, {
            selProductsList : this.selProductsList,
            mode : 'addScreen'
        });
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
            this.disableSave = false;
        } else {
            this.disableSave = true;
        }
    }
}