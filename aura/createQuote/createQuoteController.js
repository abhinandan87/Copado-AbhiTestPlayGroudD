({
	doInit : function(component, event, helper) {
		var action = component.get("c.getOptyAndSessionId");
		var oppyId = component.get("v.recordId");
        action.setParams({
            "oppyId":oppyId
        });
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                var opp = result.oppy;
                if(opp.LegalEntity__c == null || opp.ExceptionStatus__c == 'Exception Requested' || opp.ExceptionStatus__c == 'Exception Request Denied'){
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message":"You can't create a Quote without a legal entity on Opportunity or until exception request is approved",
                        "mode":"dismissible",
                        "type":"error",
                        "duration":"3000"
                    });
                    toastEvent.fire();
                    return;
                }
                else{
                    var sessionid = result.sessionid;
                    var urlEvent = $A.get("e.force:navigateToURL");
    				urlEvent.setParams({
      					"url":  "/apex/loop__looplus?eid=" + oppyId + 
                        		"&accountId=" + opp.AccountId + 
                        		"&sessionId=" + sessionid + 
                        		"&filter=Quote&hidecontact=true"
    				});
    				urlEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
	}
})