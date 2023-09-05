({
	toggleSpinner : function(component) {
		var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        $A.util.toggleClass(spinner, "slds-show");
	},
	showToast : function(title, message, type) {
	var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title":title,
        "message": message,
        "type":type
    });
    toastEvent.fire();
	},
    changeButtonText : function(component,buttonText) {
        component.set("v.buttonText",buttonText);
        window.setTimeout(function() {
            component.set("v.buttonText","Save");
        }, 5000);
    }
})