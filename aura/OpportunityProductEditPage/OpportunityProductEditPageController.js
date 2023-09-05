({
    doInit : function(component, event, helper) {
       helper.initializeData(component,event);
    },
    
    onDiscAmtPercentChange : function(component, event, helper) {
        
        var listedProducts = component.get("v.lstProductsAdded");
        var discountName = event.getSource().get("v.name");
        //console.log("onDiscAmtPercentChange - discountName: " + discountName);
        var discount = event.getSource().get("v.value");
        //console.log("onDiscAmtPercentChange - discount: " + discount);
        var validNumber = helper.validDecimal(component,discount);
        //if discount is not a valid decimal number show overlay message
        if(!validNumber) {
            component.find('overlayMessages').showCustomModal({
                                            header: "Invalid Decimal",
                                            body: "Please enter a valid decimal of upto 2 decimal places", 
                                            footer: "",
                                            showCloseButton: true,
                                            cssClass: "my-modal,my-custom-class,my-other-class",
                                            closeCallback: function() {
                                                discount=parseFloat(discount).toFixed(2);
                                                event.getSource().set("v.value",discount);
                                            }
                                        });
        }
        if (!discount || isNaN(discount)) {
             event.getSource().set("v.value", '');
        }
        var index = discountName.charAt(0);
        //console.log("onDiscAmtPercentChange - index: " + index);
        // var prodIndex = discountName[discountName.length -1];
        var prodIndex = discountName.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        //console.log("onDiscAmtPercentChange - prodIndex: " + prodIndex);
        var lstProductSelected = listedProducts[prodIndex].lstOPS;
        var salesPrice = 0;
        var indianLevyTaxAmt = 0;
        //var indianLevyProdList = component.get("v.indianLevyProdList");
        if(discountName.indexOf("Percent")!==-1) {
            salesPrice =  parseFloat(lstProductSelected[index].ExternalListPrice__c *(1-(discount)/100)).toFixed(2);
            lstProductSelected[index].DiscountType__c = 'Percentage';
            lstProductSelected[index].DiscountAmount__c = parseFloat(lstProductSelected[index].ExternalListPrice__c - salesPrice).toFixed(2) ;
        } else if(discountName.indexOf("Amount")!==-1) {
            salesPrice =  parseFloat(lstProductSelected[index].ExternalListPrice__c -discount).toFixed(2);
            lstProductSelected[index].DiscountType__c = 'Amount';            
            lstProductSelected[index].DiscountPercent__c = parseFloat(discount/(lstProductSelected[index].ExternalListPrice__c)*100).toFixed(2);
            if(lstProductSelected[index].ExternalListPrice__c <=0) {
                lstProductSelected[index].DiscountPercent__c = 0;
            }
        } else {
            lstProductSelected[index].DiscountType__c = 'No Discount';
        }
        if (listedProducts[prodIndex].isIndianLevyProd){ // SFDC-3428
          console.log('$$$$ Indian levy prod---');
          var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
          indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
        }
        lstProductSelected[index].SalesPrice__c = parseFloat(salesPrice)+parseFloat(indianLevyTaxAmt);
        lstProductSelected[index].TotalPrice__c = parseFloat(lstProductSelected[index].SalesPrice__c * lstProductSelected[index].Quantity__c).toFixed(2);
        component.set("v.lstProductsAdded["+prodIndex+ "].lstOPS",lstProductSelected);
        helper.validate(component);
    },
    
    onQtyChange : function(component, event, helper) {
        var qtyComp = event.getSource();
        //console.log("onQtyChange - name: " + qtyComp.get("v.name"));
        var qty = qtyComp.get("v.value");
        // var prodIndex = qtyComp.get("v.name").charAt(0);
        var prodIndex = qtyComp.get("v.name").replace(/\D+$/g, ""); // SFDC-911 using RegEx to extract index number at the beginning of string
        //console.log("onQtyChange - prodIndex: " + prodIndex);
        var lstProducts = component.get("v.lstProductsAdded");
        //quantity cannot be less than 1
        if(!qty || qty<1) {
            qty=1;
            component.set("v.lstProductsAdded["+prodIndex+"].productQty",qty);
        }
        
        var lstProducts = component.get("v.lstProductsAdded");
        var lstOPS = lstProducts[prodIndex].lstOPS;
        for(var i=0; i<lstOPS.length; i++) {
            lstOPS[i].TotalPrice__c=lstOPS[i].SalesPrice__c*qty ;
            lstOPS[i].Quantity__c = qty;
        }
        component.set("v.lstProductsAdded["+prodIndex+"].lstOPS",lstOPS);
        //SFDC-400 - Pro-Ration Calculation 
		helper.calculateProRate(component);
    },
    
    onEstimateValueRisk : function(component, event, helper) {
        var listComp = event.getSource();
        var name = listComp.get("v.name");
        var estimateValue = listComp.get("v.value");
        var prodIndex = name.replace(/.*\D/g, ""); 
        var lstProductsAdded = component.get("v.lstProductsAdded");
        lstProductsAdded[prodIndex].oppyProduct.EstimatedValueatRisk__c = estimateValue;
        component.set("v.lstProductsAdded",lstProductsAdded);
    },    
    onAnnualizedDiscountChange : function(component, event, helper) {
      var discountName = event.getSource().get("v.name");       
      var prodIndex = discountName.replace(/.*\D/g, "");
      var index= discountName.charAt(0);
      var lstProducts = component.get("v.lstProductsAdded");
      var discountType = lstProducts[prodIndex].discountType;
      var lstSelectedProducts = lstProducts[prodIndex].lstOPS;
      var AnnualUnitPrice = lstSelectedProducts[index].AnnualizedUnitPrice__c;
      var discountAmt = 0;
      if(discountType==="Amount") {
            discountAmt = lstSelectedProducts[index].AnnualizedDiscountAmount__c;
            lstSelectedProducts[index].AnnualizedDiscountPercent__c = parseFloat((discountAmt/AnnualUnitPrice)*100).toFixed(2);
            if(AnnualUnitPrice<=0) {
                lstSelectedProducts[index].AnnualizedDiscountPercent__c = 0;
            }
        }
        if(discountType==="Percentage") {
            discountAmt = (lstSelectedProducts[index].AnnualizedDiscountPercent__c/100)*AnnualUnitPrice;
            lstSelectedProducts[index].AnnualizedDiscountAmount__c = parseFloat(discountAmt).toFixed(2);
            if(AnnualUnitPrice<=0) {
                lstSelectedProducts[index].AnnualizedDiscountAmount__c = 0;
            } 
        } 
        component.set("v.lstProductsAdded["+prodIndex+"].lstOPS",lstSelectedProducts);
        helper.calculateProRate(component);
    },
    onAnnualizedPriceChange : function(component, event, helper) {     
        helper.calculateProRate(component);
        var listComp = event.getSource();
        var name = listComp.get("v.name");
        var index=name.charAt(0);
        var adjustedAnnualUnitPrice=0;      
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        var lstProducts = component.get("v.lstProductsAdded");
        var lstSelectedProducts = lstProducts[prodIndex].lstOPS;
        console.log('SelectedProd**' + JSON.stringify(lstSelectedProducts));
         console.log('Discount**' + lstSelectedProducts[index].AnnualizedDiscountAmount__c);
        var annualUnitPrice = listComp.get("v.value");        
        var discountAmt = 0;
        var indianLevyTaxAmt = 0;
        var salesPrice = 0;
       
        if(lstSelectedProducts[index].AnnualizedDiscountAmount__c > 0) {
            discountAmt = lstSelectedProducts[index].AnnualizedDiscountAmount__c;
        }
        salesPrice = (annualUnitPrice-discountAmt);
        if (lstProducts[prodIndex].isIndianLevyProd){ // SFDC-3428
            console.log('$$$$ unit Indian levy prod---');
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
    onListPriceChange : function(component, event, helper) {
        var listComp = event.getSource();        
        var adjustedListPrice=0;
        var name = listComp.get("v.name");
        //console.log("onListPriceChange - name: " + name);
        var index=name.charAt(0);
        //console.log("onListPriceChange - index: " + index);
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        //console.log("onListPriceChange - prodIndex: " + prodIndex);
        var lstProducts = component.get("v.lstProductsAdded");
        var lstSelectedProducts = lstProducts[prodIndex].lstOPS;
        var extListPrice = listComp.get("v.value");
        console.log("onListPriceChange - extListPrice: " + extListPrice);
        var discountType = lstProducts[prodIndex].discountType;
        var discountAmt = 0;
        var salesPrice = 0;
        var indianLevyTaxAmt = 0;              
        //var indianLevyProdList = component.get("v.indianLevyProdList");
        if(discountType==="Amount") {
            discountAmt = lstSelectedProducts[index].DiscountAmount__c;
            lstSelectedProducts[index].DiscountPercent__c = parseFloat((discountAmt/extListPrice)*100).toFixed(2);
            if(extListPrice<=0) {
                lstSelectedProducts[index].DiscountPercent__c = 0;
            }
        }
        if(discountType==="Percentage") {
            discountAmt = (lstSelectedProducts[index].DiscountPercent__c/100)*extListPrice;
            lstSelectedProducts[index].DiscountAmount__c = parseFloat(discountAmt).toFixed(2);
            if(extListPrice<=0) {
                lstSelectedProducts[index].DiscountAmount__c = 0;
            }
        }
        salesPrice = parseFloat(extListPrice-discountAmt).toFixed(2);
        if (lstProducts[prodIndex].isIndianLevyProd){ // SFDC-3428
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
        lstSelectedProducts[index].SalesPrice__c=parseFloat(salesPrice)+parseFloat(indianLevyTaxAmt);
        lstSelectedProducts[index].TotalPrice__c=parseFloat(lstSelectedProducts[index].SalesPrice__c*lstProducts[prodIndex].productQty).toFixed(2);
        component.set("v.lstProductsAdded["+prodIndex+"].lstOPS",lstSelectedProducts);
        helper.validate(component);
    },
    
    onDiscountTypeChange : function(component, event, helper) {
        var discountName = event.getSource().get("v.name");
        //console.log("onDiscountTypeChange - discountName: " + discountName);
        // var prodIndex = discountName[discountName.length -1];
        var prodIndex = discountName.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        //console.log("onDiscountTypeChange - prodIndex: " + prodIndex);
        var listedProducts = component.get("v.lstProductsAdded");
        var discountType = listedProducts[prodIndex].discountType;
        //console.log("onDiscountTypeChange - discountType: " + discountType);
        // this might return an array in case multiple line items
        var discountPercents = component.find("discountPercent");
        discountPercents = [].concat(discountPercents);//convert it into an array or add blank
        //console.log("onDiscountTypeChange - discountPercents size: " + discountPercents.length);
        // this might return an array in case multiple line items
        var discountAmounts = component.find("discountAmount");
        discountAmounts = [].concat(discountAmounts);//convert it into an array or add blank
        //console.log("onDiscountTypeChange - discountAmounts size: " + discountAmounts.length);

        if (discountType==="No Discount") {
            discountPercents.forEach(cmp => {
                //console.log('cmp.get("v.name"): ' + cmp.get("v.name"));
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
            var selectedProducts = listedProducts[prodIndex].lstOPS;
            console.log("onDiscountTypeChange - selectedProducts size: " + selectedProducts.length);
            for (var i=0; i<selectedProducts.length; i++) {
                var salesPrice = 0;
				var indianLevyTaxAmt = 0;
				//var indianLevyProdList = component.get("v.indianLevyProdList");
				console.log('selectedProducts[i].ExternalListPrice__c ==' + selectedProducts[i].ExternalListPrice__c);
                if(selectedProducts[i].ExternalListPrice__c === '' 
                   || selectedProducts[i].ExternalListPrice__c === null) {
                    salesPrice = 0;
                } else {
                	salesPrice=selectedProducts[i].ExternalListPrice__c;    
                }
                selectedProducts[i].DiscountPercent__c=0;
                selectedProducts[i].DiscountAmount__c=0;
                if (listedProducts[prodIndex].isIndianLevyProd){ // SFDC-3428
                  var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                  indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                }
                selectedProducts[i].SalesPrice__c=parseFloat(salesPrice)+parseFloat(indianLevyTaxAmt);
                selectedProducts[i].TotalPrice__c=parseFloat(selectedProducts[i].SalesPrice__c*listedProducts[prodIndex].productQty).toFixed(2) ;
            }
            component.set("v.lstProductsAdded["+prodIndex+"].lstOPS", selectedProducts);
            var discountType = component.get("v.lstProductsAdded["+prodIndex+"].discountType");
            console.log("onDiscountTypeChange - discountType: " + discountType);
        }

        if (discountType==="Amount" ) {
            discountPercents.forEach(cmp => {
                //if(cmp.get("v.name")[cmp.get("v.name").length-1]===prodIndex) {
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
        helper.calculateProRate(component);
    },
    
    productTermChange : function(component, event, helper) {
        var yearVal = event.getSource().get("v.value");
        console.log('productTermChange - yearVal: ' + yearVal);
        var index = event.getSource().get("v.name");
        //console.log('productTermChange - index: ' + index);
        var lstProducts = component.get("v.lstProductsAdded");
        var lstOPSCurrent = lstProducts[index].lstOPS;
        var lstOPS = [];
        var mapOPSAll = lstProducts[index].mapOPSAll;
        var discountType = lstProducts[index].discountType;
        //console.log('productTermChange - discountType: ' + discountType);
        var salesPrice = 0;
		var indianLevyTaxAmt = 0;
		//var indianLevyProdList = component.get("v.indianLevyProdList");        
        //carry forward existing discounts values
        if(yearVal != 1 && component.get("v.globalProRateCheck") === 'Yes' && lstProducts[index].oppyProduct.Product2.AAG__c === 'Subscription'){
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
            lstProducts[index].oppyProduct.productTermSelected = yearVal;               
        	component.set("v.lstProductsAdded["+index+ "].productTermSelected",yearVal);
            helper.calculateProRate(component);
        } else {
        
            lstOPS = mapOPSAll[yearVal];
            for(var key in lstOPS) {
                //carry forward discount percentages user already selected
                if (lstOPSCurrent && lstOPSCurrent[key]) {
                    if (discountType==='Amount') {
                        lstOPS[key].DiscountAmount__c = parseFloat(lstOPSCurrent[key].DiscountAmount__c).toFixed(2);     
                        lstOPS[key].DiscountPercent__c = parseFloat(lstOPSCurrent[key].DiscountAmount__c/lstOPSCurrent[key].ExternalListPrice__c*100).toFixed(2);         
                    }
                    else {
                        lstOPS[key].DiscountPercent__c = parseFloat(lstOPSCurrent[key].DiscountPercent__c).toFixed(2);      
                        lstOPS[key].DiscountAmount__c = parseFloat((lstOPS[key].DiscountPercent__c/100)*lstOPS[key].ExternalListPrice__c).toFixed(2);
                    }
                    if(lstOPSCurrent[key].ExternalListPrice__c<=0) {
                            lstOPS[key].DiscountPercent__c=0;
                            lstOPS[key].DiscountAmount__c=0;
                        }
                    //console.log('productTermChange - lstOPSCurrent DiscountPercent: ' + lstOPSCurrent[key].DiscountPercent__c);
                    //console.log('productTermChange - lstOPSCurrent DiscountAmount: ' + lstOPSCurrent[key].DiscountAmount__c);
                }
                
                salesPrice = parseFloat(lstOPS[key].ExternalListPrice__c - lstOPS[key].DiscountAmount__c).toFixed(2); 
                if (lstProducts[index].isIndianLevyProd){ // SFDC-3428
                  console.log('$$$$ Indian levy prod---');
                  var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
                  indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*salesPrice;
                }
                lstOPS[key].SalesPrice__c=parseFloat(salesPrice)+parseFloat(indianLevyTaxAmt);
                lstOPS[key].TotalPrice__c=parseFloat(lstOPS[key].SalesPrice__c*lstProducts[index].productQty).toFixed(2) ;
            }
            component.set("v.lstProductsAdded["+index+ "].lstOPS",lstOPS);
            component.set("v.lstProductsAdded["+index+ "].productTermSelected",yearVal);
        }
    },
    cancel : function(component, event, helper) {
        var oppyId = component.get("v.oppyId");
        helper.navigateToOppy(component);
    },
    save : function(component, event, helper) {
        helper.save(component,event);
    },
    close : function(component,event,helper) {
        helper.save(component,event,true);
    },
    remove : function(component, event, helper) {
        //console.log("remove - product name: " + event.getSource().get("v.name"));
        // var prodIndex = event.getSource().get("v.name").charAt(0);
        var prodIndex = event.getSource().get("v.name").replace(/\D+$/g, ""); // SFDC-911 using RegEx to extract index number at the beginning
        //console.log("remove - prodIndex: " + prodIndex);
        var lstProducts = component.get("v.lstProductsAdded");
        lstProducts[prodIndex].isDeleted = true;
        component.set("v.lstProductsAdded",lstProducts);
    },
    reset : function(component, event,helper) {
       helper.initializeData(component,event);
    },
    addProducts : function(component, event,helper) {
        helper.addProducts(component,event);
    },
    //SFDC-4730 Change Start
    /*
    openModal : function(component, event, helper) {
        component.set("v.openModal", true);
        var lstLegalEntity = component.get("v.lstLegalEntity");
        if(!lstLegalEntity || lstLegalEntity.length<1) {
            //query the controller to get active legal entity list
            var action = component.get("c.getValidLegalEntities");
            var legalEntityId = component.get("v.oppy.LegalEntity__c");
            action.setParams({
                "currentLegalEntityId" : legalEntityId
            });
            action.setCallback(this,function(response) {
                var state = response.getState();
                if(state ==="SUCCESS") { 
                    var result = response.getReturnValue();
                    if(result!==undefined && result!==null) {
                        component.set("v.lstLegalEntity",result);						
                    }
                } else if(state == "Error") {
                    alert("An error has occured while deleting the records");
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeModal : function(component, event, helper) {
        component.set("v.openModal", false);        
    },
    changeLegalEntity : function(component, event, helper) {
        var action = component.get("c.deleteProductsOnOppy");
        var oppyId = component.get("v.oppyId");
        var changedLegalEntity = component.get("v.newlegalEntity");
        action.setParams({
            "oppyId" : oppyId,
            "newLegalEntity" : changedLegalEntity
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if(state ==="SUCCESS") { 
                var result = response.getReturnValue();
                if(result!==undefined && result!==null) {
                    if(result.indexOf("Error Occurred")!==-1) {
                        toastEvent.setParams({
                            "title": "Oops!",
                            "message":result,
                            "mode":"dismissible",
                            "type":"error",
                            "duration":"3000"
                            
                        });
                        toastEvent.fire();
                        return;
                    }
                    toastEvent.setParams({
                        "title": "Records deleted!",
                        "message":result,
                        "mode":"dismissible",
                        "type":"success",
                        "duration":"3000"
                        
                    });
                    toastEvent.fire();
                    //helper.navigateToAddProducts(component);
                    component.set("v.openModal", false);
                    $A.get('e.force:refreshView').fire();
                    
                }
            } else if(state == "Error") {
                alert("An error has occured while deleting the records");
            }
        });
        $A.enqueueAction(action);
    },
    */
    //SFDC-4909 Change Start
    openModal : function(component, event, helper) {
        var saveOrClose = event.getSource().getLocalId();
        component.set("v.saveOrClose", saveOrClose);
        var initialProductCount = component.get("v.countOfInitialProductsAdded");
        var addedProducts = component.get("v.lstProductsAdded");
        var addedProductIds = [];
        var materialCodes = [];
        var count = 0;
        for (var key in addedProducts) {
            if(addedProducts[key].isDeleted == false){
                addedProductIds.push(addedProducts[key].oppyProduct.Product2Id);
            	materialCodes.push(addedProducts[key].oppyProduct.MaterialCode__c);
                count = count + 1;
            }
        }
        if(count == 0){
            var oppyId = component.get("v.oppyId");
            var action = component.get("c.updateLegalEntityNull");
        	action.setParams({ oppyId: oppyId });
        	
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if (result !== undefined && result !== null) {
                    if(saveOrClose == 'save'){
        				var action = component.get('c.save');
        				$A.enqueueAction(action);
        			}
        			else if (saveOrClose == 'close'){
            			var action = component.get('c.close');
        				$A.enqueueAction(action);
        			}
                }
            }
            else if (state == "Error") {
                alert("An error has occured please contact Salesforce Helpdesk");
            }
        });
        $A.enqueueAction(action);
        }
        else if(initialProductCount != count && count != 0){
        	component.set("v.countOfUpdatedProductsAdded", count);
        	component.set("v.lstMaterialCodes", materialCodes);
        	component.set("v.lstAddedProducts", addedProductIds);
            component.set("v.productsRemoved", true);
        	component.set("v.openModal", true);
        }
        else{
            if(saveOrClose == 'save'){
        		var action = component.get('c.save');
        		$A.enqueueAction(action);
        	}
        	else if (saveOrClose == 'close'){
            	var action = component.get('c.close');
        		$A.enqueueAction(action);
        	}
        } 
    },
    closeModal : function(component, event, helper) {
        component.set("v.openModal", false);
        var saveOrClose = component.get("v.saveOrClose");
        if(saveOrClose == 'save'){
        	var action = component.get('c.save');
        	$A.enqueueAction(action);
        }
        else if (saveOrClose == 'close'){
            var action = component.get('c.close');
        	$A.enqueueAction(action);
        }
    },
    newCloseModal : function(component, event, helper) {
        component.set("v.openModal", false);
    },
    //SFDC-4909 Change End
    onChangeLegalEntity: function(component, event, helper) {
        var addProducts = component.get("v.lstProductsAdded");
        var selectedProductIds = [];
        var materialCodes = [];
        for (var key in addProducts) {
            selectedProductIds.push(addProducts[key].oppyProduct.Product2Id);
            materialCodes.push(addProducts[key].oppyProduct.MaterialCode__c);
        }
        var oppyId = component.get("v.oppyId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:legalEntitySelector",
            componentAttributes: {
                oppyId: oppyId,
                lstProductsSelected: selectedProductIds,
                lstMaterialCodes: materialCodes,
                lstCurrentProductsSelected: selectedProductIds,
                isChangeLegalEntity: true
            }
        });
        evt.fire();
	},
    //SFDC-4730 Change End
    onGlobalDiscountChange: function(component,event,helper) {
        helper.applyGlobalDiscount(component);
        helper.validate(component);
        helper.resetErrorCode(component);
    },
    onGlobalTermChange : function(component,event,helper) {
        var globalTerm = component.get("v.globalTermYears");
        var index = event.getSource().get("v.name");
        var lstProducts = component.get("v.lstProductsAdded");
        var proRateCheck = component.get("v.globalProRateCheck");
        //console.log("onGlobalTermChange - globalTerm: " + globalTerm);
        if(globalTerm != 1 && proRateCheck === 'Yes'){
            var toastEvent = $A.get("e.force:showToast");
            var errMsg = 'For Prorated Products, Term will be set to 1.';
            toastEvent.setParams({
                                "title": "Error!",
                                "message":errMsg,
                                "mode":"dismissible",
                                "type":"warning",
                                "duration":"3000"
							});
            toastEvent.fire();
        }        
        for(var key in lstProducts) {
            
            var mapProductSchedulesAll = lstProducts[key].mapOPSAll;
            //console.log("onGlobalTermChange - mapProductSchedulesAll: "+mapProductSchedulesAll);
            if(lstProducts[key].oppyProduct.Product2.AAG__c === 'Subscription' && proRateCheck === 'Yes') {
                if(mapProductSchedulesAll[1]) {
                    lstProducts[key].lstOPS = mapProductSchedulesAll[1];
                    lstProducts[key].productTermSelected = 1;
                }                
            } else {       
                if(mapProductSchedulesAll[globalTerm]) {
                    lstProducts[key].lstOPS = mapProductSchedulesAll[globalTerm];
                    lstProducts[key].productTermSelected = globalTerm;
                } else {
                    for(var i=5; i>0; i--) {
                        if(mapProductSchedulesAll[i]) {
                            lstProducts[key].lstOPS = mapProductSchedulesAll[i];
                            lstProducts[key].productTermSelected = i;
                            break;
                        }
                    }
                }
            }
        }        
        component.set("v.lstProductsAdded",lstProducts);
        helper.applyGlobalDiscount(component);            
    },
    onGlobalDiscountTypeChange: function(component, event, helper) {
        helper.applyGlobalDiscount(component);
        helper.validate(component);
        helper.resetErrorCode(component);
    },
    onUpliftChange: function(component, event,helper) {
        helper.applyGlobalUplift(component);
        helper.applyGlobalDiscount(component);
        helper.validate(component);
        helper.resetErrorCode(component);
    },
    roundOffDiscounts: function(component, event, helper) {
        var discount = event.getSource().get("v.value");
        if(!discount || isNaN(discount)) {
            discount=0;
        }
        discount = parseFloat(discount).toFixed(2);
        event.getSource().set("v.value",discount);
    },
    onGlobalLicenseTypeChange: function(component, event, helper) {
        var globallicenseType = component.get("v.globalLicenseType");
        var lstProductsAdded = component.get("v.lstProductsAdded");
        for(var prod in lstProductsAdded ) {
            lstProductsAdded[prod].oppyProduct.LicenseType__c = globallicenseType;
        }
         component.set("v.lstProductsAdded",lstProductsAdded);
    },
    onLicenseTypeChange: function(component, event, helper) {
       // var licenseType = component.get("v.licenseTypes");
        var toggleText = component.find("licenseTypes");
        $A.util.toggleClass(toggleText, "hiddenLabel");
    },
     
    // SFDC-3920- Added a global checkbox to check/uncheck products as risky in one go.
    // Author - Sharique Iqbal
    // Date - 26th Feb 2021
    onGlobalProdRiskChange: function(component, event, helper) {
        var globalcheck = component.find("selectAll").get("v.value");      
        var lstProductsAdded = component.get("v.lstProductsAdded");
        for(var prod in lstProductsAdded ) {
            if (lstProductsAdded[prod].status == 'Existing') {
                if (globalcheck) {
                   lstProductsAdded[prod].oppyProduct.IsProductatRisk__c = "Yes";
                   component.set("v.globalRiskStatusHide",false);
                   if (lstProductsAdded[prod].oppyProduct.RiskStatus__c == '') {
                     lstProductsAdded[prod].oppyProduct.RiskStatus__c = 'Open - Pending Resolution';//component.get("v.defaultRiskStatus");
                   }   
                } else {
                   lstProductsAdded[prod].oppyProduct.IsProductatRisk__c = "No";
                   lstProductsAdded[prod].oppyProduct.RiskStatus__c = "";
                   lstProductsAdded[prod].oppyProduct.EstimatedValueatRisk__c = '';
                   component.set("v.globalRiskStatusHide",true);
                }
            }
        }
        component.set("v.lstProductsAdded",lstProductsAdded);
    },
      
    // SFDC-3920- Added a global picklist to select Risk Status value in one go.
    // Author - Sharique Iqbal
    // Date - 26th Feb 2021
     onGlobalRiskStatusChange: function(component, event, helper) {
        var globalRiskStatus = component.get("v.globalRiskStatus");
        var lstProductsAdded = component.get("v.lstProductsAdded");
        for(var prod in lstProductsAdded ) {
            lstProductsAdded[prod].oppyProduct.RiskStatus__c = globalRiskStatus;
        }
         component.set("v.lstProductsAdded",lstProductsAdded);
    },
    
   onRiskStatusChange: function(component, event, helper) {
        var prodRisk = event.getSource().get("v.name");
        var prodIndex = prodRisk.replace(/.*\D/g, ""); 
        var lstProductsAdded = component.get("v.lstProductsAdded");
        if (lstProductsAdded[prodIndex].oppyProduct.IsProductatRisk__c == 'No') {
               lstProductsAdded[prodIndex].oppyProduct.RiskStatus__c = '';
               lstProductsAdded[prodIndex].oppyProduct.EstimatedValueatRisk__c = '';
        } else lstProductsAdded[prodIndex].oppyProduct.RiskStatus__c = 'Open - Pending Resolution';
                
       component.set("v.lstProductsAdded",lstProductsAdded);
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
    onProRate: function(component, event, helper) {
        var proRateType = event.getSource().get("v.value");
        if(proRateType === 'Yes') {
            helper.proRateYes(component);
        } 
        else if(proRateType === 'No') {
            helper.proRateNo(component);
        }
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
    sortOLI: function(component, event, helper) {
        component.set('v.sorting', true);
        if(component.get('v.sortOLIDirection') == 'asc') {
            component.set('v.sortOLIDirection','desc');
        }
        else if(component.get('v.sortOLIDirection') == 'desc') {
            component.set('v.sortOLIDirection','asc');
        }
        var spinner = component.find("loadSpinner2");
        $A.util.toggleClass(spinner, "slds-hide");
        helper.initializeData(component,event);
    },
    resettooltip:function(component, event, helper) {
        component.set('v.tooltip','false');
        component.set("v.hoverRow",-1);
    },
    onannualUnitPriceFocus:function(component, event, helper) {
        var listComp = event.getSource();
        var adjustedAnnualUnitPrice=0;
        var name = listComp.get("v.name");
        //console.log("onListPriceChange - name: " + name);
        var index=name.charAt(0);
        //console.log("onListPriceChange - index: " + index);
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        //console.log("onListPriceChange - prodIndex: " + prodIndex);
        var lstProducts = component.get("v.lstProductsAdded");
        var lstSelectedProducts = lstProducts[prodIndex].lstOPS;
        var annualUnitPrice = listComp.get("v.value");
        var annualdiscountAmt = 0;
        var annualsalesPrice = 0;
        var indianLevyTaxAmt = 0;
        //var indianLevyProdList = component.get("v.indianLevyProdList");
        annualdiscountAmt = lstSelectedProducts[index].AnnualizedDiscountAmount__c;
        annualsalesPrice = parseFloat(annualUnitPrice-annualdiscountAmt).toFixed(2);
        if (lstProducts[prodIndex].isIndianLevyProd){ // SFDC-3428
          console.log('$$$$ Annualized Indian levy prod---');
          var indianLevyTax = $A.get("$Label.c.IndianLevyTax");
          indianLevyTaxAmt = (parseFloat(indianLevyTax)/100)*annualsalesPrice;
          adjustedAnnualUnitPrice = parseFloat(annualUnitPrice) + parseFloat(indianLevyTaxAmt);
          console.log('adjustedAnnualUnitPrice ' + adjustedAnnualUnitPrice)  
            if(Math.sign(annualsalesPrice)  > 0 && !Number.isNaN(adjustedAnnualUnitPrice)) {
              console.log('annualsalesPrice ' + annualsalesPrice);
              component.set("v.hoverRow", event.getSource().get("v.label"));
              component.set("v.tooltipmessage",adjustedAnnualUnitPrice.toFixed(2));
            }else {
                component.set("v.hoverRow", -1);
            }
            console.log('tooltip mssg' + component.get("v.tooltipmessage"));
        }
   
    },
    onlistPriceFocus:function(component, event, helper) {
        var listComp = event.getSource();
        var adjustedListPrice=0;
        var name = listComp.get("v.name");
        //console.log("onListPriceChange - name: " + name);
        var index=name.charAt(0);
        //console.log("onListPriceChange - index: " + index);
        // var prodIndex = name[name.length-1];
        var prodIndex = name.replace(/.*\D/g, ""); // SFDC-911 using RegEx to extract index number at the end of string
        //console.log("onListPriceChange - prodIndex: " + prodIndex);
        var lstProducts = component.get("v.lstProductsAdded");
        var lstSelectedProducts = lstProducts[prodIndex].lstOPS;
        var extListPrice = listComp.get("v.value");
        var discountAmt = 0;
        var salesPrice = 0;
        var indianLevyTaxAmt = 0;
        //var indianLevyProdList = component.get("v.indianLevyProdList");
        discountAmt = lstSelectedProducts[index].DiscountAmount__c;
        salesPrice = parseFloat(extListPrice-discountAmt).toFixed(2);
        if (lstProducts[prodIndex].isIndianLevyProd){ // SFDC-3428
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