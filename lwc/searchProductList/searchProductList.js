import { LightningElement,api,wire,track} from 'lwc';
// Lightning Message Service and a message channel
import {publish, subscribe, MessageContext} from 'lightning/messageService';
import SEARCHPRODUCT_FILTERS from '@salesforce/messageChannel/SearchProductFilters__c';
import SELECTED_PRODUCTS from '@salesforce/messageChannel/SelectedProducts__c';
// Apex call
import getProducts from '@salesforce/apex/ProductSearchControllerLWC.getProducts';

export default class SearchProductList extends LightningElement {
    @api oppyId;
    productFilterSubscription;
    filterValues;
    @track updatedProductList = [];
    @track paginatedProductList = [];
    @track emptyProductList = true;
    @track selectedProduct = '';
    showSpinner = false;
    pageNumber = 1;
    pageSize = 10;
    totalItemCount = 0;
    
    @wire(MessageContext) messageContext;

    //Initialize values
    connectedCallback() {        
        this.subscriptions();
    }

     // Subscribe to the different Message Channels
     subscriptions() {
        // Subscribe to ProductsFiltered message
        this.productFilterSubscription = subscribe(
            this.messageContext,
            SEARCHPRODUCT_FILTERS,
            (message) => this.handleFilterChange(message)
        );
    }

    //Receive Fitlers selected by User and refine Product List
    handleFilterChange(message) {
        this.showSpinner = true;
        this.filterValues = message.searchFilters;
        if(this.filterValues){
            this.updateProdList(); 
        }
    }

    // Get Product List based on filter values
    updateProdList(){
        this.emptyProductList = true;
        this.updatedProductList = [];
        this.paginatedProductList = [];
        this.totalItemCount = 0;
        this.pageNumber = 1;
        let SearchProdValue = "";
        let SearchMaterialCodeValue = "";
        let SearchInternalProdValue = "";
        let SearchProfitCenterValue = "";
        let SearchMediaTypeValue = "";
        let SearchFamilyNameValue = "";
        let SearchProductGroupValue = "";
        let SearchAAGValue = "";
        let SearchIBSValue = "";
        let SearchBLValue = "";
        let SearchSBLValue = "";

            //Check if Filter is applied
            if (this.filterValues) {
                if (this.filterValues.ProductName) {
                    SearchProdValue = this.filterValues.ProductName;
                }
                if (this.filterValues.MaterialCode) {
                    SearchMaterialCodeValue = this.filterValues.MaterialCode;
                }
                if (this.filterValues.InternalProdName) {
                    SearchInternalProdValue = this.filterValues.InternalProdName;
                }
                if (this.filterValues.ProfitCenter) {
                    SearchProfitCenterValue = this.filterValues.ProfitCenter;
                }
                if (this.filterValues.MediaType) {
                    SearchMediaTypeValue = this.filterValues.MediaType;
                }
                if (this.filterValues.FamilyName) {
                    SearchFamilyNameValue = this.filterValues.FamilyName;
                }
                if (this.filterValues.ProductGroup) {
                    SearchProductGroupValue = this.filterValues.ProductGroup;
                }
                if (this.filterValues.AAG) {
                    SearchAAGValue = this.filterValues.AAG;
                }
                if (this.filterValues.IBS) {
                    SearchIBSValue = this.filterValues.IBS;
                }
                if (this.filterValues.BL) {
                    SearchBLValue = this.filterValues.BL;
                }
                if (this.filterValues.SBL) {
                    SearchSBLValue = this.filterValues.SBL;
                }
           
            if (SearchProdValue || SearchMaterialCodeValue || SearchInternalProdValue || SearchProfitCenterValue ||
                SearchMediaTypeValue || SearchFamilyNameValue || SearchProductGroupValue || SearchProductGroupValue
                || SearchAAGValue || SearchIBSValue || SearchBLValue || SearchSBLValue){
                getProducts({ 
                    familyName: SearchFamilyNameValue, 
                    productName: SearchProdValue, 
                    materialNumber: SearchMaterialCodeValue,
                    businessLine: SearchBLValue, 
                    subBusinessLine: SearchSBLValue, 
                    profitCenter: SearchProfitCenterValue,
                    mediaType: SearchMediaTypeValue,
                    internalProductName: SearchInternalProdValue,
                    productGroup: SearchProductGroupValue,
                    internalBusinessSegment: SearchIBSValue,
                    aag:SearchAAGValue})
                .then(( data ) => {
                        if (data) {
                            //this.prodWrapper = data;
                            this.updatedProductList = data;
                            this.updatedProductList.length === 0 ? this.emptyProductList = true : this.emptyProductList = false;
                            this.showPaginatedProducts();
                            this.error = undefined;
                            this.showSpinner = false;
                        }
                    })
                    .catch((error) => {
                        if (error) {
                        console.log('Error Occured**' + JSON.stringify(error));
                        this.error = error;
                        this.updatedProductList = undefined;
                        this.emptyProductList = true;
                        this.showSpinner = false;
                    }
                })

            }
            else{
                this.showSpinner = false; // No data
            }
        }
    }

    // Get selected product
    selectProduct(event){
        let prodIndex = event.currentTarget.dataset.id;
        if (prodIndex) {
            this.selectedProduct = this.paginatedProductList[prodIndex];
        }
        this.publishSelectedProduct();
    }
    
    // Publish message and subscribe in selectedProductList
    publishSelectedProduct(){
        publish(this.messageContext, SELECTED_PRODUCTS, {
            selProduct : this.selectedProduct
        });
    }

    // Pagination handle
    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.showPaginatedProducts();
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.showPaginatedProducts();
    }

    handlePageSize(event) {
        let pgSize = event.detail.size;
        if(pgSize) {
            this.pageSize = pgSize;
            this.pageNumber = 1;
            this.showPaginatedProducts();
        }
    }

    showPaginatedProducts(){
        this.paginatedProductList = [];
        let fromItemNbr = (this.pageSize * (this.pageNumber - 1));
        let toItemNbr = (this.pageSize * this.pageNumber);
        console.log('fromItemNbr ' + fromItemNbr + ' toItemNbr ' + toItemNbr);
        let i;
        this.totalItemCount = this.updatedProductList.length;
        for(i=fromItemNbr; i<toItemNbr; i++){
           if(this.totalItemCount==i){
                break;
            }
            this.paginatedProductList.push(this.updatedProductList[i]);
        }        
    }

}