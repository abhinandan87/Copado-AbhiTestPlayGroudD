({
    getData: function(component, page) {
        this.showSpinner(component);
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
        var queryColumns = component.get("v.queryColumns");
        var orderBy = component.get("v.orderBy");
        var filter = component.get("v.filter");
        var fieldTransformationRules = component.get("v.fieldTransformationRules");

   
        var action = component.get("c.fetchData");
        action.setParams({
            infoJSON : JSON.stringify({
                        "pageNumber": page,
                        "recordToDisplay": recordToDisplay,
                        "objectType" : objectType,
                        "parentRecordId": parentRecordId,
                        "parentField": parentField,
                        "queryColumns": queryColumns,
                        "filter": filter,
                        "orderBy": orderBy,
                        "recordId": null
            })
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var data=result.data;
                var rules=JSON.parse(fieldTransformationRules);
                
                rules.forEach(function (transformationRule) {
                   
                    data.map(function(dataRow){
                        if( transformationRule.hasOwnProperty('urlTargetField') ){
                            if(dataRow[transformationRule.urlTargetField]!==undefined){
                                dataRow[transformationRule.fieldName+'Url']='/'+dataRow[transformationRule.urlTargetField];
                            }
                        }

                        if( transformationRule.hasOwnProperty('sourceField')){
                            var relation = transformationRule.sourceField.split('.');
                            if( dataRow.hasOwnProperty(relation[0])){
                                dataRow[transformationRule.fieldName] = dataRow[relation[0]][relation[1]];
                            }
						}
                        if( transformationRule.hasOwnProperty('toolTipField')){
                            if(transformationRule.toolTipField.includes('.')){
                                var relation = transformationRule.toolTipField.split('.');
                                if( dataRow.hasOwnProperty(relation[0])){
                                    dataRow[transformationRule.fieldName+'ToolTip'] = dataRow[relation[0]][relation[1]];
                                }
                            }
                            else{
                                dataRow[transformationRule.fieldName+'ToolTip']= dataRow[transformationRule.fieldName];
                            }
						}
                    })
                    
                });
                console.log(JSON.stringify(data));
                component.set("v.data", data);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisplay));
                this.hideSpinner(component);
            } else if (state === "ERROR") {
                this.handleResponseError(response.getError());
                
            }
        });
        $A.enqueueAction(action);
    },
    fetchReportId: function(component,page) {
       
        	var reportNameInput=component.get("v.reportName");
    	
        	var action = component.get("c.fetchReportId");
        	action.setParams({
            	reportName : reportNameInput});
        
     		action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var reportId = response.getReturnValue();
                    component.set("v.reportId", reportId);
                }
                else if (state === "ERROR") {
                    this.handleResponseError(response.getError());
                }
                console.log('The report Id is-->'+component.get("v.reportId"));
            });
        	$A.enqueueAction(action);
        
    },
    
    delete: function (component, page, recordId) {
        this.showSpinner(component);
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
        var action = component.get("c.deleteRecord");
        action.setParams({
            infoJSON : JSON.stringify({
                "pageNumber": page,
                "recordToDisplay": recordToDisplay,
                "objectType" : objectType,
                "parentRecordId": parentRecordId,
                "parentField": parentField,
                "recordId": recordId
            })
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.data", result.data);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisplay));
                this.hideSpinner(component);
                this.showToast(component, 'success', 'Object was deleted.');
            } else if (state === "ERROR") {
                //this.handleResponseError(response.getError());
                this.displayToast('Error',response.getError(), 'Error');
            }
        });
        $A.enqueueAction(action);
    },

    sortData: function (component, fieldName, sortDirection) {
        this.showSpinner(component);
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
        this.hideSpinner(component);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    showSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    showToast : function(component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Related List Message',
            message: message,
            duration:' 3000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },

    handleResponseError: function (helper, errors) {
        console.log('Getting into error handling');
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showToast(component, 'error', "Error message: " +
                    errors[0].message);
            }
        } else {
            this.showToast(component, 'error', 'Unknown error.');
        }
        this.hideSpinner(component);
    }
        
})