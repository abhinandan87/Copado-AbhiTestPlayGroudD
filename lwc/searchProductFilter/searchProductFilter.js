import { LightningElement,api,wire,track} from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import AAG_FIELD from '@salesforce/schema/Product2.AAG__c';
// Lightning Message Service and a message channel
import {publish, MessageContext} from 'lightning/messageService';
import SEARCHPRODUCT_FILTERS from '@salesforce/messageChannel/SearchProductFilters__c';
import getIbsBsSubBsLines from '@salesforce/apex/ProductSearchControllerLWC.getIbsBsSubBsLines';
import { showMessage, sortByArray } from 'c/lwcUtility';

export default class SearchProductFilter extends LightningElement {
    @api filtersList;
    aagPicklistValues;
    aagVal = '';
    ibsVal = '';
    blVal = '';
    subVal = '';
    productGroupVal = '';
    familyNameVal = '';
    mediaTypeVal = '';
    profitCenterVal = '';
    internalProdNameVal = '';
    materialCodeVal = '';
    productNameVal = '';
    @track listIbsValues = [{ label: '--None--', value: '', selected: true }];
    @track listBlValues = [{ label: '--None--', value: '', selected: true }];
    @track listSblValues = [{ label: '--None--', value: '', selected: true }];    
    error;
    disableBlValues = true;
    disableSBlValues = true;
    mapSegments;
    lstIBS = [];
    delayTimer;

    filters = {
        ProductName : '',
        MaterialCode : '',
        InternalProdName : '',
        ProfitCenter : '',
        MediaType : '',
        FamilyName : '',
        ProductGroup : '',
        AAG : '',
        IBS : '',
        BL : '',
        SBL : ''
    };

    @wire(MessageContext)
    messageContext;

    connectedCallback() { 
        this.fetchProdSegments();
    }

    // Fetch Map of Ibs,Bs and SubBs lines from Apex
    fetchProdSegments() {
        getIbsBsSubBsLines()
        .then((data) => {
            if(data){
                this.mapSegments = data;
                for (let key in this.mapSegments) {
                    this.lstIBS.push({IBS:key, MapBsSbs:this.mapSegments[key]});
                }
                this.lstIBS.forEach((prod) => {
                    this.listIbsValues = [...this.listIbsValues,{value: prod.IBS , label: prod.IBS}]; // Internalbussegments
                })
                if(this.filtersList){
                    this.setFilters();
                }
            }
        })
        .catch((error) => {
            if (error) {
            console.log('Error** ' + JSON.stringify(error));
            this.error = error;
           }
        })
    }
    
    // To set Filters from Back button on Legal and Add product Screen
    setFilters(){
        this.filters = JSON.parse(JSON.stringify(this.filtersList)); // To remove read only property and make new JSON
        this.productNameVal = this.filters.ProductName;
        this.materialCodeVal = this.filters.MaterialCode;
        this.aagVal = this.filters.AAG;
        this.ibsVal = this.filters.IBS;
        if(this.ibsVal != ''){
            this.setBusinessLine();
            if(this.blVal != ''){
                this.setSubBusinessLine();
            }
        }
        this.internalProdNameVal = this.filters.InternalProdName;
        this.profitCenterVal = this.filters.ProfitCenter;
        this.mediaTypeVal = this.filters.MediaType;
        this.familyNameVal = this.filters.FamilyName;
        this.productGroupVal = this.filters.ProductGroup;
        this.publishFilters();
    }

    // Retain/Set Business Line value on Back button
    setBusinessLine(){
        let prodindex = this.lstIBS.findIndex((item) => item.IBS == this.ibsVal);
        this.listBlValues = [{ label: '--None--', value: '', selected: true }];
        for (let BSline in this.lstIBS[prodindex].MapBsSbs) {
            this.listBlValues = [...this.listBlValues,{value: BSline , label: BSline}]; 
        }
        let subComboBoxVal = this.template.querySelector(`[data-id="BL"]`); 
        subComboBoxVal.value = this.filters.BL;
        this.blVal = this.filters.BL;
        this.disableBlValues = false;
        this.disableSBlValues = true;
    }

    //Retain/Set Sub Business Line value on Back button
    setSubBusinessLine(){
        this.disableSBlValues = false;                
        let prodindex = this.lstIBS.findIndex((item) => item.IBS == this.ibsVal);               
        this.listSblValues = [{ label: '--None--', value: '', selected: true }];       
        for (let BSline in this.lstIBS[prodindex].MapBsSbs) {
            if(BSline == this.blVal){
                this.lstIBS[prodindex].MapBsSbs[BSline].forEach((SBSline)=> { 
                    this.listSblValues = [...this.listSblValues,{value: SBSline , label: SBSline}]; 
                })
            }           
        }
        let subComboBoxVal = this.template.querySelector(`[data-id="SBL"]`);
        subComboBoxVal.value = this.filters.SBL;
        this.subVal = this.filters.SBL;
    }

