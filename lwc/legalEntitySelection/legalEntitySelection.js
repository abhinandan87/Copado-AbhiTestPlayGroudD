import { LightningElement, api, wire, track } from 'lwc';

import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { showMessage, sortByArray } from 'c/lwcUtility';
// Import custom labels
import RecommendedLegalEntityHeaderLabel from '@salesforce/label/c.RecommendedLegalEntityHeader';
import RecommendedLegalEntityNoteLabel from '@salesforce/label/c.RecommendedLegalEntityNote';
import ExceptionCheckboxLabel from '@salesforce/label/c.ExceptionCheckboxLabel';
import ExceptionInformativeMessageLabel from '@salesforce/label/c.ExceptionInformativeMessage';
// Server call functions
import getProductsAlreadyInOppy from '@salesforce/apex/ProductSearchControllerLWC.getProductsAlreadyInOppy';
import productSelectionRuleEngine from '@salesforce/apex/ProductSelectionController.productSelectionRuleEngine';
import getOppCountry from '@salesforce/apex/ProductSelectionController.getOppCountry';
import getListLegalEntity from '@salesforce/apex/ProductSelectionController.getListLegalEntity';
import saveProductsOnOpportunity from '@salesforce/apex/ProductSelectionController.saveProductsOnOpportunity';
import exceptionApprovalEmail from '@salesforce/apex/ProductSelectionController.exceptionApprovalEmail';
import updateLegalEntityOnOppy from '@salesforce/apex/ProductSelectionController.updateLegalEntityOnOppy';
// Lightning Message Service and message channels
import {publish, MessageContext} from 'lightning/messageService';
import LEGAL_PRODUCTS_LIST from '@salesforce/messageChannel/LegalProductsList__c';
import ADD_PRODUCTS_LIST from '@salesforce/messageChannel/AddProductsList__c';

export default class LegalEntitySelection extends NavigationMixin(LightningElement) {
    //input parameters
    @api recordId;
    @api selectedProdList;
    @api mode;
    @api productsRemoved = false;
    @api lstOpsWrapper = [];
    
    error;
    openModal = false;
    showSpinner = true;
    existingOppProdList;
    allProductsIds = [];
    lstCurrentProductsSelected = [];
    selectedMaterialCodes = [];
    materialCodes='';
    legalEntityResultWrapper = []; // Wrapper
    lstRecommendedLegalEntity = [{ label: '--None--', value: '', selected: true }];
    recommendedLegalEntity = '';
    setRecommendedLegalEntity = '';
    setLstRecommendedLegalEntity = [];
    lstRequestedLegalEntity = [{ label: '--None--', value: '', selected: true }];
    requestedLegalEntity = '';   
    recLegalEntityName = '';
  
    isCheck = false;
    countryTerritory = '';
    dollarValue = '';
    requestReason = '';
    hideProceed = true;
    hideShow = true;
    hideBack = false;
    errorVariant = 'error';
    successVariant = 'success';

    @wire(MessageContext) messageContext;

    label = {
        RecommendedLegalEntityHeaderLabel,
        RecommendedLegalEntityNoteLabel,
        ExceptionCheckboxLabel,
        ExceptionInformativeMessageLabel
    };

    connectedCallback(){
        this.showSpinner = true;
        this.openModal = (this.mode == 'editModal')? true : false; // Get from Edit Screen to show Legal Entity Modal
        this.mode = (this.mode == 'editModal')? 'editScreen' : this.mode;
        this.hideBack = (this.mode == 'editScreen')? true : false;   // Disable enable back button
        
        if(this.selectedProdList != null){
            this.getallProductIds();
        }
        if(this.recordId != null){
            this.fetchExistingOppProducts();
        }            
    }
    
