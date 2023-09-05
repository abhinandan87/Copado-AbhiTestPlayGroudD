({
    init: function (component, event, helper) {
        component.set('v.initLoad', true);
        helper.fetchCurrentUser(component, event, helper);
        //helper.checkUserPermission(component, event, helper);
        helper.fetchTaskPriorityValues(component, event, helper);
        helper.fetchTaskStatusValues(component, event, helper);
        helper.fetchActivitySubTypeValues(component, event, helper);
        setTimeout(function () {
            var utilityBarAPI = component.find("utilitybar");
            var eventHandler = function (response) {
				if(component.get('v.recordId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId').startsWith("00U")){
                    console.log('Disabling event creation when on event page');
                    component.set('v.onEventPage',true);
                    component.set('v.selectedType', 'Task');
                }
                else{
                    component.set('v.onEventPage',false);
                }
                component.set('v.addMoreDetail',false);
                component.set('v.disableButton',false);
                component.set('v.disableButton1',false);
                if(component.get('v.contactId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId')!=undefined && component.get('v.contactId')==component.get('v.recordId') && !component.get('v.justSaved')) {
                    console.log('Do not refresh the component when on contact page');
                }	
                else if(component.get('v.accId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId')!=undefined && component.get('v.accId')==component.get('v.recordId') && !component.get('v.justSaved')) {
                    console.log('Do not refresh the component when on account page');
                }
                    else if(component.get('v.oppId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId')!=undefined && component.get('v.oppId')==component.get('v.recordId') && !component.get('v.justSaved')) {
                        console.log('Do not refresh the component when on opportunity page');
                    }
                        else if(component.get('v.recordId')!=undefined && component.get('v.recordId')!=null){
                            if(component.get('v.recordId').startsWith("00U")){
                                /*if(!component.get('v.justSaved') && component.get('v.eventWhatId')!='' && (component.get('v.accId')==component.get('v.eventWhatId') || component.get('v.oppId')==component.get('v.eventWhatId')) && component.get('v.recordId')==component.get('v.eventWhatId')){
                                    console.log('Do not refresh the component when on event page');
                                }
                                else{*/
                                    component.set('v.showSpinner',true);
                                    console.log('Event logic..');
                                    helper.clearFields(component, event, helper);
                                    helper.fetchEventWhatId(component, event, helper);
                               // }
                            }
                            else if(component.get('v.recordId').startsWith("00T")){
                                /*if(!component.get('v.justSaved') && component.get('v.taskWhatId')!='' && (component.get('v.accId')==component.get('v.taskWhatId') || component.get('v.oppId')==component.get('v.taskWhatId')) && component.get('v.recordId')==component.get('v.taskWhatId')){
                                    console.log('Do not refresh the component when on contact page');
                                }
                                else{*/
                                    component.set('v.showSpinner',true);
                                    console.log('Task logic..');
                                    helper.clearFields(component, event, helper);
                                    helper.fetchTaskWhatId(component, event, helper);
                              //  }
                            }
                                else{
                                    helper.clearFields(component, event, helper);
                                    helper.fetchLookupInfo(component, event, helper);
                                }
                            
                        }
                            else{
                                helper.clearFields(component, event, helper);
                                helper.fetchLookupInfo(component, event, helper);
                            }
            }
            utilityBarAPI.onUtilityClick({
                eventHandler: eventHandler
            }).then(function (result) {
                console.log(result);
            }).catch(function (error) {
                console.log(error);
            });
        }, 1);
    },
    handleSaveRecord: function(component, event, helper) {
        component.set('v.disableButton',true);
        component.set('v.disableButton1',true);
        component.set('v.showSpinActivity',true);
        if(component.get('v.selectedType')=='Meeting'||component.get('v.selectedType')=='Call'){
            helper.handleSaveEvent(component, event, helper);
        }
        if(component.get('v.selectedType')=='Task'){
            helper.handleSaveTask(component, event, helper);
        }
    },
    fetchAccountId : function(component,event,helper) {
        console.log('Contact ID changed-->'+component.get('v.contactId'));
        console.log('Account ID changed-->'+component.get('v.accId'));
        console.log('Opportunity ID changed-->'+component.get('v.oppId'));
        console.log('User ID changed-->'+component.get('v.userId'));
        if(component.get('v.accId')==='' || component.get('v.accId')===null){
            component.set('v.accRecord',null);
        }
        if(component.get('v.oppId')==='' || component.get('v.oppId')===null){
            component.set('v.oppRecord',null);
        }
        if(component.get('v.contactId')==='' || component.get('v.contactId')===null){
            component.set('v.contactRecord',null);
        }
    },
    validateRelatedTo : function(component,event,helper) {
        if(component.get('v.selectedRelatedToType')=='Account' && component.get('v.recordId')!=null && (!component.get('v.recordId').startsWith("006") && !component.get('v.eventWhatId').startsWith("006") && !component.get('v.taskWhatId').startsWith("006"))){
            component.set('v.oppId','');
            component.set('v.oppRecord',null);
        } 
        if(component.get('v.selectedRelatedToType')=='Opportunity' && component.get('v.recordId')!=null && (!component.get('v.recordId').startsWith("001") && !component.get('v.eventWhatId').startsWith("001") && !component.get('v.taskWhatId').startsWith("001"))){
            component.set('v.accId','');
            component.set('v.accRecord',null);
        }
    },
    handleAddMoreDetail : function(component,event,helper) {
        component.set('v.addMoreDetail',true);
        component.set('v.disableButton',true);
        component.set('v.disableButton1',true);
        component.set('v.showSpinActivity',true);
        if(component.get('v.selectedType')=='Meeting'||component.get('v.selectedType')=='Call'){
            helper.handleSaveEvent(component, event, helper);
        }
    },
    handleEventEndTime : function(component,event,helper) {
        if(component.get('v.eventStartTime')!=undefined && component.get('v.eventStartTime')!=null){
            var enddateValue = new Date(component.get('v.eventStartTime'));
            enddateValue.setMinutes(enddateValue.getMinutes()+60);
            component.set("v.eventEndTime", enddateValue.toISOString());
        }
    }
})