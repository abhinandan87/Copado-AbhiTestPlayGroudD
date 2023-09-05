({
	doInit : function(component, event, helper) {
        //SFDC-4731 Change Start
        var action1 = component.get("c.exceptionRequestCheck");
		var oppyId = component.get("v.recordId");
        action1.setParams({
            "oppyId":oppyId
        });
        action1.setCallback(this, function(response) {
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
                    var action = component.get("c.checkRecordAccessforUser");
        			var userId = $A.get("$SObjectType.CurrentUser.Id");
					var oppyId = component.get("v.recordId");
        			console.log("oppyid=>"+oppyId);
					console.log('userid'+userId);
					helper.isCommunity(component);
        			action.setParams({
            			"usrId":userId,
            			"recordId":oppyId,
            			"actionType":"Add Products"
        			});
        			action.setCallback(this, function(response) {
            			if (response.getState() == 'SUCCESS') {
                			console.log('response'+response.getReturnValue());
                			if(response.getReturnValue().isSuccess) {
                    			var isCommunity = component.get("v.isCommunity");
                    			console.log("isCommunity=>"+isCommunity);
                    			if(isCommunity) {
                        			helper.navigateCommunity(oppyId);
                    			} else {
                        			helper.navigateLEX(component,oppyId);
                    			}
                			} else {
                    				var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    				dismissActionPanel.fire();
                                    var toastEvent = $A.get("e.force:showToast");
                    				toastEvent.setParams({
                        				"title": "Insufficient Access",
                        				"message":response.getReturnValue().validationMessage,
                        				"mode":"dismissible",
                        				"type":"error",
                        				"duration":"3000"
                    				});
                    				toastEvent.fire();
                    				return;
                				}
        					}
        			});
                $A.enqueueAction(action);
        //SFDC-4731 Change Start        
                }
        	}
        });
        $A.enqueueAction(action1);
        //SFDC-4731 Change End
	}
})

/*({
	init : function(cmp, event, helper) {
        var navService = cmp.find("navService");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__RedirectEditProductLWC'
            },
            state : {
                c__recordId : cmp.get('v.recordId'),
                c__actionname : cmp.get('v.quickActionName')
            }
        };        
         navService.navigate(pageReference);
    }
})*/