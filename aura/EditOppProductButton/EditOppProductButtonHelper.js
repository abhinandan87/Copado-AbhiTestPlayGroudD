({
    isCommunity : function(component) {
        
        var action = component.get("c.isCommunity");
        var oppyId = component.get("v.recordId");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue();          
            if(isCommunity) {                
                this.navigateCommunity(oppyId);
            } else {
                this.navigateLEX(component,oppyId);
            }
        });
        $A.enqueueAction(action);
    },
    navigateLEX : function(component,oppyId) {        
       var navService = component.find("navService");
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__RedirectAddEditProductScreen'
            },
            state : {
                c__recordId : component.get('v.recordId'),
                c__actionname : component.get('v.quickActionName')
            }
        };        
         navService.navigate(pageReference);
    },
    navigateCommunity : function(oppyId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/edit-opportunity-products?recordId="+oppyId,
            "isredirect":true
        });
        urlEvent.fire();
    },
    checkRecordAccess : function(component) {
        var action = component.get("c.checkRecordAccessforUser");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var oppyId = component.get("v.recordId");
        console.log("oppyid=>"+oppyId);
        console.log('userid'+userId);
        action.setParams({
            "usrId":userId,
            "recordId":oppyId,
            "actionType":"Edit Products"
        });
        console.log("entered into doinit");
        action.setCallback(this, function(response) {
            if (response.getState() == 'SUCCESS') {
                console.log('response'+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue().isSuccess) {
                    var isCommunity = component.get("v.isCommunity");
                    console.log("isCommunity=>"+isCommunity);
                    //first validate for auto renewal
                    // removed community code as we do not user community anymore              
                    this.navigateLEX(component,oppyId);//removed community code as it is no longer needed
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
    }
})