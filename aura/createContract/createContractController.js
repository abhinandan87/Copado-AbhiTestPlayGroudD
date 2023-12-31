({
    doInit : function(component,event,helper) {
        //SFDC-4969 Change Start
        var action1 = component.get("c.getLegalEntityAndExceptionStatus");
		var oppyId = component.get("v.recordId");
        action1.setParams({
            "oppyId":oppyId
        });
        action1.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result.LegalEntity__c == null || result.ExceptionStatus__c == 'Exception Requested' || result.ExceptionStatus__c == 'Exception Request Denied'){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message":"You can't create a contract without a legal entity on Opportunity or until exception request is approved",
                        "mode":"dismissible",
                        "type":"error",
                        "duration":"3000"
                    });
                    toastEvent.fire();
                    return;
                }
                else{
        //SFDC-4969 Change End
        			helper.isCommunity(component);
        			helper.callToServer(
            			component,
            			"c.findRecordTypes",
            			function(response) {
                			var jsonObject=JSON.parse(response);
                			component.set('v.recordTypeList',jsonObject);  
                			component.set('v.selectedRecordType',jsonObject[0].recordTypeId); 
            			}, 
            			{ objName: component.get('v.objType'),oppId: component.get('v.recordId') }
        			); 
        			helper.callToServer(
            			component,
            			"c.setTrialRecordTypeId",
            			function(response) {
                			component.set('v.trialRecordTypeId',response);  
            			} 
        			);
        			helper.callToServer(
            			component,
            			"c.setConLetterRecordTypeId",
            			function(response) {
                			component.set('v.continuationRecTypeId',response);  
            			} 
        			);
        			helper.callToServer(
            			component,
            			"c.setContractStartDateFromOppty",
            			function(response) {
                			component.set('v.contractStartDateFromOppty',response);  
            			},
            			{ oppId: component.get('v.recordId') }
        			);    
        //SFDC-4969 Change Start        
                }
        	}
        });
        $A.enqueueAction(action1);
        //SFDC-4969 Change End
    },
     
    onChange : function(component, event, helper) {
		var value = event.getSource().get("v.text");
        component.set('v.selectedRecordType', value);
        document.getElementById("continueButton").disabled = false;
	},
	
    defaultCloseAction : function(component, event, helper) {
        $A.util.addClass(component, "slds-hide");
    },
	cancel : function(component,event,helper) {
        var oppyId = component.get("v.recordId");
        var navevent = $A.get("e.force:navigateToSObject");
        navevent.setParams({
            "recordId": oppyId,
            "slideDevName": "detail",
            "isredirect":true
        });
        navevent.fire();
    },
    create : function(component, event, helper) {
        var selectedRecType=component.get('v.selectedRecordType');
        var isNonProductSpecificRecordType = helper.getSelectedRecordTypeName(component);
        var leSection = component.get('v.isLegalEntitySection');
        document.getElementById("continueButton").disabled = true;
        if (isNonProductSpecificRecordType && !leSection) {
            //Get the all Legal entities and opportnuities legal entity
            helper.callToServer(
                component,
                "c.getActiveLegalEntityForOpp",
                function(response) {
                    component.set('v.legalEntityId', response);
                },
                { oppRecordId: component.get('v.recordId')} 
            );
            helper.callToServer(
                component,
                "c.getActiveLegalEntities",
                function(response) {
                    //disable the first section, Set legal entities and enable LE section
                    component.set('v.ismaincmp', false);
                    component.set('v.legalEntities', response);
                    component.set('v.isLegalEntitySection', true);
                    // Let DOM state catch up.
                    window.setTimeout(
                        $A.getCallback( function() {
                            // Now set value from opportunity
                            component.find("legalEntity").set("v.value", component.get('v.legalEntityId'));
                        }));
                },
                { recTypeId : selectedRecType} 
            );
        } else {
            //either Not required to select legal entity 
            //or already selected
            helper.callToServer(
                component,
                "c.findContractStartAndEndDate",
                function(response) {
                    if(response == "inactiveProductRelated") {
                        alert('A product related to this Opportunity is Not Available for Sale. Hence no contract can be created. Please remove the product prior to creating the contract.');
                    } else if(response == "NotAnOppTeamMember") {
                        alert('Only Opportunity Owner, Opportunity Team members, Sales Ops, Contract Management and Administrators can create a contract.');
                    } else if(response == "NotAnAuthorizedProfile") {
                        alert('You are not authorized to create a Contract.');
                    } else if(response == "NoExisitingProductOnOpportunity") {
                        alert('The opportunity should have at least one product with \'Existing\' status to create a Continuation Letter Contract.');
                    } else if(response == "contractDatesRequired") {
                        alert('In order to create a Contract, Populate Contract Start and End date on Opportunity');                
                    } else if(response == "orderFormAlreadyPresent") {
                        alert('An Order Form Contract is already related for this Opportunity. A new Order Form Contract cannot be created.');                
                    } else if(response == "NoContractingStage") {
                        alert('An Order Form can be created only when Opportunity is at Contracting Stage.');
                    } else if(response == "discountAttachmentNeeded") {
                        alert('You must have Discount Approval in order to create a Contract. Please obtain approval for the Discount on this Opportunity and save it in Opportunity Attachments.');
                    } else if(response == "noRenewalOppty") {
                        alert('A Continuation record cannot be created for a New Business Opportunity. Please check Opportunity Record');
                    } else if(response == "opptyNotSetToAutoRenewal") {
                        alert('An Auto-Renewal Opportunity is allowed a Continuation Letter ONLY if the selection "Does this Auto Renewal Have Changes?" is also selected. Please check the Opportunity Record.');
                    } else if(response == "noActiveContract") {
                        alert('The Opportunity has no Originating Contract OR Continuation letter associated to it');
                    } else if(response == "orderFormNotAllowedOnAutoRenewalWithoutChanges") {
                        alert('An Auto-Renewal Opportunity is allowed an Order Form contract ONLY if "Does this Auto Renewal Have Changes?" is also selected. Please check the Opportunity Record.');
                    }
                    /*
                    //SFDC1-10556 : Removing the 3 Day limit for Continuation Letters Contract Creation
                    else if(response == "3daysUnavailable") {
                        alert('The active contract ends in less than 3 Business days. Continuation Letter contract cannot be created. Please check with your System Administrator'); 
                    }
                    */
                    else if(response === "NoPrimaryContactOnOpportunity") {
                        alert('In order to create a Order Form, Opportunity should have a primary Contact.');
                    } else if(response === "NoProductOnOpportunity") {
                        alert('In order to create a Order Form, Opportunity should have a Product.');
                    } else if(response==='allLostProductOnOpportunity'){
                        alert('The opportunity has products that are marked as lost. Please correct the opportunity products to create the contract');
                    }else {
                        
                        var trialRecType = component.get('v.trialRecordTypeId');
                        var continuationRecType = component.get('v.continuationRecTypeId');
                        
                        if(selectedRecType != trialRecType && selectedRecType != continuationRecType) {
                            helper.callToServer (
                                component,
                                "c.createDefaultRecord",
                                function(response) {
                                    var jsonObject=response;               
                                    component.set('v.createdRecordId',jsonObject); 
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams ( {
                                        "recordId": jsonObject    
                                    } );
                                    navEvt.fire();
                                }, 
                                {
                                    rectype: component.get('v.selectedRecordType'),
                                    oppRecordId: component.get('v.recordId'),
                                    selectedLegalEntity: component.find("legalEntity").get("v.value")
                                }
                            );
                        } else if(selectedRecType == trialRecType) {
                            var isCommunity = component.get("v.isCommunity");
                            if(isCommunity) {
                                component.set("v.ismaincmp",false);
                                component.set("v.istrialRecType",true);
                            } else {
                                var evt = $A.get("e.force:navigateToComponent");
                                var oppyId = component.get("v.recordId");
                                evt.setParams({
                                    componentDef : "c:productsForTrialContract",
                                    componentAttributes:{
                                        oppyId :oppyId
                                    }
                                });
                                evt.fire();
                            }
                        } else if(selectedRecType == continuationRecType) {
                            var isCommunity = component.get("v.isCommunity");
                            if(isCommunity) {
                                component.set("v.ismaincmp",false);
                                component.set("v.iscontinuationRecType",true);
                            } else {
                                var evt = $A.get("e.force:navigateToComponent");
                                var oppyId = component.get("v.recordId");
                                var startDate = component.get("v.contractStartDateFromOppty");
                                evt.setParams({
                                    componentDef : "c:continuationLetterComponent",
                                    componentAttributes:{
                                        startDate :startDate,
                                        oppRecordId : oppyId,
                                    }
                                });
                                evt.fire();
                            }
                        }
                    }
                }, 
                { oppRecordId: component.get('v.recordId'),
                 rectype: component.get('v.selectedRecordType') }
            );
        }
    }
})