    // Handle BusinessLine values on InternalBusinessSegment change
    handleIBSChange(event){
        let value;                   
        value = event.target.value;        
        if(event.target.dataset.id === 'IBS'){
            this.listBlValues = [{ label: '--None--', value: '', selected: true }];
            this.listSblValues = [{ label: '--None--', value: '', selected: true }];
            this.blVal = '';
            let subComboBoxVal = this.template.querySelector(`[data-id="SBL"]`);
            subComboBoxVal.value = '';
            //this.subVal = '';
            this.ibsVal = value;
            this.filters.IBS = value;
            this.filters.BL =  '';
            this.filters.SBL = '';
            if(value != ''){
                this.disableBlValues = false;
                this.disableSBlValues = true;              
                let prodindex = this.lstIBS.findIndex((item) => item.IBS == this.ibsVal);             
                for (let BSline in this.lstIBS[prodindex].MapBsSbs) {
                    this.listBlValues = [...this.listBlValues,{value: BSline , label: BSline}]; 
                }                
            }
            else{
                this.disableBlValues = true;
                this.disableSBlValues = true;
            }
            this.publishFilters();
        }
        
    }
    
    // Handle SubBusinessLine values on BusinessLine change
    handleBSLineChange(event){
        let value;                   
        value = event.target.value;           
        if(event.target.dataset.id === 'BL'){           
            this.listSblValues = [{ label: '--None--', value: '', selected: true }];
            let subComboBoxVal = this.template.querySelector(`[data-id="SBL"]`);
            subComboBoxVal.value = '';
            //this.subVal = '';
            this.blVal = value;
            this.filters.SBL = '';
            this.filters.BL = value;         
            if(value != ''){
                this.disableSBlValues = false;                
                let prodindex = this.lstIBS.findIndex((item) => item.IBS == this.ibsVal);               
                for (let BSline in this.lstIBS[prodindex].MapBsSbs) {
                    if(BSline == this.blVal){
                        this.lstIBS[prodindex].MapBsSbs[BSline].forEach((SBSline)=> { 
                            this.listSblValues = [...this.listSblValues,{value: SBSline , label: SBSline}]; 
                        })
                    }                   
                }
            }
            else{
                this.disableSBlValues = true;
            }
            this.publishFilters();
        }       
    }

    // Set and publish values in filters
    handleSearchKeyChange(event){
        let value;                   
        value = event.target.value;        
        if(event.target.dataset.id === 'ProductName'){
            this.filters.ProductName = value;
        }
        if(event.target.dataset.id === 'MaterialCode'){
            this.filters.MaterialCode = value;
        }
        if(event.target.dataset.id === 'InternalProdName'){
            this.filters.InternalProdName = value;
        }
        if(event.target.dataset.id === 'ProfitCenter'){
            this.filters.ProfitCenter = value;
        }
        if(event.target.dataset.id === 'MediaType'){
            this.filters.MediaType = value;
        }
        if(event.target.dataset.id === 'FamilyName'){
            this.filters.FamilyName = value;
        }
        if(event.target.dataset.id === 'AAG'){
            this.filters.AAG = value;
        }
        if(event.target.dataset.id === 'ProductGroup'){
            this.filters.ProductGroup = value;
        }
        if(event.target.dataset.id === 'SBL'){
            this.filters.SBL = value;
        }
        clearTimeout(this.delayTimer);
        // Delay added of .5 sec to get latest search list from server
        this.delayTimer = setTimeout(this.publishFilters.bind(this), 500); 
    }

    // Get AAG values
    @wire(getPicklistValues, {
         recordTypeId: '012000000000000AAA',
         fieldApiName: AAG_FIELD
     })   
    getAAGPicklistValues(result){
        if (result.data) {
            this.aagPicklistValues = [{ label: '--None--', value: '', selected: true }, ...result.data.values];
            const sortPicklistVal = [...this.aagPicklistValues]; 
            sortPicklistVal.sort(sortByArray('label', 1));          // call utility to sort    
            this.aagPicklistValues = sortPicklistVal;
        } else if (result.error) {
            console.log('ERROR');
        }
    }
   
    // Publish Filter values in SearchProductList
    publishFilters(){      
        publish(this.messageContext, SEARCHPRODUCT_FILTERS, {
            searchFilters : this.filters
        });    
        this.customEventFire(); 
    }

    //Custom Event Fire to send Filters List to Search LWC Container 
    //To set Filters later on Back buttons
    customEventFire(event){
        let filterSearchList = this.filters;
        this.dispatchEvent(new CustomEvent('filterprodlist',{
           "detail": {"filterList":filterSearchList}}));
    }

}