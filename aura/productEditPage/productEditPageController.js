({
    doInit : function(component, event, helper) {
        
        var action2 = component.get("c.getLicenseTypes");
        
        action2.setCallback(this,function(response) {
            //console.log("license types state >> "+ response.getState());
            if (response.getState() == 'SUCCESS') {
                var result2 = response.getReturnValue();
                //console.log(result2);
                component.set("v.licenseTypes",result2);
            }
        });
        $A.enqueueAction(action2);
        var productIds = component.get("v.productIds");
        var oppyId = component.get("v.oppyId");
        var legalEntityName = component.get("v.legalEntityName");
        //console.log("productIds"+productIds);
        //console.log("productIds"+productIds.length);
        var action = component.get("c.getProductDetails");
        
        action.setParams({
            "productIds": productIds,
            "oppyId" : oppyId, 
            "legalEntityName" : legalEntityName 
        });
        action.setCallback(this, function(response) {
            //console.log("state >> "+ response.getState());
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                //console.log(result);
                var licenseTypes = component.get("v.licenseTypes");
                var proRationReq = false;
                if(result) {
                    for( var key in result) {
                        result[key].licenseType= '';
                        //SFDC-400 Check if Proration Required or not
                        if(result[key].isProRationRequired) {
							proRationReq = true;                            
                        }
                    }
                    if(!proRationReq) {
                        component.set("v.globalProRateCheck","No");
                    }
                    component.set("v.globalProRateDisplay", proRationReq);
                    component.set("v.lstProducts",result);
                    if(result[0]) {
                        component.set("v.currencyCode",result[0].currencyCode);
                        component.set("v.oppyRecordTypeName",result[0].recordTypeName);
                        //console.log('--RecordType.DeveloperName--'+result[0].recordTypeName);  
                        //SFDC-400 - Pro-Ration Calculation 
                        helper.calculateProRate(component);
                    }                    
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    productTermChange : function(component, event, helper) {
        var yearVal = event.getSource().get("v.value");
        var index = event.getSource().get("v.name");
        var lstProducts = component.get("v.lstProducts");
        var lstProductSchedulesCurrent = lstProducts[index].lstProductsSelected;
        var lstProductSchedules = [];
        var mapProductSchedulesAll = lstProducts[index].mapProductsAll;
        //SFDC-400 Year validation for ProRation 
        if(yearVal > 1 && component.get("v.globalProRateCheck") === 'Yes' && lstProducts[index].aag === 'Subscription'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                                "title": "Error!",
                                "message":"Year cannot be selected more than 1 on Proration",
                                "mode":"dismissible",
                                "type":"error",
                                "duration":"3000"
							});
            toastEvent.fire();
            yearVal = 1;
	        component.set("v.lstProducts["+index+ "].productTermSelected",yearVal);
	        helper.calculateProRate(component);
        } else {
            var discountType = lstProducts[index].discountType;
            //console.log('discountType'+discountType);
            var salesPrice =0;
            var indianLevyTaxAmt =0;
            lstProductSchedules = mapProductSchedulesAll[yearVal];
            for(var key in lstProductSchedules) {
                if(lstProductSchedulesCurrent && lstProductSchedulesCurrent[key]) {
                    if(discountType==='Amount') {
                        lstProductSchedules[key].discountAmount = parseFloat(lstProductSchedulesCurrent[key].discountAmount).toFixed(2);
                        lstProductSchedules[key].discountPercent = parseFloat(lstProductSchedulesCurrent[key].discountAmount/lstProductSchedules[key].externalListPrice*100).toFixed(2);
                    }
                    else {
                        lstProductSchedules[key].discountPercent = parseFloat(lstProductSchedulesCurrent[key].discountPercent).toFixed(2);
                        lstProductSchedules[key].discountAmount = parseFloat((lstProductSchedules[key].discountPercent/100)*lstProductSchedules[key].externalListPrice).toFixed(2);
                    }
                    
                    
                }
        
                salesPrice = parseFloat(lstProductSchedules[key].externalListPrice - lstProductSchedules[key].discountAmount).toFixed(2); 
                if (lstProductSchedules[key].isIndianLevyProd){ // SFDC-3428
                  //console.log('$$$$ Indian levy prod---');
                  var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                  indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;            
                }
                lstProductSchedules[key].salesPrice = parseFloat(salesPrice) + parseFloat(indianLevyTaxAmt);
                lstProductSchedules[key].totalPrice=parseFloat(lstProductSchedules[key].salesPrice*lstProducts[index].productQty).toFixed(2) ;
            }
            
            component.set("v.lstProducts["+index+ "].lstProductsSelected",lstProductSchedules);
            component.set("v.lstProducts["+index+ "].productTermSelected",yearVal);
            var discountType = component.get("v.globalDiscountType");
            if(discountType!="No Discount") {
                helper.applyGlobalDiscount(component);
                helper.validate(component);
            }
        } 
    },
    cancel : function(component, event, helper) {
        var oppyId = component.get("v.oppyId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": oppyId,
            "slideDevName": "detail",
            "isredirect":true
        });
        navEvt.fire();
    },
    onSave: function(component, event, helper) {
        var isValid = helper.validateLicense(component);
        var isNumberFieldValid=helper.validateNumberFields(component);
        if(!isValid || !isNumberFieldValid) {
            return;
        }
        var spinner = component.find("loadSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var save = component.find("save");
        save.set("v.disabled",true);
        var savedProducts = component.get("v.lstProducts");
        //console.log(JSON.stringify(savedProducts));
        var oppyId = component.get("v.oppyId");
        var legalEntity = component.get("v.legalEntity");
        var action = component.get("c.saveProductsOnOpportunity");
        action.setParams({
            "stringProductWrapper": JSON.stringify(savedProducts),
            "opportunityId" :  oppyId,
            "legalEntity" : legalEntity
        });
        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                var message = result;
                //console.log("message=>"+message);
                if(message.indexOf("Error occurred")!==-1) {
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
                            "message":result,
                            "mode":"dismissible",
                            "type":"error",
                            "duration":"3000"
                        });
                    }
                    toastEvent.fire();
                    $A.util.toggleClass(spinner, "slds-hide");
            		save.set("v.disabled",false);
                    return;
                }
                toastEvent.setParams({
                    "title": "Record created!",
                    "message":result,
                    "mode":"dismissible",
                    "type":"success",
                    "duration":"3000"
                    
                });
                toastEvent.fire();
                var oppyId = component.get("v.oppyId");
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": oppyId,
                    "slideDevName": "detail",
                    "isredirect":true
                });
                $A.get('e.force:refreshView').fire();
                navEvt.fire();
                
            } else {
                var result = response.getReturnValue();
                //console.log("message=>"+result);
                toastEvent.setParams({
                    "title": "Error occurred!",
                    "message":result,
                    "mode":"dismissible",
                    "type":"error",
                    "duration":"3000"
                });
                toastEvent.fire();
            }
            $A.util.toggleClass(spinner, "slds-hide");
            save.set("v.disabled",false);
        });
        $A.enqueueAction(action);
    },
    onDiscAmtPercentChange : function(component, event, helper) {
        var listedProducts = component.get("v.lstProducts");
        var discountName = event.getSource().get("v.name");
        var discount = event.getSource().get("v.value");
        var index = discountName.charAt(0);
        // var prodIndex = discountName[discountName.length -1];
        var prodIndex = discountName.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var lstProductSelected = listedProducts[prodIndex].lstProductsSelected;
        var salesPrice =0;
        var indianLevyTaxAmt =0;
        if(discountName.indexOf("Percent")!==-1) {
            salesPrice = (lstProductSelected[index].externalListPrice *(1-(discount)/100));
            lstProductSelected[index].discountAmount = parseFloat(lstProductSelected[index].externalListPrice - salesPrice).toFixed(2) ;
        } else{
            salesPrice = (lstProductSelected[index].externalListPrice -discount);
            lstProductSelected[index].discountPercent = parseFloat((discount/(lstProductSelected[index].externalListPrice)*100)).toFixed(2);
        }
        if (lstProductSelected[index].isIndianLevyProd){ // SFDC-3428
            //console.log('$$$$ Indian levy prod---');
            var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
            indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;            
        }
        lstProductSelected[index].salesPrice = parseFloat(salesPrice + indianLevyTaxAmt).toFixed(2);
        lstProductSelected[index].totalPrice =  parseFloat(listedProducts[prodIndex].productQty * lstProductSelected[index].salesPrice).toFixed(2);
        component.set("v.lstProducts["+prodIndex+ "].lstProductsSelected",lstProductSelected);
        helper.validate(component);
    },
    onDiscountTypeChange : function(component, event, helper) {
        var discountName = event.getSource().get("v.name");
        // var prodIndex = discountName[discountName.length -1];
        var prodIndex = discountName.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var listedProducts = component.get("v.lstProducts");
        var discountType = listedProducts[prodIndex].discountType;
        // this might return an array in case multiple line items
        var discountPercents = component.find("discountPercent");
        discountPercents = [].concat(discountPercents);//convert it into an array or add blank
        // this might return an array in case multiple line items
        var discountAmounts = component.find("discountAmount");
        discountAmounts = [].concat(discountAmounts);//convert it into an array or add blank
        //console.log("discountAmounts size=>"+discountAmounts.length);
        
        if (discountType==="No Discount") {
            discountPercents.forEach(cmp => {
                // if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
                if (cmp.get("v.name").replace(/.*\D/g, "")===prodIndex) {
                	cmp.set("v.disabled",true);
            	}
            })
            discountAmounts.forEach(cmp => {
                // if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
                if (cmp.get("v.name").replace(/.*\D/g, "")===prodIndex) {
                	cmp.set("v.disabled",true);
            	}
            })
            var selectedProducts = listedProducts[prodIndex].lstProductsSelected;
            //console.log("selectedProducts size =>"+selectedProducts.length);
            for(var i=0; i<selectedProducts.length; i++) {
                var salesPrice = 0;
                var indianLevyTaxAmt = 0;
                selectedProducts[i].discountPercent=0;
                selectedProducts[i].discountAmount=0;
                //SFDC-3428
                //selectedProducts[i].salesPrice=parseFloat(selectedProducts[i].externalListPrice).toFixed(2);
                if(selectedProducts[i].externalListPrice === '' 
                   || selectedProducts[i].externalListPrice === null) {
                    salesPrice = 0;
                } else { 
                	salesPrice = parseFloat(selectedProducts[i].externalListPrice);
                }
                //salesPrice = parseFloat(selectedProducts[i].externalListPrice);
                if (selectedProducts[i].isIndianLevyProd) {
                    var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                    indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                    //console.log('$$ indianLevyTaxAmt -'+indianLevyTaxAmt);
                }
                selectedProducts[i].salesPrice = parseFloat(salesPrice + indianLevyTaxAmt).toFixed(2);          
                selectedProducts[i].totalPrice=parseFloat(selectedProducts[i].salesPrice*listedProducts[prodIndex].productQty).toFixed(2) ;
            }
            component.set("v.lstProducts["+prodIndex+"].lstProductsSelected",selectedProducts);
            var discountType = component.get("v.lstProducts["+prodIndex+"].discountType");
            //console.log("--discountType--"+discountType);
        }
        
        if (discountType==="Amount" ) {
            discountPercents.forEach(cmp => {
                // if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
                if (cmp.get("v.name").replace(/.*\D/g, "")===prodIndex) {
                	cmp.set("v.disabled",true);
            	}
            })
            discountAmounts.forEach(cmp => {
                // if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
                if (cmp.get("v.name").replace(/.*\D/g, "")===prodIndex) {
                	cmp.set("v.disabled",false);
            	}
            })
        }
        
        if (discountType==="Percentage" ) {
            discountPercents.forEach(cmp => {
                // if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
                if (cmp.get("v.name").replace(/.*\D/g, "")===prodIndex) {
                	cmp.set("v.disabled",false);
            	}
            })
            discountAmounts.forEach(cmp => {
                // if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
                if (cmp.get("v.name").replace(/.*\D/g, "")===prodIndex) {
                	cmp.set("v.disabled",true);
            	}
            })
        }
    },
    
    onQtyChange : function(component, event, helper) {
        var qtyComp = event.getSource();
        var qty = qtyComp.get("v.value");
        // var prodIndex = qtyComp.get("v.name").charAt(0);
        var prodIndex = qtyComp.get("v.name").replace(/\D+$/g, ""); // SFDC-911 using RegEx to extract index number at the beginning of string
        var lstProducts = component.get("v.lstProducts");
        //quantity cannot be less than 1
        if(!qty || qty<1) {
            qty=1;
            component.set("v.lstProducts["+prodIndex+"].productQty",qty);
        }
        var lstSelectedProducts = lstProducts[prodIndex].lstProductsSelected;
        for(var i=0; i<lstSelectedProducts.length; i++) {
            lstSelectedProducts[i].totalPrice=parseFloat(lstSelectedProducts[i].salesPrice*qty).toFixed(2) ;
        }
        component.set("v.lstProducts["+prodIndex+"].lstProductsSelected",lstSelectedProducts);
        //SFDC-400 - Pro-Ration Calculation 
		helper.calculateProRate(component);
    },
    
    onListPriceChange : function(component, event, helper) {
        var listComp = event.getSource();
        var name = listComp.get("v.name");
        var index=name.charAt(0);
        var adjustedListPrice=0;
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var lstProducts = component.get("v.lstProducts");
        var lstSelectedProducts = lstProducts[prodIndex].lstProductsSelected;
        var extListPrice = listComp.get("v.value");
        var discountType = lstProducts[prodIndex].discountType;
        var discountAmt = 0;
        var indianLevyTaxAmt = 0;
        var salesPrice = 0;
        if(discountType==="Amount") {
            discountAmt = lstSelectedProducts[index].discountAmount;
            lstSelectedProducts[index].discountPercent = parseFloat((discountAmt/extListPrice)*100).toFixed(2);
        }
        if(discountType==="Percentage") {
            discountAmt = (lstSelectedProducts[index].discountPercent/100)*extListPrice;
            lstSelectedProducts[index].discountAmount = parseFloat(discountAmt).toFixed(2);
        }
        //console.log("extListPrice" + extListPrice);
        //console.log("discountAmt"+ discountAmt);
        //lstSelectedProducts[index].salesPrice=parseFloat(extListPrice-discountAmt).toFixed(2);
        salesPrice = (extListPrice-discountAmt);
        if (lstSelectedProducts[index].isIndianLevyProd){ // SFDC-3428
            //console.log('$$$$ Indian levy prod---');
            var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
            indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
            adjustedListPrice = parseFloat(extListPrice) + parseFloat(indianLevyTaxAmt);
            if(Math.sign(salesPrice)  > 0 && !Number.isNaN(adjustedListPrice)) {
              component.set("v.hoverRow", event.getSource().get("v.label"));
              component.set("v.tooltipmessage",adjustedListPrice.toFixed(2));
            }else {
                component.set("v.hoverRow", -1);
            } 
        }
        lstSelectedProducts[index].salesPrice = parseFloat(salesPrice + indianLevyTaxAmt).toFixed(2);
        //console.log('$$$$ salesPrice---'+lstSelectedProducts[index].salesPrice);
        lstSelectedProducts[index].totalPrice=parseFloat(lstSelectedProducts[index].salesPrice*lstProducts[prodIndex].productQty).toFixed(2);
        component.set("v.lstProducts["+prodIndex+"].lstProductsSelected",lstSelectedProducts);
        helper.validate(component);
    },
    onBack : function(component,event,helper) {
        //SFDC-4730 Change Start
        //var backEvent = component.getEvent("onBackEvent");
        var backEvent = component.getEvent("backEvent");
        //SFDC-4730 Change End
        backEvent.setParams({"isBackPressed" : true});
        backEvent.fire();
    },
    onGlobalDiscountChange: function(component,event,helper) {
        helper.applyGlobalDiscount(component);
        helper.validate(component);
        helper.resetErrorCode(component);
    },
    onGlobalTermChange : function(component,event,helper) {
        var toastEvent = $A.get("e.force:showToast");
        var globalTerm = component.get("v.globalTermYears");
        var lstProducts = component.get("v.lstProducts");
        //SFDC-400 Year Restriction for ProRation
        var proRateCheck = component.get("v.globalProRateCheck");
        var errMsg = 'For Prorated Products, Term will be set to 1.';
        if(globalTerm != 1 && proRateCheck === 'Yes') {
            toastEvent.setParams({
                "title": "Error occurred!",
                "message":errMsg,
                "mode":"dismissible",
                "type":"warning",
                "duration":"3000"
            });
            toastEvent.fire();
        }
        
        for(var key in lstProducts) {
            var mapProductSchedulesAll = lstProducts[key].mapProductsAll;
            //SFDC-400 ProRation Products cannot have more than 1 Schedule
            if(lstProducts[key].aag === 'Subscription' && proRateCheck === 'Yes') {
                if(mapProductSchedulesAll[1]) {
                    lstProducts[key].lstProductsSelected = mapProductSchedulesAll[1];
                    lstProducts[key].productTermSelected = 1;
                }                
            } else {       
                if(mapProductSchedulesAll[globalTerm]) {
                    lstProducts[key].lstProductsSelected = mapProductSchedulesAll[globalTerm];
                    lstProducts[key].productTermSelected = globalTerm;
                } else {
                    console.log('test Prod Schedules ' + JSON.stringify(mapProductSchedulesAll));
                    for(var i=5; i>0; i--) {
                        console.log('test Prod count ' + i);
                        //var term = i.toString();
                        if(mapProductSchedulesAll[i]) {
                            lstProducts[key].lstProductsSelected = mapProductSchedulesAll[i];
                            lstProducts[key].productTermSelected = i;
                            break;
                        }
                    }
                }
            }
        }
        component.set("v.lstProducts",lstProducts);
        helper.applyGlobalDiscount(component);
    },
    onGlobalDiscountTypeChange: function(component, event, helper) {
        component.set("v.globalDiscountValue",0);
        helper.applyGlobalDiscount(component);
        helper.validate(component);
        helper.resetErrorCode(component);
    },
    onGlobalLicenseTypeChange: function(component, event, helper) {
        var globallicenseType = component.get("v.globalLicenseType");
        var lstProducts = component.get("v.lstProducts");
        for(var prod in lstProducts ) {
            lstProducts[prod].licenseType = globallicenseType;
        }
         component.set("v.lstProducts",lstProducts);
    },
    onLicenseTypeChange: function(component, event, helper) {
        var licenseType = component.get("v.licenseTypes");
        var toggleText = component.find("licenseTypes");
        $A.util.toggleClass(toggleText, "hiddenLabel");
    },
    collapse: function(component, event, helper) {
        var collapseId = event.getSource().get('v.name');
        var collapseLabel = event.getSource().get('v.label');
        if(collapseLabel==='Collapse') {
            event.getSource().set('v.label','Expand');
        } else {
            event.getSource().set('v.label','Collapse');
        }
        
        var collapseDiv = collapseId.replace('collapse','');
        var divComp = document.getElementById(collapseDiv);
        $A.util.toggleClass(divComp, 'slds-hide');
        
    },
    onUpliftChange: function(component, event, helper) {
        helper.applyGlobalUplift(component);
        helper.applyGlobalDiscount(component);
        helper.validate(component);
        helper.resetErrorCode(component);
    },
    onProRateRequired: function(component, event, helper){
        //SFDC-400 - Pro-Ration Calculation 
        var proRateCheck = event.getSource().get("v.value");
        if(proRateCheck === 'Yes' ) {
            helper.proRateChecked(component);
        } else {
            helper.proRateUnchecked(component);
        }
    },
    onAnnualizedPriceChange: function(component, event, helper) {
		helper.calculateProRate(component);        
        var listComp = event.getSource();
        var name = listComp.get("v.name");
        var index=name.charAt(0);
        var adjustedAnnualUnitPrice=0;
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var lstProducts = component.get("v.lstProducts");
        var lstSelectedProducts = lstProducts[prodIndex].lstProductsSelected;
        var annualUnitPrice = listComp.get("v.value");
        var discountType = lstProducts[prodIndex].discountType;
        var discountAmt = 0;
        var indianLevyTaxAmt = 0;
        var salesPrice = 0;
        if(lstSelectedProducts[index].discountAmount > 0) {
            discountAmt = lstSelectedProducts[index].discountAmount;
        }
        salesPrice = (annualUnitPrice-discountAmt);
        if (lstSelectedProducts[index].isIndianLevyProd){ // SFDC-3428
            //console.log('$$$$ Indian levy prod---');
            var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
            indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
            adjustedAnnualUnitPrice = parseFloat(annualUnitPrice) + parseFloat(indianLevyTaxAmt);
            if(Math.sign(salesPrice)  > 0 && !Number.isNaN(adjustedAnnualUnitPrice)) {
              component.set("v.hoverRow", event.getSource().get("v.label"));
              component.set("v.tooltipmessage",adjustedAnnualUnitPrice.toFixed(2));
            }else {
                component.set("v.hoverRow", -1);
            } 
        }
    },
    onAnnualDiscAmtPerChange: function(component, event, helper) {
        var listedProducts = component.get("v.lstProducts");
        var discountName = event.getSource().get("v.name");
        var discount = event.getSource().get("v.value");
        var index = discountName.charAt(0);
        var prodIndex = discountName.replace(/.*\D/g, ""); 
        var lstProductSelected = listedProducts[prodIndex].lstProductsSelected;
        var salesPrice =0;
        var indianLevyTaxAmt =0;
        if(discountName.indexOf("Percent")!==-1) {
            salesPrice = (lstProductSelected[index].AnnualizedUnitPrice *(1-(discount)/100));
            lstProductSelected[index].AnnualizedDiscountAmount = parseFloat(lstProductSelected[index].AnnualizedUnitPrice - salesPrice).toFixed(2) ;
        } else{
            lstProductSelected[index].AnnualizedDiscountPercent = parseFloat((discount/(lstProductSelected[index].AnnualizedUnitPrice)*100)).toFixed(2);
        }
        component.set("v.lstProducts["+prodIndex+ "].lstProductsSelected",lstProductSelected);
		helper.calculateProRate(component);        
    },
    resettooltip:function(component, event, helper) {
        component.set('v.tooltip','false');
        component.set("v.hoverRow",-1);
    },
    onAnnualUnitFocus : function(component, event, helper) {
        var listComp = event.getSource();
        var name = listComp.get("v.name");
        var index=name.charAt(0);
        var adjustedAnnualUnitPrice=0;
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var lstProducts = component.get("v.lstProducts");
        var lstSelectedProducts = lstProducts[prodIndex].lstProductsSelected;
        var annualUnitPrice = listComp.get("v.value");
        var discountAmt = 0;
        var indianLevyTaxAmt = 0;
        var salesPrice = 0;
        
        discountAmt = lstSelectedProducts[index].AnnualizedDiscountAmount;
        console.log("AnnualUnitPrice" + annualUnitPrice);
        console.log("discountAmt"+ discountAmt);
        //lstSelectedProducts[index].salesPrice=parseFloat(extListPrice-discountAmt).toFixed(2);
        salesPrice = (annualUnitPrice-discountAmt);
        if (lstSelectedProducts[index].isIndianLevyProd){ // SFDC-3428
            console.log('$$$$ Annual Unit ---Indian levy prod---');
            var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
            indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
          adjustedAnnualUnitPrice = parseFloat(annualUnitPrice) + parseFloat(indianLevyTaxAmt);
          if(Math.sign(salesPrice)  > 0 && !Number.isNaN(adjustedAnnualUnitPrice)) {
              component.set("v.hoverRow", event.getSource().get("v.label"));
              component.set("v.tooltipmessage",adjustedAnnualUnitPrice.toFixed(2));
            }else {
                component.set("v.hoverRow", -1);
            } 
        }
        
    },
    onlistPriceFocus : function(component, event, helper) {
        var listComp = event.getSource();
        var name = listComp.get("v.name");
        var index=name.charAt(0);
        var adjustedListPrice=0;
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var lstProducts = component.get("v.lstProducts");
        var lstSelectedProducts = lstProducts[prodIndex].lstProductsSelected;
        var extListPrice = listComp.get("v.value");
        var discountAmt = 0;
        var indianLevyTaxAmt = 0;
        var salesPrice = 0;
        
        discountAmt = lstSelectedProducts[index].discountAmount;
        console.log("extListPrice" + extListPrice);
        console.log("discountAmt"+ discountAmt);
        //lstSelectedProducts[index].salesPrice=parseFloat(extListPrice-discountAmt).toFixed(2);
        salesPrice = (extListPrice-discountAmt);
        if (lstSelectedProducts[index].isIndianLevyProd){ // SFDC-3428
            console.log('$$$$ Indian levy prod---');
            var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
            indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
          adjustedListPrice = parseFloat(extListPrice) + parseFloat(indianLevyTaxAmt);
          if(Math.sign(salesPrice)  > 0 && !Number.isNaN(adjustedListPrice)) {
              component.set("v.hoverRow", event.getSource().get("v.label"));
              component.set("v.tooltipmessage",adjustedListPrice.toFixed(2));
            }else {
                component.set("v.hoverRow", -1);
            } 
        }
        
    }
})