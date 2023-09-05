({
    closeQA: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'The record has been created successfully.',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    cancelQA: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    doInit : function (component, event, helper) {
    var action = component.get("c.getProfile");
    action.setParams({});
    action.setCallback(this,function(a) {
    component.set("v.profile",a.getReturnValue());} );
        
    $A.enqueueAction(action);    
 }
 })