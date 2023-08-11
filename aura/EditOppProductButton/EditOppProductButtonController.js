({
    init : function(component, event, helper) {    
       /* var navService = component.find("navService");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__RedirectEditProductLWC'
            },
            state : {
                c__recordId : component.get('v.recordId'),
                c__actionname : component.get('v.quickActionName')
            }
        };        
         navService.navigate(pageReference);*/ 
    },
    handleRecordLoad : function(component,event,helper) {
        //SFDC-4731 Change Start
        var action = component.get("c.exceptionRequestCheck");
		var oppyId = component.get("v.recordId");
        action.setParams({
            "oppyId":oppyId
        });
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                if(result == 'Exception Requested'){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message":"You can't add/edit products until previous Exception Request is approved or denied",
                        "mode":"dismissible",
                        "type":"error",
                        "duration":"3000"
                    });
                    toastEvent.fire();
                    return;
                }
                else{
        //SFDC-4731 Change End
        			//first check if the record is loaded
        			let changeType = event.getParams().changeType;
        			//validate the record for access
        			switch (changeType) {
            			case "ERROR" :  component.set("v.hasError",true);
                			console.log('--error occurred--'+component.get("v.recordError"));
                			break;
            			case "LOADED": helper.checkRecordAccess(component,event) ;
                			break;
            			case "CHANGED": console.log('--record being saved--');
                			break;
            			default:console.log('--changeType--'+changeType);
        			}
        //SFDC-4731 Change Start        
                }
        	}
        });
        $A.enqueueAction(action);
        //SFDC-4731 Change End
    }
})