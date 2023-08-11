({
    callToServer : function(component, method, callback, params) {
        this.toggleSpinner(component);
        var action = component.get(method);
        if(params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.toggleSpinner(component);
                callback.call(this,response.getReturnValue());
            }
            else if(state === "ERROR") {
                this.toggleSpinner(component);
                var errors = response.getError();
                this.displayToast('Error',errors[0].message, 'Error');
            }
        });
        $A.enqueueAction(action);
    }, 
    closeQuickAction : function (component) {
        $A.get("e.force:closeQuickAction").fire();
    },
    validateFields : function (component, event) {
        var errorExists = false;
        var errorMsg = 'These required fields must be completed:';
        if ($A.util.isEmpty(component.find("description").get("v.value")) || 
            $A.util.isEmpty(component.find("description").get("v.value").trim())) {
            errorExists = true;
            errorMsg += ' Description,'
        }
        if ($A.util.isEmpty(component.find("subject").get("v.value"))|| 
            $A.util.isEmpty(component.find("subject").get("v.value").trim())) {
            errorExists = true;
            errorMsg += ' Subject,'
        }
        if ($A.util.isEmpty(component.find("teamSelect").get("v.value")) || 
            $A.util.isEmpty(component.find("teamSelect").get("v.value").trim())) {
            errorExists = true;
            errorMsg += ' Team Select,'
        }
          
            if (component.find("teamSelect").get("v.value") === 'Retail' && 
              ($A.util.isEmpty(component.find("deliveryTeam").get("v.value")) || 
                $A.util.isEmpty(component.find("deliveryTeam").get("v.value").trim()))) {
               errorExists = true;
               errorMsg += ' Delivery Team,'
           }
        if(errorExists) {
            errorMsg = errorMsg.substring(0, errorMsg.length - 1);
            component.set('v.errorMessage',errorMsg);
        } else {
            component.set('v.errorMessage','');
        }
        component.set('v.errorExists',errorExists);
    }, 
    populateCase : function (component, event) {
        var cas = component.get('v.caseRecord');
        var ctrct = component.get('v.contractRecord');
        cas.Subject = component.find("subject").get("v.value");
        cas.Description = component.find("description").get("v.value");
        cas.TeamSelect__c = component.find("teamSelect").get("v.value");
        var teamSelect = component.find("teamSelect").get("v.value");
        if (teamSelect === 'Delivery') {
            cas.SingleSignOnSAM__c = component.find("SSOSam").get("v.value");
        } else {
            cas.SingleSignOnSAM__c = false;
        }
        cas.DeliveryTeam__c=component.find("deliveryTeam").get("v.value");
        cas.OrderManagementRegion__c = component.find("OMRegion").get("v.value");
        cas.OMRootCause__c = component.find("OMRootCause").get("v.value");
        cas.Type = component.find("Type").get("v.value");
        cas.Contract__c = ctrct.Id;
        cas.AccountId = ctrct.AccountId;
        cas.AccountReference__c =ctrct.AccountId;
        return cas;
    }, 
    displayToast : function(title, message, typeOfToast) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": typeOfToast
        });
        toastEvent.fire();
    },
    toggleSpinner : function(component) {
        var spinner = component.find("spinner");
        $A.util.toggleClass(spinner, "slds-hide");
        $A.util.toggleClass(spinner, "slds-show");
    },
    refreshView : function() {
        return new Promise($A.getCallback(function(resolve, reject) {
            //To refresh the view
            $A.get('e.force:refreshView').fire();
            resolve(true); 
        }));
    },
})