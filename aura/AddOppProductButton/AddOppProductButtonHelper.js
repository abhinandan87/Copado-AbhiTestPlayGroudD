({
    isCommunity : function(component) {
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunity",isCommunity);
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
       /* console.log("navigateTOUrl");
        console.log("oppyId"+oppyId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/product-selector?recordId="+oppyId,
            "isredirect":true
        });
        urlEvent.fire();*/
    }
})