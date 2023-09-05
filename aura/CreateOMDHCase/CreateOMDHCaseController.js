({
	doInit : function(component, event, helper) {
        helper.callToServer(
            component,
            "c.getOMDHRecord",
            function(response) {
                component.set('v.recordTypeId', response.recordTypeId);
                component.set('v.caseRecord', response);
            }
        );
        helper.callToServer(
            component,
            "c.getContractDetails",
            function(response) {
                component.set('v.contractRecord', response);
            },
            { contractId: component.get('v.recordId') } 
        )
	},
    defaultCloseAction : function(component, event, helper) {
        helper.closeQuickAction (component);
    },
    handleSubmit : function (component, event, helper) {
        event.preventDefault();
        helper.validateFields(component, event);
        if (!component.get("v.errorExists")) {
            var cas = helper.populateCase(component, event);
            helper.callToServer(
                component,
                "c.saveOMDHCase",
                function(response) {
                    if(response === 'Case record created') {
                        helper.displayToast('Record created!',response, 'success'); 
                        helper.closeQuickAction (component);
                        helper.refreshView(component);
                    } else {
                        component.set('v.errorMessage',response);
                        component.set('v.errorExists',true);
                    }
                },
                { cas: cas } 
            )
        }
    }, 
    teamSelectChanged : function (component, event, helper) {
        //When team select is delivery then Continue buttom and SSO field should be enabled
        //Else Disable SSO field and Continue buttons. Enable Save button.
        var teamSelect = event.getParam("value");
        if(teamSelect === "Delivery") {
            component.set('v.isDeliverySelected', true);
        } else {
            component.set('v.isDeliverySelected', false);
        }
        //When team select is Retail then field DeliveryTeam__c should be enabled
        if(teamSelect==="Retail"){
            component.set('v.isRetailSelected',true);
        } else{
            component.set('v.isRetailSelected', false);
            }
        
    }, 
    handleContinue : function (component, event, helper) {
        event.preventDefault();
        helper.validateFields(component, event);
        if (!component.get("v.errorExists")) {
            var cas = helper.populateCase(component, event);
            component.set('v.caseRecord', cas);
            helper.callToServer(
                component,
                "c.getAvailableProductsForContract",
                function(response) {
                    console.log('product list'+response);
                    component.set('v.productList', response);
                    component.set('v.isMainCmp', false);
                    if($A.util.isEmpty(response)) {
                        component.set('v.isEmptyProducts', true);
                    } else {
                        component.set('v.isEmptyProducts', false);
                    }
                },
                { ContractId: component.get('v.recordId') } 
            )
        }
    },
    saveDeliveryCases : function (component, event, helper) { 
        var strSelectRecordIds=[];
        var values = component.get("v.productList"); 
        var valueInstance;
        for(var valueInstance in values) {
            if(values[valueInstance].isSelected == true)
                strSelectRecordIds.push(values[valueInstance]);
        }
        if (strSelectRecordIds.length > 0) {
            helper.callToServer(
                component,
                "c.createDeliveryCases",
                function(response) {
                    if(response === 'Cases are Created!') {
                        helper.displayToast('Record created!',response, 'success'); 
                        helper.closeQuickAction (component);
                        helper.refreshView(component);
                    } else {
                        component.set('v.errorMessage',response);
                        component.set('v.errorExists',true);
                    }
                },
                { cas: component.get('v.caseRecord'), wrapperJson: JSON.stringify(strSelectRecordIds)} 
            )
        } else {
            component.set('v.errorMessage','You must select a product or products in order to save the case');
            component.set('v.errorExists',true);
        }
    },
    toggleSelectAll : function(component,event) {
    //console.log('Entered Method');
    var selectAllVal = component.find("selectAll").get("v.checked");
    console.log('Selected value'+selectAllVal);
    //set all products as checked
    var values = [];
    values = component.get("v.productList"); 
    for(var valueInstance in values) {
        values[valueInstance].isSelected = selectAllVal;
    }
    component.set("v.productList",values);

    }
})