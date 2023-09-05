({
	doInit : function(component) {
        var action = component.get("c.checkAssignment");
        action.setParams({ licenseName : component.get("v.licenseName") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isAssigned",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})