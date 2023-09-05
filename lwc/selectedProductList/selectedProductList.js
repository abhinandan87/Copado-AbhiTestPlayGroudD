import { LightningElement,api,wire,track } from 'lwc';
// Lightning Message Service and a message channel
import {subscribe, MessageContext} from 'lightning/messageService';
import SELECTED_PRODUCTS from '@salesforce/messageChannel/SelectedProducts__c';
import LEGAL_PRODUCTS_LIST from '@salesforce/messageChannel/LegalProductsList__c';
//Apex methods
import getProductsAlreadyInOppy from '@salesforce/apex/ProductSearchControllerLWC.getProductsAlreadyInOppy';
import { showMessage } from 'c/lwcUtility';
//Import Custom Labels
import maxAddProductCount  from "@salesforce/label/c.AddEditProdMaxAddProductCount";
import maxOppyProductCount  from "@salesforce/label/c.AddEditProdMaxOppyProductCount";

export default class SelectedProductList extends LightningElement {
    @api oppyId;
    @track globalSectionShow = true;
    @track lstOppyProductIds = [];
    @wire(MessageContext) messageContext;
    selectedProductSubscription;
    legalProductSubscription;
    //iMaxAddProductCount = 250;
    //iMaxOppyProductCount = 350;
    @track selectedProducts = [];
    @track emptyProductList = true;
    errorVariant = 'error';
    label = {
        maxAddProductCount,
        maxOppyProductCount
    };
    
    //Collapse/Expand Selected Product Section
    collapseSec(event){
        if(this.globalSectionShow === true){
            this.globalSectionShow = false;
        }
        else{
            this.globalSectionShow = true;
        }
    }

    //On load
    connectedCallback() { 
        this.fetchExistingProductList();       
        this.subscriptions();
    }

    fetchExistingProductList() {
        getProductsAlreadyInOppy( { oppyId: this.oppyId})
        .then(( data ) => {
            if(data) {
                this.lstOppyProductIds = data;
            }
        })
        .catch((error)=>{
            console.log('Error in fetching Existing Products ' + JSON.stringify(error));
        })

    }

    // Subscribe to the different Message Channels
    subscriptions() {        
        this.selectedProductSubscription = subscribe(
            this.messageContext,
            SELECTED_PRODUCTS,
            (message) => this.handleSelection(message)
        );
        this.legalProductSubscription = subscribe(
            this.messageContext,
            LEGAL_PRODUCTS_LIST,
            (message) => this.handleLegalBackProducts(message)
        );
    }

    //Receive products on back from LegalEntityScreen
    handleLegalBackProducts(message){
        this.selectedProducts = [...message.legalProdList];
        this.selectedProducts.length === 0 ? this.emptyProductList = true : this.emptyProductList = false;
        this.customEventFire();
    }

    //Receive Selected Products from SearchProductList
    handleSelection(message) {
        let iAddProdCount = this.selectedProducts ? this.selectedProducts.length  : 0;  
        let iOppyProdCount = this.lstOppyProductIds ? this.lstOppyProductIds.length  : 0;  
       
        if(iAddProdCount >= this.label.maxAddProductCount) {
            let errorMessage = 'Maximum ' + this.label.maxAddProductCount + ' products can be added at a time.';
            showMessage(this, "Error!", errorMessage, this.errorVariant);
            return;
        }
        if((iAddProdCount + iOppyProdCount) >= this.label.maxOppyProductCount) {
            let errorMessage = 'More than ' + this.label.maxOppyProductCount + ' products cannot be added to an Opportunity.';
            showMessage(this, "Error!", errorMessage, this.errorVariant);
            return;
        }
         this.selectedProducts.push(message.selProduct);
         this.selectedProducts.length === 0 ? this.emptyProductList = true : this.emptyProductList = false;
         this.customEventFire();         
     }

    //Remove Selected Product
    removeSelectedProduct(event){
        const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
        console.log('pillIndex ' + JSON.stringify(pillIndex));    
        const proditem = this.selectedProducts;
        proditem.splice(pillIndex,1);       
        this.selectedProducts = [...proditem];
        this.selectedProducts.length === 0 ? this.emptyProductList = true : this.emptyProductList = false;
        this.customEventFire();
    }

    //Custom Event Fire to send latest added/removed Products List to SearchLWCContainer 
    // For Proceed button to Show/Hide
    customEventFire(event){
        let selProdsList = this.selectedProducts;
        this.dispatchEvent(new CustomEvent('selprodlist',{
           "detail": {"prodList":selProdsList}}));
    }

}