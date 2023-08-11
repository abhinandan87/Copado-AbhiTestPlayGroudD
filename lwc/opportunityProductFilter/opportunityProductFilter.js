import { LightningElement,api,wire,track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

// Lightning Message Service and a message channel
import { publish, MessageContext } from 'lightning/messageService';
import PRODUCT_FILTERS from '@salesforce/messageChannel/ProductFilters__c';

// Opp Product schema
import STATUS_FIELD from '@salesforce/schema/OpportunityLineItem.Status__c';
import PRODUCTRISK_FIELD from '@salesforce/schema/OpportunityLineItem.IsProductatRisk__c';
import RecordTypeVal from '@salesforce/label/c.DefaultLwcRecordTypeId';

export default class ProductFilter extends LightningElement {
    
    @api mode;
    editScreen = false;
    errorProducts = false;
    sortValues = 'Name';

    filters = {
        searchKey: '',
        sortby: 'Name'
    };


    @wire(MessageContext)
    messageContext;

    connectedCallback(){  
        // Indicating Product Filters getting called from Add or Edit Screen
        if(this.mode == 'Add') {
            this.editScreen = false;
            this.filters = {
                searchKey: '',
                searchFamily: '',
                searchGroup: '',
                sortby: 'Name'
            };
        
        } else {
            this.editScreen = true;           
        }

        this.filters.yearSelected = this.yearOptions.map(
            (item) => item.value
        );
        this.filters.errorProducts = false;
    }

    @wire(getPicklistValues, {
        recordTypeId: RecordTypeVal,
        fieldApiName: STATUS_FIELD
    })     
    statuses;
    
    
    @wire(getPicklistValues, {
        recordTypeId: RecordTypeVal,
        fieldApiName: PRODUCTRISK_FIELD
    })     
    productrisks;


    get sortOptions() {
        return [
            { label: 'Product Name', value: 'Name' },
            { label: 'Material Code', value: 'MaterialCode__c' },
        ];
    }

    get yearOptions() {
        return [
          { label: "1", value: "1" },
          { label: "2", value: "2" },
          { label: "3", value: "3" },
          { label: "4", value: "4" },
          { label: "5", value: "5" }
        ];
    }
    
    
    defaultFilterValues(){
        // Populate all values of default statuses/risk one time, if statuses is undefined 
        if (!this.filters.statuses) {
            this.filters.statuses = this.statuses.data.values.map(
                (item) => item.value
            );
            this.filters.productrisks = this.productrisks.data.values.map(
                (item) => item.value
            );
        }
    }

    handleSearchKeyChange(event) {
        // Get selected search value
        // If Search key is populated first in filters, Populate all values of default statuses/risk one time, if statuses is undefined 
        if(event.target.dataset.id === 'searchProdVal'){
            this.filters.searchKey = event.target.value;
        }
        if(this.mode == "Edit"){   
            this.defaultFilterValues();  
        }
        else{
            if(event.target.dataset.id === 'searchFamilyNameVal'){
                this.filters.searchFamily = event.target.value;
            }
            if(event.target.dataset.id === 'searchProdGroupVal'){
                this.filters.searchGroup = event.target.value;
            }
        }              
       this.publishFilters();
    }

    handleSortByChange(event) {
        // Get selected sort value 
        if(this.mode == "Edit"){   
            this.defaultFilterValues();  
        }
        this.filters.sortby = event.target.value;
        this.publishFilters();
    }

    handleErroredProducts(event) {
        // Passing only selected values in filter variable
        if(this.mode == "Edit"){
            this.defaultFilterValues();
        }
        this.filters[event.target.dataset.filter] = event.target.checked;
        this.publishFilters();
    }

    handleCheckboxChange(event) {
        // Passing only selected values in filter variable
        this.defaultFilterValues();
        const value = event.target.dataset.value;    // getting selected value
        const filterArray = this.filters[event.target.dataset.filter];   // getting all values of that particular dataset

        if (event.target.checked) {
            if (!filterArray.includes(value)) {
                filterArray.push(value);   // Adding selected element if not added
            }
        } else {
            this.filters[event.target.dataset.filter] = filterArray.filter(
                (item) => item !== value   // Removing unselected element
            );
        }

        this.publishFilters();
    }
    
    // publish Filter array values in OpportunityProductList
    publishFilters(){
        publish(this.messageContext, PRODUCT_FILTERS, {
            prodFilters : this.filters
        });
    }
}