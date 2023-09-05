({
    closeQA: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success',
            message: 'The record has been updated successfully.',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    closepage: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})