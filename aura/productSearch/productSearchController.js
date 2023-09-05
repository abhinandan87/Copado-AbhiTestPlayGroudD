({
    doInit: function(component, event, helper) {

        //SFDC-4730 Change start
        //fetch all Internal Business Segment and AAG values
        component.set("v.lstInternalBusinessSegment", []);
        component.set("v.lstAAG", []);
        var action = component.get("c.getAllInternalBusinessSegmentAAG");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result !== undefined && result !== null){
                    component.set("v.lstInternalBusinessSegment", result[0]);
                    component.set("v.lstAAG", result[1]);
                    console.log(result);
                    window.setTimeout(
                        $A.getCallback(function() {
                    	helper.addScrollListener(component, event);
                    }));
                }
            }
            else if (state == "Error") {
                alert("An error has occured please contact Salesforce Helpdesk");
            }
        });
        $A.enqueueAction(action);
        /*
        //fetch all legal entities first
        component.set("v.lstLegalEntity", []);
        var action = component.get("c.getAllLegalEntities");
        var oppyId = component.get("v.oppyId");
        console.log('--oppyId--' + oppyId);
        action.setParams({
            "oppyId": oppyId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result !== undefined && result !== null) {
                    component.set("v.lstLegalEntity", result.lstLegalEntity);
                    var existingLE = result.oppyLegalEntity;

                    window.setTimeout(
                        $A.getCallback(function() {
                            // Now set our preferred value
                            if (existingLE != null && existingLE != '') {
                                component.set("v.existingLegalEntity", existingLE);
                                component.set("v.legalEntity", existingLE);
                                console.log('--existingLE doinit--' + existingLE);
                            }
                            helper.addScrollListener(component, event);
                        }));


                    console.log(result);
                }
            }
            else if (state == "Error") {
                alert("An error has occured please contact Salesforce Helpdesk");
            }
        });
        $A.enqueueAction(action);
        */
        //SFDC-4730 Change end
        component.set("v.lstProductsSelected", []);
        var action = component.get("c.getProductsAlreadyInOppy");
        var oppyId = component.get("v.oppyId");
        action.setParams({ oppyId: oppyId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result !== undefined && result !== null) {
                    component.set("v.productsAlreadyInOppy", result);
                    console.log(result);
                }
            }
            else if (state == "Error") {
                alert("An error has occured please contact Salesforce Helpdesk");
            }
        });
        $A.enqueueAction(action);

    },
    //SFDC-4730 Change Start
    /*onLegalEntitySelection: function(component, event, helper) {
        //reset all lists and filters
        console.log('Reached LegalEntitySelection');
        helper.clearLists(component);
        console.log('After helper');
        //clear already selected products list as those will be deleted
        var productsInOppy = component.get("v.productsAlreadyInOppy");
        console.log('--productAlreadyInOppy--', productsInOppy);
        if (productsInOppy && productsInOppy != null && productsInOppy.length > 0) {
            //delete existing oppy products and it's related schedules
            var oppyId = component.get("v.oppyId");
            var action = component.get("c.deleteProductsOnOppy");
            var changedLegalEntity = component.get("v.legalEntity");
            action.setParams({
                "oppyId": oppyId,
                "newLegalEntity": changedLegalEntity
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var toastEvent = $A.get("e.force:showToast");
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result !== undefined && result !== null) {
                        if (result.indexOf("Error Occurred") !== -1) {
                            toastEvent.setParams({
                                "title": "Oops!",
                                "message": result,
                                "mode": "dismissible",
                                "type": "error",
                                "duration":"3000"
                            });
                            toastEvent.fire();
                            return;
                        }
                        toastEvent.setParams({
                            "title": "Records updated!",
                            "message": result,
                            "mode": "dismissible",
                            "type": "success",
                            "duration":"3000"

                        });
                        toastEvent.fire();
                        component.set("v.productsAlreadyInOppy", []);
                        component.set("v.openModal", false);
                    }
                }
                else if (state == "Error") {
                    alert("An error has occured while deleting the records");
                }
            });
            $A.enqueueAction(action);
        }
        else {
            component.set("v.productsAlreadyInOppy", []);
            component.set("v.openModal", false);
        }

    },
    */
    //SFDC-4730 Change End
    onFilterChange: function(component, event, helper) {
        component.set("v.lstProductsSearched", []);
        var delayTimer = component.get("v.delayTimer");
        clearTimeout(delayTimer);
        delayTimer = setTimeout(function() {
            helper.fetchProducts(component);
            component.set("v.allProductsLoaded", false);
            component.set("v.offsetLimitReached", false);
            var spinner = component.find("productSpinner");
            $A.util.addClass(spinner, "slds-hide");
            $A.util.removeClass(spinner, "slds-show");
        }, 750); // Will do the ajax stuff after 1000 ms, or 1 s
        component.set("v.delayTimer", delayTimer);
    },
    onRemoveButtonClick: function(component, event, helper) {
        var selectedProds = component.get("v.lstProductsSelected");
        var index = event.getSource().get("v.name");
        var uncheckProd = selectedProds[index];
        selectedProds.splice(index, 1);
        component.set("v.lstProductsSelected", selectedProds);
    },
    cancel: function(component, event, helper) {
        var oppyId = component.get("v.oppyId");
        var navevent = $A.get("e.force:navigateToSObject");
        navevent.setParams({
            "recordId": oppyId,
            "slideDevName": "detail",
            "isredirect": true
        });
        navevent.fire();
    },
    onProductSelection: function(component, event, helper) {
        var eleCheck = event.target;
        var selectedData = component.get("v.lstProductsSelected");
        var index = event.getSource().get("v.name");
        //var index = event.target.dataset.index;
        var productData = component.get("v.lstProductsSearched");
        var selProd = productData[index];
        selProd.IsSelected = true;
        selectedData.push(selProd);
        productData[index].isSelected = true;
        component.set("v.lstProductsSearched", productData);
        component.set("v.lstProductsSelected", selectedData);
    },
    waiting: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    doneWaiting: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    onProceed: function(component, event, helper) {
        //SFDC-4730 Change Start
        /*var selectedProducts = component.get("v.lstProductsSelected");
        if (selectedProducts == null || selectedProducts == undefined || selectedProducts.length < 1) { //show error message
            alert("Select atleast one product to proceed");
            return;
        }
        var selectedProductIds = [];
        for (var key in selectedProducts) {
            selectedProductIds.push(selectedProducts[key].productId);
        }
        var legalEntity = component.get("v.legalEntity");
        var legalEntityName = '';
        var lstLegalEntity = component.get("v.lstLegalEntity");
        for (var key in lstLegalEntity) {
            if (lstLegalEntity[key].Id === legalEntity) {
                legalEntityName = lstLegalEntity[key].Name;
                break;
            }
        }
        
        var proceedEvent = component.getEvent("onProceedEvent");
        proceedEvent.setParams({
            "savedProducts": selectedProductIds,
            "legalEntity": legalEntity,
            "legalEntityName": legalEntityName
        });

        proceedEvent.fire();
        */
        component.set("v.lstProducts", []);
        var selectedProducts = component.get("v.lstProductsSelected");
        var selectedProductIds = [];
        var materialCodes = [];
        for (var key in selectedProducts) {
            selectedProductIds.push(selectedProducts[key].productId);
            materialCodes.push(selectedProducts[key].product.MaterialCode__c);
        }
        component.set("v.lstCurrentProductsSelected", selectedProductIds);
        
        var existingProductsInOppy = component.get("v.productsAlreadyInOppy");
        if (existingProductsInOppy != null && existingProductsInOppy.length > 0){
            console.log('Entered in Existing Products logic')
            for(var key in existingProductsInOppy){
           		selectedProductIds.push(existingProductsInOppy[key]);
        	}
        }
        component.set("v.lstMaterialCodes", materialCodes);
        component.set("v.lstProducts",selectedProductIds);
        component.set("v.isBack",true);
    },
    /*
    closeModal: function(component, event, helper) {
        var existingLE = component.get("v.existingLegalEntity");
        component.set("v.legalEntity", existingLE);
        component.set("v.openModal", false);
    },
    openModal: function(component, event, helper) {
        var existingLE = component.get("v.existingLegalEntity");
        console.log('--existingLE--' + existingLE);
        if (existingLE !== '--None--') {
            component.set("v.openModal", true);
            return;
        }
        helper.clearLists(component);
    },
    */
    onBack : function(cmp, event, helper) {
        var isBack = event.getParam("isBackPressed");
        cmp.set("v.isBack",false);
    },
    onIntBusiSegSelection: function(component, event, helper) {
        var intBusiSeg = component.get("v.internalBusinessSegment");
        if (intBusiSeg !== '--None--') { 
            var intBusSegment = component.get("v.internalBusinessSegment");
            component.set("v.businessLine", '--None--');
            component.set("v.lstBusinessLine", []);
        	var action = component.get("c.getAllBusLineOnIBSSelection");
            action.setParams({
                "intBusSegment": intBusSegment
            });

        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var result = response.getReturnValue();
                	if (result !== undefined && result !== null){
                    	component.set("v.lstBusinessLine", result);
                    	console.log(result);
                	}
            	}
            	else if (state == "Error") {
                	alert("An error has occured please contact Salesforce Helpdesk");
            	}
        	});
        	$A.enqueueAction(action);
            $A.enqueueAction(component.get('c.onFilterChange'));
        }
        else if(intBusiSeg === '--None--'){
            	component.set("v.businessLine", '--None--');
            	component.set("v.subBusinessLine", '--None--');
            	component.set("v.lstBusinessLine", []);
            	component.set("v.lstSubBusinessLine", []);
            	$A.enqueueAction(component.get('c.onFilterChange'));
        }
    },
    onBusLineSelection: function(component, event, helper) {
        var busiLine = component.get("v.businessLine");
        if (busiLine !== '--None--') {
            var intBusSegment = component.get("v.internalBusinessSegment");
            var busLine = component.get("v.businessLine");
            component.set("v.subBusinessLine", '--None--');
            component.set("v.lstSubBusinessLine", []);
        	var action = component.get("c.getAllSubBusLineOnBLSelection");
            action.setParams({
                "intBusSegment": intBusSegment,
                "busLine": busLine
            });

        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var result = response.getReturnValue();
                	if (result !== undefined && result !== null){
                    	component.set("v.lstSubBusinessLine", result);
                    	console.log(result);
                	}
            	}
            	else if (state == "Error") {
                	alert("An error has occured please contact Salesforce Helpdesk");
            	}
        	});
        	$A.enqueueAction(action);
            $A.enqueueAction(component.get('c.onFilterChange'));
        }
        else if(busiLine === '--None--'){
            	component.set("v.subBusinessLine", '--None--');
            	component.set("v.lstSubBusinessLine", []);
            	$A.enqueueAction(component.get('c.onFilterChange'));
        }
    }
    //SFDC-4730 Change End
})