    // Fetch Selected Products Id's and Material codes
    getallProductIds(){
        this.selectedProdList = JSON.parse(JSON.stringify(this.selectedProdList));       
        this.selectedProdList.forEach((item,index) =>{    
            if(!this.allProductsIds.includes(item.productId)){               
                this.allProductsIds.push(item.productId); // New array for Id's
                this.selectedMaterialCodes.push(item.product.MaterialCode__c);  // New array for Material codes
            }
            this.lstCurrentProductsSelected = this.allProductsIds;  // To keep only new selected product Id's
        });
    }
    
    // Fetch already existing Opportunity Products on Opportunity
    fetchExistingOppProducts(){
        getProductsAlreadyInOppy({oppyId: this.recordId})
        .then((data)=>{
            if(data){
                this.existingOppProdList = data;
                if(this.mode == 'addScreen'){  // concatenate Id's of existing and selected products if called from Add Screen else from edit remain existing prods only
                    this.allProductsIds = this.allProductsIds.concat(this.existingOppProdList);
                }
                if(this.allProductsIds != null){
                    this.callProductSelectionRuleEngine(); // for Recommended Legal Entity                    
                }
            }
        })
        .catch((error)=>{
            if (error) {
                console.log('Error Occured' + JSON.stringify(error));
                this.error = error;                
            }
        })
    }

    // Check Rule Engine
    callProductSelectionRuleEngine(){
        productSelectionRuleEngine({oppyId: this.recordId, lstProducts: this.allProductsIds})
        .then((data)=>{
            this.recommendedLegalEntity = '';
            this.legalEntityResultWrapper = data;
            this.recommendedLegalEntity =  this.legalEntityResultWrapper.recommendedLegalEntity;
            this.setRecommendedLegalEntity = this.recommendedLegalEntity; //set to again re-use it
            if(data.lstRecommendedLegalEntity != null){
                this.hideProceed = false;
                data.lstRecommendedLegalEntity.forEach((legal) => {
                    this.lstRecommendedLegalEntity = [...this.lstRecommendedLegalEntity,{label: legal.Name, value: legal.Id}]; // Internalbussegments
                })
                this.setLstRecommendedLegalEntity = this.lstRecommendedLegalEntity; // set to again re-use it
            }
            if(data.result !== "Success" && data.result !== "SUCCESS"){     
                    this.hideProceed = true;
                    let errMsg = data.errorMessage;      
                    showMessage(this, "Error!", errMsg, this.errorVariant);             
            }
            this.showSpinner = false;
        })
        .catch((error)=>{
            if (error) {
                console.log('Error Occured' + JSON.stringify(error));
                this.error = error;
                this.showSpinner = false;
            }
        })
    }

    // Set values on change 
    handleChange(event){
        var value;
        value = event.target.value; 
        if(event.target.dataset.id === 'recmLegEntityVal'){
            this.recommendedLegalEntity = value;
            this.recommendedLegalEntity == ''? this.hideProceed = true : this.hideProceed=false;
        }
        if(event.target.dataset.id === 'requestReasonVal'){
            this.requestReason = value;
        }
        if(event.target.dataset.id === 'reqLegEntityVal'){
            this.requestedLegalEntity = value;
        }
        if(event.target.dataset.id === 'dollarVal'){
            this.dollarValue = value;
        }        
    }

    // Display Exception Details form
    handleCheckboxChange(event){
        this.isCheck = event.target.checked;
        if(this.isCheck){           
            // set Value of Recommended Legal entity to None
            this.recommendedLegalEntity = '';
            this.hideShow = false;
            this.hideProceed = true;
            this.lstRecommendedLegalEntity = [{ label: '--None--', value: '', selected: true }];
            // get Requested legal entity
            this.lstRequestedLegalEntity = [{ label: '--None--', value: '', selected: true }];
            this.callListLegalEntity(); 

            // get Opp country
            this.getOpportunityCountry(); 

            // get material code comma seperated
            let lstMatCodes = this.selectedMaterialCodes;
            let matCode = '';
            for(var key in lstMatCodes){
                matCode += lstMatCodes[key] + ', ';
            }
            matCode = matCode.replace(/,\s*$/, "");
            this.materialCodes = matCode;                    
        }
        else{
            this.hideShow = true;
            this.requestReason = '';
            this.dollarValue = '';
            // Re-use set Recommended Legal entity during callback
            // avoid rule engine server call again
            this.recommendedLegalEntity = this.setRecommendedLegalEntity;  
            this.lstRecommendedLegalEntity = this.setLstRecommendedLegalEntity;
            if(this.recommendedLegalEntity != ''){
                this.hideProceed = false;
            }
        }
    }

