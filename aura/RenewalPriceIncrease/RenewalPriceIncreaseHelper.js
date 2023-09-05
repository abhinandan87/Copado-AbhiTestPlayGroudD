({
    validate : function(component,event) {
        console.log('--validating--');
        try {
            let oppyObject=component.get("v.opportunityObject");
            console.log('==validating loaded record=='+JSON.stringify(oppyObject));
            if(oppyObject.AutoRenewal__c===false) {
                component.set("v.hasErrors",true);
                component.set("v.errorMessage",$A.get("$Label.c.OppyIsNotAutoRenewal"));
                component.set("v.hasRecordLoaded",true);
                return;
            }
            if(oppyObject.DoesThisAutoRenewalHaveChanges__c===true) {
                console.log('==first if==');
                component.set("v.hasErrors",true);
                component.set("v.errorMessage",$A.get("$Label.c.OppyisAlreadyTagged"));
                component.set("v.hasRecordLoaded",true);
                console.log('==first if exit==');
                return;
            }
            if(oppyObject.PriceChangeOnly__c===true) {
                //initialize the radio button in case it is already price increase
                component.set("v.renewalAmendType",'PriceChange');
            }
            console.log('==outside if==');
            component.set("v.hasErrors",false);
            component.set("v.hasRecordLoaded",true);
        } catch (error) {
            console.log('==inside catch==');
            component.set("v.hasErrors",true);
            component.set("v.errorMessage","An error occurred while validating"+JSON.stringify(error));
        }
        
        //if(oppyObject.)
    },
    showToast : function(title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type":type
        });
        toastEvent.fire();
    },
    closeModal : function(component,event) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})