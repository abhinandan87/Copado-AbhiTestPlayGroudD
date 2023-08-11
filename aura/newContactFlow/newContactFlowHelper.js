({
	fetchRecordInfo : function(component, event, helper) {
        try{
            this.showSpinner(component, event, helper);
            console.log('Getting into newContactFlow helper method');
            component.set('v.justSaved',false);
            var recordId= component.get('v.recordId');
            var action = component.get("c.fetchSObjectfields");
            if (recordId !== null && recordId !== undefined && recordId.startsWith("001")) {
                component.set('v.accId', recordId);
                action.setParams({ "recordString" : recordId });
            }
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set('v.currentRecord', response.getReturnValue());
                    if (recordId == null || recordId == undefined || !recordId.startsWith("001")) {	
                    	component.set('v.accId', null);
                	}
                    this.hideSpinner(component, event, helper);
                }else if(state === "ERROR") {
                    console.log('An error has occurred.'+response.getError());
                }
                
            });
            $A.enqueueAction(action);
        }catch(error){
            console.log(error);
        }
    },
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        component.set('v.showSpinner',true);
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        component.set('v.showSpinner',false);
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
})