({
	doInit : function(component, event, helper) {
        var oppyId = component.get("v.oppyId");
        var selectedProducts = component.get("v.lstProductsSelected");
        var action = component.get("c.productSelectionRuleEngine");
        action.setParams({
            "oppyId": oppyId,
            "lstProducts": selectedProducts
        });

        action.setCallback(this, function(response) {
            var toastEvent = $A.get("e.force:showToast");
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result !== undefined && result !== null){
                    component.set("v.lstRecommendedLegalEntity", result.lstRecommendedLegalEntity);
                    component.set("v.recommendedLegalEntity", result.recommendedLegalEntity);
                    if(result.result!="SUCCESS"){
                        toastEvent.setParams({
                                "title": "Error!",
                                "message":result.errorMessage,
                                "mode":"sticky",
                                "type":"error",
                                "duration":"3000"
							});
                    }
                    toastEvent.fire();
                    console.log(result);
                }
            }
            else if (state == "Error") {
                alert("An error has occured please contact Salesforce Helpdesk");
            }
        });
        $A.enqueueAction(action);
	},
    
    onChange : function(component, event, helper) {
        var isCheck = event.getSource().get('v.checked')
        component.set("v.isCheck",isCheck);
        if(isCheck==true){
            component.set("v.recommendedLegalEntity", '--None--');
            component.set("v.isException",true);
            var oppyId = component.get("v.oppyId");
        	var selectedProducts = component.get("v.lstProductsSelected");
        	var action = component.get("c.getListLegalEntity");
        	action.setParams({
            	"lstProducts": selectedProducts
        	});

        	action.setCallback(this, function(response) {
                var toastEvent = $A.get("e.force:showToast");
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var result = response.getReturnValue();
                	if (result !== undefined && result !== null){
                    	component.set("v.lstRequestedLegalEntity", result.lstRecommendedLegalEntity);
                        if(result.result!="SUCCESS"){
                        	toastEvent.setParams({
                                "title": "Error!",
                                "message":result.errorMessage,
                                "mode":"dismissible",
                                "type":"error",
                                "duration":"3000"
							});
                    	}
                    	toastEvent.fire();
                    	console.log(result);
                	}
            	}
            	else if (state == "Error") {
                	alert("An error has occured please contact Salesforce Helpdesk");
            	}
        	});
        	$A.enqueueAction(action);
            
            var action2 = component.get("c.getOppCountry"); 
            action2.setParams({
            	"opportunityId": oppyId
        	});

        	action2.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var result = response.getReturnValue();
                	if (result !== undefined && result !== null){
                    	component.set("v.countryTerritory", result);
                    	console.log(result);
                	}
            	}
            	else if (state == "Error") {
                	alert("An error has occured please contact Salesforce Helpdesk");
            	}
        	});
        	$A.enqueueAction(action2);
            
            var lstMatCodes = component.get("v.lstMaterialCodes");
            var matCode = '';
            for(var key in lstMatCodes){
                matCode += lstMatCodes[key] + ', ';
            }
            matCode = matCode.replace(/,\s*$/, "");
            component.set("v.materialCodes", matCode);
        }
        else{
            component.set("v.requestReason", '');
            component.set("v.dollarValue", '');
            component.set("v.isException",false);
            var oppyId = component.get("v.oppyId");
        	var selectedProducts = component.get("v.lstProductsSelected");
        	var action = component.get("c.productSelectionRuleEngine");
        	action.setParams({
            	"oppyId": oppyId,
            	"lstProducts": selectedProducts
        	});

        	action.setCallback(this, function(response) {
                var toastEvent = $A.get("e.force:showToast");
            	var state = response.getState();
            	if (state === "SUCCESS") {
                	var result = response.getReturnValue();
                	if (result !== undefined && result !== null){
                    	component.set("v.lstRecommendedLegalEntity", result.lstRecommendedLegalEntity);
                    	component.set("v.recommendedLegalEntity", result.recommendedLegalEntity);
                        if(result.result!="SUCCESS"){
                        	toastEvent.setParams({
                                "title": "Error!",
                                "message":result.errorMessage,
                                "mode":"dismissible",
                                "type":"error",
                                "duration":"3000"
							});
                    	}
                    	toastEvent.fire();
                    	console.log(result);
                	}
            	}
            	else if (state == "Error") {
                	alert("An error has occured please contact Salesforce Helpdesk");
            	}
        	});
        $A.enqueueAction(action);
        }
    },
    
    onProceed : function(component, event, helper) {
        var selectedProductsIds = component.get("v.lstCurrentProductsSelected");
        var legalEntity = component.get("v.recommendedLegalEntity");
        var legalEntityName = '';
        var lstLegalEntity = component.get("v.lstRecommendedLegalEntity");
        for (var key in lstLegalEntity) {
            if (lstLegalEntity[key].Id === legalEntity) {
                legalEntityName = lstLegalEntity[key].Name;
                break;
            }
        }
        var oppyId = component.get("v.oppyId");
        var changeLegalEntityCheck = component.get("v.isChangeLegalEntity");
        var productsRemovedCheck = component.get("v.productsRemoved");
        if(changeLegalEntityCheck == true || productsRemovedCheck == true){
            var action = component.get("c.updateLegalEntityOnOppy");
        		action.setParams({
            		"opportunityId": oppyId,
            		"legalEntity": legalEntity
        		});

        		action.setCallback(this, function(response) {
            		var state = response.getState();
                    var toastEvent = $A.get("e.force:showToast");
            		if (state === "SUCCESS") {
                		var result = response.getReturnValue();
                		if (result !== undefined && result !== null){
                        	toastEvent.setParams({
	                    		"title": "Record updated!",
    	                		"message":result,
        	            		"mode":"dismissible",
            	        		"type":"success",
                	    		"duration":"3000"
                			});
                        	toastEvent.fire();
                            if(changeLegalEntityCheck == true){
                				var oppyId = component.get("v.oppyId");
                				var navEvt = $A.get("e.force:navigateToSObject");
                				navEvt.setParams({
                    				"recordId": oppyId,
                    				"slideDevName": "detail",
                    				"isredirect":true
                				});
                				$A.get('e.force:refreshView').fire();
                				navEvt.fire();
                            }
                            else if(productsRemovedCheck == true){
                                var modalCloseEvt = component.getEvent("modalCloseEvent");
 								modalCloseEvt.fire();
                            }
                        	console.log(result);
                        }
            		}
            		else if (state == "Error") {
                		alert("An error has occured please contact Salesforce Helpdesk");
	            	}
        		});
       			$A.enqueueAction(action);
        }
        else{		
        	var proceedEvent = component.getEvent("proceedEvent");
        	proceedEvent.setParams({
            	"savedProducts": selectedProductsIds,
            	"legalEntity": legalEntity,
            	"legalEntityName": legalEntityName
        	});
        	proceedEvent.fire();
        }
	},
    
    proceed : function(component, event, helper) {
        var selectedProdIds = event.getParam("savedProducts");
        component.set("v.selectedProductIds",selectedProdIds);
        var legalEntity = event.getParam("legalEntity");
        component.set("v.legalEntity",legalEntity);
        var legalEntityName = event.getParam("legalEntityName");
        component.set("v.legalEntityName",legalEntityName);
        var oppyId = component.get("v.oppyId");
        component.set("v.isBack",true);
    },
    
    onBack : function(component, event, helper) {
        var backEvent = component.getEvent("onBackEvent");
        backEvent.setParams({"isBackPressed" : true});
        backEvent.fire();   
	},
    
    back : function(component, event, helper) {
        var isBack = event.getParam("isBackPressed");
        component.set("v.isBack",false);
    },
    
    onSave : function(component, event, helper) {
        var returnMessage = '';   //SFDC-5126 Change
        var spinner = component.find("loadSpinner");
        $A.util.toggleClass(spinner, "slds-show");
        var save = component.find("save");
        save.set("v.disabled",true);
        var selectedProductsIds = component.get("v.lstCurrentProductsSelected");
        var oppyId = component.get("v.oppyId");
        var reason = component.get("v.requestReason");
        var legalEntity = component.get("v.requestedLegalEntity");
        var dollar = component.get("v.dollarValue");
        var country = component.get("v.countryTerritory");
        var matCodes = component.get("v.materialCodes");
        var reqLegalEntityName = '';
        var lstLegalEntity = component.get("v.lstRequestedLegalEntity");
        for (var key in lstLegalEntity) {
            if (lstLegalEntity[key].Id === legalEntity) {
                reqLegalEntityName = lstLegalEntity[key].Name;
                break;
            }
        }
        var changeLegalEntityCheck = component.get("v.isChangeLegalEntity");
        var productsRemovedCheck = component.get("v.productsRemoved");
        var toastEvent = $A.get("e.force:showToast");
        if(reason!=null && legalEntity!='--None--' && dollar!=null && country!=null && matCodes!=null){
        	var action = component.get("c.saveProductsOnOpportunity");
        	action.setParams({
            	"lstProductIds": selectedProductsIds,
            	"opportunityId" :  oppyId,
            	"legalEntity" : legalEntity,
            	"changeLegalEntityCheck": changeLegalEntityCheck,
                "productsRemovedCheck": productsRemovedCheck
        	});
        	action.setCallback(this, function(response) {
        		var toastEvent = $A.get("e.force:showToast");
            	if (response.getState() == 'SUCCESS') {
                	var result = response.getReturnValue();
                	var message = result;
                	console.log("message=>"+message);
                    //SFDC-5126 Change Start
                    var returnMessage = result;
                    if(returnMessage.indexOf("successfully")!==-1) {
            			var oppyId = component.get("v.oppyId");
                        var lstProductsAdded = component.get("v.lstProductsAdded");  //SFDC-5500 Change: List of products from Edit Product Screen
        				var action5 = component.get("c.exceptionApprovalEmail");
        				action5.setParams({
            				"opportunityId": oppyId,
            				"requestReason": reason,
            				"requestedLegalEntity": reqLegalEntityName,
            				"dollarValue": dollar,
            				"countryTerritory": country,
            				"materialCodes": matCodes,
                            "lstProductsAdded": JSON.stringify(lstProductsAdded)   //SFDC-5500 Change: List of products from Edit Product Screen
        				});

        				action5.setCallback(this, function(response) {
            				var state = response.getState();
            				if (state === "SUCCESS") {
                				var result = response.getReturnValue();
                				if (result !== undefined && result !== null) {
                    				console.log(result);
                				}
            				}
            				else if (state == "Error") {
                				alert("An error has occured please contact Salesforce Helpdesk");
	            			}
        				});
            			$A.enqueueAction(action5);
                    }
                    //SFDC-5126 Change End
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
                	if(changeLegalEntityCheck!=true || productsRemovedCheck!=true){
                	toastEvent.setParams({
	                    "title": "Record created!",
    	                "message":result,
        	            "mode":"dismissible",
            	        "type":"success",
                	    "duration":"3000"
                    
                	});
                	}
                	else{
                    	toastEvent.setParams({
	                    "title": "Record updated!",
    	                "message":result,
        	            "mode":"dismissible",
            	        "type":"success",
                	    "duration":"3000"
                    
                	});
                	}
                    toastEvent.fire();
                    if(productsRemovedCheck != true){
                		var oppyId = component.get("v.oppyId");
                		var navEvt = $A.get("e.force:navigateToSObject");
                		navEvt.setParams({
                    		"recordId": oppyId,
                    		"slideDevName": "detail",
                    		"isredirect":true
                		});
                		$A.get('e.force:refreshView').fire();
                		navEvt.fire();
                    }
                    else{
                        var modalCloseEvt = component.getEvent("modalCloseEvent");
 						modalCloseEvt.fire();
                    }
    	        } else {
                var result = response.getReturnValue();
                console.log("message=>"+result);
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
        
        //SFDC-5126 Change Start
        /*var action5 = component.get("c.exceptionApprovalEmail");
        		action5.setParams({
            		"opportunityId": oppyId,
            		"requestReason": reason,
            		"requestedLegalEntity": reqLegalEntityName,
            		"dollarValue": dollar,
            		"countryTerritory": country,
            		"materialCodes": matCodes
        		});

        		action5.setCallback(this, function(response) {
            		var state = response.getState();
            		if (state === "SUCCESS") {
                		var result = response.getReturnValue();
                		if (result !== undefined && result !== null){
                    		console.log(result);
                		}
            		}
            		else if (state == "Error") {
                		alert("An error has occured please contact Salesforce Helpdesk");
	            	}
        		});
       			$A.enqueueAction(action5);*/
            //SFDC-5126 Change End
        }
        else{
        	toastEvent.setParams({
            	"title": "Oops!",
                "message":"Please fill all the mandatory fields",
                "mode":"dismissible",
                "type":"error",
                "duration":"3000"
            });
            toastEvent.fire();
        	$A.util.toggleClass(spinner, "slds-show");
        	save.set("v.disabled",false);
        	return;
        }
        $A.util.toggleClass(spinner, "slds-hide");
        save.set("v.disabled",false);
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
    }
})