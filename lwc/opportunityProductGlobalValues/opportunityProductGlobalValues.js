import { LightningElement,api,wire,track } from 'lwc';

//Get Picklist values from OppLineItem Metadata
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LICENSE_FIELD from '@salesforce/schema/OpportunityLineItem.LicenseType__c';  
import RISKSTATUS_FIELD from '@salesforce/schema/OpportunityLineItem.RiskStatus__c';
import DISCOUNTTYPE_FIELD from '@salesforce/schema/OpportunityLineItem.DiscountType__c';

// To display toast message from lwcUtility
import { showMessage } from 'c/lwcUtility';  

// Lightning Message Service and a message channel - Publish
import { publish, MessageContext } from 'lightning/messageService';
import PRODUCT_GLOBAL_VALUES from '@salesforce/messageChannel/ProductGlobalValues__c';

// Get Custom label value
import RecordTypeVal from '@salesforce/label/c.DefaultLwcRecordTypeId';

export default class OpportunityProductGlobalValues extends LightningElement {
    
    @api getOpsWrapper = [];
    @api oppy;
    @api recordids;
    @api mode = 'Add';

    licenseTypeVal = '';
    discountTypeVal = 'No Discount';
    discountStepVal = 'Flat';
    discountValueVal = 0;
    upliftVal = 0;
    yearsVal = '1';
    riskStatusVal = '';
    prorationVal = 'Yes';  
    probabilityVal = 0;
    prodRisk = false;
    scrollAfterNItems=5;    
    lstOPSWrapper;
    globalProRateDisplay = false;
    autoRenewNoChanges = false;
    disableDiscountType = false;
    disableUplift = false;
    is6W = false;
    editScreen = false;
    discValAnnot = 'Discount Value';

    @track disableRiskStat = true;
    @track lookupAddresses;
    @track searchedAddresses = [];
    @track licensePicklistValues;
    @track discounttypePicklistValues;
    @track riskstatusPicklistValues;
    @track globalSectionShow = true;
    
    @track globalvals = {      // globalvals array for publishing values selected
        fieldName : '',
        fieldValue : ''
    };
    

    @wire(MessageContext) messageContext; // Declare for publishing message

    renderedCallback(){        												
        if (this.oppy != null && this.oppy.AutoRenewal__c && !this.getOpsWrapper.isAdmin && !this.getOpsWrapper.isSalesOps) { // Allow Sales Ops to edit Opportunity Products on any Sales Stage including 6WP                        
            if(!this.oppy.DoesThisAutoRenewalHaveChanges__c) {
                this.autoRenewNoChanges = true;
            }                          
        }
    }

    connectedCallback() {       
        // Set Values from Wrapper
        this.lstOPSWrapper = this.getOpsWrapper.lstOPSWrapper; 
        this.globalProRateDisplay = this.getOpsWrapper.canBeProRated;
        this.lookupAddresses = this.getOpsWrapper.lookupAddresses;

        //Proration field show hide
        if(!this.getOpsWrapper.canBeProRated){
            this.prorationVal = 'No'; 
        } 
        else {              
            if(this.getOpsWrapper.isProRated == 'No') {
                this.prorationVal =  'No';  
            }
        }
        
														
        if (this.oppy != null && this.oppy.AutoRenewal__c && !this.getOpsWrapper.isAdmin && !this.getOpsWrapper.isSalesOps) { // Allow Sales Ops to edit Opportunity Products on any Sales Stage including 6WP                        
            if(!this.oppy.DoesThisAutoRenewalHaveChanges__c) {
                this.autoRenewNoChanges = true;
            }
            if(this.oppy.StageName.toLowerCase().indexOf("6w")!==-1) {
               this.is6W = true;
            }                           
        }

        // Indicating Global Values called from Add or Edit Screen
        if(this.mode == 'Add') {
            this.editScreen = false;
        } else {
            this.editScreen = true;
        }

        if(this.oppy.RecordType.DeveloperName=='Gratis' || (this.autoRenewNoChanges && !(this.oppy.PriceChangeOnly__c)) || this.is6W){
            this.disableDiscountType = true;
        }
        if(this.oppy.RecordType.DeveloperName=='Gratis' || this.autoRenewNoChanges  || this.is6W){
            this.disableUplift = true;
        }
    }

    //Set License Type Picklist options
    @wire(getPicklistValues, {
        recordTypeId: RecordTypeVal,
        fieldApiName: LICENSE_FIELD
    })   
    getLicensePicklistValues(result) {
       if (result.data) {
           this.licensePicklistValues = [{ label: '--None--', value: '', selected: true }, ...result.data.values ];
       } else if (result.error) {
            console.log('ERROR');
       }
    }
   
