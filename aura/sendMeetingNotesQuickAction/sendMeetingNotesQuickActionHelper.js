({
    validateMeetingOutcome : function(component) {
        console.log('--calling server--');
        var action = component.get("c.hasMeetingOutcome");
        action.setParams({ eventId : component.get("v.recordId") });
        console.log('--setting callback call--');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('--success--');
                let result = response.getReturnValue();
                if(result === 'Validated') {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:sendMeetingNotes",
                        componentAttributes: {
                            "recordId" : component.get("v.recordId"),
                        }
                    });
                    evt.fire();
                } else {
                    this.showToast('Error!!',result,'error');
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('--incomplete--');
                this.showToast('Error!!','Something went wrong!!','error');
                $A.get("e.force:closeQuickAction").fire();
                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        this.showToast('Error!!',errors[0].message,'error');
                        $A.get("e.force:closeQuickAction").fire();
                    }
                } else {
                    console.log("Unknown error");
                    this.showToast('Error!!','Unknown error occurred','error');
                        $A.get("e.force:closeQuickAction").fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type":type
        });
        toastEvent.fire();
    }
})