({
	isCommunity : function(component) {
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunity",isCommunity);
        });
        $A.enqueueAction(action);
    },
	callToServer : function(component, method, callback, params) {
		var action = component.get(method);
        if(params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR") {
                var errors = response.getError();
                alert(errors[0].message);
            }
        });
		$A.enqueueAction(action);
    }
})