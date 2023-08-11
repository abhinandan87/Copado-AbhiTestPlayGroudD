({
    validate : function(component) {
        //validate for negative values
        var save = component.find("save");
        save.set("v.disabled",false);
        var showError = false;       
        component.set("v.showErrorMessage",showError);
        var savedProducts = component.get("v.lstProducts");
        for (var key in savedProducts) {
            for(var ps in savedProducts[key].lstProductsSelected) {
                if(savedProducts[key].lstProductsSelected[ps].totalPrice<0 || savedProducts[key].lstProductsSelected[ps].discountAmount<0){
                    save.set("v.disabled",true);
                    showError=true;
                    component.set("v.showErrorMessage",showError);
                    break;
                }                
            }            
        }
    },
    applyGlobalDiscount : function(component) {
        var lstProducts = component.get("v.lstProducts");
        var discountType = component.get("v.globalDiscountType");
        var globalDiscount = component.get("v.globalDiscountValue");
        var globalDiscountStep = component.get("v.globalDiscountStep");
        var proRateCheck = component.get("v.globalProRateCheck");
        for(var key in lstProducts) {
            lstProducts[key].discountType = discountType;
            var stepCounter = 1;
            for(var prod in lstProducts[key].lstProductsSelected) {
                
                var calculatedDiscount ;
                calculatedDiscount = globalDiscount*stepCounter;
                if(globalDiscountStep === "Step down") {
                    calculatedDiscount = globalDiscount/stepCounter;
                }
                //SFDC-400 Annualized Discount if ProRation applied
                if(lstProducts[key].aag === 'Subscription' && proRateCheck === 'Yes') {
                    if(discountType=="Amount" && lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice > 0) {
                        lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount = calculatedDiscount;
                        lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountPercent =(calculatedDiscount/lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice)*100;
                    }else if(discountType=="Percentage" && lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice > 0){
                        lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountPercent = calculatedDiscount;
                        lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount = (calculatedDiscount/100)*lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice;
                    }else {
                        lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountPercent = 0.0;
                        lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount = 0.0;
                    }
                }
                if(discountType=="Amount" && lstProducts[key].lstProductsSelected[prod].externalListPrice > 0) {
                    lstProducts[key].lstProductsSelected[prod].discountAmount = calculatedDiscount;
                    lstProducts[key].lstProductsSelected[prod].discountPercent =(calculatedDiscount/lstProducts[key].lstProductsSelected[prod].externalListPrice)*100;
                    
                }else if(discountType=="Percentage" && lstProducts[key].lstProductsSelected[prod].externalListPrice > 0){
                    lstProducts[key].lstProductsSelected[prod].discountPercent = calculatedDiscount;
                    lstProducts[key].lstProductsSelected[prod].discountAmount = (calculatedDiscount/100)*lstProducts[key].lstProductsSelected[prod].externalListPrice;
                }else {
                    lstProducts[key].lstProductsSelected[prod].discountPercent = 0.0;
                    lstProducts[key].lstProductsSelected[prod].discountAmount = 0.0;                    
                }
                var indianLevyTaxAmt = 0;
       			var salesPrice = 0;
                salesPrice = lstProducts[key].lstProductsSelected[prod].externalListPrice - lstProducts[key].lstProductsSelected[prod].discountAmount;
                lstProducts[key].lstProductsSelected[prod].totalPrice=lstProducts[key].lstProductsSelected[prod].salesPrice*lstProducts[key].productQty;
                if(globalDiscountStep.indexOf("Step")>=0) {
                    stepCounter++;
                }
                if (lstProducts[key].isIndianLevyProd){ // SFDC-3428
                    var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                    indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                }
                salesPrice = parseFloat(salesPrice) + parseFloat(indianLevyTaxAmt);
                lstProducts[key].lstProductsSelected[prod].discountPercent = parseFloat(lstProducts[key].lstProductsSelected[prod].discountPercent).toFixed(2);
                lstProducts[key].lstProductsSelected[prod].discountAmount = parseFloat(lstProducts[key].lstProductsSelected[prod].discountAmount).toFixed(2);
                lstProducts[key].lstProductsSelected[prod].salesPrice = parseFloat(salesPrice).toFixed(2);
                lstProducts[key].lstProductsSelected[prod].totalPrice = parseFloat(lstProducts[key].lstProductsSelected[prod].salesPrice*lstProducts[key].productQty).toFixed(2);
                
            }
        }
        component.set("v.lstProducts",lstProducts);
        if(discountType=="No Discount") {
            component.set("v.globalDiscountValue",0);
        }
        this.calculateProRate(component);
        console.log('ProRated Calculate on Global');
    },
    resetErrorCode : function(component) {
        component.set("v.resetErrors",false);
        component.set("v.resetErrors",true);
    },
    validateLicense : function(component) {
        //check if any field has invalid input
        //check for license type
        var lstProducts = component.get("v.lstProducts");
        var listSize = lstProducts.length;
        var isValid = true;
        var licenseTypeField=[];
        licenseTypeField = component.find("licenseTypes");
        if (!licenseTypeField) {
            return true;
        }
        licenseTypeField = [].concat(licenseTypeField);
        licenseTypeField.forEach( cmp => {
            var validity = cmp.get("v.validity");
            if(cmp.get("v.validity") !== undefined && !cmp.get("v.validity").valid) { 
            //cmp.set("v.validity", {valid:false, valueMissing :true});
            isValid=false;
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
        return isValid;
    },
    applyGlobalUplift: function(component) {
        var lstProducts = component.get("v.lstProducts");
        var upliftpercent = component.get("v.globalUplift");
        console.log('--upliftpercent--'+upliftpercent);
        for (var key in lstProducts) {
            var year = 1;
            var previousListPrice = 0;
            for (var prod in lstProducts[key].lstProductsSelected) { 
                var percentIncrease = 0.0;
                if(year>1) {
                    console.log("previousListPrice=>" + previousListPrice);
                    console.log("percentIncrease=>" + percentIncrease);
                    percentIncrease = parseFloat(upliftpercent * previousListPrice / 100).toFixed(2);                
                    console.log("percentIncrease=>" + percentIncrease);
                    lstProducts[key].lstProductsSelected[prod].externalListPrice = (parseFloat(previousListPrice).toFixed(2) * 1) + (parseFloat(percentIncrease).toFixed(2) * 1);                    
                    //lstProducts[key].lstProductsSelected[prod].externalListPrice = parseFloat(lstProducts[key].lstProductsSelected[prod].externalListPrice).toFixed(2);                    
                }
                previousListPrice = lstProducts[key].lstProductsSelected[prod].externalListPrice;
                year++;
            }            
        }
         component.set("v.lstProducts", lstProducts);
    },
    calculateProRate: function(component){
        //SFDC-400 - Pro-Ration Calculation 
        var prorateCheck = component.get("v.globalProRateCheck");
        if(prorateCheck === 'Yes'){
            this.proRateChecked(component);
        }
    },
    proRateChecked: function(component) {
        //console.log('Prorated Check ');
        var lstProducts = component.get("v.lstProducts");
        for(var key in lstProducts) {
            //proRate only for subscription products
            if (lstProducts[key].aag === 'Subscription') {
	            var discountType = lstProducts[key].discountType; 
                //var conStartDate = new Date(lstProducts[key].ContractStartDate);
                //var conEndDate = new Date(lstProducts[key].ContractEndDate);
                //var proRatedDays = this.date360(conStartDate,conEndDate);
                var proRatedDays = lstProducts[key].proRatedDays;
                var indianLevyTaxAmt = 0;
				console.log('Prorated Days '+ proRatedDays);
                if(proRatedDays !== 360 && proRatedDays < 720) {
                    //Set Product Term Selected to 1 for ProRation
                    if(lstProducts[key].productTermSelected > 1) {
                        var mapProductSchedulesAll = lstProducts[key].mapProductsAll;
                        lstProducts[key].lstProductsSelected = mapProductSchedulesAll[1];
                        lstProducts[key].productTermSelected = 1;
                    }
              
                    for(var prod in lstProducts[key].lstProductsSelected) {
                        //console.log(' annual value new ' + lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice);
                        var annualUnitPrice = 0;
                        if(lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice != undefined 
                           && lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice != null 
                           && lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice !== '') {
	                        annualUnitPrice = lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice;
                        } else {                        
                            annualUnitPrice = lstProducts[key].lstProductsSelected[prod].priceBookListPrice;
                        }
                        var AnnualDiscAmt = 0
                        if(lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount == null) {
                            lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount = 0;
                        }
                        if(discountType==="Amount") {
                            AnnualDiscAmt = lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount;
                            lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountPercent =parseFloat((AnnualDiscAmt/annualUnitPrice)*100).toFixed(2);
                        }else if(discountType==="Percentage"){
                            AnnualDiscAmt = parseFloat((lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountPercent/100)*annualUnitPrice).toFixed(2);
                            lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount = AnnualDiscAmt;
                        }else {
                            AnnualDiscAmt = 0;
                            lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountPercent = 0.0;
                            lstProducts[key].lstProductsSelected[prod].AnnualizedDiscountAmount = 0.0;
                        }
                        lstProducts[key].lstProductsSelected[prod].AnnualizedUnitPrice = annualUnitPrice;
                        var annualSalesPrice = annualUnitPrice - AnnualDiscAmt;
                        var indianLevyTaxAmtAnnual = 0;
                        if (lstProducts[key].isIndianLevyProd){ 
                            var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                            indianLevyTaxAmtAnnual = (parseFloat(indianLevyTax)/100)*annualSalesPrice;
                        }
                        // Annualized Calculations:
                        annualSalesPrice = parseFloat(annualSalesPrice) + parseFloat(indianLevyTaxAmtAnnual);
                        console.log('Annual Sales Price ' + annualSalesPrice);
                        lstProducts[key].lstProductsSelected[prod].AnnualizedTotalAmount = parseFloat((annualSalesPrice) * lstProducts[key].productQty ).toFixed(2); 
                        
                        // ProRated Calculations:
                        var unitPrice = parseFloat((annualUnitPrice / 360) * proRatedDays).toFixed(2);
                        var discount = parseFloat((AnnualDiscAmt / 360) * proRatedDays).toFixed(2);
                        var discountPercent = 0;
                        console.log('unit Price Value ' + unitPrice);
                        if(unitPrice == 0.00) {
                            discountPercent = 0;
                        } else {
                        	discountPercent = parseFloat((discount/unitPrice)*100).toFixed(4);    
                        }                        
                        var salesPrice = unitPrice - discount;
                        var indianLevyTaxAmt = 0;
                        if (lstProducts[key].isIndianLevyProd){ // SFDC-3428
                          var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                          indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                        }
                        salesPrice = parseFloat(salesPrice) + parseFloat(indianLevyTaxAmt);
                        console.log('Sales Price ' + salesPrice);
                        lstProducts[key].lstProductsSelected[prod].externalListPrice = parseFloat(unitPrice) + parseFloat(indianLevyTaxAmt);
                        lstProducts[key].lstProductsSelected[prod].discountPercent = discountPercent;
                        lstProducts[key].lstProductsSelected[prod].discountAmount = discount;
                        lstProducts[key].lstProductsSelected[prod].salesPrice = salesPrice;
                        lstProducts[key].lstProductsSelected[prod].totalPrice = parseFloat((salesPrice) * lstProducts[key].productQty ).toFixed(2);
                        lstProducts[key].ProRationApplied = "Yes";
                    }
                } 
                
            } 
            
        }
        component.set("v.lstProducts",lstProducts);
        this.validate(component);
    },
    proRateUnchecked: function(component) {
        
        var lstProducts = component.get("v.lstProducts");
        for(var key in lstProducts) {
            lstProducts[key].ProRationApplied = "No";
            for(var prod in lstProducts[key].lstProductsSelected) {
                lstProducts[key].lstProductsSelected[prod].externalListPrice = lstProducts[key].lstProductsSelected[prod].priceBookListPrice;
                lstProducts[key].lstProductsSelected[prod].discountPercent = 0.0;
                lstProducts[key].lstProductsSelected[prod].discountAmount = 0.0;
                lstProducts[key].lstProductsSelected[prod].salesPrice = lstProducts[key].lstProductsSelected[prod].priceBookListPrice;
                lstProducts[key].lstProductsSelected[prod].totalPrice = parseFloat(lstProducts[key].lstProductsSelected[prod].priceBookListPrice * lstProducts[key].productQty).toFixed(2);
            }
        }
        component.set("v.lstProducts",lstProducts);
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