    // Set Requested Legal Entity
    callListLegalEntity(){
        getListLegalEntity({lstProducts: this.allProductsIds})
        .then((data)=>{           
            if(data.lstRecommendedLegalEntity !== null && data!== null && data!== undefined){
                data.lstRecommendedLegalEntity.forEach((legal) => {
                    this.lstRequestedLegalEntity = [...this.lstRequestedLegalEntity,{label: legal.Name, value: legal.Id}]; // Internalbussegments
                    const sortPicklistVal = [...this.lstRequestedLegalEntity];       //Check Sort    
                    sortPicklistVal.sort(this.sortBy('label',1));     
                    this.lstRequestedLegalEntity = sortPicklistVal;
                })
            }
            if(data.result !== "SUCCESS" && data.result !=='Success'){   
                this.hideProceed = true;  
                let errMsg = data.errorMessage;      
                showMessage(this, "Error!", errMsg, this.errorVariant);
            }
        })
        .catch((error)=>{
            if (error) {
                console.log('Error Occured' + JSON.stringify(error));
                this.error = error;
            }
        })
    }

    // Get country on Opportunity
    getOpportunityCountry(){
        getOppCountry({opportunityId: this.recordId})
            .then((data)=>{
                if(data){
                    this.countryTerritory = data;          
                }
            })
            .catch((error)=>{
                if (error) {
                    console.log('Error Occured' + JSON.stringify(error));
                    this.error = error;
                }
            })
    }

