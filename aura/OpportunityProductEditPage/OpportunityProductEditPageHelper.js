({
    navigateToOppy: function(component) {
        var oppyId = component.get("v.oppyId");
        var navEvent = $A.get("e.force:navigateToSObject");
        navEvent.setParams({
            "recordId": oppyId,
            "slideDevName": "detail",
            "isredirect": true
        });
        navEvent.fire();
    },
    navigateToAddProducts: function(component) {
        var environmentType = component.get("v.environmentType");
        console.log("--environmentType--" + environmentType);
        var oppyId = component.get("v.oppyId");
        if (environmentType === "Lightning") {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:productSelectorModal",
                componentAttributes: {
                    oppyId: oppyId
                }
            });
            $A.get('e.force:refreshView').fire();
            evt.fire();
        }
        else if (environmentType === "Community") {

            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/productselector?recordId=" + oppyId,
                "isredirect": true
            });
            urlEvent.fire();
        }

    },
    validate: function(component) {
        //validate for negative values
        var save = component.find("save");
        save.set("v.disabled", false);
        var showError = false;
        component.set("v.showErrorMessage", showError);
        var savedProducts = component.get("v.lstProductsAdded");
        for (var key in savedProducts) {
            for (var ops in savedProducts[key].lstOPS) {
                if (savedProducts[key].lstOPS[ops].TotalPrice__c < 0 || savedProducts[key].lstOPS[ops].DiscountAmount__c < 0) {
                    save.set("v.disabled", true);
                    showError = true;
                    component.set("v.showErrorMessage", showError);
                    return;
                }
            }
        }
    },
    applyGlobalDiscount : function(component) {
        var lstProducts = component.get("v.lstProductsAdded");
        var discountType = component.get("v.globalDiscountType");
        var globalDiscount = component.get("v.globalDiscountValue");
        var globalDiscountStep = component.get("v.globalDiscountStep");
        var proRateCheck = component.get("v.globalProRateCheck");
        
        console.log("discountType==>"+discountType);
        console.log("globalDiscount==>"+globalDiscount);
        console.log("globalDiscountStep==>"+globalDiscountStep);
        console.log("lstProducts"+lstProducts);
        for(var key in lstProducts) {
            lstProducts[key].discountType = discountType;
            var stepCounter = 1;
            var stepDownCounter = lstProducts[key].lstOPS.length;
            var stepDownDiscount = globalDiscount/stepDownCounter;
            for(var prod in lstProducts[key].lstOPS) {
                
                var calculatedDiscount;
                calculatedDiscount = parseFloat(globalDiscount*stepCounter).toFixed(2);
                if(globalDiscountStep === "Step down" ) {
                    calculatedDiscount = parseFloat(stepDownDiscount*stepDownCounter--).toFixed(2);
                }
                //SFDC-400 Annualized Discount if ProRation applied
                if(lstProducts[key].oppyProduct.Product2.AAG__c === 'Subscription' && proRateCheck === 'Yes') {
                    if(discountType=="Amount" && lstProducts[key].lstOPS[prod].AnnualizedUnitPrice__c>0) {
                        lstProducts[key].lstOPS[prod].AnnualizedDiscountAmount__c = calculatedDiscount;
                        lstProducts[key].lstOPS[prod].AnnualizedDiscountPercent__c =(calculatedDiscount/lstProducts[key].lstOPS[prod].AnnualizedUnitPrice__c)*100;
                    }else if(discountType=="Percentage" && lstProducts[key].lstOPS[prod].AnnualizedUnitPrice__c>0){
                        lstProducts[key].lstOPS[prod].AnnualizedDiscountPercent__c = calculatedDiscount;
                        lstProducts[key].lstOPS[prod].AnnualizedDiscountAmount__c = (calculatedDiscount/100)*lstProducts[key].lstOPS[prod].AnnualizedUnitPrice__c;
                    }else {
                        lstProducts[key].lstOPS[prod].AnnualizedDiscountPercent__c = 0.0;
                        lstProducts[key].lstOPS[prod].AnnualizedDiscountAmount__c = 0.0;
                    }
                }
                
                if(discountType=="Amount" && lstProducts[key].lstOPS[prod].ExternalListPrice__c>0) {
                    lstProducts[key].lstOPS[prod].DiscountAmount__c = calculatedDiscount;
                    lstProducts[key].lstOPS[prod].DiscountPercent__c = parseFloat((calculatedDiscount/lstProducts[key].lstOPS[prod].ExternalListPrice__c)*100).toFixed(2);
                    
                } else if(discountType=="Percentage" && lstProducts[key].lstOPS[prod].ExternalListPrice__c>0) {
                    lstProducts[key].lstOPS[prod].DiscountPercent__c = calculatedDiscount;
                    lstProducts[key].lstOPS[prod].DiscountAmount__c = parseFloat((calculatedDiscount/100)*lstProducts[key].lstOPS[prod].ExternalListPrice__c).toFixed(2);
                } else {
                    lstProducts[key].lstOPS[prod].DiscountPercent__c = 0;
                    lstProducts[key].lstOPS[prod].DiscountAmount__c = 0;
                    
                }
                var salesPrice = 0;
				var indianLevyTaxAmt = 0;
				//var indianLevyProdList = component.get("v.indianLevyProdList");
                salesPrice = lstProducts[key].lstOPS[prod].ExternalListPrice__c - lstProducts[key].lstOPS[prod].DiscountAmount__c;
                lstProducts[key].lstOPS[prod].TotalPrice__c=lstProducts[key].lstOPS[prod].SalesPrice__c*lstProducts[key].productQty;
                if(globalDiscountStep.indexOf("Step")>=0) {
                    stepCounter++;
                }
                if (lstProducts[key].isIndianLevyProd){ // SFDC-3428
                  var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                  indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                }
                salesPrice = parseFloat(salesPrice) + parseFloat(indianLevyTaxAmt);
                lstProducts[key].lstOPS[prod].DiscountPercent__c = parseFloat(lstProducts[key].lstOPS[prod].DiscountPercent__c).toFixed(2);
                lstProducts[key].lstOPS[prod].DiscountAmount__c = parseFloat(lstProducts[key].lstOPS[prod].DiscountAmount__c).toFixed(2);
                lstProducts[key].lstOPS[prod].SalesPrice__c = parseFloat(salesPrice).toFixed(2);
                lstProducts[key].lstOPS[prod].TotalPrice__c = parseFloat(lstProducts[key].lstOPS[prod].SalesPrice__c*lstProducts[key].productQty).toFixed(2);                
            }
        }
        component.set("v.lstProductsAdded",lstProducts);
        if(discountType=="No Discount") {
            component.set("v.globalDiscountValue",0);
        }
        this.calculateProRate(component);
    },
    applyGlobalUplift: function(component) {
        console.log("helper uplift entered");
        var lstProducts = component.get("v.lstProductsAdded");
        var upliftpercent = component.get("v.globalUplift");
        //apply uplift to all
        for (var key in lstProducts) {
            var year = 1;
            var previousListPrice = 0;
            for (var prod in lstProducts[key].lstOPS) {
                var percentIncrease = 0.0;
                if (year > 1) {
                    percentIncrease = parseFloat(upliftpercent * previousListPrice / 100).toFixed(2);
                    console.log("previousListPrice=>" + previousListPrice);
                    console.log("percentIncrease=>" + percentIncrease);
                    lstProducts[key].lstOPS[prod].ExternalListPrice__c = parseFloat(previousListPrice).toFixed(2) * 1 + parseFloat(percentIncrease).toFixed(2) * 1;
                    lstProducts[key].lstOPS[prod].ExternalListPrice__c = parseFloat(lstProducts[key].lstOPS[prod].ExternalListPrice__c).toFixed(2);
                    console.log("--lstProducts[key].lstOPS[prod].ExternalListPrice__c--" + lstProducts[key].lstOPS[prod].ExternalListPrice__c);

                }
                previousListPrice = lstProducts[key].lstOPS[prod].ExternalListPrice__c;
                year++;
            }
        }
        component.set("v.lstProductsAdded", lstProducts);
    },
    resetErrorCode: function(component) {
        component.set("v.resetErrors", false);
        component.set("v.resetErrors", true);
    },
    addProducts : function(component, event) {
        var oppyId = component.get("v.oppyId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:productSelectorModal",
            componentAttributes: {
                oppyId :oppyId
            }
        });
        evt.fire();
    },
    save: function(component, event, isClosed) {
        var isValid = this.validateLicense(component);
        var isNumberFieldValid=this.validateNumberFields(component);
        console.log('Value of isValid--->'+isValid);
        console.log('Value of isNumberFieldValid--->'+isNumberFieldValid);
        if(!isValid || !isNumberFieldValid) {
            return;
        }
        var spinner = component.find("loadSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var save = component.find("save");
        save.set("v.disabled", true);
        var close = component.find("close");
        close.set("v.disabled", true);
        var savedProducts = component.get("v.lstProductsAdded");
        var oppyId = component.get("v.oppyId");
        var action = component.get("c.saveProducts");
        for (var key in savedProducts) {
            for (var ops in savedProducts[key].lstOPS) {
                savedProducts[key].lstOPS[ops].Status__c = savedProducts[key].status;
                savedProducts[key].lstOPS[ops].DiscountType__c = savedProducts[key].discountType;
            }
            if(component.get("v.globalProRateCheck") === 'No'){
                savedProducts[key].oppyProduct.IsProrated__c = "No";
            }
            console.log('SaveProrationNo ' + savedProducts[key].oppyProduct.IsProrated__c); 
        }

        action.setParams({
            "oppyId": oppyId,
            "wrapperJson": JSON.stringify(savedProducts)
        });
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                var message = result;
                console.log("message=>" + message);
                if (message.indexOf("Error occurred") !== -1) {
                    if(message.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION") || message.includes("NUMBER_OUTSIDE_VALID_RANGE")) {
                            var validationMessage="";
                            if(message.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION")) {
                                var initialValidationMessage=message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
                                validationMessage=initialValidationMessage.split(': [')[0];
                            }
                            else if(message.includes("NUMBER_OUTSIDE_VALID_RANGE")) {
                                var initialValidationMessage=message.split('NUMBER_OUTSIDE_VALID_RANGE,')[1];
                                validationMessage=initialValidationMessage.split(': [')[0];
                            }
                            toastEvent.setParams({
                                "title": "Error!",
                                "message":validationMessage,
                                "mode":"dismissible",
                                "type":"error",
                                "duration":"3000"
							});
                    }
                    else{    
                    	toastEvent.setParams({
                        "title": "Oops!",
                        "message": result,
                        "mode": "dismissible",
                        "type": "error",
                        "duration" : "3000"
        				});
                    }
                    toastEvent.fire();
                    $A.util.toggleClass(spinner, "slds-hide");
            		save.set("v.disabled",false);
                    return;
                }
                toastEvent.setParams({
                    "title": "Products Updated!",
                    "message": result,
                    "mode": "dismissible",
                    "type": "success",

                });
                toastEvent.fire();
                if (isClosed) {
                    this.navigateToOppy(component);
                }
                this.initializeData(component, event);
            }
            else {
                var result = response.getReturnValue();
                console.log("message=>" + result);
                toastEvent.setParams({
                    "title": "Error occurred!",
                    "message": result,
                    "mode": "dismissible",
                    "type": "error",
                    "duration":"3000"
                });
                toastEvent.fire();
            }
            $A.util.toggleClass(spinner, "slds-hide");
            save.set("v.disabled", false);
            close.set("v.disabled", false);
        });
        $A.enqueueAction(action);
    },
    validDecimal: function(component, numValue) {
        var testResult = /^(\d)+\.?(\d{1,2})?$/.test(numValue);
        //check to prevent errors on blank values
        if (!numValue || numValue.length == 0) {
            return true;
        }
        return testResult;
    },
    initializeData: function(component, event) {
        var action2 = component.get("c.getLicenseTypes");
        action2.setCallback(this, function(response) {
            console.log("license types state >> " + response.getState());
            if (response.getState() == 'SUCCESS') {
                var result2 = response.getReturnValue();
                component.set("v.licenseTypes", result2);
            }
        });
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.getRiskStatus");
        action3.setCallback(this, function(response) {
            console.log("Risk Status state >> " + response.getState());
            if (response.getState() == 'SUCCESS') {
                var result3 = response.getReturnValue();
                component.set("v.riskStatuses", result3);               
            }
        });
        $A.enqueueAction(action3);
        
        var action = component.get("c.getOpportunityOPS");
        var oppyId = component.get("v.oppyId");

        //process if oppyId exists
        if (oppyId) {
            action.setParams({
                "OppyId": oppyId,
                "sortOLIDirection":component.get('v.sortOLIDirection'),
                "sortOLIByFieldName":component.get('v.sortOLIByFieldName')
            });
            action.setCallback(this, function(response) {
                console.log("response.state >> " + response.getState());
                if (response.getState() === 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log('Wrapper ' + JSON.stringify(result.lstOPSWrapper));
                    component.set("v.lstProductsAdded", result.lstOPSWrapper);
                    component.set("v.oppy", result.oppy);
                    component.set("v.globalProRateDisplay", result.canBeProRated);
                    if(!result.canBeProRated){
                      component.set("v.globalProRateCheck", 'No');  
                    } else {
                        console.log('IsProRated = ' + result.isProRated);
                        if(result.isProRated == 'No') {
                            component.set("v.globalProRateCheck", 'No');  
                        }
                    }
                    component.set("v.indianLevyProdList", result.indianLevyProdList);
                    component.set("v.globalProRate","No");
                    if(result.lstOPSWrapper != null){  //SFDC-4909 Change
                    	component.set("v.countOfInitialProductsAdded", result.lstOPSWrapper.length);   //SFDC-4909 Change
                    } //SFDC-4909 Change
                    // console.log('result.isSalesOps >> ' + result.isSalesOps);
                    if (result.oppy && result.oppy.AutoRenewal__c && !result.isAdmin 
                        && !result.isSalesOps) { // SFDC-701 Allow Sales Ops to edit Opportunity Products on any Sales Stage including 6WP
                        // console.log('result.oppy.DoesThisAutoRenewalHaveChanges__c >> ' + result.oppy.DoesThisAutoRenewalHaveChanges__c);
                        if(!result.oppy.DoesThisAutoRenewalHaveChanges__c) {
                            component.set("v.autoRenewNoChanges", true);
                        }
                        if(result.oppy.StageName.toLowerCase().indexOf("6w")!==-1) {
                            component.set("v.is6W",true)
                        }
                        /*
                        else {
                            component.set("v.autoRenewHasChanges",true);
                        }
                        */
                    }
                    //SFDC-400 Check ProRation Applied
                    if(result.oppy && result.oppy.IsProRated__c) {
                        component.set("v.globalProRate",result.oppy.IsProRated__c);
                    }
                    component.set("v.hasOppyEditAccess", result.hasOpportunityEditAccess);
                    component.set("v.hasOppyProductRemoveAccess", result.hasRemoveProductAccess);
                    if (!result.lstOPSWrapper || result.lstOPSWrapper.length == 0) {
                        component.set("v.noProductsMessage", "No Products found");
                    }
                    if(component.get('v.sorting')===true) {
                        var spinner = component.find("loadSpinner2");
                        $A.util.toggleClass(spinner, "slds-hide");
                        component.set('v.sorting', false);
                    }
					this.calculateProRate(component);
                }
                else {
                   /* var result = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    console.log("message1=>" + JSON.stringify(result));
                    toastEvent.setParams({
                                "title": "Error!",
                                "message":result,
                                "mode":"dismissible",
                                "type":"error",
                                "duration":"3000"
							});
                    toastEvent.fire();*/
                    console.log(response.getReturnValue());
                }
            });
            $A.enqueueAction(action);            
        }
        
    },
    proRateYes: function(component) {
        //prorate button has been set to yes
        var lstProducts = component.get("v.lstProductsAdded");
        var oppy = component.get("v.oppy");
        //process products and set annualized unit price and pro-rated unit price
        for (var opsWrap in lstProducts) {
            //proRate only for subscription products
            if (lstProducts[opsWrap].oppyProduct.Product2.AAG__c === 'Subscription') {
                lstProducts[opsWrap].oppyProduct.isProrated__c = 'Yes';
                var conStartDate = new Date(lstProducts[opsWrap].oppyProduct.ContractStartDate__c);
                var conEndDate = new Date(lstProducts[opsWrap].oppyProduct.ContractEndDate__c);
                var proRatedDays = this.date360(conStartDate,conEndDate);
                for (var olis in lstProducts[opsWrap].lstOPS) {
                    //copy existing unit price to annualized unit price and discount
                    lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c = lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c;
                    lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c = lstProducts[opsWrap].lstOPS[olis].DiscountAmount__c;
                    lstProducts[opsWrap].lstOPS[olis].ProRatedUnitPrice__c = (lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c / 360) * proRatedDays;
                    lstProducts[opsWrap].lstOPS[olis].ProRatedDiscountAmount__c = (lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c / 360) * proRatedDays;
                    //set precision to 2
                    lstProducts[opsWrap].lstOPS[olis].ProRatedUnitPrice__c = parseFloat(lstProducts[opsWrap].lstOPS[olis].ProRatedUnitPrice__c).toFixed(2);
                    lstProducts[opsWrap].lstOPS[olis].ProRatedDiscountAmount__c = parseFloat(lstProducts[opsWrap].lstOPS[olis].ProRatedDiscountAmount__c).toFixed(2);
                    //move values from proRated to unit price
                    lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c = lstProducts[opsWrap].lstOPS[olis].ProRatedUnitPrice__c;
                    lstProducts[opsWrap].lstOPS[olis].DiscountAmount__c = lstProducts[opsWrap].lstOPS[olis].ProRatedDiscountAmount__c;
                    lstProducts[opsWrap].lstOPS[olis].SalesPrice__c = parseFloat(lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c - lstProducts[opsWrap].lstOPS[olis].DiscountAmount__c).toFixed(2);
                    lstProducts[opsWrap].lstOPS[olis].TotalPrice__c = parseFloat(lstProducts[opsWrap].lstOPS[olis].SalesPrice__c * lstProducts[opsWrap].productQty).toFixed(2);
                }
            }
        }
        component.set("v.lstProductsAdded", lstProducts);

    },
    proRateNo: function(component) {
        //proRate no has been selected that means one or more opportunity products are pro-rated
        var lstProducts = component.get("v.lstProductsAdded");
        for (var opsWrap in lstProducts) {
            //copy annualized values back to original ones
            if (lstProducts[opsWrap].oppyProduct.Product2.AAG__c === 'Subscription') {
                lstProducts[opsWrap].oppyProduct.isProrated__c = 'No';
                for (var olis in lstProducts[opsWrap].lstOPS) {
                    lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c = lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c;
                    lstProducts[opsWrap].lstOPS[olis].DiscountAmount__c = lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c;
                    lstProducts[opsWrap].lstOPS[olis].SalesPrice__c = lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c - lstProducts[opsWrap].lstOPS[olis].DiscountAmount__c;
                    lstProducts[opsWrap].lstOPS[olis].TotalPrice__c = lstProducts[opsWrap].lstOPS[olis].SalesPrice__c * lstProducts[opsWrap].productQty;
                    //remove prorated values
                    lstProducts[opsWrap].lstOPS[olis].ProRatedUnitPrice__c = 0
                    lstProducts[opsWrap].lstOPS[olis].ProRatedDiscountAmount__c = 0;
                    lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c = 0;
                    lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c= 0;
                    
                }
            }
        }
        component.set("v.lstProductsAdded", lstProducts);
    },
    calculateProRate: function(component){
        //SFDC-400 - Pro-Ration Calculation 
        var proratecheck = component.get("v.globalProRateCheck");
        if(proratecheck === 'Yes'){
            this.proRateChecked(component);
        }
    },
    proRateChecked: function(component) {
        //prorate button has been set to yes
        var lstProducts = component.get("v.lstProductsAdded");
        var oppy = component.get("v.oppy");
        //process products and set annualized unit price and pro-rated unit price
        for (var opsWrap in lstProducts) {
            //proRate only for subscription products
            if (lstProducts[opsWrap].oppyProduct.Product2.AAG__c === 'Subscription') {             
                //var conStartDate = new Date(lstProducts[opsWrap].oppyProduct.ContractStartDate__c);
                //var conEndDate = new Date(lstProducts[opsWrap].oppyProduct.ContractEndDate__c);
                //var proRatedDays = this.date360(conStartDate,conEndDate);
                var proRatedDays = lstProducts[opsWrap].proRatedDays;
                var discountType = lstProducts[opsWrap].discountType;
                var indianLevyTaxAmt = 0;
                if(proRatedDays !== 360 && proRatedDays < 720) {
                    //Set Product Term Selected to 1 for ProRation
                    if(lstProducts[opsWrap].productTermSelected > 1) {
                        var mapProductSchedulesAll = lstProducts[opsWrap].mapOPSAll;
                        lstProducts[opsWrap].lstOPS = mapProductSchedulesAll[1];
                        lstProducts[opsWrap].productTermSelected = 1;
                    }
                    console.log('pro rated days = ' + proRatedDays);
                    for (var olis in lstProducts[opsWrap].lstOPS) {
                        var AnnualDiscAmt = 0.0;
                        var annualUnitPrice = 0.0;
                        if(lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c !== undefined && lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c !== null && lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c !== '') {
                            annualUnitPrice = lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c;                        
                        }else {                        
                            annualUnitPrice = lstProducts[opsWrap].lstOPS[olis].PriceBookListPrice__c;
                        }
                        lstProducts[opsWrap].lstOPS[olis].AnnualizedUnitPrice__c = annualUnitPrice;
                        if(lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c == null) {
                            lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c = 0.0;
                        }
                        if(discountType==="Amount") {
                            AnnualDiscAmt = lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c;
                            if(annualUnitPrice == 0.0) {
                                lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountPercent__c = 0.0;
                            } else {
                            	lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountPercent__c =parseFloat((AnnualDiscAmt/annualUnitPrice)*100).toFixed(2);    
                            }
                        }else if(discountType==="Percentage"){
                            AnnualDiscAmt = parseFloat((lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountPercent__c/100)*annualUnitPrice).toFixed(2);
                            lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c = AnnualDiscAmt;
                        }else {
                            AnnualDiscAmt = 0.0;
                            lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountPercent__c = 0.0;
                            lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c = 0.0;
                        }
                        
                        var annualSalesPrice = annualUnitPrice - AnnualDiscAmt;
                        var indianLevyTaxAmtAnnual = 0;
                        if (lstProducts[opsWrap].isIndianLevyProd){ 
                          var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                          indianLevyTaxAmtAnnual = (parseFloat(indianLevyTax)/100)*annualSalesPrice;
                        }
                        // Annualized Calculations:
                        annualSalesPrice = parseFloat(annualSalesPrice) + parseFloat(indianLevyTaxAmtAnnual);
                        console.log('Annual Sales Price ' + annualSalesPrice);
                        lstProducts[opsWrap].lstOPS[olis].AnnualizedTotalAmount__c = parseFloat((annualSalesPrice) * lstProducts[opsWrap].lstOPS[olis].Quantity__c ).toFixed(2); 
                        
                        // ProRated Calculations:
                        
                        console.log('AnnualPrice ' + annualUnitPrice);
                        var unitPrice = parseFloat((annualUnitPrice / 360) * proRatedDays).toFixed(2);
                        var discount = parseFloat((lstProducts[opsWrap].lstOPS[olis].AnnualizedDiscountAmount__c / 360) * proRatedDays).toFixed(2);
                        var discountPercent = 0.0;
                        if(unitPrice == 0.00 || unitPrice == null) {
                            discountPercent = 0.0;
                        } else {
                        	discountPercent = parseFloat((discount/unitPrice)*100).toFixed(2);    
                        }                        
                        var salesPrice = unitPrice - discount;
                        if (lstProducts[opsWrap].isIndianLevyProd){ // SFDC-3428
                          var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                          indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                        }
                        salesPrice = parseFloat(salesPrice) + parseFloat(indianLevyTaxAmt);   
                        lstProducts[opsWrap].lstOPS[olis].DiscountAmount__c = discount;
                        lstProducts[opsWrap].lstOPS[olis].DiscountPercent__c = discountPercent;
                        lstProducts[opsWrap].lstOPS[olis].SalesPrice__c = salesPrice;
                        lstProducts[opsWrap].lstOPS[olis].TotalPrice__c = parseFloat((salesPrice) * lstProducts[opsWrap].lstOPS[olis].Quantity__c ).toFixed(2);
                        lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c = parseFloat(unitPrice) + parseFloat(indianLevyTaxAmt);   
                        lstProducts[opsWrap].oppyProduct.IsProRated__c = "Yes";
                          console.log('ProrationYes ' + lstProducts[opsWrap].oppyProduct.IsProrated__c); 
                        console.log('ExternalPrice** ' + lstProducts[opsWrap].lstOPS[olis].ExternalListPrice__c);
                        console.log('LevyTax** ' + indianLevyTaxAmt);
                    }
                } 
            }
        }
        component.set("v.lstProductsAdded", lstProducts);
		this.validate(component);
    },
    proRateUnchecked: function(component) {
        //proRate no has been selected that means one or more opportunity products are pro-rated
        this.initializeData(component);
        var lstProducts = component.get("v.lstProductsAdded");
        for (var opsWrap in lstProducts) {
            //copy annualized values back to original ones                             
            lstProducts[opsWrap].oppyProduct.IsProrated__c = "No";   
            console.log('ProrationNo ' + lstProducts[opsWrap].oppyProduct.IsProrated__c); 
        }
        component.set("v.lstProductsAdded", lstProducts);
    },
    validateLicense: function(component) {
        //check if any field has invalid input
        //check for license type
        var isValid = true;
        var licenseTypeField = [];
        licenseTypeField = component.find("licenseTypes");
        if (!licenseTypeField) {
            return true;
        }
        licenseTypeField = [].concat(licenseTypeField);
        licenseTypeField.forEach(cmp => {
            var validity = cmp.get("v.validity");
            if (cmp.get("v.validity") !== undefined && !cmp.get("v.validity").valid) {
                //cmp.set("v.validity", {valid:false, valueMissing :true});
                isValid = false;
                cmp.showHelpMessageIfInvalid();
            }
        })
        return isValid;
    },
    validateNumberFields: function(component) {
        var isValid=true;
        var probabilityField=[];
        probabilityField=component.find("probabilities");
        if (!probabilityField) {
            return true;
        }
        probabilityField = [].concat(probabilityField);
        probabilityField.forEach(cmp => {
            var validity = cmp.get("v.validity");
            if (!cmp.get("v.validity").valid) {
                isValid = false;
            }
        })
        var authorizedUsersField=[];
        authorizedUsersField=component.find("authorizedUsers");
        if (!authorizedUsersField) {
            return true;
        }
        authorizedUsersField=[].concat(authorizedUsersField);
        authorizedUsersField.forEach(cmp => {
            var validity = cmp.get("v.validity");
            if (!cmp.get("v.validity").valid) {
                isValid = false;
            }
        })
        var loactionSitesField=[];
        loactionSitesField=component.find("loactionSites");
        if (!loactionSitesField) {
            return true;
        }
        loactionSitesField=[].concat(loactionSitesField);
        loactionSitesField.forEach(cmp => {
            var validity = cmp.get("v.validity");
            if (!cmp.get("v.validity").valid) {
                isValid = false;
            }
        })
        var concurrentUsersField=[];
        concurrentUsersField=component.find("concurrentUsers");
        if (!concurrentUsersField) {
            return true;
        }
        concurrentUsersField=[].concat(concurrentUsersField);
        concurrentUsersField.forEach(cmp => {
            var validity = cmp.get("v.validity");
            if (!cmp.get("v.validity").valid) {
                isValid = false;
            }
        })
        var potentialUsersField=[];
        potentialUsersField=component.find("potentialUsers");
        if (!potentialUsersField) {
            return true;
        }
        potentialUsersField=[].concat(potentialUsersField);
        potentialUsersField.forEach(cmp => {
            var validity = cmp.get("v.validity");
            if (!cmp.get("v.validity").valid) {
                isValid = false;
            }
        })
        return isValid;
    },
    date360: function(startDate, endDate,european) {
       
            var date1 = new Date(startDate);
            var date2 = new Date(endDate);
            var date1_1 = date1;
            var date2_1 = date2;
            var euro = european || false;
            var date1_y = date1.getFullYear();
            var date2_y = date2.getFullYear();
            var dy = 0;
            var date1_m = date1.getMonth();
            var date2_m = date2.getMonth();
            var dm = 0;
            var date1_d = date1.getDate();
            var date2_d = date2.getDate();
            var dd = 0;
            if (euro) {
                // european way of handling dates
                if (date1_d == 31) {
                  date1_d = 30;  
                } 
                if (date2_d == 31) {
                  date2_d = 30;  
                } 
            }
            else {
                // american North American way fo days360 method
                if (date1_d == 31) {
                  date1_d = 30;  
                } 
                if (date2_d == 31) {
                    if (date1_d < 30) {
                        if (date2_m == 11) {
                            date2_y = date2_y + 1;
                            date2_m = 0;
                            date2_d = 1;
                        }
                        else {
                            date2_m = date2_m + 1;
                            date2_d = 1;
                        }
                    }
                    else {
                        date2_d = 30;
                    }
                }
            }
            dy = date2_y - date1_y;
            dm = date2_m - date1_m;
            dd = date2_d - date1_d;
            return parseFloat(dy * 360 + dm * 30 + dd);
        
    },
    proRateSave: function(component) {
        
    }
})