({
    init: function (component, event, helper) {
        if(component.get('v.objectType')=='Opportunity'){
            component.set('v.selectedBudget', "--None--");
            helper.fetchBudgetValues(component, event, helper);  
        }
        if(component.get('v.objectType')=='Contact'){
            component.set('v.selectedBusiness', "--None--");
            component.set('v.selectedJobTitle', "--None--");
            component.set('v.selectedJobFunction', "--None--");
            component.set('v.selectedGroupDesk', "--None--");
            helper.fetchBusinessSegment(component, event, helper);
            helper.fetchJobTitle(component, event, helper);
            helper.fetchJobFunction(component, event, helper);
            helper.fetchGroupDesk(component, event, helper);
        }
        setTimeout(function () {
            var utilityBarAPI = component.find("utilitybar");
            var eventHandler = function (response) {
                component.set('v.disableButton',false);
                if(component.get('v.accId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId')!=undefined && component.get('v.accId')==component.get('v.recordId') && !component.get('v.justSaved')) {
                    console.log('Do not refresh the component');
                }	
                else{
                    component.set('v.accId',null);
                    component.set('v.currentRecord',null);
                    component.set('v.fname',null);
                    component.set('v.mname',null);
                    component.set('v.lname',null);
                    component.set('v.phone',null);
                    component.set('v.email',null);
                    component.set('v.title',null);
                    component.set('v.selectedBusiness',"--None--");
                    component.set('v.selectedJobTitle',"--None--");
                    component.set('v.selectedJobFunction',"--None--");
                    component.set('v.selectedGroupDesk',"--None--");
                    component.set('v.oppyName',null);
                    component.set('v.closeDate','');
                    component.set('v.selectedBudget', "--None--");
                    helper.showSpinner(component);
                    helper.checkUserPermission(component, event, helper);
                }
            }
            utilityBarAPI.onUtilityClick({
                eventHandler: eventHandler
            }).then(function (result) {
                console.log(result);
            }).catch(function (error) {
                console.log(error);
            });
            /*utilityBarAPI.isUtilityPoppedOut({
            }).then(function (result) {
                if(component.get('v.objectType')=='Opportunity'){
                    component.set('v.selectedBudget', "--None--");
                    helper.fetchBudgetValues(component, event, helper);
                }
                helper.showSpinner(component);
                helper.checkUserPermission(component, event, helper);
            });*/
        }, 1);
    },
    handleSaveRecord: function(component, event, helper) {
        component.set('v.disableButton',true);
        if(component.get('v.objectType')=='Contact'){
            component.set('v.showSpinContact',true);
            helper.handleSaveContact(component, event, helper);
        }
        if(component.get('v.objectType')=='Opportunity'){
            component.set('v.showSpinOppy',true);
            helper.handleSaveOpportunity(component, event, helper);
        }
    },
    fetchAccountId : function(component,event,helper) {
        console.log('Account ID changed-->'+component.get('v.accId'));
    }
})