     // Navigate to Opportunity Record Page
    onCancel(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            },
        });
    }

    //Custom event fire to Edit page for closing the Legal Entity Modal
    closeModal(event){
        this.dispatchEvent(new CustomEvent('close',{detail: {'legalEntityName' : this.recLegalEntityName}}));
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    // Publish message to Aura and call Search Product Screen
    onBack(event){
        publish(this.messageContext, LEGAL_PRODUCTS_LIST, {
                legalProdList : this.selectedProdList
            });
    }

    // Update legal entity on Opportunity 
    // Move to Add Product screen with selected products to Display
    onProceed(event){
        let lstLegalEntity = this.lstRecommendedLegalEntity;            
        for (var key in lstLegalEntity) {
            if (lstLegalEntity[key].value === this.recommendedLegalEntity) {
                this.recLegalEntityName = lstLegalEntity[key].label;
                break;
            }
        }
        if(this.mode == 'editScreen'){  
            this.callUpdateLegalEntityOnOppy();
        }
        else{ // for addScreen default            
            publish(this.messageContext, ADD_PRODUCTS_LIST, {
                addProdList :this.selectedProdList, // Array of selected Products
                legalEntityId : this.recommendedLegalEntity,
                legalEntityName : this.recLegalEntityName
            });
       }
    }

    // Call apex method UpdatelegalEntityonOppy to update Legal entity on Opp
    callUpdateLegalEntityOnOppy(){
        updateLegalEntityOnOppy({opportunityId: this.recordId, legalEntity: this.recommendedLegalEntity})
            .then((data)=>{           
                if(!data.includes('Error')){
                    let successMsg = data;
                    showMessage(this, "Record updated!", successMsg, this.successVariant);
                    if(this.openModal){                        
                        this.closeModal();
                    }
                    else{
                        this.onCancel();  // Navigate back to Oppy
                    }
                }
                
            })
            .catch((error)=>{
                if (error) {
                    console.log('Error Occured' + JSON.stringify(error));
                    this.error = error;
                }
            })
    }

    // Call Apex method saveProductsOnOpportunity
    // Check Validations
    // On successfull validations, Save products on Opportunity, Requested Legal Entity and Send Exception Approval Email
    onSave(event){
        this.showSpinner = true;
        let changeLegalCheck = false;  // in case of add
        //let prodRemoveCheck = false;
        if(this.mode == 'editScreen'){  // in case of edit
            changeLegalCheck = true;
        }
        let reason = this.requestReason;
        let legalEntity = this.requestedLegalEntity;
        let dollar = this.dollarValue;
        let country = this.countryTerritory;
        let matCodes = this.materialCodes;
        let prodRemoveCheck = this.productsRemoved;


        if(reason!='' && legalEntity!='' && dollar!='' && country!='' && matCodes!=''){
            saveProductsOnOpportunity({lstProductIds: this.lstCurrentProductsSelected, opportunityId: this.recordId,
                legalEntity: this.requestedLegalEntity, changeLegalEntityCheck: changeLegalCheck, productsRemovedCheck: prodRemoveCheck})
            .then((data)=>{ 
                let mssg = JSON.stringify(data);
                if(mssg.indexOf("successfully")!==-1){
                    this.callExceptionApprovalEmail();
                }
                if(mssg.indexOf("Error occurred")!==-1) {
                    if(mssg.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION") || mssg.includes("NUMBER_OUTSIDE_VALID_RANGE")) {
                        let validationMessage="";
                        if(mssg.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION")) {
                            let initialValidationMessage=mssg.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
                            validationMessage=initialValidationMessage.split(': [')[0];
                        }
                        else if(mssg.includes("NUMBER_OUTSIDE_VALID_RANGE")) {
                            let initialValidationMessage=mssg.split('NUMBER_OUTSIDE_VALID_RANGE,')[1];
                            validationMessage=initialValidationMessage.split(': [')[0];
                        }
                        showMessage(this, "Error!", validationMessage, this.errorVariant);
                    }
                    else{
                        showMessage(this, "Oops!", mssg, this.errorVariant);
                    }
                    this.showSpinner = false;
                }          
                if(!mssg.includes('Error')){
                    let successMsg = mssg;
                    if(changeLegalCheck != true || prodRemoveCheck != true){                    
                        showMessage(this, "Record created!", successMsg, this.successVariant);
                    }
                    else{
                        showMessage(this, "Record updated!", successMsg, this.successVariant); 
                    }
                }
                
            })
            .catch((error)=>{
                if (error) {
                    this.error = error;
                    showMessage(this, "Error Occurred!", error, this.errorVariant);
                }
                this.showSpinner = false;
            })
        }
        else{
            let mssg = "Please fill all the mandatory fields";
            showMessage(this, "Oops!", mssg, this.errorVariant); 
            this.showSpinner = false;
        }
    }

    // Send Approval Email to change Legal entity
    callExceptionApprovalEmail(){
        let lstLegalEntity = this.lstRequestedLegalEntity;
        let reqLegalEntityName='';
        for (var key in lstLegalEntity) {
            if (lstLegalEntity[key].value === this.requestedLegalEntity) {
                reqLegalEntityName = lstLegalEntity[key].label;
                break;
            }
        }
        exceptionApprovalEmail({opportunityId: this.recordId, requestReason: this.requestReason, requestedLegalEntity: reqLegalEntityName, 
            dollarValue: this.dollarValue, countryTerritory: this.countryTerritory, materialCodes: this.materialCodes, lstProductsAdded: JSON.stringify(this.lstOpsWrapper)})
        .then((data)=>{
                this.showSpinner = false;
                if(this.productsRemoved == true){
                    this.closeModal(); // Save Products and Remain on Edit Screen 
                }
                else{
                    this.onCancel();  // Navigate back to Oppy
                }                        
        })
        .catch((error)=>{
            if (error) {
                this.showSpinner = false;
                this.error = error; 
                let errMsg = 'An error has occured please contact Salesforce Helpdesk';    
                showMessage(this, "Error!", errMsg, this.errorVariant);                               
            }
        })
    }

    
}