   //Set Discount Type Picklist options
    @wire(getPicklistValues, {        
       recordTypeId: RecordTypeVal,
       fieldApiName: DISCOUNTTYPE_FIELD
    })      
    getDiscountTypePicklistValues(result) {
       if (result.data) {
           this.discounttypePicklistValues = result.data.values;
       } else if (result.error) {
            console.log('ERROR');
       }
    }

    // Enable/Disable Discount Value based on Discount Type
    get disableDiscStep(){
       if(this.discountTypeVal === 'No Discount'){
           return true;
       }
           return false;
    }

    // Display Discount Step options values
    get stepOptions() {
           return [
               { label: 'Flat', value: 'Flat' },
               { label: 'Step up', value: 'Step up' },
               { label: 'Step down', value: 'Step down' },
           ];
    } 
   
    //Display Year options
    get yearOptions() {
       return [
           { label: '1 Year', value: '1' },
           { label: '2 Years', value: '2' },
           { label: '3 Years', value: '3' },
           { label: '4 Years', value: '4' },
           { label: '5 Years', value: '5' },
       ];
    } 
   
    // Set Risk Status Picklist values 
    @wire(getPicklistValues, {
       recordTypeId: RecordTypeVal,
       fieldApiName: RISKSTATUS_FIELD
    })   
    getRiskStatusPicklistValues(result) {
       if (result.data) {
           this.riskstatusPicklistValues = [{ label: '--None--', value: '', selected: true }, ...result.data.values ];
       } else if (result.error) {
           console.log('ERROR');
       }
    } 

    //Display Proration Options
    get prorationOptions() {
       return [
           { label: 'Yes', value: 'Yes' },
           { label: 'No', value: 'No' },
           
       ];
    }   
   
    //Collapse-Uncollapse Global Values section
    collapseSec(event){
       this.globalSectionShow = this.globalSectionShow === true ? false : true;
    }
   
    // Enable/Disable Risk status based on Product status checkbox and List of products
    // Publish ProductAtRisk value
    riskhandleChange(event){    
        this.globalvals.fieldName = event.target.dataset.id;
        this.globalvals.fieldValue = event.target.checked;
        this.prodRisk = event.target.checked;        
        var lstProductsAdded = this.lstOPSWrapper;
        if(this.lstOPSWrapper != null || this.lstOPSWrapper != 'undefined'){
            for(var val in lstProductsAdded ) {
                if (lstProductsAdded[val].status === 'Existing') {
                    this.disableRiskStat = this.prodRisk === true ? false : true;
                }
            }
        }
        this.publishGlobalValues();       
    }

    // This method is responsible for setting/publishing values on user change
    handleChange(event){       
        var value;    
        this.globalvals.fieldName = event.target.dataset.id;            
        value = event.target.value; 
        this.globalvals.fieldValue = value;
        
        if(event.target.dataset.id === 'LicenseType'){
            this.licenseTypeVal = value;
        }
        if(event.target.dataset.id === 'DiscountType'){
            this.discountTypeVal = value;
            this.discountValueVal = 0;
            if(this.discountTypeVal === 'No Discount'){
                //this.discountValueVal = 0;
                this.discValAnnot = 'Discount Value';
            }
            else if(this.discountTypeVal === 'Amount'){
                this.discValAnnot = 'Discount Value'+ '(' + this.oppy.CurrencyIsoCode + ')';
            }
            else if(this.discountTypeVal === 'Percentage'){
                this.discValAnnot = 'Discount Value' + '(%)';
            }
        }
        if(event.target.dataset.id === 'DiscountStep'){
            this.discountStepVal = value;
        }
        if(event.target.dataset.id === 'DiscountValue'){
            this.discountValueVal = value;
        }
        if(event.target.dataset.id === 'Uplift'){
            this.upliftVal = value;
        }
        if(event.target.dataset.id === 'Years'){
            this.yearsVal = value;
            if(this.yearsVal != 1 && this.prorationVal === 'Yes'){
                let msg = 'For Prorated Products, Term will be set to 1'
                showMessage(this, "Warning!", msg, 'warning'); 
            }
        }
        if(event.target.dataset.id === 'RiskStatus'){
            this.riskStatusVal = value;
        }
        if(event.target.dataset.id === 'Proration'){
            this.prorationVal = value;
        }
        if(event.target.dataset.id === 'Probability'){
            this.probabilityVal = value;
        }
        this.publishGlobalValues();
    }

    // Publish Global Values to OpportunityProductList 
    publishGlobalValues(){
        publish(this.messageContext, PRODUCT_GLOBAL_VALUES, {
            prodGlobalValues : this.globalvals
        });
    }

    
}