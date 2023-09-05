({
    handleRecordAction : function(component,event,helper) {
        let changeType = event.getParams().changeType;
        console.log('--event get params--'+JSON.stringify(event.getParams()));
        //console.log('--changeType--'+changeType);
        //console.log('--Opportunity Id--'+component.get('v.recordId'));
        console.log('--loaded record--'+JSON.stringify(component.get("v.opportunityObject")));
        switch (changeType) {
            case "ERROR" :  component.set("v.hasError",true);
                component.set("v.hasRecordLoaded",true);
                component.set("v.errorMessage","Oops! an error occured while loading this page"+component.get("v.recordError"));
                break;
            case "LOADED": helper.validate(component,event) ;
                break;
            case "CHANGED": console.log('--record being saved--');
                break;
            default:console.log('--changeType--'+changeType);
        }
    },
    handleSave : function(component,event,helper) {
            component.set("v.showSpinner",true);
            let amendType = component.get("v.renewalAmendType");
            console.log('==amendtype=='+amendType);
            let successMessage = '';
            if(amendType==='PriceChange') {
                component.set("v.opportunityObject.PriceChangeOnly__c",true);
                component.set("v.opportunityObject.DoesThisAutoRenewalHaveChanges__c",false);
                successMessage = $A.get("$Label.c.SuccessMsgOption1");
            }
        	else if(amendType==='FullChange') {
                component.set("v.opportunityObject.DoesThisAutoRenewalHaveChanges__c",true);
                component.set("v.opportunityObject.PriceChangeOnly__c",false);
                successMessage = $A.get("$Label.c.SuccessMsgOption2");
            }
        	let oppyRecord = component.get("v.opportunityObject");
        	console.log('--oppyRecordId--'+JSON.stringify(oppyRecord));
            var action = component.get("c.updateOppy");
            action.setParams({oppy:oppyRecord});
            action.setCallback(this,function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    if(response.getReturnValue()==='success') {
                        component.find("oppyRecordId").reloadRecord(true); 
                        helper.showToast('Success!!',successMessage,'success');
                        
                        //$A.get('e.force:refreshView').fire();
                    } else {
                        helper.showToast('Error!!','There is a problem saving record '+response.getReturnValue(),'error');
                    }
                    
                } 
                else if(state === "INCOMPLETE") {
                    helper.showToast('Warning!!','Please check your internet connection','info');
                } 
                else if(state === "ERROR") {
                    var errors = response.getError();
                    if(errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                            helper.showToast('Error!!','There is a problem saving record '+errors[0].message,'error');
                        }
                    } else {
                        console.log("Unknown error");
                        helper.showToast('Error!!','Unknown problem occurred','error');
                    }
                }
                component.set("v.showSpinner",false);
                helper.closeModal(component,event);
            });
            $A.enqueueAction(action);
        },
    handleCancel : function(component,event,helper) {
        helper.closeModal(component,event);
    },
    validateRadioChange : function(component,event,helper) {
        var radioButton = event.getSource();
        radioButton.setCustomValidity();
        radioButton.reportValidity();
        let radioValue = event.getParam("value");
        let hasError= false;
        console.log('==value=='+radioValue);
        let loadedOpportunity = component.get("v.opportunityObject");
        if(radioValue==='PriceChange') {
            //validate the scenarios related to originating contract            
            if(loadedOpportunity.ContractBeingRenewed__c===null || loadedOpportunity.ContractBeingRenewed__c===undefined) {
                //set the error message on the radio button
                radioButton.setCustomValidity($A.get("$Label.c.MissingOriginatingContract"));
                hasError = true;  
            }
            else if(loadedOpportunity.ContractBeingRenewed__r.PriceIncreaseClause__c!==null && loadedOpportunity.ContractBeingRenewed__r.PriceIncreaseClause__c!==undefined && loadedOpportunity.ContractBeingRenewed__r.PriceIncreaseClause__c.indexOf("No Increase Allowed")>-1) {
                radioButton.setCustomValidity($A.get("$Label.c.ContractNoIncreaseAllowed"));
                hasError = true;
            }
                else if(loadedOpportunity.ContractBeingRenewed__r.ContractStatus__c.indexOf("Validated")<0 && loadedOpportunity.ContractBeingRenewed__r.ContractStatus__c != 'Delivered to Customer') {
                radioButton.setCustomValidity($A.get("$Label.c.OriginatingContractNotValidated"));
                hasError = true;
            }/* 
            else if(loadedOpportunity.SourceSystem__c === 'SAP' && loadedOpportunity.RecordType.Name==='Renewal') {
                radioButton.setCustomValidity($A.get("$Label.c.SAPAutoRenewal"));
                hasError = true;
            }*/  
        } else if(radioValue === 'FullChange') {
            if(loadedOpportunity.RecordType.Name === 'Inner Year') {
                radioButton.setCustomValidity($A.get("$Label.c.InnerYearWithChange"));
                hasError = true;
            }
        }
        if(hasError) {
            radioButton.reportValidity();
            component.set("v.renewalAmendType",'');
        }
         
    },
    doInit : function(component,event,helper) {
        let option1 = {label:$A.get("$Label.c.PriceChangeFirstOption"),value:"PriceChange"};
        let options = [];
        options.push(option1);
        let option2 = {label:$A.get("$Label.c.PriceChangeSecondOption"),value:"FullChange"};
        options.push(option2);
        component.set("v.options",options);
    }
})